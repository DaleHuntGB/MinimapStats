local _, MS = ...
local isMouseOver = false
function MS:CreateTimeFrame()
    if not MS.DB.global.ShowTimeFrame then return end
    MS.TimeFrame = CreateFrame("Frame", "MinimapStats_TimeFrame", Minimap)
    MS.TimeFrame:ClearAllPoints()
    MS.TimeFrame:SetPoint(MS.DB.global.TimeAnchorPosition, MS.DB.global.TimeXOffset, MS.DB.global.TimeYOffset)
    MS.TimeFrameText = MS.TimeFrame:CreateFontString("MinimapStats_TimeFrameText", "BACKGROUND")
    MS.TimeFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.TimeFontSize, MS.DB.global.FontFlag)
    MS.TimeFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.TimeFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.TimeFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.TimeFrameText:SetShadowColor(0, 0, 0, 0)
        MS.TimeFrameText:SetShadowOffset(0, 0)
    end
    MS.TimeFrameText:SetText(MS:FetchTime())
    MS.TimeFrameText:ClearAllPoints()
    MS.TimeFrameText:SetPoint(MS.DB.global.TimeAnchorPosition, MS.TimeFrame, 0, 0)
    MS.TimeFrame:SetHeight(MS.TimeFrameText:GetStringHeight() or 21)
    MS.TimeFrame:SetWidth(MS.TimeFrameText:GetStringWidth() or 220)
    MS.TimeFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupTimeScripts()
end

function MS:UpdateTimeFrame()
    if not MS.TimeFrame and MS.DB.global.ShowTimeFrame then MS:CreateTimeFrame() end
    MS.TimeFrame:ClearAllPoints()
    MS.TimeFrame:SetPoint(MS.DB.global.TimeAnchorPosition, MS.DB.global.TimeXOffset, MS.DB.global.TimeYOffset)
    MS.TimeFrameText:SetFont(MS.DB.global.FontFace, MS.DB.global.TimeFontSize, MS.DB.global.FontFlag)
    MS.TimeFrameText:SetTextColor(MS.DB.global.FontColourR, MS.DB.global.FontColourG, MS.DB.global.FontColourB)
    if MS.DB.global.FontShadow then
        MS.TimeFrameText:SetShadowColor(MS.DB.global.ShadowColorR, MS.DB.global.ShadowColorG, MS.DB.global.ShadowColorB, 1)
        MS.TimeFrameText:SetShadowOffset(MS.DB.global.ShadowOffsetX, MS.DB.global.ShadowOffsetY)
    else
        MS.TimeFrameText:SetShadowColor(0, 0, 0, 0)
        MS.TimeFrameText:SetShadowOffset(0, 0)
    end
    MS.TimeFrameText:SetText(MS:FetchTime())
    MS.TimeFrameText:ClearAllPoints()
    MS.TimeFrameText:SetPoint(MS.DB.global.TimeAnchorPosition, MS.TimeFrame, 0, 0)
    MS.TimeFrame:SetHeight(MS.TimeFrameText:GetStringHeight() or 21)
    MS.TimeFrame:SetWidth(MS.TimeFrameText:GetStringWidth() or 220)
    MS.TimeFrame:SetFrameStrata(MS.DB.global.ElementFrameStrata)
    MS:SetupTimeScripts()
end

function MS:FetchTime()
    local Current24Hr, Current12Hr, CurrentMins, AMPMIndicator = date("%H"), date("%I"), date("%M"), date("%p") -- 24Hr, 12Hr, Mins, AM/PM
    local ServerHr, ServerMins = GetGameTime()
    local Server12Hr = ServerHr > 12 and ServerHr - 12 or ServerHr
    local TimeString = ""
    local AccentColour = MS:CalculateHexColour(MS.DB.global.AccentColourR, MS.DB.global.AccentColourG, MS.DB.global.AccentColourB)
    if MS.DB.global.TimeFormat == "24H" then
        if MS.DB.global.TimeType == "LOCAL" then
            TimeString = Current24Hr..":"..CurrentMins
        elseif MS.DB.global.TimeType == "SERVER" then
            if ServerHr < 10 then ServerHr = "0"..ServerHr end
            if ServerMins < 10 then ServerMins = "0"..ServerMins end
            TimeString = ServerHr..":"..ServerMins
        end
    elseif MS.DB.global.TimeFormat == "12H" then
        if MS.DB.global.TimeType == "LOCAL" then
            TimeString = Current12Hr..":"..CurrentMins.." " .. AccentColour .. AMPMIndicator .. "|r"
        elseif MS.DB.global.TimeType == "SERVER" then
            if Server12Hr == 0 then Server12Hr = 12 end
            if Server12Hr < 10 then Server12Hr = "0"..Server12Hr end
            if ServerMins < 10 then ServerMins = "0"..ServerMins end
            TimeString = Server12Hr..":"..ServerMins.." ".. AccentColour .. (ServerHr > 12 and "PM" or "AM") .. "|r"
        end
    end
    return TimeString
end

function MS:FetchDate()
    local CurrentDay, CurrentMonth, CurrentShortMonth, CurrentYear, CurrentLongYear = date("%d"), date("%m"), date("%b"), date("%y"), date("%Y")
    local DateString = ""
    if MS.DB.global.DateFormat == "DD/MM/YY" then
        DateString = CurrentDay.."/"..CurrentMonth.."/"..CurrentYear
    elseif MS.DB.global.DateFormat == "MM/DD/YY" then
        DateString = CurrentMonth.."/"..CurrentDay.."/"..CurrentYear
    elseif MS.DB.global.DateFormat == "YY/MM/DD" then
        DateString = CurrentYear.."/"..CurrentMonth.."/"..CurrentDay
    elseif MS.DB.global.DateFormat == "01 Jan 2020" then
        DateString = CurrentDay.." "..CurrentShortMonth.." "..CurrentLongYear
    elseif MS.DB.global.DateFormat == "Jan 01, 2020" then
        DateString = CurrentShortMonth.." "..CurrentDay..", "..CurrentLongYear
    end
    return DateString
end

function MS:SetupTimeScripts()
    if MS.DB.global.ShowTimeFrame then
        MS.TimeFrame:SetScript("OnUpdate", function(self, elapsed)
            self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
            if (self.TimeSinceLastUpdate > MS.DB.global.TimeUpdateInterval and not isMouseOver) then
                MS.TimeFrameText:SetText(MS:FetchTime())
                self:SetHeight(MS.TimeFrameText:GetStringHeight() or 21)
                self:SetWidth(MS.TimeFrameText:GetStringWidth() or 220)
                self.TimeSinceLastUpdate = 0
            end
        end)
        if MS.DB.global.MouseoverDate then
            MS.TimeFrame:SetScript("OnEnter", function()
                isMouseOver = true
                MS.TimeFrameText:SetText(MS:FetchDate())
            end)
            MS.TimeFrame:SetScript("OnLeave", function()
                isMouseOver = false
                MS.TimeFrameText:SetText(MS:FetchTime())
            end)
        else
            MS.TimeFrame:SetScript("OnEnter", nil)
            MS.TimeFrame:SetScript("OnLeave", nil)
        end
        MS.TimeFrame:SetScript("OnMouseDown", function(_, mButton)
            if mButton == "LeftButton" then
                ToggleCalendar()
            end
        end)
        MS.TimeFrame:Show()
    else
        MS.TimeFrame:SetScript("OnUpdate", nil)
        MS.TimeFrame:Hide()
    end
end