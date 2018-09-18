--unit/counter-change.lua
local usage = [====[

unit/counter-change
===================
Purpose::
    Change a units counter value

Function Calls::
    unit.changeCounter
    misc.getChange

Arguments::
    -unit       UNIT_ID
    -counter    counter_token
        Valid Values:
            webbed
            stunned
            winded
            unconscious
            suffocation
            pain
            nausea
            dizziness
            paralysis
            numbness
            fever
            exhaustion
            hunger
            thirst
            sleepiness
            blood
            infection
    -mode       Mode Type
        Valid Values:
            Percent
            Fixed
            Set
    -amount     #
    -dur        #
    
Examples::
    unit/counter-change -unit \\UNIT_ID -counter webbed -mode Set -amount 10000
    unit/counter-change -unit \\UNIT_ID -counter [ thirst hunger exhaustion sleepiness ] -mode Fixed -amount [ 1000 1000 1000 1000 ]
    unit/counter-change -unit \\UNIT_ID -counter blood -mode Percent -amount 50
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'counter',
 'mode',
 'amount',
 'dur',
 'unit',
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

value = args.amount

dur = tonumber(args.dur) or 0
if dur < 0 then return end
if type(value) == 'string' then value = {value} end
if type(args.counter) == 'string' then args.counter = {args.counter} end
if #value ~= #args.counter then
 print('Mismatch between number of tokens declared and number of changes declared')
 return
end

for i,counter in ipairs(args.counter) do
 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness' or counter == 'suffocation') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' or counter == 'blood_count' or counter == 'infection_level' then
  if counter == 'blood' then counter = 'blood_count' end
  if counter == 'infection' then counter = 'infection_level' end
  location = unit.body
 else
  print('Invalid counter token declared')
  print(counter)
  return
 end
 current = location[counter]

-- if counter == 'pain' or counter == 'nausea' or counter == 'dizziness' or counter == 'paralysis' or counter == 'numbness' or counter == 'fever' then
--  print('Counter = ', counter)
--  print('Declared counter is not meant to be changed with this script, see http://www.bay12forums.com/smf/index.php?topic=154798 for information.')
-- end
 
 change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
 dfhack.script_environment('functions/unit').changeCounter(unit,counter,change,dur)
end
