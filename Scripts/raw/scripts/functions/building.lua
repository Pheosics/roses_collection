-- Building Based Functions
utils = require 'utils'
split = utils.split_string
usages = {}

--=                     Building Table Functions
usages[#usages+1] = [===[

Building Table Functions
========================

makeBuildingTable(building)
  Purpose: Create a persistent table to track information of a given building
  Calls:   NONE
  Inputs:
           building = The building struct or building ID to make the table for
  Returns: NONE
  
]===]

function makeBuildingTable(building)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(building) then building = df.building.find(tonumber(building)) end
 if not roses or not building then return end

 roses.BuildingTable[building.id] = {}
 
 roses.BuildingTable[building.id].ID = building.id
 
 roses.BuildingTable[building.id].Enhanced = false
 
 roses.BuildingTable[building.id].Position = {}
 roses.BuildingTable[building.id].Position.x = building.centerx
 roses.BuildingTable[building.id].Position.y = building.centery
 roses.BuildingTable[building.id].Position.z = building.z
 
 if building.custom_type >= 0 then
  roses.BuildingTable[building.id].Token = df.global.world.raws.buildings.all[building.custom_type].code
 end
end

--=                     Tracking Functions
usages[#usages+1] = [===[

Building Tracking Functions
==================

trackSubtype(building,subtype,dur,alter)
  Purpose: Tracks changes to a buildings subtypes
  Calls:   changeSubtype
  Inputs:
           building = The building struct or building ID to track
           subtype  = The subtype the building changed to
           dur      = Length of change in in-game ticks
           alter    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           cb_id    = If dur > 0 then the cb_id is needed to properly track the change
  Returns: NONE
  
]===]

function trackSubtype(building,subtype,dur,alter)

end

--=                     Building Item Functions
usages[#usages+1] = [===[

Building Item Functions
=======================

addItem(building,item,dur)
  Purpose: Adds an item to the buildings "build items" list
  Calls:   NONE
  Inputs:
           building = Building struct or Building ID
           item     = Item struct or Item ID
           dur      = Length in in-game ticks
  Returns: NONE
 
removeItem(building,item,dur)
  Purpose: Remove an item from the buildings "build items" list
  Calls:   NONE
  Inputs:
           building = Building struct or Building ID
           item     = Item struct or Item ID
           dur      = Length in in-game ticks
  Returns: NONE
  
]===]

function addItem(building,item,dur)
 dur = dur or -1
 dur = tonumber(dur)
 if tonumber(building) then building = df.building.find(tonumber(building)) end
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 dfhack.items.moveToBuilding(item,building,2)
 item.flags.in_building = true
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/building','removeItem',{building.id,item.id,0}) end
end

function removeItem(building,item,dur)
 dur = dur or -1
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
  Purpose: Change the subtype of a building
  Calls:   trackSubtype
  Inputs:
           building = Building struct or Building ID
           subtype  = BUILDING_TOKEN
           dur      = Length of change in in-game ticks
           track    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
  Returns: NONE
  
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
  Purpose: Find a building on the map the satisfies the search criteria
  Calls:   NONE
  Inputs:
           search = Search table (e.g. { RANDOM, STOCKPILE })
  Returns: Table of all buildings that meet search criteria

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
