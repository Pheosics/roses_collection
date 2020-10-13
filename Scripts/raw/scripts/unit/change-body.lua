--unit/change-body.lua
--@ module=true
local utils = require 'utils'
local split = utils.split_string
local getUnit = reqscript("functions/unit").getUnit

local usage = [====[

unit/change-body
================
Purpose::
    Changes the entire body or individual body parts of a given unit

Uses::
	functions/unit

Arguments::
    -unit <UNIT_ID>
        id of unit to target for change
    -bodyPart <PART_TYPE:PART_SUBTYPE> or [ <PART_TYPE:PART_SUBTYPE> <PART_TYPE:PART_SUBTYPE> ...] 
		Part subtypes are based on part type decisions
        Valid PART_TYPEs:
			All      - targets whole body (all parts)
			Category - finds target based on body part CATEGORY
			Token    - finds target based on body part TOKEN
			Flag     - finds target based on body part FLAG
    -temperature <CHANGE>
        If present will change the temperature of the body part(s)
    -status [ <STATUS> <BOOLEAN> <STATUS> <BOOLEAN> ... ]
        If present will change the status of the body part(s)
        Valid Values:
            Fire - Sets the body part on fire
	-blood <CHANGE>
		If present will change the amount of blood
    -size [ <SIZE_TYPE> <CHANGE> <SIZE_TYPE> <CHANGE> ]
        Changes the dimensions of given units size
        Changing sizes of individual body parts is not currently possible
        Valid SIZE_TYPEs:
            All
            Length
            Area
            Size
    -dur <#ticks>
        Length of time in in-game ticks for change to last
        If absent change is permanent, except for temperatures which naturally stabalize

Examples::
	* Set the units hands and feet on fire for 1000 ticks
		unit/change-body -unit \\UNIT_ID -bodyPart [ FLAG:GRASP FLAG:STANCE ] -status [ on_fire true ] -dur 1000
	* Set the units lower legs to a temperature of 9000 Urists (temperature changes are automatically time limited)
		unit/change-body -unit \\UNIT_ID -bodyPart CATEGORY:LEG_LOWER -temperature 9000
	* Double the units size
		unit/change-body -unit \\UNIT_ID -size [ All x2 ]
]====]

validArgs = utils.invert({
    "help",
    "bodyPart",
    "temperature",
    "dur",
    "unit",
    "size",
    "status",
	"blood",
	"args",
})

function changeBodyPartStatus(unit,partType,partSubtype,statusTable,dur)
	unit = getUnit(unit)
	parts = unit:getBodyParts(partType, partSubtype)
	for _, part in pairs(parts) do
		part:changeStatus(statusTable)
	end
	if dur > 1 then
		cmd = "unit/change-body"
		cmd = cmd .. " -unit " ..tostring(unit.id)
		cmd = cmd .. " -bodyPart [ " .. partType .. ":" .. partSubtype .. " ]"
		cmd = cmd .. " -status [ "
		for k,v in pairs(statusTable) do
			cmd = cmd .. k .. " " .. tostring(not v) .. " "
		end
		cmd = cmd .. "]"
		dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
	end
end

function changeBodyPartTemperature(unit,partType,partSubType,mode,value,dur)
	unit = getUnit(unit)
	parts = unit:getBodyParts(partType, partSubtype)
	for _, part in pairs(parts) do
		change = part:computeTemperatureChange(value, mode)
		part:changeTemperature(change)
		-- No need for a duration callback since temperature changes automatically
	end
end

function changeBodySize(unit,sizeType,mode,value,dur)
	unit = getUnit(unit)
	body = unit:getBody()
    size = sizeType:upper()
    if size == "SIZE" or size == "ALL" then
        change = body:computeChange("SIZE",value,mode)
        body:changeValue("SIZE",change)
        if dur > 1 then 
			cmd = "unit/change-body"
			cmd = cmd .. " -unit " ..tostring(unit.id)
			cmd = cmd .. " -size [ SIZE "
			if change > 0 then
				cmd = cmd .. "-"..tostring(change)
			else
				cmd = cmd .. "+"..tostring(change)
			end
			dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
		end
    end
    if size == "AREA" or size == "ALL" then
        change = body:computeChange("AREA",value,mode)
        body:changeValue("AREA",change)
        if dur > 1 then 
			cmd = "unit/change-body"
			cmd = cmd .. " -unit " ..tostring(unit.id)
			cmd = cmd .. " -size [ SIZE "
			if change > 0 then
				cmd = cmd .. "-"..tostring(change)
			else
				cmd = cmd .. "+"..tostring(change)
			end
			dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
		end
    end
    if size == "LENGTH" or size == "ALL" then
        change = body:computeChange("LENGTH",value,mode)
        body:changeValue("LENGTH",change)
        if dur > 1 then 
			cmd = "unit/change-body"
			cmd = cmd .. " -unit " ..tostring(unit.id)
			cmd = cmd .. " -size [ SIZE "
			if change > 0 then
				cmd = cmd .. "-"..tostring(change)
			else
				cmd = cmd .. "+"..tostring(change)
			end
			dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
		end
    end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in unit/body-change - "

	-- Print Help Message
	if args.help then
		print(usage)
		return
	end

	-- Print valid argument list
	if args.args then
		printall(validArgs)
		return
	end
	
	-- Check for duration value, if negative return
	local dur = tonumber(args.dur) or 0
	if dur < 0 then return end

	-- Check for valid unit
	if args.unit and tonumber(args.unit) then unit = df.unit.find(tonumber(args.unit)) end
	if not unit then error(error_str .. "No valid unit selected") end

	-- Parse arguments
	local partArgs = {}
	if args.bodyPart then
		if type(args.bodyPart) == "string" then args.bodyPart = {args.bodyPart} end
		for _,v in pairs(args.bodyPart) do
			local key = split(v,':')[1]:upper()
			local value = "ALL"
			if not key == "ALL" then value = split(v,':')[2]:upper() end
			partArgs[key] = value
		end
	end
	
	local statusArgs = {}
	if args.status then
		for i = 1, #args.status, 2 do
			if args.status[i+1]:lower() == "true" then
				statusArgs[args.status[i]] = true
			else
				statusArgs[args.status[i]] = false
			end
		end
	end
	
	local sizeArgs = {}
	if args.size then
		for i = 1, #args.size, 2 do
			sizeArgs[args.size[i]] = args.size[i+1]
		end
	end
	
	-- Apply temperature change
	if args.temperature and args.bodyPart then
		if tonumber(string.sub(args.temperature,1,1)) then
			mode = "."
			value = tonumber(args.temperature)
		else
			mode = string.sub(args.temperature,1,1)
			value = tonumber(string.sub(v,2))
		end
		for k,v in pairs(partArgs) do
			changeBodyPartTemperature(unit,k,v,mode,value)
		end
	end

    -- Apply status change
	if args.status and args.bodyPart then
		for k,v in pairs(partArgs) do
			changeBodyPartStatus(unit,k,v,statusArgs,dur)
		end
	end
	
	-- Apply size change
	if args.size then
		for k,v in pairs(sizeArgs) do
			if tonumber(string.sub(v,1,1)) then
				mode = "."
				value = tonumber(v)
			else
				mode = string.sub(v,1,1)
				value = tonumber(string.sub(v,2))
			end
			changeBodySize(unit,k,mode,value,dur)
		end
	end
	
	if args.blood then
		unit.body.blood_count = unit.body.blood_count + tonumber(args.blood)
	end
end

if not dfhack_flags.module then
	main(...)
end