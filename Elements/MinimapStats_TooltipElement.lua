function MS:FetchPlayerLockouts()
    if not MS.DB.global.DisplayLockouts then return end
    RequestRaidInfo()
    local RaidLockouts = {}
    local DungeonLockouts = {}
    for i = 1, GetNumSavedInstances() do
        local Name, _, _, _, IsLocked, _, _, IsRaid, _, DifficultyName, MaxEncounters, CurrentProgress, _, _ = GetSavedInstanceInfo(i)
        local LockoutString = string.format("%s: %d/%d %s", Name, CurrentProgress, MaxEncounters, DifficultyName)
        if IsLocked then
            if IsRaid then
                table.insert(RaidLockouts, LockoutString)
            else
                table.insert(DungeonLockouts, LockoutString)
            end
        end
    end
    if #DungeonLockouts > 0 then
        GameTooltip:AddLine("Dungeon Lockouts", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for _, Lockout in pairs(DungeonLockouts) do
            GameTooltip:AddLine(Lockout, 1, 1, 1, 1)
        end
    end
    if #RaidLockouts > 0 then
        GameTooltip:AddLine("Raid Lockouts", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
        for _, Lockout in pairs(RaidLockouts) do
            GameTooltip:AddLine(Lockout, 1, 1, 1, 1)
        end
    end
end

function MS:FetchKeystones()
    local OpenRaid = LibStub:GetLibrary("LibOpenRaid-1.0")
    local AccentColour = MS:CalculateHexColour(MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
    if not OpenRaid then return end
    if MS.DB.global.DisplayPlayerKeystone then
        local KeystoneInfo = OpenRaid.GetKeystoneInfo("player")
        local KeystoneString = AccentColour .. "Your Keystone|r: "
        if KeystoneInfo then
            local KeystoneLevel = KeystoneInfo.level
            local Keystone, _, KeystoneIcon = C_ChallengeMode.GetMapUIInfo(KeystoneInfo.mapID)
            if Keystone and KeystoneIcon then
                local TexturedIcon = "|T" .. KeystoneIcon .. "16:16:0|t"
                KeystoneString = KeystoneString .. TexturedIcon .. " +" .. KeystoneLevel .. " " .. Keystone
            elseif Keystone then
                KeystoneString = KeystoneString .. " +" .. KeystoneLevel .. " " .. Keystone
            else
                KeystoneString = KeystoneString .. "No Key Found"
            end
        end
        GameTooltip:AddLine(KeystoneString, 1, 1, 1, 1)
    end
    if MS.DB.global.DisplayPartyKeystones then
        local PartyMembers = {}
        if IsInGroup() and not IsInRaid() then
            GameTooltip:AddLine("Party Keystones", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB, 1)
            for i = 1, GetNumGroupMembers() - 1 do
                local UnitID = "party" .. i
                local UnitName = UnitName(UnitID)
                if UnitName then
                    table.insert(PartyMembers, UnitName)
                end
            end

            for _, Member in pairs(PartyMembers) do
                local UnitName = GetUnitName(Member, false)
                local _, UnitClass = UnitClass(UnitName)
                local UnitClassColour = RAID_CLASS_COLORS[UnitClass]
                local KeystoneInfo = OpenRaid.GetKeystoneInfo(UnitName)
                local KeystoneLevel = KeystoneInfo.level

                if KeystoneInfo and KeystoneLevel then
                    local Keystone, _, KeystoneIcon = C_ChallengeMode.GetMapUIInfo(KeystoneInfo.mapID)
                    if KeystoneIcon then
                        local TexturedIcon = "|T" .. KeystoneIcon .. "16:16:0|t"
                        GameTooltip:AddLine(UnitClassColour .. UnitName .. "|r: " .. TexturedIcon .. " +" .. KeystoneLevel .. " " .. Keystone, 1, 1, 1, 1)
                    else
                        GameTooltip:AddLine(UnitClassColour .. UnitName .. "|r: +" .. KeystoneLevel .. " " .. Keystone, 1, 1, 1, 1)
                    end
                end
            end
        end
    end
end

function MS:FetchAffixes()
    if not MS.DB.global.DisplayAffixes then return end
    GameTooltip:AddLine("Current Affixes", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
    for i = 1, 3 do
        local AffixID = C_MythicPlus.GetCurrentAffixes()[i].id
        local AffixName, AffixDesc, AffixIconID = C_ChallengeMode.GetAffixInfo(AffixID)
        local AffixIcon = "|T" .. AffixIconID .. ":16:16:0|t "
        if i == 1 then
            GameTooltip:AddLine(AffixIcon ..AffixName, 1, 1, 1)
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
        GameTooltip:AddLine("Friends", MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
        for i = 1, TotalFriends do
            local AccountInfo = C_BattleNet.GetFriendAccountInfo(i)
            if AccountInfo then
                local FriendInfo = AccountInfo.gameAccountInfo
                local InGame = FriendInfo.clientProgram == "WoW"
                local IsOnline = FriendInfo.isOnline
                local IsAFK = AccountInfo.isAFK
                local IsDND = AccountInfo.isDND
                local FriendBNetTag = AccountInfo.accountName
                local CharacterName = FriendInfo.characterName
                local CharacterClass = FriendInfo.className
                local CharacterLevel = FriendInfo.characterLevel
                local ClassColour = MS.CharacterClassColours[CharacterClass]
                local StatusColour;

                local OnlineColour = string.format("%02x%02x%02x", 64, 255, 64)
                local AFKColour = string.format("%02x%02x%02x", 255, 128, 64)
                local DNDColour = string.format("%02x%02x%02x", 255, 64, 64)

                if InGame and CharacterClass ~= nil then
                    if IsOnline then
                        StatusColour = OnlineColour
                    elseif IsAFK then
                        StatusColour = AFKColour
                    elseif IsDND then
                        StatusColour = DNDColour
                    end
                    GameTooltip:AddLine("|cFF"..StatusColour.."• " .."|r|cFFFFFFFF"..FriendBNetTag .. "|r: " .. ClassColour .. CharacterName .. "|r [L|cFFFFCC40" .. CharacterLevel .. "|r]", 1, 1, 1)
                end
            end
        end
    end
end

function MS:CreateTooltip()
    if not MS.DB.global.ShowTooltip or InCombatLockdown() then return end
    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE", 0, 0)
    GameTooltip:SetPoint(MS.DB.global.TooltipAnchorFrom, Minimap, MS.DB.global.TooltipAnchorTo, MS.DB.global.TooltipXOffset, MS.DB.global.TooltipYOffset)
    MS:FetchPlayerLockouts()
    MS:FetchKeystones()
    MS:FetchAffixes()
    MS:FetchFriendsList()
    GameTooltip:Show()
end