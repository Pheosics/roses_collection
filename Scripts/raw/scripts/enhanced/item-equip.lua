--equip an item on a unit with a particular body part
local utils = require 'utils'

validArgs = utils.invert({
	'unit',
	'item',
	'equip',
	'unequip',
        'mat'
})
local args = utils.processArgs({...}, validArgs)

local unitId = tonumber(args.unit)
local unit = df.unit.find(unitId)
if not unit then
 error('invalid unit!', args.unit)
end

local itemId = tonumber(args.item)
local item = df.item.find(itemId)
if not item then
 error('invalid item!', args.item)
end

if args.mat then
 if args.equip then
  dfhack.script_environment('functions/enhanced').onMatEquip(item,unit)
 elseif args.unequip then
  dfhack.script_environment('functions/enhanced').onMatUnEquip(item,unit)
 end
else
 if args.equip then
  dfhack.script_environment('functions/enhanced').onItemEquip(item,unit)
 elseif args.unequip then
  dfhack.script_environment('functions/enhanced').onItemUnEquip(item,unit)
 end
end
