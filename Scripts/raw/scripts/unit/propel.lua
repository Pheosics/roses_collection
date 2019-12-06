--unit/propel.lua
local usage = [====[

unit/propel
===========
Purpose::
    Turns a unit into a projectile with a given velocity

Arguments::
    -unit #ID
        ID of the unit to turn into a projectile
    -source #ID or [ x y z ]
        Location to use when using -mode Relative
    -velocity [ vx vy vz ]
        Velocity in x,y,z
    -mode PropelMode
        Method for calculation actual projectile velocity
        Valid Types:
            Fixed
            Random
            Relative

Examples::
    unit/propel -unit \\UNIT_ID -velocity [ 0 0 100 ] -mode Fixed
    unit/propel -unit \\UNIT_ID -velocity [ 50 50 0 ] -mode Random
    unit/propel -unit \\UNIT_ID -source \\UNIT_ID -velocity [ 10 10 10 ] -mode Relative
    unit/propel -unit \\UNIT_ID -source [ \\LOCATION ] -velocity [ 10 10 10 ] -mode Relative
]====]

local utils = require "utils"
validArgs = utils.invert({
    "help",
    "source",
    "unit",
    "velocity",
    "mode",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in unit/propel - "

if args.help then
    print(usage)
    return
end

propelType = args.mode or "FIXED"

if args.unit and tonumber(args.unit) then unit = dfhack.script_environment("functions/unit").UNIT(args.unit) end
if not unit then error(error_str .. "No valid unit selected") end

if args.source then
    if tonumber(args.source) then
        sourceUnit = dfhack.script_environment("functions/unit").UNIT(args.source)
        source = sourceUnit:getPosition()
    else
        source = {}
        source.x = tonumber(args.source[1])
        source.y = tonumber(args.source[2])
        source.z = tonumber(args.source[3])
    end
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

if propelType:upper() == "RANDOM" then
    local rando = dfhack.random.new()
    rollx = rando:unitrandom()*vx
    rolly = rando:unitrandom()*vy
    rollz = rando:unitrandom()*vz
    resultx = math.floor(rollx)
    resulty = math.floor(rolly)
    resultz = math.floor(rollz)
elseif propelType:upper() == "FIXED" then
    resultx = vx
    resulty = vy
    resultz = vz
elseif propelType:upper() == "RELATIVE" then
    pos = unit:getPosition()
    if source then
        difx = pos.x - source.x
        dify = pos.y - source.y
        difz = pos.z - source.z
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
        print("Relative velocity selected, but no source declared")
        return
    end
    resultx = math.floor(totvel*dx+0.5)
    resulty = math.floor(totvel*dy+0.5)
    resultz = math.floor(totvel*dz+0.5)
else
    error(error_str .. "Invalid velocity mode selected")
    return
end

unit:makeProjectile({resultx,resulty,resultz})
