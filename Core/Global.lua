local _, MS = ...
MSG = MSG or {}
MS.AddOnName = C_AddOns.GetAddOnMetadata("MinimapStats", "Title")
MS.Version = C_AddOns.GetAddOnMetadata("MinimapStats", "Version")
MS.Author = C_AddOns.GetAddOnMetadata("MinimapStats", "Author")
MS.LSM = LibStub("LibSharedMedia-3.0")
MS.CLASS_COLOUR = {RAID_CLASS_COLORS[select(2, UnitClass("player"))].r * 255, RAID_CLASS_COLORS[select(2, UnitClass("player"))].g * 255, RAID_CLASS_COLORS[select(2, UnitClass("player"))].b * 255}
MS.InfoButton = "|A:glueannouncementpopup-icon-info:16:16|a "
MS.LEFT_CLICK_BUTTON = "|A:newplayertutorial-icon-mouse-leftbutton:20.7:15.6|a"
MS.RIGHT_CLICK_BUTTON = "|A:newplayertutorial-icon-mouse-rightbutton:20.7:15.6|a"
MS.MIDDLE_CLICK_BUTTON = "|A:newplayertutorial-icon-mouse-middlebutton:20.7:15.6|a"
MS.TestInstanceDifficulty = false

local OptionsToDB = {
    ["General"] = "General",
    ["Time"] = "Time",
    ["System Stats"] = "SystemStats",
    ["Location"] = "Location",
    ["Instance Difficulty"] = "InstanceDifficulty",
    ["Coordinates"] = "Coordinates",
    ["Tooltip"] = "Tooltip",
}

function MS:Print(MSG)
    print(MS.AddOnName .. ":|r " .. MSG)
end

function MS:SetJustification(anchorFrom)
    if anchorFrom == "TOPLEFT" or anchorFrom == "LEFT" or anchorFrom == "BOTTOMLEFT" then
        return "LEFT"
    elseif anchorFrom == "TOPRIGHT" or anchorFrom == "RIGHT" or anchorFrom == "BOTTOMRIGHT" then
        return "RIGHT"
    else
        return "CENTER"
    end
end

function MS:SetupSlashCommands()
    SLASH_MINIMAPSTATS1 = "/ms"
    SLASH_MINIMAPSTATS2 = "/minimapstats"
    SlashCmdList["MINIMAPSTATS"] = function(msg)
        if msg == "" or msg == "gui" or msg == "options" then
            MS:CreateGUI()
        elseif msg == "time" then
            MS:CreateGUI("Time")
        elseif msg == "system" or msg == "systemstats" or msg == "s" then
            MS:CreateGUI("SystemStats")
        elseif msg == "location" or msg == "loc" or msg == "l" then
            MS:CreateGUI("Location")
        elseif msg == "instance" or msg == "instancedifficulty" or msg == "i"  or msg == "id" then
            MS:CreateGUI("InstanceDifficulty")
        elseif msg == "coordinates" or msg == "coord" or msg == "c" then
            MS:CreateGUI("Coordinates")
        elseif msg == "reset" then
            MS:Reset("All")
        elseif msg == "share" then
            MS:CreateGUI("Share")
        end
    end
    MS:Print("'|cFF8080FF/ms|r' for in-game configuration.")
end

function MS:Reset(valueToReset)
    local dbValue = OptionsToDB[valueToReset]
    if valueToReset == "All" then
        for key, _ in pairs(MS.db.global) do MS.db.global[key] = CopyTable(MS.Defaults.global[key]) end
    elseif MS.db.global[dbValue] then
        MS.db.global[dbValue] = CopyTable(MS.Defaults.global[dbValue])
    end
    MS:Print("Reset " .. (valueToReset == "All" and "All Settings." or valueToReset .. " Settings."))
    MS:UpdateAll()
    if MS.GUIContainer then MS:RedrawGUI() end
end

function MS:FetchReactionColour()
    local PVPZone = C_PvP.GetZonePVPInfo()
    if PVPZone == 'arena' then
        ReactionColour = {0.84 * 255, 0.03 * 255, 0.03 * 255}
    elseif PVPZone == 'friendly' then
        ReactionColour = {0.05 * 255, 0.85 * 255, 0.03 * 255}
    elseif PVPZone == 'contested' then
        ReactionColour = {0.9 * 255, 0.85 * 255, 0.05 * 255}
    elseif PVPZone == 'hostile' then
        ReactionColour = {0.84 * 255, 0.03 * 255, 0.03 * 255}
    elseif PVPZone == 'sanctuary' then
        ReactionColour = {0.035 * 255, 0.58 * 255, 0.84 * 255}
    elseif PVPZone == 'combat' then
        ReactionColour = {0.84 * 255, 0.03 * 255, 0.03 * 255}
    else
        ReactionColour = {0.9 * 255, 0.85 * 255, 0.05 * 255}
    end
    return ReactionColour
end

function MS:UpdateAll()
    MS:UpdateTime()
    MS:UpdateSystemStats()
    MS:UpdateLocation()
    MS:UpdateInstanceDifficulty()
    MS:UpdateCoordinates()
end

function MS:ReloadPrompt(text, onAcceptText, onCancelText, onAcceptFn, onCancelFn)
    StaticPopupDialogs["MINIMAPSTATS_RELOAD"] = {
        text = text or "Reload Required to Apply Changes. Reload Now?",
        button1 = onAcceptText or "Yes, reload now!",
        button2 = onCancelText or "No, I will do it later.",
        OnAccept = onAcceptFn or function() ReloadUI() end,
        OnCancel = onCancelFn or function() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("MINIMAPSTATS_RELOAD")
end