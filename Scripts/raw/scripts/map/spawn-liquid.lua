--map/spawn-liquid.lua
--@ module=true
local utils = require "utils"

local usage = [====[

map/spawn-liquid
============
Purpose::
	Create water or magma at a given position

Uses::
	functions/map
	functions/math

Arguments::
	-unit <UNIT_ID>
		id of unit to use as target
	-pos [ <x> <y> <z> ]
		map position to use as target
	-magma
		if present will spawn magma instead of water
	-depth <#>
		depth of spawned liquid
	-offset [ <x> <y> <z> ]
		positional offset from -unit or -pos
	-plan <filename>
		plan file name to use for determining positions
	-shape <SHAPE>
		shape to use for determining positions
		Valid Shapes:
			SQUARE
			CIRCLE
	-origin <UNIT_ID> or [ <x> <y> <z> ]
		position to use as the origin for -plan
	-radius <x> or [ <x> <y> ] or [ <x> <y> <z> ]
		determines the size of the -shape
	-number <#>
		if present will choose positions randomly
		
Examples::
	* Create a radius 6 circle of depth 7 water
		map/spawn-liquid -unit \\UNIT_ID -depth 7 -shape CIRCLE -radius [ 6 6 ]
	* Create a cone of depth 2 magma based on an external file
		map/spawn-liquid -pos [ \\LOCATION ] -magma -depth 2 -origin \\UNIT_ID -plan CONE_LARGE.txt
]====]

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

local function parseLiquidOptions(liquidOptions)
	local liquidOptions = liquidOptions or {}
	local depth = tonumber(liquidOptions.depth) or 7
	local number = tonumber(liquidOptions.number) or 0
	local magma = liquidOptions.magma or false
	
	return density, magma, number
end

local function getPositions(posFields,posType)
	local map = reqscript("functions/map").MAP(false)
	local positions = {}
	if not posType then
		positions = map:getFillPositions(posFields.pos,posFields.radius)
	elseif posType:upper() == "SHAPE" then
		positions = map:getFillPositions(posFields.pos,posFields.radius,posFields.shape)
	elseif posType:upper() == "PLAN" then
		positions = map:getPlanPositions(posFields.pos,posFields.plan,posFields.origin)
	elseif posType:upper() == "FILL" then
		positions = map:getFillPositions(posFields.pos,posFields.radius)
	end
	return positions
end

function createLiquids(positions,liquidOptions)
	local map = reqscript("functions/map").MAP(false)
	if #positions == 0 then return end
    depth, magma, number = parseLiquidOptions(liquidOptions)

	if number <= 0 then
		for _, pos in pairs(positions) do
			map:createLiquid(pos,depth,magma)
		end
	else
		local n = math.min(number,#positions)
		positions = dfhack.script_environment("functions/math").permute(positions)
		for i = 1, n do
			map:createLiquid(positions[i],depth,magma)
		end
	end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in map/spawn-liquid - "

	if args.help then
		print(usage)
		return
	end
	
	-- Check for a valid position
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
	
	-- Process arguments
	local radius = args.radius or {0,0,0}
	local offset = args.offset or {0,0,0}
	local target = {x=pos.x+offset[1], y=pos.y+offset[2], z=pos.z+offset[3]}
	
	if args.plan then
		positions = getPositions({pos=target, plan=args.plan, origin=args.origin}, "PLAN")
	elseif args.shape then
		positions = getPositions({pos=target, shape=args.shape, radius=radius}, "SHAPE")
	else
		positions = getPositions({pos=target, radius=radius}, "FILL"))
	end
	createLiquids(positions,{depth=args.depth, magma=args.magma, number=args.number})
end

if not dfhack_flags.module then
	main(...)
end



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

