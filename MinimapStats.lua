local MinimapStats = LibStub("AceAddon-3.0"):NewAddon("MinimapStats")
local MSGUI = LibStub("AceGUI-3.0")
local AddOnName = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
local AddOnVersion = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
local LSM = LibStub("LibSharedMedia-3.0")
local OR = LibStub:GetLibrary("LibOpenRaid-1.0")
local MSGUIShown = false
local DebugMode = false
local TestingInstanceDifficulty = false
local MS = {}
local DefaultSettings = {
    global = {
        -- Toggles
        DisplayTime = true,
        DisplayDate = true,
        AlternativeFormatting = false,
        DateFormat = "DD/MM/YY",
        TimeFormat = "TwentyFourHourTime",
        DisplayLocation = true,
        DisplayReactionColor = false,
        UsePrimaryFontColor = false,
        LocationFontColor = "Secondary",
        DisplayInformation = true,
        UpdateInRealTime = false,
        CoordinatesFormat = "NoDecimal",
        InformationFormatString = "FPS [HomeMS]",
        --InformationFormat = "FPS [HomeMS]",
        DisplayInstanceDifficulty = true,
        UseClassColours = true,
        DisplayCoordinates = true,
        DisplayTooltipInformation = true,
        -- Fonts & Colors
        Font = "Fonts\\FRIZQT__.ttf",
        FontOutline = "THINOUTLINE",
        PrimaryFontColorR = 1.0,
        PrimaryFontColorG = 1.0,
        PrimaryFontColorB = 1.0,
        SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r,
        SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g,
        SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b,
        LocationCustomColorR = 1.0,
        LocationCustomColorG = 1.0,
        LocationCustomColorB = 1.0,
        ElementFrameStrata = "MEDIUM",
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
    MS.db = LibStub("AceDB-3.0"):New("MSDB", DefaultSettings)
    if MS.db.global.UseClassColours then
        MS.db.global.SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
        MS.db.global.SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
        MS.db.global.SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
    end
    local SecondaryFontColorRGB = { r = MS.db.global.SecondaryFontColorR, g = MS.db.global.SecondaryFontColorG, b = MS.db.global.SecondaryFontColorB }
    local SecondaryFontColor = string.format("%02x%02x%02x", SecondaryFontColorRGB.r * 255, SecondaryFontColorRGB.g * 255, SecondaryFontColorRGB.b * 255)
    function MS:FetchTime()
        local CurrentHour, CurrentMins = date("%H"), date("%M")
        local CurrentHourTwelve, CurrentAMPM = date("%I"), date("%p")
        local CurrentServerHour, CurrentServerMins = GetGameTime()
        
        local TwentyFourHourTime = string.format("%s:%s", CurrentHour, CurrentMins)
        local TwelveHourTime = string.format("%s:%s %s", CurrentHourTwelve, CurrentMins, CurrentAMPM)
        local ServerTime = string.format("%02d:%02d", CurrentServerHour, CurrentServerMins)
        local ServerTimeTwelveHour = ServerTime .. " AM"
        
        if CurrentServerHour > 12 then
            ServerTimeTwelveHour = string.format("%02d:%02d PM", CurrentServerHour - 12, CurrentServerMins)
        elseif CurrentServerHour == 12 then
            ServerTimeTwelveHour = ServerTime .. " PM"
        end
    
        if MS.db.global.DisplayTime then
            if MS.db.global.TimeFormat == "TwentyFourHourTime" then
                return TwentyFourHourTime
            elseif MS.db.global.TimeFormat == "TwelveHourTime" then
                return TwelveHourTime
            elseif MS.db.global.TimeFormat == "ServerTime" then
                return ServerTime
            elseif MS.db.global.TimeFormat == "TwelverHourServerTime" then
                return ServerTimeTwelveHour
            end
        end
    end
    function MS:FetchDate()
        local CurrentDate = date("%d")
        local CurrentMonth = date("%m")
        local CurrentYear = date("%y")
        local FullYear = date("%Y")
        local CurrentMonthName = date("%B")
        if MS.db.global.DisplayDate then
            if MS.db.global.DateFormat == "DD/MM/YY" and MS.db.global.AlternativeFormatting == false then
                return string.format("%s/%s/%s", CurrentDate, CurrentMonth, CurrentYear)
            elseif MS.db.global.DateFormat == "DD/MM/YY" and MS.db.global.AlternativeFormatting == true then
                return string.format("%s/%s/%s", CurrentMonth, CurrentDate, CurrentYear)
            elseif MS.db.global.DateFormat == "FullDate" and MS.db.global.AlternativeFormatting == false then
                return string.format("%s %s %s", CurrentDate, CurrentMonthName, FullYear)
            elseif MS.db.global.DateFormat == "FullDate" and MS.db.global.AlternativeFormatting == true then
                return string.format("%s %s %s", CurrentMonthName, CurrentDate, FullYear)
            end
        end
    end
    local CalculateHexValue = function(r, g, b)
        return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
    end
    function MS:FetchLocation()
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
        if MS.db.global.DisplayLocation then
            if MS.db.global.LocationFontColor == "Primary" then
                local PrimaryFontColor = string.format("%02x%02x%02x", MS.db.global.PrimaryFontColorR * 255, MS.db.global.PrimaryFontColorG * 255, MS.db.global.PrimaryFontColorB * 255)
                return "|cFF" .. PrimaryFontColor .. GetMinimapZoneText() .. "|r"
            elseif MS.db.global.LocationFontColor == "Secondary" then
                return "|cFF" .. SecondaryFontColor .. GetMinimapZoneText() .. "|r"
            elseif MS.db.global.LocationFontColor == "Custom" then
                local CustomFontColor = string.format("%02x%02x%02x", MS.db.global.LocationCustomColorR * 255, MS.db.global.LocationCustomColorG * 255, MS.db.global.LocationCustomColorB * 255)
                return "|cFF" .. CustomFontColor .. GetMinimapZoneText() .. "|r"
            elseif MS.db.global.LocationFontColor == "Reaction" then
                return "|cFF" .. LocationColor .. GetMinimapZoneText() .. "|r"
            end
        end
    end
    function MS:FetchInformation()
        if MS.db.global.DisplayInformation then
            local FPS = ceil(GetFramerate())
            local _, _, HomeMS, WorldMS = GetNetStats()
            local FormatString = MS.db.global.InformationFormatString;
            local FPSText = FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r"
            local HomeMSText = HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            local WorldMSText = WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            local KeyCodes = { ["FPS"] = FPSText, ["HomeMS"] = HomeMSText, ["WorldMS"] = WorldMSText, ["DualMS"] = HomeMSText .. " " .. WorldMSText}
            for KeyCode, value in pairs(KeyCodes) do
                FormatString = FormatString:gsub(KeyCode, value)
            end
            return FormatString
            --[[if MS.db.global.InformationFormat == "FPS [HomeMS]" then -- FPS [HomeMS]
                return FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r" .. " [" .. HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. "]"
            elseif MS.db.global.InformationFormat == "FPS [WorldMS]" then -- FPS [WorldMS]
                return FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r" .. " [" .. WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. "]"
            elseif MS.db.global.InformationFormat == "FPS | HomeMS" then -- FPS | HomeMS
                return FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r" .. " | " .. HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            elseif MS.db.global.InformationFormat == "FPS | WorldMS" then -- FPS | WorldMS
                return FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r" .. " | " .. WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            elseif MS.db.global.InformationFormat == "FPS (HomeMS)" then -- FPS (HomeMS)
                return FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r" .. " (" .. HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. ")"
            elseif MS.db.global.InformationFormat == "FPS (WorldMS)" then -- FPS (WorldMS)
                return FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r" .. " (" .. WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. ")"
            elseif MS.db.global.InformationFormat == "FPS" then -- FPS
                return FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r"
            elseif MS.db.global.InformationFormat == "HomeMS" then -- HomeMS
                return HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            elseif MS.db.global.InformationFormat == "WorldMS" then -- WorldMS
                return WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            elseif MS.db.global.InformationFormat == "HomeMS [WorldMS]" then -- HomeMS [WorldMS]
                return HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. " [" .. WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. "]"
            elseif MS.db.global.InformationFormat == "HomeMS | WorldMS" then -- HomeMS | WorldMS
                return HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. " | " .. WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            elseif MS.db.global.InformationFormat == "HomeMS (WorldMS)" then -- HomeMS (WorldMS)
                return HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. " (" .. WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r" .. ")"               
            end]]
        end
    end
    local function GetDungeonandRaidLockouts()
        local dungeons = {}
        local raids = {}
        for i = 1, GetNumSavedInstances() do
            local name, _, _, _, isLocked, _, _, isRaid, _, difficultyName, numEncounters, encounterProgress, _, _ = GetSavedInstanceInfo(i)
            local formattedInstanceInformation = string.format("%s: %d/%d %s", name, encounterProgress, numEncounters, difficultyName)
            if isLocked then
                if isRaid then
                    table.insert(raids, formattedInstanceInformation)
                else
                    table.insert(dungeons, formattedInstanceInformation)
                end
            end
        end
        if #dungeons > 0 then
            GameTooltip:AddLine("Dungeons", MS.db.global.SecondaryFontColorR, MS.db.global.SecondaryFontColorG, MS.db.global.SecondaryFontColorB)
            for _, line in ipairs(dungeons) do
                GameTooltip:AddLine(line, 1, 1, 1)
            end
            GameTooltip:AddLine(" ")
        end
        if #raids > 0 then
            GameTooltip:AddLine("Raids", MS.db.global.SecondaryFontColorR, MS.db.global.SecondaryFontColorG, MS.db.global.SecondaryFontColorB)
            for _, line in ipairs(raids) do
                GameTooltip:AddLine(line, 1, 1, 1)
            end
            GameTooltip:AddLine(" ")
        end
    end
    local function GetMythicPlusInformation()
        local mythicRuns = C_MythicPlus.GetRunHistory(false, true)
        local PrimaryFontColor = string.format("%02x%02x%02x", MS.db.global.PrimaryFontColorR * 255, MS.db.global.PrimaryFontColorG * 255, MS.db.global.PrimaryFontColorB * 255)
        local formattedRuns = {}
        local MythicPlusAbbr =
        {
            -- Season 3 Dungeons
            ["Dawn of the Infinite: Galakrond's Fall"] = "DOTI: Galakrond's Fall",
            ["Dawn of the Infinite: Murozond's Rise"] = "DOTI: Murozond's Rise",
        }
        for _, run in ipairs(mythicRuns) do
            local name = C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID)
            local abbrName = MythicPlusAbbr[name] or name
            table.insert(formattedRuns, string.format("%s [%d]", abbrName, run.level))
        end
        table.sort(formattedRuns, function(a, b)
            return tonumber(a:match("%d+")) > tonumber(b:match("%d+"))
        end)
        for i = 9, #formattedRuns do
            formattedRuns[i] = nil
        end
        if #formattedRuns > 0 then
            local r, g, b = MS.db.global.SecondaryFontColorR, MS.db.global.SecondaryFontColorG, MS.db.global.SecondaryFontColorB
            GameTooltip:AddLine("Mythic+ Runs", r, g, b)
            for number, line in ipairs(formattedRuns) do
                if number == 1 or number == 4 or number == 8 then
                    GameTooltip:AddLine(line, 255/255, 204/255, 0/255)
                else
                    GameTooltip:AddLine(line, 1, 1, 1)
                end
            end
            GameTooltip:AddLine(" ")
        end
    end
    local function GetPlayerKeystone()
        if not OR then 
            print(AddOnName.. ": OpenRaid was not found. This comes pre-installed with Details/Echo Raid Tools.")
            return 
        end
        local ORLibrary = OR.GetKeystoneInfo("player")
        local playerKeystoneLevel = ORLibrary.level
        local playerKeystone, _, _, keystoneIcon = C_ChallengeMode.GetMapUIInfo(ORLibrary.mythicPlusMapID)
        if playerKeystone ~= nil then
            local texturedIcon = "|T" .. keystoneIcon .. ":18:18:0|t "
            GameTooltip:AddDoubleLine("Your Keystone", texturedIcon .. playerKeystone .. " [" .. playerKeystoneLevel .. "]", MS.db.global.SecondaryFontColorR, MS.db.global.SecondaryFontColorG, MS.db.global.SecondaryFontColorB, 1, 1, 1)
        end
    end
    function MS:FetchTooltipInformation()
        GameTooltip:SetOwner(InformationFrame, "ANCHOR_BOTTOM", 0, 0)
        GetDungeonandRaidLockouts()
        GetMythicPlusInformation()
        GetPlayerKeystone()
        GameTooltip:Show()
    end
    function MS:FetchInstanceDifficulty()
        if MS.db.global.DisplayInstanceDifficulty then
            local _, _, InstanceDifficulty, _, _, _, _, InstanceID, InstanceSize = GetInstanceInfo()
            local KeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
            local InstanceDifficultyIndicator = MinimapCluster.InstanceDifficulty
            local InstanceIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Instance or _G["MiniMapInstanceDifficulty"]
            local GuildIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Guild or _G["GuildInstanceDifficulty"]
            local ChallengeIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.ChallengeMode or _G["MiniMapChallengeMode"]
            local InGarrison = InstanceID == 1152 or InstanceID == 1153 or InstanceID == 1154 or InstanceID == 1158 or InstanceID == 1159 or InstanceID == 1160
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
                local TestInstances = { NormalDungeon, HeroicDungeon, MythicDungeon, TenNormalRaid, TwentyFiveNormalRaid, TenHeroicRaid, TwentyFiveHeroicRaid, FortyRaid, MythicRaid }
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
            if InstanceDifficulty == 0 then      -- No Instance
                return " "
            elseif InGarrison then               -- Garrison
                return " "
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
    end
    function MS:FetchCoordinates()
        if MS.db.global.DisplayCoordinates then
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
                    if MS.db.global.CoordinatesFormat == "NoDecimal" then
                        return NoDecimals
                    elseif MS.db.global.CoordinatesFormat == "OneDecimal" then
                        return OneDecimal
                    elseif MS.db.global.CoordinatesFormat == "TwoDecimal" then
                        return TwoDecimals
                    end
                else
                    return " "
                end
            end
        end
    end
    function MS:SetScripts()
        if MS.db.global.DisplayTime then
            TimeFrame:SetScript("OnUpdate", UpdateTimeFrame)
            if MS.db.global.DisplayDate then
                TimeFrame:SetScript("OnEnter", function() TimeFrameText:SetText(MS:FetchDate()) TimeFrame:SetScript("OnUpdate", nil) end)
                TimeFrame:SetScript("OnLeave", function() TimeFrameText:SetText(MS:FetchTime()) TimeFrame:SetScript("OnUpdate", UpdateTimeFrame) end)
            else
                TimeFrame:SetScript("OnEnter", nil)
                TimeFrame:SetScript("OnLeave", nil)
            end
            TimeFrame:SetScript("OnMouseDown", function(self, button) if button == "LeftButton" then ToggleCalendar() end end)
        else
            TimeFrame:SetScript("OnUpdate", nil)
            TimeFrame:SetScript("OnMouseDown", nil)
        end
        if MS.db.global.DisplayLocation then
            LocationFrame:SetScript("OnEvent", UpdateLocationFrame)
        else
            LocationFrame:SetScript("OnEvent", nil)
        end
        if MS.db.global.DisplayInformation then
            InformationFrame:SetScript("OnUpdate", UpdateInformationFrame)
            InformationFrame:SetScript("OnMouseDown", function(self, button) if button == "MiddleButton" then ReloadUI() elseif button == "RightButton" then if MSGUIShown == false then MS:RunMSGUI() else return end elseif button == "LeftButton" then collectgarbage("collect") print(AddOnName.. ": Garbage Collected!") end end)
            if MS.db.global.DisplayTooltipInformation then
                InformationFrame:SetScript("OnEnter", function() MS:FetchTooltipInformation() end)
                InformationFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            else
                InformationFrame:SetScript("OnEnter", nil)
                InformationFrame:SetScript("OnLeave", nil)
            end
        else
            InformationFrame:SetScript("OnUpdate", nil)
            InformationFrame:SetScript("OnMouseDown", nil)
            InformationFrame:SetScript("OnEnter", nil)
            InformationFrame:SetScript("OnLeave", nil)
        end
        if MS.db.global.DisplayInstanceDifficulty then
            InstanceDifficultyFrame:SetScript("OnEvent", UpdateInstanceDifficultyFrame)
            if TestingInstanceDifficulty == true then
                InstanceDifficultyFrame:SetScript("OnUpdate", TestInstanceDifficultyFrame)
            else
                InstanceDifficultyFrame:SetScript("OnUpdate", nil)
            end
        else
            InstanceDifficultyFrame:SetScript("OnEvent", nil)
        end
        if MS.db.global.DisplayCoordinates then
            CoordinatesFrame:SetScript("OnUpdate", UpdateCoordinatesFrame)
        else
            CoordinatesFrame:SetScript("OnUpdate", nil)
        end
    end
    function MS:RefreshTimeElement()
        TimeFrameText:SetText(MS:FetchTime())
        TimeFrameText:SetFont(MS.db.global.Font, MS.db.global.TimeFrameFontSize, MS.db.global.FontOutline)
        TimeFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        TimeFrameText:ClearAllPoints()
        TimeFrameText:SetPoint(MS.db.global.TimeFrameAnchorFrom, TimeFrame, MS.db.global.TimeFrameAnchorTo, 0, 0)
        TimeFrame:SetHeight(TimeFrameText:GetStringHeight() or 24)
        TimeFrame:SetWidth(TimeFrameText:GetStringWidth() or 200)
        TimeFrame:ClearAllPoints()
        TimeFrame:SetPoint(MS.db.global.TimeFrameAnchorFrom, Minimap, MS.db.global.TimeFrameAnchorTo, MS.db.global.TimeFrameXOffset, MS.db.global.TimeFrameYOffset)
        TimeFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
        if MS.db.global.DisplayTime then
            TimeFrame:SetScript("OnUpdate", UpdateTimeFrame)
            if MS.db.global.DisplayDate then
                TimeFrame:SetScript("OnEnter", function() TimeFrameText:SetText(MS:FetchDate()) TimeFrame:SetScript("OnUpdate", nil) end)
                TimeFrame:SetScript("OnLeave", function() TimeFrameText:SetText(MS:FetchTime()) TimeFrame:SetScript("OnUpdate", UpdateTimeFrame) end)
            else
                TimeFrame:SetScript("OnEnter", nil)
                TimeFrame:SetScript("OnLeave", nil)
            end
            TimeFrame:SetScript("OnMouseDown", function(self, button) if button == "LeftButton" then ToggleCalendar() end end)
        else
            TimeFrame:SetScript("OnUpdate", nil)
            TimeFrame:SetScript("OnMouseDown", nil)
        end
    end
    function MS:RefreshLocationElement()
        LocationFrameText:SetText(MS:FetchLocation())
        LocationFrameText:SetFont(MS.db.global.Font, MS.db.global.LocationFrameFontSize, MS.db.global.FontOutline)
        LocationFrameText:ClearAllPoints()
        LocationFrameText:SetPoint(MS.db.global.LocationFrameAnchorFrom, LocationFrame, MS.db.global.LocationFrameAnchorTo, 0, 0)
        LocationFrame:SetHeight(LocationFrameText:GetStringHeight() or 24)
        LocationFrame:SetWidth(LocationFrameText:GetStringWidth() or 200)
        LocationFrame:ClearAllPoints()
        LocationFrame:SetPoint(MS.db.global.LocationFrameAnchorFrom, Minimap, MS.db.global.LocationFrameAnchorTo, MS.db.global.LocationFrameXOffset, MS.db.global.LocationFrameYOffset)
        LocationFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
        if MS.db.global.DisplayLocation then
            LocationFrame:SetScript("OnEvent", UpdateLocationFrame)
        else
            LocationFrame:SetScript("OnEvent", nil)
        end
    end
    function MS:RefreshInformationElement()
        InformationFrameText:SetText(MS:FetchInformation())
        InformationFrameText:SetFont(MS.db.global.Font, MS.db.global.InformationFrameFontSize, MS.db.global.FontOutline)
        InformationFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        InformationFrameText:ClearAllPoints()
        InformationFrameText:SetPoint(MS.db.global.InformationFrameAnchorFrom, InformationFrame, MS.db.global.InformationFrameAnchorTo, 0, 0)
        InformationFrame:SetHeight(InformationFrameText:GetStringHeight() or 24)
        InformationFrame:SetWidth(InformationFrameText:GetStringWidth() or 200)
        InformationFrame:ClearAllPoints()
        InformationFrame:SetPoint(MS.db.global.InformationFrameAnchorFrom, Minimap, MS.db.global.InformationFrameAnchorTo, MS.db.global.InformationFrameXOffset, MS.db.global.InformationFrameYOffset)
        InformationFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
        if MS.db.global.DisplayInformation then
            InformationFrame:SetScript("OnUpdate", UpdateInformationFrame)
            InformationFrame:SetScript("OnMouseDown", function(self, button) if button == "MiddleButton" then ReloadUI() elseif button == "RightButton" then if MSGUIShown == false then MS:RunMSGUI() else return end elseif button == "LeftButton" then collectgarbage("collect") print(AddOnName.. ": Garbage Collected!") end end)
            if MS.db.global.DisplayTooltipInformation then
                InformationFrame:SetScript("OnEnter", function() MS:FetchTooltipInformation() end)
                InformationFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            else
                InformationFrame:SetScript("OnEnter", nil)
                InformationFrame:SetScript("OnLeave", nil)
            end
        else
            InformationFrame:SetScript("OnUpdate", nil)
            InformationFrame:SetScript("OnMouseDown", nil)
            InformationFrame:SetScript("OnEnter", nil)
            InformationFrame:SetScript("OnLeave", nil)
        end
    end
    function MS:RefreshInstanceDifficultyElement()
        InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        InstanceDifficultyFrameText:SetFont(MS.db.global.Font, MS.db.global.InstanceDifficultyFrameFontSize, MS.db.global.FontOutline)
        InstanceDifficultyFrameText:ClearAllPoints()
        InstanceDifficultyFrameText:SetPoint(MS.db.global.InstanceDifficultyFrameAnchorFrom, InstanceDifficultyFrame, MS.db.global.InstanceDifficultyFrameAnchorTo, 0, 0)
        InstanceDifficultyFrame:SetHeight(InstanceDifficultyFrameText:GetStringHeight() or 24)
        InstanceDifficultyFrame:SetWidth(InstanceDifficultyFrameText:GetStringWidth() or 200)
        InstanceDifficultyFrame:ClearAllPoints()
        InstanceDifficultyFrame:SetPoint(MS.db.global.InstanceDifficultyFrameAnchorFrom, Minimap, MS.db.global.InstanceDifficultyFrameAnchorTo, MS.db.global.InstanceDifficultyFrameXOffset, MS.db.global.InstanceDifficultyFrameYOffset)
        InstanceDifficultyFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
        if MS.db.global.DisplayInstanceDifficulty then
            InstanceDifficultyFrame:SetScript("OnEvent", UpdateInstanceDifficultyFrame)
            if TestingInstanceDifficulty == true then
                InstanceDifficultyFrame:SetScript("OnUpdate", TestInstanceDifficultyFrame)
            else
                InstanceDifficultyFrame:SetScript("OnUpdate", nil)
            end
        else
            InstanceDifficultyFrame:SetScript("OnEvent", nil)
        end
    end
    function MS:RefreshCoordinatesElement()
        CoordinatesFrameText:SetText(MS:FetchCoordinates())
        CoordinatesFrameText:SetFont(MS.db.global.Font, MS.db.global.CoordinatesFrameFontSize, MS.db.global.FontOutline)
        CoordinatesFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        CoordinatesFrameText:ClearAllPoints()
        CoordinatesFrameText:SetPoint(MS.db.global.CoordinatesFrameAnchorFrom, CoordinatesFrame, MS.db.global.CoordinatesFrameAnchorTo, 0, 0)
        CoordinatesFrame:SetHeight(CoordinatesFrameText:GetStringHeight() or 24)
        CoordinatesFrame:SetWidth(CoordinatesFrameText:GetStringWidth() or 200)
        CoordinatesFrame:ClearAllPoints()
        CoordinatesFrame:SetPoint(MS.db.global.CoordinatesFrameAnchorFrom, Minimap, MS.db.global.CoordinatesFrameAnchorTo, MS.db.global.CoordinatesFrameXOffset, MS.db.global.CoordinatesFrameYOffset)
        CoordinatesFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
        if MS.db.global.DisplayCoordinates then
            CoordinatesFrame:SetScript("OnUpdate", UpdateCoordinatesFrame)
        else
            CoordinatesFrame:SetScript("OnUpdate", nil)
        end
    end
    function MS:RefreshElements()
        if MS.db.global.UseClassColours then
            MS.db.global.SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
            MS.db.global.SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
            MS.db.global.SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
        end
        SecondaryFontColorRGB = { r = MS.db.global.SecondaryFontColorR, g = MS.db.global.SecondaryFontColorG, b = MS.db.global.SecondaryFontColorB }
        SecondaryFontColor = string.format("%02x%02x%02x", SecondaryFontColorRGB.r * 255, SecondaryFontColorRGB.g * 255, SecondaryFontColorRGB.b * 255)
        TimeFrameText:SetText(MS:FetchTime())
        LocationFrameText:SetText(MS:FetchLocation())
        InformationFrameText:SetText(MS:FetchInformation())
        InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        CoordinatesFrameText:SetText(MS:FetchCoordinates())
        TimeFrameText:SetFont(MS.db.global.Font, MS.db.global.TimeFrameFontSize, MS.db.global.FontOutline)
        LocationFrameText:SetFont(MS.db.global.Font, MS.db.global.LocationFrameFontSize, MS.db.global.FontOutline)
        InformationFrameText:SetFont(MS.db.global.Font, MS.db.global.InformationFrameFontSize, MS.db.global.FontOutline)
        InstanceDifficultyFrameText:SetFont(MS.db.global.Font, MS.db.global.InstanceDifficultyFrameFontSize, MS.db.global.FontOutline)
        CoordinatesFrameText:SetFont(MS.db.global.Font, MS.db.global.CoordinatesFrameFontSize, MS.db.global.FontOutline)
        TimeFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        InformationFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        CoordinatesFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
    end
    function MS:RefreshAllElements()
        MS:RefreshTimeElement()
        MS:RefreshLocationElement()
        MS:RefreshInformationElement()
        MS:RefreshInstanceDifficultyElement()
        MS:RefreshCoordinatesElement()
        MS:RefreshElements()
        MS:SetScripts()
    end
    function MS:SetupTimeFrame()
        TimeFrame = CreateFrame("Frame", "TimeFrame", Minimap)
        TimeFrame:ClearAllPoints()
        TimeFrame:SetPoint(MS.db.global.TimeFrameAnchorFrom, Minimap, MS.db.global.TimeFrameAnchorTo, MS.db.global.TimeFrameXOffset, MS.db.global.TimeFrameYOffset)
        TimeFrameText = TimeFrame:CreateFontString("TimeFrameText", "BACKGROUND")
        TimeFrameText:ClearAllPoints()
        TimeFrameText:SetPoint(MS.db.global.TimeFrameAnchorFrom, TimeFrame, MS.db.global.TimeFrameAnchorTo, 0, 0)
        TimeFrameText:SetFont(MS.db.global.Font, MS.db.global.TimeFrameFontSize, MS.db.global.FontOutline)
        TimeFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        TimeFrameText:SetText(MS:FetchTime())
        TimeFrame:SetHeight(TimeFrameText:GetStringHeight() or 24)
        TimeFrame:SetWidth(TimeFrameText:GetStringWidth() or 200)
        TimeFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
    end
    function MS:SetupLocationFrame()
        LocationFrame = CreateFrame("Frame", "LocationFrame", Minimap)
        LocationFrame:ClearAllPoints()
        LocationFrame:SetPoint(MS.db.global.LocationFrameAnchorFrom, Minimap, MS.db.global.LocationFrameAnchorTo, MS.db.global.LocationFrameXOffset, MS.db.global.LocationFrameYOffset)
        LocationFrameText = LocationFrame:CreateFontString("LocationFrameText", "BACKGROUND")
        LocationFrameText:ClearAllPoints()
        LocationFrameText:SetPoint(MS.db.global.LocationFrameAnchorFrom, LocationFrame, MS.db.global.LocationFrameAnchorTo, 0, 0)
        LocationFrameText:SetFont(MS.db.global.Font, MS.db.global.LocationFrameFontSize, MS.db.global.FontOutline)
        LocationFrameText:SetText(MS:FetchLocation())
        LocationFrameText:SetWidth(Minimap:GetWidth() * 80 / 100)
        LocationFrameText:CanWordWrap()
        LocationFrame:SetHeight(LocationFrameText:GetStringHeight() or 24)
        LocationFrame:SetWidth(LocationFrameText:GetStringWidth() or 200)
        LocationFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
        LocationFrame:RegisterEvent("ZONE_CHANGED")
        LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        LocationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
    function MS:SetupInformationFrame()
        InformationFrame = CreateFrame("Frame", "InformationFrame", Minimap)
        InformationFrame:ClearAllPoints()
        InformationFrame:SetPoint(MS.db.global.InformationFrameAnchorFrom, Minimap, MS.db.global .InformationFrameAnchorTo, MS.db.global.InformationFrameXOffset, MS.db.global.InformationFrameYOffset)
        InformationFrameText = InformationFrame:CreateFontString("InformationFrameText", "BACKGROUND")
        InformationFrameText:ClearAllPoints()
        InformationFrameText:SetPoint(MS.db.global.InformationFrameAnchorFrom, InformationFrame, MS.db.global.InformationFrameAnchorTo, 0, 0)
        InformationFrameText:SetFont(MS.db.global.Font, MS.db.global.InformationFrameFontSize, MS.db.global .FontOutline)
        InformationFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        InformationFrameText:SetText(MS:FetchInformation())
        InformationFrame:SetHeight(InformationFrameText:GetStringHeight() or 24)
        InformationFrame:SetWidth(InformationFrameText:GetStringWidth() or 200)
        InformationFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
    end
    function MS:SetupInstanceDifficultyFrame()
        InstanceDifficultyFrame = CreateFrame("Frame", "InstanceDifficultyFrame", Minimap)
        InstanceDifficultyFrame:ClearAllPoints()
        InstanceDifficultyFrame:SetPoint(MS.db.global.InstanceDifficultyFrameAnchorFrom, Minimap, MS.db.global.InstanceDifficultyFrameAnchorTo, MS.db.global.InstanceDifficultyFrameXOffset, MS.db.global.InstanceDifficultyFrameYOffset)
        InstanceDifficultyFrameText = InstanceDifficultyFrame:CreateFontString("InstanceDifficultyFrameText", "BACKGROUND")
        InstanceDifficultyFrameText:ClearAllPoints()
        InstanceDifficultyFrameText:SetPoint(MS.db.global.InstanceDifficultyFrameAnchorFrom, InstanceDifficultyFrame, MS.db.global.InstanceDifficultyFrameAnchorTo, 0, 0)
        InstanceDifficultyFrameText:SetFont(MS.db.global.Font, MS.db.global.InstanceDifficultyFrameFontSize, MS.db.global.FontOutline)
        InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        InstanceDifficultyFrame:SetHeight(InstanceDifficultyFrameText:GetStringHeight() or 24)
        InstanceDifficultyFrame:SetWidth(InstanceDifficultyFrameText:GetStringWidth() or 200)
        InstanceDifficultyFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
        InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
        InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        InstanceDifficultyFrame:RegisterEvent("WORLD_STATE_TIMER_START")
    end
    function MS:SetupCoordinatesFrame()
        CoordinatesFrame = CreateFrame("Frame", "CoordinatesFrame", Minimap)
        CoordinatesFrame:ClearAllPoints()
        CoordinatesFrame:SetPoint(MS.db.global.CoordinatesFrameAnchorFrom, Minimap, MS.db.global .CoordinatesFrameAnchorTo, MS.db.global.CoordinatesFrameXOffset, MS.db.global.CoordinatesFrameYOffset)
        CoordinatesFrameText = CoordinatesFrame:CreateFontString("CoordinatesFrameText", "BACKGROUND")
        CoordinatesFrameText:ClearAllPoints()
        CoordinatesFrameText:SetPoint(MS.db.global.CoordinatesFrameAnchorFrom, CoordinatesFrame, MS.db.global.CoordinatesFrameAnchorTo, 0, 0)
        CoordinatesFrameText:SetFont(MS.db.global.Font, MS.db.global.CoordinatesFrameFontSize, MS.db.global .FontOutline)
        CoordinatesFrameText:SetTextColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
        CoordinatesFrameText:SetText(MS:FetchCoordinates())
        CoordinatesFrame:SetHeight(CoordinatesFrameText:GetStringHeight() or 24)
        CoordinatesFrame:SetWidth(CoordinatesFrameText:GetStringWidth() or 200)
        CoordinatesFrame:SetFrameStrata(MS.db.global.ElementFrameStrata)
    end
end
function MinimapStats:OnEnable()
    local MinimapStats = CreateFrame("Frame")
    MinimapStats:RegisterEvent("PLAYER_LOGIN")
    MS:SetupTimeFrame()
    MS:SetupLocationFrame()
    MS:SetupInformationFrame()
    MS:SetupInstanceDifficultyFrame()
    MS:SetupCoordinatesFrame()
    local TimeFrame_LastUpdate = 0
    local InformationFrame_LastUpdate = 0
    local CoordinatesFrame_LastUpdate = 0
    local InstanceDifficultyFrame_LastUpdate = 0
    function UpdateTimeFrame(TimeFrame, ElapsedTime)
        TimeFrame_LastUpdate = TimeFrame_LastUpdate + ElapsedTime
        if TimeFrame_LastUpdate > MS.db.global.TimeFrame_UpdateFrequency then
            if DebugMode then
                print(AddOnName .. ": Time Frame: Updated")
            end
            TimeFrame_LastUpdate = 0
            TimeFrameText:SetText(MS:FetchTime())
        end
    end
    function UpdateLocationFrame(LocationFrame, FrameEvent)
        if FrameEvent == "ZONE_CHANGED" or FrameEvent == "ZONE_CHANGED_INDOORS" or FrameEvent == "ZONE_CHANGED_NEW_AREA" or FrameEvent == "PLAYER_ENTERING_WORLD" then
            LocationFrameText:SetText(MS:FetchLocation())
        end
    end
    function UpdateInformationFrame(InformationFrame, ElapsedTime)
        if MS.db.global.UpdateInRealTime then
            if DebugMode then
                print(AddOnName .. ": Information Frame: Updated")
            end
            InformationFrameText:SetText(MS:FetchInformation())
        else
            InformationFrame_LastUpdate = InformationFrame_LastUpdate + ElapsedTime
            if InformationFrame_LastUpdate > MS.db.global.InformationFrame_UpdateFrequency then
                if DebugMode then
                    print(AddOnName .. ": Information Frame: Updated")
                end
                InformationFrame_LastUpdate = 0
                InformationFrameText:SetText(MS:FetchInformation())
            end
        end
    end
    function UpdateCoordinatesFrame(CoordinatesFrame, ElapsedTime)
        CoordinatesFrame_LastUpdate = CoordinatesFrame_LastUpdate + ElapsedTime
        if CoordinatesFrame_LastUpdate > MS.db.global.CoordinatesFrame_UpdateFrequency then
            if DebugMode then
                print(AddOnName .. ": Coordinates Frame: Updated")
            end
            CoordinatesFrame_LastUpdate = 0
            CoordinatesFrameText:SetText(MS:FetchCoordinates())
        end
    end
    function UpdateInstanceDifficultyFrame(InstanceDifficultyFrame, FrameEvent)
        if FrameEvent == "ZONE_CHANGED" or FrameEvent == "ZONE_CHANGED_INDOORS" or FrameEvent == "ZONE_CHANGED_NEW_AREA" or FrameEvent == "PLAYER_ENTERING_WORLD" or FrameEvent == "GROUP_ROSTER_UPDATE" or FrameEvent == "WORLD_STATE_TIME_START" then
            InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        end
    end
    function TestInstanceDifficultyFrame(InstanceDifficultyFrame, ElapsedTime)
        InstanceDifficultyFrame_LastUpdate = InstanceDifficultyFrame_LastUpdate + ElapsedTime
        if InstanceDifficultyFrame_LastUpdate > 3 then
            if DebugMode then
                print(AddOnName .. ": Instance Difficulty Frame: Updated")
            end
            InstanceDifficultyFrame_LastUpdate = 0
            InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        end
    end
    MS:SetScripts()
    function MS:ResetDefaults()
        MS.db:ResetDB()
        MS:RefreshAllElements()
        print(AddOnName .. ": Settings Reset.")
    end
    function MS:DebugModeDetection()
        if DebugMode == false then
            ToggleDebugModeButton:SetText("Debug Mode: |cFFFF4040Disabled|r")
        else
            ToggleDebugModeButton:SetText("Debug Mode: |cFF40FF40Enabled|r")
        end
    end
    function MS:ToggleDebugMode()
        if DebugMode then
            DebugMode = false
            print(AddOnName .. ": Debug Mode |cFFFF4040Disabled|r.")
        else
            DebugMode = true
            print(AddOnName .. ": Debug Mode |cFF00FF00Enabled|r.")
        end
    end
    function MS:RunMSGUI()
        local AnchorPointData = { ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left", ["RIGHT"] = "Right", ["CENTER"] = "Center", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" }
        local AnchorPointOrder = { "TOP", "TOPLEFT", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT" }
        MSGUIShown = true
        local MSGUIContainer = MSGUI:Create("Frame")
        MSGUIContainer:SetTitle(AddOnName)
        MSGUIContainer:SetStatusText("Author: |cFF8080FFUnhalted|r | Version: |cFF8080FF" .. AddOnVersion .. "|r")
        MSGUIContainer:SetCallback("OnClose", function(widget)
            MSGUI:Release(widget)
            MSGUIShown = false
        end)
        MSGUIContainer:SetLayout("Fill")
        MSGUIContainer:SetWidth(800)
        MSGUIContainer:SetHeight(900)
        MSGUIContainer:EnableResize(false)
        local function DrawTimeContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)
            local TimeToggleContainer = MSGUI:Create("InlineGroup")
            TimeToggleContainer:SetTitle("Toggle Options")
            TimeToggleContainer:SetFullWidth(true)
            local TimeFormatContainer = MSGUI:Create("InlineGroup")
            TimeFormatContainer:SetTitle("Format Options")
            TimeFormatContainer:SetFullWidth(true)
            local TimeFontSizeContainer = MSGUI:Create("InlineGroup")
            TimeFontSizeContainer:SetTitle("Font Size Options")
            TimeFontSizeContainer:SetFullWidth(true)
            local TimePositionsContainer = MSGUI:Create("InlineGroup")
            TimePositionsContainer:SetTitle("Position Options")
            TimePositionsContainer:SetFullWidth(true)
            TimePositionsContainer:SetLayout("Flow")
            local TimeMiscContainer = MSGUI:Create("InlineGroup")
            TimeMiscContainer:SetTitle("Misc Options")
            TimeMiscContainer:SetFullWidth(true)
            local DateContainer = MSGUI:Create("InlineGroup")
            DateContainer:SetTitle("Date Options")
            DateContainer:SetFullWidth(true)
            local DisplayDateOnHoverCheckBox = MSGUI:Create("CheckBox")
            DisplayDateOnHoverCheckBox:SetLabel("Display Date [Mouseover]")
            DisplayDateOnHoverCheckBox:SetFullWidth(true)
            DisplayDateOnHoverCheckBox:SetValue(MS.db.global.DisplayDate)
            DisplayDateOnHoverCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DisplayDate = value if value == false then DateFormatDropdown:SetDisabled(true) AlternativeFormatCheckBox:SetDisabled(true) else DateFormatDropdown:SetDisabled(false) AlternativeFormatCheckBox:SetDisabled(false) end MS:RefreshElements() end)
            DateContainer:AddChild(DisplayDateOnHoverCheckBox)
            AlternativeFormatCheckBox = MSGUI:Create("CheckBox")
            AlternativeFormatCheckBox:SetLabel("Alternative Format (MM/DD/YY)")
            AlternativeFormatCheckBox:SetValue(MS.db.global.AlternativeFormatting)
            AlternativeFormatCheckBox:SetFullWidth(true)
            AlternativeFormatCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.AlternativeFormatting = value MS:RefreshTimeElement() end)
            DateContainer:AddChild(AlternativeFormatCheckBox)
            DateFormatDropdown = MSGUI:Create("Dropdown")
            DateFormatDropdown:SetLabel("Date Format")
            local DateFormatDropdownData = { ["DD/MM/YY"] = "DD/MM/YY", ["FullDate"] = "01 January 2000" }
            local DateFormatDropdownOrder = { "DD/MM/YY", "FullDate" }
            DateFormatDropdown:SetList(DateFormatDropdownData, DateFormatDropdownOrder)
            DateFormatDropdown:SetValue(MS.db.global.DateFormat)
            DateFormatDropdown:SetFullWidth(true)
            DateFormatDropdown:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DateFormat = value MS:RefreshTimeElement() end)
            DateContainer:AddChild(DateFormatDropdown)
            local DisplayTimeCheckBox = MSGUI:Create("CheckBox")
            DisplayTimeCheckBox:SetLabel("Show / Hide")
            DisplayTimeCheckBox:SetValue(MS.db.global.DisplayTime)
            DisplayTimeCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DisplayTime = value MS:RefreshTimeElement() end)
            TimeToggleContainer:AddChild(DisplayTimeCheckBox)
            local TimeFormatDropdown = MSGUI:Create("Dropdown")
            TimeFormatDropdown:SetLabel("Format")
            local TimeFormatDropdownData = { ["TwentyFourHourTime"] = "24 Hour", ["TwelveHourTime"] = "12 Hour (AM/PM)", ["ServerTime"] = "24 Hour [Server Time]", ["TwelverHourServerTime"] = "12 Hour (AM/PM) [Server Time]" }
            local TimeFormatDropdownOrder = { "TwentyFourHourTime", "TwelveHourTime", "ServerTime", "TwelverHourServerTime" }
            TimeFormatDropdown:SetList(TimeFormatDropdownData, TimeFormatDropdownOrder)
            TimeFormatDropdown:SetValue(MS.db.global.TimeFormat)
            TimeFormatDropdown:SetFullWidth(true)
            TimeFormatDropdown:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.TimeFormat = value MS:RefreshTimeElement() end)
            TimeFormatContainer:AddChild(TimeFormatDropdown)
            local TimeFontSize = MSGUI:Create("Slider")
            TimeFontSize:SetLabel("Font Size")
            TimeFontSize:SetSliderValues(1, 100, 1)
            TimeFontSize:SetValue(MS.db.global.TimeFrameFontSize)
            TimeFontSize:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.TimeFrameFontSize = value MS:RefreshTimeElement() end)
            TimeFontSize:SetFullWidth(true)
            TimeFontSizeContainer:AddChild(TimeFontSize)
            local TimePositionAnchorFrom = MSGUI:Create("Dropdown")
            TimePositionAnchorFrom:SetLabel("Anchor From")
            TimePositionAnchorFrom:SetFullWidth(true)
            TimePositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            TimePositionAnchorFrom:SetValue(MS.db.global.TimeFrameAnchorFrom)
            TimePositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.TimeFrameAnchorFrom = value MS:RefreshTimeElement() end)
            local TimePositionAnchorTo = MSGUI:Create("Dropdown")
            TimePositionAnchorTo:SetLabel("Anchor To")
            TimePositionAnchorTo:SetFullWidth(true)
            TimePositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            TimePositionAnchorTo:SetValue(MS.db.global.TimeFrameAnchorFrom)
            TimePositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.TimeFrameAnchorTo = value MS:RefreshTimeElement() end)
            local TimePositionXOffset = MSGUI:Create("Slider")
            TimePositionXOffset:SetLabel("X Offset")
            TimePositionXOffset:SetFullWidth(true)
            TimePositionXOffset:SetSliderValues(-1000, 1000, 1)
            TimePositionXOffset:SetValue(MS.db.global.TimeFrameXOffset)
            TimePositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.TimeFrameXOffset = value MS:RefreshTimeElement() end)
            local TimePositionYOffset = MSGUI:Create("Slider")
            TimePositionYOffset:SetLabel("Y Offset")
            TimePositionYOffset:SetFullWidth(true)
            TimePositionYOffset:SetSliderValues(-1000, 1000, 1)
            TimePositionYOffset:SetValue(MS.db.global.TimeFrameYOffset)
            TimePositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.TimeFrameYOffset = value MS:RefreshTimeElement() end)
            local TimeUpdateFrequency = MSGUI:Create("Slider")
            TimeUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            TimeUpdateFrequency:SetFullWidth(true)
            TimeUpdateFrequency:SetSliderValues(1, 60, 1)
            TimeUpdateFrequency:SetValue(MS.db.global.TimeFrame_UpdateFrequency)
            TimeUpdateFrequency:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.TimeFrame_UpdateFrequency = value MS:RefreshTimeElement() end)
            TimeMiscContainer:AddChild(TimeUpdateFrequency)
            TimePositionsContainer:AddChild(TimePositionAnchorFrom)
            TimePositionsContainer:AddChild(TimePositionAnchorTo)
            TimePositionsContainer:AddChild(TimePositionXOffset)
            TimePositionsContainer:AddChild(TimePositionYOffset)
            MSGUIContainer:AddChild(TimeToggleContainer)
            MSGUIContainer:AddChild(TimeFormatContainer)
            MSGUIContainer:AddChild(TimeFontSizeContainer)
            MSGUIContainer:AddChild(TimePositionsContainer)
            MSGUIContainer:AddChild(DateContainer)
            MSGUIContainer:AddChild(TimeMiscContainer)
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
            DisplayLocationCheckBox:SetValue(MS.db.global.DisplayLocation)
            DisplayLocationCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DisplayLocation = value MS:RefreshLocationElement() end)
            LocationToggleContainer:AddChild(DisplayLocationCheckBox)
            local LocationFontColorSelectionDropdown = MSGUI:Create("Dropdown")
            LocationFontColorSelectionDropdown:SetLabel("Font Color")
            local LocationFontColorSelectionDropdownData = { ["Primary"] = "Primary", ["Secondary"] = "Secondary", ["Custom"] = "Custom", ["Reaction"] = "Reaction"}
            local LocationFontColorSelectionDropdownOrder = { "Primary", "Secondary", "Custom", "Reaction" }
            LocationFontColorSelectionDropdown:SetList(LocationFontColorSelectionDropdownData, LocationFontColorSelectionDropdownOrder)
            LocationFontColorSelectionDropdown:SetValue(MS.db.global.LocationFontColor)
            LocationFontColorSelectionDropdown:SetFullWidth(true)
            LocationFontColorSelectionDropdown:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.LocationFontColor = value MS:RefreshLocationElement() MSGUIContainer:ReleaseChildren() DrawLocationContainer(MSGUIContainer) end)
            LocationToggleContainer:AddChild(LocationFontColorSelectionDropdown)
            local LocationCustomColourPicker = MSGUI:Create("ColorPicker")
            LocationCustomColourPicker:SetLabel("Font Color Choice")
            LocationCustomColourPicker:SetColor(MS.db.global.LocationCustomColorR, MS.db.global.LocationCustomColorG, MS.db.global.LocationCustomColorB)
            LocationCustomColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) MS.db.global.LocationCustomColorR = r MS.db.global.LocationCustomColorG = g MS.db.global.LocationCustomColorB = b MS:RefreshLocationElement() end)
            if MS.db.global.LocationFontColor == "Custom" then
                LocationFontColorSelectionDropdown:SetValue("Custom")
                LocationCustomColourPicker:SetDisabled(false)
            else
                LocationCustomColourPicker:SetDisabled(true)
            end
            LocationToggleContainer:AddChild(LocationCustomColourPicker)
            local LocationFontSize = MSGUI:Create("Slider")
            LocationFontSize:SetLabel("Font Size")
            LocationFontSize:SetSliderValues(1, 100, 1)
            LocationFontSize:SetValue(MS.db.global.LocationFrameFontSize)
            LocationFontSize:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.LocationFrameFontSize = value MS:RefreshLocationElement() end)
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
            LocationPositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            LocationPositionAnchorFrom:SetValue(MS.db.global.LocationFrameAnchorFrom)
            LocationPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.LocationFrameAnchorFrom = value MS:RefreshLocationElement() end)
            local LocationPositionAnchorTo = MSGUI:Create("Dropdown")
            LocationPositionAnchorTo:SetLabel("Anchor To")
            LocationPositionAnchorTo:SetFullWidth(true)
            LocationPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            LocationPositionAnchorTo:SetValue(MS.db.global.LocationFrameAnchorTo)
            LocationPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.LocationFrameAnchorTo = value MS:RefreshLocationElement() end)
            local LocationPositionXOffset = MSGUI:Create("Slider")
            LocationPositionXOffset:SetLabel("X Offset")
            LocationPositionXOffset:SetFullWidth(true)
            LocationPositionXOffset:SetSliderValues(-1000, 1000, 1)
            LocationPositionXOffset:SetValue(MS.db.global.LocationFrameXOffset)
            LocationPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.LocationFrameXOffset = value MS:RefreshLocationElement() end)
            local LocationPositionYOffset = MSGUI:Create("Slider")
            LocationPositionYOffset:SetLabel("Y Offset")
            LocationPositionYOffset:SetFullWidth(true)
            LocationPositionYOffset:SetSliderValues(-1000, 1000, 1)
            LocationPositionYOffset:SetValue(MS.db.global.LocationFrameYOffset)
            LocationPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.LocationFrameYOffset = value MS:RefreshLocationElement() end)
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
            DisplayInformationCheckBox:SetValue(MS.db.global.DisplayInformation)
            DisplayInformationCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DisplayInformation = value MS:RefreshInformationElement() end)
            InformationToggleContainer:AddChild(DisplayInformationCheckBox)
            local UpdateInformationInRealTimeCheckBox = MSGUI:Create("CheckBox")
            UpdateInformationInRealTimeCheckBox:SetLabel("Real Time Update")
            UpdateInformationInRealTimeCheckBox:SetFullWidth(true)
            UpdateInformationInRealTimeCheckBox:SetValue(MS.db.global.UpdateInRealTime)
            UpdateInformationInRealTimeCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.UpdateInRealTime = value MS:RefreshInformationElement() end)
            InformationToggleContainer:AddChild(UpdateInformationInRealTimeCheckBox)
            local TooltipInformationCheckBox = MSGUI:Create("CheckBox")
            TooltipInformationCheckBox:SetLabel("Tooltip Information [Mouseover]")
            TooltipInformationCheckBox:SetFullWidth(true)
            TooltipInformationCheckBox:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            TooltipInformationCheckBox:SetValue(MS.db.global.DisplayTooltipInformation)
            TooltipInformationCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DisplayTooltipInformation = value MS:RefreshInformationElement() end)
            InformationToggleContainer:AddChild(TooltipInformationCheckBox)
            --[[local InformationFormatDropdown = MSGUI:Create("Dropdown")
            InformationFormatDropdown:SetLabel("Format")
            local InformationFormatDropdownData = {["FPS [HomeMS]"] = "FPS [HomeMS]", ["FPS [WorldMS]"] = "FPS [WorldMS]", ["FPS | HomeMS"] = "FPS | HomeMS", ["FPS | WorldMS"] = "FPS | WorldMS", ["FPS (HomeMS)"] = "FPS (HomeMS)", ["FPS (WorldMS)"] = "FPS (WorldMS)", ["FPS"] = "FPS", ["HomeMS"] = "HomeMS", ["WorldMS"] = "WorldMS", ["HomeMS [WorldMS]"] = "HomeMS [WorldMS]", ["HomeMS | WorldMS"] = "HomeMS | WorldMS", ["HomeMS (WorldMS)"] = "HomeMS (WorldMS)"}
            local InformationFormatDropdownOrder = { "FPS [HomeMS]", "FPS [WorldMS]", "FPS | HomeMS", "FPS | WorldMS", "FPS (HomeMS)", "FPS (WorldMS)", "FPS", "HomeMS", "WorldMS", "HomeMS [WorldMS]", "HomeMS | WorldMS", "HomeMS (WorldMS)" }
            InformationFormatDropdown:SetList(InformationFormatDropdownData, InformationFormatDropdownOrder)
            InformationFormatDropdown:SetValue(MS.db.global.InformationFormat)
            InformationFormatDropdown:SetFullWidth(true)
            InformationFormatDropdown:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InformationFormat = value RefreshInformationElement() end)
            InformationFormatContainer:AddChild(InformationFormatDropdown)]]
            local InformationFormatEditBox = MSGUI:Create("EditBox")
            InformationFormatEditBox:SetLabel("Format")
            InformationFormatEditBox:SetFullWidth(true)
            InformationFormatEditBox:SetText(MS.db.global.InformationFormatString)
            InformationFormatEditBox:SetCallback("OnEnterPressed", function(widget, event, value) if value:match("^%s*$") then value = "FPS [HomeMS]" InformationFormatEditBox:SetText("FPS [HomeMS]") end MS.db.global.InformationFormatString = value  MS:RefreshInformationElement() InformationFormatEditBox:ClearFocus() end)
            InformationFormatContainer:AddChild(InformationFormatEditBox)
            local InformationFormatEditBoxHelp = MSGUI:Create("Label")
            InformationFormatEditBoxHelp:SetFullWidth(true)
            InformationFormatEditBoxHelp:SetText("\n|cFFFFCC00Available Tags|r\n\n|cFF00FF00FPS|r = FPS\n|cFF00FF00HomeMS|r = Home Latency\n|cFF00FF00WorldMS|r = World Latency\n|cFF00FF00DualMS|r = Home & World MS\n\nAny seperators can be used. Some common ones are: |cFF40FF40[ ]|r or |cFF40FF40( )|r or |cFF40FF40< >|r or |cFF40FF40 | |r")
            InformationFormatContainer:AddChild(InformationFormatEditBoxHelp)
            local InformationFontSize = MSGUI:Create("Slider")
            InformationFontSize:SetLabel("Font Size")
            InformationFontSize:SetSliderValues(1, 100, 1)
            InformationFontSize:SetValue(MS.db.global.InformationFrameFontSize)
            InformationFontSize:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InformationFrameFontSize = value MS:RefreshInformationElement() end)
            InformationFontSize:SetFullWidth(true)
            InformationFontSizeContainer:AddChild(InformationFontSize)
            local InformationPositionAnchorFrom = MSGUI:Create("Dropdown")
            InformationPositionAnchorFrom:SetLabel("Anchor From")
            InformationPositionAnchorFrom:SetFullWidth(true)
            InformationPositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            InformationPositionAnchorFrom:SetValue(MS.db.global.InformationFrameAnchorFrom)
            InformationPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InformationFrameAnchorFrom = value MS:RefreshInformationElement() end)
            local InformationPositionAnchorTo = MSGUI:Create("Dropdown")
            InformationPositionAnchorTo:SetLabel("Anchor To")
            InformationPositionAnchorTo:SetFullWidth(true)
            InformationPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            InformationPositionAnchorTo:SetValue(MS.db.global.InformationFrameAnchorTo)
            InformationPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InformationFrameAnchorTo = value MS:RefreshInformationElement() end)
            local InformationPositionXOffset = MSGUI:Create("Slider")
            InformationPositionXOffset:SetLabel("X Offset")
            InformationPositionXOffset:SetFullWidth(true)
            InformationPositionXOffset:SetSliderValues(-1000, 1000, 1)
            InformationPositionXOffset:SetValue(MS.db.global.InformationFrameXOffset)
            InformationPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InformationFrameXOffset = value MS:RefreshInformationElement() end)
            local InformationPositionYOffset = MSGUI:Create("Slider")
            InformationPositionYOffset:SetLabel("Y Offset")
            InformationPositionYOffset:SetFullWidth(true)
            InformationPositionYOffset:SetSliderValues(-1000, 1000, 1)
            InformationPositionYOffset:SetValue(MS.db.global.InformationFrameYOffset)
            InformationPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InformationFrameYOffset = value MS:RefreshInformationElement() end)
            local InformationUpdateFrequency = MSGUI:Create("Slider")
            InformationUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            InformationUpdateFrequency:SetFullWidth(true)
            InformationUpdateFrequency:SetSliderValues(1, 60, 1)
            InformationUpdateFrequency:SetValue(MS.db.global.InformationFrame_UpdateFrequency)
            InformationUpdateFrequency:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InformationFrame_UpdateFrequency = value MS:RefreshInformationElement() end)
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
            DisplayInstanceDifficultyCheckBox:SetValue(MS.db.global.DisplayInstanceDifficulty)
            DisplayInstanceDifficultyCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DisplayInstanceDifficulty = value MS:RefreshInstanceDifficultyElement() end)
            InstanceDifficultyToggleContainer:AddChild(DisplayInstanceDifficultyCheckBox)
            TestInstanceDifficultyCheckBox = MSGUI:Create("CheckBox")
            TestInstanceDifficultyCheckBox:SetLabel("Test Instance Difficulty")
            TestInstanceDifficultyCheckBox:SetValue(TestingInstanceDifficulty)
            TestInstanceDifficultyCheckBox:SetCallback("OnValueChanged", function(widget, event, value) TestingInstanceDifficulty = value MS:RefreshInstanceDifficultyElement() end)
            InstanceDifficultyToggleContainer:AddChild(TestInstanceDifficultyCheckBox)
            local InstanceDifficultyFontSize = MSGUI:Create("Slider")
            InstanceDifficultyFontSize:SetLabel("Font Size")
            InstanceDifficultyFontSize:SetSliderValues(1, 100, 1)
            InstanceDifficultyFontSize:SetValue(MS.db.global.InstanceDifficultyFrameFontSize)
            InstanceDifficultyFontSize:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InstanceDifficultyFrameFontSize = value MS:RefreshInstanceDifficultyElement() end)
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
            InstanceDifficultyPositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            InstanceDifficultyPositionAnchorFrom:SetValue(MS.db.global.InstanceDifficultyFrameAnchorFrom)
            InstanceDifficultyPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InstanceDifficultyFrameAnchorFrom = value MS:RefreshInstanceDifficultyElement() end)
            local InstanceDifficultyPositionAnchorTo = MSGUI:Create("Dropdown")
            InstanceDifficultyPositionAnchorTo:SetLabel("Anchor To")
            InstanceDifficultyPositionAnchorTo:SetFullWidth(true)
            InstanceDifficultyPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            InstanceDifficultyPositionAnchorTo:SetValue(MS.db.global.InstanceDifficultyFrameAnchorTo)
            InstanceDifficultyPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InstanceDifficultyFrameAnchorTo = value MS:RefreshInstanceDifficultyElement() end)
            local InstanceDifficultyPositionXOffset = MSGUI:Create("Slider")
            InstanceDifficultyPositionXOffset:SetLabel("X Offset")
            InstanceDifficultyPositionXOffset:SetFullWidth(true)
            InstanceDifficultyPositionXOffset:SetSliderValues(-1000, 1000, 1)
            InstanceDifficultyPositionXOffset:SetValue(MS.db.global.InstanceDifficultyFrameXOffset)
            InstanceDifficultyPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InstanceDifficultyFrameXOffset = value MS:RefreshInstanceDifficultyElement() end)
            local InstanceDifficultyPositionYOffset = MSGUI:Create("Slider")
            InstanceDifficultyPositionYOffset:SetLabel("Y Offset")
            InstanceDifficultyPositionYOffset:SetFullWidth(true)
            InstanceDifficultyPositionYOffset:SetSliderValues(-1000, 1000, 1)
            InstanceDifficultyPositionYOffset:SetValue(MS.db.global.InstanceDifficultyFrameYOffset)
            InstanceDifficultyPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.InstanceDifficultyFrameYOffset = value MS:RefreshInstanceDifficultyElement() end)
            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionAnchorFrom)
            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionAnchorTo)
            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionXOffset)
            InstanceDifficultyPositionsContainer:AddChild(InstanceDifficultyPositionYOffset)
        end
        local function DrawMiscellaneousContainer(MSGUIContainer)
            local GroupDesc = MSGUI:Create("Label")
            GroupDesc:SetFullWidth(true)
            MSGUIContainer:AddChild(GroupDesc)
            local ColourContainer = MSGUI:Create("InlineGroup")
            ColourContainer:SetTitle("Colour Options")
            ColourContainer:SetFullWidth(true)
            ColourContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(ColourContainer)
            local PrimaryFontColor = MSGUI:Create("ColorPicker")
            PrimaryFontColor:SetLabel("Primary Font Color")
            PrimaryFontColor:SetHasAlpha(false)
            PrimaryFontColor:SetColor(MS.db.global.PrimaryFontColorR, MS.db.global.PrimaryFontColorG, MS.db.global.PrimaryFontColorB)
            PrimaryFontColor:SetCallback("OnValueChanged", function(widget, event, r, g, b) MS.db.global.PrimaryFontColorR = r MS.db.global.PrimaryFontColorG = g MS.db.global.PrimaryFontColorB = b MS:RefreshElements() end)
            PrimaryFontColor:SetCallback("OnValueConfirmed", function(widget, event, r, g, b) MS.db.global.PrimaryFontColorR = r MS.db.global.PrimaryFontColorG = g MS.db.global.PrimaryFontColorB = b MS:RefreshElements() end)
            local SecondaryFontColor = MSGUI:Create("ColorPicker")
            SecondaryFontColor:SetLabel("Secondary Font Color")
            SecondaryFontColor:SetHasAlpha(false)
            SecondaryFontColor:SetColor(MS.db.global.SecondaryFontColorR, MS.db.global.SecondaryFontColorG, MS.db.global.SecondaryFontColorB)
            SecondaryFontColor:SetCallback("OnValueChanged", function(widget, event, r, g, b) MS.db.global.SecondaryFontColorR = r MS.db.global.SecondaryFontColorG = g MS.db.global.SecondaryFontColorB = b MS:RefreshElements() end)
            SecondaryFontColor:SetCallback("OnValueConfirmed", function(widget, event, r, g, b) MS.db.global.SecondaryFontColorR = r MS.db.global.SecondaryFontColorG = g MS.db.global.SecondaryFontColorB = b MS:RefreshElements() end)
            if MS.db.global.UseClassColours == true then
                SecondaryFontColor:SetDisabled(true)
            else
                SecondaryFontColor:SetDisabled(false)
            end
            local ClassColorCheckBox = MSGUI:Create("CheckBox")
            ClassColorCheckBox:SetLabel("Use Class Color")
            ClassColorCheckBox:SetValue(MS.db.global.UseClassColours)
            ClassColorCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.UseClassColours = value if value == true then SecondaryFontColor:SetDisabled(true) else SecondaryFontColor:SetDisabled(false) end MS:RefreshElements() end)
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
            Font:SetValue(MS.db.global.Font)
            Font:SetCallback("OnValueChanged",
                function(widget, event, FontPath)
                    MS.db.global.Font = FontPath
                    MS:RefreshElements()
                end)
            FontContainer:AddChild(Font)
            local FontOutline = MSGUI:Create("Dropdown")
            FontOutline:SetLabel("Font Outline")
            FontOutline:SetList({ ["NONE"] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline" })
            FontOutline:SetValue(MS.db.global.FontOutline)
            FontOutline:SetFullWidth(true)
            FontOutline:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.FontOutline = value MS:RefreshElements() end)
            FontContainer:AddChild(FontOutline)
            local FrameStrataContainer = MSGUI:Create("InlineGroup")
            FrameStrataContainer:SetTitle("Frame Strata Options")
            FrameStrataContainer:SetFullWidth(true)
            FrameStrataContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(FrameStrataContainer)
            local ElementFrameStrata = MSGUI:Create("Dropdown")
            ElementFrameStrata:SetLabel("Frame Strata")
            ElementFrameStrataDropdownData = { ["LOW"] = "Low", ["MEDIUM"] = "Medium", ["HIGH"] = "High"}
            ElementFrameStrataDropdownOrder = { "LOW", "MEDIUM", "HIGH" }
            ElementFrameStrata:SetList(ElementFrameStrataDropdownData, ElementFrameStrataDropdownOrder)
            ElementFrameStrata:SetValue(MS.db.global.ElementFrameStrata)
            ElementFrameStrata:SetFullWidth(true)
            ElementFrameStrata:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.ElementFrameStrata = value MS:RefreshAllElements() end)
            FrameStrataContainer:AddChild(ElementFrameStrata)
            local MiscContainer = MSGUI:Create("InlineGroup")
            MiscContainer:SetTitle("Misc Options")
            MiscContainer:SetFullWidth(true)
            MiscContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(MiscContainer)
            ToggleDebugModeButton = MSGUI:Create("Button")
            ToggleDebugModeButton:SetText(MS:DebugModeDetection())
            ToggleDebugModeButton:SetFullWidth(true)
            ToggleDebugModeButton:SetCallback("OnClick", function() MS:ToggleDebugMode() MS:DebugModeDetection() MSGUIContainer:DoLayout() end)
            MiscContainer:AddChild(ToggleDebugModeButton)
            local ResetDefaultsButton = MSGUI:Create("Button")
            ResetDefaultsButton:SetText("Reset Defaults")
            ResetDefaultsButton:SetFullWidth(true)
            ResetDefaultsButton:SetCallback("OnClick", function() MS:ResetDefaults() MSGUIContainer:ReleaseChildren() DrawMiscellaneousContainer(MSGUIContainer) end)
            MiscContainer:AddChild(ResetDefaultsButton)
            ColourContainer:AddChild(ClassColorCheckBox)
            ColourContainer:AddChild(PrimaryFontColor)
            ColourContainer:AddChild(SecondaryFontColor)
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
            DisplayCoordinatesCheckBox:SetValue(MS.db.global.DisplayCoordinates)
            DisplayCoordinatesCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.DisplayCoordinates = value MS:RefreshCoordinatesElement() MSGUIContainer:DoLayout() end)
            CoordinatesToggleContainer:AddChild(DisplayCoordinatesCheckBox)
            local CoordinatesFormatDropdown = MSGUI:Create("Dropdown")
            CoordinatesFormatDropdown:SetLabel("Format")
            CoordinatesFormatDropdown:SetList({ ["NoDecimal"] = "No Decimals [00, 00]", ["OneDecimal"] = "One Decimal [00.0, 00.0]", ["TwoDecimal"] = "Two Decimals [00.00, 00.00]" })
            CoordinatesFormatDropdown:SetValue(MS.db.global.CoordinatesFormat)
            CoordinatesFormatDropdown:SetFullWidth(true)
            CoordinatesFormatDropdown:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.CoordinatesFormat = value MS:RefreshCoordinatesElement() end)
            CoordinatesFormatContainer:AddChild(CoordinatesFormatDropdown)
            local CoordinatesFontSize = MSGUI:Create("Slider")
            CoordinatesFontSize:SetLabel("Font Size")
            CoordinatesFontSize:SetSliderValues(1, 100, 1)
            CoordinatesFontSize:SetValue(MS.db.global.CoordinatesFrameFontSize)
            CoordinatesFontSize:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.CoordinatesFrameFontSize = value MS:RefreshCoordinatesElement() end)
            CoordinatesFontSize:SetFullWidth(true)
            CoordinatesFontSizeContainer:AddChild(CoordinatesFontSize)
            local CoordinatesPositionAnchorFrom = MSGUI:Create("Dropdown")
            CoordinatesPositionAnchorFrom:SetLabel("Anchor From")
            CoordinatesPositionAnchorFrom:SetFullWidth(true)
            CoordinatesPositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            CoordinatesPositionAnchorFrom:SetValue(MS.db.global.CoordinatesFrameAnchorFrom)
            CoordinatesPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.CoordinatesFrameAnchorFrom = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionAnchorFrom)
            local CoordinatesPositionAnchorTo = MSGUI:Create("Dropdown")
            CoordinatesPositionAnchorTo:SetLabel("Anchor To")
            CoordinatesPositionAnchorTo:SetFullWidth(true)
            CoordinatesPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            CoordinatesPositionAnchorTo:SetValue(MS.db.global.CoordinatesFrameAnchorTo)
            CoordinatesPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.CoordinatesFrameAnchorTo = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionAnchorTo)
            local CoordinatesPositionXOffset = MSGUI:Create("Slider")
            CoordinatesPositionXOffset:SetLabel("X Offset")
            CoordinatesPositionXOffset:SetFullWidth(true)
            CoordinatesPositionXOffset:SetSliderValues(-1000, 1000, 1)
            CoordinatesPositionXOffset:SetValue(MS.db.global.CoordinatesFrameXOffset)
            CoordinatesPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.CoordinatesFrameXOffset = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionXOffset)
            local CoordinatesPositionYOffset = MSGUI:Create("Slider")
            CoordinatesPositionYOffset:SetLabel("Y Offset")
            CoordinatesPositionYOffset:SetFullWidth(true)
            CoordinatesPositionYOffset:SetSliderValues(-1000, 1000, 1)
            CoordinatesPositionYOffset:SetValue(MS.db.global.CoordinatesFrameYOffset)
            CoordinatesPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.CoordinatesFrameYOffset = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionYOffset)
            local CoordinatesUpdateFrequency = MSGUI:Create("Slider")
            CoordinatesUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            CoordinatesUpdateFrequency:SetFullWidth(true)
            CoordinatesUpdateFrequency:SetSliderValues(1, 60, 1)
            CoordinatesUpdateFrequency:SetValue(MS.db.global.CoordinatesFrame_UpdateFrequency)
            CoordinatesUpdateFrequency:SetCallback("OnValueChanged", function(widget, event, value) MS.db.global.CoordinatesFrame_UpdateFrequency = value MS:RefreshCoordinatesElement() end)
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
                DrawMiscellaneousContainer(MSGUIContainer)
                MS:DebugModeDetection()
            end
        end
        local SelectedTab = MSGUI:Create("TabGroup")
        SelectedTab:SetTabs({ { text = "Time", value = "tab1" }, { text = "Location", value = "tab2" }, { text = "Information", value = "tab3" }, { text = "Instance Difficulty", value = "tab4" }, { text = "Coordinates", value = "tab5" }, { text = "Miscellaneous", value = "tab6" } })
        SelectedTab:SetCallback("OnGroupSelected", GroupSelect)
        SelectedTab:SelectTab("tab1")
        MSGUIContainer:AddChild(SelectedTab)
    end
    SLASH_MINIMAPSTATS1 = "/minimapstats"
    SLASH_MINIMAPSTATS2 = "/ms"
    SlashCmdList["MINIMAPSTATS"] = function(msg) if MSGUIShown == false then MS:RunMSGUI() end end
end
