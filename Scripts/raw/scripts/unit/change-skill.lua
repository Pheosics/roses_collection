--unit/change-skill.lua
--@ module=true
local utils = require 'utils'

local usage = [====[

unit/change-skill
=================
Purpose::
    Change the skill(s) of a unit

Uses::
	functions/unit

Arguments::
    -unit <UNIT_ID>
        id of unit to change attributes of
    -skill [ <SKILL_TOKEN> <CHANGE> <SKILL_TOKEN <CHANGE> ... ]
        Skill token(s) of the skill(s) to be changed
    -type <ChangeType>
        Valid Values:
            Experience - changes a skills experience 
            Level      - changes a skills level (DEFAULT)
    -add
        If present and unit doesn't have the skill, will add the skill
    -dur <#ticks>
        Length of time in in-game ticks for the change to last

Examples::
	* Increase units mining skill by 1 level
		unit/change-skill -unit \\UNIT_ID -skill [ MINING +1 ]
	* Half units engraving and masonry skills level for 3600 ticks
		unit/change-skill -unit \\UNIT_ID -skill [ ENGRAVING /2 MASONRY /2 ] -dur 3600
	* Set units dodging skill level to 0 for 1000 ticks
		unit/change-skill -unit \\UNIT_ID -skill [ DODGING 0 ] -dur 1000
	* Increase units mining skill experience by 100
		unit/change-skill -unit \\UNIT_ID -type Experience -skill [ MINING +100 ]
]====]


validArgs = utils.invert({
    "help",
    "skill",
    "dur",
    "unit",
    "type",
    "add",
	"args",
})

function changeSkillExperience(unit,skill,mode,value,dur,add)
	local defunit = reqscript("functions/unit").UNIT
	unit = defunit(unit)
	skill = unit:getSkill(skill,add)
	if not skill then return end
	change = skill:computeExperienceChange(value,mode)
	if change == 0 then return end
	skill:changeExperienceValue(change)
	if dur > 1 then
		cmd = "unit/change-skill"
		cmd = cmd .. " -unit " ..tostring(unit.id)
		cmd = cmd .. " -type EXPERIENCE"
		cmd = cmd .. " -skill [ " .. skill.token
		if change > 0 then
			cmd = cmd .. " -" .. tostring(change) .. " ]"
		else
			cmd = cmd .. " +" .. tostring(change) .. " ]"
		end
		dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
	end
end

function changeSkillLevel(unit,skill,mode,value,dur,add)
	local defunit = reqscript("functions/unit").UNIT
	unit = defunit(unit)
	skill = unit:getSkill(skill,add)
	if not skill then return end
	change = skill:computeLevelChange(value,mode)
	if change == 0 then return end
	skill:changeLevelValue(change)
	if dur > 1 then
		cmd = "unit/change-skill"
		cmd = cmd .. " -unit " ..tostring(unit.id)
		cmd = cmd .. " -type LEVEL"
		cmd = cmd .. " -skill [ " .. skill.token
		if change > 0 then
			cmd = cmd .. " -" .. tostring(change) .. " ]"
		else
			cmd = cmd .. " +" .. tostring(change) .. " ]"
		end
		dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
	end
end


local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in unit/change-skill - "

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
	
	-- Check for required arguments
	if not args.skill or not args.unit then return end
	
	-- Check for duration value, if negative return
	local dur = tonumber(args.dur) or 0
	if dur < 0 then return end

	-- Check for valid unit
	if args.unit and tonumber(args.unit) then unit = df.unit.find(tonumber(args.unit)) end
	if not unit then error(error_str .. "No valid unit selected") end

	-- Parse arguments
	local skills = {}
	for i = 1, #args.skill, 2 do
		skills[args.skill[i]] = args.skill[i+1]
	end
	args.type = args.type or "LEVEL"

	-- Apply changes
	for skill, v in pairs(skills) do
		if tonumber(string.sub(v,1,1)) then
			mode = "."
			value = tonumber(v)
		else
			mode = string.sub(v,1,1)
			value = tonumber(string.sub(v,2))
		end
		if Type:upper() == "LEVEL" then
			changeSkillLevel(unit, skill, mode, value, dur, args.add)
		elseif Type:upper() == "EXPERIENCE" then
			changeSkillExperience(unit, skill, mode, value, dur)
		end
    end
end

if not dfhack_flags.module then
	main(...)
end