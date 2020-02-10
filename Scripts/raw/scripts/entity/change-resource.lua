-- TODO Allow multiple additions and removals in an individual call

--entity/change-resource.lua
--@ module=true
local utils = require 'utils'
local split = utils.split_string
local validResources = reqscript("functions/entity").validResources

local usage = [====[

entity/change-resource
==================
Purpose::
    Adds and removes available resources for an entity

Uses::
	functions/entity

Arguments::
    -entity <HISTORICAL_ENTITY_ID>
        ID number of entity to change
    -type <RESROUCE_TYPE:RESOURCE_SUBTYPE>
        The type and subtype of resource to change
        Valid TYPEs and SUBTYPEs:
            CREATURE
                PET | PACK | MINION | WAGON | EXOTIC | MOUNT
            INORGANIC
                METAL | STONE | GEM | GLASS | SAND | CLAY
            ITEM
                WEAPON | SHIELD | AMMO | HELM | ARMOR | PANTS | SHOES | GLOVES
                TRAP | SIEGE | TOY | INSTRUMENT | TOOL
            ORGANIC
                LEATHER | FIBER | SILK | WOOL | WOOD | PLANT | SEED | BONE
                MEAT | CHEESE | SHELL | IVORY | HORN | PEARL | DRINK
            PRODUCT
                PICK | MELEE | RANGED | AMMO | ARMOR | ANVIL | CRAFTS
                BARRELS | FLASKS | QUIVERS | BACKPACKS | CAGES
    -obj <CREATURE_RACE:CREATURE_CASTE> or <MATERIAL_TYPE:MATERIAL_SUBTYPE> or <ITEM_TYPE:ITEM_SUBTYPE>
        The type and subtype of the creature or material to add
        For Example
            DWARF:MALE
            ELF:BONE
            CEDAR:WOOD
    -add
        Adds the resource to the entity
    -remove
        Removes the resource from the entity

Examples::
	* Add female dragons to the entities available pets
		entity/change-resource -entity \\ENTITY_ID -add -type CREATURE:PET -obj DRAGON:FEMALE
	* Add adamantine to the entities available metals
		entity/change-resource -entity \\ENTITY_ID -add -type INORGANIC:METAL -obj INORGANIC:ADAMANTINE
	* Remove all animals from the entities available mounts
		entity/change-resource -entity \\ENTITY_ID -remove -type CREATURE:MOUNT -obj ALL:ALL
]====]

validArgs = utils.invert({
    "help",
    "entity",
    "type",
    "obj",
    "remove",
    "add"
})

function addResource(entity,resourceType,resourceSubtype,object)
	local defentity = reqscript("functions/entity").ENTITY
	entity = defentity(entity)
	entity:addResource(resourceType,resourceSubtype,object)
end

function removeResource(entity,resourceType,resourceSubtype,object)
	local defentity = reqscript("functions/entity").ENTITY
	entity = defentity(entity)
	entity:removeResource(resourceType,resourceSubtype,object)
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in entity/resource-change - "
	
	if args.help then
		print(usage)
		return
	end
	
	-- Check for valid entity
	if args.entity and tonumber(args.entity) then entity = df.historical_entity.find(tonumber(args.entity)) end
	if not entity then error(error_str .. "No valid entity decalred") end
	
	-- Check for required arguments
	if not args.type then error(error_str .. "No RESOURCE_TYPE:RESOURCE_SUBTYPE declared") end
	if not args.obj  then error(error_str .. "No OBJ_TYPE:OBJ_SUBTYPE decalred") end
	
	-- Parse Arguments
	splitType = split(args.type,':')
	resourceType = splitType[1]
	resourceSubtype = splitType[2]
	if not validResources[resourceType] then error(error_str .. "Not a valid resource type - " .. resourceType) end
	if not validResources[resourceType][resourceSubtype] then error(error_str .. "Not a valid resource subtype - " .. resourceSubtype) end

	if args.add then
		addResource(entity,resourceType,resourceSubtype,args.obj)
	elseif args.remove then
		removeResource(entity,resourceType,resourceSubtype,args.obj)
	else
		error(error_str .. "Must decalre -add or -remove")
	end
end

if not dfhack_flags.module then
	main(...)
end