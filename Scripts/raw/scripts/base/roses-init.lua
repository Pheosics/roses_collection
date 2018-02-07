-- base/roses-init.lua v1.0 | DFHack 43.05
--MUST BE LOADED IN ONLOAD.INIT

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

validArgs = validArgs or utils.invert({
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

verbose = args.verbose

persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
persistTable.GlobalTable.roses.UnitTable = persistTable.GlobalTable.roses.UnitTable or {}
persistTable.GlobalTable.roses.ItemTable = persistTable.GlobalTable.roses.ItemTable or {}
persistTable.GlobalTable.roses.BuildingTable = persistTable.GlobalTable.roses.BuildingTable or {}
persistTable.GlobalTable.roses.EntityTable = persistTable.GlobalTable.roses.EntityTable or {}
persistTable.GlobalTable.roses.CommandDelay = persistTable.GlobalTable.roses.CommandDelay or {}
persistTable.GlobalTable.roses.EnvironmentDelay = persistTable.GlobalTable.roses.EnvironmentDelay or {}
persistTable.GlobalTable.roses.CounterTable = persistTable.GlobalTable.roses.CounterTable or {}
persistTable.GlobalTable.roses.LiquidTable = persistTable.GlobalTable.roses.LiquidTable or {}
persistTable.GlobalTable.roses.FlowTable = persistTable.GlobalTable.roses.FlowTable or {}
if not persistTable.GlobalTable.roses.GlobalTable then dfhack.script_environment('functions/tables').makeGlobalTable(args.verbose) end

local function civilizationNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.CivilizationTable) or #persistTable.GlobalTable.roses.CivilizationTable._children < 1
end
local function diplomacyNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.DiplomacyTable) or #persistTable.GlobalTable.roses.DiplomacyTable._children < 1
end
local function classNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.ClassTable) or #persistTable.GlobalTable.roses.ClassTable._children < 1
end
local function eventNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EventTable) or #persistTable.GlobalTable.roses.EventTable._children < 1
end
local function spellNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.SpellTable) or #persistTable.GlobalTable.roses.SpellTable._children < 1
end
local function featNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.FeatTable) or #persistTable.GlobalTable.roses.FeatTable._children < 1
end
local function EBuildingsNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedBuildingTable) or #persistTable.GlobalTable.roses.EnhancedBuildingTable._children < 1
end
local function ECreaturesNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedCreatureTable) or #persistTable.GlobalTable.roses.EnhancedCreatureTable._children < 1
end
local function EItemsNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedItemTable) or #persistTable.GlobalTable.roses.EnhancedItemTable._children < 1
end
local function EMaterialsNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedMaterialTable) or #persistTable.GlobalTable.roses.EnhancedMaterialTable._children < 1
end
local function EReactionsNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedReactionTable) or #persistTable.GlobalTable.roses.EnhancedReactionTable._children < 1
end

dfhack.script_environment('functions/tables').makeBaseTable(args.testRun,args.verbose)

--==========================================================================================================================
-- MAKE CLASS SYSTEM =======================================================================================================
--==========================================================================================================================
if args.all or args.classSystem then
 if args.verbose then print('Initializing the Class System') end
 if type(args.classSystem) == 'string' then args.classSystem = {args.classSystem} end
 featCheck = false
 spellCheck = false
 classCheck = false
 for _,check in pairs(args.classSystem) do
  if check == 'Feats' then   
   if featNotAlreadyLoaded() or args.forceReload then
    featCheck = dfhack.script_environment('functions/tables').makeFeatTable(args.testRun,args.verbose)
   elseif not featNotAlreadyLoaded() then
    featCheck = true
    if args.verbose then print('Feat SubSystem already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Spells' then
   if spellNotAlreadyLoaded() or args.forceReload then
    spellCheck = dfhack.script_environment('functions/tables').makeSpellTable(args.testRun,args.verbose)
   elseif not spellNotAlreadyLoaded() then
    spellCheck = true
    if args.verbose then print('Spell SubSystem already loaded, use -forceReload to force a reload of the system') end
   end  
  end
 end

 if classNotAlreadyLoaded() or args.forceReload then
  classCheck = dfhack.script_environment('functions/tables').makeClassTable(spellCheck,args.testRun,args.verbose)
 elseif not classNotAlreadyLoaded() then
  classCheck = true
  if args.verbose then print('Class System already loaded, use -forceReload to force a reload of the system') end
 end

 if classCheck then
  print('Class System successfully loaded')
  print('Number of Classes: '..tostring(#persistTable.GlobalTable.roses.ClassTable._children))
  if verbose then
   print('Classes:')
   for _,n in pairs(persistTable.GlobalTable.roses.ClassTable._children) do
    print(persistTable.GlobalTable.roses.ClassTable[n])
   end
  end
  if spellCheck then
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
  if featCheck then
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
-- MAKE CIVILIZATION SYSTEM ================================================================================================
--==========================================================================================================================
if args.all or args.civilizationSystem then
 if args.verbose then print('Initializing the Civilization System') end
 if type(args.civilizationSystem) == 'string' then args.civilizationSystem = {args.civilizationSystem} end
 diplomacyCheck = false
 civilizationCheck = false
 if civilizationNotAlreadyLoaded() or args.forceReload then
  civilizationCheck = dfhack.script_environment('functions/tables').makeCivilizationTable(args.testRun,args.verbose)
 elseif not classNotAlreadyLoaded() then
  civilizationCheck = true
  if args.verbose then print('Civilization System already loaded, use -forceReload to force a reload of the system') end
 end
 for _,check in pairs(args.civilizationSystem) do
  if check == 'Diplomacy' then   
   if diplomacyNotAlreadyLoaded() then
    diplomacyCheck = dfhack.script_environment('functions/tables').makeDiplomacyTable(args.verbose)
   elseif not diplomacyNotAlreadyLoaded() then
    diplomacyCheck = true
   end
  end
 end

 if civilizationCheck then
  print('Civilization System successfully loaded')
  print('Number of Civilizations: '..tostring(#persistTable.GlobalTable.roses.CivilizationTable._children))
  if verbose then
   print('Civilizations:')
   for _,n in pairs(persistTable.GlobalTable.roses.CivilizationTable._children) do
    print(persistTable.GlobalTable.roses.CivilizationTable[n])
   end
  end  
  if diplomacyCheck then
   print('Diplomacy SubSystem loaded')
  else
   print('Diplomacy SubSystem not loaded')
  end
 else
  print('Civilization System not loaded')
 end
end
--==========================================================================================================================

--==========================================================================================================================
-- MAKE ENHANCED SYSTEM ====================================================================================================
--==========================================================================================================================
if args.all or args.enhancedSystem then
 if args.verbose then print('Initializing the Enhanced System') end
 if type(args.enhancedSystem) == 'string' then args.enhancedSystem = {args.enhancedSystem} end
 for _,check in pairs(args.enhancedSystem) do
  buildingCheck = false
  creatureCheck = false
  itemCheck = false
  materialCheck = false
  reactionCheck = false
  if check == 'Buildings' then
   if EBuildingsNotAlreadyLoaded() or args.forceReload then
    buildingCheck = dfhack.script_environment('functions/tables').makeEnhancedBuildingTable(args.testRun,args.verbose)
   elseif not EBuildingsNotAlreadyLoaded() then
    buildingCheck = true
    if args.verbose then print('Enhanced System - Buildings already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Creatures' then
   if ECreaturesNotAlreadyLoaded() or args.forceReload then
    creatureCheck = dfhack.script_environment('functions/tables').makeEnhancedCreatureTable(args.testRun,args.verbose)
   elseif not ECreaturesNotAlreadyLoaded() then
    creatureCheck = true
    if args.verbose then print('Enhanced System - Creatures already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Items' then
   if EItemsNotAlreadyLoaded() or args.forceReload then
    itemCheck = dfhack.script_environment('functions/tables').makeEnhancedItemTable(args.testRun,args.verbose)
   elseif not EItemsNotAlreadyLoaded() then
    itemCheck = true
    if args.verbose then print('Enhanced System - Items already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Materials' then
   if EMaterialsNotAlreadyLoaded() or args.forceReload then
    materialCheck = dfhack.script_environment('functions/tables').makeEnhancedMaterialTable(args.testRun,args.verbose)
   elseif not EMaterialsNotAlreadyLoaded() then
    materialCheck = true
    if args.verbose then print('Enhanced System - Materials already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Reactions' then
   if EReactionsNotAlreadyLoaded() or args.forceReload then
    reactionCheck = dfhack.script_environment('functions/tables').makeEnhancedReactionTable(args.testRun,args.verbose)
   elseif not EReactionsNotAlreadyLoaded() then
    reactionCheck = true
    if args.verbose then print('Enhanced System - Reactions already loaded, use -forceReload to force a reload of the system') end
   end
  end
 end
 
 if buildingCheck then
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
 if creatureCheck then
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
 if itemCheck then
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
 if materialCheck then
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
end
--==========================================================================================================================

--==========================================================================================================================
-- MAKE EVENT SYSTEM =======================================================================================================
--==========================================================================================================================
if args.all or args.eventSystem then
 if args.verbose then print('Initializing the Event System') end
 systemCheck = false
 if eventNotAlreadyLoaded() or args.forceReload then
  systemCheck = dfhack.script_environment('functions/tables').makeEventTable(args.testRun,args.verbose)
 elseif not eventNotAlreadyLoaded() then
  systemCheck = true
  if args.verbose then print('Event System already loaded, use -forceReload to force a reload of the system') end
 end
 if systemCheck then
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
-- RUN BASE COMMANDS =======================================================================================================
--==========================================================================================================================
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
 else
  dfhack.run_command('base/persist-delay')
  dfhack.run_command('base/liquids-update')
  dfhack.run_command('base/flows-update')
  dfhack.run_command('base/on-death')
  dfhack.run_command('base/on-time')
  dfhack.run_command('base/periodic-check')
 end
end

--==========================================================================================================================
-- SET UP TRIGGERS =========================================================================================================
--==========================================================================================================================
-- Enhanced Item Triggers
if args.all or itemCheck then
 if args.verbose then print('Setting up Enhanced Item Triggers') end
 for _,itemToken in ipairs(persistTable.GlobalTable.roses.EnhancedItemTable._children) do
  item = persistTable.GlobalTable.roses.EnhancedItemTable[itemToken]
  if item.OnEquip then
   if verbose then print('trigger/action -actionType Equip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Equip ]') end
   dfhack.run_command('trigger/action -actionType Equip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Equip ]')
   if verbose then print('trigger/action -actionType Unequip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Unequip ]') end
   dfhack.run_command('trigger/action -actionType Unequip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Unequip ]')
  end
  if item.OnAttack then
   if verbose then print('trigger/action -actionType Attack -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack ]') end
   dfhack.run_command('trigger/action -actionType Attack -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack ]')
  end
  if item.OnBlock then
   if verbose then print('trigger/action -actionType Block -item '..itemToken..' -command [ enhanced/item-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action Block ]') end
   dfhack.run_command('trigger/action -actionType Block -item '..itemToken..' -command [ enhanced/item-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action Block ]')
  end
  if item.OnDodge then
   if verbose then print('trigger/action -actionType Dodge -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Dodge ]') end
   dfhack.run_command('trigger/action -actionType Dodge -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Dodge ]')
  end
  if item.OnParry then
   if verbose then print('trigger/action -actionType Parry -item '..itemToken..' -command [ enhanced/item-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry ]') end
   dfhack.run_command('trigger/action -actionType Parry -item '..itemToken..' -command [ enhanced/item-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry ]')
  end
  if item.OnMove then
   if verbose then print('trigger/action -actionType Move -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Move ]') end
   dfhack.run_command('trigger/action -actionType Move -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Move ]')
  end
  if item.OnWound then
   if verbose then print('trigger/action -actionType Wound -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound ]') end
   dfhack.run_command('trigger/action -actionType Wound -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound ]')
  end
 end
end

-- Enhanced Material Triggers
if args.all or materialCheck then
 local function matTrigger(material,materialToken,triggerType,verbose)
  if material.OnEquip then
   if verbose then print('trigger/action -actionType Equip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Equip -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Equip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Equip -matType '..triggerType..' ]')
   if verbose then print('trigger/action -actionType Unequip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Unequip -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Unequip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Unequip -matType '..triggerType..' ]')
  end
  if material.OnAttack then
   if verbose then print('trigger/action -actionType Attack -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Attack -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack -matType '..triggerType..' ]')
  end
  if material.OnBlock then
   if verbose then print('trigger/action -actionType Block -material '..materialToken..' -command [ enhanced/material-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action BLOCK -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Block -material '..materialToken..' -command [ enhanced/material-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action BLOCK -matType '..triggerType..' ]')
  end
  if material.OnDodge then
   if verbose then print('trigger/action -actionType Dodge -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Dodge -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Dodge -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Dodge -matType '..triggerType..' ]')
  end
  if material.OnParry then
   if verbose then print('trigger/action -actionType Parry -material '..materialToken..' -command [ enhanced/material-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Parry -material '..materialToken..' -command [ enhanced/material-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry -matType '..triggerType..' ]')
  end
  if material.OnMove then
   if verbose then print('trigger/action -actionType Move -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Move -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Move -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Move -matType '..triggerType..' ]')
  end
  if material.OnWound then
   if verbose then print('trigger/action -actionType Wound -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Wound -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound -matType '..triggerType..' ]')
  end
 end
 
 if verbose then print('Setting up Enhanced Material Triggers') end
 materials = persistTable.GlobalTable.roses.EnhancedMaterialTable
 for _,materialToken in pairs(materials.Inorganic._children) do
  material = materials.Inorganic[materialToken]
  materialToken = 'INORGANIC:'..materialToken
  matTrigger(material,materialToken,'Inorganic',verbose)
 end
 for _,token in pairs(materials.Creature._children) do
  for _,index in pairs(materials.Creature[token]._children) do
   if index ~= 'ALL' then
    material = materials.Creature[token][index]
    materialToken = 'CREATURE:'..token..':'..index
    matTrigger(material,materialToken,'Creature',verbose)
   end
  end
 end
 for _,token in pairs(materials.Plant._children) do
  for _,index in pairs(materials.Plant[token]._children) do
   if index ~= 'ALL' then
    material = materials.Plant[token][index]
    materialToken = 'PLANT:'..token..':'..index
    matTrigger(material,materialToken,'Plant',verbose)
   end
  end
 end
end

-- Enhanced Building Triggers
if args.all or buildingCheck then
 if verbose then print('Setting up Enhanced Building Triggers') end
 for _,buildingToken in pairs(persistTable.GlobalTable.roses.EnhancedBuildingTable._children) do
  building = persistTable.GlobalTable.roses.EnhancedBuildingTable[buildingToken]
  checks = ''
  if building.OutsideOnly then checks = checks .. ' -location Outside' end
  if building.InsideOnly then checks = checks .. ' -location Inside' end
  if building.MaxAmount then checks = checks .. ' -maxNumber ' .. building.MaxAmount end
  if building.MultiStory then checks = checks .. ' -zLevels ' .. building.MultiStory end
  if building.RequiredWater then checks = checks .. ' -requiredWater ' .. building.RequiredWater end
  if building.RequiredMagma then checks = checks .. ' -requiredMagma ' .. building.RequiredMagma end
  if building.RequiredBuildings then
   temp = ' -requiredBuilding [ '
   for _,bldg in pairs(building.RequiredBuildings._children) do
    num = building.RequiredBuildings[bldg]
    temp = temp..bldg..':'..num..' '
   end
   temp = temp..']'
   checks = checks .. temp
  end
  if building.ForbiddenBuildings then
   temp = ' -forbiddenBuilding [ '
   for _,bldg in pairs(building.ForbiddenBuildings._children) do
    num = building.ForbiddenBuildings[bldg]
    temp = temp..bldg..':'..num..' '
   end
   temp = temp..']'
   checks = checks .. temp
  end 
  if verbose then print('trigger/building -building '..buildingToken..checks..' -created -command [ enhanced/building -created -buildingID BUILDING_ID ]') end
  dfhack.run_command('trigger/building -building '..buildingToken..checks..' -created -command [ enhanced/building -created -buildingID BUILDING_ID ]')
  if verbose then print('trigger/building -building '..buildingToken..' -destroyed -command [ enhanced/building -destroyed -buildingToken BUILDING_TOKEN -buildingLocation BUILDING_LOCATION ]') end
  dfhack.run_command('trigger/building -building '..buildingToken..' -destroyed -command [ enhanced/building -destroyed -buildingToken BUILDING_TOKEN -buildingLocation BUILDING_LOCATION ]')
 end
end

-- Enhanced Reaction Triggers
if args.all or reactionCheck then
 if verbose then print('Setting up Enhanced Reaction Triggers') end
 for _,reactionToken in pairs(persistTable.GlobalTable.roses.EnhancedReactionTable._children) do
  reaction = persistTable.GlobalTable.roses.EnhancedReactionTable[reactionToken]
  if reaction.OnStart then
   checks = ' '
   if reaction.BaseDur and not reaction.DurReduction then checks = checks..'-delay '..reaction.BaseDur..' ' end
   if reaction.RequiredMagma then checks = checks..'-requiredMagma '..reaction.RequiredMagma..' ' end
   if reaction.RequiredWater then checks = checks..'-requiredWater '..reaction.RequiredWater..' ' end
   if verbose then print('trigger/reaction -reaction '..reactionToken..' -trigger onStart'..checks..'-command [ enhanced/reaction -type Start -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]') end
   dfhack.run_command('trigger/reaction -reaction '..reactionToken..' -trigger onStart'..checks..'-command [ enhanced/reaction -type Start -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ]  -job JOB_ID ]')
  end
  if reaction.OnFinish then
   if verbose then print('trigger/reaction -reaction '..reactionToken..' -trigger onFinish -command [ enhanced/reaction -type End -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]') end
   dfhack.run_command('trigger/reaction -reaction '..reactionToken..' -trigger onFinish -command [ enhanced/reaction -type End -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]')
  end
  if reaction.OnProduct then
   if verbose then print('trigger/reaction -reaction '..reactionToken..' -trigger onProduct -command [ enhanced/reaction -inputItems [ INPUT_ITEMS ] -outputItems [ OUTPUT_ITEMS ] -type Product -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]') end
   dfhack.run_command('trigger/reaction -reaction '..reactionToken..' -trigger onProduct -command [ enhanced/reaction -type Product -inputItems [ INPUT_ITEMS ] -outputItems [ OUTPUT_ITEMS ] -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]')
  end
 end
end
