local MS = {}
local AddOnName = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
local AddOnVersion = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
local LSM = LibStub("LibSharedMedia-3.0")
local AC = LibStub("AceConfig-3.0")
local AD = LibStub("AceConfigDialog-3.0")
local AG = LibStub("AceGUI-3.0")
local LSMFonts = {}
local DEBUG_MODE = false

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
            ["Toggle"] = true,
            ["Point"] = "BOTTOM",
            ["RelativePoint"] = "BOTTOM",
            ["OffsetX"] = 0,
            ["OffsetY"] = 18,
            ["FontSize"] = 21,
            ["UpdateRate"] = 20,
            ["UseServerTime"] = false,
        },
        ["DateFrame"] = {
            ["Toggle"] = true,
            ["Point"] = "TOP",
            ["RelativePoint"] = "TOP",
            ["OffsetX"] = 0,
            ["OffsetY"] = -18,
            ["FontSize"] = 12,
            ["UpdateRate"] = 60
        },
        ["SystemStatsFrame"] = {
            ["Toggle"] = true,
            ["Point"] = "BOTTOM",
            ["RelativePoint"] = "BOTTOM",
            ["OffsetX"] = 0,
            ["OffsetY"] = 3,
            ["FontSize"] = 12,
            ["UpdateRate"] = 10
        },
        ["LocationFrame"] = {
            ["Toggle"] = true,
            ["Point"] = "TOP",
            ["RelativePoint"] = "TOP",
            ["OffsetX"] = 0,
            ["OffsetY"] = -3,
            ["FontSize"] = 12
        },
        ["InstanceDifficultyFrame"] = {
            ["Toggle"] = true,
            ["Point"] = "TOPLEFT",
            ["RelativePoint"] = "TOPLEFT",
            ["OffsetX"] = 3,
            ["OffsetY"] = -3,
            ["FontSize"] = 12
        },
        ["CoordinatesFrame"] = 
        {
            ["Toggle"] = true,
            ["Point"] = "TOP",
            ["RelativePoint"] = "TOP",
            ["OffsetX"] = 0,
            ["OffsetY"] = -35,
            ["FontSize"] = 12,
            ["Format"] = "OneDecimal",
            ["UpdateRate"] = 1,
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
                        set = function(_, value) MSDB.TimeFrame.Point = value MS:UpdateTimeFrame() end
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
                        set = function(_, value) MSDB.TimeFrame.RelativePoint = value MS:UpdateTimeFrame() end
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
                        set = function(_, value) MSDB.TimeFrame.OffsetX = value MS:UpdateTimeFrame() end
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
                        set = function(_, value) MSDB.TimeFrame.OffsetY = value MS:UpdateTimeFrame() end
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
                        set = function(_, value) MSDB.TimeFrame.FontSize = value MS:UpdateTimeFrame() end
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
                        set = function(_, value) MSDB.TimeFrame.UseServerTime = value MS:UpdateTimeFrame() end
                    },
                    Toggle = {
                        type = "toggle",
                        name = "Toggle",
                        desc = "Show/Hide Time Frame",
                        order = 2,
                        get = function() return MSDB.TimeFrame.Toggle end,
                        set = function(_, value) MSDB.TimeFrame.Toggle = value MS:UpdateTimeFrame() end
                    }
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
                        order = 2,
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
                        set = function(_, value) MSDB.DateFrame.Point = value MS:UpdateDateFrame() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 3,
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
                        set = function(_, value) MSDB.DateFrame.RelativePoint = value MS:UpdateDateFrame() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 4,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.OffsetX end,
                        set = function(_, value) MSDB.DateFrame.OffsetX = value MS:UpdateDateFrame() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 5,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.OffsetY end,
                        set = function(_, value) MSDB.DateFrame.OffsetY = value MS:UpdateDateFrame() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 6,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.FontSize end,
                        set = function(_, value) MSDB.DateFrame.FontSize = value MS:UpdateDateFrame() end
                    },
                    UpdateRate = {
                        type = "range",
                        name = "Update Rate",
                        desc = "Update Frequency in Seconds",
                        order = 7,
                        min = 1,
                        max = 60,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.DateFrame.UpdateRate end,
                        set = function(_, value) MSDB.DateFrame.UpdateRate = value end
                    },
                    Toggle = {
                        type = "toggle",
                        name = "Toggle",
                        desc = "Show/Hide Date Frame",
                        order = 1,
                        get = function() return MSDB.DateFrame.Toggle end,
                        set = function(_, value) MSDB.DateFrame.Toggle = value MS:UpdateDateFrame() end
                    }
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
                        order = 2,
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
                        set = function(_, value) MSDB.SystemStatsFrame.Point = value MS:UpdateSystemStatsFrame() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 3,
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
                        set = function(_, value) MSDB.SystemStatsFrame.RelativePoint = value MS:UpdateSystemStatsFrame() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 4,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.OffsetX end,
                        set = function(_, value) MSDB.SystemStatsFrame.OffsetX = value MS:UpdateSystemStatsFrame() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 5,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.OffsetY end,
                        set = function(_, value) MSDB.SystemStatsFrame.OffsetY = value MS:UpdateSystemStatsFrame() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 6,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.FontSize end,
                        set = function(_, value) MSDB.SystemStatsFrame.FontSize = value MS:UpdateSystemStatsFrame() end
                    },
                    UpdateRate = {
                        type = "range",
                        name = "Update Rate",
                        desc = "Update Frequency in Seconds",
                        order = 7,
                        min = 1,
                        max = 60,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.SystemStatsFrame.UpdateRate end,
                        set = function(_, value) MSDB.SystemStatsFrame.UpdateRate = value end
                    },
                    Toggle = {
                        type = "toggle",
                        name = "Toggle",
                        desc = "Show/Hide System Stats Frame",
                        order = 1,
                        get = function() return MSDB.SystemStatsFrame.Toggle end,
                        set = function(_, value) MSDB.SystemStatsFrame.Toggle = value MS:UpdateSystemStatsFrame() end
                    }
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
                        order = 2,
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
                        set = function(_, value) MSDB.LocationFrame.Point = value MS:UpdateLocationFrame() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 3,
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
                        set = function(_, value) MSDB.LocationFrame.RelativePoint = value MS:UpdateLocationFrame() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 4,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.LocationFrame.OffsetX end,
                        set = function(_, value) MSDB.LocationFrame.OffsetX = value MS:UpdateLocationFrame() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 5,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.LocationFrame.OffsetY end,
                        set = function(_, value) MSDB.LocationFrame.OffsetY = value MS:UpdateLocationFrame() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 6,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.LocationFrame.FontSize end,
                        set = function(_, value) MSDB.LocationFrame.FontSize = value MS:UpdateLocationFrame() end
                    },
                    Toggle = {
                        type = "toggle",
                        name = "Toggle",
                        desc = "Show/Hide Location Frame",
                        order = 1,
                        get = function() return MSDB.LocationFrame.Toggle end,
                        set = function(_, value) MSDB.LocationFrame.Toggle = value MS:UpdateLocationFrame() end
                    }
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
                        order = 2,
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
                        set = function(_, value) MSDB.InstanceDifficultyFrame.Point = value MS:UpdateInstanceDifficultyFrame() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 3,
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
                        set = function(_, value) MSDB.InstanceDifficultyFrame.RelativePoint = value MS:UpdateInstanceDifficultyFrame() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 4,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.InstanceDifficultyFrame.OffsetX end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.OffsetX = value MS:UpdateInstanceDifficultyFrame() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 5,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.InstanceDifficultyFrame.OffsetY end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.OffsetY = value MS:UpdateInstanceDifficultyFrame() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 6,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.InstanceDifficultyFrame.FontSize end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.FontSize = value MS:UpdateInstanceDifficultyFrame() end
                    },
                    Toggle = {
                        type = "toggle",
                        name = "Toggle",
                        desc = "Show/Hide Instance Difficulty Frame",
                        order = 1,
                        get = function() return MSDB.InstanceDifficultyFrame.Toggle end,
                        set = function(_, value) MSDB.InstanceDifficultyFrame.Toggle = value MS:UpdateInstanceDifficultyFrame() end
                    }
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
                        set = function(_, r, g, b) MSDB.General.AccentColorR = r MSDB.General.AccentColorG = g MSDB.General.AccentColorB = b MSDB.General.AccentColor = string.format("|cFF%02x%02x%02x", r * 255, g * 255, b * 255) MS:UpdateFrames() end
                    },
                    ClassColor = {
                        type = "toggle",
                        name = "Class Color",
                        desc = "Change the accent color to your class color",
                        order = 2,
                        get = function() return MSDB.General.ClassColor end,
                        set = function(_, value) MSDB.General.ClassColor = value MS:UpdateFrames() end
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
            },
            Coordinates = {
                type = "group",
                name = "Coordinates",
                order = 7,
                args = {
                    Point = {
                        type = "select",
                        name = "Point",
                        desc = "Change Anchor Point of the Frame",
                        width = "full",
                        order = 2,
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
                        get = function() return MSDB.CoordinatesFrame.Point end,
                        set = function(_, value) MSDB.CoordinatesFrame.Point = value MS:UpdateCoordinatesFrame() end
                    },
                    RelativePoint = {
                        type = "select",
                        name = "Relative Point",
                        desc = "Change Relative Point of the Frame",
                        order = 3,
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
                        get = function() return MSDB.CoordinatesFrame.RelativePoint end,
                        set = function(_, value) MSDB.CoordinatesFrame.RelativePoint = value MS:UpdateCoordinatesFrame() end
                    },
                    OffsetX = {
                        type = "range",
                        name = "Offset X",
                        desc = "X Offset of the Frame",
                        order = 4,
                        min = MS.MIN_X,
                        max = MS.MAX_X,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.CoordinatesFrame.OffsetX end,
                        set = function(_, value) MSDB.CoordinatesFrame.OffsetX = value MS:UpdateCoordinatesFrame() end
                    },
                    OffsetY = {
                        type = "range",
                        name = "Offset Y",
                        desc = "Y Offset of the Frame",
                        order = 5,
                        min = MS.MIN_Y,
                        max = MS.MAX_Y,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.CoordinatesFrame.OffsetY end,
                        set = function(_, value) MSDB.CoordinatesFrame.OffsetY = value MS:UpdateCoordinatesFrame() end
                    },
                    FontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Text Font Size",
                        order = 6,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "full",
                        get = function() return MSDB.CoordinatesFrame.FontSize end,
                        set = function(_, value) MSDB.CoordinatesFrame.FontSize = value MS:UpdateCoordinatesFrame() end
                    },
                    Toggle = {
                        type = "toggle",
                        name = "Toggle",
                        desc = "Show/Hide Coordinates Frame",
                        order = 1,
                        get = function() return MSDB.CoordinatesFrame.Toggle end,
                        set = function(_, value) MSDB.CoordinatesFrame.Toggle = value MS:UpdateCoordinatesFrame() end
                    },
                    Format = {
                        type = "select",
                        name = "Format",
                        desc = "Coordinates Format",
                        order = 7,
                        width = "full",
                        values = {
                            ["NoDecimal"] = "00, 00",
                            ["OneDecimal"] = "00.0, 00.0",
                            ["TwoDecimal"] = "00.00, 00.00"
                        },
                        get = function() return MSDB.CoordinatesFrame.Format end,
                        set = function(_, value) MSDB.CoordinatesFrame.Format = value MS:UpdateCoordinatesFrame() end
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
                        get = function() return MSDB.CoordinatesFrame.UpdateRate end,
                        set = function(_, value) MSDB.CoordinatesFrame.UpdateRate = value end
                    }
                }
            }
        }
    }

    AC:RegisterOptionsTable("MinimapStats", Options)
    AD:AddToBlizOptions("MinimapStats", "MinimapStats")
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
    MS:CreateCoordinatesFrame()
    MS:UpdateColourSelection()
    MS:SetupScripts()
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

function MS:GetCoordinates()
    local PlayerMap = C_Map.GetBestMapForUnit("player")
    local InstanceType = select(2, IsInInstance())
    if InstanceType == "none" and PlayerMap then
        local PlayerPosition = C_Map.GetPlayerMapPosition(PlayerMap, "player")
        if PlayerPosition then
            local PositionX, PositionY = PlayerPosition:GetXY()
            PositionXActual = PositionX * 100
            PositionYActual = PositionY * 100
            local NoDecimals = string.format("%.0f, %.0f", PositionXActual, PositionYActual)
            local OneDecimal = string.format("%.1f, %.1f", PositionXActual, PositionYActual)
            local TwoDecimals = string.format("%.2f, %.2f", PositionXActual, PositionYActual)
            if MSDB.CoordinatesFrame.Format == "NoDecimal" then
                return NoDecimals
            elseif MSDB.CoordinatesFrame.Format == "OneDecimal" then
                return OneDecimal
            elseif MSDB.CoordinatesFrame.Format == "TwoDecimal" then
                return TwoDecimals
            end
        else
            return " "
        end
    end
end

function MS:CreateTimeFrame()
        MS.TimeFrame = CreateFrame("Frame", "TimeFrame", Minimap)
        MS.TimeFrame:SetFrameStrata("MEDIUM")
        MS.TimeFrame:SetPoint(MSDB.TimeFrame.Point, Minimap, MSDB.TimeFrame.RelativePoint, MSDB.TimeFrame.OffsetX, MSDB.TimeFrame.OffsetY)

        MS.TimeFrameText = MS.TimeFrame:CreateFontString("TimeFrameText", "OVERLAY")
        MS.TimeFrameText:SetPoint(MSDB.TimeFrame.Point, MS.TimeFrame, MSDB.TimeFrame.RelativePoint, 0, 0)
        MS.TimeFrameText:SetFont(MSDB.General.Font, MSDB.TimeFrame.FontSize, MSDB.General.FontOutline)
        MS.TimeFrameText:SetText(MS:GetCurrentTime())
        MS.TimeFrameText:SetTextColor(1, 1, 1, 1)
        MS.TimeFrameText:SetShadowOffset(0, 0)
        
        MS.TimeFrame:SetSize(MS.TimeFrameText:GetStringWidth() or 220, MS.TimeFrameText:GetStringHeight() or 24)
end

function MS:CreateDateFrame()
    MS.DateFrame = CreateFrame("Frame", "DateFrame", Minimap)
    MS.DateFrame:SetFrameStrata("MEDIUM")
    MS.DateFrame:SetPoint(MSDB.DateFrame.Point, Minimap, MSDB.DateFrame.RelativePoint, MSDB.DateFrame.OffsetX, MSDB.DateFrame.OffsetY)

    MS.DateFrameText = MS.DateFrame:CreateFontString("DateFrameText", "OVERLAY")
    MS.DateFrameText:SetPoint(MSDB.DateFrame.Point, MS.DateFrame, MSDB.DateFrame.RelativePoint, 0, 0)
    MS.DateFrameText:SetFont(MSDB.General.Font, MSDB.DateFrame.FontSize, MSDB.General.FontOutline)
    MS.DateFrameText:SetText(MS:GetCurrentDate())
    MS.DateFrameText:SetTextColor(1, 1, 1, 1)
    MS.DateFrameText:SetShadowOffset(0, 0)

    MS.DateFrame:SetSize(MS.DateFrameText:GetStringWidth() or 220, MS.DateFrameText:GetStringHeight() or 12)
end

function MS:CreateSystemsStatsFrame()
    MS.SystemStatsFrame = CreateFrame("Frame", "SystemStatsFrame", Minimap)
    MS.SystemStatsFrame:SetFrameStrata("MEDIUM")
    MS.SystemStatsFrame:SetPoint(MSDB.SystemStatsFrame.Point, Minimap, MSDB.SystemStatsFrame.RelativePoint, MSDB.SystemStatsFrame.OffsetX, MSDB.SystemStatsFrame.OffsetY)

    MS.SystemStatsFrameText = MS.SystemStatsFrame:CreateFontString("SystemStatsFrameText", "OVERLAY")
    MS.SystemStatsFrameText:SetPoint(MSDB.SystemStatsFrame.Point, MS.SystemStatsFrame, MSDB.SystemStatsFrame.RelativePoint, 0, 0)
    MS.SystemStatsFrameText:SetFont(MSDB.General.Font, MSDB.SystemStatsFrame.FontSize, MSDB.General.FontOutline)
    MS.SystemStatsFrameText:SetText(MS:GetSystemStats())
    MS.SystemStatsFrameText:SetShadowOffset(0, 0)

    MS.SystemStatsFrame:SetSize(MS.SystemStatsFrameText:GetStringWidth() or 220, MS.SystemStatsFrameText:GetStringHeight() or 12)
end

function MS:CreateLocationFrame()
    MS.LocationFrame = CreateFrame("Frame", "LocationFrame", Minimap)
    MS.LocationFrame:SetFrameStrata("MEDIUM")
    MS.LocationFrame:SetPoint(MSDB.LocationFrame.Point, Minimap, MSDB.LocationFrame.RelativePoint, MSDB.LocationFrame.OffsetX, MSDB.LocationFrame.OffsetY)

    MS.LocationFrameText = MS.LocationFrame:CreateFontString("LocationFrameText", "OVERLAY")
    MS.LocationFrameText:SetPoint(MSDB.LocationFrame.Point, MS.LocationFrame, MSDB.LocationFrame.RelativePoint, 0, 0)
    MS.LocationFrameText:SetFont(MSDB.General.Font, MSDB.LocationFrame.FontSize, MSDB.General.FontOutline)
    MS.LocationFrameText:SetText(MS:GetLocation())
    MS.LocationFrameText:SetShadowOffset(0, 0)

    MS.LocationFrame:SetSize(MS.LocationFrameText:GetStringWidth() or 220, MS.LocationFrameText:GetStringHeight() or 12)

end

function MS:CreateInstanceDifficultyFrame()
    MS.InstanceDifficultyFrame = CreateFrame("Frame", "InstanceDifficultyFrame", Minimap)
    MS.InstanceDifficultyFrame:SetFrameStrata("MEDIUM")
    MS.InstanceDifficultyFrame:SetPoint(MSDB.InstanceDifficultyFrame.Point, Minimap, MSDB.InstanceDifficultyFrame.RelativePoint, MSDB.InstanceDifficultyFrame.OffsetX, MSDB.InstanceDifficultyFrame.OffsetY)
    MS.InstanceDifficultyFrameText = MS.InstanceDifficultyFrame:CreateFontString("InstanceDifficultyFrameText", "OVERLAY")
    MS.InstanceDifficultyFrameText:SetPoint(MSDB.InstanceDifficultyFrame.Point, MS.InstanceDifficultyFrame, MSDB.InstanceDifficultyFrame.RelativePoint, 0, 0)
    MS.InstanceDifficultyFrameText:SetFont(MSDB.General.Font, MSDB.InstanceDifficultyFrame.FontSize, MSDB.General.FontOutline)
    MS.InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
    MS.InstanceDifficultyFrameText:SetShadowOffset(0, 0)
    MS.InstanceDifficultyFrame:SetSize(MS.InstanceDifficultyFrameText:GetStringWidth() or 220, MS.InstanceDifficultyFrameText:GetStringHeight() or 12)
end

function MS:CreateCoordinatesFrame()
    MS.CoordinatesFrame = CreateFrame("Frame", "CoordinatesFrame", Minimap)
    MS.CoordinatesFrame:SetFrameStrata("MEDIUM")
    MS.CoordinatesFrame:SetPoint(MSDB.CoordinatesFrame.Point, Minimap, MSDB.CoordinatesFrame.RelativePoint, MSDB.CoordinatesFrame.OffsetX, MSDB.CoordinatesFrame.OffsetY)
    MS.CoordinatesFrameText = MS.CoordinatesFrame:CreateFontString("CoordinatesFrameText", "OVERLAY")
    MS.CoordinatesFrameText:SetPoint(MSDB.CoordinatesFrame.Point, MS.CoordinatesFrame, MSDB.CoordinatesFrame.RelativePoint, 0, 0)
    MS.CoordinatesFrameText:SetFont(MSDB.General.Font, MSDB.CoordinatesFrame.FontSize, MSDB.General.FontOutline)
    MS.CoordinatesFrameText:SetShadowOffset(0, 0)
    MS.CoordinatesFrame:SetSize(MS.CoordinatesFrameText:GetStringWidth() or 220, MS.CoordinatesFrameText:GetStringHeight() or 12)
end

function MS:UpdateFrames()
    MS:UpdateColourSelection()
    MS:UpdateTimeFrame()
    MS:UpdateDateFrame()
    MS:UpdateSystemStatsFrame()
    MS:UpdateLocationFrame()
    MS:UpdateInstanceDifficultyFrame()
    MS:UpdateCoordinatesFrame()
    MS:SetupScripts()
end

function MS:SetupSlashCommands()
    SLASH_MINIMAPSTATS1 = "/minimapstats"
    SLASH_MINIMAPSTATS2 = "/ms"
    SlashCmdList["MINIMAPSTATS"] = function(msg) 
        if msg == "reset" then
            MS:ResetDefaults()
        elseif msg == "debug" then
            MS:PrintDebugInfo()
        elseif msg == "time" then
            AD:Open("MinimapStats")
            AD:SelectGroup("MinimapStats", "TimeFrame")
        elseif msg == "date" then
            AD:Open("MinimapStats")
            AD:SelectGroup("MinimapStats", "DateFrame")
        elseif msg == "system" then
            AD:Open("MinimapStats")
            AD:SelectGroup("MinimapStats", "SystemStatsFrame")
        elseif msg == "location" then
            AD:Open("MinimapStats")
            AD:SelectGroup("MinimapStats", "LocationFrame")
        elseif msg == "instance" then
            AD:Open("MinimapStats")
            AD:SelectGroup("MinimapStats", "InstanceDifficultyFrame")
        elseif msg == "coordinates" then
            AD:Open("MinimapStats")
            AD:SelectGroup("MinimapStats", "Coordinates")
        elseif msg == "config" or msg == "" then
            AD:Open("MinimapStats")
        else 
            print("|cFF00ADB5MinimapStats|r: " .. "Available Commands")
            print("|cFF00ADB5/ms|r: " .. "reset")
            print("|cFF00ADB5/ms|r: " .. "debug")
            print("|cFF00ADB5/ms|r: " .. "time")
            print("|cFF00ADB5/ms|r: " .. "date")
            print("|cFF00ADB5/ms|r: " .. "system")
            print("|cFF00ADB5/ms|r: " .. "location")
            print("|cFF00ADB5/ms|r: " .. "instance")
            print("|cFF00ADB5/ms|r: " .. "coordinates")
            print("|cFF00ADB5/ms|r: " .. "config")
        end
    end

    SLASH_RELOADUI1 = "/rl"
    SlashCmdList["RELOADUI"] = function() ReloadUI() end
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
    MS.TimeFrameText:SetText(MS:GetCurrentTime())
    MS.DateFrameText:SetText(MS:GetCurrentDate())
    MS.SystemStatsFrameText:SetText(MS:GetSystemStats())
    MS.LocationFrameText:SetText(MS:GetLocation())
    MS.InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
end

function MS:PrintDebugInfo()
    print(AddOnName .. " V" .. AddOnVersion .. " Debug Information")
    -- Time Frame Debug Information
    print("|cFF00ADB5Time Frame Information|r")
    print("|cFF00ADB5Time Frame Text|r: " .. MS.TimeFrameText:GetText())
    print("|cFF00ADB5Time Frame Location|r: " .. MS.TimeFrame:GetPoint())
    print("|cFF00ADB5Time Frame X Offset|r: " .. MSDB.TimeFrame.OffsetX)
    print("|cFF00ADB5Time Frame Y Offset|r: " .. MSDB.TimeFrame.OffsetY)
    print("|cFF00ADB5Time Frame Font Size|r: " .. MSDB.TimeFrame.FontSize)
    print("|cFF00ADB5Time Frame Update Rate|r: " .. MSDB.TimeFrame.UpdateRate)
    -- Date Frame Debug Information
    print("|cFF00ADB5Date Frame Information|r")
    print("|cFF00ADB5Date Frame Text|r: " .. MS.DateFrameText:GetText())
    print("|cFF00ADB5Date Frame Location|r: " .. MS.DateFrame:GetPoint())
    print("|cFF00ADB5Date Frame X Offset|r: " .. MSDB.DateFrame.OffsetX)
    print("|cFF00ADB5Date Frame Y Offset|r: " .. MSDB.DateFrame.OffsetY)
    print("|cFF00ADB5Date Frame Font Size|r: " .. MSDB.DateFrame.FontSize)
    print("|cFF00ADB5Date Frame Update Rate|r: " .. MSDB.DateFrame.UpdateRate)
    -- System Stats Frame Debug Information
    print("|cFF00ADB5System Stats Frame Information|r")
    print("|cFF00ADB5System Stats Frame Text|r: " .. MS.SystemStatsFrameText:GetText())
    print("|cFF00ADB5System Stats Frame Location|r: " .. MS.SystemStatsFrame:GetPoint())
    print("|cFF00ADB5System Stats Frame X Offset|r: " .. MSDB.SystemStatsFrame.OffsetX)
    print("|cFF00ADB5System Stats Frame Y Offset|r: " .. MSDB.SystemStatsFrame.OffsetY)
    print("|cFF00ADB5System Stats Frame Font Size|r: " .. MSDB.SystemStatsFrame.FontSize)
    print("|cFF00ADB5System Stats Frame Update Rate|r: " .. MSDB.SystemStatsFrame.UpdateRate)
    -- Location Frame Debug Information
    print("|cFF00ADB5Location Frame Information|r")
    print("|cFF00ADB5Location Frame Text|r: " .. MS.LocationFrameText:GetText())
    print("|cFF00ADB5Location Frame Location|r: " .. MS.LocationFrame:GetPoint())
    print("|cFF00ADB5Location Frame X Offset|r: " .. MSDB.LocationFrame.OffsetX)
    print("|cFF00ADB5Location Frame Y Offset|r: " .. MSDB.LocationFrame.OffsetY)
    print("|cFF00ADB5Location Frame Font Size|r: " .. MSDB.LocationFrame.FontSize)
    -- Instance Difficulty Frame Debug Information
    print("|cFF00ADB5Instance Difficulty Frame Information|r")
    print("|cFF00ADB5Instance Difficulty Frame Text|r: " .. (MS.InstanceDifficultyFrameText:GetText() or "No Instance"))
    print("|cFF00ADB5Instance Difficulty Frame Location|r: " .. (MS.InstanceDifficultyFrame:GetPoint() or "No Instance"))
    print("|cFF00ADB5Instance Difficulty Frame X Offset|r: " .. MSDB.InstanceDifficultyFrame.OffsetX)
    print("|cFF00ADB5Instance Difficulty Frame Y Offset|r: " .. MSDB.InstanceDifficultyFrame.OffsetY)
    print("|cFF00ADB5Instance Difficulty Frame Font Size|r: " .. MSDB.InstanceDifficultyFrame.FontSize)
    -- Coordinates Frame Debug Information
    print("|cFF00ADB5Coordinates Frame Information|r")
    print("|cFF00ADB5Coordinates Frame Text|r: " .. (MS.CoordinatesFrameText:GetText() or "In Instance"))
    print("|cFF00ADB5Coordinates Frame Location|r: " .. (MS.CoordinatesFrame:GetPoint() or "In Instance"))
    print("|cFF00ADB5Coordinates Frame X Offset|r: " .. MSDB.CoordinatesFrame.OffsetX)
    print("|cFF00ADB5Coordinates Frame Y Offset|r: " .. MSDB.CoordinatesFrame.OffsetY)
    print("|cFF00ADB5Coordinates Frame Font Size|r: " .. MSDB.CoordinatesFrame.FontSize)
    print("|cFF00ADB5Coordinates Frame Update Rate|r: " .. MSDB.CoordinatesFrame.UpdateRate)
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

function MS:UpdateTimeFrame()
    MS.TimeFrame:SetSize(MS.TimeFrameText:GetStringWidth() or 220, MS.TimeFrameText:GetStringHeight() or 24)
    MS.TimeFrame:ClearAllPoints()
    MS.TimeFrame:SetPoint(MSDB.TimeFrame.Point, Minimap, MSDB.TimeFrame.RelativePoint, MSDB.TimeFrame.OffsetX, MSDB.TimeFrame.OffsetY)
    MS.TimeFrameText:SetFont(MSDB.General.Font, MSDB.TimeFrame.FontSize, MSDB.General.FontOutline)
    if MSDB.TimeFrame.Toggle then
        MS.TimeFrameText:SetText(MS:GetCurrentTime())
    end
    MS:SetupTimeFrameScripts()
end

function MS:UpdateDateFrame()
    MS.DateFrame:SetSize(MS.DateFrameText:GetStringWidth() or 220, MS.DateFrameText:GetStringHeight() or 12)
    MS.DateFrame:ClearAllPoints()
    MS.DateFrame:SetPoint(MSDB.DateFrame.Point, Minimap, MSDB.DateFrame.RelativePoint, MSDB.DateFrame.OffsetX, MSDB.DateFrame.OffsetY)
    MS.DateFrameText:SetFont(MSDB.General.Font, MSDB.DateFrame.FontSize, MSDB.General.FontOutline)
    if MSDB.DateFrame.Toggle then
        MS.DateFrameText:SetText(MS:GetCurrentDate())
    end
    MS:SetupDateFrameScripts()
end

function MS:UpdateSystemStatsFrame()
    MS.SystemStatsFrame:SetSize(MS.SystemStatsFrameText:GetStringWidth() or 220, MS.SystemStatsFrameText:GetStringHeight() or 12)
    MS.SystemStatsFrame:ClearAllPoints()
    MS.SystemStatsFrame:SetPoint(MSDB.SystemStatsFrame.Point, Minimap, MSDB.SystemStatsFrame.RelativePoint, MSDB.SystemStatsFrame.OffsetX, MSDB.SystemStatsFrame.OffsetY)
    MS.SystemStatsFrameText:SetFont(MSDB.General.Font, MSDB.SystemStatsFrame.FontSize, MSDB.General.FontOutline)
    if MSDB.SystemStatsFrame.Toggle then
        MS.SystemStatsFrameText:SetText(MS:GetSystemStats())
    end
    MS:SetupSystemStatsFrameScripts()
end

function MS:UpdateLocationFrame()
    MS.LocationFrame:SetSize(MS.LocationFrameText:GetStringWidth() or 220, MS.LocationFrameText:GetStringHeight() or 12)
    MS.LocationFrame:ClearAllPoints()
    MS.LocationFrame:SetPoint(MSDB.LocationFrame.Point, Minimap, MSDB.LocationFrame.RelativePoint, MSDB.LocationFrame.OffsetX, MSDB.LocationFrame.OffsetY)
    MS.LocationFrameText:SetFont(MSDB.General.Font, MSDB.LocationFrame.FontSize, MSDB.General.FontOutline)
    MS:SetupLocationFrameScripts()
end

function MS:UpdateInstanceDifficultyFrame()
    MS.InstanceDifficultyFrame:SetSize(MS.InstanceDifficultyFrameText:GetStringWidth() or 220, MS.InstanceDifficultyFrameText:GetStringHeight() or 12)
    MS.InstanceDifficultyFrame:ClearAllPoints()
    MS.InstanceDifficultyFrame:SetPoint(MSDB.InstanceDifficultyFrame.Point, Minimap, MSDB.InstanceDifficultyFrame.RelativePoint, MSDB.InstanceDifficultyFrame.OffsetX, MSDB.InstanceDifficultyFrame.OffsetY)
    MS.InstanceDifficultyFrameText:SetFont(MSDB.General.Font, MSDB.InstanceDifficultyFrame.FontSize, MSDB.General.FontOutline)
    if MSDB.InstanceDifficultyFrame.Toggle then
        MS.InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
    end
    MS:SetupInstanceDifficultyFrameScripts()
end

function MS:UpdateCoordinatesFrame()
    MS.CoordinatesFrame:SetSize(MS.CoordinatesFrameText:GetStringWidth() or 220, MS.CoordinatesFrameText:GetStringHeight() or 12)
    MS.CoordinatesFrame:ClearAllPoints()
    MS.CoordinatesFrame:SetPoint(MSDB.CoordinatesFrame.Point, Minimap, MSDB.CoordinatesFrame.RelativePoint, MSDB.CoordinatesFrame.OffsetX, MSDB.CoordinatesFrame.OffsetY)
    MS.CoordinatesFrameText:SetFont(MSDB.General.Font, MSDB.CoordinatesFrame.FontSize, MSDB.General.FontOutline)
    if MSDB.CoordinatesFrame.Toggle then
        MS.CoordinatesFrameText:SetText(MS:GetCoordinates())
    end
    MS:SetupCoordinatesFrameScripts()
end

function MS:SetupTimeFrameScripts()
    if MSDB.TimeFrame.Toggle then
        MS.TimeFrame:SetScript("OnUpdate", function()
            if not TimeLastUpdate or TimeLastUpdate < GetTime() - MSDB.TimeFrame.UpdateRate then
                TimeLastUpdate = GetTime()
                MS.TimeFrameText:SetText(MS:GetCurrentTime())
                if DEBUG_MODE then
                    print(AddOnName .. ": Time Frame Updated")
                end 
            end
        end)
        MS.TimeFrame:Show()
    else
        MS.TimeFrame:SetScript("OnUpdate", nil)
        MS.TimeFrame:Hide()
    end
end

function MS:SetupDateFrameScripts()
    if MSDB.DateFrame.Toggle then
        MS.DateFrame:SetScript("OnUpdate", function()
            if not DateLastUpdate or DateLastUpdate < GetTime() - MSDB.DateFrame.UpdateRate then
                DateLastUpdate = GetTime()
                MS.DateFrameText:SetText(MS:GetCurrentDate())
                if DEBUG_MODE then
                    print(AddOnName .. ": Date Frame Updated")
                end
            end
        end)
        MS.DateFrame:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then ToggleCalendar() end end)
        MS.DateFrame:Show()
    else
        MS.DateFrame:SetScript("OnUpdate", nil)
        MS.DateFrame:SetScript("OnMouseDown", nil)
        MS.DateFrame:Hide()
    end
end

function MS:SetupSystemStatsFrameScripts()
    if MSDB.SystemStatsFrame.Toggle then
        MS.SystemStatsFrame:SetScript("OnUpdate", function()
            if not SystemStatsLastUpdate or SystemStatsLastUpdate < GetTime() - MSDB.SystemStatsFrame.UpdateRate then
                SystemStatsLastUpdate = GetTime()
                MS.SystemStatsFrameText:SetText(MS:GetSystemStats())
                if DEBUG_MODE then
                    print(AddOnName .. ": System Stats Frame Updated")
                end
            end
        end)
        MS.SystemStatsFrame:Show()
    else
        MS.SystemStatsFrame:SetScript("OnUpdate", nil)
        MS.SystemStatsFrame:Hide()
    end
end

function MS:SetupLocationFrameScripts()
    if MSDB.LocationFrame.Toggle then
        MS.LocationFrame:RegisterEvent("ZONE_CHANGED")
        MS.LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        MS.LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        MS.LocationFrame:SetScript("OnEvent", function(LocationFrame, event)
            if event == "ZONE_CHANGED" or 
            event == "ZONE_CHANGED_INDOORS" or 
            event == "ZONE_CHANGED_NEW_AREA" then
                MS.LocationFrameText:SetText(MS:GetLocation())
                if DEBUG_MODE then
                    print(AddOnName .. ": Location Frame Updated")
                end
            end
        end)
        MS.LocationFrame:Show()
    else
        MS.LocationFrame:UnregisterEvent("ZONE_CHANGED")
        MS.LocationFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
        MS.LocationFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        MS.LocationFrame:Hide();
    end
end

function MS:SetupInstanceDifficultyFrameScripts()
    if MSDB.InstanceDifficultyFrame.Toggle then
        MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
        MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        MS.InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        MS.InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        MS.InstanceDifficultyFrame:SetScript("OnEvent", function(InstanceDifficultyFrame, event)
            if event == "ZONE_CHANGED" or 
            event == "ZONE_CHANGED_INDOORS" or 
            event == "ZONE_CHANGED_NEW_AREA" or 
            event == "PLAYER_ENTERING_WORLD" or 
            event == "GROUP_ROSTER_UPDATE" then
                MS.InstanceDifficultyFrameText:SetText(MS:GetInstanceDifficulty())
                if DEBUG_MODE then
                    print(AddOnName .. ": Instance Difficulty Frame Updated")
                end
            end
        end)
    else
        MS.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED")
        MS.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
        MS.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        MS.InstanceDifficultyFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        MS.InstanceDifficultyFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end
end

function MS:SetupCoordinatesFrameScripts()
    if MSDB.CoordinatesFrame.Toggle then
        MS.CoordinatesFrame:RegisterEvent("PLAYER_STARTED_MOVING")
        MS.CoordinatesFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
        MS.CoordinatesFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        MS.CoordinatesFrame:SetScript("OnEvent", function(CoordinatesFrame, event)
            -- This feels incredibly hacky, but it works :)
            local inInstance = IsInInstance()
            if inInstance then 
                MS.CoordinatesFrame:SetScript("OnUpdate", nil)
                MS.CoordinatesFrame:Hide()
            else
                if event == "PLAYER_STARTED_MOVING" then
                    MS.CoordinatesFrame:SetScript("OnUpdate", function()
                        if not CoordinatesLastUpdate or CoordinatesLastUpdate < GetTime() - MSDB.CoordinatesFrame.UpdateRate then
                            CoordinatesLastUpdate = GetTime()
                            MS.CoordinatesFrameText:SetText(MS:GetCoordinates())
                            if DEBUG_MODE then
                                print(AddOnName .. ": Coordinates Frame Updated")
                            end
                        end
                    end)
                elseif event == "PLAYER_STOPPED_MOVING" then
                    MS.CoordinatesFrame:SetScript("OnUpdate", nil)
                end
                MS.CoordinatesFrame:Show()
            end
        end)
        MS.CoordinatesFrame:Show()
    else
        MS.CoordinatesFrame:UnregisterEvent("PLAYER_STARTED_MOVING")
        MS.CoordinatesFrame:UnregisterEvent("PLAYER_STOPPED_MOVING")
        MS.CoordinatesFrame:Hide()
    end

end

function MS:SetupScripts()
    MS:SetupTimeFrameScripts()
    MS:SetupDateFrameScripts()
    MS:SetupSystemStatsFrameScripts()
    MS:SetupLocationFrameScripts()
    MS:SetupCoordinatesFrameScripts()
    MS:SetupInstanceDifficultyFrameScripts()
end