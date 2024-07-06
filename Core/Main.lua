local _, MS = ...
local MinimapStats = LibStub("AceAddon-3.0"):NewAddon("MinimapStats")

function MinimapStats:OnInitialize()
    MS.DB = LibStub("AceDB-3.0"):New("MSDB", MS.DefaultSettings)
    for k, v in pairs(MS.DefaultSettings.global) do
        if MS.DB.global[k] == nil then
            MS.DB.global[k] = v
        end
    end
end

function MinimapStats:OnEnable()
    MS:SetAccentColour()
    MS:FetchMythicPlusInfo()
    MS:CreateTimeFrame()
    MS:CreateSystemStatsFrame()
    MS:CreateLocationFrame()
    MS:CreateCoordinatesFrame()
    MS:CreateInstanceDifficultyFrame()
    MS:SetupSlashCommands()
end