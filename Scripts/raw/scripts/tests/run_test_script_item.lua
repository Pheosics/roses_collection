script = require 'gui.script'
persistTable = require 'persist-table'

externalScripts = {}

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
-- ITEM SCRIPT CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function script_checks()
 local unitFunctions = dfhack.script_environment('functions/unit')

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

 local function mostRecentItem()
  item = df.item.find(df.global.item_next_id - 1)
  return item
 end
            
  script.sleep(1,'ticks')
  scriptCheck = {}

  printplus('')
  printplus('Item script checks starting',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START item/create -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- Checks that the script succeeds and creates a ruby short sword and then removes it 50 ticks later
  writeall('item/create -creator '..tostring(civ[1].id)..' -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:RUBY -dur 50 (Should succeed and create a ruby short sword and then remove it 50 ticks later)')
  output = dfhack.run_command_silent('item/create -creator '..tostring(civ[1].id)..' -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:RUBY -dur 20')
  writeall(output)
  item = mostRecentItem()
  id = item.id
  writeall('Pausing run_test.lua for 75 in-game ticks')
  script.sleep(75,'ticks')
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

  ---- FINISH item/create
  scriptCheck['item_create'] = itemCheck
  writeall('item/create checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START item/equip and item/unequip ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
---- START item/material-change ----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH item/material-change
  scriptCheck['item_material_change'] = itemCheck
  writeall('item/material-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START item/quality-change -----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  script.sleep(75,'ticks')
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

  ---- FINISH item/quality-change
  scriptCheck['item_quality_change'] = itemCheck
  writeall('item/quality-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START item/subtype-change -----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  script.sleep(75,'ticks')
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

  ---- FINISH item/subtype-change
  scriptCheck['item_subtype_change'] = itemCheck
  writeall('item/subtype-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START item/projectile ---------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  
  ---- FINISH item/projectile
  scriptCheck['item_projectile'] = itemCheck
  writeall('item/projectile checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Item script checks finished',COLOR_CYAN)

 io.close()
end

script.start(script_checks)
