--combination of projectile-trigger by expwnent and putnam-expansion by Putnam
--expanded by Roses (Pheosics)

local eventful = require 'plugins.eventful'
local utils = require 'utils'

hitTriggers   = hitTriggers   or {}
moveTriggers  = moveTriggers  or {}
firedTriggers = firedTriggers or {}
onFired=onFired or dfhack.event.new()
number_of_projectiles=number_of_projectiles or df.global.proj_next_id

--==========================================================================================================================
validArgs = utils.invert({
 'clear',
 'help',
 'type',
 'command',
 'item',
 'material',
 'contaminant',
 'remove',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[scripts/trigger/projectile usage
arguments:
    -help
        print this help message
    -clear
        clear all registered triggers
    -type
        trigger the command when this action takes place
        valid values:
            Move
            Hit
            Fired
    -item type
        trigger the command for items of this type
        examples:
            ITEM_AMMO_BOLT
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
    -remove
        If present will remove the projectile
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
 hitTriggers   = {}
 moveTriggers  = {}
 firedTriggers = {}
 onFired = nil
 eventful.onProjItemCheckImpact.hit = function(a) return end
 eventful.onProjItemCheckMovement.move
 require('repeat-util').cancel('onFired')
 return
end

if not args.command then
 error 'specify a command'
end


if args.type == 'Hit' then
 id = #hitTriggers + 1
 hitTriggers[id] = {}
 trigger = hitTriggers[id]
elseif args.type == 'Move' then
 id = #moveTriggers + 1
 moveTriggers[id] = {}
 trigger = moveTriggers[id]
elseif args.type == 'Fired' then
 id = #firedTriggers + 1
 firedTriggers[id] = {}
 trigger = firedTriggers[id]
else
 error 'specify an action type'
end

trigger.command = args.command
if args.item then trigger.item = args.item end
if args.material then trigger.material = args.material end
if args.contaminant then trigger.contaminant = args.contaminant end
if args.remove then trigger.remove = true

--==========================================================================================================================
function checkForFired() -- This is a custom function based off of putnam-events function checkForActions
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
  onFired(item)
 end
 number_of_projectiles = new_projectile_id
end

function enableEvent(event,ticks)
 ticks=ticks or 1
 require('repeat-util').scheduleUnlessAlreadyScheduled(event.name,ticks,'ticks',event.func)
end

eventTypes={
    ON_FIRED={name='onFired',func=checkForFired},
}

local function posIsEqual(pos1,pos2) -- Taken from Putnam's projectile_expansion
 if pos1.x ~= pos2.x or pos1.y ~= pos2.y or pos1.z ~= pos2.z then return false end
 return true
end

local function getUnitHitByProjectile(projectile) -- Taken from Putnam's projectile_expansion
 for uid,unit in ipairs(df.global.world.units.active) do
  if posIsEqual(unit.pos,projectile.cur_pos) then return unit end
 end
 return nil
end

--==========================================================================================================================
-- HANDLE AND PROCESS TRIGGERS =============================================================================================
--==========================================================================================================================
local function handler(intable,triggers)
 proj = intable.projectile
 item = proj.item
 local matStr = dfhack.matinfo.decode(item):getToken()
 local itemStr = dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id
 local conStr = {}
 if item.contaminants then
  for i,contaminant in ipairs(item.contaminants) do
   contaminantStr[i] = dfhack.matinfo.decode(contaminant.mat_type,contaminant.mat_index):getToken()
  end
 end

 for _,trigger in ipairs(triggers) do
  fire = true

  -- Check for item triggers
  if trigger.item and fire then
   check = false
   for i,iStr in ipairs(itemStr) do
    if iStr == trigger.item then
     check = true
     break
    end
   end
   if not check then fire = false end
  end

  -- Check for material triggers
  if trigger.material and fire then
   check = false
   for i,mStr in ipairs(matStr) do
    if mStr == trigger.material then
     check = true
     break
    end
   end
   if not check then fire = false end
  end

  -- Check for contaminant triggers
  nContaminant = -1
  if trigger.contaminant and fire then
   check = false
   for i,cStr in ipairs(conStr) do
    if cStr == trigger.contaminant then
     check = true
     nContaminant = i
     break
    end
   end
   if not check then fire = false end
  end

  if fire then
   intable.itemStr = itemStr
   intable.materialStr = matStr
   if trigger.contaminant then intable.contaminantStr = contaminantStr[nContaminant] end
   -- Process projectile to get information
   intable.curPos = projectile.cur_pos
   intable.prevPos = projectile.prev_pos
   intable.item = projectile.item
   intable.source = projectile.firer
   intable.target = getUnitHitByProjectile(proj)
   -- Process the command trigger
   processTrigger(trigger,intable)
   -- Follow up triggers
   if trigger.remove then dfhack.items.remove(item) end
  end
 end
end

function processTrigger(trigger,intable)
 local command = trigger.command
 local command2 = {}
  for i,arg in ipairs(command) do
  if arg == 'FIRER_ID' or arg == 'UNIT_ID' then
   command2[i] = '' .. intable.source.id
  elseif arg == 'TARGET_ID' or arg == 'HIT_UNIT_ID' then
   if intable.target then
    command2[i] = '' .. intable.target.id
   else
    command2[i] = '-1'
   end
  elseif arg == 'ITEM_MATERIAL' and intable.materialStr then
   command2[i] = '' .. intable.materialStr
  elseif arg == 'ITEM_TOKEN' and intable.itemStr then
   command2[i] = '' .. intable.itemStr
  elseif arg == 'CONTAMINANT_MATERIAL' and intable.contaminantStr then
   command2[i] = '' .. intable.contaminantStr
  elseif arg == 'ITEM_ID' and intable.item then
   command2[i] = '' .. intable.item.id
  elseif arg == 'PROJECTILE_ID' then
   command2[i] = '' .. intable.projectile.id
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
eventful.onUnload.projectileTrigger = function()
 hitTriggers   = {}
 moveTriggers  = {}
 firedTriggers = {}
 onFired = nil
end

eventful.onProjItemCheckImpact.hit = function(projectile)
 local table = {}
 table.projectile = projectile
 handler(table,hitTriggers)
end

eventful.onProjItemCheckMovement.move=function(projectile)
 local table = {}
 table.projectile = projectile
 handler(table,moveTriggers)
end

-- Eventful function for when a unit shoots a projectile
onFired.fired=function(projectile)
 if not projectile then print('Something weird happened! ',unit_id,action) return false end
 local table = {}
 table.projectile = projectile
 handler(table,firedTriggers)
end

--==========================================================================================================================
-- Enable event checking
enableEvent(eventTypes.ON_FIRED,1)
eventful.enableEvent(eventful.eventType.UNLOAD,1)
