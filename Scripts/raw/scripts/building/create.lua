--building/create.lua
local usage = [====[

building/create
===============
Purpose::
    Create a fully functioning building
    Vanilla buildings are not currently supported

Function Calls::
    map.checkFree
    building.addItem
    item.create

Arguments::
    -location      [ x y z ]
    -type          Building Type
        Building type to create
        Valid Types:
            Furnace
            Workshop
    -subtype       BUILDING_TOKEN
        Building token to create
    -item          ITEM_ID or ITEM_TYPE:ITEM_SUBTYPE
        id(s) of item(s) to be added to created building or item(s) to be created
    -material      MATERIAL_TYPE:MATERIAL_SUBTYPE
        If creating item(s) provides material for the item

Examples::
    building/create -location [ \\LOCATION ] -type Workshop -subtype SCREW_PRESS
]====]

local utils = require 'utils'
require 'dfhack.buildings'
validArgs = utils.invert({
 'help',
 'type',
 'subtype',
 'location',
 'item',
 'material',
 'test'
})

local args = utils.processArgs({...}, validArgs)

local mtype = nil
local stype = nil
local ctype = nil
local dimx = nil
local dimy = nil
local stages = nil

if args.help then
 print(usage)
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

if args.test then -- This can make a Quern but that's it
 mtype = df.building_type[args.type]
 stype = tonumber(args.subtype) -- How to get vanilla building subtype
 ctype = -1
 dimx = 1 -- How to get vanilla building sizes
 dimy = 1
 stages = 1 -- How to get vanilla building stages
end

if not mtype then
 print('Custom building not found')
 return
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
dfhack.job.removeJob(building.jobs[0])

if args.item then
 if type(args.item) ~= 'table' then args.item = {args.item} end
 if args.material then
  if type(args.material) ~= 'table' then args.material = {args.material} end
 end
 for i,x in pairs(args.item) do
  if tonumber(x) then
   id = tonumber(x)
   dfhack.script_environment('functions/building').addItem(building,id)
  elseif args.material[i] then
   item = dfhack.script_environment('functions/item').create(x,args.material[i])
   dfhack.script_environment('functions/building').addItem(building,item)
  end
 end
end
