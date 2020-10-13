--@ module=true
-- Plugins
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local myMath = reqscript("functions/math")
local myIO = reqscript("functions/io")
local getUnit = reqscript("functions/unit").getUnit
local checkSystemTable = reqscript("core/systems").checkSystemTable

-- System Definition
---- Name of the system
Name = "enhancedItems"

---- Raw file type to read
RawFileType = "Item"

---- Object function file
ObjFuncFile = "Item"

---- List of currently accepted tokens for the system
Tokens = {
	-- Base Tokens
	DESCRIPTION = {Type="Main", Subtype="String", Name="Description", Purpose="Sets a description to be used for the journal utility in the future"},
	CLASS       = {Type="Main", Subtype="String", Name="Class",       Purpose="Define an item class, not currently used for anything"},

	-- Trigger Tokens
	ON_EQUIP            = {Type="Sub", Subtype="Set", Name="OnEquip",           Purpose="Sets up a trigger for when the item is equipped"},
	ON_UNEQUIP          = {Type="Sub", Subtype="Set", Name="OnUnequip",         Purpose="Sets up a trigger for when the item is unequipped"},
	ON_ATTACK           = {Type="Sub", Subtype="Set", Name="OnAttack",          Purpose="Sets up a trigger for when a unit attacks (melee) with the item"},
	ON_SHOOT            = {Type="Sub", Subtype="Set", Name="OnShoot",           Purpose="Sets up a trigger for when a unit attacks (ranged) with the item"},
	ON_PARRY            = {Type="Sub", Subtype="Set", Name="OnParry",           Purpose="Sets up a trigger for when a unit parries with the item"},
	ON_BLOCK            = {Type="Sub", Subtype="Set", Name="OnBlock",           Purpose="Sets up a trigger for when a unit blocks with the item"},
	ON_WOUND            = {Type="Sub", Subtype="Set", Name="OnWound",           Purpose="Sets up a trigger for when a unit wounds another unit with the item"},
	ON_PROJECTILE_MOVE  = {Type="Sub", Subtype="Set", Name="OnProjectileMove",  Purpose="Sets up a trigger for when an item projectile moves"},
	ON_PROJECTILE_HIT   = {Type="Sub", Subtype="Set", Name="OnProjectileHit",   Purpose="Sets up a trigger for when an item projectile hits"},
	ON_PROJECTILE_FIRED = {Type="Sub", Subtype="Set", Name="OnProjectileFired", Purpose="Sets up a trigger for when an item projectile is fired"},
	
	-- OnEquip/OnUnequip shortcut Tokens
	ATTRIBUTE = {Type="OnEquip-OnUnequip", Subtype="Table", Name="Attributes", Purpose="Used as a shortcut for ON_EQUIP and ON_UNEQUIP attribute changes"},
	SKILL     = {Type="OnEquip-OnUnequip", Subtype="Table", Name="Skills",     Purpose="Used as a shortcut for ON_EQUIP and ON_UNEQUIP skill changes"},
	
	-- Effect Tokens (basically shortcuts for what the SCRIPT can do)
	ATTRIBUTE_CHANGE = {Type="Sub", Subtype="NamedList", Name="AttributeChange", Purpose="Equivalent to {SCRIPT:unit/change-attribute ...}", 
						Names={Target=2, Attribute=3, Change=4, Chance=5, Duration=6}},
	SKILL_CHANGE     = {Type="Sub", Subtype="NamedList", Name="SkillChange", Purpose="Equivalent to {SCRIPT:unit/change-skill ...}", 
						Names={Target=2, Skill=3, Change=4, Chance=5, Duration=6}},
	SYNDROME_CHANGE  = {Type="Sub", Subtype="NamedList", Name="SyndromeChange", Purpose="Equivalent to {SCRIPT:unit/change-syndrome ...}", 
						Names={Target=2, Syndrome=3, Change=4, Chance=5, Duration=6}},
						
	-- Script Tokens
	SCRIPT           = {Type="Sub", Subtype="ScriptC", Name="Scripts",          Purpose="A dfhack script to run with a specific chance when triggered"},
	REPEATING_SCRIPT = {Type="Sub", Subtype="ScriptF", Name="RepeatingScripts", Purpose="A dfhack script to run with a specific frequency"},
	
	-- Special Tokens
	---- Projectile Weapons
	FIRE_RATE = {Type="OnShoot", Subtype="Named", Name="FireRate", Purpose="Adjust the fire rate for ranged weapons",
				 Names={Base=2, Change=3, Max=4}},
}

EventfulFunctions = {
	onInventoryChange = {
		equipmentTrigger = function(unitID, itemID, item_old, item_new)
			local unit = df.unit.find(unitID)
			local item = df.item.find(itemID)
			if not unit or not item then return end
			if item_new and item_old then return end
			if item_new and not item_old then
				checkEquipTrigger(item,"OnEquip",unit) -- System specific check
			else
				checkEquipTrigger(item,"OnUnequip",unit) -- System specific check
			end
		end
	},
	onUnitAttack = {
		woundTrigger = function(attackerID,defenderID,wound)
			local attacker = df.unit.find(attackerID)
			local defender = df.unit.find(defenderID)
			if not attacker or not defender then return end
			local item = df.item.find(defender.last_hit.item)
			if not item then return end
			checkOnWoundTrigger(item,attacker,defender,wound) -- System specific check
		end
	},
	onProjItemCheckImpact = {
		hit = function(projectile)
			local item = projectile.item
			checkProjectileTrigger(item,"OnProjectileHit",projectile) -- System specific check
		end
	},
	onProjItemCheckMovement = {
		move = function(projectile)
			local item = projectile.item
			checkProjectileTrigger(item,"OnProjectileMove",projectile) -- System specific check
		end
	},
}
EventfulTypes = {
	UNIT_ATTACK = 1,
	INVENTORY_CHANGE = 5,
}
CustomFunctions = {
	onItemAction = {
		action = function(unit_id, action)
			if not unit_id or not action then return false end
			if action.type == df.unit_action_type.Move then
				-- What the heck am I going to do here? -ME
				-- Checking every units inventory every time they move seems overkill
			elseif action.type == df.unit_action_type.Attack then
				local item = df.item.find(action.data.attack.attack_item_id)
				if not item then return end -- The attack could be a body part attack, we don't care about those here
				local target_id = action.data.attack.target_unit_id
				checkOnActionTrigger(item,"OnAttack",unit_id,target_id,action) -- System specific check
			elseif action.type == df.unit_action_type.Block then
				local item = df.item.find(action.data.block.block_item_id)
				local target_id = action.data.block.unit_id
				checkOnActionTrigger(item,"OnBlock",unit_id,target_id,action) -- System specific check
			elseif action.type == df.unit_action_type.Parry then
				local item = df.item.find(action.data.parry.parry_item_id)
				local target_id = action.data.parry.unit_id
				checkOnActionTrigger(item,"OnParry",unit_id,target_id,action) -- System specific check
			end
		end,
	},
	onItemProjectile  = {
		shoot = function(projectile)
			if not df.is_instance(df.proj_itemst, projectile) then return end
			local item = df.item.find(projectile.bow_id)
			if not item then return end
			checkProjectileTrigger(item,"OnShoot",projectile) -- System specific check
		end,
		fired = function(projectile)
			if not df.is_instance(df.proj_itemst, projectile) then return end
			local item = projectile.item
			if not item then return end
			checkProjectileTrigger(item,"OnProjectileFired",projectile) -- System specific check
		end,
	}
}
CustomTypes = {
	onActionCheck = {ticks = 1, func=reqscript("functions/custom-events").checkForActions},
	onProjectileCheck = {ticks = 1, func=reqscript("functions/custom-events").checkForNewProjectiles}
}

Examples = [===[
	[ITEM_SHIELD:ITEM_SHIELD_EXAMPLE]
		[NAME:Example Shield]
		{DESCRIPTION:Knocks enemy backwards half the time when you block}
		... DF Item Stuff ...
		{ON_BLOCK}
			{SCRIPT:unit/propel -unit OPPONENT -source BLOCKER -velocity [ 50 50 0 ] -mode Relative:50}

	[ITEM_WEAPON:RAPID_FIRE_CROSSBOW]
		[NAME:Fast Shooting Crossbow]
		{DESCRIPTION:Shoots bolts very fast}
		... DF Item Stuff ...
		{FIRE_RATE:10:2:1} -- Base fire rate is 10, increases by 2 for each skill level, max shot speed is 1

	[ITEM_WEAPON:BLOOD_SWORD]
		[NAME:Blood Sword]
		{DESCRIPTION:Drains blood from opponent when wounded}
		... DF Item Stuff ...
		{ON_WOUND}
			{SCRIPT:unit/change-body -unit OPPONENT -blood \-10:100}
			{SCRIPT:unit/change-body -unit HOLDER -blood 10:100}
]===]

function initialize()
	local systemTable = reqscript("core/tables").Tables[Name]
	if not systemTable then return end
	
	-- Eventful Triggers
	for k,t in pairs(EventfulFunctions) do
		for name,func in pairs(t) do
			eventful[k][name] = function(...) return func(...) end
		end
	end
	for Type,ticks in pairs(EventfulTypes) do
		eventful.enableEvent(eventful.eventType[Type],ticks)
	end
	
	-- Custom Triggers
	-- How can I make this universal like the Eventful triggers so it doesn't have
	-- to be different for each system? -ME
	onItemAction = onItemAction or dfhack.event.new()
	onItemProjectile = onItemProjectile or dfhack.event.new()

	onItemAction.action = CustomFunctions.onItemAction.action
	onItemProjectile.shoot = CustomFunctions.onItemProjectile.shoot
	onItemProjectile.fired = CustomFunctions.onItemProjectile.fired
	
	for Type,v in pairs(CustomTypes) do
		repeats.scheduleUnlessAlreadyScheduled(Type,v.ticks,"ticks",v.func)
	end
	
	-- Run through necessary initialization
	---- None
end

-- Check function (run when the Eventful or Custom functions are triggered)
function check(ID, checkType, args)
	-- Using system specific check functions
end

-- Trigger function (run if correctly triggered)
function trigger(ID, Table, args)
	-- Using system specific trigger functions
end

-- System specific functions
function checkEquipTrigger(item,triggerType,unit)
	if not item then return end
	local item, Table = checkSystemTable(Name, ObjFuncFile, item)
	if not item or not Table then return end -- If not a valid item or the item doesn't have an enhanced table return
	if not Table[triggerType] then return end -- If the item doesn't have the correct enhanced table return
	
	unit = getUnit(unit)
	
	itemTrigger(Table[triggerType], item, unit)
end

function checkOnActionTrigger(item,triggerType,unitA,unitB,action)
	if not item then return end
	local item, Table = checkSystemTable(Name, ObjFuncFile, item)
	if not item or not Table then return end -- If not a valid item or the item doesn't have an enhanced table return
	if not Table[triggerType] then return end -- If the item doesn't have the correct enhanced table return
	
	unitA = getUnit(unitA)
	unitB = getUnit(unitB)
	
	itemTrigger(Table[triggerType], item, unitA, unitB)
end

function checkOnWoundTrigger(item,unitA,unitB,wound)
	if not item then return end
	local item, Table = checkSystemTable(Name, ObjFuncFile, item)
	if not item or not Table then return end -- If not a valid item or the item doesn't have an enhanced table return
	if not Table["OnWound"] then return end -- If the item doesn't have the correct enhanced table return

	unitA = getUnit(unitA)
	unitB = getUnit(unitB)
	
	itemTrigger(Table["OnWound"], item, unitA, unitB)
end

function checkProjectileTrigger(item,triggerType,projectile)
	local firer = projectile.firer
	if not firer or not item then return end
	local item, Table = checkSystemTable(Name, ObjFuncFile, item)
	if not item or not Table then return end -- If not a valid item or the item doesn't have an enhanced table return
	if not Table[triggerType] then return end -- If the item doesn't have the correct enhanced table return

	firer = getUnit(firer)
	
	itemTrigger(Table[triggerType], item, firer, nil, projectile)
end

local targetWords = {
	SELF = "unitA", HOLDER = "unitA", BLOCKER = "unitA", ATTACKER = "unitA", EQUIPER = "unitA",
	TARGET = "unitB", OPPONENT = "unitB",
}

function itemTrigger(triggerTable, item, unitHolder, opponent, projectile)
	
	for k,v in pairs(triggerTable.Attributes or {}) do unitHolder.Attributes[k]:changeValue(v) end

	for k,v in pairs(triggerTable.Skills or {}) do unitHolder.Skills[k]:changeLevelValue(v)	end

	for _,v in pairs(triggerTable.AttributeChange or {}) do
		if myMath.roll(v.Chance) then
			if targetWords[v.Target] == "unitA" then
				unitHolder.Attributes[v.Attribute]:changeValue(v.Change)
			elseif targetWords[v.Target] == "unitB" then
				opponent.Attributes[v.Attribute]:changeValue(v.Change)
			end
		end
	end

	for _,v in pairs(triggerTable.SkillChange or {}) do	end -- Need to implement -ME

	for _,v in pairs(triggerTable.SyndromeChange or {}) do end -- Need to implement -ME

	if triggerTable.FireRate then
		local rate = unitHolder:getSkillRate(item.subtype.skill_ranged, triggerTable.FireRate.Base, triggerTable.FireRate.Change)
		local maxRate = triggerTable.FireRate.Max or 80
		unitHolder:setCounter("think_counter",math.max(rate,maxRate))
	end
	
	if triggerTable.Scripts then
		local scriptTable = {}
		
		-- Base Item Stuff (Always present)
		scriptTable.item_id = item.id
		scriptTable.item_token = item.Token
		scriptTable.item_location = myIO.locationString(dfhack.items.getPosition(item._item))
		scriptTable.item_holder_id = unitHolder.id
		scriptTable.item_holder_location = myIO.locationString(unitHolder._unit.pos)
		
		-- Opponent Item Stuff (Only present for actions that involve an opponent (e.g. Attack, Wound, Block, etc..)
		if opponent then
			scriptTable.opponent_id = opponent.id or -1
			scriptTable.opponent_location = myIO.locationString(opponent._unit.pos)
		end
		
		-- Projectile Item Stuff (Only present for actions that include a projectile)
		if projectile then
			scriptTable.projectile_id = projectile.id or -1
			scriptTable.projectile_location = myIO.locationString(projectile.cur_pos)
			scriptTable.projectile_firer_id = projectile.firer.id or -1
			scriptTable.projectile_target_id = opponent.id or -1
			scriptTable.projectile_firer_location = myIO.locationString(projectile.origin_pos)
			scriptTable.projectile_target_location = myIO.locationString(projectile.target_pos)
		end
		
		for i,x in pairs(triggerTable.Scripts) do
			local script = x.Script
			local chance = x.Chance or 100
			if myMath.roll(chance) then
				dfhack.run_command(myIO.gsub_script(script,scriptTable))
			end
		end
	end
end