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
    if (#DungeonLockouts > 0 or #RaidLockouts > 0) and (MS.DB.global.DisplayVaultOptions or MS.DB.global.DisplayPlayerKeystone or MS.DB.global.DisplayPartyKeystones or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList) then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
end

function MS:FetchVaultOptions()
    if not MS.DB.global.DisplayVaultOptions then return end
    local MythicPlusRuns = C_MythicPlus.GetRunHistory(false, true)
    local MythicPlusRunsFormatted = {}
    -- Loop through all MythicPlusRuns, Get Dungeon Level & Max iLvl from Vault.
    for _, DungeonRun in ipairs(MythicPlusRuns) do
        local GViLvl = MS.GreatVaultiLvls[DungeonRun.level]
        table.insert(MythicPlusRunsFormatted, string.format("Level: %d [%d]", DungeonRun.level, GViLvl))
    end
    -- Sort: Highest to Lowest iLvl
    table.sort(MythicPlusRunsFormatted, function(a, b)
        return tonumber(a:match("%d+")) > tonumber(b:match("%d+"))
    end)
    for i = 9, #MythicPlusRunsFormatted do
        MythicPlusRunsFormatted[i] = nil
    end
    if #MythicPlusRuns > 0 then
        local R, G, B = MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB
        GameTooltip:AddLine("Mythic+ Runs", R, G, B)
        for DungeonNumber, VaultiLvl in ipairs(MythicPlusRunsFormatted) do
            if DungeonNumber == 1 or DungeonNumber == 4 or DungeonNumber == 8 then
                local VaultSlot = DungeonNumber == 1 and "1" or DungeonNumber == 4 and "2" or "3"
                GameTooltip:AddLine(MS.AccentColour .. "Vault Slot #" .. VaultSlot .. "|r - " .. VaultiLvl, 1, 1, 1)
            end
        end
    end
    if #MythicPlusRunsFormatted > 0 and (MS.DB.global.DisplayPlayerKeystone or MS.DB.global.DisplayPartyKeystones or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList) then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
end

function MS:FetchKeystones()
    local OpenRaid = LibStub:GetLibrary("LibOpenRaid-1.0")
    local TextureSize = MS.DB.global.TooltipTextureIconSize
    local NoKeyTextureIcon = "|TInterface/Icons/inv_relics_hourglass.blp:" .. TextureSize .. ":" .. TextureSize .. ":0|t"
    if not OpenRaid then return end
    if not MS.DB.global.DisplayPlayerKeystone and not MS.DB.global.DisplayPartyKeystones then return end
    if MS.DB.global.DisplayPlayerKeystone then
        local KeystoneInfo = OpenRaid.GetKeystoneInfo("player")
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
        if MS.DB.global.DisplayPartyKeystones or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList then
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
                local KeystoneInfo = OpenRaid.GetKeystoneInfo(UnitID)

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
    for i = 1, 3 do
        local AffixID = C_MythicPlus.GetCurrentAffixes()[i].id
        local AffixName, AffixDesc, AffixIconID = C_ChallengeMode.GetAffixInfo(AffixID)
        local AffixIcon = "|T" .. AffixIconID .. ":" .. TextureSize .. ":" .. TextureSize .. ":0|t "
        if i == 1 then
            GameTooltip:AddLine(AffixIcon .. AffixName, 1, 1, 1)
            if MS.DB.global.DisplayAffixDesc then
                GameTooltip:AddLine(AffixDesc, 1, 1, 1)
            end
        elseif i == 2 then
            GameTooltip:AddLine(AffixIcon ..AffixName, 1, 1, 1)
            if MS.DB.global.DisplayAffixDesc then
                GameTooltip:AddLine(AffixDesc, 1, 1, 1)
            end
        elseif i == 3 then
            GameTooltip:AddLine(AffixIcon ..AffixName, 1, 1, 1)
            if MS.DB.global.DisplayAffixDesc then
                GameTooltip:AddLine(AffixDesc, 1, 1, 1)
            end
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
                local IsOnline = FriendInfo.isOnline or AccountInfo.isOnline
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
                        FriendStatus = "|TInterface/AddOns/MinimapStats/Media/FriendBusy:8:8:0:0|t"
                    elseif IsAFK then
                        FriendStatus = "|TInterface/AddOns/MinimapStats/Media/FriendAway:8:8:0:0|t"
                    else
                        FriendStatus = "|TInterface/AddOns/MinimapStats/Media/FriendOnline:8:8:0:0|t"
                    end
                    GameTooltip:AddDoubleLine(FriendStatus .. " |r" .. FriendBNetTag .. ": " .. ClassColour .. CharacterName .. "|r [L|cFFFFCC40" .. CharacterLevel .. "|r]", MS.WoWProjects[WoWProject], 1, 1, 1, 1, 1, 1)
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
    MS:FetchKeystones()
    MS:FetchAffixes()
    MS:FetchFriendsList()
    if MS.DB.global.DisplayVaultOptions or MS.DB.global.DisplayPlayerKeystone or MS.DB.global.DisplayPartyKeystones or MS.DB.global.DisplayAffixes or MS.DB.global.DisplayFriendsList then
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
    end
    GameTooltip:AddLine("Left-Click: " .. MS.AccentColour .. "Collect Garbage|r")
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
