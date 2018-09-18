--unit/syndrome-change.lua
local usage = [====[

unit/syndrome-change
====================
Purpose::
    Change the syndrome(s) of a unit
    Also changes duration of syndromes

Function Calls::
    unit.changeSyndrome

Arguments::
    -unit             UNIT_ID
        id of unit to change syndrome(s) of
    -syndrome         SYN_NAME or [ SYN_NAME SYN_NAME ]
        Name of syndrome(s) to be changed
    -class            SYN_CLASS or [ SYN_CLASS SYN_CLASS ]
        Class of syndrome(s) to be changed
    -add
        Adds syndrome(s) to unit
    -erase
        Erases syndrome(s) from unit
    -terminate
        Terminates syndrome(s) of unit (see Feature: Tracking for information on termination)
    -alterDuration    #
        Changes the duration of syndrome(s) on unit
    -dur              #
        Length of tiem for the syndrome to last if added

Examples::
    unit/syndrome-change -unit \\UNIT_ID -class BUFF -terminate
    unit/syndrome-change -unit \\UNIT_ID -syndrome HASTE -add -dur 3600
    unit/syndrome-change -unit \\UNIT_ID -class [ SPEED_CHANGE ATTRIBUTE_CHANGE ] -alterDuration 1000
    unit/syndrome-change -unit \\UNIT_ID -class BUFF -syndrome UNHOLY -erase
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'unit',
 'syndrome',
 'class',
 'add',
 'erase',
 'terminate',
 'alterDuration',
 'dur',
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
syndromes = nil
classes = nil
if args.syndrome then
 if type(args.syndrome) ~= 'table' then
  syndromes = {args.syndrome}
 else
  syndromes = args.syndrome
 end
end
if args.class then
 if type(args.class) ~= 'table' then
  classes = {args.class}
 else
  classes = args.class
 end
end
if not syndromes and not classes then
 print('Neither syndrome name(s) or class(es) declared')
 return
end
dur = tonumber(args.dur) or 0
if dur < 0 then return end

if args.add then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'add',dur) end
 if classes then print('Currently unable to add syndromes based on classes') return end
elseif args.erase then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'erase',dur) end
 if classes then dfhack.script_environment('functions/unit').changeSyndrome(unit,classes,'eraseClass',dur) end
elseif args.terminate then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'terminate',dur) end
 if classes then dfhack.script_environment('functions/unit').changeSyndrome(unit,classes,'terminateClass',dur) end
elseif args.alterDuration then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'alterDuration',tonumber(args.alterDuration)) end
 if classes then dfhack.script_environment('functions/unit').changeSyndrome(unit,classes,'alterDurationClass',tonumber(args.alterDuration)) end
else
 print('No method declared (methods are add, erase, terminate, and alterDuration)')
 return
end
