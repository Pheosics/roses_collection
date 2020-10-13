-- base/roses-init.lua v1.0 | DFHack 43.05
--MUST BE LOADED IN ONLOAD.INIT
local utils = require 'utils'

validArgs = utils.invert({
 'help',
 'all',
 'classSystem',
 'civilizationSystem',
 'enhancedSystem',
 'eventSystem',
 'forceReload',
 'testRun',
 'verbose',
 'clear',
})
local args = utils.processArgs({...}, validArgs)
verbose = args.verbose

if args.testRun then args.forceReload = true end
if args.forceReload then 
 dfhack.script_environment('base/roses-table').initTable(args)
 loaded = true
end

if not loaded then
 local fname = nil
 savepath = dfhack.getSavePath()
 print("Searching for RosesPersist.dat in "..savepath)
 for _,f in pairs(dfhack.internal.getDir(savepath)) do
  if f == "RosesPersist.dat" then
   fname = savepath.."/RosesPersist.dat"
   break
  end
 end
 
 if fname then
  dfhack.script_environment('base/roses-table').loadFile(fname,verbose)
 else
  dfhack.script_environment('base/roses-table').initTable(args)
 end
 
 loaded = true
end



-- Misc Tables (Populated by miscellanious things in game and scripts) These are persistant tables
local persistTable = require 'persist-table'
persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
pT = persistTable.GlobalTable.roses
pT.CommandDelay     = pT.CommandDelay     or {}
pT.EnvironmentDelay = pT.EnvironmentDelay or {}
pT.CounterTable     = pT.CounterTable     or {}
pT.LiquidTable      = pT.LiquidTable      or {}
pT.FlowTable        = pT.FlowTable        or {}

--==========================================================================================================================
--= RUN BASE COMMANDS
if args.testRun then
 print('Base commands are run seperately for a -testRun')
else
 if args.verbose then
  print('Running base/persist-delay')
  dfhack.run_command('base/persist-delay -verbose')
  print('Running base/liquids-update')
  dfhack.run_command('base/liquids-update -verbose')
  print('Running base/flows-update')
  dfhack.run_command('base/flows-update -verbose')
  print('Running base/on-death')
  dfhack.run_command('base/on-death -verbose')
  print('Running base/on-time')
  dfhack.run_command('base/on-time -verbose')
  print('Running base/periodic-check')
  dfhack.run_command('base/periodic-check -verbose')
  print('Setting up triggers')
  dfhack.run_command('base/triggers -verbose')
 else
  dfhack.run_command('base/persist-delay')
  dfhack.run_command('base/liquids-update')
  dfhack.run_command('base/flows-update')
  dfhack.run_command('base/on-death')
  dfhack.run_command('base/on-time')
  dfhack.run_command('base/periodic-check')
  dfhack.run_command('base/triggers')
 end
end
--==========================================================================================================================
