--unit/body-change.lua
local usage = [====[

unit/body-change
================
Purpose::
    Changes the entire body or individual body parts of a given unit

Arguments::
    -unit #ID
        id of unit to target for change
    -partType PartType
        Type of body part to look for
        Valid Values:
            All      - targets whole body (all parts)
            Category - finds target based on body part CATEGORY
            Token    - finds target based on body part TOKEN
            Flag     - finds target based on body part FLAG
    -bodyPart BodyPart
        Depends on the part type chosen
        Special Value:
            All - Targets whole body (all parts)
    -temperature #
        If present will change the temperature of the body part(s)
    -status Status
        If present will change the status of the body part(s)
        Valid Values:
            Fire - Sets the body part on fire
    -size SizeType
        Changes the dimensions of given units size
        Changing sizes of body parts is not currently possible
        Valid Values:
            All
            Length
            Area
            Size
    -mode ChangeMode
        Method for calculating total amount of change
        Valid Values:
            Percent
            Fixed
            Set
    -amount #
        Amount of temperature or size change
    -dur #ticks
        Length of time in in-game ticks for change to last
        If absent change is permanent

Examples::
    unit/body-change -unit \\UNIT_ID -partType Flag -bodyPart GRASP -status fire -dur 1000
    unit/body-change -unit \\UNIT_ID -partType Category -bodyPart LEG_LOWER -temperature -mode Set -amount 9000
    unit/body-change -unit \\UNIT_ID -size All -mode Percent -amount 200
]====]

local utils = require 'utils'
validArgs = utils.invert({
    "help",
    "bodyPart",
    "partType",
    "temperature",
    "dur",
    "unit",
    "size",
    "mode",
    "amount",
    "status",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in unit/body-change - "

if args.help then -- Help declaration
    print(usage)
    return
end

local dur = tonumber(args.dur) or 0
if dur < 0 then return end

if args.unit and tonumber(args.unit) then unit = dfhack.script_environment("functions/unit").UNIT(args.unit) end
if not unit then error(error_str .. "No valid unit selected") end
if args.temperature or args.status then
    parts = unit:getBodyParts(args.partType,args.bodyPart)
elseif args.size then
    body = unit:getBody()
else
    error(error_str .. "Nothing to change")
end

if args.temperature then
    for _,part in ipairs(parts) do
        change = part:computeChange("TEMPERATURE",args.amount,args.mode)
        part:changeValue("TEMPERATURE",change)
        if dur >= 1 then cmd = "unit/body-change" end -- Duration callback here -ME
    end
end

if args.status then
    for _,part in ipairs(parts) do
        part:changeStatus(args.status)
    end
    if dur >= 1 then 
        cmd = "unit/body-change"
        cmd = cmd .. " -unit " .. args.unit
        if args.partType then cmd = cmd .. " -partType ".. args.partType end
        if args.bodyPart then cmd = cmd .. " -bodyPart " end
        cmd = cmd .. " -status " .. args.status
        cmd = cmd .. " -amount " .. tostring(-change)
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd) 
    end
end

if args.size then
    size = args.size:upper()
    if size == "SIZE" or size == "ALL" then
        body:computeChange("SIZE",args.amount,args.mode)
        body:changeValue("SIZE",change)
        if dur >= 1 then cmd = "unit/body-change" end -- Duration callback here -ME
    end
    if size == "AREA" or size == "ALL" then
        body:computeChange("AREA",args.amount,args.mode)
        body:changeValue("AREA",change)
        if dur >= 1 then cmd = "unit/body-change" end -- Duration callback here -ME
    end
    if size == "LENGTH" or size == "ALL" then
        body:computeChange("LENGTH",args.amount,args.mode)
        body:changeValue("LENGTH",change)
        if dur >= 1 then cmd = "unit/body-change" end -- Duration callback here -ME
    end
end
