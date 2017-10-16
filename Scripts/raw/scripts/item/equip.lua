-- equip an item on a unit with a particular body part
local utils = require 'utils'

validArgs = --[[validArgs or--]] utils.invert({
  'unit',
  'item',
  'bodyPart',
  'type',
  'mode'
})

if moduleMode then
  return
end

local args = utils.processArgs({...}, validArgs)

if args.help then
 print(help)
 return
end

local unitId = tonumber(args.unit) or ((args.unit == '\\LAST') and (df.global.unit_next_id-1))
local unit = df.unit.find(unitId)
if not unit then
 error('invalid unit!', args.unit)
end

local itemId = tonumber(args.item) or ((args.item == '\\LAST') and (df.global.item_next_id-1))
local item = df.item.find(itemId)
if not item then
 error('invalid item!', args.item)
end

local bodyPartName = args.bodyPart

if args.type == 'Category' then
 parts = dfhack.script_environment('functions/unit').getBodyToken(unit,bodyPartName)
elseif args.type == 'Flag' then
 parts = dfhack.script_environment('functions/unit').getBodyToken(unit,bodyPartName)
else
 parts = dfhack.script_environment('functions/unit').getBodyToken(unit,bodyPartName)
end
local partId = parts[1]

if not partId then
  error('invalid body part name: ', bodyPartName)
end

local mode = args.mode
mode = df.unit_inventory_item.T_mode[mode]

dfhack.script_environment('functions/item').equip(unit, item, partId, mode)

