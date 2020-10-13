--@ module=true
local utils = require 'utils'
local split = utils.split_string
local decode = reqscript("functions/io")

info = {}
info["ENTITY"] = [===[ TODO ]===]

validResources = {
	CREATURE  = {dual_resource = true,
		EXOTIC = {"animals","exotic_pet_races","exotic_pet_castes"},
		MINION = {"animals","minion_races","minion_castes"},
		MOUNT  = {"animals","mount_races","mount_castes"},
		PACK   = {"animals","pack_animal_races","pack_animal_castes"},
		PET    = {"animals","pet_races","pet_castes"},
		WAGON  = {"animals","wagon_puller_races","wagon_puller_castes"},
	},
	INORGANIC = {dual_resource = false,
		METAL = {"metals"},
		STONE = {"stones"},
		GEM   = {"gems"},
		GLASS = {"misc_mat","glass"},
		SAND  = {"misc_mat","sand"},
		CLAY  = {"misc_mat","clay"},
	},
	ITEM      = {dual_resource = false,
		WEAPON     = {"weapon_type"},
		SHIELD     = {"shield_type"},
		AMMO       = {"ammo_type"},
		HELM       = {"helm_type"},
		ARMOR      = {"armor_type"},
		PANTS      = {"pants_type"},
		SHOES      = {"shoes_type"},
		GLOVES     = {"gloves_type"},
		TRAP       = {"trap_type"},
		SIEGE      = {"siegeammo_type"},
		TOY        = {"toy_type"},
		INSTRUMENT = {"instrument_type"},
		TOOL       = {"tool_type"},
	},
	ORGANIC   = {dual_resource = true,
		LEATHER   = {"organic","leather","mat_type","mat_index"},
		FIBER     = {"organic","fiber","mat_type","mat_index"},
		SILK      = {"organic","silk","mat_type","mat_index"},
		WOOL      = {"organic","wool","mat_type","mat_index"},
		WOOD      = {"organic","wood","mat_type","mat_index"},
		PLANT     = {"plants","mat_type","mat_index"},
		SEED      = {"seeds","mat_type","mat_index"},
		BONE      = {"refuse","bone","mat_type","mat_index"},
		MEAT      = {"misc_mat","meat","mat_type","mat_index"},
		CHEESE    = {"misc_mat","cheese","mat_type","mat_index"},
		SHELL     = {"refuse","shell","mat_type","mat_index"},
		IVORY     = {"refuse","ivory","mat_type","mat_index"},
		HORN      = {"refuse","horn","mat_type","mat_index"},
		PEARL     = {"refuse","pearl","mat_type","mat_index"},
		DRINK     = {"misc_mat","booze","mat_type","mat_index"},
		EXTRACT   = {"misc_mat","extracts","mat_type","mat_index"},
		PARCHMENT = {"organic","parchment","mat_type","mat_index"},
	},
	PRODUCT   = {dual_resource = true,
		PICK      = {"metal","pick","mat_type","mat_index"},
		MELEE     = {"metal","weapon","mat_type","mat_index"},
		RANGED    = {"metal","ranged","mat_type","mat_index"},
		AMMO      = {"metal","ammo","mat_type","mat_index"},
		ARMOR     = {"metal","armor","mat_type","mat_index"},
		ANVIL     = {"metal","anvil","mat_type","mat_index"},
		CRAFTS    = {"misc_mat","crafts","mat_type","mat_index"},
		BARRELS   = {"misc_mat","barrels","mat_type","mat_index"},
		FLASKS    = {"misc_mat","flasks","mat_type","mat_index"},
		QUIVERS   = {"misc_mat","quivers","mat_type","mat_index"},
		BACKPACKS = {"misc_mat","backpacks","mat_type","mat_index"},
		CAGES     = {"misc_mat","cages","mat_type","mat_index"},
	}
}

--===============================================================================================--
--== ENTITY CLASSES =============================================================================--
--===============================================================================================--
local ENTITY = defclass(ENTITY) -- refrences <historical_entity>
function getEntity(entity) return ENTITY(entity) end

--===============================================================================================--
--== ENTITY FUNCTIONS ===========================================================================--
--===============================================================================================--
function ENTITY:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(ENTITY,key) then return rawget(ENTITY,key) end
	return self._entity[key]
end
function ENTITY:init(entity)
	--??
	if tonumber(entity) then entity = df.historical_entity.find(tonumber(entity)) end
	self.id = entity.id
	self._entity = entity
end

function ENTITY:addResource(resourceType,resourceSubtype,token)
	if resourceType == "CREATURE" then
		self:addCreature(resourceSubtype,token)
	elseif resourceType == "INORGANIC" then
		self:addInorganic(resourceSubtype,token)	
	elseif resourceType == "ITEM" then
		self:addItem(resourceSubtype,token)
	elseif resourceType == "ORGANIC" then
		self:addOrganic(resourceSubtype,token)
	elseif resourceType == "PRODUCT" then
		self:addProductMaterial(resourceSubtype,token)
	end
end

function ENTITY:addCreature(creatureType,creatureToken)
	resource_races, resource_castes = self:getResourceTables("CREATURE",creatureType)
	if not resource_races then return end
	local creatures = decode.decode_creatureToken(creatureToken)
	for i,x in pairs(creatures) do
		for j,_ in pairs(x) do
			resource_races:insert('#',i)
			resource_castes:insert('#',j)
		end
	end
end

function ENTITY:addInorganic(inorganicType,inorganicToken)
	resource_inorganic, _ = self:getResourceTables("INORGANIC",inorganicType)
	if not resource_inorganic then return end
	local inorganics = decode.decode_inorganicToken(inorganicToken,inorganicType)
	for i,_ in pairs(inorganics) do
		resource_inorganic:insert('#',i)
	end
end

function ENTITY:addItem(itemType,itemToken)
	resource_item, _ = self:getResourceTables("ITEM",itemType)
	if not resource_item then return end
	local items = decode.decode_itemToken(itemToken)
	for i,_ in pairs(items) do
		resource_item:insert('#',i)
	end
end

function ENTITY:addOrganic(organicType,organicToken)
	resource_matType, resource_matIndex = self:getResourceTables("ORGANIC",organicType)
	if not resource_matType then return end
	local organics = decode.decode_organicToken(organicToken)
	for mat_type,x in pairs(organics) do
		for mat_index,_ in pairs(x) do
			resource_matType:insert('#',mat_type)
			resource_matIndex:insert('#',mat_index)
		end
	end
end

function ENTITY:addProductMaterial(productType,materialToken)
	resource_matType, resource_matIndex = self:getResourceTables("PRODUCT",productType)
	if not resource_matType then return end
	local materials = decode.decode_materialToken(materialToken)
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

function ENTITY:getResourceTables(resourceType,resourceSubtype)
	local resource_A
	local resource_B
	entity = df.global.world.entities.all[self.id]
	resourceTable = validResources[resourceType:upper()][resourceSubtype:upper()]
	if validResources[resourceType:upper()]["dual_resource"] then
		local N = #resourceTable
		resource_A = safe_index(entity.resources,table.unpack(resourceTable,1,N-1))
		resource_B = safe_index(safe_index(entity.resources,table.unpack(resourceTable,1,N-2)),resourceTable[N])
	else
		resource_A = safe_index(entity.resources,table.unpack(resourceTable))
	end
	return resource_A, resource_B
end

function ENTITY:hasResource(resourceGroup,resourceToken)
	local found = false
	local spl = split(resourceGroup,":")
	resourceType = spl[1]
	resourceSubtype = spl[2]
	resource_A, resource_B = self:getResourceTables(resourceType,resourceSubtype)
	if resourceType == "CREATURE" then
		object = decode.decode_creatureToken(resourceToken)
	elseif resourceType == "INORGANIC" then
		object = decode.decode_inorganicToken(resourceToken)
	elseif resourceType == "ITEM" then
		object = decode.decode_itemToken(resourceToken)
	elseif resourceType == "ORGANIC" then
		object = decode.decode_organicToken(resourceToken)
	elseif resourceType == "PRODUCT" then
		object = decode.decode_materialToken(resourceToken)
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

function ENTITY:removeResource(resourceType,resourceSubtype,token)
	if resourceType == "CREATURE" then
		self:removeCreature(resourceSubtype,token)
	elseif resourceType == "INORGANIC" then
		self:removeInorganic(resourceSubtype,token)	
	elseif resourceType == "ITEM" then
		self:removeItem(resourceSubtype,token)
	elseif resourceType == "ORGANIC" then
		self:removeOrganic(resourceSubtype,token)
	elseif resourceType == "PRODUCT" then
		self:removeProductMaterial(resourceSubtype,token)
	end
end

function ENTITY:removeCreature(creatureType,creatureToken)
	resource_races, resource_castes = self:getResourceTables("CREATURE",creatureType)
	if not resource_races then return end
	local creatures = decode.decode_creatureToken(creatureToken)
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
	if not resource_inorganic then return end
	local inorganics = decode.decode_inorganicToken(inorganicToken)
	for i=#resource_inorganic-1,0,-1 do
		if resource_inorganic[i] and inorganics[resource_inorganic[i]] then
			resource_inorganic:erase(i)
		end
	end
end

function ENTITY:removeItem(itemType,itemToken)
	resource_item, _ = self:getResourceTables("ITEM",itemType)
	if not resource_item then return end
	local items = decode.decode_itemToken(itemToken)
	for i=#resource_item-1,0,-1 do
		if resource_item[i] and items[resource_item[i]] then
			resource_item:erase(i)
		end
	end
end

function ENTITY:removeOrganic(organicType,organicToken)
	resource_matType, resource_matIndex = self:getResourceTables("ORGANIC",organicType)
	if not resource_matType then return end
	local organics = decode.decode_organicToken(organicToken)
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
	if not resource_matType then return end
	local materials = decode.decode_materialToken(materialToken)
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

--===============================================================================================--
--===============================================================================================--
--===============================================================================================--