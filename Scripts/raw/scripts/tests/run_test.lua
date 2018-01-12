script = require 'gui.script'
persistTable = require 'persist-table'

externalScripts = {}

buildingFunctions = dfhack.script_environment('functions/building')
mapFunctions = dfhack.script_environment('functions/map')
unitFunctions = dfhack.script_environment('functions/unit')
itemFunctions = dfhack.script_environment('functions/item')
enhancedFunctions = dfhack.script_environment('functions/enhanced')
tableFunctions = dfhack.script_environment('functions/tables')

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

-- Get all units for scripts
civ = {}
non = {}
iciv = 0
inon = 0
for _,unit in pairs(df.global.world.units.active) do
 if dfhack.units.isCitizen(unit) then
  iciv = iciv + 1
  civ[iciv] = unit
 else
  inon = inon + 1
  non[inon] = unit
 end
end

-- Get all items for scripts
dfhack.run_command_silent('modtools/create-item -creator '..tostring(civ[1].id)..' -material INORGANIC:IRON -item WEAPON:ITEM_WEAPON_AXE_BATTLE')
buildingitem = df.item.find(df.global.item_next_id - 1)
function mostRecentItem()
 local item = df.item.find(df.global.item_next_id - 1)
 return item
end

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

-- Open external output file
file = io.open('run_test_output.txt','w')
io.output(file)


-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')
roses = persistTable.GlobalTable.roses
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ROSES SCRIPT CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function script_checks()

--df.global.pause_state = false
  script.sleep(1,'ticks')
--df.global.pause_state = true
printplus('Beginning Roses Script Checks')
printplus('All scripts will be run multiple times, with both correct and incorrect arguments')
scriptCheck = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BUILDING SCRIPT CHECKS ----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Building script checks starting',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START building/subtype-change
buildingCheck = {}
     writeall('building/create checks starting')
---- Check that the script creates a quern (only vanilla building it can make
location = mapFunctions.getPositionSurfaceFree()
locstr = tostring(location.x)..' '..tostring(location.y)..' '..tostring(location.z)
     writeall('building/create -location [ '..locstr..' ] -type Workshop -subtype 17')
output = dfhack.run_command_silent('building/create -location [ '..locstr..' ] -type Workshop -subtype 17')
writeall(output)
if not dfhack.buildings.findAtTile(location) then
 buildingCheck[#buildingCheck+1] = 'Failed to create Quern'
else
 buildingVanilla = dfhack.buildings.findAtTile(location)
end
---- Check that the script creates TEST_BUILDING_1 with an iron short sword inside it
location = mapFunctions.getPositionSurfaceFree()
locstr = tostring(location.x)..' '..tostring(location.y)..' '..tostring(location.z)
     writeall('building/create -location [ '..locstr..' ] -type Workshop -subtype TEST_BUILDING_1 -custom -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:IRON')
output = dfhack.run_command_silent('building/create -location [ '..locstr..' ] -type Workshop -subtype TEST_BUILDING_1 -custom -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:IRON')
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
-- FINISH building/subtype-change
scriptCheck['building_create'] = buildingCheck
     writeall('building/create checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START building/subtype-change
if buildingVanilla and buildingCustom then
buildingCheck = {}
     writeall('building/subtype-change checks starting')
---- Check that script fails to change vanilla building
     writeall('building/subtype-change -building '..tostring(buildingVanilla.id)..' -type TEST_BUILDING_2 (Should fail and print "Changing vanilla buildings not currently supported")')
output = dfhack.run_command_silent('building/subtype-change -building '..tostring(buildingVanilla.id)..' -type TEST_BUILDING_2')
writeall(output)
if buildingVanilla.custom_type > 0 then 
 buildingCheck[#buildingCheck+1] = 'Vanilla building incorrectly changed to a custom building'
end
---- Check that the script succeeds in changing the subtype from TEST_BUILDING_1 to TEST_BUILDING_2 for 50 ticks
     writeall('building/subtype-change -building '..tostring(buildingCustom.id)..' -type TEST_BUILDING_2 -dur 50 (Should succeed and change building subtype for 50 ticks)')
output = dfhack.run_command_silent('building/subtype-change -building '..tostring(buildingCustom.id)..' -type TEST_BUILDING_2 -dur 50')
writeall(output)
if buildingCustom.custom_type ~= ctype2 then
 buildingCheck[#buildingCheck+1] = 'Test Building 1 did not correctly change to Test Building 2'
end
---- Pause script for 75 ticks
     writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
  script.sleep(75,'ticks')
--df.global.pause_state = true
     writeall('Resuming run_test.lua')
if buildingCustom.custom_type ~= ctype1 then
 buildingCheck[#buildingCheck+1] = 'Test Building 2 did not revert back to Test Building 1'
end
---- Check that the script succeeds in changing the subtype from TEST_BUILDING_1 to TEST_BUILDING_3 and adding a handaxe to the building item list
     writeall('building/subtype-change -building '..tostring(buildingCustom.id)..' -type TEST_BUILDING_3 -item '..tostring(buildingitem.id)..' (Should succeed, change building subtype, and add a battle axe to the building item list)')
output = dfhack.run_command_silent('building/subtype-change -building '..tostring(buildingCustom.id)..' -type TEST_BUILDING_3 -item '..tostring(buildingitem.id))
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
-- FINISH building/subtype-change
scriptCheck['building_subtype_change'] = buildingCheck
     writeall('building/subtype-change checks finished')
else
  printplus('NOCHECK: building/subtype-change (building/create failed)', COLOR_YELLOW)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Building script checks finished',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FLOW SCRIPT CHECKS --------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Flow script checks starting',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START flow/random-plan
flowCheck = {}
unit = civ[1]
     writeall('flow/random-plan checks starting')
---- Check that the script succeeds in creating water of depth 3 in a 5x5 X centered on unit
     writeall('flow/random-plan -plan test_plan_5x5_X.txt -unit '..tostring(unit.id)..' -liquid water -depth 3 (Should succeed and create water of depth 3 in a 5x5 X centered on unit)')
output = dfhack.run_command_silent('flow/random-plan -plan test_plan_5x5_X.txt -unit '..tostring(unit.id)..' -liquid water -depth 3')
writeall(output)
locations = mapFunctions.getPositionPlan(dfhack.getDFPath()..'/raw/files/test_plan_5x5_X.txt',unit.pos,nil)
for _,pos in pairs(locations) do
 if dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z).designation[pos.x%16][pos.y%16].flow_size < 3 then 
  flowCheck[#flowCheck+1] = 'Water was not correctly spawned'
  break
 end
end
---- Check that the script succeeds in creating obsidian dust in a 5x5 plus centered on unit
     writeall('flow/random-plan -plan test_plan_5x5_P.txt -unit '..tostring(unit.id)..' -flow dust -inorganic OBSIDIAN -density 100 -static (Should succeed and create obsidian dust in a 5x5 plus centered on unit, dust should not expand)')
output = dfhack.run_command_silent('flow/random-plan -plan test_plan_5x5_P.txt -unit '..tostring(unit.id)..' -flow dust -inorganic OBSIDIAN -density 100 -static')
writeall(output)
locations = mapFunctions.getPositionPlan(dfhack.getDFPath()..'/raw/files/test_plan_5x5_P.txt',unit.pos,nil)
for _,pos in pairs(locations) do
 if not mapFunctions.getFlow(pos) then 
  flowCheck[#flowCheck+1] = 'Dust was not correctly spawned'
 break
 end
end
---- Print PASS/FAIL
if #flowCheck == 0 then
 printplus('PASSED: flow/random-plan',COLOR_GREEN)
else
 printplus('FAILED: flow/random-plan',COLOR_RED)
 writeall(flowCheck)
end
-- FINISH flow/random-plan
scriptCheck['flow_random_plan'] = flowCheck
     writeall('flow/random-plan checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START flow/random-pos
flowCheck = {}
unit = civ[2]
     writeall('')
     writeall('flow/random-pos checks starting')
---- Check that the script succeeds and creates a circle of water of radius 5 with a depth of 7 in the middle and tapers out
locstr = '[ 20 20 '..tostring(unit.pos.z)..' ]'
     writeall('flow/random-pos -location '..locstr..' -liquid water -depth 7 -radius [ 5 5 0 ] -circle -taper (Should succeed and create a circle of water of radius 5 with a depth of 7 in the middle and tapering out)')
output = dfhack.run_command_silent('flow/random-pos -location '..locstr..' -liquid water -depth 7 -radius [ 5 5 0 ] -circle -taper')
writeall(output)
if dfhack.maps.ensureTileBlock(20,20,unit.pos.z).designation[20%16][20%16].flow_size < 7 then 
 flowCheck[#flowCheck+1] = 'Water was not spawned correctly'
end
---- Check that the script succeeds and creates 10 mists in a 10x10 block around a location
locstr = '[ 20 20 '..tostring(unit.pos.z+1)..' ]'
     writeall('flow/random-pos -location '..locstr..' -flow mist -density 50 -static -radius [ 10 10 0 ] -number 10 (Should succeed and create 10 50 density dragon fires in a 10x10 block around the unit, fire should not spread)')
output = dfhack.run_command_silent('flow/random-pos -location '..locstr..' -flow Mist -density 100 -static -radius [ 10 10 0 ] -number 10')
writeall(output)
locations = mapFunctions.getFillPosition({20,20,unit.pos.z+1},{10,10,0})
n = 0
for _,pos in pairs(locations) do
 if mapFunctions.getFlow(pos,'MIST') then
  n = n + #mapFunctions.getFlow(pos,'MIST')
 end
end
if n ~= 10 then
 flowCheck[#flowCheck+1] = 'Mist was not spawned correctly. Number spawned = '..tostring(n)
end
---- Print PASS/FAIL
if #flowCheck == 0 then
 printplus('PASSED: flow/random-pos',COLOR_GREEN)
else
 printplus('FAILED: flow/random-pos',COLOR_RED)
 writeall(flowCheck)
end
-- FINISH flow/random-pos
scriptCheck['flow_random_pos'] = flowCheck
     writeall('flow/random-pos checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START flow/random-surface
flowCheck = {}
     writeall('')
     writeall('flow/random-surface checks starting')
---- Check that the script succeeds and creates 50 depth 5 water spots every 100 ticks for 500 ticks
     writeall('flow/random-surface -liquid -depth 5 -dur 500 -frequency 100 -number 50 (Should succeed and create 50 depth 5 water spots every 100 ticks for 500 ticks, 250 total)')
output = dfhack.run_command_silent('flow/random-surface -liquid -depth 5 -dur 500 -frequency 100 -number 50')
writeall(output)
---- Pause script for 500 ticks
     writeall('Pausing run_test.lua for 500 in-game ticks')
   script.sleep(500,'ticks')
     writeall('Resuming run_test.lua')
---- Check that the script succeeds amd creates 200 density 100 miasma spots every 100 ticks for 250 ticks
iflows = #df.global.flows
     writeall('flow/random-surface -flow miasma -density 100 -dur 250 -frequency 100 -number 200 -static (Should succeed and create 200 density 100 miasma spots that spread every 100 ticks for 250 ticks, 400 total)')
output = dfhack.run_command_silent('flow/random-surface -flow miasma -density 100 -dur 250 -frequency 100 -number 200 -static')
writeall(output)
---- Pause script for 250 ticks
     writeall('Pausing run_test.lua for 250 in-game ticks')
--df.global.pause_state = false
   script.sleep(300,'ticks')
--df.global.pause_state = true
     writeall('Resuming run_test.lua')
---- Print PASS/FAIL
if #df.global.flows < iflows+400 then
 flowCheck[#flowCheck+1] = 'Failed to spawn 400 miasma flows. Number spawned = '..tostring(#df.global.flows-iflows)
end
if #flowCheck == 0 then
 printplus('PASSED: flow/random-surface',COLOR_GREEN)
else
 printplus('FAILED: flow/random-surface',COLOR_RED)
 writeall(flowCheck)
end
-- FINISH flow/random-surface
scriptCheck['flow_random_surface'] = flowCheck
     writeall('flow/random-surface checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START flow/source
flowCheck = {}
unit = civ[3]
     writeall('')
     writeall('flow/source checks starting')
---- Check that the script succeeds and creates a source that creates a depth 3 water at the unit
     writeall('flow/source -unit '..tostring(unit.id)..' -source 3 -check 1 (Should succeed and create a source that creates a depth 3 water at unit)')
output = dfhack.run_command_silent('flow/source -unit '..tostring(unit.id)..' -source 3 -check 1')
writeall(output)
---- Check that the script succeeds and creates a sink that removes all water one tile right of unit
     writeall('flow/source -unit '..tostring(unit.id)..' -offset [ 1 0 0 ] -sink 0 -check 1 (Should succeed and create a sink the removes all water one tile right of unit)')
output = dfhack.run_command_silent('flow/source -unit '..tostring(unit.id)..' -offset [ 1 0 0 ] -sink 0 -check 1')
writeall(output)
---- Check that the script succeeds and creates a source that creates 100 density mist 5 tiles below unit
     writeall('flow/source -unit '..tostring(unit.id)..' -offset [ 0 5 0 ] -source 100 -flow MIST -check 1 (Should succeed and create a source that creates 100 density mist 5 tiles below unit)') 
output = dfhack.run_command_silent('flow/source -unit '..tostring(unit.id)..' -offset [ 0 5 0 ] -source 100 -flow MIST -check 1')
writeall(output)
---- Check that the script succeeds and creates a sink that removes all mist 4 tiles below unit
     writeall('flow/source -unit '..tostring(unit.id)..' -offset [ 0 4 0 ] -sink 0 -flow MIST -check 1 (Should succeed and create a sink that removes all mist flow four tiles below unit)')
output = dfhack.run_command_silent('flow/source -unit '..tostring(unit.id)..' -offset [ 0 4 0 ] -sink 0 -flow MIST -check 1')
writeall(output)
---- Pause script for 240 ticks
     writeall('Pausing run_test.lua for 240 in-game ticks')
--df.global.pause_state = false
   script.sleep(240,'ticks')
--df.global.pause_state = true
     writeall('Resuming run_test.lua')
---- Resume script and check that sources and sinks are working correctly
flowTable = roses.FlowTable
liquidTable = roses.LiquidTable
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
dfhack.run_command_silent('flow/source -unit '..tostring(unit.id)..' -removeAll')
---- Print PASS/FAIL
if #flowCheck == 0 then
 printplus('PASSED: flow/source',COLOR_GREEN)
else
 printplus('FAILED: flow/source',COLOR_RED)
 writeall(flowCheck)
end
-- FINISH flow/source
scriptCheck['flow_source'] = flowCheck
     writeall('flow/source checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Flow script checks finished',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ITEM SCRIPT CHECKS --------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Item script checks starting',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START item/create
itemCheck = {}
     writeall('item/create checks starting')
---- Checks that the script succeeds and creates a steel short sword
     writeall('item/create -creator '..tostring(civ[1].id)..' -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL (Should succeed and create a steel short sword)')
output = dfhack.run_command_silent('item/create -creator '..tostring(civ[1].id)..' -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL')
writeall(output)
item = mostRecentItem()
if dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id ~= 'ITEM_WEAPON_SWORD_SHORT' then
 itemCheck[#itemCheck+1] = 'Failed to create short sword'
end
     writeall('item/create -creator '..tostring(civ[1].id)..' -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:RUBY -dur 50 (Should succeed and create a ruby short sword and then remove it 50 ticks later)')
---- Checks that the script succeeds and creates a ruby short sword and then removes it 50 ticks later
output = dfhack.run_command_silent('item/create -creator '..tostring(civ[1].id)..' -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:RUBY -dur 20')
writeall(output)
item = mostRecentItem()
id = item.id
     writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
   script.sleep(75,'ticks')
--df.global.pause_state = true
     writeall('Resuming run_test.lua')
if df.item.find(id) then
 itemCheck[#itemCheck+1] = 'Ruby short sword was not correctly removed'
end
---- Print PASS/FAIL
if #itemCheck == 0 then
 printplus('PASSED: item/create',COLOR_GREEN)
else
 printplus('FAILED: item/create',COLOR_RED)
 writeall(itemCheck)
end
-- FINISH item/create
scriptCheck['item_create'] = itemCheck
     writeall('item/create checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START item/equip and item/unequip
itemCheck = {}
unit = civ[1]
dfhack.run_command_silent('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -creator '..tostring(unit.id))
item = mostRecentItem()
     writeall('')
     writeall('item/equip and item/unequip checks starting')
---- Check that the script succeeds and moves the item into the inventory of the unit
     writeall('item/equip -item '..tostring(item.id)..' -unit '..tostring(unit.id)..' -bodyPartFlag GRASP (Should succeed and move item into inventory of unit carrying in hand)')
output = dfhack.run_command_silent('item/equip -item '..tostring(item.id)..' -unit '..tostring(unit.id)..' -bodyPartFlag GRASP')
writeall(output)
yes = false
for _,itemID in pairs(unitFunctions.getInventoryType(unit,'WEAPON')) do
 if item.id == itemID then
  yes = true
  break 
 end
end
if not yes then
 itemCheck[#itemCheck+1] = 'Short sword not equipped on unit'
end
---- Check that the script succeeds and moves item from inventory to the ground at units location
     writeall('item/unequip -item '..tostring(item.id)..' (Should succeed and move item from inventory to ground at unit location)')
output = dfhack.run_command_silent('item/unequip -item '..tostring(item.id))
writeall(output)
if not same_xyz(item.pos,unit.pos) or not item.flags.on_ground or item.flags.in_inventory then
 itemCheck[#itemCheck+1] = 'Short sword not unequipped and placed on ground'
end
---- Check that the script succeeds and removes units entire inventory
     writeall('item/unequip -item ALL -unit '..tostring(unit.id)..' (Should succeed and remove all items that unit has in inventory)')
output = dfhack.run_command_silent('item/unequip -item ALL -unit '..tostring(unit.id))
writeall(output)
if #unit.inventory > 0 then
 itemCheck[#itemCheck+1] = 'Entire inventory was not correctly unequipped'
end
---- Print PASS/FAIL
if #itemCheck == 0 then
 printplus('PASSED: item/equip and item/unequip',COLOR_GREEN)
else
 printplus('FAILED: item/equip and item/unequip',COLOR_RED)
 writeall(itemCheck)
end
-- FINISH item/equip and item/unequip
scriptCheck['item_equip'] = itemCheck
     writeall('item/equip and item/unequip checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START item/material-change
itemCheck = {}
unit = civ[2]
dfhack.run_command_silent('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -creator '..tostring(unit.id))
item = mostRecentItem()
     writeall('')
     writeall('item/material-change checks starting')
---- Check that the script succeeds and changes the steel short sword into a brain short sword
     writeall('item/material-change -item '..tostring(item.id)..' -mat CREATURE_MAT:DWARF:BRAIN (Should succeed and change the material of item to dwarf brain)')
output = dfhack.run_command_silent('item/material-change -item '..tostring(item.id)..' -mat CREATURE_MAT:DWARF:BRAIN')
writeall(output)
mat = dfhack.matinfo.find('CREATURE_MAT:DWARF:BRAIN')
if mat.type ~= item.mat_type or mat.index ~= item.mat_index then
 itemCheck[#itemCheck+1] = 'Failed to change short sword material from INORGANIC:STEEL to CREATURE_MAT:DWARF:BRAIN'
end
---- Check that the script succeeds and changed the entire units inventory into adamantine for 50 ticks
     writeall('item/material-change -unit '..tostring(unit.id)..' -equipment ALL -mat INORGANIC:ADAMANTINE -dur 50 (Should succeed and change the material of all units inventory to adamantine for 50 ticks)')
output = dfhack.run_command_silent('item/material-change -unit '..tostring(unit.id)..' -equipment ALL -mat INORGANIC:ADAMANTINE -dur 50')
writeall(output)
mat = dfhack.matinfo.find('INORGANIC:ADAMANTINE')
for _,itm in pairs(unit.inventory) do
 inv = itm.item
 if inv.mat_type ~= mat.type or inv.mat_index ~= mat.index then
  itemCheck[#itemCheck+1] = 'Failed to change an inventory item material to INORGANIC:ADAMANTINE'
 end
end
     writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
   script.sleep(75,'ticks')
--df.global.pause_state = true
     writeall('Resuming run_test.lua')
for _,itm in pairs(unit.inventory) do
 inv = itm.item
 if inv.mat_type == mat.type or inv.mat_index == mat.index then
  itemCheck[#itemCheck+1] = 'Failed to reset an inventory item material from INORGANIC:ADAMANTINE'
 end
end
---- Check that the script succeeds and changes the brain short sword to steel and creates a tracking table
     writeall('item/material-change -item '..tostring(item.id)..' -mat INORGANIC:STEEL -track (Should succeed and change the material of item to steel and create a persistent table for the item to track changes)') 
output = dfhack.run_command_silent('item/material-change -item '..tostring(item.id)..' -mat INORGANIC:STEEL -track')
writeall(output)
mat = dfhack.matinfo.find('INORGANIC:STEEL')
if mat.type ~= item.mat_type or mat.index ~= item.mat_index then
 itemCheck[#itemCheck+1] = 'Failed to change short sword material from CREATURE_MAT:DWARF:BRAIN to INORGANIC:STEEL'
end
if not roses.ItemTable[tostring(item.id)] then
 itemCheck[#itemCheck+1] = 'Failed to create an ItemTable entry for short sword'
end
---- Print PASS/FAIL
if #itemCheck == 0 then
 printplus('PASSED: item/material-change',COLOR_GREEN)
else
 printplus('FAILED: item/material-change',COLOR_RED)
 writeall(itemCheck)
end
-- FINISH item/material-change
scriptCheck['item_material_change'] = itemCheck
     writeall('item/material-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START item/quality-change
itemCheck = {}
unit = civ[2]
dfhack.run_command_silent('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -creator '..tostring(unit.id))
item = mostRecentItem()
     writeall('')
     writeall('item/quality-change checks starting')
---- Check that the script succeeds and changes the quality of the item to masterwork and creates a tracking table
     writeall('item/quality-change -item '..tostring(item.id)..' -quality 5 -track (Should succeed and change the quality of the item to masterwork and track the change in the persistent item table)')
output = dfhack.run_command_silent('item/quality-change -item '..tostring(item.id)..' -quality 5 -track')
writeall(output)
if item.quality ~= 5 then
 itemCheck[#itemCheck+1] = 'Failed to increase item quality to 5'
end
if not roses.ItemTable[tostring(item.id)] then
 itemCheck[#itemCheck+1] = 'Failed to create an ItemTable entry for short sword'
end
---- Check that the script succeeds and changes the quality of the entire units inventory to masterwork for 50 ticks
     writeall('item/quality-change -unit '..tostring(unit.id)..' -equipment ALL -quality 5 -dur 50 (Should succeed and change the quality of all units inventory to masterwork for 50 ticks)')
output = dfhack.run_command_silent('item/quality-change -unit '..tostring(unit.id)..' -equipment ALL -quality 5 -dur 50')
writeall(output)
for _,itm in pairs(unit.inventory) do
 inv = itm.item
 if inv.quality ~= 5 then
  itemCheck[#itemCheck+1] = 'Failed to set inventory item quality to 5'
 end
end
     writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
   script.sleep(75,'ticks')
--df.global.pause_state = true
     writeall('Resuming run_test.lua')
for _,itm in pairs(unit.inventory) do
 inv = itm.item
 if inv.quality == 5 then
  itemCheck[#itemCheck+1] = 'Failed to reset inventory item quality'
 end
end
---- Check that the script lowers the quality of all short swords on the map by 1
     writeall('item/quality-change -type WEAPON:ITEM_WEAPON_SWORD_SHORT -upgrade (Should succeed and increase the quality of all short swords on the map by 1)') 
prequality = 0
number = 0
for _,itm in pairs(df.global.world.items.all) do
 if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()) then
  if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()).id == 'ITEM_WEAPON_SWORD_SHORT' then
   if itm.quality < 5 then number = number + 1 end
   prequality = prequality + itm.quality
  end
 end
end
output = dfhack.run_command_silent('item/quality-change -type WEAPON:ITEM_WEAPON_SWORD_SHORT -upgrade')
writeall(output)
postquality = 0
for _,itm in pairs(df.global.world.items.other.WEAPON) do
 if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()) then
  if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()).id == 'ITEM_WEAPON_SWORD_SHORT' then
   postquality = postquality + itm.quality
  end
 end
end
if postquality ~= (prequality + number) then
 itemCheck[#itemCheck+1] = 'Not all short swords increased in quality'
end
---- Print PASS/FAIL
if #itemCheck == 0 then
 printplus('PASSED: item/quality-change',COLOR_GREEN)
else
 printplus('FAILED: item/quality-change',COLOR_RED)
 writeall(itemCheck)
end
-- FINISH item/quality-change
scriptCheck['item_quality_change'] = itemCheck
     writeall('item/quality-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START item/subtype-change
itemCheck = {}
unit = civ[2]
dfhack.run_command_silent('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -creator '..tostring(unit.id))
item = mostRecentItem()
    writeall('')
    writeall('item/subtype-change checks starting')
---- Check that the script succeeds and changes short sword to long sword and creates a tracking table
    writeall('item/subtype-change -item '..tostring(item.id)..' -subtype ITEM_WEAPON_SWORD_LONG -track (Should succeed and change the short sword to a long sword and track the change in the persistent item table)')
output = dfhack.run_command_silent('item/subtype-change -item '..tostring(item.id)..' -subtype ITEM_WEAPON_SWORD_LONG -track')
writeall(output)
if dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()) then
 if dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id ~= 'ITEM_WEAPON_SWORD_LONG' then
  itemCheck[#itemCheck+1] = 'Failed to change the short sword into a long sword'
 end
end
if not roses.ItemTable[tostring(item.id)] then
 itemCheck[#itemCheck+1] = 'Failed to create ItemTable for short sword'
end
---- Check that the script succeeds and changes the pants unit is wearing into greaves for 50 ticks
    writeall('item/subtype-change -unit '..tostring(unit.id)..' -equipment PANTS -subtype ITEM_PANTS_GREAVES -dur 50 (Should succeed and change the pants the unit is wearing into greaves for 50 ticks)')
pants = unitFunctions.getInventoryType(unit,'PANTS')[1]
pants = df.item.find(pants)
presubtype = dfhack.items.getSubtypeDef(pants:getType(),pants:getSubtype()).id
output = dfhack.run_command_silent('item/subtype-change -unit '..tostring(unit.id)..' -equipment PANTS -subtype ITEM_PANTS_GREAVES -dur 50')
writeall(output)
if dfhack.items.getSubtypeDef(pants:getType(),pants:getSubtype()) then
 if dfhack.items.getSubtypeDef(pants:getType(),pants:getSubtype()).id ~= 'ITEM_PANTS_GREAVES' then
  itemCheck[itemCheck+1] = 'Failed to change pants equipment to ITEM_PANTS_GREAVES'
 end
end
    writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
   script.sleep(75,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
if dfhack.items.getSubtypeDef(pants:getType(),pants:getSubtype()).id ~= presubtype then
 itemCheck[#itemCheck+1] = 'Failed to reset pants equipment subtype'
end
---- Check that the script succeeds and changes all picks on the map into short sword
    writeall('item/subtype-change -type WEAPON:ITEM_WEAPON_PICK -subtype ITEM_WEAPON_SWORD_SHORT (Should succeed and change all picks on the map into short swords)')
picks = {}
for _,itm in pairs(df.global.world.items.all) do
 if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()) then
  if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()).id == 'ITEM_WEAPON_PICK' then
   picks[#picks+1] = itm
  end
 end
end
output = dfhack.run_command_silent('item/subtype-change -type WEAPON:ITEM_WEAPON_PICK -subtype ITEM_WEAPON_SWORD_SHORT')
writeall(output)
for _,itm in pairs(picks) do
 if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()) then
  if dfhack.items.getSubtypeDef(itm:getType(),itm:getSubtype()).id ~= 'ITEM_WEAPON_SWORD_SHORT' then
   itemCheck[#itemCheck+1] = 'Failed to turn all picks into short swords'
  end
 end
end
---- Print PASS/FAIL
if #itemCheck == 0 then
 printplus('PASSED: item/subtype-change',COLOR_GREEN)
else
 printplus('FAILED: item/subtype-change',COLOR_RED)
 writeall(itemCheck)
end
-- FINISH item/subtype-change
scriptCheck['item_subtype_change'] = itemCheck
    writeall('item/subtype-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START item/projectile
itemCheck = {}
unitSource = civ[1]
unitTarget = civ[2]
unitSource.pos.x = unitTarget.pos.x + 3
unitSource.pos.y = unitTarget.pos.y + 3
unitSource.pos.z = unitTarget.pos.z
    writeall('')
    writeall('item/projectile checks starting')
---- Check that the script succeeds and creates an iron bolt shooting from source to target
    writeall('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id)..' -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON (Should succeed and create an iron bolt shooting from source to target)')
projid = df.global.proj_next_id
itemid = df.global.item_next_id
output = dfhack.run_command_silent('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id)..' -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON')
writeall(output)
if df.global.proj_next_id ~= projid + 1 and df.global.item_next_id ~= itemid + 1 then
 itemCheck[#itemCheck+1] = 'Failed to create 1 shooting projectile'
end
---- Check that the script succeeds and creates 10 iron bolts falling from 5 z levels above the source
    writeall('item/projectile -unitSource '..tostring(unitSource.id)..' -type Falling -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON -height 5 -number 10 (Should succeed and create 10 iron bolt falling from 5 above the source)')
projid = df.global.proj_next_id
itemid = df.global.item_next_id
output = dfhack.run_command_silent('item/projectile -unitSource '..tostring(unitSource.id)..' -type Falling -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON -height 5 -number 10')
writeall(output)
if df.global.proj_next_id ~= projid + 10 and df.global.item_next_id ~= itemid + 10 then
 itemCheck[#itemCheck+1] = 'Failed to create 10 falling projectiles'
end
---- Print PASS/FAIL
if #itemCheck == 0 then
 printplus('PASSED: item/projectile',COLOR_GREEN)
else
 printplus('FAILED: item/projectile',COLOR_RED)
 writeall(itemCheck)
end
-- FINISH item/projectile
scriptCheck['item_projectile'] = itemCheck
    writeall('item/projectile checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Item script checks finished',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TILE SCRIPT CHECKS --------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Tile script checks starting',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START tile/material-change
tileCheck = {}
unit = civ[3]
    writeall('tile/material-change checks starting')
---- Check that the script succeeds and changed the material of the floor at unit location to obsidian
    writeall('tile/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor (Should succeed and change the material of the floor at unit location to obsidian)')
output = dfhack.run_command_silent('tile/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor')
writeall(output)
if mapFunctions.getTileType(unit.pos.x,unit.pos.y,unit.pos.z-1) ~= 'INORGANIC:OBSIDIAN' then
 foundType = mapFunctions.getTileType(unit.pos.x,unit.pos.y,unit.pos.z-1) or "nil"
 tileCheck[#tileCheck+1] = 'Failed to change the desired location to INORGANIC:OBSIDIAN. Location material = '..foundType
end
---- Check that the script succeeds and changes the material of floor in a 5x5 X centered on unit to slade for 50 ticks
    writeall('tile/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50 (Should succeed and change the material of floor in a 5x5 X centered at the unit to slade)')
output = dfhack.run_command_silent('tile/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50')
writeall(output)
positions = mapFunctions.getPositionPlan(dfhack.getDFPath()..'/raw/files/test_plan_5x5_X.txt',unit.pos,nil)
for _,pos in pairs(positions) do
 if mapFunctions.getTileType(pos.x,pos.y,pos.z-1) ~= 'INORGANIC:SLADE' then
  foundType = mapFunctions.getTileType(pos.x,pos.y,pos.z-1) or "nil"
  tileCheck[#tileCheck+1] = 'Failed to change the desired location to INORGANIC:SLADE. Location material = '..foundType
 end
end
    writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
  script.sleep(75,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
for _,pos in pairs(positions) do
 if mapFunctions.getTileType(pos.x,pos.y,pos.z-1) == 'INORGANIC:SLADE' then
  foundType = mapFunctions.getTileType(pos.x,pos.y,pos.z-1) or "nil"
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
-- FINISH tile/material-change
scriptCheck['tile_material_change'] = tileCheck
    writeall('tile/material-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START tile/temperature-change
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
positions = mapFunctions.getPositionPlan('test_plan_5x5_P.txt',unit,nil)
it1 = {}
it2 = {}
for i,pos in ipairs(positions) do
 block = dfhack.maps.ensureTileBlock(pos)
 it1[i] = block.temperature_1[pos.x%16][pos.y%16]
 it2[i] = block.temperature_2[pos.x%16][pos.y%16] 
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
--df.global.pause_state = false
  script.sleep(75,'ticks')
--df.global.pause_state = true
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
  tileCheck[#tileCheck+1] = 'Temperature in 5x5 Plus not correctly set to 15000. Position = '..tostring(pos[n].x)..' '..tostring(pos[n].y)..' '..tostring(pos[n].z)..'. Temperature 1/2 = '..tostring(ot1[n])..'/'..tostring(ot2[n])
 end
 if pt1[n] ~= it1[n] or pt2[n] ~= it2[n] then
  tileCheck[#tileCheck+1] = 'Temperature in 5x5 Plus not correctly reset to initial temperature. Position = '..tostring(pos[n].x)..' '..tostring(pos[n].y)..' '..tostring(pos[n].z)..'. Temperature 1/2 = '..tostring(pt1[n])..'/'..tostring(pt2[n])
 end
end 
---- Print PASS/FAIL
if #tileCheck == 0 then
 printplus('PASSED: tile/temperature-change', COLOR_GREEN)
else
 printplus('FAILED: tile/temperature-change', COLOR_RED)
 writeall(tileCheck)
end
-- FINISH tile/temperature-change
scriptCheck['tile_temperature_change'] = tileCheck
    writeall('tile/temperature-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Tile script checks finished', COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UNIT SCRIPT CHECKS --------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Unit script checks starting', COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/action-change
unitCheck = {}
unit = civ[1]
    writeall('unit/action-change checks starting')
---- Check that the script succeeds and adds an action of every type with a 500 tick cooldown
    writeall('unit/action-change -unit '..tostring(unit.id)..' -timer 500 -action All (Should succeed and add an action for every type with a 500 tick cooldown)')
output = dfhack.run_command_silent('unit/action-change -unit '..tostring(unit.id)..' -timer 500 -action All')
writeall(output)
check = true
for _,action in pairs(unit.actions) do
 if action.type => 0 then
  actionType = df.unit_action_type[action.type]
  if action.data[string.lower(actionType)].timer then
   if action.data[string.lower(actionType)].timer < 500 then
    check = false
   end
  elseif action.data[string.lower(actionType)].timer1 then
   if action.data[string.lower(actionType)].timer1 < 500 then
    check = false
   end
  end
 end
end
if not check then
 unitCheck[#unitCheck+1] = 'Failed to add a 500 tick action for each action to unit'
end
---- Check that the script succeeds and removes all actions from unit
    writeall('unit/action-change -unit '..tostring(unit.id)..' -timer clearAll (Should succeed and remove all actions from unit)')
output = dfhack.run_command_silent('unit/action-change -unit '..tostring(unit.id)..' -timer clearAll')
writeall(output)
if #unit.actions > 0 then
 unitCheck[#unitCheck+1] = 'Failed to remove all actions from unit'
end
---- Check that the script succeeds and adds an attack action with a 100 tick-cooldown and 100 ticks to all interaction cooldowns
    writeall('unit/action-change -unit '..tostring(unit.id)..' -timer 100 -action Attack -interaction All (Should succeed and add an attack action with a 100 tick cooldown and add 100 ticks to all interaction cooldowns)')
output = dfhack.run_command_silent('unit/action-change -unit '..tostring(unit.id)..' -timer 100 -action Attack -interaction All')
writeall(output)
check1 = false
check2 = false
for _,action in pairs(unit.actions) do
 if action.type == 1 then
  if action.data.attack.timer1 == 100 and action.data.attack.timer2 == 100 then
   check1 = true
   break
  end
 end
end
if unit.curse.own_interaction_delay >= 100 then
 check2 = true
end
if not check1 then
 unitCheck[#unitCheck+1] = 'Failed to add an attack action with a 100 tick delay'
end
if not check2  then
 unitCheck[#unitCheck+1] = 'Failed to increase interaction delay by 100 ticks'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/action-change',COLOR_GREEN)
else
 printplus('FAILED: unit/action-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/action-change
scriptCheck['unit_action_change'] = unitCheck
    writeall('unit/action-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/attack
unitCheck = {}
attacker = civ[1]
defender = non[1]
defender.pos.x = attacker.pos.x + 1
defender.pos.y = attacker.pos.y
defender.pos.z = attacker.pos.z
    writeall('')
    writeall('unit/attack checks starting')
---- Check that the script succeeds and adds an attack action with the calculated velocity, hit chance, and body part target
    writeall('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' (Should succeed and add an attack action to the attacker unit, with calculated velocity, hit chance, and body part target)')
output = dfhack.run_command_silent('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id))
writeall(output)
check = false
for _,action in pairs(attacker.actions) do
 if action.type == 1 then
  if action.data.attack.target_unit_id == defender.id then
   check = true
   break
  end
 end
end
if not check then
 unitCheck[#unitCheck+1] = 'Failed to assign attack action to attacking unit targeting defending unit'
end
---- Check that the script succeeds and adds 10 punch attacks against defenders head
    writeall('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' -attack PUNCH -target HEAD -number 10 -velocity 100 (Should succeed and add 10 punch attacks targeting defender head with velocity 100 and calculated hit chance)')
output = dfhack.run_command_silent('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' -attack PUNCH -target HEAD -number 10 -velocity 100')
writeall(output)
n = 0
bpn = 0
an = 0
for _,action in pairs(attacker.actions) do
 if action.type == 1 then
  if action.data.attack.target_unit_id == defender.id then
   if action.data.attack.attack_velocity == 100 and action.data.attack.target_body_part_id == bpn and action.data.attack.attack_id = an then
    n = n + 1
   end
  end
 end
end
if n ~= 10 then
 unitCheck[#unitCheck+1] = 'Failed to add 10 100 velocity punches to the head of defender'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/attack',COLOR_GREEN)
else
 printplus('FAILED: unit/attack',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/attack
scriptCheck['unit_attack'] = unitCheck
    writeall('unit/attack checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/attribute-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/attribute-change checks starting')
---- Check that the script succeeds and adds 50 strength to the unit
    writeall('unit/attribute-change -unit '..tostring(unit.id)..' -attribute STRENGTH -amount 50 -mode fixed (Should succeed and add 50 strength to the unit)')
val = unit.body.physical_attrs.STRENGTH.value
output = dfhack.run_command_silent('unit/attribute-change -unit '..tostring(unit.id)..' -attribute STRENGTH -amount 50 -mode fixed')
writeall(output)
if unit.body.physical_attrs.STRENGTH.value ~= val + 50 then
 unitCheck[#unitCheck+1] = 'Failed to add 50 strength to unit'
end
---- Check that the script succeeds and sets units toughness and endurance to 5000 for 50 ticks and creates a tracking table
    writeall('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ TOUGHNESS ENDURANCE ] -amount [ 5000 5000 ] -mode set -dur 50 -track (Should succeed and set units toughness and endurance to 5000 for 50 ticks and create a persistent unit table)')
output = dfhack.run_command_silent('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ TOUGHNESS ENDURANCE ] -amount [ 5000 5000 ] -mode set -dur 50 -track')
writeall(output)
if unit.body.physical_attrs.ENDURANCE.value ~= 5000 or unit.body.physical_attrs.TOUGHNESS.value ~= 5000 then
 unitCheck[#unitCheck+1] = 'Failed to set endurance and toughness to 5000'
end
    writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
  script.sleep(75,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
if unit.body.physical_attrs.ENDURANCE.value == 5000 or unit.body.physical_attrs.TOUGHNESS.value == 5000 then
 unitCheck[#unitCheck+1] = 'Failed to revert endurance and toughness from 5000'
end
if not safe_index(roses,'UnitTable',tostring(unit.id),'Attributes','ENDURANCE') then
 unitCheck[#unitCheck+1] = 'Failed to create tracking table'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/attribute-change',COLOR_GREEN)
else
 printplus('FAILED: unit/attribute-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/attribute-change
scriptCheck['unit_attribute_change'] = unitCheck
    writeall('unit/attribute-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/body-change
unitCheck = {}
unit = non[2]
    writeall('')
    writeall('unit/body-change checks starting')
---- Check that the script succeeds and set the eyes of unit on fire for 50 ticks
    writeall('unit/body-change -unit '..tostring(unit.id)..' -flag SIGHT -temperature Fire -dur 50 (Should succeed and set the eyes on fire for 50 ticks)')
output = dfhack.run_command_silent('unit/body-change -unit '..tostring(unit.id)..' -flag SIGHT -temperature Fire -dur 50')
writeall(output)
bps = unitFunctions.getBodyFlag(unit,'SIGHT')
for _,ids in pairs(bps) do
 if not unit.body.components.body_part_status[ids].on_fire then
  unitCheck[#unitCheck+1] = 'Failed to set SIGHT body parts on fire'
 end
end
    writeall('Pausing run_test.lua for 75 in-game ticks')
  script.sleep(75,'ticks')
    writeall('Resuming run_test.lua')
for _,ids in pairs(bps) do
 if unit.body.components.body_part_status[ids].on_fire then
  unitCheck[#unitCheck+1] = 'Failed to turn off fire of SIGHT body parts'
 end
end
scur = unit.body.size_info.size_cur
acur = unit.body.size_info.area_cur
lcur = unit.body.size_info.length_cur
---- Check that the script succeeds and sets the size of unit to half of the current
    writeall('unit/body-change -unit '..tostring(unit.id)..' -size All -amount 50 -mode Percent (Should succeed and set all sizes, size, length, and area, of the unit to 50 percent of the current)')
output = dfhack.run_command_silent('unit/body-change -unit '..tostring(unit.id)..' -size All -amount 50 -mode percent')
writeall(output)
if scur/unit.body.size_info.size_cur ~= 2 then
 unitCheck[#unitCheck+1] = 'Failed to set current size to 50% of previous size. Size ratio = '..tostring(scur/unit.body.size_info.size_cur)
end
if acur/unit.body.size_info.area_cur ~= 2 then
 unitCheck[#unitCheck+1] = 'Failed to set current area to 50% of previous area. Area ratio = '..tostring(acur/unit.body.size_info.area_cur)
end
if lcur/unit.body.size_info.length_cur ~= 2 then
 unitCheck[#unitCheck+1] = 'Failed to set current length to 50% of previous length. Length ratio = '..tostring(lcur/unit.body.size_info.length_cur)
end
---- Check that the script succeeds and sets the temperature of the upper body to 9000
    writeall('unit/body-change -unit '..tostring(unit.id)..' -token UB -temperature -mode Set -amount 9000 (Should succeed and set the upper body temperature to 9000)')
output = dfhack.run_command_silent('unit/body-change -unit '..tostring(unit.id)..' -token UB -temperature 9000')
writeall(output)
bps = unitFunctions.getBodyToken(unit,'UB')
for _,ids in pairs(bps) do
 if unit.status2.body_part_temperature[ids].whole ~= 9000 then
  unitCheck[#unitCheck+1] = 'Failed to set upper body temperature to 9000. Temperature = '..tostring(unit.status2.body_part_temperature[ids].whole)
 end
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/body-change',COLOR_GREEN)
else
 printplus('FAILED: unit/body-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/body-change
scriptCheck['unit_body_change'] = unitCheck
    writeall('unit/body-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- START unit/butcher
unitCheck = {}
unit = non[3]
    writeall('')
    writeall('unit/butcher checks starting')
---- Check that the script fails because unit is still alive
    writeall('unit/butcher -unit '..tostring(unit.id)..' (Should fail and print "Unit is still alive and has not been ordered -kill")')
output = dfhack.run_command_silent('unit/butcher -unit '..tostring(unit.id))
writeall(output)
if unit.flags1.dead then
 unitCheck[#unitCheck+1] = 'Incorrectly killed the unit'
end
---- Check that the script succeeds in killing and then butchering the unit
    writeall('unit/butcher -unit '..tostring(unit.id)..' -kill (Should succeed and kill unit then butcher it)')
output = dfhack.run_command_silent('unit/butcher -unit '..tostring(unit.id)..' -kill')
writeall(output)
    writeall('Pausing run_test.lua for 5 in-game ticks')
  script.sleep(5,'ticks')
    writeall('Resuming run_test.lua')
if not unit.flags1.dead then
 unitCheck[#unitCheck+1] = 'Failed to kill unit'
end
if #unit.corpse_parts < 1 then
 unitCheck[#unitCheck+1] = 'Failed to butcher unit'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/butcher',COLOR_GREEN)
else
 printplus('FAILED: unit/butcher',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/butcher
scriptCheck['unit_butcher'] = unitCheck
    writeall('unit/butcher checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/convert
unitCheck = {}
unit = non[4]
side = civ[1]
    writeall('')
    writeall('unit/convert checks starting')
---- Check that the script succeeds and changes the unit to a neutral
    writeall('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Neutral (Should succeed and change the unit to a neutral)')
output = dfhack.run_command_silent('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Neutral')
writeall(output)
if unit.civ_id ~= -1 and unit.population_id ~= -1 and unit.training_level ~= 9 then
 unitCheck[#unitCheck+1] = 'Failed to set unit to Neutral'
end
---- Check that the script succeeds and changes the unit to a civilian
    writeall('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Civilian (Should succeed and change the unit to a civilian)')
output = dfhack.run_command_silent('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Civilian')
writeall(output)
if unit.civ_id ~= side.civ_id and unit.population_id ~= side.population_id then
 unitCheck[#unitCheck+1] = 'Failed to set unit to Civilian'
end
---- Check that the script succeeds and changes the unit to a pet
    writeall('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Pet (Should succeed and change the unit to a pet of side)')
output = dfhack.run_command_silent('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Pet')
writeall(output)
if unit.population_id ~= -1 and not unit.flags1.tame and unit.training_level ~= 7 and unit.relationship_ids.Pet ~= side.id then
 unitCheck[#unitCheck+1] = 'Failed to set unit to Pet'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/convert',COLOR_GREEN)
else
 printplus('FAILED: unit/convert',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/convert
scriptCheck['unit_convert'] = unitCheck
    writeall('unit/convert checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/counter-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/counter-change checks starting')
---- Check that the script succeeds and increases nausea counter by 1000
    writeall('unit/counter-change -unit '..tostring(unit.id)..' -counter nausea -amount 1000 -mode Fixed (Should succeed and increase the nausea counter by 1000)')
output = dfhack.run_command_silent('unit/counter-change -unit '..tostring(unit.id)..' -counter nausea -amount 1000 -mode fixed')
writeall(output)
if unitFunctions.getCounter(unit,'nausea') < 1000 then
 unitCheck[#unitCheck+1] = 'Failed to increase units nausea counter by 1000. Unit nausea = '..tostring(unitFunctions.getCounter(unit,'nausea'))
end
---- Check that the script succeeds and sets hunger, thirst, and sleepiness timer to 0
    writeall('unit/counter-change -unit '..tostring(unit.id)..' -counter [ hunger thirst sleepiness ] -amount [ 0 0 0 ] -mode set (Should succeed and set hunger_timer, thirst_timer, and sleepiness_timer to 0)')
output = dfhack.run_command_silent('unit/counter-change -unit '..tostring(unit.id)..' -counter [ hunger thirst sleepiness ] -amount [ 0 0 0 ] -mode set')
writeall(output)
if unitFunctions.getCounter(unit,'hunger') ~= 0 then
 unitCheck[#unitCheck+1] = 'Failed to set hunger_timer to 0. Unit hunger = '..tostring(unitFunctions.getCounter(unit,'hunger'))
end
if unitFunctions.getCounter(unit,'thirst') ~= 0 then
 unitCheck[#unitCheck+1] = 'Failed to set thirst_timer to 0. Unit thirst = '..tostring(unitFunctions.getCounter(unit,'thirst'))
end
if unitFunctions.getCounter(unit,'sleepiness') ~= 0 then
 unitCheck[#unitCheck+1] = 'Failed to set sleepiness_timer to 0. Unit sleepiness = '..tostring(unitFunctions.getCounter(unit,'sleepiness'))
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/counter-change',COLOR_GREEN)
else
 printplus('FAILED: unit/counter-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/counter-change
scriptCheck['unit_counter_change'] = unitCheck
    writeall('unit/counter-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
-- START unit/create
unitCheck = {}
loc = {pos2xyz(civ[2].pos)}
location = tostring(loc[1])..' '..tostring(loc[2])..' '..tostring(loc[3])
side = civ[2]
    writeall('')
    writeall('unit/create checks starting')
---- Check that the script succeeds and creates a neutral male dwarf at given location
    writeall('unit/create -creature DWARF:MALE -loc [ '..location..' ] (Should succeed and create a neutral male dwarf at given location)')
output = dfhack.run_command_silent('unit/create -creature DWARF:MALE -loc [ '..location..' ]')
writeall(output)
---- Check that the script succeeds and creates a civilian male dwarf at the given location
    writeall('unit/create -creature DWARF:MALE -reference '..tostring(side.id)..' -side Civilian -loc [ '..location..' ] (Should succeed and create a civilian male dwarf at the reference units location)')
output = dfhack.run_command_silent('unit/create -creature DWARF:MALE -reference '..tostring(side.id)..' -side Civilian -loc [ '..location..' ]')
writeall(output)
---- Check that the script succeeds and creates a domestic dog (male or female) named Clifford
    writeall('unit/create -creature DOG:RANDOM -reference '..tostring(side.id)..' -side Domestic -name Clifford -loc [ '..location..' ] (Should succeed and create a domestic dog, male or female, named clifford at the reference units location)')
output = dfhack.run_command_silent('unit/create -creature DOG:RANDOM -reference '..tostring(side.id)..' -side Domestic -name Clifford -loc [ '..location..' ]')
writeall(output)
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/create',COLOR_GREEN)
else
 printplus('FAILED: unit/create',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/create
scriptCheck['unit_create'] = unitCheck
    writeall('unit/create checks finished')
]]
 printplus('NOTRUN: unit/create',COLOR_YELLOW)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
-- START unit/destory
unitCheck = {}
unit1 = df.unit.find(df.global.unit_next_id - 1)
unit2 = df.unit.find(df.global.unit_next_id - 2)
unit3 = df.unit.find(df.global.unit_next_id - 3)
    writeall('')
    writeall('unit/destroy checks starting')
---- Check that the script succeeds and removes Clifford the dog
    writeall('unit/destroy -unit '..tostring(unit3.id)..' -type Created (Should succeed and remove Clifford the dog and all references formed in the creation)')
output = dfhack.run_command_silent('unit/destroy -unit '..tostring(unit3.id)..' -type Created')
writeall(output)
---- Check that the script succeeds and kills the civilian dwarf as a normal kill
    writeall('unit/destory -unit '..tostring(unit2.id)..' -type Kill (Should succeed and kill the civilian dwarf as a normal kill)')
output = dfhack.run_command_silent('unit/destory -unit '..tostring(unit2.id)..' -type Kill')
writeall(output)
---- Check that the script succeeds and kills the neutral dwarf as a resurrected kill
    writeall('unit/destroy -unit '..tostring(unit1.id)..' -type Resurrected (Should succeed and kill the netural dwarf as if it were a resurrected unit)')
output = dfhack.run_command_silent('unit/destroy -unit '..tostring(unit1.id)..' -type Resurrected')
writeall(output)
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/destroy',COLOR_GREEN)
else
 printplus('FAILED: unit/destroy',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/destroy
scriptCheck['unit_destroy'] = unitCheck
    writeall('unit/destroy checks finished')
]]
 printplus('NOTRUN: unit/destroy',COLOR_YELLOW)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/emotion-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/emotion-change checks starting')
---- Check that the script succeeds and adds emotion XXXX with thought WWWW and severity and strength 0 to unit
    writeall('unit/emotion-change -unit '..tostring(unit.id)..' -emotion ACCEPTANCE (Should succeed and add emotion XXXX with thought WWWW and severity and strength 0 to unit)')
output = dfhack.run_command_silent('unit/emotion-change -unit '..tostring(unit.id)..' -emotion ACCEPTANCE')
writeall(output)
emotion = unit.status.current_soul.personality.emotions[#unit.status.current_soul.personality.emotions]
if df.emotion_type[emotion.type] ~= 'ACCEPTANCE' then
 unitCheck[#unitCheck+1] = 'Failed to add an ACCEPTANCE emotion'
end
---- Check that the script succeeds and adds emotion XXXX with thought ZZZZ and severity and strength 1000 to unit
    writeall('unit/emotion-change -unit '..tostring(unit.id)..' -emotion AGONY -thought Conflict -severity 100 -strength 100 -add (Should succeed and add emotion XXXX with thought ZZZZ and severity and strength 100 to unit)')
output = dfhack.run_command_silent('unit/emotion-change -unit '..tostring(unit.id)..' -emotion AGONY -thought Conflict -severity 100 -strength 100 -add')
writeall(output)
emotion = unit.status.current_soul.personality.emotions[#unit.status.current_soul.personality.emotions]
if df.emotion_type[emotion.type] ~= 'AGONY' and df.unit_thought_type[emotion.thought] ~= 'Conflict' then
 unitCheck[#unitCheck+1] = 'Failed to add an AGONY emotion with Conflict thought'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/emotion-change',COLOR_GREEN)
else
 printplus('FAILED: unit/emotion-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/emotion-change
scriptCheck['unit_emotion_change'] = unitCheck
    writeall('unit/emotion-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/flag-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/flag-change checks starting')
---- Check that the script succeeds and hides the unit
    writeall('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden_in_ambush -True (Should succeed and hide unit)')
output = dfhack.run_command_silent('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden_in_ambush -True')
writeall(output)
if not unit.flags1.hidden_in_ambush then
 unitCheck[#unitCheck+1] = 'Failed to hide the unit'
end
---- Check that the script succeeds and reveals the hidden unit
    writeall('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden_in_ambush -reverse (Should succeed and reveal hidden unit)')
output = dfhack.run_command_silent('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden_in_ambush -reverse')
writeall(output)
if unit.flags1.hidden_in_ambush then
 unitCheck[#unitCheck+1] = 'Failed to unhide the unit'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/flag-change',COLOR_GREEN)
else
 printplus('FAILED: unit/flag-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/flag-change
scriptCheck['unit_flag_change'] = unitCheck
    writeall('unit/flag-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/move
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/move checks starting')
---- Check that the script succeeds and moves the unit to a random position within a 5x5 square
    writeall('unit/move -unit '..tostring(unit.id)..' -random [ 5 5 0 ] (Should succeed and move the unit to a random position within a 5x5 square)')
output = dfhack.run_command_silent('unit/move -unit '..tostring(unit.id)..' -random [ 5 5 0 ]')
writeall(output)
positions = mapFunctions.getFillPosition(unit.pos,{5,5,0})
c = false
for _,pos in pairs(positions) do
 if unit.pos.x == pos.x and unit.pos.y == pos.y and unit.pos.z == pos.z then
  c = true
  break
 end
end
if not c then
 unitCheck[#unitCheck] = 'Failed to move unit to random location'
end
---- Check that the script succeeds and moves the unit to the test building
    writeall('unit/move -unit '..tostring(unit.id)..' -building TEST_BUILDING_3 (Should succeed and move the unit to the test building from earlier)')
output = dfhack.run_command_silent('unit/move -unit '..tostring(unit.id)..' -building TEST_BUILDING_3')
writeall(output)
bldgloc = dfhack.script_environment('functions/building').findBuilding({'RANDOM','CUSTOM','TEST_BUILDING_3'})[1]
if unit.pos.x ~= buildingCustom.centerx or unit.pos.y ~= buildingCustom.centery or unit.pos.z ~= buildingCustom.z then
 unitstr = '[ '..tostring(unit.pos.x)..' '..tostring(unit.pos.y)..' '..tostring(unit.pos.z)..' ]'
 bldgstr = '[ '..tostring(bldgloc.centerx)..' '..tostring(bldgloc.centery)..' '..tostring(bldgloc.z)..' ]'
 unitCheck[#unitCheck+1] = 'Failed to move unit to TEST_BUILDING_3. Unit pos = '..unitstr..'. Building pos = '..bldgstr
end
---- Check that the script succeeds and moves the unit to it's idle position
    writeall('unit/move -unit '..tostring(unit.id)..' -area Idle (Should succeed and move the unit to its idle position)')
output = dfhack.run_command_silent('unit/move -unit '..tostring(unit.id)..' -area Idle')
writeall(output)
if unit.pos.x ~= unit.idle_area.x or unit.pos.y ~= unit.idle_area.y or unit.pos.z ~= unit.idle_area.z then
 unitCheck[#unitCheck+1] = 'Failed to move unit to its idle area'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/move',COLOR_GREEN)
else
 printplus('FAILED: unit/move',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/move
scriptCheck['unit_move'] = unitCheck
    writeall('unit/move checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/propel
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/propel checks starting')
---- Check that the script succeeds and turns the unit into a projectile
    writeall('unit/propel -unitTarget '..tostring(unit.id)..' -velocity [ 0 0 100 ] -mode Fixed (Should succeed and turn the unitTarget into a projectile with velocity 100 in the z direction)')
output = dfhack.run_command_silent('unit/propel -unitTarget '..tostring(unit.id)..' -velocity [ 0 0 100 ] -mode Fixed')
writeall(output)
if not unit.flags1.projectile then
 unitCheck[#unitCheck+1] = 'Failed to turn unit into projectile'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/propel',COLOR_GREEN)
else
 printplus('FAILED: unit/propel',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/propel
scriptCheck['unit_propel'] = unitCheck
    writeall('unit/propel checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/resistance-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/resistance-change checks starting')
---- Check that the script succeeds and increases units fire resistance by 50 and creates tracking table
    writeall('unit/resistance-change -unit '..tostring(unit.id)..' -resistance FIRE -amount 50 -mode fixed (Should succeed and increase units fire resistance by 50, will also create unit persist table since there is no vanilla resistances)')
output = dfhack.run_command_silent('unit/resistance-change -unit '..tostring(unit.id)..' -resistance FIRE -amount 50 -mode fixed')
writeall(output)
_,base = unitFunctions.getUnit(unit,'Resistances','FIRE')
if math.floor(tonumber(base)) ~= 50 then
 unitCheck[#unitCheck+1] = 'Failed to increase units FIRE resistance to 50'
end
if not safe_index(roses,'UnitTable',tostring(unit.id),'Resistances','FIRE') then
 unitCheck[#unitCheck+1] = 'Failed to create FIRE resistance persistant table'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/resistance-change',COLOR_GREEN)
else
 printplus('FAILED: unit/resistance-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/resistance-change
scriptCheck['unit_resistance_change'] = unitCheck
    writeall('unit/resistance-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/skill-change
unitCheck = {}
unit = civ[1]
skill = dfhack.units.getNominalSkill(unit,df.job_skill['DODGING'])
    writeall('')
    writeall('unit/skill-change checks starting')
---- Check that the script succeeds and increases units dodging skill by 5 levels
    writeall('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGING -amount 5 -mode Fixed (Should succeed and increase units dodging skill by 5 levels)')
output = dfhack.run_command_silent('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGING -amount 5 -mode Fixed')
writeall(output)
if dfhack.units.getNominalSkill(unit,df.job_skill['DODGING']) ~= skill + 5 then
 unitCheck[#unitCheck+1] = 'Failed to increase units dodging skill by 5'
end
skill = skill + 5
---- Check that the script succeeds and doubles units dodging skill and creates tracking table
    writeall('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGING -amount 100 -mode Percent -track (Should succeed and double units dodging skill, will also create unit persist table)')
output = dfhack.run_command_silent('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGING -amount 100 -mode Percent -track')
writeall(output)
if dfhack.units.getNominalSkill(unit,df.job_skill['DODGING']) ~= skill*2 then
 unitCheck[#unitCheck+1] = 'Failed to increase units dodging skill by 200 percent'
end
if not safe_index(roses,'UnitTable',tostring(unit.id),'Skills','DODGING') then
 unitCheck[#unitCheck+1] = 'Failed to create DODGING skill persistant table'
end
-- EXPERIENCE MODE NOT CURRENTLY WORKING
---- Check that the script succeeds and adds 500 experience to the units mining skill
--    writeall('unit/skill-change -unit '..tostring(unit.id)..' -skill MINING -amount 500 -mode Experience (Should succeed and add 500 experience to the units mining skill)')
--output = dfhack.run_command_silent('unit/skill-change -unit '..tostring(unit.id)..' -skill MINING -amount 500 -mode Experience')
--writeall(output)
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/skill-change',COLOR_GREEN)
else
 printplus('FAILED: unit/skill-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/skill-change
scriptCheck['unit_skill_change'] = unitCheck
    writeall('unit/skill-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/stat-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/stat-change checks starting')
---- Check that the script succeeds and increases unit magical hit chance stat by 50 and creates tracking table
    writeall('unit/stat-change -unit '..tostring(unit.id)..' -stat CRITICAL_CHANCE -amount 50 -mode fixed (Should succeed and increase units magical hit chance by 50, will also create unit persist table since there is no vanilla stats)')
output = dfhack.run_command_silent('unit/stat-change -unit '..tostring(unit.id)..' -stat CRITICAL_CHANCE -amount 50 -mode fixed')
writeall(output)
_,base = unitFunctions.getUnit(unit,'Stats','CRITICAL_CHANCE')
if math.floor(tonumber(base)) ~= 50 then
 unitCheck[#unitCheck+1] = 'Failed to increase units stat CRITICAL_CHANCE by 50'
end
if not safe_index(roses,'UnitTable',tostring(unit.id),'Stats','CRITICAL_CHANCE') then
 unitCheck[#unitCheck+1] = 'Failed to create CRITICAL_CHANCE stat persistant table'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/stat-change',COLOR_GREEN)
else
 printplus('FAILED: unit/stat-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/stat-change
scriptCheck['unit_stat_change'] = unitCheck
    writeall('unit/stat-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/syndrome-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/syndrome-change checks starting')
---- Check that the script succeeds and adds TEST_SYNDROME_1 to the unit
    writeall('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -add (Should succeed and add TEST_SYNDROME_1 to the unit)')
output = dfhack.run_command_silent('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -add')
writeall(output)
if not unitFunctions.checkCreatureSyndrome(unit,'TEST_SYNDROME_1') then
 unitCheck[#unitCheck+1] = 'Failed to add TEST_SYNDROME_1 to unit'
end
---- Check that the script succeeds and adds 500 ticks to TEST_SYNDROME_1
    writeall('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -alterDuration 500 (Should succeed and add 500 ticks to TEST_SYNDROME_1 on the unit)')
output = dfhack.run_command_silent('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -alterDuration 500')
writeall(output)
_,_,ids = unitFunctions.getSyndrome(unit,'TEST_SYNDROME_1','name')
for _,id in pairs(ids) do
 if unit.syndromes.active[id].ticks < 500 then
  unitCheck[#unitCheck+1] = 'Failed to add 500 ticks to TEST_SYNDROME_1. TEST_SYNDROME_1 ticks = '..tostring(unit.syndromes.active[id].ticks)
 end
end
---- Check that the script succeeds and removes TEST_SYNDROME_1 to the unit
    writeall('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -erase (Should succeed and remove TEST_SYNDROME_1 to the unit)')
output = dfhack.run_command_silent('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -erase')
writeall(output)
if unitFunctions.checkCreatureSyndrome(unit,'TEST_SYNDROME_1') then
 unitCheck[#unitCheck+1] = 'Failed to remove TEST_SYNDROME_1 from unit'
end
---- Check that the script succeeds and adds TEST_SYNDROME_2 to the unit for 50 ticks
    writeall('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_2 -add -dur 50 (Should succeed and add TEST_SYNDROME_2 to the unit for 50 ticks)')
output = dfhack.run_command_silent('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_2 -add -dur 50')
writeall(output)
if not unitFunctions.checkCreatureSyndrome(unit,'TEST_SYNDROME_2') then
 unitCheck[#unitCheck+1] = 'Failed to add TEST_SYNDROME_2 to unit'
end
    writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
  script.sleep(75,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
if unitFunctions.checkCreatureSyndrome(unit,'TEST_SYNDROME_2') then
 unitCheck[#unitCheck+1] = 'Failed to remove TEST_SYNDROME_2 from unit'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/syndrome-change',COLOR_GREEN)
else
 printplus('FAILED: unit/syndrome-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/syndrome-change
scriptCheck['unit_syndrome_change'] = unitCheck
    writeall('unit/syndrome-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/trait-change
unitCheck = {}
unit = civ[1]
    writeall('')
    writeall('unit/trait-change checks starting')
---- Check that the script succeeds and lowers the units greed trait by 5
s = unit.status.current_soul.personality.traits.GREED
    writeall('unit/trait-change -unit '..tostring(unit.id).." -trait GREED -amount \\-5 -mode Fixed (Should succeed and lower units greed trait by 5)'")
output = dfhack.run_command_silent('unit/trait-change -unit '..tostring(unit.id)..' -trait GREED -amount \\-5 -mode Fixed')
writeall(output)
if unit.status.current_soul.personality.traits.GREED ~= s+5 and s+5 < 100 then
 unitCheck[#unitCheck+1] = 'Failed to increase GREED trait by 5. Previous GREED = '..tostring(s)..'. New GREED = '..tostring(unit.status.current_soul.personality.traits.GREED)
end
---- Check that the script succeeds and quarters the units bravery trait, also creates a tracking table
s = unit.status.current_soul.personality.traits.BRAVERY
    writeall('unit/trait-change -unit '..tostring(unit.id)..' -trait BRAVERY -amount 25 -mode Percent -track (Should succeed and quarter units bravery trait, will also create unit persist table)')
output = dfhack.run_command_silent('unit/trait-change -unit '..tostring(unit.id)..' -trait BRAVERY -amount 25 -mode Percent -track')
writeall(output)
if s/unit.status.current_soul.personality.traits.BRAVERY > 4.1 or s/unit.status.current_soul.personality.traits.BRAVERY < 3.9 then
 unitCheck[#unitCheck+1] = 'Failed to quarter BRAVERY trait. Previous BRAVERY = '..tostring(s)..'. New BRAVERY = '..tostring(unit.status.current_soul.personality.traits.BRAVERY)
end
if not safe_index(roses,'UnitTable',tostring(unit.id),'Traits','BRAVERY') then
 unitCheck[#unitCheck+1] = 'Failed to create BRAVERY trait persistant table'
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/trait-change',COLOR_GREEN)
else
 printplus('FAILED: unit/trait-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/trait-change
scriptCheck['unit_trait_change'] = unitCheck
    writeall('unit/trait-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/transform
unitCheck = {}
unit = civ[2]
    writeall('')
    writeall('unit/transform checks starting')
---- Check that the script succeeds and changes the unit into a male elf
    writeall('unit/transform -unit '..tostring(unit.id)..' -creature ELF:MALE (Should succeed and change the unit to a male elf)')
output = dfhack.run_command_silent('unit/transform -unit '..tostring(unit.id)..' -creature ELF:MALE')
writeall(output)
  script.sleep(2,'ticks')
if not unitFunctions.checkCreatureRace(unit,'ELF:MALE') then
 unitCheck[#unitCheck+1] = 'Failed to transform unit into ELF:MALE. Unit race/case = '..tostring(unit.race)..'/'..tostring(unit.caste)
end
---- Check that the script succeeds and changes the unit into a female dwarf for 50 ticks
    writeall('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:FEMALE -dur 50 -track (Should succeed and change the unit to a female dwarf for 50 ticks and create a unit persist table)')
output = dfhack.run_command_silent('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:FEMALE -dur 50 -track')
writeall(output)
  script.sleep(2,'ticks')
if not unitFunctions.checkCreatureRace(unit,'DWARF:FEMALE') then
 unitCheck[#unitCheck+1] = 'Failed to transfrom unit into DWARF:FEMALE. Unit race/caste = '..tostring(unit.race)..'/'..tostring(unit.caste)
end
    writeall('Pausing run_test.lua for 75 in-game ticks')
--df.global.pause_state = false
  script.sleep(75,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
if not unitFunctions.checkCreatureRace(unit,'ELF:MALE') then
 unitCheck[#unitCheck+1] = 'Failed to transform unit back into ELF:MALE from DWARF:FEMALE. Unit race/caste = '..tostring(unit.race)..'/'..tostring(unit.caste)
end
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/transform',COLOR_GREEN)
else
 printplus('FAILED: unit/transform',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/transform
scriptCheck['unit_transform'] = unitCheck
    writeall('unit/transform checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
-- START unit/wound-change
unitCheck = {}
unit = non[1]
    writeall('')
    writeall('unit/wound-change checks starting')
---- Check that the script succeeds and removes the most recent wound
    writeall('unit/wound-change -unit '..tostring(unit.id)..' -remove 1 -recent (Should succeed and remove the most recent wounds)')
output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -remove 1 -recent')
writeall(output)
---- Check that the script succeeds and regrows any lost limbs
    writeall('unit/wound-change -unit '..tostring(unit.id)..' -remove All -regrow (Should succeed and remove all wounds and return any lost limbs)')
output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -remove All -regrow')
writeall(output)
---- Kills the unit
    writeall('Killing unit')
output = dfhack.run_command_silent('unit/counter-change -unit '..tostring(unit.id)..' -counter blood -amount 0 -mode set')
writeall(output)
  script.sleep(1,'ticks')
---- Checks that the script succeeds and brings the unit back to life
    writeall('unit/wound-change -unit '..tostring(unit.id)..' -resurrect (Should succeed and bring unit back to life)')
output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -resurrect')
writeall(output)
---- Kills and butchers the unit
    writeall('Killing and Butcher unit')
output = dfhack.run_command_silent('unit/butcher -unit '..tostring(unit.id)..' -kill')
writeall(output)
---- Check that the script succeeds and brings back all corpse parts as zombies
    writeall('unit/wound-change -unit '..tostring(unit.id)..' -animate (Should succeed and bring all corpse parts back as zombies)')
output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -animate')
writeall(output)
---- Print PASS/FAIL
if #unitCheck == 0 then
 printplus('PASSED: unit/wound-change',COLOR_GREEN)
else
 printplus('FAILED: unit/wound-change',COLOR_RED)
 writeall(unitCheck)
end
-- FINISH unit/wound-change
scriptCheck['unit_wound_change'] = unitCheck
    writeall('unit/wound-change checks finished')
]]
 printplus('NOTRUN: unit/wound-change',COLOR_YELLOW) -- (Need to add ability to add wounds before taking away wounds)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Unit script checks finished',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- WRAPPER SCRIPT CHECKS------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Wrapper script checks starting',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START Unit Based Targeting
    writeall('Unit Based Targeting Starting')
wrapCheck = {}
unit = civ[1]
targ = civ[2]
----
    writeall('wrapper -checkUnit RACE -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -script [ devel/print-args TARGET_UNIT_ID ]')
output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -checkUnit RACE -script [ devel/print-args TARGET_UNIT_ID ]')
writeall(output)
----
    writeall('wrapper -checkUnit DOMESTIC -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -script [ devel/print-args TARGET_UNIT_LOCATION ]')
output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -checkUnit DOMESTIC -script [ devel/print-args TARGET_UNIT_LOCATION ]')
writeall(output)
----
    writeall('wrapper -checkUnit CIV -sourceUnit '..tostring(unit.id)..' -targetUnit '..tostring(targ.id)..' -requiredCreature DWARF:MALE -script [ devel/print-args TARGET_UNIT_DESTINATION ]')
output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -targetUnit '..tostring(targ.id)..' -checkUnit CIV -requiredCreature DWARF:MALE -script [ devel/print-args TARGET_UNIT_DESTINATION ]')
writeall(output)
----
checks = '-checkUnit ANY -radius 100 '
checks = checks..'-requiredClass GENERAL_POISON -immuneClass [ TEST_CLASS_1 TEST_SYNCLASS_1 ] '
checks = checks..'-requiredCreature DWARF:ALL -immuneCreature [ DONKEY:FEMALE HORSE:MALE ] '
checks = checks..'-requiredSyndrome "test syndrome" -immuneSyndrome [ syndromeOne syndromeTwo ] '
checks = checks..'-requiredToken COMMON_DOMESTIC -immuneToken [ FLIER MEGABEAST ] '
checks = checks..'-requiredNoble MONARCH -immuneNoble [ BARON DUKE ] '
checks = checks..'-requiredProfession MINER -immuneProfession [ MILLING PLANT ] '
checks = checks..'-requiredEntity MOUNTAIN -immuneEntity [ FOREST PLAIN ] '
checks = checks..'-requiredPathing FLEEING -immunePathing [ PATROL IDLE ] '
checks = checks..'-maxAttribute STRENGTH:5000 -minAttribute [ TOUGHNESS:500 ENDURANCE:500 ] -gtAttribute WILLPOWER:2 -ltAttribute AGILITY:1 '
checks = checks..'-maxSkill MINING:5 -minSkill [ BUTCHER:2 TANNER:2 ] -gtSkill MASONRY:1 -ltSkill CARPENTRY:1 '
checks = checks..'-maxTrait ANGER_PROPENSITY:50 -minTrait [ LOVE_PROPENSITY:10 HATE_PROPENSITY:10 ] -gtTrait LUST_PROPENSITY:1 -ltTrait ENVY_PROPENSITY:1 '
checks = checks..'-maxAge 100 -minAge 1 -gtAge 1 -ltAge 1 '
checks = checks..'-maxSpeed 500 -minSpeed 1 -gtSpeed 1 -ltSpeed 1'
    writeall('wrapper -sourceUnit '..tostring(unit.id)..' '..checks..' -test -script [ devel/print-args TARGET_UNIT_ID ]')
output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -center '..checks..' -test -script [ devel/print-args TARGET_UNIT_ID ]')
writeall(output)
---- Print PASS/FAIL
if #wrapCheck == 0 then
 printplus('PASSED: Unit Based Targeting',COLOR_GREEN)
else
 printplus('FAILED: Unit Based Targeting',COLOR_RED)
 writeall(wrapCheck)
end
-- FINISH Unit Based Targeting
    writeall('Unit Based Targeting Finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START Location Based Targeting
    writeall('Location Based Targeting Starting')
wrapCheck = {}
pos = civ[3].pos
loc = '[ '..tostring(pos.x)..' '..tostring(pos.y)..' '..tostring(pos.z)..' ]'
pos = civ[2].pos
tar = '[ '..tostring(pos.x)..' '..tostring(pos.y)..' '..tostring(pos.z)..' ]'
----
    writeall('wrapper -checkLocation LEVEL -sourceLocation '..loc..' -targetLocation '..tar..' -requiredLiquid WATER -script [ devel/print-args TARGET_POSITION ]')
output = dfhack.run_command_silent('wrapper -checkLocation LEVEL -sourceLocation '..loc..' -targetLocation '..tar..' -requiredLiquid WATER -script [ devel/print-args TARGET_POSITION ]')
writeall(output)
----
    writeall('wrapper -checkLocation ABOVE -sourceUnit '..tostring(civ[3].id)..' -targetUnit '..tostring(civ[2].id)..' -forbiddenFLOW DRAGONFIRE -script [ devel/print-args TARGET_POSITION ]')
output = dfhack.run_command_silent('wrapper -checkLocation ABOVE -sourceUnit '..tostring(civ[3].id)..' -targetUnit '..tostring(civ[2].id)..' -forbiddenFLOW DRAGONFIRE -script [ devel/print-args TARGET_POSITION ]')
writeall(output)
----
    writeall('wrapper -checkLocation BELOW -sourceLocation '..loc..' -center -forbiddenTree [CEDAR MAPLE OAK ] -script [ devel/print-args TARGET_POSITION ]')
output = dfhack.run_command_silent('wrapper -checkLocation BELOW -sourceLocation '..loc..' -center -forbiddenTree [CEDAR MAPLE OAK ] -script [ devel/print-args TARGET_POSITION ]')
writeall(output)
----
checks = '-checkLocation ANY -radius 100 '
checks = checks..'-requiredTree CEDAR -forbiddenTree [ MAPLE OAK ] '
checks = checks..'-requiredGrass GRASS_1 -forbiddenGrass [ GRASS_2 GRASS_3 ] '
checks = checks..'-requiredPlant STRAWBERRY -forbiddenPlant [ BLUEBERRY BLACKBERRY ] '
checks = checks..'-requiredLiquid WATER -forbiddenLiquid MAGMA '
checks = checks..'-requiredInorganic OBSIDIAN -forbiddenInorganic [ SLADE MARBLE ] '
checks = checks..'-requiredFlow MIST -forbiddenFlow [ MIASMA DRAGONFIRE ] '
    writeall('wrapper -sourceLocation '..loc..' -center '..checks..' -test -script [ devel/print-args TARGET_POSITION ]')
output = dfhack.run_command_silent('wrapper -sourceLocation '..loc..' -center '..checks..' -test -script [ devel/print-args TARGET_POSITION ]')
writeall(output)
---- Print PASS/FAIL
if #wrapCheck == 0 then
 printplus('PASSED: Location Based Targeting', COLOR_GREEN)
else
 printplus('FAILED: Location Based Targeting', COLOR_RED)
 writeall(wrapCheck)
end
-- FINISH Location Based Targeting
    writeall('Location Based Targeting Finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START Item Based Targeting
    writeall('Item Based Targeting Starting')
wrapCheck = {}
----
    writeall('wrapper -checkItem INVENTORY -sourceUnit '..tostring(civ[2].id)..' -targetUnit '..tostring(civ[3].id)..' -requiredItem WEAPON:ITEM_SWORD_SHORT -script [ devel/print-args TARGET_ITEM_ID ]')
output = dfhack.run_command_silent('wrapper -checkItem INVENTORY -sourceUnit '..tostring(civ[2].id)..' -targetUnit '..tostring(civ[3].id)..' -requiredItem WEAPON:ITEM_SWORD_SHORT -script [ devel/print-args TARGET_ITEM_ID ]')
writeall(output)
----
    writeall('wrapper -checkItem ONGROUND -sourceUnit '..tostring(civ[2].id)..' -center -radius [ 20 20 20 ] -requiredCorpse ALL -script [ devel/print-args TARGET_ITEM_ID ]')
output = dfhack.run_command_silent('wrapper -checkItem ONGROUND -sourceUnit '..tostring(civ[2].id)..' -center -radius [ 20 20 20 ] -requiredCorpse ALL -script [ devel/print-args TARGET_ITEM_ID ]')
writeall(output)
----
    writeall('wrapper -checkItem PROJECTILE -sourceLocation '..loc..' -center -radius [2 2 1 ] -requiredMaterial INORGANIC:IRON -script [ devel/print-args TARGET_ITEM_ID ]')
output = dfhack.run_command_silent('wrapper -checkItem PROJECTILE -sourceLocation '..loc..' -center -radius [2 2 1 ] -requiredMaterial INORGANIC:IRON -script [ devel/print-args TARGET_ITEM_ID ]')
writeall(output)
----
checks = '-checkItem ANY -radius 100 '
checks = checks..'-requiredItem STATUE -forbiddenItem [ WEAPON:ITEM_WEAPON_LONGSWORD AMMO:ITEM_AMMO_BOLT ] '
checks = checks..'-requiredMaterial STEEL -forbiddenMaterial [ SILVER GOLD ] '
checks = checks..'-requiredCorpse DWARF -forbiddenCorpse [ HUMAN:MALE ELF:FEMALE ] '
    writeall('wrapper -sourceUnit '..tostring(unit.id)..' -center '..checks..' -test -script [ devel/print-args TARGET_ITEM_ID ]')
output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -center '..checks..' -test -script [ devel/print-args TARGET_ITEM_ID ]')
writeall(output)
---- Print PASS/FAIL
if #wrapCheck == 0 then
 printplus('PASSED: Item Based Targeting', COLOR_GREEN)
else
 printplus('FAILED: Item Based Targeting', COLOR_RED)
 writeall(wrapCheck)
end
-- FINISH Item Based Targeting
    writeall('Item Based Targeting Finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Wrapper script checks finished',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Finished Roses Script Checks')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SYSTEM CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Beginning System Checks')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--printplus('Running base/roses-init with all systems enabled')
--local classCheck = ' -classSystem [ Feats Spells ]'
--local civCheck = ' -civilizationSystem [ Diplomacy ]'
--local eventCheck = ' -eventSystem'
--local enhCheck = ' -enhancedSystem [ Buildings Creatures Items Materials Reactions ]'
--local verbose = true
--printplus('base/roses-init'..classCheck..civCheck..eventCheck..enhCheck..' -verbose -testRun -forceReload')
--output = dfhack.run_command_silent('base/roses-init'..classCheck..civCheck..eventCheck..enhCheck..' -verbose -testRun -forceReload')
--writeall(output)
local persistTable = require 'persist-table'
local roses = persistTable.GlobalTable.roses
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Running Base commands:')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/persist-delay')
output = dfhack.run_command_silent('base/persist-delay -verbose')
writeall(output)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/liquids-update')
output = dfhack.run_command_silent('base/liquids-update -verbose')
writeall(output)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/flows-update')
output = dfhack.run_command_silent('base/flows-update -verbose')
writeall(output)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-death')
output = dfhack.run_command_silent('base/on-death -verbose')
writeall(output)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-time')
output = dfhack.run_command_silent('base/on-time -verbose')
writeall(output)

--print('Running base/periodic-check')
-- dfhack.run_command_silent('base/periodic-check -verbose')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    writeall('Beginning System Run Checks')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLASS SYSTEM CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('base/roses-init -classSystem [ Feats Spells ] -verbose -testRun')
output = dfhack.run_command_silent('base/roses-init -classSystem [ Feats Spells ] -verbose -testRun')
writeall(output)
-- START Class System Checks
printplus('')
printplus('Class System Checks Starting',COLOR_CYAN)
classCheck = {}
unit = civ[4]
unitTable = roses.UnitTable[tostring(unit.id)]
if not unitTable then
 tableFunctions.makeUnitTable(unit)
end
unitTable = roses.UnitTable[tostring(unit.id)]
----
    writeall('Attempting to assign Test Class 1 to unit')
output = dfhack.run_command_silent('classes/change-class -unit '..tostring(unit.id)..' -class TEST_CLASS_1 -verbose')
writeall(output)
if unitTable.Classes.Current.Name ~= 'TEST_CLASS_1' then 
 classCheck[#classCheck+1] = 'Test Class 1 was not assigned to the Unit'
end
----
    writeall('Adding experience to unit - Will level up Test Class 1 to level 1 and assign Test Spell 1')
    writeall('Mining and Woodcutting skill will increase')
output = dfhack.run_command_silent('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
writeall(output)
if unitTable.Classes.TEST_CLASS_1.Level ~= '1' then 
 classCheck[#classCheck+1] = 'Test Class 1 did not level from 0 to 1'
end
--if unitTable.Skills.MINING.Class ~= '1' or unitTable.Skills.WOODCUTTING.Class ~= '1' then
-- classCheck[#classCheck+1] = 'Test Class 1 level 1 skills were not applied correctly'
--end
if unitTable.Spells.TEST_SPELL_1 ~= '1' or not unitTable.Spells.Active.TEST_SPELL_1 then
 classCheck[#classCheck+1] = 'Test Class 1 level 1 did not add Test Spell 1'
end
----
    writeall('Adding experience to unit - Will level up Test Class 1 to level 2')
    writeall('Mining and Woodcutting skill will increase')
output = dfhack.run_command_silent('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
writeall(output)
if unitTable.Classes.TEST_CLASS_1.Level ~= '2' then
 classCheck[#classCheck+1] = 'Test Class 1 did not level from 1 to 2'
end
--if unitTable.Skills.MINING.Class ~= '5' or unitTable.Skills.WOODCUTTING.Class ~= '4' then
-- classCheck[#classCheck+1] = 'Test Class 1 level 2 skills were not applied correctly'
--end
----
    writeall('Assigning Test Spell 2 to unit')
output = dfhack.run_command_silent('classes/learn-skill -unit '..tostring(unit.id)..' -spell TEST_SPELL_2 -verbose')
writeall(output)
--if unitTable.Spells.TEST_SPELL_2 ~= '1' or not unitTable.Spells.Active.TEST_SPELL_2 then
-- classCheck[#classCheck+1] = 'Test Class 1 level 2 unable to add Test Spell 2'
--end
----
    writeall('Adding experience to unit - Will level up Test Class 1 to level 3 and auto change class to Test Class 2')
    writeall('Mining skill will increase, Woodcutting skill will reset')
output = dfhack.run_command_silent('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
writeall(output)
if unitTable.Classes.Current.TotalExp ~= '3' or unitTable.Classes.TEST_CLASS_1.Level ~= '3' then
 classCheck[#classCheck+1] = 'Test Class 1 did not level from 2 to 3'
end
--if unitTable.Skills.MINING.Class ~= '14' then
-- classCheck[#classCheck+1] = ''
--end
if unitTable.Classes.Current.Name ~= 'TEST_CLASS_2' then
 classCheck[#classCheck+1] = 'Test Class 1 did not automatically changed to Test Class 2'
end
if unitTable.Skills.WOODCUTTING.Class ~= '0' then
 classCheck[#classCheck+1] = 'Test Class 2 level 0 skills did not reset. Woodcutting class skill = '..tostring(unitTable.Skills.WOODCUTTING.Class)
end
----
    writeall('Adding experience to unit - Will level up Test Class 2 to level 1 and replace Test Spell 1 with Test Spell 3')
    writeall('Mining skill will remain the same, Carpentry skill will increase')
output = dfhack.run_command_silent('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
writeall(output)
if unitTable.Classes.Current.TotalExp ~= '4' or unitTable.Classes.TEST_CLASS_2.Level ~= '1' then
 classCheck[#classCheck+1] = 'Test Class 2 did not level from 0 to 1'
end
--if unitTable.Skills.MINING.Class ~= '14' or unitTable.Skills.CARPENTRY.Class ~= '15' or unitTable.Skills.MASONRY.Class ~= '15' then
-- classCheck[#classCheck+1] = 'Test Class 2 level 1 skills were not applied correctly'
--end
if unitTable.Spells.TEST_SPELL_3 ~= '1' or unitTable.Spells.Active.TEST_SPELL_1 or not unitTable.Spells.Active.TEST_SPELL_3 then
 classCheck[#classCheck+1] = 'Test Class 2 level 1 Test Spell 3 did not replace Test Spell 1'
end
---- Print PASS/FAIL
if #classCheck == 0 then
 printplus('PASSED: Class System - Base',COLOR_GREEN)
else
 printplus('FAILED: Class System - Base',COLOR_RED)
 writeall(classCheck)
end
-- FINISH Class System Checks
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START Feat SubSystem Checks
    writeall('Feat SubSystem Checks Starting')
featCheck = {}
----
    writeall('Attempting to assign Test Feat 2 to unit, this should fail')
output = dfhack.run_command_silent('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_2 -verbose')
writeall(output)
if unitTable.Feats.TEST_FEAT_2 then
 featCheck[#featCheck+1] = 'Test Feat 2 was applied when it should not have been'
end
----
    writeall('Attempting to assign Test Feat 1 to unit, this should work')
output = dfhack.run_command_silent('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_1 -verbose')
writeall(output)
if not unitTable.Feats.TEST_FEAT_1 then
 featCheck[#featCheck+1] = 'Test Feat 1 was not correctly applied'
end
----
    writeall('Attempting to assign Test Feat 2 to unit, now this should work')
output = dfhack.run_command_silent('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_2 -verbose')
writeall(output)
if not unitTable.Feats.TEST_FEAT_2 then
 featCheck[#featCheck+1] = 'Test Feat 2 was not correctly applied'
end
---- Print PASS/FAIL
if #featCheck == 0 then
 printplus('PASSED: Class System - Feats',COLOR_GREEN)
else
 printplus('FAILED: Class System - Feats',COLOR_RED)
 writeall(featCheck)
end
-- FINISH Feat SubSystem Checks
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START Spell SubSystem Checks
spellCheck = {}
---- Print PASS/FAIL
if #spellCheck == 0 then
 printplus('NOCHECK: Class System - Spells',COLOR_YELLOW)
else
 printplus('NOCHECK: Class System - Spells',COLOR_YELLOW)
 writeall(spellCheck)
end
-- FINISH Spell SubSystem Checks
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Class System Checks Finished',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CIVILIZATION SYSTEM CHECKS ------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('base/roses-init -civilizationSystem [ Diplomacy ] -verbose -test')
output = dfhack.run_command_silent('base/roses-init -civilizationSystem [ Diplomacy ] -verbose -test')
writeall(output)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Civilization System Checks Starting',COLOR_CYAN)
civCheck = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    writeall('')
    writeall('Creating Entity Table for MOUNTAIN entity')
civID = df.global.ui.civ_id
tableFunctions.makeEntityTable(civID,false)
entityTable = roses.EntityTable[tostring(civID)]
if not entityTable.Civilization then
 civCheck[#civCheck+1] = 'Test Civilization 1 was not correctly assigned to the entity'
end
if #df.global.world.entities.all[civID].resources.animals.mount_races ~= 0 then
 civCheck[#civCheck+1] = 'Test Civilization 1 level 0 mount creatures were not removed'
end
    writeall('Force level increase, should add dragons to available mounts and change level method')
output = dfhack.run_command_silent('civilizations/level-up -civ '..tostring(civID)..' -amount 1 -verbose')
writeall(output)
if entityTable.Civilization.Level ~= '1' then
 civCheck[#civCheck+1] = 'Test Civilization 1 did not correctly level up from 0 to 1'
end
if #df.global.world.entities.all[civID].resources.animals.mount_races ~= 2 then
 civCheck[#civCheck+1] = 'Test Civilization 1 level 1 mount creatures were not added'
end
    writeall('Next level increase should occur within 1 in-game day, will add humans as available mounts')
    writeall('Pausing run_test.lua for 3200 in-game ticks')
--df.global.pause_state = false
  script.sleep(6500,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
if entityTable.Civilization.Level ~= '2' then
 civCheck[#civCheck+1] = 'Test Civilization 1 did not correctly level up from 1 to 2' end
if #df.global.world.entities.all[civID].resources.animals.mount_races ~= 3 then
 civCheck[#civCheck+1] = 'Test Civilization 1 level 2 mount creatures were not added'
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    writeall('')
    writeall('Testing full removal and addition with Test Civ 2')
    writeall('Finding entity id for a FOREST entity')
entity = nil
for _,x in pairs(df.global.world.entities.all) do
 if x.entity_raw.code == 'FOREST' then
  entity = x
  break
 end
end
if not entity then print('No Forest Entity Found, will produce errors') end
    writeall('Creating Entity Table for FOREST entity')
tableFunctions.makeEntityTable(entity.id,false)
 nCheck = {
           pets = {'animals','pet_races'},
           wagon = {'animals','wagon_puller_races'},
           mount = {'animals','mount_races'},
           pack = {'animals','pack_animal_races'},
           minion = {'animals','minion_races'},
           exotic = {'animals','exotic_pet_races'},
           fish = {'fish_races'},
           egg = {'egg_races'},
           metal = {'metals'},
           stone = {'stones'},
           gem = {'gems'},
           leather = {'organic','leather','mat_type'},
           fiber = {'organic','fiber','mat_type'},
           silk = {'organic','silk','mat_type'},
           wool = {'organic','wool','mat_type'},
           wood = {'organic','wood','mat_type'},
           plant = {'plants','mat_type'},
           seed = {'seeds','mat_type'},
           bone = {'refuse','bone','mat_type'},
           shell = {'refuse','shell','mat_type'},
           ivory = {'refuse','ivory','mat_type'},
           horn = {'refuse','horn','mat_type'},
           weapon = {'weapon_type'},
           shield = {'shield_type'},
           ammo = {'ammo_type'},
           helm = {'helm_type'},
           armor = {'armor_type'},
           pants = {'pants_type'},
           shoes = {'shoes_type'},
           gloves = {'gloves_type'},
           trap = {'trapcomp_type'},
           siege = {'siegeammo_type'},
           toy = {'toy_type'},
           --instrument = {'instrument_type'},
           tool = {'tool_type'},
           pick = {'metal','pick','mat_type'},
           melee = {'metal','weapon','mat_type'},
           ranged = {'metal','ranged','mat_type'},
           ammo2 = {'metal','ammo','mat_type'},
           ammo3 = {'metal','ammo2','mat_type'},
           armor2 = {'metal','armor','mat_type'},
           anvil = {'metal','anvil','mat_type'},
           crafts = {'misc_mat','crafts','mat_type'},
           barrels = {'misc_mat','barrels','mat_type'},
           flasks = {'misc_mat','flasks','mat_type'},
           quivers = {'misc_mat','quivers','mat_type'},
           backpacks = {'misc_mat','backpacks','mat_type'},
           cages = {'misc_mat','cages','mat_type'},
           glass = {'misc_mat','glass','mat_type'},
           sand = {'misc_mat','sand','mat_type'},
           clay = {'misc_mat','clay','mat_type'},
           booze = {'misc_mat','booze','mat_type'},
           cheese = {'misc_mat','cheese','mat_type'},
           powders = {'misc_mat','powders','mat_type'},
           extracts = {'misc_mat','extracts','mat_type'},
           meat = {'misc_mat','meat','mat_type'}
          }
    writeall('Assigning Civlization to Entity, should clear all resources') 
for xCheck,aCheck in pairs(nCheck) do
 resources = entity.resources
 for _,tables in pairs(aCheck) do
  resources = resources[tables]
 end
--    writeall(resources)
 if #resources ~= 0 then
  civCheck[#civCheck+1] = 'Test Civilization 2 level 0 '..table.concat(aCheck,' ')..' not correctly removed from'
 end
end
    writeall('Force level increase, should add a single item to each resource category')
output = dfhack.run_command_silent('civilizations/level-up -civ '..tostring(entity.id)..' -amount 1 -verbose')
writeall(output)
for xCheck,aCheck in pairs(nCheck) do
 resources = entity.resources
 for _,tables in pairs(aCheck) do
  resources = resources[tables]
 end
--    writeall(resources)
 if #resources < 1 then
  civCheck[#civCheck+1] = 'Test Civilization 2 level 1 '..table.concat(aCheck,' ')..' not correctly added to'
 end
end
    writeall('Force level increase, should fail to level up for many different reasons')
output = dfhack.run_command_silent('civilizations/level-up -civ '..tostring(entity.id)..' -amount 1 -verbose')
writeall(output)
if roses.EntityTable[tostring(entity.id)].Civilization.Level == 3 then
 civCheck[#civCheck+1] = 'Test Civilization 2 level 2 incorrectly applied, should have failed'
end
---- Print PASS/FAIL
if #civCheck == 0 then
 printplus('PASSED: Civilization System - Base',COLOR_GREEN)
else
 printplus('FAILED: Civilization System - Base',COLOR_RED)
 writeall(civCheck)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Civilization System Checks Finished',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENHANCED SYSTEM CHECKS ----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('base/roses-init -enhancedSystem [ Buildings Creatures Items Materials Reactions ] -verbose -test')
output = dfhack.run_command_silent('base/roses-init -enhancedSystem [ Buildings Creatures Items Materials Reactions ] -verbose -test')
writeall(output)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Enhanced System Checks Starting',COLOR_CYAN)
enhCheck = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
-- START Enhanced System - Buildings
    writeall('')
    writeall('Enhanced System - Buildings Starting')
EBCheck = {}
---- Print PASS/FAIL
if #EBCheck == 0 then
 printplus('PASSED: Enhanced System - Buildings')
else
 printplus('FAILED: Enhanced System - Buildings')
 writeall(EBCheck)
end
-- FINISH Enhanced System - Buildings
    writeall('Enhanced System - Buildings Finished')
]]
 printplus('NOCHECK: Enhanced System - Buildings',COLOR_YELLOW)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START Enhanced System - Creatures
    writeall('')
    writeall('Enhanced System - Creatures Starting')
    writeall('Enhancing all dwarf creatures')
    writeall('Agility should be increased to between 5000 and 8000 and PLANT skill to between 5 and 15')
ECCheck = {}
unit = civ[5]
unitTable = roses.UnitTable[tostring(unit.id)]
if not unitTable then tableFunctions.makeUnitTable(unit.id) end
unitTable = roses.UnitTable[tostring(unit.id)]
    writeall('Before:')
    writeall(unit.body.physical_attrs.AGILITY)
--    writeall(unitTable.Skills)
for _,unit in pairs(df.global.world.units.active) do
 if dfhack.units.isDwarf(unit) then
  enhancedFunctions.enhanceCreature(unit)
 end
end
    writeall('After:')
    writeall(unit.body.physical_attrs.AGILITY)
--    writeall(unitTable.Skills)
_,base = unitFunctions.getUnit(unit,'Skills','PLANT')
if unit.body.physical_attrs.AGILITY.value < 5000 or base < 5 then
 ECCheck[#ECCheck+1] = 'Enhanced System - Creature 1 not correctly applied. Agility = '..tostring(unit.body.physical_attrs.AGILITY.value)..'. Plant = '..tostring(base)
end
if #ECCheck == 0 then
 printplus('PASSED: Enhanced System - Creatures',COLOR_GREEN)
else
 printplus('FAILED: Enhanced System - Creatures',COLOR_RED)
 writeall(ECCheck)
end
-- FINISH Enhanced System - Creatures
    writeall('Enhanced System - Creatures Finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START Enhanced System - Items
    writeall('')
    writeall('Enhanced System - Items Starting')
    writeall('When the pick is equipped the units Axe skill should increase to legendary')
    writeall('When the hand axe is equipped the unit should learn the Test Spell 1 spell')
    writeall('Both effects should revert when the item is unequipped')
    writeall('Running modtools/item-trigger')
EICheck = {}
base = 'modtools/item-trigger -itemType ITEM_WEAPON_PICK -onEquip -command'
output = dfhack.run_command_silent(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -equip ]')
writeall(output)
base = 'modtools/item-trigger -itemType ITEM_WEAPON_HANDAXE -onEquip -command'
output = dfhack.run_command_silent(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -equip ]')
writeall(output)
base = 'modtools/item-trigger -itemType ITEM_WEAPON_PICK -onUnequip -command'
output = dfhack.run_command_silent(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -unequip ]')
writeall(output)
base = 'modtools/item-trigger -itemType ITEM_WEAPON_HANDAXE -onUnequip -command'
output = dfhack.run_command_silent(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -unequip ]')
writeall(output)
----
    writeall('')
    writeall('Testing Enhanced Item 1 - ITEM_WEAPON_PICK')
output = dfhack.run_command_silent('item/create -creator '..tostring(unit.id)..' -item WEAPON:ITEM_WEAPON_PICK -material INORGANIC:STEEL -verbose')
writeall(output)
    writeall('Before Equipping the pick')
----
output = dfhack.run_command_silent('item/equip -unit '..tostring(unit.id)..' -item MOST_RECENT -verbose')
writeall(output)
    writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
--df.global.pause_state = false
  script.sleep(50,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
    writeall('After Equipping the pick')
--    writeall(unitTable.Skills)
if unitTable.Skills.AXE.Item < '15' then
 EICheck[#EICheck+1] = 'Enhanced System - Item 1 equip skill change not correctly applied'
end
----
output = dfhack.run_command_silent('item/unequip -unit '..tostring(unit.id)..' -itemType WEAPON -verbose')
writeall(output)
    writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
--df.global.pause_state = false
  script.sleep(50,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
    writeall('After UnEquipping the pick')
if unitTable.Skills.AXE.Item > '0' then
 EICheck[#EICheck+1] = 'Enhanced System - Item 1 unequip skill change not correctly applied'
end
----
    writeall('')
    writeall('Testing Enhanced Item 2 - ITEM_WEAPON_HANDAXE')
output = dfhack.run_command_silent('item/create -creator '..tostring(unit.id)..' -item WEAPON:ITEM_WEAPON_HANDAXE -material INORGANIC:STEEL -verbose')
writeall(output)
    writeall('Before Equipping the hand axe')
    writeall(unitTable.Spells.Active)
----
output = dfhack.run_command_silent('item/equip -unit '..tostring(unit.id)..' -item MOST_RECENT -verbose')
writeall(output)
    writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
--df.global.pause_state = false
  script.sleep(50,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
    writeall('After Equipping the hand axe')
if not unitTable.Spells.Active.TEST_SPELL_1 then
 EICheck[#EICheck+1] = 'Enhanced System - Item 2 equip spell change not correctly applied'
end
----
output = dfhack.run_command_silent('item/unequip -unit '..tostring(unit.id)..' -itemType WEAPON -verbose')
writeall(output)
    writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
--df.global.pause_state = false
  script.sleep(50,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
    writeall('After UnEquipping the hand axe')
if unitTable.Spells.Active.TEST_SPELL_1 then
 EICheck[#EICheck+1] = 'Enhanced System - Item 2 unequip spell change not correctly applied'
end
---- Print PASS/FAIL
if #EICheck == 0 then
 printplus('PASSED: Enhanced System - Items', COLOR_GREEN)
else
 printplus('FAILED: Enhanced System - Items', COLOR_RED)
 writeall(EICheck)
end
-- FINISH Enhanced System - Items
    writeall('Enhanced System - Items check finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
-- START Enhanced System - Materials
    writeall('')
    writeall('Enhanced System - Materials Starting')
EMCheck = {}
---- Print PASS/FAIL
if #EMCheck == 0 then
 printplus('PASSED: Enhanced System - Materials')
else
 printplus('FAILED: Enhanced System - Materials')
 writeall(EICheck)
end
-- FINISH Enhanced System - Materials
    writeall('Enhanced System - Materials Finished')
]]
 printplus('NOCHECK: Enhanced System - Materials',COLOR_YELLOW)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
-- START Enhanced System - Reactions
    writeall('')
    writeall('Enhanced System - Reactions Starting')
ERCheck = {}
---- Print PASS/FAIL
if #ERCheck == 0 then
 printplus('PASSED: Enhanced System - Reactions')
else
 printplus('FAILED: Enhanced System - Reactions')
 writeall(EICheck)
end
-- FINISH Enhanced System - Reactions
    writeall('Enhanced System - Reactions Finished')
]]
 printplus('NOCHECK: Enhanced System - Reactions',COLOR_YELLOW)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Enhanced System Checks Finished',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENT SYSTEM CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('base/roses-init -eventSystem -verbose -test')
output = dfhack.run_command_silent('base/roses-init -eventSystem -verbose -test')
writeall(output)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Event System Checks Starting',COLOR_CYAN)
eventCheck = {}
    writeall('Forcing Test Event 1 to trigger, both effects should fail')
output = dfhack.run_command_silent('events/trigger -event TEST_EVENT_1 -force -verbose')
writeall(output)
if not roses.CounterTable.TEST_EVENT_1_EFFECT_1 then
 eventCheck[#eventCheck + 1] = 'Test Event 1 Effect 1 not triggered'
end
if not roses.CounterTable.TEST_EVENT_1_EFFECT_2 then
 eventCheck[#eventCheck + 1] = 'Test Event 1 Effect 2 not triggered'
end
    writeall('Test Event 2 should occur within 1 in-game day, if successful a random location and random unit id will be printed')
    writeall('Pausing run_test.lua for 3200 in-game ticks')
--df.global.pause_state = false
  script.sleep(3200,'ticks')
--df.global.pause_state = true
    writeall('Resuming run_test.lua')
if roses.CounterTable.TEST_EVENT_2_EFFECT_1 then
 eventCheck[#eventCheck + 1] = 'Test Event 2 Effect 1 incorrectly triggered'
end
if roses.CounterTable.TEST_EVENT_2_EFFECT_2 then
 eventCheck[#eventCheck + 1] = 'Test Event 2 Effect 2 incorrectly triggered'
end
---- Print PASS/FAIL
if #eventCheck == 0 then
 printplus('PASSED: Event System - Base',COLOR_GREEN)
else
 printplus('FAILED: Event System - Base',COLOR_RED)
 writeall(eventCheck)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Event System Checks Finished',COLOR_CYAN)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('System Checks Finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXTERNAL SCRIPT CHECKS ----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Starting External Scripts Checks')
if #externalScripts == 0 then
 printplus('No external scripts declared to check')
 printplus('To add an external script simply post')
else
 for _,exScript in pairs(externalScripts) do
  printplus('Testing: '..exScript..' -testRun')
  output = dfhack.run_command_silent(exScript..' -testRun')
  writeall(output)
 end
end
io.close()
end

script.start(script_checks)
