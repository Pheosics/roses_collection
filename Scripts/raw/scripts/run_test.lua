print('Running base/roses-init with all options enabled')
local classCheck = ' -classSystem [ Feats Spells ]'
local civCheck = ' -civilizationSystem [ Diplomacy ]'
local eventCheck = ' -eventSystem'
local enhCheck = ' -enhancedSystem [ Creatures Items Materials Buildings ]'
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
print('Set up call back to check Entity details')
dfhack.timeout(4000,'ticks',function ()
                             print('Entity details')
                             printall(entityTable)
                             printall(entityTable.Civilization)
                             printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_races)
                             printall(df.global.world.entities.all[unit.civ_id].resources.animals.mount_castes)
                            end)
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
 if #resources >= 1 then civCheck['TV2_L2_'..xcheck] = 'Test Civilization 2 level 1 '..table.unpack(aCheck)..' not correctly added to' end
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
print('Enhanced Item checks need to be performed manually')
print('Have a dwarf equip and unequip a pick and a hand axe')
print('Easiest way to do this is to assign and unassign the Mining and Woodcutting professions')
print('When the pick is equipped the units Axe skill should increase to legendary')
print('When the hand axe is equipped the unit should learn the Test Spell 1 spell')
print('Both effects should revert when the item is unequipped')
base = 'modtools/item-trigger -itemType ITEM_WEAPON_PICK -onEquip -command'
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -equip ]')
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID -equip ]')
base = 'modtools/item-trigger -itemType ITEM_WEAPON_PICK -onUnequip -command'
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID ]')
dfhack.run_command(base..' [ enhanced/item-equip -unit \\UNIT_ID -item \\ITEM_ID ]')
print('Enhanced System - Items check finished')

print('**Enhanced System - Materials not currently functioning')

print('Enhanced System checks finished')

print('')
print('Event System checks:')
print('Forcing Test Event 2 to trigger, both effects should fail')
dfhack.run_command('events/trigger -event TEST_EVENT_2 -force -verbose')
print('Test Event 1 should occur within 1 in-game day, if successful a random location and random unit id will be printed')
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

print('Building script checks')
print('building/subtype-change')

print('Flow script checks')
print('flow/random-plan')
print('flow/random-pos')
print('flow/random-surface')
print('flow/source')

print('Item script checks')
print('item/create')
print('item/material-change')
print('item/projectile')
print('item/quality-change')
print('item/subtype-change')

print('Tile script checks')
print('tile/material-change')
print('tile/temperature-change')

print('Unit script checks')
print('unit/action-change')
print('unit/attack')
print('unit/attribute-change')
print('unit/body-change')
print('unit/butcher')
print('unit/convert')
print('unit/counter-change')
print('unit/create')
print('unit/destroy')
print('unit/emotion-change')
print('unit/flag-change')
print('unit/move')
print('unit/propel')
print('unit/resistance-change')
print('unit/skill-change')
print('unit/syndrome-change')
print('unit/trait-change')
print('unit/transform')
print('unit/wound-change')

print('Wrapper script check')
