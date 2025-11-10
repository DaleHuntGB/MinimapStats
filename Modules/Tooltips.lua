local _, MS = ...

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
    if #DungeonLockouts > 0 or #RaidLockouts > 0 and MS.db.global.Tooltip.Time.Date then GameTooltip:AddLine(" ", 1, 1, 1, 1) end
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

local function CreateTimeTooltip(displayDate, displayLockouts)
    GameTooltip:SetOwner(Minimap, "ANCHOR_NONE")
    GameTooltip:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -2, -1)
    GameTooltip:ClearLines()

    if displayDate then
        local dateString = date(FetchDateString())
        GameTooltip:AddLine(dateString, 1, 1, 1)
    end

    if displayLockouts then
        FetchPlayerLockouts()
    end

    GameTooltip:Show()
end

function MS:AssignTooltipScripts()
    MS.TimeFrame:SetScript("OnEnter", function() CreateTimeTooltip(MS.db.global.Tooltip.Time.Date, MS.db.global.Tooltip.Time.Lockouts) end)
    MS.TimeFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end