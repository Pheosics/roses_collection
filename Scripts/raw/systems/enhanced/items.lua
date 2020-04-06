--@ module=true
-- Plugins
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local myMath = reqscript("functions/math")
local checkSystemTable = reqscript("core/systems").checkSystemTable

-- Name of the system
Name = "enhancedItems"

-- Raw file type to read
RawFileType = "Item"

---- Object function file
ObjFuncFile = "item"

-- List of currently accepted tokens for the system
Tokens = {
	-- Base Tokens
	DESCRIPTION = {Type="Main", Subtype="String",  Name="Description"},
	CLASS       = {Type="Main", Subtype="String", Name="Class"},
	
	-- Trigger Tokens
	ON_EQUIP            = {Type="Sub", Subtype="Set", Name="OnEquip"},
	ON_ATTACK           = {Type="Sub", Subtype="Set", Name="OnAttack"},
	ON_SHOOT            = {Type="Sub", Subtype="Set", Name="OnShoot"},
	ON_PARRY            = {Type="Sub", Subtype="Set", Name="OnParry"},
	ON_BLOCK            = {Type="Sub", Subtype="Set", Name="OnBlock"},
	ON_WOUND            = {Type="Sub", Subtype="Set", Name="OnWound"},
	ON_PROJECTILE_MOVE  = {Type="Sub", Subtype="Set", Name="OnProjectileMove"},
	ON_PROJECTILE_HIT   = {Type="Sub", Subtype="Set", Name="OnProjectileHit"},
	ON_PROJECTILE_FIRED = {Type="Sub", Subtype="Set", Name="OnProjectileFired"},
	
	-- Effect Tokens
	ATTRIBUTE_CHANGE = {Type="Sub", Subtype="NamedTable", Names={Change=3, Chance=4, Duration=5}, Name="Attributes"},
	SKILL_CHANGE     = {Type="Sub", Subtype="NamedTable", Names={Change=3, Chance=4, Duration=5}, Name="Skills"},
	INTERACTION_ADD  = {Type="Sub", Subtype="NamedTable", Names={Chance=3, Duration=4}, Name="Interactions"},
	SYNDROME_ADD     = {Type="Sub", Subtype="NamedTable", Names={Chance=3, Duration=4}, Name="Syndromes"},
	ATTACKER_ATTRIBUTE_CHANGE = {Type="Sub", Subtype="NamedTable", Names={Change=3, Chance=4, Duration=5}, Name="AttackerAttributes"},
	ATTACKER_SKILL_CHANGE     = {Type="Sub", Subtype="NamedTable", Names={Change=3, Chance=4, Duration=5}, Name="AttackerSkills"},
	ATTACKER_INTERACTION_ADD  = {Type="Sub", Subtype="NamedTable", Names={Chance=3, Duration=4}, Name="AttackerInteractions"},
	ATTACKER_SYNDROME_ADD     = {Type="Sub", Subtype="NamedTable", Names={Chance=3, Duration=4}, Name="AttackerSyndromes"},
	DEFENDER_ATTRIBUTE_CHANGE = {Type="Sub", Subtype="NamedTable", Names={Change=3, Chance=4, Duration=5}, Name="DefenderAttributes"},
	DEFENDER_SKILL_CHANGE     = {Type="Sub", Subtype="NamedTable", Names={Change=3, Chance=4, Duration=5}, Name="DefenderSkills"},
	DEFENDER_INTERACTION_ADD  = {Type="Sub", Subtype="NamedTable", Names={Chance=3, Duration=4}, Name="DefenderInteractions"},
	DEFENDER_SYNDROME_ADD     = {Type="Sub", Subtype="NamedTable", Names={Chance=3, Duration=4}, Name="DefenderSyndromes"},
	SCRIPT = {Type="Sub", Subtype="Script", Name="Scripts"},
}

EventfulFunctions = {
	onInventoryChange = {
		equipmentTrigger = function(unitID, itemID, item_old, item_new)
			local unit = df.unit.find(unitID)
			local item = df.item.find(itemID)
			if not unit or not item then return end
			if item_old and item_new then return end
			local isEquip = item_new and not item_old
			if isEquip then 
				onEquip(unit,item)
			else
				onUnequip(unit,item)
			end
		end
	},
	onUnitAttack = {
		attackTrigger = function(attackerID,defenderID,wound)
			local attacker = df.unit.find(attackerID)
			local defender = df.unit.find(defenderID)
			if not attacker or not defender then return end
			onAttack(attacker,defender,wound)
		end
	},
	onProjItemCheckImpact = {
		hit = function(projectile)
		end
	},
	onProjItemCheckMovement = {
		move = function(projectile)
		end
	},
}
EventfulTypes = {
	UNIT_ATTACK = 1,
	INVENTORY_CHANGE = 5,
}
CustomFunctions = {
	onItemAction = {
		action = function(unit_id, action) -- Event for OnAttack
			if not unit_id or not action then return false end
			if action.type == df.unit_action_type.Attack or
				action.type == df.unit_action_type.Block or
				action.type == df.unit_action_type.Parry then
				onAction(unit_id,action)
			end
		end,
	},
	onItemShoot  = {
		shoot = function(projectile)
		end,
		fired = function(projectile)
		end,
	}
}
CustomTypes = {
	onAction = {ticks = 1, func=reqscript("functions/custom-events").checkForActions}
}

-- Custom Triggers
onItemAction = onItemAction or dfhack.event.new()
onShoot = onShoot or dfhack.event.new()

function onEquip(unit, item) end
function onUnequip(unit, item) end
function onAttack(attacker, defender, wound) end
function onAction(unit, action) end