print('Running base/roses-init with all options enabled')
local classCheck = ' -classSystem [ Feats Spells ]'
local civCheck = ' -civilizationSystem [ Diplomacy ]'
local eventCheck = ' -eventSystem'
local enhCheck = ' -enhancedSystem [ Creatures Items Materials Buildings ]'
local verbose = true
print('base/roses-init'..classCheck..civCheck..eventCheck..enhCheck..' -verbose')
dfhack.run_command('base/roses-init'..classCheck..civCheck..eventCheck..enhCheck..' -verbose')

local persistTable = require 'persist-table'
local roses = persistTable.GlobalTable.roses

print('')
print('Generating test cases for each System')

print('Class System:')
local classTable = roses.ClassTable
print('--Test Class 1')
classTable.TEST_CLASS_1 = {}
local class = classTable.TEST_CLASS_1
class.Name = 'Test Class 1'
class.Levels = '3'
class.AutoUpgrade = 'TEST_CLASS_2'
class.Experience = {}
class.Experience['1'] = '1'
class.Experience['2'] = '2'
class.Experience['3'] = '3'
class.RequiredAttribute = {}
class.RequiredAttribute.STRENGTH = '500'
class.LevelBonus = {}
class.LevelBonus.Skill = {}
class.LevelBonus.Skill.MINING = {}
class.LevelBonus.Skill.MINING['1'] = '1'
class.LevelBonus.Skill.MINING['2'] = '4'
class.LevelBonus.Skill.MINING['3'] = '9'
class.BonusSkill = {}
class.BonusSkill.WOODCUTTING = {}
class.BonusSkill.WOODCUTTING['1'] = '1'
class.BonusSkill.WOODCUTTING['2'] = '4'
class.BonusSkill.WOODCUTTING['3'] = '9'
class.Spells = {}
class.Spells.TEST_SPELL_1 = {}
class.Spells.TEST_SPELL_1.RequiredLevel = '1'
class.Spells.TEST_SPELL_1.AutoLearn = 'true'
class.Spells.TEST_SPELL_2 = {}
class.Spells.TEST_SPELL_2.RequiredLevel = '2'
printall(class)
print('--Test Class 2')
classTable.TEST_CLASS_2 = {}
class = classTable.TEST_CLASS_2
class.Name = 'Test Class 2'
class.Levels = '1'
class.Experience = {}
class.Experience['1'] = '1'
class.LevelBonus = {}
class.LevelBonus.Skill = {}
class.LevelBonus.Skill.CARPENTRY = {}
class.LevelBonus.Skill.CARPENTRY['1'] = '15'
class.BonusSkill = {}
class.BonusSkill.MASONRY = {}
class.BonusSkill.MASONRY['1'] = '15'
class.Spells = {}
class.Spells.TEST_SPELL_3 = {}
class.Spells.TEST_SPELL_3.RequiredLevel = '1'
class.Spells.TEST_SPELL_3.AutoLearn = 'true'
printall(class)

print('')
print('Class System - Feat SubSystem:')
local featTable = roses.FeatTable
print('--Test Feat 1')
featTable.TEST_FEAT_1 = {}
local feat = featTable.TEST_FEAT_1
feat.Name = 'Test Feat 1'
feat.Description = 'This is a testing feat, checks REQUIRED_CLASS and COST'
feat.RequiredClass = {}
feat.RequiredClass.TEST_CLASS_1 = '2'
feat.Cost = '1'
feat.Effect = {}
feat.Effect['0'] = 'devel/printargs UNIT_ID'
printall(feat)
print('--Test Feat 2')
featTable.TEST_FEAT_2 = {}
feat = featTable.TEST_FEAT_2
feat.Name = 'Test Feat 2'
feat.Description = 'This is a testing feat, checks REQUIRED_FEAT and no COST'
feat.RequiredFeat = {}
feat.RequiredFeat.TEST_FEAT_1 = 'TEST_FEAT_1'
feat.Cost = '0'
feat.Effect = {}
feat.Effect['0'] = 'devel/printargs UNIT_ID'
printall(feat)

print('')
print('Class System - Spell SubSystem:')
local spellTable = roses.SpellTable
print('--Test Spell 1')
spellTable.TEST_SPELL_1 = {}
local spell = spellTable.TEST_SPELL_1
spell.Name = 'Test Spell 1'
spell.Description = 'This is a testing spell, checks auto learning from Class, EXP_GAIN, CAST_TIME, and EXHAUSTION'
spell.ExperienceGain = '1'
spell.CastTime = '10'
spell.Exhaustion = '10000'
printall(spell)
print('--Test Spell 2')
spellTable.TEST_SPELL_2 = {}
spell = spellTable.TEST_SPELL_2
spell.Name = 'Test Spell 2'
spell.Description = 'This is a testing spell, checks COST, RESISTABLE, and TSSDS')
spell.Type = 'MAGICAL'
spell.Sphere = 'ELEMENTAL'
spell.School = 'FIRE'
spell.Discipline = 'CONJURATION'
spell.SubDiscipline = 'MISSILE'
spell.Resistable = 'true'
spell.Cost = '2'
printall(spell)
print('--Test Spell 3')
spellTable.TEST_SPELL_3 = {}
spell = spellTable.TEST_SPELL_3
spell.Name = 'Test Spell 3'
spell.Description = 'This is a testing spell, checks UPGRADE, SOURCE_PRIMARY_ATTRIBUTES, and REQUIREMENT_ATTRIBUTE'
spell.SourcePrimaryAttribute = {]
spell.SourcePrimaryAttribute['1'] = 'TOUGHNESS'
spell.SourcePrimaryAttribute['2'] = 'ENDURANCE'
spell.Upgrade = 'TEST_SPELL_1'
spell.RequirementAttribute = {}
spell.RequirementAttribute.STRENGTH = '750'
printall(spell)
print('Done generating test Class System entries')

print('')
print('Civilization System:')
local civTable = roses.CivilizationTable
print('--Test Dwarf Civ')
civTable.MOUNTAIN = {}
local civ = civTable.MOUNTAIN
civ.Name = 'Test Dwarf (MOUNTAIN) Civ'
civ.Description = 'This is a testing civ, checks LEVEL_METHOD, LEVEL_REMOVE:CREATURE, and LEVEL_ADD:CREATURE'
civ.Levels = '2'
civ.LevelMethod = 'WEEKLY'
civ.LevelPercent = '100'
civ.Level = {}
civ.Level['0'] = {}
local level = civ.Level['0']
level.Name = '0th Level for Test Dwarf Civ'
level.Remove = {}
level.Remove.Creature = {}
level.Remove.Creature.Mount = {}
level.Remove.Creature.Mount.All = 'All'
civ.Level['1'] = {}
level = civ.Level['1']
level.Name = '1st Level for Test Dwarf Civ'
level.Add = {}
level.Add.Creature = {}
level.Add.Creature.Mount = {}
level.Add.Creature.Mount.DRAGON = 'All'
level.LevelMethod = 'DAILY'
level.LevelPercent = '100'
civ.Level['2'] = {}
level = civ.Level['2']
level.Name = '2nd Level for Test Dwarf Civ'
level.Add = {}
level.Add.Creature = {}
level.Add.Creature.Mount = {}
level.Add.Creature.Mount.HUMAN = 'All'
printall(civ)
print('--Test Elf Civ')
civTable.FOREST = {}
civ = civTable.FOREST
local civ = civTable.MOUNTAIN
civ.Name = 'Test Elf (FOREST) Civ'
civ.Description = 'This is a testing civ, checks LEVEL_REQUIREMENT'
civ.Levels = '1'
civ.LevelMethod = 'DAILY'
civ.LevelPercent = '100'
civ.Level = {}
civ.Level['1'] = {}
level = civ.Level['1']
level.Required = {}
level.Required.Time = '6000'
printall(civ)
print('Done generating test Civilization System entries (no entries to generate for the Diplomacy SubSystem)')

print('')
print('Event System:')
local eventTable = roses.EventTable
print('--Test Event 1')
eventTable.TEST_EVENT_1 = {}
local event = eventTable.TEST_EVENT_1
event.Name = 'Test Event 1'
event.Description = 'This is a testing event, checks CHECK, CHANCE, and multiple EFFECTS'
event.Check = 'DAILY'
event.Chance = '100'
event.Effect = {}
event.Effect['1'] = {}
event.Effect['1'].Name = 'Test Event 1 - Test Effect 1'
event.Effect['1'].Location = {}
event.Effect['1'].Location['1'] = 'RANDOM'
event.Effect['1'].Location['2'] = 'SURFACE'
event.Effect['1'].Script = {}
event.Effect['1'].Scirpt['1'] = 'devel/print-args EFFECT_LOCATION'
event.Effect['2'] = {}
event.Effect['2'].Name = 'Test Event 1 - Test Effect 2'
event.Effect['2'].Unit = {}
event.Effect['2'].Unit['1'] = 'RANDOM'
event.Effect['2'].Script = {}
event.Effect['2'].Scirpt['1'] = 'devel/print-args EFFECT_UNIT'
printall(event)
print('--Test Event 2')
eventTable.TEST_EVENT_2 = {}
event = eventTable.TEST_EVENT_2
event.Name = 'Test Event 1'
event.Description = 'This is a testing event, checks EFFECT_REQUIREMENT and EFFECT_CONTINGENT_ON'
event.Check = 'YEARLY'
event.Chance = '100'
event.Effect = {}
event.Effect['1'] = {}
event.Effect['1'].Name = 'Test Event 2 - Test Effect 1'
event.Effect['1'].Required = {}
event.Effect['1'].Required.TreeCut = '1000'
event.Effect['1'].Location = {}
event.Effect['1'].Location['1'] = 'RANDOM'
event.Effect['1'].Location['2'] = 'SURFACE'
event.Effect['1'].Script = {}
event.Effect['1'].Scirpt['1'] = 'devel/print-args EFFECT_LOCATION'
event.Effect['2'] = {}
event.Effect['2'].Name = 'Test Event 2 - Test Effect 2'
event.Effect['2'].Contingent = '1'
event.Effect['2'].Unit = {}
event.Effect['2'].Unit['1'] = 'RANDOM'
event.Effect['2'].Script = {}
event.Effect['2'].Scirpt['1'] = 'devel/print-args EFFECT_UNIT'
printall(event)
print('Done generating test Event System entries')

print('')
print('Enhanced System:')

print('*Enhanced System - Buldings not currently operational')

print('')
print('Enhanced System - Creatures:')
local ECTable = roses.EnhancedCreatureTable
print('--Test Enhanced Creature 1')
ECTable.DWARF = {}
ECTable.DWARF.Name = 'Test Enhanced Creature 1 (DWARF)'
ECTable.DWARF.Description = 'This is a test enhanced creature, checks ATTRIBUTE and SKILL'
ECTable.DWARF.Attributes = {}
ECTable.DWARF.Attributes.AGILITY = {}
ECTable.DWARF.Attributes.AGILITY['1'] = '5000'
ECTable.DWARF.Attributes.AGILITY['2'] = '5500'
ECTable.DWARF.Attributes.AGILITY['3'] = '6000'
ECTable.DWARF.Attributes.AGILITY['4'] = '6500'
ECTable.DWARF.Attributes.AGILITY['5'] = '7000'
ECTable.DWARF.Attributes.AGILITY['6'] = '7500'
ECTable.DWARF.Attributes.AGILITY['7'] = '8000'
ECTable.DWARF.Skills = {}
ECTable.DWARF.Skills.GROWER = {}
ECTable.DWARF.Skills.GROWER.Min = '5'
ECTable.DWARF.Skills.GROWER.Max = '15'
printall(ECTable.DWARF)

print('')
print('Enhanced System - Items:')
local EITable = roses.EnhancedItemTable
print('--Test Enhanced Item 1')
EITable.ITEM_WEAPON_PICK = {}
local item = EITable.ITEM_WEAPON_PICK
item.Name = 'Test Enhanced Item 1 (ITEM_WEAPON_PICK)'
item.Description = 'This is a test enhanced item, checks ON_EQUIP ATTRIBUTE_CHANGE'
item.OnEquip = {}
item.OnEquip.Skills = {}
item.OnEquip.Skills.AXE = '15'
printall(item)
print('--Test Enhanced Item 2')
EITable.ITEM_WEAPON_HANDAXE = {}
local item = EITable.ITEM_WEAPON_HANDAXE
item.Name = 'Test Enhanced Item 2 (ITEM_WEAPON_HANDAXE)'
item.Description = 'This is a test enhanced item, checks ON_EQUIP INTERACTION_ADD'
item.OnEquip = {}
item.OnEquip.Interactions = {}
item.OnEquip.Interactions['1'] = 'TEST_SPELL_1'
printall(item)

print('')
print('*Enhanced System - Materials not currently operational')

print('Done generating test Enhanced System entries')

print('')
print('Done generating all System entries')

print('Beginning System Checks')

print('')
print('Class System Checks:')
print('Finding Unit')
for _,unit in pairs(df.global.world.creatures.active) do
 if dfhack.units.isDwarf(unit) then
  break
 end
end
print('Dwarf found, ID: '..tostring(unit.id)..' Name: '..dfhack.units.getName(unit))
print('Creating Unit Table')
dfhack.script_environment('functions/tables').makeUnitTable(unit)
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
print('Adding experience to unit - Will level up Test Class 1 to level 1 and assign Test Spell 1')
print('Mining and Woodcutting skill will increase')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
print('Adding experience to unit - Will level up Test Class 1 to level 2')
print('Mining and Woodcutting skill will increase')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
print('Assigning Test Spell 2 to unit')
dfhack.run_command('classes/learn-skill -unit '..tostring(unit.id)..' -spell TEST_SPELL_2 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
print('Adding experience to unit - Will level up Test Class 1 to level 3 and auto change class to Test Class 2')
print('Mining skill will increase, Woodcutting skill will reset')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
print('Adding experience to unit - Will level up Test Class 2 to level 1 and replace Test Spell 1 with Test Spell 3')
print('Mining skill will remain the same, Carpentry skill will increase')
dfhack.run_command('classes/add-experience -unit '..tostring(unit.id)..' -amount 1 -verbose')
print('Class/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.TEST_CLASS_1)
printall(unitTable.Classes.TEST_CLASS_2)
printall(unitTable.Spells)
printall(unitTable.Skills)
print('Base Class System checks and Spell assignment checks finished. Starting Feat SubSystem checks')

print('Feat/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
print('Attempting to assign Test Feat 2 to unit, this should fail')
dfhack.run_command('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_2 -verbose')
print('Feat/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
print('Attempting to assign Test Feat 1 to unit, this should work')
dfhack.run_command('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_1 -verbose')
print('Feat/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
print('Attempting to assign Test Feat 2 to unit, now this should work')
dfhack.run_command('classes/add-feat -unit '..tostring(unit.id)..' -feat TEST_FEAT_2 -verbose')
print('Feat/Unit details:')
printall(unitTable.Classes.Current)
printall(unitTable.Classes.Feats)
print('Feat SubSystem checks finished. Spell SubSystem checks will be made later')

print('')
print('Civilization System Checks:')
print('Creating Entity Table for unit.civ_id')
dfhack.script_environment('functions/tables').makeEntityTable(unit.civ_id)
entityTable = roses.EntityTable[tostring(unit.civ_id)]
print('Entity details')
printall(df.global.world.entities[unit.civ_id].resources.animals.mount_races)
printall(df.global.world.entities[unit.civ_id].resources.animals.mount_castes)
print('Assigning Civlization to Entity, should clear available mounts')
print('Entity details')
printall(entityTable)
printall(entityTable.Civilization)
printall(df.global.world.entities[unit.civ_id].resources.animals.mount_races)
printall(df.global.world.entities[unit.civ_id].resources.animals.mount_castes)
print('Force level increase, should add dragons to available mounts and change level method')
dfhack.run_command('civilizations/level-up -civ '..tostring(unit.civ_id)..' -amount 1 -verbose')
print('Entity details')
printall(entityTable)
printall(entityTable.Civilization)
printall(df.global.world.entities[unit.civ_id].resources.animals.mount_races)
printall(df.global.world.entities[unit.civ_id].resources.animals.mount_castes)
print('Next level increase should occur within 1 in-game day, will add humans as available mounts')
print('Set up call back to check Entity details')
dfhack.timeout(4000,'ticks',function ()
                             print('Entity details')
                             printall(entityTable)
                             printall(entityTable.Civilization)
                             printall(df.global.world.entities[unit.civ_id].resources.animals.mount_races)
                             printall(df.global.world.entities[unit.civ_id].resources.animals.mount_castes)
                            end)
print('Civilization System checks finished')

print('')
print('Event System checks:')
print('Forcing Test Event 2 to trigger, both effects should fail')
dfhack.run_command('events/trigger -event TEST_EVENT_2 -force')
print('Test Event 1 should occur within 1 in-game day, if successful a random location and random unit id will be printed')
print('Event Systen checks finished')

print('')
print('Enhanced System checks:')

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

dfhack.run_command('base/on-time')
print('System checks finished, starting script checks')

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
