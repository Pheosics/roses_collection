--map/temperature-change.lua
local usage = [====[

map/temperature-change
======================
Purpose::
    Changes the temperature of a tile
    Doesn't really work well since the game constantly updates temperatures
 
Function Calls::
    map.getPositions
    map.changeTemperature

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
     -temperature    #
         Temperature to set tile to
     -dur            #
         Length of time in in-game ticks for change to last
         Doesn't really work since the game constantly updates temperatures

Examples::

]====]

local utils = require 'utils'
validArgs = utils.invert({
 'help',
 'plan',
 'location',
 'temperature',
 'dur',
 'unit',
 'offset',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print(usage)
 return
end

dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)

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
  dfhack.script_environment('functions/map').changeTemperature(loc,nil,nil,args.temperature,dur)
 end
else
 dfhack.script_environment('functions/map').changeTemperature(location,nil,nil,args.temperature,dur)
end
