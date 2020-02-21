--@ module=true
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local defbldg = reqscript("functions/building").BUILDING
local myMath = reqscript("funcitons/math")
local systemTable = systemTable or {}
local function checkSystemTable(buildingID)
	-- Make sure the building exists
	local building = defbldg(buildingID)
	if not building then return nil end
	
	local buildingToken = building.subtype
	if buildingToken == "CUSTOM" then buildingToken = building.customtype end
	if not systemTable[buildingToken] then return nil end
	
	return building, systemTable[buildingToken]
end

-- Name of the system
Name = "enhancedBuildings"

-- List of currently accepted tokens for the system
Tokens = {
	DESCRIPTION        = {Type="Main", Subtype="String",  Name="Description"},
	OUTSIDE_ONLY       = {Type="Main", Subtype="Boolean", Name="OutsideOnly"},
	INSIDE_ONLY        = {Type="Main", Subtype="Boolean", Name="InsideOnly"},
	REQUIRED_WATER     = {Type="Main", Subtype="Number",  Name="RequiredWater"},
	REQUIRED_MAGMA     = {Type="Main", Subtype="Number",  Name="RequiredMagma"},
	REQUIRED_BUILDING  = {Type="Main", Subtype="Table",   Name="RequiredBuildings"},
	FORBIDDEN_BUILDING = {Type="Main", Subtype="Table",   Name="ForbiddenBuildings"},
	MAX_AMOUNT         = {Type="Main", Subtype="Number",  Name="MaxAmount"},
	SCRIPT             = {Type="Main", Subtype="Script",  Name="Scripts"},
}

EventfulFunctions = {
	onJobInitiated = {
		buildingTrigger = function(job)
			if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
				buildingID = job.general_refs[0].building_id 
				checkBuildingStarted(buildingID) -- This runs building checks such as Inside Only
			elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
				buildingID = job.general_refs[0].building_id
				checkBuildingUnstarted(buildingID) -- This currently doesn't do anything
			end
		end
	},
	onJobCompleted = {
		buildingTrigger = function(job)
			if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
				buildingID = job.general_refs[0].building_id
				checkBuildingFinished(buildingID) -- This runs scripts
			elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
				buildingID = job.general_refs[0].building_id
				checkBuildingDestroyed(buildingID) -- This currently doesn't do anything
			end
		end
	},
}
EventfulTypes = {
	JOB_INITIATED = 5,
	JOB_COMPLETED = 5,
}
CustomFunctions = {},
CustomTypes = {}

-- startSystemTriggers is called on intialization
function startSystemTriggers()
	-- This only needs to be loaded once since it is unchanging during gameplay
	systemTable = reqscript("core/tables").Tables[Name]
	if not systemTable then return end
	
	-- Eventful Triggers
	for k,t in pairs(EventfulFunctions) do -- No idea if this is going to work
		for name,func in pairs(t) do
			eventful[k][name] = function(...) return func(...) end
		end
	end
	for Type,ticks in pairs(EventfulTypes) do
		eventful.enableEvent(eventful.eventType[Type],ticks)
	end
	
	-- Custom Triggers
	for Type,v in pairs(CustomTypes) do
		repeats.scheduleUnlessAlreadyScheduled(Type,v.ticks,"ticks",v.func)
	end
end

local function checkJobInitiated(job)
	if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
		buildingID = job.general_refs[0].building_id 
		checkBuildingStarted(buildingID) -- This runs building checks such as Inside Only
	elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
		buildingID = job.general_refs[0].building_id
		checkBuildingUnstarted(buildingID) -- This currently doesn't do anything
	end
end

local function checkJobCompleted(job)
	if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
		buildingID = job.general_refs[0].building_id
		checkBuildingFinished(buildingID) -- This runs scripts
	elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
		buildingID = job.general_refs[0].building_id
		checkBuildingDestroyed(buildingID) -- This currently doesn't do anything
	end
end

local function checkBuildingStarted(buildingID)
	building, Table = checkSystemTable(buildingID)
	if not building then return end
 
	-- Run through checks
	local allow = true
	
	-- Boolean Checks
	if allow and Table.InsideOnly and building:isOutside() then allow = false end
	if allow and Table.OutsideOnly and building:isInside() then allow = false end
	
	-- Number Checks
	if allow and Table.RequiredWater and building:nearbyWater() < Table.RequiredWater then allow = false end
	if allow and Table.RequiredMagma and building:nearbyMagma() < Table.RequiredMagma then allow = false end
	if allow and Table.MaxAmount and building:count() > Table.MaxAmount then allow = false end
	
	-- Array Checks
	if allow and Table.RequiredBuildings then
		for reqBldg,reqNum in pairs(Table.RequiredBuilding) do
			if myMath.count("BUILDING",reqBldg) < reqNum then
				allow = false
				break
			end
		end
	end
	if allow and Table.ForbiddenBuildings then
		for reqBldg,reqNum in pairs(Table.ForbiddenBuildings) do
			if myMath.count("BUILDING",reqBldg) > reqNum then
				allow = false
				break
			end
		end
	end

	
	if not allow then
		building:deconstruct()
	end
end

local function checkBuildingUnstarted(buildingID)
	-- Nothing to be done for beginning to deconstruct a building yet
end

local function checkBuildingFinished(buildingID)
	building, Table = checkSystemTable(buildingID)
	if not building then return end
	
	BuildingTable = dfhack.script_environment("core/tables").makeBuildingTable(building)
	BuildingTable.Enhanced = true

	if Table.Scripts then
		BuildingTable.Scripts = true
		for i,x in pairs(Table.Scripts) do
			local script = x.Script
			local frequency = x.Frequency
			script = script:gsub("BUILDING_ID",tostring(building.id))
			script = script:gsub("BUILDING_TOKEN",BuildingTable.Token)
			script = script:gsub("BUILDING_LOCATION",""..tostring(building.centerx).." "..tostring(building.centery).." "..tostring(building.z).."")
			dfhack.run_command(script)
			if frequency > 0 then
				dfhack.script_environment("persist-delay").functionDelay(frequency,"enhanced/buildings","scriptTrigger",{building.id,script,frequency})
			end
		end
	end
end

local function checkBuildingDestroyed(buildingID)
	-- Nothing to be done for deconstructing a building yet (except removing the building table)
	-- Frequency based scripts will stop automatically, but may need to enable a script to run deconstruction
	dfhack.script_environment("core/tables").Tables.BuildingTable[buildingID] = nil
end

local function scriptTrigger(buildingID, script, frequency)
	if df.building.find(buildingID) then
		dfhack.run_command(script)
		dfhack.script_environment("persist-delay").functionDelay(frequency,"enhanced/buildings","scriptTrigger",{buildingID,script,frequency})
	end	
end