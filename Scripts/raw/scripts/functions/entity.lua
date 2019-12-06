local utils = require 'utils'
local split = utils.split_string

usages = {}

usages[#usages+1] = [===[
]===]

function decode_creatureToken(creatureToken)
	local spl = split(creatureToken,":")
	if #spl ~= 2 then
		error "creature expected in the form RACE:CASTE (e.g. DWARF:MALE)"
	end
	local race = spl[1]:upper()
	local caste = spl[2]:upper()
	local creatures = {}
	for i,x in ipairs(df.global.world.raws.creatures.all) do
		if race == x.creature_id or race == "ALL" then
			creatures[i] = {}
			if race ~= "ALL" then break end
		end
	end
	for i,_ in pairs(creatures) do
		for j,y in ipairs(df.global.world.raws.creatures.all[i].caste) do
			if caste == y.caste_id or caste == "ALL" then
				creatures[i][j] = true
				if caste ~= "ALL" then break end
			end
		end
	end
	return creatures
end

function decode_inorganicToken(inorganicToken)
	local inorganicToken = inorganicToken:upper()
	local inorganics = {}
	if inorganicToken == "ALL_METALS" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_METAL"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_GEMS" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_GEM"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_STONE" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_STONE"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_GLASS" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_GLASS"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_SAND" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["SOIL_SAND"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_CLAY" then
		-- Does clay have a material flag??? -ME
		--for i,x in pairs(df.global.world.raws.inorganics) do
		--	if x.material.flags["???"] then inorganics[i] = true
		--end
	else
		matinfo = dfhack.matinfo.find(inorganicToken)
		inorganics[matinfo.index] = true
	end
	return inorganics
end

function decode_itemToken(itemToken)
	local spl = split(itemToken,":")
	if #spl ~= 2 then
		error "itemToken expected in the form ITEM_TYPE:ITEM_SUBTYPE (e.g. ITEM_WEAPON:ITEM_WEAPON_SWORD_SHOT)"
	end
	local itemType = spl[1]:upper()
	local itemSubType = spl[2]:upper()
	local items = {}
	if itemType == "ITEM_AMMO" then
		ind = df.item_type["AMMO"]
	elseif itemType == "ITEM_ARMOR" then
		ind = df.item_type["ARMOR"]
	elseif itemType == "ITEM_GLOVES" then
		ind = df.item_type["GLOVES"]
	elseif itemType == "ITEM_HELM" then
		ind = df.item_type["HELM"]
	elseif itemType == "ITEM_INSTRUMENT" then
		ind = df.item_type["INSTRUMENT"]
	elseif itemType == "ITEM_PANTS" then
		ind = df.item_type["PANTS"]
	elseif itemType == "ITEM_SHIELD" then
		ind = df.item_type["SHIELD"]
	elseif itemType == "ITEM_SIEGEAMMO" then
		ind = df.item_type["SIEGEAMMO"]
	elseif itemType == "ITEM_SHOES" then
		ind = df.item_type["SHOES"]
	elseif itemType == "ITEM_TOOL" then
		ind = df.item_type["TOOL"]
	elseif itemType == "ITEM_TOY" then
		ind = df.item_type["TOY"]
	elseif itemType == "ITEM_TRAPCOMP" then
		ind = df.item_type["TRAPCOMP"]
	elseif itemType == "ITEM_WEAPON" then
		ind = df.item_type["WEAPON"]
	end
	if itemSubType == "ALL" then
		for i=0,dfhack.items.getSubtypeCount(ind)-1 do
			items[dfhack.items.getSubtypeDef(ind,i).subtype] = true
		end
	else
		for i=0,dfhack.items.getSubtypeCount(ind)-1 do
			if dfhack.items.getSubtypeDef(ind,i).id == itemSubType then
				items[dfhack.items.getSubtypeDef(ind,i).subtype] = true
				break
			end
		end
	end
	return items
end

function decode_materialToken(materialToken)
	local spl = split(materialToken,":")
	if #spl == 1 then
		temp = {}
		temp[0] = decode_inorganicToken(materialToken)
		return temp
	else
		return decode_organicToken(materialToken)
	end
end

function decode_organicToken(organicToken)
	local organics = {}
	if dfhack.matinfo.find(organicToken) then
		local mat = dfhack.matinfo.find(organicToken)
		organics[mat.type] = {}
		organics[mat.type][mat.index] = true
		return organics
	end
	local spl = split(organicToken,":")
	if #spl ~= 3 then
		error("organicToken expected in the form ORGANIC_TYPE:ORGANIC_SUBTYPE:ORGANIC_MATERIAL (e.g. CREATURE:DWARF:MEAT) - " .. organicToken)
	end
	local organicType = spl[1]:upper()
	local organicSubType = spl[2]:upper()
	local organicMaterial = spl[3]:upper()
	if organicType == "CREATURE" then
		organicTable = df.global.world.raws.creatures.all
		for i,organic in pairs(organicTable) do
			if organic.creature_id == organicSubType or organicSubType == "ALL" then
				organics[i] = {}
			end
		end
	elseif organicType == "PLANT" then
		organicTable = df.global.world.raws.plants.all
		for i,organic in pairs(organicTable) do
			if organic.id == organicSubType or organicSubType == "ALL" then
				organics[i] = {}
				if organicSubType ~= "ALL" then break end
			end
		end
	else
		error "Unrecognized ORGANIC_TYPE (CREATURE or PLANT)"
	end
	for i,_ in pairs(organics) do
		for j,material in pairs(organicTable[i].material) do
			if material.id == organicMaterial or organicMaterial == "ALL" then
				organics[i][j] = true
				if organicMaterial ~= "ALL" then break end
			end
		end
	end
	return organics
end

--===============================================================================================--
--== ENTITY FUNCTIONS ===========================================================================--
--===============================================================================================--
ENTITY = {}
ENTITY.__index = ENTITY
setmetatable(ENTITY, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function ENTITY:_init(entity)
	if tonumber(entity) then entity = df.global.world.entities.all[tonumber(entity)] end
	self.id = entity.id
end

function ENTITY:addCreature(creatureType,creatureToken)
	resource_races, resource_castes = self:getResourceTables("CREATURE",creatureType)
	if not resource_races then
		error "Invalid creatureType"
	end
	local creatures = decode_creatureToken(creatureToken)
	for i,x in pairs(creatures) do
		for j,_ in pairs(x) do
			resource_races:insert('#',i)
			resource_castes:insert('#',j)
		end
	end
end

function ENTITY:addInorganic(inorganicType,inorganicToken)
	resource_inorganic, _ = self:getResourceTables("INORGANIC",inorganicType)
	if not resource_inorganic then
		error "Invalid inorganicType"
	end
	local inorganics = decode_inorganicToken(inorganicToken,inorganicType)
	for i,_ in pairs(inorganics) do
		resource_inorganic:insert('#',i)
	end
end

function ENTITY:addItem(itemType,itemToken)
	resource_item, _ = self:getResourceTables("ITEM",itemType)
	if not resource_item then
		error "Invalid itemType"
	end
	local items = decode_itemToken(itemToken)
	for i,_ in pairs(items) do
		resource_item:insert('#',i)
	end
end

function ENTITY:addOrganic(organicType,organicToken)
	resource_matType, resource_matIndex = self:getResourceTables("ORGANIC",organicType)
	if not resource_matType then
		error "Invalid organicType"
	end
	local organics = decode_organicToken(organicToken)
	for mat_type,x in pairs(organics) do
		for mat_index,_ in pairs(x) do
			resource_matType:insert('#',mat_type)
			resource_matIndex:insert('#',mat_index)
		end
	end
end

function ENTITY:addProductMaterial(productType,materialToken)
	resource_matType, resource_matIndex = self:getResourceTables("PRODUCT",productType)
	if not resource_matType then
		error("Invalid productType - "..productType.." "..materialToken)
	end
	local materials = decode_materialToken(materialToken)
	for mat_type,x in pairs(materials) do
		if type(x) == "boolean" then
			resource_matType:insert('#',0)
			resource_matIndex:insert('#',mat_type)
		else
			for mat_index,_ in pairs(x) do
				resource_matType:insert('#',mat_type)
				resource_matIndex:insert('#',mat_index)
			end
		end
	end
end

function ENTITY:addSkill(skill_token)
	local entity = df.global.world.entities.all[self.id]
	if skill_token:upper() == "ALL" then
		for skill,_ in pairs(entity.resources.permitted_skill) do
			entity.resources.permitted_skill[skill] = true
		end
	else
		entity.resources.permitted_skill[skill_token] = true
	end
end

function ENTITY:changeEthic(ethic_token,change) end
function ENTITY:changeValue(value_token,change) end

function ENTITY:getResourceTables(resourceType,resourceSubType)
	local resource_A
	local resource_B
	entity = df.global.world.entities.all[self.id]
	if resourceType == "CREATURE" then
		local creatureType = resourceSubType:upper()
		if creatureType == "EXOTIC" then
			resource_A = entity.resources.animals.exotic_pet_races
			resource_B = entity.resources.animals.exotic_pet_castes
		elseif creatureType == "MINION" then
			resource_A = entity.resources.animals.minion_races
			resource_B = entity.resources.animals.minion_castes
		elseif creatureType == "MOUNT" then
			resource_A = entity.resources.animals.mount_races
			resource_B = entity.resources.animals.mount_castes
		elseif creatureType == "PACK" then
			resource_A = entity.resources.animals.pack_animal_races
			resource_B = entity.resources.animals.pack_animal_castes
		elseif creatureType == "PET" then
			resource_A = entity.resources.animals.pet_races
			resource_B = entity.resources.animals.pet_castes
		elseif creatureType == "WAGON" then
			resource_A = entity.resources.animals.wagon_puller_races
			resource_B = entity.resources.animals.wagon_puller_castes
		end
	elseif resourceType == "INORGANIC" then
		local inorganicType = resourceSubType:upper()
		if inorganicType == "CLAY" then
			resource_A = entity.resources.misc_mat.clay
		elseif inorganicType == "GEM" then
			resource_A = entity.resources.gems
		elseif inorganicType == "GLASS" then
			resource_A = entity.resources.misc_mat.glass
		elseif inorganicType == "METAL" then
			resource_A = entity.resources.metals
		elseif inorganicType == "SAND" then
			resource_A = entity.resources.misc_mat.sand
		elseif inorganicType == "STONE" then
			resource_A = entity.resources.stones
		end
	elseif resourceType == "ITEM" then
		local itemType = resourceSubType:upper()
		if itemType == "AMMO" then
			resource_A = entity.resources.ammo_type
		elseif itemType == "ARMOR" then
			resource_A = entity.resources.armor_type
		elseif itemType == "DIGGING_WEAPON" then
			resource_A = entity.resources.digger_type
		elseif itemType == "GLOVES" then
			resource_A = entity.resources.gloves_type
		elseif itemType == "HELM" then
			resource_A = entity.resources.helm_type
		elseif itemType == "INSTRUMENT" then
			resource_A = entity.resources.instrument_type
		elseif itemType == "PANTS" then
			resource_A = entity.resources.pants_type
		elseif itemType == "SHIELD" then
			resource_A = entity.resources.shield_type
		elseif itemType == "SIEGE_AMMO" then
			resource_A = entity.resources.siegeammo_type
		elseif itemType == "SHOES" then
			resource_A = entity.resources.shoes_type
		elseif itemType == "TOOL" then
			resource_A = entity.resources.tool_type
		elseif itemType == "TOY" then
			resource_A = entity.resources.toy_type
		elseif itemType == "TRAINING_WEAPON" then
			resource_A = entity.resources.training_weapon_type
		elseif itemType == "TRAP_COMPONENT" then
			resource_A = entity.resources.trapcomp_type
		elseif itemType == "WEAPON" then
			resource_A = entity.resources.weapon_type
		end
	elseif resourceType == "ORGANIC" then
		local organicType = resourceSubType:upper()
		if organicType == "BONE" then
			resource_A = entity.resources.refuse.bone.mat_type
			resource_B = entity.resources.refuse.bone.mat_index
		elseif organicType == "CHEESE" then
			resource_A = entity.resources.misc_mat.cheese.mat_type
			resource_B = entity.resources.misc_mat.cheese.mat_index
		elseif organicType == "DRINK" then
			resource_A = entity.resources.misc_mat.booze.mat_type
			resource_B = entity.resources.misc_mat.booze.mat_index
		elseif organicType == "EXTRACT" then
			resource_A = entity.resources.misc_mat.extracts.mat_type
			resource_B = entity.resources.misc_mat.extracts.mat_index
		elseif organicType == "HORN" then
			resource_A = entity.resources.refuse.horn.mat_type
			resource_B = entity.resources.refuse.horn.mat_index
		elseif organicType == "IVORY" then
			resource_A = entity.resources.refuse.ivory.mat_type
			resource_B = entity.resources.refuse.ivory.mat_index
		elseif organicType == "LEATHER" then
			resource_A = entity.resources.organic.leather.mat_type
			resource_B = entity.resources.organic.leather.mat_index
		elseif organicType == "MEAT" then
			resource_A = entity.resources.misc_mat.meat.mat_type
			resource_B = entity.resources.misc_mat.meat.mat_index
		elseif organicType == "PARCHMENT" then
			resource_A = entity.resources.organic.parchment.mat_type
			resource_B = entity.resources.organic.parchment.mat_index
		elseif organicType == "PEARL" then
			resource_A = entity.resources.refuse.pearl.mat_type
			resource_B = entity.resources.refuse.pearl.mat_index
		elseif organicType == "PLANT" then
			resource_A = entity.resources.plants.mat_type
			resource_B = entity.resources.plants.mat_index
		elseif organicType == "SEED" then
			resource_A = entity.resources.seeds.mat_type
			resource_B = entity.resources.seeds.mat_index
		elseif organicType == "SHELL" then
			resource_A = entity.resources.refuse.shell.mat_type
			resource_B = entity.resources.refuse.shell.mat_index
		elseif organicType == "SILK" then
			resource_A = entity.resources.organic.silk.mat_type
			resource_B = entity.resources.organic.silk.mat_index
		elseif organicType == "THREAD_CREATURE" then
			resource_A = entity.resources.organic.wool.mat_type
			resource_B = entity.resources.organic.wool.mat_index
		elseif organicType == "THREAD_PLANT" then
			resource_A = entity.resources.organic.fiber.mat_type
			resource_B = entity.resources.organic.fiber.mat_index
		elseif organicType == "WOOD" then
			resource_A = entity.resources.organic.wood.mat_type
			resource_B = entity.resources.organic.wood.mat_index
		end
	elseif resourceType == "PRODUCT_MATERIAL" or resourceType == "PRODUCT" then
		local productType = resourceSubType:upper()
		if productType == "AMMO" then
			resource_A = entity.resources.metal.ammo.mat_type
			resource_B = entity.resources.metal.ammo.mat_index
		elseif productType == "ANVIL" then
			resource_A = entity.resources.metal.anvil.mat_type
			resource_B = entity.resources.metal.anvil.mat_index
		elseif productType == "ARMOR" then
			resource_A = entity.resources.metal.armor.mat_type
			resource_B = entity.resources.metal.armor.mat_index
		elseif productType == "BACKPACK" then
			resource_A = entity.resources.misc_mat.backpacks.mat_type
			resource_B = entity.resources.misc_mat.backpacks.mat_index
		elseif productType == "BARREL" then
			resource_A = entity.resources.misc_mat.barrels.mat_type
			resource_B = entity.resources.misc_mat.barrels.mat_index
		elseif productType == "CAGE" then
			resource_A = entity.resources.misc_mat.cages.mat_type
			resource_B = entity.resources.misc_mat.cages.mat_index
		elseif productType == "CRAFTS" then
			resource_A = entity.resources.misc_mat.crafts.mat_type
			resource_B = entity.resources.misc_mat.crafts.mat_index
		elseif productType == "FLASK" then
			resource_A = entity.resources.misc_mat.flasks.mat_type
			resource_B = entity.resources.misc_mat.flasks.mat_index
		elseif productType == "INSTRUMENT" then
			resource_A = entity.resources.metal.armor.mat_type
			resource_B = entity.resources.metal.armor.mat_index
		elseif productType == "MELEE_WEAPON" then
			resource_A = entity.resources.metal.weapon.mat_type
			resource_B = entity.resources.metal.weapon.mat_index
		elseif productType == "PICK" then
			resource_A = entity.resources.metal.pick.mat_type
			resource_B = entity.resources.metal.pick.mat_index
		elseif productType == "QUIVER" then
			resource_A = entity.resources.misc_mat.quivers.mat_type
			resource_B = entity.resources.misc_mat.quivers.mat_index
		elseif productType == "RANGED_WEAPON" then
			resource_A = entity.resources.metal.ranged.mat_type
			resource_B = entity.resources.metal.ranged.mat_index
		elseif productType == "TOOL" then
			resource_A = entity.resources.metal.armor.mat_type
			resource_B = entity.resources.metal.armor.mat_index
		elseif productType == "TOY" then
			resource_A = entity.resources.metal.armor.mat_type
			resource_B = entity.resources.metal.armor.mat_index
		end
	end
	return resource_A, resource_B
end

function ENTITY:hasResource(resourceGroup,resourceToken)
	local found = false
	local spl = split(resourceGroup,":")
	resourceType = spl[1]
	resourceSubType = spl[2]
	resource_A, resource_B = self:getResourceTables(resourceType,resourceSubType)
	if resourceType == "CREATURE" then
		object = decode_creatureToken(resourceToken)
	elseif resourceType == "INORGANIC" then
		object = decode_inorganicToken(resourceToken)
	elseif resourceType == "ITEM" then
		object = decode_itemToken(resourceToken)
	elseif resourceType == "ORGANIC" then
		object = decode_organicToken(resourceToken)
	elseif resourceType == "PRODUCT" then
		object = decode_materialToken(resourceToken)
	end
	if not resource_A and not resource_B then
		--print(resourceType)
		--printall(object)
	elseif resource_B then
		for i,x in pairs(resource_A) do
			if object[x] and object[x][resource_B[i]] then
				found = true
				break
			end
		end
	else
		for i,x in pairs(resource_A) do
			if object[x] then
				found = true
				break
			end
		end
	end
	return found
end

function ENTITY:removeCreature(creatureType,creatureToken)
	resource_races, resource_castes = self:getResourceTables("CREATURE",creatureType)
	if not resource_races then
		error "Invalid creatureType"
	end
	local creatures = decode_creatureToken(creatureToken)
	local removing = {}
	for i,x in pairs(resource_races) do
		if creatures[x] and creatures[x][resource_castes[i]] then
			removing[#removing+1] = i
		end
	end
	for i = #removing,1,-1 do
		resource_races:erase(removing[i])
		resource_castes:erase(removing[i])
	end
end

function ENTITY:removeInorganic(inorganicType,inorganicToken)
	resource_inorganic, _ = self:getResourceTables("INORGANIC",inorganicType)
	if not resource_inorganic then
		error "Invalid inorganicType"
	end
	local inorganics = decode_inorganicToken(inorganicToken)
	for i=#resource_inorganic-1,0,-1 do
		if resource_inorganic[i] and inorganics[resource_inorganic[i]] then
			resource_inorganic:erase(i)
		end
	end
end

function ENTITY:removeItem(itemType,itemToken)
	resource_item, _ = self:getResourceTables("ITEM",itemType)
	if not resource_item then
		error "Invalid itemType"
	end
	local items = decode_itemToken(itemToken)
	for i=#resource_item-1,0,-1 do
		if resource_item[i] and items[resource_item[i]] then
			resource_item:erase(i)
		end
	end
end

function ENTITY:removeOrganic(organicType,organicToken)
	resource_matType, resource_matIndex = self:getResourceTables("ORGANIC",organicType)
	if not resource_matType then
		error "Invalid organicType"
	end
	local organics = decode_organicToken(organicToken)
	local removing = {}
	for i,x in pairs(resource_matType) do
		if organics[x] and organics[x][resource_matIndex[i]] then
			removing[#removing+1] = i
		end
	end
	for i = #removing,1,-1 do
		resource_matType:erase(removing[i])
		resource_matIndex:erase(removing[i])
	end
end

function ENTITY:removeProductMaterial(productType,materialToken)
	resource_matType, resource_matIndex = self:getResourceTables("PRODUCT",productType)
	if not resource_matType then
		error "Invalid productType"
	end
	local materials = decode_materialToken(materialToken)
	local removing = {}
	for i,x in pairs(resource_matType) do
		if materials[x] and materials[x][resource_matIndex[i]] then
			removing[#removing+1] = i
		end
	end
	for i = #removing,1,-1 do
		resource_matType:erase(removing[i])
		resource_matIndex:erase(removing[i])
	end
end

function ENTITY:removeSkill(skill_token)
	local entity = df.global.world.entities.all[self.id]
	if skill_token:upper() == "ALL" then
		for skill,_ in pairs(entity.resources.permitted_skill) do
			entity.resources.permitted_skill[skill] = false
		end
	else
		entity.resources.permitted_skill[skill_token] = false
	end 
end