--item/quality-change.lua
local usage = [====[

item/quality-change
===================
Purpose::
        Change the quality of a given item or equipped item(s)
        Changes are tracked

Function Calls::
        unit.getInventoryType
        item.changeQuality
      
Arguments::
    -item           ITEM_ID
        id of item to change
    -quality        #
        Quality to change item into
    -upgrade
        If present will increase quality by 1
    -downgrade
        If present will decrease quality by 1
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
     -dur           #
        Length of time for change to last

Examples::
    item/quality-change -unit \\UNIT_ID -equipment ALL -upgrade -dur 3600
    item/quality-change -item \\ITEM_ID -quality 7

]====]

local utils = require 'utils'
validArgs =  utils.invert({
 'help',
 'unit',
 'item',
 'equipment',
 'quality',
 'dur',
 'upgrade',
 'downgrade',
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
elseif args.item and tonumber(args.item) then
 items = {df.item.find(tonumber(args.item))}
else
 print('No unit or item selected')
 return
end

dur = tonumber(args.dur) or 0
for _,item in pairs(items) do
 if tonumber(item) then
  item = df.item.find(item)
 end
 if args.upgrade then
  quality = item.quality + 1
 elseif args.downgrade then
  quality = item.quality - 1
 elseif args.quality then
  quality = tonumber(args.quality)
 else
  print('No quality specified')
  return
 end
 dfhack.script_environment('functions/item').changeQuality(item,quality,dur,'track')
end
