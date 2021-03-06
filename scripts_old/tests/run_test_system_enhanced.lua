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
file = io.open('rto_enhanced.txt','w')
io.output(file)

-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Running Base commands:')
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/persist-delay')
output = dfhack.run_command_silent('base/persist-delay -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/liquids-update')
output = dfhack.run_command_silent('base/liquids-update -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/flows-update')
output = dfhack.run_command_silent('base/flows-update -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-death')
output = dfhack.run_command_silent('base/on-death -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-time')
output = dfhack.run_command_silent('base/on-time -verbose')
writeall(output)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENHANCED SYSTEM CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function system_checks()
 local unitFunctions     = dfhack.script_environment('functions/unit')
 local enhancedFunctions = dfhack.script_environment('functions/enhanced')
 local tableFunctions    = dfhack.script_environment('functions/tables')

 -- Get Units for checks
 local civ = {}
 local non = {}
 for _,unit in pairs(df.global.world.units.active) do
  if dfhack.units.isCitizen(unit) then
   civ[#civ+1] = unit
  else
   non[#non+1] = unit
  end
 end
 
  printplus('Enhanced System Checks Starting',COLOR_CYAN)
  printplus('')
  printplus('base/roses-init -enhancedSystem -verbose -testRun')
  output = dfhack.run_command_silent('base/roses-init -enhancedSystem -verbose -testRun')
  writeall(output)

  dfhack.run_command('trigger/action -clear')
  dfhack.run_command('trigger/building -clear')
  dfhack.run_command('trigger/projectile -clear')
  dfhack.run_command('trigger/reaction -clear')
  writeall('Setting up triggers')
  output = dfhack.run_command_silent('base/triggers -verbose')
  writeall(output)
  
  enhCheck = {}
  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Buildings ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('')
  writeall('Enhanced System - Buildings Starting')
  EBCheck = {}

  ---- Print PASS/FAIL
  --if #EBCheck == 0 then
  -- printplus('PASSED: Enhanced System - Buildings')
  --else
  -- printplus('FAILED: Enhanced System - Buildings')
  -- writeall(EBCheck)
  --end

  ------ FINISH Enhanced System - Buildings
  --writeall('Enhanced System - Buildings Finished')
  printplus('NOCHECK: Enhanced System - Buildings',COLOR_YELLOW)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Creatures ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('')
  writeall('Enhanced System - Creatures Starting')
  writeall('Enhancing all dwarf creatures')
  writeall('Agility should be increased to between 5000 and 8000 and PLANT skill to between 5 and 15')

  printplus('')
  --printplus('base/roses-init -enhancedSystem [ Creatures ] -verbose -testRun')
  --output = dfhack.run_command_silent('base/roses-init -enhancedSystem [ Creatures ] -verbose -testRun')
  --writeall(output)

  ECCheck = {}
  for _,unit in pairs(df.global.world.units.active) do
   if dfhack.units.isDwarf(unit) then
    enhancedFunctions.enhanceCreature(unit)
   end
  end
  unit = civ[5]
  unitTable = unitFunctions.getUnitTable(unit)
  if unitTable.Attributes.AGILITY.Total < 5000 or unitTable.Skills.PLANT.Total < 5 then
   ECCheck[#ECCheck+1] = 'Enhanced System - Creature 1 not correctly applied. Agility = '..tostring(unitTable.Attributes.AGILITY)..'. Plant = '..tostring(unitTable.Skills.PLANT)
  end

  ---- Print PASS/FAIL
  if #ECCheck == 0 then
   printplus('PASSED: Enhanced System - Creatures',COLOR_GREEN)
  else
   printplus('FAILED: Enhanced System - Creatures',COLOR_RED)
   writeall(ECCheck)
  end

  ---- FINISH Enhanced System - Creatures
  writeall('Enhanced System - Creatures Finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Items -------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('')
  writeall('Enhanced System - Items Starting')
  writeall('When the pick is equipped the units Axe skill should increase to legendary')
  writeall('When the hand axe is equipped the unit should learn the Test Spell 1 spell')
  writeall('Both effects should revert when the item is unequipped')

  printplus('')
  --printplus('base/roses-init -enhancedSystem [ Items ] -verbose -testRun')
  --output = dfhack.run_command_silent('base/roses-init -enhancedSystem [ Items ] -verbose -testRun')
  --writeall(output)

  EICheck = {}
  ----
  writeall('')
  writeall('Testing Enhanced Item 1 - ITEM_WEAPON_PICK')
  output = dfhack.run_command_silent('item/create -creator '..tostring(unit.id)..' -item WEAPON:ITEM_WEAPON_PICK -material INORGANIC:STEEL')
  writeall(output)
  writeall('Before Equipping the pick')

  ----
  output = dfhack.run_command_silent('item/equip -unit '..tostring(unit.id)..' -item MOST_RECENT -bodyPart GRASP -partType Flag -mode Weapon')
  writeall(output)
  writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
  script.sleep(50,'ticks')
  writeall('Resuming run_test.lua')
  unitTable = unitFunctions.getUnitTable(unit)
  if unitTable.Skills.AXE.Item ~= 15 then
   EICheck[#EICheck+1] = 'Enhanced System - Item 1 equip skill change not correctly applied '..unitTable.Skills.AXE.Item
  end

  ----
  output = dfhack.run_command_silent('item/unequip -unit '..tostring(unit.id)..' -itemType WEAPON')
  writeall(output)
  writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
  script.sleep(50,'ticks')
  writeall('Resuming run_test.lua')
  unitTable = unitFunctions.getUnitTable(unit)
  if unitTable.Skills.AXE.Item ~= 0 then
   EICheck[#EICheck+1] = 'Enhanced System - Item 1 unequip skill change not correctly applied '..unitTable.Skills.AXE.Item
  end

  ----
  writeall('')
  writeall('Testing Enhanced Item 2 - ITEM_WEAPON_AXE_BATTLE')
  output = dfhack.run_command_silent('item/create -creator '..tostring(unit.id)..' -item WEAPON:ITEM_WEAPON_AXE_BATTLE -material INORGANIC:STEEL')
  writeall(output)

  ----
  output = dfhack.run_command_silent('item/equip -unit '..tostring(unit.id)..' -item MOST_RECENT -bodyPart GRASP -partType Flag -mode Weapon')
  writeall(output)
  writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
  script.sleep(10,'ticks')
  writeall('Resuming run_test.lua')
  unitTable = unitFunctions.getUnitTable(unit)
  check = false
  for _,spell in pairs(unitTable.Spells.Active) do
   if spell == 'TEST_SPELL_1' then
    check = true
    break
   end
  end
  if not check then
   EICheck[#EICheck+1] = 'Enhanced System - Item 2 equip spell change not correctly applied'
  end

  ----
  output = dfhack.run_command_silent('item/unequip -unit '..tostring(unit.id)..' -itemType WEAPON')
  writeall(output)
  writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
  script.sleep(10,'ticks')
  writeall('Resuming run_test.lua')
  unitTable = unitFunctions.getUnitTable(unit)
  check = false
  for _,spell in pairs(unitTable.Spells.Active) do
   if spell == 'TEST_SPELL_1' then
    check = true
    break
   end
  end
  if check then
   EICheck[#EICheck+1] = 'Enhanced System - Item 2 unequip spell change not correctly applied'
  end

  ---- Print PASS/FAIL
  if #EICheck == 0 then
   printplus('PASSED: Enhanced System - Items', COLOR_GREEN)
  else
   printplus('FAILED: Enhanced System - Items', COLOR_RED)
   writeall(EICheck)
  end

  ---- FINISH Enhanced System - Items
  writeall('Enhanced System - Items check finished')
  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Materials ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('')
  writeall('Enhanced System - Materials Starting')

  printplus('')
  --printplus('base/roses-init -enhancedSystem [ Materials ] -verbose -testRun')
  --output = dfhack.run_command_silent('base/roses-init -enhancedSystem [ Materials ] -verbose -testRun')
  --writeall(output)

  EMCheck = {}

  ---- Print PASS/FAIL
  --if #EMCheck == 0 then
  -- printplus('PASSED: Enhanced System - Materials')
  --else
  -- printplus('FAILED: Enhanced System - Materials')
  -- writeall(EMCheck)
  --end

  ------ FINISH Enhanced System - Materials
  --writeall('Enhanced System - Materials Finished')
  printplus('NOCHECK: Enhanced System - Materials',COLOR_YELLOW)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Reactions ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('')
  writeall('Enhanced System - Reactions Starting')

  printplus('')
  --printplus('base/roses-init -enhancedSystem [ Reactions ] -verbose -testRun')
  --output = dfhack.run_command_silent('base/roses-init -enhancedSystem [ Reactions ] -verbose -testRun')
  --writeall(output)

  ERCheck = {}

  ------ Print PASS/FAIL
  --if #ERCheck == 0 then
  -- printplus('PASSED: Enhanced System - Reactions')
  --else
  -- printplus('FAILED: Enhanced System - Reactions')
  -- writeall(EICheck)
  --end

  ------ FINISH Enhanced System - Reactions
  --writeall('Enhanced System - Reactions Finished')
  printplus('NOCHECK: Enhanced System - Reactions',COLOR_YELLOW)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Enhanced System Checks Finished',COLOR_CYAN)

 io.close()
end

script.start(system_checks)
