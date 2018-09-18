--unit/move.lua
local usage = [====[

unit/move
========
Purpose::
    Moves a unit to a given location or a location based on given inputs

Function Calls::
    unit.move
    map.getPositionUnitRandom
    building.findBuilding
    misc.permute

Arguments::
    -unit        UNIT_ID
    -location    [ x y z ]
        A sprecific location to move to
    -random      [ x y z ] or #
        Either a distance in x, y, z about the unit to move to randomly
        Or a radius about the unit to move to randomly
    -building    BUILDING_ID or BUILDING_TOKEN or Building Type
        Either an ID of a building or the building token
        Valid Types:
            Random
            Owned
            TradeDepot
            Trap
    -area        Area Type
        Valid Types:
            Idle
            Destination
            Opponent
            Farm
            Meeting Area
            WaterSource
            Hospital
            Barracks
            Stockpile
    -construction    CONSTRUCTION_ID or Construction Type
        Valid Types:
            WallTop

Examples::
    unit/move -unit \\UNIT_ID -building SCREW_PRESS
    unit/move -unit \\UNIT_ID -building \\BUILDING_ID
    unit/move -unit \\UNIT_ID -area Idle
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'unit',
 'location',
 'random',
 'building',
 'area',
 'construction',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end
dur = tonumber(args.dur) or 0

if args.location then
 location = args.location
elseif args.random then
 if type(args.random) == 'string' then 
  radius = {tonumber(args.random), tonumber(args.random), tonumber(args.random)}
 else
  radius = args.random
 end
 location = dfhack.script_environment('functions/map').getPositionUnitRandom(unit,radius)
elseif args.building then
 if tonumber(args.building) then
  building = df.building.find(tonumber(args.building))
 elseif args.building == 'Random' then
  list = df.global.world.buildings.all
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Building Found')
   return
  end
 elseif args.building == 'Owned' then
  list = unit.owned_buildings
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Owned Building Found')
   return
  end
 elseif args.building == 'TradeDepot' then
  list = df.global.world.buildings.other.TRADE_DEPOT
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Trade Depot Found')
   return
  end
 elseif args.building == 'Trap' then
  list = df.global.world.buildings.other.TRAP
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Building Found')
   return
  end
 elseif args.building == 'Wagon' then
  list = df.global.world.buildings.other.WAGON
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Building Found')
   return
  end
 else
  building = dfhack.script_environment('functions/building').findBuilding({'RANDOM','CUSTOM',args.building})[1]
 end
 if building then
  location = {building.centerx,building.centery,building.z}
 else
  print('No Building Found')
  return
 end
elseif args.area then
 if args.area == 'Idle' then
  location = unit.idle_area
 elseif args.area == 'Destination' then
  location = unit.path.dest
 elseif args.area == 'Opponent' then
  location = unit.opponent.unit_pos
 elseif args.area == 'Farm' then
  list = df.global.world.buildings.other.FARM_PLOT
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Farm Plot Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'MeetingArea' then
  list = {}
  n = 1
  for _,zone in pairs(df.global.world.buildings.other.ANY_ZONE) do
   if zone.zone_flags.meeting_area then
    list[n] = zone
    n = n + 1
   end
  end
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[1]
  else
   print('No Meeting Area Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'WaterSource' then
  list = {}
  n = 1
  for _,zone in pairs(df.global.world.buildings.other.ANY_ZONE) do
   if zone.zone_flags.water_source then
    list[n] = zone
    n = n + 1
   end
  end
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[1]
  else
   print('No Water Source Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'Hospital' then
  list = df.global.world.buildings.other.ANY_HOSPITAL
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Hospital Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'Barracks' then
  list = df.global.world.buildings.other.ANY_BARRACKS
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Barracks Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'Stockpile' then
  list = df.global.world.buildings.other.STOCKPILE
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Stockpile Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 else
  print('Invalid Area Type')
  return
 end
elseif args.construction then
 if tonumber(args.construction) then
  construction = df.construction.find(tonumber(args.construction))
 elseif args.construction == 'WallTop' then
 else
 end 
end

if location then
 dfhack.script_environment('functions/unit').move(unit,location)
else
 print('No valid location')
 return
end
