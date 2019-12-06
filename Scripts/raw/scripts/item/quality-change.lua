--item/quality-change.lua
local usage = [====[

item/quality-change
====================
Purpose::
    Change the quality of a given item or equipped item(s)

Arguments::
    -item #ID
        id of item to change
    -quality #(0-7)
        Quality to set item to
    -upgrade
        If present will increase quality by 1
    -downgrade
        If present will decrease quality by 1
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
    item/quality-change -unit \\UNIT_ID -equipment ALL -upgrade -dur 3600
    item/quality-change -item \\ITEM_ID -quality 7

]====]

local utils = require "utils"
validArgs = utils.invert({
    "help",
    "unit",
    "item",
    "equipment",
    "quality",
    "dur",
    "upgrade",
    "downgrade",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in item/quality-change - "

if args.help then
    print(usage)
    return
end
if not args.quality and not args.upgrade and not args.downgrade then error(error_str.."No quality change declared") end

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
    currentQuality = item:getQuality()
    if args.quality then
        item:changeQuality(tonumber(args.quality))
    elseif args.upgrade or args.downgrade then
        if args.upgrade then quality = currentQuality + 1 end
        if args.downgrade then quality = currentQuality - 1 end
        item:changeQuality(quality)
    end
    if dur > 0  then 
        cmd = "item/quality-change"
        cmd = cmd .. " -item " .. tostring(item.id)
        cmd = cmd .. " -quality " .. tostring(currentQuality)
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
    end
end
