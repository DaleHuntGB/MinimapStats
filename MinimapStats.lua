local MS = {}
local AddOnName = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
local AddOnVersion = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
local LSM = LibStub("LibSharedMedia-3.0")
local ACC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local LSMFonts = {}

MS.MAX_X = 1000
MS.MAX_Y = 1000
MS.MIN_X = -1000
MS.MIN_Y = -1000

MinimapStatsFrame = CreateFrame("Frame", "MinimapStatsFrame", Minimap)
MinimapStatsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
MinimapStatsFrame:RegisterEvent("ADDON_LOADED")
MinimapStatsFrame:SetScript("OnEvent", function(_, event, addon) 
    if event == "ADDON_LOADED" and addon == "MinimapStats" then 
        MS:SetupDB() 
        MS:CreateOptions() 
        MS:CreateFrames() 
        MS:SetupSlashCommands() 
    end 
end)

function MS:SetupDB()
    MS.DefaultSettings = {
        ["General"] = {
            ["AccentColorR"] = 0.0,
            ["AccentColorG"] = 0.67,
            ["AccentColorB"] = 0.71,
            ["AccentColor"] = MS:ConvertAccentColor(0.0, 0.67, 0.71),
            ["Font"] = "Fonts\\FRIZQT__.TTF",
            ["FontOutline"] = "OUTLINE",
            ["ClassColor"] = false,
        },
        ["TimeFrame"] = {
            ["Point"] = "BOTTOM",
            ["RelativePoint"] = "BOTTOM",
            ["OffsetX"] = 0,
            ["OffsetY"] = 18,
            ["FontSize"] = 21,
            ["UpdateRate"] = 20,
            ["UseServerTime"] = false,
        },
        ["DateFrame"] = {
            ["Point"] = "TOP",
            ["RelativePoint"] = "TOP",
            ["OffsetX"] = 0,
            ["OffsetY"] = -18,
            ["FontSize"] = 12,
            ["UpdateRate"] = 60
        },
        ["SystemStatsFrame"] = {
            ["Point"] = "BOTTOM",
            ["RelativePoint"] = "BOTTOM",
            ["OffsetX"] = 0,
            ["OffsetY"] = 3,
            ["FontSize"] = 12,
            ["UpdateRate"] = 10
        },
        ["LocationFrame"] = {
            ["Point"] = "TOP",
            ["RelativePoint"] = "TOP",
            ["OffsetX"] = 0,
            ["OffsetY"] = -3,
            ["FontSize"] = 12
        },
        ["InstanceDifficultyFrame"] = {
            ["Point"] = "TOPLEFT",
            ["RelativePoint"] = "TOPLEFT",
            ["OffsetX"] = 3,
            ["OffsetY"] = -3,
            ["FontSize"] = 12
        }
    }

    if not MSDB then MSDB = MS.DefaultSettings
    else
        for Key, Value in pairs(MS.DefaultSettings) do
            if MSDB[Key] == nil then MSDB[Key] = Value end
        end
    end
end

function MS:CreateOptions()
    local Options = {
        type = "group",
        name = AddOnName .. " V" .. AddOnVersion,
        args = {
            TimeFrame = {
                type = "group",
                name = "Time",
                order = 2,
                args = {
                    Point = {
                        type = "select",
                        name = "Point",
                        desc = "Change Anchor Point of the Frame",
                        width = "full",
                        order = 3,
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.TimeFrame.Point end,
                        set = function(_, value) MSDB.TimeFrame.Point = value MS:UpdateFrames() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 4,
                        width = "full",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.TimeFrame.RelativePoint end,
                        set = function(_, value) MSDB.TimeFrame.RelativePoint = value MS:UpdateFrames() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 5,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.TimeFrame.OffsetX end,
                        set = function(_, value) MSDB.TimeFrame.OffsetX = value MS:UpdateFrames() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 6,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.TimeFrame.OffsetY end,
                        set = function(_, value) MSDB.TimeFrame.OffsetY = value MS:UpdateFrames() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 7,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.TimeFrame.FontSize end,
                        set = function(_, value) MSDB.TimeFrame.FontSize = value MS:UpdateFrames() end
                    },
                    UpdateRate = {
                        type = "range",
                        name = "Update Rate",
                        desc = "Update Frequency in Seconds",
                        order = 8,
                        min = 1,
                        max = 60,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.TimeFrame.UpdateRate end,
                        set = function(_, value) MSDB.TimeFrame.UpdateRate = value end
                    },
                    UseServerTime = {
                        type = "toggle",
                        name = "Use Server Time",
                        desc = "Server Time instead of Local Time",
                        order = 1,
                        get = function() return MSDB.TimeFrame.UseServerTime end,
                        set = function(_, value) MSDB.TimeFrame.UseServerTime = value MS:UpdateFrames() end
                    },
                }
            },
            DateFrame = {
                type = "group",
                name = "Date",
                order = 3,
                args = {
                    Point = {
                        type = "select",
                        name = "Point",
                        desc = "Change Anchor Point of the Frame",
                        width = "full",
                        order = 1,
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.DateFrame.Point end,
                        set = function(_, value) MSDB.DateFrame.Point = value MS:UpdateFrames() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 2,
                        width = "full",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.DateFrame.RelativePoint end,
                        set = function(_, value) MSDB.DateFrame.RelativePoint = value MS:UpdateFrames() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 3,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.OffsetX end,
                        set = function(_, value) MSDB.DateFrame.OffsetX = value MS:UpdateFrames() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 4,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.OffsetY end,
                        set = function(_, value) MSDB.DateFrame.OffsetY = value MS:UpdateFrames() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 5,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.FontSize end,
                        set = function(_, value) MSDB.DateFrame.FontSize = value MS:UpdateFrames() end
                    },
                    UpdateRate = {
                        type = "range",
                        name = "Update Rate",
                        desc = "Update Frequency in Seconds",
                        order = 6,
                        min = 1,
                        max = 60,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.UpdateRate end,
                        set = function(_, value) MSDB.DateFrame.UpdateRate = value end
                    },
                }
            },
            SystemStatsFrame = {
                type = "group",
                name = "System Stats",
                order = 4,
                args = {
                    Point = {
                        type = "select",
                        name = "Point",
                        desc = "Change Anchor Point of the Frame",
                        width = "full",
                        order = 1,
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.SystemStatsFrame.Point end,
                        set = function(_, value) MSDB.SystemStatsFrame.Point = value MS:UpdateFrames() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 2,
                        width = "full",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.SystemStatsFrame.RelativePoint end,
                        set = function(_, value) MSDB.SystemStatsFrame.RelativePoint = value MS:UpdateFrames() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 3,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.OffsetX end,
                        set = function(_, value) MSDB.SystemStatsFrame.OffsetX = value MS:UpdateFrames() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 4,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.OffsetY end,
                        set = function(_, value) MSDB.SystemStatsFrame.OffsetY = value MS:UpdateFrames() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 5,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.FontSize end,
                        set = function(_, value) MSDB.SystemStatsFrame.FontSize = value MS:UpdateFrames() end
                    },
                    UpdateRate = {
                        type = "range",
                        name = "Update Rate",
                        desc = "Update Frequency in Seconds",
                        order = 6,
                        min = 1,
                        max = 60,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.UpdateRate end,
                        set = function(_, value) MSDB.SystemStatsFrame.UpdateRate = value end
                    },
                }
            },
            LocationFrame = {
                type = "group",
                name = "Location",
                order = 5,
                args = {
                    Point = {
                        type = "select",
                        name = "Point",
                        desc = "Change Anchor Point of the Frame",
                        width = "full",
                        order = 1,
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.LocationFrame.Point end,
                        set = function(_, value) MSDB.LocationFrame.Point = value MS:UpdateFrames() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 2,
                        width = "full",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.LocationFrame.RelativePoint end,
                        set = function(_, value) MSDB.LocationFrame.RelativePoint = value MS:UpdateFrames() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 3,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.LocationFrame.OffsetX end,
                        set = function(_, value) MSDB.LocationFrame.OffsetX = value MS:UpdateFrames() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 4,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.LocationFrame.OffsetY end,
                        set = function(_, value) MSDB.LocationFrame.OffsetY = value MS:UpdateFrames() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 5,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.LocationFrame.FontSize end,
                        set = function(_, value) MSDB.LocationFrame.FontSize = value MS:UpdateFrames() end
                    },
                }
            },
            InstanceDifficultyFrame = {
                type = "group",
                name = "Instance Difficulty",
                order = 6,
                args = {
                    Point = {
                        type = "select",
                        name = "Point",
                        desc = "Change Anchor Point of the Frame",
                        width = "full",
                        order = 1,
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.InstanceDifficultyFrame.Point end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.Point = value MS:UpdateFrames() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 2,
                        width = "full",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right"
                        },
                        get = function() return MSDB.InstanceDifficultyFrame.RelativePoint end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.RelativePoint = value MS:UpdateFrames() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 3,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.InstanceDifficultyFrame.OffsetX end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.OffsetX = value MS:UpdateFrames() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 4,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.InstanceDifficultyFrame.OffsetY end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.OffsetY = value MS:UpdateFrames() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 5,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.InstanceDifficultyFrame.FontSize end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.FontSize = value MS:UpdateFrames() end
                    },
                }
            },
            General = {
                type = "group",
                name = "General",
                order = 1,
                args = {
                    FontOutline = {
                        type = "select",
                        name = "Font Outline",
                        desc = "Text Font Outline",
                        order = 4,
                        width = "full",
                        values = {
                            ["NONE"] = "None",
                            ["OUTLINE"] = "Outline",
                            ["THICKOUTLINE"] = "Thick Outline"
                        },
                        get = function() return MSDB.General.FontOutline end,
                        set = function(_, value) MSDB.General.FontOutline = value MS:UpdateFrames() end
                    },
                    Font = {
                        type = "select",
                        name = "Font",
                        desc = "Text Font",
                        order = 3,
                        width = "full",
                        values = MS:FetchSharedMediaFonts(),
                        get = function() return MSDB.General.Font end,
                        set = function(_, value) MSDB.General.Font = value MS:UpdateFrames() end
                    },
                    AccentColor = {
                        type = "color",
                        name = "Accent Color",
                        desc = "Text Accent Color",
                        order = 1,
                        hasAlpha = false,
                        get = function() return MSDB.General.AccentColorR, MSDB.General.AccentColorG, MSDB.General.AccentColorB end,
                        set = function(_, r, g, b) MSDB.General.AccentColorR = r MSDB.General.AccentColorG = g MSDB.General.AccentColorB = b MSDB.General.AccentColor = string.format("|cFF%02x%02x%02x", r * 255, g * 255, b * 255) MS:UpdateColourSelection() end
                    },
                    ClassColor = {
                        type = "toggle",
                        name = "Class Color",
                        desc = "Change the accent color to your class color",
                        order = 2,
                        get = function() return MSDB.General.ClassColor end,
                        set = function(_, value) MSDB.General.ClassColor = value MS:UpdateColourSelection() MS:UpdateFrames() end
                    },
                    ResetDefaults = {
                        type = "execute",
                        name = "Reset Defaults",
                        width = "full",
                        order = 5,
                        func = function() MS:ResetDefaults() end
                    },
                    PrintDebugInfo = {
                        type = "execute",
                        name = "Print Debug Info",
                        desc = "Prints Debug Information to Chat",
                        width = "full",
                        order = 6,
                        func = function() MS:PrintDebugInfo() end
                    }
                }
            }
        }
    }

    ACC:RegisterOptionsTable("MinimapStats", Options)
    ACD:AddToBlizOptions("MinimapStats", "MinimapStats")
end

function MS:ConvertAccentColor(r, g, b)
    return string.format("|cFF%02x%02x%02x", r * 255, g * 255, b * 255)
end

function MS:CreateFrames()
    MS:CreateTimeFrame()
    MS:CreateDateFrame()
    MS:CreateSystemsStatsFrame()
    MS:CreateLocationFrame()
    MS:CreateInstanceDifficultyFrame()
end

function MS:FetchSharedMediaFonts()
    local Fonts = LSM:HashTable("font")
    for Path, Font in pairs(Fonts) do
        LSMFonts[Font] = Path
    end
    return LSMFonts
end

function MS:GetCurrentTime()
    local Hour = date("%H")
    local Mins = date("%M")
    local GTHour, GTMins = GetGameTime()

    if MSDB.TimeFrame.UseServerTime then
        Hour = GTHour
        if GTMins < 10 then 
            Mins = "0" .. GTMins
        else
            Mins = GTMins
        end
    end

    return string.format("%s:%s", Hour, Mins)
end

function MS:GetCurrentDate()
    local Day = date("%d")
    local Month = date("%b")
    local Year = date("%Y")
    return string.format("%s %s %s", Day, Month, Year)
end

function MS:GetSystemStats()
    local FPS = ceil(GetFramerate())
    local _, _, HomeMS = GetNetStats()

    return FPS .. MSDB.General.AccentColor .. " FPS|r".. " | " .. HomeMS .. MSDB.General.AccentColor .. " MS|r"
end

function MS:GetLocation()
    local Zone = GetMinimapZoneText()
    return MSDB.General.AccentColor .. Zone .."|r"
end

function MS:GetInstanceDifficulty()
    local _, _, InstanceDifficulty, _, _, _, _, InstanceID, InstanceSize = GetInstanceInfo()
    local KeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local InstanceDifficultyIndicator = MinimapCluster.InstanceDifficulty
    local InstanceIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Instance or _G["MiniMapInstanceDifficulty"]
    local GuildIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Guild or _G["GuildInstanceDifficulty"]
    local ChallengeIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.ChallengeMode or _G["MiniMapChallengeMode"]
    local InGarrison = InstanceID == 1152 or InstanceID == 1153 or InstanceID == 1154 or InstanceID == 1158 or InstanceID == 1159 or InstanceID == 1160
    local NoInstance = ""
    local NormalDungeon = "5" .. MSDB.General.AccentColor .. "N" .. "|r"
    local HeroicDungeon = "5" .. MSDB.General.AccentColor .. "H" .. "|r"
    local MythicDungeon = "5" .. MSDB.General.AccentColor .. "M" .. "|r"
    local MythicPlusDungeon = "+" .. MSDB.General.AccentColor .. KeystoneLevel .. "|r"
    local TimewalkingDungeon = MSDB.General.AccentColor .. "TW" .. "|r"
    local TenNormalRaid = "10" .. MSDB.General.AccentColor .. "N" .. "|r"
    local TwentyFiveNormalRaid = "25" .. MSDB.General.AccentColor .. "N" .. "|r"
    local TenHeroicRaid = "10" .. MSDB.General.AccentColor .. "H" .. "|r"
    local TwentyFiveHeroicRaid = "25" .. MSDB.General.AccentColor .. "H" .. "|r"
    local FortyRaid = "40" .. MSDB.General.AccentColor .. "M" .. "|r"
    local TimewalkingRaid = InstanceSize .. MSDB.General.AccentColor .. "TW" .. "|r"
    local LFR = InstanceSize .. MSDB.General.AccentColor .. "LFR" .. "|r"
    local NormalFlexRaid = InstanceSize .. MSDB.General.AccentColor .. "N" .. "|r"
    local HeroicFlexRaid = InstanceSize .. MSDB.General.AccentColor .. "H" .. "|r"
    local MythicRaid = "20" .. MSDB.General.AccentColor .. "M" .. "|r"          

    if InstanceIndicator then
        InstanceIndicator:ClearAllPoints()
        InstanceIndicator:SetAlpha(0)
    end
    if GuildIndicator then
        GuildIndicator:ClearAllPoints()
        GuildIndicator:SetAlpha(0)
    end
    if ChallengeIndicator then
        ChallengeIndicator:ClearAllPoints()
        ChallengeIndicator:SetAlpha(0)
    end
    
    if InstanceDifficulty == 0 then      -- No Instance
        return NoInstance
    elseif InGarrison then               -- Garrison
        return NoInstance
    elseif InstanceDifficulty == 1 then  -- Normal Dungeon
        return NormalDungeon
    elseif InstanceDifficulty == 2 then  -- Heroic Dungeon
        return HeroicDungeon
    elseif InstanceDifficulty == 23 then -- Mythic Dungeon
        return MythicDungeon
    elseif InstanceDifficulty == 8 then  -- Mythic+ Dungeon
        return MythicPlusDungeon
    elseif InstanceDifficulty == 24 then -- Timewalking Dungeon
        return TimewalkingDungeon
    elseif InstanceDifficulty == 3 then  -- 10M Normal Raid
        return TenNormalRaid
    elseif InstanceDifficulty == 5 then  -- 10M Heroic Raid
        return TenHeroicRaid
    elseif InstanceDifficulty == 4 then  -- 25M Normal Raid
        return TwentyFiveNormalRaid
    elseif InstanceDifficulty == 6 then  -- 25M Heroic Raid
        return TwentyFiveHeroicRaid
    elseif InstanceDifficulty == 9 then  -- 40M Raid
        return FortyRaid
    elseif InstanceDifficulty == 33 then -- Timewalking Raid
        return TimewalkingRaid
    elseif InstanceDifficulty == 17 then -- Timewalking Raid
        return LFR
    elseif InstanceDifficulty == 14 then -- Normal Flex Raid
        return NormalFlexRaid
    elseif InstanceDifficulty == 15 then -- Heroic Flex Raid
        return HeroicFlexRaid
    elseif InstanceDifficulty == 16 then -- Mythic Raid
        return MythicRaid
    end
end

function MS:CreateTimeFrame()
    TimeFrame = CreateFrame("Frame", "TimeFrame", Minimap)
    TimeFrame:SetFrameStrata("MEDIUM")
    TimeFrame:SetPoint(MSDB.TimeFrame.Point, Minimap, MSDB.TimeFrame.RelativePoint, MSDB.TimeFrame.OffsetX, MSDB.TimeFrame.OffsetY)

    TimeFrameText = TimeFrame:CreateFontString("TimeFrameText", "OVERLAY")
    TimeFrameText:SetPoint(MSDB.TimeFrame.Point, TimeFrame, MSDB.TimeFrame.RelativePoint, 0, 0)
    TimeFrameText:SetFont(MSDB.General.Font, MSDB.TimeFrame.FontSize, MSDB.General.FontOutline)
    TimeFrameText:SetText(MS:GetCurrentTime())
    TimeFrameText:SetTextColor(1, 1, 1, 1)
    TimeFrameText:SetShadowOffset(0, 0)
    
    TimeFrame:SetSize(TimeFrameText:GetStringWidth() or 220, TimeFrameText:GetStringHeight() or 24)

    TimeFrame:SetScript("OnUpdate", function()
        if not TimeLastUpdate or TimeLastUpdate < GetTime() - MSDB.TimeFrame.UpdateRate then
            TimeLastUpdate = GetTime()
            TimeFrameText:SetText(MS:GetCurrentTime())
        end
    end)
end

function MS:CreateDateFrame()
    DateFrame = CreateFrame("Frame", "DateFrame", Minimap)
    DateFrame:SetFrameStrata("MEDIUM")
    DateFrame:SetPoint(MSDB.DateFrame.Point, Minimap, MSDB.DateFrame.RelativePoint, MSDB.DateFrame.OffsetX, MSDB.DateFrame.OffsetY)

    DateFrameText = DateFrame:CreateFontString("DateFrameText", "OVERLAY")
    DateFrameText:SetPoint(MSDB.DateFrame.Point, DateFrame, MSDB.DateFrame.RelativePoint, 0, 0)
    DateFrameText:SetFont(MSDB.General.Font, MSDB.DateFrame.FontSize, MSDB.General.FontOutline)
    DateFrameText:SetText(MS:GetCurrentDate())
    DateFrameText:SetTextColor(1, 1, 1, 1)
    DateFrameText:SetShadowOffset(0, 0)

    DateFrame:SetSize(DateFrameText:GetStringWidth() or 220, DateFrameText:GetStringHeight() or 12)

    DateFrame:SetScript("OnUpdate", function()
        if not DateLastUpdate or DateLastUpdate < GetTime() - MSDB.DateFrame.UpdateRate then
            DateLastUpdate = GetTime()
            DateFrameText:SetText(MS:GetCurrentDate())
        end
    end)

    DateFrame:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then ToggleCalendar() end end)
end

function MS:CreateSystemsStatsFrame()
    SystemStatsFrame = CreateFrame("Frame", "SystemStatsFrame", Minimap)
    SystemStatsFrame:SetFrameStrata("MEDIUM")
    SystemStatsFrame:SetPoint(MSDB.SystemStatsFrame.Point, Minimap, MSDB.SystemStatsFrame.RelativePoint, MSDB.SystemStatsFrame.OffsetX, MSDB.SystemStatsFrame.OffsetY)

    SystemStatsFrameText = SystemStatsFrame:CreateFontString("SystemStatsFrameText", "OVERLAY")
    SystemStatsFrameText:SetPoint(MSDB.SystemStatsFrame.Point, SystemStatsFrame, MSDB.SystemStatsFrame.RelativePoint, 0, 0)
    SystemStatsFrameText:SetFont(MSDB.General.Font, MSDB.SystemStatsFrame.FontSize, MSDB.General.FontOutline)
    SystemStatsFrameText:SetText(MS:GetSystemStats())
    SystemStatsFrameText:SetShadowOffset(0, 0)

    SystemStatsFrame:SetSize(SystemStatsFrameText:GetStringWidth() or 220, SystemStatsFrameText:GetStringHeight() or 12)

    SystemStatsFrame:SetScript("OnUpdate", function()
        if not SystemStatsLastUpdate or SystemStatsLastUpdate < GetTime() - MSDB.SystemStatsFrame.UpdateRate then
            SystemStatsLastUpdate = GetTime()
            SystemStatsFrameText:SetText(MS:GetSystemStats())
        end
    end)
end

function MS:CreateLocationFrame()
    LocationFrame = CreateFrame("Frame", "LocationFrame", Minimap)
    LocationFrame:SetFrameStrata("MEDIUM")
    LocationFrame:SetPoint(MSDB.LocationFrame.Point, Minimap, MSDB.LocationFrame.RelativePoint, MSDB.LocationFrame.OffsetX, MSDB.LocationFrame.OffsetY)

    LocationFrameText = LocationFrame:CreateFontString("LocationFrameText", "OVERLAY")
    LocationFrameText:SetPoint(MSDB.LocationFrame.Point, LocationFrame, MSDB.LocationFrame.RelativePoint, 0, 0)
    LocationFrameText:SetFont(MSDB.General.Font, MSDB.LocationFrame.FontSize, MSDB.General.FontOutline)
    LocationFrameText:SetText(MS:GetLocation())
    LocationFrameText:SetShadowOffset(0, 0)

    LocationFrame:SetSize(LocationFrameText:GetStringWidth() or 220, LocationFrameText:GetStringHeight() or 12)

    LocationFrame:RegisterEvent("ZONE_CHANGED")
    LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    LocationFrame:SetScript("OnEvent", function(_, event)
        if event == "ZONE_CHANGED" or 
        event == "ZONE_CHANGED_INDOORS" or 
        event == "ZONE_CHANGED_NEW_AREA" then
            LocationFrameText:SetText(MS:GetLocation())
        end
    end)
end

function MS:CreateInstanceDifficultyFrame()
    InstanceDifficultyFrame = CreateFrame("Frame", "InstanceDifficultyFrame", Minimap)
    InstanceDifficultyFrame:SetFrameStrata("MEDIUM")
    InstanceDifficultyFrame:SetPoint(MSDB.InstanceDifficultyFrame.Point, Minimap, MSDB.InstanceDifficultyFrame.RelativePoint, MSDB.InstanceDifficultyFrame.OffsetX, MSDB.InstanceDifficultyFrame.OffsetY)

    InstanceDifficultyFrameText = InstanceDifficultyFrame:CreateFontString("InstanceDifficultyFrameText", "OVERLAY")
    InstanceDifficultyFrameText:SetPoint(MSDB.InstanceDifficultyFrame.Point, InstanceDifficultyFrame, MSDB.InstanceDifficultyFrame.RelativePoint, 0, 0)
    InstanceDifficultyFrameText:SetFont(MSDB.General.Font, MSDB.InstanceDifficultyFrame.FontSize, MSDB.General.FontOutline)
    InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
    InstanceDifficultyFrameText:SetShadowOffset(0, 0)

    InstanceDifficultyFrame:SetSize(InstanceDifficultyFrameText:GetStringWidth() or 220, InstanceDifficultyFrameText:GetStringHeight() or 12)

    InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
    InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    InstanceDifficultyFrame:SetScript("OnEvent", function(_, event)
        if event == "ZONE_CHANGED" or 
        event == "ZONE_CHANGED_INDOORS" or 
        event == "ZONE_CHANGED_NEW_AREA" or 
        event == "PLAYER_ENTERING_WORLD" or 
        event == "GROUP_ROSTER_UPDATE" then
            InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
        end
    end)
end

function MS:UpdateFrames()
    TimeFrame:SetSize(TimeFrameText:GetStringWidth() or 220, TimeFrameText:GetStringHeight() or 24)
    TimeFrame:ClearAllPoints()
    TimeFrame:SetPoint(MSDB.TimeFrame.Point, Minimap, MSDB.TimeFrame.RelativePoint, MSDB.TimeFrame.OffsetX, MSDB.TimeFrame.OffsetY)
    TimeFrameText:SetFont(MSDB.General.Font, MSDB.TimeFrame.FontSize, MSDB.General.FontOutline)
    TimeFrameText:SetText(MS:GetCurrentTime())
    DateFrame:SetSize(DateFrameText:GetStringWidth() or 220, DateFrameText:GetStringHeight() or 12)
    DateFrame:ClearAllPoints()
    DateFrame:SetPoint(MSDB.DateFrame.Point, Minimap, MSDB.DateFrame.RelativePoint, MSDB.DateFrame.OffsetX, MSDB.DateFrame.OffsetY)
    DateFrameText:SetFont(MSDB.General.Font, MSDB.DateFrame.FontSize, MSDB.General.FontOutline)
    DateFrameText:SetText(MS:GetCurrentDate())
    SystemStatsFrame:SetSize(SystemStatsFrameText:GetStringWidth() or 220, SystemStatsFrameText:GetStringHeight() or 12)
    SystemStatsFrame:ClearAllPoints()
    SystemStatsFrame:SetPoint(MSDB.SystemStatsFrame.Point, Minimap, MSDB.SystemStatsFrame.RelativePoint, MSDB.SystemStatsFrame.OffsetX, MSDB.SystemStatsFrame.OffsetY)
    SystemStatsFrameText:SetFont(MSDB.General.Font, MSDB.SystemStatsFrame.FontSize, MSDB.General.FontOutline)
    SystemStatsFrameText:SetText(MS:GetSystemStats())
    LocationFrame:SetSize(LocationFrameText:GetStringWidth() or 220, LocationFrameText:GetStringHeight() or 12)
    LocationFrame:ClearAllPoints()
    LocationFrame:SetPoint(MSDB.LocationFrame.Point, Minimap, MSDB.LocationFrame.RelativePoint, MSDB.LocationFrame.OffsetX, MSDB.LocationFrame.OffsetY)
    LocationFrameText:SetFont(MSDB.General.Font, MSDB.LocationFrame.FontSize, MSDB.General.FontOutline)
    LocationFrameText:SetText(MS:GetLocation())
    InstanceDifficultyFrame:SetSize(InstanceDifficultyFrameText:GetStringWidth() or 220, InstanceDifficultyFrameText:GetStringHeight() or 12)
    InstanceDifficultyFrame:ClearAllPoints()
    InstanceDifficultyFrame:SetPoint(MSDB.InstanceDifficultyFrame.Point, Minimap, MSDB.InstanceDifficultyFrame.RelativePoint, MSDB.InstanceDifficultyFrame.OffsetX, MSDB.InstanceDifficultyFrame.OffsetY)
    InstanceDifficultyFrameText:SetFont(MSDB.General.Font, MSDB.InstanceDifficultyFrame.FontSize, MSDB.General.FontOutline)
    InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
end

function MS:SetupSlashCommands()
    SLASH_MINIMAPSTATS1 = "/minimapstats"
    SLASH_MINIMAPSTATS2 = "/ms"
    SlashCmdList["MINIMAPSTATS"] = function() InterfaceOptionsFrame_OpenToCategory("MinimapStats") end

    SLASH_RELOADUI1 = "/rl"
    SlashCmdList["RELOADUI"] = function() ReloadUI() end

    SLASH_RESET1 = "/msreset"
    SlashCmdList["RESET"] = function() MS:ResetDefaults() end

    SLASH_DEBUG1 = "/msdebug"
    SlashCmdList["DEBUG"] = function() MS:PrintDebugInfo() end
end

function MS:UpdateColourSelection()
    if MSDB.General.ClassColor then
        local _, class = UnitClass("player")
        local color = RAID_CLASS_COLORS[class]
        MSDB.General.AccentColorR = color.r
        MSDB.General.AccentColorG = color.g
        MSDB.General.AccentColorB = color.b
        MSDB.General.AccentColor = MS:ConvertAccentColor(color.r, color.g, color.b)
    end
    TimeFrameText:SetText(MS:GetCurrentTime())
    DateFrameText:SetText(MS:GetCurrentDate())
    SystemStatsFrameText:SetText(MS:GetSystemStats())
    LocationFrameText:SetText(MS:GetLocation())
    InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
end

function MS:PrintDebugInfo()
    print(AddOnName .. " V" .. AddOnVersion .. " Debug Information")
    -- Time Frame Debug Information
    print("|cFF00ADB5Time Frame Information|r")
    print("|cFF00ADB5Time Frame Text|r: " .. TimeFrameText:GetText())
    print("|cFF00ADB5Time Frame Location|r: " .. TimeFrame:GetPoint())
    print("|cFF00ADB5Time Frame X Offset|r: " .. MSDB.TimeFrame.OffsetX)
    print("|cFF00ADB5Time Frame Y Offset|r: " .. MSDB.TimeFrame.OffsetY)
    print("|cFF00ADB5Time Frame Font Size|r: " .. MSDB.TimeFrame.FontSize)
    print("|cFF00ADB5Time Frame Update Rate|r: " .. MSDB.TimeFrame.UpdateRate)
    -- Date Frame Debug Information
    print("|cFF00ADB5Date Frame Information|r")
    print("|cFF00ADB5Date Frame Text|r: " .. DateFrameText:GetText())
    print("|cFF00ADB5Date Frame Location|r: " .. DateFrame:GetPoint())
    print("|cFF00ADB5Date Frame X Offset|r: " .. MSDB.DateFrame.OffsetX)
    print("|cFF00ADB5Date Frame Y Offset|r: " .. MSDB.DateFrame.OffsetY)
    print("|cFF00ADB5Date Frame Font Size|r: " .. MSDB.DateFrame.FontSize)
    print("|cFF00ADB5Date Frame Update Rate|r: " .. MSDB.DateFrame.UpdateRate)
    -- System Stats Frame Debug Information
    print("|cFF00ADB5System Stats Frame Information|r")
    print("|cFF00ADB5System Stats Frame Text|r: " .. SystemStatsFrameText:GetText())
    print("|cFF00ADB5System Stats Frame Location|r: " .. SystemStatsFrame:GetPoint())
    print("|cFF00ADB5System Stats Frame X Offset|r: " .. MSDB.SystemStatsFrame.OffsetX)
    print("|cFF00ADB5System Stats Frame Y Offset|r: " .. MSDB.SystemStatsFrame.OffsetY)
    print("|cFF00ADB5System Stats Frame Font Size|r: " .. MSDB.SystemStatsFrame.FontSize)
    print("|cFF00ADB5System Stats Frame Update Rate|r: " .. MSDB.SystemStatsFrame.UpdateRate)
    -- Location Frame Debug Information
    print("|cFF00ADB5Location Frame Information|r")
    print("|cFF00ADB5Location Frame Text|r: " .. LocationFrameText:GetText())
    print("|cFF00ADB5Location Frame Location|r: " .. LocationFrame:GetPoint())
    print("|cFF00ADB5Location Frame X Offset|r: " .. MSDB.LocationFrame.OffsetX)
    print("|cFF00ADB5Location Frame Y Offset|r: " .. MSDB.LocationFrame.OffsetY)
    print("|cFF00ADB5Location Frame Font Size|r: " .. MSDB.LocationFrame.FontSize)
    -- Instance Difficulty Frame Debug Information
    print("|cFF00ADB5Instance Difficulty Frame Information|r")
    print("|cFF00ADB5Instance Difficulty Frame Text|r: " .. (InstanceDifficultyFrameText:GetText() or "No Instance"))
    print("|cFF00ADB5Instance Difficulty Frame Location|r: " .. (InstanceDifficultyFrame:GetPoint() or "No Instance"))
    print("|cFF00ADB5Instance Difficulty Frame X Offset|r: " .. MSDB.InstanceDifficultyFrame.OffsetX)
    print("|cFF00ADB5Instance Difficulty Frame Y Offset|r: " .. MSDB.InstanceDifficultyFrame.OffsetY)
    print("|cFF00ADB5Instance Difficulty Frame Font Size|r: " .. MSDB.InstanceDifficultyFrame.FontSize)
    -- General Information
    print("|cFF00ADB5General Information|r")
    print("|cFF00ADB5Font|r: " .. MSDB.General.Font)
    print("|cFF00ADB5Font Outline|r: " .. MSDB.General.FontOutline)
    print("|cFF00ADB5Accent Color|r: " .. "R: " .. MSDB.General.AccentColorR .. " G: " .. MSDB.General.AccentColorG .. " B: " .. MSDB.General.AccentColorB)
    print("|cFF00ADB5Class Color|r: " .. tostring(MSDB.General.ClassColor))
end

function MS:DeepCopy(table)
    local copy = {}
    for k, v in pairs(table) do
        if type(v) == 'table' then
            copy[k] = MS:DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function MS:ResetDefaults()
    MSDB = MS:DeepCopy(MS.DefaultSettings)
    MS:UpdateColourSelection()
    MS:UpdateFrames()
end