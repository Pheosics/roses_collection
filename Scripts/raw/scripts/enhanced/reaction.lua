-- Only usable with the Enhanced System - Reactions SubSystem

local utils = require 'utils'
local persistTable = require 'persist-table'

if not safe_index(persistTable.GlobalTable.roses,'EnhancedReactionTable') then return end
EReactions = persistTable.GlobalTable.roses.EnhancedReactionTable

validArgs = utils.invert({
	'help',
	'worker',
	'target',
	'building',
	'location',
	'reaction',
	'job',
	'inputItems',
	'outputItems',
	'type',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print('Valid Args (real help TBD)')
 printall(validArgs)
 return
end

local reaction
if not args.reaction then
 error 'Must specify a -reaction'
 return
end
reaction = EReactions[args.reaction]
if not reaction then return end

local building
if args.building then
 building = df.building.find(tonumber(args.building))
else
 if args.worker then
  building = dfhack.buildings.findAtTile(df.unit.find(tonumber(args.worker)).pos)
 elseif args.target then
  building = dfhack.buildings.findAtTile(df.unit.find(tonumber(args.target)).pos)
 elseif args.location then
  building = dfhack.buildings.findAtTile(args.location[1],args.location[2],args.location[3])
 end
end
if not building then return end

worker = df.unit.find(tonumber(args.worker))

if reaction.DurReduction and reaction.BaseDur then
 local job
 if not args.job then return end
 for _,j in pairs(building.jobs) do
  if j.id == tonumber(args.job) then
   job = j
   break
  end
 end
 if not job then return end
 
 local skillLevel = 0
 if reaction.Skill then
  skillLevel = dfhack.script_environment('functions/unit').getUnit(worker,'Skills',reaction.Skill)
 else
  for _,rct in pairs(df.global.world.raws.reactions) do
   if rct.code == args.reaction then
    skillID = rct.skill
	break
   end
  end
  if skillID >= 0 then skillLevel = dfhack.script_environment('functions/unit').getUnit(worker,'Skills',df.job_skill[skillID]) end
 end
 
 local function delayReaction(n,job)
  n = n-1
  if n < 1 then return end
  job.completion_timer = -1
  dfhack.timeout(1,'ticks',function () delayReaction(n,job) end)
 end
 t = tonumber(reaction.BaseDur)
 incr = tonumber(reaction.DurReduction.Increment)*skillLevel
 tadj = t-incr
 if tadj < tonumber(reaction.DurReduction.MaxReduction) then tadj = tonumber(reaction.DurReduction.MaxReduction) end
 delayReaction(tadj,job)
end

if args.type == 'Start' then
 dfhack.script_environment('functions/enhanced').reactionStart(args.reaction,worker,building,args.job)
elseif args.type == 'End' then
 dfhack.script_environment('functions/enhanced').reactionEnd(args.reaction,worker,building)
elseif args.type == 'Product' then
 print(args.location)
 print(args.outputItems)
 print(args.inputItems)
 dfhack.script_environment('functions/enhanced').reactionProduct(args.reaction,worker,building,args.inputItems,args.outputItems)
end