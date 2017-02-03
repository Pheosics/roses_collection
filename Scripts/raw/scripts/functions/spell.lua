function calculateResistance(unit,spell)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 unitID = tostring(unit.id)
 local persistTable = require 'persist-table'
  
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  print('Not a valid spell')
  return
 end
 spellTable = spellTable[spell]
 if not spellTable.Resistable then return 0 end
  
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[unitID] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 unitTable = unitTable[unitID]
 if spellTable.Type then typeResistance = unitTable.Resistances[spellTable.Type] or 0 end
 if spellTable.Sphere then sphereResistance = unitTable.Resistances[spellTable.Sphere] or 0 end
 if spellTable.School then schoolResistance = unitTable.Resistances[spellTable.School] or 0 end
 if spellTable.Discipline then disciplineResistance = unitTable.Resistances[spellTable.Discipline] or 0 end
 if spellTable.SubDiscipline then subdisciplineResistance = unitTable.Resistances[spellTable.SubDiscipline] or 0 end
 resistance = typeResistance + (sphereResistance+schoolResistance)/2 + (disciplineResistance+subdisciplineResistance)/2
 if spellTable.Penetrate then penetration = tonumber(spellTable.Penetrate) else penetrate = 0 end
 
 return resistance-penetrate
end

function Spell(source,target,spell)
 if tonumber(source) then
  source = df.unit.find(tonumber(source))
 end
 if source then
  sourceID = tostring(source.id)
 else
  print('No valid source declared')
  return
 end
 if tonumber(target) then
  target = df.unit.find(tonumber(target))
 end
 if target then
  targetID = tostring(target.id)
 else
  targetID = nil
 end
 local persistTable = require 'persist-table'
 
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[sourceID] then
  dfhack.script_environment('functions/tables').makeUnitTable(source)
 end
 unitTable = unitTable[sourceID]
 
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  print('Not a valid spell')
  return
 end
 spellTable = spellTable[spell]

---- check for casting speed buffs/debuffs
-- if not unitTable.Stats.CastingSpeed then dfhack.script_environment('functions/tables').makeUnitTableStat(source,'CastingSpeed') end
-- speedTable = unitTable.Stats.CastingSpeed
-- speed = 100 - tonumber(speedTable.Base) - tonumber(speedTable.Change) - tonumber(speedTable.Item) - tonumber(speedTable.Class)
 
---- check for casting skill and determine exhaustion
-- if not unitTable.Skills['SPELL_CASTING'] then dfhack.script_environment('functions/tables').makeUnitTableSkill(source,'SPELL_CASTING') end
-- if unitTable.Skills['SPELL_CASTING'] and spellTable.CastExhaustion then
--  castTable = unitTable.Skills['SPELL_CASTING']
--  castSkill = tonumber(castTable.Base) + tonumber(castTable.Change) + tonumber(castTable.Item) + tonumber(castTable.Class)
--  if castSkill < 0 then castSkill = 0 end
--  if castSkill > 20 then castSkill = 20 end
--  exhaustion = (100 - 4*castSkill)/100
--  exhaustion = exhaustion*tonumber(spellTable.CastExhaustion)
-- else
--  exhaustion = 0
-- end
  
 speedPerc = dfhack.script_environment('functions/misc').fillEquation(source,nil,'CASTING_SPEED_PERC')
 exaustion = dfhack.script_environment('functions/misc').fillEquation(source,nil,'CASTING_EXHAUSTION_MODIFIER')
 if spellTable.Type and spellTable.CanCrit then
  if spellTable.Type == 'PHYSICAL' then
   critChance = dfhack.script_environment('functions/misc').fillEquation(source,nil,'PHYSICAL_CRIT_CHANCE')
  else
   critChance = dfhack.script_environment('functions/misc').fillEquation(source,nil,'MAGICAL_CRIT_CHANCE')
  end
 else
  critChance = dfhack.script_environment('functions/misc').fillEquation(source,nil,'MAGICAL_CRIT_CHANCE')
 end
      
 -- process spell -> Set delay (if necessary) -> Cast Spell -> Gain Experience -> Gain Skill -> Add Exhaustion
 if spellTable.CastTime and speedPerc > 0 then
  speed = math.floor((speedPerc/100)*tonumber(spellTable.CastTime))
  if speed == 0 then speed = 1 end
  dfhack.run_command('unit/action-change -unit '..sourceID..' -action All -interaction All -timer '..tostring(speed))
  dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/class','castSpell',{sourceID,targetID,spell})
 else
  castSpell(source,target,spell)
 end
 if exhaustion > 0 then dfhack.script_environment('functions/unit').changeCounter(sourceID,'exhaustion',exhaustion) end
 if spellTable.ExperienceGain then dfhack.script_environment('functions/class').addExperience(sourceID,tonumber(spellTable.ExperienceGain)) end
 if spellTable.SkillGain then
  for _,skill in pairs(spellTable.SkillGain._children) do
   amount = spellTable.SkillGain[skill]
   dfhack.script_environment('functions/unit').changeSkill(sourceID,skill,amount)
  end
 end
end

function castSpell(source,target,spell)
 if tonumber(source) then
  source = df.unit.find(tonumber(source))
 end
 if source then
  sourceID = tostring(source.id)
 else
  sourceID = "\\-1"
 end
 if tonumber(target) then
  target = df.unit.find(tonumber(target))
 end
 if target then
  targetID = tostring(target.id)
 else
  targetID = "\\-1"
 end
 
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  print('Not a valid spell')
  return
 end
 spellTable = spellTable[spell]
 
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
