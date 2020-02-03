--@ module=true
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

--===============================================================================================--
--== UNIT CLASSES ===============================================================================--
--===============================================================================================--
UNIT             = defclass(UNIT)             -- references <df.unit>
UNIT_ACTION      = defclass(UNIT_ACTION)      -- references <df.unit_action>
UNIT_ATTACK      = defclass(UNIT_ATTACK)      -- references <df.caste_attack>
UNIT_ATTRIBUTE   = defclass(UNIT_ATTRIBUTE)   -- references <df.unit_attribute>
UNIT_BODY        = defclass(UNIT_BODY)        -- references <df.unit.T_body>
UNIT_BODYPART    = defclass(UNIT_BODYPART)    -- references <df.body_part_raw>
UNIT_PERSONALITY = defclass(UNIT_PERSONALITY) -- references <df.unit_personality>
UNIT_SKILL       = defclass(UNIT_SKILL)       -- references <df.unit_skill>

--===============================================================================================--
--== UNIT FUNCTIONS =============================================================================--
--===============================================================================================--
function UNIT:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(UNIT,key) then return rawget(UNIT,key) end
	local unit = df.unit.find(self.id)
	return unit[key]
end
function UNIT:init(unit)
	if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
	self.id = unit.id
	self._unit = unit
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

function UNIT:getAttribute(attribute)
	return UNIT_ATTRIBUTE({self._unit,attribute})
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

function UNIT:getPersonality()
	return UNIT_PERSONALITY({df.unit.find(self.id)})
end

function UNIT:getSkill(skill,add)
	local unit = df.unit.find(self.id)	
	local skillid = df.job_skill[skill]
	if not skillid then
		return UNIT_SKILL({unit.id,skill})
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

function UNIT:hasFlag(flag)
	local flags = {}
	local unit = df.unit.find(self.id)
	for k,v in pairs(unit.flags1) do flags[k] = v end
	for k,v in pairs(unit.flags2) do flags[k] = v end
	for k,v in pairs(unit.flags3) do flags[k] = v end
	return flags[flag] or false
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

function UNIT_ATTRIBUTE:changeValue(change)
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
	local unit = df.unit.find(self.unit_id)
	if self.type == "Normal" then
		skill = unit.status.current_soul.skills[id]
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
	local unit = df.unit.find(self.unit_id)
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