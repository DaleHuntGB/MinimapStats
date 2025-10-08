local _, MS = ...
local MinimapStats = LibStub("AceAddon-3.0"):NewAddon("MinimapStats") -- Register AddOn

local Defaults = {
    global = {
        General = {
            ClassColour = false,
            AccentColour = {128, 128, 255},
            Font = "Friz Quadrata TT",
            FontFlag = "OUTLINE",
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
            UpdateInterval = 1.0,
            String = "%FPS | %HOMEMS",
            Colour = {255, 255, 255},
        },
        Location = {
            Enable = true,
            Layout = {"TOPRIGHT", "TOPRIGHT", 3, -3, 12},
            ColourBy = "REACTION",
            Colour = {255, 255, 255},
            SubZone = false,
        },
        InstanceDifficulty = {},
    },
}

MS.Defaults = Defaults

function MinimapStats:OnInitialize()
    MS.db = LibStub("AceDB-3.0"):New("MinimapStatsDB", Defaults, true)
    for key, value in pairs(Defaults) do
        if MS.db.profile[key] == nil then
            MS.db.profile[key] = value
        end
    end
end

function MinimapStats:OnEnable()
    MS:SetupSlashCommands()
    MS:CreateTime()
    MS:CreateSystemStats()
end