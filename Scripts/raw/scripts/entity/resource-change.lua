--entity/resource-change.lua
local usage = [====[

entity/resource-change
==================
Purpose::
    Adds and removes available resources for an entity

Arguments::
    -entity #ID
        ID number of entity to change
    -type RESROUCE_TYPE:RESOURCE_SUBTYPE
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
    -obj CREATURE_RACE:CREATURE_CASTE or MATERIAL_TYPE:MATERIAL_SUBTYPE
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
    entity/resource-change -entity \\ENTITY_ID -add -type CREATURE:PET -obj DRAGON:FEMALE
    entity/resource-change -entity \\ENTITY_ID -add -type INORGANIC:METAL -obj INORGANIC:ADAMANTINE
]====]

local utils = require 'utils'
local split = utils.split_string

validArgs = utils.invert({
    "help",
    "entity",
    "type",
    "obj",
    "remove",
    "add"
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in entity/resource-change - "

if args.help then
    print(usage)
    return
end

if args.entity and tonumber(args.entity) then entity = dfhack.script_environment("functions/entity").ENTITY(args.entity) end
if not entity then error(error_str .. "No valid entity decalred") end

mtype = split(args.type,':')[1]
stype = split(args.type,':')[2]

if args.add then
    if entity:hasResource(args.type,args.obj) then return end
    if mtype == "CREATURE" then
        entity:addCreature(stype,args.obj)
    elseif mtype == "INORGANIC" then
        entity:addInorganic(stype,args.obj)
    elseif mtype == "ITEM" then
        entity:addItem(stype,args.obj)
    elseif mtype == "ORGANIC" then
        entity:addOrganic(stype,args.obj)
    elseif mtype == "PRODUCT" then
        entity:addProductMaterial(stype,args.obj)
    else
        error(error_str .. "Invalid type decalred")
    end
end

if args.remove then
    if mtype == "CREATURE" then
        entity:removeCreature(stype,args.obj)
    elseif mtype == "INORGANIC" then
        entity:removeInorganic(stype,args.obj)
    elseif mtype == "ITEM" then
        entity:removeItem(stype,args.obj)
    elseif mtype == "ORGANIC" then
        entity:removeOrganic(stype,args.obj)
    elseif mtype == "PRODUCT" then
        entity:removeProductMaterial(stype,args.obj)
    else
        error(error_str .. "Invalid type decalred")
    end
end
