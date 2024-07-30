local _, MS = ...
function MS:CreateSystemStatsFrame()
    if not MS.DB.global.ShowSystemsStatsFrame then return end
    MS.SystemStatsFrame = CreateFrame("Frame", "MinimapStats_SystemStatsFrame", Minimap)
    MS.SystemStatsFrame:ClearAllPoints()
    MS.SystemStatsFrame:SetPoint(MS.DB.global.SystemStatsAnchorPosition, Minimap, MS.DB.global.SystemStatsXOffset, MS.DB.global.SystemStatsYOffset)
    MS.SystemStatsFrameText = MS.SystemStatsFrame:CreateFontString("MinimapStats_SystemStatsFrameText", "BACKGROUND")
    MS.SystemStatsFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.SystemStatsFontSize, MS.DB.global.FontFlag) 
    MS.SystemStatsFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.SystemStatsFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.SystemStatsFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.SystemStatsFrameText:SetShadowColor(0, 0, 0, 0)
        MS.SystemStatsFrameText:SetShadowOffset(0, 0)
    end
    MS.SystemStatsFrameText:SetText(MS:FetchSystemStats())
    MS.SystemStatsFrameText:ClearAllPoints()
    MS.SystemStatsFrameText:SetPoint(MS.DB.global.SystemStatsAnchorPosition, MS.SystemStatsFrame, 0, 0)
    MS.SystemStatsFrame:SetHeight(MS.SystemStatsFrameText:GetStringHeight() or 12)
    MS.SystemStatsFrame:SetWidth(MS.SystemStatsFrameText:GetStringWidth() or 220)
    MS.SystemStatsFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupSystemStatsScripts()
end

function MS:UpdateSystemStatsFrame()
    if not MS.SystemStatsFrame and MS.DB.global.ShowSystemsStatsFrame then MS:CreateSystemStatsFrame() end
    MS.SystemStatsFrame:ClearAllPoints()
    MS.SystemStatsFrame:SetPoint(MS.DB.global.SystemStatsAnchorPosition, Minimap, MS.DB.global.SystemStatsXOffset, MS.DB.global.SystemStatsYOffset)
    MS.SystemStatsFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.SystemStatsFontSize, MS.DB.global.FontFlag) 
    MS.SystemStatsFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.SystemStatsFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.SystemStatsFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.SystemStatsFrameText:SetShadowColor(0, 0, 0, 0)
        MS.SystemStatsFrameText:SetShadowOffset(0, 0)
    end
    MS.SystemStatsFrameText:SetText(MS:FetchSystemStats())
    MS.SystemStatsFrameText:ClearAllPoints()
    MS.SystemStatsFrameText:SetPoint(MS.DB.global.SystemStatsAnchorPosition, MS.SystemStatsFrame, 0, 0)
    MS.SystemStatsFrame:SetHeight(MS.SystemStatsFrameText:GetStringHeight() or 12)
    MS.SystemStatsFrame:SetWidth(MS.SystemStatsFrameText:GetStringWidth() or 220)
    MS.SystemStatsFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupSystemStatsScripts()
end

function MS:FetchSystemStats()
    local DB = MS.DB.global or {}
    local FPS = math.ceil(GetFramerate())
    local _, _, HMS, WMS = GetNetStats()
    local SystemStatsString = DB.SystemStatsFormatString
    local FPSText = FPS .. MS.AccentColour .. " FPS" .. "|r"
    local HMSText = HMS .. MS.AccentColour .. " MS" .. "|r"
    local WMSText = WMS .. MS.AccentColour .. " MS" .. "|r"
    local KeyCodes = { ["FPS"] = FPSText, ["HomeMS"] = HMSText, ["WorldMS"] = WMSText }
    for KeyCode, ValueString in pairs(KeyCodes) do
        SystemStatsString = SystemStatsString:gsub(KeyCode, ValueString)
    end    
    return SystemStatsString
end

function MS:SetupSystemStatsScripts()
    if MS.DB.global.ShowSystemsStatsFrame then
        MS.SystemStatsFrame:SetScript("OnUpdate", function(self, elapsed)
            self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
            if (self.TimeSinceLastUpdate > MS.DB.global.SystemStatsUpdateInterval) then
                MS.SystemStatsFrameText:SetText(MS:FetchSystemStats())
                self:SetHeight(MS.SystemStatsFrameText:GetStringHeight() or 12)
                self:SetWidth(MS.SystemStatsFrameText:GetStringWidth() or 220)
                self.TimeSinceLastUpdate = 0
            end
        end)
        MS.SystemStatsFrame:SetScript("OnMouseDown", function(_, mButton)
            if IsShiftKeyDown() and mButton == "LeftButton" then
                C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
                if WeeklyRewardsFrame:IsShown() then WeeklyRewardsFrame:Hide() else WeeklyRewardsFrame:Show() end
            elseif mButton == "LeftButton" then
                collectgarbage("collect")
                print(MS.ADDON_NAME .. ": Garbage Collected!")
            elseif mButton == "RightButton" then
                MS:CreateGUI()
                MS.isGUIOpen = true
            elseif mButton == "MiddleButton" then
                ReloadUI()
            end
        end)
        MS.SystemStatsFrame:SetScript("OnEnter", function() MS:CreateSystemStatsTooltip() end)
        MS.SystemStatsFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
        MS.SystemStatsFrame:RegisterEvent("ENCOUNTER_END")
        MS.SystemStatsFrame:SetScript("OnEvent", function(self, event, ...) RequestRaidInfo() end)
        MS.SystemStatsFrame:Show()
    else
        MS.SystemStatsFrame:SetScript("OnUpdate", nil)
        MS.SystemStatsFrame:SetScript("OnMouseDown", nil)
        MS.SystemStatsFrame:SetScript("OnEnter", nil)
        MS.SystemStatsFrame:SetScript("OnLeave", nil)
        MS.SystemStatsFrame:UnregisterEvent("ENCOUNTER_END")
        MS.SystemStatsFrame:SetScript("OnEvent", nil)
        MS.SystemStatsFrame:Hide()
    end
end
