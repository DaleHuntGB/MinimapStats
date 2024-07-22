local _, MS = ...
function MS:CreateInstanceDifficultyFrame()
    if not MS.DB.global.ShowInstanceDifficultyFrame then return end
    MS.InstanceDifficultyFrame = CreateFrame("Frame", "MinimapStats_InstanceDifficultyFrame", Minimap)
    MS.InstanceDifficultyFrame:ClearAllPoints()
    MS.InstanceDifficultyFrame:SetPoint(MS.DB.global.InstanceDifficultyAnchorPosition, Minimap, MS.DB.global.InstanceDifficultyXOffset, MS.DB.global.InstanceDifficultyYOffset)
    MS.InstanceDifficultyFrameText = MS.InstanceDifficultyFrame:CreateFontString("MinimapStats_InstanceDifficultyFrameText", "BACKGROUND")
    MS.InstanceDifficultyFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.InstanceDifficultyFontSize, MS.DB.global.FontFlag)
    MS.InstanceDifficultyFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.InstanceDifficultyFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.InstanceDifficultyFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.InstanceDifficultyFrameText:SetShadowColor(0, 0, 0, 0)
        MS.InstanceDifficultyFrameText:SetShadowOffset(0, 0)
    end
    MS.InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
    MS.InstanceDifficultyFrameText:ClearAllPoints()
    MS.InstanceDifficultyFrameText:SetPoint(MS.DB.global.InstanceDifficultyAnchorPosition, MS.InstanceDifficultyFrame, 0, 0)
    MS.InstanceDifficultyFrame:SetHeight(MS.InstanceDifficultyFrameText:GetStringHeight() or 12)
    MS.InstanceDifficultyFrame:SetWidth(MS.InstanceDifficultyFrameText:GetStringWidth() or 220)
    MS.InstanceDifficultyFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:HideInstanceDifficulty()
    MS:SetupInstanceDifficultyScripts()
end

function MS:HideInstanceDifficulty()
    local InstanceDifficultyIndicator = MinimapCluster.InstanceDifficulty
    local InstanceIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Instance or _G["MiniMapInstanceDifficulty"]
    local GuildIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Guild or _G["GuildInstanceDifficulty"]
    local ChallengeIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.ChallengeMode or _G["MiniMapChallengeMode"]
    if InstanceDifficultyIndicator then InstanceDifficultyIndicator:ClearAllPoints() InstanceDifficultyIndicator:SetAlpha(0) end
    if InstanceIndicator then InstanceIndicator:ClearAllPoints() InstanceIndicator:SetAlpha(0) end
    if GuildIndicator then GuildIndicator:ClearAllPoints() GuildIndicator:SetAlpha(0) end
    if ChallengeIndicator then ChallengeIndicator:ClearAllPoints() ChallengeIndicator:SetAlpha(0) end
end

function MS:UpdateInstanceDifficultyFrame()
    if not MS.InstanceDifficultyFrame then MS:CreateInstanceDifficultyFrame() end
    MS.InstanceDifficultyFrame:ClearAllPoints()
    MS.InstanceDifficultyFrame:SetPoint(MS.DB.global.InstanceDifficultyAnchorPosition, Minimap, MS.DB.global.InstanceDifficultyXOffset, MS.DB.global.InstanceDifficultyYOffset)
    MS.InstanceDifficultyFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.InstanceDifficultyFontSize, MS.DB.global.FontFlag)
    MS.InstanceDifficultyFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.InstanceDifficultyFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.InstanceDifficultyFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.InstanceDifficultyFrameText:SetShadowColor(0, 0, 0, 0)
        MS.InstanceDifficultyFrameText:SetShadowOffset(0, 0)
    end
    MS.InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
    MS.InstanceDifficultyFrameText:ClearAllPoints()
    MS.InstanceDifficultyFrameText:SetPoint(MS.DB.global.InstanceDifficultyAnchorPosition, MS.InstanceDifficultyFrame, 0, 0)
    MS.InstanceDifficultyFrame:SetHeight(MS.InstanceDifficultyFrameText:GetStringHeight() or 12)
    MS.InstanceDifficultyFrame:SetWidth(MS.InstanceDifficultyFrameText:GetStringWidth() or 220)
    MS.InstanceDifficultyFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupInstanceDifficultyScripts()
end

function MS:FetchDelveTierDifficulty(WidgetID)
    -- TODO: Check if WidgetID is consistent
    if not WidgetID then return end
    local DelveTier = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(WidgetID).tierText

    return string.format("%s", DelveTier)
end

function MS:FetchInstanceDifficulty()
    local _, _, DiffID, _, MaxPlayers, _, _, InstanceID, CurrentPlayers = GetInstanceInfo()
    local KeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local PlayerInGarrison = MS.GarrisonInstanceIDs[InstanceID]
    local InstanceDifficulty = ""

    if (DiffID == 0 or PlayerInGarrison) and MS.ShowDiffID == true then 
        InstanceDifficulty = "25" .. MS.AccentColour .. "N" .. "|r" -- Used for Testing Purposes
    elseif DiffID == 0 then
        InstanceDifficulty = ""
    elseif PlayerInGarrison then 
        InstanceDifficulty = ""
    elseif DiffID == 1 or DiffID == 3 or DiffID == 4 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "N" .. "|r"
    elseif DiffID == 2 or DiffID == 5 or DiffID == 6 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "H" .. "|r"
    elseif DiffID == 16 or DiffID == 23 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "M" .. "|r"
    elseif DiffID == 8 then 
        InstanceDifficulty = MS.AccentColour .. "M" .. "|r" .. KeystoneLevel
    elseif DiffID == 9 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "N" .. "|r"
    elseif DiffID == 7 or DiffID == 17 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "LFR" .. "|r"
    elseif DiffID == 14 then 
        InstanceDifficulty = CurrentPlayers .. MS.AccentColour .. "N" .. "|r"
    elseif DiffID == 15 then 
        InstanceDifficulty = CurrentPlayers .. MS.AccentColour .. "H" .. "|r"
    elseif DiffID == 18 or DiffID == 19 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "EVT" .. "|r"
    elseif DiffID == 24 or DiffID == 33 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "TW" .. "|r"
    elseif DiffID == 11 or DiffID == 39 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "S+" .. "|r"
    elseif DiffID == 12 or DiffID == 38 then 
        InstanceDifficulty = MaxPlayers .. MS.AccentColour .. "S" .. "|r"
    elseif DiffID == 208 then
        InstanceDifficulty = "T" .. MS.AccentColour .. MS:FetchDelveTierDifficulty(6183) .. "|r"
    end

    return string.format("%s", InstanceDifficulty)
end

function MS:SetupInstanceDifficultyScripts()
    if MS.DB.global.ShowInstanceDifficultyFrame then
        MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
        MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        MS.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        MS.InstanceDifficultyFrame:RegisterEvent("WORLD_STATE_TIMER_START")
        MS.InstanceDifficultyFrame:RegisterEvent("CHALLENGE_MODE_START")
        MS.InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        MS.InstanceDifficultyFrame:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
        MS.InstanceDifficultyFrame:SetScript("OnEvent", function(self, event, ...)
            if InCombatLockdown() then return end
            MS.InstanceDifficultyFrameText:SetText(MS:FetchInstanceDifficulty())
            self:SetHeight(MS.InstanceDifficultyFrameText:GetStringHeight() or 12)
            self:SetWidth(MS.InstanceDifficultyFrameText:GetStringWidth() or 220)
        end)
        MS.InstanceDifficultyFrame:Show()
    else
        MS.InstanceDifficultyFrame:SetScript("OnEvent", nil)
        MS.InstanceDifficultyFrame:Hide()
    end
end