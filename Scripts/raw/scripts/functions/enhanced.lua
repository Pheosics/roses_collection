------------------------------------------------------------------------------------------------------------------------
--------------------------------------- Enhanced Building System Functions ---------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function buildingCreated(building)
 local persistTable = require 'persist-table'
 if not safe_index(persistTable.GlobalTable.roses,'EnhancedBuildingTable') then return end
 EBuildings = persistTable.GlobalTable.roses.EnhancedBuildingTable
 ctype = building:getCustomType()
 if ctype < 0 then return end
 buildingToken = df.global.world.raws.buildings.all[ctype].code
 if not EBuildings[buildingToken] then return end
 
 -- Run any scripts attached to the building
 if EBuildings[buildingToken].Scripts then
  for _,i in pairs(EBuildings[buildingToken].Scripts._children) do
   x = EBuildings[buildingToken].Scripts[i]
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
------------------------------------------------------------------------------------------------------------------------
--------------------------------------- Enhanced Creature System Functions ---------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function enhanceCreature(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 if unitTable.Enhanced then return end
 local EnhancedCreatureTable = persistTable.GlobalTable.roses.EnhancedCreatureTable
 if EnhancedCreatureTable then
  local creatureID = df.global.world.raws.creatures.all[unit.race].creature_id
  local casteID = df.global.world.raws.creatures.all[unit.race].caste[unit.caste].caste_id
  if safe_index(EnhancedCreatureTable,creatureID,casteID) then
   unitTable.Enhanced = 'true'
   local creatureTable = EnhancedCreatureTable[creatureID][casteID]
   if creatureTable.Size then setSize(unit,creatureTable.Size) end
   if creatureTable.Attributes then setAttributes(unit,creatureTable.Attributes) end
   if creatureTable.Skills then setSkills(unit,creatureTable.Skills) end
   if creatureTable.Stats then setStats(unit,creatureTable.Stats) end
   if creatureTable.Resistances then setResistances(unit,creatureTable.Resistances) end
   if creatureTable.Classes and classNeeded then setClass(unit,creatureTable.Classes) end
   if creatureTable.Interactions then setInteractions(unit,creatureTable.Classes) end
  else
   unitTable.Enhanced = 'true'
  end
 else
  unitTable.Enhanced = 'true'
 end
end

function setAttributes(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)] 
 for _,attribute in pairs(table._children) do
  local current = 0
  if not unitTable.Attributes[attribute] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Attributes',attribute) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Attributes',attribute)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[attribute]['7']
  elseif rn > 85 then
   value = table[attribute]['6']
  elseif rn > 65 then
   value = table[attribute]['5']
  elseif rn < 5 then
   value = table[attribute]['1']
  elseif rn < 15 then
   value = table[attribute]['2']
  elseif rn < 35 then
   value = table[attribute]['3']
  else
   value = table[attribute]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,0,'track')
 end
end

function setClass(unit,table)

end

function setInteractions(unit,table)

end

function setResistances(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]  
 for _,resistance in pairs(table._children) do
  local current = 0
  if not unitTable.Resistances[resistance] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Resistances',resistance) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Resistances',resistance)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[resistance]['7']
  elseif rn > 85 then
   value = table[resistance]['6']
  elseif rn > 65 then
   value = table[resistance]['5']
  elseif rn < 5 then
   value = table[resistance]['1']
  elseif rn < 15 then
   value = table[resistance]['2']
  elseif rn < 35 then
   value = table[resistance]['3']
  else
   value = table[resistance]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,0,'track')
 end
end

function setSize(unit,table)

end

function setSkills(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]  
 for _,skill in pairs(table._children) do
  local current = 0
  if not unitTable.Skills[skill] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Skills',skill) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Skills',skill)
  value = math.floor(math.random(table[skill].Min,table[skill].Max))
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'track')
 end
end

function setStats(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]  
 for _,stat in pairs(table._children) do
  local current = 0
  if not unitTable.Stats[stat] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Stats',stat) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Stats',stat)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[stat]['7']
  elseif rn > 85 then
   value = table[stat]['6']
  elseif rn > 65 then
   value = table[stat]['5']
  elseif rn < 5 then
   value = table[stat]['1']
  elseif rn < 15 then
   value = table[stat]['2']
  elseif rn < 35 then
   value = table[stat]['3']
  else
   value = table[stat]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeStat(unit,stat,change,0,'track')
 end
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------- Enhanced Item System Functions -----------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function enhanceItemsInventory(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
end

function onItemEquip(item,unit)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
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
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
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
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
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

--------------------------------------------------------------------------------------------------------------------------
----------------------------------------- Enhanced Material System Functions ---------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
function enhanceMaterialsInventory(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
end

function onMaterialEquip(item,unit)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local persistTable = require 'persist-table'
 local matTable = persistTable.GlobalTable.roses.EnhancedMaterialTable
 local matToken = dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()
 local util = require 'utils'
 local split = util.split_string
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
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local persistTable = require 'persist-table'
 local matTable = persistTable.GlobalTable.roses.EnhancedMaterialTable
 local matToken = dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()
 local util = require 'utils'
 local split = util.split_string
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
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedMaterialTable
 local matToken = dfhack.matinfo.decode(item.mat_type,item.mat_index):getToken()
 local util = require 'utils'
 local split = util.split_string
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

--------------------------------------------------------------------------------------------------------------------------
----------------------------------------- Enhanced Reaction System Functions ---------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
function reactionStart(reactionToken,worker,building,job)
 local persistTable = require 'persist-table'
 if not safe_index(persistTable.GlobalTable.roses,'EnhancedReactionTable') then return end
 EReactions = persistTable.GlobalTable.roses.EnhancedReactionTable
 reaction = EReactions[reactionToken]
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
 local persistTable = require 'persist-table'
 if not safe_index(persistTable.GlobalTable.roses,'EnhancedReactionTable') then return end
 EReactions = persistTable.GlobalTable.roses.EnhancedReactionTable
 reaction = EReactions[reactionToken]
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
 local persistTable = require 'persist-table'
 if not safe_index(persistTable.GlobalTable.roses,'EnhancedReactionTable') then return end
 EReactions = persistTable.GlobalTable.roses.EnhancedReactionTable
 reaction = EReactions[reactionToken]
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