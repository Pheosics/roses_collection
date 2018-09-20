-- Building Based Functions
persistTable = require 'persist-table'
if not persistTable.GlobalTable.roses then return end
buildingPersist = persistTable.GlobalTable.roses.BuildingTable
usages = {}

--=                     Building Table Functions
usages[#usages+1] = [===[

Building Table Functions
========================

makeBuildingTable(building)
  Purpose: 
  Calls:   
  Inputs:
  Returns: 

getBuildingTable(building)
  Purpose:
  Calls:
  Inputs:
  Returns:
]===]

function makeBuildingTable(building)

end

function getBuidingTable(building)

end

--=                     Tracking Functions
usages[#usages+1] = [===[

Tracking Functions
==================

trackSubtype(building,subtype,dur,alter)
  Purpose: 
  Calls:   
  Inputs:
  Returns:
]===]

function trackSubtype(building,subtype,dur,alter)

end

--=                     Building Item Functions
usages[#usages+1] = [===[

Building Item Functions
=======================

addItem(building,item,dur)
  Purpose: 
  Calls:   
  Inputs:
  Returns: 
 
removeItem(building,item,dur)
  Purpose:
  Calls:
  Inputs:
  Returns:
]===]

function addItem(building,item,dur)
 dur = dur or '0'
 dur = tonumber(dur)
 if tonumber(building) then building = df.building.find(tonumber(building)) end
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 dfhack.items.moveToBuilding(item,building,2)
 item.flags.in_building = true
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/building','removeItem',{building.id,item.id,0}) end
end

function removeItem(building,item,dur)
 dur = dur or '0'
 dur = tonumber(dur)
 if tonumber(building) then building = df.building.find(tonumber(building)) end
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 item.flags.in_building = false
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/building','addItem',{building.id,item.id,0}) end
end

--=                     Building Changing Functions
usages[#usages+1] = [===[

Building Changing Functions
===========================

changeSubtype(building,subtype,dur,track)
  Purpose: 
  Calls:   
  Inputs:
  Returns: 
]===]

function changeSubtype(building,subtype,dur,track)
 dur = dur or '0'
 dur = tonumber(dur)
 if tonumber(building) then building = df.building.find(tonumber(building)) end
 save = df.global.world.raws.buildings.all[building.custom_type].code
 for _,x in ipairs(df.global.world.raws.buildings.all) do
  if x.code == subtype then ctype = x.id end
 end
 if ctype == nil then
  print('Cant find upgrade building')
  return false
 end
 building.custom_type=ctype
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/building','changeSubtype',{building.id,save,0}) end
 return true
end

--=                     Miscellanious Functions
usages[#usages+1] = [===[

Miscellanious Functions
=======================

findBuilding(search)
  Purpose: 
  Calls:   
  Inputs:
  Returns: 
]===]

function findBuilding(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local buildingList = df.global.world.buildings.all
 local targetList = {}
 local target = nil
 local n = 0
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   targetList = buildingList
  elseif secondary == 'WORKSHOP' then
   targetList = df.global.world.buildings.other.WORKSHOP_ANY
  elseif secondary == 'FURNACE' then
   targetList = df.global.world.buildings.other.FURNACE_ANY
  elseif secondary == 'TRADE_DEPOT' then
   targetList = df.global.world.buildings.other.TRADE_DEPOT
  elseif secondary == 'STOCKPILE' then
   targetList = df.global.world.buildings.other.STOCKPILE
  elseif secondary == 'ZONE' then
   targetList = df.global.world.buildings.other.ANY_ZONE
  elseif secondary == 'CUSTOM' then
   for i,x in pairs(buildingList) do
    if df.building_workshopst:is_instance(x) or df.building_furnacest:is_instance(x) then
     if x.custom_type >= 0 then
      if df.global.world.raws.buildings.all[x.custom_type].code == tertiary then
       n = n+1
       targetList[n] = x
      end
     end
    end
   end
  end
  if #targetList > 0 then
   targetList = dfhack.script_environment('functions/misc').permute(targetList)
   target = targetList[1]
   return {target}
  else
--   print('No valid building found for event')
   return {}
  end
 elseif primary == 'ALL' then 
  if secondary == 'NONE' or secondary == 'ALL' then
   targetList = buildingList
  elseif secondary == 'WORKSHOP' then
   targetList = df.global.world.buildings.other.WORKSHOP_ANY
  elseif secondary == 'FURNACE' then
   targetList = df.global.world.buildings.other.FURNACE_ANY
  elseif secondary == 'TRADE_DEPOT' then
   targetList = df.global.world.buildings.other.TRADE_DEPOT
  elseif secondary == 'STOCKPILE' then
   targetList = df.global.world.buildings.other.STOCKPILE
  elseif secondary == 'ZONE' then
   targetList = df.global.world.buildings.other.ANY_ZONE
  elseif secondary == 'CUSTOM' then
   for i,x in pairs(buildingList) do
    if df.building_workshopst:is_instance(x) or df.building_furnacest:is_instance(x) then
     if ctype >= 0 then
      if df.global.world.raws.buildings.all[ctype].code == tertiary then
       n = n+1
       targetList[n] = x
      end
     end
    end
   end
  end
  target = {}
  nn = 1
  for _,fill in pairs(targetList) do
   target[nn] = fill
   nn = nn + 1
  end
  return target
 end
end
