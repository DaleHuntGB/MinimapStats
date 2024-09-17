local _, MS = ...
local MSGUI = LibStub:GetLibrary("AceGUI-3.0")
local GUI_W = 910
local GUI_H = 610

local LSM = LibStub("LibSharedMedia-3.0")
local LSMFonts = {}
MS.isGUIOpen = false
MS.ShowDiffID = false

function MS:GenerateLSMFonts()
    local Fonts = LSM:HashTable("font")
    for Path, Font in pairs(Fonts) do
        LSMFonts[Font] = Path
    end
    return LSMFonts
end

function MS:ToggleFont(Shown)
    return Shown and "|cFF40FF40Active|r" or "|cFFFF4040Inactive|r"
end

function MS:SetUpdateIntervalLabel(Interval)
    if Interval <= 3 then
        return "Update Interval (Seconds) [|cFFFF4040CPU Intensive|r]"
    else
        return "Update Interval (Seconds)"
    end
end

function MS:CreateGUI()
    if MS.isGUIOpen then return end
    local MSGUI_Container = MSGUI:Create("Window")
    MSGUI_Container:SetTitle("|TInterface\\AddOns\\MinimapStats\\Media\\LogoHeader:24:120|t")
    MSGUI_Container:SetLayout("Fill")
    MSGUI_Container:SetWidth(GUI_W)
    MSGUI_Container:SetHeight(GUI_H)
    MSGUI_Container:EnableResize(false)
    MSGUI_Container:SetCallback("OnClose", function(widget) MSGUI:Release(widget) MS.isGUIOpen = false MS.ShowDiffID = false MS:UpdateInstanceDifficultyFrame() end)
    MS.isGUIOpen = true

    local function DrawGeneralContainer(MSGUI_Container)
        local FontFlagOptions = { ["NONE"] = "NONE", ["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME" }
        local FontFlagOrder = { "NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME" }
        local ElementFrameStrataOptions = { ["BACKGROUND"] = "BACKGROUND", ["LOW"] = "LOW", ["MEDIUM"] = "MEDIUM", ["HIGH"] = "HIGH", ["DIALOG"] = "DIALOG", ["FULLSCREEN"] = "FULLSCREEN", ["FULLSCREEN_DIALOG"] = "FULLSCREEN_DIALOG", ["TOOLTIP"] = "TOOLTIP" }
        local ElementFrameStrataOrder = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }
        local ResetDefaultsOptions = { ["Select"] = "Select...", ["Everything"] = "Reset Everything", ["General"] = "Reset General Options", ["Time"] = "Reset Time Options", ["System Stats"] = "Reset System Stats Options", ["Location"] = "Reset Location Options", ["Coordinates"] = "Reset Coordinates Options", ["Instance Difficulty"] = "Reset Instance Difficulty Options", ["Tooltip"] = "Reset Tooltip Options" }
        local ResetDefaultsOrder = { "Everything", "General", "Time", "System Stats", "Location", "Coordinates", "Instance Difficulty", "Tooltip" }
        local GeneralOptionsContainer = MSGUI:Create("InlineGroup")
        GeneralOptionsContainer:SetTitle("General Options")
        GeneralOptionsContainer:SetLayout("Flow")
        GeneralOptionsContainer:SetFullWidth(true)

        local ElementFrameStrataDropdown = MSGUI:Create("Dropdown")
        ElementFrameStrataDropdown:SetLabel("Frame Strata")
        ElementFrameStrataDropdown:SetList(ElementFrameStrataOptions, ElementFrameStrataOrder)
        ElementFrameStrataDropdown:SetValue(MS.DB.global.ElementFrameStrata)
        ElementFrameStrataDropdown:SetCallback("OnValueChanged",
            function(_, _, Value) 
            MS.DB.global.ElementFrameStrata = Value
            MS:UpdateAllElements()
        end)
        ElementFrameStrataDropdown:SetCallback("OnEnter", 
            function() 
            GameTooltip:SetOwner(ElementFrameStrataDropdown.frame, "ANCHOR_NONE") 
            GameTooltip:SetPoint("TOPRIGHT", ElementFrameStrataDropdown.frame, "BOTTOMRIGHT", 0, -1) 
            GameTooltip:SetText("Adjust the layer at which elements are drawn.") 
        end)
        ElementFrameStrataDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        ElementFrameStrataDropdown:SetRelativeWidth(0.5)

        local ResetDefaultsDropdown = MSGUI:Create("Dropdown")
        ResetDefaultsDropdown:SetLabel("Reset Options")
        ResetDefaultsDropdown:SetList(ResetDefaultsOptions, ResetDefaultsOrder)
        ResetDefaultsDropdown:SetValue("Select")
        ResetDefaultsDropdown:SetCallback("OnValueChanged", 
            function(_, _, Value)
            if Value == "Everything" then
                MS.DB:ResetDB()
                print(MS.ADDON_NAME .. ": All Options Reset!")
            elseif Value == "General" then
                MS:ResetGeneralOptions()
                MSGUI_Container:ReleaseChildren()
                DrawGeneralContainer(MSGUI_Container)
                print(MS.ADDON_NAME .. ": General Options Reset!")
            elseif Value == "Time" then
                MS:ResetTimeOptions()
                print(MS.ADDON_NAME .. ": Time Options Reset!")
            elseif Value == "System Stats" then
                MS:ResetSystemStatsOptions()
                print(MS.ADDON_NAME .. ": System Stats Options Reset!")
            elseif Value == "Location" then
                MS:ResetLocationOptions()
                print(MS.ADDON_NAME .. ": Location Options Reset!")
            elseif Value == "Coordinates" then
                MS:ResetCoordinatesOptions()
                print(MS.ADDON_NAME .. ": Coordinates Options Reset!")
            elseif Value == "Instance Difficulty" then
                MS:ResetInstanceDifficultyOptions()
                print(MS.ADDON_NAME .. ": Instance Difficulty Options Reset!")
            elseif Value == "Tooltip" then
                MS:ResetTooltipOptions()
                print(MS.ADDON_NAME .. ": Tooltip Options Reset!")
            end
            MS:UpdateAllElements()
            ResetDefaultsDropdown:SetValue("Select")
        end)
        ResetDefaultsDropdown:SetCallback("OnEnter", 
            function() 
            GameTooltip:SetOwner(ResetDefaultsDropdown.frame, "ANCHOR_NONE") 
            GameTooltip:SetPoint("TOPRIGHT", ResetDefaultsDropdown.frame, "BOTTOMRIGHT", 0, -1) 
            GameTooltip:SetText("Reset the selected options to their default values.") 
        end)
        ResetDefaultsDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        ResetDefaultsDropdown:SetRelativeWidth(0.5)

        local ColourOptionsContainer = MSGUI:Create("InlineGroup")
        ColourOptionsContainer:SetTitle("Colour Options")
        ColourOptionsContainer:SetLayout("Flow")
        ColourOptionsContainer:SetFullWidth(true)

        local FontColourColourPicker = MSGUI:Create("ColorPicker")
        FontColourColourPicker:SetLabel("Font Colour")
        FontColourColourPicker:SetColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
        FontColourColourPicker:SetCallback("OnValueChanged", function(_, _, R, G, B) MS.DB.global.FontColourR = R MS.DB.global.FontColourG = G MS.DB.global.FontColourB = B MS:UpdateAllElements() end)
        FontColourColourPicker:SetRelativeWidth(0.33)
        
        local AccentColourColourPicker = MSGUI:Create("ColorPicker")
        AccentColourColourPicker:SetLabel("Accent Colour")
        AccentColourColourPicker:SetColor(MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
        AccentColourColourPicker:SetDisabled(MS.DB.global.ClassAccentColour)
        AccentColourColourPicker:SetCallback("OnValueChanged", 
            function(_, _, R, G, B)
            MS.DB.global.AccentColourR = R
            MS.DB.global.AccentColourG = G
            MS.DB.global.AccentColourB = B
            -- Store Previously Set Colour.
            MS.DB.global.SavedAccentColourR = R
            MS.DB.global.SavedAccentColourG = G
            MS.DB.global.SavedAccentColourB = B
            MS:SetAccentColour()
            MS:UpdateAllElements()
        end)
        AccentColourColourPicker:SetRelativeWidth(0.33)

        local ClassAccentColourCheckbox = MSGUI:Create("CheckBox")
        ClassAccentColourCheckbox:SetLabel("Class Accent Colour")
        ClassAccentColourCheckbox:SetValue(MS.DB.global.ClassAccentColour)
        ClassAccentColourCheckbox:SetCallback("OnValueChanged", 
            function(_, _, Value) MS.DB.global.ClassAccentColour = Value 
            MS:SetAccentColour()
            AccentColourColourPicker:SetColor(MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
            if MS.DB.global.ClassAccentColour then 
                AccentColourColourPicker:SetDisabled(true)
            else
                AccentColourColourPicker:SetDisabled(false)
            end
            MS:UpdateAllElements()
        end)
        ClassAccentColourCheckbox:SetRelativeWidth(0.33)

        local FontOptionsContainer = MSGUI:Create("InlineGroup")
        FontOptionsContainer:SetTitle("Font Options")
        FontOptionsContainer:SetLayout("Flow")
        FontOptionsContainer:SetFullWidth(true)
        FontOptionsContainer:SetFullWidth(true)

        local FontFaceDropdown = MSGUI:Create("Dropdown")
        FontFaceDropdown:SetLabel("Font Face")
        FontFaceDropdown:SetList(MS:GenerateLSMFonts())
        FontFaceDropdown:SetValue(MS.DB.global.FontFace)
        FontFaceDropdown:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.FontFace = Value MS:UpdateAllElements() end)
        FontFaceDropdown:SetRelativeWidth(0.5)

        local FontFlagDropdown = MSGUI:Create("Dropdown")
        FontFlagDropdown:SetLabel("Font Flag")
        FontFlagDropdown:SetList(FontFlagOptions, FontFlagOrder)
        FontFlagDropdown:SetValue(MS.DB.global.FontFlag)
        FontFlagDropdown:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.FontFlag = Value MS:UpdateAllElements() end)
        FontFlagDropdown:SetRelativeWidth(0.5)

        local ShadowOptionsContainer = MSGUI:Create("InlineGroup")
        ShadowOptionsContainer:SetTitle("Shadow Options")
        ShadowOptionsContainer:SetLayout("Flow")
        ShadowOptionsContainer:SetFullWidth(true)

        local ShadowColourColourPicker = MSGUI:Create("ColorPicker")
        ShadowColourColourPicker:SetLabel("Shadow Colour")
        ShadowColourColourPicker:SetColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB)
        ShadowColourColourPicker:SetDisabled(not MS.DB.global.FontShadow)
        ShadowColourColourPicker:SetCallback("OnValueChanged", function(_, _, R, G, B) MS.DB.global.ShadowColorR = R MS.DB.global.ShadowColorG = G MS.DB.global.ShadowColorB = B MS:UpdateAllElements() end)
        ShadowColourColourPicker:SetRelativeWidth(0.5)

        local FontShadowOffsetX = MSGUI:Create("Slider")
        FontShadowOffsetX:SetLabel("Shadow Offset X")
        FontShadowOffsetX:SetValue(MS.DB.global.ShadowOffsetX)
        FontShadowOffsetX:SetDisabled(not MS.DB.global.FontShadow)
        FontShadowOffsetX:SetSliderValues(-10, 10, 1)
        FontShadowOffsetX:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.ShadowOffsetX = Value MS:UpdateAllElements() end)
        FontShadowOffsetX:SetRelativeWidth(0.5)
        
        local FontShadowOffsetY = MSGUI:Create("Slider")
        FontShadowOffsetY:SetLabel("Shadow Offset Y")
        FontShadowOffsetY:SetValue(MS.DB.global.ShadowOffsetY)
        FontShadowOffsetY:SetDisabled(not MS.DB.global.FontShadow)
        FontShadowOffsetY:SetSliderValues(-10, 10, 1)
        FontShadowOffsetY:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.ShadowOffsetY = Value MS:UpdateAllElements() end)
        FontShadowOffsetY:SetRelativeWidth(0.5)

        local FontShadowCheckbox = MSGUI:Create("CheckBox")
        FontShadowCheckbox:SetLabel("Font Shadow")
        FontShadowCheckbox:SetValue(MS.DB.global.FontShadow)
        FontShadowCheckbox:SetCallback("OnValueChanged", 
            function(_, _, Value)
            MS.DB.global.FontShadow = Value
            MS:UpdateAllElements()
            if MS.DB.global.FontShadow then
                FontShadowOffsetX:SetDisabled(false)
                FontShadowOffsetY:SetDisabled(false)
                ShadowColourColourPicker:SetDisabled(false)
            else
                FontShadowOffsetX:SetDisabled(true)
                FontShadowOffsetY:SetDisabled(true)
                ShadowColourColourPicker:SetDisabled(true)
            end
            MSGUI_Container:DoLayout()
        end)
        FontShadowCheckbox:SetRelativeWidth(0.5)

        MSGUI_Container:AddChild(GeneralOptionsContainer)
        GeneralOptionsContainer:AddChild(ElementFrameStrataDropdown)
        GeneralOptionsContainer:AddChild(ResetDefaultsDropdown)
        MSGUI_Container:AddChild(ColourOptionsContainer)
        ColourOptionsContainer:AddChild(FontColourColourPicker)
        ColourOptionsContainer:AddChild(AccentColourColourPicker)
        ColourOptionsContainer:AddChild(ClassAccentColourCheckbox)
        MSGUI_Container:AddChild(FontOptionsContainer)
        FontOptionsContainer:AddChild(FontFaceDropdown)
        FontOptionsContainer:AddChild(FontFlagDropdown)
        FontOptionsContainer:AddChild(ShadowOptionsContainer)
        ShadowOptionsContainer:AddChild(FontShadowCheckbox)
        ShadowOptionsContainer:AddChild(ShadowColourColourPicker)
        ShadowOptionsContainer:AddChild(FontShadowOffsetX)
        ShadowOptionsContainer:AddChild(FontShadowOffsetY)

    end

    local function DrawTimeContainer(MSGUI_Container)
        local DateOptions = { ["DD/MM/YY"] = "DD/MM/YY", ["MM/DD/YY"] = "MM/DD/YY", ["YY/MM/DD"] = "YY/MM/DD", ["01 Jan 2020"] = "01 Jan 2020", ["Jan 01, 2020"] = "Jan 01, 2020"}
        local DateOrder = { "DD/MM/YY", "MM/DD/YY", "YY/MM/DD", "01 Jan 2020", "Jan 01, 2020" }
        local TimeOptionsContainer = MSGUI:Create("InlineGroup")
        TimeOptionsContainer:SetTitle("General Options")
        TimeOptionsContainer:SetLayout("Flow")
        TimeOptionsContainer:SetFullWidth(true)

        local TimeTypeDropdown = MSGUI:Create("Dropdown")
        TimeTypeDropdown:SetLabel("Source")
        TimeTypeDropdown:SetList({ ["LOCAL"] = "Local Time", ["SERVER"] = "Server / Game Time" })
        TimeTypeDropdown:SetValue(MS.DB.global.TimeType)
        TimeTypeDropdown:SetDisabled(not MS.DB.global.ShowTimeFrame)
        TimeTypeDropdown:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TimeType = Value MS:UpdateTimeFrame() end)
        TimeTypeDropdown:SetRelativeWidth(0.5)

        local TimeFormatDropdown = MSGUI:Create("Dropdown")
        TimeFormatDropdown:SetLabel("Format")
        TimeFormatDropdown:SetList({ ["12H"] = "12 Hour [00:00 AM]", ["24H"] = "24 Hour [00:00]" })
        TimeFormatDropdown:SetValue(MS.DB.global.TimeFormat)
        TimeFormatDropdown:SetDisabled(not MS.DB.global.ShowTimeFrame)
        TimeFormatDropdown:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TimeFormat = Value MS:UpdateTimeFrame() end)
        TimeFormatDropdown:SetRelativeWidth(0.5)

        local TimeFontSizeSlider = MSGUI:Create("Slider")
        TimeFontSizeSlider:SetLabel("Font Size")
        TimeFontSizeSlider:SetValue(MS.DB.global.TimeFontSize)
        TimeFontSizeSlider:SetDisabled(not MS.DB.global.ShowTimeFrame)
        TimeFontSizeSlider:SetSliderValues(8, 32, 1)
        TimeFontSizeSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TimeFontSize = Value MS:UpdateTimeFrame() end)
        TimeFontSizeSlider:SetRelativeWidth(0.5)

        local TimeUpdateInterval = MSGUI:Create("Slider")
        TimeUpdateInterval:SetLabel(MS:SetUpdateIntervalLabel(MS.DB.global.TimeUpdateInterval))
        TimeUpdateInterval:SetValue(MS.DB.global.TimeUpdateInterval)
        TimeUpdateInterval:SetDisabled(not MS.DB.global.ShowTimeFrame)
        TimeUpdateInterval:SetSliderValues(1, 60, 1)
        TimeUpdateInterval:SetCallback("OnValueChanged", 
            function(_, _, Value) 
            MS.DB.global.TimeUpdateInterval = Value 
            MS:UpdateTimeFrame()
            TimeUpdateInterval:SetLabel(MS:SetUpdateIntervalLabel(MS.DB.global.TimeUpdateInterval))
        end)
        TimeUpdateInterval:SetRelativeWidth(0.5)

        local DateOptionsContainer = MSGUI:Create("InlineGroup")
        DateOptionsContainer:SetTitle("Date Options")
        DateOptionsContainer:SetLayout("Flow")
        DateOptionsContainer:SetFullWidth(true)
        
        local DateFormatDropdown = MSGUI:Create("Dropdown")
        DateFormatDropdown:SetLabel("Format")
        DateFormatDropdown:SetList(DateOptions, DateOrder)
        DateFormatDropdown:SetValue(MS.DB.global.DateFormat)
        DateFormatDropdown:SetDisabled(not MS.DB.global.MouseoverDate or not MS.DB.global.ShowTimeFrame)
        DateFormatDropdown:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DateFormat = Value MS:UpdateTimeFrame() end)
        DateFormatDropdown:SetRelativeWidth(0.75)

        local MouseoverDateCheckbox = MSGUI:Create("CheckBox")
        MouseoverDateCheckbox:SetLabel("Show Date")
        MouseoverDateCheckbox:SetValue(MS.DB.global.MouseoverDate)
        MouseoverDateCheckbox:SetDisabled(not MS.DB.global.ShowTimeFrame)
        MouseoverDateCheckbox:SetCallback("OnValueChanged", 
            function(_, _, Value) 
            MS.DB.global.MouseoverDate = Value 
            MS:UpdateTimeFrame()
            if MS.DB.global.MouseoverDate then
                DateFormatDropdown:SetDisabled(false)
            else
                DateFormatDropdown:SetDisabled(true)
            end
            MSGUI_Container:DoLayout() 
        end)
        MouseoverDateCheckbox:SetCallback("OnEnter", 
            function()
            GameTooltip:SetOwner(MouseoverDateCheckbox.frame, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPRIGHT", MouseoverDateCheckbox.frame, "BOTTOMRIGHT", 0, -1)
            GameTooltip:SetText("Show the date when hovering over the time.")
        end)
        MouseoverDateCheckbox:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        MouseoverDateCheckbox:SetRelativeWidth(0.25)

        local PositionOptionsContainer = MSGUI:Create("InlineGroup")
        PositionOptionsContainer:SetTitle("Position Options")
        PositionOptionsContainer:SetLayout("Flow")
        PositionOptionsContainer:SetFullWidth(true)
        
        local TimeAnchorPosition = MSGUI:Create("Dropdown")
        TimeAnchorPosition:SetLabel("Position")
        TimeAnchorPosition:SetList(MS.ANCHORS)
        TimeAnchorPosition:SetValue(MS.DB.global.TimeAnchorPosition)
        TimeAnchorPosition:SetDisabled(not MS.DB.global.ShowTimeFrame)
        TimeAnchorPosition:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TimeAnchorPosition = Value MS:UpdateTimeFrame() end)
        TimeAnchorPosition:SetRelativeWidth(0.33)

        local TimeXOffsetSlider = MSGUI:Create("Slider")
        TimeXOffsetSlider:SetLabel("X Offset")
        TimeXOffsetSlider:SetValue(MS.DB.global.TimeXOffset)
        TimeXOffsetSlider:SetDisabled(not MS.DB.global.ShowTimeFrame)
        TimeXOffsetSlider:SetSliderValues(-100, 100, 1)
        TimeXOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TimeXOffset = Value MS:UpdateTimeFrame() end)
        TimeXOffsetSlider:SetRelativeWidth(0.33)

        local TimeYOffsetSlider = MSGUI:Create("Slider")
        TimeYOffsetSlider:SetLabel("Y Offset")
        TimeYOffsetSlider:SetValue(MS.DB.global.TimeYOffset)
        TimeYOffsetSlider:SetDisabled(not MS.DB.global.ShowTimeFrame)
        TimeYOffsetSlider:SetSliderValues(-100, 100, 1)
        TimeYOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TimeYOffset = Value MS:UpdateTimeFrame() end)
        TimeYOffsetSlider:SetRelativeWidth(0.33)

        local ShowTimeFrameCheckBox = MSGUI:Create("CheckBox")
        ShowTimeFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowTimeFrame))
        ShowTimeFrameCheckBox:SetValue(MS.DB.global.ShowTimeFrame)
        ShowTimeFrameCheckBox:SetCallback("OnValueChanged", 
            function(_, _, Value) MS.DB.global.ShowTimeFrame = Value 
            MS:UpdateTimeFrame() 
            ShowTimeFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowTimeFrame)) 
            MSGUI_Container:DoLayout()
            if not MS.DB.global.ShowTimeFrame then
                TimeTypeDropdown:SetDisabled(true)
                TimeFormatDropdown:SetDisabled(true)
                TimeFontSizeSlider:SetDisabled(true)
                MouseoverDateCheckbox:SetDisabled(true)
                DateFormatDropdown:SetDisabled(true)
                TimeAnchorPosition:SetDisabled(true)
                TimeXOffsetSlider:SetDisabled(true)
                TimeYOffsetSlider:SetDisabled(true)
                TimeUpdateInterval:SetDisabled(true)
            else
                TimeTypeDropdown:SetDisabled(false)
                TimeFormatDropdown:SetDisabled(false)
                TimeFontSizeSlider:SetDisabled(false)
                MouseoverDateCheckbox:SetDisabled(false)
                DateFormatDropdown:SetDisabled(not MS.DB.global.MouseoverDate)
                TimeAnchorPosition:SetDisabled(false)
                TimeXOffsetSlider:SetDisabled(false)
                TimeYOffsetSlider:SetDisabled(false)
                TimeUpdateInterval:SetDisabled(false)
            end
        end)

        MSGUI_Container:AddChild(ShowTimeFrameCheckBox)
        MSGUI_Container:AddChild(TimeOptionsContainer)
        TimeOptionsContainer:AddChild(TimeTypeDropdown)
        TimeOptionsContainer:AddChild(TimeFormatDropdown)
        TimeOptionsContainer:AddChild(TimeFontSizeSlider)
        TimeOptionsContainer:AddChild(TimeUpdateInterval)
        TimeOptionsContainer:AddChild(DateOptionsContainer)
        DateOptionsContainer:AddChild(MouseoverDateCheckbox)
        DateOptionsContainer:AddChild(DateFormatDropdown)
        MSGUI_Container:AddChild(PositionOptionsContainer)
        PositionOptionsContainer:AddChild(TimeAnchorPosition)
        PositionOptionsContainer:AddChild(TimeXOffsetSlider)
        PositionOptionsContainer:AddChild(TimeYOffsetSlider)
    end

    local function DrawSystemStatsContainer(MSGUI_Container)
        local SystemStatsOptionsContainer = MSGUI:Create("InlineGroup")
        SystemStatsOptionsContainer:SetTitle("General Options")
        SystemStatsOptionsContainer:SetLayout("Flow")
        SystemStatsOptionsContainer:SetFullWidth(true)

        local SystemStatsFormatStringEditBox = MSGUI:Create("EditBox")
        SystemStatsFormatStringEditBox:SetLabel("Format")
        SystemStatsFormatStringEditBox:SetText(MS.DB.global.SystemStatsFormatString)
        SystemStatsFormatStringEditBox:SetDisabled(not MS.DB.global.ShowSystemsStatsFrame)
        SystemStatsFormatStringEditBox:SetCallback("OnEnterPressed",
            function(_, _, Value) 
            if Value == "" then Value = "FPS | HomeMS" SystemStatsFormatStringEditBox:SetText(Value) end
            MS.DB.global.SystemStatsFormatString = Value 
            MS:UpdateSystemStatsFrame()
        end)
        SystemStatsFormatStringEditBox:SetRelativeWidth(0.33)
        SystemStatsFormatStringEditBox:SetCallback("OnEnter", function() 
            GameTooltip:SetOwner(SystemStatsFormatStringEditBox.frame, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPRIGHT", SystemStatsFormatStringEditBox.frame, "BOTTOMRIGHT", 0, -1)
            GameTooltip:SetText("|cFF8080FFFPS|r: Frames Per Second\n|cFF8080FFHomeMS|r: Home Latency\n|cFF8080FFWorldMS|r: World Latency\n")
            GameTooltip:Show()
        end)
        SystemStatsFormatStringEditBox:SetCallback("OnLeave", function() GameTooltip:Hide() end)

        local SystemStatsFontSizeSlider = MSGUI:Create("Slider")
        SystemStatsFontSizeSlider:SetLabel("Font Size")
        SystemStatsFontSizeSlider:SetValue(MS.DB.global.SystemStatsFontSize)
        SystemStatsFontSizeSlider:SetDisabled(not MS.DB.global.ShowSystemsStatsFrame)
        SystemStatsFontSizeSlider:SetSliderValues(8, 32, 1)
        SystemStatsFontSizeSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.SystemStatsFontSize = Value MS:UpdateSystemStatsFrame() end)
        SystemStatsFontSizeSlider:SetRelativeWidth(0.33)

        local SystemStatsUpdateIntervalSlider = MSGUI:Create("Slider")
        SystemStatsUpdateIntervalSlider:SetLabel(MS:SetUpdateIntervalLabel(MS.DB.global.SystemStatsUpdateInterval))
        SystemStatsUpdateIntervalSlider:SetValue(MS.DB.global.SystemStatsUpdateInterval)
        SystemStatsUpdateIntervalSlider:SetDisabled(not MS.DB.global.ShowSystemsStatsFrame)
        SystemStatsUpdateIntervalSlider:SetSliderValues(0, 60, 0.5)
        SystemStatsUpdateIntervalSlider:SetCallback("OnValueChanged", 
            function(_, _, Value) 
            MS.DB.global.SystemStatsUpdateInterval = Value 
            MS:UpdateSystemStatsFrame()
            SystemStatsUpdateIntervalSlider:SetLabel(MS:SetUpdateIntervalLabel(MS.DB.global.SystemStatsUpdateInterval))
        end)
        SystemStatsUpdateIntervalSlider:SetRelativeWidth(0.33)

        local PositionOptionsContainer = MSGUI:Create("InlineGroup")
        PositionOptionsContainer:SetTitle("Position Options")
        PositionOptionsContainer:SetLayout("Flow")
        PositionOptionsContainer:SetFullWidth(true)

        local SystemStatsAnchorPosition = MSGUI:Create("Dropdown")
        SystemStatsAnchorPosition:SetLabel("Position")
        SystemStatsAnchorPosition:SetList(MS.ANCHORS)
        SystemStatsAnchorPosition:SetValue(MS.DB.global.SystemStatsAnchorPosition)
        SystemStatsAnchorPosition:SetDisabled(not MS.DB.global.ShowSystemsStatsFrame)
        SystemStatsAnchorPosition:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.SystemStatsAnchorPosition = Value MS:UpdateSystemStatsFrame() end)
        SystemStatsAnchorPosition:SetRelativeWidth(0.33)

        local SystemStatsXOffsetSlider = MSGUI:Create("Slider")
        SystemStatsXOffsetSlider:SetLabel("X Offset")
        SystemStatsXOffsetSlider:SetValue(MS.DB.global.SystemStatsXOffset)
        SystemStatsXOffsetSlider:SetDisabled(not MS.DB.global.ShowSystemsStatsFrame)
        SystemStatsXOffsetSlider:SetSliderValues(-100, 100, 1)
        SystemStatsXOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.SystemStatsXOffset = Value MS:UpdateSystemStatsFrame() end)
        SystemStatsXOffsetSlider:SetRelativeWidth(0.33)

        local SystemStatsYOffsetSlider = MSGUI:Create("Slider")
        SystemStatsYOffsetSlider:SetLabel("Y Offset")
        SystemStatsYOffsetSlider:SetValue(MS.DB.global.SystemStatsYOffset)
        SystemStatsYOffsetSlider:SetDisabled(not MS.DB.global.ShowSystemsStatsFrame)
        SystemStatsYOffsetSlider:SetSliderValues(-100, 100, 1)
        SystemStatsYOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.SystemStatsYOffset = Value MS:UpdateSystemStatsFrame() end)
        SystemStatsYOffsetSlider:SetRelativeWidth(0.33)

        local ShowSystemsStatsFrameCheckBox = MSGUI:Create("CheckBox")
        ShowSystemsStatsFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowSystemsStatsFrame))
        ShowSystemsStatsFrameCheckBox:SetValue(MS.DB.global.ShowSystemsStatsFrame)
        ShowSystemsStatsFrameCheckBox:SetCallback("OnValueChanged", 
            function(_, _, Value) MS.DB.global.ShowSystemsStatsFrame = Value 
            MS:UpdateSystemStatsFrame() 
            ShowSystemsStatsFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowSystemsStatsFrame)) 
            MSGUI_Container:DoLayout()
            if not MS.DB.global.ShowSystemsStatsFrame then
                SystemStatsFormatStringEditBox:SetDisabled(true)
                SystemStatsUpdateIntervalSlider:SetDisabled(true)
                SystemStatsFontSizeSlider:SetDisabled(true)
                SystemStatsAnchorPosition:SetDisabled(true)
                SystemStatsXOffsetSlider:SetDisabled(true)
                SystemStatsYOffsetSlider:SetDisabled(true)
            else
                SystemStatsFormatStringEditBox:SetDisabled(false)
                SystemStatsUpdateIntervalSlider:SetDisabled(false)
                SystemStatsFontSizeSlider:SetDisabled(false)
                SystemStatsAnchorPosition:SetDisabled(false)
                SystemStatsXOffsetSlider:SetDisabled(false)
                SystemStatsYOffsetSlider:SetDisabled(false)
            end
        end)

        MSGUI_Container:AddChild(ShowSystemsStatsFrameCheckBox)
        MSGUI_Container:AddChild(SystemStatsOptionsContainer)
        SystemStatsOptionsContainer:AddChild(SystemStatsFormatStringEditBox)
        SystemStatsOptionsContainer:AddChild(SystemStatsFontSizeSlider)
        SystemStatsOptionsContainer:AddChild(SystemStatsUpdateIntervalSlider)
        MSGUI_Container:AddChild(PositionOptionsContainer)
        PositionOptionsContainer:AddChild(SystemStatsAnchorPosition)
        PositionOptionsContainer:AddChild(SystemStatsXOffsetSlider)
        PositionOptionsContainer:AddChild(SystemStatsYOffsetSlider)
    end

    local function DrawLocationContainer(MSGUI_Container)
        local ColourFormatOptions = { ["Primary"] = "Primary", ["Accent"] = "Accent", ["Reaction"] = "Reaction", ["Custom"] = "Custom" }
        local ColourFormatOrder = { "Primary", "Accent", "Reaction", "Custom" }
        local LocationOptionsContainer = MSGUI:Create("InlineGroup")
        local ColourFormat = MS.DB.global.LocationColourFormat
        LocationOptionsContainer:SetTitle("General Options")
        LocationOptionsContainer:SetLayout("Flow")
        LocationOptionsContainer:SetFullWidth(true)

        local LocationColourColourPicker = MSGUI:Create("ColorPicker")
        LocationColourColourPicker:SetLabel("Colour")
        LocationColourColourPicker:SetColor(MS.DB.global.LocationColourR, MS.DB.global.LocationColourG, MS.DB.global.LocationColourB)
        LocationColourColourPicker:SetDisabled(not MS.DB.global.ShowLocationFrame or ColourFormat ~= "Custom")
        LocationColourColourPicker:SetCallback("OnValueChanged", function(_, _, R, G, B) MS.DB.global.LocationColourR = R MS.DB.global.LocationColourG = G MS.DB.global.LocationColourB = B MS:UpdateLocationFrame() end)
        LocationColourColourPicker:SetRelativeWidth(0.33)

        local LocationColourFormatDropdown = MSGUI:Create("Dropdown")
        LocationColourFormatDropdown:SetLabel("Colour Format")
        LocationColourFormatDropdown:SetList(ColourFormatOptions, ColourFormatOrder)
        LocationColourFormatDropdown:SetValue(MS.DB.global.LocationColourFormat)
        LocationColourFormatDropdown:SetDisabled(not MS.DB.global.ShowLocationFrame)
        LocationColourFormatDropdown:SetCallback("OnValueChanged", 
            function(_, _, Value) 
            MS.DB.global.LocationColourFormat = Value
            MS:UpdateLocationFrame()
            if Value == "Custom" then
                LocationColourColourPicker:SetDisabled(false)
            else
                LocationColourColourPicker:SetDisabled(true)
            end
        end)
        LocationColourFormatDropdown:SetCallback("OnEnter", 
            function()
            GameTooltip:SetOwner(LocationColourFormatDropdown.frame, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPRIGHT", LocationColourFormatDropdown.frame, "BOTTOMRIGHT", 0, -1)
            GameTooltip:SetText("Determines how the text is coloured.")
        end)
        LocationColourFormatDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        LocationColourFormatDropdown:SetRelativeWidth(0.33)

        local LocationFontSizeSlider = MSGUI:Create("Slider")
        LocationFontSizeSlider:SetLabel("Font Size")
        LocationFontSizeSlider:SetValue(MS.DB.global.LocationFontSize)
        LocationFontSizeSlider:SetDisabled(not MS.DB.global.ShowLocationFrame)
        LocationFontSizeSlider:SetSliderValues(8, 32, 1)
        LocationFontSizeSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.LocationFontSize = Value MS:UpdateLocationFrame() end)
        LocationFontSizeSlider:SetRelativeWidth(0.33)

        local PositionOptionsContainer = MSGUI:Create("InlineGroup")
        PositionOptionsContainer:SetTitle("Position Options")
        PositionOptionsContainer:SetLayout("Flow")
        PositionOptionsContainer:SetFullWidth(true)

        local LocationAnchorPosition = MSGUI:Create("Dropdown")
        LocationAnchorPosition:SetLabel("Position")
        LocationAnchorPosition:SetList(MS.ANCHORS)
        LocationAnchorPosition:SetValue(MS.DB.global.LocationAnchorPosition)
        LocationAnchorPosition:SetDisabled(not MS.DB.global.ShowLocationFrame)
        LocationAnchorPosition:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.LocationAnchorPosition = Value MS:UpdateLocationFrame() end)
        LocationAnchorPosition:SetRelativeWidth(0.33)

        local LocationXOffsetSlider = MSGUI:Create("Slider")
        LocationXOffsetSlider:SetLabel("X Offset")
        LocationXOffsetSlider:SetValue(MS.DB.global.LocationXOffset)
        LocationXOffsetSlider:SetDisabled(not MS.DB.global.ShowLocationFrame)
        LocationXOffsetSlider:SetSliderValues(-100, 100, 1)
        LocationXOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.LocationXOffset = Value MS:UpdateLocationFrame() end)
        LocationXOffsetSlider:SetRelativeWidth(0.33)

        local LocationYOffsetSlider = MSGUI:Create("Slider")
        LocationYOffsetSlider:SetLabel("Y Offset")
        LocationYOffsetSlider:SetValue(MS.DB.global.LocationYOffset)
        LocationYOffsetSlider:SetDisabled(not MS.DB.global.ShowLocationFrame)
        LocationYOffsetSlider:SetSliderValues(-100, 100, 1)
        LocationYOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.LocationYOffset = Value MS:UpdateLocationFrame() end)
        LocationYOffsetSlider:SetRelativeWidth(0.33)

        local ShowLocationFrameCheckBox = MSGUI:Create("CheckBox")
        ShowLocationFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowLocationFrame))
        ShowLocationFrameCheckBox:SetValue(MS.DB.global.ShowLocationFrame)
        ShowLocationFrameCheckBox:SetCallback("OnValueChanged", 
            function(_, _, Value) MS.DB.global.ShowLocationFrame = Value 
            MS:UpdateLocationFrame()
            ShowLocationFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowLocationFrame)) 
            MSGUI_Container:DoLayout()
            if not MS.DB.global.ShowLocationFrame then
                LocationColourFormatDropdown:SetDisabled(true)
                LocationColourColourPicker:SetDisabled(true)
                LocationFontSizeSlider:SetDisabled(true)
                LocationAnchorPosition:SetDisabled(true)
                LocationXOffsetSlider:SetDisabled(true)
                LocationYOffsetSlider:SetDisabled(true)
            else
                LocationColourFormatDropdown:SetDisabled(false)
                LocationColourColourPicker:SetDisabled(not MS.DB.global.ShowLocationFrame or ColourFormat ~= "Custom")
                LocationFontSizeSlider:SetDisabled(false)
                LocationAnchorPosition:SetDisabled(false)
                LocationXOffsetSlider:SetDisabled(false)
                LocationYOffsetSlider:SetDisabled(false)
            end
        end)

        MSGUI_Container:AddChild(ShowLocationFrameCheckBox)
        MSGUI_Container:AddChild(LocationOptionsContainer)
        LocationOptionsContainer:AddChild(LocationColourFormatDropdown)
        LocationOptionsContainer:AddChild(LocationColourColourPicker)
        LocationOptionsContainer:AddChild(LocationFontSizeSlider)
        MSGUI_Container:AddChild(PositionOptionsContainer)
        PositionOptionsContainer:AddChild(LocationAnchorPosition)
        PositionOptionsContainer:AddChild(LocationXOffsetSlider)
        PositionOptionsContainer:AddChild(LocationYOffsetSlider)

    end

    local function DrawCoordinatesContainer(MSGUI_Container)
        local CoordinatesOptions = { ["0, 0"] = "0, 0", ["0.0, 0.0"] = "0.0, 0.0", ["0.00, 0.00"] = "0.00, 0.00" }
        local CoordinatesOrder = { "0, 0", "0.0, 0.0", "0.00, 0.00" }
        local CoordinatesOptionsContainer = MSGUI:Create("InlineGroup")
        CoordinatesOptionsContainer:SetTitle("General Options")
        CoordinatesOptionsContainer:SetLayout("Flow")
        CoordinatesOptionsContainer:SetFullWidth(true)

        local CoordinatesFormatDropdown = MSGUI:Create("Dropdown")
        CoordinatesFormatDropdown:SetLabel("Format")
        CoordinatesFormatDropdown:SetList(CoordinatesOptions, CoordinatesOrder)
        CoordinatesFormatDropdown:SetValue(MS.DB.global.CoordinatesFormat)
        CoordinatesFormatDropdown:SetDisabled(not MS.DB.global.ShowCoordinatesFrame)
        CoordinatesFormatDropdown:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.CoordinatesFormat = Value MS:UpdateCoordinatesFrame() end)
        CoordinatesFormatDropdown:SetRelativeWidth(0.5)

        local CoordinatesFontSizeSlider = MSGUI:Create("Slider")
        CoordinatesFontSizeSlider:SetLabel("Font Size")
        CoordinatesFontSizeSlider:SetValue(MS.DB.global.CoordinatesFontSize)
        CoordinatesFontSizeSlider:SetDisabled(not MS.DB.global.ShowCoordinatesFrame)
        CoordinatesFontSizeSlider:SetSliderValues(8, 32, 1)
        CoordinatesFontSizeSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.CoordinatesFontSize = Value MS:UpdateCoordinatesFrame() end)
        CoordinatesFontSizeSlider:SetRelativeWidth(0.5)

        local CoordinatesUpdateIntervalSlider = MSGUI:Create("Slider")
        CoordinatesUpdateIntervalSlider:SetLabel(MS:SetUpdateIntervalLabel(MS.DB.global.CoordinatesUpdateInterval))
        CoordinatesUpdateIntervalSlider:SetValue(MS.DB.global.CoordinatesUpdateInterval)
        CoordinatesUpdateIntervalSlider:SetDisabled(not MS.DB.global.ShowCoordinatesFrame or MS.DB.global.CoordinatesUpdateInRealTime)
        CoordinatesUpdateIntervalSlider:SetSliderValues(0, 60, 0.5)
        CoordinatesUpdateIntervalSlider:SetCallback("OnValueChanged", 
            function(_, _, Value) 
            MS.DB.global.CoordinatesUpdateInterval = Value 
            MS:UpdateCoordinatesFrame()
            CoordinatesUpdateIntervalSlider:SetLabel(MS:SetUpdateIntervalLabel(MS.DB.global.CoordinatesUpdateInterval))
        end)
        CoordinatesUpdateIntervalSlider:SetRelativeWidth(0.5)

        local CoordinatesUpdateInRealTimeCheckBox = MSGUI:Create("CheckBox")
        CoordinatesUpdateInRealTimeCheckBox:SetLabel("Update In Real Time")
        CoordinatesUpdateInRealTimeCheckBox:SetValue(MS.DB.global.CoordinatesUpdateInRealTime)
        CoordinatesUpdateInRealTimeCheckBox:SetDisabled(not MS.DB.global.ShowCoordinatesFrame)
        CoordinatesUpdateInRealTimeCheckBox:SetCallback("OnValueChanged", 
            function(_, _, Value) 
            MS.DB.global.CoordinatesUpdateInRealTime = Value 
            MS:UpdateCoordinatesFrame()
            CoordinatesUpdateIntervalSlider:SetDisabled(MS.DB.global.CoordinatesUpdateInRealTime)
        end)

        local PositionOptionsContainer = MSGUI:Create("InlineGroup")
        PositionOptionsContainer:SetTitle("Position Options")
        PositionOptionsContainer:SetLayout("Flow")
        PositionOptionsContainer:SetFullWidth(true)

        local CoordinatesAnchorPosition = MSGUI:Create("Dropdown")
        CoordinatesAnchorPosition:SetLabel("Position")
        CoordinatesAnchorPosition:SetList(MS.ANCHORS)
        CoordinatesAnchorPosition:SetValue(MS.DB.global.CoordinatesAnchorPosition)
        CoordinatesAnchorPosition:SetDisabled(not MS.DB.global.ShowCoordinatesFrame)
        CoordinatesAnchorPosition:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.CoordinatesAnchorPosition = Value MS:UpdateCoordinatesFrame() end)
        CoordinatesAnchorPosition:SetRelativeWidth(0.33)

        local CoordinatesXOffsetSlider = MSGUI:Create("Slider")
        CoordinatesXOffsetSlider:SetLabel("X Offset")
        CoordinatesXOffsetSlider:SetValue(MS.DB.global.CoordinatesXOffset)
        CoordinatesXOffsetSlider:SetDisabled(not MS.DB.global.ShowCoordinatesFrame)
        CoordinatesXOffsetSlider:SetSliderValues(-100, 100, 1)
        CoordinatesXOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.CoordinatesXOffset = Value MS:UpdateCoordinatesFrame() end)
        CoordinatesXOffsetSlider:SetRelativeWidth(0.33)

        local CoordinatesYOffsetSlider = MSGUI:Create("Slider")
        CoordinatesYOffsetSlider:SetLabel("Y Offset")
        CoordinatesYOffsetSlider:SetValue(MS.DB.global.CoordinatesYOffset)
        CoordinatesYOffsetSlider:SetDisabled(not MS.DB.global.ShowCoordinatesFrame)
        CoordinatesYOffsetSlider:SetSliderValues(-100, 100, 1)
        CoordinatesYOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.CoordinatesYOffset = Value MS:UpdateCoordinatesFrame() end)
        CoordinatesYOffsetSlider:SetRelativeWidth(0.33)

        local ShowCoordinatesFrameCheckBox = MSGUI:Create("CheckBox")
        ShowCoordinatesFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowCoordinatesFrame))
        ShowCoordinatesFrameCheckBox:SetValue(MS.DB.global.ShowCoordinatesFrame)
        ShowCoordinatesFrameCheckBox:SetCallback("OnValueChanged", 
            function(_, _, Value) MS.DB.global.ShowCoordinatesFrame = Value 
            MS:UpdateCoordinatesFrame() 
            ShowCoordinatesFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowCoordinatesFrame)) 
            MSGUI_Container:DoLayout()
            if not MS.DB.global.ShowCoordinatesFrame then
                CoordinatesFormatDropdown:SetDisabled(true)
                CoordinatesFontSizeSlider:SetDisabled(true)
                CoordinatesAnchorPosition:SetDisabled(true)
                CoordinatesXOffsetSlider:SetDisabled(true)
                CoordinatesYOffsetSlider:SetDisabled(true)
                CoordinatesUpdateIntervalSlider:SetDisabled(true)
                CoordinatesUpdateInRealTimeCheckBox:SetDisabled(true)
            else
                CoordinatesFormatDropdown:SetDisabled(false)
                CoordinatesFontSizeSlider:SetDisabled(false)
                CoordinatesAnchorPosition:SetDisabled(false)
                CoordinatesXOffsetSlider:SetDisabled(false)
                CoordinatesYOffsetSlider:SetDisabled(false)
                CoordinatesUpdateIntervalSlider:SetDisabled(false)
                CoordinatesUpdateInRealTimeCheckBox:SetDisabled(false)
            end
        end)

        MSGUI_Container:AddChild(ShowCoordinatesFrameCheckBox)
        MSGUI_Container:AddChild(CoordinatesOptionsContainer)
        CoordinatesOptionsContainer:AddChild(CoordinatesFormatDropdown)
        CoordinatesOptionsContainer:AddChild(CoordinatesFontSizeSlider)
        CoordinatesOptionsContainer:AddChild(CoordinatesUpdateIntervalSlider)
        CoordinatesOptionsContainer:AddChild(CoordinatesUpdateInRealTimeCheckBox)
        MSGUI_Container:AddChild(PositionOptionsContainer)
        PositionOptionsContainer:AddChild(CoordinatesAnchorPosition)
        PositionOptionsContainer:AddChild(CoordinatesXOffsetSlider)
        PositionOptionsContainer:AddChild(CoordinatesYOffsetSlider)
    end

    local function DrawInstanceDifficultyContainer(MSGUI_Container)
        local InstanceDifficultyOptionsContainer = MSGUI:Create("InlineGroup")
        InstanceDifficultyOptionsContainer:SetTitle("General Options")
        InstanceDifficultyOptionsContainer:SetLayout("Flow")
        InstanceDifficultyOptionsContainer:SetFullWidth(true)

        local InstanceDifficultyFontSizeSlider = MSGUI:Create("Slider")
        InstanceDifficultyFontSizeSlider:SetLabel("Font Size")
        InstanceDifficultyFontSizeSlider:SetValue(MS.DB.global.InstanceDifficultyFontSize)
        InstanceDifficultyFontSizeSlider:SetDisabled(not MS.DB.global.ShowInstanceDifficultyFrame)
        InstanceDifficultyFontSizeSlider:SetSliderValues(8, 32, 1)
        InstanceDifficultyFontSizeSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.InstanceDifficultyFontSize = Value MS:UpdateInstanceDifficultyFrame() end)
        InstanceDifficultyFontSizeSlider:SetFullWidth(true)

        local PositionOptionsContainer = MSGUI:Create("InlineGroup")
        PositionOptionsContainer:SetTitle("Position Options")
        PositionOptionsContainer:SetLayout("Flow")
        PositionOptionsContainer:SetFullWidth(true)

        local InstanceDifficultyAnchorPosition = MSGUI:Create("Dropdown")
        InstanceDifficultyAnchorPosition:SetLabel("Position")
        InstanceDifficultyAnchorPosition:SetList(MS.ANCHORS)
        InstanceDifficultyAnchorPosition:SetValue(MS.DB.global.InstanceDifficultyAnchorPosition)
        InstanceDifficultyAnchorPosition:SetDisabled(not MS.DB.global.ShowInstanceDifficultyFrame)
        InstanceDifficultyAnchorPosition:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.InstanceDifficultyAnchorPosition = Value MS:UpdateInstanceDifficultyFrame() end)
        InstanceDifficultyAnchorPosition:SetRelativeWidth(0.33)

        local InstanceDifficultyXOffsetSlider = MSGUI:Create("Slider")
        InstanceDifficultyXOffsetSlider:SetLabel("X Offset")
        InstanceDifficultyXOffsetSlider:SetValue(MS.DB.global.InstanceDifficultyXOffset)
        InstanceDifficultyXOffsetSlider:SetDisabled(not MS.DB.global.ShowInstanceDifficultyFrame)
        InstanceDifficultyXOffsetSlider:SetSliderValues(-100, 100, 1)
        InstanceDifficultyXOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.InstanceDifficultyXOffset = Value MS:UpdateInstanceDifficultyFrame() end)
        InstanceDifficultyXOffsetSlider:SetRelativeWidth(0.33)

        local InstanceDifficultyYOffsetSlider = MSGUI:Create("Slider")
        InstanceDifficultyYOffsetSlider:SetLabel("Y Offset")
        InstanceDifficultyYOffsetSlider:SetValue(MS.DB.global.InstanceDifficultyYOffset)
        InstanceDifficultyYOffsetSlider:SetDisabled(not MS.DB.global.ShowInstanceDifficultyFrame)
        InstanceDifficultyYOffsetSlider:SetSliderValues(-100, 100, 1)
        InstanceDifficultyYOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.InstanceDifficultyYOffset = Value MS:UpdateInstanceDifficultyFrame() end)
        InstanceDifficultyYOffsetSlider:SetRelativeWidth(0.33)

        local ShowInstanceDifficultyFrameCheckBox = MSGUI:Create("CheckBox")
        ShowInstanceDifficultyFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowInstanceDifficultyFrame))
        ShowInstanceDifficultyFrameCheckBox:SetValue(MS.DB.global.ShowInstanceDifficultyFrame)
        ShowInstanceDifficultyFrameCheckBox:SetCallback("OnValueChanged", 
            function(_, _, Value) MS.DB.global.ShowInstanceDifficultyFrame = Value 
            MS:UpdateInstanceDifficultyFrame() 
            ShowInstanceDifficultyFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowInstanceDifficultyFrame)) 
            MSGUI_Container:DoLayout()
                if not MS.DB.global.ShowInstanceDifficultyFrame then
                    InstanceDifficultyFontSizeSlider:SetDisabled(true)
                    InstanceDifficultyAnchorPosition:SetDisabled(true)
                    InstanceDifficultyXOffsetSlider:SetDisabled(true)
                    InstanceDifficultyYOffsetSlider:SetDisabled(true)
                else
                    InstanceDifficultyFontSizeSlider:SetDisabled(false)
                    InstanceDifficultyAnchorPosition:SetDisabled(false)
                    InstanceDifficultyXOffsetSlider:SetDisabled(false)
                    InstanceDifficultyYOffsetSlider:SetDisabled(false)
                end
            end)
        
        MSGUI_Container:AddChild(ShowInstanceDifficultyFrameCheckBox)
        MSGUI_Container:AddChild(InstanceDifficultyOptionsContainer)
        InstanceDifficultyOptionsContainer:AddChild(InstanceDifficultyFontSizeSlider)
        MSGUI_Container:AddChild(PositionOptionsContainer)
        PositionOptionsContainer:AddChild(InstanceDifficultyAnchorPosition)
        PositionOptionsContainer:AddChild(InstanceDifficultyXOffsetSlider)
        PositionOptionsContainer:AddChild(InstanceDifficultyYOffsetSlider)
    end

    local function DrawTooltipContainer(MSGUI_Container)
        local TooltipTextureIconSizeOptions = { ["8"] = "8px", ["10"] = "10px", ["12"] = "12px", ["14"] = "14px", ["16"] = "16px", ["18"] = "18px", ["20"] = "20px", ["22"] = "22px", ["24"] = "24px" }
        local TooltipTextureIconSizeOrder = { "8", "10", "12", "14", "16", "18", "20", "22", "24" }
        local SystemStatsTooltipOptionsContainer = MSGUI:Create("InlineGroup")
        if not MS.DB.global.ShowSystemsStatsFrame then
            SystemStatsTooltipOptionsContainer:SetTitle("System Stats Tooltip - Systems Stats Frame: |cFFFF4040Inactive|r. No Tooltip Will Be Displayed.")
        else 
            SystemStatsTooltipOptionsContainer:SetTitle("System Stats Tooltip")
        end
        SystemStatsTooltipOptionsContainer:SetLayout("Flow")
        SystemStatsTooltipOptionsContainer:SetFullWidth(true)

        local TimeTooltipOptionsContainer = MSGUI:Create("InlineGroup")
        if not MS.DB.global.ShowTimeFrame then
            TimeTooltipOptionsContainer:SetTitle("Time Tooltip - Time Frame: |cFFFF4040Inactive|r. No Tooltip Will Be Displayed.")
        else 
            TimeTooltipOptionsContainer:SetTitle("Time Tooltip")
        end
        TimeTooltipOptionsContainer:SetLayout("Flow")
        TimeTooltipOptionsContainer:SetFullWidth(true)

        local PositionOptionsContainer = MSGUI:Create("InlineGroup")
        PositionOptionsContainer:SetTitle("Position Options")
        PositionOptionsContainer:SetLayout("Flow")
        PositionOptionsContainer:SetFullWidth(true)

        local MythicPlusOptionsContainer = MSGUI:Create("InlineGroup")
        MythicPlusOptionsContainer:SetTitle("Mythic+ Options")
        MythicPlusOptionsContainer:SetLayout("Flow")
        MythicPlusOptionsContainer:SetFullWidth(true)

        local GreatVaultOptionsContainer = MSGUI:Create("InlineGroup")
        GreatVaultOptionsContainer:SetTitle("Great Vault Options")
        GreatVaultOptionsContainer:SetLayout("Flow")
        GreatVaultOptionsContainer:SetFullWidth(true)

        -- Position Options

        local TooltipAnchorFromPosition = MSGUI:Create("Dropdown")
        TooltipAnchorFromPosition:SetLabel("Anchor Point on Tooltip")
        TooltipAnchorFromPosition:SetList(MS.ANCHORS)
        TooltipAnchorFromPosition:SetValue(MS.DB.global.TooltipAnchorFrom)
        TooltipAnchorFromPosition:SetDisabled(not MS.DB.global.ShowTooltip)
        TooltipAnchorFromPosition:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TooltipAnchorFrom = Value end)
        TooltipAnchorFromPosition:SetRelativeWidth(0.5)

        local TooltipAnchorToPosition = MSGUI:Create("Dropdown")
        TooltipAnchorToPosition:SetLabel("Anchor Point to Minimap")
        TooltipAnchorToPosition:SetList(MS.ANCHORS)
        TooltipAnchorToPosition:SetValue(MS.DB.global.TooltipAnchorTo)
        TooltipAnchorToPosition:SetDisabled(not MS.DB.global.ShowTooltip)
        TooltipAnchorToPosition:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TooltipAnchorTo = Value end)
        TooltipAnchorToPosition:SetRelativeWidth(0.5)

        local TooltipXOffsetSlider = MSGUI:Create("Slider")
        TooltipXOffsetSlider:SetLabel("X Offset")
        TooltipXOffsetSlider:SetValue(MS.DB.global.TooltipXOffset)
        TooltipXOffsetSlider:SetDisabled(not MS.DB.global.ShowTooltip)
        TooltipXOffsetSlider:SetSliderValues(-100, 100, 1)
        TooltipXOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TooltipXOffset = Value end)
        TooltipXOffsetSlider:SetRelativeWidth(0.5)

        local TooltipYOffsetSlider = MSGUI:Create("Slider")
        TooltipYOffsetSlider:SetLabel("Y Offset")
        TooltipYOffsetSlider:SetValue(MS.DB.global.TooltipYOffset)
        TooltipYOffsetSlider:SetDisabled(not MS.DB.global.ShowTooltip)
        TooltipYOffsetSlider:SetSliderValues(-100, 100, 1)
        TooltipYOffsetSlider:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TooltipYOffset = Value end)
        TooltipYOffsetSlider:SetRelativeWidth(0.5)

        -- Toggles

        local TooltipDisplayLockoutCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayLockoutCheckbox:SetLabel("Display Lockouts")
        TooltipDisplayLockoutCheckbox:SetValue(MS.DB.global.DisplayLockouts)
        TooltipDisplayLockoutCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame)
        TooltipDisplayLockoutCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayLockouts = Value end)
        TooltipDisplayLockoutCheckbox:SetRelativeWidth(0.5)

        local TooltipDisplayPlayerKeystoneCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayPlayerKeystoneCheckbox:SetLabel("Display Player Keystone")
        TooltipDisplayPlayerKeystoneCheckbox:SetValue(MS.DB.global.DisplayPartyKeystones)
        TooltipDisplayPlayerKeystoneCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame)
        TooltipDisplayPlayerKeystoneCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayPlayerKeystone = Value end)
        TooltipDisplayPlayerKeystoneCheckbox:SetRelativeWidth(0.5)

        local TooltipDisplayPartyKeystoneCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayPartyKeystoneCheckbox:SetLabel("Display Party Keystone")
        TooltipDisplayPartyKeystoneCheckbox:SetValue(MS.DB.global.DisplayPartyKeystones)
        TooltipDisplayPartyKeystoneCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame)
        TooltipDisplayPartyKeystoneCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayPartyKeystones = Value end)
        TooltipDisplayPartyKeystoneCheckbox:SetRelativeWidth(0.5)

        --[[local TooltipDisplayAffixesDescCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayAffixesDescCheckbox:SetLabel("Display Affix Descriptions")
        TooltipDisplayAffixesDescCheckbox:SetValue(MS.DB.global.DisplayAffixDesc)
        TooltipDisplayAffixesDescCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.DisplayAffixes or not MS.DB.global.ShowSystemsStatsFrame)
        TooltipDisplayAffixesDescCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayAffixDesc = Value end)
        TooltipDisplayAffixesDescCheckbox:SetRelativeWidth(0.25)
        
        local TooltipDisplayAffixesCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayAffixesCheckbox:SetLabel("Display Affixes")
        TooltipDisplayAffixesCheckbox:SetValue(MS.DB.global.DisplayAffixes)
        TooltipDisplayAffixesCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame)
        TooltipDisplayAffixesCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayAffixes = Value
            MSGUI_Container:DoLayout()
            TooltipDisplayAffixesDescCheckbox:SetDisabled(not MS.DB.global.DisplayAffixes)
        end)
        TooltipDisplayAffixesCheckbox:SetRelativeWidth(0.25)]]

        local TooltipTextureIconSizeDropdown = MSGUI:Create("Dropdown")
        TooltipTextureIconSizeDropdown:SetLabel("Icon Size")
        TooltipTextureIconSizeDropdown:SetList(TooltipTextureIconSizeOptions, TooltipTextureIconSizeOrder)
        TooltipTextureIconSizeDropdown:SetValue(tostring(MS.DB.global.TooltipTextureIconSize))
        TooltipTextureIconSizeDropdown:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame)
        TooltipTextureIconSizeDropdown:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.TooltipTextureIconSize = tonumber(Value) end)
        TooltipTextureIconSizeDropdown:SetFullWidth(true)

        local TooltipDisplayRaidSlotsCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayRaidSlotsCheckbox:SetLabel("Display Raid Slots")
        TooltipDisplayRaidSlotsCheckbox:SetValue(MS.DB.global.DisplayRaidSlots)
        TooltipDisplayRaidSlotsCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame or not MS.DB.global.DisplayVaultOptions)
        TooltipDisplayRaidSlotsCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayRaidSlots = Value end)
        TooltipDisplayRaidSlotsCheckbox:SetRelativeWidth(0.25)

        local TooltipDisplayMythicPlusSlotsCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayMythicPlusSlotsCheckbox:SetLabel("Display Mythic+ Slots")
        TooltipDisplayMythicPlusSlotsCheckbox:SetValue(MS.DB.global.DisplayMythicPlusSlots)
        TooltipDisplayMythicPlusSlotsCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame or not MS.DB.global.DisplayVaultOptions)
        TooltipDisplayMythicPlusSlotsCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayMythicPlusSlots = Value end)
        TooltipDisplayMythicPlusSlotsCheckbox:SetRelativeWidth(0.25)

        local TooltipDisplayWorldSlotsCheckBox = MSGUI:Create("CheckBox")
        TooltipDisplayWorldSlotsCheckBox:SetLabel("Display World Slots")
        TooltipDisplayWorldSlotsCheckBox:SetValue(MS.DB.global.DisplayWorldSlots)
        TooltipDisplayWorldSlotsCheckBox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame or MS.BUILDVERSION <= 110000 or not MS.DB.global.DisplayVaultOptions)
        TooltipDisplayWorldSlotsCheckBox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayWorldSlots = Value end)
        TooltipDisplayWorldSlotsCheckBox:SetRelativeWidth(0.25)

        local TooltipDisplayVaultOptionsCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayVaultOptionsCheckbox:SetLabel("Display Vault Options")
        TooltipDisplayVaultOptionsCheckbox:SetValue(MS.DB.global.DisplayVaultOptions)
        TooltipDisplayVaultOptionsCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowSystemsStatsFrame)
        TooltipDisplayVaultOptionsCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayVaultOptions = Value MSGUI_Container:DoLayout()
            TooltipDisplayRaidSlotsCheckbox:SetDisabled(not MS.DB.global.DisplayVaultOptions)
            TooltipDisplayMythicPlusSlotsCheckbox:SetDisabled(not MS.DB.global.DisplayVaultOptions)
            TooltipDisplayWorldSlotsCheckBox:SetDisabled(not MS.DB.global.DisplayVaultOptions or MS.BUILDVERSION <= 110000)
        end)
        TooltipDisplayVaultOptionsCheckbox:SetRelativeWidth(0.25)

        local TooltipDisplayTimeCheckbox = MSGUI:Create("CheckBox")
        TooltipDisplayTimeCheckbox:SetLabel("Display Local & Server Time")
        TooltipDisplayTimeCheckbox:SetValue(MS.DB.global.DisplayTime)
        TooltipDisplayTimeCheckbox:SetDisabled(not MS.DB.global.ShowTooltip or not MS.DB.global.ShowTimeFrame)
        TooltipDisplayTimeCheckbox:SetCallback("OnValueChanged", function(_, _, Value) MS.DB.global.DisplayTime = Value end)
        TooltipDisplayTimeCheckbox:SetRelativeWidth(0.5)

        local ShowTooltipFrameCheckBox = MSGUI:Create("CheckBox")
        ShowTooltipFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowTooltip))
        ShowTooltipFrameCheckBox:SetValue(MS.DB.global.ShowTooltip)
        ShowTooltipFrameCheckBox:SetCallback("OnValueChanged", 
            function(_, _, Value) MS.DB.global.ShowTooltip = Value 
            ShowTooltipFrameCheckBox:SetLabel(MS:ToggleFont(MS.DB.global.ShowTooltip)) 
            MSGUI_Container:DoLayout()
            if not MS.DB.global.ShowTooltip then
                TooltipAnchorFromPosition:SetDisabled(true)
                TooltipAnchorToPosition:SetDisabled(true)
                TooltipXOffsetSlider:SetDisabled(true)
                TooltipYOffsetSlider:SetDisabled(true)
                TooltipDisplayLockoutCheckbox:SetDisabled(true)
                TooltipDisplayPlayerKeystoneCheckbox:SetDisabled(true)
                TooltipDisplayPartyKeystoneCheckbox:SetDisabled(true)
                --[[TooltipDisplayAffixesCheckbox:SetDisabled(true)
                TooltipDisplayAffixesDescCheckbox:SetDisabled(true)]]
                TooltipDisplayVaultOptionsCheckbox:SetDisabled(true)
                TooltipTextureIconSizeDropdown:SetDisabled(true)
                TooltipDisplayTimeCheckbox:SetDisabled(true)
                TooltipDisplayRaidSlotsCheckbox:SetDisabled(true)
                TooltipDisplayMythicPlusSlotsCheckbox:SetDisabled(true)
                TooltipDisplayWorldSlotsCheckBox:SetDisabled(true)
            else
                TooltipAnchorFromPosition:SetDisabled(false)
                TooltipAnchorToPosition:SetDisabled(false)
                TooltipXOffsetSlider:SetDisabled(false)
                TooltipYOffsetSlider:SetDisabled(false)
                TooltipDisplayLockoutCheckbox:SetDisabled(false)
                TooltipDisplayPlayerKeystoneCheckbox:SetDisabled(false)
                TooltipDisplayPartyKeystoneCheckbox:SetDisabled(false)
                --[[TooltipDisplayAffixesCheckbox:SetDisabled(false)
                TooltipDisplayAffixesDescCheckbox:SetDisabled(not MS.DB.global.DisplayAffixes)]]
                TooltipDisplayVaultOptionsCheckbox:SetDisabled(false)
                TooltipTextureIconSizeDropdown:SetDisabled(false)
                TooltipDisplayTimeCheckbox:SetDisabled(false)
                TooltipDisplayRaidSlotsCheckbox:SetDisabled(false)
                TooltipDisplayMythicPlusSlotsCheckbox:SetDisabled(false)
                TooltipDisplayWorldSlotsCheckBox:SetDisabled(false)
            end
        end)

        MSGUI_Container:AddChild(ShowTooltipFrameCheckBox)
        MSGUI_Container:AddChild(TimeTooltipOptionsContainer)
        MSGUI_Container:AddChild(SystemStatsTooltipOptionsContainer)
        TimeTooltipOptionsContainer:AddChild(TooltipDisplayTimeCheckbox)
        TimeTooltipOptionsContainer:AddChild(TooltipDisplayLockoutCheckbox)
        SystemStatsTooltipOptionsContainer:AddChild(MythicPlusOptionsContainer)
        SystemStatsTooltipOptionsContainer:AddChild(GreatVaultOptionsContainer)
        GreatVaultOptionsContainer:AddChild(TooltipDisplayVaultOptionsCheckbox)
        GreatVaultOptionsContainer:AddChild(TooltipDisplayRaidSlotsCheckbox)
        GreatVaultOptionsContainer:AddChild(TooltipDisplayMythicPlusSlotsCheckbox)
        GreatVaultOptionsContainer:AddChild(TooltipDisplayWorldSlotsCheckBox)
        MythicPlusOptionsContainer:AddChild(TooltipDisplayPlayerKeystoneCheckbox)
        MythicPlusOptionsContainer:AddChild(TooltipDisplayPartyKeystoneCheckbox)
        --[[MythicPlusOptionsContainer:AddChild(TooltipDisplayAffixesCheckbox)
        MythicPlusOptionsContainer:AddChild(TooltipDisplayAffixesDescCheckbox)]]
        MythicPlusOptionsContainer:AddChild(TooltipTextureIconSizeDropdown)
        MSGUI_Container:AddChild(PositionOptionsContainer)
        PositionOptionsContainer:AddChild(TooltipAnchorFromPosition)
        PositionOptionsContainer:AddChild(TooltipAnchorToPosition)
        PositionOptionsContainer:AddChild(TooltipXOffsetSlider)
        PositionOptionsContainer:AddChild(TooltipYOffsetSlider)

    end

    -- local function DrawLayoutContainer(MSGUI_Container)

    --     local LayoutOneImage = MSGUI:Create("Icon")
    --     LayoutOneImage:SetImage("Interface\\AddOns\\MinimapStats\\Media\\LayoutOne.tga")
    --     LayoutOneImage:SetImageSize(200, 200)
    --     LayoutOneImage:SetRelativeWidth(0.33)
    --     LayoutOneImage:SetLabel("Default")
    --     LayoutOneImage:SetCallback("OnClick", function() MS:LoadLayout(1) end)
    --     LayoutOneImage:SetCallback("OnEnter", function() LayoutOneImage:SetLabel("|cFFFFCC00Default|r") end)
    --     LayoutOneImage:SetCallback("OnLeave", function() LayoutOneImage:SetLabel("Default") end)

    --     local LayoutTwoImage = MSGUI:Create("Icon")
    --     LayoutTwoImage:SetImage("Interface\\AddOns\\MinimapStats\\Media\\LayoutTwo.tga")
    --     LayoutTwoImage:SetImageSize(200, 200)
    --     LayoutTwoImage:SetRelativeWidth(0.33)
    --     LayoutTwoImage:SetLabel("Corners")
    --     LayoutTwoImage:SetCallback("OnClick", function() MS:LoadLayout(2) end)
    --     LayoutTwoImage:SetCallback("OnEnter", function() LayoutTwoImage:SetLabel("|cFFFFCC00Corners|r") end)
    --     LayoutTwoImage:SetCallback("OnLeave", function() LayoutTwoImage:SetLabel("Corners") end)

    --     local LayoutThreeImage = MSGUI:Create("Icon")
    --     LayoutThreeImage:SetImage("Interface\\AddOns\\MinimapStats\\Media\\LayoutThree.tga")
    --     LayoutThreeImage:SetImageSize(200, 200)
    --     LayoutThreeImage:SetRelativeWidth(0.33)
    --     LayoutThreeImage:SetLabel("Inverted Corners")
    --     LayoutThreeImage:SetCallback("OnClick", function() MS:LoadLayout(3) end)
    --     LayoutThreeImage:SetCallback("OnEnter", function() LayoutThreeImage:SetLabel("|cFFFFCC00Inverted Corners|r") end)
    --     LayoutThreeImage:SetCallback("OnLeave", function() LayoutThreeImage:SetLabel("Inverted Corners") end)

    --     local LayoutInformationContainer = MSGUI:Create("InlineGroup")
    --     LayoutInformationContainer:SetLayout("Flow")
    --     LayoutInformationContainer:SetFullWidth(true)

    --     local LayoutInformationText = MSGUI:Create("Label")
    --     LayoutInformationText:SetText("|cFFFFCC00Layouts are a way to quickly change the appearance of MinimapStats. This will only change the anchor position, X & Y offsets of toggled elements. All other settings will remain the same.|r")
    --     LayoutInformationText:SetFullWidth(true)

    --     MSGUI_Container:AddChild(LayoutInformationContainer)
    --     LayoutInformationContainer:AddChild(LayoutInformationText)
    --     MSGUI_Container:AddChild(LayoutOneImage)
    --     MSGUI_Container:AddChild(LayoutTwoImage)
    --     MSGUI_Container:AddChild(LayoutThreeImage)

    -- end

    local function DrawImportExportContainer(MSGUI_Container)
        local ImportOptionsContainer = MSGUI:Create("InlineGroup")
        ImportOptionsContainer:SetTitle("Import Options")
        ImportOptionsContainer:SetLayout("Flow")
        ImportOptionsContainer:SetFullWidth(true)

        local ImportEditBox = MSGUI:Create("MultiLineEditBox")
        ImportEditBox:SetLabel("Import String")
        ImportEditBox:SetNumLines(5)
        ImportEditBox:SetFullWidth(true)
        ImportEditBox:DisableButton(true)

        local ImportButton = MSGUI:Create("Button")
        ImportButton:SetText("Import")
        ImportButton:SetCallback("OnClick", 
            function() 
            MS:ImportSavedVariables(ImportEditBox:GetText())
            StaticPopupDialogs["MINIMAPSTATS_RELOAD"] = {
                text = "A reload is required for all changes to take effect. Do you want to reload now?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function() ReloadUI() end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3
            }
            StaticPopup_Show("MINIMAPSTATS_RELOAD")
        end)
        ImportButton:SetFullWidth(true)

        local ExportOptionsContainer = MSGUI:Create("InlineGroup")
        ExportOptionsContainer:SetTitle("Export Options")
        ExportOptionsContainer:SetLayout("Flow")
        ExportOptionsContainer:SetFullWidth(true)

        local ExportEditBox = MSGUI:Create("MultiLineEditBox")
        ExportEditBox:SetLabel("Export String")
        ExportEditBox:SetFullWidth(true)
        ExportEditBox:SetNumLines(5)
        ExportEditBox:DisableButton(true)

        local ExportButton = MSGUI:Create("Button")
        ExportButton:SetText("Export")
        ExportButton:SetCallback("OnClick", function() ExportEditBox:SetText(MS:ExportSavedVariables()) ExportEditBox:HighlightText() ExportEditBox:SetFocus() end)
        ExportButton:SetRelativeWidth(0.5)

        local HighlightExportEditBox = MSGUI:Create("Button")
        HighlightExportEditBox:SetText("Highlight Text")
        HighlightExportEditBox:SetCallback("OnClick", function() ExportEditBox:HighlightText() ExportEditBox:SetFocus() end)
        HighlightExportEditBox:SetRelativeWidth(0.5)

        MSGUI_Container:AddChild(ImportOptionsContainer)
        ImportOptionsContainer:AddChild(ImportEditBox)
        ImportOptionsContainer:AddChild(ImportButton)

        MSGUI_Container:AddChild(ExportOptionsContainer)
        ExportOptionsContainer:AddChild(ExportButton)
        ExportOptionsContainer:AddChild(HighlightExportEditBox)
        ExportOptionsContainer:AddChild(ExportEditBox)
    end


    function SelectedGroup(MSGUI_Container, Event, Group)
        MSGUI_Container:ReleaseChildren()
        if Group == "General" then
            DrawGeneralContainer(MSGUI_Container)
            MS.ShowDiffID = false
        elseif Group == "Time" then
            DrawTimeContainer(MSGUI_Container)
            MS.ShowDiffID = false
        elseif Group == "System Stats" then
            DrawSystemStatsContainer(MSGUI_Container)
            MS.ShowDiffID = false
        elseif Group == "Location" then
            DrawLocationContainer(MSGUI_Container)
            MS.ShowDiffID = false
        elseif Group == "Coordinates" then
            MS.ShowDiffID = false
            DrawCoordinatesContainer(MSGUI_Container)
        elseif Group == "Instance Difficulty" then
            DrawInstanceDifficultyContainer(MSGUI_Container)
            MS.ShowDiffID = true
        elseif Group == "Tooltip" then
            DrawTooltipContainer(MSGUI_Container)
            MS.ShowDiffID = false
        -- elseif Group == "Layout Manager" then
        --     DrawLayoutContainer(MSGUI_Container)
        --     MS.ShowDiffID = false
        elseif Group == "Import/Export" then
            DrawImportExportContainer(MSGUI_Container)
            MS.ShowDiffID = false
        end
        MS:UpdateInstanceDifficultyFrame()
    end

    GUIContainerTabGroup = MSGUI:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "General",                             value = "General"},
        { text = "Time",                                value = "Time" },
        { text = "System Stats",                        value = "System Stats" },
        { text = "Location",                            value = "Location" },
        { text = "Coordinates",                         value = "Coordinates" },
        { text = "Instance Difficulty",                 value = "Instance Difficulty" },
        { text = "Tooltip",                             value = "Tooltip" },
        -- { text = "Layout Manager",                      value = "Layout Manager" },
        { text = "Import/Export",                       value = "Import/Export" }
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("General")
    MSGUI_Container:AddChild(GUIContainerTabGroup)
end