--building/subtype-change.lua
local usage = [====[

building/subtype-change
=======================
Purpose::
    Change the subtype of a building from one custom building to a different custom building
    Currently does not support changing vanilla buildings

Arguments::
    -building #ID
        id of building to be changed
    -subtype SUBTYPE
        Building token (only custom buildings currently supported)
    -item #ID or [ #ID #ID #ID ... ]
        id(s) of item(s) to be added to the buildings build materials
    -dur #ticks
        Length of time in in-game ticks for the change to last
        Added items will not be removed at end of duration

Examples::
    building/subtype-change -building \\BUILDING_ID -subtype NEW_CUSTOM_BUILDING -dur 7200
    building/subtype-change -building \\BUILDING_ID -subtype CUSTOM_BUILDING -item \\ITEM_ID    
]====]

local utils = require "utils"
validArgs = utils.invert({
    "help",
    "building",
    "item",
    "subtype",
    "dur",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in building/subtype-change -"

if args.help then
    print(usage)
    return
end
local dur = tonumber(args.dur) or 0
if dur < 0 then return end

if not args.subtype then error(error_str .. "No specified subtype chosen") end
if type(args.item) == "string" then args.item = {args.item} end

if args.building and tonumber(args.building) then building = dfhack.script_environment("functions/building").BUILDING(args.building)
if not building then error(error_str .. "No valid building specified") end

if building.customtype < 0 then print("Changing vanilla buildings not currently supported") return end

currentSubtype = building.customtype
check = building:changeSubtype(args.subtype)
if check then
    if args.item then
        for _,item in ipairs(args.item) do
            building:addItem(item)
        end
    end
    if dur > 0 then
        cmd = "building/subtype-change"
        cmd = cmd .. " -building " .. tostring(building.id)
        cmd = cmd .. " -subtype " .. currentSubtype
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
    end
end