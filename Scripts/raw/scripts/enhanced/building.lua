-- Only usable with the Enhanced System - Buildings SubSystem

local utils = require 'utils'

validArgs = utils.invert({
	'created',
	'destroyed',
	'buildingID',
	'buildingToken',
	'buildingLocation'
})
local args = utils.processArgs({...}, validArgs)

building = nil

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
 dfhack.script_environment('functions/enhanced').buildingCreated(building)
end

if args.destroyed then
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses then return end
 if args.buildingID and tonumber(args.buildingID) then
  building = roses.BuildingTable[tonumber(args.buildingID)]
  if not building then
   error 'Problem finding destroyed building, no Building Table was found'
  end
 end
 if not building then
  error 'Must specify buildingID when using -destroyed'
 end
 dfhack.script_environment('functions/enhanced').buildingDestroyed(building)
end