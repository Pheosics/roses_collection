print('Running base/roses-init with all options enabled')
local classCheck = ' -classSystem [ Feats Spells ]'
local civCheck = ' -civilizationSystem [ Diplomacy ]'
local eventCheck = ' -eventSystem'
local enhCheck = ' -enhancedSystem [ Buildings Creatures Items Materials Reactions ]'
local verbose = true
print('base/roses-init'..classCheck..civCheck..eventCheck..enhCheck..' -verbose -testRun')
dfhack.run_command('base/roses-init'..classCheck..civCheck..eventCheck..enhCheck..' -verbose -testRun')

local persistTable = require 'persist-table'
local roses = persistTable.GlobalTable.roses

print('Begin System Read Checks')

print('')
print('Class System:')
local classTable = roses.ClassTable
print('--Test Class 1')
printall(classTable.TEST_CLASS_1)
print('--Test Class 2')
printall(classTable.TEST_CLASS_2)
print('--Test Class 3')
printall(classTable.TEST_CLASS_3)

print('')
print('Class System - Feat SubSystem:')
local featTable = roses.FeatTable
print('--Test Feat 1')
printall(featTable.TEST_FEAT_1)
print('--Test Feat 2')
printall(featTable.TEST_FEAT_2)
print('--Test Feat 3')
printall(featTable.TEST_FEAT_3)

print('')
print('Class System - Spell SubSystem:')
local spellTable = roses.SpellTable
print('--Test Spell 1')
printall(spellTable.TEST_SPELL_1)
print('--Test Spell 2')
printall(spellTable.TEST_SPELL_2)
print('--Test Spell 3')
printall(spellTable.TEST_SPELL_3)
print('--Test Spell 4')
printall(spellTable.TEST_SPELL_4)

print('')
print('Civilization System:')
local civTable = roses.CivilizationTable
print('--Test Dwarf Civ')
printall(civTable.MOUNTAIN)
print('--Test Elf Civ')
printall(civTable.FOREST)

print('')
print('Event System:')
local eventTable = roses.EventTable
print('--Test Event 1')
printall(eventTable.TEST_EVENT_1)
print('--Test Event 2')
printall(eventTable.TEST_EVENT_2)
print('--Test Event 3')
printall(eventTable.TEST_EVENT_3)

print('')
print('Enhanced System:')

print('*Enhanced System - Buldings not currently operational')

print('')
print('Enhanced System - Creatures:')
local ECTable = roses.EnhancedCreatureTable
print('--Test Enhanced Creature 1')
printall(ECTable.DWARF)
print('--Test Enhanced Creature 2')
printall(ECTable.ELF)

print('')
print('Enhanced System - Items:')
local EITable = roses.EnhancedItemTable
print('--Test Enhanced Item 1')
printall(EITable.ITEM_WEAPON_PICK)
print('--Test Enhanced Item 2')
printall(EITable.ITEM_WEAPON_HANDAXE)
print('--Test Enhanced Item 3')
printall(EITable.ITEM_WEAPON_SWORD_SHORT)

print('')
print('*Enhanced System - Materials not currently operational')

print('')
print('All System Read Checks Finished')

print('Beginning System Run Checks')

print('')
print('Class System:')
classCheck = {}
print('Finding Unit')
for _,unit in pairs(df.global.world.creatures.active) do
 if dfhack.units.isDwarf(unit) then
  break
 end
end
print('Dwarf found, ID: '..tostring(unit.id)..' Name: '..dfhack.units.getName(unit))
print('Creating Unit Table')
dfhack.script_environment('functions/tables').makeUnitTable(unit,verbose)
unitTable = roses.UnitTable[tostring(unit.id)]
print('Centering view on unit')
df.global.cursor.x = unit.pos.x
df.global.cursor.y = unit.pos.y
df.global.cursor.z = unit.pos.z
print('Attempting to assign Test Class 1 to unit')
dfhack.run_command('classes/change-class -unit '..tostring(unit.id)..' -class TEST_CLASS_1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
if unitTable.Classes.Current.Name ~= 'TEST_CLASS_1' then classCheck['TC1_Assign'] = 'Test Class 1 was not assigned to the Unit' end
print('Adding experience to unit - Will level up Test Class 1 to level 1 and assign Test Spell 1')
print('Mining and Woodcutting skill will increase')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
if unitTable.Classes.Current.TotalExp ~= 1 or unitTable.Classes.TEST_CLASS_1.Level ~= 1 then classCheck['TC1_L1'] = 'Test Class 1 did not level from 0 to 1' end
if unitTable.Skills.MINING.Class ~= 1 or unitTable.Skills.WOODCUTTING ~= 1 then classCheck['TC1_SC1'] = 'Test Class 1 level 1 skills were not applied correctly' end
if unitTable.Spells.TEST_SPELL_1 ~= 1 or not unitTable.Spells.Active.TEST_SPELL_1 then classCheck['TC1_AddS1'] = 'Test Class 1 level 1 did not add Test Spell 1' end
print('Adding experience to unit - Will level up Test Class 1 to level 2')
print('Mining and Woodcutting skill will increase')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
if unitTable.Classes.Current.TotalExp ~= 2 or unitTable.Classes.TEST_CLASS_1.Level ~= 2 then classCheck['TC1_L2'] = 'Test Class 1 did not level from 1 to 2' end
if unitTable.Skills.MINING.Class ~= 5 or unitTable.Skills.WOODCUTTING ~= 4 then classCheck['TC1_SC2'] = 'Test Class 1 level 2 skills were not applied correctly' end
print('Assigning Test Spell 2 to unit')
dfhack.run_command('classes/learn-skill -unit '..tostring(unit.id)..' -spell TEST_SPELL_2 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
if unitTable.Spells.TEST_CLASS_2 ~= 1 or not unitTable.Spells.Active.TEST_SPELL_2 then classCheck['TC1_AddS2'] = 'Test Class 1 level 2 unable to add Test Spell 2' end
print('Adding experience to unit - Will level up Test Class 1 to level 3 and auto change class to Test Class 2')
print('Mining skill will increase, Woodcutting skill will reset')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
if unitTable.Classes.Current.TotalExp ~= 3 or unitTable.Classes.TEST_CLASS_1.Level ~= 3 then classCheck['TC1_L3'] = 'Test Class 1 did not level from 2 to 3' end
if unitTable.Skills.MINING.Class ~= 14 then classCheck['TC1_SC3'] = false end
if unitTable.Classes.Current.Name ~= 'TEST_CLASS_2' then classCheck['TC2_Assign'] = 'Test Class 1 did not automatically changed to Test Class 2' end
if unitTable.Skills.WOODCUTTING.Class ~= 0 then claccCheck['TC2_SC1'] = 'Test Class 2 level 0 skills did not reset' end
print('Adding experience to unit - Will level up Test Class 2 to level 1 and replace Test Spell 1 with Test Spell 3')
print('Mining skill will remain the same, Carpentry skill will increase')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
if unitTable.Classes.Current.TotalExp ~= 4 or unitTable.Classes.TEST_CLASS_2.Level ~= 1 then classCheck['TC2_L1'] = 'Test Class 2 did not level from 0 to 1' end
if unitTable.Skills.MINING.Class ~= 14 or unitTable.Skills.CARPENTRY.Class ~= 15 or unitTable.Skills.MASONRY.Class ~= 15 then classChecl['TC2_SC2'] = 'Test Class 2 level 1 skills were not applied correctly' end
if unitTable.Spells.TEST_SPELL_3 ~= 1 or unitTable.Spells.Active.TEST_SPELL_1 or not unitTable.Spells.Active.TEST_SPELL_3 then classCheck['TC2_AddS3'] = 'Test Class 2 level 1 Test Spell 3 did not replace Test Spell 1' end
print('Base Class System checks and Spell assignment checks finished. Starting Feat SubSystem checks')

print('')
print('Feat/Unit details:')
featCheck = {}
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
print('Attempting to assign Test Feat 2 to unit, this should fail')
dfhack.run_command('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_2 -verbose')
print('Feat/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
if unitTable.Classes.Feats.TEST_FEAT_2 then featCheck['TF2_Assign1'] = 'Test Feat 2 was applied when it should not have been' end
print('Attempting to assign Test Feat 1 to unit, this should work')
dfhack.run_command('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_1 -verbose')
print('Feat/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
if not unitTable.Classes.Feats.TEST_FEAT_1 then featCheck['TF1_Assign'] = 'Test Feat 1 was not correctly applied' end
print('Attempting to assign Test Feat 2 to unit, now this should work')
dfhack.run_command('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_2 -verbose')
print('Feat/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
if unitTable.Classes.Feats.TEST_FEAT_2 then featCheck['TF2_Assign2'] = 'Test Feat 2 was not correctly applied' end
print('Feat SubSystem checks finished. Spell SubSystem checks will be made later')

print('')
print('Civilization System:')
civCheck = {}
print('Creating Entity Table for unit.civ_id')
dfhack.script_environment('functions/tables').makeEntityTable(unit.civ_id,verbose)
entityTable = roses.EntityTable[tostring(unit.civ_id)]
if not entityTable.Civilization then civCheck['TV1_Assign'] = 'Test Civilization 1 was not correctly assigned to the entity' end
print('Entity details')
printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_races)
printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_castes)
print('Assigning Civlization to Entity, should clear available mounts')
print('Entity details')
printall(entityTable)
printall(entityTable.Civilization)
printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_races)
printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_castes)
if #df.global.world.entities.all[unit.civ_id].resources.animals.mount_races ~= 0 then civCheck['TV1_CA1'] = 'Test Civilization 1 level 0 mount creatures were not removed' end
print('Force level increase, should add dragons to available mounts and change level method')
dfhack.run_command('civilizations/level-up -civ '..tostring(unit.civ_id)..' -amount 1 -verbose')
print('Entity details')
printall(entityTable)
printall(entityTable.Civilization)
printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_races)
printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_castes)
if entityTable.Civilization.Level ~= 1 then civCheck['TV1_Level1'] = false end
if #df.global.world.entities.all[unit.civ_id].resources.animals.mount_races ~= 2 then civCheck['TV1_CA2'] = 'Test Civilization 1 level 1 mount creatures were not added' end
print('Next level increase should occur within 1 in-game day, will add humans as available mounts')
-- ADD WAIT HERE!!
--[[
print('Set up call back to check Entity details')
dfhack.timeout(4000,'ticks',function ()
                             print('Entity details')
                             printall(entityTable)
                             printall(entityTable.Civilization)
                             printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_races)
                             printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_castes)
                            end)
]]
print('')
print('Testing full removal and addition with Test Civ 2')
for _,entity in pairs(df.global.world.entities.all) do
 if entity.entity_raw.code == 'FOREST' then
  break
 end
end
dfhack.script_environment('functions/tables').makeEntityTable(entity.id,verbose)
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
pearl = {'refuse','pearl','mat_type'},
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
instrument = {'instrument_type'},
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
for xCheck,aCheck in pairs(nCheck) do
 resources = entity.resources
 for _,tables in pairs(aCheck) do
  resources = resources[tables]
 end
 if #resources ~= 0 then civCheck['TV2_L1_'..xcheck] = 'Test Civilization 2 level 0 '..table.unpack(aCheck)..' not correctly removed from' end
end
dfhack.run_command('civilizations/level-up -civ '..tostring(entity.id)..' -amount 1 -verbose')
for xCheck,aCheck in pairs(nCheck) do
 resources = entity.resources
 for _,tables in pairs(aCheck) do
  resources = resources[tables]
 end
 if #resources < 1 then civCheck['TV2_L2_'..xcheck] = 'Test Civilization 2 level 1 '..table.unpack(aCheck)..' not correctly added to' end
end
dfhack.run_command('civilizations/level-up -civ '..tostring(entity.id)..' -amount 1 -verbose')
if roses.EntityTable[tostring(entity.id)].Civilization.Level == 3 then civCheck['TV2_L3'] = 'Test Civilization 2 level 2 incorrectly applied, should have failed' end
print('Civilization System Run Checks Finished')

print('')
print('Enhanced System checks:')
enhCheck = {}
print('**Enhanced System - Buildings, not currently operational')

print('')
print('Enhanced System - Creatures')
print('Enhancing all dwarf creatures')
print('Agility should be increased to between 5000 and 8000 and GROWER skill to between 5 and 15')
print('For reference the dwarf used in Class System checks will be shown')
print('Before:')
printall(unit.body.physical_attrs.AGILITY)
printall(unitTable.Skills)
for _,unit in pairs(df.global.world.creatures.active) do
 if dfhack.units.isDwarf(unit) then
  dfhack.script_environment('functions/enahnced').enhanceCreature(unit)
 end
end
print('After:')
printall(unit.body.physical_attrs.AGILITY)
printall(unitTable.Skills)
if unit.body.physical_attrs.AGILITY.current < 5000 or unitTable.Skills.GROWER.Base < 5 then enhCheck['ESC1'] = 'Enhanced System - Creature 1 not correctly applied' end
print('Enhanced System - Creatures check finished')

print('')
print('Enhanced System - Items')
print('When the pick is equipped the units Axe skill should increase to legendary')
print('When the hand axe is equipped the unit should learn the Test Spell 1 spell')
print('Both effects should revert when the item is unequipped')
base = 'modtools/item-trigger -itemType ITEM_WEAPON_PICK -onEquip -command'
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -equip ]')
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -equip ]')
base = 'modtools/item-trigger -itemType ITEM_WEAPON_PICK -onUnequip -command'
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID ]')
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID ]')

print('')
print('Testing Enhanced Item 1 - ITEM_WEAPON_PICK')
dfhack.run_command('item/create -creator '..tostring(unit.id)..' -item WEAPON:ITEM_WEAPON_PICK -material INORGANIC:STEEL -verbose')
print('Before Equipping the pick')
printall(unitTable.Skills)
dfhack.run_command('item/equip -unit '..tostring(unit.id)..' -item MOST_RECENT -verbose')
-- ADD WAIT HERE!!!
print('After Equipping the pick')
printall(unitTable.Skills)
if unitTable.Skills.AXE.Item < 15 then enhCheck['ESI1_Equip'] = 'Enhanced System - Item 1 equip skill change not correctly applied' end
dfhack.run_command('item/unequip -unit '..tostring(unit.id)..' -item WEAPONS -verbose')
-- ADD WAIT HERE!!!
print('After UnEquipping the pick')
printall(unitTable.Skills)
if unitTable.Skills.AXE.Item > 0 then enhCheck['ESI1_Unequip'] = 'Enhanced System - Item 1 unequip skill change not correctly applied' end

print('')
print('Testing Enhanced Item 2 - ITEM_WEAPON_HANDAXE')
dfhack.run_command('item/create -creator '..tostring(unit.id)..' -item WEAPON:ITEM_WEAPON_HANDAXE -material INORGANIC:STEEL -verbose')
print('Before Equipping the hand axe')
printall(unitTable.Spells.Active)
dfhack.run_command('item/equip -unit '..tostring(unit.id)..' -item MOST_RECENT -verbose')
-- ADD WAIT HERE!!!
print('After Equipping the hand axe')
printall(unitTable.Spells.Active)
if not unitTable.Spells.Active.TEST_SPELL_1 then enhCheck['ESI2_Equip'] = 'Enhanced System - Item 2 equip spell change not correctly applied' end
dfhack.run_command('item/unequip -unit '..tostring(unit.id)..' -item WEAPONS -verbose')
-- ADD WAIT HERE!!!
print('After UnEquipping the hand axe')
printall(unitTable.Spells.Active)
if unitTable.Spells.Active.TEST_SPELL_1 then enhCheck['ESI2_Unequip'] = 'Enhanced System - Item 2 unequip spell change not correctly applied' end
print('Enhanced System - Items check finished')

print('**Enhanced System - Materials not currently operational')

print('**Enhanced System - Reactions not currently operational')

print('Enhanced System checks finished')

print('')
print('Event System checks:')
print('Forcing Test Event 2 to trigger, both effects should fail')
dfhack.run_command('events/trigger -event TEST_EVENT_2 -force -verbose')
print('Test Event 1 should occur within 1 in-game day, if successful a random location and random unit id will be printed')
-- ADD WAIT HERE!!!
print('Event Systen checks finished')

print('System checks finished, starting Base script checks')

print('')
print('Running Base commands:')
print('Running base/persist-delay')
dfhack.run_command('base/persist-delay -verbose')
print('Running base/liquids-update')
dfhack.run_command('base/liquids-update -verbose')
print('Running base/flows-update')
dfhack.run_command('base/flows-update -verbose')
print('Running base/on-death')
dfhack.run_command('base/on-death -verbose')
print('Running base/on-time')
dfhack.run_command('base/on-time -verbose')
print('Running base/periodic-check')
dfhack.run_command('base/periodic-check -verbose')

print('Base script checks finished, starting full script checks')
print('All scripts will be run multiple times, with both correct and incorrect arguments, starting with -help')

print('')
print('Building script checks starting')
buildingVanilla = 1
buildingCustom = 1
print('building/subtype-change checks starting')
print('building/subtype-change -help (Should print help menu)')
dfhack.run_command('building/subtype-change -help')
print('building/subtype-change (Should fail and print "No unit or building declaration")')
dfhack.run_command('building/subtype-change')
print('building/subtype-change -building '..tostring(buildingVanilla)..' -type BUILDING_CUSTOM_TEST_2 (Should fail and print "Changing vanilla buildings not currently supported")')
dfhack.run_command('building/subtype-change -building '..tostring(buildingVanilla)..' -type BUILDING_CUSTOM_TEST_2')
print('building/subtype-change -building '..tostring(buildingCustom)..' (Should fail and print "no specified subtype chosen")')
dfhack.run_command('building/subtype-change -building '..tostring(buildingCustom))
print('building/subtype-change -building '..tostring(buildingCustom)..' -type BUILDING_CUSTOM_TEST_2 (Should succeed and change building subtype)')
dfhack.run_command('building/subtype-change -building '..tostring(buildingCustom)..' -type BUILDING_CUSTOM_TEST_2')
print('building/subtype-change -building '..tostring(buildingCustom)..' -type BUILDING_CUSTOM_TEST_3 -item MOST_RECENT (Should succeed, change building subtype, and add a handaxe to the building item list)')
dfhack.run_command('building/subtype-change -building '..tostring(buildingCustom)..' -type BUILDING_CUSTOM_TEST_3 -item MOST_RECENT')
print('building/subtype-change checks finished')
print('Building script checks finished')

print('')
print('Flow script checks starting')
--Get new unit
print('flow/random-plan checks starting')
print('flow/random-plan -help')
dfhack.run_command('flow/random-plan -help')
print('flow/random-plan (Should fail and print "No plan file specified")')
dfhack.run_command('flow/random-plan')
print('flow/random-plan -plan test_plan_5x5_X.txt (Should fail and print "No unit or location selected")')
dfhack.run_command('flow/random-plan -plan test_plan_5x5_X.txt')
print('flow/random-plan -plan test_plan_5x5_X.txt -unit '..tostring(unit.id)..' -liquid water -depth 1 (Should succeed and create water of depth 1 in a 5x5 X centered on unit)')
dfhack.run_command('flow/random-plan -plan test_plan_5x5_X.txt -unit '..tostring(unit.id)..' -liquid water -depth 1')
print('flow/random-plan -plan test_plan_5x5_P.txt -unit '..tostring(unit.id)..' -flow dust -inorganic OBSIDIAN -density 100 -static (Should succeed and create obsidian dust in a 5x5 plus centered on unit, dust should not expand)')
dfhack.run_command('flow/random-plan -plan test_plan_5x5_P.txt -unit '..tostring(unit.id)..' -flow dust -inorganic OBSIDIAN -density 100 -static')
print('flow/random-plan checks finished')

print('')
--Get new unit
print('flow/random-pos checks starting')
print('flow/random-pos -help')
dfhack.run_command('flow/random-pos -help')
print('flow/random-pos (Should fail and print "No unit or location selected")')
dfhack.run_command('flow/random-pos')
print('flow/random-pos -unit '..tostring(unit.id)..' -liquid water -depth 7 -radius [ 5 5 0 ] -circle -taper (Should succeed and create a circle of water of radius 5 with a depth of 7 in the middle and tapering out)')
dfhack.run_command('flow/random-pos -unit '..tostring(unit.id)..' -liquid water -depth 7 -radius [ 5 5 0 ] -circle -taper')
print('flow/random-pos -unit '..tostring(unit.id)..' -flow dragonfire -density 50 -static -radius [ 10 10 0 ] -number 10 (Should succeed and create 10 50 density dragon fires in a 10x10 block around the unit, fire should not spread)')
dfhack.run_command('flow/random-pos -unit '..tostring(unit.id)..' -flow dragonfire -density 50 -static -radius [ 10 10 0 ] -number 10')
print('flow/random-pos checks finished')

print('')
print('flow/random-surface checks starting')
print('flow/random-surface -help')
dfhack.run_command('flow/random-surface -help')
print('flow/random-surface (Should fail and print "Neither a flow or a liquid specified, aborting.")')
dfhack.run_command('flow/random-surface')
print('flow/random-surface -liquid magma -depth 5 -dur 500 -frequency 100 -number 50 (Should succeed and create 50 depth 5 magma spots every 100 ticks for 500 ticks, 250 total)')
dfhack.run_command('flow/random-surface -liquid magma -depth 5 -dur 500 -frequency 100 -number 50')
print('flow/random-surface -flow miasma -density 100 -dur 250 -frequency 100 -number 200 (Should succeed and create 200 density 100 miasma spots that spread every 100 ticks for 250 ticks, 400 total)')
dfhack.run_command('flow/random-surface -flow miasma -density 100 -dur 250 -frequency 100 -number 200')
print('flow/random-surface checks finished')

print('')
print('flow/source checks starting')
-- Get new unit
print('flow/source -help')
dfhack.run_command('flow/source -help')
print('flow/source (Should fail and print "No unit or location selected")')
dfhack.run_command('flow/source')
print('flow/source -unit '..tostring(unit.id)..' -source 3 (Should succeed and create a source that creates a depth 3 water at unit)')
dfhack.run_command('flow/source -unit '..tostring(unit.id)..' -source 3')
print('flow/source -unit '..tostring(unit.id)..' -offset [ 1 0 0 ] -sink 0 (Should succeed and create a sink the removes all water one tile right of unit)')
dfhack.run_command('flow/source -unit '..tostring(unit.id)..' -offset [ 1 0 0 ] -sink 0')
print('flow/source -unit '..tostring(unit.id)..' -offset [ 0 5 0 ] -source 100 -flow MIST (Should succeed and create a source that creates 100 density mist 5 tiles below unit)') 
dfhack.run_command('flow/source -unit '..tostring(unit.id)..' -offset [ 0 5 0 ] -source 100 -flow MIST')
print('flow/source -unit '..tostring(unit.id)..' -offset [ 0 4 0 ] -sink 0 -flow MIST (Should succeed and create a sink that removes all mist flow four tiles below unit)')
dfhack.run_command('flow/source -unit '..tostring(unit.id)..' -offset [ 0 4 0 ] -sink 0 -flow MIST')
print('flow/source checks finished')
print('Flow script checks finished')

print('')
print('Item script checks starting')
print('item/create checks starting')
print('item/create -help')
dfhack.run_command('item/create -help')
print('item/create (Should fail and print "Invalid item")')
dfhack.run_command('item/create')
print('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT (Should fail and print "Invalid material")')
dfhack.run_command('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT')
print('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL (Should succeed and create a steel short sword)')
dfhack.run_command('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL')
print('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:RUBY -dur 50 (Should succeed and create a ruby short sword and then remove it 50 ticks later)')
dfhack.run_command('item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:RUBY -dur 50')
print('item/create checks finished')

print('')
print('item/equip and item/unequip checks starting')
-- Get new unit
-- Get new item
print('item/equip -help')
dfhack.run_command('item/equip -help')
print('item/unequip -help')
dfhack.run_command('item/unequip -help')
print('item/equip (Should fail and print "No item selected")')
dfhack.run_command('item/equip')
print('item/equip -item '..tostring(item.id)..' (Should fail and print "No unit selected")')
dfhack.run_command('item/equip -item '..tostring(item.id))
print('item/equip -item '..tostring(item.id)..' -unit '..tostring(unit.id)..' -bodyPartFlag GRASP (Should succeed and move item into inventory of unit carrying in hand)')
dfhack.run_command('item/equip -item '..tostring(item.id)..' -unit '..tostring(unit.id)..' -bodyPartFlag GRASP')
print('item/unequip -item '..tostring(item.id)..' -ground (Should succeed and move item from inventory to ground at unit location)')
dfhack.run_command('item/unequip -item '..tostring(item.id)..' -ground')
print('item/equip -item '..tostring(item.id)..' -unit STANDING -bodyPartCategory HEAD -mode 0 (Should succeed and move item into inventory of unit weilding it on head)')
dfhack.run_command('item/equip -item '..tostring(item.id)..' -unit STANDING -bodyPartCategory HEAD -mode 0')
print('item/unequip -item ALL -unit '..tostring(unit.id)..' -destroy (Should succeed and destroy all items that unit has in inventory)')
dfhack.run_command('item/unequip -item ALL -unit '..tostring(unit.id)..' -destroy')
print('item/equip and item/unequip checks finished')

print('')
print('item/material-change checks starting')
-- Get new item
-- Get new unit
print('item/material-change -help')
dfhack.run_command('item/material-change -help')
print('item/material-change (Should fail and print "No unit or item selected")')
dfhack.run_command('item/material-change')
print('item/material-change -item '..tostring(item.id)..' -mat CREATURE_MAT:DWARF:BRAIN (Should succeed and change the material of item to dwarf brain)')
dfhack.run_command('item/material-change -item '..tostring(item.id)..' -mat CREATURE_MAT:DWARF:BRAIN')
print('item/material-change -unit '..tostring(unit.id)..' -equipment ALL -mat INORGANIC:ADAMANTINE -dur 50 (Should succeed and change the material of all units inventory to adamantine for 50 ticks)')
dfhack.run_command('item/material-change -unit '..tostring(unit.id)..' -equipment ALL -mat INORGANIC:ADAMANTINE -dur 50')
print('item/material-change -item '..tostring(item.id)..' -mat INORGANIC:STEEL -track (Should succeed and change the material of item to steel and create a persistent table for the item to track changes)') 
dfhack.run_command('item/material-change -item '..tostring(item.id)..' -mat INORGANIC:STEEL -track')
print('item/material-change checks finished')

print('')
print('item/projectile checks starting')
print('item/projectile -help')
dfhack.run_command('item/projectile -help')
print('item/projectile (Should fail and print "No source specified")')
dfhack.run_command('item/projectile')
print('item/projectile -unitSource '..tostring(unitSource.id)..' (Should fail and print "No target specified")')
dfhack.run_command('item/projectile -unitSource '..tostring(unitSource.id))
print('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id)..' (Should fail and print "No item specified")')
dfhack.run_command('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id))
print('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id)..' -item AMMO:ITEM_AMMO_BOLT (Should fail and print "Invalid material")')
dfhack.run_command('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id)..' -item AMMO:ITEM_AMMO_BOLT')
print('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id)..' -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON (Should succeed and create an iron bolt shooting from source to target)')
dfhack.run_command('item/projectile -unitSource '..tostring(unitSource.id)..' -unitTarget '..tostring(unitTarget.id)..' -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON')
print('item/projectile -unitSource '..tostring(unitSource.id)..' -type Falling -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON -height 5 -number 10 (Should succeed and create 10 iron bolt falling from 5 above the source)')
dfhack.run_command('item/projectile -unitSource '..tostring(unitSource.id)..' -type Falling -item AMMO:ITEM_AMMO_BOLT -mat INORGANIC:IRON -height 5 -number 10')
print('item/projectile checks finished')

print('')
print('item/quality-change checks starting')
print('item/quality-change -help')
dfhack.run_command('item/quality-change -help')
print('item/quality-change (Should fail and print "No unit or item selected")')
dfhack.run_command('item/quality-change')
print('item/quality-change -item '..tostring(item.id)..' -quality 7 -track (Should succeed and change the quality of the item to masterwork and track the change in the persistent item table)')
dfhack.run_command('item/quality-change -item '..tostring(item.id)..' -quality 7 -track')
print('item/quality-change -unit '..tostring(unit.id)..' -equipment ALL -quality 7 -dur 50 (Should succeed and change the quality of all units inventory to masterwork for 50 ticks)')
dfhack.run_command('item/quality-change -unit '..tostring(unit.id)..' -equipment ALL -quality 7 -dur 50')
print('item/quality-change -type WEAPON:ITEM_WEAPON_SWORD_SHORT -downgrade (Should succeed and lower the quality of all short swords on the map by 1)') 
dfhack.run_command('item/quality-change -type WEAPON:ITEM_WEAPON_SWORD_SHORT -downgrade')
print('item/quality-change checks finished')

print('')
print('item/subtype-change checks starting')
print('item/subtype-change -help')
dfhack.run_command('item/subtype-change -help')
print('item/subtype-change (Should fail and print "No unit or item selected")')
dfhack.run_command('item/subtype-change')
print('item/subtype-change -item '..tostring(item.id)..' -subtype ITEM_WEAPON_SWORD_LONG -track (Should succeed and change the short sword to a long sword and track the change in the persistent item table)')
dfhack.run_command('item/subtype-change -item '..tostring(item.id)..' -subtype ITEM_WEAPON_SWORD_LONG -track')
print('item/subtype-change -unit '..tostring(unit.id)..' -equipment PANTS -subtype ITEM_PANTS_GREAVES -dur 50 (Should succeed and change the pants the unit is wearing into greaves for 50 ticks)')
dfhack.run_command('item/subtype-change -unit '..tostring(unit.id)..' -equipment PANTS -subtype ITEM_PANTS_GREAVES -dur 50')
print('item/subtype-change -type WEAPON:ITEM_WEAPON_PICK -subtype ITEM_WEAPON_SWORD_SHORT (Should succeed and change all picks on the map into short swords)') 
dfhack.run_command('item/subtype-change -type WEAPON:ITEM_WEAPON_PICK -subtype ITEM_WEAPON_SWORD_SHORT')
print('item/subtype-change checks finished')
print('Item script checks finished')

print('')
print('Tile script checks starting')
-- Get New Unit
print('tile/material-change checks starting')
print('tile/material-change -help')
dfhack.run_command('tile/material-change -help')
print('tile/material-change (Should fail and print "No material declaration")')
dfhack.run_command('tile/material-change')
print('tile/material-change -material INORGANIC:OBSIDIAN (Should fail and print "No unit or location selected")')
dfhack.run_command('tile/material-change -material INORGANIC:OBSIDIAN')
print('tile/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor (Should succeed and change the material of the floor at unit location to obsidian)')
dfhack.run_command('tile/material-change -material INORGANIC:OBSIDIAN -unit '..tostring(unit.id)..' -floor')
print('tile/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50 (Should succeed and change the material of floor in a 5x5 X centered at the unit to slade)')
dfhack.run_command('tile/material-change -material INORGANIC:SLADE -unit '..tostring(unit.id)..' -floor -plan test_plan_5x5_X.txt -dur 50')
print('tile/material-change checks finished')

print('')
print('tile/temperature-change checks starting')
print('tile/temperature-change -help')
dfhack.run_command('tile/temperature-change -help')
print('tile/temperature-change (Should fail and print "no unit or location selected")')
dfhack.run_command('tile/temperature-change')
print('tile/temperature-change -unit '..tostring(unit.id)..' -temperature 9000 (Should succeed and set the temperature at the units location to 9000)')
dfhack.run_command('tile/temperature-change -unit '..tostring(unit.id)..' -temperature 9000')
print('tile/temperature-change -unit '..tostring(unit.id)..' -plan test_plan_5x5_P.txt -temperature 15000 -dur 50 (Should succeed and set the temperature in a 5x5 plus centered at the unit to 15000 for 50 ticks)')
dfhack.run_command('tile/temperature-change -unit '..tostring(unit.id)..' -plan test_plan_5x5_P.txt -temperature 15000 -dur 50')
print('tile/temperature-change checks finished')
print('Tile script checks finished')

print('')
print('Unit script checks starting')
-- Get new unit
print('unit/action-change checks starting')
print('unit/action-change -help')
dfhack.run_command('unit/action-change -help')
print('unit/action-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/action-change')
print('unit/action-change -unit '..tostring(unit.id)..' (Should fail and print "No timer set")')
dfhack.run_command('unit/action-change -unit '..tostring(unit.id))
print('unit/action-change -unit '..tostring(unit.id)..' -timer 500 -action All (Should succeed and add an action for every type with a 500 tick cooldown)')
dfhack.run_command('unit/action-change -unit '..tostring(unit.id)..' -timer 500 -action All')
print('unit/action-change -unit '..tostring(unit.id)..' -timer clearAll (Should succeed and remove all actions from unit)')
dfhack.run_command('unit/action-change -unit '..tostring(unit.id)..' -timer clearAll')
print('unit/action-change -unit '..tostring(unit.id)..' -timer 100 -action Attack -interaction All (Should succeed and add an attack action with a 100 tick cooldown and add 100 ticks to all interaction cooldowns)')
dfhack.run_command('unit/action-change -unit '..tostring(unit.id)..' -timer 100 -action Attack -interaction All')
print('unit/action-change checks finished')

print('')
print('unit/attack checks starting')
-- Get new unit (defender)
-- Get new unit (attacker)
-- Move units together
print('unit/attack -help')
dfhack.run_command('unit/attack -help')
print('unit/attack (Should fail and print "No defender selected")')
dfhack.run_command('unit/attack')
print('unit/attack -defender '..tostring(defender.id)..' (Should fail and print "No attacker selected")')
dfhack.run_command('unit/attack -defender '..tostring(defender.id))
print('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' (Should succeed and add an attack action to the attacker unit, with calculated velocity, hit chance, and body part target)')
dfhack.run_command('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id))
print('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' -attack PUNCH -target HEAD -number 10 -velocity 100 (Should succeed and add 10 punch attacks targeting defender head with velocity 100 and calculated hit chance)')
dfhack.run_command('unit/attack -defender '..tostring(defender.id)..' -attacker '..tostring(attacker.id)..' -attack PUNCH -target HEAD -number 10 -velocity 100')
print('unit/attack checks finished')

print('')
print('unit/attribute-change checks starting')
-- Get new unit
print('unit/attribute-change -help')
dfhack.run_command('unit/attribute-change')
print('unit/attribute-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/attribute-change')
print('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ STRENGTH AGILITY ] -amount 50 (Should fail and print "Mismatch between number of attributes declared and number of changes declared")')
dfhack.run_command('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ STRENGTH AGILITY ] -amount 50')
print('unit/attribute-change -unit '..tostring(unit.id)..' -attribute STRENGHT -amount 50 (Should fail and print "Invalid attribute id")')
dfhack.run_command('unit/attribute-change -unit '..tostring(unit.id)..' -attribute STRENGHT -amount 50')
print('unit/attribute-change -unit '..tostring(unit.id)..' -attribute STRENGTH -amount 50 -mode fixed -dur 50 (Should succeed and add 50 strength to the unit for 50 ticks)')
dfhack.run_command('unit/attribute-change -unit '..tostring(unit.id)..' -attribute STRENGTH -amount 50 -mode fixed -dur 50')
print('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ TOUGHNESS ENDURANCE ] -amount [ 5000 5000 ] -mode set -dur 50 -track (Should succeed and set units toughness and endurance to 5000 for 50 ticks and create a persistent unit table)')
dfhack.run_command('unit/attribute-change -unit '..tostring(unit.id)..' -attribute [ TOUGHNESS ENDURANCE ] -amount [ 5000 5000 ] -mode set -dur 50 -track')
print('unit/attribute-change checks finished')

print('')
print('unit/body-change checks starting')
-- Get new unit
print('unit/body-change -help')
dfhack.run_command('unit/body-change -help')
print('unit/body-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/body-change')
print('unit/body-change -unit '..tostring(unit.id)..' (Should fail and print "Nothing to change declared, choose -age, -size, or -temperature")')
dfhack.run_command('unit/body-change -unit '..tostring(unit.id))
print('unit/body-change -unit '..tostring(unit.id)..' -flag SIGHT -temperature Fire -dur 50 (Should succeed and set the eyes on fire for 50 ticks)')
dfhack.run_command('unit/body-change -unit '..tostring(unit.id)..' -flag SIGHT -temperature Fire -dur 50')
print('unit/body-change -unit '..tostring(unit.id)..' -size All -amount 50 -mode percent (Should succeed and set all sizes, size, length, and area, of the unit to 50 percent of the current)')
dfhack.run_command('unit/body-change -unit '..tostring(unit.id)..' -size All -amount 50 -mode percent')
print('unit/body-change -unit '..tostring(unit.id)..' -token UB -temperature 9000 (Should succeed and set the upper body temperature to 9000)')
dfhack.run_command('unit/body-change -unit '..tostring(unit.id)..' -token UB -temperature 9000')
print('unit/body-change checks finished')

print('')
print('unit/butcher checks starting')
-- Get new unit
print('unit/butcher -help')
dfhack.run_command('unit/butcher -help')
print('unit/butcher (Should fail and print "No corpse selected")')
dfhack.run_command('unit/butcher')
print('unit/butcher -unit '..tostring(unit.id)..' (Should fail and print "Unit is still alive and has not been ordered -kill")')
dfhack.run_command('unit/butcher -unit '..tostring(unit.id))
print('unit/butcher -unit '..tostring(unit.id)..' -kill (Should succeed and kill unit then butcher it)')
dfhack.run_command('unit/butcher -unit '..tostring(unit.id)..' -kill')
print('unit/butcher checks finished')

print('')
print('unit/convert checks starting')
-- Get new unit
-- Get new unit (side)
print('unit/convert -help')
dfhack.run_command('unit/convert -help')
print('unit/convert (Should fail and print "No unit selected")')
dfhack.run_command('unit/convert')
print('unit/convert -unit '..tostring(unit.id)..' (Should fail and print "No side selected")')
dfhack.run_command('unit/convert -unit '..tostring(unit.id))
print('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Neutral (Should succeed and change the unit to a neutral)')
dfhack.run_command('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Neutral')
print('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Civilian (Should succeed and change the unit to a civilian)')
dfhack.run_command('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Civilian')
print('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Pet (Should succeed and change the unit to a pet of side)')
dfhack.run_command('unit/convert -unit '..tostring(unit.id)..' -side '..tostring(side.id)..' -type Pet')
print('unit/convert checks finished')

print('')
print('unit/counter-change checks starting')
-- Get new unit
print('unit/counter-change -help')
dfhack.run_command('unit/counter-change -help')
print('unit/counter-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/counter-change')
print('unit/counter-change -unit '..tostring(unit.id)..' -counter [ nausea dizziness ] -amount 1000 (Should fail and print "Mismatch between number of counters declared and number of changes declared")')
dfhack.run_command('unit/counter-change -unit '..tostring(unit.id)..' -counter [ nausea dizziness ] -amount 1000')
print('unit/counter-change -unit '..tostring(unit.id)..' -counter nausae -amount 1000 (Should fail and print "Invalid counter token declared")')
dfhack.run_command('unit/counter-change -unit '..tostring(unit.id)..' -counter nausae -amount 1000')
print('unit/counter-change -unit '..tostring(unit.id)..' -counter nausea -amount 1000 -mode fixed (Should succeed and incread the nausea counter by 1000)')
dfhack.run_command('unit/counter-change -unit '..tostring(unit.id)..' -counter nausea -amount 1000 -mode fixed')
print('unit/counter-change -unit '..tostring(unit.id)..' -counter [ hunger thirst sleepiness ] -amount 0 -mode set (Should succeed and set hunger_timer, thirst_timer, and sleepiness_timer to 0)')
dfhack.run_command('unit/counter-change -unit '..tostring(unit.id)..' -counter [ hunger thirst sleepiness ] -amount 0 -mode set')
print('unit/counter-change checks finished')

print('')
print('unit/create checks starting')
-- Get new unit
print('unit/create -help')
dfhack.run_command('unit/create -help')
print('unit/create (Should fail and print "No creature declared")')
dfhack.run_command('unit/create')
print('unit/create -creature DWAR:MALE (Should fail and print "Invalid race")')
dfhack.run_command('unit/create -creature DWAR:MALE')
print('unit/create -creature DWARF:MAL (Should fail and print "Invalid caste")')
dfhack.run_command('unit/create -creature DWARF:MAL')
-- Get location
print('unit/create -creature DWARF:MALE -loc [ '..table.unpack(location)..' ] (Should succeed and create a neutral male dwarf at given location)')
dfhack.run_command('unit/create -creature DWARF:MALE -loc [ '..table.unpack(location)..' ]')
print('unit/create -creature DWARF:MALE -reference '..tostring(unit.id)..' -side Civilian -loc [ '..table.unpack(unit.pos)..' ] (Should succeed and create a civilian male dwarf at the reference units location)')
dfhack.run_command('unit/create -creature DWARF:MALE -reference '..tostring(unit.id)..' -side Civilian -loc [ '..table.unpack(unit.pos)..' ]')
print('unit/create -creature DOG:RANDOM -reference '..tostring(unit.id)..' -side Domestic -name Clifford -loc [ '..table.unpack(unit.pos)..' ] (Should succeed and create a domestic dog, male or female, named clifford at the reference units location)')
dfhack.run_command('unit/create -creature DOG:RANDOM -reference '..tostring(unit.id)..' -side Domestic -name Clifford -loc [ '..table.unpack(unit.pos)..' ]')
print('unit/create checks finished')

print('')
print('unit/destroy checks starting')
print('unit/destroy -help')
dfhack.run_command('unit/destroy -help')
print('unit/destroy (Should fail and print "No unit selected")')
dfhack.run_command('unit/destroy')
-- Get clifford
print('unit/destroy -unit '..tostring(unit.id)..' -type Created (Should succeed and remove Clifford the dog and all references formed in the creation)')
dfhack.run_command('unit/destroy -unit '..tostring(unit.id)..' -type Created')
-- Get civilian dwarf
print('unit/destory -unit '..tostring(unit.id)..' -type Kill (Should succeed and kill the civilian dwarf as a normal kill)')
dfhack.run_command('unit/destory -unit '..tostring(unit.id)..' -type Kill')
-- Get netural dwarf
print('unit/destroy -unit '..tostring(unit.id)..' -type Resurrected (Should succeed and kill the netural dwarf as if it were a resurrected unit)')
dfhack.run_command('unit/destroy -unit '..tostring(unit.id)..' -type Resurrected')
print('unit/destroy checks finished')

print('')
print('unit/emotion-change checks starting')
-- Get new unit
print('unit/emotion-change -help')
dfhack.run_command('unit/emotion-change -help')
print('unit/emotion-change (Should fail and print "No unit selected")')
dfhack.run_command()
print('unit/emotion-change -unit '..tostring(unit.id)..' (Should fail and print "Invalid Emotion")')
dfhack.run_command('unit/emotion-change -unit '..tostring(unit.id))
print('unit/emotion-change -unit '..tostring(unit.id)..' -emotion XXXX -thought YYYY (Should fail and print "Invalid Thought")')
dfhack.run_command('unit/emotion-change -unit '..tostring(unit.id)..' -emotion XXXX -thought YYYY')
print('unit/emotion-change -unit '..tostring(unit.id)..' -emotion XXXX (Should succeed and add emotion XXXX with thought WWWW and severity and strength 0 to unit)')
dfhack.run_command('unit/emotion-change -unit '..tostring(unit.id)..' -emotion XXXX')
print('unit/emotion-change -unit '..tostring(unit.id)..' -emotion XXXX -thought ZZZZ -severity 100 -strength 100 -add (Should succeed and add emotion XXXX with thought ZZZZ and severity and strength 100 to unit)')
dfhack.run_command('unit/emotion-change -unit '..tostring(unit.id)..' -emotion XXXX -thought ZZZZ -severity 100 -strength 100 -add')
print('unit/emotion-change -unit '..tostring(unit.id)..' -emotion Negative -remove All (Should succeed and remove all negative emotions from unit)')
dfhack.run_command('unit/emotion-change -unit '..tostring(unit.id)..' -emotion Negative -remove All')
print('unit/emotion-change checks finished')

print('')
print('unit/flag-change checks starting')
-- Get new unit
print('unit/flag-change -help')
dfhack.run_command('unit/flag-change -help')
print('unit/flag-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/flag-change')
print('unit/flag-change -unit '..tostring(unit.id)..' -flag BAD_FLAG (Should fail and print "No valid flag declared")')
dfhack.run_command('unit/flag-change -unit '..tostring(unit.id)..' -flag BAD_FLAG')
print('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden -True (Should succeed and hide unit)')
dfhack.run_command('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden -True')
print('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden -reverse (Should succeed and reveal hidden unit)')
dfhack.run_command('unit/flag-change -unit '..tostring(unit.id)..' -flag hidden -reverse')
print('unit/flag-change checks finished')

print('')
print('unit/move checks starting')
-- Get new unit
print('unit/move -help')
dfhack.run_command('unit/move -help')
print('unit/move (Should fail and print "No unit selected")')
dfhack.run_command('unit/move')
print('unit/move -unit '..tostring(unit.id)..' (Should fail and print "No valid location")')
dfhack.run_command('unit/move -unit '..tostring(unit.id))
print('unit/move -unit '..tostring(unit.id)..' -random [ 5 5 0 ] (Should succeed and move the unit to a random position within a 5x5 square)')
dfhack.run_command('unit/move -unit '..tostring(unit.id)..' -random [ 5 5 0 ]')
print('unit/move -unit '..tostring(unit.id)..' -area Idle (Should succeed and move the unit to its idle position)')
dfhack.run_command('unit/move -unit '..tostring(unit.id)..' -area Idle')
print('unit/move -unit '..tostring(unit.id)..' -building Random (Should succeed and move the unit to a random building on the map)')
dfhack.run_command('unit/move -unit '..tostring(unit.id)..' -building Random')
print('unit/move checks finished')

print('')
print('unit/propel checks starting')
-- Get new unit
print('unit/propel -help')
dfhack.run_command('unit/propel -help')
print('unit/propel (Should fail and print "No target specified")')
dfhack.run_command('unit/propel')
print('unit/propel -unitTarget '..tostring(unit.id)..' -velocity [ 0 0 100 ] -mode Relative (Should fail and print "Relative velocity selected, but no source declared")')
dfhack.run_command('unit/propel -unitTarget '..tostring(unit.id)..' -velocity [ 0 0 100 ] -mode Relative')
print('unit/propel -unitTarget '..tostring(unit.id)..' -velocity [ 0 0 100 ] -mode Fixed (Should succeed and turn the unitTarget into a projectile with velocity 100 in the z direction)')
dfhack.run_command('unit/propel -unitTarget '..tostring(unit.id)..' -velocity [ 0 0 100 ] -mode Fixed')
print('unit/propel checks finished')

print('')
print('unit/resistance-change checks starting')
print('unit/resistance-change -help')
dfhack.run_command('unit/resistance-change -help')
print('unit/resistance-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/resistance-change')
print('unit/resistance-change -unit '..tostring(unit.id)..' -resistance [ FIRE ICE ] -amount 50 (Should fail and print "Mismatch between number of resistances declared and number of changes declared")')
dfhack.run_command('unit/resistance-change -unit '..tostring(unit.id)..' -resistance [ FIRE ICE ] -amount 50')
print('unit/resistance-change -unit '..tostring(unit.id)..' -resistance FIRE -amount 50 -mode fixed (Should succeed and increase units fire resistance by 50, will also create unit persist table since there is no vanilla resistances)')
dfhack.run_command('unit/resistance-change -unit '..tostring(unit.id)..' -resistance FIRE -amount 50 -mode fixed')
print('unit/resistance-change checks finished')

print('')
print('unit/skill-change checks starting')
print('unit/skill-change -help')
dfhack.run_command('unit/skill-change -help')
print('unit/skill-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/skill-change')
print('unit/skill-change -unit '..tostring(unit.id)..' -skill [ DODGER ARMOR_USER ] -amount 50 (Should fail and print "Mismatch between number of skills declared and number of changes declared")')
dfhack.run_command('unit/skill-change -unit '..tostring(unit.id)..' -skill [ DODGER ARMOR_USER ] -amount 50')
print('unit/skill-change -unit '..tostring(unit.id)..' -skill DOGDER -amount 50 (Should fail and print "Invalid skill token")')
dfhack.run_command('unit/skill-change -unit '..tostring(unit.id)..' -skill DOGDER -amount 50')
print('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGER -amount 5 -mode Fixed (Should succeed and increase units dodging skill by 5 levels)')
dfhack.run_command('unit/skill-change -unit '..tostring(unit.id)..' -skill DODGER -amount 5 -mode Fixed')
print('unit/skill-change -unit '..tostring(unit.id)..' -skill ARMOR_USER -amount 200 -mode Percent -track (Should succeed and double units armor skill, will also create unit persist table)')
dfhack.run_command('unit/skill-change -unit '..tostring(unit.id)..' -skill ARMOR_USER -amount 200 -mode Percent -track')
print('unit/skill-change -unit '..tostring(unit.id)..' -skill MINING -amount 500 -mode Experience (Should succeed and add 500 experience to the units mining skill)')
dfhack.run_command('unit/skill-change -unit '..tostring(unit.id)..' -skill MINING -amount 500 -mode Experience')
print('unit/skill-change checks finished')

print('')
print('unit/stat-change checks starting')
print('unit/stat-change -help')
dfhack.run_command('unit/stat-change -help')
print('unit/stat-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/stat-change')
print('unit/stat-change -unit '..tostring(unit.id)..' -stat [ MAGICAL_HIT_CHANCE PHYSICAL_HIT_CHANCE ] -amount 50 (Should fail and print "Mismatch between number of stats declared and number of changes declared")')
dfhack.run_command('unit/stat-change -unit '..tostring(unit.id)..' -stat [ MAGICAL_HIT_CHANCE PHYSICAL_HIT_CHANCE ] -amount 50')
print('unit/stat-change -unit '..tostring(unit.id)..' -stat MAGICAL_HIT_CHANCE -amount 50 -mode fixed (Should succeed and increase units magical hit chance by 50, will also create unit persist table since there is no vanilla stats)')
dfhack.run_command('unit/stat-change -unit '..tostring(unit.id)..' -stat MAGICAL_HIT_CHANCE -amount 50 -mode fixed')
print('unit/stat-change checks finished')

print('')
print('unit/syndrome-change checks starting')
print('unit/syndrome-change -help')
dfhack.run_command('unit/syndrome-change -help')
print('unit/syndrome-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/syndrome-change')
print('unit/syndrome-change -unit '..tostring(unit.id)..' (Should fail and print "Neither syndrome name(s) or class(es) declared")')
dfhack.run_command('unit/syndrome-change -unit '..tostring(unit.id))
print('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 (Should fail and print "No method declared (methods are add, erase, terminate, and alterDuration)")')
dfhack.run_command('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1')
print('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -add (Should succeed and add TEST_SYNDROME_1 to the unit)')
dfhack.run_command('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -add')
print('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -alterDuration 500 (Should succeed and add 500 ticks to TEST_SYNDROME_1 on the unit)')
dfhack.run_command('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_1 -alterDuration 500')
print('unit/syndrome-change -unit '..tostring(unit.id)..' -class TEST_SYNDROME_CLASS -erase (Should succeed and remove all syndromes with a TEST_SYNDROME_CLASS class from unit)')
dfhack.run_command('unit/syndrome-change -unit '..tostring(unit.id)..' -class TEST_SYNDROME_CLASS -erase')
print('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_2 -add -dur 50 (Should succeed and add TEST_SYNDROME_2 to the unit for 50 ticks)')
dfhack.run_command('unit/syndrome-change -unit '..tostring(unit.id)..' -syndrome TEST_SYNDROME_2 -add -dur 50')
print('unit/syndrome-change checks finished')

print('')
print('unit/trait-change checks starting')
print('unit/trait-change -help')
dfhack.run_command('unit/trait-change -help')
print('unit/trait-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/trait-change')
print('unit/trait-change -unit '..tostring(unit.id)..' -trait [ ANGER DEPRESSION ] -amount 50 (Should fail and print "Mismatch between number of traits declared and number of changes declared")')
dfhack.run_command('unit/trait-change -unit '..tostring(unit.id)..' -trait [ ANGER DEPRESSION ] -amount 50')
print('unit/trait-change -unit '..tostring(unit.id)..' -trait ANGR -amount 50 (Should fail and print "Invalid trait token")')
dfhack.run_command('unit/trait-change -unit '..tostring(unit.id)..' -trait ANGR -amount 50')
print('unit/trait-change -unit '..tostring(unit.id)..' -trait ANGER -amount \-5 -mode Fixed (Should succeed and lower units anger trait by 5)')
dfhack.run_command('unit/trait-change -unit '..tostring(unit.id)..' -trait ANGER -amount \-5 -mode Fixed')
print('unit/trait-change -unit '..tostring(unit.id)..' -trait DEPRESSION -amount 25 -mode Percent -track (Should succeed and quarter units depression trait, will also create unit persist table)')
dfhack.run_command('unit/trait-change -unit '..tostring(unit.id)..' -trait DEPRESSION -amount 25 -mode Percent -track')
print('unit/trait-change checks finished')

print('')
print('unit/transform checks starting')
print('unit/transform -help')
dfhack.run_command('unit/transform -help')
print('unit/transform (Should fail and print "No unit selected")')
dfhack.run_command('unit/transform')
print('unit/transform -unit '..tostring(unit.id)..' (Should fail and print "No creature declared")')
dfhack.run_command('unit/transform -unit '..tostring(unit.id))
print('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:MALE (Should fail and print "Unit already the desired creature")')
dfhack.run_command('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:MALE')
print('unit/transform -unit '..tostring(unit.id)..' -creature ELF:MALE (Should succeed and change the unit to a male elf)')
dfhack.run_command('unit/transform -unit '..tostring(unit.id)..' -creature ELF:MALE')
print('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:FEMALE -dur 50 -track (Should succeed and change the unit to a female dwarf for 50 ticks and create a unit persist table)')
dfhack.run_command('unit/transform -unit '..tostring(unit.id)..' -creature DWARF:FEMALE -dur 50 -track')
print('unit/transform checks finished')

print('')
print('unit/wound-change checks starting')
print('unit/wound-change -help')
dfhack.run_command('unit/wound-change -help')
print('unit/wound-change (Should fail and print "No unit selected")')
dfhack.run_command('unit/wound-change')
print('unit/wound-change -unit '..tostring(unit.id)..' -remove 1 -recent (Should succeed and remove the most recent wounds)')
dfhack.run_command('unit/wound-change -unit '..tostring(unit.id)..' -remove 1 -recent')
print('unit/wound-change -unit '..tostring(unit.id)..' -remove All -regrow (Should succeed and remove all wounds and return any lost limbs)')
dfhack.run_command('unit/wound-change -unit '..tostring(unit.id)..' -remove All -regrow')
print('unit/wound-change -unit '..tostring(unit.id)..' -resurrect -fitForResurrect -regrow (Should fail and print "No corpse parts found for resurrection/animation")')
dfhack.run_command('unit/wound-change -unit '..tostring(unit.id)..' -resurrect -fitForResurrect -regrow')
print('Killing unit')
dfhack.run_command('unit/counter-change -unit '..tostring(unit.id)..' -counter blood -amount 0 -mode set')
print('unit/wound-change -unit '..tostring(unit.id)..' -resurrect (Should succeed and bring unit back to life)')
dfhack.run_command('unit/wound-change -unit '..tostring(unit.id)..' -resurrect')
print('Killing and Butcher unit')
dfhack.run_command('unit/butcher -unit '..tostring(unit.id)..' -kill')
print('unit/wound-change -unit '..tostring(unit.id)..' -animate (Should succeed and bring all corpse parts back as zombies)')
dfhack.run_command('unit/wound-change -unit '..tostring(unit.id)..' -animate')
print('unit/wound-change checks finished')

print('')
print('Wrapper script check')

print("Roses' Systems and Scripts finished testing")
print('Printing error list')
print('Class System')
printall(classCheck)
print('')
print('Civilization System')
printall(civCheck)
print('')
print('Enhanced System')
printall(enhCheck)
print('')
print('Event System')
printall(eventCheck)
print('')
print('Base Scripts')
printall(baseCheck)
print('')
print('All Scripts')
printall(scriptCheck)
print('')

-- These checks are for external scripts (scripts not included in the Roses Collection)
--[[
print('Now starting external script checks')
dir = dfhack.getDFPath()
print('The following checks will attempt to run every script included in the hacks/scripts folder and the raw/scripts folder')
print('If there are no -testRun options included in the script, the check will simply run the script with no arguments (almost assuredly causing an error of some sort)')
print('Looking in hack/scripts')
path = dir..'/hack/scripts/'
for _,fname in pairs(dfhack.internal.getDir(path)) do
end
print('raw/scripts')
path = dir..'/raw/scripts/'
for _,fname in pairs(dfhack.internal.getDir(path)) do
end
]]
