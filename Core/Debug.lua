local _, MS = ...
local MSGUI = MS.GUI
local DEBUG_UI_HEIGHT = 864

function MS:GetFrameAnchors(FrameName, FrameNameText)
    if not FrameName then return end
    local InformationList = {}
    local AnchorFrom, _, AnchorTo, XOffset, YOffset = FrameName:GetPoint()
    local Font, FontSize = FrameNameText:GetFont()
    table.insert(InformationList, "|cFF8080FFAnchor From|r: " .. (AnchorFrom or "nil"))
    table.insert(InformationList, "|cFF8080FFAnchor To|r: " .. (AnchorTo or "nil"))
    table.insert(InformationList, "|cFF8080FFX Offset|r: " .. (XOffset and math.floor(XOffset) or "nil"))
    table.insert(InformationList, "|cFF8080FFY Offset|r: " .. (YOffset and math.floor(YOffset) or "nil"))
    table.insert(InformationList, "|cFF8080FFFont|r: " .. (Font or "nil"))
    table.insert(InformationList, "|cFF8080FFText|r: " .. (FrameNameText:GetText() or "Empty"))
    table.insert(InformationList, "|cFF8080FFFont Size|r: " .. (FontSize and math.ceil(FontSize) or "nil"))
    table.insert(InformationList, "|cFF8080FFFrame Strata|r: " .. (FrameName:GetFrameStrata() or "nil"))

    return table.concat(InformationList, "\n")
end

function MS:GetFrameVisibility(FrameName)
    if not FrameName then FrameName = "" return  FrameName .. "|cFFFF4040Not Found|r" end
    return (FrameName:IsVisible() and "|cFF40FF40Visible|r" or "|cFFFF4040Hidden|r")
end


function MS:DebugUI()
    local DebugFrame = MSGUI:Create("Window")
    DebugFrame:SetTitle(MS.ADDON_NAME .. " |cFFFFFFFFDebug|r")
    DebugFrame:SetWidth(512)
    DebugFrame:SetHeight(DEBUG_UI_HEIGHT)
    DebugFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    DebugFrame:SetCallback("OnClose", function(widget) MSGUI:Release(widget) MS.isGUIOpen = false MS.ShowDiffID = false MS:UpdateInstanceDifficultyFrame() end)
    DebugFrame:SetLayout("Flow")
    DebugFrame:EnableResize(false)

    local DebugFrameTitle = MSGUI:Create("Heading")
    DebugFrameTitle:SetText("General")
    DebugFrameTitle:SetFullWidth(true)

    local TimeLabel = MSGUI:Create("Label")
    TimeLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    TimeLabel:SetText("|cFF8080FFTime|r: " .. date("%H:%M"))
    TimeLabel:SetFullWidth(true)

    local DateLabel = MSGUI:Create("Label")
    DateLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    DateLabel:SetText("|cFF8080FFDate|r: " .. date("%d/%m/%Y"))
    DateLabel:SetFullWidth(true)

    local InterfaceLabel = MSGUI:Create("Label")
    InterfaceLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    InterfaceLabel:SetText("|cFF8080FFInterface|r: " .. MS.BUILDVERSION)
    InterfaceLabel:SetFullWidth(true)

    local VersionLabel = MSGUI:Create("Label")
    VersionLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    VersionLabel:SetText("|cFF8080FFVersion|r: " .. MS.ADDON_VERSION)
    VersionLabel:SetFullWidth(true)

    local ElvUIStatus = MSGUI:Create("Label")
    ElvUIStatus:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    ElvUIStatus:SetText("|cFF8080FFElvUI|r: " .. tostring(C_AddOns.IsAddOnLoaded("ElvUI") and "|cFF40FF40Yes|r" or "|cFFFF4040No|r"))
    ElvUIStatus:SetFullWidth(true)

    local TimeGroup = MSGUI:Create("SimpleGroup")
    TimeGroup:SetFullWidth(true)
    TimeGroup:SetLayout("Flow")

    local TimeHeading = MSGUI:Create("Heading")
    TimeHeading:SetText("Time Frame: " .. MS:GetFrameVisibility(MS.TimeFrame))
    TimeHeading:SetFullWidth(true)

    local TimeAnchors = MSGUI:Create("Label")
    TimeAnchors:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    TimeAnchors:SetText(MS:GetFrameAnchors(MS.TimeFrame, MS.TimeFrameText))
    TimeAnchors:SetFullWidth(true)

    local SystemsStatsGroup = MSGUI:Create("SimpleGroup")
    SystemsStatsGroup:SetFullWidth(true)
    SystemsStatsGroup:SetLayout("Flow")

    local SystemsStatsHeading = MSGUI:Create("Heading")
    SystemsStatsHeading:SetText("System Stats Frame: " .. MS:GetFrameVisibility(MS.SystemStatsFrame))
    SystemsStatsHeading:SetFullWidth(true)

    local SystemsStatsAnchors = MSGUI:Create("Label")
    SystemsStatsAnchors:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    SystemsStatsAnchors:SetText(MS:GetFrameAnchors(MS.SystemStatsFrame, MS.SystemStatsFrameText))
    SystemsStatsAnchors:SetFullWidth(true)

    local LocationGroup = MSGUI:Create("SimpleGroup")
    LocationGroup:SetFullWidth(true)
    LocationGroup:SetLayout("Flow")

    local LocationHeading = MSGUI:Create("Heading")
    LocationHeading:SetText("Location Frame: " .. MS:GetFrameVisibility(MS.LocationFrame))
    LocationHeading:SetFullWidth(true)

    local LocationAnchors = MSGUI:Create("Label")
    LocationAnchors:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    LocationAnchors:SetText(MS:GetFrameAnchors(MS.LocationFrame, MS.LocationFrameText))
    LocationAnchors:SetFullWidth(true)

    local CoordinatesGroup = MSGUI:Create("SimpleGroup")
    CoordinatesGroup:SetFullWidth(true)
    CoordinatesGroup:SetLayout("Flow")

    local CoordinatesHeading = MSGUI:Create("Heading")
    CoordinatesHeading:SetText("Coordinates Frame: " .. MS:GetFrameVisibility(MS.CoordinatesFrame))
    CoordinatesHeading:SetFullWidth(true)

    local CoordinatesAnchors = MSGUI:Create("Label")
    CoordinatesAnchors:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    CoordinatesAnchors:SetText(MS:GetFrameAnchors(MS.CoordinatesFrame, MS.CoordinatesFrameText))
    CoordinatesAnchors:SetFullWidth(true)

    local InstanceDifficultyGroup = MSGUI:Create("SimpleGroup")
    InstanceDifficultyGroup:SetFullWidth(true)
    InstanceDifficultyGroup:SetLayout("Flow")

    local InstanceDifficultyHeading = MSGUI:Create("Heading")
    InstanceDifficultyHeading:SetText("Instance Difficulty Frame: " .. MS:GetFrameVisibility(MS.InstanceDifficultyFrame))
    InstanceDifficultyHeading:SetFullWidth(true)

    local InstanceDifficultyAnchors = MSGUI:Create("Label")
    InstanceDifficultyAnchors:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    InstanceDifficultyAnchors:SetText(MS:GetFrameAnchors(MS.InstanceDifficultyFrame, MS.InstanceDifficultyFrameText))
    InstanceDifficultyAnchors:SetFullWidth(true)

    DebugFrame:AddChild(DebugFrameTitle)
    DebugFrame:AddChild(TimeLabel)
    DebugFrame:AddChild(DateLabel)
    DebugFrame:AddChild(InterfaceLabel)
    DebugFrame:AddChild(VersionLabel)
    DebugFrame:AddChild(ElvUIStatus)

    DebugFrame:AddChild(TimeGroup)
    TimeGroup:AddChild(TimeHeading)
    TimeGroup:AddChild(TimeAnchors)
    DebugFrame:AddChild(SystemsStatsGroup)
    SystemsStatsGroup:AddChild(SystemsStatsHeading)
    SystemsStatsGroup:AddChild(SystemsStatsAnchors)
    DebugFrame:AddChild(LocationGroup)
    LocationGroup:AddChild(LocationHeading)
    LocationGroup:AddChild(LocationAnchors)
    DebugFrame:AddChild(CoordinatesGroup)
    CoordinatesGroup:AddChild(CoordinatesHeading)
    CoordinatesGroup:AddChild(CoordinatesAnchors)
    DebugFrame:AddChild(InstanceDifficultyGroup)
    InstanceDifficultyGroup:AddChild(InstanceDifficultyHeading)
    InstanceDifficultyGroup:AddChild(InstanceDifficultyAnchors)
end
