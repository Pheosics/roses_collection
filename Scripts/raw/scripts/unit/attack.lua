--unit/attack.lua
local usage = [====[

unit/attack
===========
Purpose::
    Create a custom attack using either supplied or calculated values

Function Calls::
    unit.getBodyRandom
    unit.getBodyParts
    unit.getInventory
    unit.getAttack
    item.getAttack
    attack.getAttackItemVelocity
    attack.getAttackUnitVelocity
    arrack.addAttack
        
Arguments::
    -defender        UNIT_ID
        Unit ID of defending unit
    -attacker        UNIT_ID
        Unit ID of attacking unit
    -target          CATEGORY
        Body part category to target for attack
        If absent it will select a random body part weighted by size
    -weapon
        If present it will use the attacker unit's equipped weapon
        If absent it will assume a body part attack
    -attack          ATTACK_TOKEN
        Attack token (e.g. PUNCH) of attack to use
        If absent it will select a random attack
    -velocity        #
        Velocity to use for attack
        If absent it will calculate the velocity based on various factors
    -hitchance       #
        Chance for attack to hitchance
        DEFAULT VALUE: 100
    -delay           #
        Delay time until attack executes
        DEFAULT VALUE: 1
    -number          #
        Number of attacks to executes
        DEFAULT VALUE: 1
            
Examples::
    unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID
    unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID -target HEAD -weapon -velocity 1000
    unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID -target UPPERBODY -attack PUNCH -number 100
]====]

local utils = require 'utils'
validArgs = utils.invert({
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
 'flags'
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print(usage)
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
 target = unitFunctions.getBodyRandom(defender)
else
 target = unitFunctions.getBodyParts(defender,'Category',args.target)[1]
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
  item = unitFunctions.getInventory(attacker,'ItemType','WEAPON')[1]
  if not item then
   print('No Equipped Weapon')
   return
  end
 end
 if not args.attack then
  attack = itemFunctions.getAttack(item,'Random')
 else
  attack = itemFunctions.getAttack(item,args.attack)
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
  attack = unitFunctions.getAttack(attacker,'Random')
 else
  attack = unitFunctions.getAttack(attacker,args.attack)
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
 attackFunctions.addAttack(attacker,defender.id,attack_id,target,item_id,attack,hitchance,velocity,delay,args.flags)
 j = j + 1
end
