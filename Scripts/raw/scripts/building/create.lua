--building/create.lua v0.1 | DFHack 43.05
local utils = require 'utils'
require 'dfhack.buildings'

validArgs = validArgs or utils.invert({
 'help',
 'type',
 'subtype',
 'custom',
 'location',
 'item',
 'material',
 'clear',
})

local args = utils.processArgs({...}, validArgs)

local mtype = nil
local stype = nil
local ctype = nil
local dimx = nil
local dimy = nil
local stages = nil

if args.help then
print(
[[building/subtype-change.lua
 arguments:
  -help
   print this help message
]])
return
end

if not args.location then
 print('No location to place building declared')
 return
end

bldgType = args.type or 'Workshop'
if not args.subtype then
 print('No building subtype declared')
 return
end

if args.custom then
 for i,bldg in pairs(df.global.world.raws.buildings.all) do
  if bldg.code == args.subtype then
   mtype = bldg.building_type
   stype = bldg.building_subtype
   ctype = i
   dimx = bldg.dim_x
   dimy = bldg.dim_y
   stages = bldg.build_stages
  end
 end

 if not mtype then
  print('Custom building not found')
  return
 end

else
 mtype = df.building_type[args.type]
 stype = tonumber(args.subtype) -- How to get vanilla building subtype
 ctype = -1
 dimx = 1 -- How to get vanilla building sizes
 dimy = 1
 stages = 1 -- How to get vanilla building stages
end

local x = args.location[1]
local y = args.location[2]
local z = args.location[3]

check = dfhack.script_environment('functions/map').checkFree
-- Check quadrant 4
local free = true
local quad = 4
for xp = x, x+dimx-1 do
 for yp = y, y+dimy-1 do
  if not check(xp,yp,z) then
   free = false
  end
 end
end
-- Check quadrant 1
if not free then
 free = true
 quad = 1
 for xp = x, x+dimx-1 do
  for yp = y-dimy-1, y do
   if not check(xp,yp,z) then
    free = false
   end
  end
 end
end
-- Check quadrant 3
if not free then
 free = true
 quad = 3
 for xp = x-dimx-1, x do
  for yp = y, y+dimy-1 do
   if not check(xp,yp,z) then
    free = false
   end
  end
 end
end
-- Check quadrant 2
if not free then
 free = true
 quad = 2
 for xp = x-dimx-1, x do
  for yp = y-dimy-1, y do
   if not check(xp,yp,z) then
    free = false
   end
  end
 end
end

if not free then
 print('Building location not free')
 return
end

if quad == 1 then
 x = x
 y = y - dimy - 1
elseif quad == 2 then
 x = x - dimx - 1
 y = y - dimy - 1
elseif quad == 3 then
 x = x - dimx - 1
 y = y
end

local pos = {}
pos.x = x
pos.y = y
pos.z = z

filters = dfhack.buildings.getFiltersByType({},mtype,stype,ctype)
building = dfhack.buildings.constructBuilding({pos=pos,type=mtype,subtype=stype,custom=ctype,filters=filters})
building.construction_stage = stages
building.jobs:erase(0)

if args.item then
 if type(args.item) ~= 'table' then args.item = {args.item} end
 if args.material then
  if type(args.material) ~= 'table' then args.material = {args.material} end
 end
 for i,x in pairs(args.item) do
  if tonumber(x) then
   id = tonumber(x)
   dfhack.script_environment('functions/building').addItem(building,item)
  elseif args.material[i] then
   item = dfhack.script_environment('functions/item').create(x,args.material[i])
   dfhack.script_environment('functions/building').addItem(building,item)
  end
 end
end
