-- Addon declaration
HandyNotes_HigherLearning = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_HigherLearning","AceEvent-3.0")
local HNHL = HandyNotes_HigherLearning
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_HigherLearning")

---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
	profile = {
		icon_scale				= 1.0,
		icon_alpha				= 1.0,
		icon_scale_minimap 		= 1.0,
		icon_alpha_minimap 		= 1.0,
		
		completed 				= false, 
		showExtra   			= true,
	},
}

---------------------------------------------------------
-- Localize some globals
local next = next
local select = select
local string_find = string.find
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip
local HandyNotes = HandyNotes
local tonumber = tonumber
local strsplit = strsplit

local TomTom = TomTom
local wipe = wipe
local pairs = pairs
local GetAchievementInfo = GetAchievementInfo
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo

---------------------------------------------------------
-- Constants and icons
local defkey = "default"
local iconDB = {
	["HigherLearning"] = "Interface\\AddOns\\HandyNotes_HigherLearning\\texture\\Book1",
	--["HigherLearning"] = "Interface\\Minimap\\Tracking\\Class",
	--["HigherLearning"] = "Interface\\Icons\\inv_misc_book_06",
	[defkey] = "Interface\\Icons\\INV_Misc_QuestionMark", -- default fallback icon
}

setmetatable(iconDB, {__index = function(t, k)
		local v = t[defkey]
		rawset(t, k, v)
		return v
	end
})

---------------------------------------------------------
-- Plugin Handlers to HandyNotes
local HNHLHandler = {}

local function createWaypoint(button, mapFile, coord)
	local c, z = HandyNotes:GetCZ(mapFile)
	local x, y = HandyNotes:getXY(coord)

	local data = HNHL_Data[mapFile] and HNHL_Data[mapFile][coord]
	if not data then return end

	local vType  = data.type
	local vName  = data.name
	local vNote = data.note

--[[
	if not vName or vName == "" then
		vName = vType or "Waypoint"
	end
]]
	if TomTom then
		TomTom:AddZWaypoint(c, z, x*100, y*100, vName)
	elseif Cartographer_Waypoints then
		Cartographer_Waypoints:AddWaypoint(NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, vName))
	end
end

local clickedNote, clickedNoteZone
local info = {}
local function generateMenu(button, level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		info.isTitle      = 1
		info.text         = L["HandyNotes"]
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
		wipe(info)

		if TomTom or Cartographer_Waypoints then
			info.disabled     = nil
			info.isTitle      = nil
			info.notCheckable = nil
			info.text = L["Create waypoint"]
			info.icon = nil
			info.func = createWaypoint
			info.arg1 = clickedNoteZone
			info.arg2 = clickedNote
			UIDropDownMenu_AddButton(info, level)
		end

		info.text         = L["Close"]
		info.icon         = nil
		info.func         = function() CloseDropDownMenus() end
		info.arg1         = nil
		info.arg2         = nil
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
	end
end

local HNHL_Dropdown = CreateFrame("Frame", "HandyNotes_HigherLearningDropdownMenu")
HNHL_Dropdown.displayMode = "MENU"
HNHL_Dropdown.initialize = generateMenu

function HNHLHandler:OnClick(button, down, mapFile, coord)
	if TomTom or Cartographer_Waypoints then
		if button == "RightButton" and not down then
			clickedNoteZone = mapFile
			clickedNote = coord
			ToggleDropDownMenu(1, nil, HNHL_Dropdown, self, 0, 0)
		end
	end
end

function HNHLHandler:OnEnter(mapFile, coord)
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
    tooltip:ClearLines()

    if self:GetCenter() > UIParent:GetCenter() then
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end

    local data = HNHL_Data[mapFile] and HNHL_Data[mapFile][coord]
    if not data then return end

    local vType         = data.type
    local vNote	        = data.note
	local vName  		= data.name
    local achievementID = data.achievementID
    local criteriaID    = data.criteriaID

    local achievementName
    if achievementID then
        local _, name = GetAchievementInfo(achievementID)
        achievementName = name
    end

	--[[
    local criteriaName
    if achievementID and criteriaID then
        local numCriteria = GetAchievementNumCriteria(achievementID)
        for i = 1, numCriteria do
            local cName, _, _, _, _, _, _, _, _, cID = GetAchievementCriteriaInfo(achievementID, i)
            if cID == criteriaID then
                criteriaName = cName
                break
            end
        end
    end
	]]
	local criteriaName = vName and L[vName] or vName
	
	local noteText = vNote and L[vNote] or vNote

    if achievementName and achievementName ~= "" then
        --tooltip:AddLine("|cffffff00" .. achievementName .. "|r")
		 tooltip:AddLine("|cFFFFD700" .. achievementName .. "|r")
    end

    if criteriaName and criteriaName ~= "" then
        --tooltip:AddLine("|cffe0e0e0" .. criteriaName .. "|r") --серый
		tooltip:AddLine("|cFFFFFFFF" .. criteriaName .. "|r")
    end
	
	--tooltip:AddLine(" ")

	-------------
	if db.profile.showExtra and noteText and noteText ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine("|cff00ffff" .. noteText .. "|r", 1, 1, 1, true)
	end
	-------------

	--[[
    if TomTom and tooltip:GetOwner():GetParent() ~= Minimap then
        --tooltip:AddLine(L["<Right-Click to set a waypoint in TomTom>"])
		tooltip:AddLine(" ")
		tooltip:AddLine("|cff888888<Right-Click to set waypoint>|r")
    end
	]]
	--
	if db.profile.completed then
		if data.completed then
			tooltip:AddLine("|cff00ff00Completed|r")
		else
			tooltip:AddLine("|cffff0000Not completed|r")
		end
	end
	
    tooltip:Show()
end

function HNHLHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

local criteriaCache = {}

local function BuildCriteriaCache()
    wipe(criteriaCache)
    for _, points in pairs(HNHL_Data) do
        for _, data in pairs(points) do
            local achID = data.achievementID
            if achID and not criteriaCache[achID] then
                criteriaCache[achID] = {}
                local numCriteria = GetAchievementNumCriteria(achID)
                for i = 1, numCriteria do
                    local _, _, done, _, _, _, _, _, _, id =
                        GetAchievementCriteriaInfo(achID, i)
                    if id then
                        criteriaCache[achID][id] = done
                    end
                end
            end
        end
    end
end

local function UpdatePointCompletion()
    BuildCriteriaCache()
    for _, points in pairs(HNHL_Data) do
        for _, data in pairs(points) do
            local achID = data.achievementID
            local criteriaID = data.criteriaID
            if achID and criteriaID and criteriaCache[achID] then
                data.completed = criteriaCache[achID][criteriaID] or false
            else
                data.completed = false
            end
        end
    end
end

local function iter(t, prestate, scale, alpha)
    if not t then return nil end
    local state, data = next(t, prestate)
    while state do
        if data then
            local Completed = db.profile.completed
            local isCompleted = data.completed
            if Completed or not isCompleted then
                local icon = iconDB[data.type] or iconDB["HigherLearning"]
                --return state, nil, icon, scale, alpha
				return state, nil, icon, scale * 1.25, alpha
            end
        end
        state, data = next(t, state)
    end
end

function HNHLHandler:GetNodes(mapFile, minimap)

    local scale
    local alpha

    if minimap then
        scale = db.profile.icon_scale_minimap
        alpha = db.profile.icon_alpha_minimap
    else
        scale = db.profile.icon_scale
        alpha = db.profile.icon_alpha
    end

    return function(t, prestate)
        return iter(t, prestate, scale, alpha)
    end,
    HNHL_Data[mapFile],
    nil
end

---------------------------------------------------------
-- Options table

local options = {
	type = "group",
	name = L["Title"],
	desc = L["Desc"],
	get = function(info) return db.profile[info.arg] end,
	set = function(info, v)
		db.profile[info.arg] = v
		HNHL:SendMessage("HandyNotes_NotifyUpdate", "HigherLearning")
	end,
	args = {
		desc = {
			name = L["Setting desc"],
			type = "description",
			order = 0,
		},
		icon_scale = {
			type = "range",
			name = L["Icon Scale"],
			desc = L["The scale of the icons"],
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale",
			order = 10,
		},
		icon_alpha = {
			type = "range",
			name = L["Icon Alpha"],
			desc = L["The alpha transparency of the icons"],
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha",
			order = 20,
		},
		icon_scale_minimap = {
			type = "range",
			name = L["Minimap Icon Scale"],
			desc = L["The scale of the icons on the Minimap"],
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale_minimap",
			order = 30,
		},
		icon_alpha_minimap = {
			type = "range",
			name = L["Minimap Icon Alpha"],
			desc = L["The alpha transparency of the icons on the Minimap"],
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha_minimap",
			order = 40,
		},
		completed = {
			type = "toggle",
			name = L["Show completed"],
			desc = L["Display completed nodes"],
			arg = "completed",
			order = 50,			
		},
		-----------------------------
		showExtra = {
			type = "toggle",
			name = L["Show extra"],
			desc = L["Extra desc"],
			--name = "Show Note Text",
			--desc = "Show additional note information in the tooltip",
			arg = "showExtra",
			order = 60,
		},		
	},
}

---------------------------------------------------------
-- Addon initialization

function HNHL:OnInitialize()
	db = LibStub("AceDB-3.0"):New("HandyNotes_HigherLearningDB", defaults)
	self.db = db

	HandyNotes:RegisterPluginDB("HigherLearning", HNHLHandler, options)

	--self:RegisterEvent("ZONE_CHANGED", "Refresh")
	--self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Refresh")
	--self:RegisterEvent("ZONE_CHANGED_INDOORS", "Refresh")

	self:RegisterEvent("CRITERIA_UPDATE", "OnCriteriaChanged")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitialUpdate")

	 UpdatePointCompletion()
	 
end
function HNHL:InitialUpdate()
    UpdatePointCompletion()
    self:Refresh()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
-----------------
--[[
function HNHL:ITEM_TEXT_BEGIN()
    self:RegisterEvent("CRITERIA_UPDATE", "OnCriteriaChanged")
    self:RegisterEvent("CRITERIA_EARNED", "OnCriteriaChanged")
    self:RegisterEvent("CRITERIA_COMPLETE", "OnCriteriaChanged")
    self:RegisterEvent("ACHIEVEMENT_EARNED", "OnCriteriaChanged")

	UpdatePointCompletion()

    self:Refresh()
end
]]


function HNHL:OnCriteriaChanged()
--print("CRITERIA_UPDATE fired")
    UpdatePointCompletion()
    self:Refresh()
end
--[[
function HNHL:ITEM_TEXT_CLOSED()
	self:UnregisterEvent("CRITERIA_UPDATE")
	self:UnregisterEvent("CRITERIA_EARNED")
	self:UnregisterEvent("CRITERIA_COMPLETE")
	self:UnregisterEvent("ACHIEVEMENT_EARNED")
	
	UpdatePointCompletion()
    self:Refresh()
end
]]


-----------------------------------


function HNHL:Refresh()
    HNHL:SendMessage("HandyNotes_NotifyUpdate", "HigherLearning")
	--self:SendMessage("HandyNotes_NotifyUpdate", addonName:gsub("HandyNotes_", ""))
end

--[[
function HNHL:OnEnable()
	HNHL:SendMessage("HandyNotes_NotifyUpdate", "HigherLearning")
end
--]]