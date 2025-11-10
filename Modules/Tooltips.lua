local _, MS = ...

local RaidDifficultyIDs = {
    [14] = "Normal",
    [15] = "Heroic",
    [16] = "Mythic",
    [17] = "LFR",
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
    dateString = dateString:gsub("%%(%a+)", function(fmt)
        local ok, result = pcall(date, "%" .. fmt)
        if not ok then return "%" .. fmt end
        if fmt == "b" or fmt == "B" then return string.format("|c%s%s|r", AccentColour, result) end
        return result
    end)

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
    return string.format(
        (DB.Format == "12H" and "%02d:%02d %s") or "%02d:%02d",
        (DB.Format == "12H" and ((CurrHr % 12 == 0) and 12 or (CurrHr % 12))) or CurrHr,
        CurrMin,
        (DB.Format == "12H" and ((tonumber(CurrHr) >= 12) and "|c" .. AccentColour .. "PM" .. "|r" or "|c" .. AccentColour .. "AM" .. "|r")) or ""
    )
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
        local RaidRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid)
        for i = 1, 3 do
            local DifficultyName = RaidDifficultyIDs[RaidRuns[i].level]
            if DifficultyName == nil then break end
            table.insert(RaidsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "%s|r", i, DifficultyName))
        end

        if #RaidsCompleted > 0 then
            GameTooltip:AddLine("|c" .. AccentColour .. "Raid|r |cFFFFFFFFGreat Vault|r", 1, 1, 1, 1)
            for _, Raid in pairs(RaidsCompleted) do
                GameTooltip:AddLine(Raid, 1, 1, 1)
            end
        end
    end

    local function FetchMythicPlusData()
        if not MS.db.global.Tooltip.SystemStats.Vault.Options.MythicPlus then return end
        local MythicPlusRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities)
        for i = 1, 3 do
            local KeyLevel = MythicPlusRuns[i].level
            if KeyLevel == nil or KeyLevel == 0 then break end
            table.insert(MythicPlusRunsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "+%d|r", i, KeyLevel))
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

    local function FetchWorldData()
        if not MS.db.global.Tooltip.SystemStats.Vault.Options.World then return end
        local WorldRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
        for i = 1, 3 do
            local WorldLevel = WorldRuns[i].level
            if WorldLevel == nil or WorldLevel == 0 then break end
            table.insert(WorldRunsCompleted, string.format("Slot #%d: Tier |c" .. AccentColour .. "%d|r", i, WorldLevel))
        end

        if #WorldRunsCompleted > 0 then
            if #RaidsCompleted > 0 or #MythicPlusRunsCompleted > 0 then GameTooltip:AddLine(" ", 1, 1, 1, 1) end
            GameTooltip:AddLine("|c" .. AccentColour .. "World|r |cFFFFFFFFGreat Vault|r", 1, 1, 1, 1)
            for _, Delve in pairs(WorldRunsCompleted) do
                GameTooltip:AddLine(Delve, 1, 1, 1)
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
    GameTooltip:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -2)
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
    GameTooltip:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -2)
    GameTooltip:ClearLines()

    if displayVaultOptions then
        FetchVaultOptions()
    end

    GameTooltip:AddDoubleLine(MS.RIGHT_CLICK_BUTTON .. "|c" .. AccentColour .. "Right-Click|r", "Open Configuration", 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine(MS.MIDDLE_CLICK_BUTTON .. "|c" .. AccentColour .. "Middle-Click|r", "Reload UI", 1, 1, 1, 1, 1, 1)

    GameTooltip:Show()
end

function MS:AssignTooltipScripts()
    MS.TimeFrame:SetScript("OnEnter", function(self) CreateTimeTooltip(MS.db.global.Tooltip.Time.Date, MS.db.global.Tooltip.Time.Lockouts, MS.db.global.Tooltip.Time.AlternateTime) end)
    MS.TimeFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    MS.SystemStatsFrame:SetScript("OnEnter", function(self) CreateSystemStatsTooltip(MS.db.global.Tooltip.SystemStats.Vault.Enable) end)
    MS.SystemStatsFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end