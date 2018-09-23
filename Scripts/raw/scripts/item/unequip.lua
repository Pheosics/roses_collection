--item/unequip.lua
local usage = [====[

item/unequip
============
Purpose::
    Equip an item to a unit, bypassing normal equipment rules

Function Calls::
    unit.getBodyParts
    unit.getInventory
    item.unequip

Arguments::
    -unit           UNIT_ID
        id of unit to equip item to
    -item           ITEM_ID
        id of item to equip
        Special Tokens:
                ALL
    -itemType       Item Type
        Type of item to check inventory for
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
    -bodyType
        Body part type to find to unequip from
        Valid Values:
            Category
            Flag
            Token
    -bodyPart
        Body part to equip to (based on -bodyType)
    -mode
        Mode of item to check inventory for
        Valid Values:
            Worn

Examples::
    item/unequip -unit \\UNIT_ID -itemType WEAPON
    item/unequip -unit \\UNIT_ID -item \\ITEM_ID 
    item/unequip -unit \\UNIT_ID -bodyType Category -bodyPart UPPERBODY

]====]

local utils = require 'utils'
validArgs = utils.invert({
  'help',
  'unit',
  'item',
  'itemType',
  'bodyPart',
  'bodyType',
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

items = {}
if args.item and tonumber(args.item) then
 dfhack.script_environment('functions/item').unequip(args.item, unit)
 return
elseif args.item then
 if args.item == 'ALL' then
  for _,x in pairs(unit.inventory) do
   items[#items+1] = x.item.id
  end
 end
elseif args.bodypart then
 parts = dfhack.script_environment('functions/unit').getBodyParts(unit,args.bodyType,args.bodyPart)
 items = dfhack.script_environment('functions/unit').getInventory(unit,'BodyPart',parts)
elseif args.mode then
 items = dfhack.script_environment('functions/unit').getInventory(unit,'Mode',df.unit_inventory_item.T_mode[args.mode])
elseif args.itemType then
 items = dfhack.script_environment('functions/unit').getInventory(unit,'Type',args.itemType)
end

for _,itemId in pairs(items) do
 dfhack.script_environment('functions/item').unequip(itemId, unit)
end

