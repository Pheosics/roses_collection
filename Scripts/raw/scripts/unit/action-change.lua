--unit/action-change.lua
local usage = [====[

unit/action-change
==================
Purpose::
	Changes the timer of a given action or interaction

Function Calls::
	unit.changeAction
	unit.changeInteraction
	
Arguments::
	-unit			UNIT_ID
	-action			Action Type
		The type of action to modify
		Valid Values:
			All
			Move
			Attack
	-interaction	Interaction Type or Token
		The type of interaction to modify
		Valid Values:
			All
			Innate
			Learned
			INTERACTION_TOKEN
	-timer			#
		what to set the timer of the action to
		lower values mean the unit will be able to act again sooner
		Special Token:
			clear (erases all actions of the valid action type)
			clearAll (erases all actions regardless of action type)

Examples::
	unit/action-change -unit \\UNIT_ID -action All -timer 200
	unit/action-change -unit 35 -interaction Learned -timer 5000
]====]

local utils = require 'utils'

validArgs = utils.invert({
 'help',
 'unit',
 'timer',
 'action',
 'interaction',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

if args.timer and tonumber(args.timer) then
 timer = tonumber(args.timer)
elseif string.lower(args.timer) == 'clear' then
 timer = 'clear'
elseif string.lower(args.timer) == 'clearall' then
 timer = 'clearAll'
else
 print('No timer set')
 return
end

if args.action == 'All' then
 for i = 0,19 do
  dfhack.script_environment('functions/unit').changeAction(unit,df.unit_action_type[i],timer)
 end
elseif args.action then
 dfhack.script_environment('functions/unit').changeAction(unit,args.action,timer)
end

interaction = string.lower(args.interaction)
if interaction == 'learned' or interaction == 'all' then
 for _,id in pairs(unit.curse.interaction_id) do
  dfhack.script_environment('functions/unit').changeInteraction(unit,id,timer,'Learned')
 end
end

if interaction == 'innate' or interaction == 'all' then
 for _,id in pairs(unit.curse.own_interaction) do
  dfhack.script_environment('functions/unit').changeInteraction(unit,id,timer,'Innate')
 end
end

if interaction ~= 'all' and interaction ~= 'learned' and interaction ~= 'innate' then
 for _,interaction in pairs(df.global.world.raws.interactions) do
  if interaction.name == args.interaction then
   dfhack.script_environment('functions/unit').changeInteraction(unit,interaction.id,timer,'Both')
   return
  end
 end
end
