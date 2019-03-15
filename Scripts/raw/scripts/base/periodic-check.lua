--base/periodic-check v1.0 | DFHack 43.05

local period = 100
roses = dfhack.script_environment('base/roses-table').roses

-- Check all active units
for _,unit in pairs(df.global.world.units.active) do
 -- Enhanced Creature Checks
 if roses.Systems.EnhancedCreature then
  dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
 end
end
  
dfhack.timeout(period,'ticks', function () dfhack.run_command('base/periodic-check') end )
