--spells/trigger.lua v0.8 | DFHack 43.05

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

validArgs = validArgs or utils.invert({
 'help',
 'source',
 'target',
 'spell',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[spells/trigger
  arguments:
   -help
     print this help message
   -source id
   -target id
   -spell TOKEN
 ]])
 return
end

spell = persistTable.GlobalTable.roses.SpellTable[args.spell]
if not spell then
 print('No spell found in database')
 return
end

if args.source and tonumber(args.source) then
 source = tonumber(args.source)
else
 source = nil
end
if args.target and tonumber(args.target) then
 target = tonumber(args.target)
else
 target = nil
end

dfhack.script_environment('functions/spell').Spell(source,target,args.spell,verbose)
