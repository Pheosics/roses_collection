--unit/attack.lua
--@ module=true
local utils = require 'utils'
defunit = reqscript("functions/unit").UNIT
defitem = reqscript("functions/item").ITEM
randoms = reqscript("functions/math").selectRandom

local usage = [====[

unit/attack
===========
Purpose::
    Create a custom attack using either supplied or calculated values
   
Arguments::
    -defender <UNIT_ID>
        Unit ID of defending unit
    -attacker <UNIT_ID>
        Unit ID of attacking unit
    -target <BP_CATEGORY>
        Body part category to target for attack
        If absent it will select a random body part weighted by size
    -weapon
        If present it will use the attacker unit's equipped weapon
        If absent it will assume a body part attack
    -attack <ATTACK_TOKEN>
        Attack token (e.g. PUNCH) of attack to use
        If absent it will select a random attack
    -velocity <#>
        Velocity to use for attack
        If absent it will calculate the velocity based on various factors
    -hitchance <#>
        Chance for attack to hitchance
        DEFAULT VALUE: 100
    -delay <#>
        Delay time until attack executes
        DEFAULT VALUE: 1
    -number <#>
        Number of attacks to executes
        DEFAULT VALUE: 1
            
Examples::
	* Add a random body part attack to the attacker targeting a random body part of the defender
		unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID
	* Add a random weapon attack to the attacker targeting the defenders head
		unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID -target HEAD -weapon -velocity 1000
	* Add 100 punch attacks to attacker target defenders upper body
		unit/attack -attacker \\UNIT_ID -defender \\UNIT_ID -target UPPERBODY -attack PUNCH -number 100
]====]


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
	"args",
})

local function setAttack(attacker, defender, target_bp, attack, velocity, hitchance, delay, number)
	number = tonumber(number) or 1
	delay = delay or 1
	
	-- Set Attack Action Data
	local attack_data = {}
	attack_data.target_unit_id = defender.id
	attack_data.target_body_part_id = defender.id
	attack_data.attack_id = attack.id
	attack_data.attack_velocity = velocity
	attack_data.attack_accuracy = hitchance
	attack_data.timer1 = delay
	attack_data.timer2 = delay
	if attack.item_id then 
		attack_data.attack_item_id = attack.item_id
		attack_data.attack_body_part_id = -1
	else
		attack_data.attack_item_id = -1
		attack_data.attack_body_part_id = attack.body_part_idx[0]
	end
	
	j = 0
	while j < number do
		attacker:addAttack(attack_data)
		j = j + 1
	end
end

function weaponAttack(attacker, defender, options)
	options = options or {}
	
	-- Get Attacker Information
	attacker = defunit(attacker)
	items = attacker:getInventoryItems("Type","WEAPON")
	weapon = defitem(randoms(items))
	if not weapon then return end
	
	-- Get Attack Information
	attackType = options.attack or "RANDOM"
	attack = weapon:getAttack(attackType)
	if not attack then return end
	if options.velocity then
		velocity = tonumber(options.velocity)
	else
		velocity = attack:computeVelocity()
	end
	if options.hitchance then
		hitchance = tonumber(options.hitchance)
	else
		hitchance = attack:computeHitChance()
	end
	
	-- Get Defender Information
	defender = defunit(defender)
	targetCategory = options.target or "RANDOM"
	body_parts = defender:getBodyParts("CATEGORY",targetCategory)
	target_bp = randoms(body_parts)
	
	setAttack(attacker, defender, target_bp, attack, velocity, hitchance, options.delay, options.number)
end

function bodyPartAttack(attacker, defender, options)
	options = options or {}
	
	-- Get Attacker Information
	attacker = defunit(attacker)
	attackType = options.attack or "RANDOM"
	
	-- Get Attack Information
	attackType = options.attack or "RANDOM"
	attack = attacker:getAttack(attackType)
	if not attack then return end
	if options.velocity then
		velocity = tonumber(options.velocity)
	else
		velocity = attack:computeVelocity()
	end
	if options.hitchance then
		hitchance = tonumber(options.hitchance)
	else
		hitchance = attack:computeHitChance()
	end
	
	-- Get Defender Information
	defender = defunit(defender)
	targetCategory = options.target or "RANDOM"
	body_parts = defender:getBodyParts("CATEGORY",targetCategory)
	target_bp = randoms(body_parts)
	
	setAttack(attacker, defender, target_bp, attack, velocity, hitchance, options.delay, options.number)
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in unit/attack - "
	
	-- Print Help Message
	if args.help then
		print(usage)
		return
	end
	
	-- Print valid argument list
	if args.args then
		printall(validArgs)
		return
	end
	
	if args.defender and tonumber(args.defender) then defender = df.unit.find(tonumber(args.defender)) end
	if args.attacker and tonumber(args.attacker) then attacker = df.unit.find(tonumber(args.attacker)) end
	if not defender or not attacker then error(error_str .. "Invalid attacker or defender") end
	
	local options = {}
	options.velocity = args.velocity
	options.delay = args.delay
	options.number = args.number
	options.hitchance = args.hitchance
	options.target = args.target
	options.attack = args.attack
	
	if args.weapon then
		weaponAttack(attacker,defender,options)
	else
		bodyPartAttack(attacker,defender,options)
	end
end

if not dfhack_flags.module then
	main(...)
end
