--Functions for use in the Class System, v42.06a
local utils = require 'utils'
split = utils.split_string
usages = {}

--=                     Class System Table Functions
usages[#usages+1] = [===[

Class System Table Functions 
============================

getData(table,test)
  Purpose: Read data from Class System files (classes.txt, spells.txt, feats.txt)
  Calls:   NONE
  Inputs:
           table = Table type (Class, Spell, or Feat)
           test  = True/False
  Returns: Tables containing information from files

makeClassTable(test)
  Purpose: Create Class System - Class Table
  Calls:   getData
  Inputs:
           test = True/False
  Returns: Boolean whether the table was successfully made

makeFeatTable(test)
  Purpose: Create Class System - Feat Table
  Calls:   getData
  Inputs:
           test = True/False
  Returns: Boolean whether the table was successfully made

makeSpellTable(test)
  Purpose: Create Class System - Spell Table
  Calls:   getData
  Inputs:
           test = True/False
  Returns: Boolean whether the table was successfully made

]===]

function getData(table,test)
 if table == 'Class' then
  tokenCheck = '[CLASS'
  filename = 'classes'
 elseif table == 'Spell' then
  tokenCheck = '[SPELL'
  filename = 'spells'
 elseif table == 'Feat' then
  tokenCheck = '[FEAT'
  filename = 'feats'
 else 
  return
 end
 print('Searching for a '..table..' file')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/Class/','/raw/scripts/'}
 local n = 1
 if test then
  filename = filename..'_test'
  locations = {'/raw/systems/Test/'}
 end
 for _,location in ipairs(locations) do
  local path = dir..location
  print('Looking in '..location)
  if dfhack.internal.getDir(path) then
   for _,fname in pairs(dfhack.internal.getDir(path)) do
    if (split(fname,'_')[1] == filename or fname == filename..'.txt') and string.match(fname,'txt') then
     files[n] = path..fname
     n = n + 1
    end
   end
  end
 end

 if #files >= 1 then
  print(table..' files found:')
  printall(files)
 else
  print('No '..table..' files found')
  return false
 end

 local data = {}
 local dataInfo = {}
 for _,file in ipairs(files) do
  data[file] = {}
  local iofile = io.open(file,"r")
  local lineCount = 1
  while true do
   local line = iofile:read("*line")
   if line == nil then break end
   data[file][lineCount] = line
   lineCount = lineCount + 1
  end
  iofile:close()

  dataInfo[file] = {}
  local count = 1
  local endline = 1
  for i,line in ipairs(data[file]) do
   endline = i
   sline = line:gsub("%s+","")
   if split(sline,':')[1] == tokenCheck then
    dataInfo[file][count] = {split(split(sline,':')[2],']')[1],i+1,0}
    if count > 1 then
     dataInfo[file][count-1][3] = i-1
    end
    count = count + 1
   end
  end
  dataInfo[file][count-1][3] = endline
 end

 return data, dataInfo, files
end

function makeClassTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.Class = 'false'
 dataFiles,dataInfoFiles,files = getData('Class',test)
 if not dataFiles then return false end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   classToken = x[1]
   startLine  = x[2]
   endLine    = x[3]
   persistTable.GlobalTable.roses.ClassTable[classToken] = {}
   class = persistTable.GlobalTable.roses.ClassTable[classToken]
   class.Level = {}
   class.Spells = {}
   level = '0'
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if     test == '[NAME' then
     class.Name = array[2]
    elseif test == '[LEVELS' then
     class.Levels = array[2]
    elseif test == '[DESCRIPTION' then
     class.Description = array[2]
    elseif test == '[AUTO_UPGRADE' then
     class.AutoUpgrade = array[2]
    elseif test == '[REQUIREMENT_CLASS' then
     class.RequiredClass = class.RequiredClass or {}
     class.RequiredClass[array[2]] = array[3]
    elseif test == '[FORBIDDEN_CLASS' then
     class.ForbiddenClass = class.ForbiddenClass or {}
     class.ForbiddenClass[array[2]] = array[3]
    elseif test == '[REQUIREMENT_SKILL' then
     class.RequiredSkill = class.RequiredSkill or {}
     class.RequiredSkill[array[2]] = array[3]
    elseif test == '[REQUIREMENT_TRAIT' then
     class.RequiredTrait = class.RequiredTrait or {}
     class.RequiredTrait[array[2]] = array[3]
    elseif test == '[REQUIREMENT_COUNTER' then
     class.RequiredCounter = class.RequiredCounter or {}
     class.RequiredCounter[array[2]] = array[3]
    elseif test == '[REQUIREMENT_ATTRIBUTE' then
     class.RequiredAttribute = class.RequiredAttribute or {}
     class.RequiredAttribute[array[2]] = array[3]
    elseif test == '[REQUIREMENT_CREATURE' then
     class.RequiredCreature = class.RequiredCreature or {}
     class.RequiredCreature[array[2]] = array[3]
    elseif test == '[LEVEL' then
     level = array[2]
     class.Level[level] = {}
     classLevel = class.Level[level]
    elseif test == '[EXPERIENCE' then
     classLevel.Experience = array[2]
    elseif test == '[FEAT_POINTS' then
     classLevel.FeatPoints = array[2]
    elseif test == '[LEVEL_BONUS' then
     classLevel.LevelBonus = classLevel.LevelBonus or {}
     if array[2] == 'ATTRIBUTE' then
      classLevel.LevelBonus.Attribute = classLevel.LevelBonus.Attribute or {}
      classLevel.LevelBonus.Attribute[array[3]] = array[4]
     elseif array[2] == 'SKILL' then
      classLevel.LevelBonus.Skill = classLevel.LevelBonus.Skill or {}
      classLevel.LevelBonus.Skill[array[3]] = array[4]
     elseif array[2] == 'RESISTANCE' then
      classLevel.LevelBonus.Resistance = classLevel.LevelBonus.Resistance or {}
      classLevel.LevelBonus.Resistance[array[3]] = array[4]
     elseif array[2] == 'STAT' then
      classLevel.LevelBonus.Stat = classLevel.LevelBonus.Stat or {}
      classLevel.LevelBonus.Stat[array[3]] = array[4]
     elseif array[2] == 'TRAIT' then
      classLevel.LevelBonus.Trait = classLevel.LevelBonus.Trait or {}
      classLevel.LevelBonus.Trait[array[3]] = array[4]
     end
    elseif test == '[ADJUSTMENT' then
     classLevel.Adjustments = classLevel.Adjustments or {}
     if array[2] == 'ATTRIBUTE' then
      classLevel.Adjustments.Attribute = classLevel.Adjustments.Attribute or {}
      classLevel.Adjustments.Attribute[array[3]] = array[4]
     elseif array[2] == 'SKILL' then
      classLevel.Adjustments.Skill = classLevel.Adjustments.Skill or {}
      classLevel.Adjustments.Skill[array[3]] = array[4]
     elseif array[2] == 'RESISTANCE' then
      classLevel.Adjustments.Resistance = classLevel.Adjustments.Resistance or {}
      classLevel.Adjustments.Resistance[array[3]] = array[4]
     elseif array[2] == 'STAT' then
      classLevel.Adjustments.Stat = classLevel.Adjustments.Stat or {}
      classLevel.Adjustments.Stat[array[3]] = array[4]
     elseif array[2] == 'TRAIT' then
      classLevel.Adjustments.Trait = classLevel.Adjustments.Trait or {}
      classLevel.Adjustments.Trait[array[3]] = array[4]
     end
    elseif test == '[SPELL' then
     if array[3] then
      if array[3] == 'AUTO' then
       class.Spells[array[2]] = {}
       class.Spells[array[2]].RequiredLevel = level
       class.Spells[array[2]].AutoLearn = 'true'
      else
       class.Spells[array[2]] = {}
       class.Spells[array[2]].RequiredLevel = array[3]
       class.Spells[array[2]].AutoLearn = 'false'
      end
     else
      class.Spells[array[2]] = {}
      class.Spells[array[2]].RequiredLevel = level
      class.Spells[array[2]].AutoLearn = 'false'
     end
    end
   end
   for lvl = 0, tonumber(class.Levels) do
    if not class.Level[tostring(lvl)] then
     print('Level '..tostring(lvl)..' not found for Class '..classToken)
     class.Level[tostring(lvl)] = {}
    end
   end
  end
 end

 persistTable.GlobalTable.roses.Systems.Class = 'true'
 return true
end

function makeFeatTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.Feat = 'false'
 dataFiles,dataInfoFiles,files = getData('Feat',test)
 if not dataFiles then return false end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   featToken = x[1]
   startLine = x[2]
   endLine   = x[3]
   persistTable.GlobalTable.roses.FeatTable[featToken] = {}
   feat = persistTable.GlobalTable.roses.FeatTable[featToken]
   feat.Effect = {}
   feat.Script = {}
   effects = 0
   scripts = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if     test == '[NAME' then
     feat.Name = array[2]
    elseif test == '[DESCRIPTION' then
     feat.Description = array[2]
    elseif test == '[COST' then
     feat.Cost = array[2]
    elseif test == '[REQUIRED_CLASS' then
     feat.RequiredClass = feat.RequiredClass or {}
     feat.RequiredClass[array[2]] = array[3]
    elseif test == '[FORBIDDEN_CLASS' then
     feat.ForbiddenClass = feat.ForbiddenClass or {}
     feat.ForbiddenClass[array[2]] = array[3]
    elseif test == '[REQUIRED_FEAT' then
     feat.RequiredFeat = feat.RequiredFeat or {}
     feat.RequiredFeat[array[2]] = array[2]
    elseif test == '[FORBIDDEN_FEAT' then
     feat.ForbiddenFeat = feat.ForbiddenFeat or {}
     feat.ForbiddenFeat[array[2]] = array[2]
    elseif test == '[EFFECT' then
     feat.Effect[tostring(effects)] = array[2]
     effects = effects + 1
    elseif test == '[SCRIPT' then
     script = data[j]:gsub("%s+","")
     script = table.concat({select(2,table.unpack(split(script,':')))},':')
     script = string.sub(script,1,-2)
     feat.Script[tostring(scripts)] = script
     scripts = scripts + 1
    end
   end
  end
 end

 persistTable.GlobalTable.roses.Systems.Feat = 'true'
 return true
end

function makeSpellTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.Spell = 'false'
 dataFiles,dataInfoFiles,files = getData('Spell',test)
 if not dataFiles then return false end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   spellToken = x[1]
   startLine  = x[2]
   endLine    = x[3]
   persistTable.GlobalTable.roses.SpellTable[spellToken] = {}
   spell = persistTable.GlobalTable.roses.SpellTable[spellToken]
   spell.Script = {}
   spell.Cost = '0'
   spell.Classification = {}
   spell.Details = {}
   scriptNum = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if     test == '[NAME' then
     spell.Name = array[2]
    elseif test == '[DESCRIPTION' then
     spell.Description = array[2]
    elseif test == '[LEVEL' then
     spell.Level = array[2]
    elseif test == '[UPGRADE' then
     spell.Upgrade = array[2]
    elseif test == '[CLASS_RESTRICTED]' then
     spell.ClassRestricted = 'true'
    elseif test == '[ANNOUNCEMENT' then
     spell.Announcement = array[2]
	elseif test == '[COST' then
	 spell.Cost = array[2]
    elseif test == '[TYPE' then
     spell.Classification.Type = array[2]
    elseif test == '[SPHERE' then
     spell.Classification.Sphere = array[2]
    elseif test == '[SCHOOL' then
     spell.Classification.School = array[2]
    elseif test == '[DISCIPLINE' then
     spell.Classification.Discipline = array[2]
    elseif test == '[SUBDISCIPLINE' then
     spell.Classification.SubDiscipline = array[2]
    elseif test == '[RESISTABLE]' then
     spell.Details.Resistable = 'true'
    elseif test == '[CAN_CRIT]' then
     spell.Details.CanCrit = 'true'
    elseif test == '[PENETRATION' then
     spell.Details.Penetration = array[2]
    elseif test == '[CAST_TIME' then
     spell.Details.CastTime = array[2]
    elseif test == '[EXHAUSTION' then
     spell.Details.Exhaustion = array[2]
    elseif test == '[HIT_MODIFIER' then
     spell.Details.HitModifier = array[2]
    elseif test == '[HIT_MODIFIER_PERC' then
     spell.Details.HitModifierPerc = array[2]
    elseif test == '[EXP_GAIN' then
     spell.Gains = spell.Gains or {}
     spell.Gains.Experience = array[2]
    elseif test == '[SKILL_GAIN' then
     spell.Gains = spell.Gains or {}
     spell.Gains.Skill = spell.Gains.Skill or {}
     spell.Gains.Skill[array[2]] = array[3]
    elseif test == '[REQUIRED_ATTRIBUTE' then
     spell.RequiredAttribute = spell.RequiredAttribute or {}
     spell.RequiredAttribute[array[2]] = array[3]
    elseif test == '[REQUIRED_CLASS' then
     spell.RequiredClass = spell.RequiredClass or {}
     spell.RequiredClass[array[2]] = array[3]
    elseif test == '[FORBIDDEN_CLASS' then
     spell.ForbiddenClass = spell.ForbiddenClass or {}
     spell.ForbiddenClass[array[2]] = array[3]
    elseif test == '[REQUIRED_SPELL' then
     spell.RequiredSpell = spell.RequiredSpell or {}
     spell.RequiredSpell[array[2]] = array[2]
    elseif test == '[FORBIDDEN_SPELL' then
     spell.ForbiddenSpell = spell.ForbiddenSpell or {}
     spell.ForbiddenSpell[array[2]] = array[2]
    elseif test == '[SOURCE_PRIMARY_ATTRIBUTES' then
     spell.SourceAttributes = spell.SourceAttributes or {}
     spell.SourceAttributes.Primary = {}
     --tempTable = makeTable(array,2)
     --for x,y in pairs(tempTable) do
     -- spell.SourceAttributes.Primary[tostring(x)] = y
     --end
    elseif test == '[SOURCE_SECONDARY_ATTRIBUTES' then
     spell.SourceAttributes = spell.SourceAttributes or {}
     spell.SourceAttributes.Secondary = {}
     --tempTable = makeTable(array,2)
     --for x,y in pairs(tempTable) do
     -- spell.SourceAttributes.Secondary[tostring(x)] = y
     --end
    elseif test == '[TARGET_PRIMARY_ATTRIBUTES' then
     spell.TargetAttributes = spell.TargetAttributes or {}
     spell.TargetAttributes.Primary = {}
     --tempTable = makeTable(array,2)
     --for x,y in pairs(tempTable) do
     -- spell.TargetAttributes.Primary[tostring(x)] = y
     --end
    elseif test == '[TARGET_SECONDARY_ATTRIBUTES' then
     spell.TargetAttributes = spell.TargetAttributes or {}
     spell.TargetAttributes.Secondary = {}
     --tempTable = makeTable(array,2)
     --for x,y in pairs(tempTable) do
     -- spell.TargetAttributes.Secondary[tostring(x)] = y
     --end
    elseif test == '[SCRIPT' then
     script = data[j]
     script = table.concat({select(2,table.unpack(split(script,':')))},':')
     script = string.sub(script,1,-2)
     spell.Script[tostring(scriptNum)] = script
     scriptNum = scriptNum + 1
    end
   end
  end
 end

 persistTable.GlobalTable.roses.Systems.Spell = 'true'
 return true
end

--=                     Class System - Class Functions
usages[#usages+1] = [===[

Class System Class Functions 
============================

addExperience(unit,amount)
  Purpose: Adds experience to a units current class
  Calls:   NONE
  Inputs:
           unit    = The unit struct or unit ID to make the table for
           amount  = Amount of experience to add to unit
  Returns:

changeLevel(unit)
  Purpose: Increase the level of the units current class by 1
  Calls:   NONE
  Inputs:
           unit    = The unit struct or unit ID to make the table for
  Returns:

changeClass(unit,change)
  Purpose: Change the units current class to the new class
  Calls:   checkRequirementsClass | changeName
  Inputs:
           unit    = The unit struct or unit ID to make the table for
           change  = The CLASS_TOKEN to change into
  Returns:

]===]

function addExperience(unit,amount,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 classPersist = persistTable.GlobalTable.roses.ClassTable

 -- Check if unit passed is unit ID or unit struct
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 -- Make sure unit has a valid UnitTable, return if they don't
 if not unitPersist[tostring(unit.id)] then return end
 local unitTable = unitPersist[tostring(unit.id)]

 -- Get units current class, return if current class is NONE
 local unitClasses = unitTable.Classes
 local currentClass = unitClasses.Current
 if currentClass == 'NONE' then return end
 class = unitClasses[currentClass]

 -- Add experience to the current class 
 class.Experience = tostring(tonumber(class.Experience)+amount)
 class.SkillExp = tostring(tonumber(class.SkillExp)+amount)

 -- Check if enough experience to level up
 classLevel = tonumber(class.Level)
 nextLevel = math.floor(classLevel+1)
 if classLevel < tonumber(classPersist[currentClass].Levels) then
  nextExpLevel = tonumber(classPersist[currentClass].Level[tostring(nextLevel)].Experience) or 0
  if tonumber(class.Experience) >= nextExpLevel then
   if verbose then print('Unit leveled up!') end
   changeLevel(unit,verbose)
  end
 end
end

function changeLevel(unit,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 classPersist = persistTable.GlobalTable.roses.ClassTable

 -- Check if unit passed is unit ID or unit struct
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 -- Make sure unit has a valid UnitTable, return if they don't
 if not unitPersist[tostring(unit.id)] then return false end
 local unitTable = unitPersist[tostring(unit.id)]

 -- Get units current class, return if current class is NONE
 local unitClasses = unitTable.Classes
 local currentClass = unitClasses.Current
 if currentClass == 'NONE' then return false end

 local class = unitClasses[currentClass]
 local level = tonumber(class.Level)

 local classTable = classPersist[currentClass]
 local maxLevel = false
 -- For now assume amount is only ever +1
 if level >= tonumber(classTable.Levels) then
  if verbose then print('Already at max level') end
  return false
 else
  if level + 1 == tonumber(classTable.Levels) then maxLevel = true end
  class.Level = tostring(level+1)
 end
 classTableLevel = classTable.Level[tostring(level + 1)]
 classTablePrev  = classTable.Level[tostring(level)]

 unitFunctions = dfhack.script_environment('functions/unit')
 -- Apply permenant changes
 if classTableLevel.LevelBonus then
  for _,mType in pairs(classTableLevel.LevelBonus._children) do
   for _,sType in pairs(classTableLevel.LevelBonus[mType]._children) do
    local bonus = tonumber(classTableLevel.LevelBonus[mType][sType])
    if mType == 'Attribute'  then unitFunctions.changeAttribute( unit,sType,bonus,0,'track') end
    if mType == 'Resistance' then unitFunctions.changeResistance(unit,sType,bonus,0,'track') end
    if mType == 'Skill'      then unitFunctions.changeSkill(     unit,sType,bonus,0,'track') end
    if mType == 'Stat'       then unitFunctions.changeStat(      unit,sType,bonus,0,'track') end
    if mType == 'Trait'      then unitFunctions.changeTrait(     unit,sType,bonus,0,'track') end
   end
  end
 end  

 -- Apply Level Changes
 if classTableLevel.Adjustments then
  -- First remove last levels adjustments
  if classTablePrev and classTablePrev.Adjustments then
   for _,mType in pairs(classTablePrev.Adjustments._children) do
    for _,sType in pairs(classTablePrev.Adjustments[mType]._children) do
     local change = -1*tonumber(classTablePrev.Adjustments[mType][sType])
     if mType == 'Attribute'  then unitFunctions.changeAttribute( unit,sType,change,0,'class') end
     if mType == 'Resistance' then unitFunctions.changeResistance(unit,sType,change,0,'class') end
     if mType == 'Skill'      then unitFunctions.changeSkill(     unit,sType,change,0,'class') end
     if mType == 'Stat'       then unitFunctions.changeStat(      unit,sType,change,0,'class') end
     if mType == 'Trait'      then unitFunctions.changeTrait(     unit,sType,change,0,'class') end
    end
   end
  end
  -- Then add this levels adjustments
  for _,mType in pairs(classTableLevel.Adjustments._children) do
   for _,sType in pairs(classTableLevel.Adjustments[mType]._children) do
    local change = tonumber(classTableLevel.Adjustments[mType][sType])
    if mType == 'Attribute'  then unitFunctions.changeAttribute( unit,sType,change,0,'class') end
    if mType == 'Resistance' then unitFunctions.changeResistance(unit,sType,change,0,'class') end
    if mType == 'Skill'      then unitFunctions.changeSkill(     unit,sType,change,0,'class') end
    if mType == 'Stat'       then unitFunctions.changeStat(      unit,sType,change,0,'class') end
    if mType == 'Trait'      then unitFunctions.changeTrait(     unit,sType,change,0,'class') end
   end
  end
 end

 -- Check if this level gives feat points
 if classTableLevel.FeatPoints and tonumber(classTableLevel.FeatPoints) then
  unitTable.Feats.Points = tostring(tonumber(classTableLevel.FeatPoints) + tonumber(unitTable.Feats.Points))
 end

 -- Check for spells learned this level
 for _,spell in pairs(classTable.Spells._children) do
  local spellTable = classTable.Spells[spell]
  if level + 1 >= tonumber(spellTable.RequiredLevel) then
   if spellTable.AutoLearn then
    changeSpell(unit,spell,'learn',verbose)
   end
  end
 end

 -- Check if the class auto upgrades at max level
 if maxLevel then
  if verbose then print('Maximum level for class '..classTable.Name..' reached!') end
  if classTable.AutoUpgrade then
   if verbose then print('Auto upgrading class to '..classPersist[classTable.AutoUpgrade].Name) end
   changeClass(unit,classTable.AutoUpgrade,verbose)
  end
 end

 return true
end

function changeClass(unit,change,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 classPersist = persistTable.GlobalTable.roses.ClassTable

 -- Check if unit passed is unit ID or unit struct
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 -- Make sure unit has a valid UnitTable, create if they don't
 if not unitPersist[tostring(unit.id)] then
  dfhack.script_environment('functions/unit').makeUnitTable(unit)
 end
 local unitTable = unitPersist[tostring(unit.id)]

 -- Check that not already the class to change into
 if unitTable.Classes.Current == change then
  if verbose then print('Already this class: '..change) end
  return false
 end

 -- Check that the class to change into exists
 local nextClassTable = classPersist[change]
 if not nextClassTable then
  if verbose then print('No such class to change into: '..change) end
  return false
 end

 -- Check that the unit meets the class requirements
 if not checkRequirementsClass(unit,change,verbose) then
  if verbose then print('Does not meet class requirements') end
  return false
 end

 -- If unit has a class already remove the class changes 
 if unitTable.Classes.Current ~= 'NONE' then
  local currentClassTable = classPersist[unitTable.Classes.Current]
  local currentUnitClass  = unitTable.Classes[unitTable.Classes.Current]

  -- Remove Class Name
  changeName(unit,change,'remove')

  -- Remove Level Adjustments for old class
  currentClassLevel = currentUnitClass.Level
  classLevelTable = currentClassTable.Level[currentClassLevel]
  if classLevelTable.Adjustments then
   for _,mType in pairs(classLevelTable.Adjustments._children) do
    for _,sType in pairs(classLevelTable.Adjustments[mType]._children) do
     local change = -1*tonumber(classLevelTable.Adjustments[mType][sType])
     if mType == 'Attribute'  then unitFunctions.changeAttribute( unit,sType,change,0,'class') end
     if mType == 'Resistance' then unitFunctions.changeResistance(unit,sType,change,0,'class') end
     if mType == 'Skill'      then unitFunctions.changeSkill(     unit,sType,change,0,'class') end
     if mType == 'Stat'       then unitFunctions.changeStat(      unit,sType,change,0,'class') end
     if mType == 'Trait'      then unitFunctions.changeTrait(     unit,sType,change,0,'class') end
    end
   end
  end

  -- Remove Spells and Abilities
  for _,spell in pairs(currentClassTable.Spells._children) do
   changeSpell(unit,spell,'remove',verbose)
  end
 end

 -- Check if unit was previously the new class, get correct new class level
 if unitTable.Classes[change] then
  newLevel = unitTable.Classes[change].Level
 else
  unitTable.Classes[change] = {}
  unitTable.Classes[change].Level = '0'
  unitTable.Classes[change].Experience = '0'
  unitTable.Classes[change].SkillExp = '0'
  newLevel = '0'
 end

 -- Add Level Adjustments for new class
 classLevelTable = classPersist[change].Level[newLevel]
 if classLevelTable then
  if classLevelTable.Adjustments then
   for _,mType in pairs(classLevelTable.Adjustments._children) do
    for _,sType in pairs(classLevelTable.Adjustments[mType]._children) do
     local change = tonumber(classLevelTable.Adjustments[mType][sType])
     if mType == 'Attribute'  then unitFunctions.changeAttribute( unit,sType,change,0,'class') end
     if mType == 'Resistance' then unitFunctions.changeResistance(unit,sType,change,0,'class') end
     if mType == 'Skill'      then unitFunctions.changeSkill(     unit,sType,change,0,'class') end
     if mType == 'Stat'       then unitFunctions.changeStat(      unit,sType,change,0,'class') end
     if mType == 'Trait'      then unitFunctions.changeTrait(     unit,sType,change,0,'class') end
    end
   end
  end
 end

 -- Add new class name to unit
 changeName(unit,change,'add')

 -- Add new class spells to unit
 for _,spell in pairs(classPersist[change].Spells._children) do
  local spellTable = classPersist[change].Spells[spell]
  if level + 1 > tonumber(spellTable.RequiredLevel) then
   if spellTable.AutoLearn then
    changeSpell(unit,spell,'learn',verbose)
   elseif unitTable.Spells[spell] then
    changeSpell(unit,spell,'add',verbose)
   end
  end
 end

 -- Finally Change Current Class Table
 unitTable.Classes.Current = change

 if verbose then print('Class change successful!') end
 return true
end

function changeName(unit,name,direction,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if direction == 'add' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,name,'add',0)
 elseif direction == 'remove' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,name,'erase',0)
 elseif direction == 'removeall' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,'CLASS_NAME','eraseClass',0)
 end
end

function changeSpell(unit,spell,direction,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 classPersist = persistTable.GlobalTable.roses.ClassTable
 spellPersist = persistTable.GlobalTable.roses.SpellTable

 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unitPersist[tostring(unit.id)] then
  dfhack.script_environment('functions/unit').makeUnitTable(unit)
 end
 unitTable = unitPersist[tostring(unit.id)]

 if direction == 'learn' and unitTable.Spells[spell] then direction = 'add' end

 -- Check if we are adding the spell to the unit
 if direction == 'add' then
  test, upgrade = checkRequirementsSpell(unit,spell,verbose)
  if test then
   dfhack.script_environment('functions/unit').changeSyndrome(unit,spell,'add',0)
   unitTable.Spells.Active[spell] = spell
  end
  if upgrade then
   dfhack.script_environment('functions/unit').changeSyndrome(unit,upgrade,'erase',0)
   unitTable.Spells.Active[upgrade] = nil
  end
 end

 -- Check if we are removing the spell from the unit
 if direction == 'remove' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,spell,'erase',0)
  unitTable.Spells.Active[spell] = nil
 end

 -- Check if the unit is learning the spell 
 if direction == 'learn' then
  currentClassName = unitTable.Classes.Current
  if not classPersist[currentClassName] then return false end
  currentClass = unitTable.Classes[currentClassName]
  if unitTable.Spells.Active[spell] then
   if verbose then print('Spell already known and active') return end
  end
  test, upgrade = checkRequirementsSpell(unit,spell,verbose)
  if test then
   if verbose then print('Spell learned, adding to unit') end
   unitTable.Spells[spell] = '1'
   dfhack.script_environment('functions/unit').changeSyndrome(unit,spell,'add',0)
   unitTable.Spells.Active[spell] = spell
   if spellPersist[spell] then
    currentClass.SkillExp = tostring(tonumber(currentClass.SkillExp) - tonumber(spellPersist[spell].Cost))
   end
  end
  if upgrade then
   dfhack.script_environment('functions/unit').changeSyndrome(unit,upgrade,'erase',0)
   unitTable.Spells.Active[upgrade] = nil
  end
 end

 -- Bypass spell requirements and just learn/add to unit
 if direction == 'force' then
  unitTable.Spells[spell] = '1'
  dfhack.script_environment('functions/unit').changeSyndrome(unit,spell,'add',0)
  unitTable.Spells.Active[spell] = spell
 end
end

function checkRequirementsClass(unit,check,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 classPersist = persistTable.GlobalTable.roses.ClassTable

 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unitPersist[tostring(unit.id)] then 
  dfhack.script_environment('functions/unit').makeUnitTable(unit)
 end
 unitTable = unitPersist[tostring(unit.id)]
 unitClasses = unitTable.Classes
 unitInfo = dfhack.script_environment('functions/unit').getUnitTable(unit)

 if not classPersist[check] then
  if verbose then print ('No specified class to check for requirements') end
  return false
 end
 classTable = classPersist[check]

 -- Check for Required Class
 if classTable.RequiredClass then
  for _,class in pairs(classTable.RequiredClass._children) do
   if not unitClasses[class] then return false end
   local classLevel = unitClasses[class].Level
   local checkLevel = classTable.RequiredClass[class]
   if tonumber(classLevel) < tonumber(checkLevel) then
    if verbose then print('Class requirements not met. '..class..' level '..checkLevel..' needed. Current level is '..tostring(classLevel)) end
    return false
   end
  end
 end

-- Check for Forbidden Class
 if classTable.ForbiddenClass then 
  for _,class in pairs(classTable.ForbiddenClass._children) do
   if unitClasses[class] then
    local classLevel = unitClasses[class].Level
    local checkLevel = classTable.ForbiddenClass[class]
    if tonumber(classLevel) >= tonumber(checkLevel) and tonumber(checkLevel) ~= 0 then
     if verbose then print('Already a member of a forbidden class. '..class) end
     return false
    end
   end
  end
 end

-- Check for Required Attributes
 if classTable.RequiredAttribute then
  for _,attr in pairs(classTable.RequiredAttribute._children) do
   local unitsValue = unitInfo.Attributes[attr].Base or 0
   local checkValue = classTable.RequiredAttribute[attr]
   if unitsValue < tonumber(checkValue) then
    if verbose then print('Attribute requirements not met. '..checkValue..' '..attr..' needed. Current amount is '..tostring(unitValue)) end
    return false
   end
  end
 end

-- Check for Required Skills
 if classTable.RequiredSkill then
  for _,skill in pairs(classTable.RequiredSkill._children) do
   local unitsValue = unitInfo.Skills[skill].Base or 0
   local checkValue = classTable.RequiredSkill[skill]
   if unitsValue < tonumber(checkValue) then
    if verbose then print('Skill requirements not met. '..checkValue..' '..attr..' needed. Current amount is '..tostring(unitValue)) end
    return false
   end
  end
 end

-- Check for Required Traits
 if classTable.RequiredTrait then
  for _,trait in pairs(classTable.RequiredTrait._children) do
   local unitsValue = unitInfo.Traits[trait].Base or 0
   local checkValue = classTable.RequiredTrait[trait]
   if unitsValue < tonumber(checkValue) then
    if verbose then print('Trait requirements not met. '..checkValue..' '..attr..' needed. Current amount is '..tostring(unitValue)) end
    return false
   end
  end
 end

 return true
end

function checkRequirementsSpell(unit,check,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 classPersist = persistTable.GlobalTable.roses.ClassTable
 spellPersist = persistTable.GlobalTable.roses.SpellTable

 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unitPersist[tostring(unit.id)] then 
  dfhack.script_environment('functions/unit').makeUnitTable(unit)
 end
 unitTable = unitPersist[tostring(unit.id)]
 unitClassTable = unitTable.Classes[unitTable.Classes.Current]
 unitInfo = dfhack.script_environment('functions/unit').getUnitTable(unit)
 classTable = classPersist[unitTable.Classes.Current]

 if not spellPersist[check] then
  if verbose then print ('No specified spell to check for requirements') end
  return false
 end
 spellTable = spellPersist[check]

 -- Check if the spell is class restricted
 if spellTable.ClassRestricted then
  if not classTable then return false end
  if not classTable.Spells[spell] then return false end
 end

 -- Check for Required Class
 if spellTable.RequiredClass then
  for _,class in pairs(spellTable.RequiredClass._children) do
   if unitTable.Classes[class] then
    if tonumber(unitTable[class].Level) < tonumber(spellTable.RequiredClass[class]) then
     return false
    end
   else
    return false
   end
  end
 end

 -- Check for Forbidden Class
 if spellTable.ForbiddenClass then
  for _,class in pairs(spellTable.ForbiddenClass._children) do
   if unitTable.Classes[class] then
    return false
   end
  end
 end

 -- Check for Required Spell
 if spellTable.RequiredSpell then
  for _,spell in pairs(spellTable.RequiredSpell._children) do
   if not unitTable.Spells[spell] then
    return false
   end
  end
 end

 -- Check for Forbidden Spell
 if spellTable.ForbiddenSpell then
  for _,spell in pairs(spellTable.ForbiddenSpell._children) do
   if unitTable.Spells[spell] then
    return false
   end
  end
 end

 -- Check for Required Attribute
 if spellTable.RequiredAttribute then
  for _,attr in pairs(spellTable.RequiredAttribute._children) do
   if unitInfo.Attributes[attr].Base < tonumber(spellTable.RequiredAttribute[attr]) then
    return false
   end
  end
 end

 -- Check for Cost
 if spellTable.Cost then
  if tonumber(unitClassTable.SkillExp) < tonumber(spellTable.Cost) then
   if verbose then print('Not enough points to learn spell. Needed '..spellTable.Cost..' currently have '..unitClassTable.SkillExp) end
   return false
  end
 end

 -- Check if it is a Spell Upgrade
 upgrade = nil
 if spellTable.Upgrade then upgrade = spellTable.Upgrade end

 return true, upgrade
end

--=                     Class System - Feat Functions
usages[#usages+1] = [===[

Class System Feat Functions 
===========================

addFeat(unit,feat)
  Purpose: Add a feat to the unit
  Calls:   checkRequirementsFeat
  Inputs:
           unit = The unit struct or unit ID to make the table for
           feat = The FEAT_TOKEN to add
  Returns: NONE

]===]

function addFeat(unit,feat,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 featPersist = persistTable.GlobalTable.roses.FeatTable

 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unitPersist[tostring(unit.id)] then return end
 unitFeats = unitPersist[tostring(unit.id)].Feats

 featTable = featPersist[feat]
 if not featTable then
  if verbose then print('Not a valid feat: '..feat) end
  return
 end

 test = checkRequirementsFeat(unit,feat,verbose)
 if test then
  unitFeats[feat] = 'true'
  unitFeats.Points = tostring(tonumber(unitFeats.Points) - tonumber(featTable.Cost))
  for _,x in pairs(featTable.Script._children) do
   effect = featTable.Script[x]
   effect = effect:gsub('UNIT_ID',key)
   dfhack.run_command(effect)
  end
 end
end

function checkRequirementsFeat(unit,feat,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 unitPersist = persistTable.GlobalTable.roses.UnitTable
 featPersist = persistTable.GlobalTable.roses.FeatTable

 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unitPersist[tostring(unit.id)] then return end
 unitTable = unitPersist[tostring(unit.id)]
 unitFeats = unitTable.Feats
 unitClasses = unitTable.Classes

 featTable = featPersist[feat]
 if not featTable then
  if verbose then print('Not a valid feat: '..feat) end
  return
 end

 if tonumber(featTable.Cost) > tonumber(unitFeats.Points) then
  if verbose then print('Not enough feat points to learn feat') end
  return false
 end

 if featTable.ForbiddenClass then
  for _,class in pairs(featTable.ForbiddenClass._children) do
   level = featTable.ForbiddenClass[class]
   if unitClasses[class] then
    if tonumber(level) < tonumber(unitClasses[class].Level) then
     if verbose then print('Unit has too many levels in a forbidden class') end
     return false
    end
   end
  end
 end

 if featTable.ForbiddenFeat then
  for _,forbiddenFeat in pairs(featTable.ForbiddenFeat._children) do
   if unitFeats[forbiddenFeat] then
    if verbose then print('Unit has a forbidden feat') end
    return false
   end
  end
 end

 if featTable.RequiredFeat then
  for _,requiredFeat in pairs(featTable.RequiredFeat._children) do
   if not unitFeats[requiredFeat] then
    if verbose then print('Unit does not have the required feat') end
    return false
   end
  end
 end

 if featTable.RequiredClass then
  for _,class in pairs(featTable.RequiredClass._children) do
   level = featTable.RequiredClass[class]
   if not unitClasses[class] then
    if verbose then print('Unit does not have the required class') end
    return false
   else
    if tonumber(level) > tonumber(unitClasses[class].Level) then
     if verbose then print('Unit does not have the required level of required class') end
     return false
    end
   end
  end
 end

 return true
end

--=                     Class System - Spell Functions
usages[#usages+1] = [===[

Class System Spell Functions 
============================

changeSpell(unit,spell,direction)
  Purpose: Make a unit learn or unlearn a specific spell
  Calls:   checkRequirementsSpell
  Inputs:
           unit      = The unit struct or unit ID to make the table for
           spell     = The SPELL_TOKEN to modify
           direction = Learn/Unlearn the spell
  Returns: NONE

]===]


