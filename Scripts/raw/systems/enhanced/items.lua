--@ module=true
local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
local repeats = require("repeat-util")
local defitem = reqscript("functions/item")
local defunit = reqscript("functions/unit")
local systemTable = systemTable or {}
local function checkSystemTable(itemID)
	-- Check that the item exists
	local item = defitem(itemID)
	if not item then return nil end
	
	local itemToken = item:getSubtype()
	if not systemTable[itemToken] then return nil end
	
	return item, systemTable[itemToken]
end
local function findInventoryItem(unitID,triggerType)
	local itemID = -1
	unit = defunit(unitID)
	items = unit:getInventoryItems("ALL")
	for _, item in pairs(items) do
		itemToken = item
		if systemTable[itemToken] and systemTable[itemToken][triggerType] then
			itemID = item.id
			break
		end
	end
	return itemID
end

-- Name of the system
Name = "enhancedItems"

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
		equipmentTrigger = function(unit, item, item_old, item_new)
			if item_old and item_new then return end
			local isEquip = item_new and not item_old
			item, Table = checkSystemTable(itemID)
			if not item or not Table.OnEquip then return end
			if isEquip then 
				applyEffects(unitID,Table.OnEquip)
			else
				unapplyEffects(unitID,Table.OnEquip)
			end
		end
	},
	onUnitAttack = {
		attackTrigger = function(attacker,defender,wound)
			attacker = df.unit.find(attacker)
			defender = df.unit.find(defender)
			if not attacker or not defender then return end
		end
	},
	onReport = {
		reportActionTrigger = function(reportID)
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
		attack = function(unit_id, action) -- Event for OnAttack
			if not unit_id or not action then return false end
			if action.type == df.unit_action_type.Attack then
				local item_id = action.data.attack.attack_item_id
				if item_id < 0 then return end
				onAction("OnAttack",unit_id,item_id,action)
			end
		end,
		block = function(unit_id, action) -- Event for OnBlock
			if not unit_id or not action then return false end
			if action.type == df.unit_action_type.Block then
				local item_id = action.data.block.block_item_id
				if item_id < 0 then return end
				onAction("OnBlock",unit_id,item_id,action)
			end
		end,
		parry = function(unit_id, action) -- Event for OnParry
			if not unit_id or not action then return false end
			if action.type == df.unit_action_type.Parry then
				local item_id = action.data.parry.parry_item_id
				if item_id < 0 then return end
				onAction("OnParry",unit_id,item_id,action)
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

-- startSystemTriggers is called on intialization
function startSystemTriggers()
	-- This only needs to be loaded once since it is unchanging during gameplay
	systemTable = dfhack.script_environment("core/tables").Tables[Name]
	if not systemTable then return end
	
	-- Set up triggers
	---- Eventful Triggers
	for k,t in pairs(EventfulFunctions) do -- No idea if this is going to work
		for name,func in pairs(t) do
			eventful[k][name] = function(...) return func(...) end
		end
	end
	for Type,ticks in pairs(EventfulTypes) do
		eventful.enableEvent(eventful.eventType[Type],ticks)
	end
	
	---- Custom Triggers
	for k,t in pairs(CustomFunctions) do -- No idea if this is going to work
		for name,func in pairs(t) do
			eventful[k][name] = function(...) return func(...) end
		end
	end
	for Type,v in pairs(CustomTypes) do
		repeats.scheduleUnlessAlreadyScheduled(Type,v.ticks,"ticks",v.func)
	end
end

local function applyEffects(unitID,triggerTable)
end

local function unapplyEffects(unitID,triggerTable)
end

local function onAction(triggerType,unitID,itemID,action)
	if itemID == "inventory" then itemID = findInventoryItem(unitID,triggerType) end
	item, Table = checkSystemTable(itemID)
	if not item or not Table[triggerType] then return end
	-- Apply changes from Table[triggerType]
end

local function scriptTrigger(itemID, script, frequency)
	if df.item.find(itemID) then
		dfhack.run_command(script)
		dfhack.script_environment("persist-delay").functionDelay(frequency,"enhanced/items","scriptTrigger",{itemID,script,frequency})
	end	
end