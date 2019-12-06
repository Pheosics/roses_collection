--unit/transform.lua
local usage = [====[

unit/transform
==============
Purpose::
    Change a units creature and caste
    Any changes are tracked for easy removal

Function Calls::
    unit.checkCreatureRace
    unit.changeRace
    misc.permute

Arguments::
    -unit        UNIT_ID
        id of unit to change attributes of
    -creature    CREATURE:CASTE
        Creature/Caste combination to transform into
        Special Values (for CASTE)
            !RANDOM!
            !GENDER!
    -dur         #
        Length of time in in=game ticks for the change to last
    -syndrome    SYN_NAME
        Attaches a syndrome with the given name to the change for tracking purposes

Examples::
    unit/transform -unit \\UNIT_ID -creature ELEMENTAL:!RANDOM! -dur 3600
    unit/transform -unit \\UNIT_ID -creature DWARF:!GENDER!
]====]

local utils = require 'utils'
local split = utils.split_string
validArgs = utils.invert({
 'help',
 'unit',
 'creature',
 'dur',
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
 print('No unit declared')
 return
end
if not args.creature then
 print('No creature declared')
 return
else
 race = split(args.creature,':')[1]
 caste = split(args.creature,':')[2]
end
if dfhack.script_environment('functions/unit').checkCreatureRace(unit,args.creature) then
 print('Unit already the desired creature')
 return
end

for i,v in ipairs(df.global.world.raws.creatures.all) do
 if v.creature_id == race then
  raceIndex = i
  race = v
  break
 end
end
if not race then
  error 'Invalid race.'
end

if caste == '!RANDOM!' then
 castes = {}
 for i,v in pairs(race.caste) do
  castes[#castes+1] = i
 end
 castes = dfhack.script_environment('functions/misc').permute(castes)
 casteIndex = castes[1]
elseif caste == '!GENDER!' then
 gender = unit.sex
 for i,v in pairs(race.caste) do
  if v.gender == gender then
   casteIndex = i
   break
  end
 end
else
 for i,v in pairs(race.caste) do
  if v.caste_id == caste then
   casteIndex = i
   break
  end
 end
end
if not casteIndex then
  error 'Invalid caste.'
end

dur = tonumber(args.dur) or 0
dfhack.script_environment('functions/unit').changeRace(unit,raceIndex,casteIndex,dur,'track',args.syndrome)
