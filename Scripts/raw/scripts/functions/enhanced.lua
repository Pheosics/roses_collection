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
  local creatureID = df.global.world.raws.creatures.all[unit.race].id
  if EnhancedCreatureTable[creatureID] then
   unitTable.Enhanced = 'true'  
   local creatureTable = EnhancedCreatureTable[creatureID]
   if creatureTable.Size then setSize(unit,creatureTable.Size) end
   if creatureTable.Attributes then setAttributes(unit,creatureTable.Attributes) end
   if creatureTable.Skills then setSkills(unit,creatureTable.Skills) end
   if creatureTable.Stats then setStats(unit,creatureTable.Stats) end
   if creatureTable.Resistances then setResistances(unit,creatureTable.Resistances) end
   if creatureTable.Classes and classNeeded then setClass(unit,creatureTable.Classes) end
   if creatureTable.Interactions then setInteractions(unit,creatureTable.Classes) end
  else
   unittable.Enhanced = 'true'
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
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]  
 for _,skill in pairs(table._children) do
  local current = 0
  if not unitTable.Skills[skill] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Attributes',attribute) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Skills',skill)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[skill]['7']
  elseif rn > 85 then
   value = table[skill]['6']
  elseif rn > 65 then
   value = table[skill]['5']
  elseif rn < 5 then
   value = table[skill]['1']
  elseif rn < 15 then
   value = table[skill]['2']
  elseif rn < 35 then
   value = table[skill]['3']
  else
   value = table[skill]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'track')
 end
end

function setStats(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
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
