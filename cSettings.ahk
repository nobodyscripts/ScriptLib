#Requires AutoHotkey v2.0

#Include cLogging.ahk
#Include Misc.ahk

; ------------------- Settings -------------------
; Loads UserSettings.ini values for the rest of the script to use
If (!IsSet(S)) {
    Global S := cSettings()
}
/**
 * Single instance of a script setting object
 * @property Name Name of the setting and global var name
 * @property DefaultValue Default value for non developers
 * @property NobodyDefaultValue Default value for developer
 * @property DataType Internal custom datatype string {bool | int | array}
 * @property Category Ini file category heading
 * @method __new Constructor
 * @method ValueToString Converts value to file writable string
 * @method SetCommaDelimStrToArr Set global of this.Name to an array of value
 * split by comma
 */
Class singleSetting {
    ;@region Properties
    /**
     * Name of the setting and global var name
     * @type {String} 
     */
    Name := ""
    /**
     * Value for this setting
     * @type {String | Integer | Any} 
     */
    Value := ""
    /**
     * Default value for non developers
     * @type {String | Integer | Any} 
     */
    DefaultValue := 0
    /**
     * Internal custom datatype string
     * @type {String} 
     */
    DataType := "bool"
    /**
     * Ini file category heading
     * @type {String} 
     */
    Category := "Default"
    ;@endregion

    ;@region __new()
    /**
     * Constructs class and provides object back, has defaults for all except 
     * iName
     * @constructor
     * @param iName Name of the setting and global var
     * @param {Integer} iDefaultValue Default value set in script
     * @param {Integer} iNobodyDefaultValue Default value set for developer
     * @param {String} [iDataType="bool"] Internal custom datatype
     * @param {String} [iCategory="Default"] Ini file section heading name
     * @returns {singleSetting} Returns (this)
     */
    __New(iName, iDefaultValue := 0, iDataType :=
        "bool", iCategory := "Default") {
        this.Name := iName
        this.DefaultValue := iDefaultValue
        this.Value := iDefaultValue
        this.DataType := iDataType
        this.Category := iCategory
        Return this
    }
    ;@endregion

    ;@region ValueToString()
    /**
     * Convert value to file writable string
     * @param {Any} value Defaults to getting value of the global variable
     * @returns {String | Integer | Any} 
     */
    ValueToString(value := %this.Name%) {
        Switch (StrLower(this.DataType)) {
        Case "bool":
            Return BinaryToStr(value)
        Case "array":
            Return ArrToCommaDelimStr(value)
        default:
            Return value
        }
    }
    ;@endregion

    ;@region SetCommaDelimStrToArr()
    /**
     * Set global of this.Name to an array of value split by comma
     * @param var Value comma seperated string to split into array
     */
    SetCommaDelimStrToArr(var) {
        %this.Name% := StrSplit(var, " ", ",.")
    }
    ;@endregion
}

/**
 * cSettings - Stores settings data
 * @property sFilename Full file path to ini file for settings
 * @property sFileSection Ini section heading for settings
 * @property Map Map to store singleSettings objects per global var name
 * @method initSettings Load Map with defaults, check if file, load if possible,
 * return loaded state
 * @method loadSettings Load script settings into global vars, runs UpdateSettings
 * first to add missing settings rather than reset to defaults if some settings
 * exist
 * @method UpdateSettings Adds missing settings using defaults if some settings 
 * don't exist
 * @method WriteDefaults Write default settings to ini file, does not wipe other
 * removed settings
 * @method SaveCurrentSettings Save current Map to ini file converting to format
 * safe for storage
 * @method WriteToIni Write (key, value) to ini file within (section) heading
 * @method IniToVar Reads ini value for (name) in (section) from (file) and 
 * returns as string or Boolean
 */
Class cSettings {
    ;@region Properties
    /**
     * Full file path to ini file for settings
     * @type {String} 
     */
    sFilename := A_ScriptDir "\UserSettings.ini"
    /**
     * Ini section heading for settings
     * @type {String}
     */
    sFileSection := "Default"
    /**
     * Map to store singleSettings objects per global var name
     * @type {Map<string, singleSetting>}
     */
    Map := Map()
    ;@endregion

    __New() {
        this.AddSetting("Default", "EnableLogging", false, "bool")
        this.AddSetting("Default", "TimestampLogs", true, "bool")

        this.AddSetting("Updates", "CheckForUpdatesEnable", true, "bool")
        this.AddSetting("Updates", "CheckForUpdatesReleaseOnly", true, "bool")
        this.AddSetting("Updates", "CheckForUpdatesLastCheck", 0, "int")

        this.AddSetting("Debug", "Debug", false, "bool")
        this.AddSetting("Debug", "Verbose", false, "bool")
        this.AddSetting("Debug", "LogBuffer", true, "bool")
    }

    ;@region AddSetting()
    /**
     * Add a setting to the class to track and update
     */
    AddSetting(section, Name, default, type) {
        this.Map[Name] := singleSetting(Name, default, type, section)
    }
    ;@endregion

    ;@region Get()
    /**
     * Get value by setting name
     */
    Get(Name) {
        Return this.Map[Name].Value
    }
    ;@endregion

    ;@region Set()
    /**
     * Get value by setting name
     */
    Set(Name, value) {
        this.Map[Name].Value := value
    }
    ;@endregion

    ;@region GetDefault()
    /**
     * Get default value by setting name
     */
    GetDefault(Name) {
        Return this.Map[Name].DefaultValue
    }
    ;@endregion

    ;@region initSettings()
    /**
     * Load Map with defaults, check if file, load if possible, return loaded 
     * state
     * @param {Integer} secondary Is script the main script or a spammer (for 
     * paths)
     * @returns {Boolean} 
     */
    initSettings(secondary := false) {
        Global Debug

        ;@region Settings map initialization

        ;@endregion

        If (!secondary) {
            If (FileExist(A_ScriptDir "\IsNobody")) {
                Debug := true
                Out.I("Settings: Nobody mode, forced debug")
            }
            If (!FileExist(this.sFilename)) {
                Out.I("No UserSettings.ini found, writing default file.")
                this.WriteDefaults()
            }
            If (this.loadSettings()) {
                UpdateDebugLevel()
                Out.I("Loaded settings.")
            } Else {
                Return false
            }
            Return true
        } Else {
            this.sFilename := A_ScriptDir "\..\UserSettings.ini"
            If (this.loadSettings()) {
                UpdateDebugLevel()
                Out.I("Loaded settings.")
            } Else {
                Return false
            }
            Return true
        }
    }
    ;@endregion

    ;@region loadSettings()
    /**
     * Load script settings into global vars, runs UpdateSettings first to add
     * missing settings rather than reset to defaults if some settings exist
     * @returns {Boolean} False if error
     */
    loadSettings() {
        ;@region Globals
        Global Debug := false
        ;@endregion

        this.UpdateSettings()
        For (setting in this.Map) {
            Try {
                If (StrLower(this.Map[setting].DataType) != "array") {
                    value := this.IniToVar(this.Map[setting].Name,
                        this.Map[setting].Category)
                    this.Set(this.Map[setting].Name, value)

                } Else {
                    ; special handling for array datatypes
                    value := CommaDelimStrToArr(this.IniToVar(this.Map[setting].Name,
                        this.Map[setting].Category))
                    this.Set(this.Map[setting].Name, value)
                }
            } Catch As exc {
                If (exc.Extra) {
                    Out.E("LoadSettings failed - " exc.Message "`n" exc
                        .Extra)
                } Else {
                    Out.E("LoadSettings failed - " exc.Message)
                }
                MsgBox("Could not load all settings, making new default " .
                    this.sFilename)
                Out.I("Attempting to write a new default " this.sFilename ".")
                this.WriteDefaults()
                Return false
            }
        }
        Return true
    }
    ;@endregion

    ;@region UpdateSettings()
    /**
     * Adds missing settings using defaults if some settings don't exist
     */
    UpdateSettings() {
        For (setting in this.Map) {
            this.WriteToIni(this.Map[setting].Name)
        }
    }
    ;@endregion

    ;@region WriteDefaults()
    /**
     * Write default settings to ini file, does not wipe other removed settings
     */
    WriteDefaults() {
        For (setting in this.Map) {
            this.Set(setting, this.Map[setting].DefaultValue)
            this.WriteToIni(this.Map[setting].Name)
        }
    }
    ;@endregion

    ;@region SaveCurrentSettings()
    /**
     * Save current Map to ini file converting to format safe for storage
     */
    SaveCurrentSettings() {
        For (setting in this.Map) {
            this.WriteToIni(this.Map[setting].Name)
        }
    }
    ;@endregion

    ;@region WriteToIni()
    /**
     * Write (key, value) to ini file within (section) heading
     * @param key Name of setting
     * @param value Value of setting
     * @param {String} [section="Default"] 
     */
    WriteToIni(Name) {
        value := this.Map[Name].ValueToString(),
        fn := this.sFilename,
        cat := this.Map[Name].Category
        Try {
            storedVal := IniRead(fn, cat, Name)
        } Catch Error {
        }
        If (!IsSet(storedVal)) {
            IniWrite(value, this.sFilename, cat, Name)
            Return
        }
        If (storedVal != value) {
            IniWrite(value, this.sFilename, cat, Name)
        }
    }
    ;@endregion

    ;@region IniToVar()
    /**
     * Reads ini value for (name) in (section) from (file) and returns as 
     * string or Boolean
     * @param name 
     * @param {String} section 
     * @param {String} file 
     * @returns {Integer | String} 
     */
    IniToVar(name, section := this.sFileSection, file := this.sFilename) {
        var := IniRead(file, section, name)
        Switch var {
        Case "true":
            Return true
        Case "false":
            Return false
        default:
            Return var
        }
    }
    ;@endregion
}
