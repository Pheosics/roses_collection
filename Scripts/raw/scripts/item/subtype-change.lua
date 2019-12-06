--item/subtype-change.lua
local usage = [====[

item/subtype-change
====================
Purpose::
    Change the subtype of a given item or equipped item(s)
 
Arguments::
    -item #ID
        id of item to change
    -subtype ITEM_SUBTYPE
        Subtype to change item into
    -unit #ID
        id of unit to change if using -equipment
    -equipment ITEM_TYPE
        Type of equipment to check for
        Valid Types:
            ALL
            WEAPON
            ARMOR
            HELM
            SHOES
            SHIELD
            GLOVES
            PANTS
            AMMO
    -dur #ticks
        Length of time for change to last

Examples::
    item/subtype-change -item \\ITEM_ID -subtype INORGANIC:DIAMOND -dur 3600
    item/subtype-change -unit \\UNIT_ID -equipment WEAPON -mat INORGANIC:SLADE

]====]

local utils = require "utils"
validArgs = utils.invert({
    "help",
    "unit",
    "item",
    "equipment",
    "subtype",
    "dur",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in item/subtype-change - "

if args.help then
    print(usage)
    return
end
if not args.subtype then error(error_str.."No subtype change declared") end

dur = tonumber(args.dur) or 0
if dur < 0 then return end

if args.item and tonumber(args.item) then
    items = {dfhack.script_environment("functions/item").ITEM(tonumber(args.item))}
elseif args.unit and tonumber(args.unit) then
    unit = dfhack.script_environment("functions/unit").UNIT(tonumber(args.unit))
    items = unit:getInventoryItems("TYPE",args.equipment)
    for i,item in pairs(items) do
        items[i] = dfhack.script_environment("functions/item").ITEM(item)
    end
end
if not items then
    error(error_str .. "No item or unit selected")
end

for _,item in pairs(items) do
    currentSubtype = item:getSubtype()
    item:changeSubtype(args.subtype)
    if dur > 0  then 
        cmd = "item/subtype-change"
        cmd = cmd .. " -item " .. tostring(item.id)
        cmd = cmd .. " -subtype " .. currentSubtype
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
    end
end
