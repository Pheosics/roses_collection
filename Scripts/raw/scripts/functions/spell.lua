-- Functions for the Spell SubSystem in the Class System, vN/A
-- NOTE: These scripts still need substantial work, and have not been tested yet (hence the N/A)
--[[
 calculateAttribute(unit,spell,base,check,verbose)
 calculateSkill(unit,spell,base,verbose)
 calculateStat(unit,spell,base,verbose)
 calculateResistance(target,spell,verbose)
 Spell(source,target,spell,verbose)
 castSpell(source,target,spell,verbose)
]]
------------------------------------------------------------------------
function calculateAttribute(unit,spell,base,check,verbose)
 -- Check that we have a valid unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return 0 end

 -- Get the Spell Table for this Spell
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return 0
 end
 spellTable = spellTable[spell]

 -- Calculate the average of the Primary or Secondary Attributes
 if base == 'PRIMARY' then
  if check == 'SOURCE' then
   Table = spellTable.SourcePrimaryAttribute
  elseif check == 'TARGET' then
   Table = spellTable.TargetPrimaryAttribute
  end
 elseif base == 'SECONDARY' then
  if check == 'SOURCE' then
   Table = spellTable.SourceSecondaryAttribute
  elseif check == 'TARGET' then
   Table = spellTable.TargetSecondaryAttribute
  end
 end

 local attribute = 0
 if Table then
  for _,n in pairs(Table._children) do
   attCheck = Table[n]
   attribute = attribute + dfhack.script_environment('functions/unit').getUnit(unit,'Attributes',attCheck,verbose)
  end
  attribute = attribute/(#Table._children) 
 end
 return attribute
end

function calculateSkill(unit,spell,base,verbose)
 -- Check that we have a valid unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return 0 end

 -- Get the Spell Table for this Spell
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return 0
 end
 spellTable = spellTable[spell]

 -- Get the Global Skill
 local skill = dfhack.script_environment('functions/unit').getUnit(unit,'Skills',base,verbose)

 -- Get the TSSDS Skill
 local TSSDS = {}
 if spellTable.Type then table.insert(TSSDS,spellTable.Type) end
 if spellTable.Sphere then table.insert(TSSDS,spellTable.Sphere) end
 if spellTable.School then table.insert(TSSDS,spellTable.School) end
 if spellTable.Discipline then table.insert(TSSDS,spellTable.Discipline) end
 if spellTable.SubDiscipline then table.insert(TSSDS,spellTable.SubDiscipline) end
 for _,add in pairs(TSSDS) do
  sklCheck = add..'_'..base
  skill = skill + dfhack.script_environment('functions/unit').getUnit(unit,'Skills',sklCheck,verbose)
 end

 return skill
end

function calculateStat(unit,spell,base,verbose)
 -- Check that we have a valid unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return 0 end

 -- Get the Spell Table for this Spell
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return 0
 end
 spellTable = spellTable[spell]

 -- Get the Global Stat
 local stat = dfhack.script_environment('functions/unit').getUnit(unit,'Stats',base,verbose)

 -- Get the TSSDS Stats
 local TSSDS = {}
 if spellTable.Type then table.insert(TSSDS,spellTable.Type) end
 if spellTable.Sphere then table.insert(TSSDS,spellTable.Sphere) end
 if spellTable.School then table.insert(TSSDS,spellTable.School) end
 if spellTable.Discipline then table.insert(TSSDS,spellTable.Discipline) end
 if spellTable.SubDiscipline then table.insert(TSSDS,spellTable.SubDiscipline) end
 for _,add in pairs(TSSDS) do
  sttCheck = add..'_'..base
  stat = stat + dfhack.script_environment('functions/unit').getUnit(unit,'Stats',sttCheck,verbose)
 end

 -- Spells have innate penetration and hit modifiers that need to be taken into account
 if base == 'PENETRATION' then
  if spellTable.Penetration then stat = stat + tonumber(spellTable.Penetration) end
 elseif base == 'HIT_CHANCE' then
  if spellTable.HitModifier then stat = stat + tonumber(spellTable.HitModifier) end
  if spellTable.HitModifierPerc then stat = stat*(tonumber(spellTable.HitModifierPerc)/100) end
 end
 return stat
end

function calculateResistance(unit,spell,verbose)
 -- Check that we have a valid unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return 0 end

 -- Get the Spell Table for this Spell
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return 0
 end
 spellTable = spellTable[spell]
 if not spellTable.Resistable then return 0 end

 -- Get any global resistance
 local resistance = dfhack.script_environment('functions/unit').getUnit(unit,'Resistances','RESISTANCE',verbose)

 -- Get the TSSDS Resistances 
 local TSSDS = {}
 if spellTable.Type then table.insert(TSSDS,spellTable.Type) end
 if spellTable.Sphere then table.insert(TSSDS,spellTable.Sphere) end
 if spellTable.School then table.insert(TSSDS,spellTable.School) end
 if spellTable.Discipline then table.insert(TSSDS,spellTable.Discipline) end
 if spellTable.SubDiscipline then table.insert(TSSDS,spellTable.SubDiscipline) end
 for _,add in pairs(TSSDS) do
  resCheck = add..'_'..base
  resistance = resistance + dfhack.script_environment('functions/unit').getUnit(unit,'Resistances',rstCheck,verbose)
 end

 return resistance
end

function Spell(sourceID,targetID,spell,verbose)
 -- Get the SpellTable for this spell
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return
 end
 spellTable = spellTable[spell]

 -- Calculate Exhaustion and Casting Speed
 if sourceID then
  if spellTable.Type then
   speedPerc = fillEquation(source,spell,spellTable.Type..'_SPEED_PERC')
   exaustion = fillEquation(source,spell,spellTable.Type..'_EXHAUSTION_MODIFIER')
  else
   speedPerc = fillEquation(source,spell,'MAGICAL_SPEED_PERC')
   exaustion = fillEquation(source,spell,'MAGICAL_EXHAUSTION_MODIFIER')
  end
 else
  speedPerc = 100 -- Normal Casting Speed
  exhaustion = 0  -- No Exhaustion Cost
 end

 -- process spell -> Set delay (if necessary) -> Cast Spell
 if spellTable.CastTime and speedPerc > 0 then
  speed = math.floor((speedPerc/100)*tonumber(spellTable.CastTime))
  if speed == 0 then speed = 1 end
  if sourceID then dfhack.run_command('unit/action-change -unit '..sourceID..' -action All -interaction All -timer '..tostring(speed))
  dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/class','castSpell',{sourceID,targetID,spell})
 else
  castSpell(sourceID,targetID,spell)
 end

 -- Add Exhaustion
 if exhaustion > 0 and sourceID then dfhack.script_environment('functions/unit').changeCounter(sourceID,'exhaustion',exhaustion) end

 -- Gain Experience
 if spellTable.ExperienceGain and sourceID then dfhack.script_environment('functions/class').addExperience(sourceID,tonumber(spellTable.ExperienceGain)) end

 -- Gain Skill
 if spellTable.SkillGain and sourceID then
  for _,skill in pairs(spellTable.SkillGain._children) do
   amount = spellTable.SkillGain[skill]
   dfhack.script_environment('functions/unit').changeSkillExp(sourceID,skill,amount)
  end
 end
end

function castSpell(sourceID,targetID,spell)
 -- Get Spell Table for this Spell
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return
 end
 spellTable = spellTable[spell]

 -- Change Unit IDs to strings for output
 if sourceID then
  sourceStr = tostring(source.id)
 else
  sourceStr = "\\-1"
 end
 if targetID then
  targetStr = tostring(target.id)
 else
  targetStr = "\\-1"
 end

 -- Fill the script with correct values
 for _,i in pairs(spellTable.Script._children) do
  script = spellTable.Script[i]
  -- Calculate any necessary equation values
  while script:find('EQUATION') do
   look = string.match(script..'+',"EQUATION.(.-)[+%-*/]")
   array = split(look,"%.")
   value = fillEquation(sourceID,targetID,spell,array[1])
   script = script:gsub(string.match(script..'+',"(EQUATION.-)[+%-*/]"),tostring(value))
  end
  -- Fill target and source information
  script = script:gsub('SPELL_TARGET',targetStr)
  script = script:gsub('\\TARGET_ID',targetStr)
  script = script:gsub('\\DEFENDER_ID',targetStr)
  script = script:gsub('SPELL_SOURCE',sourceStr)
  script = script:gsub('\\SOURCE_ID',sourceStr)
  script = script:gsub('\\ATTACKER_ID',sourceStr)
  dfhack.run_command(script)
 end

 -- Handle the script announcements
 -- TODO
 -- source_name = dfhack.unit.getVisibleName(df.unit.find(tonumber(source)))
 -- target_name = dfhack.unit.getVisibleName(df.unit.find(tonumber(target)))
end

function fillEquation(sourceID,targetID,spell,equation)
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 local unitFunctions = dfhack.script_environment('functions/unit')

 -- Get equation if a built in one
 local equationTable = persistTable.GlobalTable.roses.baseTable.Equations
 if equationTable then
  if equationTable[string.upper(equation)] then 
   equation = equationTable[string.upper(equation)]
  end
 end
  
 -- Loop over SOURCE and TARGET to fill all variables
 for _,check in pairs({'SOURCE','TARGET'}) do
  if check == 'SOURCE' then
   if not sourceID then
    break
   else
    unitID = sourceID
   end
  elseif check == 'TARGET' then
   if not targetID then
    break
   else
    unitID = targetID
   end
  end

  -- Handle all SOURCE and all TARGETS
  while equation:find(check) do
   look = string.match(equation..'+',check..".(.-)[+%-*/]")
   array = split(look,"%.")
   if array[1] == 'ATTRIBUTE' then
    if array[2] == 'WEIGHT' then
     value = unitFunctions.calculateWieght(unitID,false)
    elseif array[2] == 'FULL_WEIGHT' then
     value = unitFunctions.calculateWieght(unitID,true)
    elseif array[2] == 'PRIMARY' and spell then
     value = calculateAttribute(sourceID,spell,'PRIMARY',check)
    elseif array[2] == 'SECONDARY' and spell then
     value = calculateAttribute(sourceID,spell,'SECONDARY',check)
    else
     value = unitFunctions.getUnit(unitID,'Attributes',array[2])
    end
   elseif array[1] == 'SKILL' then
    if array[2] == 'WEAPON' then
     value = unitFunctions.getWeaponSkill(unitID)
    elseif array[2]:find('!') and spell then
     value = calculateSkill(unitID,spell,split(array[2],'!')[2])
    else
     value = unitFunctions.getUnit(unitID,'Skills',array[2])
    end
   elseif array[1] == 'STAT' then
    if array[2]:find('!') and spell then
     value = calculateStat(unitID,spell,split(array[2],'!')[2])
    else
     value = unitFunctions.getUnit(unitID,'Stats',array[2])
    end
   elseif array[1] == 'RESISTANCE' then
    if array[2]:find('!') and spell then
     value = calculateResistance(unitID,spell)
    else
     value = unitFunctions.getUnit(unitID,'Resistances',array[2])
    end
   elseif array[1] == 'TRAIT' then
    value = unitFunctions.getUnit(unitID,'Traits',array[2])
   elseif array[1] == 'COUNTER' then
    value = unitFunction.getCounter(unitID,string.lower(array[2]))
   end
   equation = equation:gsub(string.match(equation..'+',"("..check..".-)[+%-*/]"),tostring(value))
  end
 end

 -- Check for spell calls (like SPELL.LEVEL)
 if spell then
  spellTable = persistTable.GlobalTable.roses.SpellTable[spell]
  while equation:find('SPELL') do
   look = string.match(equation..'+',"SPELL.(.-)[+%-*/]")
   array = split(look,"%.")
   if array[1] == 'LEVEL' then
    value = spellTable.Level or 1
   end
   equation = equation:gsub(string.match(equation..'+',"(SPELL.-)[+%-*/]"),tostring(value))
  end
 end

 -- Evaluate any recursive equations
 while equation:find('EQUATION') do
  look = string.match(equation..'+',"EQUATION.(.-)[+%-*/]")
  array = split(look,"%.")
  value = fillEquation(sourceID,targetID,spell,array[1])
  equation = equation:gsub(string.match(equation..'+',"(EQUATION.-)[+%-*/]"),tostring(value))
 end

 equals = assert(load("return "..equation))
 value = equals()
 return value
end

