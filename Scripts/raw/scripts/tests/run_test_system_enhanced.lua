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
 local enhancedFunctions = dfhack.script_environment('functions/enhanced')
 local tableFunctions = dfhack.script_environment('functions/tables')

  printplus('Enhanced System Checks Starting',COLOR_CYAN)
  enhCheck = {}

  printplus('')
  printplus('base/roses-init -enhancedSystem [ Buildings Creatures Items Materials Reactions ] -verbose -test')
  output = dfhack.run_command_silent('base/roses-init -enhancedSystem [ Buildings Creatures Items Materials Reactions ] -verbose -test')
  writeall(output)
  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Buildings ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH Enhanced System - Buildings
  writeall('Enhanced System - Buildings Finished')
  printplus('NOCHECK: Enhanced System - Buildings',COLOR_YELLOW)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Creatures ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  for _,unit in pairs(df.global.world.units.active) do
   if dfhack.units.isDwarf(unit) then
    enhancedFunctions.enhanceCreature(unit)
   end
  end
  writeall('After:')
  writeall(unit.body.physical_attrs.AGILITY)
  _,base = unitFunctions.getUnit(unit,'Skills','PLANT')
  if unit.body.physical_attrs.AGILITY.value < 5000 or base < 5 then
   ECCheck[#ECCheck+1] = 'Enhanced System - Creature 1 not correctly applied. Agility = '..tostring(unit.body.physical_attrs.AGILITY.value)..'. Plant = '..tostring(base)
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
  script.sleep(50,'ticks')
  writeall('Resuming run_test.lua')
  writeall('After Equipping the pick')
  if unitTable.Skills.AXE.Item < '15' then
   EICheck[#EICheck+1] = 'Enhanced System - Item 1 equip skill change not correctly applied'
  end

  ----
  output = dfhack.run_command_silent('item/unequip -unit '..tostring(unit.id)..' -itemType WEAPON -verbose')
  writeall(output)
  writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
  script.sleep(50,'ticks')
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
  script.sleep(50,'ticks')
  writeall('Resuming run_test.lua')
  writeall('After Equipping the hand axe')
  if not unitTable.Spells.Active.TEST_SPELL_1 then
   EICheck[#EICheck+1] = 'Enhanced System - Item 2 equip spell change not correctly applied'
  end

  ----
  output = dfhack.run_command_silent('item/unequip -unit '..tostring(unit.id)..' -itemType WEAPON -verbose')
  writeall(output)
  writeall('Pausing run_test.lua for 50 in-game ticks (so the item-trigger script can correctly trigger)')
  script.sleep(50,'ticks')
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

  ---- FINISH Enhanced System - Items
  writeall('Enhanced System - Items check finished')
  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Materials ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH Enhanced System - Materials
  writeall('Enhanced System - Materials Finished')
  printplus('NOCHECK: Enhanced System - Materials',COLOR_YELLOW)
  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Enhanced System - Reactions ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH Enhanced System - Reactions
  writeall('Enhanced System - Reactions Finished')
  printplus('NOCHECK: Enhanced System - Reactions',COLOR_YELLOW)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Enhanced System Checks Finished',COLOR_CYAN)

 io.close()
end

script.start(system_checks)
