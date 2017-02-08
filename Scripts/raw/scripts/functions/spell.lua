-- Functions for the Spell SubSystem in the Class System, vN/A
-- NOTE: These scripts still need substantial work, and have not been tested yet (hence the N/A)
--[[
 calculateResistance(target,spell,verbose) -- Calculates the resistances for a given spell/target combo
 calculatePenetration(source,spell,verbose) -- Calculates the penetration for a given spell/source combo
 calculateHitChance(source,spell,verbose) -- Calculates the hit chance for a given spell/source combo
 Spell(source,target,spell,verbose) -- Sets up the spell, calculates various needed parameters, then calls castSpell to run the actual script
 castSpell(source,target,spell,verbose) -- Runs the scripts associated with the spell, replacing certain key strings with the appropriate numbers
]]
------------------------------------------------------------------------
function calculateResistance(target,spell,verbose)
 local resistance = 0
 local unit = target
 if not unit then return resistance end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 unitID = tostring(unit.id)
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return resistance
 end
 spellTable = spellTable[spell]
 if not spellTable.Resistable then return resistance end
 local getResistance = dfhack.script_environment('functions/unit').getUnit
 if spellTable.Type then typeResistance = getResistance(unit,'Resistances',spellTable.Type) end
 if spellTable.Sphere then sphereResistance = getResistance(unit,'Resistances',spellTable.Sphere) end
 if spellTable.School then schoolResistance = getResistance(unit,'Resistances',spellTable.School) end
 if spellTable.Discipline then disciplineResistance = getResistance(unit,'Resistances',spellTable.Discipline) end
 if spellTable.SubDiscipline then subdisciplineResistance = getResistance(unit,'Resistances',spellTable.SubDiscipline) end
 resistanceTable = {typeResistance,sphereResistance,schoolResistance,disciplineResistance,subdisciplineResistance}
 for _,x in pairs(spellTable.Resistable._children) do
  table.insert(resistanceTable,spellTable.Resistable[x])
 end
-- Should resistance just take the largest one?
-- resistance = table.sort(resistanceTable)[#resistanceTable]
-- Or should it be multiplicative?
-- for _,val in pairs(resistanceTable) do
--  resistance = resistance + val*(100-resistance)/100
-- end
-- Or should it just all add together?
 for _,val in pairs(resistanceTable) do
  resistance = resistance + val
 end
 return resistance
end

function calculatePenetration(source,spell,verbose)
 local penetrate = 0
 local unit = source
 if not unit then return penetrate end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 unitID = tostring(unit.id)
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return penetrate
 end
 spellTable = spellTable[spell]
 local spellPenetrate = spellTable.Penetrate or 0
 local getPenetrate = dfhack.script_environment('functions/unit').getUnit
 local basePenetrate = getPenetrate(unit,'Stats','SKILL_PENETRATION')
 if spellTable.Type then typePenetrate = getPenetrate(unit,'Stats',spellTable.Type..'_SKILL_PENETRATION') end
 if spellTable.Sphere then spherePenetrate = getPenetrate(unit,'Stats',spellTable.Sphere..'_SKILL_PENETRATION') end
 if spellTable.School then schoolPenetrate = getPenetrate(unit,'Stats',spellTable.School..'_SKILL_PENETRATION') end
 if spellTable.Discipline then disciplinePenetrate = getPenetrate(unit,'Stats',spellTable.Discipline..'_SKILL_PENETRATION') end
 if spellTable.SubDiscipline then subdisciplinePenetrate = getPenetrate(unit,'Stats',spellTable.SubDiscipline..'_SKILL_PENETRATION') end
 penetrateTable = {spellPenetrate,basePenetrate,typePenetrate,spherePenetrate,schoolPenetrate,disciplinePenetrate,subdisciplinePenetrate}
 if spellTable.Resistable then
  for _,x in pairs(spellTable.Resistable._children) do
   table.insert(penetrateTable,getPenetrate(unit,'Stats',spellTable.Resistable[x]..'_SKILL_PENETRATION'))
  end
 end
-- Should penetration just take the largest one?
-- penetrate = table.sort(penetrateTable)[#penetrateTable]
-- Or should it be multiplicative?
-- for _,val in pairs(penetrateTable) do
--  penetrate = penetrate + val*(100-penetrate)/100
-- end
-- Or should it just all add together?
 for _,val in pairs(penetrateTable) do
  penetrate = penetrate + val
 end
 return penetrate
end

function calculateHitChance(source,spell,verbose)
 local hitchance = 100
 if not source then return hitchance end
 if tonumber(source) then source = df.unit.find(tonumber(source)) end
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return hitchance
 end
 spellTable = spellTable[spell]
 if spellTable.Type then
  hitchance = dfhack.script_environment('functions/misc').fillEquation(source,spell,spellTable.Type..'_HIT_CHANCE')
 else
  hitchance = dfhack.script_environment('functions/misc').fillEquation(source,spell,'MAGICAL_HIT_CHANCE')
 end
 --[[
 spellTable = spellTable[spell]
 local spellHitBonus = spellTable.HitChance or 0
 local spellHitPerc = spellTable.HitChancePerc or 100
 local getHit = dfhack.script_environment('functions/unit').getUnit
 local baseHit = getPenetrate(unit,'Stats','HIT_CHANCE')
 local hitTable = {baseHit,spellHitBonus}
 if spellTable.Type then table.insert(hitTable,getHit(unit,'Stats',spellTable.Type..'_HIT_CHANCE')) end
 if spellTable.Sphere then table.insert(hitTable,getHit(unit,'Stats',spellTable.Sphere..'_HIT_CHANCE') end
 if spellTable.School then table.insert(hitTable,getHit(unit,'Stats',spellTable.School..'_HIT_CHANCE') end
 if spellTable.Discipline then table.insert(hitTable,getHit(unit,'Stats',spellTable.Discipline..'_HIT_CHANCE') end
 if spellTable.SubDiscipline then table.insert(hitTable,getHit(unit,'Stats',spellTable.SubDiscipline..'_HIT_CHANCE') end
-- Should penetration just take the largest one?
-- hitchance = table.sort(hitTable)[#hitTable]
-- Or should it be multiplicative?
-- for _,val in pairs(hitTable) do
-- hitchance = hitchance + val*(100-hitchance)/100
-- end
-- Or should it just all add together?
 for _,val in pairs(hitTable) do
  hitchance = hitchance + val
 end
 hitchance = hitchance*(spellHitPerc/100)
 ]]
 return hitchance
end

function Spell(source,target,spell,verbose)
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return
 end
 spellTable = spellTable[spell]
 if source then 
  if tonumber(source) then source = df.unit.find(tonumber(source)) end
  sourceID = tostring(source.id)
 else
  sourceID = nil
 end
 if target then
  if tonumber(target) then target = df.unit.find(tonumber(target)) end
  targetID = tostring(target.id)
 else
  targetID = nil
 end
 if sourceID then
  local unitTable = persistTable.GlobalTable.roses.UnitTable
  if not unitTable[sourceID] then dfhack.script_environment('functions/tables').makeUnitTable(source) end
  unitTable = unitTable[sourceID]
  if spellTable.Type then
   speedPerc = dfhack.script_environment('functions/misc').fillEquation(source,spell,spellTable.Type..'_SPEED_PERC')
   exaustion = dfhack.script_environment('functions/misc').fillEquation(source,spell,spellTable.Type..'_EXHAUSTION_MODIFIER')
  else
   speedPerc = dfhack.script_environment('functions/misc').fillEquation(source,spell,'MAGICAL_SPEED_PERC')
   exaustion = dfhack.script_environment('functions/misc').fillEquation(source,spell,'MAGICAL_EXHAUSTION_MODIFIER')
  end
 else
  speedPerc = 100
  exhaustion = 0
 end
 -- process spell -> Set delay (if necessary) -> Cast Spell -> Gain Experience -> Gain Skill -> Add Exhaustion
 if spellTable.CastTime and speedPerc > 0 then
  speed = math.floor((speedPerc/100)*tonumber(spellTable.CastTime))
  if speed == 0 then speed = 1 end
  if sourceID then dfhack.run_command('unit/action-change -unit '..sourceID..' -action All -interaction All -timer '..tostring(speed)))
  dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/class','castSpell',{sourceID,targetID,spell})
 else
  castSpell(source,target,spell)
 end
 if exhaustion > 0 and sourceID then dfhack.script_environment('functions/unit').changeCounter(sourceID,'exhaustion',exhaustion) end
 if spellTable.ExperienceGain and sourceID then dfhack.script_environment('functions/class').addExperience(sourceID,tonumber(spellTable.ExperienceGain)) end
 if spellTable.SkillGain and sourceID then
  for _,skill in pairs(spellTable.SkillGain._children) do
   amount = spellTable.SkillGain[skill]
   dfhack.script_environment('functions/unit').changeSkill(sourceID,skill,amount)
  end
 end
end

function castSpell(source,target,spell,verbose)
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return
 end
 spellTable = spellTable[spell]
 if source then
  if tonumber(source) then source = df.unit.find(tonumber(source)) end
  sourceID = tostring(source.id)
 else
  sourceID = "\\-1"
 end
 if target then
  if tonumber(target) then target = df.unit.find(tonumber(target)) end
  targetID = tostring(target.id)
 else
  targetID = "\\-1"
 end
 for _,i in pairs(spellTable.Script._children) do
  script = spellTable.Script[i]
  script = script:gsub('SPELL_TARGET',targetID)
  script = script:gsub('\\TARGET_ID',targetID)
  script = script:gsub('\\DEFENDER_ID',targetID)
  script = script:gsub('SPELL_SOURCE',sourceID)
  script = script:gsub('\\SOURCE_ID',sourceID)
  script = script:gsub('\\ATTACKER_ID',sourceID)
  dfhack.run_command(script)
 end
end
