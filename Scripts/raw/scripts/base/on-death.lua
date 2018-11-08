--base/classes.lua v1.0 | DFHack 43.05

local persistTable = require 'persist-table'
local utils = require 'utils'
local split = utils.split_string
local events = require "plugins.eventful"
events.enableEvent(events.eventType.UNIT_DEATH,10)

function expCheck(unit,unitTarget,radius)

 local xmin = unitTarget.pos.x - radius
 local xmax = unitTarget.pos.x + radius
 local ymin = unitTarget.pos.y - radius
 local ymax = unitTarget.pos.y + radius
 local zmin = unitTarget.pos.z - radius
 local zmax = unitTarget.pos.z + radius

 if (unit.pos.x >= xmin and unit.pos.x <= xmax and unit.pos.y >= ymin and unit.pos.y <= ymax and unit.pos.z >= zmin and unit.pos.z <= zmax) then
  if unit.civ_id == unitTarget.civ_id then return true end
 end

 return false
end

events.onUnitDeath.mainFunction=function(target_id)
 roses = persistTable.GlobalTable.roses
 if not roses then return  end

 target = df.unit.find(target_id)
 target_civ = target.civ_id
 target_race = target.race
 target_caste = target.caste
 target_creature_name = df.creature_raw.find(target_race).creature_id
 target_caste_name = df.creature_raw.find(target_race).caste[target_caste].caste_id
 if target_civ >= 0 then 
  target_civ_name = df.global.world.entities.all[target_civ].entity_raw.code
 else
  target_civ_name = 'NONE'
 end
 
 killer_id = tonumber(target.relationship_ids.LastAttacker)
 if killer_id >= 0 then
  killer = df.unit.find(killer_id)
  killer_civ = killer.civ_id
  killer_race = killer.race
  killer_caste = killer.caste
  killer_creature_name = df.creature_raw.find(killer_race).creature_id
  killer_caste_name = df.creature_raw.find(killer_race).caste[killer_caste].caste_id
  if killer_civ >= 0 then
   killer_civ_name = df.global.world.entities.all[killer_civ].entity_raw.code
  else
   killer_civ_name = 'NONE'
  end
 end

-- GeneralTable Checks
 if roses.GlobalTable then
  killTable = roses.GlobalTable.Kills
  if killer_id >= 0 then
   killTable.Total = killTable.Total or '0'
   killTable.Total = tostring(killTable.Total + 1)
   killTable[killer_creature_name] = killTable[killer_creature_name] or {}
   killTable[killer_creature_name].Total = killTable[killer_creature_name].Total or '0'
   killTable[killer_creature_name].Total = tostring(killTable[killer_creature_name].Total + 1)
   killTable[killer_creature_name][killer_caste_name] = killTable[killer_creature_name][killer_caste_name] or '0'
   killTable[killer_creature_name][killer_caste_name] = tostring(killTable[killer_creature_name][killer_caste_name] + 1)
   killTable[killer_civ_name] = killTable[killer_civ_name] or '0'
   killTable[killer_civ_name] = tostring(killTable[killer_civ_name] + 1)
  end
  deathTable = roses.GlobalTable.Deaths
  deathTable.Total = deathTable.Total or '0'
  deathTable.Total = tostring(deathTable.Total + 1)
  deathTable[target_creature_name] = deathTable[target_creature_name] or {}
  deathTable[target_creature_name].Total = deathTable[target_creature_name].Total or '0'
  deathTable[target_creature_name].Total = tostring(deathTable[target_creature_name].Total + 1)
  deathTable[target_creature_name][target_caste_name] = deathTable[target_creature_name][target_caste_name] or '0'
  deathTable[target_creature_name][target_caste_name] = tostring(deathTable[target_creature_name][target_caste_name] + 1)
  deathTable[target_civ_name] = deathTable[target_civ_name] or '0'
  deathTable[target_civ_name] = tostring(deathTable[target_civ_name] + 1)
 end

-- EntityTable Checks
 if roses.EntityTable then
  if killer_id >= 0 and killer_civ >= 0 then
   if not roses.EntityTable[tostring(killer_civ)] then dfhack.script_environment('functions/entity').makeEntityTable(tostring(killer_civ)) end
   killTable = roses.EntityTable[tostring(killer_civ)].Kills
   killTable.Total = killTable.Total or '0'
   killTable.Total = tostring(killTable.Total + 1)
   killTable[killer_creature_name] = killTable[killer_creature_name] or {}
   killTable[killer_creature_name][killer_caste_name] = killTable[killer_creature_name][killer_caste_name] or '0'
   killTable[killer_creature_name][killer_caste_name] = tostring(killTable[killer_creature_name][killer_caste_name] + 1)
  end
  if target_civ >= 0 then
   if not roses.EntityTable[tostring(target_civ)] then dfhack.script_environment('functions/entity').makeEntityTable(tostring(target_civ)) end
   deathTable = roses.EntityTable[tostring(target_civ)].Deaths
   deathTable.Total = deathTable.Total or '0'
   deathTable.Total = tostring(deathTable.Total + 1)
   deathTable[target_creature_name] = deathTable[target_creature_name] or {}
   deathTable[target_creature_name][target_caste_name] = deathTable[target_creature_name][target_caste_name] or '0'
   deathTable[target_creature_name][target_caste_name] = tostring(deathTable[target_creature_name][target_caste_name] + 1)
  end
 end

-- ClassTable Checks
 if roses.ClassTable and killer_id >= 0 then
  if safe_index(roses, 'EnhancedCreatureTable',target_race,target_caste,'Experience') then
   experience = tonumber(roses.EnhancedCreatureTable[target_race][target_caste].Experience)
  else
   experience = 1
  end

  experience_list = {}
  experience_radius = tonumber(roses.BaseTable.ExperienceRadius)
  if experience_radius == -1 then
   experience_list = {killer_id}
  else
   for i,unit in ipairs(df.global.world.units.active) do
    if expCheck(unit,killer,experience_radius) then experience_list[i] = unit.id end
   end
  end

  for _,unit_id in ipairs(experience_list) do
   dfhack.script_environment('functions/class').addExperience(unit_id,experience,true)
  end
 end
end
