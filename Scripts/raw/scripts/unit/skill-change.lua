--unit/skill-change.lua
local usage = [====[

unit/skill-change
=================
Purpose::
    Change the skill(s) of a unit
    
Arguments::
    -unit #ID
        id of unit to change attributes of
    -skill SKILL_TOKEN
        Skill token(s) of the skill(s) to be changed
    -type ChangeType
        Valid Values:
            Experience - changes a skills experience 
            Level      - changes a skills level (DEFAULT)
    -mode ChangeMode
        Mode of calculating the change
        Valid Values:
            Percent - changes skill(s) by a given percentage level
            Fixed   - changes skill(s) by a flat amount
            Set     - sets skill(s) to a given level
    -amount #
        Number(s) to use for skill changes
        Must have the same amount of numbers as there are SKILL_TOKENs or be a single number
    -add
        If present and unit doesn't have the skill, will add the skill
    -dur #ticks
        Length of time in in-game ticks for the change to last

Examples::
    unit/skill-change -unit \\UNIT_ID -amount 1 -skill MINING
    unit/skill-change -unit \\UNIT_ID -mode Percent -amount [ 50 50 ] -skill [ ENGRAVING MASONRY  ] -dur 3600
    unit/skill-change -unit \\UNIT_ID -mode Set -amount 0 -skill DODGING -dur 1000
    unit/skill-change -unit \\UNIT_ID -type Experience -amount 100 -skill MINING
]====]

local utils = require 'utils'
validArgs = utils.invert({
    "help",
    "skill",
    "mode",
    "amount",
    "dur",
    "unit",
    "type",
    "add",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in unit/skill-change - "

if args.help then -- Help declaration
    print(usage)
    return
end
local dur = tonumber(args.dur) or 0
if dur < 0 then return end

if args.unit and tonumber(args.unit) then unit = dfhack.script_environment("functions/unit").UNIT(args.unit) end
if not unit then error(error_str .. "No valid unit selected") end

args.type = args.type or "LEVEL"
args.mode = args.mode or "FIXED"
if type(args.amount) == "string" then args.amount = {args.amount} end
if type(args.skill)  == "string" then args.skill = {args.skill} end
if type(args.mode)   == "string" then args.mode = {args.mode} end
if type(args.type)   == "string" then args.type = {args.type} end

for i,skill_token in ipairs(args.skill) do
    value = args.amount[i] or args.amount[0]
    mode = args.mode[i] or args.mode[0]
    Type = args.type[i] or args.type[0]
    skill = unit:getSkill(skill_token)
    if not skill then
        if args.add then
            skill = unit:addSkill(skill_token)
        else
            return
        end
    end
    change = skill:computeChange(Type,value,mode)
    skill:changeValue(Type,change)
    if dur >= 1 then 
        cmd = "unit/skill-change"
        cmd = cmd .. " -unit " .. args.unit
        cmd = cmd .. " -skill " .. skill_token
        cmd = cmd .. " -type " .. Type
        cmd = cmd .. " -amount " .. tostring(-change[i])
        dfhack.script_environment('persist-delay').commandDelay(dur,cmd)
    end
end
