-- civilizations/level-up.lua v0.8 | DFHack 43.05

local utils = require 'utils'

validArgs = utils.invert({
 'help',
 'civ',
 'unit',
 'amount',
 'verbose',
 'override'
})
local args = utils.processArgs({...}, validArgs)

if args.unit then
 args.civ = df.unit.find(tonumber(args.unit)).civ_id
end
civid = tonumber(args.civ)
if args.amount then
 amount = tonumber(args.amount)
else
 amount = 1
end

yes = false
if args.override then
 yes = true
else
 yes = dfhack.script_environment('functions/civilization').checkRequirements(civid,args.verbose)
end
if yes then dfhack.script_environment('functions/civilization').changeLevel(civid,amount,args.verbose) end

