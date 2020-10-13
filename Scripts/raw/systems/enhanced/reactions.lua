--@ module=true
-- Plugins
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local myMath = reqscript("functions/math")
local myIO = reqscript("functions/io")
local map = reqscript("functions/map").getMap()
local getJob = reqscript("functions/job").getJob
local getReaction = reqscript("functions/reaction").getReaction
local getBuilding = reqscript("functions/building").getBuilding
local checkSystemTable = reqscript("core/systems").checkSystemTable

-- System Definition
---- Name of the system
Name = "enhancedReactions"

---- Raw file type to read
RawFileType = "Reaction"

---- Object function file
ObjFuncFile = "Reaction"

---- List of currently accepted tokens for the system
Tokens = {
	-- Base Tokens
	DESCRIPTION = {Type="Main", Subtype="String", Name="Description", Purpose="Sets a description to be used for the journal utility in the future"},
	
	-- Trigger Tokens
	ON_QUEUE   = {Type="Sub", Subtype="Set", Name="OnQueue",   Purpose="Sets up a trigger for when the reaction is started (before materials are gathered)"},
	ON_START   = {Type="Sub", Subtype="Set", Name="OnStart",   Purpose="Sets up a trigger for when the reaction is started (after materials are gathered)"},
	ON_FINISH  = {Type="Sub", Subtype="Set", Name="OnFinish",  Purpose="Sets up a trigger for when the reaction is finished (no product necessary)"},
	ON_PRODUCT = {Type="Sub", Subtype="Set", Name="OnProduct", Purpose="Sets up a trigger for when the reaction is finished and a product is created"},
	
	-- Script Tokens
	SCRIPT           = {Type="Sub", Subtype="ScriptC", Name="ChanceScripts",    Purpose="A dfhack script to run with a specific chance when triggered"},
	REPEATING_SCRIPT = {Type="Sub", Subtype="ScriptF", Name="RepeatingScripts", Purpose="A dfhack script to run with a specific frequency"},
	
	--
	CREATE = {Type="Sub", Subtype="NamedList", Name="Products", Purpose="Add custom products to a reaction (produced for any specified trigger)",
				Names={Probability=2, Amount=3, Type=4, Subtype=5, MatType=6, MatSubtype=7}},

	-- Shortcut Tokens
	PRODUCT        = {Type="OnFinish", Subtype="NamedList", Name="Products", Purpose="Add custom products to a reaction (only for when the reaction finishes)",
						Names={Probability=2, Amount=3, Type=4, Subtype=5, MatType=6, MatSubtype=7}},
	REQUIRED_WATER = {Type="OnQueue", Subtype="Number", Name="RequiredWater", Purpose="Amount of nearby water required for the reaction (does not consume the water)"},
	REQUIRED_MAGMA = {Type="OnQueue", Subtype="Number", Name="RequiredMagma", Purpose="Amount of nearby magma required for the reaction (does not consume the magma)"},
	--CONSUMED_WATER = {Type="OnQueue", Subtype="Number", Name="ConsumedWater", Purpose="Amount of nearby water required for the reaction (consumes the water)"},
	--CONSUMED_MAGMA = {Type="OnQueue", Subtype="Number", Name="ConsumedMagma", Purpose="Amount of nearby magma required for the reaction (consumes the magma)"},
	REACTION_TIME  = {Type="OnStart", Subtype="Named", Name="ReactionTime", Purpose="Changes the amount of time it takes to complete the reaction once all materials are brought to it", 
						Names={Skill=2, BaseDur=3, SkillDecrease=4, MinDur=5}},

}

---- Eventful based functions
EventfulFunctions = {
	onJobInitiated = {
		reactionTrigger = function(job)
			if not job.reaction_name or job.reaction_name == '' then return end
			check(job.reaction_name, "OnBegin", job) -- This runs OnQueue and OnStart triggers
		end
	},
	onJobCompleted = {
		reactionTrigger = function(job)
			if not job.reaction_name or job.reaction_name == '' then return end
			check(job.reaction_name, "OnFinish", job)
		end
	},
	onReactionComplete = {
		reactionTrigger = function(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
			checkReactionProduct(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native) -- System specific check
		end
	},
}
---- Eventful based types
EventfulTypes = {
	JOB_INITIATED = 1,
	JOB_COMPLETED = 0,
	--JOB_PRODUCT = 1, Not actually a thing, just here so I won't forget about it
}
CustomFunctions = {
}
CustomTypes = {
}

Examples = [===[
	[REACTION:MAKE_WAX_CRAFTS]
		{REACTION_TIME:WAX_WORKING:1:1:1}
		{PRODUCT:100:7:LIQUID:WATER:NONE:NONE}
		{PRODUCT:100:150:FLOW:MATERIALDUST:INORGANIC:SLADE}
		{ON_QUEUE} -- Triggers when the reaction is queued
			{SCRIPT:devel/print-args ON_QUEUE REACTION_NAME WORKER_ID BUILDING_ID [ LOCATION ]:100}
		{ON_START} -- Triggers after the ingredients are gathered
			{SCRIPT:devel/print-args ON_START REACTION_NAME WORKER_ID BUILDING_ID [ LOCATION ]:100}
		{ON_FINISH} -- Triggers when the reaction is finished, no product needed
			{SCRIPT:devel/print-args ON_FINISH REACTION_NAME WORKER_ID BUILDING_ID [ LOCATION ]:100}
		{ON_PRODUCT} -- Triggers when the reaction is finished and a product is produced
			{SCRIPT:devel/print-args ON_PRODUCT REACTION_NAME WORKER_ID BUILDING_ID [ LOCATION ]:100}
		[NAME:make wax crafts]
		[BUILDING:CRAFTSMAN:CUSTOM_SHIFT_W]
		[REAGENT:wax:150:GLOB:NONE:NONE:NONE]
		[REACTION_CLASS:WAX]
		[PRODUCT:100:1:CRAFTS:NONE:GET_MATERIAL_FROM_REAGENT:wax:NONE]
		[SKILL:WAX_WORKING]
]===]

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
	for Type,v in pairs(CustomTypes) do
		repeats.scheduleUnlessAlreadyScheduled(Type,v.ticks,"ticks",v.func)
	end
end

-- Check function (run when the Eventful or Custom functions are triggered)
function check(reactionID, checkType, job)
	local reaction, Table = checkSystemTable(Name, ObjFuncFile, reactionID)
	local job = getJob(job)
	if not reaction or not Table or not job then return end -- Is there a chance the job will be gone by the time the trigger happens? -ME
	
	if checkType == "OnBegin" then
		-- Seperate out OnQueue vs OnStart triggers
		if Table["OnQueue"] then checkReactionQueued(reaction, Table["OnQueue"], job) end
		if Table["OnStart"] then checkReactionStarted(reaction, Table["OnStart"], job) end
	else
		if not Table[checkType] then return end
		trigger(reaction, Table[checkType], job)
	end
end

-- Trigger function (run if correctly triggered)
function trigger(reaction, Table, job)
	local worker = job.getWorker() or {}
	local building = job.getHolder() or {}
	
	if Table.Products then
		for _, product in pairs(Table.Products) do
			local chance = product.Probability or 100
			if myMath.roll(chance) then
				printall(product)
				-- Generate material type and subtype
				local mat_type = 0
				local mat_subtype = 0
				local mat_index = 0
				if dfhack.matinfo.find(product.MatType..":"..product.MatSubtype) then
					local mat = dfhack.matinfo.find(product.MatType..":"..product.MatSubtype)
					mat_type = mat.type
					mat_subtype = mat.subtype
					mat_index = mat.index
				elseif product.MatType == "NONE" then
				elseif product.MatType == "" then
				end

				-- Generate product type and subtype
				if product.Type == "FLOW" then -- Product types that can't be decoded
					local flowType = reqscript("functions/map").flow_types[product.Subtype]
					local density = product.Amount
					map:createFlow(worker.pos,flowType,density,mat_index,false,mat_type)
				elseif product.Type == "LIQUID" then
					local liquidType = product.Subtype
					local depth = product.Amount
					map:createLiquid(worker.pos, depth, liquidType=="MAGMA")
				elseif product.Type == "" then
				else
				end
			end
		end
	end
	
	-- Trigger repeating scripts
	if Table.RepeatingScripts then
		local scriptTable = {}
		scriptTable.reaction_name = job.reaction_name
		scriptTable.worker_id = worker.id or -1
		scriptTable.building_id = building.id or -1
		scriptTable.location = myIO.locationString(building.centerx,building.centery,building.z)
		for i,x in pairs(Table.RepeatingScripts) do
			local script = myIO.gsub_script(x.Script,scriptTable)
			local frequency = x.Frequency
			repeatScript("building", buildingID, script, frequency, delayID)
		end
	end
	
	-- Trigger chance scripts
	if Table.ChanceScripts then
		local scriptTable = {}
		scriptTable.reaction_name = job.reaction_name
		scriptTable.worker_id = worker.id or -1
		scriptTable.building_id = building.id or -1
		scriptTable.location = myIO.locationString(building.centerx,building.centery,building.z)
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
function checkReactionQueued(reaction, Table, job)
	local allow = true
	local building = getBuilding(job.getHolder())
	
	if allow and Table.RequiredWater and building:nearbyWater() < Table.RequiredWater then allow = false end
	if allow and Table.RequiredMagma and building:nearbyMagma() < Table.RequiredMagma then allow = false end
	
	if not allow then
		job.removeJob()
		return
	end
	
	trigger(reaction, Table, job)
end

function checkReactionStarted(reaction, Table, job)
	-- Completion timer is negative while gathering materials for the reaction
	if job.completion_timer < 0 then
		dfhack.timeout(1,'ticks',function () checkReactionStarted(reaction, Table, job) end)
		return
	end
	
	if Table.ReactionTime then
		local unit = job.getWorker()
		local skillLvl = 0
		if unit and df.job_skill[Table.ReactionTime.Skill] then
			skillLvl = dfhack.units.getEffectiveSkill(unit,df.job_skill[Table.ReactionTime.Skill])
		end
		local delay = Table.ReactionTime.BaseDur - skillLvl*Table.ReactionTime.SkillDecrease
		delay = math.max(delay,Table.ReactionTime.MinDur)
		job:delay(delay)
	end
	
	trigger(reaction, Table, job)
end

job_product_triggered = {}
function checkReactionProduct(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
	local job = unit.job.current_job
	if job_product_triggered[job.id] then return end
	local reactionID = reaction.code
	check(reactionID, "OnProduct", job)
	job_product_triggered[job.id] = true
end
