-- originally outside-only by expwnent
-- expanded by Roses (Pheosics)
--
local eventful = require 'plugins.eventful'
local utils = require 'utils'
local split = utils.split_string

registeredBuildings = registeredBuildings or {}
checkEvery = checkEvery or 100
timeoutId = timeoutId or nil

local usage = [====[
trigger/building
=====================
This allows you to specify certain custom buildings with a variety of build conditions. 
If the player attempts to build a building in an inappropriate location,
the building will be destroyed.

Arguments::

    -clear
        clears the list of registered buildings
    -building name
        specify the id of the building
    -location OUTSIDE or INSIDE
        state whether the building needs to be built outside or inside
    -zLevels #
        the number of z levels needed for the building
    -requiredBuilding [ ID:# ]
        the id and number of a building(s) that needs to already be built to continue
    -forbiddenBuilding [ ID:# ]
        the id and number of a building(s) that cannot be already built to continue
    -maxNumber #
        the maximum number of this type of building
    -requiredWater #
        the amount of water next to the building that is required to build
        it will check every tile between x1-1->x2+1, y1-1->y2+1, and z-1->z
    -requiredMagma #
        the amount of water next to the building that is required to build
        it will check every tile between x1-1->x2+1, y1-1->y2+1, and z-1->z
    -command [ commandStrs ]
        specify the command to be executed if the building passes the checks
        commandStrs
            \\BUILDING_ID
            \\BUILDING_TOKEN
            \\BUILDING_LOCATION
            anything -> anything
]====]

validArgs = validArgs or utils.invert({
 'help',
 'clear',
 'building',
 'location',
 'zLevels',
 'requiredBuilding',
 'forbiddenBuilding',
 'maxNumber',
 'requiredWater',
 'requiredMagma',
 'command', 
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.clear then
 registeredBuildings = {}
end

if args.checkEvery then
 if not tonumber(args.checkEvery) then
  error('Invalid checkEvery.')
 end
 checkEvery = tonumber(args.checkEvery)
end

if not args.building then
 return
end

registeredBuildings[args.building] = {}

if args.location then
 if args.location == 'OUTSIDE' then registeredBuildings[args.building].Outside = true end
 if args.location == 'INSIDE' then registeredBuildings[args.building].Inside = true end
end

if args.zLevels then registeredBuildings[args.building].ZLevels = tonumber(args.zLevels) or -1 end
if args.requiredBuilding then 
 registeredBuildings[args.building].RequiredBuilding = args.requiredBuilding 
end
if args.forbiddenBuilding then 
 registeredBuildings[args.building].ForbiddenBuilding = args.forbiddenBuilding
end
if args.maxNumber then registeredBuildings[args.building].MaxNumber = tonumber(args.maxNumber) or -1 end
if args.requiredWater then registeredBuildings[args.building].RequiredWater = tonumber(args.requiredWater) or -1 end
if args.requiredMagma then registeredBuildings[args.building].RequiredMagma = tonumber(args.requiredMagma) or -1 end

-- Eventful Function
local function checkBuilding(buildingID)
 local building = df.building.find(buildingID)
 local buildingToken = building:getCustomType()
 if buildingToken < 0 then return end
 buildingToken = buildingToken.code
 if not registeredBuildings[buildingToken] then return end
 local pos = {}
 pos.x = building.centerx
 pos.y = building.centery
 pos.z = building.z
 designation = dfhack.maps.getTileBlock(pos).designation[pos.x%16][pos.y%16]

 trigger = registeredBuildings[buildingToken]
 destroy = false
 if trigger.Outside then -- Check to make sure the building is being built outside
  if not designation.outside then destroy = true end
 end

 if trigger.Inside and not destroy then -- Check to make sure the building is being built inside
  if designation.outside then destroy = true end
 end

 if trigger.ZLevels and trigger.ZLevels >= 2 and not destroy then -- Check that there are the required number of Z levels clear
  for x = building.x1,building.x2 do
   for y = building.y1,building.y2 do
    for z = building.z,building.z+trigger.ZLevels-1 do
     if dfhack.maps.isValidTilePos(x,y,z) and not destroy then
      if df.tiletype.attrs[dfhack.maps.getTileType(x,y,z)].material ~= df.tiletype_material.AIR then
       destroy = true
       break
      end
     end
    end
   end
  end
 end

 if trigger.RequiredBuilding and not destroy then -- Check that the prerequisite building is already built 
  for _,req in pairs(trigger.RequiredBuilding) do
   reqBldg = split(req,':')[1]
   reqNum = split(req,':')[2] or 1
   check = false
   n = 0
   for _,bldg in pairs(df.global.world.buildings.all) do
    if bldg:getCustomType() >= 0 and bldg:getCustomType().code == req then
     n = n+1
     if n >= reqNum then
      check = true
      break
     end
    end
   end
   if not check then
    destroy = true
    break
   end
  end
 end
   
 if trigger.ForbiddenBuilding and not destroy then -- Check that the forbidden building is not already built
  for _,req in pairs(trigger.ForbiddenBuilding) do
   reqBldg = split(req,':')[1]
   reqNum = split(req,':')[2] or 1
   check = true
   n = 0
   for _,bldg in pairs(df.global.world.buildings.all) do
    if bldg:getCustomType() >= 0 and bldg:getCustomType().code == req then
     n = n+1
     if n >= reqNum then
      check = false
      break
     end
    end
   end
   if not check then
    destroy = true
    break
   end
  end
 end

 if trigger.MaxNumber and not destroy then -- Check that there are less than max number of the building
  i = 0
  for _,bldg in pairs(df.global.world.buildings.all) do
   if bldg:getCustomType() >= 0 and bldg:getCustomType().code == buildingToken then
    i = i+1
    if i >= trigger.MaxNumber then
     destroy = true
     break
    end
   end
  end
 end

 if trigger.RequiredWater and not destroy then -- Check that there is enough water present nearby
  amount = 0
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
  if amount < trigger.RequiredWater then destroy = true end
 end

 if trigger.RequiredMagma and not destroy then -- Check that there is enough magma present nearby
  amount = 0
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
  if amount < trigger.RequiredMagma then destroy = true end
 end

 if destroy then 
  destroyBuilding(building)
  return
 end

 if trigger.command then
  processCommand(building,trigger.command)
 end
end

local function destroyBuilding(building)
 if #building.jobs > 0 and building.jobs[0] and building.jobs[0].job_type == df.job_type.DestroyBuilding then
  return
 end
 local b = dfhack.buildings.deconstruct(building)
 if b then
  --TODO: print an error message to the user so they know
  return
 end
-- building.flags.almost_deleted = 1
end

local function processCommand(building,command)
 local command2 = {}
 for i,arg in ipairs(command) do
  if arg == '\\BUILDING_ID' then
   command2[i] = '' .. building.id
  elseif arg == '\\BUILDING_TOKEN' then
   command2[i] = '' .. building:getCustomType().code
  elseif arg == '\\BUILDING_LOCATION' then
   command2[i] = '[ '..building.centerx..' '..building.centery..' '..building.z..' ]'
  else
   command2[i] = arg
  end
 end
 dfhack.run_command(table.unpack(command2))
end

-- Enable Event Checking
eventful.enableEvent(eventful.eventType.UNLOAD,1)
eventful.onUnload.buildingTrigger = function()
 registeredBuildings = {}
 checkEvery = 100
 timeoutId = nil
end

eventful.enableEvent(eventful.eventType.BUILDING, 100)
eventful.onBuildingCreatedDestroyed.outsideOnly = function(buildingID)
 checkBuilding(buildingID)
end