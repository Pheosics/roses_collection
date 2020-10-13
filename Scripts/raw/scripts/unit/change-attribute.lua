--unit/change-attribute.lua
--@ module=true
local utils = require 'utils'
local getUnit = reqscript("functions/unit").getUnit

local usage = [====[

unit/change-attribute
=====================
Purpose::
    Change the attriubute(s) of a unit

Uses::
	functions/unit

Arguments::
    -unit <UNIT_ID>
        id of unit to change attributes of
    -attribute [ <ATTRIBUTE_TOKEN> <CHANGE> <ATTRIBUTE_TOKEN> <CHANGE> ]
        Attribute token(s) of the attribute(s) to be changed
    -dur <#ticks>
        Length of time in in-game ticks for the change to last

Examples::
	* Add 100 to the units strength base value
		unit/change-attribute -unit \\UNIT_ID -attribute [ STRENGTH +100 ]
	* Change toughness and endurance to 10% and willpower to 50% of base value for 3600 ticks
		unit/change-attribute -unit \\UNIT_ID -attribute [ ENDURANCE /10 TOUGHNESS /10 WILLPOWER /2 ] -dur 3600
	* Set units willpower to 5000 for 1000 ticks
		unit/change-attribute -unit \\UNIT_ID -attribute [ WILLPOWER 5000 ] -dur 1000
]====]


validArgs = utils.invert({
    "help",
    "attribute",
    "mode",
    "amount",
    "dur",
    "unit",
	"args",
})

function changeAttribute(unit,attribute,mode,value,dur)
	unit = getUnit(unit)
	attribute = unit.Attributes[attribute]
	if not attribute then return end
	change = attribute:computeChange(value,mode)
	if change == 0 then return end
	attribute:changeValue(change, dur)
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in unit/change-attribute - "

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
	local attributes = {}
	for i = 1, #args.attribute, 2 do
		attributes[args.attribute[i]] = args.attribute[i+1]
	end

	-- Apply changes
	for attribute, v in pairs(attributes) do
		if tonumber(string.sub(v,1,1)) then
			mode = "."
			value = tonumber(v)
		else
			mode = string.sub(v,1,1)
			value = tonumber(string.sub(v,2))
		end
		changeAttribute(unit, attribute, mode, value, dur)
    end
end

if not dfhack_flags.module then
	main(...)
end