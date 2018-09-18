-- item/equip.lua
local usage = [====[

item/equip
==========
Purpose::
    Equip an item to a unit, bypassing normal equipment rules

Function Calls::
    unit.getBodyParts
    item.equip

Arguments::
    -unit        UNIT_ID
        id of unit to equip item to
    -item        ITEM_ID
        id of item to equip
        Special Tokens:
            GROUND
            MOST_RECENT
    -bodyType    Body Part Type
        Body part type to find to equip to
        Valid Values:
            Category
            Flag
            Token
    -bodyPart
        Body part to equip to (based on -bodyType)
    -mode
        Method for equiping
        Valid Values:
            Worn

Examples::
    item/equip -unit \\UNIT_ID -item MOST_RECENT -bodyType Flag -bodyPart GRASP
    item/equip -unit \\UNIT_ID -item \\ITEM_ID -bodyType Category -bodyPart UPPERBODY

]====]

local utils = require 'utils'
validArgs = utils.invert({
  'unit',
  'item',
  'bodyPart',
  'bodytype',
  'mode',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

local unitId = tonumber(args.unit)
local unit = df.unit.find(unitId)
if not unit then
 error('invalid unit!', args.unit)
end

if args.item == 'GROUND' then
 print('Currently equipping all items from ground is not currently supported')
 return
elseif args.item == 'MOST_RECENT' then
 itemID = df.global.item_next_id-1
 item = df.item.find(itemID)
elseif tonumber(args.item) then
 itemId = tonumber(args.item)
 item = df.item.find(itemId)
end
if not item then
 error('invalid item!', args.item)
end

local bodyPartName = args.bodyPart
parts = dfhack.script_environment('functions/unit').getBodyParts(unit,args.bodyType,args.bodyPart)
local partId = parts[1]
if not partId then
  error('invalid body part name: ', bodyPartName)
end

local mode = args.mode or 'Worn'
mode = df.unit_inventory_item.T_mode[mode]

dfhack.script_environment('functions/item').equip(item, unit, partId, mode)
