-- combination of reaction-trigger and reaction-product-trigger by expwnent
-- expanded by Roses (Pheosics)
--
local eventful = require 'plugins.eventful'
local utils = require 'utils'
local split = utils.split_string

reactionStartTriggers   = reactionStartTriggers   or {}
reactionEndTriggers     = reactionEndTriggers     or {}
reactionProductTriggers = reactionProductTriggers or {}

validArgs = validArgs or utils.invert({
 'help',
 'clear',
 'trigger',
 'reaction',
 'requiredWater',
 'requiredMagma',
 'command', 
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(validArgs)
 return
end

if args.clear then
 reactionStartTriggers   = {}
 reactionEndTriggers     = {}
 reactionProductTriggers = {}
end

if not args.trigger then
 error('Must specify a trigger type')
 return
end

if not args.reaction then
 error('Must specify a reaction name')
 return
end

if not args.command then
 error('No command specified')
 return
end

if args.trigger == 'onStart' then
 reactionStartTriggers[args.reaction] = {}
elseif args.trigger == 'onFinish' then
 reactionEndTriggers[args.reaction] = {}
elseif args.trigger == 'onProduct' then
 reactionProductTriggers[args.reaction] = {}
end


eventful.onJobInitiated.reactionStartTrigger = function(job)
 if not job.reaction_name or job.reaction_name == '' then return end
 if not job.reaction_name or not reactionStartTriggers[job.reaction_name] then return end
 printall(job)
end

eventful.onJobCompleted.reactionEndTrigger = function(job)
 if not job.reaction_name or job.reaction_name == '' then return end
 if not job.reaction_name or not reactionEndTriggers[job.reaction_name] then return end
 printall(job)
end

eventful.onReactionComplete.reactionProductTrigger = function(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
 if not reactionProductTriggers[reaction.code] then return end
 printall(reaction)
 printall(reaction_product)
 printall(input_items)
 printall(input_reagents)
 printall(output_items)
end

local function processCommand(table,command)
 local command2 = {}
 for i,arg in ipairs(command) do
  if arg == '\\WORKER_ID' then
   command2[i] = ''..table.worker.id
  elseif arg == '\\BUILDING_ID' then
   command2[i] = ''..table.building.id
  elseif arg == '\\LOCATION' then
   command2[i] = ''..table.locStr
  elseif arg == '\\INPUT_ITEMS' then
   command2[i] = ''
  elseif arg == '\\INPUT_REAGENTS' then
   command2[i] = ''
  elseif arg == '\\PRODUCTS' then
   command2[i] = ''
  elseif arg == '\\OUTPUT_ITEMS' then
   command2[i] = ''
  elseif arg == '\\TARGET_ID' then
   command2[i] = ''
  elseif arg == '\\REACTION_NAME' then
   command2[i] = ''..table.reaction.code
  else
   command2[i] = arg
  end
 end
 dfhack.run_command(table.unpack(command2))
end

-- Enable Event Checking
eventful.enableEvent(eventful.eventType.JOB_INITIATED,1)
eventful.enableEvent(eventful.eventType.JOB_COMPLETED,0)
--eventful.enableEvent(eventful.eventType.JOB_PRODUCT,1) --Not actually a thing, only here so I don't forget about it later
eventful.enableEvent(eventful.eventType.UNLOAD,1)
eventful.onUnload.reactionTrigger = function()
 reactionStartTrigger   = {}
 reactionEndTrigger     = {}
 reactionProductTrigger = {}
end

