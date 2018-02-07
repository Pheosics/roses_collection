-- combination of reaction-trigger and reaction-product-trigger by expwnent
-- expanded by Roses (Pheosics)
--
local usage = [====[

modtools/reaction-trigger
=========================
Triggers dfhack commands when custom reactions complete, regardless of whether
it produced anything, once per completion.  Arguments::

    -clear
        unregister all reaction hooks
    -reactionName name
        specify the name of the reaction
    -syndrome name
        specify the name of the syndrome to be applied to the targets
    -allowNonworkerTargets
        allow other units in the same building to be targetted by
        either the script or the syndrome
    -allowMultipleTargets
        allow multiple targets to the script or syndrome
        if absent:
            if running a script, only one target will be used
            if applying a syndrome, then only one target will be infected
    -resetPolicy policy
        the policy in the case that the syndrome is already present
        policy
            NewInstance (default)
            DoNothing
            ResetDuration
            AddDuration
    -command [ commandStrs ]
        specify the command to be run on the target(s)
        special args
            \\WORKER_ID
            \\TARGET_ID
            \\BUILDING_ID
            \\LOCATION
            \\REACTION_NAME
            \\anything -> \anything
            anything -> anything

]====]
local eventful = require 'plugins.eventful'
local utils = require 'utils'
local syndromeUtil = require 'syndrome-util'

reactionStartTriggers   = reactionStartTriggers   or {}
reactionEndTriggers     = reactionEndTriggers     or {}
reactionProductTriggers = reactionProductTriggers or {}

validArgs = validArgs or utils.invert({
 'help',
 'clear',
 'trigger',
 'reaction',
 'delay',
 'requiredWater',
 'requiredMagma',
 'command',
 'allowNonworkerTargets',
 'allowMultipleTargets',
 'syndrome',
 'resetPolicy'
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.clear then
 reactionStartTriggers   = {}
 reactionEndTriggers     = {}
 reactionProductTriggers = {}
 return
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

if not args.trigger then
 if args.delay or args.requiredMagma or args.requiredWater then args.trigger = 'onStart' end
end

if args.delay and not args.trigger == 'onStart' then error('-delay only works when -trigger is set to onStart') return end
if args.requiredMagma and not args.trigger == 'onStart' then error('-requiredMagma only works when -trigger is set to onStart') return end
if args.requiredWater and not args.trigger == 'onStart' then error('-requiredWater only works when -trigger is set to onStart') return end

if args.trigger == 'onStart' then
 reactionStartTriggers[args.reaction] = {}
 if args.delay then reactionStartTriggers[args.reaction].delay = tonumber(args.delay) end
 if args.requiredMagma then reactionStartTriggers[args.reaction].RequiredMagma = tonumber(args.requiredMagma) end
 if args.requiredWater then reactionStartTriggers[args.reaction].RequiredWater = tonumber(args.requiredWater) end
 trigger = reactionStartTriggers[args.reaction]
elseif args.trigger == 'onFinish' then
 reactionEndTriggers[args.reaction] = {}
 trigger = reactionEndTriggers[args.reaction]
elseif args.trigger == 'onProduct' then
 reactionProductTriggers[args.reaction] = {}
 trigger = reactionProductTriggers[args.reaction]
end

trigger.command = args.command
trigger.syndrome = args.syndrome
trigger.resetPolicy = args.resetPolicy
trigger.allowMultipleTargets = args.allowMultipleTargets
trigger.allowNonworkerTargets = args.allowNonworkerTargets

--=================================================================================================
function delayReaction(n,job)
 n = n-1
 if n < 1 then return end
 job.completion_timer = -1
 dfhack.timeout(1,'ticks',function () delayReaction(n,job) end)
end

function getWorkerandBuilding(job)
 worker = false
 building = false
 for _,gref in pairs(job.general_refs) do
  if gref._type == df.general_ref_unit_workerst then
   worker = gref.unit_id
  elseif gref._type == df.general_ref_building_holderst then
   building = gref.building_id
  end
 end
 return worker,building
end

function handleJob(job,triggers)
 worker,building = getWorkerandBuilding(job)
 if not building then return end
 if not worker then
  dfhack.timeout(1,'ticks',function () handleJob(job,triggers) end)
  return
 end
 for _,rct in pairs(df.global.world.raws.reactions) do
  if rct.code == job.reaction_name then
   reaction = rct
   break
  end
 end
 if not reaction then return end
 local tbl = {}
 tbl.unit = worker
 tbl.building = building
 tbl.reaction = reaction
 tbl.job = job
 yes = handleTriggers(tbl,triggers)
 if triggers.delay and yes and job then
  delayReaction(reactionStartTriggers[job.reaction_name].delay,job)
 end
end

function handleProduct(reaction,reaction_product,unit,input_items,input_reagents,output_items)
 local _,building = getWorkerandBuilding(unit.job.current_job)
 local tbl = {}
 tbl.unit = unit.id
 tbl.reaction = reaction
 tbl.building = building
 tbl.job = unit.job.current_job
 tbl.InputItems = input_items
 tbl.OutputItems = output_items
 yes = handleTriggers(tbl,reactionProductTriggers[reaction.code])
end

function handleTriggers(tbl,trigger)
 local go = true
 worker = df.unit.find(tbl.unit)
 building = df.building.find(tbl.building)
 tbl.locStr = ''..building.centerx..' '..building.centery..' '..building.z..''
 magPos = {}
 watPos = {}
 -- Check for required amount of water and magma
 if trigger.RequiredWater then
  amount = 0
  pos = {}
  for x = building.x1-1,building.x2+1 do
   for y = building.y1-1,building.y2+1 do
    for z = building.z-1,building.z do
     if dfhack.maps.isValidTilePos(x,y,z) then
      designation = dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16]
      if not designation.liquid_type and designation.flow_size > 0 then 
       amount = amount + designation.flow_size
	   watPos[#watPos+1] = {x,y,z}
	  end
     end
    end
   end
  end
  if amount < trigger.RequiredWater then go = false end
 end
 if trigger.RequiredMagma and go then
  amount = 0
  pos = {}
  for x = building.x1-1,building.x2+1 do
   for y = building.y1-1,building.y2+1 do
    for z = building.z-1,building.z do
     if dfhack.maps.isValidTilePos(x,y,z) then
      designation = dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16]
      if designation.liquid_type and designation.flow_size > 0 then 
	   amount = amount + designation.flow_size
	   magPos[#magPos+1] = {x,y,z}
	  end
     end
    end
   end
  end
  if amount < trigger.RequiredMagma then go = false end
 end
 if go then
  -- Remove required water
  for _,pos in pairs(watPos) do
   x = pos[1]
   y = pos[2]
   z = pos[3]
   flow = dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16].flow_size
   if flow >= trigger.RequiredMagma then
	dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16].flow_size = flow-trigger.RequiredMagma
    break
   else
	dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16].flow_size = 0
	trigger.RequiredMagma = trigger.RequiredMagma - flow
   end
  end 
  -- Remove required magma
  for _,pos in pairs(magPos) do
   x = pos[1]
   y = pos[2]
   z = pos[3]
   flow = dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16].flow_size
   if flow >= trigger.RequiredMagma then
	dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16].flow_size = flow-trigger.RequiredMagma
    break
   else
	dfhack.maps.getTileBlock(x,y,z).designation[x%16][y%16].flow_size = 0
	trigger.RequiredMagma = trigger.RequiredMagma - flow
   end
  end 
  -- Run command and/or apply syndrome
  local function doAction(action)
   local didSomething
   if action.command then
    tbl.target = worker.id
    processCommand(tbl, action.command)
   end
   if action.syndrome then
    didSomething = syndromeUtil.infectWithSyndromeIfValidTarget(worker, action.syndrome, action.resetPolicy) or didSomething
   end
   if didSomething and not action.allowMultipleTargets then
    return
   end
   local function foreach(unit)
    if unit == worker then
     return false
    elseif unit.pos.z ~= building.z then
     return false
    elseif unit.pos.x < building.x1 or unit.pos.x > building.x2 then
     return false
    elseif unit.pos.y < building.y1 or unit.pos.y > building.y2 then
     return false
    else
     if action.command then
	  tbl.target = unit.id
      processCommand(tbl, action.command)
     end
     if action.syndrome then
      didSomething = syndrome.infectWithSyndromeIfValidTarget(unit,action.syndrome,action.resetPolicy) or didSomething
     end
     if didSomething and not action.allowMultipleTargets then
      return true
     end
     return false
    end
   end
   for _,unit in ipairs(df.global.world.units.all) do
    if foreach(unit) then
     break
    end
   end
  end
  doAction(trigger)
  return true
 else
  dfhack.jobs.removeJob(tbl.job)
  return false
 end
end

function processCommand(tbl,command)
 local command2 = {}
 for i,arg in ipairs(command) do
  if arg == 'WORKER_ID' then
   command2[i] = ''..tbl.unit
  elseif arg == 'TARGET_ID' then
   command2[i] = ''..tbl.target
  elseif arg == 'BUILDING_ID' then
   command2[i] = ''..tbl.building
  elseif arg == 'LOCATION' then
   command2[i] = ''..tbl.locStr
  elseif arg == 'REACTION_NAME' then
   command2[i] = ''..tbl.reaction.code
  elseif arg == 'JOB_ID' then
   command2[i] = ''..tbl.job.id
  elseif arg == 'INPUT_ITEMS' and tbl.InputItems then
   strTemp = ''
   for _,item in pairs(tbl.InputItems) do
    strTemp = strTemp..item.id..' '
   end
   command2[i] = ''..strTemp
  elseif arg == 'INPUT_REAGENTS' and tbl.InputReagents then
   command2[i] = ''
  elseif arg == 'PRODUCTS' and tbl.Products then
   command2[i] = ''
  elseif arg == 'OUTPUT_ITEMS' and tbl.OutputItems then
   strTemp = ''
   for _,item in pairs(tbl.OutputItems) do
    strTemp = strTemp..item.id..' '
   end
   command2[i] = ''..strTemp
  else
   command2[i] = arg
  end
 end
 dfhack.run_command(table.unpack(command2))
end

eventful.onJobInitiated.reactionStartTrigger = function(job)
 if not job.reaction_name or job.reaction_name == '' then return end
 if not reactionStartTriggers[job.reaction_name] then return end
 handleJob(job,reactionStartTriggers[job.reaction_name])
end

eventful.onJobCompleted.reactionEndTrigger = function(job)
 if not job.reaction_name or job.reaction_name == '' then return end
 if not reactionEndTriggers[job.reaction_name] then return end
 handleJob(job,reactionEndTriggers[job.reaction_name])
end

eventful.onReactionComplete.reactionProductTrigger = function(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
 if not reactionProductTriggers[reaction.code] then return end
 handleProduct(reaction,reaction_product,unit,input_items,input_reagents,output_items)
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

