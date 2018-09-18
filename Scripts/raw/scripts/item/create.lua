--item/create.lua
local usage = [====[

item/create
===========
Purpose::
    Creates an item and it's cooresponding item table for tracking

Function Calls::
    item.create
      
Arguments::
    -creator     UNIT_ID
        id of creator unit, set to 0 if not present
    -item        ITEM_TYPE:ITEM_SUBTYPE
        Item to be created
    -material    MATERIAL_TYPE:MATERIAL_SUBTYPE
        Material to make item out of
    -quality     #
        Quality to create the item at
    -dur         #
        Length of time for item to exist
    -matchingGloves
        If present it will create two gloves with correct handedness
    -matchingShoes
        If present it will create two shoes

Examples::
    -item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:SUPER_INORGANIC -quality 7 -dur 3600
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'creator',
 'material',
 'item',
 'matchingGloves',
 'matchingShoes',
 'dur',
 'quality',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if not args.creator then
 args.creator = 0
end
local item1 = dfhack.script_environment('functions/item').create(args.item,args.material,args.creator,args.quality,args.dur)
if args.matchingGloves or args.matchingShoes then
 if args.matchingGloves then
  item1 = df.item.find(item1)
  item1:setGloveHandedness(1);
 end
 local item2 = dfhack.script_environment('functions/item').create(args.item,args.material,args.creator,args.quality,args.dur)
 if args.matchingGloves then
  item2 = df.item.find(item2)
  item2:setGloveHandedness(2);
 end
end
