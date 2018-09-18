--map/flow-pos.lua
local usage = [====[

map/flow-pos
============
Purpose::
    Spawns flows/liquids in a radius around given position
    Can fill radius or spawn randomly in radius
 
Function Calls::
    map.getPositions
    map.getPosition
    map.spawnFlow
    map.spawnLiquid

Arguments::
    -unit           UNIT_ID
        id of unit to use as target in plan
    -location       [ x y z ]
        Location to use as target in plan

    FOR FLOWS:
        -flow           Flow Type
            Type of flow to create
            Valid Types:
                Miasma
                Steam
                Mist
                MaterialDust
                MagmaMist
                Smoke
                Dragonfire
                Fire
                Web
                MaterialGas
                MaterialVapor
                OceanWave
                SeaFoam
                ItemCloud
        -inorganic      INORGANIC_TOKEN
            Inorganic to create flow from (only works for some flow types)
        -density        #
            Density of flow to create
        -static
            If present flow will not spread

    FOR LIQUIDS:
        -liquid         Liquid Type
            Type of liquid to create
            Valid Types:
                Water
                Magma
        -depth          #
            Depth of liquid to spawn
        -circle
            If present will translate -radius into a circle instead of a square
        -taper
            If present will set the center to -depth and the edge of radius to 1

    FOR BOTH:
        -radius         [ x y z ]
            Distance from target in x y z to create flows/liquids in
        -offset         [ x y z ]
            Offset from target location
        -number         #
            Number of flows/liquids to place within -radius
            If not included or 0 fills entire -radius

Examples::
    map/flow-pos -unit \\UNIT_ID -radius [ 5 5 0 ] -flow MagmaMist -density 100 -liquid Magma -depth 7 -circle -taper
    map/flow-pos -location [ \\LOCATION ] -flow Web -inorganic STEEL -density 500 -radius [ 10 10 5 ] -number 15
]====]

flowtypes = {
            MIASMA = 0,
            STEAM = 1,
            MIST = 2,
            MATERIALDUST = 3,
            MAGMAMIST = 4,
            SMOKE = 5,
            DRAGONFIRE = 6,
            FIRE = 7,
            WEB = 8,
            MATERIALGAS = 9,
            MATERIALVAPOR = 10,
            OCEANWAVE = 11,
            SEAFOAM = 12,
            ITEMCLOUD = 13
            }

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'unit',
 'location',
 'liquid',
 'flow',
 'density',
 'radius',
 'number',
 'inorganic',
 'static',
 'liquid',
 'depth',
 'circle',
 'taper',
 'offset'
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

pos = {}
if args.unit and tonumber(args.unit) then
 pos = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 pos.x = args.location[1]
 pos.y = args.location[2]
 pos.z = args.location[3]
else
 print('No unit or location selected')
 return
end

radius = args.radius or {0,0,0}
offset = args.offset or {0,0,0}
number = args.number or 0
number = tonumber(number)
depth = args.depth or 0
depth = tonumber(depth)
location = {}
location.x = pos.x + offset[1]
location.y = pos.y + offset[2]
location.z = pos.z + offset[3]

if args.flow then
 stype = args.flow
 density = tonumber(args.density) or 1
 itype = args.inorganic or 0
 local snum = flowtypes[string.upper(stype)]
 local inum = 0
 if itype ~= 0 then
  inum = dfhack.matinfo.find(itype).index
 end
 if number == 0 then
  edges, n = dfhack.script_environment('functions/map').getPositions('Edges',{target=location,radius=radius})
  dfhack.script_environment('functions/map').spawnFlow(edges,{0,0,0},snum,inum,density,args.static)
 else
  for i = 1, number, 1 do
   pos = dfhack.script_environment('functions/map').getPosition('Location',{target=location,radius=radius})
   dfhack.script_environment('functions/map').spawnFlow(pos,{0,0,0},snum,inum,density,args.static)
  end
 end
end

if args.liquid then
 if args.liquid == magma then magma = true end
 if number == 0 then
  edges, n = dfhack.script_environment('functions/map').getPositions('Edges',{target=location,radius=radius})
  dfhack.script_environment('functions/map').spawnLiquid(edges,{0,0,0},depth,magma,args.circle,args.taper)
 else
  for i = 1, number, 1 do
   pos = dfhack.script_environment('functions/map').getPosition('Location',{target=location,radius=radius})
   dfhack.script_environment('functions/map').spawnLiquid(pos,{0,0,0},depth,magma,nil,nil)
  end
 end
end
