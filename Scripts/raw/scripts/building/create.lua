-- TODO Add support for custom building filters
-- TODO Add support for custom building items list
-- TODO Add support for abstract buildings
-- TODO Add duration for created buildings
-- TODO Add option to clear ground area for building

--building/create.lua
--@ module=true
local utils = require "utils"
local hardcoded_bldgs = reqscript("functions/building").hardcoded_bldgs

local usage = [====[

building/create
===============
Purpose::
    Create a fully functioning building

Uses::
	functions/building

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
	* Create a custom building (e.g. a building found in the raws)
		building/create -location [ \\LOCATION ] -type Workshop -subtype SCREW_PRESS
	* Create a hardcoded building
		building/create -location [ \\LOCATION ] -type Furnace -subtype SMELTER
]====]

validArgs = utils.invert({
    "help",
    "type",
    "subtype",
    "location"
})

function createBuilding(pos,type_id,subtype_id,custom_id)
	require "dfhack.buildings"
	building = dfhack.buildings.constructBuilding({pos=pos,type=type_id,subtype=subtype_id,custom=custom_id,filters={{},{}}})
	building.construction_stage = building:getMaxBuildStage()
	dfhack.job.removeJob(building.jobs[0])
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in building/create -"

	if args.help then
		print(usage)
		return
	end

	-- Check for required arguments
	if not args.location then error(error_str .. "No location to place building declared") end
	if not args.type then error(error_str .. "No building type declared") end
	if not args.subtype then error(error_str .. "No building subtype declared") end

	-- Parse arguments
	local pos = {}
	pos.x = tonumber(args.location[1])
	pos.y = tonumber(args.location[2])
	pos.z = tonumber(args.location[3])

	-- Check that the building type is valid
	local type_id = df.building_type[args.type]
	if not type_id then error(error_str .. "Invalid building type - " .. args.type) end
	
	-- Check that the building subtype is valid
	local subtype_id
	local custom_id
	if hardcoded_bldgs[args.type:upper()] then
		-- Check for hardcoded or custom building
		if hardcoded_bldgs[args.type:upper()][args.subtype:upper()] then
			subtype_id = hardcoded_bldgs[args.type:upper()][args.subtype:upper()]
			custom_id = -1
		else
			subtype_id = hardcoded_bldgs[args.type:upper()]["CUSTOM"]
			for i,bldg in pairs(df.global.world.raws.buildings.all) do
				if bldg.code == args.subtype then
					custom_id = i
					break
				end
			end
		end
	else
		subtype_id = -1
		custom_id = -1
	end
	if not subtype_id then error(error_str .. "Invalid subtype " .. args.subtype .. " for type " .. args.type) end
	
	createBuilding(pos,type_id,subtype_id,custom_id)
end

if not dfhack_flags.module then
	main(...)
end