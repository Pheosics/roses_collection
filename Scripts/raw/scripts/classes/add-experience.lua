-- classes/add-experience v0.8 | DFHack 43.05

local utils = require 'utils'

validArgs = utils.invert({
 'help',
 'unit',
 'amount',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end

if args.amount and tonumber(args.amount) then
 amount = tonumber(args.amount)
else
 amount = 0
end

verbose = false
if args.verbose then verbose = true end

dfhack.script_environment('functions/class').addExperience(unit,amount,verbose)
