--item/material-change.lua
local usage = [====[

item/material-change
====================
Purpose::
    Change the material of a given item or equipped item(s)
    Changes are tracked

Function Calls::
    unit.getInventoryType
    item.changeMaterial
      
Arguments::
    -item        ITEM_ID
        id of item to change
    -mat         MATERIAL_TYPE:MATERIAL_SUBTYPE
        Material to change item into
    -unit        UNIT_ID
        id of unit to change if using -equipment
    -equipment   Equipment Type
        Type of equipment to check for
        Valid Types:
            ALL
            WEAPON
            ARMOR
            HELM
            SHOES
            SHIELD
            GLOVES
            PANTS
            AMMO
    -dur         #
        Length of time for change to last

Examples::
    item/material-change -item \\ITEM_ID -mat INORGANIC:DIAMOND -dur 3600
    item/material-change -unit \\UNIT_ID -equipment WEAPON -mat INORGANIC:SLADE

]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'unit',
 'item',
 'equipment',
 'mat',
 'dur',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

items = {}
if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
 local types = args.equipment
 items = dfhack.script_environment('functions/unit').getInventoryType(unit,types)
else
 if args.item and tonumber(args.item) then
  items = {df.item.find(tonumber(args.item))}
 else
  print('No unit or item selected')
  return
 end
end

dur = tonumber(args.dur) or 0
for _,item in pairs(items) do
 dfhack.script_environment('functions/item').changeMaterial(item,args.mat,dur,'track')
end
