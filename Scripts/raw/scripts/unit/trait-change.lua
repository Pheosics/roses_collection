--unit/trait-change.lua
local usage = [====[

unit/trait-change
=====================
Purpose::
    Change the trait(s) of a unit and track those changes
    Tracked changes can end naturally or be terminated early using other scripts
        
Function Calls::
    unit.getUnitTable
    unit.changeTrait
    misc.getChange
        
Arguments::
    -unit       UNIT_ID
        id of unit to change traits of
    -trait      TRAIT_TOKEN or [ TRAIT_TOKEN TRAIT_TOKEN ... ]
        Trait(s) to be changed
    -mode       Change Mode
        Mode of calculating the change
        Valid Values:
            Percent - changes trait(s) by a given percentage level
            Fixed   - changes trait(s) by a flat amount
            Set     - sets trait(s) to a given level
    -amount     # or [ # # ... ]
        Number(s) to use for trait changes
        Must have the same amount of numbers as there are TRAIT_TOKENS
    -dur        #
        Length of time in in=game ticks for the change to last
    -syndrome   SYN_NAME
        Attaches a syndrome with the given name to the change for tracking purposes

Examples::
    unit/trait-change -unit \\UNIT_ID -mode Fixed -amount 20 -trait ELOQUENCY
    unit/trait-change -unit \\UNIT_ID -mode Percent -amount [ 200 200 ] -trait [ FRIENDSHIP FAMILY ] -dur 3600
    unit/trait-change -unit \\UNIT_ID -mode Set -amount 0 -trait SELF_CONTROL -dur 1000
]====]


local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'trait',
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
if type(args.trait) == 'string' then args.trait = {args.trait} end
if #value ~= #args.trait then
 print('Mismatch between number of skills declared and number of changes declared')
 return
end

unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
for i,trait in ipairs(args.trait) do
 if unitTable.Traits[trait] then
  current = unitTable.Traits[trait].Base
  change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
  dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'track',args.syndrome)
 else
  print('Invalid Trait Token: '..trait)
 end
end
