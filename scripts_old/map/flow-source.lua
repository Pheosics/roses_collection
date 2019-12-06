-- map/flow-source
local usage = [====[

map/flow-source
===============
Purpose::
    Creates a source/sink for a given flow/liquid
    Sources will constantly create flows of given density or top liquids to given depth
    Sinks will constantly remove flow density or lower liquids to given depth

Function Calls::
    map.flowSource
    map.flowSink
    map.liquidSource
    map.liquidSink

Arguments::
    -unit             UNIT_ID
        id of unit to use for location targeting
    -location         [ x y z ]
        Location to place flow/liquid source/sink
    -offset           [ x y z ]
        Offset from either -unit or -location position
    -source           #
        If making a flow source this sets the density of source
        If making a liquid source this sets the depth of source
    -sink             #
        If making a flow sink this sets the denstiy of sink
        If making a liquid sink this sets the depth of sink
    -flow             Flow Type
        Type of flow to create source/sink for
        If absent it will create a liquid source/sink
        Valid Types:
            Miasma
            Steam
            Mist
            MaterialDust
            MagmaMist
            Smoke
            Dragonfire
            Fire
            Web
            MaterialGas
            MaterialVapor
            OceanWave
            SeaFoam
            ItemCloud
    -inorganic        INORGANIC_TOKEN
        Inorganic to create flow from (only works for some flow types)
    -magma
        If present and no -flow will create a magma source/sink
        If not present and no -flow will create a water source/sink
    -remove
        If present will remove all source/sinks at given position
    -removeAll
        If present will remove all source/sinks on the map
    -removeAllSource
        If present will remove all sources on the map
    -removeAllSink
        If present will remove all sinks on the map
   
Examples::
    map/flow-source -location [ \\LOCATION ] -flow Mist -source 100
    map/flow-source -unit \\UNIT_ID -sink 0
]====]

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

local utils = require 'utils'
validArgs = utils.invert({
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
 print(usage)
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
  number = tostring(#flowTable._children + 1)
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
  flowTable[number] = {} 
  flowTable[number].x = tostring(x)
  flowTable[number].y = tostring(y)
  flowTable[number].z = tostring(z)
  flowTable[number].Density = tostring(density)
  flowTable[number].Inorganic = tostring(inorganic)
  flowTable[number].FlowType = tostring(flowtype)
  flowTable[number].Check = tostring(check)
  flowTable[number].Type = 'Source'
  dfhack.script_environment('functions/map').flowSource(number)
 else
  number = tostring(#liquidTable._children + 1)
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
  number = tostring(#flowTable._children + 1)
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
  flowTable[number] = {} 
  flowTable[number].x = tostring(x)
  flowTable[number].y = tostring(y)
  flowTable[number].z = tostring(z)
  flowTable[number].Density = tostring(density)
  flowTable[number].Inorganic = tostring(inorganic)
  flowTable[number].FlowType = tostring(flowtype)
  flowTable[number].Check = tostring(check)
  flowTable[number].Type = 'Sink'
  dfhack.script_environment('functions/map').flowSink(number)
 else
  depth = args.sink
  number = tostring(#liquidTable._children + 1)
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
