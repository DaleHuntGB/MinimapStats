local MinimapStats = LibStub("AceAddon-3.0"):NewAddon("MinimapStats")
local MSGUI = LibStub("AceGUI-3.0")
local AddOnName = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
local AddOnVersion = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
local LSM = LibStub("LibSharedMedia-3.0")
local MSGUIShown = false
local DebugMode = false
local TestingInstanceDifficulty = false

local DefaultSettings = {
    global = {
        -- Toggles
        DisplayTime = true,
        TimeFormat = "TwentyFourHourTime",
        DisplayLocation = true,
        DisplayReactionColor = false,
        DisplayInformation = true,
        InformationFormat = "FPSHomeMS",
        CoordinatesFormat = "NoDecimal",
        DisplayInstanceDifficulty = true,
        UseClassColours = true,
        DisplayCoordinates = true,
        -- Fonts & Colors
        Font = "Fonts\\FRIZQT__.ttf",
        FontOutline = "THINOUTLINE",
        PrimaryFontColorR = 1.0,
        PrimaryFontColorG = 1.0,
        PrimaryFontColorB = 1.0,
        SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r,
        SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g,
        SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b,
        -- Font Sizes
        TimeFrameFontSize = 16,
        LocationFrameFontSize = 12,
        InformationFrameFontSize = 12,
        InstanceDifficultyFrameFontSize = 12,
        CoordinatesFrameFontSize = 12,
        -- Anchors
        TimeFrameAnchorFrom = "BOTTOM",
        TimeFrameAnchorTo = "BOTTOM",
        LocationFrameAnchorFrom = "TOP",
        LocationFrameAnchorTo = "TOP",
        InformationFrameAnchorFrom = "BOTTOM",
        InformationFrameAnchorTo = "BOTTOM",
        InstanceDifficultyFrameAnchorFrom = "TOPLEFT",
        InstanceDifficultyFrameAnchorTo = "TOPLEFT",
        CoordinatesFrameAnchorFrom = "TOP",
        CoordinatesFrameAnchorTo = "TOP",
        -- Positions
        TimeFrameXOffset = 0,
        TimeFrameYOffset = 17,
        LocationFrameXOffset = 0,
        LocationFrameYOffset = -3,
        InformationFrameXOffset = 0,
        InformationFrameYOffset = 3,
        InstanceDifficultyFrameXOffset = 3,
        InstanceDifficultyFrameYOffset = -3,
        CoordinatesFrameXOffset = 0,
        CoordinatesFrameYOffset = -17,
        TimeFrame_UpdateFrequency = 3,
        InformationFrame_UpdateFrequency = 5,
        CoordinatesFrame_UpdateFrequency = 5,

    }
}

function MinimapStats:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MSDB", DefaultSettings)

    if self.db.global.UseClassColours then
        self.db.global.SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
        self.db.global.SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
        self.db.global.SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
    end
    local SecondaryFontColorRGB = { r = self.db.global.SecondaryFontColorR, g = self.db.global.SecondaryFontColorG,
        b = self.db.global.SecondaryFontColorB }
    local SecondaryFontColor = string.format("%02x%02x%02x", SecondaryFontColorRGB.r * 255, SecondaryFontColorRGB.g * 255,
        SecondaryFontColorRGB.b * 255)

    function FetchTime()
        local CurrentHour = date("%H")
        local CurrentMins = date("%M")
        local CurrentHourTwelve = date("%I")
        local CurrentMinsTwelve = date("%M")
        local CurrentAMPM = date("%p")
        local CurrentServerHour, CurrentServerMins = GetGameTime()
        local TwentyFourHourTime = CurrentHour .. ":" .. CurrentMins
        local TwelveHourTime = CurrentHourTwelve .. ":" .. CurrentMinsTwelve .. " " .. CurrentAMPM
        local ServerTime = CurrentServerHour .. ":" .. CurrentServerMins

        if self.db.global.DisplayTime then
            if self.db.global.TimeFormat == "TwentyFourHourTime" then
                return TwentyFourHourTime
            elseif self.db.global.TimeFormat == "TwelveHourTime" then
                return TwelveHourTime
            elseif self.db.global.TimeFormat == "ServerTime" then
                return ServerTime
            elseif self.db.global.TimeFormat == "TwelverHourServerTime" then
                if CurrentServerHour < 12 then
                    return string.format("%02d:%02d" .. " AM", CurrentServerHour, CurrentServerMins)
                elseif CurrentServerHour > 12 then
                    return string.format("%02d:%02d" .. " PM", CurrentServerHour - 12, CurrentServerMins)
                elseif CurrentServerHour == 12 and CurrentServerMins < 60 then
                    return string.format("%02d:%02d" .. " PM", CurrentServerHour, CurrentServerMins)
                end
            end
        end
    end

    local CalculateHexValue = function(r, g, b)
        return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
    end

    function FetchLocation()
        local LocationColor = "FFFFFF";
        local PVPZone = GetZonePVPInfo()
        if PVPZone == 'arena' then
            LocationColor = CalculateHexValue(0.84, 0.03, 0.03)
        elseif PVPZone == 'friendly' then
            LocationColor = CalculateHexValue(0.05, 0.85, 0.03)
        elseif PVPZone == 'contested' then
            LocationColor = CalculateHexValue(0.9, 0.85, 0.05)
        elseif PVPZone == 'hostile' then
            LocationColor = CalculateHexValue(0.84, 0.03, 0.03)
        elseif PVPZone == 'sanctuary' then
            LocationColor = CalculateHexValue(0.035, 0.58, 0.84)
        elseif PVPZone == 'combat' then
            LocationColor = CalculateHexValue(0.84, 0.03, 0.03)
        else
            LocationColor = CalculateHexValue(0.9, 0.85, 0.05)
        end

        if self.db.global.DisplayLocation then
            if self.db.global.DisplayReactionColor then
                return "|cFF" .. LocationColor .. GetMinimapZoneText() .. "|r"
            end
            return "|cFF" .. SecondaryFontColor .. GetMinimapZoneText() .. "|r"
        end
    end

    function FetchInformation()
        local FPS = ceil(GetFramerate())
        local _, _, HomeMS, WorldMS = GetNetStats()

        local FPSText = FPS .. "|cFF" .. SecondaryFontColor .. " FPS " .. "|r"
        local HomeMSText = HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
        local WorldMSText = WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"

        local FPSHomeMS = FPSText .. "[" .. HomeMSText .. "]"
        local FPSWorldMS = FPSText .. "[" .. WorldMSText .. "]"
        local FPSOnly = FPSText
        local HomeMSOnly = HomeMSText
        local WorldMSOnly = WorldMSText
        local MSOnly = HomeMSText .. " [" .. WorldMSText .. "]"


        if self.db.global.DisplayInformation then
            if self.db.global.InformationFormat == "FPSHomeMS" then
                return FPSHomeMS
            elseif self.db.global.InformationFormat == "FPSWorldMS" then
                return FPSWorldMS
            elseif self.db.global.InformationFormat == "FPSOnly" then
                return FPSOnly
            elseif self.db.global.InformationFormat == "HomeMSOnly" then
                return HomeMSOnly
            elseif self.db.global.InformationFormat == "WorldMSOnly" then
                return WorldMSOnly
            elseif self.db.global.InformationFormat == "MSOnly" then
                return MSOnly
            end
        end
    end

    function FetchInstanceDifficulty()
        if self.db.global.DisplayInstanceDifficulty then
            local _, _, InstanceDifficulty, _, _, _, _, InstanceID, InstanceSize = GetInstanceInfo()
            local KeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
            local InstanceDifficultyIndicator = MinimapCluster.InstanceDifficulty
            local InstanceIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Instance or
            _G["MiniMapInstanceDifficulty"]
            local GuildIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Guild or
            _G["GuildInstanceDifficulty"]
            local ChallengeIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.ChallengeMode or
            _G["MiniMapChallengeMode"]
            local InGarrison = InstanceID == 1152 or InstanceID == 1153 or InstanceID == 1154 or InstanceID == 1158 or
            InstanceID == 1159 or InstanceID == 1160

            local NormalDungeon = "5" .. "|cFF" .. SecondaryFontColor .. "N" .. "|r"
            local HeroicDungeon = "5" .. "|cFF" .. SecondaryFontColor .. "H" .. "|r"
            local MythicDungeon = "5" .. "|cFF" .. SecondaryFontColor .. "M" .. "|r"
            local MythicPlusDungeon = "+" .. "|cFF" .. SecondaryFontColor .. KeystoneLevel .. "|r"
            local TimewalkingDungeon = "|cFF" .. SecondaryFontColor .. "TW" .. "|r"
            local TenNormalRaid = "10" .. "|cFF" .. SecondaryFontColor .. "N" .. "|r"
            local TwentyFiveNormalRaid = "25" .. "|cFF" .. SecondaryFontColor .. "N" .. "|r"
            local TenHeroicRaid = "10" .. "|cFF" .. SecondaryFontColor .. "H" .. "|r"
            local TwentyFiveHeroicRaid = "25" .. "|cFF" .. SecondaryFontColor .. "H" .. "|r"
            local FortyRaid = "40" .. "|cFF" .. SecondaryFontColor .. "M" .. "|r"
            local TimewalkingRaid = "|cFF" .. SecondaryFontColor .. InstanceSize .. "|r" .. "TW"
            local LFR = "|cFF" .. SecondaryFontColor .. InstanceSize .. "|r" .. "LFR"
            local NormalFlexRaid = "|cFF" .. SecondaryFontColor .. InstanceSize .. "|r" .. "N"
            local HeroicFlexRaid = "|cFF" .. SecondaryFontColor .. InstanceSize .. "|r" .. "H"
            local MythicRaid = "20" .. "|cFF" .. SecondaryFontColor .. "M" .. "|r"


            if TestingInstanceDifficulty then
                local TestInstances = { NormalDungeon, HeroicDungeon, MythicDungeon, TenNormalRaid, TwentyFiveNormalRaid,
                    TenHeroicRaid, TwentyFiveHeroicRaid, FortyRaid, MythicRaid }
                return TestInstances[math.random(1, #TestInstances)]
            end

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

            if InstanceDifficulty == 0 then  -- No Instance
                return " "
            elseif InGarrison then           -- Garrison
                return " "
            elseif InstanceDifficulty == 1 then -- Normal Dungeon
                return NormalDungeon
            elseif InstanceDifficulty == 2 then -- Heroic Dungeon
                return HeroicDungeon
            elseif InstanceDifficulty == 23 then -- Mythic Dungeon
                return MythicDungeon
            elseif InstanceDifficulty == 8 then -- Mythic+ Dungeon
                return MythicPlusDungeon
            elseif InstanceDifficulty == 24 then -- Timewalking Dungeon
                return TimewalkingDungeon
            elseif InstanceDifficulty == 3 then -- 10M Normal Raid
                return TenNormalRaid
            elseif InstanceDifficulty == 5 then -- 10M Heroic Raid
                return TenHeroicRaid
            elseif InstanceDifficulty == 4 then -- 25M Normal Raid
                return TwentyFiveNormalRaid
            elseif InstanceDifficulty == 6 then -- 25M Heroic Raid
                return TwentyFiveHeroicRaid
            elseif InstanceDifficulty == 9 then -- 40M Raid
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
    end

    function FetchCoordinates()
        if self.db.global.DisplayCoordinates then
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
                    if self.db.global.CoordinatesFormat == "NoDecimal" then
                        return NoDecimals
                    elseif self.db.global.CoordinatesFormat == "OneDecimal" then
                        return OneDecimal
                    elseif self.db.global.CoordinatesFormat == "TwoDecimal" then
                        return TwoDecimals
                    end
                else
                    return " "
                end
            end
        end
    end

    function RefreshElements()
        if self.db.global.UseClassColours then
            self.db.global.SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
            self.db.global.SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
            self.db.global.SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
        end

        SecondaryFontColorRGB = { r = self.db.global.SecondaryFontColorR, g = self.db.global.SecondaryFontColorG,
            b = self.db.global.SecondaryFontColorB }
        SecondaryFontColor = string.format("%02x%02x%02x", SecondaryFontColorRGB.r * 255, SecondaryFontColorRGB.g * 255,
            SecondaryFontColorRGB.b * 255)

        TimeFrameText:SetText(FetchTime())
        LocationFrameText:SetText(FetchLocation())
        InformationFrameText:SetText(FetchInformation())
        InstanceDifficultyFrameText:SetText(FetchInstanceDifficulty())
        CoordinatesFrameText:SetText(FetchCoordinates())

        TimeFrameText:SetFont(self.db.global.Font, self.db.global.TimeFrameFontSize, self.db.global.FontOutline)
        LocationFrameText:SetFont(self.db.global.Font, self.db.global.LocationFrameFontSize, self.db.global.FontOutline)
        InformationFrameText:SetFont(self.db.global.Font, self.db.global.InformationFrameFontSize,
            self.db.global.FontOutline)
        InstanceDifficultyFrameText:SetFont(self.db.global.Font, self.db.global.InstanceDifficultyFrameFontSize,
            self.db.global.FontOutline)
        CoordinatesFrameText:SetFont(self.db.global.Font, self.db.global.CoordinatesFrameFontSize,
            self.db.global.FontOutline)

        TimeFrameText:SetTextColor(self.db.global.PrimaryFontColorR, self.db.global.PrimaryFontColorG,
            self.db.global.PrimaryFontColorB)
        InformationFrameText:SetTextColor(self.db.global.PrimaryFontColorR, self.db.global.PrimaryFontColorG,
            self.db.global.PrimaryFontColorB)
        CoordinatesFrameText:SetTextColor(self.db.global.PrimaryFontColorR, self.db.global.PrimaryFontColorG,
            self.db.global.PrimaryFontColorB)

        TimeFrame:SetHeight(TimeFrameText:GetStringHeight() or 24)
        TimeFrame:SetWidth(TimeFrameText:GetStringWidth() or 200)
        LocationFrame:SetHeight(LocationFrameText:GetStringHeight() or 24)
        LocationFrame:SetWidth(LocationFrameText:GetStringWidth() or 200)
        InformationFrame:SetHeight(InformationFrameText:GetStringHeight() or 24)
        InformationFrame:SetWidth(InformationFrameText:GetStringWidth() or 200)
        InstanceDifficultyFrame:SetHeight(InstanceDifficultyFrameText:GetStringHeight() or 24)
        InstanceDifficultyFrame:SetWidth(InstanceDifficultyFrameText:GetStringWidth() or 200)
        CoordinatesFrame:SetHeight(CoordinatesFrameText:GetStringHeight() or 24)
        CoordinatesFrame:SetWidth(CoordinatesFrameText:GetStringWidth() or 200)

        TimeFrame:ClearAllPoints()
        TimeFrame:SetPoint(self.db.global.TimeFrameAnchorFrom, Minimap, self.db.global.TimeFrameAnchorTo,
            self.db.global.TimeFrameXOffset, self.db.global.TimeFrameYOffset)
        LocationFrame:ClearAllPoints()
        LocationFrame:SetPoint(self.db.global.LocationFrameAnchorFrom, Minimap, self.db.global.LocationFrameAnchorTo,
            self.db.global.LocationFrameXOffset, self.db.global.LocationFrameYOffset)
        InformationFrame:ClearAllPoints()
        InformationFrame:SetPoint(self.db.global.InformationFrameAnchorFrom, Minimap,
            self.db.global.InformationFrameAnchorTo, self.db.global.InformationFrameXOffset,
            self.db.global.InformationFrameYOffset)
        InstanceDifficultyFrame:ClearAllPoints()
        InstanceDifficultyFrame:SetPoint(self.db.global.InstanceDifficultyFrameAnchorFrom, Minimap,
            self.db.global.InstanceDifficultyFrameAnchorTo, self.db.global.InstanceDifficultyFrameXOffset,
            self.db.global.InstanceDifficultyFrameYOffset)
        CoordinatesFrame:ClearAllPoints()
        CoordinatesFrame:SetPoint(self.db.global.CoordinatesFrameAnchorFrom, Minimap,
            self.db.global.CoordinatesFrameAnchorTo, self.db.global.CoordinatesFrameXOffset,
            self.db.global.CoordinatesFrameYOffset)

        if self.db.global.DisplayCoordinates then
            CoordinatesFrame:SetScript("OnUpdate", UpdateCoordinatesFrame)
        else
            CoordinatesFrame:SetScript("OnUpdate", nil)
        end
        if self.db.global.DisplayTime then
            TimeFrame:SetScript("OnUpdate", UpdateTimeFrame)
            TimeFrame:SetScript("OnMouseDown",
                function(self, button) if button == "LeftButton" then ToggleCalendar() end end)
        else
            TimeFrame:SetScript("OnUpdate", nil)
        end
        LocationFrame:SetScript("OnEvent", UpdateLocationFrame)
        if self.db.global.DisplayInformation then
            InformationFrame:SetScript("OnUpdate", UpdateInformationFrame)
            InformationFrame:SetScript("OnMouseDown",
                function(self, button) if button == "MiddleButton" then ReloadUI() elseif button == "RightButton" then if MSGUIShown == false then
                            RunMSGUI() else return end end end)
        else
            InformationFrame:SetScript("OnUpdate", nil)
        end
        InstanceDifficultyFrame:SetScript("OnEvent", UpdateInstanceDifficultyFrame)
        if TestingInstanceDifficulty == true then
            InstanceDifficultyFrame:SetScript("OnUpdate", TestInstanceDifficultyFrame)
        else
            InstanceDifficultyFrame:SetScript("OnUpdate", nil)
        end
    end
end

function MinimapStats:OnEnable()
    local MinimapStats = CreateFrame("Frame")
    MinimapStats:RegisterEvent("PLAYER_LOGIN")

    --[[ Time Frame ]]
                       --
    TimeFrame = CreateFrame("Frame", "TimeFrame", Minimap)
    TimeFrame:ClearAllPoints()
    TimeFrame:SetPoint(self.db.global.TimeFrameAnchorFrom, Minimap, self.db.global.TimeFrameAnchorTo,
        self.db.global.TimeFrameXOffset, self.db.global.TimeFrameYOffset)
    TimeFrameText = TimeFrame:CreateFontString("TimeFrameText", "BACKGROUND")
    TimeFrameText:ClearAllPoints()
    TimeFrameText:SetPoint(self.db.global.TimeFrameAnchorFrom, TimeFrame, self.db.global.TimeFrameAnchorTo, 0, 0)
    TimeFrameText:SetFont(self.db.global.Font, self.db.global.TimeFrameFontSize, self.db.global.FontOutline)
    TimeFrameText:SetTextColor(self.db.global.PrimaryFontColorR, self.db.global.PrimaryFontColorG,
        self.db.global.PrimaryFontColorB)
    TimeFrameText:SetText(FetchTime())
    TimeFrame:SetHeight(TimeFrameText:GetStringHeight() or 24)
    TimeFrame:SetWidth(TimeFrameText:GetStringWidth() or 200)

    --[[ Location Frame ]]
                           --
    LocationFrame = CreateFrame("Frame", "LocationFrame", Minimap)
    LocationFrame:ClearAllPoints()
    LocationFrame:SetPoint(self.db.global.LocationFrameAnchorFrom, Minimap, self.db.global.LocationFrameAnchorTo,
        self.db.global.LocationFrameXOffset, self.db.global.LocationFrameYOffset)
    LocationFrameText = LocationFrame:CreateFontString("LocationFrameText", "BACKGROUND")
    LocationFrameText:ClearAllPoints()
    LocationFrameText:SetPoint(self.db.global.LocationFrameAnchorFrom, LocationFrame,
        self.db.global.LocationFrameAnchorTo, 0, 0)
    LocationFrameText:SetFont(self.db.global.Font, self.db.global.LocationFrameFontSize, self.db.global.FontOutline)
    LocationFrameText:SetText(FetchLocation())
    LocationFrameText:SetWidth(Minimap:GetWidth() * 80 / 100)
    LocationFrameText:CanWordWrap()
    LocationFrame:SetHeight(LocationFrameText:GetStringHeight() or 24)
    LocationFrame:SetWidth(LocationFrameText:GetStringWidth() or 200)

    --[[ Location Frame: Event Registeration ]]
                                                --
    LocationFrame:RegisterEvent("ZONE_CHANGED")
    LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    LocationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    --[[ Information Frame ]]
                              --
    InformationFrame = CreateFrame("Frame", "InformationFrame", Minimap)
    InformationFrame:ClearAllPoints()
    InformationFrame:SetPoint(self.db.global.InformationFrameAnchorFrom, Minimap, self.db.global
    .InformationFrameAnchorTo, self.db.global.InformationFrameXOffset, self.db.global.InformationFrameYOffset)
    InformationFrameText = InformationFrame:CreateFontString("InformationFrameText", "BACKGROUND")
    InformationFrameText:ClearAllPoints()
    InformationFrameText:SetPoint(self.db.global.InformationFrameAnchorFrom, InformationFrame,
        self.db.global.InformationFrameAnchorTo, 0, 0)
    InformationFrameText:SetFont(self.db.global.Font, self.db.global.InformationFrameFontSize, self.db.global
    .FontOutline)
    InformationFrameText:SetTextColor(self.db.global.PrimaryFontColorR, self.db.global.PrimaryFontColorG,
        self.db.global.PrimaryFontColorB)
    InformationFrameText:SetText(FetchInformation())
    InformationFrame:SetHeight(InformationFrameText:GetStringHeight() or 24)
    InformationFrame:SetWidth(InformationFrameText:GetStringWidth() or 200)

    --[[ Instance Difficulty Frame ]]
                                      --
    InstanceDifficultyFrame = CreateFrame("Frame", "InstanceDifficultyFrame", Minimap)
    InstanceDifficultyFrame:ClearAllPoints()
    InstanceDifficultyFrame:SetPoint(self.db.global.InstanceDifficultyFrameAnchorFrom, Minimap,
        self.db.global.InstanceDifficultyFrameAnchorTo, self.db.global.InstanceDifficultyFrameXOffset,
        self.db.global.InstanceDifficultyFrameYOffset)
    InstanceDifficultyFrameText = InstanceDifficultyFrame:CreateFontString("InstanceDifficultyFrameText", "BACKGROUND")
    InstanceDifficultyFrameText:ClearAllPoints()
    InstanceDifficultyFrameText:SetPoint(self.db.global.InstanceDifficultyFrameAnchorFrom, InstanceDifficultyFrame,
        self.db.global.InstanceDifficultyFrameAnchorTo, 0, 0)
    InstanceDifficultyFrameText:SetFont(self.db.global.Font, self.db.global.InstanceDifficultyFrameFontSize,
        self.db.global.FontOutline)
    InstanceDifficultyFrameText:SetText(FetchInstanceDifficulty())
    InstanceDifficultyFrame:SetHeight(InstanceDifficultyFrameText:GetStringHeight() or 24)
    InstanceDifficultyFrame:SetWidth(InstanceDifficultyFrameText:GetStringWidth() or 200)

    --[[ Instance Difficulty Frame: Event Registeration ]]
                                                           --
    InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
    InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    InstanceDifficultyFrame:RegisterEvent("WORLD_STATE_TIMER_START")

    CoordinatesFrame = CreateFrame("Frame", "CoordinatesFrame", Minimap)
    CoordinatesFrame:ClearAllPoints()
    CoordinatesFrame:SetPoint(self.db.global.CoordinatesFrameAnchorFrom, Minimap, self.db.global
    .CoordinatesFrameAnchorTo, self.db.global.CoordinatesFrameXOffset, self.db.global.CoordinatesFrameYOffset)
    CoordinatesFrameText = CoordinatesFrame:CreateFontString("CoordinatesFrameText", "BACKGROUND")
    CoordinatesFrameText:ClearAllPoints()
    CoordinatesFrameText:SetPoint(self.db.global.CoordinatesFrameAnchorFrom, CoordinatesFrame,
        self.db.global.CoordinatesFrameAnchorTo, 0, 0)
    CoordinatesFrameText:SetFont(self.db.global.Font, self.db.global.CoordinatesFrameFontSize, self.db.global
    .FontOutline)
    CoordinatesFrameText:SetTextColor(self.db.global.PrimaryFontColorR, self.db.global.PrimaryFontColorG,
        self.db.global.PrimaryFontColorB)
    CoordinatesFrameText:SetText(FetchCoordinates())
    CoordinatesFrame:SetHeight(CoordinatesFrameText:GetStringHeight() or 24)
    CoordinatesFrame:SetWidth(CoordinatesFrameText:GetStringWidth() or 200)

    local TimeFrame_LastUpdate = 0
    local InformationFrame_LastUpdate = 0
    local CoordinatesFrame_LastUpdate = 0
    local InstanceDifficultyFrame_LastUpdate = 0

    function UpdateTimeFrame(TimeFrame, ElapsedTime)
        TimeFrame_LastUpdate = TimeFrame_LastUpdate + ElapsedTime
        if TimeFrame_LastUpdate > self.db.global.TimeFrame_UpdateFrequency then
            if DebugMode then
                print(AddOnName .. ": Time Frame: Updated")
            end
            TimeFrame_LastUpdate = 0
            TimeFrameText:SetText(FetchTime())
        end
    end

    function UpdateLocationFrame(LocationFrame, FrameEvent)
        if FrameEvent == "ZONE_CHANGED" or FrameEvent == "ZONE_CHANGED_INDOORS" or FrameEvent == "ZONE_CHANGED_NEW_AREA" or FrameEvent == "PLAYER_ENTERING_WORLD" then
            LocationFrameText:SetText(FetchLocation())
        end
    end

    function UpdateInformationFrame(InformationFrame, ElapsedTime)
        InformationFrame_LastUpdate = InformationFrame_LastUpdate + ElapsedTime
        if InformationFrame_LastUpdate > self.db.global.InformationFrame_UpdateFrequency then
            if DebugMode then
                print(AddOnName .. ": Information Frame: Updated")
            end
            InformationFrame_LastUpdate = 0
            InformationFrameText:SetText(FetchInformation())
        end
    end

    function UpdateCoordinatesFrame(CoordinatesFrame, ElapsedTime)
        CoordinatesFrame_LastUpdate = CoordinatesFrame_LastUpdate + ElapsedTime
        if CoordinatesFrame_LastUpdate > self.db.global.CoordinatesFrame_UpdateFrequency then
            if DebugMode then
                print(AddOnName .. ": Coordinates Frame: Updated")
            end
            CoordinatesFrame_LastUpdate = 0
            CoordinatesFrameText:SetText(FetchCoordinates())
        end
    end

    function UpdateInstanceDifficultyFrame(InstanceDifficultyFrame, FrameEvent)
        if FrameEvent == "ZONE_CHANGED" or FrameEvent == "ZONE_CHANGED_INDOORS" or FrameEvent == "ZONE_CHANGED_NEW_AREA" or FrameEvent == "PLAYER_ENTERING_WORLD" or FrameEvent == "GROUP_ROSTER_UPDATE" or FrameEvent == "WORLD_STATE_TIME_START" then
            InstanceDifficultyFrameText:SetText(FetchInstanceDifficulty())
        end
    end

    function TestInstanceDifficultyFrame(InstanceDifficultyFrame, ElapsedTime)
        InstanceDifficultyFrame_LastUpdate = InstanceDifficultyFrame_LastUpdate + ElapsedTime
        if InstanceDifficultyFrame_LastUpdate > 3 then
            if DebugMode then
                print(AddOnName .. ": Instance Difficulty Frame: Updated")
            end
            InstanceDifficultyFrame_LastUpdate = 0
            InstanceDifficultyFrameText:SetText(FetchInstanceDifficulty())
        end
    end

    --[[ Scripts ]]
                    --
    if self.db.global.DisplayCoordinates then
        CoordinatesFrame:SetScript("OnUpdate", UpdateCoordinatesFrame)
    else
        CoordinatesFrame:SetScript("OnUpdate", nil)
    end
    if self.db.global.DisplayTime then
        TimeFrame:SetScript("OnUpdate", UpdateTimeFrame)
        TimeFrame:SetScript("OnMouseDown", function(self, button) if button == "LeftButton" then ToggleCalendar() end end)
    else
        TimeFrame:SetScript("OnUpdate", nil)
    end
    LocationFrame:SetScript("OnEvent", UpdateLocationFrame)
    if self.db.global.DisplayInformation then
        InformationFrame:SetScript("OnUpdate", UpdateInformationFrame)
        InformationFrame:SetScript("OnMouseDown",
            function(self, button) if button == "MiddleButton" then ReloadUI() elseif button == "RightButton" then if MSGUIShown == false then
                        RunMSGUI() else return end end end)
    else
        InformationFrame:SetScript("OnUpdate", nil)
    end
    InstanceDifficultyFrame:SetScript("OnEvent", UpdateInstanceDifficultyFrame)

    function ResetDefaults()
        self.db:ResetDB()
        RefreshElements()
        print(AddOnName .. ": Settings Reset.")
    end

    function DebugModeDetection()
        if DebugMode == false then
            ToggleDebugModeButton:SetText("Debug Mode: |cFFFF4040Disabled|r")
        else
            ToggleDebugModeButton:SetText("Debug Mode: |cFF40FF40Enabled|r")
        end
    end

    function ToggleDebugMode()
        if DebugMode then
            DebugMode = false
            print(AddOnName .. ": Debug Mode |cFFFF4040Disabled|r.")
        else
            DebugMode = true
            print(AddOnName .. ": Debug Mode |cFF00FF00Enabled|r.")
        end
    end

    function RunMSGUI()
        MSGUIShown = true

        local MSGUIContainer = MSGUI:Create("Window")
        MSGUIContainer:SetTitle(AddOnName .. " V" .. AddOnVersion)
        MSGUIContainer:SetCallback("OnClose", function(widget)
            MSGUI:Release(widget)
            MSGUIShown = false
        end)
        MSGUIContainer:SetLayout("Fill")
        MSGUIContainer:SetWidth(750)
        MSGUIContainer:SetHeight(700)
        MSGUIContainer:EnableResize(false)

        local function DrawTimeContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)

            local TimeToggleContainer = MSGUI:Create("InlineGroup")
            TimeToggleContainer:SetTitle("Toggle Options")
            TimeToggleContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(TimeToggleContainer)

            local TimeFormatContainer = MSGUI:Create("InlineGroup")
            TimeFormatContainer:SetTitle("Format Options")
            TimeFormatContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(TimeFormatContainer)

            local TimeFontSizeContainer = MSGUI:Create("InlineGroup")
            TimeFontSizeContainer:SetTitle("Font Size Options")
            TimeFontSizeContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(TimeFontSizeContainer)

            local TimePositionsContainer = MSGUI:Create("InlineGroup")
            TimePositionsContainer:SetTitle("Position Options")
            TimePositionsContainer:SetFullWidth(true)
            TimePositionsContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(TimePositionsContainer)

            local TimeMiscContainer = MSGUI:Create("InlineGroup")
            TimeMiscContainer:SetTitle("Misc Options")
            TimeMiscContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(TimeMiscContainer)

            local DisplayTimeCheckBox = MSGUI:Create("CheckBox")
            DisplayTimeCheckBox:SetLabel("Show / Hide")
            DisplayTimeCheckBox:SetValue(self.db.global.DisplayTime)
            DisplayTimeCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.DisplayTime = value
                    RefreshElements()
                end)
            TimeToggleContainer:AddChild(DisplayTimeCheckBox)

            local TimeFormatDropdown = MSGUI:Create("Dropdown")
            TimeFormatDropdown:SetLabel("Format")
            local TimeFormatDropdownData =
            {
                ["TwentyFourHourTime"] = "24 Hour",
                ["TwelveHourTime"] = "12 Hour (AM/PM)",
                ["ServerTime"] = "24 Hour [Server Time]",
                ["TwelverHourServerTime"] = "12 Hour (AM/PM) [Server Time]"
            }
            local TimeFormatDropdownOrder =
            {
                "TwentyFourHourTime",
                "TwelveHourTime",
                "ServerTime",
                "TwelverHourServerTime"
            }
            TimeFormatDropdown:SetList(TimeFormatDropdownData, TimeFormatDropdownOrder)
            TimeFormatDropdown:SetValue(self.db.global.TimeFormat)
            TimeFormatDropdown:SetFullWidth(true)
            TimeFormatDropdown:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.TimeFormat = value
                    RefreshElements()
                end)
            TimeFormatContainer:AddChild(TimeFormatDropdown)

            local TimeFontSize = MSGUI:Create("Slider")
            TimeFontSize:SetLabel("Font Size")
            TimeFontSize:SetSliderValues(1, 100, 1)
            TimeFontSize:SetValue(self.db.global.TimeFrameFontSize)
            TimeFontSize:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.TimeFrameFontSize = value
                    RefreshElements()
                end)
            TimeFontSize:SetFullWidth(true)
            TimeFontSizeContainer:AddChild(TimeFontSize)

            local TimePositionAnchorFrom = MSGUI:Create("Dropdown")
            TimePositionAnchorFrom:SetLabel("Anchor From")
            TimePositionAnchorFrom:SetFullWidth(true)
            TimePositionAnchorFrom:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            TimePositionAnchorFrom:SetValue(self.db.global.TimeFrameAnchorFrom)
            TimePositionAnchorFrom:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.TimeFrameAnchorFrom = value
                    RefreshElements()
                end)

            local TimePositionAnchorTo = MSGUI:Create("Dropdown")
            TimePositionAnchorTo:SetLabel("Anchor To")
            TimePositionAnchorTo:SetFullWidth(true)
            TimePositionAnchorTo:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            TimePositionAnchorTo:SetValue(self.db.global.TimeFrameAnchorFrom)
            TimePositionAnchorTo:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.TimeFrameAnchorTo = value
                    RefreshElements()
                end)

            local TimePositionXOffset = MSGUI:Create("Slider")
            TimePositionXOffset:SetLabel("X Offset")
            TimePositionXOffset:SetFullWidth(true)
            TimePositionXOffset:SetSliderValues(-1000, 1000, 1)
            TimePositionXOffset:SetValue(self.db.global.TimeFrameXOffset)
            TimePositionXOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.TimeFrameXOffset = value
                    RefreshElements()
                end)

            local TimePositionYOffset = MSGUI:Create("Slider")
            TimePositionYOffset:SetLabel("Y Offset")
            TimePositionYOffset:SetFullWidth(true)
            TimePositionYOffset:SetSliderValues(-1000, 1000, 1)
            TimePositionYOffset:SetValue(self.db.global.TimeFrameYOffset)
            TimePositionYOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.TimeFrameYOffset = value
                    RefreshElements()
                end)

            local TimeUpdateFrequency = MSGUI:Create("Slider")
            TimeUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            TimeUpdateFrequency:SetFullWidth(true)
            TimeUpdateFrequency:SetSliderValues(1, 60, 1)
            TimeUpdateFrequency:SetValue(self.db.global.TimeFrame_UpdateFrequency)
            TimeUpdateFrequency:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.TimeFrame_UpdateFrequency = value
                    RefreshElements()
                end)
            TimeMiscContainer:AddChild(TimeUpdateFrequency)

            TimePositionsContainer:AddChild(TimePositionAnchorFrom)
            TimePositionsContainer:AddChild(TimePositionAnchorTo)
            TimePositionsContainer:AddChild(TimePositionXOffset)
            TimePositionsContainer:AddChild(TimePositionYOffset)
        end

        local function DrawLocationContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)

            local LocationToggleContainer = MSGUI:Create("InlineGroup")
            LocationToggleContainer:SetTitle("Toggle Options")
            LocationToggleContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(LocationToggleContainer)

            local LocationFontSizeContainer = MSGUI:Create("InlineGroup")
            LocationFontSizeContainer:SetTitle("Font Size Options")
            LocationFontSizeContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(LocationFontSizeContainer)

            local DisplayLocationCheckBox = MSGUI:Create("CheckBox")
            DisplayLocationCheckBox:SetLabel("Show / Hide")
            DisplayLocationCheckBox:SetValue(self.db.global.DisplayLocation)
            DisplayLocationCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.DisplayLocation = value
                    RefreshElements()
                end)
            LocationToggleContainer:AddChild(DisplayLocationCheckBox)

            local DisplayReactionColorCheckBox = MSGUI:Create("CheckBox")
            DisplayReactionColorCheckBox:SetLabel("Display Reaction Color")
            DisplayReactionColorCheckBox:SetValue(self.db.global.DisplayReactionColor)
            DisplayReactionColorCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.DisplayReactionColor = value
                    RefreshElements()
                end)
            LocationToggleContainer:AddChild(DisplayReactionColorCheckBox)

            local LocationFontSize = MSGUI:Create("Slider")
            LocationFontSize:SetLabel("Font Size")
            LocationFontSize:SetSliderValues(1, 100, 1)
            LocationFontSize:SetValue(self.db.global.LocationFrameFontSize)
            LocationFontSize:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.LocationFrameFontSize = value
                    RefreshElements()
                end)
            LocationFontSize:SetFullWidth(true)
            LocationFontSizeContainer:AddChild(LocationFontSize)

            local LocationPositionsContainer = MSGUI:Create("InlineGroup")
            LocationPositionsContainer:SetTitle("Position Options")
            LocationPositionsContainer:SetFullWidth(true)
            LocationPositionsContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(LocationPositionsContainer)

            local LocationPositionAnchorFrom = MSGUI:Create("Dropdown")
            LocationPositionAnchorFrom:SetLabel("Anchor From")
            LocationPositionAnchorFrom:SetFullWidth(true)
            LocationPositionAnchorFrom:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            LocationPositionAnchorFrom:SetValue(self.db.global.LocationFrameAnchorFrom)
            LocationPositionAnchorFrom:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.LocationFrameAnchorFrom = value
                    RefreshElements()
                end)

            local LocationPositionAnchorTo = MSGUI:Create("Dropdown")
            LocationPositionAnchorTo:SetLabel("Anchor To")
            LocationPositionAnchorTo:SetFullWidth(true)
            LocationPositionAnchorTo:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            LocationPositionAnchorTo:SetValue(self.db.global.LocationFrameAnchorTo)
            LocationPositionAnchorTo:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.LocationFrameAnchorTo = value
                    RefreshElements()
                end)

            local LocationPositionXOffset = MSGUI:Create("Slider")
            LocationPositionXOffset:SetLabel("X Offset")
            LocationPositionXOffset:SetFullWidth(true)
            LocationPositionXOffset:SetSliderValues(-1000, 1000, 1)
            LocationPositionXOffset:SetValue(self.db.global.LocationFrameXOffset)
            LocationPositionXOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.LocationFrameXOffset = value
                    RefreshElements()
                end)

            local LocationPositionYOffset = MSGUI:Create("Slider")
            LocationPositionYOffset:SetLabel("Y Offset")
            LocationPositionYOffset:SetFullWidth(true)
            LocationPositionYOffset:SetSliderValues(-1000, 1000, 1)
            LocationPositionYOffset:SetValue(self.db.global.LocationFrameYOffset)
            LocationPositionYOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.LocationFrameYOffset = value
                    RefreshElements()
                end)

            LocationPositionsContainer:AddChild(LocationPositionAnchorFrom)
            LocationPositionsContainer:AddChild(LocationPositionAnchorTo)
            LocationPositionsContainer:AddChild(LocationPositionXOffset)
            LocationPositionsContainer:AddChild(LocationPositionYOffset)
        end

        local function DrawInformationContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)

            local InformationToggleContainer = MSGUI:Create("InlineGroup")
            InformationToggleContainer:SetTitle("Toggle Options")
            InformationToggleContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(InformationToggleContainer)

            local InformationFormatContainer = MSGUI:Create("InlineGroup")
            InformationFormatContainer:SetTitle("Format Options")
            InformationFormatContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(InformationFormatContainer)

            local InformationFontSizeContainer = MSGUI:Create("InlineGroup")
            InformationFontSizeContainer:SetTitle("Font Size Options")
            InformationFontSizeContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(InformationFontSizeContainer)

            local InformationPositionsContainer = MSGUI:Create("InlineGroup")
            InformationPositionsContainer:SetTitle("Position Options")
            InformationPositionsContainer:SetFullWidth(true)
            InformationPositionsContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(InformationPositionsContainer)

            local InformationMiscContainer = MSGUI:Create("InlineGroup")
            InformationMiscContainer:SetTitle("Misc Options")
            InformationMiscContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(InformationMiscContainer)

            local DisplayInformationCheckBox = MSGUI:Create("CheckBox")
            DisplayInformationCheckBox:SetLabel("Show / Hide")
            DisplayInformationCheckBox:SetValue(self.db.global.DisplayInformation)
            DisplayInformationCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.DisplayInformation = value
                    RefreshElements()
                end)
            InformationToggleContainer:AddChild(DisplayInformationCheckBox)

            local InformationFormatDropdown = MSGUI:Create("Dropdown")
            InformationFormatDropdown:SetLabel("Format")
            local InformationFormatDropdownData =
            {
                ["FPSHomeMS"] = "FPS [Home MS]",
                ["FPSWorldMS"] = "FPS [World MS]",
                ["FPSOnly"] = "FPS",
                ["HomeMSOnly"] = "Home MS",
                ["WorldMSOnly"] = "World MS",
                ["MSOnly"] = "Home MS [World MS]"
            }
            local InformationFormatDataOrder =
            {
                "FPSHomeMS",
                "FPSWorldMS",
                "FPSOnly",
                "MSOnly",
                "HomeMSOnly",
                "WorldMSOnly",
            }
            InformationFormatDropdown:SetList(InformationFormatDropdownData, InformationFormatDataOrder)
            InformationFormatDropdown:SetValue(self.db.global.InformationFormat)
            InformationFormatDropdown:SetFullWidth(true)
            InformationFormatDropdown:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InformationFormat = value
                    RefreshElements()
                end)
            InformationFormatContainer:AddChild(InformationFormatDropdown)

            local InformationFontSize = MSGUI:Create("Slider")
            InformationFontSize:SetLabel("Font Size")
            InformationFontSize:SetSliderValues(1, 100, 1)
            InformationFontSize:SetValue(self.db.global.InformationFrameFontSize)
            InformationFontSize:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InformationFrameFontSize = value
                    RefreshElements()
                end)
            InformationFontSize:SetFullWidth(true)
            InformationFontSizeContainer:AddChild(InformationFontSize)

            local InformationPositionAnchorFrom = MSGUI:Create("Dropdown")
            InformationPositionAnchorFrom:SetLabel("Anchor From")
            InformationPositionAnchorFrom:SetFullWidth(true)
            InformationPositionAnchorFrom:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            InformationPositionAnchorFrom:SetValue(self.db.global.InformationFrameAnchorFrom)
            InformationPositionAnchorFrom:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InformationFrameAnchorFrom = value
                    RefreshElements()
                end)

            local InformationPositionAnchorTo = MSGUI:Create("Dropdown")
            InformationPositionAnchorTo:SetLabel("Anchor To")
            InformationPositionAnchorTo:SetFullWidth(true)
            InformationPositionAnchorTo:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            InformationPositionAnchorTo:SetValue(self.db.global.InformationFrameAnchorTo)
            InformationPositionAnchorTo:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InformationFrameAnchorTo = value
                    RefreshElements()
                end)

            local InformationPositionXOffset = MSGUI:Create("Slider")
            InformationPositionXOffset:SetLabel("X Offset")
            InformationPositionXOffset:SetFullWidth(true)
            InformationPositionXOffset:SetSliderValues(-1000, 1000, 1)
            InformationPositionXOffset:SetValue(self.db.global.InformationFrameXOffset)
            InformationPositionXOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InformationFrameXOffset = value
                    RefreshElements()
                end)

            local InformationPositionYOffset = MSGUI:Create("Slider")
            InformationPositionYOffset:SetLabel("Y Offset")
            InformationPositionYOffset:SetFullWidth(true)
            InformationPositionYOffset:SetSliderValues(-1000, 1000, 1)
            InformationPositionYOffset:SetValue(self.db.global.InformationFrameYOffset)
            InformationPositionYOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InformationFrameYOffset = value
                    RefreshElements()
                end)

            local InformationUpdateFrequency = MSGUI:Create("Slider")
            InformationUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            InformationUpdateFrequency:SetFullWidth(true)
            InformationUpdateFrequency:SetSliderValues(1, 60, 1)
            InformationUpdateFrequency:SetValue(self.db.global.InformationFrame_UpdateFrequency)
            InformationUpdateFrequency:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InformationFrame_UpdateFrequency = value
                    RefreshElements()
                end)
            InformationMiscContainer:AddChild(InformationUpdateFrequency)

            InformationPositionsContainer:AddChild(InformationPositionAnchorFrom)
            InformationPositionsContainer:AddChild(InformationPositionAnchorTo)
            InformationPositionsContainer:AddChild(InformationPositionXOffset)
            InformationPositionsContainer:AddChild(InformationPositionYOffset)
        end

        local function DrawInstanceDifficultyContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)

            local InstanceDifficultyToggleContainer = MSGUI:Create("InlineGroup")
            InstanceDifficultyToggleContainer:SetTitle("Toggle Options")
            InstanceDifficultyToggleContainer:SetFullWidth(true)
            InstanceDifficultyToggleContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(InstanceDifficultyToggleContainer)

            local InstanceDifficultyFontSizeContainer = MSGUI:Create("InlineGroup")
            InstanceDifficultyFontSizeContainer:SetTitle("Font Size Options")
            InstanceDifficultyFontSizeContainer:SetFullWidth(true)
            InstanceDifficultyFontSizeContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(InstanceDifficultyFontSizeContainer)

            local DisplayInstanceDifficultyCheckBox = MSGUI:Create("CheckBox")
            DisplayInstanceDifficultyCheckBox:SetLabel("Show / Hide")
            DisplayInstanceDifficultyCheckBox:SetValue(self.db.global.DisplayInstanceDifficulty)
            DisplayInstanceDifficultyCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.DisplayInstanceDifficulty = value
                    RefreshElements()
                end)
            InstanceDifficultyToggleContainer:AddChild(DisplayInstanceDifficultyCheckBox)

            TestInstanceDifficultyCheckBox = MSGUI:Create("CheckBox")
            TestInstanceDifficultyCheckBox:SetLabel("Test Instance Difficulty")
            TestInstanceDifficultyCheckBox:SetValue(TestingInstanceDifficulty)
            TestInstanceDifficultyCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    TestingInstanceDifficulty = value
                    RefreshElements()
                end)
            InstanceDifficultyToggleContainer:AddChild(TestInstanceDifficultyCheckBox)

            local InstanceDifficultyFontSize = MSGUI:Create("Slider")
            InstanceDifficultyFontSize:SetLabel("Font Size")
            InstanceDifficultyFontSize:SetSliderValues(1, 100, 1)
            InstanceDifficultyFontSize:SetValue(self.db.global.InstanceDifficultyFrameFontSize)
            InstanceDifficultyFontSize:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InstanceDifficultyFrameFontSize = value
                    RefreshElements()
                end)
            InstanceDifficultyFontSize:SetFullWidth(true)
            InstanceDifficultyFontSizeContainer:AddChild(InstanceDifficultyFontSize)

            local InstanceDifficultyPositionsContainer = MSGUI:Create("InlineGroup")
            InstanceDifficultyPositionsContainer:SetTitle("Position Options")
            InstanceDifficultyPositionsContainer:SetFullWidth(true)
            InstanceDifficultyPositionsContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(InstanceDifficultyPositionsContainer)

            local InstanceDifficultyPositionAnchorFrom = MSGUI:Create("Dropdown")
            InstanceDifficultyPositionAnchorFrom:SetLabel("Anchor From")
            InstanceDifficultyPositionAnchorFrom:SetFullWidth(true)
            InstanceDifficultyPositionAnchorFrom:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            InstanceDifficultyPositionAnchorFrom:SetValue(self.db.global.InstanceDifficultyFrameAnchorFrom)
            InstanceDifficultyPositionAnchorFrom:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InstanceDifficultyFrameAnchorFrom = value
                    RefreshElements()
                end)

            local InstanceDifficultyPositionAnchorTo = MSGUI:Create("Dropdown")
            InstanceDifficultyPositionAnchorTo:SetLabel("Anchor To")
            InstanceDifficultyPositionAnchorTo:SetFullWidth(true)
            InstanceDifficultyPositionAnchorTo:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            InstanceDifficultyPositionAnchorTo:SetValue(self.db.global.InstanceDifficultyFrameAnchorTo)
            InstanceDifficultyPositionAnchorTo:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InstanceDifficultyFrameAnchorTo = value
                    RefreshElements()
                end)

            local InstanceDifficultyPositionXOffset = MSGUI:Create("Slider")
            InstanceDifficultyPositionXOffset:SetLabel("X Offset")
            InstanceDifficultyPositionXOffset:SetFullWidth(true)
            InstanceDifficultyPositionXOffset:SetSliderValues(-1000, 1000, 1)
            InstanceDifficultyPositionXOffset:SetValue(self.db.global.InstanceDifficultyFrameXOffset)
            InstanceDifficultyPositionXOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InstanceDifficultyFrameXOffset = value
                    RefreshElements()
                end)

            local InstanceDifficultyPositionYOffset = MSGUI:Create("Slider")
            InstanceDifficultyPositionYOffset:SetLabel("Y Offset")
            InstanceDifficultyPositionYOffset:SetFullWidth(true)
            InstanceDifficultyPositionYOffset:SetSliderValues(-1000, 1000, 1)
            InstanceDifficultyPositionYOffset:SetValue(self.db.global.InstanceDifficultyFrameYOffset)
            InstanceDifficultyPositionYOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.InstanceDifficultyFrameYOffset = value
                    RefreshElements()
                end)

            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionAnchorFrom)
            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionAnchorTo)
            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionXOffset)
            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionYOffset)
        end

        local function DrawFontandColourContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)

            local ColourContainer = MSGUI:Create("InlineGroup")
            ColourContainer:SetTitle("Colour Options")
            ColourContainer:SetFullWidth(true)
            ColourContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(ColourContainer)

            local ClassColorCheckBox = MSGUI:Create("CheckBox")
            ClassColorCheckBox:SetLabel("Use Class Color")
            ClassColorCheckBox:SetValue(self.db.global.UseClassColours)
            ClassColorCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.UseClassColours = value
                    if value == true then SecondaryFontColor:SetDisabled(true) else SecondaryFontColor:SetDisabled(false) end
                    RefreshElements()
                end)
            ColourContainer:AddChild(ClassColorCheckBox)

            local PrimaryFontColor = MSGUI:Create("ColorPicker")
            PrimaryFontColor:SetLabel("Primary Font Color")
            PrimaryFontColor:SetHasAlpha(false)
            PrimaryFontColor:SetColor(self.db.global.PrimaryFontColorR, self.db.global.PrimaryFontColorG,
                self.db.global.PrimaryFontColorB)
            PrimaryFontColor:SetCallback("OnValueChanged",
                function(widget, event, r, g, b)
                    self.db.global.PrimaryFontColorR = r
                    self.db.global.PrimaryFontColorG = g
                    self.db.global.PrimaryFontColorB = b
                    RefreshElements()
                end)
            PrimaryFontColor:SetCallback("OnValueConfirmed",
                function(widget, event, r, g, b)
                    self.db.global.PrimaryFontColorR = r
                    self.db.global.PrimaryFontColorG = g
                    self.db.global.PrimaryFontColorB = b
                    RefreshElements()
                end)
            ColourContainer:AddChild(PrimaryFontColor)

            SecondaryFontColor = MSGUI:Create("ColorPicker")
            SecondaryFontColor:SetLabel("Secondary Font Color")
            SecondaryFontColor:SetHasAlpha(false)
            SecondaryFontColor:SetColor(self.db.global.SecondaryFontColorR, self.db.global.SecondaryFontColorG,
                self.db.global.SecondaryFontColorB)
            SecondaryFontColor:SetCallback("OnValueChanged",
                function(widget, event, r, g, b)
                    self.db.global.SecondaryFontColorR = r
                    self.db.global.SecondaryFontColorG = g
                    self.db.global.SecondaryFontColorB = b
                    RefreshElements()
                end)
            SecondaryFontColor:SetCallback("OnValueConfirmed",
                function(widget, event, r, g, b)
                    self.db.global.SecondaryFontColorR = r
                    self.db.global.SecondaryFontColorG = g
                    self.db.global.SecondaryFontColorB = b
                    RefreshElements()
                end)
            if self.db.global.UseClassColours == true then
                SecondaryFontColor:SetDisabled(true)
            else
                SecondaryFontColor:SetDisabled(false)
            end
            ColourContainer:AddChild(SecondaryFontColor)

            local FontContainer = MSGUI:Create("InlineGroup")
            FontContainer:SetTitle("Font Options")
            FontContainer:SetFullWidth(true)
            FontContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(FontContainer)

            local Font = MSGUI:Create("Dropdown")
            Font:SetLabel("Font")
            local FontList = LSM:HashTable("font")
            for FontPath, FontName in pairs(FontList) do
                Font:AddItem(FontName, FontPath)
            end
            Font:SetFullWidth(true)
            Font:SetValue(self.db.global.Font)
            Font:SetCallback("OnValueChanged",
                function(widget, event, FontPath)
                    self.db.global.Font = FontPath
                    RefreshElements()
                end)
            FontContainer:AddChild(Font)

            local FontOutline = MSGUI:Create("Dropdown")
            FontOutline:SetLabel("Font Outline")
            FontOutline:SetList({ ["NONE"] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline" })
            FontOutline:SetValue(self.db.global.FontOutline)
            FontOutline:SetFullWidth(true)
            FontOutline:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.FontOutline = value
                    RefreshElements()
                end)
            FontContainer:AddChild(FontOutline)

            local MiscContainer = MSGUI:Create("InlineGroup")
            MiscContainer:SetTitle("Misc Options")
            MiscContainer:SetFullWidth(true)
            MiscContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(MiscContainer)

            ToggleDebugModeButton = MSGUI:Create("Button")
            ToggleDebugModeButton:SetText(DebugModeDetection())
            ToggleDebugModeButton:SetFullWidth(true)
            ToggleDebugModeButton:SetCallback("OnClick",
                function()
                    ToggleDebugMode()
                    DebugModeDetection()
                    MSGUIContainer:DoLayout()
                end)
            MiscContainer:AddChild(ToggleDebugModeButton)

            local ResetDefaultsButton = MSGUI:Create("Button")
            ResetDefaultsButton:SetText("Reset Defaults")
            ResetDefaultsButton:SetFullWidth(true)
            ResetDefaultsButton:SetCallback("OnClick", function() ResetDefaults() end)
            MiscContainer:AddChild(ResetDefaultsButton)
        end

        local function DrawCoordinatesContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)

            local CoordinatesToggleContainer = MSGUI:Create("InlineGroup")
            CoordinatesToggleContainer:SetTitle("Toggle Options")
            CoordinatesToggleContainer:SetFullWidth(true)
            CoordinatesToggleContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(CoordinatesToggleContainer)

            local CoordinatesFormatContainer = MSGUI:Create("InlineGroup")
            CoordinatesFormatContainer:SetTitle("Format Options")
            CoordinatesFormatContainer:SetFullWidth(true)
            CoordinatesFormatContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(CoordinatesFormatContainer)

            local CoordinatesFontSizeContainer = MSGUI:Create("InlineGroup")
            CoordinatesFontSizeContainer:SetTitle("Font Size Options")
            CoordinatesFontSizeContainer:SetFullWidth(true)
            CoordinatesFontSizeContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(CoordinatesFontSizeContainer)

            local CoordinatesPositionsContainer = MSGUI:Create("InlineGroup")
            CoordinatesPositionsContainer:SetTitle("Position Options")
            CoordinatesPositionsContainer:SetFullWidth(true)
            CoordinatesPositionsContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(CoordinatesPositionsContainer)

            local CoordinatesMiscContainer = MSGUI:Create("InlineGroup")
            CoordinatesMiscContainer:SetTitle("Misc Options")
            CoordinatesMiscContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(CoordinatesMiscContainer)

            local DisplayCoordinatesCheckBox = MSGUI:Create("CheckBox")
            DisplayCoordinatesCheckBox:SetLabel("Show / Hide")
            DisplayCoordinatesCheckBox:SetValue(self.db.global.DisplayCoordinates)
            DisplayCoordinatesCheckBox:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.DisplayCoordinates = value
                    RefreshElements()
                    MSGUIContainer:DoLayout()
                end)
            CoordinatesToggleContainer:AddChild(DisplayCoordinatesCheckBox)

            local CoordinatesFormatDropdown = MSGUI:Create("Dropdown")
            CoordinatesFormatDropdown:SetLabel("Format")
            CoordinatesFormatDropdown:SetList({ ["NoDecimal"] = "No Decimals [00, 00]",
                ["OneDecimal"] = "One Decimal [00.0, 00.0]", ["TwoDecimal"] = "Two Decimals [00.00, 00.00]" })
            CoordinatesFormatDropdown:SetValue(self.db.global.CoordinatesFormat)
            CoordinatesFormatDropdown:SetFullWidth(true)
            CoordinatesFormatDropdown:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.CoordinatesFormat = value
                    RefreshElements()
                end)
            CoordinatesFormatContainer:AddChild(CoordinatesFormatDropdown)

            local CoordinatesFontSize = MSGUI:Create("Slider")
            CoordinatesFontSize:SetLabel("Font Size")
            CoordinatesFontSize:SetSliderValues(1, 100, 1)
            CoordinatesFontSize:SetValue(self.db.global.CoordinatesFrameFontSize)
            CoordinatesFontSize:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.CoordinatesFrameFontSize = value
                    RefreshElements()
                end)
            CoordinatesFontSize:SetFullWidth(true)
            CoordinatesFontSizeContainer:AddChild(CoordinatesFontSize)

            local CoordinatesPositionAnchorFrom = MSGUI:Create("Dropdown")
            CoordinatesPositionAnchorFrom:SetLabel("Anchor From")
            CoordinatesPositionAnchorFrom:SetFullWidth(true)
            CoordinatesPositionAnchorFrom:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            CoordinatesPositionAnchorFrom:SetValue(self.db.global.CoordinatesFrameAnchorFrom)
            CoordinatesPositionAnchorFrom:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.CoordinatesFrameAnchorFrom = value
                    RefreshElements()
                end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionAnchorFrom)

            local CoordinatesPositionAnchorTo = MSGUI:Create("Dropdown")
            CoordinatesPositionAnchorTo:SetLabel("Anchor To")
            CoordinatesPositionAnchorTo:SetFullWidth(true)
            CoordinatesPositionAnchorTo:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left",
                ["RIGHT"] = "Right", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right",
                ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" })
            CoordinatesPositionAnchorTo:SetValue(self.db.global.CoordinatesFrameAnchorTo)
            CoordinatesPositionAnchorTo:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.CoordinatesFrameAnchorTo = value
                    RefreshElements()
                end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionAnchorTo)

            local CoordinatesPositionXOffset = MSGUI:Create("Slider")
            CoordinatesPositionXOffset:SetLabel("X Offset")
            CoordinatesPositionXOffset:SetFullWidth(true)
            CoordinatesPositionXOffset:SetSliderValues(-1000, 1000, 1)
            CoordinatesPositionXOffset:SetValue(self.db.global.CoordinatesFrameXOffset)
            CoordinatesPositionXOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.CoordinatesFrameXOffset = value
                    RefreshElements()
                end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionXOffset)

            local CoordinatesPositionYOffset = MSGUI:Create("Slider")
            CoordinatesPositionYOffset:SetLabel("Y Offset")
            CoordinatesPositionYOffset:SetFullWidth(true)
            CoordinatesPositionYOffset:SetSliderValues(-1000, 1000, 1)
            CoordinatesPositionYOffset:SetValue(self.db.global.CoordinatesFrameYOffset)
            CoordinatesPositionYOffset:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.CoordinatesFrameYOffset = value
                    RefreshElements()
                end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionYOffset)

            local CoordinatesUpdateFrequency = MSGUI:Create("Slider")
            CoordinatesUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            CoordinatesUpdateFrequency:SetFullWidth(true)
            CoordinatesUpdateFrequency:SetSliderValues(1, 60, 1)
            CoordinatesUpdateFrequency:SetValue(self.db.global.CoordinatesFrame_UpdateFrequency)
            CoordinatesUpdateFrequency:SetCallback("OnValueChanged",
                function(widget, event, value)
                    self.db.global.CoordinatesFrame_UpdateFrequency = value
                    RefreshElements()
                end)
            CoordinatesMiscContainer:AddChild(CoordinatesUpdateFrequency)
        end

        local function GroupSelect(MSGUIContainer, Event, SelectedGroup)
            MSGUIContainer:ReleaseChildren()
            if SelectedGroup == "tab1" then
                DrawTimeContainer(MSGUIContainer)
            elseif SelectedGroup == "tab2" then
                DrawLocationContainer(MSGUIContainer)
            elseif SelectedGroup == "tab3" then
                DrawInformationContainer(MSGUIContainer)
            elseif SelectedGroup == "tab4" then
                DrawInstanceDifficultyContainer(MSGUIContainer)
            elseif SelectedGroup == "tab5" then
                DrawCoordinatesContainer(MSGUIContainer)
            elseif SelectedGroup == "tab6" then
                DrawFontandColourContainer(MSGUIContainer)
                DebugModeDetection()
            end
        end

        local SelectedTab = MSGUI:Create("TabGroup")
        SelectedTab:SetTabs({ { text = "Time", value = "tab1" }, { text = "Location", value = "tab2" },
            { text = "Information", value = "tab3" }, { text = "Instance Difficulty", value = "tab4" },
            { text = "Coordinates", value = "tab5" }, { text = "Font and Colour", value = "tab6" } })
        SelectedTab:SetCallback("OnGroupSelected", GroupSelect)
        SelectedTab:SelectTab("tab1")
        MSGUIContainer:AddChild(SelectedTab)
    end

    SLASH_MINIMAPSTATS1 = "/minimapstats"
    SLASH_MINIMAPSTATS2 = "/ms"
    SlashCmdList["MINIMAPSTATS"] = function(msg) if MSGUIShown == false then RunMSGUI() end end
end
