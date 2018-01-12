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

  ---- FINISH Location Based Targeting
  writeall('Location Based Targeting Finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- START Item Based Targeting ----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ---- FINISH Item Based Targeting
  writeall('Item Based Targeting Finished')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Wrapper script checks finished',COLOR_CYAN)

 io.close()
end

script.start(script_checks)
