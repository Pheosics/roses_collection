--@ module=true
-- Plugins
---- Universal Plugins
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local myMath = reqscript("functions/math")
local myIO = reqscript("functions/io")
local repeatScript = reqscript("functions/custom-events").repeatingScriptTrigger
local checkSystemTable = reqscript("core/systems").checkSystemTable

---- System Specific Plugins
local getJob = reqscript("functions/job").getJob

-- System Definition
Initialization = true

---- Name of the system
Name = "enhancedBuildings"

---- Raw file type to read
RawFileType = "Building"

---- Object function file
ObjFuncFile = "Building"

---- List of currently accepted tokens for the system
Tokens = {
	-- Base Tokens
	DESCRIPTION = {Type="Main", Subtype="String",  Name="Description", Purpose="Sets a description to be used for the journal utility in the future"},

	-- Trigger Tokens
	ON_QUEUE       = {Type="Sub", Subtype="Set", Name="OnQueue",       Purpose="Sets up a trigger for when the building is started (before materials are gathered)"},
	ON_START       = {Type="Sub", Subtype="Set", Name="OnStart",       Purpose="Sets up a trigger for when the building is started (after materials are gathered)"},
	ON_FINISH      = {Type="Sub", Subtype="Set", Name="OnFinish",      Purpose="Sets up a trigger for when the building is finished"},
	ON_DECONSTRUCT = {Type="Sub", Subtype="Set", Name="OnDeconstruct", Purpose="Sets up a trigger for when the building is being deconstructed"},
	--ON_DEMOLISHED  = {Type="Sub", Subtype="Set", Name="OnDemolished",  Purpose="Sets up a trigger for when the building is demolished (e.g. from a building destroyer)"},
	ON_REMOVED     = {Type="Sub", Subtype="Set", Name="OnRemoved",     Purpose="Sets up a trigger for when the building is fully removed (from deconstruction)"},

	-- Script Tokens
	REPEATING_SCRIPT = {Type="Sub", Subtype="ScriptF", Name="RepeatingScripts", Purpose="A dfhack script to run at a specific frequency (if # == 0 the script is only run once)"},
	SCRIPT           = {Type="Sub", Subtype="ScriptC", Name="ChanceScripts",    Purpose="A dfhack script to run once with a specific probability"},
	
	-- Mechanical Building Tokens
	MECHANICAL         = {Type="Sub",  Subtype="Set",     Name="Mechanical",    Purpose="Sets the building as a mechanical building through require('plugins.building-hacks').registerBuilding"},
	POWER_CONSUMED     = {Type="Sub",  Subtype="Number",  Name="PowerConsumed", Purpose="Amount of power consumed if {MECHANICAL}"},
	POWER_PRODUCED     = {Type="Sub",  Subtype="Number",  Name="PowerProduced", Purpose="Amount of power produced if {MECHANICAL}"},
	GEAR_POINT         = {Type="Sub",  Subtype="Named",   Name="Gears",         Purpose="Location of gear connection point if {MECHANICAL}", 
							Names={x=2,y=3}},
	AUTO_GEARS         = {Type="Sub",  Subtype="Boolean", Name="AutoGears",     Purpose="Sets auto_gears to true for registerBuilding"},
	NEEDS_POWER        = {Type="Sub",  Subtype="Boolean", Name="NeedsPower",    Purpose="Sets needs_power to true for registerBuilding"},
	
	-- Shortcut Tokens
	---- Check Building Tokens
	OUTSIDE_ONLY       = {Type="OnQueue", Subtype="Boolean", Name="OutsideOnly",        Purpose="If present, will only allow construction if all squares are outside"},
	INSIDE_ONLY        = {Type="OnQueue", Subtype="Boolean", Name="InsideOnly",         Purpose="If present, will only allow construction if all squares are inside"},
	REQUIRED_WATER     = {Type="OnQueue", Subtype="Number",  Name="RequiredWater",      Purpose="Amount of water needed around and/or under the building to be constructed"},
	REQUIRED_MAGMA     = {Type="OnQueue", Subtype="Number",  Name="RequiredMagma",      Purpose="Amount of magma needed around and/or under the building to be constructed"},
	REQUIRED_BUILDING  = {Type="OnQueue", Subtype="Table",   Name="RequiredBuildings",  Purpose="Amount of specific building needed to exist in order for this building to be constructed"},
	FORBIDDEN_BUILDING = {Type="OnQueue", Subtype="Table",   Name="ForbiddenBuildings", Purpose="Amount of specific building needed to exist in order for this building to not be constructed"},
	MAX_AMOUNT         = {Type="OnQueue", Subtype="Number",  Name="MaxAmount",          Purpose="Max number of this building that can be constructed (equivalent to {FORBIDDEN_BUILDING:THIS_BUILDING:#}"},
	---- Modify Building Tokens
	CONSTRUCTION_TIME = {Type="OnStart", Subtype="Named",   Name="ConstructionTime", Purpose="Changes the amount of time it takes to construct the building once all materials are brought to it", 
							Names={Skill=2, BaseDur=3, SkillDecrease=4, MinDur=5}},

}

---- Eventful based functions
EventfulFunctions = {
	onJobInitiated = {
		buildingTrigger = function(job)
			if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
				buildingID = job.general_refs[0].building_id 
				check(buildingID, "OnBegin", job) -- This runs OnQueue and OnStart triggers
			elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
				buildingID = job.general_refs[0].building_id
				check(buildingID, "OnDeconstruct", job)
			end
		end
	},
	onJobCompleted = {
		buildingTrigger = function(job)
			if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
				buildingID = job.general_refs[0].building_id
				check(buildingID, "OnFinish", job)
			elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
				buildingID = job.general_refs[0].building_id
				check(buildingID, "OnRemoved", job)
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

---- Examples for System
Examples = [===[
	[BUILDING_WORKSHOP:FOUNTAIN]
		[NAME:Fountain]
		{DESCRIPTION:A building that continually produces mist}
		... DF Building Stuff ...
		{REQUIRED_WATER:4}
		{ON_FINISH}
			{REPEATING_SCRIPT:map/spawn-flow -pos [ BUILDING_LOCATION ] -type Mist -density 100:25}
		
	[BUILDING_WORKSHOP:COMPLEX_BUILDING]
		[NAME:Complex Building]
		{DESCRIPTION:A complex building that takes a long time to build}
		... DF Building Stuff ...
		{CONSTRUCTION_TIME:MECHANICS:1000:10:1} Base construction time is 1000 ticks, lowers by 10 for each skill level, max build speed is 1
		
	[BUILDING_WORKSHOP:WINDMILL]
		[NAME:Windmill]
		{DESCRIPTION:A building that can only be built outside and makes power}
		... DF Building Stuff ...
		{OUTSIDE_ONLY}
		{MECHANICAL}
			{AUTO_GEARS}
			{POWER_PRODUCED:25}
]===]

-- Initialization function (run when starting DF)
function initialize()
	local systemTable = reqscript("core/tables").Tables[Name]
	if not systemTable then return end

	-- Eventful Triggers
	for k,t in pairs(EventfulFunctions) do
		for name,func in pairs(t) do
			eventful[k][name] = function(...) return func(...) end
		end
	end
	for Type,ticks in pairs(EventfulTypes) do
		eventful.enableEvent(eventful.eventType[Type],ticks)
	end
	
	-- Custom Triggers
	---- None
	
	-- Run through necessary initialization
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

-- Check function (run when the Eventful or Custom functions are triggered)
function check(buildingID, checkType, job)
	local building, Table = checkSystemTable(Name, ObjFuncFile, buildingID)
	local job = getJob(job)
	if not building or not Table or not job then return end -- Is there a chance the job will be gone by the time the trigger happens? -ME
	
	if checkType == "OnBegin" then
		-- Seperate out OnQueue vs OnStart triggers
		if Table["OnQueue"] then checkBuildingQueued(building, Table["OnQueue"], job) end
		if Table["OnStart"] then checkBuildingStarted(building, Table["OnStart"], job) end
	else
		if not Table[checkType] then return end
		if checkType == "OnFinish" then
			BuildingTable = dfhack.script_environment("core/tables").makeBuildingTable(building)
			BuildingTable.Enhanced = true
		end
		trigger(building, Table[checkType], job)
	end
end

-- Trigger function (run if correctly triggered)
function trigger(building, Table, job)
	-- Trigger repeating scripts
	if Table.RepeatingScripts then
		local scriptTable = {}
		scriptTable.building_id = building.id
		scriptTable.building_token = BuildingTable.Token
		scriptTable.building_location = myIO.locationString(building.centerx,building.centery,building.z)
		for i,x in pairs(Table.RepeatingScripts) do
			local script = myIO.gsub_script(x.Script,scriptTable)
			local frequency = x.Frequency
			repeatScript("building", buildingID, script, frequency, delayID)
		end
	end
	
	-- Trigger chance scripts
	if Table.ChanceScripts then
		local scriptTable = {}
		scriptTable.building_id = building.id
		scriptTable.building_token = BuildingTable.Token
		scriptTable.building_location = myIO.locationString(building.centerx,building.centery,building.z)
		for i,x in pairs(Table.ChanceScripts) do
			local script = x.Script
			local chance = x.Chance or 100
			if myMath.roll(chance) then
				dfhack.run_command(myIO.gsub_script(script,scriptTable))
			end
		end
	end
end

-- System specific functions
function checkBuildingQueued(building, Table, job)
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
	
	trigger(building, Table, job)
end

function checkBuildingStarted(building, Table, job)
	-- Completion timer is negative while gathering materials for the building
	if job.completion_timer < 0 then
		dfhack.timeout(1,'ticks',function () checkBuildingStarted(building, Table, job) end)
		return
	end
		
	if Table.ConstructionTime then
		local unit = job.getWorker()
		local skillLvl = 0
		if unit and df.job_skill[Table.ConstructionTime.Skill] then -- How do we get the job_skill required for building the building? -ME
			skillLvl = dfack.units.getEffectiveSkill(unit,df.job_skill[Table.ConstructionTime.Skill])
		end
		local delay = Table.ConstructionTime.BaseDur - skillLvl*Table.ConstructionTime.SkillDecrease
		delay = math.max(delay,Table.ConstructionTime.MinDur)
		job:delay(delay)
	end
	
	trigger(building, Table, job)
end