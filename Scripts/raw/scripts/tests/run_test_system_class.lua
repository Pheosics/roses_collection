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
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/persist-delay')
output = dfhack.run_command_silent('base/persist-delay -verbose')
writeall(output)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/liquids-update')
output = dfhack.run_command_silent('base/liquids-update -verbose')
writeall(output)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/flows-update')
output = dfhack.run_command_silent('base/flows-update -verbose')
writeall(output)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-death')
output = dfhack.run_command_silent('base/on-death -verbose')
writeall(output)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-time')
output = dfhack.run_command_silent('base/on-time -verbose')
writeall(output)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLASS SYSTEM CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function system_checks()
 local tableFunctions = dfhack.script_environment('functions/tables')
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

  script.sleep(1,'ticks')
  scriptCheck = {}

  printplus('')
  printplus('Class System checks starting',COLOR_CYAN)

  local persistTable = require 'persist-table'
  local roses = persistTable.GlobalTable.roses
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Base System Checks ------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  printplus('')
  printplus('base/roses-init -classSystem [ Feats Spells ] -verbose -testRun')
  output = dfhack.run_command_silent('base/roses-init -classSystem [ Feats Spells ] -verbose -testRun')
  writeall(output)

  -- START Class System Checks
  printplus('')
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Feat SubSystem Checks ---------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Spell SubSystem Checks --------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  spellCheck = {}
  ---- Print PASS/FAIL
  if #spellCheck == 0 then
   printplus('NOCHECK: Class System - Spells',COLOR_YELLOW)
  else
   printplus('NOCHECK: Class System - Spells',COLOR_YELLOW)
   writeall(spellCheck)
  end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Class System Checks Finished',COLOR_CYAN)

 io.close()
end

script.start(system_checks)
