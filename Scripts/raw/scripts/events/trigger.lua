-- events/trigger.lua v0.8 | DFHack 43.05

local utils = require 'utils'
local persistTable = require 'persist-table'

validArgs = utils.invert({
 'help',
 'event',
 'force',
 'verbose',
 'forceAll'
})
local args = utils.processArgs({...}, validArgs)

force = false
verbose = false
forceAll = false
if args.force then force = true end
if args.verbose then verbose = true end
if args.forceAll then
 force = true
 forceAll = true
end

triggered = {}
roses = dfhack.script_environment('base/roses-init').roses
eventTable = roses.EventTable
event = args.event
if not eventTable[event] then
 print('Not a valid event')
 return
end
if force or dfhack.script_environment('functions/event').checkRequirements(event,0,verbose) then
 triggered[0] = true
 for i,_ in pairs(eventTable[event].Effect) do
  if forceAll or dfhack.script_environment('functions/event').checkRequirements(event,tonumber(i),verbose) then
   triggered[tonumber(i)] = true
   contingency = tonumber(eventTable[event].Effect[i].Contingent) or 0
   if triggered[contingency] then dfhack.script_environment('functions/event').triggerEvent(event,tonumber(i),verbose) end
  end
 end
end
