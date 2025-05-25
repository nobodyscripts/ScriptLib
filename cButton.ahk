#Requires AutoHotkey v2.0

#Include cPoint.ahk

/**
 * cButton Class, extends cPoint with button related colour checking
 * @module cButton
 * @property {String} Active Active button colour (excluding text)
 * @property {String} ActiveMouseOver Active button colour when mouse over

 * @property {String} Inactive Inactive button colour
 * @property {String} Background Background window main colour
 * @method IsButton 
 * @method IsMouseOver
 * @method IsButtonActive
 * @method IsButtonInactive
 * @method IsColourMatch Matches on any colour property
 * @method IsBackground
 * @method ColourToUserString
 */
Class cButton extends cPoint {
    /** 0xFFFFFF
     * @type {String} */
    Active := ""
    /** 0xFFFFFF
     *  @type {String} */
    ActiveMouseOver := ""
    /** 0xFFFFFF
     * @type {String} */
    Inactive := ""
    /** 0xFFFFFF
     * @type {String} */
    Background := ""
    /** 0xFFFFFF
     * @type {String} */
    ActiveSelected := ""
    /** 0xFFFFFF
     * @type {String} */
    InactiveSelected := ""

    ;@region Button methods
    ;@region IsButton()
    /**
     * Is the provided colour a LBR button
     * @param colour 
     * @returns {Integer} true/false
     */
    IsButton(colour) {
        colour := this.GetColour()
        If (colour = this.Active || colour = this.ActiveMouseOver ||
            colour = this.ActiveSelected || colour = this.Inactive ||
            colour = this.InactiveSelected) {
            Return true
        }
        Return false
    }
    ;@endregion

    ;@region IsMouseOver()
    /**
     * Is the provided colour a button in mouseover state
     * @returns {Integer} true/false
     */
    IsMouseOver() {
        colour := this.GetColour()
        If (colour = this.ActiveMouseOver) {
            Return true
        }
        Return false
    }
    ;@endregion

    ;@region IsButtonActive()
    /**
     * Is the provided colour a button in active state
     * @returns {Integer} true/false
     */
    IsButtonActive() {
        colour := this.GetColour()
        If (colour = this.Active || colour = this.ActiveMouseOver || colour =
            this.ActiveSelected) {
            Return true
        }
        Return false
    }
    ;@endregion

    ;@region IsButtonInactive()
    /**
     * Is the provided colour a button in inactive state
     * @returns {Integer} true/false
     */
    IsButtonInactive() {
        colour := this.GetColour()
        If (colour = this.Inactive || colour = this.InactiveSelected) {
            Return true
        }
        Return false
    }
    ;@endregion

    ;@region IsColourNotMatch()
    /**
     * Is the provided colour a button or background
     * @returns {Integer} true/false
     */
    IsColourMatch() {
        colour := this.GetColour()
        If (colour = this.Active || colour = this.ActiveMouseOver || colour = this
            .Inactive || colour = this.Background || colour = this.ActiveSelected || colour = this.InactiveSelected
        ) {
            Return false
        }
        Return true
    }
    ;@endregion
    ;@endregion

    ;@region IsBackground()
    /**
     * Is the provided colour the background panel colour
     * @returns {Integer} true/false
     */
    IsBackground() {
        If (this.GetColour() = this.Background) {
            Return true
        }
        Return false
    }
    ;@endregion

    ;@region ColourToUserString()
    /**
     * Returns a user interface formatted string of the matching colour
     */
    ColourToUserString() {
        col := this.GetColour()
        Switch (col) {
        Case this.Active:
            Return "Active button"
        Case this.ActiveMouseOver:
            Return "Active, mouse over button"
        Case this.Inactive:
            Return "Inactive button"
        Case this.Background:
            Return "Panel background"
        Case this.ActiveSelected:
            Return "Active, selected button"
        Case this.InactiveSelected:
            Return "Inactive, selected button"

        default: Return "Unknown colour: " col
        }
    }
;@endregion
}
