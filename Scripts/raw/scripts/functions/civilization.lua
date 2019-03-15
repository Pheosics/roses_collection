-- Functions to be used with the Civilization System, v42.06a
local utils = require 'utils'
split = utils.split_string
usages = {}

--=                     Civilization System Table Functions
usages[#usages+1] = [===[

Civilization System Table Functions 
===================================

getData(test)
  Purpose: Read data from the entity files 
  Calls:   NONE
  Inputs:
           test  = True/False
  Returns: Tables containing information from files

makeCivilizationTable(test)
  Purpose: Create Civilization system persistent table
  Calls:   getData
  Inputs:
           test = True/False
  Returns: Boolean whether the table was successfully made

]===]

function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function getData(test,verbose)
 if verbose then print('Searching for Civilization information in entity files') end
 local filename = 'entity'
 local tokenCheck = '[ENTITY'
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/'}
 local n = 1 
 if test then 
  filename = filename..'_test'
  locations = {'/raw/systems/Test/'} 
 end
 for _,location in ipairs(locations) do
  local path = dir..location
  if verbose then print('Looking in '..location) end
  if dfhack.internal.getDir(path) then
   for _,fname in pairs(dfhack.internal.getDir(path)) do
    if (split(fname,'_')[1] == filename or fname == filename..'.txt') and string.match(fname,'txt') then
     files[n] = path..fname
     n = n + 1
    end
   end
  end
 end

 if #files >= 1 and verbose then
  print('Civilization files found:')
  printall(files)
 elseif verbose then
  print('No Civilization files found')
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
  count = 1
  endline = 1
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

function makeCivilizationTable(runtest,verbose)
 local Table = {}
 local numCivs = 0
 dataFiles,dataInfoFiles,files = getData(runtest,verbose)
 if not dataFiles then return numCivs end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   numCivs = numCivs + 1
   civToken  = x[1]
   startLine = x[2]
   endLine   = x[3]
   Table[civToken] = {}
   civ = Table[civToken]
   civ.Level = {}
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
     array[k] = tonumber(array[k]) or array[k]
    end
    if test == '{NAME' then
     civ.Name = array[2]
    elseif test == '{DESCRIPTION' then
     civ.Description = array[2]
    elseif test == '{LEVELS' then
     civ.Levels = array[2]
    elseif test == '{LEVEL_METHOD' then
     civ.LevelMethod = array[2]
     civ.LevelPercent = array[3]
    elseif test == '{LEVEL' then
     level = array[2]
     civ.Level[level] = {}
     civsLevel = civ.Level[level]
    elseif test == '{LEVEL_NAME' then
     civsLevel.Name = array[2]
    elseif test == '{LEVEL_REQUIREMENT' then
     civsLevel.Required = civsLevel.Required or {}
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
     end
    elseif test == '{LEVEL_REMOVE' then
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
    elseif test == '{LEVEL_ADD' then
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
      civsLevel.Add.Product = civsLevel.Add.Product or {}
      civsLevel.Add.Product[subType] = civsLevel.Add.Product[subType] or {}
      civsLevel.Add.Product[subType][array[4]] = array[5]
     end
    elseif test == '{LEVEL_CHANGE_ETHICS' then
     civsLevel.Ethics = civsLevel.Ethics or {}
     civsLevel.Ethics[array[2]] = array[3]
    elseif test == '{LEVEL_CHANGE_VALUES' then
     civsLevel.Values = civsLevel.Values or {}
     civsLevel.Values[array[2]] = array[3]
    elseif test == '{LEVEL_CHANGE_SKILLS' then
     civsLevel.Skills = civsLevel.Skills or {}
     civsLevel.Skills[array[2]] = array[3]
    elseif test == '{LEVEL_CHANGE_CLASSES' then
     civsLevel.Classes = civsLevel.Classes or {}
     civsLevel.Classes[array[2]] = array[3]
    elseif test == '{LEVEL_CHANGE_METHOD' then
     civsLevel.LevelMethod = array[2]
     civsLevel.LevelPercent = array[3]
    end
   end
  end
 end

 return numCivs, Table
end

--=                     Class System Table Functions
usages[#usages+1] = [===[

Civilization System Functions 
=============================

changeLevel(entity)
  Purpose: Increase the entities civilization level
  Calls:   NONE
  Inputs:
           entity = ENTITY_ID or Entity struct
  Returns: NONE
 
checkEntity(id,method)
  Purpose: Check if the entity has leveled up
  Calls:   queueCheck | checkRequirements
  Inputs:
           id = ENTITY_ID
           method = Current leveling method
  Returns: NONE

]===]

function changeLevel(entity,verbose)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(entity) then entity = df.global.world.entities.all[tonumber(entity)] end
 if not roses or not entity or not roses.EntityTable[entity.id] then return false end

 entityTable = roses.EntityTable[entity.id]
 entityToken = df.global.world.entities.all[entity.id].entity_raw.code
 civilizationTable = roses.CivilizationTable[entityToken]
 if civilizationTable then
  if civilizationTable.Level then
   currentLevel = entityTable.Civilization.Level
   nextLevel = currentLevel + 1
   if nextLevel > civilizationTable.Levels then return end
   entityTable.Civilization.Level = nextLevel

   if civilizationTable.Level[nextLevel] then
    if civilizationTable.Level[nextLevel].Remove then
     for mtype,depth1 in pairs(civilizationTable.Level[nextLevel].Remove) do
      for stype,depth2 in pairs(depth1) do
       for mobj,sobj in pairs(depth2) do
        dfhack.script_environment('functions/entity').changeResources(entity,mtype,stype,mobj,sobj,-1,verbose)
       end
      end
     end
    end
    if civilizationTable.Level[nextLevel].Add then
     for mtype,depth1 in pairs(civilizationTable.Level[nextLevel].Add) do
      for stype,depth2 in pairs(depth1) do
       for mobj,sobj in pairs(depth2) do
        dfhack.script_environment('functions/entity').changeResources(entity,mtype,stype,mobj,sobj,1,verbose)
       end
      end
     end
    end
    if civilizationTable.Level[nextLevel].LevelMethod then
     entityTable.Civilization.CurrentMethod = civilizationTable.Level[nextLevel].LevelMethod
     entityTable.Civilization.CurrentPercent = civilizationTable.Level[nextLevel].LevelPercent
	 queueCheck(entity.id,entityTable.Civilization.CurrentMethod,verbose)
    end
   end
  end
 end
end

function changeStanding(civ1,civ2,amount,verbose)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses then return false end
 diplomacyTable = roses.DiplomacyTable
 if diplomacyTable then
  if diplomacyTable[civ1] then
   if diplomacyTable[civ1][civ2] then
    diplomacyTable[civ1][civ2] = diplomacyTable[civ1][civ2] + amount
    diplomacyTable[civ2][civ1] = diplomacyTable[civ2][civ1] + amount
    return diplomacyTable[civ1][civ2]
   end
  end
 end
 return 0
end

function checkEntity(id,method,verbose)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses then return false end
 if not roses.EntityTable[id] then 
  dfhack.script_environment('functions/entity').makeEntityTable(id,verbose)
 end
 roses = dfhack.script_environment('base/roses-table').roses
 
 entityTable = roses.EntityTable[id].Civilization
 if entityTable then
  percent = entityTable.CurrentPercent
  if method ~= entityTable.CurrentMethod then return end
  rand = dfhack.random.new()
  rnum = rand:random(100)
  if rnum <= tonumber(percent) then
   leveled = checkRequirements(id,verbose)
   if leveled then
    changeLevel(id,1,verbose)
    if verbose then print('Civilization leveled up') end
    method = entityTable.CurrentMethod
   end
  end
 end
 queueCheck(id,method,verbose)
end

function checkRequirements(entityID,verbose)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses or not roses.EntityTable[entityID] or not roses.EntityTable[entityID].Civilization then return false end

 entity = roses.EntityTable[entityID]
 level  = entity.Civilization.Level+1
 name   = df.global.world.entities.all[entityID].entity_raw.code
 if not roses.CivilizationTable[name] then
  return false
 else
  civilization = roses.CivilizationTable[name]
 end
 if not civilization.Level[level] then return false end
 
 check = civilization.Level[level].Required
 if not check then return true end

-- Check for amount of time passed
 if check.Time then
  local x = tonumber(check.Time)
  if df.global.ui.fortress_age < x then
   return false
  end
 end

-- Check for fortress wealth
 if check.Wealth then
  for wtype,amount in pairs(check.Wealth) do
   if df.global.ui.tasks.wealth[string.lower(wtype)] then
    if df.global.ui.tasks.wealth[string.lower(wtype)] < amount then
     return false
    end
   end
  end
 end

-- Check for fortress population
 if check.Population then
  local population = 0
  local populations = df.global.world.entities.all[entityID]
  for _,n in pairs(populations) do
   population = population + df.global.world.entity_populations[n].counts
  end
  local x = tonumber(check.Population)
  if population < x then
   return false
  end
 end

-- Check for season
 season = {SPRING=0,SUMMER=1,FALL=2,WINTER=3}
 if check.Season then
  if not season[check.Season] == df.global.cur_season then
   return false
  end
 end

-- Check for trees cut
 if check.TreeCut then
  local x = check.TreeCut
  if df.global.ui.trees_removed < tonumber(x) then
   return false
  end
 end

-- Check for fortress rank
 if check.Rank then
  local x = tonumber(check.Rank)
  if df.global.ui.fortress_rank < x then
   return false
  end
 end

-- Check for progress
 if check.ProgressPopulation then
  local x = tonumber(check.ProgressPopulation)
  if df.global.ui.progress_population < x then
   return false
  end 
 end
 if check.ProgressTrade then
  local x = tonumber(check.ProgressTrade)
  if df.global.ui.progress_trade < x then
   return false
  end 
 end
 if check.ProgressProduction then
  local x = tonumber(check.ProgressProduction)
  if df.global.ui.progress_production < x then
   return false
  end 
 end

-- Check for artifacts
 if check.NumArtifacts then
  local x = tonumber(check.NumArtifacts)
  if df.global.ui.tasks.num_artifacts < x then
   return false
  end 
 end

-- Check for total deaths
 if check.TotDeaths then
  local x = tonumber(check.TotDeaths)
  if df.global.ui.tasks.total_deaths < x then
   return false
  end 
 end

-- Check for insanities
 if check.TotInsanities then
  local x = tonumber(check.TotInsanities)
  if df.global.ui.tasks.total_insanities < x then
   return false
  end 
 end

-- Check for executions
 if check.TotExecutions then
  local x = tonumber(check.TotExecutions)
  if df.global.ui.tasks.total_executions < x then
   return false
  end 
 end 

-- Check for migrant waves
 if check.MigrantWaves then
  local x = tonumber(check.MigrantWaves)
  if df.global.ui.tasks.migrant_wave_idx < x then
   return false
  end 
 end

-- Check for counter
 if check.CounterMax then
  for counter,a1 in pairs(check.CounterMax) do
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if a2 > a1 then
     return false
    end
   end
  end
 end
 if check.CounterMin then
  for counter,a1 in pairs(check.CounterMin) do
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if a2 < a1 then
     return false
    end
   end
  end
 end
 if check.CounterEqual then
  for counter,a1 in pairs(check.CounterEqual) do
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if not a2 == a1 then
     return false
    end
   end
  end
 end

-- Check for item
 if check.Item then
  for itype,Type in pairs(check.Item) do
   for isubtype,n1 in pairs(Type) do
    n2 = 0
    for _,item in pairs(df.global.world.items.other[itype]) do
     if item.subtype.ID == isubtype then n2 = n2 + 1 end
    end
    if n2 < n1 then
     return false
    end
   end
  end
 end

-- Check for building
 if check.Building then
  for building,n1 in pairs(check.Building) do
   n2 = 0
   local buildingList = df.global.world.buildings.all
   for i,x in pairs(buildingList) do
    if df.building_workshopst:is_instance(x) or df.building_furnacest:is_instance(x) then
     if x.custom_type >= 0 then
      if df.global.world.raws.buildings.all[x.custom_type].code == building then
       n2 = n2+1
      end
     end
    end
    if n2 < n1 then
     return false
    end
   end
  end
 end

-- Check for skill
 if check.Skill then
  for skill,level in pairs(check.Skill) do
   for _,unit in pairs(df.global.world.units.active) do
    if dfhack.units.getEffectiveSkill(unit,df.job_skill[skill]) < level then
     return false
    end
   end
  end 
 end

-- Check for class
 if check.Class and roses.ClassTable then
  for className,level in pairs(check.Class) do
   for _,unit in pairs(df.global.world.units.active) do
    if roses.UnitTable[unit.id] then
     if roses.UnitTable[unit.id].Classes[classname] then
      if tonumber(roses.UnitTable[unit.id].Classes[classname]) < level then
       return false
      end
     else
      return false
     end
    else
     return false
    end
   end
  end
 end

-- Check for kills
 if check.CreatureKills and roses.GlobalTable then
  for creature,Type in pairs(check.CreatureKills) do
   for caste,n1 in pairs(Type) do
    if caste == 'ALL' or caste == 'TOTAL' then
     n2 = roses.GlobalTable.Kills[creature].Total
    else
     n2 = roses.GlobalTable.Kills[creature][caste]
    end
    if n1 and n2 then
     if tonumber(n2) < n1 then
      return false
     end
    end
   end
  end
 end

 if check.EntityKills and roses.GlobalTable then
  for entity,n1 in pairs(check.EntityKills) do
   n2 = roses.GlobalTable.Kills[entity]
   if n1 and n2 then
    if tonumber(n2) < n1 then
     return false
    end
   end
  end
 end

-- Check for deaths
 if check.CreatureDeaths and roses.GlobalTable then
  for creature,Type in pairs(check.CreatureDeaths) do
   for caste,n1 in pairs(Type) do
    if caste == 'ALL' or caste == 'TOTAL' then
     n2 = roses.GlobalTable.Deaths[creature].Total
    else
     n2 = roses.GlobalTable.Deaths[creature][caste]
    end
    if n1 and n2 then
     if tonumber(n2) < n1 then
      return false
     end
    end
   end
  end
 end

 if check.EntityDeaths and roses.GlobalTable then
  for entity,n1 in pairs(check.EntityDeaths) do
   n2 = roses.GlobalTable.Deaths[entity]
   if n1 and n2 then
    if tonumber(n2) < n1 then
     return false
    end
   end
  end 
 end

-- Check for sieges
 if check.Sieges and roses.GlobalTable then
  for civ,number in pairs(check.Sieges) do
   if roses.GlobalTable.Sieges[civ] then
    if tonumber(roses.GlobalTable.Sieges[civ]) < number then
     return false
    end
   end
  end
 end

-- Check for trades
 if check.Trades and roses.GlobalTable then
  for civ,number in pairs(check.Trades) do
   if roses.GlobalTable.Trades[civ] then
    if tonumber(roses.GlobalTable.Trades[civ]) < number then
     return false
    end
   end
  end
 end

 return true
end

function queueCheck(id,method,verbose)
 if method == 'YEARLY' then
  curtick = df.global.cur_year_tick
  ticks = 1200*28*3*4-curtick
  if ticks <= 0 then ticks = 1200*28*3*4 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'YEARLY',verbose)
                                 end
                )
 elseif method == 'SEASON' then
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'SEASON',verbose)
                                 end
                )
 elseif method == 'MONTHLY' then
  curtick = df.global.cur_year_tick
  moy = curtick/(1200*28)
  ticks = math.ceil(moy)*1200*28 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'MONTHLY',verbose)
                                 end
                )
 elseif method == 'WEEKLY' then
  curtick = df.global.cur_year_tick
  woy = curtick/(1200*7)
  ticks = math.ceil(woy)*1200*7 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'WEEKLY',verbose)
                                 end
                )
 elseif method == 'DAILY' then
  curtick = df.global.cur_year_tick
  doy = curtick/1200
  ticks = math.ceil(doy)*1200 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'DAILY',verbose)
                                 end
                )
 else
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'SEASON',verbose)
                                 end
                )
 end
end
