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
            local RaidLockout = RaidLockout:gsub("Normal", "N"):gsub("Heroic", "H"):gsub("Mythic", "M"):gsub("Looking For Raid", "LFR"):gsub("25 Player", "25M"):gsub("10 Player", "10M")
            local RaidDisplayString = MS.AccentColour .. RaidTitle .. "|r: " .. RaidLockout
            GameTooltip:AddDoubleLine(RaidDisplayString, RaidReset, 1, 1, 1, 1, 1, 1)
        end
    end
    -- if (#DungeonLockouts > 0 or #RaidLockouts > 0) and (MS.DB.global.DisplayVaultOptions or MS.DB.global.DisplayPlayerKeystone or (IsInGroup() and MS.DB.global.DisplayPartyKeystones) or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList) then
    --     GameTooltip:AddLine(" ", 1, 1, 1, 1)
    -- end
    if (#DungeonLockouts > 0 or #RaidLockouts > 0) and (MS.DB.global.DisplayTime) then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
end

function MS:FetchVaultOptions()
    if not MS.DB.global.DisplayVaultOptions then return end
    local RaidsCompleted = {}
    local MythicPlusRunsCompleted = {}
    local DelveRunsCompleted = {}
    if not C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then C_AddOns.LoadAddOn("Blizzard_WeeklyRewards") end
    if MS.DB.global.DisplayRaidSlots then 
        local RaidRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid)
        for i = 1, 3 do
            local DifficultyName = MS.RaidDifficultyIDs[RaidRuns[i].level]
            local GViLvl = MS.RaidGreatVaultiLvls[RaidRuns[i].level]
            if DifficultyName == nil then break end
            table.insert(RaidsCompleted, string.format("Slot #%d: " .. MS.AccentColour .. "%s|r [%d]", i, DifficultyName, GViLvl))
        end
    end
    if MS.DB.global.DisplayMythicPlusSlots then
        local MythicPlusRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus)
        for i = 1, 3 do
            local KeyLevel = MythicPlusRuns[i].level
            local GViLvl = MS.MythicPlusGreatVaultiLvls[MythicPlusRuns[i].level]
            if KeyLevel == nil or KeyLevel == 0 then break end
            table.insert(MythicPlusRunsCompleted, string.format("Slot #%d: " .. MS.AccentColour .. "+%d|r [%d]", i, KeyLevel, GViLvl))
        end
    end
    if MS.DB.global.DisplayDelveSlots then
        if MS.BUILDVERSION > 110000 then
            local DelveRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Delve)

            for i = 1, 3 do
                local DelveLevel = DelveRuns[i].level
                local GViLvl = MS.DelveGreatVaultiLvls[DelveRuns[i].level]
                if DelveLevel == nil or DelveLevel == 0 then break end
                table.insert(DelveRunsCompleted, string.format("Slot #%d: " .. MS.AccentColour .. "%d|r [%d]", i, DelveLevel, GViLvl))
            end
        end
    end

    if #RaidsCompleted > 0 then
        GameTooltip:AddLine("Raid |cFFFFFFFFGreat Vault|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for _, Raid in pairs(RaidsCompleted) do
            GameTooltip:AddLine(Raid, 1, 1, 1)
        end
    end

    if #MythicPlusRunsCompleted > 0 then
        if #RaidsCompleted > 0 then
            GameTooltip:AddLine(" ", 1, 1, 1, 1)
        end
        GameTooltip:AddLine("Mythic+ |cFFFFFFFFGreat Vault|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for _, Key in pairs(MythicPlusRunsCompleted) do
            GameTooltip:AddLine(Key, 1, 1, 1)
        end
    end

    if #DelveRunsCompleted > 0 then
        if #RaidsCompleted > 0 or #MythicPlusRunsCompleted > 0 then
            GameTooltip:AddLine(" ", 1, 1, 1, 1)
        end
        GameTooltip:AddLine("Delve |cFFFFFFFFGreat Vault|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for _, Delve in pairs(DelveRunsCompleted) do
            GameTooltip:AddLine(Delve, 1, 1, 1)
        end
    end

    if (#RaidsCompleted > 0 or #MythicPlusRunsCompleted > 0 or #DelveRunsCompleted > 0) and (MS.DB.global.DisplayPlayerKeystone or (IsInGroup() and MS.DB.global.DisplayPartyKeystones) or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList) then
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
            local Keystone, _, _, KeystoneIcon = C_ChallengeMode.GetMapUIInfo(KeystoneInfo.challengeMapID)
            if Keystone and KeystoneIcon then
                local TexturedIcon = "|T" .. KeystoneIcon .. ":" .. TextureSize .. ":" .. TextureSize .. ":0|t"
                GameTooltip:AddLine(TexturedIcon .. " +" .. KeystoneLevel .. " " .. Keystone, 1, 1, 1, 1)
            elseif Keystone then
                GameTooltip:AddLine(NoKeyTextureIcon .. " +" .. KeystoneLevel .. " " .. Keystone, 1, 1, 1, 1)
            else
                GameTooltip:AddLine(NoKeyTextureIcon .. " No Keystone", 1, 1, 1, 1)
            end
        end
        if (IsInGroup() and MS.DB.global.DisplayPartyKeystones) 
        or (MS.DB.global.DisplayAffixes) 
        or MS.DB.global.DisplayFriendsList 
        then
            GameTooltip:AddLine(" ", 1, 1, 1, 1)
        end
    end
    if MS.DB.global.DisplayPartyKeystones then
        local PartyMembers = {}
        local WHITE_COLOUR_OVERRIDE = "|cFFFFFFFF"
        local IsInDelve = select(4, GetInstanceInfo())
        if IsInGroup() and not IsInRaid() and not IsInDelve then
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
                    local Keystone, _, _, KeystoneIcon = C_ChallengeMode.GetMapUIInfo(KeystoneInfo.challengeMapID)
                    local KeystoneLevel = KeystoneInfo.level
                    if Keystone and KeystoneIcon then
                        local TexturedIcon = "|T" .. KeystoneIcon .. ":" .. TextureSize .. ":" .. TextureSize .. ":0|t"
                        GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. TexturedIcon .. " +" .. KeystoneLevel .. " " .. Keystone .. "|r", UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                    elseif Keystone then
                        GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. NoKeyTextureIcon .. " +" .. KeystoneLevel .. " |r" .. Keystone, UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                    else
                        GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. NoKeyTextureIcon .. " No Keystone", UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                    end
                else
                    GameTooltip:AddLine(FormattedUnitName .. ": " .. WHITE_COLOUR_OVERRIDE .. NoKeyTextureIcon .. " No Keystone", UnitClassColour.r, UnitClassColour.g, UnitClassColour.b)
                end
            end
            if (MS.DB.global.DisplayAffixes) 
            or MS.DB.global.DisplayFriendsList 
            then
                GameTooltip:AddLine(" ", 1, 1, 1, 1)
            end
        end
    end
end

function MS:FetchAffixes()
    if not MS.DB.global.DisplayAffixes then return end
    local TextureSize = MS.DB.global.TooltipTextureIconSize
    GameTooltip:AddLine("Current |cFFFFFFFFAffixes|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
    if (MS.AffixIDs[1] == nil) then
        GameTooltip:AddLine("Affix Data: |cFFFFFFFFNone Found.|r", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
    end
    for i = 1, MS.NUM_OF_AFFIXES do
        if MS.AffixIDs[i] == nil then break end
        local AffixName, AffixDesc, AffixIconID = C_ChallengeMode.GetAffixInfo(MS.AffixIDs[i].id)
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
    GameTooltip:AddDoubleLine("Local Time", date("%H:%M"), MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1, 1, 1)
    GameTooltip:AddDoubleLine("Server Time", ServerTime, MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1, 1, 1)
end

function MS:CreateSystemStatsTooltip()
    if not MS.DB.global.ShowTooltip or InCombatLockdown() then return end
    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE", 0, 0)
    GameTooltip:SetPoint(MS.DB.global.TooltipAnchorFrom, Minimap, MS.DB.global.TooltipAnchorTo, MS.DB.global.TooltipXOffset, MS.DB.global.TooltipYOffset)
    MS:FetchVaultOptions()
    if MS.OR then MS:FetchKeystones() end
    MS:FetchAffixes()
    MS:FetchFriendsList()
    if MS.DB.global.DisplayVaultOptions
    or MS.DB.global.DisplayPlayerKeystone
    or (IsInGroup() and not IsInRaid() and MS.DB.global.DisplayPartyKeystones)
    or (MS.DB.global.DisplayAffixes)
    or (MS.DB.global.DisplayFriendsList)
    then
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
    MS:FetchPlayerLockouts()
    MS:FetchTimeInformation()
    GameTooltip:AddLine(" ", 1, 1, 1, 1)
    GameTooltip:AddLine("Left-Click: " .. MS.AccentColour .. "Toggle Calendar|r")
    GameTooltip:Show()
end
