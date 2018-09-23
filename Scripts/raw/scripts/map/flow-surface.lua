--map/flow-surface.lua
local usage = [====[

map/flow-surface
================
Purpose::
    Create "weather-like" effect of flow/liquid spawning on surface
    Frequency and total duration can be specified

Function Calls::
    map.getPositions
    map.getPosition
    map.spawnFlow
    map.spawnLiquid

Arguments::
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
        -radius         [ x y z ]
            Size of liquid spawned
        -circle
            If present will translate -radius into a circle instead of a square
        -taper
            If present will set the center to -depth and the edge of radius to 1

    FOR BOTH:
        -dur            #
            How long the spawnings continue for
        -frequency      #
            How often flows/liquids are spawned
        -number         #
            Number of flows/liquids spawned at each frequency

Examples::
    map/flow-surface -flow DRAGONFIRE -density 25 -frequency 200 -number 50 -dur 7200
    map/flow-surface -flow WEB -inorganic GOLD -density 50 -frequency 500 -number 100 -dur 1000
    map/flow-surface -liquid magma -depth 1 -radius [ 1 1 0 ] -circle -number 50 -frequency 500 -dur 5000
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
 'flow',
 'dur',
 'density',
 'frequency',
 'number',
 'inorganic',
 'liquid',
 'static',
 'circle',
 'radius',
 'depth',
 'taper',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

frequency = tonumber(args.frequency) or 100
number = tonumber(args.number) or 1
duration = tonumber(args.dur) or 1
 
if args.flow then
 local stype = args.flow
 local density = tonumber(args.density) or 1
 local itype = args.inorganic or 0
 local snum = flowtypes[string.upper(stype)]
 local inum = 0
 if itype ~= 0 then
  inum = dfhack.matinfo.find(itype).index
 end
 for i = 1, number, 1 do
  pos = dfhack.script_environment('functions/map').getPosition('Random')
  pos = dfhack.script_environment('functions/map').getPosition('Surface',{location=pos})
  flow = dfhack.maps.spawnFlow(pos,snum,0,inum,density)
  if args.static then flow.expanding = false end
 end
 if duration-frequency > 0 then
  script = 'map/flow-surface -flow '..stype..' -number '..tostring(number)..' -frequency '..tostring(frequency)..' -density '..tostring(density)
  script = script..' -dur '..tostring(duration-frequency)
  if itype ~= 0 then script = script..' -inorganic '..itype end
  if args.static then script = script..' -static' end
  dfhack.script_environment('persist-delay').commandDelay(frequency,script)
 end
end

if args.liquid then
 radius = args.radius or {0,0,0}
 depth = tonumber(args.depth) or 7
 offset = {0,0,0}
 if args.liquid == magma then magma = true end
 for i = 1, number, 1 do
  pos = dfhack.script_environment('functions/map').getPosition('Random')
  pos = dfhack.script_environment('functions/map').getPosition('Surface',{location=pos})
  edges, n = dfhack.script_environment('functions/map').getPositions('Edges',{target=pos,radius=radius})
  dfhack.script_environment('functions/map').spawnLiquid(edges,offset,depth,magma,args.circle,args.taper)
 end
 if duration-frequency > 0 then
  script = 'map/flow-surface -liquid '..args.liquid..' -number '..tostring(number)..' -frequency '..tostring(frequency)..' -depth '..tostring(depth)..' -radius [ '..table.unpack(radius)..' ]'
  script = script..' -dur '..tostring(duration-frequency)
  if args.circle then script = script.. ' -circle' end
  if args.taper then script = script..' -taper' end
  dfhack.script_environment('persist-delay').commandDelay(frequency,script)
 end
end
