--combination of item-trigger by expwnent and putnam-events by Putnam
--expanded by Roses (Pheosics)

local eventful = require 'plugins.eventful'
local utils = require 'utils'

attackTriggers  = attackTriggers  or {}
shootTriggers   = shootTriggers   or {}
blockTriggers   = blockTriggers   or {}
dodgeTriggers   = dodgeTriggers   or {}
equipTriggers   = equipTriggers   or {}
moveTriggers    = moveTriggers    or {}
parryTriggers   = parryTriggers   or {}
unequipTriggers = unequipTriggers or {}
woundTriggers   = woundTriggers   or {}
reportTriggers  = reportTriggers  or {}

onUnitAction=onUnitAction or dfhack.event.new()
onShoot=onShoot or dfhack.event.new()
local actions_already_checked=actions_already_checked or {}
things_to_do_every_action=things_to_do_every_action or {}
actions_to_be_ignored_forever=actions_to_be_ignored_forever or {}
number_of_projectiles=number_of_projectiles or df.global.proj_next_id

--==========================================================================================================================
validArgs = utils.invert({
 'clear',
 'help',
 'actionType',
 'command',
 'item',
 'material',
 'contaminant',
 'creature',
 'attack',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[scripts/modtools/item-trigger.lua usage
arguments:
    -help
        print this help message
    -clear
        clear all registered triggers
    -actionType
        trigger the command when this action takes place
        valid values:
            Attack
            Shoot
            Block
            Dodge
            Equip
            Move
            Parry
            Unequip
            Wound
            ANNOUNCEMENT_TYPE (e.g. COMBAT_JUMP_DODGE_PROJ, COMBAT_COUNTERSTRIKE)
    -item type
        trigger the command for items of this type
        examples:
            ITEM_WEAPON_PICK
    -material mat
        trigger the commmand on items with the given material
        examples
            INORGANIC:IRON
            CREATURE:DWARF:BRAIN
            PLANT:MUSHROOM_HELMET_PLUMP:DRINK
    -contaminant mat
        trigger the command on items with a given material contaminant
        examples
            INORGANIC:IRON
            CREATURE:DWARF:BRAIN
            PLANT:MUSHROOM_HELMET_PLUMP:DRINK
    -creature creature
        trigger the command on creature performing the action
        examples:
            DWARF:ALL
            ELF:FEMALE
    -attack type
        trigger the command when a certain attack is performed
        obviously only works for the attack actionType
    -command [ commandStrs ]
        specify the command to be executed
        commandStrs
            UNIT_ID
            ATTACKER_ID
            BLOCKER_ID
            PARRIER_ID
            DEFENDER_ID
            BLOCKED_UNIT_ID
            PARRIED_UNIT_ID
            ITEM_MATERIAL
            ITEM_TOKEN
            ITEM_ID
            CONTAMINANT_MATERIAL
            anything -> anything
]])
 return
end

if args.clear then
 attackTriggers  = {}
 shootTriggers   = {}
 blockTriggers   = {}
 dodgeTriggers   = {}
 equipTriggers   = {}
 parryTriggers   = {}
 unequipTriggers = {}
 woundTriggers   = {}
 reportTriggers  = {}
 onUnitAction = nil
 onShoot = nil
 things_to_do_every_action = {}
 actions_to_be_ignored_forever = {}
 eventful.onInventoryChange.equipmentTrigger = function (a,b,c,d) return end
 eventful.onUnitAttack.attackTrigger = function(a,b,c) return end
 require('repeat-util').cancel('onAction')
 require('repeat-util').cancel('onShoot')
 return
end

if not args.command then
 error 'specify a command'
end


if args.actionType == 'Attack' then
 id = #attackTriggers + 1
 attackTriggers[id] = {}
 trigger = attackTriggers[id]
elseif args.actionType == 'Shoot' then
 id = #shootTriggers + 1
 shootTriggers[id] = {}
 trigger = shootTriggers[id]
elseif args.actionType == 'Block' then
 id = #blockTriggers + 1
 blockTriggers[id] = {}
 trigger = blockTriggers[id]
elseif args.actionType == 'Dodge' then
 error('Dodge triggers do not work correctly, use COMBAT_JUMP_DODGE_PROJ')
 --dodgeTriggers = dodgeTriggers or {}
 --id = #dodgeTriggers + 1
 --dodgeTriggers[id] = {}
 --trigger = dodgeTriggers[id]
elseif args.actionType == 'Equip' then
 id = #equipTriggers + 1
 equipTriggers[id] = {}
 trigger = equipTriggers[id]
elseif args.actionType == 'Move' then
 id = #moveTriggers + 1
 moveTriggers[id] = {}
 trigger = moveTriggers[id]
elseif args.actionType == 'Parry' then
 id = #parryTriggers + 1
 parryTriggers[id] = {}
 trigger = parryTriggers[id]
elseif args.actionType == 'Unequip' then
 id = #unequipTriggers + 1
 unequipTriggers[id] = {}
 trigger = unequipTriggers[id]
elseif args.actionType == 'Wound' then
 id = #woundTriggers + 1
 woundTriggers[id] = {}
 trigger = woundTriggers[id]
elseif df.announcement_type[args.actionType] then
 reportTriggers[args.actionType] = reportTriggers[args.actionType] or {}
 id = #reportTriggers[args.actionType] + 1
 trigger = reportTriggers[args.actionType][id]
else
 error 'specify an action type'
end

trigger.command = args.command
if args.item then
 trigger.item = args.item
end
if args.material then
 trigger.material = args.material
end
if args.contaminant then
 trigger.contaminant = args.contaminant
end
if args.creature then
 trigger.creature = args.creature
end
if args.attack then
 trigger.attack = args.attack
end 
 
--==========================================================================================================================
function checkForShot() -- This is a custom function based off of putnam-events function checkForActions
 old_projectile_id = number_of_projectiles
 new_projectile_id = df.global.proj_next_id
 if old_projectile_id == new_projectile_id then return end
 diff_projectile_id = new_projectile_id - old_projectile_id
 i = 0
 items = {}
 while i < diff_projectile_id do
  found = false
  projectile = df.global.world.proj_list
  while not found do
   projectile = projectile.next
   if projectile then
    if projectile.item.id == old_projectile_id + i then
	 items[i+1] = projectile.item
	 found = true
	end
   else
    items[i+1] = nil
	found = true
   end
  end
  i = i + 1
 end
 for j,item in ipairs(items) do
  onShoot(item)
 end
 number_of_projectiles = new_projectile_id
end

--==========================================================================================================================
-- Need to create an onUnitAction event since there is not a built in one (this is taken from putnam-events)
function checkForActions()
 for _,something_to_do_to_every_action in pairs(things_to_do_every_action) do
  something_to_do_to_every_action[5]=something_to_do_to_every_action[5]+1 or 0
 end
 for k,unit in ipairs(df.global.world.units.active) do
  local unit_id=unit.id
  actions_already_checked[unit_id]=actions_already_checked[unit_id] or {}
  local unit_action_checked=actions_already_checked[unit_id]
  for _,action in ipairs(unit.actions) do
   local action_id=action.id
   if action.type~=-1 then
    for kk,something_to_do_to_every_action in pairs(things_to_do_every_action) do
     if something_to_do_to_every_action[1] then 
      if something_to_do_to_every_action[5]>1 or (unit_id==something_to_do_to_every_action[3] and action_id==something_to_do_to_every_action[4]) then
       things_to_do_every_action[kk]=nil
      else
       something_to_do_to_every_action[1](unit_id,action,intable.unpack(something_to_do_to_every_action[2]))
      end
     end
    end
    if not unit_action_checked[action_id] then
     onUnitAction(unit_id,action)
     unit_action_checked[action_id]=true
    end
   end
  end
 end
end

--==========================================================================================================================
function enableEvent(event,ticks)
 ticks=ticks or 1
 require('repeat-util').scheduleUnlessAlreadyScheduled(event.name,ticks,'ticks',event.func)
end

--==========================================================================================================================

--==========================================================================================================================
-- HANDLE AND PROCESS TRIGGERS =============================================================================================
--==========================================================================================================================
local function handler(unit_id,intable,triggers)
 -- Get CREATURE:CASTE combo
 local unit = df.unit.find(unit_id)
 local racename = df.creature_raw.find(unit.race).creature_id
 local castename = df.creature_raw.find(unit.race).caste[unit.caste].caste_id
 -- Get ITEM_TYPE:ITEM_SUBTYPE and MAT_TYPE:MAT_SUBTYPE combos
 itemStr = {}
 materialStr = {}
 contaminantStr = {}
 if intable.item then -- If an item is used for the action, then use that item
  item = intable.item
  itemStr = {dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id}
  materialStr = {dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()}
  if item.contaminants then
   for i,contaminant in ipairs(item.contaminants) do
    contaminantStr[i] = dfhack.matinfo.decode(contaminant.mat_type,contaminant.mat_index):getToken()
   end
  end
 elseif intable.inventory then -- If there is no item used for the action, check the units inventory instead
  for _,invItem in ipairs(unit.inventory) do
   if invItem.mode == df.unit_inventory_item.T_mode['Worn'] or invItem.mode == df.unit_inventory_item.T_mode['Weapon'] then
    itemStr[#itemStr+1] = dfhack.items.getSubtypeDef(invItem.item:getType(),invItem.item:getSubtype()).id
    materialStr[#materialStr+1] = dfhack.matinfo.decode(invItem.item.mat_type,invItem.item.mat_index):getToken()
	if invItem.item.contaminants then
     for j,contaminant in ipairs(invItem.item.contaminants) do
      contaminantStr[#contaminantStr+1] = dfhack.matinfo.decode(contaminant.mat_type,contaminant.mat_index):getToken()
     end
	end
   end
  end
 end

 for _,trigger in ipairs(triggers) do
  fire = true
  -- Check for a -creature trigger
  if trigger.creature and fire then
   if racename..':'..castename ~= trigger.creature and racename..':ALL' ~= trigger.creature then fire = false end
  end

  -- Check for an -item trigger
  nItem = -1
  if trigger.item and fire then
   check = false
   for i,iStr in ipairs(itemStr) do
    if iStr == trigger.item then
     check = true
     nItem = i
     break
    end
   end
   if not check then fire = false end
  end

  -- Check for a -material trigger
  nMaterial = -1
  if trigger.material and fire then
   check = false
   for i,mStr in ipairs(materialStr) do
    if mStr == trigger.material then
     check = true
     nMaterial = i
     break
    end
   end
   if not check then fire = false end
  end

  -- Check for a -contaminant trigger
  nContaminant = -1
  if trigger.contaminant and fire then
   check = false
   for i,cStr in ipairs(contaminantStr) do
    if cStr == trigger.contaminant then
     check = true
     nContaminant = i
     break
    end
   end
   if not check then fire = false end
  end

  -- Check for an -attack trigger
  if trigger.attack and intable.attack and fire then
   if trigger.attack ~= intable.attack then fire = false end
  end

  -- All checks passed, trigger
  if fire then
   intable.source = unit
   if nItem then intable.itemStr = itemStr[nItem] end
   if nMaterial then intable.materialStr = materialStr[nMaterial] end
   if nContaminant then intable.contaminantStr = contaminantStr[nContaminant] end
   processTrigger(trigger,intable)
  end
 end
end

function processTrigger(trigger,intable)
 local command = trigger.command
 local command2 = {}
  for i,arg in ipairs(command) do
  if arg == 'ATTACKER_ID' then
   command2[i] = '' .. intable.source.id
  elseif arg == 'UNIT_ID' then
   command2[i] = 'Unit ID' .. intable.source.id
  elseif arg == 'BLOCKER_ID' then
   command2[i] = '' .. intable.source.id
  elseif arg == 'PARRIER_ID' then
   command2[i] = '' .. intable.source.id
  elseif arg == 'DEFENDER_ID' then
   command2[i] = '' .. intable.target.id
  elseif arg == 'BLOCKED_UNIT_ID' then
   command2[i] = 'NOT_YET_IMPLEMENTED'--'' .. intable.target.id
  elseif arg == 'PARRIED_UNIT_ID' then
   command2[i] = 'NOT_YET_IMPLEMENTED'--'' .. intable.target.id
  elseif arg == 'ITEM_MATERIAL' and intable.materialStr then
   command2[i] = '' .. intable.materialStr
  elseif arg == 'ITEM_TOKEN' and intable.itemStr then
   command2[i] = '' .. intable.itemStr
  elseif arg == 'CONTAMINANT_MATERIAL' and intable.contaminantStr then
   command2[i] = '' .. intable.contaminantStr
  elseif arg == 'ITEM_ID' and intable.item then
   command2[i] = 'Item ID' .. intable.item.id
  elseif arg == 'ATTACK_VELOCITY' then
   command2[i] = '' .. intable.velocity
  elseif arg == 'ATTACK_ACCURACY' then
   command2[i] = '' .. intable.accuracy
  elseif arg == 'ATTACK_TYPE' then
   command2[i] = '' .. intable.attack
  elseif arg == 'TARGET_BODY_PART_ID' then
   command2[i] = '' .. intable.targetBodyPart
  elseif arg == 'WOUND_ID' then
   command2[i] = '' .. intable.wound.id
  elseif arg == 'PROJECTILE_ID' then
   command2[i] = 'Projectile ID' .. intable.projectile.id
  elseif arg == 'PROJECTILE_ITEM_ID' then
   command2[i] = 'Projectile Item ID' .. intable.projItem.id
  else
   command2[i] = arg
  end
 end
 dfhack.run_command(table.unpack(command2))
end
--==========================================================================================================================

--==========================================================================================================================
-- EVENTFUL FUNCTIONS ======================================================================================================
--==========================================================================================================================
-- Eventful function for when the game is unloaded
eventful.onUnload.actionTrigger = function()
 attackTriggers  = {}
 shootTriggers   = {}
 blockTriggers   = {}
 dodgeTriggers   = {}
 equipTriggers   = {}
 parryTriggers   = {}
 unequipTriggers = {}
 woundTriggers   = {}
 reportTriggers  = {}
 onUnitAction = nil
 onShoot = nil
 things_to_do_every_action = {}
 actions_to_be_ignored_forever = {}
end

-- Eventful function for when a report is triggered
eventful.onReport.reportActionTrigger = function(reportID)
 report = df.report.find(reportID)
 if not report then return end
 if report.flags.continuation then return end
 reportType = df.announcement_type[report.type]
 if not reportTriggers[reportType] then return end
 print('Report Action Triggers not currently supported.')
 print('Still need to figure out how to get the correct')
 print('unit and location information from just report.')
 --handler(unit_id,intable,reportTriggers[reportType])
end

-- Eventful function for when a unit's inventory changes
eventful.onInventoryChange.equipmentTrigger = function(unit, item, item_old, item_new)
 if item_old and item_new then
  return
 end

 local isEquip = item_new and not item_old
 local intable = {}
 intable.item = df.item.find(item)
 if isEquip then 
  intable.triggerType = 'Equip'
  handler(unit,intable,equipTriggers)
 else
  intable.triggertype = 'Unequip'
  handler(unit,intable,unequipTriggers)
 end
end

-- Eventful function for when a unit is wounded
eventful.onUnitAttack.attackTrigger = function(attacker,defender,wound)
 attacker = df.unit.find(attacker)
 defender = df.unit.find(defender)

 if not attacker then
  return
 end

 local intable = {}
 intable.target = defender
 intable.wound = wound
 intable.triggerType = 'Wound'
 handler(attacker.id,intable,woundTriggers)
end

-- Eventful function for when a unit attacks
onUnitAction.attack=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Attack then
  local intable = {}
  intable.target = df.unit.find(action.data.attack.target_unit_id)
  intable.velocity = action.data.attack.attack_velocity
  intable.accuracy = action.data.attack.attack_accuracy
  intable.targetBodyPart = action.data.attack.target_body_part_id
  if action.data.attack.attack_item_id >= 0 then
   intable.item = df.item.find(action.data.attack.attack_item_id)
   if not intable.item then return end
   if intable.item._type == df.item_shieldst then
    intable.attack = 'strike'
   else
    if action.data.attack.attack_id >= 0 then
     intable.attack = intable.item.subtype.attacks[action.data.attack.attack_id].verb_2nd
	else
	 intable.attack = 'Attack'
	end
   end
  elseif action.data.attack.attack_body_part_id then
   intable.item = nil
   if action.data.attack.attack_id >= 0 then
    intable.attack = df.unit.find(unit_id).body.body_plan.attacks[action.data.attack.attack_id].name
   else
    intable.attack = 'Attack'
   end
  end
  intable.triggerType = 'Attack'
  handler(unit_id,intable,attackTriggers)
 end
end

-- Eventful function for when a unit shoots a projectile
onShoot.shoot=function(projectile)
 if not projectile then print('Something weird happened! ',unit_id,action) return false end
 local intable = {}
 intable.unit = projectile.firer
 intable.item = df.item.find(projectile.bow_id)
 intable.projectile = projectile
 intable.projItem = projectile.item
 handler(intable.unit.id,intable,shootTriggers)
end

-- Eventful function for when a unit blocks
onUnitAction.block=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Block then
  local intable = {}
  --intable.target = ???
  intable.item = df.item.find(action.data.block.block_item_id)
  intable.triggerType = 'Block'
  handler(unit_id,intable,blockTriggers)
 end
end

-- Eventful function for when a unit parries
onUnitAction.parry=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Parry then
  local intable = {}
  --intable.target = ???
  intable.item = df.item.find(action.data.parry.parry_item_id)
  intable.triggerType = 'Parry'
  handler(unit_id,intable,parryTriggers)
 end
end

-- Eventful function for when a unit dodges
onUnitAction.dodge=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Dodge then
  local intable = {}
  intable.inventory = true
  intable.start = {action.data.dodge.x1, action.data.dodge.y1, action.data.dodge.z1}
  intable.ends  = {action.data.dodge.x2, action.data.dodge.y2, action.data.dodge.z2}
  intable.triggerType = 'Dodge'
  handler(unit_id,intable,dodgeTriggers)
 end
end

-- Eventful function for when a unit moves
onUnitAction.move=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Move then
  local intable = {}
  intable.inventory = true
  intable.start = {action.data.move.x, action.data.move.y, action.data.move.z}
  local unit = df.unit.find(unit_id)
  intable.ends  = {unit.pos.x, unit.pos.y, unit.pos.z}
  intable.triggerType = 'Move'
  handler(unit_id,intable,moveTriggers)
 end
end

--==========================================================================================================================
-- Custom event types
eventTypes={
    ON_ACTION={name='onAction',func=checkForActions},
    ON_SHOOT={name='onShoot',func=checkForShot},
}

-- Enable event checking
enableEvent(eventTypes.ON_ACTION,1)
enableEvent(eventTypes.ON_SHOOT,1)
eventful.enableEvent(eventful.eventType.UNIT_ATTACK,1) -- this event type is cheap, so checking every tick is fine
eventful.enableEvent(eventful.eventType.INVENTORY_CHANGE,5) --this is expensive, but you might still want to set it lower
eventful.enableEvent(eventful.eventType.REPORT,1) -- I don't know how expensive this is, setting to 1 to test
eventful.enableEvent(eventful.eventType.UNLOAD,1)
