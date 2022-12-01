local AddOn, MinimapStats = ...

local MS_Config = CreateFrame("Frame", "MinimapStats_Config", InterfaceOptionsFramePanelContainer)
MS_Config.name = "MinimapStats"

InterfaceOptions_AddCategory(MinimapStats_Config)

MS_Config:Hide()
MS_Config:SetScript("OnShow", 
function() 

	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --
	-- Heading & SubHeadings
	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

	local MS_ConfigHeading = MS_Config:CreateFontString("$parentMS_ConfigHeading", "ARTWORK", "GameFontNormalLarge")
	MS_ConfigHeading:SetPoint("TOPLEFT", 10, -10)
	MS_ConfigHeading:SetText("|cFF8080FFToggles|r")

	local MS_ConfigSecondaryHeading = MS_Config:CreateFontString("$parentMS_ConfigHeading", "ARTWORK", "GameFontNormal")
	MS_ConfigSecondaryHeading:SetPoint("TOPLEFT", MS_ConfigHeading, "BOTTOMLEFT", 0, -3)
	MS_ConfigSecondaryHeading:SetText("Created by Unhalted - Twisting Nether")

	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --
	-- Toggles
	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

	local ClassColor_ToggleBox = CreateFrame("CheckButton", "$parentClassColor_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	ClassColor_ToggleBox:SetPoint("TOPLEFT", MS_ConfigHeading, "BOTTOMLEFT", 0, -25)
	ClassColor_ToggleBox.Text:SetText("Class Colors [Forces Reload]")
	ClassColor_ToggleBox.Text:SetPoint("LEFT", ClassColor_ToggleBox, "RIGHT", 3, 0)
	ClassColor_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.ClassColor = ToggledOn; ReloadUI(); end)

	local TimeText_ToggleBox = CreateFrame("CheckButton", "$parentTimeText_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	TimeText_ToggleBox:SetPoint("TOPLEFT", ClassColor_ToggleBox, "BOTTOMLEFT", 0, -10)
	TimeText_ToggleBox.Text:SetText("Time")
	TimeText_ToggleBox.Text:SetPoint("LEFT", TimeText_ToggleBox, "RIGHT", 3, 0)
	TimeText_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.TimeText = ToggledOn; MS_UpdateTimeOnToggle(); end)

	local ServerTime_ToggleBox = CreateFrame("CheckButton", "$parentTimeText_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	ServerTime_ToggleBox:SetPoint("TOPLEFT", TimeText_ToggleBox, "BOTTOMLEFT", 0, -10)
	ServerTime_ToggleBox.Text:SetText("Server Time")
	ServerTime_ToggleBox.Text:SetPoint("LEFT", ServerTime_ToggleBox, "RIGHT", 3, 0)
	ServerTime_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.ServerTime = ToggledOn; MS_UpdateTimeOnToggle(); end)

	local TwelveHourClock_ToggleBox = CreateFrame("CheckButton", "$parentTimeText_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	TwelveHourClock_ToggleBox:SetPoint("TOPLEFT", ServerTime_ToggleBox, "BOTTOMLEFT", 0, -10)
	TwelveHourClock_ToggleBox.Text:SetText("Twelve Hour Clock")
	TwelveHourClock_ToggleBox.Text:SetPoint("LEFT", TwelveHourClock_ToggleBox, "RIGHT", 3, 0)
	TwelveHourClock_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.TwelveHourClock = ToggledOn; MS_UpdateTimeOnToggle(); end)

	local FPSText_ToggleBox = CreateFrame("CheckButton", "$parentFPSText_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	FPSText_ToggleBox:SetPoint("TOPLEFT", TwelveHourClock_ToggleBox, "BOTTOMLEFT", 0, -10)
	FPSText_ToggleBox.Text:SetText("FPS")
	FPSText_ToggleBox.Text:SetPoint("LEFT", FPSText_ToggleBox, "RIGHT", 3, 0)
	FPSText_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.FPSText = ToggledOn;  MS_UpdateSystemStatsOnToggle(); end)

	local LatencyText_ToggleBox = CreateFrame("CheckButton", "$parentLatencyText_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	LatencyText_ToggleBox:SetPoint("TOPLEFT", FPSText_ToggleBox, "BOTTOMLEFT", 0, -10)
	LatencyText_ToggleBox.Text:SetText("Latency")
	LatencyText_ToggleBox.Text:SetPoint("LEFT", LatencyText_ToggleBox, "RIGHT", 3, 0)
	LatencyText_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.LatencyText = ToggledOn; MS_UpdateSystemStatsOnToggle(); end)

	local LocationText_ToggleBox = CreateFrame("CheckButton", "$parentLocationText_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	LocationText_ToggleBox:SetPoint("TOPLEFT", LatencyText_ToggleBox, "BOTTOMLEFT", 0, -10)
	LocationText_ToggleBox.Text:SetText("Location")
	LocationText_ToggleBox.Text:SetPoint("LEFT", LocationText_ToggleBox, "RIGHT", 3, 0)
	LocationText_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.LocationText = ToggledOn; MS_UpdateLocationOnToggle(); end)

	local LocationReactionColor_ToggleBox = CreateFrame("CheckButton", "$parentLocationReactionColor_ToggleBox", MS_Config, "InterfaceOptionsCheckButtonTemplate")
	LocationReactionColor_ToggleBox:SetPoint("TOPLEFT", LocationText_ToggleBox, "BOTTOMLEFT", 0, -10)
	LocationReactionColor_ToggleBox.Text:SetText("Reaction Color for Location [Forces Reload]")
	LocationReactionColor_ToggleBox.Text:SetPoint("LEFT", LocationReactionColor_ToggleBox, "RIGHT", 3, 0)
	LocationReactionColor_ToggleBox:SetScript("OnClick", function(this) local ToggledOn = not not this:GetChecked() MinimapStats_ConfigDB.LocationReactColor = ToggledOn; ReloadUI(); end)

	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --
	-- Font Sizes - Heading & SubHeadings
	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

	local MS_Config_FontsHeading = MS_Config:CreateFontString("$parentMS_Config_FontsHeading", "ARTWORK", "GameFontNormalLarge")
	MS_Config_FontsHeading:SetPoint("TOPLEFT", 10, -335)
	MS_Config_FontsHeading:SetText("|cFF8080FFFont Sizes|r")

	-- Time Text Size

	local TimeTextSize_Heading = MS_Config:CreateFontString("$parentTimeTextSize_Heading", "ARTWORK", "GameFontNormal")
	TimeTextSize_Heading:SetPoint("TOPLEFT", MS_Config_FontsHeading, "BOTTOMLEFT", 0, -10)
	TimeTextSize_Heading:SetText("Time Text Size:")

	local TimeTextSize_EditBox = CreateFrame("EditBox", "$parentTimeTextSize_EditBox", MS_Config, "InputBoxTemplate")
	TimeTextSize_EditBox:SetSize(24, 24)
	TimeTextSize_EditBox:ClearAllPoints()
	TimeTextSize_EditBox:SetPoint("LEFT", TimeTextSize_Heading, "RIGHT", 10, 0)
	TimeTextSize_EditBox:SetAutoFocus(false)
	TimeTextSize_EditBox:SetNumeric()
	TimeTextSize_EditBox:Insert(MinimapStats_ConfigDB.TimeTextSize)

	TimeTextSize_EditBox:SetScript("OnEnterPressed", function(self) local TimeTextSize = self:GetText(); MinimapStats_ConfigDB.TimeTextSize = TimeTextSize; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local TimeTextSize_IncreaseButton = CreateFrame("Button", "TimeTextSize_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	TimeTextSize_IncreaseButton:SetSize(22, 22)
	TimeTextSize_IncreaseButton:SetText("+")
	TimeTextSize_IncreaseButton:SetPoint("LEFT", TimeTextSize_EditBox, "RIGHT", 3, 0)
	TimeTextSize_IncreaseButton:SetScript("OnClick", function() TimeTextSize_IncreaseButton = MinimapStats_ConfigDB.TimeTextSize + 1; MinimapStats_ConfigDB.TimeTextSize = TimeTextSize_IncreaseButton; TimeTextSize_EditBox:SetText(TimeTextSize_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local TimeTextSize_DecreaseButton = CreateFrame("Button", "TimeTextSize_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	TimeTextSize_DecreaseButton:SetSize(22, 22)
	TimeTextSize_DecreaseButton:SetText("-")
	TimeTextSize_DecreaseButton:SetPoint("LEFT", TimeTextSize_IncreaseButton, "RIGHT", 3, 0)
	TimeTextSize_DecreaseButton:SetScript("OnClick", function() TimeTextSize_DecreaseButton = MinimapStats_ConfigDB.TimeTextSize - 1; MinimapStats_ConfigDB.TimeTextSize = TimeTextSize_DecreaseButton; TimeTextSize_EditBox:SetText(TimeTextSize_DecreaseButton); UpdateChanges(); end)

	-- SystemStats Text Size

	local SystemStatsTextSize_Heading = MS_Config:CreateFontString("$parentSystemStatsTextSize_EditBox", "ARTWORK", "GameFontNormal")
	SystemStatsTextSize_Heading:SetPoint("TOPLEFT", TimeTextSize_Heading, "BOTTOMLEFT", 0, -10)
	SystemStatsTextSize_Heading:SetText("System Stats Text Size:")

	local SystemStatsTextSize_EditBox = CreateFrame("EditBox", "$parentTimeTextSize_EditBox", MS_Config, "InputBoxTemplate")
	SystemStatsTextSize_EditBox:SetSize(24, 24)
	SystemStatsTextSize_EditBox:ClearAllPoints()
	SystemStatsTextSize_EditBox:SetPoint("LEFT", SystemStatsTextSize_Heading, "RIGHT", 10, 0)
	SystemStatsTextSize_EditBox:SetAutoFocus(false)
	SystemStatsTextSize_EditBox:SetNumeric()
	SystemStatsTextSize_EditBox:Insert(MinimapStats_ConfigDB.SystemStatsTextSize)

	SystemStatsTextSize_EditBox:SetScript("OnEnterPressed", function(self) local SystemStatsTextSize = self:GetText(); MinimapStats_ConfigDB.SystemStatsTextSize = SystemStatsTextSize; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local SystemStatsTextSize_IncreaseButton = CreateFrame("Button", "SystemStatsTextSize_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	SystemStatsTextSize_IncreaseButton:SetSize(22, 22)
	SystemStatsTextSize_IncreaseButton:SetText("+")
	SystemStatsTextSize_IncreaseButton:SetPoint("LEFT", SystemStatsTextSize_EditBox, "RIGHT", 3, 0)
	SystemStatsTextSize_IncreaseButton:SetScript("OnClick", function() SystemStatsTextSize_IncreaseButton = MinimapStats_ConfigDB.SystemStatsTextSize + 1; MinimapStats_ConfigDB.SystemStatsTextSize = SystemStatsTextSize_IncreaseButton; SystemStatsTextSize_EditBox:SetText(SystemStatsTextSize_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local SystemStatsTextSize_DecreaseButton = CreateFrame("Button", "TimeTextSize_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	SystemStatsTextSize_DecreaseButton:SetSize(22, 22)
	SystemStatsTextSize_DecreaseButton:SetText("-")
	SystemStatsTextSize_DecreaseButton:SetPoint("LEFT", SystemStatsTextSize_IncreaseButton, "RIGHT", 3, 0)
	SystemStatsTextSize_DecreaseButton:SetScript("OnClick", function() SystemStatsTextSize_DecreaseButton = MinimapStats_ConfigDB.SystemStatsTextSize - 1; MinimapStats_ConfigDB.SystemStatsTextSize = SystemStatsTextSize_DecreaseButton; SystemStatsTextSize_EditBox:SetText(SystemStatsTextSize_DecreaseButton); UpdateChanges(); end)

	-- Location Text Size

	local LocationTextSize_Heading = MS_Config:CreateFontString("$parentLocationTextSize_Heading", "ARTWORK", "GameFontNormal")
	LocationTextSize_Heading:SetPoint("TOPLEFT", SystemStatsTextSize_Heading, "BOTTOMLEFT", 0, -10)
	LocationTextSize_Heading:SetText("Location Text Size:")

	local LocationTextSize_EditBox = CreateFrame("EditBox", "$parentTimeTextSize_EditBox", MS_Config, "InputBoxTemplate")
	LocationTextSize_EditBox:SetSize(24, 24)
	LocationTextSize_EditBox:ClearAllPoints()
	LocationTextSize_EditBox:SetPoint("LEFT", LocationTextSize_Heading, "RIGHT", 10, 0)
	LocationTextSize_EditBox:SetAutoFocus(false)
	LocationTextSize_EditBox:SetNumeric()
	LocationTextSize_EditBox:Insert(MinimapStats_ConfigDB.LocationTextSize)

	LocationTextSize_EditBox:SetScript("OnEnterPressed", function(self) local LocationTextSize = self:GetText(); MinimapStats_ConfigDB.LocationTextSize = LocationTextSize; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local LocationTextSize_IncreaseButton = CreateFrame("Button", "LocationTextSize_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	LocationTextSize_IncreaseButton:SetSize(22, 22)
	LocationTextSize_IncreaseButton:SetText("+")
	LocationTextSize_IncreaseButton:SetPoint("LEFT", LocationTextSize_EditBox, "RIGHT", 3, 0)
	LocationTextSize_IncreaseButton:SetScript("OnClick", function() LocationTextSize_IncreaseButton = MinimapStats_ConfigDB.LocationTextSize + 1; MinimapStats_ConfigDB.LocationTextSize = LocationTextSize_IncreaseButton; LocationTextSize_EditBox:SetText(LocationTextSize_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local LocationTextSize_DecreaseButton = CreateFrame("Button", "TimeTextSize_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	LocationTextSize_DecreaseButton:SetSize(22, 22)
	LocationTextSize_DecreaseButton:SetText("-")
	LocationTextSize_DecreaseButton:SetPoint("LEFT", LocationTextSize_IncreaseButton, "RIGHT", 3, 0)
	LocationTextSize_DecreaseButton:SetScript("OnClick", function() LocationTextSize_DecreaseButton = MinimapStats_ConfigDB.LocationTextSize - 1; MinimapStats_ConfigDB.LocationTextSize = LocationTextSize_DecreaseButton; LocationTextSize_EditBox:SetText(LocationTextSize_DecreaseButton); UpdateChanges(); end)

	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --
	-- Anchor Points - Heading & SubHeadings
	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

	local MS_Config_XYOffsetHeading = MS_Config:CreateFontString("$parentMS_Config_XYOffsetHeading", "ARTWORK", "GameFontNormalLarge")
	MS_Config_XYOffsetHeading:SetPoint("TOPLEFT", 10, -425)
	MS_Config_XYOffsetHeading:SetText("|cFF8080FFX & Y OffSets|r")

	-- Time Frame XY Offset

	-- X Offset

	local TimeFrameXOffset_Heading = MS_Config:CreateFontString("$parentTimeFrameXOffset_Heading", "ARTWORK", "GameFontNormal")
	TimeFrameXOffset_Heading:SetPoint("TOPLEFT", MS_Config_XYOffsetHeading, "BOTTOMLEFT", 0, -10)
	TimeFrameXOffset_Heading:SetText("Time - X Offset:")

	local TimeFrameXOffset_EditBox = CreateFrame("EditBox", "$parentTimeFrameXOffset_EditBox", MS_Config, "InputBoxTemplate")
	TimeFrameXOffset_EditBox:SetSize(24, 24)
	TimeFrameXOffset_EditBox:ClearAllPoints()
	TimeFrameXOffset_EditBox:SetPoint("LEFT", TimeFrameXOffset_Heading, "RIGHT", 10, 0)
	TimeFrameXOffset_EditBox:SetAutoFocus(false)
	TimeFrameXOffset_EditBox:SetNumeric()
	TimeFrameXOffset_EditBox:Insert(MinimapStats_ConfigDB.TimeFrameXOffset)

	TimeFrameXOffset_EditBox:SetScript("OnEnterPressed", function(self) local TimeFrameXOffset = self:GetText(); MinimapStats_ConfigDB.TimeFrameXOffset = TimeFrameXOffset; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local TimeFrameXOffset_IncreaseButton = CreateFrame("Button", "TimeFrameXOffset_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	TimeFrameXOffset_IncreaseButton:SetSize(22, 22)
	TimeFrameXOffset_IncreaseButton:SetText("+")
	TimeFrameXOffset_IncreaseButton:SetPoint("LEFT", TimeFrameXOffset_EditBox, "RIGHT", 3, 0)
	TimeFrameXOffset_IncreaseButton:SetScript("OnClick", function() TimeFrameXOffset_IncreaseButton = MinimapStats_ConfigDB.TimeFrameXOffset + 1; MinimapStats_ConfigDB.TimeFrameXOffset = TimeFrameXOffset_IncreaseButton; TimeFrameXOffset_EditBox:SetText(TimeFrameXOffset_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local TimeFrameXOffset_DecreaseButton = CreateFrame("Button", "TimeFrameXOffset_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	TimeFrameXOffset_DecreaseButton:SetSize(22, 22)
	TimeFrameXOffset_DecreaseButton:SetText("-")
	TimeFrameXOffset_DecreaseButton:SetPoint("LEFT", TimeFrameXOffset_IncreaseButton, "RIGHT", 3, 0)
	TimeFrameXOffset_DecreaseButton:SetScript("OnClick", function() TimeFrameXOffset_DecreaseButton = MinimapStats_ConfigDB.TimeFrameXOffset - 1; MinimapStats_ConfigDB.TimeFrameXOffset = TimeFrameXOffset_DecreaseButton; TimeFrameXOffset_EditBox:SetText(TimeFrameXOffset_DecreaseButton); UpdateChanges(); end)

	-- Y Offset

	local TimeFrameYOffset_Heading = MS_Config:CreateFontString("$parentTimeFrameYOffset_Heading", "ARTWORK", "GameFontNormal")
	TimeFrameYOffset_Heading:SetPoint("TOPLEFT", TimeFrameXOffset_Heading, "BOTTOMLEFT", 0, -10)
	TimeFrameYOffset_Heading:SetText("Time - Y Offset:")

	local TimeFrameYOffset_EditBox = CreateFrame("EditBox", "$parentTimeFrameYOffset_EditBox", MS_Config, "InputBoxTemplate")
	TimeFrameYOffset_EditBox:SetSize(24, 24)
	TimeFrameYOffset_EditBox:ClearAllPoints()
	TimeFrameYOffset_EditBox:SetPoint("LEFT", TimeFrameYOffset_Heading, "RIGHT", 10, 0)
	TimeFrameYOffset_EditBox:SetAutoFocus(false)
	TimeFrameYOffset_EditBox:SetNumeric()
	TimeFrameYOffset_EditBox:Insert(MinimapStats_ConfigDB.TimeFrameYOffset)

	TimeFrameYOffset_EditBox:SetScript("OnEnterPressed", function(self) local TimeFrameYOffset = self:GetText(); MinimapStats_ConfigDB.TimeFrameYOffset = TimeFrameYOffset; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local TimeFrameYOffset_IncreaseButton = CreateFrame("Button", "TimeFrameYOffset_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	TimeFrameYOffset_IncreaseButton:SetSize(22, 22)
	TimeFrameYOffset_IncreaseButton:SetText("+")
	TimeFrameYOffset_IncreaseButton:SetPoint("LEFT", TimeFrameYOffset_EditBox, "RIGHT", 3, 0)
	TimeFrameYOffset_IncreaseButton:SetScript("OnClick", function() TimeFrameYOffset_IncreaseButton = MinimapStats_ConfigDB.TimeFrameYOffset + 1; MinimapStats_ConfigDB.TimeFrameYOffset = TimeFrameYOffset_IncreaseButton; TimeFrameYOffset_EditBox:SetText(TimeFrameYOffset_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local TimeFrameYOffset_DecreaseButton = CreateFrame("Button", "TimeFrameYOffset_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	TimeFrameYOffset_DecreaseButton:SetSize(22, 22)
	TimeFrameYOffset_DecreaseButton:SetText("-")
	TimeFrameYOffset_DecreaseButton:SetPoint("LEFT", TimeFrameYOffset_IncreaseButton, "RIGHT", 3, 0)
	TimeFrameYOffset_DecreaseButton:SetScript("OnClick", function() TimeFrameYOffset_DecreaseButton = MinimapStats_ConfigDB.TimeFrameYOffset - 1; MinimapStats_ConfigDB.TimeFrameYOffset = TimeFrameYOffset_DecreaseButton; TimeFrameYOffset_EditBox:SetText(TimeFrameYOffset_DecreaseButton); UpdateChanges(); end)

	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --
	-- System Stats Frame XY Offset
	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

	-- X Offset

	local SystemStatsFrameXOffset_Heading = MS_Config:CreateFontString("$parentSystemStatsFrameXOffset_Heading", "ARTWORK", "GameFontNormal")
	SystemStatsFrameXOffset_Heading:SetPoint("TOPLEFT", TimeFrameYOffset_Heading, "BOTTOMLEFT", 0, -20)
	SystemStatsFrameXOffset_Heading:SetText("System Stats - X Offset:")

	local SystemStatsFrameXOffset_EditBox = CreateFrame("EditBox", "$parentSystemStatsFrameXOffset_EditBox", MS_Config, "InputBoxTemplate")
	SystemStatsFrameXOffset_EditBox:SetSize(24, 24)
	SystemStatsFrameXOffset_EditBox:ClearAllPoints()
	SystemStatsFrameXOffset_EditBox:SetPoint("LEFT", SystemStatsFrameXOffset_Heading, "RIGHT", 10, 0)
	SystemStatsFrameXOffset_EditBox:SetAutoFocus(false)
	SystemStatsFrameXOffset_EditBox:SetNumeric()
	SystemStatsFrameXOffset_EditBox:Insert(MinimapStats_ConfigDB.SystemStatsFrameXOffset)

	SystemStatsFrameXOffset_EditBox:SetScript("OnEnterPressed", function(self) local SystemStatsFrameXOffset = self:GetText(); MinimapStats_ConfigDB.SystemStatsFrameXOffset = SystemStatsFrameXOffset; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local SystemStatsFrameXOffset_IncreaseButton = CreateFrame("Button", "SystemStatsFrameXOffset_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	SystemStatsFrameXOffset_IncreaseButton:SetSize(22, 22)
	SystemStatsFrameXOffset_IncreaseButton:SetText("+")
	SystemStatsFrameXOffset_IncreaseButton:SetPoint("LEFT", SystemStatsFrameXOffset_EditBox, "RIGHT", 3, 0)
	SystemStatsFrameXOffset_IncreaseButton:SetScript("OnClick", function() SystemStatsFrameXOffset_IncreaseButton = MinimapStats_ConfigDB.SystemStatsFrameXOffset + 1; MinimapStats_ConfigDB.SystemStatsFrameXOffset = SystemStatsFrameXOffset_IncreaseButton; SystemStatsFrameXOffset_EditBox:SetText(SystemStatsFrameXOffset_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local SystemStatsFrameXOffset_DecreaseButton = CreateFrame("Button", "SystemStatsFrameXOffset_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	SystemStatsFrameXOffset_DecreaseButton:SetSize(22, 22)
	SystemStatsFrameXOffset_DecreaseButton:SetText("-")
	SystemStatsFrameXOffset_DecreaseButton:SetPoint("LEFT", SystemStatsFrameXOffset_IncreaseButton, "RIGHT", 3, 0)
	SystemStatsFrameXOffset_DecreaseButton:SetScript("OnClick", function() SystemStatsFrameXOffset_DecreaseButton = MinimapStats_ConfigDB.SystemStatsFrameXOffset - 1; MinimapStats_ConfigDB.SystemStatsFrameXOffset = SystemStatsFrameXOffset_DecreaseButton; SystemStatsFrameXOffset_EditBox:SetText(SystemStatsFrameXOffset_DecreaseButton); UpdateChanges(); end)

	-- Y Offset

	local SystemStatsFrameYOffset_Heading = MS_Config:CreateFontString("$parentSystemStatsFrameYOffset_Heading", "ARTWORK", "GameFontNormal")
	SystemStatsFrameYOffset_Heading:SetPoint("TOPLEFT", SystemStatsFrameXOffset_Heading, "BOTTOMLEFT", 0, -10)
	SystemStatsFrameYOffset_Heading:SetText("System Stats - Y Offset:")

	local SystemStatsFrameYOffset_EditBox = CreateFrame("EditBox", "$parentSystemStatsFrameYOffset_EditBox", MS_Config, "InputBoxTemplate")
	SystemStatsFrameYOffset_EditBox:SetSize(24, 24)
	SystemStatsFrameYOffset_EditBox:ClearAllPoints()
	SystemStatsFrameYOffset_EditBox:SetPoint("LEFT", SystemStatsFrameYOffset_Heading, "RIGHT", 10, 0)
	SystemStatsFrameYOffset_EditBox:SetAutoFocus(false)
	SystemStatsFrameYOffset_EditBox:SetNumeric()
	SystemStatsFrameYOffset_EditBox:Insert(MinimapStats_ConfigDB.SystemStatsFrameYOffset)

	SystemStatsFrameYOffset_EditBox:SetScript("OnEnterPressed", function(self) local SystemStatsFrameYOffset = self:GetText(); MinimapStats_ConfigDB.SystemStatsFrameYOffset = SystemStatsFrameYOffset; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local SystemStatsFrameYOffset_IncreaseButton = CreateFrame("Button", "SystemStatsFrameYOffset_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	SystemStatsFrameYOffset_IncreaseButton:SetSize(22, 22)
	SystemStatsFrameYOffset_IncreaseButton:SetText("+")
	SystemStatsFrameYOffset_IncreaseButton:SetPoint("LEFT", SystemStatsFrameYOffset_EditBox, "RIGHT", 3, 0)
	SystemStatsFrameYOffset_IncreaseButton:SetScript("OnClick", function() SystemStatsFrameYOffset_IncreaseButton = MinimapStats_ConfigDB.SystemStatsFrameYOffset + 1; MinimapStats_ConfigDB.SystemStatsFrameYOffset = SystemStatsFrameYOffset_IncreaseButton; SystemStatsFrameYOffset_EditBox:SetText(SystemStatsFrameYOffset_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local SystemStatsFrameYOffset_DecreaseButton = CreateFrame("Button", "SystemStatsFrameYOffset_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	SystemStatsFrameYOffset_DecreaseButton:SetSize(22, 22)
	SystemStatsFrameYOffset_DecreaseButton:SetText("-")
	SystemStatsFrameYOffset_DecreaseButton:SetPoint("LEFT", SystemStatsFrameYOffset_IncreaseButton, "RIGHT", 3, 0)
	SystemStatsFrameYOffset_DecreaseButton:SetScript("OnClick", function() SystemStatsFrameYOffset_DecreaseButton = MinimapStats_ConfigDB.SystemStatsFrameYOffset - 1; MinimapStats_ConfigDB.SystemStatsFrameYOffset = SystemStatsFrameYOffset_DecreaseButton; SystemStatsFrameYOffset_EditBox:SetText(SystemStatsFrameYOffset_DecreaseButton); UpdateChanges(); end)

	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --
	-- Location Frame XY Offset
	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

	-- X Offset

	local LocationFrameXOffset_Heading = MS_Config:CreateFontString("$parentLocationFrameXOffset_Heading", "ARTWORK", "GameFontNormal")
	LocationFrameXOffset_Heading:SetPoint("TOPLEFT", SystemStatsFrameYOffset_Heading, "BOTTOMLEFT", 0, -20)
	LocationFrameXOffset_Heading:SetText("Location - X Offset:")

	local LocationFrameXOffset_EditBox = CreateFrame("EditBox", "$parentLocationFrameXOffset_EditBox", MS_Config, "InputBoxTemplate")
	LocationFrameXOffset_EditBox:SetSize(24, 24)
	LocationFrameXOffset_EditBox:ClearAllPoints()
	LocationFrameXOffset_EditBox:SetPoint("LEFT", LocationFrameXOffset_Heading, "RIGHT", 10, 0)
	LocationFrameXOffset_EditBox:SetAutoFocus(false)
	LocationFrameXOffset_EditBox:SetNumeric()
	LocationFrameXOffset_EditBox:Insert(MinimapStats_ConfigDB.LocationFrameXOffset)

	LocationFrameXOffset_EditBox:SetScript("OnEnterPressed", function(self) local LocationFrameXOffset = self:GetText(); MinimapStats_ConfigDB.LocationFrameXOffset = LocationFrameXOffset; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local LocationFrameXOffset_IncreaseButton = CreateFrame("Button", "LocationFrameXOffset_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	LocationFrameXOffset_IncreaseButton:SetSize(22, 22)
	LocationFrameXOffset_IncreaseButton:SetText("+")
	LocationFrameXOffset_IncreaseButton:SetPoint("LEFT", LocationFrameXOffset_EditBox, "RIGHT", 3, 0)
	LocationFrameXOffset_IncreaseButton:SetScript("OnClick", function() LocationFrameXOffset_IncreaseButton = MinimapStats_ConfigDB.LocationFrameXOffset + 1; MinimapStats_ConfigDB.LocationFrameXOffset = LocationFrameXOffset_IncreaseButton; LocationFrameXOffset_EditBox:SetText(LocationFrameXOffset_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local LocationFrameXOffset_DecreaseButton = CreateFrame("Button", "LocationFrameXOffset_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	LocationFrameXOffset_DecreaseButton:SetSize(22, 22)
	LocationFrameXOffset_DecreaseButton:SetText("-")
	LocationFrameXOffset_DecreaseButton:SetPoint("LEFT", LocationFrameXOffset_IncreaseButton, "RIGHT", 3, 0)
	LocationFrameXOffset_DecreaseButton:SetScript("OnClick", function() LocationFrameXOffset_DecreaseButton = MinimapStats_ConfigDB.LocationFrameXOffset - 1; MinimapStats_ConfigDB.LocationFrameXOffset = LocationFrameXOffset_DecreaseButton; LocationFrameXOffset_EditBox:SetText(LocationFrameXOffset_DecreaseButton); UpdateChanges(); end)

	-- Y Offset

	local LocationFrameYOffset_Heading = MS_Config:CreateFontString("$parentLocationFrameYOffset_Heading", "ARTWORK", "GameFontNormal")
	LocationFrameYOffset_Heading:SetPoint("TOPLEFT", LocationFrameXOffset_Heading, "BOTTOMLEFT", 0, -10)
	LocationFrameYOffset_Heading:SetText("Location - Y Offset:")

	local LocationFrameYOffset_EditBox = CreateFrame("EditBox", "$parentLocationFrameYOffset_EditBox", MS_Config, "InputBoxTemplate")
	LocationFrameYOffset_EditBox:SetSize(24, 24)
	LocationFrameYOffset_EditBox:ClearAllPoints()
	LocationFrameYOffset_EditBox:SetPoint("LEFT", LocationFrameYOffset_Heading, "RIGHT", 10, 0)
	LocationFrameYOffset_EditBox:SetAutoFocus(false)
	LocationFrameYOffset_EditBox:SetNumeric()
	LocationFrameYOffset_EditBox:Insert(MinimapStats_ConfigDB.LocationFrameYOffset)

	LocationFrameYOffset_EditBox:SetScript("OnEnterPressed", function(self) local LocationFrameYOffset = self:GetText(); MinimapStats_ConfigDB.LocationFrameYOffset = LocationFrameYOffset; self:ClearFocus(); UpdateChanges(); end)

	-- Increase Button

	local LocationFrameYOffset_IncreaseButton = CreateFrame("Button", "LocationFrameYOffset_IncreaseButton", MS_Config, "UIPanelButtonTemplate")
	LocationFrameYOffset_IncreaseButton:SetSize(22, 22)
	LocationFrameYOffset_IncreaseButton:SetText("+")
	LocationFrameYOffset_IncreaseButton:SetPoint("LEFT", LocationFrameYOffset_EditBox, "RIGHT", 3, 0)
	LocationFrameYOffset_IncreaseButton:SetScript("OnClick", function() LocationFrameYOffset_IncreaseButton = MinimapStats_ConfigDB.LocationFrameYOffset + 1; MinimapStats_ConfigDB.LocationFrameYOffset = LocationFrameYOffset_IncreaseButton; LocationFrameYOffset_EditBox:SetText(LocationFrameYOffset_IncreaseButton); UpdateChanges(); end)

	-- Decrease Button

	local LocationFrameYOffset_DecreaseButton = CreateFrame("Button", "LocationFrameYOffset_DecreaseButton", MS_Config, "UIPanelButtonTemplate")
	LocationFrameYOffset_DecreaseButton:SetSize(22, 22)
	LocationFrameYOffset_DecreaseButton:SetText("-")
	LocationFrameYOffset_DecreaseButton:SetPoint("LEFT", LocationFrameYOffset_IncreaseButton, "RIGHT", 3, 0)
	LocationFrameYOffset_DecreaseButton:SetScript("OnClick", function() LocationFrameYOffset_DecreaseButton = MinimapStats_ConfigDB.LocationFrameYOffset - 1; MinimapStats_ConfigDB.LocationFrameYOffset = LocationFrameYOffset_DecreaseButton; LocationFrameYOffset_EditBox:SetText(LocationFrameYOffset_DecreaseButton); UpdateChanges(); end)

	-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

	local DefaultValuesButton = CreateFrame("Button", "DefaultValuesButton", MS_Config, "UIPanelButtonTemplate")
	DefaultValuesButton:SetSize(128, 36)
	DefaultValuesButton:SetText("Reset Values")
	DefaultValuesButton:SetPoint("BOTTOMRIGHT", MS_Config, "BOTTOMRIGHT", -3, 3)
	DefaultValuesButton:SetScript("OnClick", function() 
		TimeTextSize_EditBox:SetText(21)
		SystemStatsTextSize_EditBox:SetText(13)
		LocationTextSize_EditBox:SetText(16)
		TimeFrameXOffset_EditBox:SetText(0)
		TimeFrameYOffset_EditBox:SetText(15)
		SystemStatsFrameXOffset_EditBox:SetText(0)
		SystemStatsFrameYOffset_EditBox:SetText(2)
		LocationFrameXOffset_EditBox:SetText(0)
		LocationFrameYOffset_EditBox:SetText(-3)
		MinimapStats_ConfigDB.TimeTextSize = 21
		MinimapStats_ConfigDB.SystemStatsTextSize = 13
		MinimapStats_ConfigDB.LocationTextSize = 16
		MinimapStats_ConfigDB.TimeFrameXOffset = 0
		MinimapStats_ConfigDB.TimeFrameYOffset = 15
		MinimapStats_ConfigDB.SystemStatsFrameXOffset = 0
		MinimapStats_ConfigDB.SystemStatsFrameYOffset = 2
		MinimapStats_ConfigDB.LocationFrameXOffset = 0
		MinimapStats_ConfigDB.LocationFrameYOffset = -3
		UpdateChanges();
		print("|cFF8080FFMinimapStats:|r Default Settings Restored Successfully.")
	end)

	local ReloadUIButton = CreateFrame("Button", "ReloadUIButton", MS_Config, "UIPanelButtonTemplate")
	ReloadUIButton:SetSize(128, 36)
	ReloadUIButton:SetText("Reload")
	ReloadUIButton:SetPoint("BOTTOM", DefaultValuesButton, "TOP", 0, 3)
	ReloadUIButton:SetScript("OnClick", function() ReloadUI() end)

	function MS_Config:Refresh()
		ClassColor_ToggleBox:SetChecked(MinimapStats_ConfigDB.ClassColor)
		TimeText_ToggleBox:SetChecked(MinimapStats_ConfigDB.TimeText)
		FPSText_ToggleBox:SetChecked(MinimapStats_ConfigDB.FPSText)
		LatencyText_ToggleBox:SetChecked(MinimapStats_ConfigDB.LatencyText)
		LocationText_ToggleBox:SetChecked(MinimapStats_ConfigDB.LocationText)
		LocationReactionColor_ToggleBox:SetChecked(MinimapStats_ConfigDB.LocationReactColor)
		TwelveHourClock_ToggleBox:SetChecked(MinimapStats_ConfigDB.TwelveHourClock)
		ServerTime_ToggleBox:SetChecked(MinimapStats_ConfigDB.ServerTime)
	end

	MS_Config:Refresh()
	MS_Config:SetScript("OnShow", nil)

end)
