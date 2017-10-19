-- unequip an item from a unit, or a particular body part
local utils = require 'utils'

validArgs = utils.invert({
  'unit',
  'item',
  'itemType',
  'bodyPart',
  'partType',
  'mode'
})
local args = utils.processArgs({...}, validArgs)

local unitId = tonumber(args.unit)
local unit = df.unit.find(unitId)
if not unit then
 error('invalid unit!', args.unit)
end

if args.bodypart then
 local bodyPartName = args.bodyPart
 if args.partType == 'Category' then
  parts = dfhack.script_environment('functions/unit').getBodyToken(unit,bodyPartName)
 elseif args.partType == 'Flag' then
  parts = dfhack.script_environment('functions/unit').getBodyToken(unit,bodyPartName)
 else
  parts = dfhack.script_environment('functions/unit').getBodyToken(unit,bodyPartName)
 end

 items = dfhack.script_environment('functions/unit').getInventoryBodyPart(unit,parts)
 for _,itemId in pairs(items) do
  dfhack.script_environment('functions/item').unequip(itemId, unit)
 end
end

if args.mode then
 items = dfhack.script_environment('functions/unit').getInventoryMode(unit,df.unit_inventory_item.T_mode[args.mode])
 for _,itemId in pairs(items) do
  dfhack.script_environment('functions/item').unequip(itemId, unit)
 end
end

if args.itemType then
 items = dfhack.script_environment('functions/unit').getInventoryType(unit,args.itemType)
 for _,itemId in pairs(items) do
  dfhack.script_environment('functions/item').unequip(itemId, unit)
 end
end

if args.item then
 if args.item == 'ALL' then
  local items = {}
  for _.x in pairs(unit.inventory) do
   items[#items+1] = x.item.id
  end
  for _,itemId in pairs(items) do
   dfhack.script_environment('functions/item').unequip(itemId,unit)
  end
 else
  dfhack.script_environment('functions/item').unequip(item, unit)
 end
end
