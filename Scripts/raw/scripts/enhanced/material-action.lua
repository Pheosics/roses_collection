local utils = require 'utils'

validArgs = utils.invert({
	'unit',
	'item',
	'source',
	'target',
	'action',
	'wound',
	'velocity',
	'accuracy',
	'matType'
})
local args = utils.processArgs({...}, validArgs)

local itemId = tonumber(args.item)
local item = df.item.find(itemId)
if not item then
 error('invalid item!', args.item)
end

if not args.action then
 error('No action specified')
end

options = {}
if args.wound then options.wound = args.wound end
if args.velocity then options.velocity = args.velocity end
if args.accuracy then options.accuracy = args.accuracy end

actionType = string.upper(args.action)
if actionType == 'EQUIP' or actionType == 'UNEQUIP' then
 if args.unit and tonumber(args.unit) then unit = df.unit.find(tonumber(args.unit)) end
 if not unit then error('invalid unit!', args.unit) end
 if actionType == 'EQUIP' then dfhack.script_environment('functions/enhanced').onMaterialEquip(item,unit) end
 if actionType == 'UNEQUIP' then dfhack.script_environment('functions/enhanced').onMaterialUnEquip(item,unit) end
else
 if args.source and tonumber(args.source) then source = df.unit.find(tonumber(args.source)) end
 if args.target and tonumber(args.target) then target = df.unit.find(tonumber(args.target)) end
 if not source and not target then error('Neither source or target declared') end
 if actionType == 'ATTACK' then dfhack.script_environment('functions/enhanced').onMaterialAction(item,'OnAttack',source,target,options) end
 if actionType == 'BLOCK' then dfhack.script_environment('functions/enhanced').onMaterialAction(item,'OnBlock',source,target,options) end
 if actionType == 'DODGE' then dfhack.script_environment('functions/enhanced').onMaterialAction(item,'OnDodge',source,target,options) end
 if actionType == 'MOVE' then dfhack.script_environment('functions/enhanced').onMaterialAction(item,'OnMove',source,target,options) end
 if actionType == 'PARRY' then dfhack.script_environment('functions/enhanced').onMaterialAction(item,'OnParry',source,target,options) end
 if actionType == 'WOUND' then dfhack.script_environment('functions/enhanced').onMaterialAction(item,'OnWound',source,target,options) end
end