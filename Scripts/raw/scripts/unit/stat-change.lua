--unit/stat-change.lua
local usage = [====[

unit/stat-change
================
Purpose::
    Change the stat(s) of a unit and track those changes
    Tracked changes can end naturally or be terminated early using other scripts
        
Function Calls::
    unit.getUnitTable
    unit.changeStat
    misc.getChange
        
Arguments::
    -unit      UNIT_ID
        id of unit to change stats of
    -stat      STAT_TOKEN or [ STAT_TOKEN STAT_TOKEN ... ]
        Stat(s) to be changed
    -mode      Change Mode
        Mode of calculating the change
        Valid Values:
            Percent - changes stat(s) by a given percentage level
            Fixed   - changes stat(s) by a flat amount
            Set     - sets stat(s) to a given level
    -amount    # or [ # # ... ]
        Number(s) to use for stat changes
        Must have the same amount of numbers as there are STAT_TOKENs
    -dur       #
        Length of time in in=game ticks for the change to last
    -syndrome  SYN_NAME
        Attaches a syndrome with the given name to the change for tracking purposes

Examples::
    unit/stat-change -unit \\UNIT_ID -mode Fixed -amount 10 -stat PARRY_CHANCE
    unit/stat-change -unit \\UNIT_ID -mode Percent -amount [ 80 120 ] -stat [ CRIT_CHANCE CRIT_DAMAGE ] -dur 3600
    unit/stat-change -unit \\UNIT_ID -mode Set -amount 100 -stat DODGE_CHANCE -dur 1000
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'stat',
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
if type(args.stat) == 'string' then args.stat = {args.stat} end
if #value ~= #args.stat then
 print('Mismatch between number of resistances declared and number of changes declared')
 return
end

unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
for i,stat in ipairs(args.stat) do
 if unitTable.Stats[stat] then
  current = unitTable.Stats[stat]
  change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
  dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'track',args.syndrome)
 else
  print('Invalid Stat Token: '..stat)
 end
end

