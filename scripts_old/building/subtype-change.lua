--building/subtype-change.lua
local usage = [====[

building/subtype-change
=======================
Purpose::
    Change the subtype of a building from one custom building to a different custom building
    Currently does not support changing vanilla buildings
 
Function Calls::
    building.changeSubtype
    building.addItem

Arguments::
    -building      BUILDING_ID
        id of building to be changed
    -unit          UNIT_ID
        id of unit to check location for building (if you have a unit id and no building id)
    -subtype       BUILDING_TOKEN
        Building token (only custom buildings currently supported)
    -item          ITEM_ID or [ ITEM_ID ITEM_ID ]
        id(s) of item(s) to be added to the buildings build materials
    -dur           #
        Length of time in in-game ticks for the change to last
        Added items will be removed at end of duration

Examples::
    building/subtype-change -building \\BUILDING_ID -subtype NEW_CUSTOM_BUILDING -dur 7200
    building/subtype-change -unit \\UNIT_ID -subtype CUSTOM_BUILDING -item \\ITEM_ID    
]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'building',
 'unit',
 'item',
 'subtype',
 'dur',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if not args.subtype then print('No specified subtype chosen') return end
if type(args.item) == 'string' then args.item = {args.item} end

if args.building then
 building = df.building.find(tonumber(args.building))
elseif args.unit then
 building = dfhack.buildings.findAtTile(df.unit.find(tonumber(args.unit)).pos)
else
 print('No unit or building declaration')
 return
end
if not building then print('No valid building') return end
if building.custom_type < 0 then print('Changing vanilla buildings not currently supported') return end

dur = args.dur or 0
check = dfhack.script_environment('functions/building').changeSubtype(building,args.subtype,dur,'track')
if check then
 if args.item then
  for _,item in ipairs(args.item) do
   dfhack.script_environment('functions/building').addItem(building,item,dur)
  end
 end
end
