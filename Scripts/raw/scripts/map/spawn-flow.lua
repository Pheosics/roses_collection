--map/spawn-flow.lua
--@ module=true
local utils = require "utils"
local flow_types = reqscript("functions/map").flow_types

local usage = [====[

map/spawn-flow
============
Purpose::
	Create a flow at a given position

Uses::
	functions/map
	functions/math

Arguments::
	-unit <UNIT_ID>
		id of unit to use as target
	-pos [ <x> <y> <z> ]
		map position to use as target
	-type FLOWTYPE
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
	-density <#>
		density of spawned flow
	-inorganic <INORGANIC_TOKEN>
		inorganic token to use for flows that have specific inorganic materials
	-static
		if present the spawned flow will not spread to nearby map squares
		and will just slowly decay in place
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
	* Create density 100 INORGANIC:STEEL webs in a circle with a radius of 6 tiles
		map/spawn-flow -unit \\UNIT_ID -type WEB -density 100 -inorganic STEEL -shape CIRCLE -radius [ 6 6 ]
	* Create a density 50 fire flow in a cone, the flow will not spread and will remain in the tiles chosen
		map/spawn-flow -pos [ \\LOCATION ] -type FIRE -density 50 -static -origin \\UNIT_ID -plan CONE_LARGE.txt
]====]

validArgs = utils.invert({
	"help",
	"unit",
	"pos",
	"type",
	"density",
	"radius",
	"number",
	"inorganic",
	"static",
	"offset",
	"plan",
	"shape",
	"origin",
})

local function parseFlowOptions(flowOptions)
	local flowOptions = flowOptions or {}
	local density = tonumber(flowOptions.density) or 100
	local inorganic = 0
	local number = tonumber(flowOptions.number) or 0
	local static = flowOptions.static or false
	if flowOptions.inorganic then inorganic = dfhack.matinfo.find(flowOptions.inorganic).index end
	
	return density, inorganic, number, static
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

function createFlows(flowType,positions,flowOptions)
	local map = reqscript("functions/map").MAP(false)
	if #positions == 0 then return end
    density, inorganic, number, static = parseFlowOptions(flowOptions)
	flowN = flow_types[flowType]

	if number <= 0 then
		for _, pos in pairs(positions) do
			map:createFlow(pos,flowN,density,inorganic,static)
		end
	else
		local n = math.min(number,#positions)
		positions = reqscript("functions/math").permute(positions)
		for i = 1, n do
			map:createFlow(positions[i],flowN,density,inorganic,static)
		end
	end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in map/spawn-flow - "

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
	
	-- Check for required arguments
	if not args.type or not flow_types[args.type:upper()] then 
		error(error_str.."Unknown flow type declared - "..args.type) 
	end
	flowType = args.type:upper()
	
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
	createFlows(flowType,positions,{density=args.density, inorganic=args.inorganic, number=args.number, static=args.static})
end

if not dfhack_flags.module then
	main(...)
end
