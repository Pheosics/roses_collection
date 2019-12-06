--building/create.lua
local usage = [====[

building/create
===============
Purpose::
    Create a fully functioning building
    Vanilla buildings are not currently supported (except for the QUERN for testing purposes)

Arguments::
    -location [ x y z ]
    -type Type
        Building type to create
        Valid Types:
            Furnace
            Workshop
    -subtype SUBTYPE
        Building token to create

Examples::
    building/create -location [ \\LOCATION ] -type Workshop -subtype SCREW_PRESS
]====]

local utils = require "utils"
require "dfhack.buildings"
validArgs = utils.invert({
    "help",
    "type",
    "subtype",
    "location",
    "test",
    "force"
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in building/create -"

if args.help then
    print(usage)
    return
end

if not args.location then error(error_str .. "No location to place building declared") end

bldgType = args.type or "Workshop"
if not args.subtype then error(error_str .. "No building subtype declared") end

local mtype = nil
local stype = nil
local ctype = nil
local dimx = nil
local dimy = nil
local stages = nil

for i,bldg in pairs(df.global.world.raws.buildings.all) do
    if bldg.code == args.subtype then
        mtype = bldg.building_type
        stype = bldg.building_subtype
        ctype = i
        dimx = bldg.dim_x
        dimy = bldg.dim_y
        stages = bldg.build_stages
    end
end

if args.test then -- This can make a Quern but that's it
    mtype = df.building_type[args.type]
    stype = tonumber(args.subtype) -- How to get vanilla building subtype?
    ctype = -1
    dimx = 1 -- How to get vanilla building sizes?
    dimy = 1
    stages = 1 -- How to get vanilla building stages?
end

if not mtype then error(error_str .. "Custom building not found") end

local x = tonumber(args.location[1])
local y = tonumber(args.location[2])
local z = tonumber(args.location[3])

local map = dfhack.script_environment("functions/map").MAP()
local free = true
if args.force then
    free = true
else
    -- This works fine for odd dimx and dimy, but checks 1 to many squares for even
    local dx = math.floor(dimx/2)
    local dy = math.floor(dimy/2)
    for xp = x-dx, x+dx do
        for yp = y-dy, y+dy do
            if not map:checkFree(xp,yp,z) then
                free = false
                break
            end
        end
    end
    x = x-dx
    y = y-dy
end

if not free then
    print("Building location not free")
    return
end

filters = dfhack.buildings.getFiltersByType({},mtype,stype,ctype)
if not filters then
    filters = dfhack.buildings.getFiltersByType({},mtype,stype,0)
end

local pos = {}
pos.x = x
pos.y = y
pos.z = z

building = dfhack.buildings.constructBuilding({pos=pos,type=mtype,subtype=stype,custom=ctype,filters=filters})
building.construction_stage = stages
dfhack.job.removeJob(building.jobs[0])