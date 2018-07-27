script = require 'gui.script'
persistTable = require 'persist-table'

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
file = io.open('run_test_output.txt','w')
io.output(file)


-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')
roses = persistTable.GlobalTable.roses
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TILE SCRIPT CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function script_checks()
 local mapFunctions = dfhack.script_environment('functions/map')

 -- Get all units for scripts
 civ = {}
 non = {}
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
  printplus('Tile script checks starting',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START tile/material-change ----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  tileCheck = {}
  unit = civ[3]
  writeall('tile/material-change checks starting')

  ---- Check that the script succeeds and changed the material of the floor at unit location to obsidian
  writeall('tile/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor (Should succeed and change the material of the floor at unit location to obsidian)')
  output = dfhack.run_command_silent('tile/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor')
  writeall(output)
  if mapFunctions.GetTileMat(unit.pos.x,unit.pos.y,unit.pos.z-1) ~= 'INORGANIC:OBSIDIAN' then
   foundType = mapFunctions.GetTileMat(unit.pos.x,unit.pos.y,unit.pos.z-1) or "nil"
   tileCheck[#tileCheck+1] = 'Failed to change the desired location to INORGANIC:OBSIDIAN. Location material = '..foundType
  end

  ---- Check that the script succeeds and changes the material of floor in a 5x5 X centered on unit to slade for 50 ticks
  writeall('tile/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50 (Should succeed and change the material of floor in a 5x5 X centered at the unit to slade)')
  output = dfhack.run_command_silent('tile/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50')
  writeall(output)
  positions, n = mapFunctions.getPlanPositions(dfhack.getDFPath()..'/raw/files/test_plan_5x5_X.txt',unit.pos,nil)
  for _,pos in pairs(positions) do
   if mapFunctions.GetTileMat(pos.x,pos.y,pos.z-1) ~= 'INORGANIC:SLADE' then
    foundType = mapFunctions.GetTileMat(pos.x,pos.y,pos.z-1) or "nil"
    tileCheck[#tileCheck+1] = 'Failed to change the desired location to INORGANIC:SLADE. Location material = '..foundType
   end
  end
  writeall('Pausing run_test.lua for 75 in-game ticks')
  script.sleep(75,'ticks')
  writeall('Resuming run_test.lua')
  for _,pos in pairs(positions) do
   if mapFunctions.GetTileMat(pos.x,pos.y,pos.z-1) == 'INORGANIC:SLADE' then
    foundType = mapFunctions.GetTileMat(pos.x,pos.y,pos.z-1) or "nil"
    tileCheck[#tileCheck+1] = 'Failed to revert the desired location from INORGANIC:SLADE. Location material = '..foundType
   end
  end

  ---- Print PASS/FAIL
  if #tileCheck == 0 then
   printplus('PASSED: tile/material-change',COLOR_GREEN)
  else
   printplus('FAILED: tile/material-change',COLOR_RED)
   writeall(tileCheck)
  end

  ---- FINISH tile/material-change
  scriptCheck['tile_material_change'] = tileCheck
  writeall('tile/material-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START tile/temperature-change -------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  tileCheck = {}
  unit = civ[3]
  writeall('')
  writeall('tile/temperature-change checks starting')

  ---- Check that the script succeeds and set the temperature at units location to 9000
  writeall('tile/temperature-change -unit '..tostring(unit.id)..' -temperature 9000 (Should succeed and set the temperature at the units location to 9000)')
  output = dfhack.run_command_silent('tile/temperature-change -unit '..tostring(unit.id)..' -temperature 9000')
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
  writeall('tile/temperature-change -unit '..tostring(unit.id)..' -plan test_plan_5x5_P.txt -temperature 15000 -dur 50 (Should succeed and set the temperature in a 5x5 plus centered at the unit to 15000 for 50 ticks)')
  output = dfhack.run_command_silent('tile/temperature-change -unit '..tostring(unit.id)..' -plan test_plan_5x5_P.txt -temperature 15000 -dur 50')
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
   printplus('PASSED: tile/temperature-change', COLOR_GREEN)
  else
   printplus('FAILED: tile/temperature-change', COLOR_RED)
   writeall(tileCheck)
  end

  ---- FINISH tile/temperature-change
  scriptCheck['tile_temperature_change'] = tileCheck
  writeall('tile/temperature-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Tile script checks finished', COLOR_CYAN)

 io.close()
end

script.start(script_checks)
