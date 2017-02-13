local period = 100
local persistTable = require 'persist-table'
local roses = persistTable.GlobalTable.roses
if not roses then return end

-- Check all active units
for id,unit in pairs(df.globa.world.units.active) do
 if not roses.UnitTable[tostring(id)] then dfhack.script_environment('functions/unit').makeUnitTable(unit) end
 local unitTable = roses.UnitTable[tostring(id)]
 -- Class checks
 local classNeeded = false
 if roses.ClassTable and unitTable.Classes.Current.Name == 'NONE' then classNeeded = true end
 -- Civilization Creature Checks
 if roses.CivilizationTable and roses.ClassTable and classNeeded and unit.race > 0 then
  if roses.EntityTable[tostring(unit.race)].Civilization then
   changed = dfhack.script_environment('functions/civilization').setClass(unit,roses.EntityTable[tostring(unit.race)].Civilization.Classes)
   if changed then classNeeded = false end
  end
 end
 -- Enhanced Creature Checks
 if roses.EnhancedCreatureTable and not unitTable.Enhanced then
  dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
 end
end
  
dfhack.timeout(period,'ticks', function () dfhack.run_command('base/periodic-check) end )
