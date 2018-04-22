--combination of item-trigger by expwnent and putnam-events by Putnam
--expanded by Roses (Pheosics)

local eventful = require 'plugins.eventful'
local utils = require 'utils'

hitTriggers   = hitTriggers   or {}
moveTriggers  = moveTriggers  or {}
firedTriggers = firedTriggers or {}

--==========================================================================================================================
validArgs = validArgs or utils.invert({
 'clear',
 'help',
 'type',
 'command',
 'item',
 'material',
 'contaminant',
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
 return
end

if not args.command then
 error 'specify a command'
end


if args.type == 'Hit' then
elseif args.type == 'Move' then
elseif args.type == 'Fired' then
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
--==========================================================================================================================

--==========================================================================================================================
-- HANDLE AND PROCESS TRIGGERS =============================================================================================
--==========================================================================================================================
local function handler(unit_id,intable,triggers)
end

function processTrigger(trigger,intable)
 local command = trigger.command
 local command2 = {}
  for i,arg in ipairs(command) do
  if arg == 'ATTACKER_ID' then
   command2[i] = '' .. intable.source.id
  elseif arg == 'UNIT_ID' then
   command2[i] = '' .. intable.source.id
  elseif arg == 'DEFENDER_ID' then
   command2[i] = '' .. intable.target.id
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
end

--==========================================================================================================================

-- Enable event checking
eventful.enableEvent(eventful.eventType.UNLOAD,1)