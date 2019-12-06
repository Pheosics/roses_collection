-- Item Based Functions
utils = require 'utils'
split = utils.split_string
usages = {}

--=                     Item Table Functions
usages[#usages+1] = [===[

Item Table Functions
====================

makeItemTable(item)
  Purpose: Create a persistant table to track information of a given item
  Calls:   NONE
  Inputs:
           item = Item struct or item id
  Returns: NONE

getItemTable(item)
  Purpose: Collects all information from the game and the items persistant table into an easily accessible lua table
  Calls:   NONE
  Inputs:
           item = Item struct or item id
  Returns: Table of information about the item
]===]

function makeItemTable(item)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not roses or not item then return end

 roses.ItemTable[item.id] = {}
 itemTable = roses.ItemTable[item.id]

 itemTable.Material = {}
 itemTable.Material.Base = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 itemTable.Material.StatusEffects = {}

 itemTable.Quality = {}
 itemTable.Quality.Base = item.quality
 itemTable.Quality.StatusEffects = {}

 itemTable.Subtype = {}
 itemTable.Subtype.Base = dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id
 itemTable.Subtype.StatusEffects = {}

 itemTable.Stats = {}
 itemTable.Stats.Kills = 0
end

function getItemTable(item)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 
 if not roses then
  itemTable = nil
 else
  itemPersist = roses.ItemTable
  if not itemPersist[item.id] then
   itemTable = nil
  else
   itemTable = itemPersist[item.id]
  end
 end

 local outTable = {}

 -- Item Table stuff goes here!!!!

 return outTable
end

--=                     Item Table Functions
usages[#usages+1] = [===[

Tracking Functions
==================

trackMaterial(item,material,dur,alter)
  Purpose: Tracks material changes to an item
  Calls:   changeMaterial
  Inputs:
           item     = Item struct or item id
           material = MATERIAL_TYPE:MATERIAL_SUBTYPE
           dur      = Length of change in in-game ticks
           alter    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
  Returns: NONE

trackQuality(item,quality,dur,alter)
  Purpose: Tracks quality changes to an item
  Calls:   changeQuality
  Inputs:
           item     = Item struct or item id
           quality  = Quality number (0-7)
           dur      = Length of change in in-game ticks
           alter    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
  Returns: NONE

trackSubtype(item,material,dur,alter)
  Purpose: Tracks subtype changes to an item
  Calls:   changeSubtype
  Inputs:
           item     = Item struct or item id
           subtype  = ITEM_SUBTYPE
           dur      = Length of change in in-game ticks
           alter    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
  Returns: NONE
]===]

function trackMaterial(item,material,dur,alter)
 if alter == 'terminated' then return end
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not roses or not item then return end
 
 if not roses.ItemTable[item.id] then makeItemTable(item) end
 roses = dfhack.script_environment('base/roses-table').roses
 
 Table = roses.ItemTable[item.id]['Material']
 func = changeMaterial
 alter = alter or 'track'
 alter = string.lower(alter)
 if alter == 'track' then
  if dur > 0 then
   statusTable = Table.StatusEffects
   statusNumber = #statusTable
   statusTable[statusNumber+1] = {}
   statusTable[statusNumber+1].End = math.floor(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[statusNumber+1].Change = material
   statusTable[statusNumber+1].Linked = false
  else
   Table.Base = material
  end
 elseif alter == 'end' then
  statusTable = Table.StatusEffects
  for i = #statusTable,1,-1 do -- Remove any naturally ended effects
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 elseif alter == 'terminate' or alter == 'terminateclass' then
  -- Termination not currently supported for items
 end
end

function trackQuality(item,quality,dur,alter)
 if alter == 'terminated' then return end
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not roses or not item then return end
 
 if not roses.ItemTable[item.id] then makeItemTable(item) end
 roses = dfhack.script_environment('base/roses-table').roses
 
 Table = roses.ItemTable[item.id]['Quality']
 func = changeQuality

 alter = alter or 'track'
 alter = string.lower(alter)
 if alter == 'track' then
  if dur > 0 then
   statusTable = Table.StatusEffects
   statusNumber = #statusTable
   statusTable[statusNumber+1] = {}
   statusTable[statusNumber+1].End = math.floor(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[statusNumber+1].Change = quality
   statusTable[statusNumber+1].Linked = false
  else
   Table.Base = quality
  end
 elseif alter == 'end' then
  statusTable = Table.StatusEffects
  for i = #statusTable,1,-1 do -- Remove any naturally ended effects
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 elseif alter == 'terminate' or alter == 'terminateclass' then
  -- Termination not currently supported for items
 end
end

function trackSubtype(item,subtype,dur,alter)
 if alter == 'terminated' then return end
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not roses or not item then return end
 
 if not roses.ItemTable[item.id] then makeItemTable(item) end
 roses = dfhack.script_environment('base/roses-table').roses
 
 Table = roses.ItemTable[item.id]['Subtype']
 func = changeSubtype

 alter = alter or 'track'
 alter = string.lower(alter)
 if alter == 'track' then
  if dur > 0 then
   statusTable = Table.StatusEffects
   statusNumber = #statusTable
   statusTable[statusNumber+1] = {}
   statusTable[statusNumber+1].End = math.floor(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[statusNumber+1].Change = subtype
   statusTable[statusNumber+1].Linked = false
  else
   Table.Base = subtype
  end
 elseif alter == 'end' then
  statusTable = Table.StatusEffects
  for i = #statusTable,1,-1 do -- Remove any naturally ended effects
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 elseif alter == 'terminate' or alter == 'terminateclass' then
  -- Termination not currently supported for items
 end
end

--=                     Item Changing Functions
usages[#usages+1] = [===[

Changing Functions
==================

changeMaterial(item,material,dur,track)
  Purpose: Change the material an item is made from (temporarily or permanently) and track the change
  Calls:   trackMaterial
  Inputs:
           item     = Item struct or item id
           material = Material string (MATERIAL_TYPE:MATERIAL_SUBTYPE) to change item to
           dur      = Length of change in in-game ticks
           track    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
  Returns: NONE

changeQuality(item,quality,dur,track)
  Purpose: Change the quality of an item (temporarily or permanently) and track the change
  Calls:   trackQuality
  Inputs:
           item    = Item struct or item id
           quality = Quality number (0-7)
           dur     = Length of change in in-game ticks
           track   = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
  Returns: NONE

changeSubtype(item,subtype,dur,track)
  Purpose: Change the subtype of an item (temporarily or permanently) and track the change
  Calls:   trackSubtype
  Inputs:
           item    = Item struct or item id
           subtype = ITEM_SUBTYPE to change item into
           dur     = Length of change in in-game ticks
           track   = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
  Returns: NONE
]===]

function changeMaterial(item,material,dur,track)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 
 itemTable = getItemTable(item)
 mat = dfhack.matinfo.find(material)
 save = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 item.mat_type = mat.type
 item.mat_index = mat.index
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeMaterial',{item.id,save,0,'end'}) end
 trackMaterial(item,material,dur,track)
end

function changeQuality(item,quality,dur,track)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 
 itemTable = getItemTable(item)
 save = item.quality
 if quality > 5 then quality = 5 end
 if quality < 0 then quality = 0 end
 item:setQuality(quality)
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeQuality',{item.id,save,0,'end'}) end
 trackQuality(item,quality,dur,track)
end

function changeSubtype(item,subtype,dur,track)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 
 itemTable = getItemTable(item)
 local itemType = item:getType()
 local itemSubtype = item:getSubtype()
 itemSubtype = dfhack.items.getSubtypeDef(itemType,itemSubtype).id
 local found = false
 for i=0,dfhack.items.getSubtypeCount(itemType)-1,1 do
  local item_sub = dfhack.items.getSubtypeDef(itemType,i)
  if item_sub.id == subtype then
   item:setSubtype(item_sub.subtype)
   found = true
  end
 end
 if not found then
  print('Incompatable item type and subtype')
  return
 end
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeSubtype',{item.id,itemSubtype,0,'end'}) end
 trackSubtype(item,subtype,dur,track)
end

--=                     Item Attack Functions
usages[#usages+1] = [===[

Attack Functions
================

getAttack(item,attack)
  Purpose: Gets the attack number of an item
  Calls:   NONE
  Inputs:
           item   = Item struct or item id
           attack = ATTACK_TOKEN (e.g. PUNCH), attack verb, or Random
  Returns: Attack ID number
]===]

function getAttack(item,attack)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 
 attackID = false
 if attack == 'Random' then
  local rand = dfhack.random.new()
  local totwght = 0
  local weights = {}
  weights[0] = 0
  local n = 1
  for _,attacks in pairs(item.subtype.attacks) do
   totwght = totwght + 1
   weights[n] = weights[n-1] + 1
   n = n + 1  
  end
  pick = rand:random(totwght)
  for i = 1,n do
   if pick >= weights[i-1] and pick < weights[i] then
    attackID = i-1
    break
   end
  end
 else
  for i,attacks in pairs(item.subtype.attacks) do
   if attacks.verb_2nd == attack or attacks.verb_3rd == attack then
    attackID = i
    break
   end
  end
 end
 return attackID
end

--=                     Item Creation Functions
usages[#usages+1] = [===[

Creation Functions
==================

create(item,material,creatorID,quality,dur)
  Purpose: Creates an item of the given material and quality
  Calls:   NONE
  Inputs:
           item      = ITEM_TYPE:ITEM_SUBTYPE
           material  = MATERIAL_TYPE:MATERIAL_SUBTYPE
           creatorID = Unit ID to use as item creator
           quality   = Quality number of item (0-7)
           dur       = Length of time in in-game ticks for item to exist
  Returns: ID of created item

removal(item)
  Purpose: Destroys an item correctly
  Calls:   NONE
  Inputs:
           item = Item struct or item id to destroy
  Returns: NONE

equip(item,unit,bodyPart,mode)
  Purpose: Equips an item to a unit ignoring normal equipment requirements
  Calls:   NONE
  Inputs:
           item     = Item struct or item id to equip
           unit     = Unit struct or unit id to equip item to
           bodyPart = Body Part id to equip item to
           mode     = Equip mode (e.g. Worn)
  Returns: NONE

unequip(item,unit)
  Purpose: Unequips an item from a unit
  Calls:   NONE
  Inputs:
           item = Item struct or item id to unequip
           unit = Unit struct or unit id to unequip item from
  Returns: NONE
]===]

function create(item,material,a,b,c) --from modtools/create-item
 quality = b or 0
 creatorID = a or -1
 if creatorID == -1 then
  creator = df.global.world.units.active[0]
  creatorID = creator.id
 else
  if tonumber(creatorID) then 
   creator = df.unit.find(tonumber(creatorID))
  else
   creator = creatorID
  end
  if creator then
   creatorID = creator.id
  else
   creator = df.global.world.units.active[0]
   creatorID = creator.id
  end
 end
 dur = c or 0
 dur = tonumber(dur)
 itemType = dfhack.items.findType(item)
 if itemType == -1 then
  error 'Invalid item.'
 end
 local itemSubtype = dfhack.items.findSubtype(item)
 material = dfhack.matinfo.find(material)
 if not material then
  error 'Invalid material.'
 end
 if tonumber(creatorID) >= 0 then
  item = dfhack.items.createItem(itemType, itemSubtype, material.type, material.index, creator)
 end
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','removal',{item}) end
 return item
end

function removal(item)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 dfhack.items.remove(item)
end

function equip(item,unit,bodyPart,mode) --from modtools/equip-item
 --it is assumed that the item is on the ground
 --taken from expwnent and modified
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not item or not unit then return end
 item.flags.on_ground = false
 item.flags.in_inventory = true
 local block = dfhack.maps.getTileBlock(item.pos)
 local occupancy = block.occupancy[item.pos.x%16][item.pos.y%16]
 for k,v in ipairs(block.items) do
   if v == item.id then
     block.items:erase(k)
     break
   end
 end
 local foundItem = false
 for k,v in ipairs(block.items) do
   local blockItem = df.item.find(v)
   if blockItem.pos.x == item.pos.x and blockItem.pos.y == item.pos.y then
     foundItem = true
     break
   end
 end
 if not foundItem then
   occupancy.item = false
 end
 local inventoryItem = df.unit_inventory_item:new()
 inventoryItem.item = item
 inventoryItem.mode = mode
 inventoryItem.body_part_id = bodyPart
 unit.inventory:insert(#unit.inventory,inventoryItem)
end

function unequip(item,unit) --basically just reversed modtools/equip-item
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not item or not unit then return end
 
 local slot = -1
 for i,x in pairs(unit.inventory) do
  if x.item.id == item.id then
    slot = i
    break
  end
 end
 if slot < 0 then return end
 unit.inventory:erase(slot)
 item.flags.in_inventory = false
 item.flags.on_ground = true
 local block = dfhack.maps.getTileBlock(unit.pos)
 block.items:insert(#block.items,item.id)
 local occupancy = block.occupancy[unit.pos.x%16][unit.pos.y%16]
 occupancy.item = true
end

--=                     Item Projectile Functions
usages[#usages+1] = [===[

Projectile Functions
====================

makeProjectileFall(item,origin,velocity)
  Purpose: Turn an item into a falling projectile
  Calls:   NONE
  Inputs:
           item     = Item struct or item id
           origin   = { x y z }
           velocity = { x y z } (falling projectiles use a three component velocity)
  Returns: NONE

makeProjectileShoot(item,origin,target,options)
  Purpose: Turn an item into a shooting projectile
  Calls:   NONE
  Inputs:
           item    = Item struct or item id
           origin  = { x y z }
           target  = { x y z }
           options = { velocity=#, accuracy=#, range=#, minimum=#, firer=# } (shooting projectiles use a single component velocity)
  Returns: NONE
]===]

function makeProjectileFall(item,origin,velocity)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=origin[1]
 proj.origin_pos.y=origin[2]
 proj.origin_pos.z=origin[3]
 proj.prev_pos.x=origin[1]
 proj.prev_pos.y=origin[2]
 proj.prev_pos.z=origin[3]
 proj.cur_pos.x=origin[1]
 proj.cur_pos.y=origin[2]
 proj.cur_pos.z=origin[3]
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.flags.no_collide=true
 proj.speed_x=velocity[1]
 proj.speed_y=velocity[2]
 proj.speed_z=velocity[3]
end

function makeProjectileShot(item,origin,target,options)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not item then return end
 if options then
  velocity = options.velocity or 20
  hit_chance = options.accuracy or 50
  max_range = options.range or 10
  min_range = options.minimum or 1
  firer = df.unit.find(tonumber(options.firer)) or nil
 else
  velocity = 20
  hit_chance = 50
  max_range = 10
  min_range = 1
  firer = nil
 end
 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=origin[1]
 proj.origin_pos.y=origin[2]
 proj.origin_pos.z=origin[3]
 proj.prev_pos.x=origin[1]
 proj.prev_pos.y=origin[2]
 proj.prev_pos.z=origin[3]
 proj.cur_pos.x=origin[1]
 proj.cur_pos.y=origin[2]
 proj.cur_pos.z=origin[3]
 proj.target_pos.x=target[1]
 proj.target_pos.y=target[2]
 proj.target_pos.z=target[3]
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=false
 proj.flags.piercing=false
 proj.flags.parabolic=false
 proj.flags.unk9=false
 proj.flags.no_collide=false
-- Need to figure out these numbers!!!
 proj.distance_flown=0 -- Self explanatory
 proj.fall_threshold=max_range -- Seems to be able to hit units further away with larger numbers
 proj.min_hit_distance=min_range -- Seems to be unable to hit units closer than this value
 proj.min_ground_distance=max_range-1 -- No idea
 proj.fall_counter=0 -- No idea
 proj.fall_delay=0 -- No idea
 proj.hit_rating=hit_chance -- I think this is how likely it is to hit a unit (or to go where it should maybe?)
 proj.unk22 = velocity
 proj.firer = firer
 proj.speed_x=0
 proj.speed_y=0
 proj.speed_z=0
end

--=                     Miscellanious Functions
usages[#usages+1] = [===[

Miscellanious Functions
=======================

findItem(search)
  Purpose: Find an item on the map that satisfies the search criteria
  Calls:   NONE
  Inputs:
           search = Search table (e.g. { RANDOM, WEAPON, ITEM_WEAPON_SWORD_SHORT })
  Returns: Table of all items that meet search criteria
]===]

function findItem(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local itemList = df.global.world.items.all
 local targetList = {}
 local target = nil
 local n = 0
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'WEAPON' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_weaponst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'ARMOR' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_armorst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'HELM' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_helmst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'SHIELD' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_shieldst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'GLOVE' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_glovesst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'SHOE' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_shoesst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'PANTS' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_pantsst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'AMMO' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_ammost:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'MATERIAL' then
   local mat_type = dfhack.matinfo.find(tertiary).type
   local mat_index = dfhack.matinfo.find(tertiary).index
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and x.mat_type == mat_type and x.mat_index == mat_index then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'VALUE' then
   if tertiary == 'LESS_THAN' then
    for i,x in pairs(itemList) do
     if dfhack.items.getPosition(x) and dfhack.items.getValue(x) <= tonumber(quaternary) then
      n = n + 1
      targetList[n] = x
     end
    end
   elseif tertiary == 'GREATER_THAN' then
    for i,x in pairs(itemList) do
     if dfhack.items.getPosition(x) and dfhack.items.getValue(x) >= tonumber(quaternary) then
      n = n + 1
      targetList[n] = x
     end
    end
   end
  end
 end
 if n > 0 then
  targetList = dfhack.script_environment('functions/misc').permute(targetList)
  target = targetList[1]
  return {target}
 else
--  print('No valid item found for event')
  return {}
 end
end
