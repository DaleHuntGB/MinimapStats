local _, MS = ...
local LSM = MS.LSM

local function FetchLocation()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Location
    local ReactionColour = string.format("FF%02x%02x%02x", MS:FetchReactionColour()[1], MS:FetchReactionColour()[2], MS:FetchReactionColour()[3])
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])

    if DB.ColourBy == "REACTION" then
        return string.format("|c%s%s|r", ReactionColour, DB.SubZone and (GetSubZoneText() ~= "" and GetSubZoneText() or GetZoneText()) or GetZoneText())
    elseif DB.ColourBy == "ACCENT" then
        return string.format("|c%s%s|r", AccentColour, DB.SubZone and (GetSubZoneText() ~= "" and GetSubZoneText() or GetZoneText()) or GetZoneText())
    elseif DB.ColourBy == "CUSTOM" then
        return string.format("|cFF%02x%02x%02x%s|r", DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.SubZone and (GetSubZoneText() ~= "" and GetSubZoneText() or GetZoneText()) or GetZoneText())
    end
end

function MS:CreateLocation()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Location

    local LocationFrame = CreateFrame("Frame", "MinimapStats_LocationFrame", Minimap)
    LocationFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    LocationFrame:SetFrameStrata("MEDIUM")
    LocationFrame.Text = LocationFrame:CreateFontString(nil, "OVERLAY")
    LocationFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
    LocationFrame.Text:SetText(FetchLocation())
    LocationFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
    LocationFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
    LocationFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
    LocationFrame.Text:SetPoint(DB.Layout[1], LocationFrame, DB.Layout[1], 0, 0)
    LocationFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
    LocationFrame:SetWidth(LocationFrame.Text:GetStringWidth())
    LocationFrame:SetHeight(LocationFrame.Text:GetStringHeight())
    if DB.Enable then
        LocationFrame:Show()
        LocationFrame:RegisterEvent("ZONE_CHANGED")
        LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        LocationFrame:SetScript("OnEvent", function(self, event, ...)
            self.Text:SetText(FetchLocation())
            self:SetWidth(self.Text:GetStringWidth())
            self:SetHeight(self.Text:GetStringHeight())
        end)
    else
        LocationFrame:Hide()
        LocationFrame:UnregisterEvent("ZONE_CHANGED")
        LocationFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
        LocationFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        LocationFrame:SetScript("OnEvent", nil)
    end
    MS.LocationFrame = LocationFrame
end

function MS:UpdateLocation()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Location
    if MS.LocationFrame then
        MS.LocationFrame:ClearAllPoints()
        MS.LocationFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        MS.LocationFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
        MS.LocationFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
        MS.LocationFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
        MS.LocationFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
        MS.LocationFrame.Text:SetPoint(DB.Layout[1], MS.LocationFrame, DB.Layout[1], 0, 0)
        MS.LocationFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
        MS.LocationFrame:SetWidth(MS.LocationFrame.Text:GetStringWidth())
        MS.LocationFrame:SetHeight(MS.LocationFrame.Text:GetStringHeight())
        if DB.Enable then
            MS.LocationFrame:Show()
            MS.LocationFrame:RegisterEvent("ZONE_CHANGED")
            MS.LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
            MS.LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            MS.LocationFrame:SetScript("OnEvent", function(self, event, ...)
                self.Text:SetText(FetchLocation())
                self:SetWidth(self.Text:GetStringWidth())
                self:SetHeight(self.Text:GetStringHeight())
            end)
            MS.LocationFrame.Text:SetText(FetchLocation())
            MS.LocationFrame:SetWidth(MS.LocationFrame.Text:GetStringWidth())
            MS.LocationFrame:SetHeight(MS.LocationFrame.Text:GetStringHeight())
        else
            MS.LocationFrame:Hide()
            MS.LocationFrame:UnregisterEvent("ZONE_CHANGED")
            MS.LocationFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
            MS.LocationFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
            MS.LocationFrame:SetScript("OnEvent", nil)
        end
    end
end