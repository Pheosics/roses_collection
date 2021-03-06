--unit/propel.lua
local usage = [====[

unit/propel
===========
Purpose::
    Turns a unit into a projectile with a given velocity

Function Calls::
    unit.makeProjectile

Arguments::
    -unitTarget    UNIT_ID
        ID of the unit to turn into a projectile
    -unitSource    UNIT_ID
        ID of the unit to use for positioning when using -mode Relative
    -velocity      [ x y z ]
        Velocity in x,y,z
    -mode          Propel Type
        Method for calculation actual projectile velocity
        Valid Types:
            Fixed
            Random
            Relative

Examples::
    unit/propel -unitSource \\UNIT_ID -velocity [ 0 0 100 ] -mode Fixed
    unit/propel -unitSource \\UNIT_ID -velocity [ 50 50 0 ] -mode Random
    unit/propel -unitSource \\UNIT_ID -unitTarget \\UNIT_ID -velocity [ 10 10 10 ] -mode Relative
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'unitSource',
 'unitTarget',
 'velocity',
 'mode',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.mode == 'Fixed' or args.mode == 'fixed' then
 propelType = 'fixed'
elseif args.mode == 'Random' or args.mode == 'random' then
 propelType = 'random'
elseif args.mode == 'Relative' or args.mode == 'relative' then
 propelType = 'relative'
else
 propelType = 'fixed'
end

if args.unitTarget and tonumber(args.unitTarget) then
 unit = df.unit.find(tonumber(args.unitTarget))
else
 print('No target specified')
 return
end
if args.unitSource and tonumber(args.unitSource) then
 unitSource = df.unit.find(tonumber(args.unitSource))
else
 unitSource = nil
end

strength = args.velocity or {0,0,0}
local vx = strength[1]
local vy = strength[2]
local vz = strength[3]

if propelType == 'random' then
 local rando = dfhack.random.new()
 rollx = rando:unitrandom()*vx
 rolly = rando:unitrandom()*vy
 rollz = rando:unitrandom()*vz
 resultx = math.floor(rollx)
 resulty = math.floor(rolly)
 resultz = math.floor(rollz)
elseif propelType == 'fixed' then
 resultx = vx
 resulty = vy
 resultz = vz
elseif propelType == 'relative' then
 if unitSource then
 difx = unit.pos.x - unitSource.pos.x
 dify = unit.pos.y - unitSource.pos.y
 difz = unit.pos.z - unitSource.pos.z
 totvel = math.sqrt(vx*vx+vy*vy+vz*vz)
 totdis = math.sqrt(difx*difx+dify*dify+difz*difz)
 dx = difx/totdis
 dy = dify/totdis
 dz = difz/totdis
 if difx == 0 and dify == 0 and difz == 0 then
  dx = (rando:random(3) - 1)/math.sqrt(3)
  dy = (rando:random(3) - 1)/math.sqrt(3)
  dz = (rando:random(3) - 1)/math.sqrt(3)
 end
 else
  print('Relative velocity selected, but no source declared')
  return
 end
 resultx = math.floor(totvel*dx+0.5)
 resulty = math.floor(totvel*dy+0.5)
 resultz = math.floor(totvel*dz+0.5)
else
 print('Not a valid type')
 return
end

dfhack.script_environment('functions/unit').makeProjectile(unit,{resultx,resulty,resultz})
