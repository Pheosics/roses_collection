--@ module=true
-- Plugins
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local myMath = reqscript("functions/math")
local checkSystemTable = reqscript("core/systems").checkSystemTable

-- System Definition
Initialization = true

---- Name of the system
Name = "enhancedBuildings"

---- Raw file type to read
RawFileType = "Building"

---- Object function file
ObjFuncFile = "building"

---- List of currently accepted tokens for the system
Tokens = {
	DESCRIPTION        = {Type="Main", Subtype="String",  Name="Description"},
	OUTSIDE_ONLY       = {Type="Main", Subtype="Boolean", Name="OutsideOnly"}, -- Tested
	INSIDE_ONLY        = {Type="Main", Subtype="Boolean", Name="InsideOnly"}, -- Tested
	REQUIRED_WATER     = {Type="Main", Subtype="Number",  Name="RequiredWater"},
	REQUIRED_MAGMA     = {Type="Main", Subtype="Number",  Name="RequiredMagma"},
	REQUIRED_BUILDING  = {Type="Main", Subtype="Table",   Name="RequiredBuildings"},
	FORBIDDEN_BUILDING = {Type="Main", Subtype="Table",   Name="ForbiddenBuildings"},
	MAX_AMOUNT         = {Type="Main", Subtype="Number",  Name="MaxAmount"}, -- Tested
	SCRIPT             = {Type="Main", Subtype="Script",  Name="Scripts"}, -- Tested
	CONSTRUCTION_TIME  = {Type="Main", Subtype="Named",   Name="ConstructionTime", Names={Skill=2, BaseDur=3, SkillDecrease=4, MinDur=5}}, -- Tested
	MECHANICAL         = {Type="Sub",  Subtype="Set",     Name="Mechanical"}, -- Tested
	POWER_CONSUMED     = {Type="Sub",  Subtype="Number",  Name="PowerConsumed"}, -- Tested
	POWER_PRODUCED     = {Type="Sub",  Subtype="Number",  Name="PowerProduced"}, -- Tested
	GEAR_POINT         = {Type="Sub",  Subtype="Named",   Name="Gears", Names={x=2,y=3}},
	AUTO_GEARS         = {Type="Sub",  Subtype="Boolean", Name="AutoGears"}, -- Tested
	NEEDS_POWER        = {Type="Sub",  Subtype="Boolean", Name="NeedsPower"},
}

---- Eventful based functions
EventfulFunctions = {
	onJobInitiated = {
		buildingTrigger = function(job)
			if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
				buildingID = job.general_refs[0].building_id 
				checkBuildingStarted(buildingID,job) -- This runs building checks such as Inside Only
			elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
				buildingID = job.general_refs[0].building_id
				-- checkBuildingUnstarted(buildingID,job) -- Not currently needed
			end
		end
	},
	onJobCompleted = {
		buildingTrigger = function(job)
			if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
				buildingID = job.general_refs[0].building_id
				checkBuildingFinished(buildingID,job) -- This runs scripts
			elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
				buildingID = job.general_refs[0].building_id
				-- checkBuildingDestroyed(buildingID,job) -- Not currently needed
			end
		end
	},
}
---- Eventful based types
EventfulTypes = {
	JOB_INITIATED = 5,
	JOB_COMPLETED = 5,
}

---- Custom functions
CustomFunctions = {}

---- Custom types
CustomTypes = {}

function initialize()
	local systemTable = reqscript("core/tables").Tables[Name]
	if not systemTable then return end
	
	-- Run through necessary initialization (currently only Mechanical)
	registerBuilding = require('plugins.building-hacks').registerBuilding
	for token, Table in pairs(systemTable) do
		if Table.Mechanical then
			registerBuilding{name=token,
				consume = Table.Mechanical.PowerConsumed,
				produce = Table.Mechanical.PowerProduced,
				auto_gears = Table.Mechanical.AutoGears
			}
		end
	end
end

function checkBuildingStarted(buildingID,job)
	local building, Table = checkSystemTable(Name, ObjFuncFile, buildingID)
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
		return
	end
	
	if Table.ConstructionTime then
		local unit
		local skillLvl = 0
		for i,x in pairs(job.general_refs) do
			if x._type == df.general_ref_unit_workerst then
				unit = df.unit.find(job.general_refs[i].unit_id)
				break
			end
		end
		if unit and df.job_skill[Table.ConstructionTime.Skill] then
			skillLvl = dfack.units.getEffectiveSkill(unit,df.job_skill[Table.ConstructionTime.Skill])
		end
		local delay = Table.ConstructionTime.BaseDur - skillLvl*Table.ConstructionTime.SkillDecrease
		delay = math.max(delay,Table.ConstructionTime.MinDur)
		reqscript("functions/custom-events").delayJob(job,delay)
	end
end

function checkBuildingFinished(buildingID,job)
	local building, Table = checkSystemTable(Name, ObjFuncFile, buildingID)
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
			reqscript("functions/custom-events").repeatingScriptTrigger("building", buildingID, script, frequency, delayID)
		end
	end
end