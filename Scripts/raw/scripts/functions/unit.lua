local utils = require 'utils'
usages = {}

--===============================================================================================--
--== UNIT FUNCTIONS =============================================================================--
--===============================================================================================--
UNIT = {}
UNIT.__index = UNIT
setmetatable(UNIT, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT:_init(unit)
	if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
	self.id = unit.id
end
function UNIT:_dfhack(func)
	local unit = df.unit.find(self.id)
	return dfhack.units[func](unit)
end
function UNIT:_struct()
	return df.unit.find(self.id)
end

function UNIT:addAction(action_type,action_data) 
	if action_type:upper() == "TALK" then return end
	local unit = df.unit.find(self.id)
	action = df.unit_action:new()
	action.id = unit.next_action_id
	unit.next_action_id = unit.next_action_id + 1
	action.type = df.unit_action_type[action_type]
	for k,v in pairs(action_data) do
		if type(v) == "number" then
			action.data[action_type:lower()][k] = v
		else
			for k2,v2 in pairs(v) do
				action.data[action_type:lower()][k][k2] = v2
			end
		end
	end
	unit.actions:insert('#',action)
end

function UNIT:addSkill(skill)
	local unit = df.unit.find(self.id)
	local skillid = df.job_skill[skill]
	utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = 0},'id')
	return UNIT_SKILL(unit.id,skill)
end

function UNIT:changePosition(location)
	local unit = df.unit.find(self.id)
	local pos = {}
	pos.x = tonumber(location.x) or tonumber(location[1]) or tonumber(unit.pos.x)
	pos.y = tonumber(location.y) or tonumber(location[2]) or tonumber(unit.pos.y)
	pos.z = tonumber(location.z) or tonumber(location[3]) or tonumber(unit.pos.z)
	if pos.x < 0 or pos.y < 0 or pos.z < 0 then
		return
	end
	local unitoccupancy = dfhack.maps.getTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
	local newoccupancy = dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16]
	if newoccupancy.unit then
		unit.flags1.on_ground=true
	end
	unit.pos.x = pos.x
	unit.pos.y = pos.y
	unit.pos.z = pos.z
	if not unit.flags1.on_ground then 
		unitoccupancy.unit = false 
	else 
		unitoccupancy.unit_grounded = false 
	end
end

function UNIT:getActions(action_type)
	local action_type = action_type or "ALL"
	local out = {}
	local actions = df.unit.find(self.id).actions
	for i = #actions-1, 0, -1 do
		if actions[i] and actions[i]["type"] >= 0 then
			if (action_type:upper() == "ALL" or df.unit_action_type[action_type] == actions[i]["type"]) then
				if df.unit_action_type[actions[i]["type"]]:upper() ~= "TALK" then 
					out[#out+1] = UNIT_ACTION(self.id,actions[i])
				end
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
		out = UNIT_ATTACK(unit,attack_id)
	else
		for attack_id,attack in pairs(unit.body.body_plan.attacks) do
			if attack.name:upper() == name:upper() then
				out = UNIT_ATTACK(unit,attack_id)
			end
		end
	end
	return out
end

function UNIT:getAttribute(attribute)
	local unit = df.unit.find(self.id)
	return UNIT_ATTRIBUTE(unit.id,attribute)
end

function UNIT:getBody()
	return UNIT_BODY(self.id)
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
		parts[1] = UNIT_BODYPART(self.id,target)
	else
		for j,y in pairs(body.body_plan.body_parts) do
			if not body.components.body_part_status[j].missing then
				if value:upper() == "ALL"
					or (filter:upper() == "CATEGORY"  and y.category == value)
					or (filter:upper() == "TOKEN"     and y.token == value)
					or (filter:upper() == "FLAG"      and y.flags[value])
					or (filter:upper() == "CONNECTED" and y.con_part_id == value) then
					parts[#parts+1] = UNIT_BODYPART(self.id,j)
				end
			end
		end
	end
	return parts
end

function UNIT:getInteractions(interaction_type,interaction_name)
	local i_type = interaction_type or "BOTH"
	local i_name = interaction_name or "ALL"
	local unit = df.unit.find(self.id)
	local raws = df.global.world.raws.interactions
	local interactions = {}
	if i_type:upper() == "INNATE" or i_type:upper() == "BOTH" then
		for i,id in pairs(unit.curse.own_interaction) do
			if i_name:upper() == "ALL" or i_name == raws[id].name then interactions[#interactions+1] = UNIT_INTERACTION(unit,id,"INNATE") end
		end
	end
	if i_type:upper() == "LEARNED" or i_type:upper() == "BOTH" then
		for i,id in pairs(unit.curse.interaction_id) do
			if i_name:upper() == "ALL" or i_name == raws[id].name then interactions[#interactions+1] = UNIT_INTERACTION(unit,id,"LEARNED") end
		end
	end
	return interactions
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

function UNIT:getPosition(positionType)
	if not positionType or positionType:upper() == "CURRENT" then
		return df.unit.find(self.id).pos
	elseif positionType:upper() == "DESTINATION" then
	end
end

function UNIT:getSkill(skill)
	local unit = df.unit.find(self.id)	
	local skillid = df.job_skill[skill]
	if not skillid then
		return UNIT_SKILL(unit.id,skill)
	end
	local found = false
	for i,x in ipairs(unit.status.current_soul.skills) do
		if x.id == skillid then
			found = true
			break
		end
	end
	if found then
		return UNIT_SKILL(unit.id,skill)
	else
		return nil
	end
end

function UNIT:getSyndromes()
	local unit = df.unit.find(self.id)
	local syndromes = {}
	local raws = df.global.world.raws.syndromes.all
	for _,x in ipairs(unit.syndromes.active) do
		syndromes[#syndromes+1] = UNIT_SYNDROME(unit.id,x)
	end
	return syndromes
end

function UNIT:getTrait(trait)
	return UNIT_TRAIT(self.id,trait)
end

function UNIT:hasCreatureClass(class)
	local classes = {}
	local unit = df.unit.find(self.id)
	local caste_raws = df.creature_raw.find(unit.race).caste[unit.caste]
	for _,class in ipairs(caste_raws.creature_class) do classes[class.value] = class.value	end
	return classes[class]
end

function UNIT:hasCreatureToken(token)
	local tokens = {}
	local unit = df.unit.find(self.id)
	local race_raws = df.creature_raw.find(unit.race)
	local caste_raws = race_raws.caste[unit.caste]
	for k,v in pairs(race_raws.flags)  do tokens[k] = v end
	for k,v in pairs(caste_raws.flags) do tokens[k] = v end
	return tokens[token]
end

function UNIT:hasFlag(flag)
	local flags = {}
	local unit = df.unit.find(self.id)
	for k,v in pairs(unit.flags1) do flags[k] = v end
	for k,v in pairs(unit.flags2) do flags[k] = v end
	for k,v in pairs(unit.flags3) do flags[k] = v end
	return flags[flag]
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
UNIT_ACTION = {}
UNIT_ACTION.__index = UNIT_ACTION
setmetatable(UNIT_ACTION, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_ACTION:_init(unit_id,action)
	self.action = action
	self.type = df.unit_action_type[action.type]
	self.unit_id = unit_id
end

function UNIT_ACTION:removeAction()
	actions = df.unit.find(self.unit_id).actions
	for i = #actions-1, 0, -1 do
		print(actions[i].id, self.action.id)
		if actions[i].id == self.action.id then
			actions:erase(i)
			break
		end
	end
end

function UNIT_ACTION:changeDelay(change)
	local data = self.action.data[string.lower(self.type)]
	for t,_ in pairs(data) do
		if t == "timer" then
			data.timer = change
			break
		elseif t == "timer1" or t == "timer2" then
			data.timer1 = change
			data.timer2 = change
			break
		end
	end
end

function UNIT_ACTION:getData()
	return self.action.data[string.lower(self.type)]
end

function UNIT_ACTION:getDelay()
	local value = -1
	local data = self.action.data[string.lower(self.type)]
	for t,_ in pairs(data) do
		if t == "timer" then
			value = data.timer
			break
		elseif t == "timer1" or t == "timer2" then
			value = data.timer1
			break
		end
	end
	return value
end

--===============================================================================================--
--== UNIT_ATTACK FUNCTIONS ======================================================================--
--===============================================================================================--
UNIT_ATTACK = {}
UNIT_ATTACK.__index = UNIT_ATTACK
setmetatable(UNIT_ATTACK, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_ATTACK:_init(unit,attack_id)
	self.id = tonumber(attack_id)
	self.attack = unit.body.body_plan.attacks[attack_id]
	self.unit_id = unit.id
end

function UNIT_ATTACK:computeMomentum()
	local unit = df.unit.find(self.unit_id)
	local attack = self.attack
	local vel_mod = attack.velocity_modifier
	local strength = dhack.units.getPhysicalAttrValue(unit,df.physical_attribute_type["STRENGTH"])
	local velocity = 100*(strength/1000)*(vel_mod/1000)
	if velocity < 1 then velocity = 1 end
	
	local body_part = UNIT_BODYPART(unit.id,attack.body_part_idx[0])
	local tl_id = attack.tissue_layer_idx[0]
	
	local partsize = body_part:computeSize()
	local density = 0
	if tl_id == -1 then
		density = body_part:computeAverageDensity()
	else
		local tissue_data = df.global.world.raws.creatures.all[unit.race].tissue[tl_id]
		density = dfhack.matinfo.decode(tissue_data.mat_type,tissue_data.mat_index).material.solid_density
	end
	local weight = partsize*(density/100)
	local momentum = (velocity*weight)/1000 + 1
	
	return math.floor(momentum+0.5)
end

function UNIT_ATTACK:computeVelocity()
	local unit = df.unit.find(self.unit_id)
	local attack = self.attack
	local vel_mod = attack.velocity_modifier
	local strength = dfhack.units.getPhysicalAttrValue(unit,df.physical_attribute_type["STRENGTH"])
	local velocity = 100*(strength/1000)*(vel_mod/1000)
	if velocity < 1 then velocity = 1 end

	return math.floor(velocity+0.5)
end

--===============================================================================================--
--== UNIT_ATTRIBUTE FUNCTIONS ===================================================================--
--===============================================================================================--
UNIT_ATTRIBUTE = {}
UNIT_ATTRIBUTE.__index = UNIT_ATTRIBUTE
setmetatable(UNIT_ATTRIBUTE, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_ATTRIBUTE:_init(unit_id,attribute_token)
	self.token = attribute_token
	self.unit_id = unit_id
	self.min_val = 0
	self.max_val = 50000
	if df.physical_attribute_type[attribute_token] then
		self.type = "Physical"
	elseif df.mental_attribute_type[attribute_token] then
		self.type = "Mental"
	else
		self.type = "Custom"
	end
end

function UNIT_ATTRIBUTE:changeValue(change)
	if change == 0 then return change end
	local unit = df.unit.find(self.unit_id)
	local current = self:getBaseValue()
	if self.type == "Physical" then
		unit.body.physical_attrs[self.token].value = current + change
	elseif self.type == "Mental" then
		unit.status.current_soul.mental_attrs[self.token].value = current + change
	elseif self.type == "Custom" then
		-- No custom attrtibutes yet
	end
	return change
end

function UNIT_ATTRIBUTE:computeChange(value,mode)
	value = tonumber(value)
	local change = 0
	local current = self:getBaseValue()
	local mode = mode or "FIXED"
	if mode:upper() == "FIXED" then
		change = value
	elseif mode:upper() == "PERCENT" then
		local percent = value/100
		change = current*percent - current
	elseif mode:upper() == "SET" then
		change = value - current
	else
		change = value
	end
	if current + change > self.max_val then
		change = self.max_val - current
	elseif current + change < self.min_val then
		change = self.min_val - current
	end	
	return math.floor(change+0.5)
end

function UNIT_ATTRIBUTE:getBaseValue()
	local value = 0
	local unit = df.unit.find(self.unit_id)
	if self.type == "Physical" then
		value = unit.body.physical_attrs[self.token].value
	elseif self.type == "Mental" then
		value = unit.status.current_soul.mental_attrs[self.token].value
	elseif self.type == "Custom" then
		-- No custom attrtibutes yet
	end
	return value
end

function UNIT_ATTRIBUTE:getCurseValue()
	local base = self:getBaseValue()
	local efct = self:getEffectiveValue()
	return efct - base
end

function UNIT_ATTRIBUTE:getEffectiveValue()
	local value = 0
	local unit = df.unit.find(self.unit_id)
	if self.type == "Physical" then
		value = dfhack.units.getPhysicalAttrValue(unit,df.physical_attribute_type[self.token])
	elseif self.type == "Mental" then
		value = dfhack.units.getMentalAttrValue(unit,df.mental_attribute_type[self.token])
	elseif self.type == "Custom" then
		-- No custom attrtibutes yet
	end
	return value
end

--===============================================================================================--
--== UNIT_BODY FUNCTIONS ========================================================================--
--===============================================================================================--
UNIT_BODY = {}
UNIT_BODY.__index = UNIT_BODY
setmetatable(UNIT_BODY, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_BODY:_init(unit_id)
	self.unit_id = unit_id
end

function UNIT_BODY:changeValue(changeType,change)
	if change == 0 then return change end
	local unit = df.unit.find(self.unit_id)
	if changeType:upper() == "SIZE" then
		unit.body.size_info.size_cur = unit.body.size_info.size_cur + change
	elseif changeType:upper() == "AREA" then
		unit.body.size_info.area_cur = unit.body.size_info.area_cur + change
	elseif changeType:upper() == "LENGTH" then
		unit.body.size_info.length_cur = unit.body.size_info.length_cur + change
	end
end

function UNIT_BODY:computeChange(changeType,value,mode)
	local unit = df.unit.find(self.unit_id)
	local value = tonumber(value)
	local mode = mode or "FIXED"
	local change = 0
	local current = 0
	if changeType:upper() == "SIZE" then
		current = unit.body.size_info.size_cur
	elseif changeType:upper() == "AREA" then
		current = unit.body.size_info.area_cur
	elseif changeType:upper() == "LENGTH" then
		current = unit.body.size_info.length_cur
	end
	if mode:upper() == "FIXED" then
		change = value
	elseif mode:upper() == "PERCENT" then
		local percent = value/100
		change = current*percent - current
	elseif mode:upper() == "SET" then
		change = value - current
	else
		change = value
	end
	return math.floor(change+0.5)
end

--===============================================================================================--
--== UNIT_BODYPART FUNCTIONS ====================================================================--
--===============================================================================================--
UNIT_BODYPART = {}
UNIT_BODYPART.__index = UNIT_BODYPART
setmetatable(UNIT_BODYPART, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_BODYPART:_init(unit_id,bp_id)
	self.id = bp_id
	self.unit_id = unit_id
end

function UNIT_BODYPART:changeStatus(status)
	local unit = df.unit.find(self.unit_id)
	if status:upper() == "FIRE" then
		unit.body.components.body_part_status[self.id].on_fire = not unit.body.components.body_part_status[self.id].on_fire
	end
end

function UNIT_BODYPART:changeValue(changeType,change)
	if change == 0 then return change end
	local unit = df.unit.find(self.unit_id)
	if changeType:upper() == "TEMPERATURE" then
		unit.status2.body_part_temperature[self.id].whole = unit.status2.body_part_temperature[self.id].whole + change
	end
end

function UNIT_BODYPART:computeAverageDensity()
	local unit = df.unit.find(self.unit_id)
	local body_part = unit.body.body_plan.body_parts[self.id]
	local raws = df.global.world.raws.creatures.all[unit.race]
	local solid_density = 0
	for _,layer in pairs(body_part.layers) do
		local frac = layer.part_fraction
		local tissue_data = raws.tissue[layer.tissue_id]
		local material = dfhack.matinfo.decode(tissue_data.mat_type,tissue_data.mat_index).material
		solid_density = solid_density + frac*material.solid_density
	end
	return solid_density
end

function UNIT_BODYPART:computeChange(changeType,value,mode)
	local value = tonumber(value)
	local mode = mode or "FIXED"
	local change = 0
	local current = 0
	if changeType:upper() == "TEMPERATURE" then
		current = unit.status2.body_part_temperature[self.id].whole
	end
	if mode:upper() == "FIXED" then
		change = value
	elseif mode:upper() == "PERCENT" then
		local percent = value/100
		change = current*percent - current
	elseif mode:upper() == "SET" then
		change = value - current
	else
		change = value
	end
	return math.floor(change+0.5)
end

function UNIT_BODYPART:computeSize()
	local unit = df.unit.find(self.unit_id)
	local body_part = unit.body.body_plan.body_parts[self.id]
	return (unit.body.size_info.size_cur*body_part.relsize)/unit.body.body_plan.total_relsize
end

function UNIT_BODYPART:getStatus(status)
	local unit = df.unit.find(self.unit_id)
	if status:upper() == "FIRE" then
		return unit.body.components.body_part_status[self.id].on_fire
	end
end

--===============================================================================================--
--== UNIT_INTERACTION FUNCTIONS =================================================================--
--===============================================================================================--
UNIT_INTERACTION = {}
UNIT_INTERACTION.__index = UNIT_INTERACTION
setmetatable(UNIT_INTERACTION, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_INTERACTION:_init(unit,interaction_id,interaction_type)
	self.id = interaction_id --<int>
	self.unit_id = unit.id --<int>
	self.type = interaction_type --<string>
	if interaction_type == "INNATE" then
		self.details = unit.body.body_plan.interactions[interaction_id].interaction --<creature_interaction>
	elseif interaction_type == "LEARNED" then
		self.details = df.global.world.raws.effects.all[interaction_id].interaction --<creature_interaction>
	end
	self.interaction_raw = df.global.world.raws.interactions[self.details.type_id] --<interaction>
	self.name = self.details.adv_name	
end

function UNIT_INTERACTION:changeDelay(change)
	local unit = df.unit.find(self.unit_id)
	if self.type == "INNATE" then
		for i,id in pairs(unit.curse.own_interaction) do
			if id == self.id then
				unit.curse.own_interaction_delay[i] = change
			end
		end
	elseif self.type == "LEARNED" then
		for i, id in pairs(unit.curse.interaction_id) do
			if id == self.id then
				unit.curse.interaction_delay[i] = change
			end
		end
	end
end

function UNIT_INTERACTION:getDelay(change)
	local value = -1
	local unit = df.unit.find(self.unit_id)
	if self.type == "INNATE" then
		for i,id in pairs(unit.curse.own_interaction) do
			if id == self.id then
				value = unit.curse.own_interaction_delay[i]
			end
		end
	elseif self.type == "LEARNED" then
		for i, id in pairs(unit.curse.interaction_id) do
			if id == self.id then
				value = unit.curse.interaction_delay[i]
			end
		end
	end
	return value
end

--===============================================================================================--
--== UNIT_SKILL FUNCTIONS =======================================================================--
--===============================================================================================--
UNIT_SKILL = {}
UNIT_SKILL.__index = UNIT_SKILL
setmetatable(UNIT_SKILL, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_SKILL:_init(unit_id,skill_token)
	self.token = skill_token
	self.unit_id = unit_id
	self.min_val = 0
	self.max_val = 50
	if df.job_skill[skill_token] then
		self.type = "Normal"
		self.skillid = df.job_skill[skill_token]
	else
		self.type = "Custom"
	end
end

function UNIT_SKILL:changeValue(Type,change) -- NEED TO ADD UNIT_SKILL LEVELING UP!
	if change == 0 then return change end
	local unit = df.unit.find(self.unit_id)
	if self.type == "Normal" then
		local id = -1
		for i,x in ipairs(unit.status.current_soul.skills) do
			if x.id == self.skillid then
				id = i
				break
			end
		end
		if id < 0 then return end
		if Type:upper() == "EXPERIENCE" then
			unit.status.current_soul.skills[id].experience = unit.status.current_soul.skills[id].experience + change
		elseif Type:upper() == "LEVEL" then
			unit.status.current_soul.skills[id].rating = unit.status.current_soul.skills[id].rating + change
		end
	elseif self.type == "Custom" then
		-- No custom skills yet
	end
end

function UNIT_SKILL:computeChange(Type,value,mode)
	value = tonumber(value)
	local change = 0
	local current = self:getBaseValue(Type)
	local mode = mode or "FIXED"
	if mode:upper() == "FIXED" then
		change = value
	elseif mode:upper() == "PERCENT" then
		local percent = value/100
		change = current*percent - current
	elseif mode:upper() == "SET" then
		change = value - current
	else
		change = value
	end
	if Type == "LEVEL" then
		if current + change > self.max_val then
			change = self.max_val - current
		elseif current + change < self.min_val then
			change = self.min_val - current
		end
	end
	return math.floor(change+0.5)
end

function UNIT_SKILL:getBaseValue(Type)
	Type = Type or "LEVEL"
	local value = 0
	local unit = df.unit.find(self.unit_id)
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
	local unit = df.unit.find(self.unit_id)
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
--== UNIT_SYNDROME FUNCTIONS ====================================================================--
--===============================================================================================--
UNIT_SYNDROME = {}
UNIT_SYNDROME.__index = UNIT_SYNDROME
setmetatable(UNIT_SYNDROME, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_SYNDROME:_init(unit_id,syndrome)
	self.type = syndrome.type
	self.infect_time = {syndrome.year,syndrome.year_time}
	self.unit_id = unit_id
	self.syndrome_raw = df.global.world.raws.syndromes.all[syndrome.type] --<syndrome>
	self.name = df.global.world.raws.syndromes.all[syndrome.type].syn_name
end

function UNIT_SYNDROME:getClasses()
	local classes = {}
	for _,v in pairs(self.syndrome_raw.syn_class) do
		classes[v.value] = v.value
	end
	return classes
end

--===============================================================================================--
--== UNIT_TRAIT FUNCTIONS =======================================================================--
--===============================================================================================--
UNIT_TRAIT = {}
UNIT_TRAIT.__index = UNIT_TRAIT
setmetatable(UNIT_TRAIT, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function UNIT_TRAIT:_init(unit_id,trait_token)
	self.token = trait_token
	self.unit_id = unit_id
	self.min_val = -100
	self.max_val = 100
	if df.unit.find(unit_id).status.current_soul.personality.traits[trait_token] then
		self.type = "Normal"
	else
		self.type = "Custom"
	end
end

function UNIT_TRAIT:changeValue(change)
	local unit = df.unit.find(self.unit_id)
	if self.type == "Normal" then
		unit.status.current_soul.personality.traits[self.token] = unit.status.current_soul.personality.traits[self.token] + change
	elseif self.type == "Custom" then
		-- No custom traits yet
	end
end

function UNIT_TRAIT:computeChange(value,mode)
	value = tonumber(value)
	local change = 0
	local current = self:getBaseValue()
	local mode = mode or "FIXED"
	if mode:upper() == "FIXED" then
		change = value
	elseif mode:upper() == "PERCENT" then
		local percent = value/100
		change = current*percent - current
	elseif mode:upper() == "SET" then
		change = value - current
	else
		change = value
	end
	if current + change > self.max_val then
		change = self.max_val - current
	elseif current + change < self.min_val then
		change = self.min_val - current
	end	
	return math.floor(change+0.5)
end

function UNIT_TRAIT:getBaseValue()
	local unit = df.unit.find(self.unit_id)
	if self.type == "Normal" then
		return unit.status.current_soul.personality.traits[self.token]
	elseif self.type == "Custom" then
		-- No custom traits yet
	end
end







function UNIT:changeCounter(counter,change)
	local unit = df.unit.find(self.id)
	local new = 0
	local counter = string.lower(counter)
	if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
		or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
		unit.counters[counter] = unit.counters[counter] + change
		new = unit.counters[counter]
	elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
		or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
		or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
		if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
		unit.counters2[counter] = unit.counters2[counter] + change
		new = unit.counters2[counter]
	elseif counter == 'blood' or counter == 'infection' then
		unit.body[counter] = unit.body[counter] + change
		new = unit.body[counter]
	end
	return new
end
  
function UNIT:getCounterValue(counter)
	local unit = df.unit.find(self.id)
	local counter = string.lower(counter)
	local value = 0
	if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
		or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
		value = unit.counters[counter]
	elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
		or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
		or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
		if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
		value = unit.counters2[counter]
	elseif counter == 'blood' or counter == 'infection' then
		value = unit.body[counter]
	end
	return value
end





function create() end

function destroy () end

function locate() end