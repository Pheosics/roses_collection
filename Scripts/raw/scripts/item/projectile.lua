--item/projectile.lua
local usage = [====[

item/projectile
===============
Purpose::
    Turn an item into a projectile
    Either creates an item from scratch or checks a units inventory
    Projectile mechanics are either Falling or Shooting

Arguments::
    -type Type
        Type of projectile to create (changes number meanings)
        Valid Types:
            Falling
            Shooting
    -unitSource #ID
        id of source unit of projectile
    -unitTarget #ID
        id of target unit of projectile
    -locationSource [ x y z ]
        Location of starting point of projectile
    -locationTarget [ x y z ]
        Location of targets point of projectile
    -item ITEM_TYPE:ITEM_SUBTYPE
        Item to be created or checked for
    -material MATERIAL_TYPE:MATERIAL_SUBTYPE
        Material of item to be created (if not using -equipped)
    -height #
        Number of tiles above target to start projectile if using -type Falling
    -equipped
        If present will check unitSource's inventory
        If not present will create necessary items
    -number #
        Number of items to fire
        If creating will create this many
        If using equipped with use up to this many
        DEFAULT 1
    -velocity # or [ vx vy vz ]
        If using -type Shooting velocity is a single number
        If using -type Falling velcoity is an [ x y z ] triplet
        DEFAULT 20 or [ 0 0 0 ]
    -maxrange #
        Maximum range the projectile can travel in tiles and still hit
        DEFAULT 10
    -minrange #
        Minimum range the projectile must travel to hit
        DEFAULT 1
    -hitchance #
        Chance for projectile to hit target
        DEFAULT 50
    -quality #(0-7)
        If creating items will create items at given quality
        DEFAULT 0

Examples::
    item/projectile -unitSource \\UNIT_ID -unitTarget \\UNIT_ID -item AMMO:ITEM_AMMO_BOLT -equipped -type Falling -height 10
    item/projectile -unitSource \\UNIT_ID -locationTarget [ \\LOCATION ] -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -number 10 -velocity 50 -maxrange 4 -hitchance 10

]====]

local utils = require "utils"
validArgs = utils.invert({
    "help",
    "unitSource",
    "unitTarget",
    "locationSource",
    "locationTarget",
    "creator",
    "material",
    "item",
    "number",
    "maxrange",
    "velocity",
    "minrange",
    "hitchance",
    "height",
    "equipped",
    "type",
    "quality",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in item/projectile - "

if args.help then -- Help declaration
 print(usage)
 return
end

if not args.item then error(error_str .. "No item declared") end

if args.unitSource and args.locationSource then args.locationSource = nil end
if args.unitTarget and args.locationTarget then args.locationTarget = nil end

if args.unitSource and tonumber(args.unitSource) then
    origin = df.unit.find(tonumber(args.unitSource)).pos
    if not args.creator then args.creator = args.unitSource end
elseif args.locationSource then
    origin = {x=args.locationSource[1],
              y=args.locationSource[2],
              z=args.locationSource[3]}
else
    error(error_str .. "No source specified")
end

if args.unitTarget and tonumber(args.unitTarget) then
    target = df.unit.find(tonumber(args.unitTarget)).pos
elseif args.locationTarget then
    target = {x=args.locationTarget[1],
              y=args.locationTarget[2],
              z=args.locationTarget[3]}
elseif args.type:upper() == "FALLING" then
    target = origin
else
    error(error_str .. "No target specified")
end

local itemType = dfhack.items.findType(args.item)
if itemType == -1 then error(error_str .. "Invalid item") end
local itemSubtype = dfhack.items.findSubtype(args.item)

if args.equipped and not args.unitSource then error(error_str .. "No unit to check for equipment") end
if args.equipped and args.unitSource then
    unit = dfhack.script_environment("functions/unit").UNIT(args.creator)
    items = unit:getInventoryItems("ITEM",args.item)
    for i,item in pairs(items) do items[i] = dfhack.script_environment("functions/item").ITEM(item) end
end

number = tonumber(args.number) or 1
args.type = args.type or "FALLING"
for n = 1, number do
    item = nil
    if args.equipped then
        item = items[1]
        if item:getStackSize() > 1 then
            item:changeStackSize(-1)
            item = dfhack.script_environment("functions/item").create(args.item,args.material,args.creator,args.quality)
        end
    else
        if not args.material or not dfhack.matinfo.find(args.material) then error(error_str .. "Invalid material") end
        item = dfhack.script_environment("functions/item").create(args.item,args.material,args.creator,args.quality)
    end
    if not item then return end

    height = tonumber(args.height) or 0 
    if args.type:upper() == "FALLING" then
        velocity = args.velocity or {0,0,0}
        position = {x = tonumber(target.x),
                    y = tonumber(target.y),
                    z = tonumber(target.z+height)}
    elseif args.type:upper() == "SHOOTING" then
        velocity = tonumber(args.velocity) or 20
        position = {x = tonumber(origin.x),
                    y = tonumber(origin.y),
                    z = tonumber(origin.z+height)}
        options = {
            target   = target,
            accuracy = tonumber(args.hitchance),
            range    = tonumber(args.maxrange),
            minimum  = tonumber(args.minrange)}
    end
    item:makeProjectile("FALLING",position,velocity,options)
end
