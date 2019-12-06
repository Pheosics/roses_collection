--item/create.lua
local usage = [====[

item/create
===========
Purpose::
    Creates an item and it"s cooresponding item table for tracking

Arguments::
    -creator #ID
        id of creator unit, set to 0 if not present
    -item ITEM_TYPE:ITEM_SUBTYPE
        Item to be created
    -material MATERIAL_TYPE:MATERIAL_SUBTYPE
        Material to make item out of
    -quality #(0-7)
        Quality to create the item at
    -dur #ticks
        Length of time for item to exist
    -matchingGloves
        If present it will create two gloves with correct handedness
    -matchingShoes
        If present it will create two shoes

Examples::
    item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:SUPER_INORGANIC -quality 7 -dur 3600
]====]

local utils = require "utils"
validArgs = utils.invert({
    "help",
    "creator",
    "material",
    "item",
    "matchingGloves",
    "matchingShoes",
    "dur",
    "quality",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in item/create - "

if args.help then
    print(usage)
    return
end

dur = tonumber(args.dur) or 0
if dur < 0 then return end

if not args.item then error(error_str .. "No item declared") end
if not args.material then error(error_str .. "No material declared") end

item1 = dfhack.script_environment("functions/item").create(args.item,args.material,args.creator,args.quality)
if args.matchingGloves or args.matchingShoes then
    item2 = dfhack.script_environment("functions/item").create(args.item,args.material,args.creator,args.quality)
    if args.matchingGloves then 
        df.item.find(item1.id):setGloveHandedness(1) 
        df.item.find(item2.id):setGloveHandedness(1) 
    end
end

if dur > 0 then
    cmd = "item/destroy"
    dfhack.script_environment("persist-delay").commandDelay(dur,cmd .. " -item " .. tostring(item1.id))
    if item2 then dfhack.script_environment("persist-delay").commandDelay(dur,cmd .. " -item " .. tostring(item2.id)) end
end