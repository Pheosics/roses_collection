usages = {}

usages[#usages+1] = [===[
]===]

--===============================================================================================--
--== ITEM FUNCTIONS ==============================================================================--
--===============================================================================================--

ITEM = {}
ITEM.__index = ITEM
setmetatable(ITEM, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function ITEM:_init(item)
	if tonumber(item) then item = df.item.find(tonumber(item)) end
	self.id = item.id
end

function ITEM:getAttack(attack_verb)
	local verb = attack_verb or "RANDOM"
	local item = df.item.find(self.id)
	if verb:upper() == "RANDOM" then
		local rand = dfhack.random.new()
		local weights = {}
		weights[0] = 0
		local n = 0
		for _,attacks in pairs(item.subtype.attacks) do
			if attacks.edged then x = 100 else x = 1 end
			n = n + 1
			weights[n] = weights[n-1] + x
		end
		local pick = rand:random(weights[n])
		for i = 1,n do
			if pick >= weights[i-1] and pick < weights[i] then attack = i-1 break end
		end
		if not attack then attack = n end
		out = ITEM_ATTACK(item.id,item.subtype.attacks[attack])
	else
		for _,attack in pairs(item.subtype.attacks) do
			if attack.verb_2nd:upper() == verb:upper() 
				or attack.verb_3rd:upper() == verb:upper() then
				out = ITEM_ATTACK(item.id,attack)
				break
			end
		end
	end
	return out
end

function ITEM:changeMaterial(material)
	local item = df.item.find(self.id)
	local mat = dfhack.matinfo.find(material)
	if not mat then return end
	item.mat_type = mat.type
	item.mat_index = mat.index
end

function ITEM:changeQuality(quality)
	local item = df.item.find(self.id)
	if quality > 5 then quality = 5 end
	if quality < 0 then quality = 0 end
	item:setQuality(quality)
end

function ITEM:changeStackSize(change)
	local item = df.item.find(self.id)
	item.stack_size = item.stack_size + change
end

function ITEM:changeSubtype(subtype)
	local item = df.item.find(self.id)
	local itemType = item:getType()
	for i = 0, dfhack.items.getSubtypeCount(itemType)-1, 1 do
		local item_sub = dfhack.items.getSubtypeDef(itemType,i)
		if item_sub.id == subtype then
			item:setSubtype(item_sub.subtype)
			break
		end
	end
end

function ITEM:getMaterial()
	local item = df.item.find(self.id)
	return dfhack.matinfo.getToken(item.mat_type,item.mat_index)
end

function ITEM:getQuality()
	local item = df.item.find(self.id)
	return item.quality
end

function ITEM:getStackSize()
	return df.item.find(self.id).stack_size
end

function ITEM:getSubtype()
	local item = df.item.find(self.id)
	local itemType = item:getType()
	local itemSubtype = item:getSubtype()
	return dfhack.items.getSubtypeDef(itemType,itemSubtype).id
end

function ITEM:makeProjectile(projectileType,origin,velocity,options)
	local item = df.item.find(self.id)
	dfhack.items.moveToGround(item,origin)
	local velocity = velocity or {0,0,0}
	if options then
		target = options.target
		hit_chance = options.accuracy or 50
		max_range = options.range or 10
		min_range = options.minimum or 1
	end

	proj = dfhack.items.makeProjectile(item)
	proj.origin_pos.x = origin[1] or origin.x
	proj.origin_pos.y = origin[2] or origin.y
	proj.origin_pos.z = origin[3] or origin.z
	proj.prev_pos.x   = origin[1] or origin.x 
	proj.prev_pos.y   = origin[2] or origin.y
	proj.prev_pos.z   = origin[3] or origin.z
	proj.cur_pos.x    = origin[1] or origin.x
	proj.cur_pos.y    = origin[2] or origin.y
	proj.cur_pos.z    = origin[3] or origin.z
	proj.flags.no_impact_destroy = false

	if projectileType:upper() == "FALLING" then
		proj.flags.bouncing          = true
		proj.flags.piercing          = true
		proj.flags.parabolic         = true
		proj.flags.unk9              = true
		proj.flags.no_collide        = true
		proj.speed_x = velocity[1] or velocity.x or velocity or 0
		proj.speed_y = velocity[2] or velocity.y or velocity or 0
		proj.speed_z = velocity[3] or velocity.z or velocity or 0
	elseif projectileType:upper() == "SHOOTING" then
		proj.target_pos.x = target[1] or target.x
		proj.target_pos.y = target[2] or target.y
		proj.target_pos.z = target[3] or target.z
		proj.flags.bouncing          = false
		proj.flags.piercing          = false
		proj.flags.parabolic         = false
		proj.flags.unk9              = false
		proj.flags.no_collide        = false
		proj.distance_flown = 0
		proj.fall_threshold = max_range or 10
		proj.min_hit_distance = min_range or 1
		proj.min_ground_distance = max_range-1 or 9
		proj.fall_counter = 0
		proj.fall_delay = 0
		proj.hit_rating = hit_change or 50
		proj.unk22 = velocity[0] or velocity or 20
		proj.speed_x = 0
		proj.speed_y = 0
		proj.speed_z = 0
		proj.firer = nil
	end
end

--===============================================================================================--
--== ITEM_ATTACK FUNCTIONS ======================================================================--
--===============================================================================================--
ITEM_ATTACK = {}
ITEM_ATTACK.__index = ITEM_ATTACK
setmetatable(ITEM_ATTACK, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function ITEM_ATTACK:_init(item_id,attack)
	self.attack = attack
	self.item_id = item_id
end

function ITEM_ATTACK:computeVelocity()
	local item = df.item.find(self.item_id)
	local unit = dfhack.items.getHolderUnit(item)
	local material = dfhack.matinfo.decode(item.mat_type,item.mat_index).material
		
	local actweight = item.subtype.size*(material.solid_density/100)
	local effweight = unit.body.size_info.size_cur/100 + actweight
	local vel_mod = self.attack.velocity_mult
	local strength = dfhack.units.getPhysicalAttrValue(unit,df.physical_attribute_type["STRENGTH"])
	local velocity = unit.body.size_info.size_base*strength*(vel_mod/1000)*(effweight/1000)
	if velocity < 1 then velocity = 1 end
	local momentum = (velocity*actweight)/1000 + 1

	return math.floor(velocity)
end

function create(item,material,creatorID,quality) --from modtools/create-item
	quality = tonumber(quality) or 0
	creatorID = tonumber(creatorID) or -1
	if creatorID == -1 then creatorID = df.global.world.units.active[0].id end

	local itemType = dfhack.items.findType(item)
	if itemType == -1 then return end
	local itemSubtype = dfhack.items.findSubtype(item)
	local material = dfhack.matinfo.find(material)
	if not material then return end
	item = dfhack.items.createItem(itemType, itemSubtype, material.type, material.index, df.unit.find(creatorID))
	
	return ITEM(item)
end

function destroy () end

function locate() end

function makeProjectile() end

function move() end