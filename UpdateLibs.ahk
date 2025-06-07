#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 8
#SingleInstance Force

#Include cLogging.ahk
#Include cSettings.ahk

/** @type {cLog} */
Out := cLog(A_ScriptDir "\Secondaries.log", true, 3, false)

S.initSettings()

UpdateLibs()

;@region UpdateLibs()
UpdateLibs(*) {
    Try {
        HasPressed := MsgBox("Update all scriptlib folders?",
            "Update folders?", "0x1 0x100 0x10")
        If (HasPressed = "OK") {
            UpdateFolders := ["..\LeafBlowerScript\ScriptLib",
                "..\LBRSaveManager\ScriptLib",
                "..\wizardswheel2script\ScriptLib",
                "..\WW2SaveManager\ScriptLib",
                "..\MacroCreator\ScriptLib"]
            For (folder in UpdateFolders) {
                If (DirExist(folder)) {
                    ; Wipe any file first
                    DirDelete(A_ScriptDir "\" folder, 1)
                    DirCreate(A_ScriptDir "\" folder)

                    FileCopy(A_ScriptDir "\*.ahk", A_ScriptDir "\" folder, 1)
                    FileCopy(A_ScriptDir "\*.md", A_ScriptDir "\" folder, 1)
                    FileCopy(A_ScriptDir "\*.json", A_ScriptDir "\" folder, 1)
                    
                    DirCopy(A_ScriptDir "\ExtLibs", A_ScriptDir "\" folder "\ExtLibs", 1)
                }
            }
        }
    } Catch Error As OutputVar {
        Out.E(OutputVar)
    }
}
;@endregion
