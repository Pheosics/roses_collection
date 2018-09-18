--unit/body-change.lua
local usage = [====[

unit/body-change
================
Purpose::
    Changes the entire body or individual body parts of a given unit

Function Calls::
    unit.getBodyParts
    unit.changeBody
    misc.getChange

Arguments::
    -unit            UNIT_ID
        id of unit to target for change
    -partType        Part Type
        Type of body part to look for
        Valid Values:
            All      - targets whole body (all parts)
            Category - finds target based on body part CATEGORY
            Token    - finds target based on body part TOKEN
            Flag     - finds target based on body part FLAG
    -bodyPart        CATEGORY, TOKEN, or FLAG
        Depends on the part type chosen
        Special Value:
            All - Targets whole body (all parts)
    -temperature
        If present will change the temperature of the body part(s)
        Special Value:
            Fire - Sets the body part on fire
    -size            Size Type
        Changes the dimensions of given units size
        Changing sizes of body parts is not currently possible
        Valid Values:
            All
            Length
            Area
            Size
    -mode            Mode Type
        Method for calculating total amount of change
        Valid Values:
            Percent
            Fixed
            Set
    -amount          #
        Amount of temperature or size change
    -dur             #
        Length of time in in-game ticks for change to last
        If absent change is permanent

Examples::
    unit/body-change -unit \\UNIT_ID -partType Flag -bodyPart GRASP -temperature fire -dur 1000
    unit/body-change -unit \\UNIT_ID -partType Category -bodyPart LEG_LOWER -temperature -mode Set -amount 9000
    unit/body-change -unit \\UNIT_ID -partType All -bodyPart All -size All -mode Percent -amount 200
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'bodyPart',
 'partType',
 'temperature',
 'dur',
 'unit',
 'size',
 'mode',
 'amount',
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

dur = tonumber(args.dur) or 0
if dur < 0 then return end
value = args.amount

parts = {}
if args.partType == 'All' or args.bodyPart == 'All' then
 body = unit.body.body_plan.body_parts
 for k,v in ipairs(body) do
  parts[k] = k
 end
else
 parts = dfhack.script_environment('functions/unit').getBodyParts(unit,args.partType,args.bodyPart)
end

if args.temperature then
 for _,part in ipairs(parts) do
  if args.temperature == 'Fire' or args.temperature == 'fire' then
   dfhack.script_environment('functions/unit').changeBody(unit,part,'Temperature','Fire',dur)
  else
   current = unit.status2.body_part_temperature[part].whole
   change = dfhack.script_environment('functions/misc').getChange(current,value,args.mode)
   dfhack.script_environment('functions/unit').changeBody(unit,part,'Temperature',change,dur)
  end
 end
elseif args.size then -- Can't currently change the size of individual body parts without changing entire caste raws
 if args.size == 'Size' or args.size == 'All' then
  current = unit.body.size_info.size_cur
  change = dfhack.script_environment('functions/misc').getChange(current,value,args.mode)
  dfhack.script_environment('functions/unit').changeBody(unit,nil,'Size',change,dur)
 end
 if args.size == 'Area' or args.size == 'All' then
  current = unit.body.size_info.area_cur
  change = dfhack.script_environment('functions/misc').getChange(current,value,args.mode)
  dfhack.script_environment('functions/unit').changeBody(unit,nil,'Area',change,dur)
 end
 if args.size == 'Length' or args.size == 'All' then
  current = unit.body.size_info.length_cur
  change = dfhack.script_environment('functions/misc').getChange(current,value,args.mode)
  dfhack.script_environment('functions/unit').changeBody(unit,nil,'Length',change,dur)
 end
end
