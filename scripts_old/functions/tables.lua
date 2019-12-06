---------------------------------------------------------------------------------------------
-------- Functions for making persistent tables from text files (used in Systems) -----------
---------------------------------------------------------------------------------------------
function makeBaseTable(test,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.BaseTable = {}
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
 base = persistTable.GlobalTable.roses.BaseTable
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
     base.CustomAttributes[#base.CustomAttributes._children+1] = array[2]
    elseif test == '[RESISTANCE' then
     base.CustomResistances[#base.CustomResistances._children+1] = array[2]
    elseif test == '[STAT' then
     base.CustomStats[#base.CustomStats._children+1] = array[2]
    elseif test == '[TYPE' then
     for arg = 2,#array,1 do
      base.Types[#base.Types._children+1] = array[arg]
     end
    elseif test == '[SPHERE' then
     for arg = 2,#array,1 do
      base.Spheres[#base.Spheres._children+1] = array[arg]
     end
    elseif test == '[SCHOOL' then
     for arg = 2,#array,1 do
      base.Schools[#base.Schools._children+1] = array[arg]
     end
    elseif test == '[DISCIPLINE' then
     for arg = 2,#array,1 do
      base.Disciplines[#base.Disciplines._children+1] = array[arg]
     end
    elseif test == '[SUBDISCIPLINE' then
     for arg = 2,#array,1 do
      base.SubDisciplines[#base.SubDisciplines._children+1] = array[arg]
     end
    elseif test == '[EQUATION' then
     base.Equations[array[2]] = array[3]
    end
   end
  end
 end
end

function makeWrapperTemplateTable(test,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.WrapperTemplateTable = {}
 templates = persistTable.GlobalTable.roses.WrapperTemplateTable
 
 dataFiles,dataInfoFiles,files = getData('Wrapper Template','/raw/systems/','templates','[TEMPLATE',test,verbose)
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
end

function makeGlobalTable(verbose)
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.GlobalTable = {}
 persistTable.GlobalTable.roses.GlobalTable.Kills = {}
 persistTable.GlobalTable.roses.GlobalTable.Deaths = {}
 persistTable.GlobalTable.roses.GlobalTable.Trades = {}
 persistTable.GlobalTable.roses.GlobalTable.Sieges = {}
end

-- Moved to functions/enhanced, keep for now because other one isn't working
--function makeEnhancedMaterialTable(test,verbose)
-- local utils = require 'utils'
-- local split = utils.split_string
-- local persistTable = require 'persist-table'
-- persistTable.GlobalTable.roses.EnhancedMaterialTable = {}
-- persistTable.GlobalTable.roses.EnhancedMaterialTable.Inorganic = {}
-- persistTable.GlobalTable.roses.EnhancedMaterialTable.Creature = {}
-- persistTable.GlobalTable.roses.EnhancedMaterialTable.Plant = {}
-- persistTable.GlobalTable.roses.EnhancedMaterialTable.Misc = {}
-- materials = persistTable.GlobalTable.roses.EnhancedMaterialTable
--
-- dataFiles,dataInfoFiles,files = getData('Enhanced Material','/raw/systems/Enhanced','Ematerials','[MATERIAL',test,verbose)
-- if not dataFiles then return false end
-- for _,file in ipairs(files) do
--  dataInfo = dataInfoFiles[file]
--  data = dataFiles[file]
--  for i,x in ipairs(dataInfo) do
--   materialToken = split(x[1],':')[1]
--   materialIndex = split(x[1],':')[2]
--   startLine = x[2]+1
--   if i ==#dataInfo then
--    endLine = #data
--   else
--    endLine = dataInfo[i+1][2]-1
--   end
--   scripts = 0
--   for j = startLine,endLine,1 do
--    test = data[j]:gsub("%s+","")
--    test = split(test,':')[1]
--    array = split(data[j],':')
--    for k = 1, #array, 1 do
--     array[k] = split(array[k],']')[1]
--    end
--	if materialToken == 'INORGANIC' then
--	 materials.Inorganic[materialIndex] = materials.Inorganic[materialIndex] or {}
--	 material = materials.Inorganic[materialIndex]
--	elseif materialToken == 'CREATURE' then
--	 materials.Creature[materialIndex] = materials.Creature[materialIndex] or {}
--	 materials.Creature[materialIndex][split(x[1],':')[3]] = materials.Creature[materialIndex][split(x[1],':')[3]] or {}
--	 material = materials.Creature[materialIndex][split(x[1],':')[3]]
--	elseif materialToken == 'PLANT' then
--	 materials.Plant[materialIndex] = materials.Plant[materialIndex] or {}
--	 materials.Plant[materialIndex][split(x[1],':')[3]] = materials.Plant[materialIndex][split(x[1],':')[3]] or {}
--	 material = materials.Plant[materialIndex][split(x[1],':')[3]]
--	else
--	 materials.Misc[materialToken] = materials.Misc[materialToken] or {}
--	 material = materials.Misc[materialToken]
--    end
--    if test == '[NAME' then
--     material.Name = array[2]
--    elseif test == '[DESCRIPTION' then
--     material.Description = array[2]
--    elseif test == '[CLASS' then
--     material.Class = array[2]
--    elseif test == '[ON_REPORT' then
--     material.OnReport = material.OnReport or {}
--     material.OnReport[array[2]] = {}
--     onTable = material.OnReport[array[2]]
--     if array[3] then
--      onTable.Chance = array[3]
--     else
--      onTable.Chance = '100'
--     end
--    elseif test == '[ON_EQUIP' then
--     material.OnEquip = material.OnEquip or {}
--     onTable = material.OnEquip
--     onTable.Chance = array[2]
--    elseif test == '[ON_EQUIP]' then
--     material.OnEquip = material.OnEquip or {}
--     onTable = material.OnEquip
--     onTable.Chance = '100'
--    elseif test == '[ON_ATTACK' then
--     material.OnAttack = material.OnAttack or {}
--     onTable = material.OnAttack
--     onTable.Chance = array[2]
--    elseif test == '[ON_ATTACK]' then
--     material.OnAttack = material.OnAttack or {}
--     onTable = material.OnAttack
--     onTable.Chance = '100'
--    elseif test == '[ON_SHOOT' then
--     material.OnShoot = material.OnShoot or {}
--     onTable = material.OnShoot
--     onTable.Chance = array[2]
--    elseif test == '[ON_SHOOT]' then
--     material.OnShoot = material.OnShoot or {}
--     onTable = material.OnShoot
--     onTable.Chance = '100'
--    elseif test == '[ON_PARRY' then
--     material.OnParry = material.OnParry or {}
--     onTable = material.OnParry
--     onTable.Chance = array[2]
--    elseif test == '[ON_PARRY]' then
--     material.OnParry = material.OnParry or {}
--     onTable = material.OnParry
--     onTable.Chance = '100'
--    elseif test == '[ON_DODGE' then
--     material.OnDodge = material.OnDodge or {}
--     onTable = material.OnDodge
--     onTable.Chance = array[2]
--    elseif test == '[ON_DODGE]' then
--     material.OnDodge = material.OnDodge or {}
--     onTable = material.OnDodge
--     onTable.Chance = '100'
--    elseif test == '[ON_BLOCK' then
--     material.OnBlock = material.OnBlock or {}
--     onTable = material.OnBlock
--     onTable.Chance = array[2]
--    elseif test == '[ON_BLOCK]' then
--     material.OnBlock = material.OnBlock or {}
--     onTable = material.OnBlock
--     onTable.Chance = '100'
--    elseif test == '[ON_WOUND' then
--     material.OnWound = material.OnWound or {}
--     onTable = material.OnWound
--     onTable.Chance = array[2]
--    elseif test == '[ON_WOUND]' then
--     material.OnWound = material.OnWound or {}
--     onTable = material.OnWound
--     onTable.Chance = '100'
--    elseif test == '[ON_PROJECTILE_MOVE]' then
--     material.OnProjectileMove = material.OnProjectileMove or {}
--	 onTable = material.OnProjectileMove
--	 onTable.Chance = '100'
--    elseif test == '[ON_PROJECTILE_MOVE' then
--     material.OnProjectileMove = material.OnProjectileMove or {}
--	 onTable = material.OnProjectileMove
--	 onTable.Chance = array[2]
--    elseif test == '[ON_PROJECTILE_HIT]' then
--     material.OnProjectileHit = material.OnProjectileHit or {}
-- 	 onTable = material.OnProjectileHit
--	 onTable.Chance = '100'
--    elseif test == '[ON_PROJECTILE_HIT' then
--     material.OnProjectileHit = material.OnProjectileHit or {}
--	 onTable = material.OnProjectileHit
--	 onTable.Chance = array[2]
--    elseif test == '[ON_PROJECTILE_FIRED]' then
--     material.OnProjectileFired = material.OnProjectileFired or {}
--	 onTable = material.OnProjectileFired
--	 onTable.Chance = '100'
--    elseif test == '[ON_PROJECTILE_FIRED' then
--     material.OnProjectileFired = material.OnProjectileFired or {}
--	 onTable = material.OnProjectileFired
--	 onTable.Chance = array[2]
--    elseif test == '[TRIGGER_CHANCE' then
--     onTable.Chance = array[2]
--    elseif test == '[ATTRIBUTE_CHANGE' then
--     onTable.Attributes = onTable.Attributes or {}
--     onTable.Attributes[array[2]] = array[3]
--    elseif test == '[SKILL_CHANGE' then
--     onTable.Skills = onTable.Skills or {}
--     onTable.Skills[array[2]] = array[3]
--    elseif test == '[TRAIT_CHANGE' then
--     onTable.Traits = onTable.Traits or {}
--     onTable.Traits[array[2]] = array[3]
--    elseif test == '[STAT_CHANGE' then
--     onTable.Stats = onTable.Stats or {}
--     onTable.Stats[array[2]] = array[3]
--    elseif test == '[RESISTANCE_CHANGE' then
--     onTable.Resistances = onTable.Resistances or {}
--     onTable.Resistances[array[2]] = array[3]
--    elseif test == '[INTERACTION_ADD' then
--     onTable.Interactions = onTable.Interactions or {}
--     onTable.Interactions[#onTable.Interactions+1] = array[2]
--    elseif test == '[SYNDROME_ADD' then
--     onTable.Syndromes = onTable.Syndromes or {}
--     onTable.Syndromes[#onTable.Syndromes+1] = array[2]
--    elseif test == '[ATTACKER_ATTRIBUTE_CHANGE' then
--     onTable.AttackerAttributes = onTable.AttackerAttributes or {}
--     onTable.AttackerAttributes[array[2]] = array[3]
--    elseif test == '[ATTACKER_SKILL_CHANGE' then
--     onTable.AttackerSkills = onTable.AttackerSkills or {}
--     onTable.AttackerSkills[array[2]] = array[3]
--    elseif test == '[ATTACKER_TRAIT_CHANGE' then
--     onTable.AttackerTraits = onTable.AttackerTraits or {}
--     onTable.AttackerTraits[array[2]] = array[3]
--    elseif test == '[ATTACKER_STAT_CHANGE' then
--     onTable.AttackerStats = onTable.AttackerStats or {}
--     onTable.AttackerStats[array[2]] = array[3]
--    elseif test == '[ATTACKER_RESISTANCE_CHANGE' then
--     onTable.AttackerResistances = onTable.AttackerResistances or {}
--     onTable.AttackerResistances[array[2]] = array[3]
--    elseif test == '[ATTACKER_INTERACTION_ADD' then
--     onTable.AttackerInteractions = onTable.AttackerInteractions or {}
--     onTable.AttackerInteractions[#onTable.AttackerInteractions+1] = array[2]
--    elseif test == '[ATTACKER_SYNDROME_ADD' then
--     onTable.AttackerSyndromes = onTable.AttackerSyndromes or {}
--     onTable.AttackerSyndromes[#onTable.AttackerSyndromes+1] = array[2]
--    elseif test == '[ATTACKER_CHANGE_DUR' then
--     onTable.AttackerDur = array[2]
--    elseif test == '[DEFENDER_ATTRIBUTE_CHANGE' then
--     onTable.DefenderAttributes = onTable.DefenderAttributes or {}
--     onTable.DefenderAttributes[array[2]] = array[3]
--    elseif test == '[DEFENDER_SKILL_CHANGE' then
--     onTable.DefenderSkills = onTable.DefenderSkills or {}
--     onTable.DefenderSkills[array[2]] = array[3]
--    elseif test == '[DEFENDER_TRAIT_CHANGE' then
--     onTable.DefenderTraits = onTable.DefenderTraits or {}
--     onTable.DefenderTraits[array[2]] = array[3]
--    elseif test == '[DEFENDER_STAT_CHANGE' then
--     onTable.DefenderStats = onTable.DefenderStats or {}
--     onTable.DefenderStats[array[2]] = array[3]
--    elseif test == '[DEFENDER_RESISTANCE_CHANGE' then
--     onTable.DefenderResistances = onTable.DefenderResistances or {}
--     onTable.DefenderResistances[array[2]] = array[3]
--    elseif test == '[DEFENDER_INTERACTION_ADD' then
--     onTable.DefenderInteractions = onTable.DefenderInteractions or {}
--     onTable.DefenderInteractions[#onTable.DefenderInteractions+1] = array[2]
--    elseif test == '[DEFENDER_SYNDROME_ADD' then
--     onTable.DefenderSyndromes = onTable.DefenderSyndromes or {}
--     onTable.DefenderSyndromes[#onTable.DefenderSyndromes+1] = array[2]
--    elseif test == '[DEFENDER_CHANGE_DUR' then
--     onTable.DefenderDur = array[2]
--    elseif test == '[SCRIPT' or test == '[SPELL' then
--     onTable.Scripts = onTable.Scripts or {}
--     scripts = scripts + 1
--     onTable.Scripts[tostring(scripts)] = {}
--     a = data[j]
--     a = table.concat({select(2,table.unpack(split(a,':')))},':')
-- 	 n = string.find(string.reverse(a),':')
--     script = string.sub(a,1,-(n+1))
--	 chance = string.sub(a,-(n-1),-2)
--	 onTable.Scripts[tostring(scripts)].Script = script
--     onTable.Scripts[tostring(scripts)].Chance = chance
--    end
--   end
--  end
-- end
---- Copy any ALL material data into the respective MATERIAL:INDEX combo, INDEX material data is given priority
-- -- No need for inorganics
-- -- Creatures
-- for _,materialToken in pairs(materials.Creature._children) do
--  for n,creature in pairs(df.global.world.raws.creatures.all) do
--   if materialToken == creature.creature_id then
--    creatureID = n
--    break
--   end
--  end
--  if creatureID and materials.Creature[materialToken].ALL then
--   for _,material in pairs(creature.caste[0].materials) do
--    if not materials.Creature[materialToken][material.id] then
--     materials.Creature[materialToken][material.id] = {}
--    end
--   end
--  end
--  if materials.Creature[materialToken].ALL then
--   for _,materialIndex in pairs(materials.Creature[materialToken]._children) do
--    if not materialIndex == 'ALL' then
--     for _,x in pairs(materials.Creature[materialToken].ALL._children) do
--      if not materials.Creature[materialToken][materialIndex][x] then
--       materials.Creature[materialToken][materialIndex][x] = materials.Creature[materialToken].ALL[x]
--      else
--       for _,y in pairs(materials.Creature[materialToken].ALL[x]._children) do
--        if not materials.Creature[materialToken][materialIndex][x][y] then
--         materials.Creature[materialToken][materialIndex][x][y] = materials.Creature[materialToken].ALL[x][y]
--        end
--       end
--      end
--     end
--    end
--   end
--  end
-- end
-- -- Plants 
-- for _,materialToken in pairs(materials.Plant._children) do
--  for n,plant in pairs(df.global.world.raws.plants.all) do
--   if materialToken == plant.id then
--    plantID = n
--    break
--   end
--  end
--  if plantID and materials.Plant[materialToken].ALL then
--   for _,material in pairs(df.global.world.raws.plants.all[plantID].material) do
--    if not materials.Plant[materialToken][material.id] then
--     materials.Plant[materialToken][material.id] = {}
--    end
--   end
--  end
--  if materials.Plant[materialToken].ALL then
--   for _,materialIndex in pairs(materials.Plant[materialToken]._children) do
--    if not materialIndex == 'ALL' then
--     for _,x in pairs(materials.Plant[materialToken].ALL._children) do
--      if not materials.Plant[materialToken][materialIndex][x] then
--       materials.Plant[materialToken][materialIndex][x] = materials.Plant[materialToken].ALL[x]
--      else
--       for _,y in pairs(materials.Plant[materialToken].ALL[x]._children) do
--        if not materials.Plant[materialToken][materialIndex][x][y] then
--         materials.Plant[materialToken][materialIndex][x][y] = materials.Plant[materialToken].ALL[x][y]
--        end
--       end
--      end
--     end
--    end
--   end
--  end
-- end
-- return true
--end
