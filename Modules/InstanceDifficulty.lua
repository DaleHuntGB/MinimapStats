local _, MS = ...
local LSM = MS.LSM

local GarrisonInstanceIDs = {
    [1152] = true,
    [1153] = true,
    [1154] = true,
    [1158] = true,
    [1159] = true,
    [1160] = true,
}

local function HideInstanceDifficulty()
    if not MS.db.global.InstanceDifficulty.HideBlizzardInstanceBanner then return end
    local InstanceDifficultyIndicator = MinimapCluster.InstanceDifficulty
    local InstanceIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Instance or _G["MiniMapInstanceDifficulty"]
    local GuildIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Guild or _G["GuildInstanceDifficulty"]
    local ChallengeIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.ChallengeMode or _G["MiniMapChallengeMode"]
    if InstanceDifficultyIndicator then InstanceDifficultyIndicator:SetAlpha(0) end
    if InstanceIndicator then InstanceIndicator:SetAlpha(0) end
    if GuildIndicator then GuildIndicator:SetAlpha(0) end
    if ChallengeIndicator then ChallengeIndicator:SetAlpha(0) end
end

function MS:FetchDelveTierDifficulty(WidgetID)
    if not WidgetID or WidgetID == nil then return end
    local DelveTier = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(WidgetID).tierText

    return string.format("%s", DelveTier)
end

local function FetchInstanceDifficulty()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.InstanceDifficulty
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])
    local _, _, DiffID, _, MaxPlayers, _, _, InstanceID, CurrentPlayers = GetInstanceInfo()
    local KeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local PlayerInGarrison = GarrisonInstanceIDs[InstanceID]
    local InstanceDifficulty = ""

    if (DiffID == 0 or PlayerInGarrison) and MS.TestInstanceDifficulty == true then
        InstanceDifficulty = "25" .. "|c" .. AccentColour .. (DB.Abbreviate and "N" or " Normal") .. "|r"
    elseif DiffID == 0 or PlayerInGarrison then
        InstanceDifficulty = ""
    elseif DiffID == 1 or DiffID == 3 or DiffID == 4 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "N" or " Normal") .. "|r"
    elseif DiffID == 2 or DiffID == 5 or DiffID == 6 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "H" or " Heroic") .. "|r"
    elseif DiffID == 16 or DiffID == 23 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "M" or " Mythic") .. "|r"
    elseif DiffID == 8 then
        InstanceDifficulty = "|c" .. AccentColour .. (DB.Abbreviate and "M" or "Mythic ") .. "|r" .. KeystoneLevel
    elseif DiffID == 9 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "N" or " Normal") .. "|r"
    elseif DiffID == 7 or DiffID == 17 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "LFR" or " Looking For Raid") .. "|r"
    elseif DiffID == 14 then
        InstanceDifficulty = CurrentPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "N" or " Normal") .. "|r"
    elseif DiffID == 15 then
        InstanceDifficulty = CurrentPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "H" or " Heroic") .. "|r"
    elseif DiffID == 18 or DiffID == 19 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "EVT" or " Event") .. "|r"
    elseif DiffID == 24 or DiffID == 33 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "TW" or " Timewalking") .. "|r"
    elseif DiffID == 11 or DiffID == 39 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "S+" or " Heroic Scenario") .. "|r"
    elseif DiffID == 12 or DiffID == 38 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "S" or " Scenario") .. "|r"
    elseif DiffID == 205 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. (DB.Abbreviate and "F" or " Follower") .. "|r"
    elseif DiffID == 208 then
        InstanceDifficulty = "|c" .. AccentColour .. (DB.Abbreviate and "T" or "Tier ") .. "|r" .. MS:FetchDelveTierDifficulty(6183)
    end

    return InstanceDifficulty
end

function MS:CreateInstanceDifficulty()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.InstanceDifficulty

    local InstanceDifficultyFrame = CreateFrame("Frame", "MinimapStats_InstanceDifficultyFrame", UIParent)
    InstanceDifficultyFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    InstanceDifficultyFrame:SetFrameStrata(GeneralDB.FrameStrata)
    InstanceDifficultyFrame.Text = InstanceDifficultyFrame:CreateFontString(nil, "OVERLAY")
    InstanceDifficultyFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
    InstanceDifficultyFrame.Text:SetText(FetchInstanceDifficulty())
    InstanceDifficultyFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
    InstanceDifficultyFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
    InstanceDifficultyFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
    InstanceDifficultyFrame.Text:SetPoint(DB.Layout[1], InstanceDifficultyFrame, DB.Layout[1], 0, 0)
    InstanceDifficultyFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
    InstanceDifficultyFrame:SetWidth(InstanceDifficultyFrame.Text:GetStringWidth())
    InstanceDifficultyFrame:SetHeight(InstanceDifficultyFrame.Text:GetStringHeight())
    if DB.Enable then
        HideInstanceDifficulty()
        InstanceDifficultyFrame:Show()
        InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
        InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        InstanceDifficultyFrame:SetScript("OnEvent", function(self, event, ...)
            self.Text:SetText(FetchInstanceDifficulty())
            self:SetWidth(self.Text:GetStringWidth())
            self:SetHeight(self.Text:GetStringHeight())
        end)
    else
        InstanceDifficultyFrame:Hide()
        InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED")
        InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
        InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        InstanceDifficultyFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        InstanceDifficultyFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        InstanceDifficultyFrame:SetScript("OnEvent", nil)
    end
    MS.InstanceDifficultyFrame = InstanceDifficultyFrame
end

function MS:UpdateInstanceDifficulty()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.InstanceDifficulty
    if MS.InstanceDifficultyFrame then
        MS.InstanceDifficultyFrame:ClearAllPoints()
        MS.InstanceDifficultyFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        MS.InstanceDifficultyFrame:SetFrameStrata(GeneralDB.FrameStrata)
        MS.InstanceDifficultyFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
        MS.InstanceDifficultyFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
        MS.InstanceDifficultyFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
        MS.InstanceDifficultyFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
        MS.InstanceDifficultyFrame.Text:SetPoint(DB.Layout[1], MS.InstanceDifficultyFrame, DB.Layout[1], 0, 0)
        MS.InstanceDifficultyFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
        MS.InstanceDifficultyFrame:SetWidth(MS.InstanceDifficultyFrame.Text:GetStringWidth())
        MS.InstanceDifficultyFrame:SetHeight(MS.InstanceDifficultyFrame.Text:GetStringHeight())
        if DB.Enable then
            HideInstanceDifficulty()
            MS.InstanceDifficultyFrame:Show()
            MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
            MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
            MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            MS.InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            MS.InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
            MS.InstanceDifficultyFrame:SetScript("OnEvent", function(self, event, ...)
                self.Text:SetText(FetchInstanceDifficulty())
                self:SetWidth(self.Text:GetStringWidth())
                self:SetHeight(self.Text:GetStringHeight())
            end)
            MS.InstanceDifficultyFrame.Text:SetText(FetchInstanceDifficulty())
            MS.InstanceDifficultyFrame:SetWidth(MS.InstanceDifficultyFrame.Text:GetStringWidth())
            MS.InstanceDifficultyFrame:SetHeight(MS.InstanceDifficultyFrame.Text:GetStringHeight())
        else
            MS.InstanceDifficultyFrame:Hide()
            MS.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED")
            MS.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
            MS.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
            MS.InstanceDifficultyFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            MS.InstanceDifficultyFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
            MS.InstanceDifficultyFrame:SetScript("OnEvent", nil)
        end
    end
end