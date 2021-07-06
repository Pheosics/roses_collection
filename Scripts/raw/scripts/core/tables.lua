--@ module = true
local json = require "json"

savepath = dfhack.getSavePath()
Tables = Tables or {}

-- Initialize tables that will be used for the various scripts and systems included in this package
function initTables(scripts,systems,test,verbose)
	-- Game Tables
	Tables.GlobalTable = {}
	Tables.CounterTable = {}
	Tables.UnitTable = {}
	Tables.ItemTable = {}
	Tables.BuildingTable = {}
	Tables.EntityTable = {}
	
	-- Systems
	Tables.Systems = {}
	dfhack.color(COLOR_LIGHTRED)
	if verbose > 3 then print("\nBeginning system load\n") end
	for _,systemFile in pairs(systems) do
		system = reqscript(systemFile)
		n, Table = reqscript("core/systems").makeSystemTable(system,test,verbose > 3)
		if n > 0 then
			Tables.Systems[system.Name] = n
			Tables[system.Name] = Table
		end
	end
end

-- Load tables from a save file
function loadFile(fname)
	Tables = json.decode_file(fname)
end

-- Add a new entry in the Tables.BuildingTable
function makeBuildingTable(building)
	if Tables.BuildingTable[building.id] then return Tables.BuildingTable[building.id] end
	
	Tables.BuildingTable[building.id] = {}
	Tables.BuildingTable[building.id].ID = building.id
	Tables.BuildingTable[building.id].Position = {}
	Tables.BuildingTable[building.id].Position.x = building.centerx
	Tables.BuildingTable[building.id].Position.y = building.centery
	Tables.BuildingTable[building.id].Position.z = building.z
	Tables.BuildingTable[building.id].Type = building.type
	Tables.BuildingTable[building.id].Subtype = building.subtype
	Tables.BuildingTable[building.id].Customtype = building.customtype
	Tables.BuildingTable[building.id].Hardcoded = building.subtype ~= "CUSTOM"
	if Tables.BuildingTable[building.id].Hardcoded then
		Tables.BuildingTable[building.id].Token = building.Token
	else
		Tables.BuildingTable[building.id].Token = building.Token
	end
	
	return Tables.BuildingTable[building.id]
end

-- Add a new entry in the Tables.EntityTable
function makeEntityTable(entity)
	if Tables.EntityTable[entity.id] then return Tables.EntityTable[entity.id] end
	
	Tables.EntityTable[entity.id] = {}
	
	return Tables.EntityTable[entity.id]
end

-- Add a new entry in the Tables.ItemTable
function makeItemTable(item)
	if Tables.ItemTable[item.id] then return Tables.ItemTable[item.id] end
	
	Tables.ItemTable[item.id] = {}
	
	return Tables.ItemTable[item.id]
end

-- Add a new entry in the Tables.UnitTable
function makeUnitTable(unit)
	if Tables.UnitTable[unit.id] then return Tables.UnitTable[unit.id] end
	
	Tables.UnitTable[unit.id] = {}
	
	return Tables.UnitTable[unit.id]
end