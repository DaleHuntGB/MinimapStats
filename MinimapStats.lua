local AddOn, MinimapStats = ...
-- Create Frames
local MS_TimeFrame = CreateFrame("Frame")
MS_TimeFrame:RegisterEvent("PLAYER_LOGIN")
MS_TimeFrame:RegisterEvent("ADDON_LOADED")
MS_TimeFrame:SetScript("OnEvent", function(self, event, arg1)

	if event == "ADDON_LOADED" and arg1 == "MinimapStats" then 
		if (MinimapStats_ConfigDB == nil) then 
			MinimapStats_ConfigDB = {
				-- Text Toggles
				["ClassColor"] = true,
				["TimeText"] = true,
				["ServerTime"] = false,
				["TwelveHourClock"] = false,
				["FPSText"] = true,
				["LatencyText"] = true,
				["LocationText"] = true,
				["LocationReactColor"] = false,

				-- Size Toggles
				["TimeTextSize"] = 21,
				["SystemStatsTextSize"] = 13,
				["LocationTextSize"] = 16,

				-- Anchors
				-- ["TimeFrameAnchor"] = Minimap,
				-- ["SystemStatsFrameAnchor"] = Minimap,
				-- ["LocationFrameAnchor"] = Minimap,

				-- ["TimeFrameAnchorPoint"] = "BOTTOM",
				-- ["TimeFrameAnchorToPoint"] = "BOTTOM",

				-- Offsets
				["TimeFrameXOffset"] = 0,
				["TimeFrameYOffset"] = 15,
				["SystemStatsFrameXOffset"] = 0,
				["SystemStatsFrameYOffset"] = 2,
				["LocationFrameXOffset"] = 0,
				["LocationFrameYOffset"] = -3,
			}
		end

		-- ## ## ## ## ## ## ## ## ## ## ## Time Frame ## ## ## ## ## ## ## ## ## ## ## --

		MS_TimeFrame = CreateFrame("Frame", "MS_TimeFrame", UIParent)
		MS_TimeFrame:ClearAllPoints()
		MS_TimeFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", MinimapStats_ConfigDB.TimeFrameXOffset, MinimapStats_ConfigDB.TimeFrameYOffset)
		MS_TimeFrame:SetFrameStrata("HIGH")
		MS_TimeFrame:EnableMouse(true)

		-- ## ## ## ## ## ## ## ## ## ## ## SystemStats Frame ## ## ## ## ## ## ## ## ## ## ## --

		MS_SystemStatsFrame = CreateFrame("Frame", "MS_SystemStatsFrame", UIParent)
		MS_SystemStatsFrame:ClearAllPoints()
		MS_SystemStatsFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", MinimapStats_ConfigDB.SystemStatsFrameXOffset, MinimapStats_ConfigDB.SystemStatsFrameYOffset)
		MS_SystemStatsFrame:SetFrameStrata("HIGH")
		MS_SystemStatsFrame:EnableMouse(true)

		-- ## ## ## ## ## ## ## ## ## ## ## Location Frame ## ## ## ## ## ## ## ## ## ## ## --

		MS_LocationFrame = CreateFrame("Frame", "MS_LocationFrame", UIParent)
		MS_LocationFrame:ClearAllPoints()
		MS_LocationFrame:SetPoint("TOP", Minimap, "TOP", MinimapStats_ConfigDB.LocationFrameXOffset, MinimapStats_ConfigDB.LocationFrameYOffset)
		MS_LocationFrame:SetFrameStrata("HIGH")
		MS_LocationFrame:EnableMouse(true)

		-- ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## --

		-- Locals

		local MS_Font = STANDARD_TEXT_FONT
		local FontFlag = "THINOUTLINE"
		local FontTextAlign = "CENTER"

		local TextColor

		local AccentColor = "8080FF"

		-- GetClassColor

		if MinimapStats_ConfigDB.ClassColor == true then
			local _, PlayerClass = UnitClass("player")
			TextColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[PlayerClass]
		end

		function MS_GetLocationReactionColor() -- Thanks Elv
			local PVPInfo = GetZonePVPInfo()
				if PVPInfo == 'arena' then
					return 0.84, 0.03, 0.03
				elseif PVPInfo == 'friendly' then
					return 0.05, 0.85, 0.03
				elseif PVPInfo == 'contested' then
					return 0.9, 0.85, 0.05
				elseif PVPInfo == 'hostile' then
					return 0.84, 0.03, 0.03
				elseif PVPInfo == 'sanctuary' then
					return 0.035, 0.58, 0.84
				elseif PVPInfo == 'combat' then
					return 0.84, 0.03, 0.03
				else
					return 0.9, 0.85, 0.05
				end
		end

		function MS_GetTime()
			if MinimapStats_ConfigDB.TimeText == true then
				local CurrentTime = date("%H:%M")
					if MinimapStats_ConfigDB.TwelveHourClock == true then
						local TwelveHourClock = date("%I:%M")
						local AMPM = date("%p")
							if MinimapStats_ConfigDB.ClassColor == true then 
								return "|cFFFFFFFF" .. TwelveHourClock .. "|r" .. " " .. AMPM
							else
								return "|cFFFFFFFF" .. TwelveHourClock .. "|r" .. "|cFF" .. AccentColor .. " " .. AMPM .. "|r"
							end
					end
				return "|cFFFFFFFF"..CurrentTime.."|r"
			end
		end

		-- GetServerTime

		function MS_GetServerTime()
			if MinimapStats_ConfigDB.TimeText == true and MinimapStats_ConfigDB.ServerTime == true then
				local Hours, Minutes = GetGameTime()
				if MinimapStats_ConfigDB.TwelveHourClock == true and MinimapStats_ConfigDB.ClassColor == true then
					if Hours < 12 then
						return format("|cFFFFFFFF".."%02d:%02d".."|r".." AM", Hours, Minutes)
					elseif Hours > 12 then
						return format("|cFFFFFFFF".."%02d:%02d".."|r".." PM", Hours - 12, Minutes)
					elseif Hours == 12 and Minutes < 60 then 
						return format("|cFFFFFFFF".."%02d:%02d".."|r".." PM", Hours, Minutes)
					end
				end
				if MinimapStats_ConfigDB.TwelveHourClock == true and MinimapStats_ConfigDB.ClassColor == false then
					if Hours < 12 then
						return format("|cFFFFFFFF".."%02d:%02d".."|r", Hours, Minutes) .."|cFF"..AccentColor.." AM|r"
					elseif Hours > 12 then
						return format("|cFFFFFFFF".."%02d:%02d".."|r", Hours - 12, Minutes) .."|cFF"..AccentColor.." PM|r"
					elseif Hours == 12 and Minutes < 60 then 
						return format("|cFFFFFFFF".."%02d:%02d".."|r", Hours, Minutes) .."|cFF"..AccentColor.." PM|r"
					end					
				end
				return format("|cFFFFFFFF".."%02d:%02d".."|r", Hours, Minutes)
			end
		end

		-- GetSystemStats

		function MS_GetSystemStats()
			if MinimapStats_ConfigDB.ClassColor == true then 
				if MinimapStats_ConfigDB.FPSText == true and MinimapStats_ConfigDB.LatencyText == true then
					return "|cFFFFFFFF" .. floor(GetFramerate()) .. "|r" .." FPS" .. "|cFFFFFFFF" .. " | " .. "|r" .. "|cFFFFFFFF" .. select(3, GetNetStats()) .. "|r" .. " MS"
				elseif MinimapStats_ConfigDB.FPSText == true and MinimapStats_ConfigDB.LatencyText == false then
					return "|cFFFFFFFF" .. floor(GetFramerate()) .. "|r" .. " FPS"
				elseif MinimapStats_ConfigDB.FPSText == false and MinimapStats_ConfigDB.LatencyText == true then
					return "|cFFFFFFFF" .. select(3, GetNetStats()) .. "|r" .. " MS"
				end
			else
				if MinimapStats_ConfigDB.FPSText == true and MinimapStats_ConfigDB.LatencyText == true then
					return "|cFFFFFFFF" .. floor(GetFramerate()) .. "|r" .."|cFF".. AccentColor .." FPS" .. "|r".. "|cFFFFFFFF" .. " | " .. "|r" .. "|cFFFFFFFF" .. select(3, GetNetStats()) .. "|r" .. "|cFF" .. AccentColor .. " MS" .. "|r"
				elseif MinimapStats_ConfigDB.FPSText == true and MinimapStats_ConfigDB.LatencyText == false then
					return "|cFFFFFFFF" .. floor(GetFramerate()) .. "|r" .. "|cFF".. AccentColor .." FPS" .. "|r"
				elseif MinimapStats_ConfigDB.FPSText == false and MinimapStats_ConfigDB.LatencyText == true then
					return "|cFFFFFFFF" .. select(3, GetNetStats()) .. "|r" .. "|cFF" .. AccentColor .. " MS" .. "|r"
				end
			end
		end

		-- GetLocation

		function MS_GetLocation()
			if MinimapStats_ConfigDB.LocationText == true then
				if MinimapStats_ConfigDB.ClassColor == true then 
					return GetMinimapZoneText()
				elseif MinimapStats_ConfigDB.LocationReactColor == true then
					return GetMinimapZoneText()
				else
					return "|cFF" .. AccentColor .. GetMinimapZoneText() .. "|r"
				end
			end
		end

		-- Create Texts

		MS_TimeFrame.Text = MS_TimeFrame:CreateFontString(nil, "BACKGROUND")
		MS_TimeFrame.Text:SetPoint("CENTER", MS_TimeFrame, "CENTER")
		MS_TimeFrame.Text:SetFont(MS_Font, MinimapStats_ConfigDB.TimeTextSize, FontFlag)
		if MinimapStats_ConfigDB.ClassColor == true then
			MS_TimeFrame.Text:SetTextColor(TextColor.r, TextColor.g, TextColor.b)
		end

		MS_SystemStatsFrame.Text = MS_SystemStatsFrame:CreateFontString(nil, "BACKGROUND")
		MS_SystemStatsFrame.Text:SetPoint("CENTER", MS_SystemStatsFrame, "CENTER")
		MS_SystemStatsFrame.Text:SetFont(MS_Font, MinimapStats_ConfigDB.SystemStatsTextSize, FontFlag)
		if MinimapStats_ConfigDB.ClassColor == true then
			MS_SystemStatsFrame.Text:SetTextColor(TextColor.r, TextColor.g, TextColor.b)
		end

		MS_LocationFrame.Text = MS_LocationFrame:CreateFontString(nil, "BACKGROUND")
		MS_LocationFrame.Text:SetPoint("CENTER", MS_LocationFrame, "CENTER")
		MS_LocationFrame.Text:SetFont(MS_Font, MinimapStats_ConfigDB.LocationTextSize, FontFlag)
		if MinimapStats_ConfigDB.ClassColor == true then
			MS_LocationFrame.Text:SetTextColor(TextColor.r, TextColor.g, TextColor.b)
		end
		if MinimapStats_ConfigDB.LocationReactColor == true then
			MS_LocationFrame.Text:SetTextColor(MS_GetLocationReactionColor())
		end

		-- Update Time

		local Time_LastUpdate = 0

		local function UpdateTime(MS_TimeFrame, Elapsed_Time)

			Time_LastUpdate = Time_LastUpdate + Elapsed_Time
			if Time_LastUpdate > 1 then
				Time_LastUpdate = 0

				if MinimapStats_ConfigDB.ServerTime == true then
					MS_TimeFrame.Text:SetText(MS_GetServerTime())
				else
					MS_TimeFrame.Text:SetText(MS_GetTime())
				end

				MS_TimeFrame:SetWidth(MS_TimeFrame.Text:GetStringWidth())
				MS_TimeFrame:SetHeight(MS_TimeFrame.Text:GetStringHeight())
			end
		end

		-- Update System Stats

		local SystemsStats_LastUpdate = 0

		local function UpdateSystemStats(MS_SystemStatsFrame, Elapsed_Time)

			SystemsStats_LastUpdate = SystemsStats_LastUpdate + Elapsed_Time
			if SystemsStats_LastUpdate > 1 then
				SystemsStats_LastUpdate = 0

				MS_SystemStatsFrame.Text:SetText(MS_GetSystemStats())

				MS_SystemStatsFrame:SetWidth(MS_SystemStatsFrame.Text:GetStringWidth())
				MS_SystemStatsFrame:SetHeight(MS_SystemStatsFrame.Text:GetStringHeight())
			end
		end

		-- Update Location

		local Location_LastUpdate = 0

		local function UpdateLocation(MS_LocationFrame, Elapsed_Time)

			Location_LastUpdate = Location_LastUpdate + Elapsed_Time
			if Location_LastUpdate > 1 then
				Location_LastUpdate = 0

				MS_LocationFrame.Text:SetText(MS_GetLocation())

				MS_LocationFrame:SetWidth(MS_LocationFrame.Text:GetStringWidth())
				MS_LocationFrame:SetHeight(MS_LocationFrame.Text:GetStringHeight())
			end
		end

		-- Update on Toggles

		function MS_UpdateTimeOnToggle()

			if MinimapStats_ConfigDB.ServerTime == true then
				MS_TimeFrame.Text:SetText(MS_GetServerTime())
			else
				MS_TimeFrame.Text:SetText(MS_GetTime())
			end

			MS_TimeFrame:SetWidth(MS_TimeFrame.Text:GetStringWidth())
			MS_TimeFrame:SetHeight(MS_TimeFrame.Text:GetStringHeight())		
		end


		function MS_UpdateSystemStatsOnToggle()

			MS_SystemStatsFrame.Text:SetText(MS_GetSystemStats())

			MS_SystemStatsFrame:SetWidth(MS_SystemStatsFrame.Text:GetStringWidth())
			MS_SystemStatsFrame:SetHeight(MS_SystemStatsFrame.Text:GetStringHeight())			

		end

		function MS_UpdateLocationOnToggle()

			MS_LocationFrame.Text:SetText(MS_GetLocation())

			MS_LocationFrame:SetWidth(MS_LocationFrame.Text:GetStringWidth())
			MS_LocationFrame:SetHeight(MS_LocationFrame.Text:GetStringHeight())
		end

		function UpdateChanges()
			MS_TimeFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", MinimapStats_ConfigDB.TimeFrameXOffset, MinimapStats_ConfigDB.TimeFrameYOffset)
			MS_SystemStatsFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", MinimapStats_ConfigDB.SystemStatsFrameXOffset, MinimapStats_ConfigDB.SystemStatsFrameYOffset)
			MS_LocationFrame:SetPoint("TOP", Minimap, "TOP", MinimapStats_ConfigDB.LocationFrameXOffset, MinimapStats_ConfigDB.LocationFrameYOffset)
			--
			MS_TimeFrame.Text:SetFont(MS_Font, MinimapStats_ConfigDB.TimeTextSize, FontFlag)
			MS_SystemStatsFrame.Text:SetFont(MS_Font, MinimapStats_ConfigDB.SystemStatsTextSize, FontFlag)
			MS_LocationFrame.Text:SetFont(MS_Font, MinimapStats_ConfigDB.LocationTextSize, FontFlag)
		end

		MS_TimeFrame:SetScript("OnMouseUp", function(self, button) if button == "LeftButton" then ToggleCalendar() end end)
		MS_SystemStatsFrame:SetScript("OnMouseUp", function(self, button) if button == "MiddleButton" then ReloadUI(); elseif button == "RightButton" then InterfaceOptionsFrame_OpenToCategory(MinimapStats_Config) end end)

		MS_TimeFrame:SetScript("OnUpdate", UpdateTime)
		MS_SystemStatsFrame:SetScript("OnUpdate", UpdateSystemStats)
		MS_LocationFrame:SetScript("OnUpdate", UpdateLocation)
	end
end)

print("|cFF8080FFMinimapStats:|r /msconfig - Configuration Window")

SLASH_MSConfig1 = "/msconfig"
SlashCmdList["MSConfig"] = function() InterfaceOptionsFrame_OpenToCategory(MinimapStats_Config) end

