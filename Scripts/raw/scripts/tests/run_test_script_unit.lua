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
file = io.open('rto_unit.txt','w')
io.output(file)


-- Initialize base/roses-table
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UNIT SCRIPT CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function script_checks()
 local mapFunctions = dfhack.script_environment('functions/map')
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

  script.sleep(1,'ticks')
  scriptCheck = {}

  printplus('')
  printplus('Unit script checks starting', COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/action-change ------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  unitCheck = {}
  unit = civ[1]
  writeall('unit/action-change checks starting')

  ---- Check that the script succeeds and adds an action of every type with a 500 tick cooldown
  writeall('unit/action-change -unit '..tostring(unit.id)..' -timer 500 -action All (Should succeed and add an action for every type with a 500 tick cooldown)')
  output = dfhack.run_command_silent('unit/action-change -unit '..tostring(unit.id)..' -timer 500 -action All')
  writeall(output)
  check = true
  timerTypes = {'move','holdterrain','climb','job','talk','unsteady','dodge','recover','standup','liedown','job2','pushobject','suckblood'}
  for _,action in pairs(unit.actions) do
   if action.type >= 0 then
    actionType = string.lower(df.unit_action_type[action.type])
    if timerTypes[actionType] then
     if action.data[actionType].timer < 500 then
      check = false
     end
    elseif actionType == 'attack' then
     if action.data[actionType].timer1 < 100 then
      check = false
     end
    end
   end
  end
  if not check then
   unitCheck[#unitCheck+1] = 'Failed to add a 500 tick action for each action to unit'
  end
  ---- Check that the script succeeds and removes all actions from unit
  writeall('unit/action-change -unit '..tostring(unit.id)..' action ALL -timer clearAll (Should succeed and remove all actions from unit)')
  output = dfhack.run_command_silent('unit/action-change -unit '..tostring(unit.id)..' -action ALL -timer clearAll')
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
  if unit.curse.own_interaction_delay[0] >= 100 then
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
  
  ---- FINISH unit/action-change
  scriptCheck['unit_action_change'] = unitCheck
  writeall('unit/action-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/attack -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  writeall('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' -attack PUNCH -target HEAD -number 10 -velocity 100 -delay 10 (Should succeed and add 10 punch attacks targeting defender head with velocity 100 and calculated hit chance)')
  output = dfhack.run_command_silent('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' -attack PUNCH -target HEAD -number 10 -velocity 100 -delay 10')
  writeall(output)
  n = 0
  bpn = unitFunctions.getBodyCategory(defender,'HEAD')[1]
  for _,action in pairs(attacker.actions) do
   if action.type == 1 then
    if action.data.attack.target_unit_id == defender.id then
     if action.data.attack.attack_velocity == 100 and action.data.attack.target_body_part_id == bpn then
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

  ---- FINISH unit/attack
  scriptCheck['unit_attack'] = unitCheck
  writeall('unit/attack checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/attribute-change ---------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  writeall('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ TOUGHNESS ENDURANCE ] -amount [ 5000 5000 ] -mode set -dur 50 (Should succeed and set units toughness and endurance to 5000 for 50 ticks and create a persistent unit table)')
  output = dfhack.run_command_silent('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ TOUGHNESS ENDURANCE ] -amount [ 5000 5000 ] -mode set -dur 50')
  writeall(output)
  if unit.body.physical_attrs.ENDURANCE.value ~= 5000 or unit.body.physical_attrs.TOUGHNESS.value ~= 5000 then
   unitCheck[#unitCheck+1] = 'Failed to set endurance and toughness to 5000'
  end
  writeall('Pausing run_test.lua for 75 in-game ticks')
  script.sleep(75,'ticks')
  writeall('Resuming run_test.lua')
  if unit.body.physical_attrs.ENDURANCE.value == 5000 or unit.body.physical_attrs.TOUGHNESS.value == 5000 then
   unitCheck[#unitCheck+1] = 'Failed to revert endurance and toughness from 5000'
  end
  roses = dfhack.script_environment('base/roses-table').roses
  unitTable = roses.UnitTable[unit.id]
  if not unitTable.Attributes.ENDURANCE then
   unitCheck[#unitCheck+1] = 'Failed to create tracking table'
  end

  ---- Print PASS/FAIL
  if #unitCheck == 0 then
   printplus('PASSED: unit/attribute-change',COLOR_GREEN)
  else
   printplus('FAILED: unit/attribute-change',COLOR_RED)
   writeall(unitCheck)
  end

  ---- FINISH unit/attribute-change
  scriptCheck['unit_attribute_change'] = unitCheck
  writeall('unit/attribute-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/body-change --------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  unitCheck = {}
  unit = non[2]
  writeall('')
  writeall('unit/body-change checks starting')

  ---- Check that the script succeeds and set the eyes of unit on fire for 50 ticks
  writeall('unit/body-change -unit '..tostring(unit.id)..' -partType Flag -bodyPart SIGHT -temperature Fire -dur 50 (Should succeed and set the eyes on fire for 50 ticks)')
  output = dfhack.run_command_silent('unit/body-change -unit '..tostring(unit.id)..' -partType Flag -bodyPart SIGHT -temperature Fire -dur 50')
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

  ---- Check that the script succeeds and sets the size of unit to half of the current
  scur = unit.body.size_info.size_cur
  acur = unit.body.size_info.area_cur
  lcur = unit.body.size_info.length_cur
  writeall('unit/body-change -unit '..tostring(unit.id)..' -size All -amount 50 -mode Percent (Should succeed and set all sizes, size, length, and area, of the unit to 50 percent of the current)')
  output = dfhack.run_command_silent('unit/body-change -unit '..tostring(unit.id)..' -size All -amount 50 -mode percent')
  writeall(output)
  if scur/unit.body.size_info.size_cur < 1.9 or scur/unit.body.size_info.size_cur > 2.1 then
   unitCheck[#unitCheck+1] = 'Failed to set current size to 50% of previous size. Size ratio = '..tostring(scur/unit.body.size_info.size_cur)
  end
  if acur/unit.body.size_info.area_cur < 1.9 or acur/unit.body.size_info.area_cur > 2.1 then
   unitCheck[#unitCheck+1] = 'Failed to set current area to 50% of previous area. Area ratio = '..tostring(acur/unit.body.size_info.area_cur)
  end
  if lcur/unit.body.size_info.length_cur < 1.9 or lcur/unit.body.size_info.length_cur > 2.1 then
   unitCheck[#unitCheck+1] = 'Failed to set current length to 50% of previous length. Length ratio = '..tostring(lcur/unit.body.size_info.length_cur)
  end
  
  ---- Check that the script succeeds and sets the temperature of the upper body to 9000
  writeall('unit/body-change -unit '..tostring(unit.id)..' -partType Token -bodyPart UB -temperature -mode Set -amount 9000 (Should succeed and set the upper body temperature to 9000)')
  output = dfhack.run_command_silent('unit/body-change -unit '..tostring(unit.id)..' -partType Token -bodyPart UB -temperature -mode Set -amount 9000')
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

  ---- FINISH unit/body-change
  scriptCheck['unit_body_change'] = unitCheck
  writeall('unit/body-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/butcher --------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  unitCheck = {}
  unit = non[3]
  writeall('')
  writeall('unit/butcher checks starting')

  ---- Check that the script fails because unit is still alive
  writeall('unit/butcher -unit '..tostring(unit.id)..' (Should fail and print "Unit is still alive and has not been ordered -kill")')
  output = dfhack.run_command_silent('unit/butcher -unit '..tostring(unit.id))
  writeall(output)
  if dfhack.units.isKilled(unit) then
   unitCheck[#unitCheck+1] = 'Incorrectly killed the unit'
  end

  ---- Check that the script succeeds in killing and then butchering the unit
  writeall('unit/butcher -unit '..tostring(unit.id)..' -kill (Should succeed and kill unit then butcher it)')
  output = dfhack.run_command_silent('unit/butcher -unit '..tostring(unit.id)..' -kill')
  writeall(output)
  writeall('Pausing run_test.lua for 5 in-game ticks')
  script.sleep(5,'ticks')
  writeall('Resuming run_test.lua')
  if not dfhack.units.isKilled(unit) then
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

  ---- FINISH unit/butcher
  scriptCheck['unit_butcher'] = unitCheck
  writeall('unit/butcher checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- START unit/convert --------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  unitCheck = {}
--  unit = non[4]
--  side = civ[1]
--  writeall('')
--  writeall('unit/convert checks starting')
--
--  ---- Check that the script succeeds and changes the unit to a neutral
--  writeall('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Neutral (Should succeed and change the unit to a neutral)')
--  output = dfhack.run_command_silent('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Neutral')
--  writeall(output)
--  if unit.civ_id ~= -1 and unit.population_id ~= -1 and unit.training_level ~= 9 then
--   unitCheck[#unitCheck+1] = 'Failed to set unit to Neutral'
--  end
--
--  ---- Check that the script succeeds and changes the unit to a civilian
--  writeall('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Civilian (Should succeed and change the unit to a civilian)')
--  output = dfhack.run_command_silent('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Civilian')
--  writeall(output)
--  if unit.civ_id ~= side.civ_id and unit.population_id ~= side.population_id then
--   unitCheck[#unitCheck+1] = 'Failed to set unit to Civilian'
--  end
--
--  ---- Check that the script succeeds and changes the unit to a pet
--  writeall('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Pet (Should succeed and change the unit to a pet of side)')
--  output = dfhack.run_command_silent('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Pet')
--  writeall(output)
--  if unit.population_id ~= -1 and not unit.flags1.tame and unit.training_level ~= 7 and unit.relationship_ids.Pet ~= side.id then
--   unitCheck[#unitCheck+1] = 'Failed to set unit to Pet'
--  end
--
--  ---- Print PASS/FAIL
--  if #unitCheck == 0 then
--   printplus('PASSED: unit/convert',COLOR_GREEN)
--  else
--   printplus('FAILED: unit/convert',COLOR_RED)
--   writeall(unitCheck)
--  end
--  
--  ---- FINISH unit/convert
--  scriptCheck['unit_convert'] = unitCheck
--  writeall('unit/convert checks finished')
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/counter-change -----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH unit/counter-change
  scriptCheck['unit_counter_change'] = unitCheck
  writeall('unit/counter-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/create -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  unitCheck = {}
--  loc = {pos2xyz(civ[2].pos)}
--  location = tostring(loc[1])..' '..tostring(loc[2])..' '..tostring(loc[3])
--  side = civ[2]
--  writeall('')
--  writeall('unit/create checks starting')
--
--  ---- Check that the script succeeds and creates a neutral male dwarf at given location
--  writeall('unit/create -creature DWARF:MALE -loc [ '..location..' ] (Should succeed and create a neutral male dwarf at given location)')
--  output = dfhack.run_command_silent('unit/create -creature DWARF:MALE -loc [ '..location..' ]')
--  writeall(output)
--
--  ---- Check that the script succeeds and creates a civilian male dwarf at the given location
--  writeall('unit/create -creature DWARF:MALE -reference '..tostring(side.id)..' -side Civilian -loc [ '..location..' ] (Should succeed and create a civilian male dwarf at the reference units location)')
--  output = dfhack.run_command_silent('unit/create -creature DWARF:MALE -reference '..tostring(side.id)..' -side Civilian -loc [ '..location..' ]')
--  writeall(output)
--
--  ---- Check that the script succeeds and creates a domestic dog (male or female) named Clifford
--  writeall('unit/create -creature DOG:RANDOM -reference '..tostring(side.id)..' -side Domestic -name Clifford -loc [ '..location..' ] (Should succeed and create a domestic dog, male or female, named clifford at the reference units location)')
--  output = dfhack.run_command_silent('unit/create -creature DOG:RANDOM -reference '..tostring(side.id)..' -side Domestic -name Clifford -loc [ '..location..' ]')
--  writeall(output)
--
--  ---- Print PASS/FAIL
--  if #unitCheck == 0 then
--   printplus('PASSED: unit/create',COLOR_GREEN)
--  else
--   printplus('FAILED: unit/create',COLOR_RED)
--   writeall(unitCheck)
--  end
--
--  ---- FINISH unit/create
--  scriptCheck['unit_create'] = unitCheck
--  writeall('unit/create checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/destory ------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  unitCheck = {}
--  unit1 = df.unit.find(df.global.unit_next_id - 1)
--  unit2 = df.unit.find(df.global.unit_next_id - 2)
--  unit3 = df.unit.find(df.global.unit_next_id - 3)
--  writeall('')
--  writeall('unit/destroy checks starting')
--
--  ---- Check that the script succeeds and removes Clifford the dog
--  writeall('unit/destroy -unit '..tostring(unit3.id)..' -type Created (Should succeed and remove Clifford the dog and all references formed in the creation)')
--  output = dfhack.run_command_silent('unit/destroy -unit '..tostring(unit3.id)..' -type Created')
--  writeall(output)
--
--  ---- Check that the script succeeds and kills the civilian dwarf as a normal kill
--  writeall('unit/destory -unit '..tostring(unit2.id)..' -type Kill (Should succeed and kill the civilian dwarf as a normal kill)')
--  output = dfhack.run_command_silent('unit/destory -unit '..tostring(unit2.id)..' -type Kill')
--  writeall(output)
--
--  ---- Check that the script succeeds and kills the neutral dwarf as a resurrected kill
--  writeall('unit/destroy -unit '..tostring(unit1.id)..' -type Resurrected (Should succeed and kill the netural dwarf as if it were a resurrected unit)')
--  output = dfhack.run_command_silent('unit/destroy -unit '..tostring(unit1.id)..' -type Resurrected')
--  writeall(output)
--
--  ---- Print PASS/FAIL
--  if #unitCheck == 0 then
--   printplus('PASSED: unit/destroy',COLOR_GREEN)
--  else
--   printplus('FAILED: unit/destroy',COLOR_RED)
--   writeall(unitCheck)
--  end
--
--  ---- FINISH unit/destroy
--  scriptCheck['unit_destroy'] = unitCheck
--  writeall('unit/destroy checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/emotion-change -----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  unitCheck = {}
--  unit = civ[1]
--  writeall('')
--  writeall('unit/emotion-change checks starting')
--
--  ---- Check that the script succeeds and adds emotion XXXX with thought WWWW and severity and strength 0 to unit
--  writeall('unit/emotion-change -unit '..tostring(unit.id)..' -emotion ACCEPTANCE (Should succeed and add emotion XXXX with thought WWWW and severity and strength 0 to unit)')
--  output = dfhack.run_command_silent('unit/emotion-change -unit '..tostring(unit.id)..' -emotion ACCEPTANCE')
--  writeall(output)
--  emotion = unit.status.current_soul.personality.emotions[#unit.status.current_soul.personality.emotions-1]
--  if df.emotion_type[emotion.type] ~= 'ACCEPTANCE' then
--   unitCheck[#unitCheck+1] = 'Failed to add an ACCEPTANCE emotion'
--  end
--
--  ---- Check that the script succeeds and adds emotion XXXX with thought ZZZZ and severity and strength 1000 to unit
--  writeall('unit/emotion-change -unit '..tostring(unit.id)..' -emotion AGONY -thought Conflict -severity 100 -strength 100 -add (Should succeed and add emotion XXXX with thought ZZZZ and severity and strength 100 to unit)')
--  output = dfhack.run_command_silent('unit/emotion-change -unit '..tostring(unit.id)..' -emotion AGONY -thought Conflict -severity 100 -strength 100 -add')
--  writeall(output)
--  emotion = unit.status.current_soul.personality.emotions[#unit.status.current_soul.personality.emotions-1]
--  if df.emotion_type[emotion.type] ~= 'AGONY' and df.unit_thought_type[emotion.thought] ~= 'Conflict' then
--   unitCheck[#unitCheck+1] = 'Failed to add an AGONY emotion with Conflict thought'
--  end
--
--  ---- Print PASS/FAIL
--  if #unitCheck == 0 then
--   printplus('PASSED: unit/emotion-change',COLOR_GREEN)
--  else
--   printplus('FAILED: unit/emotion-change',COLOR_RED)
--   writeall(unitCheck)
--  end
--
--  ---- FINISH unit/emotion-change
--  scriptCheck['unit_emotion_change'] = unitCheck
--  writeall('unit/emotion-change checks finished')
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/flag-change --------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH unit/flag-change
  scriptCheck['unit_flag_change'] = unitCheck
  writeall('unit/flag-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/move ---------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  unitCheck = {}
  unit = civ[1]
  writeall('')
  writeall('unit/move checks starting')

  ---- Check that the script succeeds and moves the unit to a random position within a 5x5 square
  writeall('unit/move -unit '..tostring(unit.id)..' -random [ 5 5 0 ] (Should succeed and move the unit to a random position within a 5x5 square)')
  output = dfhack.run_command_silent('unit/move -unit '..tostring(unit.id)..' -random [ 5 5 0 ]')
  writeall(output)
  positions, n = mapFunctions.getFillPositions(unit.pos,{5,5,0})
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
  writeall('unit/move -unit '..tostring(unit.id)..' -building Wagon (Should succeed and move the unit to the wagon)')
  output = dfhack.run_command_silent('unit/move -unit '..tostring(unit.id)..' -building Wagon')
  writeall(output)
  bldgloc = df.global.world.buildings.all[0]
  if unit.pos.x ~= bldgloc.centerx or unit.pos.y ~= bldgloc.centery or unit.pos.z ~= bldgloc.z then
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

  ---- FINISH unit/move
  scriptCheck['unit_move'] = unitCheck
  writeall('unit/move checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/propel -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH unit/propel
  scriptCheck['unit_propel'] = unitCheck
  writeall('unit/propel checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/resistance-change --------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  unitCheck = {}
  unit = civ[1]
  writeall('')
  writeall('unit/resistance-change checks starting')

  ---- Check that the script succeeds and increases units fire resistance by 50 and creates tracking table
  writeall('unit/resistance-change -unit '..tostring(unit.id)..' -resistance FIRE -amount 50 -mode fixed (Should succeed and increase units fire resistance by 50, will also create unit persist table since there is no vanilla resistances)')
  output = dfhack.run_command_silent('unit/resistance-change -unit '..tostring(unit.id)..' -resistance FIRE -amount 50 -mode fixed')
  writeall(output)
  base = unitFunctions.getUnitTable(unit)
  base = base['Resistances']['FIRE'].Base or 0
  if math.floor(tonumber(base)) ~= 50 then
   unitCheck[#unitCheck+1] = 'Failed to increase units FIRE resistance to 50'
  end
  roses = dfhack.script_environment('base/roses-table').roses
  unitTable = roses.UnitTable[unit.id]
  if not unitTable.Resistances.FIRE then
   unitCheck[#unitCheck+1] = 'Failed to create FIRE resistance persistant table'
  end

  ---- Print PASS/FAIL
  if #unitCheck == 0 then
   printplus('PASSED: unit/resistance-change',COLOR_GREEN)
  else
   printplus('FAILED: unit/resistance-change',COLOR_RED)
   writeall(unitCheck)
  end

  ---- FINISH unit/resistance-change
  scriptCheck['unit_resistance_change'] = unitCheck
  writeall('unit/resistance-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/skill-change -------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  writeall('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGING -amount 200 -mode Percent (Should succeed and double units dodging skill, will also create unit persist table)')
  output = dfhack.run_command_silent('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGING -amount 200 -mode Percent')
  writeall(output)
  if dfhack.units.getNominalSkill(unit,df.job_skill['DODGING']) ~= skill*2 then
   unitCheck[#unitCheck+1] = 'Failed to increase units dodging skill by 200 percent'
  end
  roses = dfhack.script_environment('base/roses-table').roses
  unitTable = roses.UnitTable[unit.id]
  if not unitTable.Skills.DODGING then
   unitCheck[#unitCheck+1] = 'Failed to create DODGING skill persistant table'
  end

  ---- Print PASS/FAIL
  if #unitCheck == 0 then
   printplus('PASSED: unit/skill-change',COLOR_GREEN)
  else
   printplus('FAILED: unit/skill-change',COLOR_RED)
   writeall(unitCheck)
  end

  ---- FINISH unit/skill-change
  scriptCheck['unit_skill_change'] = unitCheck
  writeall('unit/skill-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/stat-change --------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  unitCheck = {}
  unit = civ[1]
  writeall('')
  writeall('unit/stat-change checks starting')

  ---- Check that the script succeeds and increases unit magical hit chance stat by 50 and creates tracking table
  writeall('unit/stat-change -unit '..tostring(unit.id)..' -stat CRITICAL_CHANCE -amount 50 -mode fixed (Should succeed and increase units magical hit chance by 50, will also create unit persist table since there is no vanilla stats)')
  output = dfhack.run_command_silent('unit/stat-change -unit '..tostring(unit.id)..' -stat CRITICAL_CHANCE -amount 50 -mode fixed')
  writeall(output)
  base = unitFunctions.getUnitTable(unit)
  base = base['Stats']['CRITICAL_CHANCE'].Base or 0
  if math.floor(tonumber(base)) ~= 50 then
   unitCheck[#unitCheck+1] = 'Failed to increase units stat CRITICAL_CHANCE by 50'
  end
  roses = dfhack.script_environment('base/roses-table').roses
  unitTable = roses.UnitTable[unit.id]
  if not unitTable.Stats.CRITICAL_CHANCE then
   unitCheck[#unitCheck+1] = 'Failed to create CRITICAL_CHANCE stat persistant table'
  end

  ---- Print PASS/FAIL
  if #unitCheck == 0 then
   printplus('PASSED: unit/stat-change',COLOR_GREEN)
  else
   printplus('FAILED: unit/stat-change',COLOR_RED)
   writeall(unitCheck)
  end

  ---- FINISH unit/stat-change
  scriptCheck['unit_stat_change'] = unitCheck
  writeall('unit/stat-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/syndrome-change ----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  script.sleep(75,'ticks')
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

  ---- FINISH unit/syndrome-change
  scriptCheck['unit_syndrome_change'] = unitCheck
  writeall('unit/syndrome-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/trait-change -------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  unitCheck = {}
  unit = civ[1]
  writeall('')
  writeall('unit/trait-change checks starting')

  ---- Check that the script succeeds and lowers the units greed trait by 5
  s = unit.status.current_soul.personality.traits.GREED
  writeall('unit/trait-change -unit '..tostring(unit.id).." -trait GREED -amount 5 -mode Fixed (Should succeed and lower units greed trait by 5)'")
  output = dfhack.run_command_silent('unit/trait-change -unit '..tostring(unit.id)..' -trait GREED -amount 5 -mode Fixed')
  writeall(output)
  if unit.status.current_soul.personality.traits.GREED ~= s+5 and s+5 < 100 then
   unitCheck[#unitCheck+1] = 'Failed to increase GREED trait by 5. Previous GREED = '..tostring(s)..'. New GREED = '..tostring(unit.status.current_soul.personality.traits.GREED)
  end

  ---- Check that the script succeeds and quarters the units bravery trait, also creates a tracking table
  s = unit.status.current_soul.personality.traits.BRAVERY
  writeall('unit/trait-change -unit '..tostring(unit.id)..' -trait BRAVERY -amount 25 -mode Percent (Should succeed and quarter units bravery trait, will also create unit persist table)')
  output = dfhack.run_command_silent('unit/trait-change -unit '..tostring(unit.id)..' -trait BRAVERY -amount 25 -mode Percent')
  writeall(output)
  if s/unit.status.current_soul.personality.traits.BRAVERY > 5.0 or s/unit.status.current_soul.personality.traits.BRAVERY < 3.0 then
   unitCheck[#unitCheck+1] = 'Failed to quarter BRAVERY trait. Previous BRAVERY = '..tostring(s)..'. New BRAVERY = '..tostring(unit.status.current_soul.personality.traits.BRAVERY)
  end
  roses = dfhack.script_environment('base/roses-table').roses
  unitTable = roses.UnitTable[unit.id]
  if not unitTable.Traits.BRAVERY then
   unitCheck[#unitCheck+1] = 'Failed to create BRAVERY trait persistant table'
  end

  ---- Print PASS/FAIL
  if #unitCheck == 0 then
   printplus('PASSED: unit/trait-change',COLOR_GREEN)
  else
   printplus('FAILED: unit/trait-change',COLOR_RED)
   writeall(unitCheck)
  end

  ---- FINISH unit/trait-change
  scriptCheck['unit_trait_change'] = unitCheck
  writeall('unit/trait-change checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/transform ----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  writeall('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:FEMALE -dur 50 (Should succeed and change the unit to a female dwarf for 50 ticks and create a unit persist table)')
  output = dfhack.run_command_silent('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:FEMALE -dur 50')
  writeall(output)
  script.sleep(2,'ticks')
  if not unitFunctions.checkCreatureRace(unit,'DWARF:FEMALE') then
   unitCheck[#unitCheck+1] = 'Failed to transfrom unit into DWARF:FEMALE. Unit race/caste = '..tostring(unit.race)..'/'..tostring(unit.caste)
  end
  writeall('Pausing run_test.lua for 75 in-game ticks')
  script.sleep(75,'ticks')
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

  ---- FINISH unit/transform
  scriptCheck['unit_transform'] = unitCheck
  writeall('unit/transform checks finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START unit/wound-change -------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  unitCheck = {}
--  unit = non[1]
--  writeall('')
--  writeall('unit/wound-change checks starting')
--
--  ---- Check that the script succeeds and removes the most recent wound
--  writeall('unit/wound-change -unit '..tostring(unit.id)..' -remove 1 -recent (Should succeed and remove the most recent wounds)')
--  output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -remove 1 -recent')
--  writeall(output)
--
--  ---- Check that the script succeeds and regrows any lost limbs
--  writeall('unit/wound-change -unit '..tostring(unit.id)..' -remove All -regrow (Should succeed and remove all wounds and return any lost limbs)')
--  output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -remove All -regrow')
--  writeall(output)
--
--  ---- Kills the unit
--  writeall('Killing unit')
--  output = dfhack.run_command_silent('unit/counter-change -unit '..tostring(unit.id)..' -counter blood -amount 0 -mode set')
--  writeall(output)
--  script.sleep(1,'ticks')
--
--  ---- Checks that the script succeeds and brings the unit back to life
--  writeall('unit/wound-change -unit '..tostring(unit.id)..' -resurrect (Should succeed and bring unit back to life)')
--  output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -resurrect')
--  writeall(output)
--  ---- Kills and butchers the unit
--  writeall('Killing and Butcher unit')
--  output = dfhack.run_command_silent('unit/butcher -unit '..tostring(unit.id)..' -kill')
--  writeall(output)
--
--  ---- Check that the script succeeds and brings back all corpse parts as zombies
--  writeall('unit/wound-change -unit '..tostring(unit.id)..' -animate (Should succeed and bring all corpse parts back as zombies)')
--  output = dfhack.run_command_silent('unit/wound-change -unit '..tostring(unit.id)..' -animate')
--  writeall(output)
--
--  ---- Print PASS/FAIL
--  if #unitCheck == 0 then
--   printplus('PASSED: unit/wound-change',COLOR_GREEN)
--  else
--   printplus('FAILED: unit/wound-change',COLOR_RED)
--   writeall(unitCheck)
--  end
--
--  ---- FINISH unit/wound-change
--  scriptCheck['unit_wound_change'] = unitCheck
--  writeall('unit/wound-change checks finished')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Unit script checks finished',COLOR_CYAN)

 io.close()
end

script.start(script_checks)
