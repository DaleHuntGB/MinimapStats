local MinimapStats = LibStub("AceAddon-3.0"):NewAddon("MinimapStats")
local MSGUI = LibStub("AceGUI-3.0")
local AddOnName = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
local AddOnVersion = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
local AddOnAuthor = C_AddOns.GetAddOnMetadata("MinimapStats", "Author")
local AddOnNameVersion = AddOnName .. " [V" .. AddOnVersion .. "]"
local LSM = LibStub("LibSharedMedia-3.0")
local OR = LibStub:GetLibrary("LibOpenRaid-1.0")
local MSGUIShown = false
local PrintFrameUpdates = false
local TestingInstanceDifficulty = false
local MS = {}
local characterClassTable = {
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
        DisplayRaidDungeonLockouts = true,
        DisplayMythicPlusRuns = true,
        DisplayPlayerKeystone = true,
        DisplayPartyKeystones = true,
        DisplayAffixes = true,
        DisplayAffixDescriptions = true,
        DisplayFriendList = true,
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
        TooltipAnchorFrom = "TOPRIGHT",
        TooltipAnchorTo = "BOTTOMRIGHT",
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
        TooltipXOffset = 0,
        TooltipYOffset = -2,
    }
}
function MinimapStats:OnInitialize()
    MS.db = LibStub("AceDB-3.0"):New("MSDB", DefaultSettings)
    MSDBG = MS.db.global
    if MSDBG.UseClassColours then
        MSDBG.SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
        MSDBG.SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
        MSDBG.SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
    end
    local SecondaryFontColorRGB = { r = MSDBG.SecondaryFontColorR, g = MSDBG.SecondaryFontColorG, b = MSDBG.SecondaryFontColorB }
    local SecondaryFontColor = string.format("%02x%02x%02x", SecondaryFontColorRGB.r * 255, SecondaryFontColorRGB.g * 255, SecondaryFontColorRGB.b * 255)

    function MS:PrettyPrint(msg)
        print(AddOnNameVersion..": " .. msg)
    end
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
    
        if MSDBG.DisplayTime then
            if MSDBG.TimeFormat == "TwentyFourHourTime" then
                return TwentyFourHourTime
            elseif MSDBG.TimeFormat == "TwelveHourTime" then
                return TwelveHourTime
            elseif MSDBG.TimeFormat == "ServerTime" then
                return ServerTime
            elseif MSDBG.TimeFormat == "TwelverHourServerTime" then
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
        if MSDBG.DisplayDate then
            if MSDBG.DateFormat == "DD/MM/YY" and MSDBG.AlternativeFormatting == false then
                return string.format("%s/%s/%s", CurrentDate, CurrentMonth, CurrentYear)
            elseif MSDBG.DateFormat == "DD/MM/YY" and MSDBG.AlternativeFormatting == true then
                return string.format("%s/%s/%s", CurrentMonth, CurrentDate, CurrentYear)
            elseif MSDBG.DateFormat == "FullDate" and MSDBG.AlternativeFormatting == false then
                return string.format("%s %s %s", CurrentDate, CurrentMonthName, FullYear)
            elseif MSDBG.DateFormat == "FullDate" and MSDBG.AlternativeFormatting == true then
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
        if MSDBG.DisplayLocation then
            if MSDBG.LocationFontColor == "Primary" then
                local PrimaryFontColor = string.format("%02x%02x%02x", MSDBG.PrimaryFontColorR * 255, MSDBG.PrimaryFontColorG * 255, MSDBG.PrimaryFontColorB * 255)
                return "|cFF" .. PrimaryFontColor .. GetMinimapZoneText() .. "|r"
            elseif MSDBG.LocationFontColor == "Secondary" then
                return "|cFF" .. SecondaryFontColor .. GetMinimapZoneText() .. "|r"
            elseif MSDBG.LocationFontColor == "Custom" then
                local CustomFontColor = string.format("%02x%02x%02x", MSDBG.LocationCustomColorR * 255, MSDBG.LocationCustomColorG * 255, MSDBG.LocationCustomColorB * 255)
                return "|cFF" .. CustomFontColor .. GetMinimapZoneText() .. "|r"
            elseif MSDBG.LocationFontColor == "Reaction" then
                return "|cFF" .. LocationColor .. GetMinimapZoneText() .. "|r"
            end
        end
    end
    function MS:FetchInformation()
        if MSDBG.DisplayInformation then
            local FPS = ceil(GetFramerate())
            local _, _, HomeMS, WorldMS = GetNetStats()
            local FormatString = MSDBG.InformationFormatString;
            local FPSText = FPS .. "|cFF" .. SecondaryFontColor .. " FPS" .. "|r"
            local HomeMSText = HomeMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            local WorldMSText = WorldMS .. "|cFF" .. SecondaryFontColor .. " MS" .. "|r"
            local KeyCodes = { ["FPS"] = FPSText, ["HomeMS"] = HomeMSText, ["WorldMS"] = WorldMSText, ["DualMS"] = HomeMSText .. " " .. WorldMSText}
            for KeyCode, value in pairs(KeyCodes) do
                FormatString = FormatString:gsub(KeyCode, value)
            end
            return FormatString
        end
    end
    local function GetDungeonandRaidLockouts()
        RequestRaidInfo()
        local dungeons = {}
        local raids = {}
        if not MSDBG.DisplayRaidDungeonLockouts then return end
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
            GameTooltip:AddLine("Dungeons", MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB)
            for _, line in ipairs(dungeons) do
                GameTooltip:AddLine(line, 1, 1, 1)
            end
            if MSDBG.DisplayMythicPlusRuns or MSDBG.DisplayPlayerKeystone or MSDBG.DisplayPartyKeystones or MSDBG.DisplayAffixes or MSDBG.DisplayFriendList or #raids > 0 then
                GameTooltip:AddLine(" ")
            end
        end
        if #raids > 0 then
            GameTooltip:AddLine("Raids", MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB)
            for _, line in ipairs(raids) do
                GameTooltip:AddLine(line, 1, 1, 1)
            end
            if MSDBG.DisplayMythicPlusRuns or MSDBG.DisplayPlayerKeystone or MSDBG.DisplayPartyKeystones or MSDBG.DisplayAffixes or MSDBG.DisplayFriendList then
                GameTooltip:AddLine(" ")
            end
        end
    end
    local function GetMythicPlusInformation()
        if not MSDBG.DisplayMythicPlusRuns then return end
        local mythicRuns = C_MythicPlus.GetRunHistory(false, true)
        local PrimaryFontColor = string.format("%02x%02x%02x", MSDBG.PrimaryFontColorR * 255, MSDBG.PrimaryFontColorG * 255, MSDBG.PrimaryFontColorB * 255)
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
            local r, g, b = MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB
            GameTooltip:AddLine("Mythic+ Runs", r, g, b)
            for number, line in ipairs(formattedRuns) do
                if number == 1 or number == 4 or number == 8 then
                    GameTooltip:AddLine(line, 255/255, 204/255, 0/255)
                else
                    GameTooltip:AddLine(line, 1, 1, 1)
                end
            end
            if MSDBG.DisplayPlayerKeystone or MSDBG.DisplayPartyKeystones or MSDBG.DisplayAffixes or MSDBG.DisplayFriendList then
                GameTooltip:AddLine(" ")
            end
        end
    end
    local function GetPlayerKeystone()
        if not MSDBG.DisplayPlayerKeystone then return end
        if not OR then 
            MS:PrettyPrint("OpenRaid was not found. This comes pre-installed with Details/Echo Raid Tools.")
            return 
        end
        GameTooltip:AddLine("Your Keystone", MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB)
        local ORLibrary = OR.GetKeystoneInfo("player")
        local playerKeystoneLevel = ORLibrary.level
        local playerKeystone, _, _, keystoneIcon = C_ChallengeMode.GetMapUIInfo(ORLibrary.mythicPlusMapID)
        if playerKeystone and keystoneIcon then
            local texturedIcon = "|T" .. keystoneIcon .. ":16:16:0|t "
            GameTooltip:AddLine(texturedIcon .. playerKeystone .. " [" .. playerKeystoneLevel .. "]", 1, 1, 1)
        else
            GameTooltip:AddLine("No Keystone", 1, 1, 1)
        end
        if (MSDBG.DisplayPartyKeystones and IsInGroup()) or MSDBG.DisplayAffixes or MSDBG.DisplayFriendList then
            GameTooltip:AddLine(" ")
        end
    end
    local function GetPartyKeystones()
        if not MSDBG.DisplayPartyKeystones then return end
        if not OR then
            MS:PrettyPrint("OpenRaid was not found. This comes pre-installed with Details/Echo Raid Tools.")
            return
        end
    
        local partyMembers = {}
    
        if IsInGroup() and not IsInRaid() then
            GameTooltip:AddLine("Party Keystones", MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB)
            for i = 1, GetNumGroupMembers() - 1 do
                local unit = "party" .. i
                local name = GetUnitName(unit, true)
                if name then
                    table.insert(partyMembers, unit)
                end
            end
            for _, unit in ipairs(partyMembers) do
                local name = GetUnitName(unit, true)
                local nameServerless = name:gsub("-%w+", "")
                local _, class = UnitClass(unit)
                local classColor = RAID_CLASS_COLORS[class]
                local keystoneInfo = OR.GetKeystoneInfo(name)
        
                if keystoneInfo and keystoneInfo.level then
                    local keystoneName, _, _, keystoneIcon = C_ChallengeMode.GetMapUIInfo(keystoneInfo.mythicPlusMapID)
                    local keystoneLevel = keystoneInfo.level
                    local texturedIcon = "|T" .. keystoneIcon .. ":16:16:0|t "
                    GameTooltip:AddLine(nameServerless .. ": " .. "|cFFFFFFFF".. texturedIcon.. keystoneName .. " [" .. keystoneLevel .. "]|r" , classColor.r, classColor.g, classColor.b)
                else
                    GameTooltip:AddLine(nameServerless .. ": " .. "|cFFFFFFFFNo Keystone|r" , classColor.r, classColor.g, classColor.b)
                end
            end
            if MSDBG.DisplayAffixes or MSDBG.DisplayFriendList then
                GameTooltip:AddLine(" ")
            end
        end
    end
    
    local function GetAffixInfo()
        if not MSDBG.DisplayAffixes then return end
        GameTooltip:AddLine("Current Affixes", MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB)
        for i = 1, 3 do
            local affixID = C_MythicPlus.GetCurrentAffixes()[i].id
            local affixName, affixDesc, affixIconID = C_ChallengeMode.GetAffixInfo(affixID)
            local affixIcon = "|T" .. affixIconID .. ":16:16:0|t "
            if i == 1 then
                GameTooltip:AddLine(affixIcon ..affixName, 1, 1, 1)
                if MSDBG.DisplayAffixDescriptions then
                    GameTooltip:AddLine(affixDesc, 1, 1, 1)
                end
            elseif i == 2 then
                GameTooltip:AddLine(affixIcon ..affixName, 1, 1, 1)
                if MSDBG.DisplayAffixDescriptions then
                    GameTooltip:AddLine(affixDesc, 1, 1, 1)
                end
            elseif i == 3 then
                GameTooltip:AddLine(affixIcon ..affixName, 1, 1, 1)
                if MSDBG.DisplayAffixDescriptions then
                    GameTooltip:AddLine(affixDesc, 1, 1, 1)
                end
            end
        end
        if MSDBG.DisplayFriendList then
            GameTooltip:AddLine(" ")
        end
    end

    local function GetFriendListInfo()
        if not MSDBG.DisplayFriendList then return end
        GameTooltip:AddLine("Friends", MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB)
        local _, totalFriends= BNGetNumFriends()
        for i = 1, totalFriends do
            local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
            if accountInfo then
                local friendInfo = accountInfo.gameAccountInfo
                local inGame = friendInfo.clientProgram == "WoW"
                local isOnline = friendInfo.isOnline
                local isAFK = accountInfo.isAFK
                local isDND = accountInfo.isDND
                local friendBnet = accountInfo.accountName
                local characterName = friendInfo.characterName
                local characterClass = friendInfo.className
                local characterLevel = friendInfo.characterLevel
                local classColor = characterClassTable[characterClass]
                local statusColor;

                local onlineColor = string.format("%02x%02x%02x", 64, 255, 64)
                local afkColor = string.format("%02x%02x%02x", 255, 128, 64)
                local dndColor = string.format("%02x%02x%02x", 255, 64, 64)

                if inGame and characterClass ~= nil then
                    if isOnline then
                        statusColor = onlineColor
                    end
                    if isAFK then
                        statusColor = afkColor
                    end
                    if isDND then
                        statusColor = dndColor
                    end
                    GameTooltip:AddLine("|cFF"..statusColor.."• " .."|r|cFFFFFFFF"..friendBnet .. "|r: " .. classColor .. characterName .. "|r [L|cFFFFCC40" .. characterLevel .. "|r]", 1, 1, 1)
                end
            end
        end
    end
    function MS:FetchTooltipInformation()
        if InCombatLockdown() then return end
        GameTooltip:SetOwner(Minimap, "ANCHOR_NONE", 0, 0)
        GameTooltip:SetPoint(MSDBG.TooltipAnchorFrom, Minimap, MSDBG.TooltipAnchorTo, MSDBG.TooltipXOffset, MSDBG.TooltipYOffset)
        GetDungeonandRaidLockouts()
        GetMythicPlusInformation()
        GetPlayerKeystone()
        GetPartyKeystones()
        GetAffixInfo()
        GetFriendListInfo()
        GameTooltip:Show()
    end
    function MS:FetchInstanceDifficulty()
        if MSDBG.DisplayInstanceDifficulty then
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
        if MSDBG.DisplayCoordinates then
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
                    if MSDBG.CoordinatesFormat == "NoDecimal" then
                        return NoDecimals
                    elseif MSDBG.CoordinatesFormat == "OneDecimal" then
                        return OneDecimal
                    elseif MSDBG.CoordinatesFormat == "TwoDecimal" then
                        return TwoDecimals
                    end
                else
                    return " "
                end
            end
        end
    end
    function MS:SetScripts()
        if MSDBG.DisplayTime then
            TimeFrame:SetScript("OnUpdate", UpdateTimeFrame)
            if MSDBG.DisplayDate then
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
        if MSDBG.DisplayLocation then
            LocationFrame:SetScript("OnEvent", UpdateLocationFrame)
        else
            LocationFrame:SetScript("OnEvent", nil)
        end
        if MSDBG.DisplayInformation then
            InformationFrame:SetScript("OnUpdate", UpdateInformationFrame)
            InformationFrame:SetScript("OnMouseDown", function(self, button) if button == "MiddleButton" then ReloadUI() elseif button == "RightButton" then if MSGUIShown == false then MS:RunMSGUI() else return end elseif button == "LeftButton" then collectgarbage("collect") MS:PrettyPrint("Garbage Collected") end end)
            if MSDBG.DisplayTooltipInformation then
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
        if MSDBG.DisplayInstanceDifficulty then
            InstanceDifficultyFrame:SetScript("OnEvent", UpdateInstanceDifficultyFrame)
            if TestingInstanceDifficulty == true then
                InstanceDifficultyFrame:SetScript("OnUpdate", TestInstanceDifficultyFrame)
            else
                InstanceDifficultyFrame:SetScript("OnUpdate", nil)
            end
        else
            InstanceDifficultyFrame:SetScript("OnEvent", nil)
        end
        if MSDBG.DisplayCoordinates then
            CoordinatesFrame:SetScript("OnUpdate", UpdateCoordinatesFrame)
        else
            CoordinatesFrame:SetScript("OnUpdate", nil)
        end
    end
    function MS:RefreshTimeElement()
        TimeFrame:SetHeight(TimeFrameText:GetStringHeight() or 24)
        TimeFrame:SetWidth(TimeFrameText:GetStringWidth() or 200)
        TimeFrame:ClearAllPoints()
        TimeFrame:SetPoint(MSDBG.TimeFrameAnchorFrom, Minimap, MSDBG.TimeFrameAnchorTo, MSDBG.TimeFrameXOffset, MSDBG.TimeFrameYOffset)
        TimeFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
        TimeFrameText:SetText(MS:FetchTime())
        TimeFrameText:SetFont(MSDBG.Font, MSDBG.TimeFrameFontSize, MSDBG.FontOutline)
        TimeFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        TimeFrameText:ClearAllPoints()
        TimeFrameText:SetPoint(MSDBG.TimeFrameAnchorFrom, TimeFrame, MSDBG.TimeFrameAnchorTo, 0, 0)
        if MSDBG.DisplayTime then
            TimeFrame:SetScript("OnUpdate", UpdateTimeFrame)
            if MSDBG.DisplayDate then
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
        LocationFrame:SetHeight(LocationFrameText:GetStringHeight() or 24)
        LocationFrame:SetWidth(LocationFrameText:GetStringWidth() or 200)
        LocationFrame:ClearAllPoints()
        LocationFrame:SetPoint(MSDBG.LocationFrameAnchorFrom, Minimap, MSDBG.LocationFrameAnchorTo, MSDBG.LocationFrameXOffset, MSDBG.LocationFrameYOffset)
        LocationFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
        LocationFrameText:SetText(MS:FetchLocation())
        LocationFrameText:SetFont(MSDBG.Font, MSDBG.LocationFrameFontSize, MSDBG.FontOutline)
        LocationFrameText:ClearAllPoints()
        LocationFrameText:SetPoint(MSDBG.LocationFrameAnchorFrom, LocationFrame, MSDBG.LocationFrameAnchorTo, 0, 0)
        if MSDBG.DisplayLocation then
            LocationFrame:SetScript("OnEvent", UpdateLocationFrame)
        else
            LocationFrame:SetScript("OnEvent", nil)
        end
    end
    function MS:RefreshInformationElement()
        InformationFrame:SetHeight(InformationFrameText:GetStringHeight() or 24)
        InformationFrame:SetWidth(InformationFrameText:GetStringWidth() or 200)
        InformationFrame:ClearAllPoints()
        InformationFrame:SetPoint(MSDBG.InformationFrameAnchorFrom, Minimap, MSDBG.InformationFrameAnchorTo, MSDBG.InformationFrameXOffset, MSDBG.InformationFrameYOffset)
        InformationFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
        InformationFrameText:SetText(MS:FetchInformation())
        InformationFrameText:SetFont(MSDBG.Font, MSDBG.InformationFrameFontSize, MSDBG.FontOutline)
        InformationFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        InformationFrameText:ClearAllPoints()
        InformationFrameText:SetPoint(MSDBG.InformationFrameAnchorFrom, InformationFrame, MSDBG.InformationFrameAnchorTo, 0, 0)
        if MSDBG.DisplayInformation then
            InformationFrame:SetScript("OnUpdate", UpdateInformationFrame)
            InformationFrame:SetScript("OnMouseDown", function(self, button) if button == "MiddleButton" then ReloadUI() elseif button == "RightButton" then if MSGUIShown == false then MS:RunMSGUI() else return end elseif button == "LeftButton" then collectgarbage("collect") MS:PrettyPrint("Garbage Collected") end end)
            if MSDBG.DisplayTooltipInformation then
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
        InstanceDifficultyFrame:SetHeight(InstanceDifficultyFrameText:GetStringHeight() or 24)
        InstanceDifficultyFrame:SetWidth(InstanceDifficultyFrameText:GetStringWidth() or 200)
        InstanceDifficultyFrame:ClearAllPoints()
        InstanceDifficultyFrame:SetPoint(MSDBG.InstanceDifficultyFrameAnchorFrom, Minimap, MSDBG.InstanceDifficultyFrameAnchorTo, MSDBG.InstanceDifficultyFrameXOffset, MSDBG.InstanceDifficultyFrameYOffset)
        InstanceDifficultyFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
        InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        InstanceDifficultyFrameText:SetFont(MSDBG.Font, MSDBG.InstanceDifficultyFrameFontSize, MSDBG.FontOutline)
        InstanceDifficultyFrameText:ClearAllPoints()
        InstanceDifficultyFrameText:SetPoint(MSDBG.InstanceDifficultyFrameAnchorFrom, InstanceDifficultyFrame, MSDBG.InstanceDifficultyFrameAnchorTo, 0, 0)
        if MSDBG.DisplayInstanceDifficulty then
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
        CoordinatesFrame:SetHeight(CoordinatesFrameText:GetStringHeight() or 24)
        CoordinatesFrame:SetWidth(CoordinatesFrameText:GetStringWidth() or 200)
        CoordinatesFrame:ClearAllPoints()
        CoordinatesFrame:SetPoint(MSDBG.CoordinatesFrameAnchorFrom, Minimap, MSDBG.CoordinatesFrameAnchorTo, MSDBG.CoordinatesFrameXOffset, MSDBG.CoordinatesFrameYOffset)
        CoordinatesFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
        CoordinatesFrameText:SetText(MS:FetchCoordinates())
        CoordinatesFrameText:SetFont(MSDBG.Font, MSDBG.CoordinatesFrameFontSize, MSDBG.FontOutline)
        CoordinatesFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        CoordinatesFrameText:ClearAllPoints()
        CoordinatesFrameText:SetPoint(MSDBG.CoordinatesFrameAnchorFrom, CoordinatesFrame, MSDBG.CoordinatesFrameAnchorTo, 0, 0)
        if MSDBG.DisplayCoordinates then
            CoordinatesFrame:SetScript("OnUpdate", UpdateCoordinatesFrame)
        else
            CoordinatesFrame:SetScript("OnUpdate", nil)
        end
    end
    function MS:RefreshElements()
        if MSDBG.UseClassColours then
            MSDBG.SecondaryFontColorR = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].r
            MSDBG.SecondaryFontColorG = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].g
            MSDBG.SecondaryFontColorB = (RAID_CLASS_COLORS)[select(2, UnitClass("player"))].b
        end
        SecondaryFontColorRGB = { r = MSDBG.SecondaryFontColorR, g = MSDBG.SecondaryFontColorG, b = MSDBG.SecondaryFontColorB }
        SecondaryFontColor = string.format("%02x%02x%02x", SecondaryFontColorRGB.r * 255, SecondaryFontColorRGB.g * 255, SecondaryFontColorRGB.b * 255)
        TimeFrameText:SetText(MS:FetchTime())
        LocationFrameText:SetText(MS:FetchLocation())
        InformationFrameText:SetText(MS:FetchInformation())
        InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        CoordinatesFrameText:SetText(MS:FetchCoordinates())
        TimeFrameText:SetFont(MSDBG.Font, MSDBG.TimeFrameFontSize, MSDBG.FontOutline)
        LocationFrameText:SetFont(MSDBG.Font, MSDBG.LocationFrameFontSize, MSDBG.FontOutline)
        InformationFrameText:SetFont(MSDBG.Font, MSDBG.InformationFrameFontSize, MSDBG.FontOutline)
        InstanceDifficultyFrameText:SetFont(MSDBG.Font, MSDBG.InstanceDifficultyFrameFontSize, MSDBG.FontOutline)
        CoordinatesFrameText:SetFont(MSDBG.Font, MSDBG.CoordinatesFrameFontSize, MSDBG.FontOutline)
        TimeFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        InformationFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        CoordinatesFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
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
        TimeFrame:SetPoint(MSDBG.TimeFrameAnchorFrom, Minimap, MSDBG.TimeFrameAnchorTo, MSDBG.TimeFrameXOffset, MSDBG.TimeFrameYOffset)
        TimeFrameText = TimeFrame:CreateFontString("TimeFrameText", "BACKGROUND")
        TimeFrameText:ClearAllPoints()
        TimeFrameText:SetPoint(MSDBG.TimeFrameAnchorFrom, TimeFrame, MSDBG.TimeFrameAnchorTo, 0, 0)
        TimeFrameText:SetFont(MSDBG.Font, MSDBG.TimeFrameFontSize, MSDBG.FontOutline)
        TimeFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        TimeFrameText:SetText(MS:FetchTime())
        TimeFrame:SetHeight(TimeFrameText:GetStringHeight() or 24)
        TimeFrame:SetWidth(TimeFrameText:GetStringWidth() or 200)
        TimeFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
    end
    function MS:SetupLocationFrame()
        LocationFrame = CreateFrame("Frame", "LocationFrame", Minimap)
        LocationFrame:ClearAllPoints()
        LocationFrame:SetPoint(MSDBG.LocationFrameAnchorFrom, Minimap, MSDBG.LocationFrameAnchorTo, MSDBG.LocationFrameXOffset, MSDBG.LocationFrameYOffset)
        LocationFrameText = LocationFrame:CreateFontString("LocationFrameText", "BACKGROUND")
        LocationFrameText:ClearAllPoints()
        LocationFrameText:SetPoint(MSDBG.LocationFrameAnchorFrom, LocationFrame, MSDBG.LocationFrameAnchorTo, 0, 0)
        LocationFrameText:SetFont(MSDBG.Font, MSDBG.LocationFrameFontSize, MSDBG.FontOutline)
        LocationFrameText:SetText(MS:FetchLocation())
        LocationFrame:SetHeight(LocationFrameText:GetStringHeight() or 24)
        LocationFrame:SetWidth(LocationFrameText:GetWidth() or 200)
        LocationFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
        LocationFrame:RegisterEvent("ZONE_CHANGED")
        LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        LocationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
    function MS:SetupInformationFrame()
        InformationFrame = CreateFrame("Frame", "InformationFrame", Minimap)
        InformationFrame:ClearAllPoints()
        InformationFrame:SetPoint(MSDBG.InformationFrameAnchorFrom, Minimap, MSDBG .InformationFrameAnchorTo, MSDBG.InformationFrameXOffset, MSDBG.InformationFrameYOffset)
        InformationFrameText = InformationFrame:CreateFontString("InformationFrameText", "BACKGROUND")
        InformationFrameText:ClearAllPoints()
        InformationFrameText:SetPoint(MSDBG.InformationFrameAnchorFrom, InformationFrame, MSDBG.InformationFrameAnchorTo, 0, 0)
        InformationFrameText:SetFont(MSDBG.Font, MSDBG.InformationFrameFontSize, MSDBG .FontOutline)
        InformationFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        InformationFrameText:SetText(MS:FetchInformation())
        InformationFrame:SetHeight(InformationFrameText:GetStringHeight() or 24)
        InformationFrame:SetWidth(InformationFrameText:GetStringWidth() or 200)
        InformationFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
    end
    function MS:SetupInstanceDifficultyFrame()
        InstanceDifficultyFrame = CreateFrame("Frame", "InstanceDifficultyFrame", Minimap)
        InstanceDifficultyFrame:ClearAllPoints()
        InstanceDifficultyFrame:SetPoint(MSDBG.InstanceDifficultyFrameAnchorFrom, Minimap, MSDBG.InstanceDifficultyFrameAnchorTo, MSDBG.InstanceDifficultyFrameXOffset, MSDBG.InstanceDifficultyFrameYOffset)
        InstanceDifficultyFrameText = InstanceDifficultyFrame:CreateFontString("InstanceDifficultyFrameText", "BACKGROUND")
        InstanceDifficultyFrameText:ClearAllPoints()
        InstanceDifficultyFrameText:SetPoint(MSDBG.InstanceDifficultyFrameAnchorFrom, InstanceDifficultyFrame, MSDBG.InstanceDifficultyFrameAnchorTo, 0, 0)
        InstanceDifficultyFrameText:SetFont(MSDBG.Font, MSDBG.InstanceDifficultyFrameFontSize, MSDBG.FontOutline)
        InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        InstanceDifficultyFrame:SetHeight(InstanceDifficultyFrameText:GetStringHeight() or 24)
        InstanceDifficultyFrame:SetWidth(InstanceDifficultyFrameText:GetStringWidth() or 200)
        InstanceDifficultyFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
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
        CoordinatesFrame:SetPoint(MSDBG.CoordinatesFrameAnchorFrom, Minimap, MSDBG .CoordinatesFrameAnchorTo, MSDBG.CoordinatesFrameXOffset, MSDBG.CoordinatesFrameYOffset)
        CoordinatesFrameText = CoordinatesFrame:CreateFontString("CoordinatesFrameText", "BACKGROUND")
        CoordinatesFrameText:ClearAllPoints()
        CoordinatesFrameText:SetPoint(MSDBG.CoordinatesFrameAnchorFrom, CoordinatesFrame, MSDBG.CoordinatesFrameAnchorTo, 0, 0)
        CoordinatesFrameText:SetFont(MSDBG.Font, MSDBG.CoordinatesFrameFontSize, MSDBG .FontOutline)
        CoordinatesFrameText:SetTextColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
        CoordinatesFrameText:SetText(MS:FetchCoordinates())
        CoordinatesFrame:SetHeight(CoordinatesFrameText:GetStringHeight() or 24)
        CoordinatesFrame:SetWidth(CoordinatesFrameText:GetStringWidth() or 200)
        CoordinatesFrame:SetFrameStrata(MSDBG.ElementFrameStrata)
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
        if TimeFrame_LastUpdate > MSDBG.TimeFrame_UpdateFrequency then
            if PrintFrameUpdates then
                MS:PrettyPrint("Time Frame: Updated")
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
        if MSDBG.UpdateInRealTime then
            if PrintFrameUpdates then
                MS:PrettyPrint("Information Frame: Updated")
            end
            InformationFrameText:SetText(MS:FetchInformation())
        else
            InformationFrame_LastUpdate = InformationFrame_LastUpdate + ElapsedTime
            if InformationFrame_LastUpdate > MSDBG.InformationFrame_UpdateFrequency then
                if PrintFrameUpdates then
                    MS:PrettyPrint("Information Frame: Updated")
                end
                InformationFrame_LastUpdate = 0
                InformationFrameText:SetText(MS:FetchInformation())
            end
        end
    end
    function UpdateCoordinatesFrame(CoordinatesFrame, ElapsedTime)
        CoordinatesFrame_LastUpdate = CoordinatesFrame_LastUpdate + ElapsedTime
        if CoordinatesFrame_LastUpdate > MSDBG.CoordinatesFrame_UpdateFrequency then
            if PrintFrameUpdates then
                MS:PrettyPrint("Coordinates Frame: Updated")
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
            if PrintFrameUpdates then
                MS:PrettyPrint("Instance Difficulty Frame: Updated")
            end
            InstanceDifficultyFrame_LastUpdate = 0
            InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
        end
    end
    MS:SetScripts()
    function MS:ResetDefaults()
        MS.db:ResetDB()
        MS:RefreshAllElements()
        MS:PrettyPrint("Settings have been reset to default.")
    end
    function MS:PrintFrameUpdateDetection()
        if PrintFrameUpdates == false then
            ToggleDebugModeButton:SetText("Print Frame Updates: |cFFFF4040Disabled|r")
        else
            ToggleDebugModeButton:SetText("Print Frame Updates: |cFF40FF40Enabled|r")
        end
    end
    function MS:TogglePrintFrameUpdates()
        if PrintFrameUpdates then
            PrintFrameUpdates = false
            MS:PrettyPrint("Print Frame Updates |cFFFF4040Disabled|r.")
        else
            PrintFrameUpdates = true
            MS:PrettyPrint("Print Frame Updates |cFF40FF40Enabled|r.")
        end
    end

    local function GenerateInformation(FrameName, FrameNameText)
        local InformationList = {}
        local AnchorFrom, ParentAnchor, AnchorTo, XOffset, YOffset = FrameName:GetPoint()
        local Font, FontSize, _ = FrameNameText:GetFont()
        table.insert(InformationList, "|cFFFFCC40Anchor From|r: " .. AnchorFrom)
        table.insert(InformationList, "|cFFFFCC40Parent Anchor|r: " .. ParentAnchor:GetName())
        table.insert(InformationList, "|cFFFFCC40Anchor To|r: " .. AnchorTo)
        table.insert(InformationList, "|cFFFFCC40X Offset|r: " .. XOffset)
        table.insert(InformationList, "|cFFFFCC40Y Offset|r: " .. YOffset)
        table.insert(InformationList, "|cFFFFCC40Font|r: " .. Font)
        if FrameNameText:GetText() ~= nil then table.insert(InformationList, "|cFFFFCC40Text|r: ".. FrameNameText:GetText()) else table.insert(InformationList, "|cFFFFCC40Text|r: Empty") end
        table.insert(InformationList, "|cFFFFCC40Font Size|r: " .. math.ceil(FontSize))
        table.insert(InformationList, "|cFFFFCC40Frame Strata|r: " .. FrameName:GetFrameStrata())
        return table.concat(InformationList, "\n")
    end

    function MS:DebugInformation()
        local DebugFrame = MSGUI:Create("Window")
        DebugFrame:SetTitle(AddOnNameVersion .. ": Debug Information")
        DebugFrame:SetWidth(400)
        DebugFrame:SetHeight(700)
        DebugFrame:SetLayout("Flow")
        DebugFrame:SetCallback("OnClose", function(widget) MSGUI:Release(widget) end)
        DebugFrame:EnableResize(false)
        local TimeDateLabel = MSGUI:Create("Heading")
        TimeDateLabel:SetFullWidth(true)
        TimeDateLabel:SetText("|cFF8080FFTime & Date|r")
        local TimeDateText = MSGUI:Create("Label")
        TimeDateText:SetFullWidth(true)
        TimeDateText:SetText(string.format("|cFF8080FFTime|r: %s:%s\n|cFF8080FFDate|r: %s/%s/%s", date("%H"), date("%M"), date("%d"), date("%m"), date("%Y")))
        DebugFrame:AddChild(TimeDateLabel)
        DebugFrame:AddChild(TimeDateText)
        -- Add Time Frame Information
        local TimeFrameLabel = MSGUI:Create("Heading")
        TimeFrameLabel:SetFullWidth(true)
        TimeFrameLabel:SetText(MSDBG.DisplayTime and "|cFF8080FFTime Frame|r: |cFF40FF40Enabled|r" or "|cFF8080FFTime Frame|r: |cFFFF4040Disabled|r")
        local TimeFrameList = MSGUI:Create("Label")
        TimeFrameList:SetFullWidth(true)
        TimeFrameList:SetText(GenerateInformation(TimeFrame, TimeFrameText))
        DebugFrame:AddChild(TimeFrameLabel)
        DebugFrame:AddChild(TimeFrameList)
        -- Add Location Frame Information
        local LocationFrameLabel = MSGUI:Create("Heading")
        LocationFrameLabel:SetFullWidth(true)
        LocationFrameLabel:SetText(MSDBG.DisplayLocation and "|cFF8080FFLocation Frame|r: |cFF40FF40Enabled|r" or "|cFF8080FFLocation Frame|r: |cFFFF4040Disabled|r")
        local LocationFrameList = MSGUI:Create("Label")
        LocationFrameList:SetFullWidth(true)
        LocationFrameList:SetText(GenerateInformation(LocationFrame, LocationFrameText))
        DebugFrame:AddChild(LocationFrameLabel)
        DebugFrame:AddChild(LocationFrameList)
        -- Add Information Frame Information
        local InformationFrameLabel = MSGUI:Create("Heading")
        InformationFrameLabel:SetFullWidth(true)
        InformationFrameLabel:SetText(MSDBG.DisplayInformation and "|cFF8080FFInformation Frame|r: |cFF40FF40Enabled|r" or "|cFF8080FFInformation Frame|r: |cFFFF4040Disabled|r")
        local InformationFrameList = MSGUI:Create("Label")
        InformationFrameList:SetFullWidth(true)
        InformationFrameList:SetText(GenerateInformation(InformationFrame, InformationFrameText))
        DebugFrame:AddChild(InformationFrameLabel)
        DebugFrame:AddChild(InformationFrameList)
        -- Add Instance Difficulty Frame Information
        local InstanceDifficultyFrameLabel = MSGUI:Create("Heading")
        InstanceDifficultyFrameLabel:SetFullWidth(true)
        InstanceDifficultyFrameLabel:SetText(MSDBG.DisplayInstanceDifficulty and "|cFF8080FFInstance Difficulty Frame|r: |cFF40FF40Enabled|r" or "|cFF8080FFInstance Difficulty Frame|r: |cFFFF4040Disabled|r")
        local InstanceDifficultyFrameList = MSGUI:Create("Label")
        InstanceDifficultyFrameList:SetFullWidth(true)
        InstanceDifficultyFrameList:SetText(GenerateInformation(InstanceDifficultyFrame, InstanceDifficultyFrameText))
        DebugFrame:AddChild(InstanceDifficultyFrameLabel)
        DebugFrame:AddChild(InstanceDifficultyFrameList)
        -- Add Coordinates Frame Information
        local CoordinatesFrameLabel = MSGUI:Create("Heading")
        CoordinatesFrameLabel:SetFullWidth(true)
        CoordinatesFrameLabel:SetText(MSDBG.DisplayCoordinates and "|cFF8080FFCoordinates Frame|r: |cFF40FF40Enabled|r" or "|cFF8080FFCoordinates Frame|r: |cFFFF4040Disabled|r")
        local CoordinatesFrameList = MSGUI:Create("Label")
        CoordinatesFrameList:SetFullWidth(true)
        CoordinatesFrameList:SetText(GenerateInformation(CoordinatesFrame, CoordinatesFrameText))
        DebugFrame:AddChild(CoordinatesFrameLabel)
        DebugFrame:AddChild(CoordinatesFrameList)

    end

    function MS:RunMSGUI()
        local AnchorPointData = { ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left", ["RIGHT"] = "Right", ["CENTER"] = "Center", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" }
        local AnchorPointOrder = { "TOP", "TOPLEFT", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT" }
        local GUI_WIDTH = 900
        local GUI_HEIGHT = 1000
        MSGUIShown = true
        local MSGUIContainer = MSGUI:Create("Frame")
        MSGUIContainer:SetTitle(AddOnName)
        MSGUIContainer:SetStatusText("Version " .. AddOnVersion .. " by " .. AddOnAuthor)
        MSGUIContainer:SetCallback("OnClose", function(widget)
            MSGUI:Release(widget)
            MSGUIShown = false
        end)
        MSGUIContainer:SetLayout("Fill")
        MSGUIContainer:SetWidth(GUI_WIDTH)
        MSGUIContainer:SetHeight(GUI_HEIGHT)
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
            DisplayDateOnHoverCheckBox:SetValue(MSDBG.DisplayDate)
            DisplayDateOnHoverCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayDate = value if value == false then DateFormatDropdown:SetDisabled(true) AlternativeFormatCheckBox:SetDisabled(true) else DateFormatDropdown:SetDisabled(false) AlternativeFormatCheckBox:SetDisabled(false) end MS:RefreshElements() end)
            DateContainer:AddChild(DisplayDateOnHoverCheckBox)
            AlternativeFormatCheckBox = MSGUI:Create("CheckBox")
            AlternativeFormatCheckBox:SetLabel("Alternative Format (MM/DD/YY)")
            AlternativeFormatCheckBox:SetValue(MSDBG.AlternativeFormatting)
            AlternativeFormatCheckBox:SetFullWidth(true)
            AlternativeFormatCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.AlternativeFormatting = value MS:RefreshTimeElement() end)
            DateContainer:AddChild(AlternativeFormatCheckBox)
            DateFormatDropdown = MSGUI:Create("Dropdown")
            DateFormatDropdown:SetLabel("Date Format")
            local DateFormatDropdownData = { ["DD/MM/YY"] = "DD/MM/YY", ["FullDate"] = "01 January 2000" }
            local DateFormatDropdownOrder = { "DD/MM/YY", "FullDate" }
            DateFormatDropdown:SetList(DateFormatDropdownData, DateFormatDropdownOrder)
            DateFormatDropdown:SetValue(MSDBG.DateFormat)
            DateFormatDropdown:SetFullWidth(true)
            DateFormatDropdown:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DateFormat = value MS:RefreshTimeElement() end)
            DateContainer:AddChild(DateFormatDropdown)
            local DisplayTimeCheckBox = MSGUI:Create("CheckBox")
            DisplayTimeCheckBox:SetLabel("Show / Hide")
            DisplayTimeCheckBox:SetValue(MSDBG.DisplayTime)
            DisplayTimeCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayTime = value MS:RefreshTimeElement() end)
            TimeToggleContainer:AddChild(DisplayTimeCheckBox)
            local TimeFormatDropdown = MSGUI:Create("Dropdown")
            TimeFormatDropdown:SetLabel("Format")
            local TimeFormatDropdownData = { ["TwentyFourHourTime"] = "24 Hour", ["TwelveHourTime"] = "12 Hour (AM/PM)", ["ServerTime"] = "24 Hour [Server Time]", ["TwelverHourServerTime"] = "12 Hour (AM/PM) [Server Time]" }
            local TimeFormatDropdownOrder = { "TwentyFourHourTime", "TwelveHourTime", "ServerTime", "TwelverHourServerTime" }
            TimeFormatDropdown:SetList(TimeFormatDropdownData, TimeFormatDropdownOrder)
            TimeFormatDropdown:SetValue(MSDBG.TimeFormat)
            TimeFormatDropdown:SetFullWidth(true)
            TimeFormatDropdown:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TimeFormat = value MS:RefreshTimeElement() end)
            TimeFormatContainer:AddChild(TimeFormatDropdown)
            local TimeFontSize = MSGUI:Create("Slider")
            TimeFontSize:SetLabel("Font Size")
            TimeFontSize:SetSliderValues(1, 100, 1)
            TimeFontSize:SetValue(MSDBG.TimeFrameFontSize)
            TimeFontSize:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TimeFrameFontSize = value MS:RefreshTimeElement() end)
            TimeFontSize:SetFullWidth(true)
            TimeFontSizeContainer:AddChild(TimeFontSize)
            local TimePositionAnchorFrom = MSGUI:Create("Dropdown")
            TimePositionAnchorFrom:SetLabel("Anchor From")
            TimePositionAnchorFrom:SetFullWidth(true)
            TimePositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            TimePositionAnchorFrom:SetValue(MSDBG.TimeFrameAnchorFrom)
            TimePositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TimeFrameAnchorFrom = value MS:RefreshTimeElement() end)
            local TimePositionAnchorTo = MSGUI:Create("Dropdown")
            TimePositionAnchorTo:SetLabel("Anchor To")
            TimePositionAnchorTo:SetFullWidth(true)
            TimePositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            TimePositionAnchorTo:SetValue(MSDBG.TimeFrameAnchorFrom)
            TimePositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TimeFrameAnchorTo = value MS:RefreshTimeElement() end)
            local TimePositionXOffset = MSGUI:Create("Slider")
            TimePositionXOffset:SetLabel("X Offset")
            TimePositionXOffset:SetFullWidth(true)
            TimePositionXOffset:SetSliderValues(-1000, 1000, 1)
            TimePositionXOffset:SetValue(MSDBG.TimeFrameXOffset)
            TimePositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TimeFrameXOffset = value MS:RefreshTimeElement() end)
            local TimePositionYOffset = MSGUI:Create("Slider")
            TimePositionYOffset:SetLabel("Y Offset")
            TimePositionYOffset:SetFullWidth(true)
            TimePositionYOffset:SetSliderValues(-1000, 1000, 1)
            TimePositionYOffset:SetValue(MSDBG.TimeFrameYOffset)
            TimePositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TimeFrameYOffset = value MS:RefreshTimeElement() end)
            local TimeUpdateFrequency = MSGUI:Create("Slider")
            TimeUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            TimeUpdateFrequency:SetFullWidth(true)
            TimeUpdateFrequency:SetSliderValues(1, 60, 1)
            TimeUpdateFrequency:SetValue(MSDBG.TimeFrame_UpdateFrequency)
            TimeUpdateFrequency:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TimeFrame_UpdateFrequency = value MS:RefreshTimeElement() end)
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
            local LocationFormatContainer = MSGUI:Create("InlineGroup")
            LocationFormatContainer:SetTitle("Format Options")
            LocationFormatContainer:SetFullWidth(true)
            LocationFormatContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(LocationFormatContainer)
            local LocationFontSizeContainer = MSGUI:Create("InlineGroup")
            LocationFontSizeContainer:SetTitle("Font Size Options")
            LocationFontSizeContainer:SetFullWidth(true)
            MSGUIContainer:AddChild(LocationFontSizeContainer)
            local DisplayLocationCheckBox = MSGUI:Create("CheckBox")
            DisplayLocationCheckBox:SetLabel("Show / Hide")
            DisplayLocationCheckBox:SetValue(MSDBG.DisplayLocation)
            DisplayLocationCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayLocation = value MS:RefreshLocationElement() end)
            local LocationFontColorSelectionDropdown = MSGUI:Create("Dropdown")
            LocationFontColorSelectionDropdown:SetLabel("Color Font By")
            local LocationFontColorSelectionDropdownData = { ["Primary"] = "Primary Colour", ["Secondary"] = "Secondary Colour", ["Reaction"] = "Reaction Colour", ["Custom"] = "Custom Colour"}
            local LocationFontColorSelectionDropdownOrder = { "Primary", "Secondary", "Reaction", "Custom" }
            LocationFontColorSelectionDropdown:SetList(LocationFontColorSelectionDropdownData, LocationFontColorSelectionDropdownOrder)
            LocationFontColorSelectionDropdown:SetValue(MSDBG.LocationFontColor)
            LocationFontColorSelectionDropdown:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.LocationFontColor = value MS:RefreshLocationElement() MSGUIContainer:ReleaseChildren() DrawLocationContainer(MSGUIContainer) end)
            LocationFontColorSelectionDropdown:SetWidth(GUI_WIDTH / 1.75)
            local LocationCustomColourPicker = MSGUI:Create("ColorPicker")
            LocationCustomColourPicker:SetLabel("Custom Font Color")
            LocationCustomColourPicker:SetColor(MSDBG.LocationCustomColorR, MSDBG.LocationCustomColorG, MSDBG.LocationCustomColorB)
            LocationCustomColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) MSDBG.LocationCustomColorR = r MSDBG.LocationCustomColorG = g MSDBG.LocationCustomColorB = b MS:RefreshLocationElement() end)
            if MSDBG.LocationFontColor == "Custom" then
                LocationFontColorSelectionDropdown:SetValue("Custom")
                LocationCustomColourPicker:SetDisabled(false)
            else
                LocationCustomColourPicker:SetDisabled(true)
            end
            LocationToggleContainer:AddChild(DisplayLocationCheckBox)
            LocationFormatContainer:AddChild(LocationFontColorSelectionDropdown)
            LocationFormatContainer:AddChild(LocationCustomColourPicker)
            local LocationFontSize = MSGUI:Create("Slider")
            LocationFontSize:SetLabel("Font Size")
            LocationFontSize:SetSliderValues(1, 100, 1)
            LocationFontSize:SetValue(MSDBG.LocationFrameFontSize)
            LocationFontSize:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.LocationFrameFontSize = value MS:RefreshLocationElement() end)
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
            LocationPositionAnchorFrom:SetValue(MSDBG.LocationFrameAnchorFrom)
            LocationPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.LocationFrameAnchorFrom = value MS:RefreshLocationElement() end)
            local LocationPositionAnchorTo = MSGUI:Create("Dropdown")
            LocationPositionAnchorTo:SetLabel("Anchor To")
            LocationPositionAnchorTo:SetFullWidth(true)
            LocationPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            LocationPositionAnchorTo:SetValue(MSDBG.LocationFrameAnchorTo)
            LocationPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.LocationFrameAnchorTo = value MS:RefreshLocationElement() end)
            local LocationPositionXOffset = MSGUI:Create("Slider")
            LocationPositionXOffset:SetLabel("X Offset")
            LocationPositionXOffset:SetFullWidth(true)
            LocationPositionXOffset:SetSliderValues(-1000, 1000, 1)
            LocationPositionXOffset:SetValue(MSDBG.LocationFrameXOffset)
            LocationPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.LocationFrameXOffset = value MS:RefreshLocationElement() end)
            local LocationPositionYOffset = MSGUI:Create("Slider")
            LocationPositionYOffset:SetLabel("Y Offset")
            LocationPositionYOffset:SetFullWidth(true)
            LocationPositionYOffset:SetSliderValues(-1000, 1000, 1)
            LocationPositionYOffset:SetValue(MSDBG.LocationFrameYOffset)
            LocationPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.LocationFrameYOffset = value MS:RefreshLocationElement() end)
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
            local TooltipInformationContainer = MSGUI:Create("InlineGroup")
            TooltipInformationContainer:SetTitle("Tooltip Options")
            TooltipInformationContainer:SetFullWidth(true)
            TooltipInformationContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(TooltipInformationContainer)
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
            DisplayInformationCheckBox:SetValue(MSDBG.DisplayInformation)
            DisplayInformationCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayInformation = value MS:RefreshInformationElement() end)
            InformationToggleContainer:AddChild(DisplayInformationCheckBox)
            local UpdateInformationInRealTimeCheckBox = MSGUI:Create("CheckBox")
            UpdateInformationInRealTimeCheckBox:SetLabel("Real Time Update")
            UpdateInformationInRealTimeCheckBox:SetFullWidth(true)
            UpdateInformationInRealTimeCheckBox:SetValue(MSDBG.UpdateInRealTime)
            UpdateInformationInRealTimeCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.UpdateInRealTime = value MS:RefreshInformationElement() end)
            InformationToggleContainer:AddChild(UpdateInformationInRealTimeCheckBox)
            local TooltipInformationCheckBox = MSGUI:Create("CheckBox")
            TooltipInformationCheckBox:SetLabel("Display Tooltip Information [Mouseover]")
            TooltipInformationCheckBox:SetFullWidth(true)
            TooltipInformationCheckBox:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            TooltipInformationCheckBox:SetValue(MSDBG.DisplayTooltipInformation)
            TooltipInformationCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayTooltipInformation = value MS:RefreshInformationElement() MSGUIContainer:ReleaseChildren() DrawInformationContainer(MSGUIContainer) end)
            TooltipInformationContainer:AddChild(TooltipInformationCheckBox)
            local DisplayRaidDungeonLockoutsCheckBox = MSGUI:Create("CheckBox")
            DisplayRaidDungeonLockoutsCheckBox:SetLabel("Raid / Dungeon Lockouts")
            DisplayRaidDungeonLockoutsCheckBox:SetValue(MSDBG.DisplayRaidDungeonLockouts)
            DisplayRaidDungeonLockoutsCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayRaidDungeonLockouts = value MS:RefreshInformationElement() end)
            TooltipInformationContainer:AddChild(DisplayRaidDungeonLockoutsCheckBox)
            local DisplayMythicPlusRunsCheckBox = MSGUI:Create("CheckBox")
            DisplayMythicPlusRunsCheckBox:SetLabel("Mythic+ Runs")
            DisplayMythicPlusRunsCheckBox:SetValue(MSDBG.DisplayMythicPlusRuns)
            DisplayMythicPlusRunsCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayMythicPlusRuns = value MS:RefreshInformationElement() end)
            TooltipInformationContainer:AddChild(DisplayMythicPlusRunsCheckBox)
            local DisplayPlayerKeystoneCheckBox = MSGUI:Create("CheckBox")
            DisplayPlayerKeystoneCheckBox:SetLabel("Player Keystone")
            DisplayPlayerKeystoneCheckBox:SetValue(MSDBG.DisplayPlayerKeystone)
            DisplayPlayerKeystoneCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayPlayerKeystone = value MS:RefreshInformationElement() end)
            TooltipInformationContainer:AddChild(DisplayPlayerKeystoneCheckBox)
            local DisplayPartyKeystonesCheckBox = MSGUI:Create("CheckBox")
            DisplayPartyKeystonesCheckBox:SetLabel("Party Keystones")
            DisplayPartyKeystonesCheckBox:SetValue(MSDBG.DisplayPartyKeystones)
            DisplayPartyKeystonesCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayPartyKeystones = value MS:RefreshInformationElement() end)
            TooltipInformationContainer:AddChild(DisplayPartyKeystonesCheckBox)
            local DisplayAffixDescriptionsCheckBox = MSGUI:Create("CheckBox")
            DisplayAffixDescriptionsCheckBox:SetLabel("Affix Descriptions")
            DisplayAffixDescriptionsCheckBox:SetValue(MSDBG.DisplayAffixDescriptions)
            DisplayAffixDescriptionsCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayAffixDescriptions = value MS:RefreshInformationElement() end)
            local DisplayAffixesCheckBox = MSGUI:Create("CheckBox")
            DisplayAffixesCheckBox:SetLabel("Affixes")
            DisplayAffixesCheckBox:SetValue(MSDBG.DisplayAffixes)
            DisplayAffixesCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayAffixes = value MS:RefreshInformationElement() MSGUIContainer:ReleaseChildren() DrawInformationContainer(MSGUIContainer) end)
            if not MSDBG.DisplayAffixes then 
                DisplayAffixDescriptionsCheckBox:SetDisabled(true)
            end
            TooltipInformationContainer:AddChild(DisplayAffixesCheckBox)
            TooltipInformationContainer:AddChild(DisplayAffixDescriptionsCheckBox)
            local DisplayFriendListCheckBox = MSGUI:Create("CheckBox")
            DisplayFriendListCheckBox:SetLabel("Friend List")
            DisplayFriendListCheckBox:SetValue(MSDBG.DisplayFriendList)
            DisplayFriendListCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayFriendList = value MS:RefreshInformationElement() end)
            TooltipInformationContainer:AddChild(DisplayFriendListCheckBox)
            local TooltipInformationSeparator = MSGUI:Create("Heading")
            TooltipInformationSeparator:SetFullWidth(true)
            TooltipInformationSeparator:SetText("Position Options")
            TooltipInformationContainer:AddChild(TooltipInformationSeparator)
            local TooltipInformationAnchorFromDropdown = MSGUI:Create("Dropdown")
            TooltipInformationAnchorFromDropdown:SetLabel("Anchor From")
            TooltipInformationAnchorFromDropdown:SetList(AnchorPointData, AnchorPointOrder)
            TooltipInformationAnchorFromDropdown:SetValue(MSDBG.TooltipAnchorFrom)
            TooltipInformationAnchorFromDropdown:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TooltipAnchorFrom = value MS:RefreshInformationElement() end)
            local TooltipInformationAnchorToDropdown = MSGUI:Create("Dropdown")
            TooltipInformationAnchorToDropdown:SetLabel("Anchor To")
            TooltipInformationAnchorToDropdown:SetList(AnchorPointData, AnchorPointOrder)
            TooltipInformationAnchorToDropdown:SetValue(MSDBG.TooltipAnchorTo)
            TooltipInformationAnchorToDropdown:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TooltipAnchorTo = value MS:RefreshInformationElement() end)
            local TooltipInformationXOffset = MSGUI:Create("Slider")
            TooltipInformationXOffset:SetLabel("X Offset")
            TooltipInformationXOffset:SetSliderValues(-1000, 1000, 1)
            TooltipInformationXOffset:SetValue(MSDBG.TooltipXOffset)
            TooltipInformationXOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TooltipXOffset = value MS:RefreshInformationElement() end)
            local TooltipInformationYOffset = MSGUI:Create("Slider")
            TooltipInformationYOffset:SetLabel("Y Offset")
            TooltipInformationYOffset:SetSliderValues(-1000, 1000, 1)
            TooltipInformationYOffset:SetValue(MSDBG.TooltipYOffset)
            TooltipInformationYOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.TooltipYOffset = value MS:RefreshInformationElement() end)
            TooltipInformationContainer:AddChild(TooltipInformationAnchorFromDropdown)
            TooltipInformationContainer:AddChild(TooltipInformationAnchorToDropdown)
            TooltipInformationContainer:AddChild(TooltipInformationXOffset)
            TooltipInformationContainer:AddChild(TooltipInformationYOffset)
            if not MSDBG.DisplayTooltipInformation then
                DisplayRaidDungeonLockoutsCheckBox:SetDisabled(true)
                DisplayMythicPlusRunsCheckBox:SetDisabled(true)
                DisplayPlayerKeystoneCheckBox:SetDisabled(true)
                DisplayPartyKeystonesCheckBox:SetDisabled(true)
                DisplayAffixesCheckBox:SetDisabled(true)
                DisplayAffixDescriptionsCheckBox:SetDisabled(true)
                DisplayFriendListCheckBox:SetDisabled(true)
                TooltipInformationAnchorFromDropdown:SetDisabled(true)
                TooltipInformationAnchorToDropdown:SetDisabled(true)
                TooltipInformationXOffset:SetDisabled(true)
                TooltipInformationYOffset:SetDisabled(true)
            end
            local InformationFormatEditBox = MSGUI:Create("EditBox")
            InformationFormatEditBox:SetLabel("Format")
            InformationFormatEditBox:SetFullWidth(true)
            InformationFormatEditBox:SetText(MSDBG.InformationFormatString)
            InformationFormatEditBox:SetCallback("OnEnterPressed", function(widget, event, value) if value:match("^%s*$") then value = "FPS [HomeMS]" InformationFormatEditBox:SetText("FPS [HomeMS]") end MSDBG.InformationFormatString = value  MS:RefreshInformationElement() InformationFormatEditBox:ClearFocus() end)
            InformationFormatContainer:AddChild(InformationFormatEditBox)
            local InformationFormatEditBoxHelp = MSGUI:Create("Label")
            InformationFormatEditBoxHelp:SetFullWidth(true)
            InformationFormatEditBoxHelp:SetText("\n|cFFFFCC00Available Tags|r\n\n|cFF8080FFFPS|r = FPS\n|cFF8080FFHomeMS|r = Home Latency\n|cFF8080FFWorldMS|r = World Latency\n|cFF8080FFDualMS|r = Home & World MS\n\nAny seperators can be used. Some common ones are: |cFF8080FF[ ]|r or |cFF8080FF( )|r or |cFF8080FF< >|r or |cFF8080FF | |r")
            InformationFormatContainer:AddChild(InformationFormatEditBoxHelp)
            local InformationFontSize = MSGUI:Create("Slider")
            InformationFontSize:SetLabel("Font Size")
            InformationFontSize:SetSliderValues(1, 100, 1)
            InformationFontSize:SetValue(MSDBG.InformationFrameFontSize)
            InformationFontSize:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InformationFrameFontSize = value MS:RefreshInformationElement() end)
            InformationFontSize:SetFullWidth(true)
            InformationFontSizeContainer:AddChild(InformationFontSize)
            local InformationPositionAnchorFrom = MSGUI:Create("Dropdown")
            InformationPositionAnchorFrom:SetLabel("Anchor From")
            InformationPositionAnchorFrom:SetFullWidth(true)
            InformationPositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            InformationPositionAnchorFrom:SetValue(MSDBG.InformationFrameAnchorFrom)
            InformationPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InformationFrameAnchorFrom = value MS:RefreshInformationElement() end)
            local InformationPositionAnchorTo = MSGUI:Create("Dropdown")
            InformationPositionAnchorTo:SetLabel("Anchor To")
            InformationPositionAnchorTo:SetFullWidth(true)
            InformationPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            InformationPositionAnchorTo:SetValue(MSDBG.InformationFrameAnchorTo)
            InformationPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InformationFrameAnchorTo = value MS:RefreshInformationElement() end)
            local InformationPositionXOffset = MSGUI:Create("Slider")
            InformationPositionXOffset:SetLabel("X Offset")
            InformationPositionXOffset:SetFullWidth(true)
            InformationPositionXOffset:SetSliderValues(-1000, 1000, 1)
            InformationPositionXOffset:SetValue(MSDBG.InformationFrameXOffset)
            InformationPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InformationFrameXOffset = value MS:RefreshInformationElement() end)
            local InformationPositionYOffset = MSGUI:Create("Slider")
            InformationPositionYOffset:SetLabel("Y Offset")
            InformationPositionYOffset:SetFullWidth(true)
            InformationPositionYOffset:SetSliderValues(-1000, 1000, 1)
            InformationPositionYOffset:SetValue(MSDBG.InformationFrameYOffset)
            InformationPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InformationFrameYOffset = value MS:RefreshInformationElement() end)
            local InformationUpdateFrequency = MSGUI:Create("Slider")
            InformationUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            InformationUpdateFrequency:SetFullWidth(true)
            InformationUpdateFrequency:SetSliderValues(1, 60, 1)
            InformationUpdateFrequency:SetValue(MSDBG.InformationFrame_UpdateFrequency)
            InformationUpdateFrequency:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InformationFrame_UpdateFrequency = value MS:RefreshInformationElement() end)
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
            DisplayInstanceDifficultyCheckBox:SetValue(MSDBG.DisplayInstanceDifficulty)
            DisplayInstanceDifficultyCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayInstanceDifficulty = value MS:RefreshInstanceDifficultyElement() end)
            InstanceDifficultyToggleContainer:AddChild(DisplayInstanceDifficultyCheckBox)
            TestInstanceDifficultyCheckBox = MSGUI:Create("CheckBox")
            TestInstanceDifficultyCheckBox:SetLabel("Test Instance Difficulty")
            TestInstanceDifficultyCheckBox:SetValue(TestingInstanceDifficulty)
            TestInstanceDifficultyCheckBox:SetCallback("OnValueChanged", function(widget, event, value) TestingInstanceDifficulty = value MS:RefreshInstanceDifficultyElement() end)
            InstanceDifficultyToggleContainer:AddChild(TestInstanceDifficultyCheckBox)
            local InstanceDifficultyFontSize = MSGUI:Create("Slider")
            InstanceDifficultyFontSize:SetLabel("Font Size")
            InstanceDifficultyFontSize:SetSliderValues(1, 100, 1)
            InstanceDifficultyFontSize:SetValue(MSDBG.InstanceDifficultyFrameFontSize)
            InstanceDifficultyFontSize:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InstanceDifficultyFrameFontSize = value MS:RefreshInstanceDifficultyElement() end)
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
            InstanceDifficultyPositionAnchorFrom:SetValue(MSDBG.InstanceDifficultyFrameAnchorFrom)
            InstanceDifficultyPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InstanceDifficultyFrameAnchorFrom = value MS:RefreshInstanceDifficultyElement() end)
            local InstanceDifficultyPositionAnchorTo = MSGUI:Create("Dropdown")
            InstanceDifficultyPositionAnchorTo:SetLabel("Anchor To")
            InstanceDifficultyPositionAnchorTo:SetFullWidth(true)
            InstanceDifficultyPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            InstanceDifficultyPositionAnchorTo:SetValue(MSDBG.InstanceDifficultyFrameAnchorTo)
            InstanceDifficultyPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InstanceDifficultyFrameAnchorTo = value MS:RefreshInstanceDifficultyElement() end)
            local InstanceDifficultyPositionXOffset = MSGUI:Create("Slider")
            InstanceDifficultyPositionXOffset:SetLabel("X Offset")
            InstanceDifficultyPositionXOffset:SetFullWidth(true)
            InstanceDifficultyPositionXOffset:SetSliderValues(-1000, 1000, 1)
            InstanceDifficultyPositionXOffset:SetValue(MSDBG.InstanceDifficultyFrameXOffset)
            InstanceDifficultyPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InstanceDifficultyFrameXOffset = value MS:RefreshInstanceDifficultyElement() end)
            local InstanceDifficultyPositionYOffset = MSGUI:Create("Slider")
            InstanceDifficultyPositionYOffset:SetLabel("Y Offset")
            InstanceDifficultyPositionYOffset:SetFullWidth(true)
            InstanceDifficultyPositionYOffset:SetSliderValues(-1000, 1000, 1)
            InstanceDifficultyPositionYOffset:SetValue(MSDBG.InstanceDifficultyFrameYOffset)
            InstanceDifficultyPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.InstanceDifficultyFrameYOffset = value MS:RefreshInstanceDifficultyElement() end)
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
            PrimaryFontColor:SetColor(MSDBG.PrimaryFontColorR, MSDBG.PrimaryFontColorG, MSDBG.PrimaryFontColorB)
            PrimaryFontColor:SetCallback("OnValueChanged", function(widget, event, r, g, b) MSDBG.PrimaryFontColorR = r MSDBG.PrimaryFontColorG = g MSDBG.PrimaryFontColorB = b MS:RefreshElements() end)
            PrimaryFontColor:SetCallback("OnValueConfirmed", function(widget, event, r, g, b) MSDBG.PrimaryFontColorR = r MSDBG.PrimaryFontColorG = g MSDBG.PrimaryFontColorB = b MS:RefreshElements() end)
            local SecondaryFontColor = MSGUI:Create("ColorPicker")
            SecondaryFontColor:SetLabel("Secondary Font Color")
            SecondaryFontColor:SetHasAlpha(false)
            SecondaryFontColor:SetColor(MSDBG.SecondaryFontColorR, MSDBG.SecondaryFontColorG, MSDBG.SecondaryFontColorB)
            SecondaryFontColor:SetCallback("OnValueChanged", function(widget, event, r, g, b) MSDBG.SecondaryFontColorR = r MSDBG.SecondaryFontColorG = g MSDBG.SecondaryFontColorB = b MS:RefreshElements() end)
            SecondaryFontColor:SetCallback("OnValueConfirmed", function(widget, event, r, g, b) MSDBG.SecondaryFontColorR = r MSDBG.SecondaryFontColorG = g MSDBG.SecondaryFontColorB = b MS:RefreshElements() end)
            if MSDBG.UseClassColours == true then
                SecondaryFontColor:SetDisabled(true)
            else
                SecondaryFontColor:SetDisabled(false)
            end
            local ClassColorCheckBox = MSGUI:Create("CheckBox")
            ClassColorCheckBox:SetLabel("Use Class Color")
            ClassColorCheckBox:SetValue(MSDBG.UseClassColours)
            ClassColorCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.UseClassColours = value if value == true then SecondaryFontColor:SetDisabled(true) else SecondaryFontColor:SetDisabled(false) end MS:RefreshElements() end)
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
            Font:SetValue(MSDBG.Font)
            Font:SetCallback("OnValueChanged",
                function(widget, event, FontPath)
                    MSDBG.Font = FontPath
                    MS:RefreshElements()
                end)
            FontContainer:AddChild(Font)
            local FontOutline = MSGUI:Create("Dropdown")
            FontOutline:SetLabel("Font Outline")
            FontOutline:SetList({ ["NONE"] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline" })
            FontOutline:SetValue(MSDBG.FontOutline)
            FontOutline:SetFullWidth(true)
            FontOutline:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.FontOutline = value MS:RefreshElements() end)
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
            ElementFrameStrata:SetValue(MSDBG.ElementFrameStrata)
            ElementFrameStrata:SetFullWidth(true)
            ElementFrameStrata:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.ElementFrameStrata = value MS:RefreshAllElements() end)
            FrameStrataContainer:AddChild(ElementFrameStrata)
            local MiscContainer = MSGUI:Create("InlineGroup")
            MiscContainer:SetTitle("Misc Options")
            MiscContainer:SetFullWidth(true)
            MiscContainer:SetLayout("Flow")
            MSGUIContainer:AddChild(MiscContainer)
            ToggleDebugModeButton = MSGUI:Create("Button")
            ToggleDebugModeButton:SetText(MS:PrintFrameUpdateDetection())
            ToggleDebugModeButton:SetFullWidth(true)
            ToggleDebugModeButton:SetCallback("OnClick", function() MS:TogglePrintFrameUpdates() MS:PrintFrameUpdateDetection() MSGUIContainer:DoLayout() end)
            MiscContainer:AddChild(ToggleDebugModeButton)
            local ResetDefaultsButton = MSGUI:Create("Button")
            ResetDefaultsButton:SetText("Reset Defaults")
            ResetDefaultsButton:SetFullWidth(true)
            ResetDefaultsButton:SetCallback("OnClick", function() MS:ResetDefaults() MSGUIContainer:ReleaseChildren() DrawMiscellaneousContainer(MSGUIContainer) end)
            local DebugPrintButton = MSGUI:Create("Button")
            DebugPrintButton:SetText("Debug Information")
            DebugPrintButton:SetFullWidth(true)
            DebugPrintButton:SetCallback("OnClick", function() MS:DebugInformation() end)
            MiscContainer:AddChild(ResetDefaultsButton)
            MiscContainer:AddChild(DebugPrintButton)
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
            DisplayCoordinatesCheckBox:SetValue(MSDBG.DisplayCoordinates)
            DisplayCoordinatesCheckBox:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.DisplayCoordinates = value MS:RefreshCoordinatesElement() MSGUIContainer:DoLayout() end)
            CoordinatesToggleContainer:AddChild(DisplayCoordinatesCheckBox)
            local CoordinatesFormatDropdown = MSGUI:Create("Dropdown")
            CoordinatesFormatDropdown:SetLabel("Format")
            CoordinatesFormatDropdown:SetList({ ["NoDecimal"] = "No Decimals [00, 00]", ["OneDecimal"] = "One Decimal [00.0, 00.0]", ["TwoDecimal"] = "Two Decimals [00.00, 00.00]" })
            CoordinatesFormatDropdown:SetValue(MSDBG.CoordinatesFormat)
            CoordinatesFormatDropdown:SetFullWidth(true)
            CoordinatesFormatDropdown:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.CoordinatesFormat = value MS:RefreshCoordinatesElement() end)
            CoordinatesFormatContainer:AddChild(CoordinatesFormatDropdown)
            local CoordinatesFontSize = MSGUI:Create("Slider")
            CoordinatesFontSize:SetLabel("Font Size")
            CoordinatesFontSize:SetSliderValues(1, 100, 1)
            CoordinatesFontSize:SetValue(MSDBG.CoordinatesFrameFontSize)
            CoordinatesFontSize:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.CoordinatesFrameFontSize = value MS:RefreshCoordinatesElement() end)
            CoordinatesFontSize:SetFullWidth(true)
            CoordinatesFontSizeContainer:AddChild(CoordinatesFontSize)
            local CoordinatesPositionAnchorFrom = MSGUI:Create("Dropdown")
            CoordinatesPositionAnchorFrom:SetLabel("Anchor From")
            CoordinatesPositionAnchorFrom:SetFullWidth(true)
            CoordinatesPositionAnchorFrom:SetList(AnchorPointData, AnchorPointOrder)
            CoordinatesPositionAnchorFrom:SetValue(MSDBG.CoordinatesFrameAnchorFrom)
            CoordinatesPositionAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.CoordinatesFrameAnchorFrom = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionAnchorFrom)
            local CoordinatesPositionAnchorTo = MSGUI:Create("Dropdown")
            CoordinatesPositionAnchorTo:SetLabel("Anchor To")
            CoordinatesPositionAnchorTo:SetFullWidth(true)
            CoordinatesPositionAnchorTo:SetList(AnchorPointData, AnchorPointOrder)
            CoordinatesPositionAnchorTo:SetValue(MSDBG.CoordinatesFrameAnchorTo)
            CoordinatesPositionAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.CoordinatesFrameAnchorTo = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionAnchorTo)
            local CoordinatesPositionXOffset = MSGUI:Create("Slider")
            CoordinatesPositionXOffset:SetLabel("X Offset")
            CoordinatesPositionXOffset:SetFullWidth(true)
            CoordinatesPositionXOffset:SetSliderValues(-1000, 1000, 1)
            CoordinatesPositionXOffset:SetValue(MSDBG.CoordinatesFrameXOffset)
            CoordinatesPositionXOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.CoordinatesFrameXOffset = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionXOffset)
            local CoordinatesPositionYOffset = MSGUI:Create("Slider")
            CoordinatesPositionYOffset:SetLabel("Y Offset")
            CoordinatesPositionYOffset:SetFullWidth(true)
            CoordinatesPositionYOffset:SetSliderValues(-1000, 1000, 1)
            CoordinatesPositionYOffset:SetValue(MSDBG.CoordinatesFrameYOffset)
            CoordinatesPositionYOffset:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.CoordinatesFrameYOffset = value MS:RefreshCoordinatesElement() end)
            CoordinatesPositionsContainer:AddChild(CoordinatesPositionYOffset)
            local CoordinatesUpdateFrequency = MSGUI:Create("Slider")
            CoordinatesUpdateFrequency:SetLabel("Update Frequency [Seconds]")
            CoordinatesUpdateFrequency:SetFullWidth(true)
            CoordinatesUpdateFrequency:SetSliderValues(1, 60, 1)
            CoordinatesUpdateFrequency:SetValue(MSDBG.CoordinatesFrame_UpdateFrequency)
            CoordinatesUpdateFrequency:SetCallback("OnValueChanged", function(widget, event, value) MSDBG.CoordinatesFrame_UpdateFrequency = value MS:RefreshCoordinatesElement() end)
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
                MS:PrintFrameUpdateDetection()
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
