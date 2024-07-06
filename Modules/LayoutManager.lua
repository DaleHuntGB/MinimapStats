local _, MS = ...

function MS:LoadLayout(LayoutToLoad)
    if LayoutToLoad == 1 then -- Default Layout
        MS.DB.global.TimeAnchorPosition = "BOTTOM"
        MS.DB.global.TimeXOffset = 0
        MS.DB.global.TimeYOffset = 15
        MS.DB.global.SystemStatsAnchorPosition = "BOTTOM"
        MS.DB.global.SystemStatsXOffset = 0
        MS.DB.global.SystemStatsYOffset = 3
        MS.DB.global.LocationAnchorPosition = "TOP"
        MS.DB.global.LocationXOffset = 0
        MS.DB.global.LocationYOffset = -3
        MS.DB.global.CoordinatesAnchorPosition = "TOP"
        MS.DB.global.CoordinatesXOffset = 0
        MS.DB.global.CoordinatesYOffset = -15
        MS.DB.global.InstanceDifficultyAnchorPosition = "TOPLEFT"
        MS.DB.global.InstanceDifficultyXOffset = 3
        MS.DB.global.InstanceDifficultyYOffset = -3
    elseif LayoutToLoad == 2 then -- Corners
        MS.DB.global.TimeAnchorPosition = "BOTTOMLEFT"
        MS.DB.global.TimeXOffset = 3
        MS.DB.global.TimeYOffset = 3
        MS.DB.global.SystemStatsAnchorPosition = "BOTTOMRIGHT"
        MS.DB.global.SystemStatsXOffset = -3
        MS.DB.global.SystemStatsYOffset = 3
        MS.DB.global.LocationAnchorPosition = "TOPLEFT"
        MS.DB.global.LocationXOffset = 3
        MS.DB.global.LocationYOffset = -3
        MS.DB.global.CoordinatesAnchorPosition = "TOPLEFT"
        MS.DB.global.CoordinatesXOffset = 3
        MS.DB.global.CoordinatesYOffset = -18
        MS.DB.global.InstanceDifficultyAnchorPosition = "TOPRIGHT"
        MS.DB.global.InstanceDifficultyXOffset = -3
        MS.DB.global.InstanceDifficultyYOffset = -3
    elseif LayoutToLoad == 3 then -- Inverted Corners
        MS.DB.global.TimeAnchorPosition = "BOTTOMRIGHT"
        MS.DB.global.TimeXOffset = -3
        MS.DB.global.TimeYOffset = 3
        MS.DB.global.SystemStatsAnchorPosition = "BOTTOMLEFT"
        MS.DB.global.SystemStatsXOffset = 3
        MS.DB.global.SystemStatsYOffset = 3
        MS.DB.global.LocationAnchorPosition = "TOPRIGHT"
        MS.DB.global.LocationXOffset = -3
        MS.DB.global.LocationYOffset = -3
        MS.DB.global.CoordinatesAnchorPosition = "TOPRIGHT"
        MS.DB.global.CoordinatesXOffset = -3
        MS.DB.global.CoordinatesYOffset = -18
        MS.DB.global.InstanceDifficultyAnchorPosition = "TOPLEFT"
        MS.DB.global.InstanceDifficultyXOffset = 3
        MS.DB.global.InstanceDifficultyYOffset = -3
    end
    MS:UpdateAllElements()
end