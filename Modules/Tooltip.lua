local _, MS = ...
function MS:FetchPlayerLockouts()
    if not MS.DB.global.DisplayLockouts then return end
    RequestRaidInfo()
    local RaidLockouts = {}
    local DungeonLockouts = {}
    for i = 1, GetNumSavedInstances() do
        local Name, _, Reset, _, IsLocked, _, _, IsRaid, _, DifficultyName, MaxEncounters, CurrentProgress, _, _ = GetSavedInstanceInfo(i)
        local Days = math.floor(Reset / 86400)
        local Hours = math.floor((Reset % 86400) / 3600)
        local Mins = math.floor((Reset % 3600) / 60)
        Reset = Days > 0 and string.format("%dd %dh %dm", Days, Hours, Mins) or string.format("%dh %dm", Hours, Mins)
        local LockoutString = string.format("%s: %d/%d %s [%s%s|r]", Name, CurrentProgress, MaxEncounters, DifficultyName, MS.AccentColour, Reset)
        if IsLocked then
            if IsRaid then
                table.insert(RaidLockouts, LockoutString)
            else
                table.insert(DungeonLockouts, LockoutString)
            end
        end
    end
    if #DungeonLockouts > 0 then
        GameTooltip:AddLine("Dungeon |cFFFFFFFFLockouts|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for _, Lockout in pairs(DungeonLockouts) do
            local DungeonTitle, DungeonLockout, DungeonReset = Lockout:match("([^:]+): (.+) %[(.+)%]")
            local DungeonTitle = MS.AbbrInstances[DungeonTitle:match("([^:]+)")] or DungeonTitle
            local DungeonLockout = DungeonLockout:gsub("Normal", "N"):gsub("Heroic", "H"):gsub("Mythic", "M")
            local DungeonDisplayString = MS.AccentColour .. DungeonTitle .. "|r: " .. DungeonLockout
            GameTooltip:AddDoubleLine(DungeonDisplayString, DungeonReset, 1, 1, 1, 1, 1, 1)
        end
    end
    if #RaidLockouts > 0 then
        if #DungeonLockouts > 0 then
            GameTooltip:AddLine(" ", 1, 1, 1, 1)
        end
        GameTooltip:AddLine("Raid |cFFFFFFFFLockouts|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for _, Lockout in pairs(RaidLockouts) do
            local RaidTitle, RaidLockout, RaidReset = Lockout:match("([^:]+): (.+) %[(.+)%]")
            local RaidTitle = MS.AbbrInstances[RaidTitle:match("([^:]+)")] or RaidTitle
            local RaidLockout = RaidLockout:gsub("Normal", "N"):gsub("Heroic", "H"):gsub("Mythic", "M"):gsub("Looking For Raid", "LFR")
            local RaidDisplayString = MS.AccentColour .. RaidTitle .. "|r: " .. RaidLockout
            GameTooltip:AddDoubleLine(RaidDisplayString, RaidReset, 1, 1, 1, 1, 1, 1)
        end
    end
    if (#DungeonLockouts > 0 or #RaidLockouts > 0) and (MS.DB.global.DisplayVaultOptions or MS.DB.global.DisplayPlayerKeystone or (IsInGroup() and MS.DB.global.DisplayPartyKeystones) or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList) then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
end

function MS:FetchVaultOptions()
    if not MS.DB.global.DisplayVaultOptions then return end
    -- Fetch Raid Options
    local RaidRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid)
    local RaidsCompleted = {}
    for i = 1, 3 do
        local DifficultyName = MS.RaidDifficultyIDs[RaidRuns[i].level]
        local GViLvl = MS.RaidGreatVaultiLvls[RaidRuns[i].level]
        table.insert(RaidsCompleted, string.format(MS.AccentColour .. "%s|r [%d]", DifficultyName, GViLvl))
    end
    -- Fetch Mythic+ Options
    local MythicPlusRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus)
    local MythicPlusRunsCompleted = {}
    for i = 1, 3 do
        local KeyLevel = MythicPlusRuns[i].level
        local GViLvl = MS.MythicPlusGreatVaultiLvls[MythicPlusRuns[i].level]
        table.insert(MythicPlusRunsCompleted, string.format(MS.AccentColour .. "+%d|r [%d]", KeyLevel, GViLvl))
    end
    if #RaidsCompleted > 0 or #MythicPlusRunsCompleted > 0 then
        GameTooltip:AddLine("Great |cFFFFFFFFVault|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
    end
    if #RaidsCompleted > 0 then
        GameTooltip:AddLine("Raid |cFFFFFFFFSlots|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for i, Raid in ipairs(RaidsCompleted) do
            GameTooltip:AddLine(string.format("Slot #%d: %s", i, Raid), 1, 1, 1)
        end
    end
    if #RaidsCompleted > 0 and #MythicPlusRunsCompleted > 0 then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
    if #MythicPlusRunsCompleted > 0 then
        GameTooltip:AddLine("Mythic+ |cFFFFFFFFSlots|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for i, MythicPlusRun in ipairs(MythicPlusRunsCompleted) do
            GameTooltip:AddLine(string.format("Slot #%d: %s", i, MythicPlusRun), 1, 1, 1)
        end
    end

    if #MythicPlusRunsCompleted > 0 and (MS.DB.global.DisplayPlayerKeystone or (IsInGroup() and MS.DB.global.DisplayPartyKeystones) or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList) then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
end

function MS:FetchKeystones()
    local TextureSize = MS.DB.global.TooltipTextureIconSize
    local NoKeyTextureIcon = "|TInterface/Icons/inv_relics_hourglass.blp:" .. TextureSize .. ":" .. TextureSize .. ":0|t"
    if not MS.OR then return end
    if not MS.DB.global.DisplayPlayerKeystone and not MS.DB.global.DisplayPartyKeystones then return end
    if MS.DB.global.DisplayPlayerKeystone then
        local KeystoneInfo = MS.OR.GetKeystoneInfo("player")
        GameTooltip:AddLine("Your |cFFFFFFFFKeystone|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        if KeystoneInfo then
            local KeystoneLevel = KeystoneInfo.level
            local Keystone, _, _, KeystoneIcon = C_ChallengeMode.GetMapUIInfo(KeystoneInfo.mythicPlusMapID)
            if Keystone and KeystoneIcon then
                local TexturedIcon = "|T" .. KeystoneIcon .. ":" .. TextureSize .. ":" .. TextureSize .. ":0|t"
                GameTooltip:AddLine(TexturedIcon .. " +" .. KeystoneLevel .. " " .. Keystone, 1, 1, 1, 1)
            elseif Keystone then
                GameTooltip:AddLine(NoKeyTextureIcon .. " +" .. KeystoneLevel .. " " .. Keystone, 1, 1, 1, 1)
            else
                GameTooltip:AddLine(NoKeyTextureIcon .. " No Keystone", 1, 1, 1, 1)
            end
        end
        if (IsInGroup() and MS.DB.global.DisplayPartyKeystones) or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList then
            GameTooltip:AddLine(" ", 1, 1, 1, 1)
        end
    end
    if MS.DB.global.DisplayPartyKeystones then
        local PartyMembers = {}
        local WHITE_COLOUR_OVERRIDE = "|cFFFFFFFF"
        if IsInGroup() and not IsInRaid() then
            GameTooltip:AddLine("Party |cFFFFFFFFKeystones|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
            for i = 1, GetNumGroupMembers() - 1 do
                local UnitID = "party" .. i
                local UnitName = GetUnitName(UnitID, true)
                if UnitName then
                    table.insert(PartyMembers, UnitID)
                end
            end

            for _, UnitID in ipairs(PartyMembers) do
                local UnitName = GetUnitName(UnitID, true)
                local FormattedUnitName = UnitName:match("([^-]+)")
                local UnitClassColour = RAID_CLASS_COLORS[select(2, UnitClass(UnitID))]
                local KeystoneInfo = MS.OR.GetKeystoneInfo(UnitID)

                if KeystoneInfo then
                    local Keystone, _, _, KeystoneIcon = C_ChallengeMode.GetMapUIInfo(KeystoneInfo.mythicPlusMapID)
                    local KeystoneLevel = KeystoneInfo.level
                    if KeystoneIcon then
                        local TexturedIcon = "|T" .. KeystoneIcon .. ":" .. TextureSize .. ":" .. TextureSize .. ":0|t"
                        GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. TexturedIcon .. " +" .. KeystoneLevel .. " |r" .. Keystone, UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                    elseif Keystone then
                        GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. NoKeyTextureIcon .. " +" .. KeystoneLevel .. " |r" .. Keystone, UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                    else
                        GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. NoKeyTextureIcon .. " No Keystone", UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                    end
                else
                    GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. NoKeyTextureIcon .. " No Keystone", UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                end
            end
            if MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList then
                GameTooltip:AddLine(" ", 1, 1, 1, 1)
            end
        end
    end
end

function MS:FetchAffixes()
    if not MS.DB.global.DisplayAffixes then return end
    local TextureSize = MS.DB.global.TooltipTextureIconSize
    GameTooltip:AddLine("Current |cFFFFFFFFAffixes|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
    for i = 1, MS.NUM_OF_AFFIXES do
        local AffixID = C_MythicPlus.GetCurrentAffixes()[i].id
        local AffixName, AffixDesc, AffixIconID = C_ChallengeMode.GetAffixInfo(AffixID)
        local AffixIcon = "|T" .. AffixIconID .. ":" .. TextureSize .. ":" .. TextureSize .. ":0|t "
        GameTooltip:AddLine(AffixIcon .. AffixName, 1, 1, 1)
        if MS.DB.global.DisplayAffixDesc then
            GameTooltip:AddLine(AffixDesc, 1, 1, 1)
        end
    end
    if MS.DB.global.DisplayFriendsList then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
end

function MS:FetchFriendsList()
    if not MS.DB.global.DisplayFriendsList then return end
    local _, TotalFriends = BNGetNumFriends()
    local HasOnlineFriends = false
    for i = 1, TotalFriends do
        local AccountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if AccountInfo and AccountInfo.gameAccountInfo and AccountInfo.gameAccountInfo.clientProgram == "WoW" and AccountInfo.gameAccountInfo.className ~= nil then
            HasOnlineFriends = true
            break
        end
    end

    if HasOnlineFriends then
        GameTooltip:AddLine("Friends |cFFFFFFFFList|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
        for i = 1, TotalFriends do
            local AccountInfo = C_BattleNet.GetFriendAccountInfo(i)
            if AccountInfo then
                local FriendInfo = AccountInfo.gameAccountInfo
                local InGame = FriendInfo.clientProgram == "WoW"
                local IsAFK = FriendInfo.isGameAFK or AccountInfo.isAFK
                local IsDND = FriendInfo.isGameBusy or AccountInfo.isDND
                local FriendBNetTag = AccountInfo.accountName
                local CharacterName = FriendInfo.characterName
                local CharacterClass = FriendInfo.className
                local WoWProject = FriendInfo.wowProjectID
                local CharacterLevel = FriendInfo.characterLevel
                local ClassColour = MS.CharacterClassColours[CharacterClass]
                local FriendStatus;

                if InGame and CharacterClass ~= nil then
                    if IsDND then
                        FriendStatus = "|TInterface/AddOns/MinimapStats/Media/FriendBusy:14:14:0:0|t"
                    elseif IsAFK then
                        FriendStatus = "|TInterface/AddOns/MinimapStats/Media/FriendAway:14:14:0:0|t"
                    else
                        FriendStatus = "|TInterface/AddOns/MinimapStats/Media/FriendOnline:14:14:0:0|t"
                    end
                    GameTooltip:AddDoubleLine(FriendStatus .. "|r" .. FriendBNetTag .. ": " .. ClassColour .. CharacterName .. "|r [L|cFFFFCC40" .. CharacterLevel .. "|r]", MS.WoWProjects[WoWProject], 1, 1, 1, 1, 1, 1)
                end
            end
        end
    end
end

function MS:FetchTimeInformation()
    local ServerHr, ServerMins = GetGameTime()
    local ServerTime = string.format("%02d:%02d", ServerHr, ServerMins)
    GameTooltip:AddDoubleLine("Local Time (24H)", date("%H:%M"), MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1, 1, 1)
    GameTooltip:AddDoubleLine("Server Time", ServerTime, MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1, 1, 1)
end

function MS:CreateSystemStatsTooltip()
    if not MS.DB.global.ShowTooltip or InCombatLockdown() then return end
    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE", 0, 0)
    GameTooltip:SetPoint(MS.DB.global.TooltipAnchorFrom, Minimap, MS.DB.global.TooltipAnchorTo, MS.DB.global.TooltipXOffset, MS.DB.global.TooltipYOffset)
    MS:FetchPlayerLockouts()
    MS:FetchVaultOptions()
    if MS.OR then 
        MS:FetchKeystones()
    end
    MS:FetchAffixes()
    MS:FetchFriendsList()
    if MS.DB.global.DisplayVaultOptions or MS.DB.global.DisplayPlayerKeystone or (IsInGroup() and not IsInRaid() and MS.DB.global.DisplayPartyKeystones) or MS.DB.global.DisplayAffixes or (MS.DB.global.DisplayFriendsList ) then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
    GameTooltip:AddLine("Left-Click: " .. MS.AccentColour .. "Collect Garbage|r")
    GameTooltip:AddLine("Shift + Left-Click: " .. MS.AccentColour .. "Open Great Vault|r")
    GameTooltip:AddLine("Right-Click: " .. MS.AccentColour .. "MinimapStats Config|r")
    GameTooltip:AddLine("Middle-Click: " .. MS.AccentColour .. "Reload UI|r")
    GameTooltip:Show()
end

function MS:CreateTimeTooltip()
    if (not MS.DB.global.ShowTooltip or not MS.DB.global.DisplayTime) or InCombatLockdown() then return end
    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE", 0, 0)
    GameTooltip:SetPoint(MS.DB.global.TooltipAnchorFrom, Minimap, MS.DB.global.TooltipAnchorTo, MS.DB.global.TooltipXOffset, MS.DB.global.TooltipYOffset)
    MS:FetchTimeInformation()
    GameTooltip:AddLine(" ", 1, 1, 1, 1)
    GameTooltip:AddLine("Left-Click: " .. MS.AccentColour .. "Toggle Calendar|r")
    GameTooltip:Show()
end
