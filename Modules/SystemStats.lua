local _, MS = ...
local LSM = MS.LSM

local function SystemStats_OnClick(self, button)
    if button == "RightButton" then
        MS:CreateGUI()
    elseif button == "MiddleButton" then
        ReloadUI()
    end
end


local function FetchSystemStats()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.SystemStats
    local systemStatsString = DB.String

    local AccentColour = GeneralDB.ClassColour and string.format("FF%02x%02x%02x", MS.CLASS_COLOUR[1], MS.CLASS_COLOUR[2], MS.CLASS_COLOUR[3]) or string.format("FF%02x%02x%02x", GeneralDB.AccentColour[1], GeneralDB.AccentColour[2], GeneralDB.AccentColour[3])

    local bandWidthUpTexture = "|TInterface\\AddOns\\MinimapStats\\Media\\BandwidthUp.png:" .. DB.Layout[5] .. ":" .. DB.Layout[5] .. "|t"
    local bandWidthDownTexture = "|TInterface\\AddOns\\MinimapStats\\Media\\BandwidthDown.png:" .. DB.Layout[5] .. ":" .. DB.Layout[5] .. "|t"

    local FPS = string.format("%s|c%sFPS|r", math.floor(GetFramerate()), AccentColour)
    local bandWidthDown = string.format("%s%s", math.floor(select(1, GetNetStats())), bandWidthDownTexture)
    local bandWidthUp = string.format("%s%s", math.floor(select(2, GetNetStats())), bandWidthUpTexture)
    local latencyHome = string.format("%s|c%sMS|r", math.floor(select(3, GetNetStats())), AccentColour)
    local latencyWorld = string.format("%s|c%sMS|r", math.floor(select(4, GetNetStats())), AccentColour)

    local Replacements = {
        ["%%fps"] = FPS,
        ["%%home"] = latencyHome,
        ["%%world"] = latencyWorld,
        ["%%down"] = bandWidthDown,
        ["%%up"] = bandWidthUp,
        ["%%shortdate"] = string.format("%s |c%s%s|r %s", date("%d"), AccentColour, date("%b"), date("%y")),
        ["%%longdate"] = string.format("%s |c%s%s|r %s", date("%d"), AccentColour, date("%B"), date("%Y")),
    }

    for token, value in pairs(Replacements) do systemStatsString = systemStatsString:gsub(token, value) end

    systemStatsString = systemStatsString:gsub("%%(%a+)", function(fmt)
        local ok, result = pcall(date, "%" .. fmt)
        if not ok then return "%" .. fmt end
        if fmt == "b" or fmt == "B" then return string.format("|c%s%s|r", AccentColour, result) end
        return result
    end)

    systemStatsString = systemStatsString:gsub("\\n", "\n")
    return systemStatsString
end

function MS:CreateSystemStats()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.SystemStats

    local SystemStatsFrame = CreateFrame("Frame", "MinimapStats_SystemStatsFrame", UIParent)
    SystemStatsFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    SystemStatsFrame:SetFrameStrata("MEDIUM")
    SystemStatsFrame.Text = SystemStatsFrame:CreateFontString(nil, "OVERLAY")
    SystemStatsFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
    SystemStatsFrame.Text:SetText(FetchSystemStats())
    SystemStatsFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
    SystemStatsFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
    SystemStatsFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
    SystemStatsFrame.Text:SetPoint(DB.Layout[1], SystemStatsFrame, DB.Layout[1], 0, 0)
    SystemStatsFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
    SystemStatsFrame:SetWidth(SystemStatsFrame.Text:GetStringWidth())
    SystemStatsFrame:SetHeight(SystemStatsFrame.Text:GetStringHeight())
    if DB.Enable then
        SystemStatsFrame:Show()
        SystemStatsFrame:SetScript("OnUpdate", function(self, elapsed)
            self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
            if self.TimeSinceLastUpdate >= DB.UpdateInterval then
                self.Text:SetText(FetchSystemStats())
                self:SetWidth(self.Text:GetStringWidth())
                self:SetHeight(self.Text:GetStringHeight())
                self.TimeSinceLastUpdate = 0
            end
        end)
        SystemStatsFrame:SetScript("OnMouseDown", SystemStats_OnClick)
    else
        SystemStatsFrame:Hide()
        SystemStatsFrame:SetScript("OnUpdate", nil)
        SystemStatsFrame:SetScript("OnMouseDown", nil)
    end
    MS.SystemStatsFrame = SystemStatsFrame
end

function MS:UpdateSystemStats()
    local GeneralDB = MS.db.global.General
    local DB = MS.db.global.SystemStats
    if MS.SystemStatsFrame then
        MS.SystemStatsFrame:ClearAllPoints()
        MS.SystemStatsFrame:SetPoint(DB.Layout[1], Minimap, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        MS.SystemStatsFrame.Text:SetFont(LSM:Fetch("font", GeneralDB.Font), DB.Layout[5], GeneralDB.FontFlag)
        MS.SystemStatsFrame.Text:SetTextColor(DB.Colour[1]/255, DB.Colour[2]/255, DB.Colour[3]/255, 1)
        MS.SystemStatsFrame.Text:SetShadowColor(GeneralDB.FontShadow.Colour[1]/255, GeneralDB.FontShadow.Colour[2]/255, GeneralDB.FontShadow.Colour[3]/255, 1)
        MS.SystemStatsFrame.Text:SetShadowOffset(GeneralDB.FontShadow.OffsetX, GeneralDB.FontShadow.OffsetY)
        MS.SystemStatsFrame.Text:SetPoint(DB.Layout[1], MS.SystemStatsFrame, DB.Layout[1], 0, 0)
        MS.SystemStatsFrame.Text:SetJustifyH(MS:SetJustification(DB.Layout[1]))
        MS.SystemStatsFrame:SetWidth(MS.SystemStatsFrame.Text:GetStringWidth())
        MS.SystemStatsFrame:SetHeight(MS.SystemStatsFrame.Text:GetStringHeight())
        if DB.Enable then
            MS.SystemStatsFrame:Show()
            MS.SystemStatsFrame:SetScript("OnUpdate", function(self, elapsed)
                self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
                if self.TimeSinceLastUpdate >= DB.UpdateInterval then
                    self.Text:SetText(FetchSystemStats())
                    self:SetWidth(self.Text:GetStringWidth())
                    self:SetHeight(self.Text:GetStringHeight())
                    self.TimeSinceLastUpdate = 0
                end
            end)
            MS.SystemStatsFrame.Text:SetText(FetchSystemStats())
            MS.SystemStatsFrame:SetWidth(MS.SystemStatsFrame.Text:GetStringWidth())
            MS.SystemStatsFrame:SetHeight(MS.SystemStatsFrame.Text:GetStringHeight())
            MS.SystemStatsFrame:SetScript("OnMouseDown", SystemStats_OnClick)
        else
            MS.SystemStatsFrame:Hide()
            MS.SystemStatsFrame:SetScript("OnUpdate", nil)
            MS.SystemStatsFrame:SetScript("OnMouseDown", nil)
        end
    end
end