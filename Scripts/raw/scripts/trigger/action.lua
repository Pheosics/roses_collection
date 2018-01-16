--combination of item-trigger by expwnent and putnam-events by Putnam
--expanded by Roses (Pheosics)

local eventful = require 'plugins.eventful'
local utils = require 'utils'

attackTriggers  = attackTriggers  or {}
blockTriggers   = blockTriggers   or {}
dodgeTriggers   = dodgeTriggers   or {}
equipTriggers   = equipTriggers   or {}
moveTriggers    = moveTriggers    or {}
parryTriggers   = parryTriggers   or {}
unequipTriggers = unequipTriggers or {}
woundTriggers   = woundTriggers   or {}

--==========================================================================================================================
validArgs = validArgs or utils.invert({
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
            Block
            Dodge
            Equip
            Move
            Parry
            Unequip
            Wound
    -item type
        trigger the command for items of this type
        examples:
            WEAPON:ITEM_WEAPON_PICK
    -material mat
        trigger the commmand on items with the given material
        examples
            INORGANIC:IRON
            CREATURE_MAT:DWARF:BRAIN
            PLANT_MAT:MUSHROOM_HELMET_PLUMP:DRINK
    -contaminant mat
        trigger the command on items with a given material contaminant
        examples
            INORGANIC:IRON
            CREATURE_MAT:DWARF:BRAIN
            PLANT_MAT:MUSHROOM_HELMET_PLUMP:DRINK
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
            \\UNIT_ID
            \\ATTACKER_ID
            \\BLOCKER_ID
            \\PARRIER_ID
            \\DEFENDER_ID
            \\BLOCKED_UNIT_ID
            \\PARRIED_UNIT_ID
            \\ITEM_MATERIAL
            \\ITEM_TOKEN
            \\ITEM_ID
            \\CONTAMINANT_MATERIAL
            anything -> anything
]])
 return
end

if args.clear then
 attackTriggers  = {}
 blockTriggers   = {}
 dodgeTriggers   = {}
 equipTriggers   = {}
 parryTriggers   = {}
 unequipTriggers = {}
 woundTriggers   = {}
end

if not args.command then
 if not args.clear then
  error 'specify a command'
 end
 return
end

if args.actionType == 'Attack' then
 triggers = attackTriggers
elseif args.actionType == 'Block' then
 triggers = blockTriggers
elseif args.actionType == 'Dodge' then
 triggers = dodgeTriggers
elseif args.actionType == 'Equip' then
 triggers = equipTriggers
elseif args.actionType == 'Move' then
 triggers = moveTriggers
elseif args.actionType == 'Parry' then
 triggers = parryTriggers
elseif args.actionType == 'Unequip' then
 triggers = unequipTriggers
elseif args.actionType == 'Wound' then
 triggers = woundTriggers
else
 error 'specify an action type'
end

id = #triggers+1
triggers[id] = {}
triggers[id].command = args.command
if args.item then
 triggers[id].item = args.item
end
if args.material then
 triggers[id].material = args.material
end
if args.contaminant then
 triggers[id].contaminant = args.contaminant
end
if args.creature then
 triggers[id].creature = args.creature
end
if args.attack then
 triggers[id].attack = args.attack
end
--==========================================================================================================================

--==========================================================================================================================
-- Need to create an onUnitAction event since there is not a built in one (this is taken from putnam-events)
onUnitAction=onUnitAction or dfhack.event.new()
local actions_already_checked=actions_already_checked or {}
things_to_do_every_action=things_to_do_every_action or {}
actions_to_be_ignored_forever=actions_to_be_ignored_forever or {}

local function checkForActions()
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
       something_to_do_to_every_action[1](unit_id,action,table.unpack(something_to_do_to_every_action[2]))
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

function doSomethingToEveryActionNextTick(unit_id,action_id,func,func_args) --func is thing to do, unit_id and action_id represent the action that gave the "order"
 actions_to_be_ignored_forever[unit_id]=actions_to_be_ignored_forever[unit_id] or {}
 if not actions_to_be_ignored_forever[unit_id][action_id] then
  table.insert(things_to_do_every_action,{func,func_args,unit_id,action_id,0})
 end
 actions_to_be_ignored_forever[unit_id][action_id]=true
end

function enableEvent(event,ticks)
 ticks=ticks or 1
 require('repeat-util').scheduleUnlessAlreadyScheduled(event.name,ticks,'ticks',event.func)
end

eventTypes={
    ON_ACTION={name='onAction',func=checkForActions},
}
--==========================================================================================================================

--==========================================================================================================================
-- HANDLE AND PROCESS TRIGGERS =============================================================================================
--==========================================================================================================================
function handler(unit_id,table,triggers)
 -- Get CREATURE:CASTE combo
 local unit = df.unit.find(unit_id)
 local racename = df.creature_raw.find(unit.race).creature_id
 local castename = unitraws.caste[unit.caste].caste_id
 -- Get ITEM_TYPE:ITEM_SUBTYPE and MAT_TYPE:MAT_SUBTYPE combos
 itemStr = {}
 materialStr = {}
 contaminantStr = {}
 if table.item then -- If an item is used for the action, then use that item
  itemStr = {dfhack.items.getSubtypeDef(table.item:getType(),table.item:getSubtype()).id}
  materialStr = {dfhack.matinfo.decode(table.item.mat_type,table.item.mat_index):getToken()}
  for i,contaminant in ipairs(table.item.contaminants) do
   contaminantStr[i] = dfhack.matinfo.decode(contaminant.mat_type,contaminant.mat_index):getToken()
  end
 elseif table.inventory then -- If there is no item used for the action, check the units inventory instead
  for _,invItem in ipairs(unit.inventory) do
   if invItem.mode == df.unit_inventory_item.T_mode['Worn'] or invItem.mode = df.unit_inventory_item.T_mode['Weapon'] then
    itemStr[#itemStr+1] = dfhack.items.getSubtypeDef(invItem.item:getType(),invItem.item:getSubtype()).id
    materialStr[#materialStr+1] = dfhack.matinfo.decode(invItem.item.mat_type,invItem.item.mat_index):getToken()
    for j,contaminant in ipairs(invItem.item.contaminants) do
     contaminantStr[#contaminantStr+1] = dfhack.matinfo.decode(contaminant.mat_type,contaminant.mat_index):getToken()
    end
   end
  end
 end

 for _,trigger in ipairs(triggers) do
  -- Check for a -creature trigger
  if trigger.creature then
   if racename..':'..castename ~= trigger.creature and racename..':ALL' ~= trigger.creature then break end
  end

  -- Check for an -item trigger
  nItem = -1
  if trigger.item then
   check = false
   for i,iStr in ipairs(itemStr) do
    if itemStr == trigger.item then
     check = true
     nItem = i
     break
    end
   end
   if not check then break end
  end

  -- Check for a -material trigger
  nMaterial = -1
  if trigger.material then
   check = false
   for i,mStr in ipairs(materialStr) do
    if materialStr == trigger.material then
     check = true
     nMaterial = i
     break
    end
   end
   if not check then break end
  end

  -- Check for a -contaminant trigger
  nContaminant = -1
  if trigger.contaminant then
   check = false
   for i,cStr in ipairs(contaminantStr) do
    if contaminantStr == trigger.contaminant then
     check = true
     nContaminant = i
     break
    end
   end
   if not check then break end
  end

  -- Check for an -attack trigger
  if trigger.attack and table.attack then
   if trigger.attack ~= table.attack then break end
  end

  -- All checks passed, trigger
  table.source = unit
  if nItem then table.itemStr = itemStr[nItem] end
  if nMaterial then table.materialStr = materialStr[nMaterial] end
  if nContaminant then table.contaminantStr = contaminantStr[nContaminant] end
  processTrigger(trigger,table)
 end
end

function processTrigger(trigger,table)
 local command = trigger.command
 local command2 = {}
  for i,arg in ipairs(command) do
  if arg == '\\ATTACKER_ID' then
   command2[i] = '' .. table.source.id
  elseif arg == '\\UNIT_ID' then
   command2[i] = '' .. table.source.id
  elseif arg == '\\BLOCKER_ID' then
   command2[i] = '' .. table.source.id
  elseif arg == '\\PARRIER_ID' then
   command2[i] = '' .. table.source.id
  elseif arg == '\\DEFENDER_ID' then
   command2[i] = '' .. table.target.id
  elseif arg == '\\BLOCKED_UNIT_ID' then
   command2[i] = '' .. table.target.id
  elseif arg == '\\PARRIED_UNIT_ID' then
   command2[i] = '' .. table.target.id
  elseif arg == '\\ITEM_MATERIAL' and table.materialStr then
   command2[i] = '' .. table.materialStr
  elseif arg == '\\ITEM_TOKEN' and table.itemStr then
   command2[i] = '' .. table.itemStr
  elseif arg == '\\CONTAMINANT_MATERIAL' and table.contaminantStr then
   command2[i] = '' .. table.contaminantStr
  elseif arg == '\\ITEM_ID' and table.item then
   command2[i] = '' .. table.item.id
  elseif arg == '\\ATTACK_VELOCITY' then
   command2[i] = '' .. table.velocity
  elseif arg == '\\ATTACK_ACCURACY' then
   command2[i] = '' .. table.accuracy
  elseif arg == '\\ATTACK_TYPE' then
   command2[i] = '' .. table.attack
  elseif arg == '\\TARGET_BODY_PART_ID' then
   command2[i] == '' .. table.targetBodyPart
  elseif arg == '\\WOUND_ID' then
   command2[i] == '' .. table.wound.id
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
 blockTriggers   = {}
 dodgeTriggers   = {}
 equipTriggers   = {}
 parryTriggers   = {}
 unequipTriggers = {}
 woundTriggers   = {}
end

-- Eventful function for when a unit's inventory changes
eventful.onInventoryChange.equipmentTrigger = function(unit, item, item_old, item_new)
 if item_old and item_new then
  return
 end

 local isEquip = item_new and not item_old
 local table = {}
 table.item = item
 if isEquip then 
  table.triggerType = 'Equip'
  handler(unit,table,equipTriggers)
 else
  table.triggertype = 'Unequip'
  handler(unit,table,unequipTriggers)
 end
end

-- Eventful function for when a unit is wounded
eventful.onUnitAttack.attackTrigger = function(attacker,defender,wound)
 attacker = df.unit.find(attacker)
 defender = df.unit.find(defender)

 if not attacker then
  return
 end

 local table
 table.target = defender
 table.wound = wound
 table.triggerType = 'Wound'
 handler(attacker.id,table,woundTriggers)
end

-- Eventful function for when a unit attacks
eventTypes.onUnitAction.attack=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Attack then
  local table = {}
  table.target = df.unit.find(action.data.attack.target_unid_id)
  table.velocity = action.data.attack.attack_velocity
  table.accuracy = action.data.attack.attack_accuracy
  table.targetBodyPart = action.data.attack.target_body_part_id
  if action.data.attack.attack_item_id then
   table.item = df.item.find(action.data.attack.attack_item_id)
   table.attack = table.item.subtype.attacks[action.data.attack.attack_id].noun
  elseif action.data.attack.attack_body_part_id then
   table.item = nil
   table.attack = df.unit.find(unit_id).body.body_plan.attacks[action.data.attack.attack_id].name
  end
  table.triggerType = 'Attack'
  handler(unit_id,table,attackTriggers)
 end
end

-- Eventful function for when a unit blocks
eventTypes.onUnitAction.block=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Block then
  local table = {}
  --table.target = ???
  table.item = df.item.find(action.data.block.block_item_id)
  table.triggerType = 'Block'
  handler(unit_id,table,blockTriggers)
 end
end

-- Eventful function for when a unit parries
eventTypes.onUnitAction.parry=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Parry then
  local table = {}
  --table.target = ???
  table.item = df.item.find(action.data.parry.parry_item_id)
  table.triggerType = 'Parry'
  handler(unit_id,table,parryTriggers)
 end
end

-- Eventful function for when a unit dodges
eventTypes.onUnitAction.dodge=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Dodge then
  local table = {}
  table.inventory = true
  table.start = {action.data.dodge.x1, action.data.dodge.y1, action.data.dodge.z1}
  table.ends  = {action.data.dodge.x2, action.data.dodge.y2, action.data.dodge.z2}
  table.triggerType = 'Dodge'
  handler(unit_id,table,dodgeTriggers)
 end
end

-- Eventful function for when a unit moves
eventTypes.onUnitAction.move=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Move then
  local table = {}
  table.inventory = true
  table.start = {action.data.move.x, action.data.move.y, action.data.move.z}
  local unit = df.unit.find(unit_id)
  table.ends  = {unit.pos.x, unit.pos.y, unit.pos.z}
  table.triggerType = 'Move'
  handler(unit_id,table,moveTriggers)
 end
end

--==========================================================================================================================

-- Enable event checking
eventful.enableEvent(eventful.eventType.UNIT_ATTACK,1) -- this event type is cheap, so checking every tick is fine
eventful.enableEvent(eventful.eventType.INVENTORY_CHANGE,5) --this is expensive, but you might still want to set it lower
eventful.enableEvent(eventful.eventType.UNLOAD,1)
enableEvent(eventTypes.ON_ACTION,1)
