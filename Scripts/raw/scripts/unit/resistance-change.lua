--unit/resistance-change.lua
local usage = [====[

unit/resistance-change
======================
Purpose::
    Change the resistance(s) of a unit and track those changes
    Tracked changes can end naturally or be terminated early using other scripts
        
Function Calls::
    unit.getUnitTable
    unit.changeResistance
    misc.getChange
        
Arguments::
    -unit           UNIT_ID
        id of unit to change attributes of
    -resistance     RESISTANCE_TOKEN or [ RESISTANCE_TOKEN RESISTANCE_TOKEN ... ]
        Resistance(s) to be changed
    -mode           Change Mode
        Mode of calculating the change
        Valid Values:
           Percent - changes resistance(s) by a given percentage level
           Fixed   - changes resistance(s) by a flat amount
           Set     - sets resistance(s) to a given level
    -amount         # or [ # # ... ]
        Number(s) to use for resistance changes
        Must have the same amount of numbers as there are RESISTANCE_TOKENs
    -dur            #
        Length of time in in=game ticks for the change to last
    -syndrome       SYN_NAME
        Attaches a syndrome with the given name to the change for tracking purposes

Examples::
    unit/resistance-change -unit \\UNIT_ID -mode Fixed -amount 100 -resistance WATER
    unit/resistance-change -unit \\UNIT_ID -mode Percent -amount [ 10 10 10 ] -resistance [ STORM AIR FIRE ] -dur 3600
    unit/resistance-change -unit \\UNIT_ID -mode set -amount 50 -resistance ICE -dur 1000
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'resistance',
 'mode',
 'amount',
 'dur',
 'unit',
 'syndrome',
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
if type(args.resistance) == 'string' then args.resistance = {args.resistance} end
if #value ~= #args.resistance then
 print('Mismatch between number of resistances declared and number of changes declared')
 return
end

unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
for i,resistance in ipairs(args.resistance) do
 if unitTable.Resistances[resistance] == nil then
  print('Invalid Resistance Token: '..resistance)
 else
  current = unitTable.Resistance[resistance].Base
  change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
  dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'track',args.syndrome)
 end
end
