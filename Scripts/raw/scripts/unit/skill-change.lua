--unit/skill-change.lua
local usage = [====[

unit/skill-change
=================
Purpose::
    Change the skill(s) of a unit and track those changes
    Tracked changes can end naturally or be terminated early using other scripts
    Only use for level changes currently

Function Calls::
    unit.getUnitTable
    unit.changeSkill
    misc.getChange
        
Arguments::
    -unit           UNIT_ID
        id of unit to change attributes of
    -skill      SKILL_TOKEN or [ SKILL_TOKEN SKILL_TOKEN ... ]
        Skill(s) to be changed
    -mode           Change Mode
        Mode of calculating the change
        Valid Values:
           Percent - changes skill(s) by a given percentage level
           Fixed   - changes skill(s) by a flat amount
           Set     - sets skill(s) to a given level
    -amount         # or [ # # ... ]
        Number(s) to use for skill changes
        Must have the same amount of numbers as there are SKILL_TOKENs
    -dur            #
        Length of time in in=game ticks for the change to last
    -syndrome       SYN_NAME
        Attaches a syndrome with the given name to the change for tracking purposes

Examples::
    unit/skill-change -unit \\UNIT_ID -mode Fixed -amount 1 -skill MINING
    unit/skill-change -unit \\UNIT_ID -mode Percent -amount [ 50 50 ] -skill [ ENGRAVING MASONRY  ] -dur 3600
    unit/skill-change -unit \\UNIT_ID -mode Set -amount 0 -skill DODGING -dur 1000
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'skill',
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
if type(args.skill) == 'string' then args.skill = {args.skill} end
if #value ~= #args.skill then
 print('Mismatch between number of skills declared and number of changes declared')
 return
end

unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
for i,skill in ipairs(args.skill) do
 if unitTable.Skills[skill] then
  current = unitTable.Skills[skill].Base
  change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'track',args.syndrome)
 else
  print('Invalid Skill Token: '..skill)
 end
end
