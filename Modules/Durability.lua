local _, MS = ...
local LSM = MS.LSM

local function FetchDurabilityValueColour(durabilityPercent)
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Durability
    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])

    if DB.ColourBy == "VALUE" then
        return MS:DurabilityColourThreshold(durabilityPercent)
    elseif DB.ColourBy == "ACCENT" then
        return AccentColour
    elseif DB.ColourBy == "CUSTOM" then
        return string.format("FF%02x%02x%02x", DB.Colour[1], DB.Colour[2], DB.Colour[3])
    end

    return "FFFFFFFF"
end

local function ApplyDurabilityTextFormat(textFormat, valueText)
    local formattedText, replacements = textFormat:gsub("%%s", valueText, 1)
    if replacements == 0 then formattedText = textFormat .. valueText end
    return formattedText:gsub("%%%%", "%%")
end

local function FetchDurability()
    local DB = MS.db.global.Durability
    local textFormat = DB.Text or "%s%%"

    local bracketColour, rawFormat = textFormat:match("^%[([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])%](.+)$")
    if bracketColour and rawFormat then
        local prefixToken, suffixText = rawFormat:match("^([%w_]+)(.*)$")
        if prefixToken then textFormat = string.format("|cFF%s%s|r%s", bracketColour:upper(), prefixToken, suffixText) end
    end

    local totalDurability, maxDurability = 0, 0
    for i = 1, 18 do
        local currentDurability, maximumDurability = GetInventoryItemDurability(i)
        if currentDurability and maximumDurability then
            totalDurability = totalDurability + currentDurability
            maxDurability = maxDurability + maximumDurability
        end
    end

    if maxDurability == 0 then return ApplyDurabilityTextFormat(textFormat, "N/A") end
    local durabilityPercent = (totalDurability / maxDurability) * 100
    local valueColour = FetchDurabilityValueColour(durabilityPercent)

    local colouredValue = string.format("|c%s%.0f|r", valueColour, durabilityPercent)
    return ApplyDurabilityTextFormat(textFormat, colouredValue)
end

function MS:CreateDurability()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Durability

    local DurabilityFrame = CreateFrame("Frame", "MinimapStats_DurabilityFrame", UIParent)
    DurabilityFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    DurabilityFrame:SetFrameStrata(GeneralDB.FrameStrata)
    DurabilityFrame.Text = DurabilityFrame:CreateFontString(nil, "OVERLAY")
    DurabilityFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
    DurabilityFrame.Text:SetText(FetchDurability())
    DurabilityFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
    DurabilityFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
    DurabilityFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
    DurabilityFrame.Text:SetPoint(DB.Layout[1], DurabilityFrame, DB.Layout[1], 0, 0)
    DurabilityFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
    DurabilityFrame:SetWidth(DurabilityFrame.Text:GetStringWidth())
    DurabilityFrame:SetHeight(DurabilityFrame.Text:GetStringHeight())
    if DB.Enable then
        DurabilityFrame:Show()
        DurabilityFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        DurabilityFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        DurabilityFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        DurabilityFrame:SetScript("OnEvent", function(self, event, ...)
            self.Text:SetText(FetchDurability())
            self:SetWidth(self.Text:GetStringWidth())
            self:SetHeight(self.Text:GetStringHeight())
        end)
    else
        DurabilityFrame:Hide()
        DurabilityFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        DurabilityFrame:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        DurabilityFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
        DurabilityFrame:SetScript("OnEvent", nil)
    end
    MS.DurabilityFrame = DurabilityFrame
end

function MS:UpdateDurability()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.Durability
    if MS.DurabilityFrame then
        MS.DurabilityFrame:ClearAllPoints()
        MS.DurabilityFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        MS.DurabilityFrame:SetFrameStrata(GeneralDB.FrameStrata)
        MS.DurabilityFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
        MS.DurabilityFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
        MS.DurabilityFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
        MS.DurabilityFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
        MS.DurabilityFrame.Text:SetPoint(DB.Layout[1], MS.DurabilityFrame, DB.Layout[1], 0, 0)
        MS.DurabilityFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
        MS.DurabilityFrame:SetWidth(MS.DurabilityFrame.Text:GetStringWidth())
        MS.DurabilityFrame:SetHeight(MS.DurabilityFrame.Text:GetStringHeight())
        if DB.Enable then
            MS.DurabilityFrame:Show()
            MS.DurabilityFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            MS.DurabilityFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
            MS.DurabilityFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
            MS.DurabilityFrame:SetScript("OnEvent", function(self, event, ...)
                self.Text:SetText(FetchDurability())
                self:SetWidth(self.Text:GetStringWidth())
                self:SetHeight(self.Text:GetStringHeight())
            end)
            MS.DurabilityFrame.Text:SetText(FetchDurability())
            MS.DurabilityFrame:SetWidth(MS.DurabilityFrame.Text:GetStringWidth())
            MS.DurabilityFrame:SetHeight(MS.DurabilityFrame.Text:GetStringHeight())
        else
            MS.DurabilityFrame:Hide()
            MS.DurabilityFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            MS.DurabilityFrame:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
            MS.DurabilityFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
            MS.DurabilityFrame:SetScript("OnEvent", nil)
        end
    end
end
