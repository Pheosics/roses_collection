-- equip an item on a unit with a particular body part
local utils = require 'utils'

validArgs = utils.invert({
  'unit',
  'item',
  'bodyPart',
  'type',
  'mode',
  'verbose'
})
local args = utils.processArgs({...}, validArgs)

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

if args.type == 'Category' then
 parts = dfhack.script_environment('functions/unit').getBodyCategory(unit,bodyPartName)
elseif args.type == 'Flag' then
 parts = dfhack.script_environment('functions/unit').getBodyFlag(unit,bodyPartName)
else
 parts = dfhack.script_environment('functions/unit').getBodyToken(unit,bodyPartName)
end
local partId = parts[1]

if not partId then
  error('invalid body part name: ', bodyPartName)
end

local mode = args.mode or 'Worn'
mode = df.unit_inventory_item.T_mode[mode]

dfhack.script_environment('functions/item').equip(item, unit, partId, mode)
--require('plugins.eventful').onInventoryChange.equipmentTrigger(unit.id,item.id,nil,item.id)
