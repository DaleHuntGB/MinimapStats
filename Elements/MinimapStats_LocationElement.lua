function MS:CreateLocationFrame()
    if not MS.DB.global.ShowLocationFrame then return end
    MS.LocationFrame = CreateFrame("Frame", "MinimapStats_LocationFrame", Minimap)
    MS.LocationFrame:ClearAllPoints()
    MS.LocationFrame:SetPoint(MS.DB.global.LocationAnchorPosition, Minimap, MS.DB.global.LocationXOffset, MS.DB.global.LocationYOffset)
    MS.LocationFrameText = MS.LocationFrame:CreateFontString("MinimapStats_LocationFrameText", "BACKGROUND")
    MS.LocationFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.LocationFontSize, MS.DB.global.FontFlag)
    MS.LocationFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.LocationFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.LocationFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.LocationFrameText:SetShadowColor(0, 0, 0, 0)
        MS.LocationFrameText:SetShadowOffset(0, 0)
    end
    MS.LocationFrameText:SetText(MS:FetchLocation())
    MS.LocationFrameText:ClearAllPoints()
    MS.LocationFrameText:SetPoint(MS.DB.global.LocationAnchorPosition, MS.LocationFrame, 0, 0)
    MS.LocationFrame:SetHeight(MS.LocationFrameText:GetStringHeight() or 12)
    MS.LocationFrame:SetWidth(MS.LocationFrameText:GetStringWidth() or 220)
    MS.LocationFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupLocationScripts()
end

function MS:UpdateLocationFrame()
    if not MS.LocationFrame and MS.DB.global.ShowLocationFrame then MS:CreateLocationFrame() end
    MS.LocationFrame = CreateFrame("Frame", "MinimapStats_LocationFrame", Minimap)
    MS.LocationFrame:ClearAllPoints()
    MS.LocationFrame:SetPoint(MS.DB.global.LocationAnchorPosition, Minimap, MS.DB.global.LocationXOffset, MS.DB.global.LocationYOffset)
    MS.LocationFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.LocationFontSize, MS.DB.global.FontFlag)
    MS.LocationFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.LocationFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.LocationFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.LocationFrameText:SetShadowColor(0, 0, 0, 0)
        MS.LocationFrameText:SetShadowOffset(0, 0)
    end
    MS.LocationFrameText:SetText(MS:FetchLocation())
    MS.LocationFrameText:ClearAllPoints()
    MS.LocationFrameText:SetPoint(MS.DB.global.LocationAnchorPosition, MS.LocationFrame, 0, 0)
    MS.LocationFrame:SetHeight(MS.LocationFrameText:GetStringHeight() or 12)
    MS.LocationFrame:SetWidth(MS.LocationFrameText:GetStringWidth() or 220)
    MS.LocationFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupLocationScripts()
end

function MS:FetchLocation()
    local ZoneName = GetMinimapZoneText()
    local ColourHighlight = MS:CalculateHexColour(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.LocationColourFormat == "Primary" then
        ColourHighlight = MS:CalculateHexColour(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    elseif MS.DB.global.LocationColourFormat == "Reaction" then
        ColourHighlight = MS:SetReactionColour()
    elseif MS.DB.global.LocationColourFormat == "Accent" then
        ColourHighlight = MS:CalculateHexColour(MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
    elseif MS.DB.global.LocationColourFormat == "Custom" then
        ColourHighlight = MS:CalculateHexColour(MS.DB.global.LocationColourR, MS.DB.global.LocationColourG, MS.DB.global.LocationColourB)
    end
    return string.format("%s%s|r", ColourHighlight, ZoneName)
end

function MS:SetupLocationScripts()
    if MS.DB.global.ShowLocationFrame then
        MS.LocationFrame:RegisterEvent("ZONE_CHANGED")
        MS.LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        MS.LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        MS.LocationFrame:SetScript("OnEvent", function(self, event, ...)
            MS.LocationFrameText:SetText(MS:FetchLocation())
            self:SetHeight(MS.LocationFrameText:GetStringHeight() or 12)
            self:SetWidth(MS.LocationFrameText:GetStringWidth() or 220)
            
        end)
        MS.LocationFrame:Show()
    else
        MS.LocationFrame:SetScript("OnEvent", nil)
        MS.LocationFrame:Hide()
    end
end