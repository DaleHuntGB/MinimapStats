local _, MS = ...
local LSM = MS.LSM

local function FetchCoordinates()
    local DB = MS.db.global.Coordinates
    local GeneralDB = MS.db.global.General
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])
    local PlayerMap = C_Map.GetBestMapForUnit("player")
    local InstanceType = select(2, IsInInstance())
    local CoordinatesString = ""
    if DB.ColourBy == "ACCENT" then
        AccentColour = AccentColour
    elseif DB.ColourBy == "CUSTOM" then
        AccentColour = string.format("FF%02x%02x%02x", DB.Colour[1], DB.Colour[2], DB.Colour[3])
    end
    if InstanceType == "none" and PlayerMap then
        local PlayerPosition = C_Map.GetPlayerMapPosition(PlayerMap, "player")
        if PlayerPosition then
            local PositionX, PositionY = PlayerPosition:GetXY()
            PositionXActual = PositionX * 100
            PositionYActual = PositionY * 100
            if MS.db.global.Coordinates.Format == "NONE" then
                CoordinatesString = format("|c%s%.0f|r|cFFFFFFFF,|r |c%s%.0f|r", AccentColour, PositionXActual, AccentColour, PositionYActual)
            elseif MS.db.global.Coordinates.Format == "SINGLE" then
                CoordinatesString = format("|c%s%.1f|r|cFFFFFFFF,|r |c%s%.1f|r", AccentColour, PositionXActual, AccentColour, PositionYActual)
            elseif MS.db.global.Coordinates.Format == "DOUBLE" then
                CoordinatesString = format("|c%s%.2f|r|cFFFFFFFF,|r |c%s%.2f|r", AccentColour, PositionXActual, AccentColour, PositionYActual)
            end
        else
            CoordinatesString = ""
        end
    end
    return CoordinatesString
end

local function Coordinates_CopyCoordinates()
    local currentCoordinates = FetchCoordinates():gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    StaticPopupDialogs["COPY_DIALOG"] = {
        text = "Current Coordinates:",
        button1 = "Okay",
        OnAccept = function() end,
        hasEditBox = true,
        maxLetters = 255,
        editBoxWidth = 300,
        OnShow = function(self)
            self.EditBox:SetText(currentCoordinates)
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        timeout = 0,
        whileDead = true,
    }
    StaticPopup_Show("COPY_DIALOG")
end

function MS:CreateCoordinates()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Coordinates

    local CoordinatesFrame = CreateFrame("Frame", "MinimapStats_CoordinatesFrame", UIParent)
    CoordinatesFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    CoordinatesFrame:SetFrameStrata("MEDIUM")
    CoordinatesFrame.Text = CoordinatesFrame:CreateFontString(nil, "OVERLAY")
    CoordinatesFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
    CoordinatesFrame.Text:SetText(FetchCoordinates())
    CoordinatesFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
    CoordinatesFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
    CoordinatesFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
    CoordinatesFrame.Text:SetPoint(DB.Layout[1], CoordinatesFrame, DB.Layout[1], 0, 0)
    CoordinatesFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
    CoordinatesFrame:SetWidth(CoordinatesFrame.Text:GetWidth())
    CoordinatesFrame:SetHeight(CoordinatesFrame.Text:GetHeight())
    if DB.Enable then
        CoordinatesFrame:Show()
        CoordinatesFrame:SetScript("OnUpdate", function(self, elapsed)
            self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
            if self.TimeSinceLastUpdate >= DB.UpdateInterval then
                self.Text:SetText(FetchCoordinates())
                self:SetWidth(self.Text:GetWidth())
                self:SetHeight(self.Text:GetHeight())
                self.TimeSinceLastUpdate = 0
            end
        end)
        CoordinatesFrame:SetScript("OnMouseDown", Coordinates_CopyCoordinates)
    else
        CoordinatesFrame:Hide()
        CoordinatesFrame:SetScript("OnUpdate", nil)
        CoordinatesFrame:SetScript("OnMouseDown", nil)
    end
    MS.CoordinatesFrame = CoordinatesFrame
end

function MS:UpdateCoordinates()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Coordinates
    if MS.CoordinatesFrame then
        MS.CoordinatesFrame:ClearAllPoints()
        MS.CoordinatesFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        MS.CoordinatesFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
        MS.CoordinatesFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
        MS.CoordinatesFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
        MS.CoordinatesFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
        MS.CoordinatesFrame.Text:SetPoint(DB.Layout[1], MS.CoordinatesFrame, DB.Layout[1], 0, 0)
        MS.CoordinatesFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
        MS.CoordinatesFrame:SetWidth(MS.CoordinatesFrame.Text:GetStringWidth())
        MS.CoordinatesFrame:SetHeight(MS.CoordinatesFrame.Text:GetStringHeight())
        if DB.Enable then
            MS.CoordinatesFrame:Show()
            MS.CoordinatesFrame:SetScript("OnUpdate", function(self, elapsed)
                self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
                if self.TimeSinceLastUpdate >= DB.UpdateInterval then
                    self.Text:SetText(FetchCoordinates())
                    self:SetWidth(self.Text:GetStringWidth())
                    self:SetHeight(self.Text:GetStringHeight())
                    self.TimeSinceLastUpdate = 0
                end
            end)
            MS.CoordinatesFrame:SetScript("OnMouseDown", Coordinates_CopyCoordinates)
        else
            MS.CoordinatesFrame:Hide()
            MS.CoordinatesFrame:SetScript("OnUpdate", nil)
            MS.CoordinatesFrame:SetScript("OnMouseDown", nil)
        end
    end
end