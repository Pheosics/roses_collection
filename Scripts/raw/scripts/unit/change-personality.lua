--unit/change-personality.lua
--@ module=true
local utils = require 'utils'

local usage = [====[

unit/change-personality
=====================
Purpose::
    Change the traits, dreams, values, and emotions of a unit

Uses::
	functions/unit

Arguments::
    -unit #ID
        id of unit to change traits of
    -trait [ <TRAIT_TOKEN> <CHANGE> <TRAIT_TOKEN> <CHANGE> ... ]
        Trait token(s) of the trait(s) to be changed
    -dur #ticks
        Length of time in in=game ticks for the change to last

Examples::
	* Increase units ELOQUENCY trait by 20
		unit/trait-change -unit \\UNIT_ID -trait [ ELOQUENCY +20 ]
]====]

validArgs = utils.invert({
    "help",
    "trait",
	"emotion",
	"value",
	"dream",
    "dur",
    "unit",
	"args",
})

function changeTrait(unit,trait,mode,value,dur)
	local defunit = reqscript("functions/unit").UNIT
	unit = defunit(unit)
	personality = unit:getPersonality()
	if not personality then return end
	change = personality:computeTraitChange(trait,value,mode)
	if change == 0 then return end
	personality:changeTraitValue(trait,change)
	if dur > 1 then
		cmd = "unit/change-personality"
		cmd = cmd .. " -unit " .. tostring(unit.id)
		cmd = cmd .. " -trait [ " .. trait
		if change > 0 then
			cmd = cmd .. " -" .. tostring(value) .. " ]"
		else
			cmd = cmd .. " +" .. tostring(value) .. " ]"
		end
		dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
	end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in unit/change-personality - "

	-- Print Help Message
	if args.help then
		print(usage)
		return
	end

	-- Print valid argument list
	if args.args then
		printall(validArgs)
		return
	end
	
	-- Check for duration value, if negative return
	local dur = tonumber(args.dur) or 0
	if dur < 0 then return end

	-- Check for valid unit
	if args.unit and tonumber(args.unit) then unit = df.unit.find(tonumber(args.unit)) end
	if not unit then error(error_str .. "No valid unit selected") end

	-- Parse arguments
	if args.trait then
		local traits = {}
		for i = 1, #args.trait, 2 do
			trait = args.trait[i]
			v = args.trait[i+1]
			if tonumber(string.sub(v,1,1)) then
				mode = "."
				value = tonumber(v)
			else
				mode = string.sub(v,1,1)
				value = tonumber(string.sub(v,2))
			end
			changeTrait(unit, trait, mode, value, dur)
		end
	end
	
	if args.dream then
		error(error_str.."Dream changing not yet implemented")
	end

	if args.value then
		error(error_str.."Value changing not yet implemented")
	end	
	
	if args.emotion then
		error(error_str.."Emotion changing not yet implemented")
	end
end

if not dfhack_flags.module then
	main(...)
end