local utils = require 'utils'
split = utils.split_string
usages = {}

--=                     Enhanced System Table Functions
usages[#usages+1] = [===[
]===]

function getData(table,test)
 if table == 'Building' then
  tokenCheck = '[BUILDING'
  filename = 'building'
 elseif table == 'Creature' then
  tokenCheck = '[CREATURE'
  filename = 'creature'
 elseif table == 'Item' then
  tokenCheck = '[ITEM'
  filename = 'item'
 elseif table == 'Material' then
  tokenCheck = '[MATERIAL_TEMPLATE'
  filename = 'material_template'
 elseif table == 'Inorganic' then
  tokenCheck = '[INORGANIC'
  filename = 'inorganic'
 elseif table == 'PlantMat' then
  tokenCheck = '[PLANT'
  filename = 'plant'
 elseif table == 'AnimalMat' then
  tokenCheck = '[CREATURE'
  filename = 'creature'
 elseif table == 'Reaction' then
  tokenCheck = '[BUILDING'
  filename = 'building'
 else
  return
 end
 print('Searching for a '..table..' file')
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
   ls = split(line,':')
   if split(ls[1],'_')[1] == tokenCheck then -- Need to check for all ITEM_X and BUILDING_X tokens
    dataInfo[file][count] = {split(ls[2],']')[1],i+1,0}
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

function makeEnhancedBuildingTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.EnhancedBuilding = 'false'
 dataFiles,dataInfoFiles,files = getData('Building',test)
 if not dataFiles then return false end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   persistTable.GlobalTable.roses.EnhancedBuildingTable[token] = {}
   table = persistTable.GlobalTable.roses.EnhancedBuildingTable[token]
   table.Scripts = {}
   scripts = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
    end
    if test == '[NAME' then -- Take raw building name
     table.Name = split(array[2],']')[1]
    elseif string.sub(test,1,1) == '[' then
     -- This is here so we skip unnecessary raw tokens
     foo = 0
    elseif test == '{DESCRIPTION' then
     table.Description = array[2]
    elseif test == '{MULTI_STORY' then
     table.MultiStory = array[2]
    elseif test == '{TREE_BUILDING}' then
     table.TreeBuilding = 'true'
    elseif test == '{BASEMENT}' then
     table.Basement = 'true'
    elseif test == '{WALLS}' then
     table.Walls = 'true'
    elseif test == '{OUTSIDE_ONLY}' then
     table.OutsideOnly = 'true'
    elseif test == '{INSIDE_ONLY}' then
     table.InsideOnly = 'true'
    elseif test == '{STAIRS' then
     table.Stairs = {}
     table.Stairs.x = array[2]
     table.Stairs.y = array[3]
    elseif test == '{UPGRADE' then
     table.Upgrade = array[2]
    elseif test == '{REQUIRED_WATER' then
     table.RequiredWater = array[2]
    elseif test == '{REQUIRED_MAGMA' then
     table.RequiredMagma = array[2]
    elseif test == '{REQUIRED_BUILDING' then
     table.RequiredBuildings = table.RequiredBuildings or {}
     table.RequiredBuildings[array[2]] = array[3]
    elseif test == '{FORBIDDEN_BUILDING' then
     table.ForbiddenBuildings = table.ForbiddenBuildings or {}
     table.ForbiddenBuildings[array[2]] = array[3]
    elseif test == '{MAX_AMOUNT' then
     table.MaxAmount = array[2]
    elseif test == '{SCRIPT' or test == '{SPELL' then
     scripts = scripts + 1
     table.Scripts[tostring(scripts)] = {}
     a = data[j]
     a = table.concat({select(2,table.unpack(split(a,':')))},':')
     n = string.find(string.reverse(a),':')
     script = string.sub(a,1,-(n+1))
     frequency = string.sub(a,-(n-1),-2)
     table.Scripts[tostring(scripts)].Script = script
     table.Scripts[tostring(scripts)].Frequency = frequency
    end
   end
   if table.OutsideOnly == 'true' and table.InsideOnly == 'true' then
    table.OutsideOnly = nil
    table.InsideOnly = nil
   end
   if scripts == 0 then table.Scripts = nil end
  end
 end

 persistTable.GlobalTable.roses.Systems.EnhancedBuilding = 'true'
 return true
end

function makeEnhancedCreatureTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.EnhancedCreature = 'false'
 dataFiles,dataInfoFiles,files = getData('Creature',test)
 if not dataFiles then return false end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   tokens[token] = token
   persistTable.GlobalTable.roses.EnhancedCreatureTable[token] = {}
   persistTable.GlobalTable.roses.EnhancedCreatureTable[token]['ALL'] = {}

   for n,c in pairs(df.global.world.raws.creatures.all) do
    if token == c.creature_id then
     creatureID = n
     break
    end
   end
   if creatureID then
    for _,caste in pairs(df.global.world.raws.creatures.all[creatureID].caste) do
     casteToken = caste.caste_id
     persistTable.GlobalTable.roses.EnhancedCreatureTable[token][casteToken] = {}
    end
   end

   creature = persistTable.GlobalTable.roses.EnhancedCreatureTable[token]['ALL']
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
    end
    if test == '[CASTE' then
     caste = split(array[2],']')[1]
     creature = persistTable.GlobalTable.roses.EnhancedCreatureTable[token][caste]
    elseif test == '[SELECT_CASTE' then
     caste = split(array[2],']')[1]
     creature = persistTable.GlobalTable.roses.EnhancedCreatureTable[token][caste]
    elseif test == '[NAME' then
     creature.Name = split(array[2],']')[1]
    elseif test == '[DESCRIPTION' then
     creature.Description = split(array[2],']')[1]
    elseif string.sub(test,1,1) == '[' then
     -- This is here so we skip unnecessary raw tokens
     foo = 0
    elseif test == '{BODY_SIZE' then
     creature.Size = {}
     creature.Size.Baby = array[2]
     creature.Size.Child = array[3]
     creature.Size.Adult = array[4]
     creature.Size.Max = array[5]
     creature.Size.Variance = array[6]
    elseif test == '{ATTRIBUTE' then
     creature.Attributes = creature.Attributes or {}
     creature.Attributes[array[2]] = {}
     creature.Attributes[array[2]]['1'] = array[3]
     creature.Attributes[array[2]]['2'] = array[4] or array[3]
     creature.Attributes[array[2]]['3'] = array[5] or array[3]
     creature.Attributes[array[2]]['4'] = array[6] or array[3]
     creature.Attributes[array[2]]['5'] = array[7] or array[3]
     creature.Attributes[array[2]]['6'] = array[8] or array[3]
     creature.Attributes[array[2]]['7'] = array[9] or array[3]
    elseif test == '{NATURAL_SKILL' then
     creature.Skills = creature.Skills or {}
     creature.Skills[array[2]] = {}
     creature.Skills[array[2]].Min = array[3]
     creature.Skills[array[2]].Max = array[4] or array[3]
    elseif test == '{STAT' then
     creature.Stats = creature.Stats or {}
     creature.Stats[array[2]] = {}
     creature.Stats[array[2]].Min = array[3]
     creature.Stats[array[2]].Max = array[4] or array[3]
    elseif test == '{RESISTANCE' then
     creature.Resistances = creature.Resistances or {}
     creature.Resistances[array[2]] = array[3]
    elseif test == '{CLASS' then
     creature.Classes = creature.Classes or {}
     creature.Classes[array[2]] = {}
     creature.Classes[array[2]].Level = array[3]
     creature.Classes[array[2]].Interactions = array[4]
    elseif test =='{INTERACTION' then
     creature.Interactions = creature.Interactions or {}
     creature.Interactions[array[2]] = {}
     creature.Interactions[array[2]].Probability = array[3]
    end
   end
  end
 end

-- Copy any ALL caste data into the respective CREATURE:CASTE combo, CASTE caste data is given priority
 creatures = persistTable.GlobalTable.roses.EnhancedCreatureTable
 for _,creatureToken in pairs(tokens) do
  for n,c in pairs(df.global.world.raws.creatures.all) do
   if creatureToken == c.creature_id then
    creatureID = n
    break
   end
  end
  if creatureID then
   for _,caste in pairs(df.global.world.raws.creatures.all[creatureID].caste) do
    casteToken = caste.caste_id
    if not creatures[creatureToken][casteToken] then creatures[creatureToken][casteToken] = {} end
    if creatures[creatureToken].ALL then
     for _,x in pairs(creatures[creatureToken].ALL._children) do
      if not creatures[creatureToken][casteToken][x] then
       creatures[creatureToken][casteToken][x] = creatures[creatureToken].ALL[x]
      else
       for _,y in pairs(creatures[creatureToken].ALL[x]._children) do
        if not creatures[creatureToken][casteToken][x][y] then
         creatures[creatureToken][casteToken][x][y] = creatures[creatureToken].ALL[x][y]
        end
       end
      end
     end
    end
   end
  end
 end

 persistTable.GlobalTable.roses.Systems.EnhancedCreature = 'true'
 return true
end

function makeEnhancedItemTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.EnhancedItem = 'false'
 dataFiles,dataInfoFiles,files = getData('Item',test)
 if not dataFiles then return false end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   persistTable.GlobalTable.roses.EnhancedItemTable[token] = {}
   item = persistTable.GlobalTable.roses.EnhancedItemTable[token]
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
    end
    if     test == '[NAME' then -- Take raw item name
     item.Name = split(array[2],']')[1]
    elseif string.sub(test,1,1) == '[' then
     -- This is here so we skip unnecessary raw tokens
     foo = 0
    elseif test == '{DESCRIPTION' then
     item.Description = array[2]
    elseif test == '{CLASS' then
     item.Class = array[2]
    elseif test == '{ON_REPORT' then
     item.OnReport = item.OnReport or {}
     item.OnReport[array[2]] = {}
     onTable = item.OnReport[array[2]]
     if array[3] then
      onTable.Chance = array[3]
     else
      onTable.Chance = '100'
     end
    elseif test == '{ON_EQUIP' then
     item.OnEquip = item.OnEquip or {}
     onTable = item.OnEquip
     onTable.Chance = array[2]
    elseif test == '{ON_EQUIP}' then
     item.OnEquip = item.OnEquip or {}
     onTable = item.OnEquip
     onTable.Chance = '100'
    elseif test == '{ON_ATTACK' then
     item.OnAttack = item.OnAttack or {}
     onTable = item.OnAttack
     onTable.Chance = array[2]
    elseif test == '{ON_ATTACK}' then
     item.OnAttack = item.OnAttack or {}
     onTable = item.OnAttack
     onTable.Chance = '100'
    elseif test == '{ON_SHOOT' then
     item.OnShoot = item.OnShoot or {}
     onTable = item.OnShoot
     onTable.Chance = array[2]
    elseif test == '{ON_SHOOT}' then
     item.OnShoot = item.OnSHoot or {}
     onTable = item.OnShoot
     onTable.Chance = '100'
    elseif test == '{ON_PARRY' then
     item.OnParry = item.OnParry or {}
     onTable = item.OnParry
     onTable.Chance = array[2]
    elseif test == '{ON_PARRY}' then
     item.OnParry = item.OnParry or {}
     onTable = item.OnParry
     onTable.Chance = '100'
    elseif test == '{ON_DODGE' then
     item.OnDodge = item.OnDodge or {}
     onTable = item.OnDodge
     onTable.Chance = array[2]
    elseif test == '{ON_DODGE}' then
     item.OnDodge = item.OnDodge or {}
     onTable = item.OnDodge
     onTable.Chance = '100'
    elseif test == '{ON_BLOCK' then
     item.OnBlock = item.OnBlock or {}
     onTable = item.OnBlock
     onTable.Chance = array[2]
    elseif test == '{ON_BLOCK}' then
     item.OnBlock = item.OnBlock or {}
     onTable = item.OnBlock
     onTable.Chance = '100'
    elseif test == '{ON_WOUND' then
     item.OnWound = item.OnWound or {}
     onTable = item.OnWound
     onTable.Chance = array[2]
    elseif test == '{ON_WOUND}' then
     item.OnWound = item.OnWound or {}
     onTable = item.OnWound
     onTable.Chance = '100'
    elseif test == '{ON_PROJECTILE_MOVE}' then
     item.OnProjectileMove = item.OnProjectileMove or {}
     onTable = item.OnProjectileMove
     onTable.Chance = '100'
    elseif test == '{ON_PROJECTILE_MOVE' then
     item.OnProjectileMove = item.OnProjectileMove or {}
     onTable = item.OnProjectileMove
     onTable.Chance = array[2]
    elseif test == '{ON_PROJECTILE_HIT}' then
     item.OnProjectileHit = item.OnProjectileHit or {}
     onTable = item.OnProjectileHit
     onTable.Chance = '100'
    elseif test == '{ON_PROJECTILE_HIT' then
     item.OnProjectileHit = item.OnProjectileHit or {}
     onTable = item.OnProjectileHit
     onTable.Chance = array[2]
    elseif test == '{ON_PROJECTILE_FIRED}' then
     item.OnProjectileFired = item.OnProjectileFired or {}
     onTable = item.OnProjectileFired
     onTable.Chance = '100'
    elseif test == '{ON_PROJECTILE_FIRED' then
     item.OnProjectileFired = item.OnProjectileFired or {}
     onTable = item.OnProjectileFired
     onTable.Chance = array[2]
    elseif test == '{TRIGGER_CHANCE' then
     onTable.Chance = array[2]
    elseif test == '{ATTRIBUTE_CHANGE' then
     onTable.Attributes = onTable.Attributes or {}
     onTable.Attributes[array[2]] = array[3]
    elseif test == '{SKILL_CHANGE' then
     onTable.Skills = onTable.Skills or {}
     onTable.Skills[array[2]] = array[3]
    elseif test == '{TRAIT_CHANGE' then
     onTable.Traits = onTable.Traits or {}
     onTable.Traits[array[2]] = array[3]
    elseif test == '{STAT_CHANGE' then
     onTable.Stats = onTable.Stats or {}
     onTable.Stats[array[2]] = array[3]
    elseif test == '{RESISTANCE_CHANGE' then
     onTable.Resistances = onTable.Resistances or {}
     onTable.Resistances[array[2]] = array[3]
    elseif test == '{INTERACTION_ADD' then
     onTable.Interactions = onTable.Interactions or {}
     onTable.Interactions[#onTable.Interactions+1] = array[2]
    elseif test == '{SYNDROME_ADD' then
     onTable.Syndromes = onTable.Syndromes or {}
     onTable.Syndromes[#onTable.Syndromes+1] = array[2]
    elseif test == '{ATTACKER_ATTRIBUTE_CHANGE' then
     onTable.AttackerAttributes = onTable.AttackerAttributes or {}
     onTable.AttackerAttributes[array[2]] = array[3]
    elseif test == '{ATTACKER_SKILL_CHANGE' then
     onTable.AttackerSkills = onTable.AttackerSkills or {}
     onTable.AttackerSkills[array[2]] = array[3]
    elseif test == '{ATTACKER_TRAIT_CHANGE' then
     onTable.AttackerTraits = onTable.AttackerTraits or {}
     onTable.AttackerTraits[array[2]] = array[3]
    elseif test == '{ATTACKER_STAT_CHANGE' then
     onTable.AttackerStats = onTable.AttackerStats or {}
     onTable.AttackerStats[array[2]] = array[3]
    elseif test == '{ATTACKER_RESISTANCE_CHANGE' then
     onTable.AttackerResistances = onTable.AttackerResistances or {}
     onTable.AttackerResistances[array[2]] = array[3]
    elseif test == '{ATTACKER_INTERACTION_ADD' then
     onTable.AttackerInteractions = onTable.AttackerInteractions or {}
     onTable.AttackerInteractions[#onTable.AttackerInteractions+1] = array[2]
    elseif test == '{ATTACKER_SYNDROME_ADD' then
     onTable.AttackerSyndromes = onTable.AttackerSyndromes or {}
     onTable.AttackerSyndromes[#onTable.AttackerSyndromes+1] = array[2]
    elseif test == '{ATTACKER_CHANGE_DUR' then
     onTable.AttackerDur = array[2]
    elseif test == '{DEFENDER_ATTRIBUTE_CHANGE' then
     onTable.DefenderAttributes = onTable.DefenderAttributes or {}
     onTable.DefenderAttributes[array[2]] = array[3]
    elseif test == '{DEFENDER_SKILL_CHANGE' then
     onTable.DefenderSkills = onTable.DefenderSkills or {}
     onTable.DefenderSkills[array[2]] = array[3]
    elseif test == '{DEFENDER_TRAIT_CHANGE' then
     onTable.DefenderTraits = onTable.DefenderTraits or {}
     onTable.DefenderTraits[array[2]] = array[3]
    elseif test == '{DEFENDER_STAT_CHANGE' then
     onTable.DefenderStats = onTable.DefenderStats or {}
     onTable.DefenderStats[array[2]] = array[3]
    elseif test == '{DEFENDER_RESISTANCE_CHANGE' then
     onTable.DefenderResistances = onTable.DefenderResistances or {}
     onTable.DefenderResistances[array[2]] = array[3]
    elseif test == '{DEFENDER_INTERACTION_ADD' then
     onTable.DefenderInteractions = onTable.DefenderInteractions or {}
     onTable.DefenderInteractions[#onTable.DefenderInteractions+1] = array[2]
    elseif test == '{DEFENDER_SYNDROME_ADD' then
     onTable.DefenderSyndromes = onTable.DefenderSyndromes or {}
     onTable.DefenderSyndromes[#onTable.DefenderSyndromes+1] = array[2]
    elseif test == '{DEFENDER_CHANGE_DUR' then
     onTable.DefenderDur = array[2]
    elseif test == '{SCRIPT' or test == '{SPELL' then
     onTable.Scripts = onTable.Scripts or {}
     scripts = scripts + 1
     onTable.Scripts[tostring(scripts)] = {}
     a = data[j]
     a = table.concat({select(2,table.unpack(split(a,':')))},':')
     n = string.find(string.reverse(a),':')
     script = string.sub(a,1,-(n+1))
     chance = string.sub(a,-(n-1),-2)
     onTable.Scripts[tostring(scripts)].Script = script
     onTable.Scripts[tostring(scripts)].Chance = chance
    end
   end
  end
 end

 persistTable.GlobalTable.roses.Systems.EnhancedItem = 'true'
 return true
end


function makeEnhancedMaterialTable(test)
 persistTable.GlobalTable.roses.Systems.EnhancedMaterial = 'false'
 print('Enhanced System - Materials, not currently working')
 return false

 --materialFiles,  materialInfoFiles   materialfiles  = getData('Material' ,test)
 --inorganicFiles, inorganicInfoFiles, inorganicfiles = getData('Inorganic',test)
 --plantFiles,     plantInfoFiles,     plantfiles     = getData('PlantMat' ,test)
 --animalFiles,    animalInfoFiles,    animalfiles    = getData('AnimalMat',test)

 --persistTable.GlobalTable.roses.Systems.EnhancedMaterial = 'true'

end

function makeEnhancedReactionTable(test)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 persistTable.GlobalTable.roses.Systems.EnhancedReaction = 'false'
 dataFiles,dataInfoFiles,files = getData('Reaction',test)
 if not dataFiles then return false end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   persistTable.GlobalTable.roses.EnhancedReactionTable[token] = {}
   table = persistTable.GlobalTable.roses.EnhancedReactionTable[token]
   table.Scripts = {}
   scripts = 0
   products = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
    end
    if     test == '[NAME' then -- Take raw reaction name
     table.Name = split(array[2],']')[1]
    elseif string.sub(test,1,1) == '[' then
     -- This is here so we skip unnecessary raw tokens
     foo = 0
    elseif test == '{DESCRIPTION' then
     table.Description = array[2]
    elseif test == '{BASE_DURATION' then
     table.BaseDur = array[2]
    elseif test == '{REQUIRED_MAGMA' then
     table.RequiredMagma = array[2]
    elseif test == '{REQUIRED_WATER' then
     table.RequiredWater = array[2]
    elseif test == '[SKILL' then -- Take raw table skill
     table.Skill = split(array[2],']')[1]
    elseif test == '{SKILL' then -- OR custom table skill
     table.Skill = array[2]
    elseif test == '{ON_PRODUCT}' then
     table.OnProduct = 'true'
    elseif test == '{ON_START}' then
     table.OnStart = 'true'
    elseif test == '{ON_FINISH}' then
     table.OnFinish = 'true'
    elseif test == '{DURATION_REDUCTION' then
     table.DurReduction = {}
     table.DurReduction.Increment = array[2]
     table.DurReduction.MaxReduction = array[3]
    elseif test == '{ADDITIONAL_PRODUCT' then
     table.Products = table.Products or {}
     products = products + 1
     num = tostring(products)
     table.Products[num] = {}
     table.Products[num].Chance = array[2]
     table.Products[num].Number = array[3]
     table.Products[num].MaterialType = array[4]
     table.Products[num].MaterialSubType = array[5]
     table.Products[num].ItemType = array[6]
     table.Products[num].ItemSubType = array[7]
    elseif test == '{FREEZE}' then
     table.Frozen = 'true'
    elseif test == '{REMOVE}' then
     table.Disappear = 'true'
    elseif test == '{SCRIPT' then
     scripts = scripts + 1
     script = data[j]
     script = table.concat({select(2,table.unpack(split(script,':')))},':')
     script = string.sub(script,1,-2)
     table.Scripts[tostring(scripts)] = script
    end
   end
  end
 end

 persistTable.GlobalTable.roses.Systems.EnhancedReaction = 'true'
 return true
end

--=                     Enhanced System - Building  Functions
usages[#usages+1] = [===[
]===]

function buildingCreated(building)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 buildingEnhanced = persistTable.GlobalTable.roses.EnhancedBuildingTable
 
 ctype = building:getCustomType()
 if ctype < 0 then return end
 buildingToken = df.global.world.raws.buildings.all[ctype].code
 if not buildingEnhanced[buildingToken] then return end
 EBuilding = buildingEnhanced[buildingToken]
 
 -- Run any scripts attached to the building
 if EBuilding.Scripts then
  for _,i in pairs(EBuilding.Scripts._children) do
   x = EBuilding.Scripts[i]
   local script = x.Script
   local frequency = tonumber(x.Frequency)
   script = script:gsub('BUILDING_ID',tostring(building.id))
   script = script:gsub('BUILDING_TOKEN',buildingToken)
   script = script:gsub('BUILDING_LOCATION',""..tostring(building.centerx).." "..tostring(building.centery).." "..tostring(building.z).."")
   dfhack.run_command(script)
   if frequency > 0 then dfhack.timeout(frequency,'ticks',function () buildingTrigger(building.id,script,frequency,true) end) end
  end
 end
 
 -- Still need to figure out how to do the multi-story thing
end

function buildingDestroyed(building)
 -- Once I can do the multi-story thing in buildingCreated() I will need to figure out how to undo it
 return false
end

function buildingTrigger(buildingID,script,frequency,continue)
 if continue and df.building.find(buildingID) then
  dfhack.run_command(script)
  dfhack.timeout(frequency,'ticks', function () buildingTrigger(buildingID,script,frequency,true) end)
 end			 
end

--=                     Enhanced System - Creature Functions
usages[#usages+1] = [===[
]===]

function enhanceCreature(unit)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 creatureEnhanced = persistTable.GlobalTable.roses.EnhancedCreatureTable

 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end

 if creatureEnhanced then
  local creatureID = df.global.world.raws.creatures.all[unit.race].creature_id
  local casteID = df.global.world.raws.creatures.all[unit.race].caste[unit.caste].caste_id
  if safe_index(creatureEnhanced,creatureID,casteID) then
   if not unitPersist[tostring(unit.id)] then 
    dfhack.script_environment('functions/unit').makeUnitTable(unit)
   end
   unitTable = unitPersist[tostring(unit.id)]
   if unitTable.Enhanced then return end

   unitTable.Enhanced = 'true'
   local table = creatureEnhanced[creatureID][casteID]
   if table.Attributes   then setN(unit, 'Attributes', table.Attributes) end
   if table.Skills       then setN(unit, 'Skills', table.Skills) end
   if table.Stats        then setN(unit, 'Stats', table.Stats) end
   if table.Resistances  then setN(unit, 'Resistances', table.Resistances) end
   --if table.Size         then setSize(unit, table.Size) end
   --if table.Classes      then setClass(unit, table.Classes) end
   --if table.Interactions then setInteractions(unit, table.Interactions) end
  end
 end
end

function setN(unit,ttype, table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)

 for _,entry in pairs(table._children) do
  if not unitTable[ttype][entry] then return false end
  current = unitTable[ttype][entry]
  if ttype == 'Skills' then
   value = math.floor(math.random(table[skill].Min,table[skill].Max))
  else
   rn = math.random(0,100)
   if rn > 95 then
    value = table[entry]['7']
   elseif rn > 85 then
    value = table[entry]['6']
   elseif rn > 65 then
    value = table[entry]['5']
   elseif rn < 5 then
    value = table[entry]['1']
   elseif rn < 15 then
    value = table[entry]['2']
   elseif rn < 35 then
    value = table[entry]['3']
   else
    value = table[entry]['4']
   end
  end
  change = dfhack.script_environment('functions/misc').getChange(current,tonumber(value),'set')
  if ttype == 'Attributes' then
   dfhack.script_environment('functions/unit').changeAttribute(unit,entry,change,0,'track')
  elseif ttype == 'Stats' then
   dfhack.script_environment('functions/unit').changeStat(unit,entry,change,0,'track')
  elseif ttype == 'Resistances' then
   dfhack.script_environment('functions/unit').changeResistance(unit,entry,change,0,'track')
  elseif ttype == 'Skills' then
   dfhack.script_environment('functions/unit').changeSkill(unit,entry,change,0,'track')
  end
 end
end

function setClass(unit,table)

end

function setInteractions(unit,table)

end

function setSize(unit,table)

end

--=                     Enhanced System - Item Functions
usages[#usages+1] = [===[
]===]

function enhanceItemsInventory(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
end

function onItemEquip(item,unit)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 itemTable = persistTable.GlobalTable.roses.EnhancedItemTable

 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 if not safe_index(itemTable,item.subtype.id,'OnEquip') then return end
 itemTable = itemTable[item.subtype.id]
 onTable = itemTable.OnEquip
 if onTable.Attributes then
  for _,attribute in pairs(onTable.Attributes._children) do
   change = onTable.Attributes[attribute]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,0,'item')
  end
 end
 if onTable.Resistances then
  for _,resistance in pairs(onTable.Resistances._children) do
   change = onTable.Resistances[resistance]
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,0,'item')
  end
 end
 if onTable.Skills then
  for _,skill in pairs(onTable.Skills._children) do
   change = onTable.Skills[skill]
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'item')
  end
 end
 if onTable.Stats then
  for _,stat in pairs(onTable.Stats._children) do
   change = onTable.Stats[stat]
   dfhack.script_environment('functions/unit').changeStat(unit,stat,change,0,'item')
  end
 end
 if onTable.Traits then
  for _,trait in pairs(onTable.Traits._children) do
   change = onTable.Traits[trait]
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,0,'item')
  end
 end
 if onTable.Syndromes then
  for _,n in pairs(onTable.Syndromes._children) do
   syndrome = onTable.Syndromes[n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',0)
  end
 end
 if onTable.Interactions then
  for _,n in pairs(onTable.Interactions._children) do
   syndrome = onTable.Interactions[n]
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'forceLearn',verbose)
  end
 end
 if onTable.Scripts then
  for _,n in pairs(onTable.Scripts._children) do
   script = onTable.Scripts[n]
   dfhack.run_command(script)
  end
 end
end

function onItemUnEquip(item,unit)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 itemTable = persistTable.GlobalTable.roses.EnhancedItemTable

 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 if not safe_index(itemTable,item.subtype.id,'OnEquip') then return end
 itemTable = itemTable[item.subtype.id]
 onTable = itemTable.OnEquip
 if onTable.Attributes then
  for _,attribute in pairs(onTable.Attributes._children) do
   change = tonumber(onTable.Attributes[attribute])
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,-change,0,'item')
  end
 end
 if onTable.Resistances then
  for _,resistance in pairs(onTable.Resistances._children) do
   change = tonumber(onTable.Resistances[resistance])
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,-change,0,'item')
  end
 end
 if onTable.Skills then
  for _,skill in pairs(onTable.Skills._children) do
   change = tonumber(onTable.Skills[skill])
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,-change,0,'item')
  end
 end
 if onTable.Stats then
  for _,stat in pairs(onTable.Stats._children) do
   change = tonumber(onTable.Stats[stat])
   dfhack.script_environment('functions/unit').changeStat(unit,stat,-change,0,'item')
  end
 end
 if onTable.Traits then
  for _,trait in pairs(onTable.Traits._children) do
   change = tonumber(onTable.Traits[trait])
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,-change,0,'item')
  end
 end
 if onTable.Syndromes then
  for _,n in pairs(onTable.Syndromes._children) do
   syndrome = onTable.Syndromes[n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'erase',0)
  end
 end
 if onTable.Interactions then
  for _,n in pairs(onTable.Interactions._children) do
   syndrome = onTable.Interactions[n]
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'unlearn',verbose)
  end
 end
end

function onItemAction(item,onAction,attacker,defender,options)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 itemTable = persistTable.GlobalTable.roses.EnhancedItemTable

 if tonumber(item) then item = df.item.find(tonumber(item)) end

 if not safe_index(itemTable,item.subtype.id,onAction) then return end
 itemTable = itemTable[item.subtype.id]
 onTable = itemTable[onAction]
 chance = tonumber(onTable.Chance)
 local rand = dfhack.random.new()
 if rand:random(100) > chance then return end
 
 if attacker then if tonumber(attacker) then attacker = df.unit.find(tonumber(attacker)) end end
 if defender then if tonumber(defender) then defender = df.unit.find(tonumber(defender)) end end
 options  = options or {}
 velocity = options.velocity or 0
 accuracy = options.accuracy or 0
 wound    = options.wound    or -1
 
 for _,add in pairs({'Attacker','Defender'}) do
  unit = nil
  if add == 'Attacker' and attacker then
   unit = attacker
   dur = onTable.AttackerDur or 0
  end
  if add == 'Defender' then
   unit = defender
   dur = onTable.DefenderDur or 0  
  end
  if unit then
   dur = tonumber(dur)
   if onTable[add..'Attributes'] then
    for _,attribute in pairs(onTable[add..'Attributes']._children) do
     change = onTable[add..'Attributes'][attribute]
     dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'item')
    end
   end
   if onTable[add..'Resistances'] then
    for _,resistance in pairs(onTable[add..'Resistances']._children) do
     change = onTable[add..'Resistances'][resistance]
     dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'item')
    end
   end
   if onTable[add..'Skills'] then
    for _,skill in pairs(onTable[add..'Skills']._children) do
     change = onTable[add..'Skills'][skill]
     dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'item')
    end
   end
   if onTable[add..'Stats'] then
    for _,stat in pairs(onTable[add..'Stats']._children) do
     change = onTable[add..'Stats'][stat]
     dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'item')
    end
   end
   if onTable[add..'Traits'] then
    for _,trait in pairs(onTable[add..'Traits']._children) do
     change = onTable[add..'Traits'][trait]
     dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'item')
    end
   end
   if onTable[add..'Syndromes'] then
    for _,n in pairs(onTable[add..'Syndromes']._children) do
     syndrome = onTable[add..'Syndromes'][n]
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
   if onTable[add..'Interactions'] then
    for _,n in pairs(onTable[add..'Interactions']._children) do
     syndrome = onTable[add..'Interactions'][n]
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
  end
 end
 for _,n in pairs(onTable.Scripts._children) do
  x = onTable.Scripts[n]
  script = x.Script
  if rand:random(100) <= x.Chance then
   if attacker then script = script:gsub('SOURCE_UNIT_ID',tostring(attacker.id)) end
   if defender then script = script:gsub('TARGET_UNIT_ID',tostring(defender.id)) end
   script = script:gsub('ITEM_ID',tostring(item.id))
   script = script:gsub('ITEM_TOKEN',tostring(item.subtype.id))
   dfhack.run_command(script)
  end
 end
end

--=                     Enhanced System -Material Functions
usages[#usages+1] = [===[
]===]

function enhanceMaterialsInventory(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
end

function onMaterialEquip(item,unit)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 matTable = persistTable.GlobalTable.roses.EnhancedMaterialTable

 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local matToken = dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()
 local array = split(matToken,':')

 if array[1] == 'INORGANIC' then
  matTable = matTable.Inorganic
  if not safe_index(matTable,array[2],'OnEquip') then return end
  onTable = matTable[array[2]].OnEquip
 elseif array[1] == 'CREATURE' then
  matTable = matTable.Creature
  if not safe_index(matTable,array[2],array[3],'OnEquip') then return end
  onTable = matTable[array[2]][array[3]].OnEquip
 elseif array[1] == 'PLANT' then
  matTable = matTable.Plant
  if not safe_index(matTable,array[2],array[3],'OnEquip') then return end
  onTable = matTable[array[2]][array[3]].OnEquip
 else
  matTable = matTable.Misc
  if not safe_index(matTable,array[2],'OnEquip') then return end
  onTable = matTable[array[2]].OnEquip
 end

 if onTable.Attributes then
  for _,attribute in pairs(onTable.Attributes._children) do
   change = onTable.Attributes[attribute]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,0,'item')
  end
 end

 if onTable.Resistances then
  for _,resistance in pairs(onTable.Resistances._children) do
   change = onTable.Resistances[resistance]
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,0,'item')
  end
 end

 if onTable.Skills then
  for _,skill in pairs(onTable.Skills._children) do
   change = onTable.Skills[skill]
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'item')
  end
 end

 if onTable.Stats then
  for _,stat in pairs(onTable.Stats._children) do
   change = onTable.Stats[stat]
   dfhack.script_environment('functions/unit').changeStat(unit,stat,change,0,'item')
  end
 end

 if onTable.Traits then
  for _,trait in pairs(onTable.Traits._children) do
   change = onTable.Traits[trait]
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,0,'item')
  end
 end

 if onTable.Syndromes then
  for _,n in pairs(onTable.Syndromes._children) do
   syndrome = onTable.Syndromes[n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',0)
  end
 end

 if onTable.Interactions then
  for _,n in pairs(onTable.Interactions._children) do
   syndrome = onTable.Interactions[n]
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'forceLearn',verbose)
  end
 end

 if onTable.Scripts then
  for _,n in pairs(onTable.Scripts._children) do
   script = onTable.Scripts[n]
   dfhack.run_command(script)
  end
 end
end

function onMaterialUnEquip(item,unit)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 matTable = persistTable.GlobalTable.roses.EnhancedMaterialTable

 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local matToken = dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()
 local array = split(matToken,':')

 if array[1] == 'INORGANIC' then
  matTable = matTable.Inorganic
  if not safe_index(matTable,array[2],'OnEquip') then return end
  onTable = matTable[array[2]].OnEquip
 elseif array[1] == 'CREATURE' then
  matTable = matTable.Creature
  if not safe_index(matTable,array[2],array[3],'OnEquip') then return end
  onTable = matTable[array[2]][array[3]].OnEquip
 elseif array[1] == 'PLANT' then
  matTable = matTable.Plant
  if not safe_index(matTable,array[2],array[3],'OnEquip') then return end
  onTable = matTable[array[2]][array[3]].OnEquip
 else
  matTable = matTable.Misc
  if not safe_index(matTable,array[2],'OnEquip') then return end
  onTable = matTable[array[2]].OnEquip
 end

 if onTable.Attributes then
  for _,attribute in pairs(onTable.Attributes._children) do
   change = tonumber(onTable.Attributes[attribute])
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,-change,0,'item')
  end
 end

 if onTable.Resistances then
  for _,resistance in pairs(onTable.Resistances._children) do
   change = tonumber(onTable.Resistances[resistance])
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,-change,0,'item')
  end
 end

 if onTable.Skills then
  for _,skill in pairs(onTable.Skills._children) do
   change = tonumber(onTable.Skills[skill])
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,-change,0,'item')
  end
 end

 if onTable.Stats then
  for _,stat in pairs(onTable.Stats._children) do
   change = tonumber(onTable.Stats[stat])
   dfhack.script_environment('functions/unit').changeStat(unit,stat,-change,0,'item')
  end
 end

 if onTable.Traits then
  for _,trait in pairs(onTable.Traits._children) do
   change = tonumber(onTable.Traits[trait])
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,-change,0,'item')
  end
 end

 if onTable.Syndromes then
  for _,n in pairs(onTable.Syndromes._children) do
   syndrome = onTable.Syndromes[n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'erase',0)
  end
 end

 if onTable.Interactions then
  for _,n in pairs(onTable.Interactions._children) do
   syndrome = onTable.Interactions[n]
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'unlearn',verbose)
  end
 end
end

function onMaterialAction(item,onAction,attacker,defender,options)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 matTable = persistTable.GlobalTable.roses.EnhancedMaterialTable

 if tonumber(item) then item = df.item.find(tonumber(item)) end
 local matToken = dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()
 local array = split(matToken,':')

 if array[1] == 'INORGANIC' then
  matTable = matTable.Inorganic
  if not safe_index(matTable,array[2],onAction) then return end
  onTable = matTable[array[2]][onAction]
 elseif array[1] == 'CREATURE' then
  matTable = matTable.Creature
  if not safe_index(matTable,array[2],array[3],onAction) then return end
  onTable = matTable[array[2]][array[3]][onAction]
 elseif array[1] == 'PLANT' then
  matTable = matTable.Plant
  if not safe_index(matTable,array[2],array[3],onAction) then return end
  onTable = matTable[array[2]][array[3]][onAction]
 else
  matTable = matTable.Misc
  if not safe_index(matTable,array[2],onAction) then return end
  onTable = matTable[array[2]][onAction]
 end
 chance = tonumber(onTable.Chance)
 local rand = dfhack.random.new()
 if rand:random(100) > chance then return end
 
 if attacker then if tonumber(attacker) then attacker = df.unit.find(tonumber(attacker)) end end
 if defender then if tonumber(defender) then defender = df.unit.find(tonumber(defender)) end end
 options  = options or {}
 velocity = options.velocity or 0
 accuracy = options.accuracy or 0
 wound    = options.wound    or -1
 
 for _,add in pairs({'Attacker','Defender'}) do
  unit = nil
  if add == 'Attacker' and attacker then
   unit = attacker
   dur = onTable.AttackerDur or 0
  end
  if add == 'Defender' then
   unit = defender
   dur = onTable.DefenderDur or 0  
  end
  if unit then
   dur = tonumber(dur)
   if onTable[add..'Attributes'] then
    for _,attribute in pairs(onTable[add..'Attributes']._children) do
     change = onTable[add..'Attributes'][attribute]
     dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'item')
    end
   end
   if onTable[add..'Resistances'] then
    for _,resistance in pairs(onTable[add..'Resistances']._children) do
     change = onTable[add..'Resistances'][resistance]
     dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'item')
    end
   end
   if onTable[add..'Skills'] then
    for _,skill in pairs(onTable[add..'Skills']._children) do
     change = onTable[add..'Skills'][skill]
     dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'item')
    end
   end
   if onTable[add..'Stats'] then
    for _,stat in pairs(onTable[add..'Stats']._children) do
     change = onTable[add..'Stats'][stat]
     dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'item')
    end
   end
   if onTable[add..'Traits'] then
    for _,trait in pairs(onTable[add..'Traits']._children) do
     change = onTable[add..'Traits'][trait]
     dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'item')
    end
   end
   if onTable[add..'Syndromes'] then
    for _,n in pairs(onTable[add..'Syndromes']._children) do
     syndrome = onTable[add..'Syndromes'][n]
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
   if onTable[add..'Interactions'] then
    for _,n in pairs(onTable[add..'Interactions']._children) do
     syndrome = onTable[add..'Interactions'][n]
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
  end
 end
 for _,n in pairs(onTable.Scripts._children) do
  x = onTable.Scripts[n]
  script = x.Script
  if rand:random(100) <= x.Chance then
   if attacker then script = script:gsub('SOURCE_UNIT_ID',tostring(attacker.id)) end
   if defender then script = script:gsub('TARGET_UNIT_ID',tostring(defender.id)) end
   script = script:gsub('ITEM_ID',tostring(item.id))
   script = script:gsub('ITEM_TOKEN',tostring(item.subtype.id))
   dfhack.run_command(script)
  end
 end
end

--=                     Enhanced System - Reaction Functions
usages[#usages+1] = [===[
]===]

function reactionStart(reactionToken,worker,building,job)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 reactionEnhanced = persistTable.GlobalTable.roses.EnhancedReactionTable

 reaction = reactionEnhanced[reactionToken]
 if not reaction then return end

 for _,i in pairs(reaction.Scripts._children) do
  script = reaction.Scripts[i]
  script = script:gsub('WORKER_ID',tostring(worker.id))
  script = script:gsub('UNIT_ID',tostring(worker.id))
  script = script:gsub('BUILDING_ID',tostring(building.id))
  script = script:gsub('REACTION_NAME',reactionToken)
  script = script:gsub('LOCATION',""..tostring(worker.pos.x).." "..tostring(worker.pos.y).." "..tostring(worker.pos.z).."")
  dfhack.run_command(script)
 end
end

function reactionEnd(reactionToken,worker,building)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 reactionEnhanced = persistTable.GlobalTable.roses.EnhancedReactionTable

 reaction = reactionEnhanced[reactionToken]
 if not reaction then return end

 for _,i in pairs(reaction.Scripts._children) do
  script = reaction.Scripts[i]
  script = script:gsub('WORKER_ID',tostring(worker.id))
  script = script:gsub('UNIT_ID',tostring(worker.id))
  script = script:gsub('BUILDING_ID',tostring(building.id))
  script = script:gsub('REACTION_NAME',reactionToken)
  script = script:gsub('LOCATION',""..tostring(worker.pos.x).." "..tostring(worker.pos.y).." "..tostring(worker.pos.z).."")
  dfhack.run_command(script)
 end
end

function reactionProduct(reactionToken,worker,building,inputItems,outputItems)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return false end
 reactionEnhanced = persistTable.GlobalTable.roses.EnhancedReactionTable

 reaction = reactionEnhanced[reactionToken]
 if not reaction then return end

 for _,i in pairs(reaction.Scripts._children) do
  script = reaction.Scripts[i]
  script = script:gsub('WORKER_ID',tostring(worker.id))
  script = script:gsub('UNIT_ID',tostring(worker.id))
  script = script:gsub('BUILDING_ID',tostring(building.id))
  script = script:gsub('REACTION_NAME',reactionToken)
  script = script:gsub('LOCATION',""..tostring(worker.pos.x).." "..tostring(worker.pos.y).." "..tostring(worker.pos.z).."")
   strTemp = ''
   for _,item in pairs(inputItems) do
    strTemp = strTemp..item..' '
   end
   script = script:gsub('INPUT_ITEMS',strTemp)
   strTemp = ''
   for _,item in pairs(outputItems) do
    strTemp = strTemp..item..' '
   end
   script = script:gsub('OUTPUT_ITEMS',strTemp)  
  dfhack.run_command(script)
 end
end
