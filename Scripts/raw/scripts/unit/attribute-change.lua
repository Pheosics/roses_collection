--unit/attribute-change.lua
local usage = [====[

unit/attribute-change
=====================
Purpose::
    Change the attriubute(s) of a unit and track those changes
    Tracked changes can end naturally or be terminated early using other scripts
    
Function Calls::
    unit.getUnitTable
    unit.changeAttribute
    misc.getChange
    
Arguments::
    -unit        UNIT_ID
        id of unit to change attributes of
    -attribute   ATTRIBUTE_TOKEN or [ ATTRIBUTE_TOKEN ATTRIBUTE_TOKEN ... ]
        Attribute(s) to be changed
    -mode        Change Mode
        Mode of calculating the change
        Valid Values:
            Percent - changes attribute(s) by a given percentage level
            Fixed   - changes attribute(s) by a flat amount
            Set     - sets attribute(s) to a given level
    -amount      # or [ # # ... ]
        Number(s) to use for attribute changes
        Must have the same amount of numbers as there are ATTRIBUTE_TOKENS
    -dur         #
        Length of time in in=game ticks for the change to last
    -syndrome    SYN_NAME
        Attaches a syndrome with the given name to the change for tracking purposes

Examples::
    unit/attribute-change -unit \\UNIT_ID -mode Fixed -amount 100 -attribute STRENGTH
    unit/attribute-change -unit \\UNIT_ID -mode Percent -amount [ 10 10 10 ] -attribute [ ENDURANCE TOUGHNESS WILLPOWER ] -dur 3600
    unit/attribute-change -unit \\UNIT_ID -mode Set -amount 5000 -attribute WILLPOWER -dur 1000
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'attribute',
 'mode',
 'amount',
 'dur',
 'unit',
 'syndrome',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
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
if type(args.attribute) == 'string' then args.attribute = {args.attribute} end
if #value ~= #args.attribute then
 print('Mismatch between number of attributes declared and number of changes declared')
 return
end

unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
for i,attribute in ipairs(args.attribute) do
 if unitTable.Attributes[attribute] then
  current = unitTable.Attributes[attribute].Base
  change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
  dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'track',args.syndrome)
 else
  print('Invalid Attribute Token: '..attribute)
 end
end
