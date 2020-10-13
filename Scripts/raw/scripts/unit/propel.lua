--unit/propel.lua
--@ module=true
local utils = require 'utils'
local getUnit = reqscript("functions/unit").getUnit

local usage = [====[

unit/propel
===========
Purpose::
    Turns a unit into a projectile with a given velocity

Uses::
	functions/unit

Arguments::
    -unit <UNIT_ID>
        ID of the unit to turn into a projectile
    -source <UNIT_ID> or [ <x> <y> <z> ]
        Location to use when using -mode Relative
    -velocity [ <vx> <vy> <vz> ]
        Velocity in x,y,z
    -mode <PROPEL_MODE>
        Method for calculation actual projectile velocity
        Valid Types:
            Fixed
            Random
            Relative

Examples::
	* Propel a unit upwards with a vz of 100
		unit/propel -unit \\UNIT_ID -velocity [ 0 0 100 ] -mode Fixed
	* Propel a unit with a random vx and vy between -50 and 50
		unit/propel -unit \\UNIT_ID -velocity [ 50 50 0 ] -mode Random
	* Propel a unit with vx, vy, and vz magnitude of 10 and sign relative to a source unit
		unit/propel -unit \\UNIT_ID -source \\UNIT_ID -velocity [ 10 10 10 ] -mode Relative
	* Propel a unit with vx, vy, and vz magnitude of 10 and sign relative to a source location
		unit/propel -unit \\UNIT_ID -source [ \\LOCATION ] -velocity [ 10 10 10 ] -mode Relative
]====]

validArgs = utils.invert({
    "help",
    "source",
    "unit",
    "velocity",
    "mode",
	"args"
})

function propel(unit,vx,vy,vz)
	if vx == 0 and vy == 0 and vz == 0 then return end
	unit = getUnit(unit)
	unit:makeProjectile({resultx,resulty,resultz})
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in unit/action-change - "

	-- Print help message
	if args.help then
		print(usage)
		return
	end
	
	-- Print valid argument list
	if args.args then
		printall(validArgs)
		return
	end

	-- Check for valid unit
	if args.unit and tonumber(args.unit) then unit = df.unit.find(tonumber(args.unit)) end
	if not unit then error(error_str .. "No valid unit selected") end

	-- Check for source unit or location
	if args.source then
		if tonumber(args.source) then
			source = df.unit.find(tonumber(args.source)).pos
		else
			source = {}
			source.x = tonumber(args.source[1])
			source.y = tonumber(args.source[2])
			source.z = tonumber(args.source[3])
		end
	end
	
	-- Parse args
	strength = args.velocity or {0,0,0}
	local vx = strength[1]
	local vy = strength[2]
	local vz = strength[3]

	propelType = args.mode or "FIXED"
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
			error(error_str.."Relative velocity selected, but no source declared")
		end
		resultx = math.floor(totvel*dx+0.5)
		resulty = math.floor(totvel*dy+0.5)
		resultz = math.floor(totvel*dz+0.5)
	else
		error(error_str .. "Invalid velocity mode selected")
	end
	
	propel(unit,resultx,resulty,resultz)
end

if not dfhack_flags.module then
	main(...)
end