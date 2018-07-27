--entity/resource-change.lua v0.8 | DFHack 43.05

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
