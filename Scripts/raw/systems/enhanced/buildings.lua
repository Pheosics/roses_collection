local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
usages = {}

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

function startSystemTriggers()
	-- Event for initiating construction/deconstruction of a building (JOB_INITIATED)
	eventful.onJobInitiated.buildingTrigger = function(job)
		if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
			buildingID = job.general_refs[0].building_id -- Can the building ID ref ever be not the first one?
			checkBuildingStarted(buildingID) -- This runs building checks such as Inside Only
		elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
			buildingID = job.general_refs[0].building_id -- Can the building ID ref ever be not the first one?
			checkBuildingUnstarted(buildingID) -- This currently doesn't do anything
		end
	end

	-- Event for finishing construction/destruction of a building (JOB_COMPLETED)
	eventful.onJobCompleted.buildingTrigger = function(job)
		if job.job_type and df.job_type[job.job_type] == "ConstructBuilding" then
			buildingID = job.general_refs[0].building_id -- Can the building ID ref ever be not the first one?
			checkBuildingFinished(buildingID) -- This runs scripts
		elseif job.job_type and df.job_type[job.job_type] == "DestroyBuilding" then
			buildingID = job.general_refs[0].building_id -- Can the building ID ref ever be not the first one?
			checkBuildingDestroyed(buildingID) -- This currently doesn't do anything
		end
	end

    -- Enable events
	eventful.enableEvent(eventful.eventType.JOB_INITIATED,5)
	eventful.enableEvent(eventful.eventType.JOB_COMPLETED,5)
end

function checkSystemTable(buildingID)
	-- Make sure the building exists
	local building = df.building.find(buildingID)
	if not building then return nil end
	
	-- Make sure the building is a custom building
	local ctype = building:getCustomType()
	if ctype < 0 then return nil end
	
	-- Get the building token and check if there is an enhanced building entry
	local buildingToken = df.global.world.raws.buildings.all[ctype].code
	local Table = dfhack.script_environment("base/tables").Tables[Name]
	if not Table[buildingToken] then return nil end
	
	return building, Table[buildingToken]
end

function checkBuildingStarted(buildingID)
	building, Table = checkSystemTable(buildingID)
	if not building then return end
	
	local allow = true
	local pos = {}
	pos.x = building.centerx
	pos.y = building.centery
	pos.z = building.z
	designation = dfhack.maps.getTileBlock(pos).designation[pos.x%16][pos.y%16]
 
	-- Run through checks
	-- InsideOnly
	if Table.InsideOnly and allow then
		if designation.outside then allow = false end
	end
	
	-- OutsideOnly
	if Table.OutsideOnly and allow then
		if not designation.outside then allow = false end
	end
	
	-- RequiredWater
	if Table.RequiredWater and allow then
		local amount = 0
		for x = building.x1-1,building.x2+1 do
			for y = building.y1-1,building.y2+1 do
				for z = building.z-1,building.z do
					if dfhack.maps.isValidTilePos(x,y,z) then 
						designation = dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16]
						if not designation.liquid_type then amount = amount + designation.flow_size end
					end
				end
			end
		end
		if amount < Table.RequiredWater then allow = false end
	end
	
	-- RequiredMagma
	if Table.RequiredMagma and allow then
		local amount = 0
		for x = building.x1-1,building.x2+1 do
			for y = building.y1-1,building.y2+1 do
				for z = building.z-1,building.z do
					if dfhack.maps.isValidTilePos(x,y,z) then 
						designation = dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16]
						if designation.liquid_type then amount = amount + designation.flow_size end
					end
				end
			end
		end
		if amount < Table.RequiredMagma then allow = false end
	end
	
	-- RequiredBuildings
	if Table.RequiredBuildings and allow then
		for reqBldg,reqNum in pairs(Table.RequiredBuilding) do
			local check = false
			local n = 0
			for _,bldg in pairs(df.global.world.buildings.all) do
				if bldg:getCustomType() >= 0 and bldg:getCustomType().code == reqBldg then
					n = n+1
					if n >= reqNum then
						check = true
						break
					end
				end
			end
			if not check then
				allow = false
				break
			end
		end
	end
	
	-- ForbiddenBuildings
	if Table.ForbiddenBuildings and allow then
		for reqBldg,reqNum in pairs(Table.ForbiddenBuildings) do
			local check = false
			local n = 0
			for _,bldg in pairs(df.global.world.buildings.all) do
				if bldg:getCustomType() >= 0 and bldg:getCustomType().code == reqBldg then
					n = n+1
					if n >= reqNum then
						check = true
						break
					end
				end
			end
			if check then
				allow = false
				break
			end
		end
	end
	
	-- MaxAmount
	if Table.MaxAmount and allow then
		local n = 0
		for _,bldg in pairs(df.global.world.buildings.all) do
			if bldg:getCustomType() >= 0 and bldg:getCustomType() == building:getCustomType() then
				if n >= Table.MaxAmount then
					allow = false
					break
				end
				n = n + 1
			end
		end
	end
	
	if not allow then
		if building.jobs[0] and building.jobs[0].job_type == df.job_type.DestroyBuilding then return end
		local b = dfhack.buildings.deconstruct(building)
	end
end

function checkBuildingUnstarted(buildingID)
	-- Nothing to be done for beginning to deconstruct a building yet
	--building, Table = checkSystemTable(buildingID)
end

function checkBuildingFinished(buildingID)
	building, Table = checkSystemTable(buildingID)
	if not building then return end
	
	BuildingTable = dfhack.script_environment("base/tables").makeBuildingTable(building)
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
				dfhack.script_environment("persist-delay").environmentDelay(frequency,"enhanced/building","scriptTrigger",{building.id,script,frequency})
			end
		end
	end
end

function checkBuildingDestroyed(buildingID)
	-- Nothing to be done for deconstructing a building yet (except removing the building table)
	--building, Table = checkSystemTable(buildingID)
	--if not building then return end
	
	dfhack.script_environment("base/tables").Tables.BuildingTable[buildingID] = nil
end

function scriptTrigger(buildingID, script, frequency)
	if df.building.find(buildingID) then -- This should automatically stop the scripts from repeating if the building is deconstructed
		dfhack.run_command(script)
		dfhack.script_environment("persist-delay").environmentDelay(frequency,"enhanced/building","scriptTrigger",{building.id,script,frequency})
	end	
end