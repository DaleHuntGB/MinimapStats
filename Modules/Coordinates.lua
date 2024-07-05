local _, MS = ...
function MS:CreateCoordinatesFrame()
    if not MS.DB.global.ShowCoordinatesFrame then return end
    MS.CoordinatesFrame = CreateFrame("Frame", "MinimapStats_CoordinatesFrame", Minimap)
    MS.CoordinatesFrame:ClearAllPoints()
    MS.CoordinatesFrame:SetPoint(MS.DB.global.CoordinatesAnchorPosition, MS.DB.global.CoordinatesXOffset, MS.DB.global.CoordinatesYOffset)
    MS.CoordinatesFrameText = MS.CoordinatesFrame:CreateFontString("MinimapStats_CoordinatesFrameText", "BACKGROUND")
    MS.CoordinatesFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.CoordinatesFontSize, MS.DB.global.FontFlag)
    MS.CoordinatesFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.CoordinatesFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.CoordinatesFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.CoordinatesFrameText:SetShadowColor(0, 0, 0, 0)
        MS.CoordinatesFrameText:SetShadowOffset(0, 0)
    end
    MS.CoordinatesFrameText:SetText(MS:FetchCoordinates())
    MS.CoordinatesFrameText:ClearAllPoints()
    MS.CoordinatesFrameText:SetPoint(MS.DB.global.CoordinatesAnchorPosition, MS.CoordinatesFrame, 0, 0)
    MS.CoordinatesFrame:SetHeight(MS.CoordinatesFrameText:GetStringHeight() or 21)
    MS.CoordinatesFrame:SetWidth(MS.CoordinatesFrameText:GetStringWidth() or 220)
    MS.CoordinatesFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupCoordinatesScripts()
end

function MS:UpdateCoordinatesFrame()
    if not MS.CoordinatesFrame and MS.DB.global.ShowCoordinatesFrame then MS:CreateCoordinatesFrame() end
    MS.CoordinatesFrame:ClearAllPoints()
    MS.CoordinatesFrame:SetPoint(MS.DB.global.CoordinatesAnchorPosition, MS.DB.global.CoordinatesXOffset, MS.DB.global.CoordinatesYOffset)
    MS.CoordinatesFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.CoordinatesFontSize, MS.DB.global.FontFlag)
    MS.CoordinatesFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.CoordinatesFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.CoordinatesFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.CoordinatesFrameText:SetShadowColor(0, 0, 0, 0)
        MS.CoordinatesFrameText:SetShadowOffset(0, 0)
    end
    MS.CoordinatesFrameText:SetText(MS:FetchCoordinates())
    MS.CoordinatesFrameText:ClearAllPoints()
    MS.CoordinatesFrameText:SetPoint(MS.DB.global.CoordinatesAnchorPosition, MS.CoordinatesFrame, 0, 0)
    MS.CoordinatesFrame:SetHeight(MS.CoordinatesFrameText:GetStringHeight() or 21)
    MS.CoordinatesFrame:SetWidth(MS.CoordinatesFrameText:GetStringWidth() or 220)
    MS.CoordinatesFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupCoordinatesScripts()
end

function MS:FetchCoordinates()
    local PlayerMap = C_Map.GetBestMapForUnit("player")
    local InstanceType = select(2, IsInInstance())
    local CoordinatesString = ""
    if InstanceType == "none" and PlayerMap then
        local PlayerPosition = C_Map.GetPlayerMapPosition(PlayerMap, "player")
        if PlayerPosition then
            local PositionX, PositionY = PlayerPosition:GetXY()
            PositionXActual = PositionX * 100
            PositionYActual = PositionY * 100
            if MS.DB.global.CoordinatesFormat == "0, 0" then
                CoordinatesString = format("%d, %d", PositionXActual, PositionYActual)
            elseif MS.DB.global.CoordinatesFormat == "0.0, 0.0" then
                CoordinatesString = format("%.1f, %.1f", PositionXActual, PositionYActual)
            elseif MS.DB.global.CoordinatesFormat == "0.00, 0.00" then
                CoordinatesString = format("%.2f, %.2f", PositionXActual, PositionYActual)
            end
        else
            CoordinatesString = ""
        end
    end
    return CoordinatesString
end

function MS:SetupCoordinatesScripts()
    if MS.DB.global.ShowCoordinatesFrame then
        MS.CoordinatesFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        MS.CoordinatesFrame:SetScript("OnEvent", function(self, event, ...)
            MS.CoordinatesFrameText:SetText(MS:FetchCoordinates())
            self:SetHeight(MS.CoordinatesFrameText:GetStringHeight() or 21)
            self:SetWidth(MS.CoordinatesFrameText:GetStringWidth() or 220)
        end)
        if MS.DB.global.CoordinatesUpdateInRealTime then 
            MS.CoordinatesFrame:SetScript("OnUpdate", function(self)
                MS.CoordinatesFrameText:SetText(MS:FetchCoordinates())
                self:SetHeight(MS.CoordinatesFrameText:GetStringHeight() or 21)
                self:SetWidth(MS.CoordinatesFrameText:GetStringWidth() or 220)
            end)
        elseif not MS.DB.global.CoordinatesUpdateInRealTime then
            MS.CoordinatesFrame:SetScript("OnUpdate", function(self, elapsed)
                self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
                if self.TimeSinceLastUpdate >= MS.DB.global.CoordinatesUpdateInterval then
                    self.TimeSinceLastUpdate = 0
                    MS.CoordinatesFrameText:SetText(MS:FetchCoordinates())
                    self:SetHeight(MS.CoordinatesFrameText:GetStringHeight() or 21)
                    self:SetWidth(MS.CoordinatesFrameText:GetStringWidth() or 220)
                end
            end)
        end
        MS.CoordinatesFrame:Show()
    else
        MS.CoordinatesFrame:SetScript("OnUpdate", nil)
        MS.CoordinatesFrame:SetScript("OnEvent", nil)
        MS.CoordinatesFrame:Hide()
    end
end