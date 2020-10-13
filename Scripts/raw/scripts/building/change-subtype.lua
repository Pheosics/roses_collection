-- TODO Handle changing from hardcoded subtype to custom subtype

--building/change-subtype.lua
--@ module=true
local utils = require "utils"
local getBuilding = reqscript("functions/building").getBuilding

local usage = [====[

building/change-subtype
=======================
Purpose::
    Change the subtype of a building from one custom building to a different custom building
    Or from one hard coded subtype to another hard coded subtype of the same type
	Does not support changing building type (e.g. going from Workshop -> Furnace or Chair -> Bed)

Uses::
	functions/building

Arguments::
    -building <BUILDING_ID>
        id of building to be changed
    -subtype <SUBTYPE>
        Custom building token or hardcoded building token (e.g. FARMERS)
    -dur #ticks
        Length of time in in-game ticks for the change to last
        Added items will not be removed at end of duration

Examples::
	* Change a custom building to a different custom building subtype for 7200 ticks
		building/change-subtype -building \\BUILDING_ID -subtype NEW_CUSTOM_BUILDING -dur 7200
	* Change a metalsmith forge to a magma forge
		building/change-subtype -building \\BUILDING_ID -subtype MAGMAFORGE
]====]


validArgs = utils.invert({
    "help",
    "building",
    "subtype",
    "dur",
	"args",
})

function changeSubtype(bldg,subtype,dur)
	bldg = getBuilding(bldg)
	local current = bldg.subtype
	check = bldg:changeSubtype(subtype)
	if not check then return end
	if dur > 1 then
		cmd = "building/change-subtype"
		cmd = cmd .. " -building " .. tostring(bldg.id)
		cmd = cmd .. " -subtype " .. current
		dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
	end
end
 
function changeCustomtype(bldg,customtype,dur)
	bldg = getBuilding(bldg)
	local current = bldg.customtype
	check = bldg:changeCustomtype(customtype)
	if not check then return end
	if dur > 1 then
		cmd = "building/change-subtype"
		cmd = cmd .. " -building " .. tostring(bldg.id)
		cmd = cmd .. " -subtype " .. current
		dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
	end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in building/change-subtype -"

	-- Print Help
	if args.help then
		print(usage)
		return
	end
	
	-- Print Valid Args
	if args.args then
		printall(validArgs)
		return
	end
	
	-- Check for non-negative duration
	local dur = tonumber(args.dur) or 0
	if dur < 0 then return end

    -- Check for required tokens
	if not args.subtype then error(error_str .. "No specified subtype chosen") end

    -- Check for valid building
	if args.building and tonumber(args.building) then building = df.building.find(tonumber(args.building)) end
	if not building then error(error_str .. "No valid building specified") end
	
	-- Check if we are changing a custom building or hardcoded building
	if building:getCustomType() < 0 then
		changeSubtype(building,args.subtype,dur)
	else
		changeCustomtype(building,args.subtype,dur)
	end

end

if not dfhack_flags.module then
	main(...)
end