local _, MS = ...
local LSM = MS.LSM

local function Time_OnClick(self, button)
    if button == "LeftButton" then
        ToggleCalendar()
    end
end

local function FetchTime()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Time
    local CurrHr, CurrMin = nil, nil
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])

    if DB.TimeZone == "Local" then
        CurrHr, CurrMin = date("%H"), date("%M")
    elseif DB.TimeZone == "Realm" then
        CurrHr, CurrMin = GetGameTime()
    end
    -- If AM/PM colour with accent colour, else, 24H without accent colour
    return string.format(
        (DB.Format == "12H" and "%02d:%02d %s") or "%02d:%02d",
        (DB.Format == "12H" and ((CurrHr % 12 == 0) and 12 or (CurrHr % 12))) or CurrHr,
        CurrMin,
        (DB.Format == "12H" and ((tonumber(CurrHr) >= 12) and "|c" .. AccentColour .. "PM" .. "|r" or "|c" .. AccentColour .. "AM" .. "|r")) or ""
    )
end

function MS:CreateTime()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Time

    local TimeFrame = CreateFrame("Frame", "MinimapStats_TimeFrame", UIParent)
    TimeFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    TimeFrame:SetFrameStrata("MEDIUM")
    TimeFrame.Text = TimeFrame:CreateFontString(nil, "OVERLAY")
    TimeFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
    TimeFrame.Text:SetText(FetchTime())
    TimeFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
    TimeFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
    TimeFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
    TimeFrame.Text:SetPoint(DB.Layout[1], TimeFrame, DB.Layout[1], 0, 0)
    TimeFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
    TimeFrame:SetWidth(TimeFrame.Text:GetStringWidth())
    TimeFrame:SetHeight(TimeFrame.Text:GetStringHeight())
    if DB.Enable then
        TimeFrame:Show()
        TimeFrame:SetScript("OnUpdate", function(self, elapsed)
            self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
            if self.TimeSinceLastUpdate >= DB.UpdateInterval then
                self.Text:SetText(FetchTime())
                self:SetWidth(self.Text:GetStringWidth())
                self:SetHeight(self.Text:GetStringHeight())
                self.TimeSinceLastUpdate = 0
            end
        end)
        TimeFrame:SetScript("OnMouseDown", Time_OnClick)
    else
        TimeFrame:Hide()
        TimeFrame:SetScript("OnUpdate", nil)
        TimeFrame:SetScript("OnMouseDown", nil)
    end
    MS.TimeFrame = TimeFrame
end

function MS:UpdateTime()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Time
    if MS.TimeFrame then
        MS.TimeFrame:ClearAllPoints()
        MS.TimeFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        MS.TimeFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
        MS.TimeFrame.Text:SetText(FetchTime())
        MS.TimeFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
        MS.TimeFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
        MS.TimeFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
        MS.TimeFrame.Text:SetPoint(DB.Layout[1], MS.TimeFrame, DB.Layout[1], 0, 0)
        MS.TimeFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
        MS.TimeFrame:SetWidth(MS.TimeFrame.Text:GetStringWidth())
        MS.TimeFrame:SetHeight(MS.TimeFrame.Text:GetStringHeight())
        if DB.Enable then
            MS.TimeFrame:Show()
            MS.TimeFrame:SetScript("OnUpdate", function(self, elapsed)
                self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
                if self.TimeSinceLastUpdate >= DB.UpdateInterval then
                    self.Text:SetText(FetchTime())
                    self:SetWidth(self.Text:GetStringWidth())
                    self:SetHeight(self.Text:GetStringHeight())
                    self.TimeSinceLastUpdate = 0
                end
            end)
            MS.TimeFrame:SetScript("OnMouseDown", Time_OnClick)
            MS.TimeFrame.Text:SetText(FetchTime())
            MS.TimeFrame:SetWidth(MS.TimeFrame.Text:GetStringWidth())
            MS.TimeFrame:SetHeight(MS.TimeFrame.Text:GetStringHeight())
        else
            MS.TimeFrame:Hide()
            MS.TimeFrame:SetScript("OnUpdate", nil)
            MS.TimeFrame:SetScript("OnMouseDown", nil)
        end
    end
end