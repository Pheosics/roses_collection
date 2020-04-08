--@ module=true
-- Plugins
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local myMath = reqscript("functions/math")
local myIO = reqscript("functions/io")
local checkSystemTable = reqscript("core/systems").checkSystemTable

-- System Definition
Initialization = true

-- Name of the system
Name = "enhancedItems"

-- Raw file type to read
RawFileType = "Item"

---- Object function file
ObjFuncFile = "item"

-- List of currently accepted tokens for the system
Tokens = {
	-- Base Tokens
	DESCRIPTION = {Type="Main", Subtype="String",  Name="Description", Purpose="Sets a description to be used for the journal utility in the future"},
	CLASS       = {Type="Main", Subtype="String", Name="Class", Purpose="Define an item class, not currently used for anything"},

	-- Trigger Tokens
	ON_EQUIP            = {Type="Sub", Subtype="Set", Name="OnEquip", Purpose="Sets up a trigger for when the item is equipped"},
	ON_ATTACK           = {Type="Sub", Subtype="Set", Name="OnAttack", Purpose="Sets up a trigger for when a unit attacks (melee) with the item"},
	ON_SHOOT            = {Type="Sub", Subtype="Set", Name="OnShoot", Purpose="Sets up a trigger for when a unit attacks (ranged) with the item"},
	ON_PARRY            = {Type="Sub", Subtype="Set", Name="OnParry", Purpose="Sets up a trigger for when a unit parries with the item"},
	ON_BLOCK            = {Type="Sub", Subtype="Set", Name="OnBlock", Purpose="Sets up a trigger for when a unit blocks with the item"},
	ON_WOUND            = {Type="Sub", Subtype="Set", Name="OnWound", Purpose="Sets up a trigger for when a unit wounds another unit with the item"},
	ON_PROJECTILE_MOVE  = {Type="Sub", Subtype="Set", Name="OnProjectileMove", Purpose="Sets up a trigger for when an item projectile moves"},
	ON_PROJECTILE_HIT   = {Type="Sub", Subtype="Set", Name="OnProjectileHit", Purpose="Sets up a trigger for when an item projectile hits"},
	ON_PROJECTILE_FIRED = {Type="Sub", Subtype="Set", Name="OnProjectileFired", Purpose="Sets up a trigger for when an item projectile is fired"},
	
	-- Effect Tokens (basically shortcuts for what the SCRIPT can do)
	--ATTRIBUTE_CHANGE = {Type="Sub", Subtype="NamedList", Name="Attributes", Purpose="Equivalent to {SCRIPT:unit/change-attribute ...}", 
	--					Names={Target=2, Attribute=3, Change=4, Chance=5, Duration=6}},
	--SKILL_CHANGE     = {Type="Sub", Subtype="NamedList", Name="Skills", Purpose="Equivalent to {SCRIPT:unit/change-skill ...}", 
	--					Names={Target=2, Skill=3, Change=4, Chance=5, Duration=6}},
	--SYNDROME_CHANGE  = {Type="Sub", Subtype="NamedList", Name="Syndromes", Purpose="Equivalent to {SCRIPT:unit/change-syndrome ...}", 
	--					Names={Target=2, Syndrome=3, Change=4, Chance=5, Duration=6}},
						
	-- Script Tokens
	SCRIPT           = {Type="Sub", Subtype="ScriptC", Name="Scripts", Purpose="A dfhack script to run with a specific chance when triggered"},
	--REPEATING_SCRIPT = {Type="Sub", Subtype="ScriptF", Name="RepeatingScripts", Purpose=""}
}

EventfulFunctions = {
	onInventoryChange = {
		equipmentTrigger = function(unitID, itemID, item_old, item_new)
			local unit = df.unit.find(unitID)
			local item = df.item.find(itemID)
			if not unit or not item then return end
			if item_new and item_old then return end
			if item_new and not item_old then
				checkItemTrigger(item,"OnEquip",unit,"equip")
			else
				checkItemTrigger(item,"OnEquip",unit,"unequip")
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
			checkItemTrigger(item,"OnWound",attacker,defender,wound)
		end
	},
	onProjItemCheckImpact = {
		hit = function(projectile)
			local item = projectile.item
			checkItemTrigger(item,"OnProjectileHit",projectile)
		end
	},
	onProjItemCheckMovement = {
		move = function(projectile)
			local item = projectile.item
			checkItemTrigger(item,"OnProjectileMove",projectile)
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
				--checkItemTrigger(item,"OnMove",unit_id,action) 
				-- What the heck am I going to do here?
				-- Checking every units inventory every time they move seems overkill
			elseif action.type == df.unit_action_type.Attack then
				local item = df.item.find(action.data.attack.attack_item_id)
				if not item then return end -- The attack could be a body part attack, we don't care about those here
				local target_id = action.data.attack.target_unit_id
				checkItemTrigger(item,"OnAttack",unit_id,target_id,action)
			elseif action.type == df.unit_action_type.Block then
				local item = df.item.find(action.data.block.block_item_id)
				local target_id = action.data.block.unit_id
				checkItemTrigger(item,"OnBlock",unit_id,target_id,action)
			elseif action.type == df.unit_action_type.Parry then
				local item = df.item.find(action.data.parry.parry_item_id)
				local target_id = action.data.parry.unit_id
				checkItemTrigger(item,"OnParry",unit_id,target_id,action)
			end
		end,
	},
	onItemProjectile  = {
		shoot = function(projectile)
			local item = df.item.find(projectile.bow_id)
			if not item then return end
			checkItemTrigger(item,"OnShoot",projectile)
		end,
		fired = function(projectile)
			local item = projectile.item
			if not item then return end
			checkItemTrigger(item,"OnProjectileFired",projectile)
		end,
	}
}
CustomTypes = {
	onActionCheck = {ticks = 1, func=reqscript("functions/custom-events").checkForActions},
	onProjectileCheck = {ticks = 1, func=reqscript("functions/custom-events").checkForNewProjectiles}
}

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
	onItemAction = onItemAction or dfhack.event.new()
	onItemProjectile = onItemProjectile or dfhack.event.new()

	onItemAction.action = CustomFunctions.onItemAction.action
	onItemProjectile.shoot = CustomFunctions.onItemProjectile.shoot
	onItemProjectile.fired = CustomFunctions.onItemProjectile.fired
	
	for Type,v in pairs(CustomTypes) do
		repeats.scheduleUnlessAlreadyScheduled(Type,v.ticks,"ticks",v.func)
	end
end

function checkItemTrigger(itemID, triggerType, ...)
	if not itemID then return end
	local item, Table = checkSystemTable(Name, ObjFuncFile, itemID)
	if not item or not Table then return end -- If not a valid item or the item doesn't have an enhanced table return
	if not Table[triggerType] then return end -- If the item doesn't have the correct enhanced table return
	
	if triggerType == "OnEquip" then
		onEquip(Table[triggerType], item, ...)
	elseif triggerType == "OnWound" then
		onWound(Table[triggerType], item, ...)
	elseif triggerType == "OnMove" or
			triggerType == "OnAttack" or
			triggerType == "OnBlock" or
			triggerType == "OnParry" then
		onAction(Table[triggerType], item, ...)
	elseif triggerType == "OnShoot" or
			triggerType == "OnProjectileFired" or
			triggerType == "OnProjectileHit" or
			triggerType == "OnProjectileMove" then
		onProjectile(Table[triggerType], item, ...)
	end
end

function itemTrigger(triggerTable, item, unitHolder, opponent, projectile)
	local opponent = opponent or {}
	local projectile = projectile or {firer={}}
	local scriptTable = {}
	
	-- Base Item Stuff (Always present)
	scriptTable.item_id = item.id
	scriptTable.item_token = item.Token
	scriptTable.item_location = myIO.locationString(dfhack.items.getPosition(item._item))
	scriptTable.item_holder_id = unitHolder.id
	scriptTable.item_holder_location = myIO.locationString(unitHolder.pos)
	
	-- Opponent Item Stuff (Only present for actions that involve an opponent (e.g. Attack, Wound, Block, etc..)
	scriptTable.opponent_id = opponent.id or -1
	scriptTable.opponent_location = myIO.locationString(opponent.pos)
	
	-- Projectile Item Stuff (Only present for actions that include a projectile)
	scriptTable.projectile_id = projectile.id or -1
	scriptTable.projectile_location = myIO.locationString(projectile.cur_pos)
	scriptTable.projectile_firer_id = projectile.firer.id or -1
	scriptTable.projectile_target_id = opponent.id or -1
	scriptTable.projectile_firer_location = myIO.locationString(projectile.origin_pos)
	scriptTable.projectile_target_location = myIO.locationString(projectile.target_pos)
	
	for i,x in pairs(triggerTable.Scripts) do
		local script = x.Script
		local chance = x.Chance
		if myMath.roll(chance) then
			dfhack.run_command(myIO.gsub_script(script,scriptTable))
		end
	end
end

function onEquip(Table, item, unit, mode)
	itemTrigger(Table, item, unit, nil, nil)
end

function onWound(Table, item, attacker, defender, wound)
	itemTrigger(Table, item, attacker, defender, nil)
end

function onAction(Table, item, unit_id, target_id, action)
	itemTrigger(Table, item, df.unit.find(unit_id), df.unit.find(target_id), nil)
end

function onProjectile(Table, item, projectile)
	local firer = projectile.firer
	if not firer then return end
	itemTrigger(Table, item, firer, nil, projectile)
end