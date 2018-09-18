--unit/flag-change.lua
local usage = [====[

unit/flag-change
======
Purpose::
    Changes the boolean value of a given flag

Function Calls::
    None

Arguments::
    -unit        UNIT_ID
    -flag        Unit Flag
        Valid Values:
            Any flag in flags1, flags2, or flags3
    -True
        If present it will set the flag to true
    -False
        If present it will set the flag to false
    -reverse
        If present it will reverse the value of the flag (True->False or False->True)
Examples::
    unit/flag-change -unit \\UNIT_ID -flag hidden -True
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'unit',
 'flag',
 'reverse',
 'True',
 'False',
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

f1 = unit.flags1
f2 = unit.flags2
f3 = unit.flags3

for k,_ in pairs(f1) do
 if args.flag == k then
  flag = 'flags1'
 end
end
for k,_ in pairs(f2) do
 if args.flag == k then
  flag = 'flags2'
 end
end
for k,_ in pairs(f3) do
 if args.flag == k then
  flag = 'flags3'
 end
end

if not flag then
 print('No valid flag declared')
 return
end

if args.reverse then
 if unit[flag][args.flag] then
  unit[flag][args.flag] = false
 else
  unit[flag][args.flag] = true
 end
elseif args.True then
 unit[flag][args.flag] = true
elseif args.False then
 unit[flag][args.flag] = false
end
