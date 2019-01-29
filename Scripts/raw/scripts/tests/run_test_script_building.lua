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
file = io.open('rto_building.txt','w')
io.output(file)

-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BUILDING SCRIPT CHECKS ----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function script_checks()
 local mapFunctions = dfhack.script_environment('functions/map')

 -- Get all items for scripts
 dfhack.run_command_silent('modtools/create-item -creator '..tostring(df.global.world.units.active[1].id)..' -material INORGANIC:IRON -item WEAPON:ITEM_WEAPON_AXE_BATTLE')
 buildingitem = df.item.find(df.global.item_next_id - 1)

-- Get building information for scripts
 for i,bldg in pairs(df.global.world.raws.buildings.all) do
  if bldg.code == 'TEST_BUILDING_1' then
   ctype1 = i
  elseif bldg.code == 'TEST_BUILDING_2' then
   ctype2 = i
  elseif bldg.code == 'TEST_BUILDING_3' then
   ctype3 = i
  end
 end
            
  script.sleep(1,'ticks')
  scriptCheck = {}

  printplus('')
  printplus('Building script checks starting',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START building/subtype-change -------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  buildingCheck = {}
  writeall('building/create checks starting')

  ---- Check that the script creates a quern (only vanilla building it can make)
  location = mapFunctions.getPositionSurfaceFree()
  locstr = tostring(location.x)..' '..tostring(location.y)..' '..tostring(location.z)
  writeall('building/create -location [ '..locstr..' ] -type Workshop -subtype 17 -test')
  output = dfhack.run_command_silent('building/create -location [ '..locstr..' ] -type Workshop -subtype 17 -test')
  writeall(output)
  if not dfhack.buildings.findAtTile(location) then
   buildingCheck[#buildingCheck+1] = 'Failed to create Quern'
  else
   buildingVanilla = dfhack.buildings.findAtTile(location)
  end

  ---- Check that the script creates TEST_BUILDING_1 with an iron short sword inside it
  location = mapFunctions.getPositionSurfaceFree()
  locstr = tostring(location.x)..' '..tostring(location.y)..' '..tostring(location.z)
  writeall('building/create -location [ '..locstr..' ] -type Workshop -subtype TEST_BUILDING_1 -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:IRON')
  output = dfhack.run_command_silent('building/create -location [ '..locstr..' ] -type Workshop -subtype TEST_BUILDING_1 -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:IRON')
  writeall(output)
  if not dfhack.buildings.findAtTile(location) then
   buildingCheck[#buildingCheck+1] = 'Failed to create TEST_BUILDING_1'
  else
   buildingCustom = dfhack.buildings.findAtTile(location)
  end

  ---- Print PASS/FAIL
  if #buildingCheck == 0 then
   printplus('PASSED: building/create',COLOR_GREEN)
  else
   printplus('FAILED: building/create',COLOR_RED)
   writeall(buildingCheck)
  end

  ---- FINISH building/subtype-change
  scriptCheck['building_create'] = buildingCheck
  writeall('building/create checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START building/subtype-change -------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  if buildingVanilla and buildingCustom then
   buildingCheck = {}
   writeall('building/subtype-change checks starting')

   ---- Check that script fails to change vanilla building
   writeall('building/subtype-change -building '..tostring(buildingVanilla.id)..' -subtype TEST_BUILDING_2 (Should fail and print "Changing vanilla buildings not currently supported")')
   output = dfhack.run_command_silent('building/subtype-change -building '..tostring(buildingVanilla.id)..' -subtype TEST_BUILDING_2')
   writeall(output)
   if buildingVanilla.custom_type > 0 then 
    buildingCheck[#buildingCheck+1] = 'Vanilla building incorrectly changed to a custom building'
   end

   ---- Check that the script succeeds in changing the subtype from TEST_BUILDING_1 to TEST_BUILDING_2 for 50 ticks
   writeall('building/subtype-change -building '..tostring(buildingCustom.id)..' -subtype TEST_BUILDING_2 -dur 50 (Should succeed and change building subtype for 50 ticks)')
   output = dfhack.run_command_silent('building/subtype-change -building '..tostring(buildingCustom.id)..' -subtype TEST_BUILDING_2 -dur 50')
   writeall(output)
   if buildingCustom.custom_type ~= ctype2 then
    buildingCheck[#buildingCheck+1] = 'Test Building 1 did not correctly change to Test Building 2'
   end
   ---- Pause script for 75 ticks
   writeall('Pausing run_test.lua for 75 in-game ticks')
   script.sleep(75,'ticks')
   writeall('Resuming run_test.lua')
   if buildingCustom.custom_type ~= ctype1 then
    buildingCheck[#buildingCheck+1] = 'Test Building 2 did not revert back to Test Building 1'
   end

   ---- Check that the script succeeds in changing the subtype from TEST_BUILDING_1 to TEST_BUILDING_3 and adding a handaxe to the building item list
   writeall('building/subtype-change -building '..tostring(buildingCustom.id)..' -subtype TEST_BUILDING_3 -item '..tostring(buildingitem.id)..' (Should succeed, change building subtype, and add a battle axe to the building item list)')
   output = dfhack.run_command_silent('building/subtype-change -building '..tostring(buildingCustom.id)..' -subtype TEST_BUILDING_3 -item '..tostring(buildingitem.id))
   writeall(output)
   if buildingCustom.custom_type ~= ctype3 then 
    buildingCheck[#buildingCheck+1] = 'Test Building 1 did not correctly change to Test Building 3'
   end
   if not buildingitem.flags.in_building then 
    buildingCheck[#buildingCheck+1] = 'Item not correctly added to building list'
   end

   ---- Print PASS/FAIL
   if #buildingCheck == 0 then
    printplus('PASSED: building/subtype-change',COLOR_GREEN)
   else
    printplus('FAILED: building/subtype-change',COLOR_RED)
    writeall(buildingCheck)
   end
 
   ---- FINISH building/subtype-change
   scriptCheck['building_subtype_change'] = buildingCheck
   writeall('building/subtype-change checks finished')
  else
   printplus('NOCHECK: building/subtype-change (building/create failed)', COLOR_YELLOW)
  end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Building script checks finished',COLOR_CYAN)

 io.close()
end

script.start(script_checks)
