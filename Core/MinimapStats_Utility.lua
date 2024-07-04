MS = {}
MS.ADDON_NAME = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
MS.ADDON_VERSION = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
MS.ADDON_AUTHOR = C_AddOns.GetAddOnMetadata("MinimapStats", "Author")
MS.ANCHORS = {
    ["TOPLEFT"] = "TOPLEFT",
    ["TOP"] = "TOP",
    ["TOPRIGHT"] = "TOPRIGHT",
    ["LEFT"] = "LEFT",
    ["CENTER"] = "CENTER",
    ["RIGHT"] = "RIGHT",
    ["BOTTOMLEFT"] = "BOTTOMLEFT",
    ["BOTTOM"] = "BOTTOM",
    ["BOTTOMRIGHT"] = "BOTTOMRIGHT"
}
MS.DefaultSettings = {
    global = {
        -- General
        FontFace = "Fonts\\FRIZQT__.ttf",
        FontFlag = "OUTLINE",
        FontShadow = false,
        ShadowColorR = 0.0,
        ShadowColorG = 0.0,
        ShadowColorB = 0.0,
        ShadowOffsetX = 0.0,
        ShadowOffsetY = 0.0,
        ElementFrameStrata = "MEDIUM",
        FontColourR = 1.0,
        FontColourG = 1.0,
        FontColourB = 1.0,
        AccentColourR = 0.5,
        AccentColourG = 0.5,
        AccentColourB = 1.0,
        SavedAccentColourR = 0.5,
        SavedAccentColourG = 0.5,
        SavedAccentColourB = 1.0,
        ClassAccentColour = false,
        -- Time Frame
        ShowTimeFrame = true,
        TimeFormat = "24H", -- "12H" or "24H"
        TimeType = "LOCAL", -- "LOCAL" or "SERVER"
        MouseoverDate = true,
        DateFormat = "DD/MM/YY",
        TimeUpdateInterval = 15,
        TimeAnchorPosition = "BOTTOM",
        TimeXOffset = 0,
        TimeYOffset = 15,
        TimeFontSize = 21,
        -- SystemStats Frame
        ShowSystemsStatsFrame = true,
        SystemStatsFormatString = "FPS | HomeMS",
        SystemStatsUpdateInterval = 10,
        SystemStatsAnchorPosition = "BOTTOM",
        SystemStatsXOffset = 0,
        SystemStatsYOffset = 3,
        SystemStatsFontSize = 12,
        -- Location Frame
        ShowLocationFrame = true,
        LocationColourFormat = "Primary", -- "Primary", "Reaction", "Accent" or "Custom"
        LocationColourR = 1.0,
        LocationColourG = 1.0,
        LocationColourB = 1.0,
        LocationAnchorPosition = "TOP",
        LocationXOffset = 0,
        LocationYOffset = -3,
        LocationFontSize = 12,
        -- Coordinates Frame
        ShowCoordinatesFrame = true,
        CoordinatesFormat = "0, 0", -- "0.0, 0.0" or "0.00, 0.00"
        CoordinatesUpdateInterval = 3,
        CoordinatesUpdateInRealTime = false,
        CoordinatesAnchorPosition = "TOP",
        CoordinatesXOffset = 0,
        CoordinatesYOffset = -15,
        CoordinatesFontSize = 12,
        -- Instance Difficulty Frame
        ShowInstanceDifficultyFrame = true,
        InstanceDifficultyAnchorPosition = "TOPLEFT",
        InstanceDifficultyXOffset = 3,
        InstanceDifficultyYOffset = -3,
        InstanceDifficultyFontSize = 12,
        -- Tooltip Options
        ShowTooltip = true,
        TooltipAnchorFrom = "TOPRIGHT",
        TooltipAnchorTo = "BOTTOMRIGHT",
        TooltipXOffset = 1,
        TooltipYOffset = -2,
        DisplayLockouts = true,
        DisplayPlayerKeystone = true,
        DisplayPartyKeystones = true,
        DisplayAffixes = true,
        DisplayAffixDesc = false,
        DisplayFriendsList = true,
    }
}

function MS:SetAccentColour()
    local DB = MS.DB.global or {}
    if DB.ClassAccentColour then
        DB.AccentColourR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
        DB.AccentColourG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
        DB.AccentColourB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
    else
        DB.AccentColourR = DB.SavedAccentColourR
        DB.AccentColourG = DB.SavedAccentColourG
        DB.AccentColourB = DB.SavedAccentColourB
    end
end

function MS:SetReactionColour()
    local PVPZone = GetZonePVPInfo()
    if PVPZone == 'arena' then
        LocationColor = MS:CalculateHexColour(0.84, 0.03, 0.03)
    elseif PVPZone == 'friendly' then
        LocationColor = MS:CalculateHexColour(0.05, 0.85, 0.03)
    elseif PVPZone == 'contested' then
        LocationColor = MS:CalculateHexColour(0.9, 0.85, 0.05)
    elseif PVPZone == 'hostile' then
        LocationColor = MS:CalculateHexColour(0.84, 0.03, 0.03)
    elseif PVPZone == 'sanctuary' then
        LocationColor = MS:CalculateHexColour(0.035, 0.58, 0.84)
    elseif PVPZone == 'combat' then
        LocationColor = MS:CalculateHexColour(0.84, 0.03, 0.03)
    else
        LocationColor = MS:CalculateHexColour(0.9, 0.85, 0.05)
    end

    return LocationColor
end

MS.CharacterClassColours = {
    ["Death Knight"] = "|cFFC41E3A",
    ["Demon Hunter"] = "|cFFA330C9",
    ["Druid"] = "|cFFFF7C0A",
    ["Evoker"] = "|cFF33937F",
    ["Hunter"] = "|cFFAAD372",
    ["Mage"] = "|cFF3FC7EB",
    ["Monk"] = "|cFF00FF98",
    ["Paladin"] = "|cFFF48CBA",
    ["Priest"] = "|cFFFFFFFF",
    ["Rogue"] = "|cFFFFF468",
    ["Shaman"] = "|cFF0070DD",
    ["Warlock"] = "|cFF8788EE",
    ["Warrior"] = "|cFFC69B6D",
}

MS.GreatVaultiLvls = {
    [2] = "509", -- +2
    [3] = "509", -- +3
    [4] = "512", -- +4
    [5] = "512", -- +5
    [6] = "515", -- +6
    [7] = "515", -- +7
    [8] = "519", -- +8
    [9] = "519", -- +9
    [10] = "522" -- +10
}

MS.GarrisonInstanceIDs = {
    [1152] = true,
    [1153] = true,
    [1154] = true,
    [1158] = true,
    [1159] = true,
    [1160] = true,
}

function MS:CalculateHexColour(R, G, B)
    return string.format("|cFF%02x%02x%02x", R * 255, G * 255, B * 255, 1)
end

function MS:UpdateAllElements()
    if MS.DB.global.ShowTimeFrame then MS:UpdateTimeFrame() end
    if MS.DB.global.ShowSystemsStatsFrame then MS:UpdateSystemStatsFrame() end
    if MS.DB.global.ShowLocationFrame then MS:UpdateLocationFrame() end
    if MS.DB.global.ShowCoordinatesFrame then MS:UpdateCoordinatesFrame() end
    if MS.DB.global.ShowInstanceDifficultyFrame then MS:UpdateInstanceDifficultyFrame() end
end

function MS:SetupSlashCommands()
    SLASH_MINIMAPSTATS1 = "/minimapstats"
    SLASH_MINIMAPSTATS2 = "/ms"
    SlashCmdList["MINIMAPSTATS"] = function()
        MS:CreateGUI()
        MS.isGUIOpen = true
    end
end