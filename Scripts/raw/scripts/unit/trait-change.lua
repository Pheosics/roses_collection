--unit/trait-change.lua
local usage = [====[

unit/trait-change
=====================
Purpose::
    Change the trait(s) of a unit
 
Arguments::
    -unit #ID
        id of unit to change traits of
    -trait TRAIT_TOKEN
        Trait token(s) of the trait(s) to be changed
    -mode ChangeMode
        Mode of calculating the change
        Valid Values:
            Percent - changes trait(s) by a given percentage level
            Fixed   - changes trait(s) by a flat amount
            Set     - sets trait(s) to a given level
    -amount #
        Number(s) to use for trait changes
        Must have the same amount of numbers as there are TRAIT_TOKENS
    -dur #ticks
        Length of time in in=game ticks for the change to last

Examples::
    unit/trait-change -unit \\UNIT_ID -amount 20 -trait ELOQUENCY
    unit/trait-change -unit \\UNIT_ID -mode [ Percent Fixed ] -amount [ 200 -20 ] -trait [ FRIENDSHIP FAMILY ] -dur 3600
    unit/trait-change -unit \\UNIT_ID -mode Set -amount 0 -trait SELF_CONTROL -dur 1000
]====]


local utils = require 'utils'
validArgs = utils.invert({
    "help",
    "trait",
    "mode",
    "amount",
    "dur",
    "unit",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in unit/trait-change - "

if args.help then -- Help declaration
    print(usage)
    return
end
local dur = tonumber(args.dur) or 0
if dur < 0 then return end

if args.unit and tonumber(args.unit) then unit = dfhack.script_environment("functions/unit").UNIT(args.unit) end
if not unit then error(error_str .. "No valid unit selected") end

args.mode = args.mode or "FIXED"

if type(args.amount) == "string" then args.amount = {args.amount} end
if type(args.trait)  == "string" then args.trait = {args.trait} end
if type(args.mode)   == "string" then args.mode = {args.mode} end

for i,trait_token in ipairs(args.trait) do
    value = args.amount[i] or args.amount[0]
    mode = args.mode[i] or args.mode[0]
    trait = unit:getTrait(trait_token)
    change = trait:computeChange(value,mode)
    trait:changeValue(change)
    if dur >= 1 then 
        cmd = "unit/trait-change"
        cmd = cmd .. " -unit " .. args.unit
        cmd = cmd .. " -trait " .. trait_token
        cmd = cmd .. " -amount " .. tostring(-change[i])
        dfhack.script_environment('persist-delay').commandDelay(dur,cmd)
    end
end