local _, MS = ...
MS.ADDON_NAME = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
MS.ADDON_VERSION = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
MS.ADDON_AUTHOR = C_AddOns.GetAddOnMetadata("MinimapStats", "Author")
MS.BUILDVERSION = select(4, GetBuildInfo())
MS.OR = LibStub:GetLibrary("LibOpenRaid-1.0", true)
MS.GUI = LibStub:GetLibrary("AceGUI-3.0")
MS.NUM_OF_AFFIXES = 5
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
        TimeYOffset = 18,
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
        CoordinatesYOffset = -18,
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
        DisplayAffixThresholds = true,
        DisplayAffixDesc = false,
        DisplayVaultOptions = true,
        DisplayRaidSlots = true,
        DisplayMythicPlusSlots = true,
        DisplayWorldSlots = true,
        DisplayTime = true,
        TooltipTextureIconSize = 16,
    }
}

function MS:SetAccentColour()
    if MS.DB.global.ClassAccentColour then
        MS.DB.global.AccentColourR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
        MS.DB.global.AccentColourG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
        MS.DB.global.AccentColourB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
    else
        MS.DB.global.AccentColourR = MS.DB.global.SavedAccentColourR
        MS.DB.global.AccentColourG = MS.DB.global.SavedAccentColourG
        MS.DB.global.AccentColourB = MS.DB.global.SavedAccentColourB
    end

    MS.AccentColour = MS:CalculateHexColour(MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
end

function MS:SetReactionColour()
    local PVPZone = C_PvP.GetZonePVPInfo()
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

if MS.BUILDVERSION > 110000 then
    MS.MythicPlusGreatVaultiLvls = {
        [2] = "649",        -- +2
        [3] = "649",        -- +3
        [4] = "652",        -- +4
        [5] = "652",        -- +5
        [6] = "655",        -- +6
        [7] = "658",        -- +7
        [8] = "658",        -- +8
        [9] = "658",        -- +9
        [10] = "662",       -- +10
    }
    MS.RaidGreatVaultiLvls = {
        [14] = "636",                   -- Normal
        [15] = "649",                   -- Heroic
        [16] = "623",                   -- Heroic
        [17] = "623",                   -- LFR
    }
    MS.WorldGreatVaultiLvls = {
        [1] = "623",                    -- Tier 1
        [2] = "623",                    -- Tier 2
        [3] = "626",                    -- Tier 3
        [4] = "632",                    -- Tier 4
        [5] = "636",                    -- Tier 5
        [6] = "642",                    -- Tier 6
        [7] = "645",                    -- Tier 7
        [8] = "649",                    -- Tier 8
    }
end

MS.RaidDifficultyIDs = {
    [14] = "Normal",
    [15] = "Heroic",
    [16] = "Mythic",
    [17] = "LFR",
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
    SlashCmdList["MINIMAPSTATS"] = function(msg)
        if msg == "" then
            MS:CreateGUI()
        elseif msg == "debug" then
            MS:DebugUI()
        end
    end
end

function MS:ResetGeneralOptions()
    MS.DB.global.FontFace = "Fonts\\FRIZQT__.ttf"
    MS.DB.global.FontFlag = "OUTLINE"
    MS.DB.global.FontShadow = false
    MS.DB.global.ShadowColorR = 0.0
    MS.DB.global.ShadowColorG = 0.0
    MS.DB.global.ShadowColorB = 0.0
    MS.DB.global.ShadowOffsetX = 0.0
    MS.DB.global.ShadowOffsetY = 0.0
    MS.DB.global.ElementFrameStrata = "MEDIUM"
    MS.DB.global.FontColourR = 1.0
    MS.DB.global.FontColourG = 1.0
    MS.DB.global.FontColourB = 1.0
    MS.DB.global.AccentColourR = 0.5
    MS.DB.global.AccentColourG = 0.5
    MS.DB.global.AccentColourB = 1.0
    MS.DB.global.SavedAccentColourR = 0.5
    MS.DB.global.SavedAccentColourG = 0.5
    MS.DB.global.SavedAccentColourB = 1.0
    MS.DB.global.ClassAccentColour = false
end

function MS:ResetTimeOptions()
    MS.DB.global.ShowTimeFrame = true
    MS.DB.global.TimeFormat = "24H"
    MS.DB.global.TimeType = "LOCAL"
    MS.DB.global.MouseoverDate = true
    MS.DB.global.DateFormat = "DD/MM/YY"
    MS.DB.global.TimeUpdateInterval = 15
    MS.DB.global.TimeAnchorPosition = "BOTTOM"
    MS.DB.global.TimeXOffset = 0
    MS.DB.global.TimeYOffset = 18
    MS.DB.global.TimeFontSize = 21
end

function MS:ResetSystemStatsOptions()
    MS.DB.global.ShowSystemsStatsFrame = true
    MS.DB.global.SystemStatsFormatString = "FPS | HomeMS"
    MS.DB.global.SystemStatsUpdateInterval = 10
    MS.DB.global.SystemStatsAnchorPosition = "BOTTOM"
    MS.DB.global.SystemStatsXOffset = 0
    MS.DB.global.SystemStatsYOffset = 3
    MS.DB.global.SystemStatsFontSize = 12
end

function MS:ResetLocationOptions()
    MS.DB.global.ShowLocationFrame = true
    MS.DB.global.LocationColourFormat = "Primary"
    MS.DB.global.LocationColourR = 1.0
    MS.DB.global.LocationColourG = 1.0
    MS.DB.global.LocationColourB = 1.0
    MS.DB.global.LocationAnchorPosition = "TOP"
    MS.DB.global.LocationXOffset = 0
    MS.DB.global.LocationYOffset = -3
    MS.DB.global.LocationFontSize = 12
end

function MS:ResetCoordinatesOptions()
    MS.DB.global.ShowCoordinatesFrame = true
    MS.DB.global.CoordinatesFormat = "0, 0"
    MS.DB.global.CoordinatesUpdateInterval = 3
    MS.DB.global.CoordinatesUpdateInRealTime = false
    MS.DB.global.CoordinatesAnchorPosition = "TOP"
    MS.DB.global.CoordinatesXOffset = 0
    MS.DB.global.CoordinatesYOffset = -18
    MS.DB.global.CoordinatesFontSize = 12
end

function MS:ResetInstanceDifficultyOptions()
    MS.DB.global.ShowInstanceDifficultyFrame = true
    MS.DB.global.InstanceDifficultyAnchorPosition = "TOPLEFT"
    MS.DB.global.InstanceDifficultyXOffset = 3
    MS.DB.global.InstanceDifficultyYOffset = -3
    MS.DB.global.InstanceDifficultyFontSize = 12
end

function MS:ResetTooltipOptions()
    MS.DB.global.ShowTooltip = true
    MS.DB.global.TooltipAnchorFrom = "TOPRIGHT"
    MS.DB.global.TooltipAnchorTo = "BOTTOMRIGHT"
    MS.DB.global.TooltipXOffset = 1
    MS.DB.global.TooltipYOffset = -2
    MS.DB.global.DisplayLockouts = true
    MS.DB.global.DisplayPlayerKeystone = true
    MS.DB.global.DisplayPartyKeystones = true
    MS.DB.global.DisplayAffixes = true
    MS.DB.global.DisplayAffixDesc = false
    MS.DB.global.DisplayAffixThresholds = true
    MS.DB.global.DisplayVaultOptions = true
    MS.DB.global.TooltipTextureIconSize = 16
    MS.DB.global.DisplayTime = true
    MS.DB.global.DisplayRaidSlots = true
    MS.DB.global.DisplayMythicPlusSlots = true
    MS.DB.global.DisplayWorldSlots = true
end

function MS:FetchMythicPlusInfo()
    C_AddOns.LoadAddOn("Blizzard_ChallengesUI")
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestCurrentAffixes()
    MS.AffixIDs = C_MythicPlus.GetCurrentAffixes()
    C_MythicPlus.RequestRewards()
end

MS.WoWProjects = {
    [1] = "Retail",
    [2] = "Classic",
    [3] = "Burning Crusade",
    [11] = "Wrath of the Lich King",
    [14] = "Cataclysm"
}

local function GetTotalMemoryColor(AddOnTotalMemory)
    if AddOnTotalMemory > 110 then
        return "|cFFFF4040"
    else
        return "|cFF40FF40"  -- Green for good (<= 110MB)
    end
end

local function GetMemoryColor(AddOnMemory)
    if AddOnMemory >= 30 then
        return "|cFFFF4040"
    elseif AddOnMemory >= 10 then
        return "|cFFFFA500"
    else
        return "|cFF40FF40"
    end
end

function MS:FetchAddOnMemoryUsage()
    local AddOns = {}
    local AddOnsCount = C_AddOns.GetNumAddOns()
    local TotalAddOnMemory = 0
    UpdateAddOnMemoryUsage()
    for i = 1, AddOnsCount do
        local AddOnName = C_AddOns.GetAddOnInfo(i)
        local AddOnMemory = GetAddOnMemoryUsage(i) / 1024

        if AddOnMemory > 1 then
            table.insert(AddOns, {AddOnName, AddOnMemory})
            TotalAddOnMemory = TotalAddOnMemory + AddOnMemory
        end
    end

    table.sort(AddOns, function(a, b) return a[2] > b[2] end)

    for _, AddOnData in ipairs(AddOns) do
        local AddOnMemoryColour = GetMemoryColor(AddOnData[2])
        print(MS.AccentColour .. AddOnData[1] .. "|r: ", string.format("%s%.2f|rMB", AddOnMemoryColour, AddOnData[2]))
    end

    local TotalAddOnMemoryColour = GetTotalMemoryColor(TotalAddOnMemory)
    print("|cFF8080FFTotal AddOn Memory Usage|r: ", string.format("%s%.2f|rMB", TotalAddOnMemoryColour, TotalAddOnMemory))
end
