--map/spawn-liquid.lua
local usage = [====[

map/spawn-liquid
============
Purpose::
	Create water or magma at a given position
	
Arguments::
	-unit #ID
		id of unit to use as target
	-pos [ x y z ]
		map position to use as target
	-magma
		if present will spawn magma instead of water
	-depth #
		depth of spawned liquid
	-offset [ x y z ]
		positional offset from -unit or -pos
	-plan filename
		plan file name to use for determining positions
	-shape SHAPE
		shape to use for determining positions
		Valid Shapes:
			SQUARE
			CIRCLE
	-origin #ID or [ x y z ]
		position to use as the origin for -plan
	-radius x or [ x y ] or [ x y z ]
		determines the size of the -shape
	-number #
		if present will choose positions randomly
		
Examples::
	map/spawn-liquid -unit \\UNIT_ID -depth 7 -shape CIRCLE -radius [ 6 6 ]
	map/spawn-liquid -pos [ \\LOCATION ] -magma -depth 2 -origin \\UNIT_ID -plan CONE_LARGE.txt
]====]

local utils = require "utils"
validArgs = utils.invert({
	"help",
	"unit",
	"pos",
	"radius",
	"number",
	"offset",
	"plan",
	"shape",
	"origin",
	"magma",
	"depth",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in map/spawn-liquid - "

if args.help then
	print(usage)
	return
end

local pos = {}
if args.unit and tonumber(args.unit) then
	pos = df.unit.find(tonumber(args.unit)).pos
elseif args.pos then
	pos.x = args.pos[1]
	pos.y = args.pos[2]
	pos.z = args.pos[3]
else
	error(error_str.."No unit or location selected")
	return
end

local radius = args.radius or {0,0,0}
local offset = args.offset or {0,0,0}
local number = args.number or 0
local depth = args.depth or 1
local target = {x=pos.x+offset[1], y=pos.y+offset[2], z=pos.z+offset[3]}

local positions = {}
MAP = dfhack.script_environment("functions/map").MAP(false)
if args.plan then
	positions = MAP:getPlanPositions(target,args.plan,args.origin)
elseif args.shape then
	positions = MAP:getFillPositions(target,radius,args.shape)
else
	positions = MAP:getFillPositions(target,radius)
end
if #positions == 0 then return end
if number == 0 then number = #positions end
local n = math.min(number,#positions)
positions = dfhack.script_environment("functions/math").permute(positions)

for i = 1, n do
	MAP:createLiquid(positions[i],depth,args.magma)
end

