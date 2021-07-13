--@ module = true
local utils = require "utils"

info = {}
info["UNIT"]           = [===[ TODO ]===]
info["UNIT_ACTION"]    = [===[ TODO ]===]
info["UNIT_ATTACK"]    = [===[ TODO ]===]
info["UNIT_ATTRIBUTE"] = [===[ TODO ]===]
info["UNIT_BODY"]      = [===[ TODO ]===]
info["UNIT_BODYPART"]  = [===[ TODO ]===]
info["UNIT_SKILL"]     = [===[ TODO ]===]

local myMath = reqscript("functions/math")
local computeChange = myMath.computeChange

local function nextSkillLevel(rating)
	if rating == 0 then
		return 1
	else
		return (400 + (100 * rating))
	end
end

local counterLocation = {
	-- counters
	think_counter = "counters",
	job_counter = "counters",
	swap_counter = "counters",
	death_cause = "counters",
	death_id = "counters",
	winded = "counters", 
	stunned = "counters",
	unconscious = "counters",
	suffocation = "counters",
	webbed = "counters",
	pain = "counters",
	nausea = "counters",
	dizziness = "counters",
	-- counters2
	paralysis = "counters2",
	numbness = "counters2",
	fever = "counters2",
	exhaustion = "counters2",
	hunger_timer = "counters2",
	thirst_timer = "counters2",
	sleepiness_timer = "counters2",
	stomach_content = "counters2",
	stomach_food = "counters2",
	vomit_timeout = "counters2",
	stored_fat = "counters2",
}
local counterShortcuts = {
	sleepiness = "sleepiness_timer",
	thirst = "thirst_timer",
	hunger = "hunger_timer",
}

--===============================================================================================--
--== UNIT CLASSES ===============================================================================--
--===============================================================================================--
local UNIT             = defclass(UNIT)             -- references <df.unit>
local UNIT_ACTION      = defclass(UNIT_ACTION)      -- references <df.unit_action>
local UNIT_ATTACK      = defclass(UNIT_ATTACK)      -- references <df.caste_attack>
local UNIT_ATTRIBUTE   = defclass(UNIT_ATTRIBUTE)   -- references <df.unit_attribute>
local UNIT_BODY        = defclass(UNIT_BODY)        -- references <df.unit.T_body>
local UNIT_BODYPART    = defclass(UNIT_BODYPART)    -- references <df.body_part_raw>
local UNIT_PERSONALITY = defclass(UNIT_PERSONALITY) -- references <df.unit_personality>
local UNIT_SKILL       = defclass(UNIT_SKILL)       -- references <df.unit_skill>
function getUnit(unit) return UNIT(unit) end

--===============================================================================================--
--== UNIT FUNCTIONS =============================================================================--
--===============================================================================================--
function UNIT:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT,key) then return rawget(UNIT,key) end
	if dfhack.units[key] then 
		return function(...) 
			return dfhack.units[key](self._unit,...) 
		end
	end
	return df.unit.find(self.id)[key]
end
function UNIT:init(unit)
	if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
	self.id = unit.id
	self._unit = unit
	self.Token = reqscript("functions/io").find_creatureToken(unit.id)
	self.Pronoun1, self.Pronoun2 = reqscript("functions/text").getPronoun(unit)
	self._creatureRaws = df.global.world.raws.creatures.all[unit.race]
	self._casteRaws = df.global.world.raws.creatures.all[unit.race].caste[unit.caste]
	self.Attributes = setmetatable({}, {__index = function (table, key) 
													return UNIT_ATTRIBUTE({self._unit,key})
												end})
	self.Skills     = setmetatable({}, {__index = function (table, key) 
													return self:getSkill(key, true)
												end})
	self.Flags      = setmetatable({}, {__index = function (table, key)
													local flags = {}
													for k,v in pairs(self._unit.flags1) do flags[k] = v end
													for k,v in pairs(self._unit.flags2) do flags[k] = v end
													for k,v in pairs(self._unit.flags3) do flags[k] = v end
													return flags[key] or false
												end})
	self.Counters   = setmetatable({}, {__index = function (table, key)
													local c = counterShortcuts[counter] or counter
													if not counterLocation[c] then return -1 end
													return self._unit[counterLocation[c]][c]	
												end})
	self.Personality = function () return UNIT_PERSONALITY({self._unit}) end
end

function UNIT:addAttack(attack_data)
	unit = df.unit.find(self.id)
	attack = df.unit_action:new()
	attack.id = unit.next_action_id
	attack.type = df.unit_action_type["Attack"]
	for k,v in pairs(attack_data) do
		attack.data.attack[k] = v
	end
	unit.actions:insert('#',attack)
	unit.next_action_id = unit.next_action_id + 1
end

function UNIT:addSkill(skill)
	local unit = df.unit.find(self.id)
	local skillid = df.job_skill[skill]
	utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = 0},"id")
	return UNIT_SKILL({unit,skill,#unit.status.current_soul.skills})
end

function UNIT:getActions(action_type)
	local action_type = action_type or "ALL"
	local out = {}
	local actions = df.unit.find(self.id).actions
	for n, action in pairs(actions) do
		if action["type"] >= 0 then
			if (action_type == "ALL" or df.unit_action_type[action_type] == action["type"]) then
				out[#out+1] = UNIT_ACTION({self._unit,action})
			end
		end
	end
	return out
end

function UNIT:getAttack(attack_name)
	local name = attack_name or "RANDOM"
	local unit = df.unit.find(self.id)
	if name:upper() == "RANDOM" then
		local rand = dfhack.random.new()
		local weights = {}
		weights[0] = 0
		local n = 0
		for _,attacks in pairs(unit.body.body_plan.attacks) do
			if attacks.flags.main then x = 100 else x = 1 end
			n = n + 1
			weights[n] = weights[n-1] + x
		end
		local pick = rand:random(weights[n])
		for i = 1,n do
			if pick >= weights[i-1] and pick < weights[i] then attack_id= i-1 break end
		end
		if not attack_id then attack_id = n end
		out = UNIT_ATTACK({unit,attack_id})
	else
		for attack_id,attack in pairs(unit.body.body_plan.attacks) do
			if attack.name:upper() == name:upper() then
				out = UNIT_ATTACK({unit,attack_id})
			end
		end
	end
	return out
end

function UNIT:getBody()
	return UNIT_BODY({df.unit.find(self.id)})
end

function UNIT:getBodyParts(filter,value)
	local value = value or "RANDOM"
	local parts = {}
	local body = df.unit.find(self.id).body
	if value:upper() == "RANDOM" then
		local rand = dfhack.random.new()
		local weights = {}
		weights[0] = 0
		local n = 0
		for _,targets in pairs(body.body_plan.body_parts) do
			n = n + 1
			weights[n] = weights[n-1] + targets.relsize 
		end
		local pick = rand:random(weights[n])
		for i = 1,n do
			if pick >= weights[i-1] and pick < weights[i] then target = i-1 break end
		end
		if not target then target = n end
		parts[1] = UNIT_BODYPART({self._unit,target})
	else
		for j,y in pairs(body.body_plan.body_parts) do
			if not body.components.body_part_status[j].missing then
				if value:upper() == "ALL"
					or (filter:upper() == "CATEGORY"  and y.category == value)
					or (filter:upper() == "TOKEN"     and y.token == value)
					or (filter:upper() == "FLAG"      and y.flags[value])
					or (filter:upper() == "CONNECTED" and y.con_part_id == value) then
					parts[#parts+1] = UNIT_BODYPART({self._unit,j})
				end
			end
		end
	end
	return parts
end

function UNIT:getInventoryItems(filter,value)
	local items = {}
	local inventory = df.unit.find(self.id).inventory
	for _,x in ipairs(inventory) do
		if (filter == "ALL" or value == "ALL")
			or (filter:upper() == "TYPE" and df.item_type[x.item:getType()] == value)
			or (filter:upper() == "MODE" and x.mode == value)
			or (filter:upper() == "PART" and x.body_part_id == value) 
			or (filter:upper() == "ITEM" 
				and dfhack.items.getSubtypeDef(x.item:getType(),x.item:getSubtype()).id == value) then
			items[#items+1] = x.item
		end
	end
	return items
end

function UNIT:getSkill(skill,add)
	local unit = df.unit.find(self.id)	
	local skillid = df.job_skill[skill]
	if not skillid then
		return UNIT_SKILL({unit,skill})
	end
	local found = false
	for i,x in pairs(unit.status.current_soul.skills) do
		if x.id == skillid then
			found = true
			n = i
			break
		end
	end
	if found then
		return UNIT_SKILL({unit,skill,n})
	else
		if add then
			return self:addSkill(skill)
		else
			return nil
		end
	end
end

function UNIT:getSkillRate(skill,baseRate,changeRate)
	local skillLevel = dfhack.units.getEffectiveSkill(self._unit,skill) or 0
	return baseRate - skillLevel*changeRate
end

function UNIT:makeProjectile(velocity)
	local unit = df.unit.find(self.id)
	local vx = velocity.x or velocity[1]
	local vy = velocity.y or velocity[2]
	local vz = velocity.z or velocity[3]
	local count=0
	local l = df.global.world.proj_list
	local lastlist=l
	l=l.next
	while l do
		count=count+1
		if l.next==nil then
			lastlist = l
		end
		l = l.next
	end
	
	newlist = df.proj_list_link:new()
	lastlist.next=newlist
	newlist.prev=lastlist
	proj = df.proj_unitst:new()
	newlist.item=proj
	proj.link=newlist
	proj.id=df.global.proj_next_id
	df.global.proj_next_id=df.global.proj_next_id+1
	proj.unit=unit
	proj.origin_pos.x = unit.pos.x
	proj.origin_pos.y = unit.pos.y
	proj.origin_pos.z = unit.pos.z
	proj.prev_pos.x   = unit.pos.x
	proj.prev_pos.y   = unit.pos.y
	proj.prev_pos.z   = unit.pos.z
	proj.cur_pos.x    = unit.pos.x
	proj.cur_pos.y    = unit.pos.y
	proj.cur_pos.z    = unit.pos.z
	proj.flags.no_impact_destroy = true
	proj.flags.piercing          = true
	proj.flags.parabolic         = true
	proj.flags.unk9              = true
	proj.speed_x = velocity.x or velocity[1]
	proj.speed_y = velocity.y or velocity[2]
	proj.speed_z = velocity.z or velocity[3]
	unitoccupancy = dfhack.maps.ensureTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
	if not unit.flags1.on_ground then
		unitoccupancy.unit = false
	else
		unitoccupancy.unit_grounded = false
	end
	unit.flags1.projectile = true
	unit.flags1.on_ground  = false
end

function UNIT:setCounter(counter, value)
	local c = counterShortcuts[counter] or counter
	if not counterLocation[c] then return end
	self._unit[counterLocation[c]][c] = value
end

--===============================================================================================--
--== UNIT_ACTION FUNCTIONS ======================================================================--
--===============================================================================================--
function UNIT_ACTION:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT_ACTION,key) then return rawget(UNIT_ACTION,key) end
	return self._action[key]
end
function UNIT_ACTION:init(input)
	self.unit = input[1]
	self._action = input[2]
	self.type = df.unit_action_type[self._action.type]
	self.data = self._action.data[self.type:lower()]
end

function UNIT_ACTION:removeAction()
	self._action.type = -1
end

function UNIT_ACTION:getDelay()
	local value = -1
	for t,v in pairs(self.data) do
		if t == "timer" then
			value = v
			break
		elseif t == "timer1" or t == "timer2" then
			value = v
			break
		end
	end
	return value
end

--===============================================================================================--
--== UNIT_ATTACK FUNCTIONS ======================================================================--
--===============================================================================================--
function UNIT_ATTACK:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT_ATTACK,key) then return rawget(UNIT_ATTACK,key) end
	return self._attack[key]
end
function UNIT_ATTACK:init(input)
	self.unit = input[1]
	self.id = input[2]
	self.item_id = false
	self._attack = self.unit.body.body_plan.attacks[input[2]]
end

function UNIT_ATTACK:computeHitChance()
	-- Not currently implemented -ME
	local hitchance = 100
	return math.floor(hitchance+0.5)
end

function UNIT_ATTACK:computeVelocity()
	local vel_mod = self._attack.velocity_modifier
	local strength = dfhack.units.getPhysicalAttrValue(self.unit,df.physical_attribute_type["STRENGTH"])
	local velocity = 100*(strength/1000)*(vel_mod/1000)
	if velocity < 1 then velocity = 1 end

	return math.floor(velocity+0.5)
end

--===============================================================================================--
--== UNIT_ATTRIBUTE FUNCTIONS ===================================================================--
--===============================================================================================--
function UNIT_ATTRIBUTE:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT_ATTRIBUTE,key) then return rawget(UNIT_ATTRIBUTE,key) end
	return self._attribute[key]
end
function UNIT_ATTRIBUTE:__add(x)
	self:changeValue(x)
end
function UNIT_ATTRIBUTE:init(input)
	self.unit = input[1]
	self.token = input[2]
	self.min_val = 0
	self.max_val = 5000
	if df.physical_attribute_type[self.token] then
		self.type = "Physical"
		self._attribute = self.unit.body.physical_attrs[self.token]
	elseif df.mental_attribute_type[self.token] then
		self.type = "Mental"
		self._attribute = self.unit.status.current_soul.mental_attrs[self.token]
	else
		self.type = "Custom"
	end
end

function UNIT_ATTRIBUTE:changeValue(change,dur)
	change = tonumber(change)
	dur = dur or 0
	if change == 0 then return end
	local unit = df.unit.find(self.unit.id)
	if self.type == "Physical" then
		local current = unit.body.physical_attrs[self.token].value
		unit.body.physical_attrs[self.token].value = current + change
	elseif self.type == "Mental" then
		local current = unit.status.current_soul.mental_attrs[self.token].value
		unit.status.current_soul.mental_attrs[self.token].value = current + change
	elseif self.type == "Custom" then
		-- No custom attrtibutes yet
	end
	if dur > 0 then dfhack.script_environment("persist-delay").classDelay(dur,"unit",{self.unit.id,"Attributes",self.token,-change}) end
end

function UNIT_ATTRIBUTE:computeChange(value,mode)
	local value = tonumber(value)
	local current = self:getBaseValue()
	return computeChange(mode or "+", value, current)
end

function UNIT_ATTRIBUTE:getBaseValue()
	local value = 0
	local unit = df.unit.find(self.unit.id)
	if self.type == "Physical" then
		value = unit.body.physical_attrs[self.token].value
	elseif self.type == "Mental" then
		value = unit.status.current_soul.mental_attrs[self.token].value
	elseif self.type == "Custom" then
		-- No custom attrtibutes yet
	end
	return value
end

--===============================================================================================--
--== UNIT_BODY FUNCTIONS ========================================================================--
--===============================================================================================--
function UNIT_BODY:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT_BODY,key) then return rawget(UNIT_BODY,key) end
	return self._body[key]
end
function UNIT_BODY:init(input)
	self.unit = input[1]
	self._body = self.unit.body
end

function UNIT_BODY:changeValue(changeType,change)
	if change == 0 then return change end
	if changeType:upper() == "SIZE" then
		self.unit.body.size_info.size_cur = self.unit.body.size_info.size_cur + change
	elseif changeType:upper() == "AREA" then
		self.unit.body.size_info.area_cur = self.unit.body.size_info.area_cur + change
	elseif changeType:upper() == "LENGTH" then
		self.unit.body.size_info.length_cur = self.unit.body.size_info.length_cur + change
	end
end

function UNIT_BODY:computeChange(changeType,value,mode)
	local value = tonumber(value)
	local current
	if changeType:upper() == "SIZE" then
		current = self.unit.body.size_info.size_cur
	elseif changeType:upper() == "AREA" then
		current = self.unit.body.size_info.area_cur
	elseif changeType:upper() == "LENGTH" then
		current = self.unit.body.size_info.length_cur
	end
	return computeChange(mode or "+", value, current)
end

--===============================================================================================--
--== UNIT_BODYPART FUNCTIONS ====================================================================--
--===============================================================================================--
function UNIT_BODYPART:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT_BODYPART,key) then return rawget(UNIT_BODYPART,key) end
	return self._bodypart[key]
end
function UNIT_BODYPART:init(input)
	self.unit = input[1]
	self.id = input[2]
	self._bodypart = self.unit.body.body_plan.body_parts[self.id]
end

function UNIT_BODYPART:changeStatus(statusTable)
	for status, bool in pairs(statusTable) do
		self.unit.body.components.body_part_status[self.id][status] = bool
	end
end

function UNIT_BODYPART:changeTemperature(change)
	if change == 0 then return change end
	self.unit.status2.body_part_temperature[self.id].whole = self.unit.status2.body_part_temperature[self.id].whole + change
end

function UNIT_BODYPART:computeTemperatureChange(value,mode)
	local value = tonumber(value)
	local current = self:getTemperature()
	return computeChange(mode or "+", value, current)
end

function UNIT_BODYPART:getStatus(status)
	local unit = df.unit.find(self.unit.id)
	return unit.body.components.body_part_status[self.id][status]
end

function UNIT_BODYPART:getTemeperature()
	local unit = df.unit.find(self.unit.id)
	return unit.status2.body_part_temperature[self.id].whole
end

--===============================================================================================--
--== UNIT_PERSONALITY FUNCTIONS =================================================================--
--===============================================================================================--
function UNIT_PERSONALITY:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT_PERSONALITY,key) then return rawget(UNIT_PERSONALITY,key) end
	return self._personality[key]
end
function UNIT_PERSONALITY:init(input)
	self.unit = input[1]
	self._personality = self.unit.status.current_soul.personality
end

function UNIT_PERSONALITY:changeTraitValue(trait,change)
	self.unit.status.current_soul.personality.traits[trait] = self.unit.status.current_soul.personality.traits[trait] + change
end

function UNIT_PERSONALITY:computeTraitChange(trait,value,mode)
	local current = self:getTrait(trait)
	return computeChange(mode or "+",value,current)
end

function UNIT_PERSONALITY:getTrait(trait)
	unit = df.unit.find(unit.id)
	return unit.status.current_soul.personality.traits[trait]
end

--===============================================================================================--
--== UNIT_SKILL FUNCTIONS =======================================================================--
--===============================================================================================--
function UNIT_SKILL:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT_SKILL,key) then return rawget(UNIT_SKILL,key) end
	return nil
end
function UNIT_SKILL:__add(x)
	if math.abs(x) < 1 then
		self:changeExperienceValue(1/x)
	else
		self:changeLevelValue(x)
	end
end
function UNIT_SKILL:init(input)
	self.unit = input[1]
	self.token = input[2]
	self.id = input[3]
	self.min_val = 0
	self.max_val = 50
	if df.job_skill[input[2]] then
		self.type = "Normal"
	else
		self.type = "Custom"
	end
end

function UNIT_SKILL:changeExperienceValue(change) -- Skill leveling taken from modtools/skill-change.lua
	if change == 0 then return change end
	local unit = df.unit.find(self.unit.id)
	if self.type == "Normal" then
		skill = unit.status.current_soul.skills[self.id]
		local newExp = skill.experience + change
		if (newExp < 0) or (newExp > nextSkillLevel(skill.rating+1)) then
			if newExp > 0 then --positive
				repeat
					newExp = newExp - nextSkillLevel(skill.rating+1)
					skill.rating = skill.rating + 1
				until newExp < nextSkillLevel(skill.rating)
			else -- negative
				repeat
					newExp = newExp + nextSkillLevel(skill.rating)
					skill.rating = math.max(skill.rating - 1, 0)
				until (newExp >= 0) or skill.rating == 0
				if newExp < 0 then newExp = 0 end
			end
		end
        skill.experience = newExp
	elseif self.type == "Custom" then
		-- No custom skills yet
	end
end

function UNIT_SKILL:changeLevelValue(change)
	if change == 0 then return change end
	local unit = df.unit.find(self.unit.id)
	if self.type == "Normal" then
		local id = self.id
		unit.status.current_soul.skills[id].rating = unit.status.current_soul.skills[id].rating + change
	elseif self.type == "Custom" then
		-- No custom skills yet
	end
end

function UNIT_SKILL:computeExperienceChange(value,mode)
	local value = tonumber(value)
	local current = self:getBaseValue("EXPERIENCE")
	return computeChange(mode or "+", value, current)
end

function UNIT_SKILL:computeLevelChange(value,mode)
	local value = tonumber(value)
	local current = self:getBaseValue("LEVEL")
	return computeChange(mode or "+", value, current)
end

function UNIT_SKILL:getBaseValue(Type)
	Type = Type or "LEVEL"
	local value = 0
	local unit = df.unit.find(self.unit.id)
	if self.type == "Normal" then
		local skillid = df.job_skill[self.token]
		if Type:upper() == "EXPERIENCE" then
			value = dfhack.units.getExperience(unit, skillid, false)
		elseif Type:upper() == "LEVEL" then
			value = dfhack.units.getNominalSkill(unit, skillid, false)
		end	
	elseif self.type == "Custom" then
		-- No custom skills yet
	end
	return value
end

function UNIT_SKILL:getEffectiveValue(Type)
	Type = Type or "LEVEL"
	local value = 0
	local unit = df.unit.find(self.unit.id)
	if self.type == "Normal" then
		local skillid = df.job_skill[self.token]
		if Type:upper() == "EXPERIENCE" then
			value = dfhack.units.getExperience(unit, skillid, true)
		elseif Type:upper() == "LEVEL" then
			value = dfhack.units.getEffectiveSkill(unit, skillid)
		end	
	elseif self.type == "Custom" then
		-- No custom skills yet
	end
	return value
end

--===============================================================================================--
--== UNIT GUI FUNCTIONS =========================================================================--
--===============================================================================================--
function UNIT:getAttributesDescription(Type)
	local strOut = ""
	local pronoun = self.Pronoun
	local attribute_string = reqscript("functions/text").attribute_string
	
	if Type == "Physical" then
		plusStr  = ""
		minusStr = ""
		for attribute,_ in pairs(self._unit.body.physical_attrs) do
			range = df.global.world.raws.creatures.all[self._unit.race].caste[self._unit.sex].attributes.phys_att_range[attribute]
			value = self._unit.body.physical_attrs[attribute].value
			tempstr, bin = attribute_string(attribute,value,range)
			if     bin > 0 then
				plusStr = plusStr..tempstr..", "
			elseif bin < 0 then
				minusStr = minusStr..tempstr..", "
			end
		end
		plusStr = fixString(plusStr)
		minusStr = fixString(minusStr)
		if plusStr == "" and minusStr == "" then
			strOut = pronoun.." is unremarkably average physically"
		elseif plusStr == "" then
			strOut = pronoun.." is "..minusStr
		elseif minusStr == "" then
			strOut = pronoun.." is "..plusStr
		else
			strOut = pronoun.." is "..plusStr..", but "..minusStr
		end
  
	elseif Type == "Mental" then
		plusStr  = ""
		minusStr = ""
		for attribute,_ in pairs(self._unit.status.current_soul.mental_attrs) do
			range = df.global.world.raws.creatures.all[self._unit.race].caste[self._unit.sex].attributes.ment_att_range[attribute]
			value = self._unit.status.current_soul.mental_attrs[attribute].value
			tempstr, bin = attribute_string(attribute,value,range)
			if     bin > 0 then
				plusStr = plusStr..tempstr..", "
			elseif bin < 0 then
				minusStr = minusStr..tempstr..", "
			end
		end
		plusStr = fixString(plusStr)
		minusStr = fixString(minusStr)
		if plusStr == "" and minusStr == "" then
			strOut = pronoun.." has unremarkably average mental attributes"
		elseif plusStr == "" then
			strOut = pronoun.." has "..minusStr
		elseif minusStr == "" then
			strOut = pronoun.." has "..plusStr
		else
			strOut = pronoun.." has "..plusStr..", but "..minusStr
		end 
	end
 
	return strOut
end

function UNIT:getAppearanceDescription()
	local list = self:getAppearanceDetails()
	local p1 = self.Pronoun1
	local p2 = self.Pronoun2
	local strings = {}
	local strTemps = {}
	local strOut = ""
	local modifiers = reqscript("functions/text").modifiers
	local styles = reqscript("functions/text").styles
	local hair_string = reqscript("functions/text").hair_string
	local color_string = reqscript("functions/text").color_string
	
	-- Need to actually generate the strings associated with the details
	for bp, tbl in pairs(list) do
		strings[bp] = {}
		for x, y in pairs(tbl) do
			if df.appearance_modifier_type[x] then
				strings[bp][x] = modifiers[df.appearance_modifier_type[x]][y.Bin]
			elseif x == "Color" then
				strings[bp][x] = y.String
			elseif x == "Style" then
				strings[bp][x] = styles[df.tissue_style_type[y.Value]]
			end
		end
	end

	strTemps["Body"] = ""
	if strings["Body"] then
		s1 = ""
		s2 = ""
		a = strings["Body"].HEIGHT or ""
		if a ~= "" then s1 = "is "..a end
		b = strings["Body"].BROADNESS or ""
		if b ~= "" then s2 = "a "..b.." frame" end
		if s2 ~= "" and s1 == "" then
			strTemps["Body"] = p1.." has "..s2..". "
		elseif s1 ~= "" and s2 == "" then
			strTemps["Body"] = p1.." "..s1..". "
		elseif s1 ~= "" and s2 ~= "" then
			strTemps["Body"] = p1.." "..s1.." with "..s2..". "
		end
	end
	strTemps["Hair"] = ""
	if strings["Hair"] then
		if strings["Hair"].Style == "clean shaven" then
			strTemps["Hair"] = p2.." hair is clean shaven. "
		else
			s1 = ""
			a = strings["Hair"].LENGTH or ""
			if a ~= "" then s1 = s1.." "..a.."," end
			b = strings["Hair"].CURLY  or ""
			if b ~= "" then s1 = s1.." "..b.."," end
			c = strings["Hair"].DENSE  or ""
			if c ~= "" then s1 = s1.." "..c.."," end
			d = strings["Hair"].Style  or ""
			if d ~= "" then s1 = s1.." "..d.."," end
			s1 = fixString(s1)
			e = strings["Hair"].Color  or ""
			if e ~= "" and s1 ~= "" then s1 = e..", "..s1 end
			if e ~= "" and s1 == "" then s1 = e end
			if s1 ~= "" then strTemps["Hair"] = p2.." hair is "..s1..". " end
		end
	end
	strTemps["Eyes"] = ""
	if strings["Eyes"] then
		s1 = ""
		a = strings["Eyes"].LARGE_IRIS or ""
		if a ~= "" then s1 = s1.." "..a.."," end
		b = strings["Eyes"].DEEP_SET or ""
		if b ~= "" then s1 = s1.." "..b.."," end
		c = strings["Eyes"].CLOSE_SET or ""
		if c ~= "" then s1 = s1.." "..c.."," end
		d = strings["Eyes"].ROUND_VS_NARROW or ""
		if d ~= "" then s1 = s1.." "..d.."," end
		s1 = fixString(s1)
		e = strings["Eyes"].Color or ""
		if e ~= "" and s1 ~= "" then 
			s1 = e..", "..s1 
		elseif e ~= "" and s1 == "" then
			s1 = e
		end
		if s1 ~= "" then strTemps["Eyes"] = p2.." eyes are "..s1..". " end
	end
	strTemps["Skin"] = ""
	if strings["Skin"] then
		s1 = ""
		a = strings["Skin"].WRINKLY or ""
		if a ~= "" then s1 = a..", " end
		b = strings["Skin"].Color or ""
		if b ~= "" then s1 = s1..b.." colored" end
		if s1 ~= "" then strTemps["Skin"] = p1.." has "..s1.." skin. " end
	end
	strTemps["Skull"] = ""
	if strings["skull"] then
		s1 = ""
		a = strings["skull"].BROAD_CHIN or ""
		if a ~= "" then s1 = s1.." "..a.."," end
		b = strings["skull"].SQUARE_CHIN or ""
		if b ~= "" then s1 = s1.." "..b.."," end
		c = strings["skull"].JUTTING_CHIN or ""
		if c ~= "" then s1 = s1.." "..c.."," end
		if s1 ~= "" then
			s1 = fixString(s1)
			strTemps["Skull"] = p2.." chin is "..s1..". "
		end
	end
	strTemps["Head"] = ""
	if strings["head"] then
		s1 = ""
		s2 = ""
		a = strings["head"].HEIGHT or ""
		b = strings["head"].BROADNESS or ""
		if a ~= "" and b ~= "" then
			s1 = a.." and "..b
		else
			s1 = a..b
		end
		c = strings["skull"].HIGH_CHEEKBONES or ""
		if c ~= "" then s2 = c.." cheekbones" end
		if s1 == "" and s2 ~= "" then
			strTemps["Head"] = p2.." head has "..s2..". "
		elseif s1 ~= "" and s2 == "" then
			strTemps["Head"] = p2.." head is "..s1..". "
		elseif s1 ~= "" and s2 ~= "" then
			strTemps["Head"] = p2.." head is "..s1.." with "..s2..". "
		end
	end
	strOut = strTemps["Body"]..strTemps["Skin"]..strTemps["Eyes"]..strTemps["Hair"]..strTemps["Head"]..strTemps["Skull"]

	return strOut
end

function UNIT:getAppearanceDetails()
	local raw = df.global.world.raws.creatures.all[unit.race].caste[unit.caste]
	local patterns = df.global.world.raws.descriptors.patterns
	local colors = df.global.world.raws.descriptors.colors
	local appearance = unit.appearance

	local body = {}
	local skin = {}
	local eyes = {}
	local hair = {}
	local ears = {}
	local nose = {}
	local otherColors = {}
	local otherHairs = {}
	local parts = {}
 
	for i,style in pairs(raw.tissue_styles) do
		for j,n in pairs(style.list_idx) do
			otherHairs[style.noun] = {
				PartName   = style.noun, 
				StyleToken = df.tissue_style_type[appearance.tissue_style[n]]}
			partN  = style.part_idx[j]
			layerN = style.layer_idx[j]
			bpart  = raw.body_info.body_parts[partN].layers[layerN]
			for k,idx in pairs(bpart.bp_modifiers) do
				x = raw.bp_appearance.modifier_idx[idx]
				val = appearance.bp_modifiers[idx]
				modifier = raw.bp_appearance.modifiers[x]
				y = 6
				for jdx,k in pairs(modifier.desc_range) do
					if val < k then
						y = jdx
						break
					end
				end
				y = y - 3
		
				Type = df.appearance_modifier_type[modifier.type]
				otherHairs[style.noun][Type] = {}
				otherHairs[style.noun][Type].n = val
				otherHairs[style.noun][Type].y = y
			end
		end
	end 
	hair = otherHairs.hair
	if not hair then hair = {} end
		otherHairs.hair = nil

	temp1 = {}
	temp2 = {}
	for i,n in pairs(appearance.colors) do
		x = raw.color_modifiers[i].pattern_index[n]
		part = raw.color_modifiers[i].part
		if part == "skin" then 
			skin.ColorToken = patterns[x].id
			skin.ColorString = color_string(patterns[x])
		elseif part == "eyes" then
			eyes.ColorToken = patterns[x].id
			eyes.ColorString = color_string(patterns[x])
		elseif part == "hair" then
			temp1[#temp1+1] = raw.color_modifiers[i]
			temp2[#temp2+1] = n
		else
			colorstring = color_string(patterns[x])
			partstring = raw.color_modifiers[i].part
			otherColors[part] = {
				PartName    = part, 
				PartString  = partstring, 
				ColorToken  = patterns[x].id, 
				ColorString = colorstring}
		end
	end
	if #temp1 == 1 then
		x = temp1[1].pattern_index[temp2[1]]
		hair.ColorToken = patterns[x].id
		hair.ColorString = colors[patterns[x].colors[0]].name
	else
		unitAge = dfhack.units.getAge(unit)*336
		mod1 = 1
		mod2 = 1
		found = false
		for i,mod in pairs(temp1) do
			if unitAge >= mod.start_date and unitAge <= mod.end_date then
				mod1 = i-1
				mod2 = i
				found = true
			elseif not found and unitAge > mod.end_date then
				mod1 = i
				mod2 = i
			end
		end
		x = temp1[mod2].pattern_index[temp2[mod2]]
		y = temp1[mod1].pattern_index[temp2[mod1]]
		hair.ColorToken = patterns[x].id
		if mod1 == mod2 then
			hair.ColorString = colors[patterns[x].colors[0]].name
		else
			d = (temp1[mod2].end_date - temp1[mod2].start_date)/6
			bin = 6
			for i = 1,6 do
				if unitAge < temp1[mod2].start_date + i*d then
					bin = i
					break
				end
			end
			hair.ColorString = hair_string(bin,x,y)
		end
	end
 
	for i,n in pairs(appearance.bp_modifiers) do
		x = raw.bp_appearance.modifier_idx[i]
		modifier = raw.bp_appearance.modifiers[x]
		partname = modifier.noun
		y = 6
		for j,k in pairs(modifier.desc_range) do
			if n < k then
				y = j
				break
			end
		end
		y = y - 3
		if partname == "" then
			pn = modifier.body_parts[0]
			bodypart = raw.body_info.body_parts[pn]
			partname = bodypart.name_singular[0].value
		end
		if partname == "eyes" then
			eyes[df.appearance_modifier_type[modifier.type]] = {}
			eyes[df.appearance_modifier_type[modifier.type]].n = n
			eyes[df.appearance_modifier_type[modifier.type]].y = y
		elseif partname == "ears" then
			ears[df.appearance_modifier_type[modifier.type]] = {}
			ears[df.appearance_modifier_type[modifier.type]].n = n
			ears[df.appearance_modifier_type[modifier.type]].y = y
		elseif partname == "nose" then
			nose[df.appearance_modifier_type[modifier.type]] = {}
			nose[df.appearance_modifier_type[modifier.type]].n = n
			nose[df.appearance_modifier_type[modifier.type]].y = y
		elseif partname == "hair" then
			-- Skip hair, already did it
		elseif partname == "skin" then
			if df.appearance_modifier_type[modifier.type] == "WRINKLY" then -- Why did I seperate this out?
				skin.Wrinkles_n = n
				skin.Wrinkles_y = y
			end
		else
			parts[partname] = parts[partname] or {}
			parts[partname][df.appearance_modifier_type[modifier.type]] = parts[partname][df.appearance_modifier_type[modifier.type]] or {}
			parts[partname][df.appearance_modifier_type[modifier.type]].n = n
			parts[partname][df.appearance_modifier_type[modifier.type]].y = y
		end
	end
 
	for i,n in pairs(appearance.body_modifiers) do
		modifier = raw.body_appearance_modifiers[i]
		y = 6
		for j,k in pairs(modifier.desc_range) do
			if n < k then
				y = j
				break
			end
		end
		y = y - 3
		body[df.appearance_modifier_type[modifier.type]] = body[df.appearance_modifier_type[modifier.type]] or {}
		body[df.appearance_modifier_type[modifier.type]].n = n
		body[df.appearance_modifier_type[modifier.type]].y = y
	end
 
	local list = {}
	-- Body appearance
	list.Body = {}
	for Type,_ in pairs(body) do
		list.Body[Type] = {Part="Body", Type=Type, Value=body[Type].n, Bin=body[Type].y, _colorBin=body[Type].y}
		list.Body[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Body[Type].Bin]  
	end
	-- Skin appearance
		list.Skin = {}
		list.Skin.Color   = {
			Part = "Skin",
			Type = "Color",
			Value = skin.ColorToken, 
			Bin = "--", 
			String = skin.ColorString}
		list.Skin.WRINKLY = {
			Part = "Skin",
			Type = "WRINKLY",
			Value = skin.Wrinkles_n, 
			Bin = skin.Wrinkles_y}
		list.Skin.WRINKLY.String = modifiers[df.appearance_modifier_type.WRINKLY][skin.Wrinkles_y]
	-- Eye appearance
	list.Eyes = {}
	list.Eyes.Color = {
		Part = "Eyes",
		Type = "Color", 
		Value = eyes.ColorToken, 
		Bin = "--", 
		String = eyes.ColorString}
	for Type,_ in pairs(eyes) do
		if Type ~= "ColorToken" and Type ~= "ColorString" then
			list.Eyes[Type] = {
				Part = "Eyes", 
				Type = Type, 
				Value = eyes[Type].n, 
				Bin = eyes[Type].y, 
				_colorBin = eyes[Type].y}
			list.Eyes[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Eyes[Type].Bin]
		end
	end
	-- Hair appearance
	list.Hair = {}
	list.Hair.Color = {
		Part="Hair", 
		Type="Color", 
		Value=hair.ColorToken, 
		Bin="--", 
		String=hair.ColorString}
	list.Hair.Style = {
		Part="Hair", 
		Type="Style", 
		Value=hair.StyleToken, 
		Bin="--", 
		String=styles[df.tissue_style_type[hair.StyleToken]]}
	for Type,_ in pairs(hair) do
		if Type ~= "ColorToken" and Type ~= "ColorString" and Type ~= "StyleToken" and Type ~= "PartName" then
			list.Hair[Type] = {
				Part="Hair", 
				Type=Type, 
				Value=hair[Type].n, 
				Bin=hair[Type].y, 
				_colorBin=hair[Type].y}
			list.Hair[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Hair[Type].Bin]
		end
	end
	-- Ear appearance
	list.Ears = {}
	for Type,_ in pairs(ears) do
		list.Ears[Type] = {
			Part="Ears", 
			Type=Type, 
			Value=ears[Type].n, 
			Bin=ears[Type].y, 
			_colorBin=ears[Type].y}
		list.Ears[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Ears[Type].Bin]
	end 
	-- Nose appearance
	list.Nose = {}
	for Type,_ in pairs(nose) do
		list.Nose[Type] = {
			Part="Nose", 
			Type=Type, 
			Value=nose[Type].n, 
			Bin=nose[Type].y, 
			_colorBin=nose[Type].y}
		list.Nose[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Nose[Type].Bin]
	end
	-- Other colors
	list.OtherColors = {}
	for i,other in pairs(otherColors) do
		--list.OtherColors[i] = {}
		list.OtherColors[i] = {
			Part=other.PartName, 
			Type="Color", 
			Value=other.ColorToken, 
			Bin="--", 
			String=other.ColorString}
	end
	-- Other hair styles (can they be colored differently???)
	for i,other in pairs(otherHairs) do
		list[i] = {}
		list[i].Style = {
			Part=other.PartName, 
			Type="Style", 
			Value=other.StyleToken, 
			Bin="--", 
			String=styles[df.tissue_style_type[other.StyleToken]]}
		for Type,_ in pairs(other) do
			if Type ~= "StyleToken" and Type ~= "PartName" then
				list[i][Type] = {
					Part=other.PartName, 
					Type=Type, 
					Value=other[Type].n, 
					Bin=other[Type].y, 
					_colorBin=other[Type].y}
				list[i][Type].String = modifiers[df.appearance_modifier_type[Type]][list[i][Type].Bin]
			end
		end
	end
	-- Body part modifier(s)
	for i,part in pairs(parts) do
		list[i] = {}
		for j,Type in pairs(part) do
			list[i][j] = {
				Part=i, 
				Type=j, 
				Value=Type.n, 
				Bin=Type.y, 
				_colorBin=Type.y}
			list[i][j].String = modifiers[df.appearance_modifier_type[j]][list[i][j].Bin]
		end
	end
 
	return list
end
