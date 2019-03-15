script = require 'gui.script'

function printplus(text,color)
 color = color or COLOR_WHITE
 dfhack.color(color)
  dfhack.println(text)
 dfhack.color(COLOR_RESET)
 io.write(text..'\n')
end

function writeall(tbl)
 if not tbl then return end
 if type(tbl) == 'table' then
  for _,text in pairs(tbl) do
   io.write(text..'\n')
  end
 elseif type(tbl) == 'userdata' then
  io.write('userdata\n')
 else
  io.write(tbl..'\n')
 end
end

-- Open external output file
file = io.open('rto_map.txt','w')
io.output(file)

-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MAP SCRIPT CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function script_checks()
 local mapFunctions = dfhack.script_environment('functions/map')
 -- Get all units for scripts
 local civ = {}
 local non = {}
 for _,unit in pairs(df.global.world.units.active) do
  if dfhack.units.isCitizen(unit) then
   civ[#civ+1] = unit
  else
   non[#non+1] = unit
  end
 end

  script.sleep(1,'ticks')
  scriptCheck = {}

  printplus('')
  printplus('Map script checks starting',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START map/flow-plan --------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  flowCheck = {}
  unit = civ[1]
  writeall('map/flow-plan checks starting')

  ---- Check that the script succeeds in creating water of depth 3 in a 5x5 X centered on unit
  writeall('map/flow-plan -plan test_plan_5x5_X.txt -unit '..tostring(unit.id)..' -liquid water -depth 3 (Should succeed and create water of depth 3 in a 5x5 X centered on unit)')
  output = dfhack.run_command_silent('map/flow-plan -plan test_plan_5x5_X.txt -unit '..tostring(unit.id)..' -liquid water -depth 3')
  writeall(output)
  locations, n = mapFunctions.getPlanPositions(dfhack.getDFPath()..'/raw/files/test_plan_5x5_X.txt',unit.pos,nil)
  for _,pos in pairs(locations) do
   if dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z).designation[pos.x%16][pos.y%16].flow_size < 3 then 
    flowCheck[#flowCheck+1] = 'Water was not correctly spawned'
    break
   end
  end

  ---- Check that the script succeeds in creating obsidian dust in a 5x5 plus centered on unit
  writeall('map/flow-plan -plan test_plan_5x5_P.txt -unit '..tostring(unit.id)..' -flow MATERIALDUST -inorganic OBSIDIAN -density 100 -static (Should succeed and create obsidian dust in a 5x5 plus centered on unit, dust should not expand)')
  output = dfhack.run_command_silent('map/flow-plan -plan test_plan_5x5_P.txt -unit '..tostring(unit.id)..' -flow MATERIALDUST -inorganic OBSIDIAN -density 100 -static')
  writeall(output)
  locations, n = mapFunctions.getPlanPositions(dfhack.getDFPath()..'/raw/files/test_plan_5x5_P.txt',unit.pos,nil)
  for _,pos in pairs(locations) do
   if not mapFunctions.getFlow(pos) then 
    flowCheck[#flowCheck+1] = 'Dust was not correctly spawned'
    break
   end
  end

  ---- Print PASS/FAIL
  if #flowCheck == 0 then
   printplus('PASSED: map/flow-plan',COLOR_GREEN)
  else
   printplus('FAILED: map/flow-plan',COLOR_RED)
   writeall(flowCheck)
  end

  ---- FINISH map/flow-plan
  scriptCheck['flow_random_plan'] = flowCheck
  writeall('map/flow-plan checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START map/flow-pos ---------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  flowCheck = {}
  unit = civ[2]
  writeall('')
  writeall('map/flow-pos checks starting')

  ---- Check that the script succeeds and creates a circle of water of radius 5 with a depth of 7 in the middle and tapers out
  locstr = '[ 20 20 '..tostring(unit.pos.z)..' ]'
  writeall('map/flow-pos -location '..locstr..' -liquid water -depth 7 -radius [ 5 5 0 ] -circle -taper (Should succeed and create a circle of water of radius 5 with a depth of 7 in the middle and tapering out)')
  output = dfhack.run_command_silent('map/flow-pos -location '..locstr..' -liquid water -depth 7 -radius [ 5 5 0 ] -circle -taper')
  writeall(output)
  if dfhack.maps.ensureTileBlock(20,20,unit.pos.z).designation[20%16][20%16].flow_size < 7 then 
   flowCheck[#flowCheck+1] = 'Water was not spawned correctly'
  end

  ---- Check that the script succeeds and creates 10 mists in a 10x10 block around a location
  locstr = '[ 20 20 '..tostring(unit.pos.z+1)..' ]'
  writeall('map/flow-pos -location '..locstr..' -flow mist -density 50 -static -radius [ 10 10 0 ] -number 10 (Should succeed and create 10 50 density dragon fires in a 10x10 block around the unit, fire should not spread)')
  output = dfhack.run_command_silent('map/flow-pos -location '..locstr..' -flow Mist -density 100 -static -radius [ 10 10 0 ] -number 10')
  writeall(output)
  locations, n = mapFunctions.getFillPositions({20,20,unit.pos.z+1},{10,10,0})
  n = 0
  for _,pos in pairs(locations) do
   if mapFunctions.getFlow(pos,'MIST') then
    n = n + #mapFunctions.getFlow(pos,'MIST')
   end
  end
  if n < 10 then
   flowCheck[#flowCheck+1] = 'Mist was not spawned correctly. Number spawned = '..tostring(n)
  end

  ---- Print PASS/FAIL
  if #flowCheck == 0 then
   printplus('PASSED: map/flow-pos',COLOR_GREEN)
  else
   printplus('FAILED: map/flow-pos',COLOR_RED)
   writeall(flowCheck)
  end

  ---- FINISH map/flow-pos
  scriptCheck['flow_random_pos'] = flowCheck
  writeall('map/flow-pos checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START map/flow-surface -----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  flowCheck = {}
  writeall('')
  writeall('map/flow-surface checks starting')

  ---- Check that the script succeeds and creates 50 depth 5 water spots every 100 ticks for 500 ticks
  writeall('map/flow-surface -liquid -depth 5 -dur 500 -frequency 100 -number 50 (Should succeed and create 50 depth 5 water spots every 100 ticks for 500 ticks, 250 total)')
  output = dfhack.run_command_silent('map/flow-surface -liquid -depth 5 -dur 500 -frequency 100 -number 50')
  writeall(output)
  ---- Pause script for 500 ticks
  writeall('Pausing run_test.lua for 500 in-game ticks')
  script.sleep(500,'ticks')
  writeall('Resuming run_test.lua')

  ---- Check that the script succeeds amd creates 200 density 100 miasma spots every 100 ticks for 250 ticks
  iflows = #df.global.flows
  writeall('map/flow-surface -flow miasma -density 100 -dur 250 -frequency 100 -number 200 -static (Should succeed and create 200 density 100 miasma spots that spread every 100 ticks for 250 ticks, 400 total)')
  output = dfhack.run_command_silent('map/flow-surface -flow miasma -density 100 -dur 250 -frequency 100 -number 200 -static')
  writeall(output)
  ---- Pause script for 250 ticks
  writeall('Pausing run_test.lua for 250 in-game ticks')
  script.sleep(300,'ticks')
  writeall('Resuming run_test.lua')
  if #df.global.flows < iflows+400 then
   flowCheck[#flowCheck+1] = 'Failed to spawn 400 miasma flows. Number spawned = '..tostring(#df.global.flows-iflows)
  end

  ---- Print PASS/FAIL
  if #flowCheck == 0 then
   printplus('PASSED: map/flow-surface',COLOR_GREEN)
  else
   printplus('FAILED: map/flow-surface',COLOR_RED)
   writeall(flowCheck)
  end

  ---- FINISH map/flow-surface
  scriptCheck['flow_random_surface'] = flowCheck
  writeall('map/flow-surface checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START map/flow-source -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  flowCheck = {}
  unit = civ[3]
  writeall('')
  writeall('map/flow-source checks starting')

  ---- Check that the script succeeds and creates a source that creates a depth 3 water at the unit
  writeall('map/flow-source -unit '..tostring(unit.id)..' -source 3 -check 1 (Should succeed and create a source that creates a depth 3 water at unit)')
  output = dfhack.run_command_silent('map/flow-source -unit '..tostring(unit.id)..' -source 3 -check 1')
  writeall(output)

  ---- Check that the script succeeds and creates a sink that removes all water one tile right of unit
  writeall('map/flow-source -unit '..tostring(unit.id)..' -offset [ 1 0 0 ] -sink 0 -check 1 (Should succeed and create a sink the removes all water one tile right of unit)')
  output = dfhack.run_command_silent('map/flow-source -unit '..tostring(unit.id)..' -offset [ 1 0 0 ] -sink 0 -check 1')
  writeall(output)

  ---- Check that the script succeeds and creates a source that creates 100 density mist 5 tiles below unit
  writeall('map/flow-source -unit '..tostring(unit.id)..' -offset [ 0 5 0 ] -source 100 -flow MIST -check 1 (Should succeed and create a source that creates 100 density mist 5 tiles below unit)') 
  output = dfhack.run_command_silent('map/flow-source -unit '..tostring(unit.id)..' -offset [ 0 5 0 ] -source 100 -flow MIST -check 1')
  writeall(output)

  ---- Check that the script succeeds and creates a sink that removes all mist 4 tiles below unit
  writeall('map/flow-source -unit '..tostring(unit.id)..' -offset [ 0 4 0 ] -sink 0 -flow MIST -check 1 (Should succeed and create a sink that removes all mist flow four tiles below unit)')
  output = dfhack.run_command_silent('map/flow-source -unit '..tostring(unit.id)..' -offset [ 0 4 0 ] -sink 0 -flow MIST -check 1')
  writeall(output)
  ---- Pause script for 240 ticks
  writeall('Pausing run_test.lua for 240 in-game ticks')
  script.sleep(240,'ticks')
  writeall('Resuming run_test.lua')

  ---- Resume script and check that sources and sinks are working correctly
  persistTable = require 'persist-table'
  flowTable = persistTable.GlobalTable.roses.FlowTable
  liquidTable = persistTable.GlobalTable.roses.LiquidTable
  liquidSource = false
  for _,n in pairs(liquidTable._children) do
   liquid = liquidTable[n]
   if tonumber(liquid.x) == unit.pos.x and tonumber(liquid.y) == unit.pos.y and tonumber(liquid.z) == unit.pos.z and liquid.Type == 'Source' then
    liquidSource = true
    break
   end
  end

  liquidSink = false
  for _,n in pairs(liquidTable._children) do
   liquid = liquidTable[n]
   if tonumber(liquid.x) == unit.pos.x+1 and tonumber(liquid.y) == unit.pos.y and tonumber(liquid.z) == unit.pos.z and liquid.Type == 'Sink' then
    liquidSink = true
    break
   end
  end

  flowSource = false
  for _,n in pairs(flowTable._children) do
   flow = flowTable[n]
   if tonumber(flow.x) == unit.pos.x and tonumber(flow.y) == unit.pos.y+5 and tonumber(flow.z) == unit.pos.z and flow.Type == 'Source' then
    flowSource = true
    break
   end
  end

  flowSink = false
  for _,n in pairs(flowTable._children) do
   flow = flowTable[n]
   if tonumber(flow.x) == unit.pos.x and tonumber(flow.y) == unit.pos.y+4 and tonumber(flow.z) == unit.pos.z and flow.Type == 'Sink' then
    flowSink = true
    break
   end
  end

  if not liquidSource then
   flowCheck[#flowCheck+1] = 'Water source was not created correctly'
  end
  if not liquidSink then
   flowCheck[#flowCheck+1] = 'Water sink was not created correctly'
  end
  if not flowSource then
   flowCheck[#flowCheck+1] = 'Mist source was not created correctly'
  end
  if not flowSink then
   flowCheck[#flowCheck+1] = 'Mist sink was not created correctly'
  end
  dfhack.run_command_silent('map/flow-source -unit '..tostring(unit.id)..' -removeAll')

  ---- Print PASS/FAIL
  if #flowCheck == 0 then
   printplus('PASSED: map/flow-source',COLOR_GREEN)
  else
   printplus('FAILED: map/flow-source',COLOR_RED)
   writeall(flowCheck)
  end

  ---- FINISH map/flow-source
  scriptCheck['flow_source'] = flowCheck
  writeall('map/flow-source checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START map/material-change ----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  tileCheck = {}
  unit = civ[3]
  writeall('map/material-change checks starting')

  ---- Check that the script succeeds and changed the material of the floor at unit location to obsidian
  writeall('map/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor (Should succeed and change the material of the floor at unit location to obsidian)')
  output = dfhack.run_command_silent('map/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor')
  writeall(output)
  if mapFunctions.getTileMat(unit.pos.x,unit.pos.y,unit.pos.z-1) ~= 'INORGANIC:OBSIDIAN' then
   foundType = mapFunctions.getTileMat(unit.pos.x,unit.pos.y,unit.pos.z-1) or "nil"
   tileCheck[#tileCheck+1] = 'Failed to change the desired location to INORGANIC:OBSIDIAN. Location material = '..foundType
  end

  ---- Check that the script succeeds and changes the material of floor in a 5x5 X centered on unit to slade for 50 ticks
  writeall('map/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50 (Should succeed and change the material of floor in a 5x5 X centered at the unit to slade)')
  output = dfhack.run_command_silent('map/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50')
  writeall(output)
  positions, n = mapFunctions.getPlanPositions(dfhack.getDFPath()..'/raw/files/test_plan_5x5_X.txt',unit.pos,nil)
  for _,pos in pairs(positions) do
   if mapFunctions.getTileMat(pos.x,pos.y,pos.z-1) ~= 'INORGANIC:SLADE' then
    foundType = mapFunctions.getTileMat(pos.x,pos.y,pos.z-1) or "nil"
    tileCheck[#tileCheck+1] = 'Failed to change the desired location to INORGANIC:SLADE. Location material = '..foundType
   end
  end
  writeall('Pausing run_test.lua for 75 in-game ticks')
  script.sleep(75,'ticks')
  writeall('Resuming run_test.lua')
  for _,pos in pairs(positions) do
   if mapFunctions.getTileMat(pos.x,pos.y,pos.z-1) == 'INORGANIC:SLADE' then
    foundType = mapFunctions.getTileMat(pos.x,pos.y,pos.z-1) or "nil"
    tileCheck[#tileCheck+1] = 'Failed to revert the desired location from INORGANIC:SLADE. Location material = '..foundType
   end
  end

  ---- Print PASS/FAIL
  if #tileCheck == 0 then
   printplus('PASSED: map/material-change',COLOR_GREEN)
  else
   printplus('FAILED: map/material-change < Very likely to fail ',COLOR_RED)
   writeall(tileCheck)
  end

  ---- FINISH tile/material-change
  scriptCheck['map_material_change'] = tileCheck
  writeall('map/material-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START map/temperature-change -------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  tileCheck = {}
  unit = civ[3]
  writeall('')
  writeall('map/temperature-change checks starting')

  ---- Check that the script succeeds and set the temperature at units location to 9000
  writeall('map/temperature-change -unit '..tostring(unit.id)..' -temperature 9000 (Should succeed and set the temperature at the units location to 9000)')
  output = dfhack.run_command_silent('map/temperature-change -unit '..tostring(unit.id)..' -temperature 9000')
  writeall(output)
  block = dfhack.maps.ensureTileBlock(unit.pos)
  if block.temperature_1[unit.pos.x%16][unit.pos.y%16] ~= 9000 or block.temperature_2[unit.pos.x%16][unit.pos.y%16] ~= 9000 then
   tileCheck[#tileCheck+1] = 'Failed to set temperature to 9000 at unit location. Tempreature 1/2 = '..tostring(block.temperature_1[unit.pos.x%16][unit.pos.y%16])..'/'..tostring(block.temperature_2[unit.pos.x%16][unit.pos.y%16])
  end

  ---- Check that the script succeeds and sets the temerpature in a 5x5 plus centered on the unit to 15000 for 50 ticks
  positions, n = mapFunctions.getPlanPositions(dfhack.getDFPath()..'/raw/files/test_plan_5x5_X.txt',unit.pos,nil)
  it1 = {}
  it2 = {}
  ps1 = {}
  for i,pos in ipairs(positions) do
   block = dfhack.maps.ensureTileBlock(pos)
   it1[i] = block.temperature_1[pos.x%16][pos.y%16]
   it2[i] = block.temperature_2[pos.x%16][pos.y%16]
   ps1[i] = ps1[i] or {}
   ps1[i].x = pos.x
   ps1[i].y = pos.y
   ps1[i].z = pos.z
  end
  writeall('map/temperature-change -unit '..tostring(unit.id)..' -plan test_plan_5x5_P.txt -temperature 15000 -dur 50 (Should succeed and set the temperature in a 5x5 plus centered at the unit to 15000 for 50 ticks)')
  output = dfhack.run_command_silent('map/temperature-change -unit '..tostring(unit.id)..' -plan test_plan_5x5_P.txt -temperature 15000 -dur 50')
  writeall(output)
  ot1 = {}
  ot2 = {}
  for i,pos in ipairs(positions) do
   block = dfhack.maps.ensureTileBlock(pos)
   ot1[i] = block.temperature_1[pos.x%16][pos.y%16]
   ot2[i] = block.temperature_2[pos.x%16][pos.y%16] 
  end
  writeall('Pausing run_test.lua for 75 in-game ticks')
  script.sleep(75,'ticks')
  writeall('Resuming run_test.lua')
  pt1 = {}
  pt2 = {}
  for i,pos in ipairs(positions) do
   block = dfhack.maps.ensureTileBlock(pos)
   pt1[i] = block.temperature_1[pos.x%16][pos.y%16]
   pt2[i] = block.temperature_2[pos.x%16][pos.y%16] 
  end
  for n=1,#it1 do
   if ot1[n] ~= 15000 or ot2[n] ~= 15000 then
    tileCheck[#tileCheck+1] = 'Temperature in 5x5 Plus not correctly set to 15000. Position = '..tostring(ps1[n].x)..' '..tostring(ps1[n].y)..' '..tostring(ps1[n].z)..'. Temperature 1/2 = '..tostring(ot1[n])..'/'..tostring(ot2[n])
   end
   if pt1[n] ~= it1[n] or pt2[n] ~= it2[n] then
    tileCheck[#tileCheck+1] = 'Temperature in 5x5 Plus not correctly reset to initial temperature. Position = '..tostring(ps1[n].x)..' '..tostring(ps1[n].y)..' '..tostring(ps1[n].z)..'. Temperature 1/2 = '..tostring(pt1[n])..'/'..tostring(pt2[n])
   end
  end 

  ---- Print PASS/FAIL
  if #tileCheck == 0 then
   printplus('PASSED: map/temperature-change', COLOR_GREEN)
  else
   printplus('FAILED: map/temperature-change < Very likely to fail', COLOR_RED)
   writeall(tileCheck)
  end

  ---- FINISH tile/temperature-change
  scriptCheck['map_temperature_change'] = tileCheck
  writeall('map/temperature-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Map script checks finished', COLOR_CYAN)

 io.close()
end

script.start(script_checks)
