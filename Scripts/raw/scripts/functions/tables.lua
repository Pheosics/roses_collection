--[[ List of Functions
getData(table,dirLocation,filename,tokenCheck) -- Used for getting data from text files and splitting into chunks
makeTable(array,pos,fill) -- A shortcut function for making a table out of an array

makeBaseTable() -- Base information used in all systems
makeWrapperTemplateTable() -- Wrapper Templates
makeCivilzationTable() -- Civilzation System
makeClassTable(spellcheck) -- Class System
makeFeatTable() -- Class System | Feat SubSystem
makeSpellTable() -- Class System | Spell SubSystem
makeEnhancedBuildingTable() -- Enhanced System
makeEnhancedCreatureTable() -- Enhanced System
makeEnhancedItemTable() -- Enhanced System
makeEventTable() -- Event System

makeDiplomacyTable() -- Civilization System | Diplomacy SubSystem
makeEntityTable(entity) -- Make a persistent table for the declared entity
makeGlobalTable() -- Make a global persistent table used in all systems
makeItemTable(item) -- Make a persistent table for the declared item
makeUnitTable(unit) -- Make a persistent table for the declared unit
makeUnitTableSecondary(unit,secondary) -- Add a secondary (attribute/skill/etc) table for the declared unit
makeUnitTableClass(unit,class) -- Add a class table for the declared unit
makeUnitTableSpell(unit,spell) -- Add a spell table for the declared unit
makeUnitTableSide(unit) -- Add a table tracking allegiance information for the declared unit
makeUnitTableSummon(unit) -- Add a table tracking summoning information for the declared unit
makeUnitTableTransform(unit) -- Add a table tracking transformation information for the declared unit
]]

---------------------------------------------------------------------------------------------
-------- Functions that are shared between multiple other functions in this file ------------
---------------------------------------------------------------------------------------------
function getData(table,dirLocation,filename,tokenCheck)
 --print('Searching for an '..table..' file')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/',dirLocation,'/raw/scripts/'}
 local n = 1
 for _,location in ipairs(locations) do
  local path = dir..location
--  print('Looking in '..location)
  if dfhack.internal.getDir(path) then
   for _,fname in pairs(dfhack.internal.getDir(path)) do
    if (split(fname,'_')[1] == filename or fname == filename..'.txt') the
     files[n] = path..fname
     n = n + 1
    end
   end
  end
 end
 
 if #files >= 1 then
--  print(table..' files found:')
--  printall(files)
 else
--  print('No '..table..' files found')
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
  for i,line in ipairs(data[file]) do
   if split(line,':')[1] == tokenCheck then
    dataInfo[file][count] = {split(split(line,':')[2],']')[1],i,0}
    count = count + 1
   end
  end
 end
 
 return data, dataInfo, files
end

function makeTable(array,pos,fill)
 local temp = {}
 local temptable = {select(pos,table.unpack(array))}
 local strint = '1'
 for _,v in pairs(temptable) do
  temp[strint] = v
  strint = tostring(strint+1)
 end
 if fill then
  if tonumber(strint)-1 < tonumber(fill)+1 then
   while tonumber(strint)-1 < tonumber(fill)+1 do
    temp[strint] = temp[tostring(strint-1)]
    strint = tostring(strint+1)
   end
  end
 end
 return temp
end
 
---------------------------------------------------------------------------------------------
-------- Functions for making persistent tables from text files (used in Systems) -----------
---------------------------------------------------------------------------------------------
function makeBaseTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.BaseTable = {}
 
 print('Searching for an included base file')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/','/raw/scripts/'}
 local n = 1
 for _,location in ipairs(locations) do
  local path = dir..location
--  print('Looking in '..location)
  if dfhack.internal.getDir(path) then
   for _,fname in pairs(dfhack.internal.getDir(path)) do
    if (fname == 'base.txt') then
     files[n] = path..fname
     n = n + 1
    end
   end
  end
 end
 
 base = persistTable.GlobalTable.roses.BaseTable
 base.ExperienceRadius = '-1'
 base.FeatGains = '100:25'
 base.CustomAttributes = {}
 base.CustomSkills = {}
 base.CustomResistances = {}
 base.CustomStats = {}
 if #files < 1 then
  print('No Base file found, assuming defaults')
 else
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
     base.CustomAttributes[array[2]] = array[2]
    elseif test == '[RESISTANCE' then
     resistanceTable = base.CustomResistances
     for j,x in pairs(array) do
      if j == 1 then
       a = 1
      elseif j == #array then
       resistanceTable[array[j]] = array[j]
      else
       resistanceTable[array[j]] = resistanceTable[array[j]] or {}
       resistanceTable = resistanceTable[array[j]]
      end
     end
    elseif test == '[STAT' then
     base.CustomStats[array[2]] = array[2]
    end
   end
  end
 end
end

function makeWrapperTemplateTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.WrapperTemplateTable = {}
 templates = persistTable.GlobalTable.roses.WrapperTemplateTable
 
 dataFiles,dataInfoFiles,files = getData('Wrapper Template','/raw/systems/','templates','[TEMPLATE')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
  templateToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  templates[templateToken] = {}
  template = templates[templateToken]
  template.Level = {}
  template.Positions = {}
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    template.Name = array[2]
   elseif test == '[INPUT' then
    template.Input = array[2]
   end
  end
 end
end

-- Start Civilization System Functions
function makeCivilizationTable()
 function tchelper(first, rest)
  return first:upper()..rest:lower()
 end

 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.CivilizationTable = {}
 civilizations = persistTable.GlobalTable.roses.CivilizationTable
 
 dataFiles,dataInfoFiles,files = getData('Civilization','/raw/systems/Civilizations','civilizations','[CIVILIZATION')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
  civilizationToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  civilizations[civilizationToken] = {}
  civilization = civilizations[civilizationToken]
  civilization.Level = {}
  civilization.Positions = {}
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    civilization.Name = array[2]
   elseif test == '[LEVELS' then
    civilization.Levels = array[2]
   elseif test == '[LEVEL_METHOD' then
    civilization.LevelMethod = array[2]
    civilization.LevelPercent = array[3]
   elseif test == '[LEVEL' then
    level = array[2]
    civilization.Level[level] = {}
    civsLevel = civilization.Level[level]
    civsLevel.Required = {}
   elseif test == '[LEVEL_NAME' then
    civsLevel.Name = array[2]
   elseif test == '[LEVEL_REQUIREMENT' then
    if array[2] == 'COUNTER_MAX' then
     civsLevel.Required.CounterMax = civsLevel.Required.CounterMax or {}
     civsLevel.Required.CounterMax[array[3]] = array[4]
    elseif array[2] == 'COUNTER_MIN' then
     civsLevel.Required.CounterMin = civsLevel.Required.CounterMin or {}
     civsLevel.Required.CounterMin[array[3]] = array[4]
    elseif array[2] == 'COUNTER_EQUAL' then
     civsLevel.Required.CounterEqual = civsLevel.Required.CounterEqual or {}
     civsLevel.Required.CounterEqual[array[3]] = array[4]
    elseif array[2] == 'TIME' then
     civsLevel.Required.Time = array[3]
    elseif array[2] == 'POPULATION' then
     civsLevel.Required.Population = array[3]
    elseif array[2] == 'SEASON' then
     civsLevel.Required.Season = array[3]
    elseif array[2] == 'TREES_CUT' then
     civsLevel.Required.TreeCut = array[3]
    elseif array[2] == 'FORTRESS_RANK' then
     civsLevel.Required.Rank = array[3]
    elseif array[2] == 'PROGRESS_RANK' then
     if array[3] == 'POPULATION' then civsLevel.Required.ProgressPopulation = array[4] end
     if array[3] == 'TRADE' then civsLevel.Required.ProgressTrade = array[4] end
     if array[3] == 'PRODUCTION' then civsLevel.Required.ProgressProduction = array[4] end
    elseif array[2] == 'ARTIFACTS' then
     civsLevel.Required.NumArtifacts = array[3]
    elseif array[2] == 'TOTAL_DEATHS' then
     civsLevel.Required.TotDeaths = array[3]
    elseif array[2] == 'TOTAL_INSANITIES' then
     civsLevel.Required.TotInsanities = array[3]
    elseif array[2] == 'TOTAL_EXECUTIONS' then
     civsLevel.Required.TotExecutions = array[3]
    elseif array[2] == 'MIGRANT_WAVES' then
     civsLevel.Required.MigrantWaves = array[3]
    elseif array[2] == 'WEALTH' then
     civsLevel.Required.Wealth = civsLevel.Required.Wealth or {}
     civsLevel.Required.Wealth[array[3]] = array[4]
    elseif array[2] == 'BUILDING' then
     civsLevel.Required.Building = civsLevel.Required.Building or {}
     civsLevel.Required.Building[array[3]] = array[4]
    elseif array[2] == 'SKILL' then
     civsLevel.Required.Skill = civsLevel.Required.Skill or {}
     civsLevel.Required.Skill[array[3]] = array[4]
    elseif array[2] == 'CLASS' then
     civsLevel.Required.Class = civsLevel.Required.Class or {}
     civsLevel.Required.Class[array[3]] = array[4]
    elseif array[2] == 'ENTITY_KILLS' then
     civsLevel.Required.EntityKills = civsLevel.Required.EntityKills or {}
     civsLevel.Required.EntityKills[array[3]] = array[4]
    elseif array[2] == 'CREATURE_KILLS' then
     civsLevel.Required.CreatureKills = civsLevel.Required.CreatureKills or {}
     civsLevel.Required.CreatureKills[array[3]] = civsLevel.Required.CreatureKills[array[3]] or {}
     civsLevel.Required.CreatureKills[array[3]][array[4]] = array[5]
    elseif array[2] == 'ENTITY_DEATHS' then
     civsLevel.Required.EntityDeaths = civsLevel.Required.EntityDeaths or {}
     civsLevel.Required.EntityDeaths[array[3]] = array[4]
    elseif array[2] == 'CREATURE_DEATHS' then
     civsLevel.Required.CreatureDeaths = civsLevel.Required.CreatureDeaths or {}
     civsLevel.Required.CreatureDeaths[array[3]] = civsLevel.Required.CreatureDeaths[array[3]] or {}
     civsLevel.Required.CreatureDeaths[array[3]][array[4]] = array[5]
    elseif array[2] == 'TRADES' then
     civsLevel.Required.Trades = civsLevel.Required.Trades or {}
     civsLevel.Required.Trades[array[3]] = array[4]
    elseif array[2] == 'SIEGES' then
     civsLevel.Required.Sieges = civsLevel.Required.Sieges or {}
     civsLevel.Required.Sieges[array[3]] = array[4]
    elseif array[2] == 'DIPLOMACY' then
     civsLevel.Required.Diplomacy = civsLevel.Required.Diplomacy or {}
     civsLevel.Required.Diplomacy[array[3]..':'..array[4]..':'..array[5]..':'..array[6]] = '1'
    end
   elseif test == '[LEVEL_REMOVE' then
    subType = array[3]:gsub("(%a)([%w_']*)", tchelper)
    civsLevel.Remove = civsLevel.Remove or {}
    if array[2] == 'CREATURE' then
     civsLevel.Remove.Creature = civsLevel.Remove.Creature or {}
     civsLevel.Remove.Creature[subType] = civsLevel.Remove.Creature[subType] or {}
     civsLevel.Remove.Creature[subType][array[4]] = array[5]
    elseif array[2] == 'INORGANIC' then
     civsLevel.Remove.Inorganic = civsLevel.Remove.Inorganic or {}
     civsLevel.Remove.Inorganic[subType] = civsLevel.Remove.Inorganic[subType] or {}
     civsLevel.Remove.Inorganic[subType][array[4]] = array[4]
    elseif array[2] == 'ORGANIC' then
     civsLevel.Remove.Organic = civsLevel.Remove.Organic or {}
     civsLevel.Remove.Organic[subType] = civsLevel.Remove.Organic[subType] or {}
     civsLevel.Remove.Organic[subType][array[4]] = array[5]
    elseif array[2] == 'REFUSE' then
     civsLevel.Remove.Refuse = civsLevel.Remove.Refuse or {}
     civsLevel.Remove.Refuse[subType] = civsLevel.Remove.Refuse[subType] or {}
     civsLevel.Remove.Refuse[subType][array[4]] = array[5]
    elseif array[2] == 'ITEM' then
     civsLevel.Remove.Item = civsLevel.Remove.Item or {}
     civsLevel.Remove.Item[subType] = civsLevel.Remove.Item[subType] or {}
     civsLevel.Remove.Item[subType][array[4]] = array[4]
    elseif array[2] == 'MISC' then
     civsLevel.Remove.Misc = civsLevel.Remove.Misc or {}
     civsLevel.Remove.Misc[subType] = civsLevel.Remove.Misc[subType] or {}
     civsLevel.Remove.Misc[subType][array[4]] = array[5]
    elseif array[2] == 'PRODUCT' then
     civsLevel.Remove.Product = civsLevel.Remove.Product or {}
     civsLevel.Remove.Product[subType] = civsLevel.Remove.Product[subType] or {}
     civsLevel.Remove.Product[subType][array[4]] = array[5]
    end
   elseif test == '[LEVEL_ADD' then
    subType = array[3]:gsub("(%a)([%w_']*)", tchelper)
    civsLevel.Add = civsLevel.Add or {}
    if array[2] == 'CREATURE' then
     civsLevel.Add.Creature = civsLevel.Add.Creature or {}
     civsLevel.Add.Creature[subType] = civsLevel.Add.Creature[subType] or {}
     civsLevel.Add.Creature[subType][array[4]] = array[5]
    elseif array[2] == 'INORGANIC' then
     civsLevel.Add.Inorganic = civsLevel.Add.Inorganic or {}
     civsLevel.Add.Inorganic[subType] = civsLevel.Add.Inorganic[subType] or {}
     civsLevel.Add.Inorganic[subType][array[4]] = array[4]
    elseif array[2] == 'ORGANIC' then
     civsLevel.Add.Organic = civsLevel.Add.Organic or {}
     civsLevel.Add.Organic[subType] = civsLevel.Add.Organic[subType] or {}
     civsLevel.Add.Organic[subType][array[4]] = array[5]
    elseif array[2] == 'REFUSE' then
     civsLevel.Add.Refuse = civsLevel.Add.Refuse or {}
     civsLevel.Add.Refuse[subType] = civsLevel.Add.Refuse[subType] or {}
     civsLevel.Add.Refuse[subType][array[4]] = array[5]
    elseif array[2] == 'ITEM' then
     civsLevel.Add.Item = civsLevel.Add.Item or {}
     civsLevel.Add.Item[subType] = civsLevel.Add.Item[subType] or {}
     civsLevel.Add.Item[subType][array[4]] = array[4]
    elseif array[2] == 'MISC' then
     civsLevel.Add.Misc = civsLevel.Add.Misc or {}
     civsLevel.Add.Misc[subType] = civsLevel.Add.Misc[subType] or {}
     civsLevel.Add.Misc[subType][array[4]] = array[5]
    elseif array[2] == 'PRODUCT' then
     civsLevel.Remove.Product = civsLevel.Remove.Product or {}
     civsLevel.Remove.Product[subType] = civsLevel.Remove.Product[subType] or {}
     civsLevel.Remove.Product[subType][array[4]] = array[5]
    end
   elseif testa== '[LEVEL_CHANGE_ETHICS' then
    civsLevel.Ethics = civsLevel.Ethics or {}
    civsLevel.Ethics[array[2]] = array[3]
   elseif testa== '[LEVEL_CHANGE_VALUES' then
    civsLevel.Values = civsLevel.Values or {}
    civsLevel.Values[array[2]] = array[3]
   elseif testa== '[LEVEL_CHANGE_SKILLS' then
    civsLevel.Skills = civsLevel.Skills or {}
    civsLevel.Skills[array[2]] = array[3]
   elseif testa== '[LEVEL_CHANGE_CLASSES' then
    civsLevel.Classes = civsLevel.Classes or {}
    civsLevel.Classes[array[2]] = array[3]
   elseif test == '[LEVEL_CHANGE_METHOD' then
    civsLevel.LevelMethod = array[2]
    civsLevel.LevelPercent = array[3]
   elseif test == '[LEVEL_REMOVE_POSITION' then
    civsLevel.RemovePosition = civsLevel.RemovePosition or {}
    civsLevel.RemovePosition[array[2]] = array[2]
   elseif test == '[LEVEL_ADD_POSITION' then
    civsLevel.AddPosition = civsLevel.AddPosition or {}
    position = array[2]
    civsLevel.AddPosition[position] = position
    civilization.Positions[position] = {}
    civsAddPosition = civilization.Positions[position]
    civsAddPosition.AllowedCreature = {}
    civsAddPosition.AllowedClass = {}
    civsAddPosition.RejectedCreature = {}
    civsAddPosition.RejectedClass = {}
    civsAddPosition.Responsibility = {}
    civsAddPosition.AppointedBy = {}
    civsAddPosition.Flags = {}
   elseif test == '[ALLOWED_CREATURE' then
    civsAddPosition.AllowedCreature[array[2]] = array[3]
   elseif test == '[REJECTED_CREATURE' then
    civsAddPosition.RejectedCreature[array[2]] = array[3]
   elseif test == '[ALLOWED_CLASS' then
    civsAddPosition.AllowedClass[array[2]] = array[2]
   elseif test == '[REJECTED_CLASS' then
    civsAddPosition.RejectedClass[array[2]] = array[2]
   elseif test == '[NAME' then
    civsAddPosition.Name = array[2]..':'..array[3]
   elseif test == '[NAME_MALE' then
    civsAddPosition.NameMale = array[2]..':'..array[3]
   elseif test == '[NAME_FEMALE' then
    civsAddPosition.NameFemale = array[2]..':'..array[3]
   elseif test == '[SPOUSE' then
    civsAddPosition.Spouse = array[2]..':'..array[3]
   elseif test == '[SPOUSE_MALE' then
    civsAddPosition.SpouseMale = array[2]..':'..array[3]
   elseif test == '[SPOUSE_FEMALE' then
    civsAddPosition.SpouseFemale = array[2]..':'..array[3]
   elseif test == '[NUMBER' then
    civsAddPosition.Number = array[2]
   elseif test == '[SUCCESSION' then
    civsAddPosition.Sucession = array[2]
   elseif test == '[LAND_HOLDER' then
    civsAddPosition.LandHolder = array[2]
   elseif test == '[LAND_NAME' then
    civsAddPosition.LandName = array[2]
   elseif test == '[APPOINTED_BY' then
    civsAddPosition.AppointedBy[array[2]] = array[2]
   elseif test == '[REPLACED_BY' then
    civsAddPosition.ReplacedBy = array[2]
   elseif test == '[RESPONSIBILITY' then
    civsAddPosition.Responsibility[array[2]] = array[2]
   elseif test == '[PRECEDENCE' then
    civsAddPosition.Precedence = array[2]
   elseif test == '[REQUIRES_POPULATION' then
    civsAddPosition.RequiresPopulation = array[2]
   elseif test == '[REQUIRED_BOXES' then
    civsAddPosition.RequiredBoxes = array[2]
   elseif test == '[REQUIRED_CABINETS' then
    civsAddPosition.RequiredCabinets = array[2]
   elseif test == '[REQUIRED_RACKS' then
    civsAddPosition.RequiredRacks = array[2]
   elseif test == '[REQUIRED_STANDS' then
    civsAddPosition.RequiredStands = array[2]
   elseif test == '[REQUIRED_OFFICE' then
    civsAddPosition.RequiredOffice = array[2]
   elseif test == '[REQUIRED_BEDROOM' then
    civsAddPosition.RequiredBedroom = array[2]
   elseif test == '[REQUIRED_DINING' then
    civsAddPosition.RequiredDining = array[2]
   elseif test == '[REQUIRED_TOMB' then
    civsAddPosition.RequiredTomb = array[2]
   elseif test == '[MANDATE_MAX' then
    civsAddPosition.MandateMax = array[2]
   elseif test == '[DEMAND_MAX' then
    civsAddPosition.DemandMax = array[2]
   elseif test == '[COLOR' then
    civsAddPosition.Color = array[2]..':'..array[3]..':'..array[4]
   elseif test == '[SQUAD' then
    civsAddPosition.Squad = array[2]..':'..array[3]..':'..array[4]
   elseif test == '[COMMANDER' then
    civsAddPosition.Commander = array[2]..':'..array[3]
   elseif test == '[FLAGS' then
    civsAddPosition.Flags[array[2]] = 'true'
   else
    if position then civsAddPosition[split(split(data[j],']')[1],'%[')[2]] = 'true' end
   end
  end
 end
 end

 for id,entity in pairs(df.global.world.entities.all) do
  makeEntityTable(id)
 end

 return true
end
-- End Civilization System Functions
   
-- Start Class System Functions
function makeClassTable(spellCheck)
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.ClassTable = {}
 classes = persistTable.GlobalTable.roses.ClassTable
 if not spellCheck then
--  print('Generating spell tables from class files')
  persistTable.GlobalTable.roses.SpellTable = {}
 end
 
 dataFiles,dataInfoFiles,files = getData('Class','/raw/systems/Classes','classes','[CLASS')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   classToken = x[1]
   startLine = x[2]+1
   if i ==#dataInfo then
    endLine = #data
   else
    endLine = dataInfo[i+1][2]-1
   end
   classes[classToken] = {}
   class = classes[classToken]
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    if test == '[NAME' then
     class.Name = split(split(data[j],':')[2],']')[1]
    elseif test == '[LEVELS' then
     class.Levels = split(split(data[j],':')[2],']')[1]
    end
    if class.Name and class.Levels then break end
   end
   class.Spells = {}
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[AUTO_UPGRADE' then
     class.AutoUpgrade = array[2]
    elseif test == '[EXP' then
     class.Experience = {}
     local temptable = {select(2,table.unpack(array))}
     strint = '1'
     for _,v in pairs(temptable) do
      class.Experience[strint] = v
      strint = tostring(strint+1)
     end
     if tonumber(strint)-1 < tonumber(class.Levels) then
      print('Incorrect amount of experience numbers, must be equal to number of levels. Assuming linear progression for next experience level')
      while (tonumber(strint)-1) < tonumber(class.Levels) do
--    print('Incorrect amount of experience numbers, must be equal to number of levels. Assuming linear progression for next experience level')
       class.Experience[strint] = tostring(2*tonumber(class.Experience[tostring(strint-1)])-tonumber(class.Experience[tostring(strint-2)]))
       strint = tostring(tonumber(strint)+1)
      end
     end
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
    elseif test == '[REQUIREMENT_PHYS' or test == '[REQUIREMENT_MENT' or test == '[REQUIREMENT_ATTRIBUTE' then
     class.RequiredAttribute = class.RequiredAttribute or {}
     class.RequiredAttribute[array[2]] = array[3]
    elseif test == '[REQUIREMENT_CREATURE' then
     class.RequiredCreature = class.RequiredCreature or {}
     class.RequiredCreature[array[2]] = array[3]
    elseif test == '[LEVELING_BONUS' then
     class.LevelBonus = class.LevelBonus or {}
     if array[2] == 'PHYSICAL' or array[2] == 'MENTAL' or array[2] == 'ATTRIBUTE' then
      class.LevelBonus.Attribute = class.LevelBonus.Attribute or {}
      class.LevelBonus.Attribute[array[3]] = makeTable(array,4,class.Levels)
     elseif array[2] == 'SKILL' then
      class.LevelBonus.Skill = class.LevelBonus.Skill or {}
      class.LevelBonus.Skill[array[3]] = makeTable(array,4,class.Levels)
     elseif array[2] == 'RESISTANCE' then
      class.LevelBonus.Resistance = class.LevelBonus.Resistance or {}
      class.LevelBonus.Resistance[array[3]] = makeTable(array,4,class.Levels)
     elseif array[2] == 'STAT' then
      class.LevelBonus.Stat = class.LevelBonus.Stat or {}
      class.LevelBonus.Stat[array[3]] = makeTable(array,4,class.Levels)
     elseif array[2] == 'TRAIT' then
      class.LevelBonus.Trait = class.LevelBonus.Trait or {}
      class.LevelBonus.Trait[array[3]] = makeTable(array,4,class.Levels)
     end
    elseif test == '[BONUS_PHYS' or test == '[BONUS_MENT' or test == '[BONUS_ATTRIBUTE' then
     class.BonusAttribute = class.BonusAttribute or {}
     class.BonusAttribute[array[2]] = makeTable(array,3,class.Levels)
    elseif test == '[BONUS_TRAIT' then
     class.BonusTrait = class.BonusTrait or {}
     class.BonusTrait[array[2]] = makeTable(array,3,class.Levels)
    elseif test == '[BONUS_SKILL' then
     class.BonusSkill = class.BonusSkill or {}
     class.BonusSkill[array[2]] = makeTable(array,3,class.Levels)
    elseif test == '[BONUS_STAT' then
     class.BonusStat = class.BonusStat or {}
     class.BonusStat[array[2]] = makeTable(array,3,class.Levels)
    elseif test == '[BONUS_RESISTANCE' then
     class.BonusResistance = class.BonusResistance or {}
     class.BonusResistance[array[2]] = makeTable(array,3,class.Levels)
    elseif test == '[SPELL' then
     spell = array[2]
     if not spellCheck then
      persistTable.GlobalTable.roses.SpellTable[spell] = {}
      spellTable = persistTable.GlobalTable.roses.SpellTable[spell]
      spellTable.Cost = '0'
     else
      spellTable = {}
      spellTable.Cost = '0'
     end
     class.Spells[spell] = {}
     spells = class.Spells[spell]
     spells.RequiredLevel = array[3]
     if spells.RequiredLevel == 'AUTO' then
      spells.RequiredLevel = '0'
      spells.AutoLearn = 'true'
     end
    elseif test == '[SPELL_REQUIRE_PHYS' or test == '[SPELL_REQUIRE_MENT' or test == '[SPELL_REQUIRE_ATTRIBUTE' then
     spellTable.RequiredAttribute = spellTable.RequiredAttribute or {}
     spellTable.RequiredAttribute[array[2]] = array[3]
    elseif test == '[SPELL_FORBIDDEN_SPELL' then
     spellTable.ForbiddenSpell = spellTable.ForbiddenSpell or {}
     spellTable.ForbiddenSpell[array[2]] = array[2]
    elseif test == '[SPELL_FORBIDDEN_CLASS' then
     spellTable.ForbiddenClass = spellTable.ForbiddenClass or {}
     spellTable.ForbiddenClass[array[2]] = array[3]
    elseif test == '[SPELL_UPGRADE' then
     spellTable.Upgrade = array[2]
    elseif test == '[SPELL_COST' then
     spellTable.Cost = array[2]
    elseif test == '[SPELL_EXP_GAIN' then
     spellTable.ExperienceGain = array[2]
    elseif test == '[SPELL_AUTO_LEARN]' then
     spells.AutoLearn = 'true'
    end
   end
  end
 end
 return true
end

function makeSpellTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.SpellTable = {}
 spells = persistTable.GlobalTable.roses.SpellTable

 dataFiles,dataInfoFiles,files = getData('Spell','/raw/systems/Classes','spells','[SPELL')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
   spellToken = x[1]
   startLine = x[2]+1
   if i ==#dataInfo then
    endLine = #data
   else
    endLine = dataInfo[i+1][2]-1
   end
   spells[spellToken] = {}
   spell = spells[spellToken]
   spell.Cost = '0'
   spell.Script = {}
   scriptNum = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[NAME' then
     spell.Name = array[2]
    elseif test == '[DESCRIPTION' then
     spell.Description = array[2]
    elseif test == '[TYPE' then
     spell.Type = array[2]
    elseif test == '[SPHERE' then
     spell.Sphere = array[2]
    elseif test == '[SCHOOL' then
     spell.School = array[2]
    elseif test == '[DISCIPLINE' then
     spell.Discipline = array[2]
    elseif test == '[SUBDISCIPLINE' then
     spell.SubDiscipline = array[2]
    elseif test == '[LEVEL' then
     spell.Level = array[2]
    elseif test == '[EFFECT' then
     spell.Effect = array[2]
    elseif test == '[ANNOUNCEMENT' then
     spell.Announcement = array[2]
    elseif test == '[RESISTABLE' then
     spell.Resistable = array[2]
    elseif test == '[PENETRATE' then
     spell.Penetration = array[2]
    elseif test == '[HIT_MODIFIER' then
     spell.HitModifier = array[2]
    elseif test == '[HIT_MODIFIER_PERC' then
     spell.HitModifierPerc = array[2]
    elseif test == '[SOURCE_PRIMARY_ATTRIBUTES' then
     spell.SourcePrimaryAttribute = makeTable(array,2)
    elseif test == '[SOURCE_SECONDARY_ATTRIBUTES' then
     spell.SourceSecondaryAttribute = makeTable(array,2)
    elseif test == '[TARGET_PRIMARY_ATTRIBUTES' then
     spell.TargetPrimaryAttribute = makeTable(array,2)
    elseif test == '[TARGET_SECONDARY_ATTRIBUTES' then
     spell.TargetSecondaryAttribute = makeTable(array,2)
    elseif test == '[SCRIPT' then
     script = data[j]:gsub("%s+","")
     script = table.concat({select(2,table.unpack(split(script,':')))},':')
     script = string.sub(script,1,-2)
     spell.Script[scriptNum] = script
     scriptNum = scriptNum + 1
    elseif test == '[EXP_GAIN' then
     spell.ExperienceGain = array[2]
    elseif test == '[SKILL_GAIN' then
     spell.SkillGain = spell.SkillGain or {}
     spell.SkillGain[array[2]] = array[3]
    elseif test == '[UPGRADE' then
     spell.Upgrade = array[2]
    elseif test == '[COST' then
     spell.Cost = array[2]
    elseif test == '[CAST_TIME' then
     spell.CastTime = array[2]
    elseif test == '[EXHAUSTION' then
     spell.CastExhaustion = array[2]
    elseif test == '[REQUIREMENT_PHYS' or test == '[REQUIREMENT_MENT' or test == '[REQUIREMENT_ATTRIBUTE' then
     spell.RequiredAttribute = spell.RequiredAttribute or {}
     spell.RequiredAttribute[array[2]] = array[3]
    elseif test == '[FORBIDDEN_CLASS' then
     spell.ForbiddenClass = spell.ForbiddenClass or {}
     spell.ForbiddenClass[array[2]] = array[3]
    elseif test == '[FORBIDDEN_SPELL' then
     spell.ForbiddenSpell = spell.ForbiddenSpell or {}
     spell.ForbiddenSpell[array[2]] = array[3]
    end
   end
  end
 end
 return true
end
   
function makeFeatTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.FeatTable = {}
 feats = persistTable.GlobalTable.roses.FeatTable

 dataFiles,dataInfoFiles,files = getData('Feat','/raw/systems/Classes','feats','[FEAT')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
   featToken = x[1]
   startLine = x[2]+1
   if i ==#dataInfo then
    endLine = #data
   else
    endLine = dataInfo[i+1][2]-1
   end
   feats[featToken] = {}
   feat = feats[featToken]
   feat.Cost = '1'
   feat.Effect = {}
   num = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[NAME' then
     feat.Name = array[2]
    elseif test == '[DESCRIPTION' then
     feat.Description = array[2]
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
    elseif test == '[COST' then
     feat.Cost = array[2]
    elseif test == '[EFFECT' then
     script = data[j]:gsub("%s+","")
     script = table.concat({select(2,table.unpack(split(script,':')))},':')
     script = string.sub(script,1,-2)
     feat.Effect[num] = script
     num = num + 1
    end
   end
   feat.Effects = tostring(num)
  end
 end
 return true
end
-- End Class System Functions
   
-- Start Enhanced System Functions
function makeEnhancedBuildingTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.EnhancedBuildingTable = {}
 buildings = persistTable.GlobalTable.roses.EnhancedBuildingTable
 
 dataFiles,dataInfoFiles,files = getData('Enhanced Building','/raw/systems/Enhanced','Ebuildings','[BUILDING')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
  buildingToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  buildings[buildingToken] = {}
  building = buildings[buildingToken]
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    building.Name = array[2]
   elseif test == '[DESCRIPTION' then
    building.Description = array[2]
   elseif test == '[MULTI_STORY' then
    building.MultiStory = array[2]
   elseif test == '[TREE_BUILDING' then
    building.TreeBuilding = array[2]
   elseif test == '[BASEMENT' then
    building.Basement = array[2]
   elseif test == '[ROOF' then
    building.Roof = array[2]
   elseif test == '[WALLS' then
    building.Walls = array[2]
   elseif test == '[STAIRS' then
    building.Stairs = array[2]
   elseif test == '[UPGRADE' then
    building.Upgrade = array[2]
   elseif test == '[SPELL' then
    spell = array[2]
    building.Spells = building.Spells or {}
    building.Spells[spell] = {}
    building.Spells[spell].Frequency = array[3]
   elseif test == '[REQUIRED_WATER' then
    building.RequiredWater = array[2]
   elseif test == '[REQUIRED_MAGMA' then
    building.RequiredMagma = array[2]
   elseif test == '[MAX_AMOUNT' then
    building.MaxAmount = array[2]
   elseif test == '[OUTSIDE_ONLY]' then
    building.OutsideOnly = 'true'
   elseif test == '[INSIDE_ONLY]' then
    building.InsideOnly = 'true'
   elseif test == '[REQUIRED_BUILDING' then
    building.RequiredBuildings = building.RequiredBuildings or {}
    building.RequiredBuildings[array[2]] = array[3]
   elseif test == '[FORBIDDEN_BUILDING' then
    building.ForbiddenBuildings = building.ForbiddenBuildings or {}
    building.ForbiddenBuildings[array[2]] = array[3]
   end
  end
 end
end
 
function makeEnhancedCreatureTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.EnhancedCreatureTable = {}
 creatures = persistTable.GlobalTable.roses.EnhancedCreatureTable
  
 dataFiles,dataInfoFiles,files = getData('Enhanced Creature','/raw/systems/Enhanced','Ecreatures','[CREATURE')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
   dataInfo = dataInfoFiles[file]
   data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
  creatureToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  creatures[creatureToken] = {}
  creature = creatures[creatureToken]
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    creature.Name = array[2]
   elseif test == '[DESCRIPTION' then
    creature.Description = array[2]
   elseif test == '[BODY_SIZE' then
    creature.Size = {}
    creature.Size.Baby = array[2]
    creature.Size.Child = array[3]
    creature.Size.Adult = array[4]
    creature.Size.Max = array[5]
    creature.Size.Variance = array[6]
   elseif test == '[ATTRIBUTE' then
    creature.Attributes = creature.Attributes or {}
    creature.Attributes[array[2]] = {}
    creature.Attributes[array[2]]['1'] = array[3]
    creature.Attributes[array[2]]['2'] = array[4]
    creature.Attributes[array[2]]['3'] = array[5]
    creature.Attributes[array[2]]['4'] = array[6]
    creature.Attributes[array[2]]['5'] = array[7]
    creature.Attributes[array[2]]['6'] = array[8]
   elseif test == '[SKILL' then
    creature.Skills = creature.Skills or {}
    creature.Skills[array[2]] = {}
    creature.Skills[array[2]].Min = array[3]
    creature.Skills[array[2]].Max = array[4]
   elseif test == '[STAT' then
    creature.Stats = creature.Stats or {}
    creature.Stats[array[2]] = {}
    creature.Stats[array[2]].Min = array[3]
    creature.Stats[array[2]].Max = array[4]
   elseif test == '[RESISTANCE' then
    creature.Resistances = creature.Resistances or {}
    creature.Resistances[array[2]] = array[3]
   elseif test == '[CLASS' then
    creature.Classes = creature.Classes or {}
    creature.Classes[array[2]] = {}
    creature.Classes[array[2]].Level = array[3]
    creature.Classes[array[2]].Interactions = array[4]
   elseif test =='[INTERACTION' then
    creature.Interactions = creature.Interactions or {}
    creature.Interactions[array[2]] = {}
    creature.Interactions[array[2]].Probability = array[3]
   end
  end
 end
end

function makeEnhancedItemTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.EnhancedItemTable = {}
 items = persistTable.GlobalTable.roses.EnhancedItemTable
   
 dataFiles,dataInfoFiles,files = getData('Enhanced Item','/raw/systems/Enhanced','Eitems','[ITEM')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
  itemToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  items[itemToken] = {}
  item = items[itemToken]
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    item.Name = array[2]
   elseif test == '[DESCRIPTION' then
    item.Description = array[2]
   elseif test == '[ATTRIBUTE_CHANGE' then
    item.Attributes = item.Attributes or {}
    item.Attributes[array[2]] = array[3]
   elseif test == '[SKILL_CHANGE' then
    item.Skills = item.Skills or {}
    item.Skills[array[2]] = array[3]
   elseif test == '[TRAIT_CHANGE' then
    item.Traits = item.Traits or {}
    item.Traits[array[2]] = array[3]
   elseif test == '[STAT_CHANGE' then
    item.Stats = item.Stats or {}
    item.Stats[stat] = array[3]
   elseif test == '[RESISTANCE_CHANGE' then
    item.Resistances = item.Resistances or {}
    item.Resistances[array[2]] = array[3]
   elseif test == '[INTERACTION_ADD' then
    item.Interactions = item.Interactions or {}
    item.Interactions[#item.Interactions+1] = array[2]
   elseif test == '[SYNDROME_ADD' then
    item.Syndromes = item.Syndromes or {}
    item.Syndromes[#item.Syndromes+1] = array[2]      
   end
  end
 end
end   
-- End Enhanced System Functions

-- Start Event System Functions
function makeEventTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.EventTable = {}
 events = persistTable.GlobalTable.roses.EventTable
    
 dataFiles,dataInfoFiles,files = getData('Event','/raw/systems/Events','events','[EVENT')
 if not dataFiles then return false end
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
 for i,x in ipairs(dataInfo) do
  eventToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  events[eventToken] = {}
  event = events[eventToken]
  event.Effect = {}
  event.Required = {}
  event.Delay = {}
  numberOfEffects = 0
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    event.Name = array[2]
   elseif test == '[CHECK' then
    event.Check = array[2]
   elseif test == '[CHANCE' then
    event.Chance = array[2]
   elseif test == '[DELAY' then
    event.Delay[array[2]] = array[3]
   elseif test == '[REQUIREMENT' then
    if array[2] == 'COUNTER_MAX' then
     event.Required.CounterMax = event.Required.CounterMax or {}
     event.Required.CounterMax[array[3]] = array[4]
    elseif array[2] == 'COUNTER_MIN' then
     event.Required.CounterMin = event.Required.CounterMin or {}
     event.Required.CounterMin[array[3]] = array[4]
    elseif array[2] == 'COUNTER_EQUAL' then
     event.Required.CounterEqual = event.Required.CounterEqual or {}
     event.Required.CounterEqual[array[3]] = array[4]
    elseif array[2] == 'TIME' then
     event.Required.Time = array[3]
    elseif array[2] == 'POPULATION' then
     event.Required.Population = array[3]
    elseif array[2] == 'SEASON' then
     event.Required.Season = array[3]
    elseif array[2] == 'TREES_CUT' then
     event.Required.TreeCut = array[3]
    elseif array[2] == 'FORTRESS_RANK' then
     event.Required.Rank = array[3]
    elseif array[2] == 'PROGRESS_RANK' then
     if array[3] == 'POPULATION' then event.Required.ProgressPopulation = array[4] end
     if array[3] == 'TRADE' then event.Required.ProgressTrade = array[4] end
     if array[3] == 'PRODUCTION' then event.Required.ProgressProduction = array[4] end
    elseif array[2] == 'ARTIFACTS' then
     event.Required.NumArtifacts = array[3]
    elseif array[2] == 'TOTAL_DEATHS' then
     event.Required.TotDeaths = array[3]
    elseif array[2] == 'TOTAL_INSANITIES' then
     event.Required.TotInsanities = array[3]
    elseif array[2] == 'TOTAL_EXECUTIONS' then
     event.Required.TotExecutions = array[3]
    elseif array[2] == 'MIGRANT_WAVES' then
     event.Required.MigrantWaves = array[3]
    elseif array[2] == 'WEALTH' then
     event.Required.Wealth = event.Required.Wealth or {}
     event.Required.Wealth[array[3]] = array[4]
    elseif array[2] == 'BUILDING' then
     event.Required.Building = event.Required.Building or {}
     event.Required.Building[array[3]] = array[4]
    elseif array[2] == 'SKILL' then
     event.Required.Skill = event.Required.Skill or {}
     event.Required.Skill[array[3]] = array[4]
    elseif array[2] == 'CLASS' then
     event.Required.Class = event.Required.Class or {}
     event.Required.Class[array[3]] = array[4]
    elseif array[2] == 'ENTITY_KILLS' then
     event.Required.EntityKills = event.Required.EntityKills or {}
     event.Required.EntityKills[array[3]] = array[4]
    elseif array[2] == 'CREATURE_KILLS' then
     event.Required.CreatureKills = event.Required.CreatureKills or {}
     event.Required.CreatureKills[array[3]] = event.Required.CreatureKills[array[3]] or {}
     event.Required.CreatureKills[array[3]][array[4]] = array[5]
    elseif array[2] == 'ENTITY_DEATHS' then
     event.Required.EntityDeaths = event.Required.EntityDeaths or {}
     event.Required.EntityDeaths[array[3]] = array[4]
    elseif array[2] == 'CREATURE_DEATHS' then
     event.Required.CreatureDeaths = event.Required.CreatureDeaths or {}
     event.Required.CreatureDeaths[array[3]] = event.Required.CreatureDeaths[array[3]] or {}
     event.Required.CreatureDeaths[array[3]][array[4]] = array[5]
    elseif array[2] == 'TRADES' then
     event.Required.Trades = event.Required.Trades or {}
     event.Required.Trades[array[3]] = array[4]
    elseif array[2] == 'SIEGES' then
     event.Required.Sieges = event.Required.Sieges or {}
     event.Required.Sieges[array[3]] = array[4]
    elseif array[2] == 'DIPLOMACY' then
     event.Required.Diplomacy = event.Required.Diplomacy or {}
     event.Required.Diplomacy[array[3]..':'..array[4]..':'..array[5]..':'..array[6]] = '1'
    end
   elseif test == '[EFFECT' then
    number = array[2]
    numberOfEffects = numberOfEffects + 1
    event.Effect[number] = {}
    effect = event.Effect[number]
    effect.Arguments = '0'
    effect.Argument = {}
    effect.Required = {}
    effect.Script = {}
    effect.Delay = {}
    effect.Scripts = '0'
   elseif test == '[EFFECT_NAME' then
    effect.Name = array[2]
   elseif test == '[EFFECT_CHANCE' then
    effect.Chance = array[2]
   elseif test == '[EFFECT_CONTINGENT_ON' then
    effect.Contingent = array[2]
   elseif test == '[EFFECT_DELAY' then
    effect.Delay[array[2]] = array[3]
   elseif test == '[EFFECT_REQUIREMENT' then
    if array[2] == 'COUNTER_MAX' then
     effect.Required.CounterMax = effect.Required.CounterMax or {}
     effect.Required.CounterMax[array[3]] = array[4]
    elseif array[2] == 'COUNTER_MIN' then
     effect.Required.CounterMin = effect.Required.CounterMin or {}
     effect.Required.CounterMin[array[3]] = array[4]
    elseif array[2] == 'COUNTER_EQUAL' then
     effect.Required.CounterEqual = effect.Required.CounterEqual or {}
     effect.Required.CounterEqual[array[3]] = array[4]
    elseif array[2] == 'TIME' then
     effect.Required.Time = array[3]
    elseif array[2] == 'POPULATION' then
     effect.Required.Population = array[3]
    elseif array[2] == 'SEASON' then
     effect.Required.Season = array[3]
    elseif array[2] == 'TREES_CUT' then
     effect.Required.TreeCut = array[3]
    elseif array[2] == 'FORTRESS_RANK' then
     effect.Required.Rank = array[3]
    elseif array[2] == 'PROGRESS_RANK' then
     if array[3] == 'POPULATION' then effect.Required.ProgressPopulation = array[4] end
     if array[3] == 'TRADE' then effect.Required.ProgressTrade = array[4] end
     if array[3] == 'PRODUCTION' then effect.Required.ProgressProduction = array[4] end
    elseif array[2] == 'ARTIFACTS' then
     effect.Required.NumArtifacts = array[3]
    elseif array[2] == 'TOTAL_DEATHS' then
     effect.Required.TotDeaths = array[3]
    elseif array[2] == 'TOTAL_INSANITIES' then
     effect.Required.TotInsanities = array[3]
    elseif array[2] == 'TOTAL_EXECUTIONS' then
     effect.Required.TotExecutions = array[3]
    elseif array[2] == 'MIGRANT_WAVES' then
     effect.Required.MigrantWaves = array[3]
    elseif array[2] == 'WEALTH' then
     effect.Required.Wealth = effect.Required.Wealth or {}
     effect.Required.Wealth[array[3]] = array[4]
    elseif array[2] == 'BUILDING' then
     effect.Required.Building = effect.Required.Building or {}
     effect.Required.Building[array[3]] = array[4]
    elseif array[2] == 'SKILL' then
     effect.Required.Skill = effect.Required.Skill or {}
     effect.Required.Skill[array[3]] = array[4]
    elseif array[2] == 'CLASS' then
     effect.Required.Class = effect.Required.Class or {}
     effect.Required.Class[array[3]] = array[4]
    elseif array[2] == 'ENTITY_KILLS' then
     effect.Required.EntityKills = effect.Required.EntityKills or {}
     effect.Required.EntityKills[array[3]] = array[4]
    elseif array[2] == 'CREATURE_KILLS' then
     effect.Required.CreatureKills = effect.Required.CreatureKills or {}
     effect.Required.CreatureKills[array[3]] = effect.Required.CreatureKills[array[3]] or {}
     effect.Required.CreatureKills[array[3]][array[4]] = array[5]
    elseif array[2] == 'ENTITY_DEATHS' then
     effect.Required.EntityDeaths = effect.Required.EntityDeaths or {}
     effect.Required.EntityDeaths[array[3]] = array[4]
    elseif array[2] == 'CREATURE_DEATHS' then
     effect.Required.CreatureDeaths = effect.Required.CreatureDeaths or {}
     effect.Required.CreatureDeaths[array[3]] = effect.Required.CreatureDeaths[array[3]] or {}
     effect.Required.CreatureDeaths[array[3]][array[4]] = array[5]
    elseif array[2] == 'TRADES' then
     effect.Required.Trades = effect.Required.Trades or {}
     effect.Required.Trades[array[3]] = array[4]
    elseif array[2] == 'SIEGES' then
     effect.Required.Sieges = effect.Required.Sieges or {}
     effect.Required.Sieges[array[3]] = array[4]
    elseif array[2] == 'DIPLOMACY' then
     effect.Required.Diplomacy = effect.Required.Diplomacy or {}
     effect.Required.Diplomacy[array[3]..':'..array[4]..':'..array[5]..':'..array[6]] = '1'
    end
   elseif test == '[EFFECT_UNIT' then
    effect.Unit = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Unit[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_LOCATION' then
    effect.Location = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Location[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_BUILDING' then
    effect.Building = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Building[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_ITEM' then
    effect.Item = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Item[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_ARGUMENT' then
    argnumber = array[2]
    effect.Arguments = tostring(effect.Arguments + 1)
    effect.Argument[argnumber] = {}
    argument = effect.Argument[argnumber]
   elseif test == '[ARGUMENT_WEIGHTING' then
    argument.Weighting = array[2]
   elseif test == '[ARGUMENT_EQUATION' then
    argument.Equation = array[2]
   elseif test == '[ARGUMENT_VARIABLE' then
    argument.Variable = array[2]
   elseif test == '[EFFECT_SCRIPT' then
    effect.Scripts = tostring(effect.Scripts + 1)
    script = data[j]:gsub("%s+","")
    script = table.concat({select(2,table.unpack(split(script,':')))},':')
    script = string.sub(script,1,-2)
    effect.Script[effect.Scripts] = script
   end
  end
  event.Effects = tostring(numberOfEffects)
 end
 end
 return true
end
--End Event System Functions
   
---------------------------------------------------------------------------------------------
-------- Functions for making persistent tables for tracking in-game information ------------
---------------------------------------------------------------------------------------------
function makeDiplomacyTable()
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.DiplomacyTable = persistTable.GlobalTable.roses.DiplomacyTable or {}
 for _,civ1 in pairs(persistTable.GlobalTable.roses.EntityTable._children) do
  persistTable.GlobalTable.roses.DiplomacyTable[civ1] = persistTable.GlobalTable.roses.DiplomacyTable[civ1] or {}
  for _,civ2 in pairs(persistTable.GlobalTable.roses.EntityTable._children) do
   if civ1 == civ2 then
    persistTable.GlobalTable.roses.DiplomacyTable[civ1][civ2] = '1000'
   else
    persistTable.GlobalTable.roses.DiplomacyTable[civ1][civ2] = '0'
   end
  end
 end
 return true
end

function makeEntityTable(entity)
 if tonumber(entity) then
  civid = tonumber(entity)
 else
  civid = entity.id
 end
 key = tostring(civid)
 entity = df.global.world.entities.all[civid]
 local persistTable = require 'persist-table'
 local key = tostring(entity.id)
 local entity = entity.entity_raw.code
 local civilizations = persistTable.GlobalTable.roses.CivilizationTable
 local entityTable = persistTable.GlobalTable.roses.EntityTable
 if entityTable[key] then
  return
 else
  entityTable[key] = {}
  entityTable = entityTable[key]
  entityTable.Kills = {}
  entityTable.Deaths = {}
  entityTable.Trades = '0'
  entityTable.Sieges = '0'
  if civilizations then
   if civilizations[entity] then
    entityTable.Civilization = {}
    entityTable.Civilization.Name = entity
    entityTable.Civilization.Level = '0'
    entityTable.Civilization.CurrentMethod = civilizations[entity].LevelMethod
    entityTable.Civilization.CurrentPercent = civilizations[entity].LevelPercent
    entityTable.Civilization.Classes = {}
    if civilizations[entity].Level then
     if civilizations[entity].Level['0'] then
      for _,mtype in pairs(civilizations[entity].Level['0'].Remove._children) do
       local depth1 = civilizations[entity].Level['0'].Remove[mtype]
       for _,stype in pairs(depth1._children) do
        local depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         local sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,-1,true)
        end
       end
      end
      for _,mtype in pairs(civilizations[entity].Level['0'].Add._children) do
       local depth1 = civilizations[entity].Level['0'].Add[mtype]
       for _,stype in pairs(depth1._children) do
        local depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         local sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,1,true)
        end
       end
      end
      if civilizations[entity].Level['0'].Classes then
       for _,class in pairs(civilizations[entity].Level['0'].Classes._children) do
        level = tonumber(civilizations[entity].Level['0'].Classes[class])
        if level > 0 then
         entityTable.Civilization.Classes[class] = tostring(level)
        else
         entityTable.Civilization.Classes[class] = nil
        end
       end
      end
     end
    end
   end
  end
 end
end

function makeGlobalTable()
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.GlobalTable = {}
 persistTable.GlobalTable.roses.GlobalTable.Kills = {}
 persistTable.GlobalTable.roses.GlobalTable.Deaths = {}
 persistTable.GlobalTable.roses.GlobalTable.Trades = {}
 persistTable.GlobalTable.roses.GlobalTable.Sieges = {}
end

function makeItemTable(item)
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end
 itemID = item.id
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.ItemTable[tostring(itemID)] = {}
 itemTable = persistTable.GlobalTable.roses.ItemTable[tostring(itemID)]

 itemTable.Material = {}
 itemTable.Material.Base = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 itemTable.Material.Current = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 itemTable.Material.StatusEffects = {}

 itemTable.Quality = {}
 itemTable.Quality.Base = item.quality
 itemTable.Quality.Current = item.quality
 itemTable.Quality.StatusEffects = {}

 itemTable.Subtype = {}
 itemTable.Subtype.Base = dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id
 itemTable.Subtype.Current = dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id
 itemTable.Subtype.StatusEffects = {}

 itemTable.Stats = {}
 itemTable.Stats.Kills = '0'
end

function makeUnitTable(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)] = {}
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.SyndromeTrack = {}
 unitTable.Attributes = {}
 unitTable.Skills = {}
 unitTable.Traits = {}
 unitTable.Feats = {}
 unitTable.Resistances = {}
 unitTable.General = {}
 unitTable.Stats = {}
 unitTable.Stats.Kills = '0'
 unitTable.Stats.Deaths = '0'
 
 unitTable.Classes = {}
 if persistTable.GlobalTable.roses.ClassTable then
  unitTable.Classes.Current = {}
  unitTable.Classes.Current.Name = 'NONE'
  unitTable.Classes.Current.TotalExp = tostring(0)
  unitTable.Classes.Current.FeatPoints = tostring(0)
 end

 unitTable.Spells = {}
 if persistTable.GlobalTable.roses.SpellTable then 
  unitTable.Spells.Active = {}
 end
end

function makeUnitTableSecondary(unit,table,token)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable[table][token] = {}
 base = dfhack.script_environment('functions/enhanced').getEnhancedCreature(unit,table,token)
 unitTable[table][token].Base = base
 unitTable[table][token].Change = '0'
 unitTable[table][token].Class = '0'
 unitTable[table][token].Item = '0'
 unitTable[table][token].StatusEffects = {}    
end

function makeUnitTableClass(unit,class)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Classes[class] = {}
 unitTable.Classes[class].Level = '0'
 unitTable.Classes[class].Experience = '0'
 unitTable.Classes[class].SkillExp = '0'
end

function makeUnitTableSpell(unit,spell)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Spells[spell] = '0'
end

function makeUnitTableSide(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.General.Side = {}
 unitTable.General.Side.StatusEffects = {}
end

function makeUnitTableTransform(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.General.Transform = {}
 unitTable.General.Transform.Race = {}
 unitTable.General.Transform.Race.Base = tostring(unit.race)
 unitTable.General.Transform.Race.Current = tostring(unit.race)
 unitTable.General.Transform.Caste = {}
 unitTable.General.Transform.Caste.Base = tostring(unit.caste)
 unitTable.General.Transform.Caste.Current = tostring(unit.caste)
 unitTable.General.Transform.StatusEffects = {}
end

function makeUnitTableSummon(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.General.Summoned = {}
 unitTable.General.Summoned.Creator = tostring(-1)
 unitTable.General.Summoned.End = tostring(-1)
 unitTable.General.Summoned.Syndrome = tostring(-1)
end
