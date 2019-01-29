-- base/roses-init.lua v1.0 | DFHack 43.05
--MUST BE LOADED IN ONLOAD.INIT

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

local function makeBaseTable(test,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 print('Searching for an included base file')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/','/raw/scripts/'}
 local n = 1
 local filename = 'base.txt'
 if test then filename = 'base_test.txt' end
 for _,location in ipairs(locations) do
  local path = dir..location
  if verbose then print('Looking in '..location) end
  if dfhack.internal.getDir(path) then
   for _,fname in pairs(dfhack.internal.getDir(path)) do
    if (fname == filename) then
     files[n] = path..fname
     n = n + 1
    end
   end
  end
 end
 base = {}
 base.ExperienceRadius = '-1'
 base.FeatGains = '100:25'
 base.CustomAttributes = {}
 base.CustomSkills = {}
 base.CustomResistances = {}
 base.CustomStats = {}
 base.Types = {}
 base.Spheres = {}
 base.Schools = {}
 base.Disciplines = {}
 base.SubDisciplines = {}
 base.Equations = {}
 if #files < 1 then
  print('No Base file found, assuming defaults')
  base.Types = {}
  base.Types['1'] = 'MAGICAL'
  base.Types['2'] = 'PHYSICAL'
 else
  if verbose then printall(files) end
  for _,file in ipairs(files) do
   local data = {}
   local iofile = io.open(file,"r")
   local lineCount = 1
   while true do
    local line = iofile:read("*line")
    if line == nil then break end
    data[lineCount] = line
    lineCount = lineCount + 1
   end
   iofile:close()  
   for i,line in pairs(data) do
    test = line:gsub("%s+","")
    test = split(test,':')[1]
    array = split(line,':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[EXPERIENCE_RADIUS' then
     base.ExperienceRadius = array[2]
    elseif test == '[FEAT_GAINS' then
     base.FeatGains = array[2]..':'..array[3]
    elseif test == '[SKILL' then
     base.CustomSkills[array[2]] = array[3]
    elseif test == '[ATTRIBUTE' then
     base.CustomAttributes[#base.CustomAttributes+1] = array[2]
    elseif test == '[RESISTANCE' then
     base.CustomResistances[#base.CustomResistances+1] = array[2]
    elseif test == '[STAT' then
     base.CustomStats[#base.CustomStats+1] = array[2]
    elseif test == '[TYPE' then
     for arg = 2,#array,1 do
      base.Types[#base.Types+1] = array[arg]
     end
    elseif test == '[SPHERE' then
     for arg = 2,#array,1 do
      base.Spheres[#base.Spheres+1] = array[arg]
     end
    elseif test == '[SCHOOL' then
     for arg = 2,#array,1 do
      base.Schools[#base.Schools+1] = array[arg]
     end
    elseif test == '[DISCIPLINE' then
     for arg = 2,#array,1 do
      base.Disciplines[#base.Disciplines+1] = array[arg]
     end
    elseif test == '[SUBDISCIPLINE' then
     for arg = 2,#array,1 do
      base.SubDisciplines[#base.SubDisciplines+1] = array[arg]
     end
    elseif test == '[EQUATION' then
     base.Equations[array[2]] = array[3]
    end
   end
  end
 end
 
 return base
end

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

roses = {} -- EVENTUALLY WE WILL NEED TO LOAD FILE HERE!!!!!

if args.clear then
 roses = nil
 persistTable.GlobalTable.roses = {}
 return
end
if args.testRun then args.forceReload = true end
verbose = args.verbose

if args.forceReload then roses = {} end

-- System Tables (Populated by files read into the game)
roses.Systems = roses.Systems or {}
---- CLASS SYSTEM
roses.ClassTable = roses.ClassTable or {}
roses.FeatTable  = roses.FeatTable  or {}
roses.SpellTable = roses.SpellTable or {}
---- CIVILIZATION SYSTEM
roses.CivilizationTable = roses.CivilizationTable or {}
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
roses.GlobalTable   = roses.GlobalTable   or {}
roses.CounterTable  = roses.CounterTable  or {}
roses.UnitTable     = roses.UnitTable     or {}
roses.ItemTable     = roses.ItemTable     or {}
roses.BuildingTable = roses.BuildingTable or {}
roses.EntityTable   = roses.EntityTable   or {}

-- Misc Tables (Populated by miscellanious things in game and scripts) These are persistant tables
persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
pT = persistTable.GlobalTable.roses
pT.CommandDelay     = pT.CommandDelay     or {}
pT.EnvironmentDelay = pT.EnvironmentDelay or {}
pT.CounterTable     = pT.CounterTable     or {}
pT.LiquidTable      = pT.LiquidTable      or {}
pT.FlowTable        = pT.FlowTable        or {}

if not roses.BaseTable then
 roses.BaseTable = makeBaseTable(args.testRun,args.verbose)
end

numClasses    = roses.Systems.Class            or 0
numFeats      = roses.Systems.Feat             or 0
numSpells     = roses.Systems.Spell            or 0
numCivs       = roses.Systems.Civilization     or 0
numEBuildings = roses.Systems.EnhancedBuilding or 0
numECreatures = roses.Systems.EnhancedCreature or 0
numEItems     = roses.Systems.EnhancedItem     or 0
numEMaterials = roses.Systems.EnhancedMaterial or 0
numEReactions = roses.Systems.EnhancedReaction or 0

--==========================================================================================================================
--= MAKE CLASS SYSTEM 
if args.all or args.classSystem then
 print('Initializing the Class System')

 if not roses.Systems.Class then
  numClasses, Table = dfhack.script_environment('functions/class').makeClassTable(args.testRun,verbose)
  if numClasses > 0 then
   roses.ClassTable = Table
   roses.Systems.Class = numClasses
  end
 end

 if not roses.Systems.Feat then
  numFeats, Table = dfhack.script_environment('functions/class').makeFeatTable(args.testRun,verbose)
  if numFeats > 0 then
   roses.FeatTable = Table
   roses.Systems.Feat = numFeats
  end
 end
 
 if not roses.Systems.Spell then
  numSpells, Table = dfhack.script_environment('functions/class').makeSpellTable(args.testRun,verbose)
  if numSpells > 0 then
   roses.SpellTable = Table
   roses.Systems.Class = numSpells
  end
 end
 
 if roses.Systems.Class then
  print('Class System successfully loaded')
  print('Number of Classes: '..tostring(numClasses))
  if verbose then
   print('Classes:')
   for _,class in pairs(roses.ClassTable) do
    print(class.Name)
   end
  end

  if roses.Systems.Spell then
   print('Spell SubSystem loaded')
   print('Number of Spells: '..tostring(numSpells))
   if verbose then
    print('Spells:')
    for _,spell in pairs(roses.SpellTable) do
     print(spell.Name)
    end
   end
  else
   print('Spell SubSystem not loaded')
  end

  if roses.Systems.Feat == 'true' then
   print('Feat SubSystem loaded')
   print('Number of Feats: '..tostring(numFeats))
   if verbose then
    print('Feats:')
    for _,feat in pairs(roses.FeatTable) do
     print(feat.Name)
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

 if not roses.Systems.Civilization then
  numCivs, Table = dfhack.script_environment('functions/civilization').makeCivilizationTable(args.testRun,verbose)
  if numCivs > 0 then
   roses.CivilizationTable = Table
   roses.Systems.Civilization = numCivs
  end
 end

 if roses.Systems.Civilization then
  print('Civilization System successfully loaded')
  print('Number of Civilizations: '..tostring(numCivs))
  if verbose then
   print('Civilizations:')
   for _,civ in pairs(roses.CivilizationTable) do
    print(civ.Name)
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

 if not roses.Systems.EnhancedItem then
  numEItems, Table = dfhack.script_environment('functions/enhanced').makeEnhancedItemTable(args.testRun,verbose)
  if numEItems > 0 then
   roses.EnhancedItemTable = Table
   roses.Systems.EnhancedItem = numEItems
  end
 end

 if not roses.Systems.EnhancedBuilding then
  numEBuildings, Table = dfhack.script_environment('functions/enhanced').makeEnhancedBuildingTable(args.testRun,verbose)
  if numEBuildings > 0 then
   roses.EnhancedBuildingTable = Table
   roses.Systems.EnhancedBuilding = numEBuildings
  end
 end
 
 if not roses.Systems.EnhancedCreature then
  numECreatures, Table = dfhack.script_environment('functions/enhanced').makeEnhancedCreatureTable(args.testRun,verbose)
  if numECreatures > 0 then
   roses.EnhancedCreatureTable = Table
   roses.Systems.EnhancedCreature = numECreatures
  end
 end
 
 if not roses.Systems.EnhancedMaterial then
  numEMaterials, Table = dfhack.script_environment('functions/enhanced').makeEnhancedMaterialTable(args.testRun,verbose)
  if numEMaterials > 0 then
   roses.EnhancedMaterialTable = Table
   roses.Systems.EnhancedMaterial = numEMaterials
  end
 end
 
 if not roses.Systems.EnhancedReaction then
  numEReactions, Table = dfhack.script_environment('functions/enhanced').makeEnhancedReactionTable(args.testRun,verbose)
  if numEReactions > 0 then
   roses.EnhancedReaction = Table
   roses.Systems.EnhancedReaction = numEReactions
  end
 end
 
 if roses.Systems.EnhancedBuilding then
  print('Enhanced System - Buildings successfully loaded')
  print('Number of Enhanced Buildings: '..tostring(numEBuildings))
  if verbose then
   print('Enhanced Buildings:')
   for _,n in pairs(roses.EnhancedBuildingTable) do
    print(n.Name)
   end
  end
 else
  print('Enhanced System - Buildings not loaded')
 end

 if roses.Systems.EnhancedCreature then
  print('Enhanced System - Creatures successfully loaded')
  print('Number of Enhanced Creatures: '..tostring(numECreatures))
  if verbose then
   print('Enhanced Creatures:')
   for _,n in pairs(roses.EnhancedCreatureTable) do
    print(n.Name)
   end
  end
 else
  print('Enhanced System - Creatures not loaded')
 end

 if roses.Systems.EnhancedItem then
  print('Enhanced System - Items successfully loaded')
  print('Number of Enhanced Items: '..tostring(numEItems))
  if verbose then
   print('Enhanced Items:')
   for _,n in pairs(roses.EnhancedItemTable) do
    print(n.Name)
   end
  end
 else
  print('Enhanced System - Items not loaded')
 end

 if roses.Systems.EnhancedMaterial then
  print('Enhanced System - Materials successfully loaded')
  print('Number of Enhanced Materials: '..tostring(numEMaterials))
  if verbose then
   print('Enhanced Materials:')
   for _,n in pairs(roses.EnhancedMaterialTable) do
    print(n.Name)
   end
  end
 else
  print('Enhanced System - Materials not loaded')
 end

 if roses.Systems.EnhancedReaction then
  print('Enhanced System - Reaction successfully loaded')
  print('Number of Enhanced Reactions: '..tostring(numEReactions))
  if verbose then
   print('Enhanced Reactions:')
   for _,n in pairs(roses.EnhancedReactionTable) do
    print(n.Name)
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

 if not roses.Systems.Event then
  numEvents, Table = dfhack.script_environment('functions/event').makeEventTable(args.testRun,verbose)
  if numEvents > 0 then
   roses.EventTable = Table
   roses.Systems.Event = numEvents
  end
 end

 if roses.Systems.Event then
  print('Event System successfully loaded')
  print('Number of Events: '..tostring(numEvents))
  if verbose then
   print('Events:')
   for _,n in pairs(roses.EventTable) do
    print(n.Name)
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
