local utils = require 'utils'
split = utils.split_string
usages = {}

--=                     Enhanced System Table Functions
usages[#usages+1] = [===[
]===]

function getData(ttable,test,verbose)
 if ttable == 'Building' then
  tokenCheck = '[BUILDING'
  filename = 'building'
 elseif ttable == 'Creature' then
  tokenCheck = '[CREATURE'
  filename = 'creature'
 elseif ttable == 'Item' then
  tokenCheck = '[ITEM'
  filename = 'item'
 elseif ttable == 'Material' then
  tokenCheck = '[MATERIAL_TEMPLATE'
  filename = 'material_template'
 elseif ttable == 'Inorganic' then
  tokenCheck = '[INORGANIC'
  filename = 'inorganic'
 elseif ttable == 'PlantMat' then
  tokenCheck = '[PLANT'
  filename = 'plant'
 elseif ttable == 'AnimalMat' then
  tokenCheck = '[CREATURE'
  filename = 'creature'
 elseif ttable == 'Reaction' then
  tokenCheck = '[REACTION'
  filename = 'reaction'
 else
  return
 end
 if verbose then print('Searching for a '..ttable..' file') end
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
  print(ttable..' files found:')
  printall(files)
 elseif verbose then
  print('No '..ttable..' files found')
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
   if ttable == 'Building' then
    ls = split(split(sline,':')[1],'_')[1]
   elseif ttable == 'Item' then
    ls = split(split(sline,':')[1],'_')[1]
   else
    ls = split(sline,':')[1]
   end
   if ls == tokenCheck then
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

function makeEnhancedBuildingTable(runtest,verbose)
 local Table = {}
 local numEnhanced = 0
 dataFiles,dataInfoFiles,files = getData('Building',runtest,verbose)
 if not dataFiles then return numEnhanced end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   Table[token] = {}
   ptable = Table[token]
   ptable.Scripts = {}
   scripts = 0
   enhanced = false
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
     array[k] = tonumber(array[k]) or array[k]
    end
    if test == '[NAME' then -- Take raw building name
     ptable.Name = split(array[2],']')[1]
    elseif string.sub(test,1,1) == '[' then
     -- This is here so we skip unnecessary raw tokens
     foo = 0
    elseif test == '{DESCRIPTION' then
     ptable.Description = array[2]
     enhanced = true
    elseif test == '{MULTI_STORY' then
     ptable.MultiStory = array[2]
     enhanced = true
    elseif test == '{TREE_BUILDING}' then
     ptable.TreeBuilding = true
     enhanced = true
    elseif test == '{BASEMENT}' then
     ptable.Basement = true
     enhanced = true
    elseif test == '{WALLS}' then
     ptable.Walls = true
     enhanced = true
    elseif test == '{OUTSIDE_ONLY}' then
     ptable.OutsideOnly = true
     enhanced = true
    elseif test == '{INSIDE_ONLY}' then
     ptable.InsideOnly = true
     enhanced = true
    elseif test == '{STAIRS' then
     ptable.Stairs = {}
     ptable.Stairs.x = array[2]
     ptable.Stairs.y = array[3]
     enhanced = true
    elseif test == '{ANCHOR' then
     ptable.Anchor = {}
     ptable.Anchor.x = array[2]
     ptable.Anchor.y = array[3]
     enhanced = true
    elseif test == '{UPGRADE' then
     ptable.Upgrade = array[2]
     enhanced = true
    elseif test == '{REQUIRED_WATER' then
     ptable.RequiredWater = array[2]
     enhanced = true
    elseif test == '{REQUIRED_MAGMA' then
     ptable.RequiredMagma = array[2]
     enhanced = true
    elseif test == '{REQUIRED_BUILDING' then
     ptable.RequiredBuildings = table.RequiredBuildings or {}
     ptable.RequiredBuildings[array[2]] = array[3]
     enhanced = true
    elseif test == '{FORBIDDEN_BUILDING' then
     ptable.ForbiddenBuildings = table.ForbiddenBuildings or {}
     ptable.ForbiddenBuildings[array[2]] = array[3]
     enhanced = true
    elseif test == '{MAX_AMOUNT' then
     ptable.MaxAmount = array[2]
     enhanced = true
    elseif test == '{SCRIPT' or test == '{SPELL' then
     scripts = scripts + 1
     ptable.Scripts[scripts] = {}
     a = data[j]
     a = table.concat({select(2,table.unpack(split(a,':')))},':')
     n = string.find(string.reverse(a),':')
     script = string.sub(a,1,-(n+1))
     frequency = string.sub(a,-(n-1),-2)
     ptable.Scripts[scripts].Script = script
     ptable.Scripts[scripts].Frequency = frequency
     enhanced = true
    end
   end
   if ptable.OutsideOnly and ptable.InsideOnly then
    ptable.OutsideOnly = nil
    ptable.InsideOnly = nil
   end
   if scripts == 0 then ptable.Scripts = nil end
   if not enhanced then Table[token] = nil else numEnhanced = numEnhanced + 1 end
  end
 end

 return numEnhanced, Table
end

function makeEnhancedCreatureTable(runtest,verbose)
 local Table = {}
 local numEnhanced = 0
 dataFiles,dataInfoFiles,files = getData('Creature',runtest,verbose)
 if not dataFiles then return numEnhanced end

 tokens = {}
 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   tokens[token] = token
   Table[token] = {}
   Table[token]['ALL'] = {}
   enhanced = false
   for n,c in pairs(df.global.world.raws.creatures.all) do
    if token == c.creature_id then
     creatureID = n
     break
    end
   end
   if creatureID then
    for _,caste in pairs(df.global.world.raws.creatures.all[creatureID].caste) do
     casteToken = caste.caste_id
     Table[token][casteToken] = {}
    end
   end

   creature = Table[token]['ALL']
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
     array[k] = tonumber(array[k]) or array[k]
    end
    if test == '[CASTE' then
     caste = split(array[2],']')[1]
     creature = Table[token][caste]
    elseif test == '[SELECT_CASTE' then
     caste = split(array[2],']')[1]
     creature = Table[token][caste]
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
     enhanced = true
    elseif test == '{ATTRIBUTE' then
     creature.Attributes = creature.Attributes or {}
     creature.Attributes[array[2]] = {}
     creature.Attributes[array[2]][1] = array[3]
     creature.Attributes[array[2]][2] = array[4] or array[3]
     creature.Attributes[array[2]][3] = array[5] or array[3]
     creature.Attributes[array[2]][4] = array[6] or array[3]
     creature.Attributes[array[2]][5] = array[7] or array[3]
     creature.Attributes[array[2]][6] = array[8] or array[3]
     creature.Attributes[array[2]][7] = array[9] or array[3]
     enhanced = true
    elseif test == '{NATURAL_SKILL' then
     creature.Skills = creature.Skills or {}
     creature.Skills[array[2]] = {}
     creature.Skills[array[2]].Min = array[3]
     creature.Skills[array[2]].Max = array[4] or array[3]
     enhanced = true
    elseif test == '{STAT' then
     creature.Stats = creature.Stats or {}
     creature.Stats[array[2]] = {}
     creature.Stats[array[2]].Min = array[3]
     creature.Stats[array[2]].Max = array[4] or array[3]
     enhanced = true
    elseif test == '{RESISTANCE' then
     creature.Resistances = creature.Resistances or {}
     creature.Resistances[array[2]] = array[3]
     enhanced = true
    elseif test == '{CLASS' then
     creature.Classes = creature.Classes or {}
     creature.Classes[array[2]] = {}
     creature.Classes[array[2]].Level = array[3]
     creature.Classes[array[2]].Interactions = array[4]
     enhanced = true
    elseif test =='{INTERACTION' then
     creature.Interactions = creature.Interactions or {}
     creature.Interactions[array[2]] = {}
     creature.Interactions[array[2]].Probability = array[3]
     enhanced = true
    end
   end
   if not enhanced then Table[token] = nil else numEnhanced = numEnhanced + 1 end
  end
 end

-- Copy any ALL caste data into the respective CREATURE:CASTE combo, CASTE caste data is given priority
 creatures = Table
 for _,creatureToken in pairs(tokens) do
  for n,c in pairs(df.global.world.raws.creatures.all) do
   if creatureToken == c.creature_id then
    creatureID = n
    break
   end
  end
  if creatureID and creatures[creatureToken] then
   for _,caste in pairs(df.global.world.raws.creatures.all[creatureID].caste) do
    casteToken = caste.caste_id
    if not creatures[creatureToken][casteToken] then creatures[creatureToken][casteToken] = {} end
    if creatures[creatureToken].ALL then
     for x,_ in pairs(creatures[creatureToken].ALL) do
      if not creatures[creatureToken][casteToken][x] then
       creatures[creatureToken][casteToken][x] = creatures[creatureToken].ALL[x]
      else
       for y,_ in pairs(creatures[creatureToken].ALL[x]) do
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

 return numEnhanced, Table
end

function makeEnhancedItemTable(runtest,verbose)
 local Table = {}
 local numEnhanced = 0
 dataFiles,dataInfoFiles,files = getData('Item',runtest,verbose)
 if not dataFiles then return numEnhanced end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   Table[token] = {}
   item = Table[token]
   scripts = 0
   enhanced = false
   for j = startLine,endLine,1 do
    testa = data[j]:gsub("%s+","")
    test = split(testa,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
     array[k] = tonumber(array[k]) or array[k]
    end
    if     test == '[NAME' then -- Take raw item name
     item.Name = split(array[2],']')[1]
    elseif string.sub(test,1,1) == '[' then
     -- This is here so we skip unnecessary raw tokens
     foo = 0
    elseif test == '{DESCRIPTION' then
     item.Description = array[2]
     enhanced = true
    elseif test == '{CLASS' then
     item.Class = array[2]
     enhanced = true
    elseif test == '{ON_REPORT' then
     item.OnReport = item.OnReport or {}
     item.OnReport[array[2]] = {}
     onTable = item.OnReport[array[2]]
     if array[3] then
      onTable.Chance = array[3]
     else
      onTable.Chance = 100
     end
     enhanced = true
    elseif test == '{ON_EQUIP' then
     item.OnEquip = item.OnEquip or {}
     onTable = item.OnEquip
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_EQUIP}' then
     item.OnEquip = item.OnEquip or {}
     onTable = item.OnEquip
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_ATTACK' then
     item.OnAttack = item.OnAttack or {}
     onTable = item.OnAttack
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_ATTACK}' then
     item.OnAttack = item.OnAttack or {}
     onTable = item.OnAttack
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_SHOOT' then
     item.OnShoot = item.OnShoot or {}
     onTable = item.OnShoot
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_SHOOT}' then
     item.OnShoot = item.OnSHoot or {}
     onTable = item.OnShoot
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_PARRY' then
     item.OnParry = item.OnParry or {}
     onTable = item.OnParry
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_PARRY}' then
     item.OnParry = item.OnParry or {}
     onTable = item.OnParry
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_DODGE' then
     item.OnDodge = item.OnDodge or {}
     onTable = item.OnDodge
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_DODGE}' then
     item.OnDodge = item.OnDodge or {}
     onTable = item.OnDodge
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_BLOCK' then
     item.OnBlock = item.OnBlock or {}
     onTable = item.OnBlock
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_BLOCK}' then
     item.OnBlock = item.OnBlock or {}
     onTable = item.OnBlock
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_WOUND' then
     item.OnWound = item.OnWound or {}
     onTable = item.OnWound
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_WOUND}' then
     item.OnWound = item.OnWound or {}
     onTable = item.OnWound
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_PROJECTILE_MOVE}' then
     item.OnProjectileMove = item.OnProjectileMove or {}
     onTable = item.OnProjectileMove
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_PROJECTILE_MOVE' then
     item.OnProjectileMove = item.OnProjectileMove or {}
     onTable = item.OnProjectileMove
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_PROJECTILE_HIT}' then
     item.OnProjectileHit = item.OnProjectileHit or {}
     onTable = item.OnProjectileHit
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_PROJECTILE_HIT' then
     item.OnProjectileHit = item.OnProjectileHit or {}
     onTable = item.OnProjectileHit
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ON_PROJECTILE_FIRED}' then
     item.OnProjectileFired = item.OnProjectileFired or {}
     onTable = item.OnProjectileFired
     onTable.Chance = 100
     enhanced = true
    elseif test == '{ON_PROJECTILE_FIRED' then
     item.OnProjectileFired = item.OnProjectileFired or {}
     onTable = item.OnProjectileFired
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{TRIGGER_CHANCE' then
     onTable.Chance = array[2]
     enhanced = true
    elseif test == '{ATTRIBUTE_CHANGE' then
     onTable.Attributes = onTable.Attributes or {}
     onTable.Attributes[array[2]] = array[3]
     enhanced = true
    elseif test == '{SKILL_CHANGE' then
     onTable.Skills = onTable.Skills or {}
     onTable.Skills[array[2]] = array[3]
     enhanced = true
    elseif test == '{TRAIT_CHANGE' then
     onTable.Traits = onTable.Traits or {}
     onTable.Traits[array[2]] = array[3]
     enhanced = true
    elseif test == '{STAT_CHANGE' then
     onTable.Stats = onTable.Stats or {}
     onTable.Stats[array[2]] = array[3]
     enhanced = true
    elseif test == '{RESISTANCE_CHANGE' then
     onTable.Resistances = onTable.Resistances or {}
     onTable.Resistances[array[2]] = array[3]
     enhanced = true
    elseif test == '{INTERACTION_ADD' then
     onTable.Interactions = onTable.Interactions or {}
     onTable.Interactions[#onTable.Interactions+1] = array[2]
     enhanced = true
    elseif test == '{SYNDROME_ADD' then
     onTable.Syndromes = onTable.Syndromes or {}
     onTable.Syndromes[#onTable.Syndromes+1] = array[2]
     enhanced = true
    elseif test == '{ATTACKER_ATTRIBUTE_CHANGE' then
     onTable.AttackerAttributes = onTable.AttackerAttributes or {}
     onTable.AttackerAttributes[array[2]] = array[3]
     enhanced = true
    elseif test == '{ATTACKER_SKILL_CHANGE' then
     onTable.AttackerSkills = onTable.AttackerSkills or {}
     onTable.AttackerSkills[array[2]] = array[3]
     enhanced = true
    elseif test == '{ATTACKER_TRAIT_CHANGE' then
     onTable.AttackerTraits = onTable.AttackerTraits or {}
     onTable.AttackerTraits[array[2]] = array[3]
     enhanced = true
    elseif test == '{ATTACKER_STAT_CHANGE' then
     onTable.AttackerStats = onTable.AttackerStats or {}
     onTable.AttackerStats[array[2]] = array[3]
     enhanced = true
    elseif test == '{ATTACKER_RESISTANCE_CHANGE' then
     onTable.AttackerResistances = onTable.AttackerResistances or {}
     onTable.AttackerResistances[array[2]] = array[3]
     enhanced = true
    elseif test == '{ATTACKER_INTERACTION_ADD' then
     onTable.AttackerInteractions = onTable.AttackerInteractions or {}
     onTable.AttackerInteractions[#onTable.AttackerInteractions+1] = array[2]
     enhanced = true
    elseif test == '{ATTACKER_SYNDROME_ADD' then
     onTable.AttackerSyndromes = onTable.AttackerSyndromes or {}
     onTable.AttackerSyndromes[#onTable.AttackerSyndromes+1] = array[2]
     enhanced = true
    elseif test == '{ATTACKER_CHANGE_DUR' then
     onTable.AttackerDur = array[2]
     enhanced = true
    elseif test == '{DEFENDER_ATTRIBUTE_CHANGE' then
     onTable.DefenderAttributes = onTable.DefenderAttributes or {}
     onTable.DefenderAttributes[array[2]] = array[3]
     enhanced = true
    elseif test == '{DEFENDER_SKILL_CHANGE' then
     onTable.DefenderSkills = onTable.DefenderSkills or {}
     onTable.DefenderSkills[array[2]] = array[3]
     enhanced = true
    elseif test == '{DEFENDER_TRAIT_CHANGE' then
     onTable.DefenderTraits = onTable.DefenderTraits or {}
     onTable.DefenderTraits[array[2]] = array[3]
     enhanced = true
    elseif test == '{DEFENDER_STAT_CHANGE' then
     onTable.DefenderStats = onTable.DefenderStats or {}
     onTable.DefenderStats[array[2]] = array[3]
     enhanced = true
    elseif test == '{DEFENDER_RESISTANCE_CHANGE' then
     onTable.DefenderResistances = onTable.DefenderResistances or {}
     onTable.DefenderResistances[array[2]] = array[3]
     enhanced = true
    elseif test == '{DEFENDER_INTERACTION_ADD' then
     onTable.DefenderInteractions = onTable.DefenderInteractions or {}
     onTable.DefenderInteractions[#onTable.DefenderInteractions+1] = array[2]
     enhanced = true
    elseif test == '{DEFENDER_SYNDROME_ADD' then
     onTable.DefenderSyndromes = onTable.DefenderSyndromes or {}
     onTable.DefenderSyndromes[#onTable.DefenderSyndromes+1] = array[2]
     enhanced = true
    elseif test == '{DEFENDER_CHANGE_DUR' then
     onTable.DefenderDur = array[2]
     enhanced = true
    elseif test == '{SCRIPT' or test == '{SPELL' then
     onTable.Scripts = onTable.Scripts or {}
     scripts = scripts + 1
     onTable.Scripts[scripts] = {}
     a = data[j]
     a = table.concat({select(2,table.unpack(split(a,':')))},':')
     n = string.find(string.reverse(a),':')
     script = string.sub(a,1,-(n+1))
     chance = string.sub(a,-(n-1),-2)
     onTable.Scripts[scripts].Script = script
     onTable.Scripts[scripts].Chance = chance
     enhanced = true
    end
   end
   if not enhanced then Table[token] = nil else numEnhanced = numEnhanced + 1 end
  end
 end

 return numEnhanced, Table
end

function makeEnhancedMaterialTable(runtest,verbose)
 local Table = {}
 local numEnhanced = 0
 print('Enhanced System - Materials, not currently working')
 return numEnhanced

 --materialFiles,  materialInfoFiles   materialfiles  = getData('Material' ,test)
 --inorganicFiles, inorganicInfoFiles, inorganicfiles = getData('Inorganic',test)
 --plantFiles,     plantInfoFiles,     plantfiles     = getData('PlantMat' ,test)
 --animalFiles,    animalInfoFiles,    animalfiles    = getData('AnimalMat',test)

end

function makeEnhancedReactionTable(runtest,verbose)
 local Table = {}
 local numEnhanced = 0
 dataFiles,dataInfoFiles,files = getData('Reaction',runtest,verbose)
 if not dataFiles then return numEnhanced end

 for _,file in ipairs(files) do
  dataInfo = dataInfoFiles[file]
  data = dataFiles[file]
  for i,x in ipairs(dataInfo) do
   token      = x[1]
   startLine  = x[2]
   endLine    = x[3]
   Table[token] = {}
   ptable = Table[token]
   ptable.Scripts = {}
   scripts = 0
   products = 0
   enhanced = false
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],'}')[1]
     array[k] = tonumber(array[k]) or array[k]
    end
    if     test == '[NAME' then -- Take raw reaction name
     ptable.Name = split(array[2],']')[1]
    elseif string.sub(test,1,1) == '[' then
     -- This is here so we skip unnecessary raw tokens
     foo = 0
    elseif test == '{DESCRIPTION' then
     ptable.Description = array[2]
     enhanced = true
    elseif test == '{BASE_DURATION' then
     ptable.BaseDur = array[2]
     enhanced = true
    elseif test == '{REQUIRED_MAGMA' then
     ptable.RequiredMagma = array[2]
     enhanced = true
    elseif test == '{REQUIRED_WATER' then
     ptable.RequiredWater = array[2]
     enhanced = true
    elseif test == '[SKILL' then -- Take raw table skill
     ptable.Skill = split(array[2],']')[1]
     enhanced = true
    elseif test == '{SKILL' then -- OR custom table skill
     ptable.Skill = array[2]
     enhanced = true
    elseif test == '{ON_PRODUCT}' then
     ptable.OnProduct = true
     enhanced = true
    elseif test == '{ON_START}' then
     ptable.OnStart = true
     enhanced = true
    elseif test == '{ON_FINISH}' then
     ptable.OnFinish = true
     enhanced = true
    elseif test == '{DURATION_REDUCTION' then
     ptable.DurReduction = {}
     ptable.DurReduction.Increment = array[2]
     ptable.DurReduction.MaxReduction = array[3]
     enhanced = true
    elseif test == '{ADDITIONAL_PRODUCT' then
     ptable.Products = table.Products or {}
     products = products + 1
     ptable.Products[products] = {}
     ptable.Products[products].Chance = array[2]
     ptable.Products[products].Number = array[3]
     ptable.Products[products].MaterialType = array[4]
     ptable.Products[products].MaterialSubType = array[5]
     ptable.Products[products].ItemType = array[6]
     ptable.Products[products].ItemSubType = array[7]
     enhanced = true
    elseif test == '{FREEZE}' then
     ptable.Frozen = true
     enhanced = true
    elseif test == '{REMOVE}' then
     ptable.Disappear = true
     enhanced = true
    elseif test == '{SCRIPT' then
     scripts = scripts + 1
     script = data[j]
     script = table.concat({select(2,table.unpack(split(script,':')))},':')
     script = string.sub(script,1,-2)
     ptable.Scripts[scripts] = script
     enhanced = true
    end
   end
   if not enhanced then Table[token] = nil else numEnhanced = numEnhanced + 1 end
  end
 end

 return numEnhanced, Table
end

--=                     Enhanced System - Building  Functions
usages[#usages+1] = [===[
]===]

function buildingCreated(building)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses then return false end
 ctype = building:getCustomType()
 if ctype < 0 then return end
 buildingToken = df.global.world.raws.buildings.all[ctype].code
 if not roses.EnhancedBuildingTable[buildingToken] then return end
 EBuilding = roses.EnhancedBuildingTable[buildingToken]
 if not roses.BuildingTable[building.id] then
  dfhack.script_environment('functions/building').makeBuildingTable(building)
 end
 roses = dfhack.script_environment('base/roses-table').roses
 bldgTable = roses.BuildingTable[building.id]
 bldgTable.Enhanced = true
 
 -- Run any scripts attached to the building
 if EBuilding.Scripts then
  bldgTable.Scripts = true
  for i,x in pairs(EBuilding.Scripts) do
   local script = x.Script
   local frequency = x.Frequency
   script = script:gsub('BUILDING_ID',tostring(building.id))
   script = script:gsub('BUILDING_TOKEN',buildingToken)
   script = script:gsub('BUILDING_LOCATION',""..tostring(building.centerx).." "..tostring(building.centery).." "..tostring(building.z).."")
   dfhack.run_command(script)
   if frequency > 0 then dfhack.timeout(frequency,'ticks',function () buildingTrigger(building.id,script,frequency,true) end) end
  end
 end

 if EBuilding.MultiStory and EBuilding.MultiStory > 1 then
  bldgTable.MultiStory = true
  bldgTable.Stories = {}
  mid_x = building.centerx
  mid_y = building.centery
  walk = dfhack.maps.ensureTileBlock(mid_x,mid_y,building.z).walkable[mid_x%16][mid_y%16]
  
  -- Create stairs
  if EBuilding.Stairs then
   x = building.x1 + EBuilding.Stairs.x - 1
   y = building.y1 + EBuilding.Stairs.x - 1
   z = building.z
   bldgTable.StairTileType = df.tiletype[dfhack.maps.getTileType(x,y,z)]
   bldgTable.Stairs = {x=x,y=y,z=z}
   dfhack.script_environment('functions/map').setTileType('StoneStairU',x,y,z)
  end

  for i = 1, EBuilding.MultiStory-1 do
   level_token = '!'..buildingToken..'_LEVEL_'..tostring(i+1)
   level_bldg = nil
   for k,v in pairs(df.global.world.raws.buildings.all) do
    if v.code == level_token then
     level_bldg = v
     break
    end
   end
   if not level_bldg then return end
   xLevel = mid_x - math.floor((level_bldg.dim_x+1)/2) + 1
   yLevel = mid_y - math.floor((level_bldg.dim_y+1)/2) + 1
   zLevel = building.z + i
   location = '-location [ '..tostring(xLevel)..' '..tostring(yLevel)..' '..tostring(zLevel)..' ]'
   dfhack.run_command('building/create '..location..' -type Workshop -subtype '..level_token..' -force')
   bldgTable.Stories[level_token] = building.id + i
   roses.BuildingTable[building.id + i] = {}
   roses.BuildingTable[building.id + i].Story = building.id
   
   -- Create floor (489)
   for x = xLevel, xLevel + level_bldg.dim_x-1 do
    for y = yLevel, yLevel + level_bldg.dim_y-1 do
     dfhack.script_environment('functions/map').setTileType('ConstructedFloor',x,y,zLevel)
     -- Shouldn't alter the impassible tiles -ME
     x0 = x-xLevel
     y0 = y-yLevel
     if level_bldg.tile_block[x0][y0] == 0 then
      dfhack.maps.ensureTileBlock(x,y,zLevel).occupancy[x%16][y%16].building = 2
      dfhack.maps.ensureTileBlock(x,y,zLevel).walkable[x%16][y%16] = walk
     else
      -- Tile is impassible, but it should already be impassible by construction
      dfhack.maps.ensureTileBlock(x,y,zLevel).occupancy[x%16][y%16].building = 6 
      dfhack.maps.ensureTileBlock(x,y,zLevel).walkable[x%16][y%16] = 0      
     end
    end
   end
   
   level_enhanced = roses.EnhancedBuildingTable[level_token]
   if level_enhanced then
    if level_enhanced.Stairs then
     x = xLevel + level_enhanced.Stairs.x - 1
     y = yLevel + level_enhanced.Stairs.x - 1
     if i == EBuilding.MultiStory then
      dfhack.script_environment('functions/map').setTileType('StoneStairD',x,y,zLevel)
     else
      dfhack.script_environment('functions/map').setTileType('StoneStairUD',x,y,zLevel)
     end
    end
   end
  end
 end 
end

function buildingDestroyed(building)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses or not building.Enhanced then return false end
 
 if building.Scripts then
  -- Building scripts should automatically stop once the building is deconstructed
  -- If we need to manually stop them or if there is a script to only run on deconstruct
  -- put that here -ME
 end
 
 if building.MultiStory or building.Story then
  if building.Story then building = roses.BuildingTable[building.Story] end -- Get the base building
  if not building or not building.Token or not roses.EnhancedBuildingTable[building.Token] then
   error 'Something went wrong when trying to deconstruct the building'
  end
  EBuilding = roses.EnhancedBuildingTable[building.Token]
  -- Deconstruct from top down
  for i = EBuilding.MultiStory-1,1,-1 do
   level_token = '!'..building.Token..'_LEVEL_'..tostring(i+1)
   level_id = building.Stories[level_token]
   if level_id then
    level_bldg = df.building.find(level_id)
    if level_bldg then
     for x = level_bldg.x1, level_bldg.x2 do
      for y = level_bldg.y1, level_bldg.y2 do
       dfhack.script_environment('functions/map').setTileType('OpenSpace',x,y,level_bldg.z)
       dfhack.maps.ensureTileBlock(x,y,level_bldg.z).walkable[x%16][y%16] = 0          
      end
     end
     level_bldg.construction_stage = 0
     b = dfhack.buildings.deconstruct(level_bldg)
    end
   end
   if roses.BuildingTable[level_id] then roses.BuildingTable[level_id] = nil end
  end
  
  if building.ID and df.building.find(building.ID) then
   df.building.find(building.ID).construction_stage = 0
   dfhack.buildings.deconstruct(df.building.find(building.ID))
  end
  
  if building.StairTileType and building.Stairs then
   dfhack.script_environment('functions/map').setTileType(building.StairTileType,building.Stairs.x,building.Stairs.y,building.Stairs.z)
  end
 end
 
 if building.ID and roses.BuildingTable[building.ID] then roses.BuildingTable[building.ID] = nil end
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
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not unit then return false end
 creatureEnhanced = roses.EnhancedCreatureTable

 if creatureEnhanced then
  local creatureID = df.global.world.raws.creatures.all[unit.race].creature_id
  local casteID    = df.global.world.raws.creatures.all[unit.race].caste[unit.caste].caste_id
  if safe_index(creatureEnhanced,creatureID,casteID) then
   if not roses.UnitTable[unit.id] then 
    dfhack.script_environment('functions/unit').makeUnitTable(unit)
   end
   roses = dfhack.script_environment('base/roses-table').roses
   unitTable = roses.UnitTable[unit.id]
   if unitTable.Enhanced then return end

   unitTable.Enhanced = true
   local ctable = creatureEnhanced[creatureID][casteID]
   if ctable.Attributes   then setN(unit, 'Attributes',  ctable.Attributes)  end
   if ctable.Skills       then setN(unit, 'Skills',      ctable.Skills)      end
   if ctable.Stats        then setN(unit, 'Stats',       ctable.Stats)       end
   if ctable.Resistances  then setN(unit, 'Resistances', ctable.Resistances) end
   --if table.Size         then setSize(unit, table.Size) end
   --if table.Classes      then setClass(unit, table.Classes) end
   --if table.Interactions then setInteractions(unit, table.Interactions) end
  end
 end
end

function setN(unit,ttype,ctable)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 unitFunctions = dfhack.script_environment('functions/unit')
 unitTable = unitFunctions.getUnitTable(unit)

 for entry,_ in pairs(ctable) do
  if not unitTable[ttype][entry] then return false end
  current = unitTable[ttype][entry].Base
  if ttype == 'Skills' then
   value = math.floor(math.random(ctable[entry].Min,ctable[entry].Max))
  else
   rn = math.random(0,100)
   if rn > 95 then
    value = ctable[entry][7]
   elseif rn > 85 then
    value = ctable[entry][6]
   elseif rn > 65 then
    value = ctable[entry][5]
   elseif rn < 5 then
    value = ctable[entry][1]
   elseif rn < 15 then
    value = ctable[entry][2]
   elseif rn < 35 then
    value = ctable[entry][3]
   else
    value = ctable[entry][4]
   end
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  if ttype == 'Attributes'      then unitFunctions.changeAttribute(unit,entry,change,0,'track')
  elseif ttype == 'Stats'       then unitFunctions.changeStat(unit,entry,change,0,'track')
  elseif ttype == 'Resistances' then unitFunctions.changeResistance(unit,entry,change,0,'track')
  elseif ttype == 'Skills'      then unitFunctions.changeSkill(unit,entry,change,0,'track')
  end
 end
end

function setClass(unit,ctable)

end

function setInteractions(unit,ctable)

end

function setSize(unit,ctable)

end

--=                     Enhanced System - Item Functions
usages[#usages+1] = [===[
]===]

function enhanceItemsInventory(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
end

function onItemEquip(item,unit)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not item or not unit then return false end

 itemTable = roses.EnhancedItemTable
 if not safe_index(itemTable,item.subtype.id,'OnEquip') then return end
 itemTable = itemTable[item.subtype.id]
 onTable = itemTable.OnEquip
 if onTable.Attributes then
  for attribute,change in pairs(onTable.Attributes) do
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,0,'item')
  end
 end
 if onTable.Resistances then
  for resistance,change in pairs(onTable.Resistances) do
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,0,'item')
  end
 end
 if onTable.Skills then
  for skill,change in pairs(onTable.Skills) do
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'item')
  end
 end
 if onTable.Stats then
  for stat,change in pairs(onTable.Stats) do
   dfhack.script_environment('functions/unit').changeStat(unit,stat,change,0,'item')
  end
 end
 if onTable.Traits then
  for trait,change in pairs(onTable.Traits) do
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,0,'item')
  end
 end
 if onTable.Syndromes then
  for n,syndrome in pairs(onTable.Syndromes) do
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',0)
  end
 end
 if onTable.Interactions then
  for n,syndrome in pairs(onTable.Interactions) do
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'force',verbose)
  end
 end
 if onTable.Scripts then
  for n,script in pairs(onTable.Scripts) do
   dfhack.run_command(script)
  end
 end
end

function onItemUnEquip(item,unit)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not item or not unit then return false end

 itemTable = roses.EnhancedItemTable
 if not safe_index(itemTable,item.subtype.id,'OnEquip') then return end
 itemTable = itemTable[item.subtype.id]
 onTable = itemTable.OnEquip
 if onTable.Attributes then
  for attribute,change in pairs(onTable.Attributes) do
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,-change,0,'item')
  end
 end
 if onTable.Resistances then
  for resistance,change in pairs(onTable.Resistances) do
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,-change,0,'item')
  end
 end
 if onTable.Skills then
  for skill,change in pairs(onTable.Skills) do
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,-change,0,'item')
  end
 end
 if onTable.Stats then
  for stat,change in pairs(onTable.Stats) do
   dfhack.script_environment('functions/unit').changeStat(unit,stat,-change,0,'item')
  end
 end
 if onTable.Traits then
  for trait,change in pairs(onTable.Traits) do
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,-change,0,'item')
  end
 end
 if onTable.Syndromes then
  for n,syndrome in pairs(onTable.Syndromes) do
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'erase',0)
  end
 end
 if onTable.Interactions then
  for n,syndrome in pairs(onTable.Interactions) do
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'remove',verbose)
  end
 end
end

function onItemAction(item,onAction,attacker,defender,options)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not roses or not item then return false end
 
 itemTable = roses.EnhancedItemTable
 if not safe_index(itemTable,item.subtype.id,onAction) then return end
 onTable = itemTable[item.subtype.id][onAction]
 local rand = dfhack.random.new()
 if rand:random(100) > onTable.Chance then return end
 
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
  if add == 'Defender' and defender then
   unit = defender
   dur = onTable.DefenderDur or 0  
  end
  if unit then
   if onTable[add..'Attributes'] then
    for attribute,change in pairs(onTable[add..'Attributes']) do
     dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'item')
    end
   end
   if onTable[add..'Resistances'] then
    for resistance,change in pairs(onTable[add..'Resistances']) do
     dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'item')
    end
   end
   if onTable[add..'Skills'] then
    for skill,change in pairs(onTable[add..'Skills']) do
     dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'item')
    end
   end
   if onTable[add..'Stats'] then
    for stat,change in pairs(onTable[add..'Stats']) do
     dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'item')
    end
   end
   if onTable[add..'Traits'] then
    for trait,change in pairs(onTable[add..'Traits']) do
     dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'item')
    end
   end
   if onTable[add..'Syndromes'] then
    for n,syndrome in pairs(onTable[add..'Syndromes']) do
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
   if onTable[add..'Interactions'] then
    for n,syndrome in pairs(onTable[add..'Interactions']) do
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
  end
 end
 for n,x in pairs(onTable.Scripts) do
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
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not item or not unit then return false end

 matTable = roses.EnhancedMaterialTable
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
  for attribute,change in pairs(onTable.Attributes) do
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,0,'item')
  end
 end

 if onTable.Resistances then
  for resistance,change in pairs(onTable.Resistances) do
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,0,'item')
  end
 end

 if onTable.Skills then
  for skill,change in pairs(onTable.Skills) do
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'item')
  end
 end

 if onTable.Stats then
  for stat,change in pairs(onTable.Stats) do
   dfhack.script_environment('functions/unit').changeStat(unit,stat,change,0,'item')
  end
 end

 if onTable.Traits then
  for trait,change in pairs(onTable.Traits) do
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,0,'item')
  end
 end

 if onTable.Syndromes then
  for n,syndrome in pairs(onTable.Syndromes) do
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',0)
  end
 end

 if onTable.Interactions then
  for n,syndrome in pairs(onTable.Interactions) do
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'force',verbose)
  end
 end

 if onTable.Scripts then
  for n,script in pairs(onTable.Scripts) do
   dfhack.run_command(script)
  end
 end
end

function onMaterialUnEquip(item,unit)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not item or not unit then return false end
 
 matTable = roses.EnhancedMaterialTable
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
  for attribute,change in pairs(onTable.Attributes) do
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,-change,0,'item')
  end
 end

 if onTable.Resistances then
  for resistance,change in pairs(onTable.Resistances) do
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,-change,0,'item')
  end
 end

 if onTable.Skills then
  for skill,change in pairs(onTable.Skills) do
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,-change,0,'item')
  end
 end

 if onTable.Stats then
  for stat,change in pairs(onTable.Stats) do
   dfhack.script_environment('functions/unit').changeStat(unit,stat,-change,0,'item')
  end
 end

 if onTable.Traits then
  for trait,change in pairs(onTable.Traits) do
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,-change,0,'item')
  end
 end

 if onTable.Syndromes then
  for n,syndrome in pairs(onTable.Syndromes) do
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'erase',0)
  end
 end

 if onTable.Interactions then
  for n,syndrome in pairs(onTable.Interactions) do
   dfhack.script_environment('functions/class').changeSpell(unit,syndrome,'remove',verbose)
  end
 end
end

function onMaterialAction(item,onAction,attacker,defender,options)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not roses or not item then return false end
 
 matTable = roses.EnhancedMaterialTable
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
 local rand = dfhack.random.new()
 if rand:random(100) > onTable.Chance then return end
 
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
  if add == 'Defender' and defender then
   unit = defender
   dur = onTable.DefenderDur or 0  
  end
  if unit then
   if onTable[add..'Attributes'] then
    for attribute,change in pairs(onTable[add..'Attributes']) do
     dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'item')
    end
   end
   if onTable[add..'Resistances'] then
    for resistance,change in pairs(onTable[add..'Resistances']) do
     dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'item')
    end
   end
   if onTable[add..'Skills'] then
    for skill,change in pairs(onTable[add..'Skills']) do
     dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'item')
    end
   end
   if onTable[add..'Stats'] then
    for stat,change in pairs(onTable[add..'Stats']) do
     dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'item')
    end
   end
   if onTable[add..'Traits'] then
    for trait,change in pairs(onTable[add..'Traits']) do
     dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'item')
    end
   end
   if onTable[add..'Syndromes'] then
    for n,syndrome in pairs(onTable[add..'Syndromes']) do
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
   if onTable[add..'Interactions'] then
    for n,syndrome in pairs(onTable[add..'Interactions']) do
     dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
    end
   end
  end
 end
 for n,x in pairs(onTable.Scripts) do
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
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses or not roses.EnhancedReactionTable[reactionToken] then return false end

 reaction = roses.EnhancedReactionTable[reactionToken]
 for i,script in pairs(reaction.Scripts) do
  script = script:gsub('WORKER_ID',tostring(worker.id))
  script = script:gsub('UNIT_ID',tostring(worker.id))
  script = script:gsub('BUILDING_ID',tostring(building.id))
  script = script:gsub('REACTION_NAME',reactionToken)
  script = script:gsub('LOCATION',""..tostring(worker.pos.x).." "..tostring(worker.pos.y).." "..tostring(worker.pos.z).."")
  dfhack.run_command(script)
 end
end

function reactionEnd(reactionToken,worker,building)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses or not roses.EnhancedReactionTable[reactionToken] then return false end

 reaction = roses.EnhancedReactionTable[reactionToken]
 for i,script in pairs(reaction.Scripts) do
  script = script:gsub('WORKER_ID',tostring(worker.id))
  script = script:gsub('UNIT_ID',tostring(worker.id))
  script = script:gsub('BUILDING_ID',tostring(building.id))
  script = script:gsub('REACTION_NAME',reactionToken)
  script = script:gsub('LOCATION',""..tostring(worker.pos.x).." "..tostring(worker.pos.y).." "..tostring(worker.pos.z).."")
  dfhack.run_command(script)
 end
end

function reactionProduct(reactionToken,worker,building,inputItems,outputItems)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses or not roses.EnhancedReactionTable[reactionToken] then return false end

 reaction = roses.EnhancedReactionTable[reactionToken]
 for i,script in pairs(reaction.Scripts) do
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
