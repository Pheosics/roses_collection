-- flow/source.lua v0.8 | DFHack 43.05

local utils = require 'utils'

flowtypes = {
              MIASMA = 0,
              STEAM = 1,
              MIST = 2,
              MATERIALDUST = 3,
              MAGMAMIST = 4,
              SMOKE = 5,
              DRAGONFIRE = 6,
              FIRE = 7,
              WEB = 8,
              MATERIALGAS = 9,
              MATERIALVAPOR = 10,
              OCEANWAVE = 11,
              SEAFOAM = 12,
			  ITEMCLOUD = 13
             }
             
validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'location',
 'offset',
 'source',
 'sink',
 'remove',
 'removeAll',
 'removeAllSource',
 'removeAllSink',
 'magma',
 'flow',
 'inorganic',
 'check',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 return
end

pos = {}
if args.unit and tonumber(args.unit) then
 pos = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 pos.x = args.location[1]
 pos.y = args.location[2]
 pos.z = args.location[3]
else
 if not args.removeAll or not args.removeAllSource or not args.removeAllSink then
  print('No unit or location selected')
  return
 end
end
offset = args.offset or {0,0,0}
check = tonumber(args.check) or 12
x = pos.x + offset[1]
y = pos.y + offset[2]
z = pos.z + offset[3]

local persistTable = require 'persist-table'
liquidTable = persistTable.GlobalTable.roses.LiquidTable
flowTable = persistTable.GlobalTable.roses.FlowTable
number = tostring(#liquidTable._children)

if args.removeAll then
 persistTable.GlobalTable.roses.LiquidTable = {}
 persistTable.GlobalTable.roses.FlowTable = {}
elseif args.removeAllSource then
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if liquid.Type == 'Source' then
   liquidTable[i] = nil
  end
 end
 for _,i in pairs(flowTable._children) do
  flow = flowTable[i]
  if flow.Type == 'Source' then
   flowTable[i] = nil
  end
 end
elseif args.removeAllSink then
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if liquid.Type == 'Sink' then
   liquidTable[i] = nil
  end
 end
  for _,i in pairs(flowTable._children) do
  flow = flowTable[i]
  if flow.Type == 'Sink' then
   flowTable[i] = nil
  end
 end
elseif args.remove then
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if tonumber(liquid.x) == x and tonumber(liquid.y) == y and tonumber(liquid.z) == z then
   liquidTable[i] = nil
  end
 end
 for _,i in pairs(flowTable._children) do
  flow = flowTable[i]
  if tonumber(flow.x) == x and tonumber(flow.y) == y and tonumber(flow.z) == z then
   flowTable[i] = nil
  end
 end
elseif args.source then
 if args.flow then
  number = tostring(#flowTable._children)
  density = args.source
  inorganic = args.inorganic or 0
  if inorganic ~= 0 then
   inorganic = dfhack.matinfo.find(inorganic).index
  end
  flowtype = flowtypes[string.upper(args.flow)]
  for _,i in pairs(flowTable._children) do
   flow = flowTable[i]
   if tonumber(flow.x) == x and tonumber(flow.y) == y and tonumber(flow.z) == z then
    flowTable[i] = nil
   end
  end
  flowTable[tostring(number)] = {} 
  flowTable[tostring(number)].x = tostring(x)
  flowTable[tostring(number)].y = tostring(y)
  flowTable[tostring(number)].z = tostring(z)
  flowTable[tostring(number)].Density = tostring(density)
  flowTable[tostring(number)].Inorganic = tostring(inorganic)
  flowTable[tostring(number)].FlowType = tostring(flowtype)
  flowTable[tostring(number)].Check = tostring(check)
  flowTable[tostring(number)].Type = 'Source'
  dfhack.script_environment('functions/map').flowSource(number)
 else
  number = tostring(#liquidTable._children)
  depth = args.source
  for _,i in pairs(liquidTable._children) do
   liquid = liquidTable[i]
   if tonumber(liquid.x) == x and tonumber(liquid.y) == y and tonumber(liquid.z) == z then
    liquidTable[i] = nil
   end
  end
  liquidTable[number] = {}
  liquidTable[number].x = tostring(x)
  liquidTable[number].y = tostring(y)
  liquidTable[number].z = tostring(z)
  liquidTable[number].Depth = tostring(depth)
  liquidTable[number].Check = tostring(check)
  if args.magma then liquidTable[number].Magma = 'true' end
  liquidTable[number].Type = 'Source'
  dfhack.script_environment('functions/map').liquidSource(number)
 end
elseif args.sink then
 if args.flow then
  number = tostring(#flowTable._children)
  density = args.sink
  inorganic = args.inorganic or 0
  if inorganic ~= 0 then
   inorganic = dfhack.matinfo.find(inorganic).index
  end
  flowtype = flowtypes[string.upper(args.flow)]
  for _,i in pairs(flowTable._children) do
   flow = flowTable[i]
   if tonumber(flow.x) == x and tonumber(flow.y) == y and tonumber(flow.z) == z then
    flowTable[i] = nil
   end
  end
  flowTable[tostring(number)] = {} 
  flowTable[tostring(number)].x = tostring(x)
  flowTable[tostring(number)].y = tostring(y)
  flowTable[tostring(number)].z = tostring(z)
  flowTable[tostring(number)].Density = tostring(density)
  flowTable[tostring(number)].Inorganic = tostring(inorganic)
  flowTable[tostring(number)].FlowType = tostring(flowtype)
  flowTable[tostring(number)].Check = tostring(check)
  flowTable[tostring(number)].Type = 'Sink'
  dfhack.script_environment('functions/map').flowSink(number)
 else
  depth = args.sink
  number = tostring(#liquidTable._children)
  for _,i in pairs(liquidTable._children) do
   liquid = liquidTable[i]
   if tonumber(liquid.x) == x and tonumber(liquid.y) == y and tonumber(liquid.z) == z then
    liquidTable[i] = nil
   end
  end
  liquidTable[number] = {}
  liquidTable[number].x = tostring(x)
  liquidTable[number].y = tostring(y)
  liquidTable[number].z = tostring(z)
  liquidTable[number].Depth = tostring(depth)
  liquidTable[number].Check = tostring(check)
  if args.magma then liquidTable[number].Magma = 'true' end
  liquidTable[number].Type = 'Sink'
  dfhack.script_environment('functions/map').liquidSink(number)
 end
end
