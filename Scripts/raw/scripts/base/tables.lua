local utils = require "utils"
local split = utils.split_string
local json = require "json"

savepath = dfhack.getSavePath()
Tables = Tables

function initTables(scripts,systems)
	Tables = {}
	
	-- Game Tables
	Tables.GlobalTable = {}
	Tables.CounterTable = {}
	Tables.UnitTable = {}
	Tables.ItemTable = {}
	Tables.BuildingTable = {}
	Tables.EntityTable = {}
	
	-- Systems
	Tables.Systems = {}
	for _,system in pairs(systems) do
		n, Table = dfhack.script_environment(system).makeSystemTable()
		if n > 0 then
			Tables.Systems[system] = n
			Tables[system] = Table
			dfhack.script_environment(system).startSystemTriggers()
		end
	end
end

function loadFile(fname)
	Tables = json.decode_file(fname)
	
	for system,_ in pairs(Tables.Systems) do
		dfhack.script_environment(system).startSystemTriggers()
	end
end

function makeBuildingTable(building)
	if Tables.BuildingTable[building.id] then return Tables.BuildingTable[building.id] end
	
	Tables.BuildingTable[building.id] = {}
	Tables.BuildingTable[building.id].ID = building.id
	Tables.BuildingTable[building.id].Position = {}
	Tables.BuildingTable[building.id].Position.x = building.centerx
	Tables.BuildingTable[building.id].Position.y = building.centery
	Tables.BuildingTable[building.id].Position.z = building.z
	if building.custom_type >= 0 then
		Tables.BuildingTable[building.id].Token = df.global.world.raws.buildings.all[building.custom_type].code
	end
	
	return Tables.BuildingTable[building.id]
end

function makeEntityTable(entity)
	if Tables.EntityTable[entity.id] then return Tables.EntityTable[entity.id] end
	
	Tables.EntityTable[entity.id] = {}
	
	return Tables.EntityTable[entity.id]
end

function makeItemTable(item)
	if Tables.ItemTable[item.id] then return Tables.ItemTable[item.id] end
	
	Tables.ItemTable[item.id] = {}
	
	return Tables.ItemTable[item.id]
end

function makeUnitTable(unit)
	if Tables.UnitTable[unit.id] then return Tables.UnitTable[unit.id] end
	
	Tables.UnitTable[unit.id] = {}
	
	return Tables.UnitTable[unit.id]
end