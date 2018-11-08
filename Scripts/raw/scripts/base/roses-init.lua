-- base/roses-init.lua v1.0 | DFHack 43.05
--MUST BE LOADED IN ONLOAD.INIT

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

validArgs = utils.invert({
 'help',
 'all',
 'classSystem',
 'civilizationSystem',
 'enhancedSystem',
 'eventSystem',
 'forceReload',
 'testRun',
 'verbose',
 'clear',
})
local args = utils.processArgs({...}, validArgs)

if args.clear then
 persistTable.GlobalTable.roses = {}
 return
end
if args.testRun then args.forceReload = true end
verbose = args.verbose

persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
roses = persistTable.GlobalTable.roses

-- System Tables (Populated by files read into the game)
roses.Systems = roses.Systems or {}
---- CLASS SYSTEM
roses.ClassTable = roses.ClassTable or {}
roses.FeatTable  = roses.FeatTable  or {}
roses.SpellTable = roses.SpellTable or {}
---- CIVILIZATION SYSTEM
roses.CivilizationTable = roses.CivilizationTable or {}
roses.CivilizationTable.Loaded
roses.DiplomacyTable    = roses.DiplomacyTable    or {}
---- ENHANCED SYSTEM
roses.EnhancedItemTable     = roses.EnhancedItemTable     or {}
roses.EnhancedMaterialTable = roses.EnhancedMaterialTable or {}
roses.EnhancedCreatureTable = roses.EnhancedCreatureTable or {}
roses.EnhancedBuildingTable = roses.EnhancedBuildingTable or {}
roses.EnhancedReactionTable = roses.EnhancedReactionTable or {}
---- EVENT SYSTEM
roses.EventTable = roses.EventTable or {}

-- Game Tables (Populated by units/items/buildings/entities in game)
roses.UnitTable     = roses.UnitTable     or {}
roses.ItemTable     = roses.ItemTable     or {}
roses.BuildingTable = roses.BuildingTable or {}
roses.EntityTable   = roses.EntityTable   or {}

-- Misc Tables (Populated by miscellanious things in game and scripts)
roses.CommandDelay     = roses.CommandDelay     or {}
roses.EnvironmentDelay = roses.EnvironmentDelay or {}
roses.CounterTable     = roses.CounterTable     or {}
roses.LiquidTable      = roses.LiquidTable      or {}
roses.FlowTable        = roses.FlowTable        or {}

dfhack.script_environment('functions/tables').makeBaseTable(args.testRun,args.verbose)

--==========================================================================================================================
--= MAKE CLASS SYSTEM 
if args.all or args.classSystem then
 print('Initializing the Class System')
 if args.forceReload then
  roses.ClassTable = {}, roses.Systems.Class = 'false'
  roses.FeatTable = {}, roses.Systems.Feat = 'false'
  roses.SpellTable = {}, roses.Systems.Spell = 'false'
 end

 if not roses.Systems.Class or roses.Systems.Class == 'false' then
  dfhack.script_environment('functions/class').makeClassTable(args.testRun)
 end

 if not roses.Systems.Feat or roses.Systems.Feat == 'false' then
  dfhack.script_environment('functions/class').makeFeatTable(args.testRun)
 end

 if not roses.Systems.Spell or roses.Systems.Spell == 'false' then
  dfhack.script_environment('functions/class').makeSpellTable(args.testRun)
 end
 
 if roses.Systems.Class == 'true' then
  print('Class System successfully loaded')
  print('Number of Classes: '..tostring(#persistTable.GlobalTable.roses.ClassTable._children))
  if verbose then
   print('Classes:')
   for _,n in pairs(persistTable.GlobalTable.roses.ClassTable._children) do
    print(persistTable.GlobalTable.roses.ClassTable[n])
   end
  end

  if roses.Systems.Spell == 'true' then
   print('Spell SubSystem loaded')
   print('Number of Spells: '..tostring(#persistTable.GlobalTable.roses.SpellTable._children))
   if verbose then
    print('Spells:')
    for _,n in pairs(persistTable.GlobalTable.roses.SpellTable._children) do
     print(persistTable.GlobalTable.roses.SpellTable[n])
    end
   end
  else
   print('Spell SubSystem not loaded')
  end

  if roses.Systems.Feat == 'true' then
   print('Feat SubSystem loaded')
   print('Number of Feats: '..tostring(#persistTable.GlobalTable.roses.FeatTable._children))
   if verbose then
    print('Feats:')
    for _,n in pairs(persistTable.GlobalTable.roses.FeatTable._children) do
     print(persistTable.GlobalTable.roses.FeatTable[n])
    end
   end
  else
   print('Feat SubSystem not loaded')
  end

 else
  print('Class System not loaded')
 end
end
--==========================================================================================================================

--==========================================================================================================================
--= MAKE CIVILIZATION SYSTEM
if args.all or args.civilizationSystem then
 print('Initializing the Civilization System')
 if args.forceReload then
  roses.CivilizationTable = {}, roses.Systems.Civilization == 'false'
 end

 if not roses.Systems.Civilization or roses.Systems.Civilization == 'false' then
  dfhack.script_environment('functions/civilization').makeCivilizationTable(args.testRun)
 end

 if roses.Systems.Civilization == 'true'  then
  print('Civilization System successfully loaded')
  print('Number of Civilizations: '..tostring(#persistTable.GlobalTable.roses.CivilizationTable._children))
  if verbose then
   print('Civilizations:')
   for _,n in pairs(persistTable.GlobalTable.roses.CivilizationTable._children) do
    print(persistTable.GlobalTable.roses.CivilizationTable[n])
   end
  end  

 else
  print('Civilization System not loaded')
 end
end
--==========================================================================================================================

--==========================================================================================================================
--= MAKE ENHANCED SYSTEM
if args.all or args.enhancedSystem then
 print('Initializing the Enhanced System')
 if args.forceReload then
  roses.EnhancedItemTable     =  {}, roses.Systems.EnhancedItem = 'false'
  roses.EnhancedMaterialTable =  {}, roses.Systems.EnhancedMaterial = 'false'
  roses.EnhancedCreatureTable =  {}, roses.Systems.EnhancedCreature = 'false'
  roses.EnhancedBuildingTable =  {}, roses.Systems.EnhancedBuilding = 'false'
  roses.EnhancedReactionTable =  {}, roses.Systems.EnhancedReaction = 'false'
 end

 if not roses.Systems.EnhancedItem or roses.Systems.EnhancedItem == 'false' then
  dfhack.script_environment('functions/enhanced').makeEnhancedItemTable(args.testRun)
 end

 if not roses.Systems.EnhancedMaterial or roses.Systems.EnhancedMaterial == 'false' then
  dfhack.script_environment('functions/enhanced').makeEnhancedMaterialTable(args.testRun)
 end

 if not roses.Systems.EnhancedCreature or roses.Systems.EnhancedCreature == 'false' then
  dfhack.script_environment('functions/enhanced').makeEnhancedCreatureTable(args.testRun)
 end

 if not roses.Systems.EnhancedBuilding or roses.Systems.EnhancedBuilding == 'false' then
  dfhack.script_environment('functions/enhanced').makeEnhancedBuildingTable(args.testRun)
 end

 if not roses.Systems.EnhancedReaction or roses.Systems.EnhancedReaction == 'false' then
  dfhack.script_environment('functions/enhanced').makeEnhancedReactionTable(args.testRun)
 end

 if roses.Systems.EnhancedBuilding == 'true' then
  print('Enhanced System - Buildings successfully loaded')
  print('Number of Enhanced Buildings: '..tostring(#persistTable.GlobalTable.roses.EnhancedBuildingTable._children))
  if verbose then
   print('Enhanced Buildings:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedBuildingTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedBuildingTable[n])
   end
  end
 else
  print('Enhanced System - Buildings not loaded')
 end

 if roses.Systems.EnhancedCreature == 'true'  then
  print('Enhanced System - Creatures successfully loaded')
  print('Number of Enhanced Creatures: '..tostring(#persistTable.GlobalTable.roses.EnhancedCreatureTable._children))
  if verbose then
   print('Enhanced Creatures:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedCreatureTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedCreatureTable[n])
   end
  end
 else
  print('Enhanced System - Creatures not loaded')
 end

 if roses.Systems.EnhancedItem == 'true'  then
  print('Enhanced System - Items successfully loaded')
  print('Number of Enhanced Items: '..tostring(#persistTable.GlobalTable.roses.EnhancedItemTable._children))
  if verbose then
   print('Enhanced Items:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedItemTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedItemTable[n])
   end
  end
 else
  print('Enhanced System - Items not loaded')
 end

 if roses.Systems.EnhancedMaterial == 'true'  then
  print('Enhanced System - Materials successfully loaded')
  print('Number of Enhanced Materials: '..tostring(#persistTable.GlobalTable.roses.EnhancedMaterialTable._children))
  if verbose then
   print('Enhanced Materials:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedMaterialTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedMaterialTable[n])
   end
  end
 else
  print('Enhanced System - Materials not loaded')
 end

 if roses.Systems.EnhancedReaction == 'true' then
  print('Enhanced System - Reaction successfully loaded')
  print('Number of Enhanced Reactions: '..tostring(#persistTable.GlobalTable.roses.EnhancedReactionTable._children))
  if verbose then
   print('Enhanced Reactions:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedReactionTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedReactionTable[n])
   end
  end
 else
  print('Enhanced System - Reactions not loaded')
 end
end
--==========================================================================================================================

--==========================================================================================================================
--= MAKE EVENT SYSTEM
if args.all or args.eventSystem then
 print('Initializing the Event System')
 if args.forceReload then
  roses.EventTable = {}, roses.Systems.Event == 'false'
 end

 if not roses.Systems.Event or roses.Systems.Event == 'false' then
  dfhack.script_environment('functions/event').makeEventTable(args.testRun)
 end

 if roses.Systems.Event == 'true'  then
  print('Event System successfully loaded')
  print('Number of Events: '..tostring(#persistTable.GlobalTable.roses.EventTable._children))
  if verbose then
   print('Events:')
   for _,n in pairs(persistTable.GlobalTable.roses.EventTable._children) do
    print(persistTable.GlobalTable.roses.EventTable[n])
   end
  end
 else
  print('Event System not loaded')
 end
end
--==========================================================================================================================

--==========================================================================================================================
--= RUN BASE COMMANDS
if args.testRun then
 print('Base commands are run seperately for a -testRun')
else
 if args.verbose then
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
  print('Setting up triggers')
  dfhack.run_command('base/triggers -verbose')
 else
  dfhack.run_command('base/persist-delay')
  dfhack.run_command('base/liquids-update')
  dfhack.run_command('base/flows-update')
  dfhack.run_command('base/on-death')
  dfhack.run_command('base/on-time')
  dfhack.run_command('base/periodic-check')
  dfhack.run_command('base/triggers')
 end
end

--==========================================================================================================================
