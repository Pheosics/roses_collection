--map/flow-plan.lua
local usage = [====[

map/flow-plan
=============
Purpose::
    Spawn flows or liquids based on an external file
 
Function Calls::
    map.getPositions
    map.spawnFlow
    map.spawnLiquid

Arguments::
    -plan           filename.txt
        Name of plan file
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

    FOR BOTH:
        -origin         UNIT_ID or [ x y z ]
            Unit id or location to use as origin (required in some plan files)
        -offset         [ x y z ]
            Offset from target location
        -number         #
            If present will not completely fill the plan and only place the given number of tiles

Examples::
    map/flow-plan -plan 5x5_X.txt -unit \\UNIT_ID -liquid Magma -depth 7
    map/flow-plan -plan 9x5_Cone.txt -location [ \\LOCATION_ID ] -flow Dragonfire -density 100 -static -origin \\UNIT_ID
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
 'number',
 'inorganic',
 'static',
 'liquid',
 'depth',
 'offset',
 'origin',
 'plan',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if not args.plan then
 print('No plan file specified')
 return
end

if args.unit and tonumber(args.unit) then
 target = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 target = args.location
else
 print('No unit or location selected')
 return
end
offset = args.offset or {0,0,0}
number = args.number or 0
depth = args.depth or 7

if args.origin and tonumber(args.origin) then
 origin = df.unit.find(tonumber(args.origin)).pos
elseif args.origin then
 origin = args.origin
end

path = dfhack.getDFPath()..'/raw/files/'..args.plan
positions = dfhack.script_environment('functions/map').getPositions('Plan',{file=path,target=target,origin=origin})

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
  for i,pos in ipairs(positions) do
   dfhack.script_environment('functions/map').spawnFlow(pos,offset,snum,inum,density,args.static)
  end
 else
  local rand = dfhack.random.new()
  for i = 1, number, 1 do
   j = rand:random(#positions)
   dfhack.script_environment('functions/map').spawnFlow(positions[j],offset,snum,inum,density,args.static)
  end
 end
end
if args.liquid then
 magma = false
 if string.lower(args.liquid) == 'magma' then magma = true end
 if number == 0 then
  for i,pos in ipairs(positions) do
   dfhack.script_environment('functions/map').spawnLiquid(pos,offset,depth,magma,nil,nil)
  end
 else
  local rand = dfhack.random.new()
  for i = 1, number, 1 do
   j = rand:random(#positions)
   dfhack.script_environment('functions/map').spawnLiquid(positions[j],offset,depth,magma,nil,nil)
  end
 end
end
