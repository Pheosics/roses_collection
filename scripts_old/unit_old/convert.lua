--unit/convert.lua
local usage = [====[

unit/convert
============
Purpose::
	Changes various ids and flags of a unit

Function Calls::
	unit.changeSide

Arguments::
	-unit		UNIT_ID
		Unit id of target unit
	-side		UNIT_ID
		Unit id of reference unit
	-type		Side Type
		Changes are based off of the -side unit and -type of change
		Valid Values:
			Civilian
			Ally
			Friend
			Neutral
			Enemy
			Invader
			Pet
	-dur		#
		Length of time in in-game ticks for the change to last
	-syndrome	SYN_NAME
		If present attaches a syndrome to the change for tracking purposes

Examples::
	unit/convert -unit \\UNIT_ID -side \\UNIT_ID -type Pet -dur 1000
	unit/convert -unit \\UNIT_ID -side \\UNIT_ID -type Civilian
]====]

local utils = require 'utils'

validArgs = utils.invert({
 'help',
 'unit',
 'side',
 'type',
 'dur',
 'syndrome',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print(usage)
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

if args.side and tonumber(args.side) then
 side = df.unit.find(tonumber(args.side))
else
 print('No side selected')
 return
end

side_type = args.type or 'Neutral'
dur = tonumber(args.dur) or 0
if dur < 0 then return end

dfhack.script_environment('functions/unit').changeSide(unit,side,side_type,dur,'track',args.syndrome)
