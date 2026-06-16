local _, MS = ...
local LSM = MS.LSM

local function FetchDate()
	local dateString = MS.db.global.Date.Format:gsub("%[([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])%]([^%[]*)", function(colour, text) return "|cFF" .. colour:upper() .. text .. "|r" end)
	dateString = dateString:gsub("%%(%a)", function(format)
		local ok, result = pcall(date, "%" .. format)
		return ok and result or "%" .. format
	end)
	return dateString:gsub("\\n", "\n"):gsub("%%%%", "%%")
end

function MS:CreateDate()
	local GeneralDB = MS.db.global.General
	local DB = MS.db.global.Date

	local DateFrame = CreateFrame("Frame", "MinimapStats_DateFrame", UIParent)
	DateFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
	DateFrame:SetFrameStrata(GeneralDB.FrameStrata)
	DateFrame.Text = DateFrame:CreateFontString(nil, "OVERLAY")
	DateFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
	DateFrame.Text:SetText(FetchDate())
	DateFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
	DateFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
	DateFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
	DateFrame.Text:SetPoint(DB.Layout[1], DateFrame, DB.Layout[1], 0, 0)
	DateFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
	DateFrame:SetWidth(DateFrame.Text:GetStringWidth())
	DateFrame:SetHeight(DateFrame.Text:GetStringHeight())
	if DB.Enable then
		DateFrame:Show()
		DateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		DateFrame:RegisterEvent("ZONE_CHANGED")
		DateFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
		DateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		DateFrame:SetScript("OnEvent", function(_, event, ...)
			DateFrame.Text:SetText(FetchDate())
			DateFrame:SetWidth(DateFrame.Text:GetStringWidth())
			DateFrame:SetHeight(DateFrame.Text:GetStringHeight())
		end)
	else
		DateFrame:Hide()
		DateFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		DateFrame:UnregisterEvent("ZONE_CHANGED")
		DateFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
		DateFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		DateFrame:SetScript("OnEvent", nil)
	end
	MS.DateFrame = DateFrame
end

function MS:UpdateDate()
	local GeneralDB = MS.db.global.General
	local DB = MS.db.global.Date
	if MS.DateFrame then
		MS.DateFrame:ClearAllPoints()
		MS.DateFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
		MS.DateFrame:SetFrameStrata(GeneralDB.FrameStrata)
		MS.DateFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
		MS.DateFrame.Text:SetText(FetchDate())
		MS.DateFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
		MS.DateFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
		MS.DateFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
		MS.DateFrame.Text:SetPoint(DB.Layout[1], MS.DateFrame, DB.Layout[1], 0, 0)
		MS.DateFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
		MS.DateFrame:SetWidth(MS.DateFrame.Text:GetStringWidth())
		MS.DateFrame:SetHeight(MS.DateFrame.Text:GetStringHeight())
		if DB.Enable then
			MS.DateFrame:Show()
			MS.DateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
			MS.DateFrame:RegisterEvent("ZONE_CHANGED")
			MS.DateFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
			MS.DateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			MS.DateFrame:SetScript("OnEvent", function(_, event, ...)
				MS.DateFrame.Text:SetText(FetchDate())
				MS.DateFrame:SetWidth(MS.DateFrame.Text:GetStringWidth())
				MS.DateFrame:SetHeight(MS.DateFrame.Text:GetStringHeight())
			end)
			MS.DateFrame.Text:SetText(FetchDate())
			MS.DateFrame:SetWidth(MS.DateFrame.Text:GetStringWidth())
			MS.DateFrame:SetHeight(MS.DateFrame.Text:GetStringHeight())
		else
			MS.DateFrame:Hide()
			MS.DateFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
			MS.DateFrame:UnregisterEvent("ZONE_CHANGED")
			MS.DateFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
			MS.DateFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
			MS.DateFrame:SetScript("OnEvent", nil)
			MS.DateFrame:SetScript("OnMouseDown", nil)
		end
	end
end
