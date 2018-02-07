-- Only usable with the Enhanced System - Buildings SubSystem

local utils = require 'utils'
local persistTable = require 'persist-table'

if not safe_index(persistTable.GlobalTable.roses,'EnhancedBuildingTable') then return end
EBuildings = persistTable.GlobalTable.roses.EnhancedBuildingTable

validArgs = utils.invert({
	'created',
	'destroyed',
	'buildingID',
	'buildingToken',
	'buildingLocation'
})
local args = utils.processArgs({...}, validArgs)

if not args.created and not args.destroyed then args.created = true end

if args.created then
 if args.buildingID and tonumber(args.buildingID) then
  building = df.building.find(tonumber(args.buildingID))
  if not building then
   error 'Problem finding builing, possibly has been deconstructed'
  end
 end
 if not building then
  error 'Must specify buildingID when using -created'
 end
 ctype = building:getCustomType()
 if ctype < 0 then return end
 buildingToken = df.global.world.raws.buildings.all[ctype].code
 if not EBuildings[buildingToken] then return end
 dfhack.script_environment('functions/enhanced').buildingCreated(building)
 if persistTable.GlobalTable.roses then
  persistTable.GlobalTable.roses.BuildingTable[tostring(building.id)] = {}
  persistTable.GlobalTable.roses.BuildingTable[tostring(building.id)].Token = buildingToken
  persistTable.GlobalTable.roses.BuildingTable[tostring(building.id)].x = tostring(building.centerx)
  persistTable.GlobalTable.roses.BuildingTable[tostring(building.id)].y = tostring(building.centery)
  persistTable.GlobalTable.roses.BuildingTable[tostring(building.id)].z = tostring(building.z)
 end
end

if args.destroyed then
 if not persistTable.GlobalTable.roses then return end
 buildings = persistTable.GlobalTable.roses.BuildingTable
 if buildings[tostring(args.buildingID)] then
  buildingToken = buildings[tostring(buildingID)].Token
  building = {}
  building.id = buildingID
  building.centerx = buildings[tostring(buildingID)].x
  building.centery = buildings[tostring(buildingID)].y
  building.z = buildings[tostring(buildingID)].z
  dfhack.script_environment('functions/enhanced').buildingDestroyed(building)
  persistTable.GlobalTable.roses.BuildingTable[tostring(buildingID)] = nil
 end
end