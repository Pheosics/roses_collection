--combination of item-trigger by expwnent and putnam-events by Putnam
--expanded by Roses (Pheosics)

--triggers scripts when a unit attacks another with a weapon type, a weapon of a particular material, or a weapon contaminated with a particular material, or when a unit equips/unequips a particular item type, an item of a particular material, or an item contaminated with a particular material

local eventful = require 'plugins.eventful'
local utils = require 'utils'

attackTriggers = attackTriggers or {}
blockTriggers  = blockTriggers  or {}
dodgeTriggers  = dodgeTriggers  or {}
equipTriggers  = equipTriggers  or {}
moveTriggers   = moveTriggers   or {}
parryTriggers  = parryTriggers  or {}
woundTriggers  = woundTriggers or {}

-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------

function handler(unit_id,table,triggers)
 -- Get CREATURE:CASTE combo
 local unit = df.unit.find(unit_id)
 local racename = df.creature_raw.find(unit.race).creature_id
 local castename = unitraws.caste[unit.caste].caste_id
 -- Get ITEM_TYPE:ITEM_SUBTYPE and MAT_TYPE:MAT_SUBTYPE combos
 if table.item then -- If an item is used for the action, then use that item
  itemStr = {dfhack.items.getSubtypeDef(table.item:getType(),table.item:getSubtype()).id}
  materialStr = {dfhack.matinfo.decode(table.item.mat_type,table.item.mat_index):getToken()}
  for i,contaminant in ipairs(table.item.contaminants) do
   contaminantStr = contaminantStr or {}
   contaminantStr[i] = dfhack.matinfo.decode(contaminant.mat_type,contaminant.mat_index):getToken()
  end
 else table.inventory -- If there is no item used for the action, check the units inventory instead
  itemStr = {}
  materialStr = {}
  contaminantStr = {}
  for i,invItem in ipairs(unit.inventory) do
   if invItem.mode == df.unit_inventory_item.T_mode['Worn'] or invItem.mode = df.unit_inventory_item.T_mode['Weapon'] then
    itemStr[i] = dfhack.items.getSubtypeDef(invItem.item:getType(),invItem.item:getSubtype()).id
    materialStr[i] = dfhack.matinfo.decode(invItem.item.mat_type,invItem.item.mat_index):getToken()
    for j,contaminant in ipairs(invItem.item.contaminants) do
     contaminantStr[i] = contaminantStr[i] or {}
     contaminantStr[i][j] = dfhack.matinfo.decode(contaminant.mat_type,contaminant.mat_index):getToken()
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
  if trigger.item then

  end


 end
end

function attackHandler(unit_id,action)
 local fire = true
 -- Get CREATURE:CASTE combo
 local unit = df.unit.find(unit_id)
 local racename = df.creature_raw.find(unit.race).creature_id
 local castename = unitraws.caste[unit.caste].caste_id
 -- Get ITEM_TYPE:ITEM_SUBTYPE combo 
 local item = df.item.find(action.data.attack.attack_item_id)
 local itemStr = dfhack.items.getSubtypeDef(table.item:getType(),table.item:getSubtype()).id
 -- Get MAT_TYPE:MAT_SUBTYPE for item material combo
 local materialStr = dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()
 -- Get MAT_TYPE:MAT_SUBTYPE for item contaminant combo
 local contaminants = item.contaminants 
 for _,trigger in ipairs(attackTriggers) do
  -- Check Creature
  -- Check Item
  -- Check Material
  -- Check Contaminant
 end
end

-- Enable event checking
eventful.enableEvent(eventful.eventType.UNIT_ATTACK,1) -- this event type is cheap, so checking every tick is fine
eventful.enableEvent(eventful.eventType.INVENTORY_CHANGE,5) --this is expensive, but you might still want to set it lower
eventful.enableEvent(eventful.eventType.UNLOAD,1)
enableEvent(eventTypes.ON_ACTION,1)

-------------------------------------------------------------------------------
-- Eventful function for when the game is unloaded
eventful.onUnload.actionTrigger = function()
 attackTriggers = {}
 blockTriggers  = {}
 dodgeTriggers  = {}
 equipTriggers  = {}
 parryTriggers  = {}
 strikeTriggers = {}
end

-- Eventful function for when a unit's inventory changes
eventful.onInventoryChange.equipmentTrigger = function(unit, item, item_old, item_new)
 if item_old and item_new then
  return
 end

 local isEquip = item_new and not item_old
 equipHandler(unit,item,isEquip)
end

-- Eventful function for when a unit is wounded
eventful.onUnitAttack.attackTrigger = function(attacker,defender,wound)
 attacker = df.unit.find(attacker)
 defender = df.unit.find(defender)

 if not attacker then
  return
 end

 woundHandler(attacker,defender,wound)
end

-- Eventful function for when a unit attacks
eventTypes.onUnitAction.attack=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Attack then
  attackHandler(unit_id,action)
 end
end

-- Eventful function for when a unit blocks
eventTypes.onUnitAction.attack=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Block then
  blockHandler(unit_id,action)
 end
end

-- Eventful function for when a unit parries
eventTypes.onUnitAction.attack=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Parry then
  parryHandler(unit_id,action)
 end
end

-- Eventful function for when a unit dodges
eventTypes.onUnitAction.attack=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Dodge then
  dodgeHandler(unit_id,action)
 end
end

-- Eventful function for when a unit moves
eventTypes.onUnitAction.attack=function(unit_id,action)
 if not unit_id or not action then print('Something weird happened! ',unit_id,action) return false end
 if action.type==df.unit_action_type.Move then
  moveHandler(unit_id,action)
 end
end
-------------------------------------------------------------------------------

validArgs = validArgs or utils.invert({
 'clear',
 'help',
 'actionType',
 'command',
 'item',
 'material',
 'contaminant',
 'creature',
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
    -command [ commandStrs ]
        specify the command to be executed
        commandStrs
            \\ATTACKER_ID
            \\DEFENDER_ID
            \\ITEM_MATERIAL
            \\ITEM_MATERIAL_TYPE
            \\ITEM_ID
            \\ITEM_TYPE
            \\CONTAMINANT_MATERIAL
            \\CONTAMINANT_MATERIAL_TYPE
            \\CONTAMINANT_MATERIAL_INDEX
            \\MODE
            \\UNIT_ID
            \\anything -> \anything
            anything -> anything
]])
 return
end

if args.clear then
 attackTriggers = {}
 blockTriggers  = {}
 dodgeTriggers  = {}
 equipTriggers  = {}
 parryTriggers  = {}
 woundTriggers  = {}
end

if not args.command then
 if not args.clear then
  error 'specify a command'
 end
 return
end

if args.actionType == 'Attack' then
 id = #attackTriggers+1
 attackTriggers[id] = {}
 trigger = attackTriggers[id]
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
elseif args.actionType == 'Block' then

elseif args.actionType == 'Dodge' then

elseif args.actionType == 'Equip' then

elseif args.actionType == 'Move' then

elseif args.actionType == 'Parry' then

elseif args.actionType == 'Unequip' then

elseif args.actionType == 'Wound' then

else
 error 'specify an action type'
end





















if args.itemType then
 local temp
 for _,itemdef in ipairs(df.global.world.raws.itemdefs.all) do
  if itemdef.id == args.itemType then
   temp = args.itemType --itemdef.subtype
   break
  end
 end
 if not temp then
  error 'Could not find item type.'
 end
 args.itemType = temp
end

local numConditions = (args.material and 1 or 0) + (args.itemType and 1 or 0) + (args.contaminant and 1 or 0)
if numConditions > 1 then
 error 'too many conditions defined: not (yet) supported (pester expwnent if you want it)'
elseif numConditions == 0 then
 error 'specify a material, weaponType, or contaminant'
end

if args.material then
 if not materialTriggers[args.material] then
  materialTriggers[args.material] = {}
 end
 table.insert(materialTriggers[args.material],args)
elseif args.itemType then
 if not itemTriggers[args.itemType] then
  itemTriggers[args.itemType] = {}
 end
 table.insert(itemTriggers[args.itemType],args)
elseif args.contaminant then
 if not contaminantTriggers[args.contaminant] then
  contaminantTriggers[args.contaminant] = {}
 end
 table.insert(contaminantTriggers[args.contaminant],args)
end


