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
file = io.open('rto_civilization.txt','w')
io.output(file)

-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')

printplus('')
printplus('Running Base commands:')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
-- CIVILIZATION SYSTEM CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function system_checks()
 local tableFunctions = dfhack.script_environment('functions/entity')

 printplus('Civilization System Checks Starting',COLOR_CYAN)
 civCheck = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Base System Checks ------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  printplus('')
  printplus('base/roses-init -civilizationSystem [ Diplomacy ] -verbose -testRun')
  output = dfhack.run_command_silent('base/roses-init -civilizationSystem [ Diplomacy ] -verbose -testRun')
  writeall(output)
  
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('')
  writeall('Creating Entity Table for MOUNTAIN entity')
  civID = df.global.ui.civ_id
  dfhack.script_environment('functions/entity').makeEntityTable(civID,true)
  roses = dfhack.script_environment('base/roses-table').roses
  entityTable = roses.EntityTable[civID]
  script.sleep(5,'ticks')
  if not entityTable.Civilization then
   civCheck[#civCheck+1] = 'Test Civilization 1 was not correctly assigned to the entity'
  end
  if #df.global.world.entities.all[civID].resources.animals.mount_races ~= 0 then
   civCheck[#civCheck+1] = 'Test Civilization 1 level 0 mount creatures were not removed'
  end
  
  ----
  writeall('Force level increase, should add dragons to available mounts and change level method')
  output = dfhack.run_command_silent('civilizations/level-up -civ '..tostring(civID)..' -amount 1 -verbose')
  writeall(output)
  roses = dfhack.script_environment('base/roses-table').roses
  entityTable = roses.EntityTable[civID]
  if entityTable.Civilization.Level ~= 1 then
   civCheck[#civCheck+1] = 'Test Civilization 1 did not correctly level up from 0 to 1'
  end
  if #df.global.world.entities.all[civID].resources.animals.mount_races ~= 2 then
   civCheck[#civCheck+1] = 'Test Civilization 1 level 1 mount creatures were not added'
  end

  ----
  writeall('Next level increase should occur within 1 in-game day, will add humans as available mounts')
  writeall('Pausing run_test.lua for 3200 in-game ticks')
  script.sleep(6500,'ticks')
  writeall('Resuming run_test.lua')
  roses = dfhack.script_environment('base/roses-table').roses
  entityTable = roses.EntityTable[civID]
  if entityTable.Civilization.Level ~= 2 then
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
  tableFunctions.makeEntityTable(entity.id,true)
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
   if #resources ~= 0 then
    civCheck[#civCheck+1] = 'Test Civilization 2 level 0 '..table.concat(aCheck,' ')..' not correctly removed from'
   end
  end

  ----
  writeall('Force level increase, should add a single item to each resource category')
  output = dfhack.run_command_silent('civilizations/level-up -civ '..tostring(entity.id)..' -amount 1 -verbose')
  writeall(output)
  for xCheck,aCheck in pairs(nCheck) do
   resources = entity.resources
   for _,tables in pairs(aCheck) do
    resources = resources[tables]
   end
   if #resources < 1 then
    civCheck[#civCheck+1] = 'Test Civilization 2 level 1 '..table.concat(aCheck,' ')..' not correctly added to'
   end
  end

  ----
  writeall('Force level increase, should fail to level up for many different reasons')
  output = dfhack.run_command_silent('civilizations/level-up -civ '..tostring(entity.id)..' -amount 1 -verbose')
  writeall(output)
  roses = dfhack.script_environment('base/roses-table').roses
  entityTable = roses.EntityTable[entity.id]
  if entityTable.Civilization.Level == 2 then
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

 io.close()
end

script.start(system_checks)
