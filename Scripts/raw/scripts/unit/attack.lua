--unit/attack.lua
local usage = [====[

unit/attack
===========
Purpose::
    Create a custom attack using either supplied or calculated values
   
Arguments::
    -defender #ID
        Unit ID of defending unit
    -attacker #ID
        Unit ID of attacking unit
    -target BP_CATEGORY
        Body part category to target for attack
        If absent it will select a random body part weighted by size
    -weapon
        If present it will use the attacker unit's equipped weapon
        If absent it will assume a body part attack
    -attack ATTACK_TOKEN
        Attack token (e.g. PUNCH) of attack to use
        If absent it will select a random attack
    -velocity #
        Velocity to use for attack
        If absent it will calculate the velocity based on various factors
    -hitchance #
        Chance for attack to hitchance
        DEFAULT VALUE: 100
    -delay #
        Delay time until attack executes
        DEFAULT VALUE: 1
    -number #
        Number of attacks to executes
        DEFAULT VALUE: 1
            
Examples::
    unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID
    unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID -target HEAD -weapon -velocity 1000
    unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID -target UPPERBODY -attack PUNCH -number 100
]====]

local utils = require 'utils'
validArgs = utils.invert({
    "help",
    "defender",
    "attacker",
    "target",
    "attack",
    "velocity",
    "hitchance",
    "weapon",
    "delay",
    "number",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in unit/attack - "

if args.help then
    print(usage)
    return
end

if args.defender and tonumber(args.defender) then defender = dfhack.script_environment("functions/unit").UNIT(args.defender) end
if args.attacker and tonumber(args.attacker) then attacker = dfhack.script_environment("functions/unit").UNIT(args.attacker) end
if not defender or not attacker then error(error_str .. "Invalid attacker or defender") end

local delay = tonumber(args.delay) or 1
local number = tonumber(args.number) or 1
local hitchance = tonumber(args.hitchance) or 100

-- Get attack information
if args.weapon then
    if string.lower(args.weapon) == "equipped" then
        items = attacker:getInventoryItems("Type","WEAPON")
        itemx = dfhack.script_environment("functions/math").selectRandom(items)
        item = dfhack.script_environment("functions/item").ITEM(itemx)
    end
    if not item then error(error_str .. "No valid Equipped Weapon") end
    attack = item:getAttack(args.attack)
    if not attack then error(error_str .. "No appropriate attack found") end
else
    attack = attacker:getAttack(args.attack)
    if not attack then error(error_str .. "No appropriate attack found") end
end
if args.velocity and tonumber(args.velocity) then
    velocity = tonumber(args.velocity)
else
    velocity = attack:computeVelocity()
end
-- Get target information
body_parts = defender:getBodyParts("CATEGORY",args.target)
target = dfhack.script_environment("functions/math").selectRandom(body_parts)

local attack_data = df.unit_action:new().data.attack
attack_data.target_unit_id = defender.id
attack_data.target_body_part_id = target.id
attack_data.attack_id = attack.id
attack_data.attack_velocity = velocity
attack_data.attack_accuracy = hitchance
attack_data.timer1 = delay
attack_data.timer2 = delay
if item then 
    attack_data.attack_item_id = item.id
    attack_data.attack_body_part_id = -1
else
    attack_data.attack_item_id = -1
    attack_data.attack_body_part_id = attack.body_part_idx[0]
end


j = 0
while j < number do
    attacker:addAction("Attack",attack_data)
    j = j + 1
end
