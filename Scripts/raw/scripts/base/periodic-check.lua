--base/periodic-check v1.0 | DFHack 43.05

local period = 100
local persistTable = require 'persist-table'
local roses = persistTable.GlobalTable.roses
if not roses then return end

-- Check all active units
for _,unit in pairs(df.global.world.units.active) do
 -- Enhanced Creature Checks
 dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
end
  
dfhack.timeout(period,'ticks', function () dfhack.run_command('base/periodic-check') end )
