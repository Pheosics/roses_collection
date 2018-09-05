--unit/resistance-change.lua v1.0 | DFHack 43.05
local usage = [====[

xxxxxx
======
Purpose::

Function Calls::

Arguments::

Examples::

]====]

local utils = require 'utils'

validArgs = utils.invert({
 'help',
 'resistance',
 'mode',
 'amount',
 'dur',
 'unit',
 'announcement',
 'track',
 'syndrome',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/resistance-change.lua
  Change the resistance(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -resistance RESISTANCE_ID
     resistance(s) to be changed
   -mode Type
     Valid Types:
      Fixed
      Percent
      Set
   -amount #
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
   -announcement string
     optional argument to create an announcement and combat log report
  examples:
 ]])
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

track = args.track or 'track'

for i,resistance in ipairs(args.resistance) do
 _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Resistances',resistance)
 change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
 dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,track,args.syndrome)
end
if args.announcement then
--add announcement information
end
