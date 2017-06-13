--unit/attack.lua v0.8 | DFHack 43.05

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'defender',
 'attacker',
 'target',
 'attack',
 'velocity',
 'hitchance',
 'weapon',
 'delay',
 'number',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/attack
 ]])
 return
end

if args.defender and tonumber(args.defender) then
 defender = df.unit.find(tonumber(args.defender))
else
 print('No defender selected')
 return
end
if args.attacker and tonumber(args.attacker) then
 attacker = df.unit.find(tonumber(args.attacker))
else
 print('No attacker selected')
 return
end

attack = nil
target = nil
delay = tonumber(args.delay) or 1
number = tonumber(args.number) or 1
hitchance = tonumber(args.hitchance) or 100
unitFunctions = dfhack.script_environment('functions/unit')
attackFunctions = dfhack.script_environment('functions/attack')
itemFunctions = dfhack.script_environment('functions/item')

if not args.target then
 target = unitFunctions.checkBodyRandom(defender)
else
 target = unitFunctions.checkBodyCategory(defender,args.target)[1]
end
 
if not target then
 print('No appropriate target found')
 return
end
 
if args.weapon then
 attack_id = -1
 local item = nil
 args.weapon = 'Equipped'
 if args.weapon == 'Equipped' then
  item = unitFunctions.checkInventoryType(attacker,'WEAPON')[1]
  if not item then
   print('No Equipped Weapon')
   return
  end
 end
 if not args.attack then
  attack = itemFunctions.checkAttack(item,'Random')
 else
  attack = itemFunctions.checkAttack(item,args.attack)
 end
 if not attack then
  print('No appropriate attack found')
  return
 end
 item_id = item.id
 if args.velocity then
  velocity = tonumber(args.velocity)
 else
  velocity = attackFunctions.getAttackItemVelocity(attacker,item,attack)
 end
else
 item_id = -1 
 if not args.attack then
  attack = unitFunctions.checkAttack(attacker,'Random')
 else
  attack = unitFunctions.checkAttack(attacker,args.attack)
 end
 if not attack then
  print('No appropriate attack found')
  return
 end
 attack_id = attacker.body.body_plan.attacks[attack].body_part_idx[0]
 if args.velocity then
  velocity = tonumber(args.velocity)
 else
  velocity = attackFunctions.getAttackUnitVelocity(attacker,attack)
 end
end

j = 0
while j < number do
 attackFunctions.addAttack(attacker,defender.id,attack_id,target,item_id,attack,hitchance,velocity,delay)
 j = j + 1
end
