local _, MS = ...
local MinimapStats = LibStub("AceAddon-3.0"):NewAddon("MinimapStats") -- Register AddOn

local Defaults = {
    global = {
        General = {
            ClassColour = false,
            AccentColour = {128, 128, 255},
            Font = "Friz Quadrata TT",
            FontFlag = "OUTLINE",
            FrameStrata = "MEDIUM",
            FontShadow = {
                Colour = {0, 0, 0, 1},
                OffsetX = 0,
                OffsetY = 0,
            }
        },
        Time = {
            Enable = true,
            TimeZone = "Local",
            Format = "24H",
            UpdateInterval = 60.0,
            Colour = {255, 255, 255},
            Layout = {"BOTTOMLEFT", "BOTTOMLEFT", 3, 17, 18},
        },
        SystemStats = {
            Enable = true,
            Layout = {"BOTTOMLEFT", "BOTTOMLEFT", 3, 3, 12},
            UpdateInterval = 3.0,
            String = "%fps | %home",
            Colour = {255, 255, 255},
        },
        Location = {
            Enable = true,
            Layout = {"TOPLEFT", "TOPLEFT", 3, -3, 12},
            ColourBy = "REACTION",
            Colour = {255, 255, 255},
            SubZone = false,
        },
        InstanceDifficulty = {
            Enable = true,
            Layout = {"TOPLEFT", "TOPLEFT", 3, -17, 12},
            Colour = {255, 255, 255},
            Abbreviate = true,
            HideBlizzardInstanceBanner = true,
        },
        Coordinates = {
            Enable = true,
            Layout = {"TOPRIGHT", "TOPRIGHT", -3, -3, 12},
            ColourBy = "CUSTOM",
            Colour = {255, 255, 255},
            UpdateInterval = 1.0,
            Format = "SINGLE",
        },
        Tooltip = {
            Time = {
                Date = true,
                DateString = "%A, %B %d, %Y",
                AlternateTime = true,
                Lockouts = true,
            },
            SystemStats = {
                Vault = {
                    Enable = true,
                    Options = {
                        Raid = true,
                        MythicPlus = true,
                        World = true,
                    }
                }
            }
        }
    },
}

MS.Defaults = Defaults

function MinimapStats:OnInitialize()
    MS.db = LibStub("AceDB-3.0"):New("MinimapStatsDB", Defaults)
end

function MinimapStats:InitializeUI()
    MS:SetupSlashCommands()
    MS:CreateTime()
    MS:CreateSystemStats()
    MS:CreateLocation()
    MS:CreateCoordinates()
    MS:CreateInstanceDifficulty()
    MS:AssignTooltipScripts()
end

function MinimapStats:OnEnable()
    local addon = self
    C_Timer.After(0, function()
        addon:InitializeUI()
    end)
end