--map/material-change.lua
local usage = [====[

map/material-change
===================
Purpose::
    Changes the inorganic material a tile is made out of
 
Function Calls::
    map.getPositions
    map.changeInorganic

Arguments::
     -plan           filename.txt
         File name of plan to use for finding locations
     -unit           UNIT_ID
         id of unit to use for position targeting
     -location       [ x y z ]
         Location to use for position targeting
     -offset         [ x y z ]
         Offset in x, y, z to use with position targeting
     -floor
         If present will target location z-1
     -material       INORGANIC_TOKEN
         Material token to change to
     -dur            #
         Length of time in in-game ticks for change to last

Examples::

]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'plan',
 'location',
 'material',
 'dur',
 'unit',
 'floor',
 'offset',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if not args.material then
 print('No material declaration')
 return
end

dur = tonumber(args.dur) or 0

if args.unit and tonumber(args.unit) then
 pos = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 pos = args.location
else
 print('No unit or location selected')
 return
end
offset = args.offset or {0,0,0}
location = {}
location.x = pos.x + offset[1] or pos[1] + offset[1]
location.y = pos.y + offset[2] or pos[2] + offset[2]
location.z = pos.z + offset[3] or pos[3] + offset[3]

if args.plan then
 file = dfhack.getDFPath()..'/raw/files/'..args.plan
 locations,n = dfhack.script_environment('functions/map').getPositions('Plan',{file=file,target=location})
 for i,loc in ipairs(locations) do
  if args.floor then
   loc.z = loc.z - 1
  end
  dfhack.script_environment('functions/map').changeInorganic(loc,nil,nil,args.material,dur)
 end
else
 if args.floor then
  location.z = location.z - 1
 end
 dfhack.script_environment('functions/map').changeInorganic(location,nil,nil,args.material,dur)
end

