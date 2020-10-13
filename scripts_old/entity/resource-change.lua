--entity/resource-change.lua
local usage = [====[

entity/resource-change
==================
Purpose::
    Adds and removes available resources for an entity

Function Calls::
    entity.changeResources
    
Arguments::
    -civ     ENTITY ID
    -type    RESROUCE_TYPE:RESOURCE_SUBTYPE
        The type and subtype of resource to change
        Valid TYPEs and SUBTYPEs:
            CREATURE
                PET | PACK | MINION | WAGON | EXOTIC | MOUNT | FISH | EGG
            INORGANIC
                METAL | STONE | GEM
            ITEM
                WEAPON | SHIELD | AMMO | HELM | ARMOR | PANTS | SHOES | GLOVES
                TRAP | SIEGE | TOY | INSTRUMENT | TOOL
            ORGANIC
                LEATHER | FIBER | SILK | WOOL | WOOD | PLANT | SEED
            MISC
                GLASS | SAND | BOOZE | CHEESE | POWDER | EXTRACT | MEAT
            REFUSE
                BONE | SHELL | PEARL | TOOTH | HORN
            PRODUCT
                PICK | MELEE | RANGED | AMMO | AMMO2 | ARMOR | ANVIL | CRAFTS
                BARRELS | FLASKS | QUIVERS | BACKPACKS | CAGES
    -obj     CREATURE_RACE:CREATURE_CASTE or MATERIAL_TYPE:MATERIAL_SUBTYPE
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
    entity/resource-change -civ 23 -add -type CREATURE:PET -obj DRAGON:FEMALE
    entity/resource-change -civ 57 -add -type INORGANIC -obj INORGANIC:ADAMANTINE
]====]

local utils = require 'utils'
local split = utils.split_string

validArgs = utils.invert({
 'help',
 'civ',
 'type',
 'obj',
 'remove',
 'add',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

mtype = split(args.type,':')[1]
stype = split(args.type,':')[2]
if args.obj then
 mobj = split(args.obj,':')[1]
 sobj = split(args.obj,':')[2]
else
 mobj = nil
 sobj = nil
end
direction = 0
if args.remove then direction = -1 end
if args.add then direction = 1 end
if args.add and args.removes then return end

if tonumber(args.civ) then
 civid = tonumber(args.civ)
 civ = df.global.world.entities.all[civid]
 if not civ then
  print('Not a valid civ number')
  return
 end

 dfhack.script_environment('functions/entity').changeResources(civ,mtype,stype,mobj,sobj,direction,args.verbose)
else
 civs = {}
 n = 0
 for _,civ in pairs(df.global.world.entities.all) do
  if civ.entity_raw.code == args.civ then
   civs[n] = civ
   n = n + 1
  end
 end
 
 for _,civ in pairs(civs) do
  dfhack.script_environment('functions/entity').changeResources(civ,mtype,stype,mobj,sobj,direction,args.verbose)
 end
end
