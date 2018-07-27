--building based functions, version 42.06a
--[[
addItem(building,item,duration)
  Purpose: Adds an item to a buildings item list
  Calls: persistDelay.environmentDelay
  Inputs:
        building:               Building ID or building struct
        item:                   Item ID or item struct
        duration:               Time (in ticks) for the item to remain in the building
  Returns: NA

removeItem(building,item,duration)
  Purpose: Removes an item from a buildings item list
  Calls: persistDelay.environmentDelay
  Inputs:
        building:               Building ID or building struct
        item:                   Item ID or item struct
        duration:               Time (in ticks) for the item to remain outside of building
  Returns: NA

changeSubtype(building,subtype,duration)
  Purpose: Changes the subtype of a building
  Calls: persistDelay.environmentDelay
  Inputs:
        building:               Building ID or building struct
        subtype:                RAW Token of custom building
        duration:               Time (in ticks) for the change to last
  Returns: Boolean - Did the building successfully change?

findBuilding(searchTable)
  Purpose: Finds a building that satisfies certain criteria
  Calls: misc.permute
  Inputs:
        searchTable:            Table of strings to search for a building on the map (NEED TO ADD MORE INFORMATION)
  Returns: Table - { target[s] )
]]
---------------------------------------------------------------------------------------
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

function changeSubtype(building,subtype,dur)
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
