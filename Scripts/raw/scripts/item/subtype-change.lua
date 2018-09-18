--item/subtype-change.lua
local usage = [====[

item/subtype-change
===================
Purpose::
    Change the subtype of a given item or equipped item(s)
    Changes are tracked

Function Calls::
    unit.getInventoryType
    item.changeSubtype
      
Arguments::
    -item           ITEM_ID
        id of item to change
    -subtype        ITEM_SUBTYPE
        Subtype to change item into
    -unit           UNIT_ID
        id of unit to change if using -equipment
    -equipment      Equipment Type
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
    -dur            #
        Length of time for change to last

Examples::
    item/subtype-change -unit \\UNIT_ID -equipment WEAPON -subtype ITEM_WEAPON_RARE -dur 3600
    item/subtype-change -item \\ITEM_ID -subtype ITEM_ARMOR_BETTER

]====]

local utils = require 'utils'
local split = utils.split_string
validArgs = utils.invert({
 'help',
 'unit',
 'item',
 'equipment',
 'subtype',
 'dur',
 'upgrade',
 'downgrade',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print(usage)
 return
end

items = {}
if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
 local types = args.equipment
 items = dfhack.script_environment('functions/unit').getInventoryType(unit,types)
elseif args.item and tonumber(args.item) then
 items = {df.item.find(tonumber(args.item))}
else
 print('No unit or item selected')
 return
end

dur = tonumber(args.dur) or 0
for _,item in pairs(items) do
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end
 local name = item.subtype.id
 local namea = split(name,'_')
 local num = tonumber(namea[#namea])
 if args.upgrade then
  num = num + 1
  namea[#namea] = tostring(num)
  subtype = table.concat(namea,'_')
 elseif args.downgrade then
  num = num - 1
  namea[#namea] = tostring(num)
  subtype = table.concat(namea,'_')
 elseif args.subtype then
  subtype = args.subtype
 else
  print('No subtype specified')
  return
 end
 dfhack.script_environment('functions/item').changeSubtype(item,subtype,dur,'track')
end
