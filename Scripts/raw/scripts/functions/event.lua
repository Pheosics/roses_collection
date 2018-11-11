-- Functions for the Event System
utils = require 'utils'
split = utils.split_string
usages = {}

------------------------------------------------------------------------

function getData(test)
 print('Searching for an Event file')
 local filename = 'events'
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/Events/','/raw/scripts/'}
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
   if split(line,':')[1] == tokenCheck then
    dataInfo[file][count] = {split(split(line,':')[2],']')[1],i+1,0}
    if count > 1 then
     dataInfo[file][count-1][3] = i-1
    end
    count = count + 1
   end
  end
 end
 dataInfo[file][count-1][3] = endline

 return data, dataInfo, files
end

function makeEventTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.Event = 'false'
 dataFiles,dataInfoFiles,files = getData(test)
 if not dataFiles then return false end
 
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   eventToken = x[1]
   startLine  = x[2]
   endLine    = x[3]
   persistTable.GlobalTable.roses.EventTable[eventToken] = {}
   event = persistTable.GlobalTable.roses.EventTable[eventToken]
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
     end
    elseif test == '[EFFECT_UNIT' then
     effect.Unit = {}
     local temptable = {select(2,table.unpack(array))}
     strint = '1'
     for _,v in pairs(temptable) do
      effect.Unit[strint] = v
      strint = tostring(math.floor(strint+1))
     end
    elseif test == '[EFFECT_LOCATION' then
     effect.Location = {}
     local temptable = {select(2,table.unpack(array))}
     strint = '1'
     for _,v in pairs(temptable) do
      effect.Location[strint] = v
      strint = tostring(math.floor(strint+1))
     end
    elseif test == '[EFFECT_BUILDING' then
     effect.Building = {}
     local temptable = {select(2,table.unpack(array))}
     strint = '1'
     for _,v in pairs(temptable) do
      effect.Building[strint] = v
      strint = tostring(math.floor(strint+1))
     end
    elseif test == '[EFFECT_ITEM' then
     effect.Item = {}
     local temptable = {select(2,table.unpack(array))}
     strint = '1'
     for _,v in pairs(temptable) do
      effect.Item[strint] = v
      strint = tostring(math.floor(strint+1))
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
     effect.Scripts = tostring(math.floor(effect.Scripts + 1))
     script = data[j]:gsub("%s+"," ")
     script = table.concat({select(2,table.unpack(split(script,':')))},':')
     script = string.sub(script,1,-2)
     effect.Script[effect.Scripts] = script
    end
   end
   event.Effects = tostring(numberOfEffects)
  end
 end

 persistTable.GlobalTable.roses.Systems.Event = 'true'
 return true
end

function checkRequirements(event,effect,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 event = persistTable.GlobalTable.roses.EventTable[event]
 if not event then return false  end

 yes = true
 if effect == 0 or effect == nil then
  check = event.Required
  chance = tonumber(event.Chance)
 else
  check = event.Effect[tostring(effect)].Required
  chance = tonumber(event.Effect[tostring(effect)].Chance)
  if not chance then chance = tonumber(event.Chance) end
 end
 if not check then return false end
-- Check for chance occurance
 if not chance then chance = 0 end
 local rand = dfhack.random.new()
 local rnum = rand:random(100)
 if rnum > chance then
  return false
 end
-- Check for amount of time passed
 if check.Time then
  local x = tonumber(check.Time)
  if df.global.ui.fortress_age < x then
   return false
  end
 end
-- Check for fortress wealth
 if check.Wealth then
  for _,wtype in pairs(check.Wealth._children) do
   local amount = tonumber(check.Wealth[wtype])
   if df.global.ui.tasks.wealth[string.lower(wtype)] then
    if df.global.ui.tasks.wealth[string.lower(wtype)] < amount then
     return false
    end
   end
  end
 end
-- Check for fortress population
 if check.Population then
  local x = tonumber(check.Population)
  if df.global.ui.tasks.population < x then
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
  for _,counter in pairs(check.CounterMax._children) do
   a1 = tonumber(check.CounterMax[counter])
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if a2 > a1 then
     return false
    end
   end
  end
 end
 if check.CounterMin then
  for _,counter in pairs(check.CounterMin._children) do
   a1 = tonumber(check.CounterMin[counter])
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if a2 < a1 then
     return false
    end
   end
  end
 end
 if check.CounterEqual then
  for _,counter in pairs(check.CounterEqual._children) do
   a1 = tonumber(check.CounterEqual[counter])
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
  for _,itype in pairs(check.Item._children) do
   for _,isubtype in pairs(check.Item[itype]._children) do
    n1 = tonumber(check.Item[itype][isubtype])
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
  for _,building in pairs(check.Building._children) do
   n1 = tonumber(check.Building[building])
   n2 = 0
   local buildingList = df.global.world.buildings.all
   for i,x in pairs(buildingList) do
    if df.building_workshopst:is_instance(x) or df.building_furnacest:is_instance(x) then
     if x.custom_type >= 0 then
      if df.global.world.raws.buildings.all[x.custom_type].code == builing then
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
  for _,skill in pairs(check.Skill._children) do
   level = tonumber(check.Skill[skill])
   for _,unit in pairs(df.global.world.units.active) do
    if dfhack.units.getEffectiveSkill(unit,df.job_skill[skill]) < level then
     return false
    end
   end
  end 
 end
-- Check for class
 if check.Class and persistTable.GlobalTable.roses.ClassTable then
  for _,classname in pairs(check.Class._children) do
   level = tonumber(check.Class[classname])
   for _,unit in pairs(df.global.world.units.active) do
    if persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)] then
     if persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)].Classes[classname] then
      if tonumber(persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)].Classes[classname]) < level then
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
 if check.CreatureKills and persistTable.GlobalTable.roses.GlobalTable then
  for _,creature in pairs(check.CreatureKills._children) do
   for _,caste in pairs(check.CreatureKills[creature]._children) do
    n1 = tonumber(check.CreatureKills[creature][caste])
    if caste == 'ALL' or caste == 'TOTAL' then
     n2 = persistTable.GlobalTable.roses.GlobalTable.Kills[creature].Total
    else
     n2 = persistTable.GlobalTable.roses.GlobalTable.Kills[creature][caste]
    end
    if n1 and n2 then
     if tonumber(n2) < n1 then
      return false
     end
    end
   end
  end
 end
 if check.EntityKills and persistTable.GlobalTable.roses.GlobalTable then
  for _,entity in pairs(check.EntityKills._children) do
   n1 = tonumber(check.EntityKills[entity])
   n2 = persistTable.GlobalTable.roses.GlobalTable.Kills[entity]
   if n1 and n2 then
    if tonumber(n2) < n1 then
     return false
    end
   end
  end
 end
-- Check for deaths
 if check.CreatureDeaths and persistTable.GlobalTable.roses.GlobalTable then
  for _,creature in pairs(check.CreatureDeaths._children) do
   for _,caste in pairs(check.CreatureDeaths[creature]._children) do
    n1 = tonumber(check.CreatureDeaths[creature][caste])
    if caste == 'ALL' or caste == 'TOTAL' then
     n2 = persistTable.GlobalTable.roses.GlobalTable.Deaths[creature].Total
    else
     n2 = persistTable.GlobalTable.roses.GlobalTable.Deaths[creature][caste]
    end
    if n1 and n2 then
     if tonumber(n2) < n1 then
      return false
     end
    end
   end
  end
 end
 if check.EntityDeaths and persistTable.GlobalTable.roses.GlobalTable then
  for _,entity in pairs(check.EntityDeaths._children) do
   n1 = tonumber(check.EntityDeaths[entity])
   n2 = persistTable.GlobalTable.roses.GlobalTable.Deaths[entity]
   if n1 and n2 then
    if tonumber(n2) < n1 then
     return false
    end
   end
  end 
 end
-- Check for sieges
 if check.Sieges and persistTable.GlobalTable.roses.GlobalTable then
  for _,civ in pairs(check.Sieges._children) do
   number = tonumber(check.Sieges[civ])
   if persistTable.GlobalTable.roses.GlobalTable.Sieges[civ] then
    if tonumber(persistTable.GlobalTable.roses.GlobalTable.Sieges[civ]) < number then
     return false
    end
   end
  end
 end
-- Check for trades
 if check.Trades and persistTable.GlobalTable.roses.GlobalTable then
  for _,civ in pairs(check.Trades._children) do
   number = tonumber(check.Trades[civ])
   if persistTable.GlobalTable.roses.GlobalTable.Trades[civ] then
    if tonumber(persistTable.GlobalTable.roses.GlobalTable.Trades[civ]) < number then
     return false
    end
   end
  end
 end
-- Check for diplomacy
 if check.Diplomacy and persistTable.GlobalTable.roses.DiplomacyTable then
  for _,dip_string in pairs(check.Diplomacy._children) do
   dip_array = split(dip_string,':')
   civ1,civ2,relation,number = dip_array[1],dip_array[2],dip_array[3],dip_array[4]
   if civ1 and civ2 and relation and number then
    score = tonumber(persistTable.GlobalTable.roses.DiplomacyTable[civ1][civ2])
    if relation == 'GREATER' then
     if score < tonumber(number) then
      return false
     end
    elseif relation == 'LESS' then
     if score > tonumber(number) then
      return false
     end
    end
   end
  end
 end
 return true
end

function triggerEvent(event,effect,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 eventTable = persistTable.GlobalTable.roses.EventTable[event]

 effect = tostring(effect)
 if not eventTable then
  if verbose then print('No such event to trigger: '..event) end
  return
 end
 effectTable = eventTable.Effect[effect]
 if not effectTable then
  if verbose then print('No such effect for given event: '..event..' - '..effect) end
  return
 end
 delay = 0
 delayTable = eventTable.Delay
 if delayTable then
  if delayTable['STATIC'] then
   delay = tonumber(delayTable['STATIC'])
  elseif delayTable['RANDOM'] then
   local rand = dfhack.random.new()
   delay = rand:random(tonumber(delayTable['RANDOM']))+1
  end
 end
 delayTable = effectTable.Delay
 if delayTable then
  if delayTable['STATIC'] then
   delay = delay + tonumber(delayTable['STATIC'])
  elseif delayTable['RANDOM'] then
   local rand = dfhack.random.new()
   delay = delay + rand:random(tonumber(delayTable['RANDOM']))+1
  end
 end
 units,buildings,locations,items = {},{},{},{}
 if effectTable.Unit then units = dfhack.script_environment('functions/unit').findUnit(effectTable.Unit) end
 if effectTable.Building then buildings = dfhack.script_environment('functions/building').findBuilding(effectTable.Building) end
 if effectTable.Location then locations = dfhack.script_environment('functions/map').findLocation(effectTable.Location) end
 if effectTable.Item then items = dfhack.script_environment('functions/item').findItem(effectTable.Item) end
 nu,nb,nl,ni = #units,#buildings,#locations,#items
 if nu == 0 then nu = 1 end
 if nb == 0 then nb = 1 end
 if nl == 0 then nl = 1 end
 if ni == 0 then ni = 1 end
 nn = nu*nb*nl*ni
 n = 1
 fill = {}
 if nn == 1 then
  fill[1] = {units[1],buildings[1],locations[1],items[1]}
 else
  for u = 1,nu do
   for b = 1,nb do
    for l = 1,nl do
     for i = 1,ni do
      fill[n] = {units[u],buildings[b],locations[l],items[i]}
      n = n + 1
     end
    end
   end
  end
 end
 for _,nscript in pairs(effectTable.Script._children) do
  for _,filler in ipairs(fill) do
   script = effectTable.Script[nscript]
   if filler[1] then script = script:gsub('EFFECT_UNIT',tostring(filler[1].id)) end
   if filler[2] then script = script:gsub('EFFECT_BUILDING',tostring(filler[2].id)) end
   if filler[3] then script = script:gsub('EFFECT_LOCATION',"[ "..tostring(filler[3].x).." "..tostring(filler[3].y).." "..tostring(filler[3].z).." ]") end
   if filler[4] then script = script:gsub('EFFECT_ITEM',tostring(filler[4].id)) end
   for _,argnum in pairs(effectTable.Argument._children) do
    argument = effectTable.Argument[argnum]
    if argument.Variable and not argument.Equation then 
     input = split(argument.Variable,',')
    elseif argument.Equation and not argument.Variable then
     input = split(argument.Equation,',')
    elseif argument.Variable and argument.Equation then
     if verbose then print('Can not have both variable and equation specified in argument: event, effect, argument = '..event..', '..effect..', '..argnum) end
     input = {}
    elseif not argument.Variable and not argument.Equation then
     if verbose then print('Neither variables or equation specified in argument: event, effect, argument = '..event..', '..effect..', '..argnum) end
     input = {}
    end
    if argument.Weighting then 
     weighting = split(argument.Weighting,',')
     weightsum = 0
     for _,nweight in pairs(weighting) do
      weightsum = weightsum + nweight
     end
    else
     weighting = {}
     for i = 1,#input do
      weighting[i] = 1
     end
     weightsum = #input
    end
    if #weighting ~= #input or #input == 0 then
     if verbose then print('Incorrect match of variables/equations and weightings in argument: event, effect, argument = '..event..', '..effect..', '..argnum) end
     switch = ''
    else
     local rando = dfhack.random.new()
     rand = rando:random(weightsum)+1
     for pick,npick in pairs(weighting) do
      if rand - npick <= 0 then
       break
      else
       rand = rand - npick
      end
     end
     if not pick then pick = 1 end
     switch = input[pick]
    end
    script = script:gsub('\\ARG_'..tostring(argnum),tostring(switch))
   end
   if delay > 0 then
    dfhack.script_environment('persist-delay').commandDelay(delay,script)
   else
    dfhack.run_command(script)
   end
  end
 end
end

function checkEvent(event,method,verbose)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 eventTable = persistTable.GlobalTable.roses.EventTable[event]

 local triggered = {}
 if checkRequirements(event,0,verbose) then
  triggered[0] = true
  for _,i in pairs(eventTable.Effect._children) do
   if checkRequirements(event,tonumber(i),verbose) then
    contingency = tonumber(eventTable.Effect[i].Contingent) or 0
    if triggered[contingency] then
     triggered[tonumber(i)] = true
     triggerEvent(event,tonumber(i),verbose)
     if verbose then print('Event effect triggered '..event) end
    end
   end
  end
 end
 queueCheck(event,method,verbose)
end

function queueCheck(id,method,verbose)
 if method == 'YEARLY' then
  curtick = df.global.cur_year_tick
  ticks = 1200*28*3*4-curtick
  if ticks <= 0 then ticks = 1200*28*3*4 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEvent(id,'YEARLY',verbose)
                                 end
                )
 elseif method == 'SEASON' then
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEvent(id,'SEASON',verbose)
                                 end
                )
 elseif method == 'MONTHLY' then
  curtick = df.global.cur_year_tick
  moy = curtick/(1200*28)
  ticks = math.ceil(moy)*1200*28 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEvent(id,'MONTHLY',verbose)
                                 end
                )
 elseif method == 'WEEKLY' then
  curtick = df.global.cur_year_tick
  woy = curtick/(1200*7)
  ticks = math.ceil(woy)*1200*7 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEvent(id,'WEEKLY',verbose)
                                 end
                )
 elseif method == 'DAILY' then
  curtick = df.global.cur_year_tick
  doy = curtick/1200
  ticks = math.ceil(doy)*1200 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEvent(id,'DAILY',verbose)
                                 end
                )
 else
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEvent(id,'SEASON',verbose) 
                                 end
                )
 end
end
