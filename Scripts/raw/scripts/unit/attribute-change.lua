--unit/attribute-change.lua
local usage = [====[

unit/attribute-change
=====================
Purpose::
    Change the attriubute(s) of a unit

Arguments::
    -unit #ID
        id of unit to change attributes of
    -attribute ATTRIBUTE_TOKEN
        Attribute token(s) of the attribute(s) to be changed
    -mode ChangeMode
        Mode of calculating the change
        Valid Values:
            Percent - changes attribute(s) by a given percentage level
            Fixed   - changes attribute(s) by a flat amount (DEFAULT)
            Set     - sets attribute(s) to a given level
    -amount #
        Number(s) to use for attribute changes
    -dur #ticks
        Length of time in in-game ticks for the change to last

Examples::
    unit/attribute-change -unit \\UNIT_ID -amount 100 -attribute STRENGTH
    unit/attribute-change -unit \\UNIT_ID -mode Percent -amount [ 10 10 50 ] -attribute [ ENDURANCE TOUGHNESS WILLPOWER ] -dur 3600
    unit/attribute-change -unit \\UNIT_ID -mode Set -amount 5000 -attribute WILLPOWER -dur 1000
]====]

local utils = require 'utils'
validArgs = utils.invert({
    "help",
    "attribute",
    "mode",
    "amount",
    "dur",
    "unit",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in unit/attribute-change - "

-- Print Help Message
if args.help then
    print(usage)
    return
end

-- Check for duration value, if negative return
local dur = tonumber(args.dur) or 0
if dur < 0 then return end

-- Check for valid unit
if args.unit and tonumber(args.unit) then unit = dfhack.script_environment("functions/unit").UNIT(args.unit) end
if not unit then error(error_str .. "No valid unit selected") end

-- Parse arguments
args.mode = args.mode or "fixed"
if type(args.amount) == "string"    then args.amount = {args.amount} end
if type(args.attribute) == "string" then args.attribute = {args.attribute} end
if type(args.mode) == "string"      then args.mode = {args.mode} end

-- Apply changes
for i,attribute in ipairs(args.attribute) do
    value = args.amount[i] or args.amount[0]
    mode = args.mode[i] or args.mode[0]
    attribute = unit:getAttribute(attribute)
    change = attribute:computeChange(value,mode)
    print(change)
    attribute:changeValue(change)
    if dur >= 1 then 
        cmd = "unit/attribute-change"
        cmd = cmd .. " -unit " .. args.unit
        cmd = cmd .. " -attribute " .. attribute
        cmd = cmd .. " -amount " .. tostring(-change)
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd) 
    end
end
