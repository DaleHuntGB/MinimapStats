local _, MS = ...

local RaidDifficultyIDs = {
    [14] = "Normal",
    [15] = "Heroic",
    [16] = "Mythic",
    [17] = "LFR",
}

local GVaultLevels = {
    ["Mythic+"] = {
        [-1]    = "Go do M0s, please.", -- Heroic :) If you have this in your vault, you are trolling for real.
        [0]     = 259,
        [2]     = 259,
        [3]     = 259,
        [4]     = 263,
        [5]     = 263,
        [6]     = 266,
        [7]     = 269,
        [8]     = 269,
        [9]     = 269,
        [10]    = 272
    },
    ["World"] = {
        [1]     = 233,
        [2]     = 237,
        [3]     = 240,
        [4]     = 243,
        [5]     = 246,
        [6]     = 253,
        [7]     = 256,
        [8]     = 259,
        [9]     = 259,
        [10]    = 259,
        [11]    = 259,
    },
    ["Raids"] = {
        [14]    = 246,
        [15]    = 259,
        [16]    = 272,
        [17]    = 233,
    }
}

local function FetchPlayerLockouts()
    local GeneralDB = MS.db.global.General
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])
    RequestRaidInfo()
    local RaidLockouts = {}
    local DungeonLockouts = {}
    for i = 1, GetNumSavedInstances() do
        local Name, _, Reset, _, IsLocked, _, _, IsRaid, _, DifficultyName, MaxEncounters, CurrentProgress, _, _ = GetSavedInstanceInfo(i)
        local Days = math.floor(Reset / 86400)
        local Hours = math.floor((Reset % 86400) / 3600)
        local Mins = math.floor((Reset % 3600) / 60)
        local ResetFormatted = Days > 0 and string.format("%dd %dh %dm", Days, Hours, Mins) or string.format("%dh %dm", Hours, Mins)
        local LockoutString = string.format("%s: %d/%d %s [|c%s%s|r]", Name, CurrentProgress, MaxEncounters, DifficultyName, AccentColour, ResetFormatted)
        if IsLocked then
            if IsRaid then
                table.insert(RaidLockouts, LockoutString)
            else
                table.insert(DungeonLockouts, LockoutString)
            end
        end
    end
    if #DungeonLockouts > 0 or #RaidLockouts > 0 and (MS.db.global.Tooltip.Time.Date or MS.db.global.Tooltip.Time.AlternateTime) then GameTooltip:AddLine(" ", 1, 1, 1, 1) end
    if #DungeonLockouts > 0 then
        GameTooltip:AddLine("|c" .. AccentColour .. "Dungeon|r |cFFFFFFFFLockouts|r", 1, 1, 1, 1)
        for _, Lockout in pairs(DungeonLockouts) do
            local DungeonTitle, DungeonLockout, DungeonReset = Lockout:match("([^:]+): (.+) %[(.+)%]")
            local DungeonLockout = DungeonLockout:gsub("Normal", "N"):gsub("Heroic", "H"):gsub("Mythic", "M")
            local DungeonDisplayString = "|c" .. AccentColour .. DungeonTitle .. "|r: " .. DungeonLockout
            GameTooltip:AddDoubleLine(DungeonDisplayString, DungeonReset, 1, 1, 1, 1, 1, 1)
        end
    end
    if #RaidLockouts > 0 then
        if #DungeonLockouts > 0 then
            GameTooltip:AddLine(" ", 1, 1, 1, 1)
        end
        GameTooltip:AddLine("|c" .. AccentColour .. "Raid|r |cFFFFFFFFLockouts|r", 1, 1, 1, 1)
        for _, Lockout in pairs(RaidLockouts) do
            local RaidTitle, RaidLockout, RaidReset = Lockout:match("([^:]+): (.+) %[(.+)%]")
            local RaidLockout = RaidLockout:gsub("Normal", "|c" .. AccentColour .. "N|r"):gsub("Heroic", "|c" .. AccentColour .. "H|r"):gsub("Mythic", "|c" .. AccentColour .. "M|r"):gsub("Looking For Raid", "|c" .. AccentColour .. "LFR|r"):gsub("25 Player", "|c" .. AccentColour .. "25M|r"):gsub("10 Player", "|c" .. AccentColour .. "10M|r")
            local RaidDisplayString = "|c" .. AccentColour .. RaidTitle .. "|r: " .. RaidLockout
            GameTooltip:AddDoubleLine(RaidDisplayString, RaidReset, 1, 1, 1, 1, 1, 1)
        end
    end
end

local function FetchDateString()
    local GeneralDB = MS.db.global.General
    local dateString = MS.db.global.Tooltip.Time.DateString
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])
    dateString = dateString:gsub("%%(%a+)", function(fmt) local ok, result = pcall(date, "%" .. fmt) if not ok then return "%" .. fmt end if fmt == "b" or fmt == "B" then return string.format("|c%s%s|r", AccentColour, result) end return result end)

    dateString = dateString:gsub("\\n", "\n")
    return dateString
end

local function FetchAlternateTime()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Time
    local CurrHr, CurrMin = nil, nil
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])
    if DB.TimeZone == "Local" then
        CurrHr, CurrMin = GetGameTime()
    elseif DB.TimeZone == "Realm" then
        CurrHr, CurrMin = date("%H"), date("%M")
    end
    return string.format( (DB.Format == "12H" and "%02d:%02d %s") or "%02d:%02d", (DB.Format == "12H" and ((CurrHr % 12 == 0) and 12 or (CurrHr % 12))) or CurrHr, CurrMin, (DB.Format == "12H" and ((tonumber(CurrHr) >= 12) and "|c" .. AccentColour .. "PM" .. "|r" or "|c" .. AccentColour .. "AM" .. "|r")) or "" )
end

local function FetchVaultOptions()
    local GeneralDB = MS.db.global.General
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])
    local RaidsCompleted = {}
    local MythicPlusRunsCompleted = {}
    local WorldRunsCompleted = {}
    if not C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then C_AddOns.LoadAddOn("Blizzard_WeeklyRewards") end

    local function FetchRaidData()
        if not MS.db.global.Tooltip.SystemStats.Vault.Options.Raid then return end
        if WeeklyRewardsUtil.HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Raid) then
            local RaidRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid)
            for i = 1, 3 do
                local DifficultyName = RaidDifficultyIDs[RaidRuns[i].level]
                if DifficultyName == nil then break end
                if MS.db.global.Tooltip.SystemStats.Vault.ItemLevel then
                    table.insert(RaidsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "%s|r - [|c%siLvl|r: %s|r]", i, DifficultyName, AccentColour, GVaultLevels["Raids"][RaidRuns[i].level]))
                else
                    table.insert(RaidsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "%s|r", i, DifficultyName))
                end
            end

            if #RaidsCompleted > 0 then
                GameTooltip:AddLine("|c" .. AccentColour .. "Raid|r |cFFFFFFFFGreat Vault|r", 1, 1, 1, 1)
                for _, Raid in pairs(RaidsCompleted) do
                    GameTooltip:AddLine(Raid, 1, 1, 1)
                end
            end
        end
    end

    local function FetchMythicPlusData()
        if not MS.db.global.Tooltip.SystemStats.Vault.Options.MythicPlus then return end
        if WeeklyRewardsUtil.HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Activities) then
            local MythicPlusRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities)
            for i = 1, 3 do
                local KeyLevel = MythicPlusRuns[i].level
                if KeyLevel == nil or KeyLevel == 0 then break end
                if MS.db.global.Tooltip.SystemStats.Vault.ItemLevel then
                    table.insert(MythicPlusRunsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "+%d|r - [|c%siLvl|r: %s|r]", i, KeyLevel, AccentColour, GVaultLevels["Mythic+"][KeyLevel]))
                else
                    table.insert(MythicPlusRunsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "+%d|r", i, KeyLevel))
                end
            end

            if #MythicPlusRunsCompleted > 0 then
                if #RaidsCompleted > 0 then
                    GameTooltip:AddLine(" ", 1, 1, 1, 1)
                end
                GameTooltip:AddLine("|c" .. AccentColour .. "Mythic+|r |cFFFFFFFFGreat Vault|r", 1, 1, 1, 1)
                for _, Key in pairs(MythicPlusRunsCompleted) do
                    GameTooltip:AddLine(Key, 1, 1, 1)
                end
            end
        end
    end

    local function FetchWorldData()
        if not MS.db.global.Tooltip.SystemStats.Vault.Options.World then return end
        if WeeklyRewardsUtil.HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.World) then
            local WorldRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
            for i = 1, 3 do
                local WorldLevel = WorldRuns[i].level
                if WorldLevel == nil or WorldLevel == 0 then break end
                if MS.db.global.Tooltip.SystemStats.Vault.ItemLevel then
                    table.insert(WorldRunsCompleted, string.format("Slot #%d: Tier |c" .. AccentColour .. "%d|r - [|c%siLvl|r: %s|r]", i, WorldLevel, AccentColour, GVaultLevels["World"][WorldLevel]))
                else
                    table.insert(WorldRunsCompleted, string.format("Slot #%d: Tier |c" .. AccentColour .. "%d|r", i, WorldLevel))
                end
            end

            if #WorldRunsCompleted > 0 then
                if #RaidsCompleted > 0 or #MythicPlusRunsCompleted > 0 then GameTooltip:AddLine(" ", 1, 1, 1, 1) end
                GameTooltip:AddLine("|c" .. AccentColour .. "World|r |cFFFFFFFFGreat Vault|r", 1, 1, 1, 1)
                for _, Delve in pairs(WorldRunsCompleted) do
                    GameTooltip:AddLine(Delve, 1, 1, 1)
                end
            end
        end
    end

    FetchRaidData()
    FetchMythicPlusData()
    FetchWorldData()

    if #RaidsCompleted > 0 or #MythicPlusRunsCompleted > 0 or #WorldRunsCompleted > 0 then GameTooltip:AddLine(" ", 1, 1, 1, 1) end
end

local function CreateTimeTooltip(displayDate, displayLockouts, displayAlternateTime)
    local GeneralDB = MS.db.global.General
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])

    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE")
    GameTooltip:SetPoint(MS.db.global.Tooltip.Position.AnchorFrom, Minimap, MS.db.global.Tooltip.Position.AnchorTo, MS.db.global.Tooltip.Position.OffsetX, MS.db.global.Tooltip.Position.OffsetY)
    GameTooltip:ClearLines()

    if displayDate and not displayAlternateTime then
        local dateString = date(FetchDateString())
        GameTooltip:AddLine(dateString, 1, 1, 1)
    elseif displayDate and displayAlternateTime then
        local dateString = date(FetchDateString())
        local alternateTimeString = string.format("|c%s%s|r Time: %s", AccentColour, MS.db.global.Time.TimeZone == "Local" and "Server" or "Local", FetchAlternateTime())
        GameTooltip:AddDoubleLine(dateString, alternateTimeString, 1, 1, 1, 1, 1, 1)
    elseif not displayDate and displayAlternateTime then
        local alternateTimeString = string.format("|c%s%s|r Time: %s", AccentColour, MS.db.global.Time.TimeZone == "Local" and "Server" or "Local", FetchAlternateTime())
        GameTooltip:AddLine(alternateTimeString, 1, 1, 1)
    end

    if displayLockouts then FetchPlayerLockouts() end

    if displayLockouts or displayDate or displayAlternateTime then GameTooltip:AddLine(" ", 1, 1, 1, 1) end
    GameTooltip:AddDoubleLine(MS.LEFT_CLICK_BUTTON .. "|c" .. AccentColour .. "Left-Click|r", "Open Calendar", 1, 1, 1, 1, 1, 1)

    GameTooltip:Show()
end

local function CreateSystemStatsTooltip(displayVaultOptions)
    local GeneralDB = MS.db.global.General
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])

    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE")
    GameTooltip:SetPoint(MS.db.global.Tooltip.Position.AnchorFrom, Minimap, MS.db.global.Tooltip.Position.AnchorTo, MS.db.global.Tooltip.Position.OffsetX, MS.db.global.Tooltip.Position.OffsetY)
    GameTooltip:ClearLines()

    if displayVaultOptions then FetchVaultOptions() end

    GameTooltip:AddDoubleLine(MS.LEFT_CLICK_BUTTON .. "|c" .. AccentColour .. "Left-Click|r", "Open Great Vault", 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine(MS.RIGHT_CLICK_BUTTON .. "|c" .. AccentColour .. "Right-Click|r", "Open Configuration", 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine(MS.MIDDLE_CLICK_BUTTON .. "|c" .. AccentColour .. "Middle-Click|r", "Reload UI", 1, 1, 1, 1, 1, 1)

    GameTooltip:Show()
end

local function CreateDurabilityTooltip()
    if not MS.db.global.Tooltip.Durability.Enable then return end
    local TooltipDB = MS.db.global.Tooltip.Position

    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE")
    GameTooltip:SetPoint(TooltipDB.AnchorFrom, Minimap, TooltipDB.AnchorTo, TooltipDB.OffsetX, TooltipDB.OffsetY)
    GameTooltip:ClearLines()

    local TotalPercent = 0
    local ItemCount = 0

    local InventorySlots = {
        [1] = "HEADSLOT",
        [2] = "NECKSLOT",
        [3] = "SHOULDERSLOT",
        [4] = "SHIRTSLOT",
        [5] = "CHESTSLOT",
        [6] = "WAISTSLOT",
        [7] = "LEGSSLOT",
        [8] = "FEETSLOT",
        [9] = "WRISTSLOT",
        [10] = "HANDSSLOT",
        [11] = "FINGER1SLOT",
        [12] = "FINGER2SLOT",
        [13] = "TRINKET1SLOT",
        [14] = "TRINKET2SLOT",
        [15] = "BACKSLOT",
        [16] = "MAINHANDSLOT",
        [17] = "OFFHANDSLOT",
        [18] = "RANGEDSLOT"
    }

    local PrettyInventorySlot = {
        ["HEADSLOT"] = "Head",
        ["NECKSLOT"] = "Neck",
        ["SHOULDERSLOT"] = "Shoulder",
        ["SHIRTSLOT"] = "Shirt",
        ["CHESTSLOT"] = "Chest",
        ["WAISTSLOT"] = "Waist",
        ["LEGSSLOT"] = "Legs",
        ["FEETSLOT"] = "Feet",
        ["WRISTSLOT"] = "Wrists",
        ["HANDSSLOT"] = "Hands",
        ["FINGER1SLOT"] = "Finger 1",
        ["FINGER2SLOT"] = "Finger 2",
        ["TRINKET1SLOT"] = "Trinket 1",
        ["TRINKET2SLOT"] = "Trinket 2",
        ["BACKSLOT"] = "Back",
        ["MAINHANDSLOT"] = "Main Hand",
        ["OFFHANDSLOT"] = "Off Hand",
        ["RANGEDSLOT"] = "Ranged"
    }

    for slot = 1, 18 do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum and maximum > 0 then
            local percent = (current / maximum) * 100
            local colour = MS:DurabilityColourThreshold(percent)
            local slotName = PrettyInventorySlot[InventorySlots[slot]] or InventorySlots[slot]

            GameTooltip:AddDoubleLine(slotName, string.format("|c%s%.0f%%|r", colour, percent), 1, 1, 1, 1, 1, 1 )

            TotalPercent = TotalPercent + percent
            ItemCount = ItemCount + 1
        end
    end

    if ItemCount > 0 then
        GameTooltip:AddLine(" ")
        local average = TotalPercent / ItemCount
        local avgColour = MS:DurabilityColourThreshold(average)
        GameTooltip:AddDoubleLine( "Average", string.format("|c%s%.0f%%|r", avgColour, average), 1, 1, 1, 1, 1, 1 )
    else return
    end

    GameTooltip:Show()
end

function MS:AssignTooltipScripts()
    MS.TimeFrame:SetScript("OnEnter", function(self) CreateTimeTooltip(MS.db.global.Tooltip.Time.Date, MS.db.global.Tooltip.Time.Lockouts, MS.db.global.Tooltip.Time.AlternateTime) end)
    MS.TimeFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    MS.SystemStatsFrame:SetScript("OnEnter", function(self) CreateSystemStatsTooltip(MS.db.global.Tooltip.SystemStats.Vault.Enable) end)
    MS.SystemStatsFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    MS.DurabilityFrame:SetScript("OnEnter", function(self) CreateDurabilityTooltip() end)
    MS.DurabilityFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end