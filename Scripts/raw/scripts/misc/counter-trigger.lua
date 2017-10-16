--special/counter-trigger.lua v1.0 | DFHack 43.05
   
local utils = require 'utils'
local persistTable = require 'persist-table'

function counters(types,unit,counter,increase,style,cap,script,reset)
 trigger = false
 if types == 'GLOBAL' then
  val = dfhack.script_environment('functions/misc').changeCounter(counter,increase)
 elseif types == 'UNIT' then
  val = dfhack.script_environment('functions/misc').changeCounter('!UNIT:'..counter,increase,unit.id)
 end
 
 if style == 'minimum' then
  if val >= cap and cap >= 0 then
   trigger = true
  end
 elseif style == 'percent' then
  rando = dfhack.random.new()
  roll = rando:drandom()
  if roll <= val/cap and cap >=1 then
   trigger = true
  end
 end

 if trigger and script then
  if reset then
   if types == 'GLOBAL' then
    dfhack.script_environment('functions/misc').changeCounter(counter,-val)
   elseif types == 'UNIT' then
    dfhack.script_environment('functions/misc').changeCounter('!UNIT:'..counter,-val,unit.id)
   end
  end

  dfhack.run_command(script)
 end

 return trigger
end

validArgs = validArgs or utils.invert({
 'help',
 'type',
 'unit',
 'style',
 'counter',
 'increment',
 'cap',
 'script',
 'no_reset',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special/counters.lua
  Allows for creation, examination, and ultimately triggering based on counters
  arguments:
   -help
     print this help message
   -type GLOBAL or UNIT
    REQUIRED
   -unit id
     id of the target unit to associate the counter with, REQUIRED if using -type UNIT
   -style minimum or percent
     minimum - once the value of the counter has surpassed a certain amount, the counter will trigger the script. the counter is then reset to zero
     percent - the script has a chance of triggering each time the counter is increased, with a 100% chance once it reaches a certain amount. the counter is reset to zero on triggering
     if no style given will not check for cap and will just add to counter
   -counter ANY_STRING
     REQUIRED
     any string value, the counter will be saved as this type
     examples:
      FIRE
      BURN
      POISON
   -increment #
     amount for the counter to change
     DEFAULT 1
   -cap #
     level of triggering for the counter
     once it hits the cap (or is triggered earlier by percentage) the counter will reset to 0
     if no cap is given then script will never be run
   -script [ command line input ]
     the script to trigger when the counter is reached 
  example:
   special/counters -unit \\UNIT_ID -style minimum -counter BERSERK -increment 1 -cap 10 -script [unit-attributes-change -unit \\UNIT_ID -physical [STRENGTH,AGILITY] -fixed [1000,\-200] ]
 ]])
 return
end

if not args.counter then -- Check for counter declaration !REQUIRED
 print('No counter selected')
 return
end

if not args.type then
 args.type = 'GLOBAL'
elseif args.type == 'UNIT' and not args.unit then
 print('No unit selected for -type UNIT couner')
 return
elseif args.type == 'UNIT' and args.unit then
 unit = df.unit.find(tonumber(args.unit))
end

reset = true
if args.no_reset then reset = false end
increment = args.increment or 1
cap = args.cap or -1
style = args.style or nil

counters(args.type,unit,args.counter,increment,style,cap,script,reset)
