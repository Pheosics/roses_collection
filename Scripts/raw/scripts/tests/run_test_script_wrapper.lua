script = require 'gui.script'
roses = dfhack.script_environment('base/roses-init').roses

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- WRAPPER SCRIPT CHECKS -----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function script_checks()

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

  printplus('')
  printplus('Wrapper script checks starting',COLOR_CYAN)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Unit Based Targeting ----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('Unit Based Targeting Starting')
  wrapCheck = {}
  unit = civ[1]
  targ = civ[2]

  ----
  writeall('wrapper -getUnit RACE -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -script [ devel/print-args TARGET_UNIT_ID ]')
  output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -getUnit RACE -script [ devel/print-args TARGET_UNIT_ID ]')
  writeall(output)

  ----
  writeall('wrapper -getUnit DOMESTIC -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -script [ devel/print-args TARGET_UNIT_LOCATION ]')
  output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -center -radius [ 50 50 5 ] -getUnit DOMESTIC -script [ devel/print-args TARGET_UNIT_LOCATION ]')
  writeall(output)

  ----
  writeall('wrapper -getUnit CIV -sourceUnit '..tostring(unit.id)..' -targetUnit '..tostring(targ.id)..' -checkCreature REQUIRED:DWARF:MALE -script [ devel/print-args TARGET_UNIT_DESTINATION ]')
  output = dfhack.run_command_silent('wrapper -sourceUnit '..tostring(unit.id)..' -targetUnit '..tostring(targ.id)..' -getUnit CIV -checkCreature REQUIRED:DWARF:MALE -script [ devel/print-args TARGET_UNIT_DESTINATION ]')
  writeall(output)

  ----
  checks = '-getUnit ANY -radius 100 '
  checks = checks..'-checkClass [ REQUIRED:GENERAL_POISON IMMUNE:TEST_CLASS_1 IMMUNE:TEST_SYNCLASS_1 ] '
  checks = checks..'-checkCreature [ REQUIRED:DWARF:ALL IMMUNE:DONKEY:FEMALE IMMUNE:HORSE:MALE ] '
  checks = checks..'-checkSyndrome [ "REQUIRED:test syndrome" IMMUNE:syndromeOne IMMUNE:syndromeTwo ] '
  checks = checks..'-checkToken [ REQUIRED:COMMON_DOMESTIC IMMUNE:FLIER MEGABEAST ] '
  checks = checks..'-checkNoble [ REQUIRED:MONARCH IMMUNE:BARON DUKE ] '
  checks = checks..'-checkProfession [ REQUIRED:MINER IMMUNE:MILLING PLANT ] '
  checks = checks..'-checkEntity [ REQUIRED:MOUNTAIN IMMUNE:FOREST PLAIN ] '
  checks = checks..'-checkPathing [ REQUIRED:FLEEING IMMUNE:PATROL IDLE ] '
  checks = checks..'-checkAttribute [ MAX:STRENGTH:5000 MIN:TOUGHNESS:500 MIN:ENDURANCE:500 GREATER:WILLPOWER:2 LESS:AGILITY:1 ] '
  checks = checks..'-checkSkill [ MAX:MINING:5 MIN:BUTCHER:2 MIN:TANNER:2 GREATER:MASONRY:1 LESS:CARPENTRY:1 ] '
  checks = checks..'-checkTrait [ MAX:ANGER_PROPENSITY:50 MIN:LOVE_PROPENSITY:10 MIN:HATE_PROPENSITY:10 GREATER:LUST_PROPENSITY:1 LESS:ENVY_PROPENSITY:1 ] '
  checks = checks..'-checkAge [ MAX:100 MIN:1 GREATER:1 LESS:1 ] '
  checks = checks..'-checkSpeed [ MAX:500 MIN:1 GREATER:1 LESS:1 ] '
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

  ---- FINISH Unit Based Targeting
  writeall('Unit Based Targeting Finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Location Based Targeting ------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('Location Based Targeting Starting')
  wrapCheck = {}
  pos = civ[3].pos
  loc = '[ '..tostring(pos.x)..' '..tostring(pos.y)..' '..tostring(pos.z)..' ]'
  pos = civ[2].pos
  tar = '[ '..tostring(pos.x)..' '..tostring(pos.y)..' '..tostring(pos.z)..' ]'

  ----
  writeall('wrapper -getLocation LEVEL -sourceLocation '..loc..' -targetLocation '..tar..' -checkLiquid REQUIRED:WATER -script [ devel/print-args TARGET_POSITION ]')
  output = dfhack.run_command_silent('wrapper -getLocation LEVEL -sourceLocation '..loc..' -targetLocation '..tar..' -checkLiquid REQUIRED:WATER -script [ devel/print-args TARGET_POSITION ]')
  writeall(output)

  ----
  writeall('wrapper -getLocation ABOVE -sourceUnit '..tostring(civ[3].id)..' -targetUnit '..tostring(civ[2].id)..' -checkFlow FORBIDDEN:DRAGONFIRE -script [ devel/print-args TARGET_POSITION ]')
  output = dfhack.run_command_silent('wrapper -getLocation ABOVE -sourceUnit '..tostring(civ[3].id)..' -targetUnit '..tostring(civ[2].id)..' -checkFlow FORBIDDEN:DRAGONFIRE -script [ devel/print-args TARGET_POSITION ]')
  writeall(output)

  ----
  writeall('wrapper -getLocation BELOW -sourceLocation '..loc..' -center -checkTree [ FORBIDDEN:CEDAR FORBIDDEN:MAPLE FORBIDDEN:OAK ] -script [ devel/print-args TARGET_POSITION ]')
  output = dfhack.run_command_silent('wrapper -getLocation BELOW -sourceLocation '..loc..' -center -checkTree [ FORBIDDEN:CEDAR FORBIDDEN:MAPLE FORBIDDEN:OAK ] -script [ devel/print-args TARGET_POSITION ]')
  writeall(output)

  ----
  checks = '-getLocation ANY -radius 100 '
  checks = checks..'-checkTree [ REQUIRED:CEDAR FORBIDDEN:MAPLE FORBIDDEN:OAK ] '
  --checks = checks..'-checkGrass [ REQUIRED:GRASS_1 FORBIDDEN:GRASS_2 FORBIDDEN:GRASS_3 ] '
  checks = checks..'-checkPlant [ REQUIRED:STRAWBERRY FORBIDDEN:BLUEBERRY FORBIDDEN:BLACKBERRY ] '
  checks = checks..'-checkLiquid [ REQUIRED:WATER FORBIDDEN:MAGMA ] '
  checks = checks..'-checkInorganic [ REQUIRED:OBSIDIAN FORBIDDEN:SLADE FORBIDDEN:MARBLE ] '
  checks = checks..'-checkFlow [ REQUIRED:MIST FORBIDDEN:MIASMA FORBIDDEN:DRAGONFIRE ] '
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

  ---- FINISH Location Based Targeting
  writeall('Location Based Targeting Finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Item Based Targeting ----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('Item Based Targeting Starting')
  wrapCheck = {}

  ----
  writeall('wrapper -getItem INVENTORY -sourceUnit '..tostring(civ[2].id)..' -targetUnit '..tostring(civ[3].id)..' -checkItemType REQUIERD:WEAPON:ITEM_SWORD_SHORT -script [ devel/print-args TARGET_ITEM_ID ]')
  output = dfhack.run_command_silent('wrapper -getItem INVENTORY -sourceUnit '..tostring(civ[2].id)..' -targetUnit '..tostring(civ[3].id)..' -checkItemType REQUIRED:WEAPON:ITEM_SWORD_SHORT -script [ devel/print-args TARGET_ITEM_ID ]')
  writeall(output)

  ----
  writeall('wrapper -getItem ONGROUND -sourceUnit '..tostring(civ[2].id)..' -center -radius [ 20 20 20 ] -checkCorpse REQUIRED:ALL -script [ devel/print-args TARGET_ITEM_ID ]')
  output = dfhack.run_command_silent('wrapper -getItem ONGROUND -sourceUnit '..tostring(civ[2].id)..' -center -radius [ 20 20 20 ] -checkCorpse REQUIRED:ALL -script [ devel/print-args TARGET_ITEM_ID ]')
  writeall(output)

  ----
  writeall('wrapper -getItem PROJECTILE -sourceLocation '..loc..' -center -radius [ 2 2 1 ] -checkMaterial REQUIRED:INORGANIC:IRON -script [ devel/print-args TARGET_ITEM_ID ]')
  output = dfhack.run_command_silent('wrapper -getItem PROJECTILE -sourceLocation '..loc..' -center -radius [ 2 2 1 ] -checkMaterial REQUIRED:INORGANIC:IRON -script [ devel/print-args TARGET_ITEM_ID ]')
  writeall(output)

  ----
  checks = '-getItem ANY -radius 100 '
  checks = checks..'-checkItemType [ REQUIRED:STATUE FORBIDDEN:WEAPON:ITEM_WEAPON_LONGSWORD FORBIDDEN:AMMO:ITEM_AMMO_BOLT ] '
  checks = checks..'-checkMaterial [ REQUIRED:STEEL FORBIDDEN:SILVER FORBIDDEN:GOLD ] '
  checks = checks..'-checkCorpse [ REQUIRED:DWARF FORBIDDEN:HUMAN:MALE FORBIDDEN:ELF:FEMALE ] '
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

  ---- FINISH Item Based Targeting
  writeall('Item Based Targeting Finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Wrapper script checks finished',COLOR_CYAN)

 io.close()
end

script.start(script_checks)
