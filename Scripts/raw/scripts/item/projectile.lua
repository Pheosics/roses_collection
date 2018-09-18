--item/projectile.lua
local usage = [====[

item/projectile
===============
Purpose::
    Turn an item into a projectile
    Either creates an item from scratch or checks a units inventory
    Projectile mechanics are either Falling or Shooting

Function Calls::
    item.create
    item.makeProjectileFall
    item.makeProjectileShot

Arguments::
    -type        Projectile Type
        Type of projectile to create (changes number meanings)
        Valid Types:
            Falling
            Shooting
    -unitSource    UNIT_ID
        id of source unit of projectile
    -unitTarget    UNIT_ID
        id of target unit of projectile
    -locationSource    [ x y z ]
        Location of starting point of projectile
    -locationTarget    [ x y z ]
        Location of targets point of projectile
    -item        ITEM_TYPE:ITEM_SUBTYPE
        Item to be created or checked for
    -mat        MATERIAL_TYPE:MATERIAL_SUBTYPE
        Material of item to be created (if not using -equipped)
    -height        #
        Number of tiles above target to start projectile if using -type Falling
    -equipped
        If present will check unitSource's inventory
        If not present will create necessary items
    -number        #
        Number of items to fire
        If creating will create this many
        If using equipped with use up to this many
        DEFAULT 1
    -velocity    # or [ # # # ]
        If using -type Shooting velocity is a single number
        If using -type Falling velcoity is an [ x y z ] triplet
        DEFAULT 20 or [ 0 0 0 ]
    -maxrange    #
        Maximum range the projectile can travel in tiles and still hit
        DEFAULT 10
    -minrange    #
        Minimum range the projectile must travel to hit
        DEFAULT 1
    -hitchance    #
        Chance for projectile to hit target
        DEFAULT 50
    -quality    #
        If creating items will create items at given quality
        DEFAULT 0

Examples::
    item/projectile -unitSource \\UNIT_ID -unitTarget \\UNIT_ID -item AMMO:ITEM_AMMO_BOLT -equipped -type Falling -height 10
    item/projectile -unitSource \\UNIT_ID -locationTarget [ \\LOCATION ] -item WEAPON:ITEM_WEAPON_SWORD_SHORT -mat INORGANIC:STEEL -number 10 -velocity 50 -maxrange 4 -hitchance 10

]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'unitSource',
 'unitTarget',
 'locationSource',
 'locationTarget',
 'creator',
 'mat',
 'item',
 'number',
 'maxrange',
 'velocity',
 'minrange',
 'hitchance',
 'height',
 'equipped',
 'type',
 'quality',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print(usage)
 return
end

if args.unitSource and args.locationSource then
 print("Can't have unit and location specified as source at same time")
 args.locationSource = nil
end
if args.unitTarget and args.locationTarget then
 print("Can't have unit and location specified as target at same time")
 args.locationTarget = nil
end

if args.unitSource then -- Check for source declaration !REQUIRED
 origin = df.unit.find(tonumber(args.unitSource)).pos
elseif args.locationSource then
 origin = {x=args.locationSource[1],y=args.locationSource[2],z=args.locationSource[3]}
else
 print('No source specified')
 return
end

if args.unitTarget then -- Check for target declaration !REQUIRED
 target = df.unit.find(tonumber(args.unitTarget)).pos
elseif args.locationTarget then
 target = {x=args.locationTarget[1],y=args.locationTarget[2],z=args.locationTarget[3]}
elseif args.type == 'falling' or args.type == 'Falling' then
 target = origin
else
 print('No target specified')
 return
end

if not args.item then
 print('No item specified')
 return
end

local itemType = dfhack.items.findType(args.item)
if itemType == -1 then
 print('Invalid item')
 return
end
local itemSubtype = dfhack.items.findSubtype(args.item)
local create = true
if args.equipped and (not args.unitSource) then
 print('No unit to check for equipment')
 return
elseif args.equipped and args.unitSource then
 create = false
 args.creator = args.unitSource
end

number = tonumber(args.number) or 1 -- Specify number of projectiles (default 1)
for n = 1, number, 1 do
 item = nil
 if create then
  if not args.mat or not dfhack.matinfo.find(args.mat) then
   print('Invalid material')
   return
  end
  if not args.creator then args.creator = 0 end
  item = dfhack.script_environment('functions/item').create(args.item,args.mat,args.creator,args.quality)
  item = df.item.find(item)
 else
  unit = df.unit.find(tonumber(args.creator))
  local inventory = unit.inventory
  for k,v in ipairs(inventory) do
   if v.item:getType() == itemType and v.item:getSubtype() == itemSubtype then
    item = v.item
    break
   else
    for l,w in ipairs(dfhack.items.getContainedItems(v.item)) do
     if w:getType() == itemType and w:getSubtype() == itemSubtype then
      item = w
      break
     end
    end
   end
  end
  if not item then
   return
  end
  if item.stack_size == 1 then
   break
  else
   item.stack_size = item.stack_size - 1
   item = dfhack.script_environment('functions/item').create(args.item,dfhack.matinfo.getToken(item.mat_type,item.mat_index),dfhack.items.getHolderUnit(item).id,item.quality)
   item = df.item.find(item)
  end
 end

 if args.type == 'Falling' then
  velocity = args.velocity or {0,0,0}
  height = tonumber(args.height) or 0
  dfhack.items.moveToGround(item,{x=tonumber(target.x),y=tonumber(target.y),z=tonumber(target.z+height)})
  dfhack.script_environment('functions/item').makeProjectileFall(item,{target.x,target.y,target.z+height},velocity)
 else
  velocity = tonumber(args.velocity) or 20 -- Specify velocity of projectiles (default 20)
  hit_chance = tonumber(args.hitchance) or 50 -- Specify hit percent of projectiles (default 50)
  max_range = tonumber(args.maxrange) or 10 -- Specify max range of projectiles (default 10)
  min_range = tonumber(args.minrange) or 1 -- Specify minimum range of projectiles (default 1)
  height = tonumber(args.height) or 0
  dfhack.items.moveToGround(item,{x=tonumber(origin.x),y=tonumber(origin.y),z=tonumber(origin.z+height)})
  dfhack.script_environment('functions/item').makeProjectileShot(item,{origin.x,origin.y,origin.z+height},{target.x,target.y,target.z},{velocity=velocity,accuracy=hit_chance,range=max_range,minimum=min_range,firer=args.unitSource})
 end
end
