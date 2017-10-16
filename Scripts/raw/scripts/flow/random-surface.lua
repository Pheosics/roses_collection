--flow/random-surface.lua v1.0 | DFHack 43.05

local utils = require 'utils'

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

validArgs = validArgs or utils.invert({
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

if args.help then -- Help declaration
 print([[flow/random-surface.lua
  Create a number of flows/liquids spawned randomly on the surface every frequency for a set duration
  arguments:
   -help
     print this help message
  FOR FLOWS:
   -flow TYPE
     specify the flow type
     valid types:
      miasma
      mist
      mist2
      dust
      lavamist
      smoke
      dragonfire
      firebreath
      web
      undirectedgas
      undirectedvapor
      oceanwave
      seafoam
   -inorganic INORGANIC_TOKEN
     specify the material of the flow, if applicable
     examples:
      IRON
      RUBY
      etc...
   -density #
     specify how dense each flow is
     DEFAULT 1
   -static
     sets the flow as static so that it doesn't expand
  FOR LIQUIDS:
   -liquid TYPE
     specify the liquid type
	 valid types:
	  water
	  magma
   -depth #
     specify the depth of the liquid spawned
	 DEFAULT 7
   -radius [ # # # ]
     sets the size of the liquid spawned in x y z coordinates
	 DEFAULT [ 0 0 0 ]
   -circle
     specify whether to spawn as a circle
   -taper
     specify whether to decrease depth as you move away from the center of the spawned liquid
  FOR BOTH:
   -dur #
     specify how long the 'weather' effect lasts in in-game ticks
     DEFAULT 1
   -frequency #
     specify how often the flows are spawned
     DEFAULT 100
   -number #
     specify the number of flows that are spawned at each frequency
     DEFAULT 1
  examples:
   flow/random-surface -flow firebreath -density 25 -frequency 200 -number 50 -dur 7200
   flow/random-surface -flow web -inorganic GOLD -density 50 -frequency 500 -number 100 -dur 1000
   flow/random-surface -liquid magma -depth 1 -radius [ 1 1 0 ] -circle -number 50 -frequency 500 -dur 5000
 ]])
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
  pos = dfhack.script_environment('functions/map').getPositionRandom()
  pos = dfhack.script_environment('functions/map').getPositionSurface(pos)
  flow = dfhack.maps.spawnFlow(pos,snum,0,inum,density)
  if args.static then flow.expanding = false end
 end
 if duration-frequency > 0 then
  script = 'flow/random-surface -flow '..stype..' -number '..tostring(number)..' -frequency '..tostring(frequency)..' -density '..tostring(density)
  script = script..' -dur '..tostring(duration-frequency)
  if itype ~= 0 then script = script..' -inorganic '..itype end
  dfhack.script_environment('persist-delay').commandDelay(frequency,script)
 end
elseif args.liquid then
 radius = args.radius or {0,0,0}
 depth = tonumber(args.depth) or 7
 offset = {0,0,0}
 if args.liquid == magma then magma = true end
 for i = 1, number, 1 do
  pos = dfhack.script_environment('functions/map').getPositionRandom()
  pos = dfhack.script_environment('functions/map').getPositionSurface(pos)
  edges = dfhack.script_environment('functions/map').getEdgesPosition(pos,radius)
  dfhack.script_environment('functions/map').spawnLiquid(edges,offset,depth,magma,args.circle,args.taper)
 end
 if duration-frequency > 0 then
  script = 'flow/random-surface -liquid '..args.liquid..' -number '..tostring(number)..' -frequency '..tostring(frequency)..' -depth '..tostring(depth)..' -radius [ '..table.unpack(radius)..' ]'
  script = script..' -dur '..tostring(duration-frequency)
  if args.circle then script = script.. ' -circle' end
  if args.taper then script = script..' -taper' end
  dfhack.script_environment('persist-delay').commandDelay(frequency,script)
 end
else
 print('Neither a flow or liquid specified, aborting.')
end
