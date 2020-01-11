--map/spawn-flow.lua
local usage = [====[

map/spawn-flow
============
Purpose::
	Create a flow at a given position

Arguments::
	-unit #ID
		id of unit to use as target
	-pos [ x y z ]
		map position to use as target
	-type FLOWTYPE
		Valid Types:
			MIASMA
			STEAM
			MIST
			MATERIALDUST
			MAGMAMIST
			SMOKE
			DRAGONFIRE
			FIRE
			WEB
			MATERIALGAS
			MATERIALVAPOR
			OCEANWAVE
			SEAFOAM
			ITEMCLOUD
	-density #
		density of spawned flow
	-inorganic INORGANIC_TOKEN
		inorganic token to use for flows that have specific inorganic materials
	-static
		if present the spawned flow will not spread to nearby map squares
		and will just slowly decay in place
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
	map/spawn-flow -unit \\UNIT_ID -type WEB -density 100 -inorganic STEEL -shape CIRCLE -radius [ 6 6 ]
	map/spawn-flow -pos [ \\LOCATION ] -type FIRE -density 50 -static -origin \\UNIT_ID -plan CONE_LARGE.txt
]====]

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

local utils = require "utils"
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
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in map/spawn-flow - "

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

if not args.type or not flowtypes[string.upper(args.type)] then 
	error(error_str.."Unknown flow type declared - "..args.type) 
end

local flowN = flowtypes[string.upper(args.type)]
local radius = args.radius or {0,0,0}
local offset = args.offset or {0,0,0}
local number = args.number or 0
local density = args.density or 1
local itype = args.inorganic or 0
local inorganicN = 0
if itype ~= 0 then
	inorganicN = dfhack.matinfo.find(itype).index
end
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
	MAP:createFlow(positions[i],flowN,density,inorganicN,args.static)
end

