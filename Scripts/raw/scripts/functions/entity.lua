--entity based functions, version 42.06a
usages = {}

--=                     Entity Table Functions
usages[#usages+1] = [===[

Entity Table Functions 
====================

makeEntityTable(entity)
  Purpose: Create a persistant table to track information of a given entity
  Calls:   NONE
  Inputs:
           entity = The entity struct or entity ID to make the table for
  Returns: NONE

]===]

function makeEntityTable(entity,verbose)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(entity) then entity = df.global.world.entities.all[tonumber(entity)] end
 if not roses or not entity then return end

 local key = entity.id
 local entity = entity.entity_raw.code
 civilizations = roses.CivilizationTable
 entityTable = roses.EntityTable
 if entityTable[key] then
  return
 else
  entityTable[key] = {}
  entityTable = entityTable[key]
  entityTable.Kills = {}
  entityTable.Deaths = {}
  entityTable.Trades = 0
  entityTable.Sieges = 0
  if civilizations then
   if civilizations[entity] then
    entityTable.Civilization = {}
    entityTable.Civilization.Name = entity
    entityTable.Civilization.Level = 0
    entityTable.Civilization.CurrentMethod = civilizations[entity].LevelMethod
    entityTable.Civilization.CurrentPercent = civilizations[entity].LevelPercent
    entityTable.Civilization.Classes = {}
    if safe_index(civilizations,entity,'Level',0,'Remove') then
     for mtype,depth1 in pairs(civilizations[entity].Level[0].Remove) do
      for stype,depth2 in pairs(depth1) do
       for mobj,sobj in pairs(depth2) do
        dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,-1,verbose)
       end
      end
     end
    end
    if safe_index(civilizations,entity,'Level',0,'Add') then
     for mtype,depth1 in pairs(civilizations[entity].Level[0].Add) do
      for stype,depth2 in pairs(depth1) do
       for mobj,sobj in pairs(depth2) do
        dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,1,verbose)
       end
      end
     end
     if safe_index(civilizations,entity,'Level',0,'Classes') then
      for class,level in pairs(civilizations[entity].Level[0].Classes) do
       if level > 0 then
        entityTable.Civilization.Classes[class] = level
       else
        entityTable.Civilization.Classes[class] = nil
       end
      end
     end
    end
   end
  end
 end
end

--=                     Entity Changing Functions
usages[#usages+1] = [===[

Entity Changing Functions 
====================

changeResources(entity,mtype,stype,mobj,sobj,direction)
  Purpose: Add or remove a resource from the entity
  Calls:   changeCreature, changeInorganic, changeItem, changeMisc, changeOrganic
           changeRefuse, changeProduct, changeSkill, changeEthic, changeValue
  Inputs:
           entity    = The entity struct or entity ID to change the resource of
           mtype     = The TYPE of resource to change (see the entity/resouce-change script for valid types)
           stype     = The SUBTYPE of resource to change (see the entity/resouce-change script for valid types)
           mobj      = The CREATURE_RACE, MATERIAL_TYPE, or ITEM_SUBTYPE of resource to change
           sobj      = The CREATURE_CASTE or MATERIAL_SUBTYPE of resource to change
           direction = 'Add' or 'Remove'
  Returns: NONE

]===]
function changeResources(entity,mtype,stype,mobj,sobj,direction,verbose)
 if string.upper(mtype) == 'CREATURE' then
  changeCreature(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'INORGANIC' then
  changeInorganic(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'ITEM' then
  changeItem(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'MISC' then
  changeMisc(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'ORGANIC' then
  changeOrganic(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'REFUSE' then
  changeRefuse(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'PRODUCT' then
  changeProduct(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'SKILLS' then
  changeSkill(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'ETHICS' then
  changeEthic(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'VALUES' then
  changeValue(entity,stype,mobj,sobj,direction,verbose)
 else
  if verbose then print('No valid resource type to add') end
  return
 end
end

function changeCreature(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 resources = civ.resources
 creature = {}
 check = false
 if string.upper(mobj) == 'ALL' then
  for i,x in ipairs(df.global.world.raws.creatures.all) do
   creature[i] = {}
  end
  check = true
 else
  mobj_id = -1
  for i,x in ipairs(df.global.world.raws.creatures.all) do
   if string.upper(mobj) == x.creature_id then
    mobj_id = i
    check = true
    creature[mobj_id] = {}
    break
   end
  end
 end
 if not check then
  if verbose then print('Creature not found '..mobj) end
  return
 end
 check = false
 if string.upper(sobj) == 'ALL' then
  for i,x in pairs(creature) do
   for j,y in pairs(df.global.world.raws.creatures.all[i].caste) do
    creature[i][j] = j
   end
  end
  check = true
 else
  for i,x in pairs(creature) do
   sobj_id = -1
   for j,y in ipairs(df.global.world.raws.creatures.all[i].caste) do
    if string.upper(sobj) == y.caste_id then
     sobj_id = j
     creature[i][sobj_id] = sobj_id
     check = true
     break
    end
   end
  end
 end
 if not check then
  if verbose then print('Caste not found '..sobj) end
  return
 end
 if string.upper(stype) == 'ALL' then
  if verbose then print('-type CREATURE:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif string.upper(stype) == 'PET' then
  races = resources.animals.pet_races
  castes = resources.animals.pet_castes
 elseif string.upper(stype) == 'WAGON' then
  races = resources.animals.wagon_puller_races
  castes = resources.animals.wagon_puller_castes
 elseif string.upper(stype) == 'MOUNT' then
  races = resources.animals.mount_races
  castes = resources.animals.mount_castes
 elseif string.upper(stype) == 'PACK' then
  races = resources.animals.pack_animal_races
  castes = resources.animals.pack_animal_castes
 elseif string.upper(stype) == 'MINION' then
  races = resources.animals.minion_races
  castes = resources.animals.minion_castes
 elseif string.upper(stype) == 'EXOTIC' then
  races = resources.animals.exotic_pet_races
  castes = resources.animals.exotic_pet_castes
 elseif string.upper(stype) == 'FISH' then
  races = resources.fish_races
  castes = resources.fish_castes
 elseif string.upper(stype) == 'EGG' then
  races = resources.egg_races
  castes = resources.egg_castes
 else
  if verbose then print('Not a valid type') end
 end
 if direction == -1 or direction == 'Remove' then
  local int = 1
  removing = {}
  for i,x in pairs(races) do
   if creature[x] then
    if creature[x][castes[i]] then
     removing[int] = i
     int = int + 1
     if verbose then print('Removing CREATURE:CASTE '..x..':'..i..' from '..stype) end
    end
   end
  end
  for i = #removing,1,-1 do
   races:erase(removing[i])
   castes:erase(removing[i])
  end
 elseif direction == 1 or direction == 'Add' then
  for i,x in pairs(creature) do
   for j,y in pairs(x) do
    races:insert('#',i)
    castes:insert('#',y)
    if verbose then print('Adding CREATURE:CASTE '..i..':'..y..' to '..stype) end
   end
  end
 end
end

function changeInorganic(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 resources = civ.resources
 if stype == 'ALL' then
  if verbose then print('-type INORGANIC:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'METAL' then
  inorganic = resources.metals
  check = 'IS_METAL'
 elseif stype == 'STONE' then
  inorganic = resources.stones
  check = 'IS_STONE'
 elseif stype == 'GEM' then
  inorganic = resources.gems
  check = 'IS_GEM'
 else
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 or direction == 'Remove' then
   for i=#inorganic-1,0,-1 do
    inorganic:erase(i)
    if verbose then print('Removing inorganic TYPE:SUBTYPE'..stype..':'..i) end
   end
  elseif direction == 1 or direction == 'Add' then
   for i,x in pairs(df.global.world.raws.inorganics) do
    if x.material.flags[check] then
     inorganic:insert('#',dfhack.matinfo.find(x.id).index)
     if verbose then print('Adding inorganic TYPE:SUBTYPE'..stype..':'..dfhack.matinfo.find(x.id).index) end
    end
   end
  end
 else
  matinfo = dfhack.matinfo.find(mobj)
  if matinfo then
   mat_id = dfhack.matinfo.find(mobj).index
--  if dfhack.matinfo.decode(0,mat_id).material.flags[check] then
    if direction == -1 or direction == 'Remove' then
     for i=#inorganic-1,0,-1 do
      if inorganic[i] == mat_id then
       inorganic:erase(i)
       if verbose then print('Removing inorganic TYPE:SUBTYPE'..stype..':'..mat_id) end
       break
      end
     end
    elseif direction == 1 or direction == 'Add' then
     inorganic:insert('#',mat_id)
     if verbose then print('Adding inorganic TYPE:SUBTYPE'..stype..':'..mat_id) end
    end
  else
   if verbose then print('Material not valid ['..mobj..':'..sobj..'] material') end
  end
 end
end

function changeItem(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 resources = civ.resources
 if stype == 'ALL' then
  if verbose then print('-type ITEM:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'WEAPON' then
  ind = df.item_type['WEAPON']
  items = resources.weapon_type
 elseif stype == 'SHIELD' then
  ind = df.item_type['SHIELD']
  items = resources.shield_type
 elseif stype == 'AMMO' then
  ind = df.item_type['AMMO']
  items = resources.ammo_type
 elseif stype == 'HELM' then
  ind = df.item_type['HELM']
  items = resources.helm_type
 elseif stype == 'ARMOR' then
  ind = df.item_type['ARMOR']
  items = resources.armor_type
 elseif stype == 'PANTS' then
  ind = df.item_type['PANTS']
  items = resources.pants_type
 elseif stype == 'SHOES' then
  ind = df.item_type['SHOES']
  items = resources.shoes_type
 elseif stype == 'GLOVES' then
  ind = df.item_type['GLOVES']
  items = resources.gloves_type
 elseif stype == 'TRAP' then
  ind = df.item_type['TRAPCOMP']
  items = resources.trapcomp_type
 elseif stype == 'SIEGE' then
  ind = df.item_type['SIEGEAMMO']
  items = resources.siegeammo_type
 elseif stype == 'TOY' then
  ind = df.item_type['TOY']
  items = resources.toy_type
 elseif stype == 'INSTRUMENT' then
  ind = df.item_type['INSTRUMENT']
  items = resources.instrument_type
 elseif stype == 'TOOL' then
  ind = df.item_type['TOOL']
  items = resources.tool_type
 elseif stype == 'DIGGER' then
  --Don't know what the item_type of digger is, don't think there is one
  ind = df.item_type['WEAPON']
  items = resources.digger_type
 elseif stype == 'TRAINING' then
  --Don't know what the item_type of training is, don't think there is one
  ind = df.item_type['WEAPON']
  items = resources.training_weapon_type
 else
  if verbose then print('Not a valid item type') end
  return
 end
-- Add or remove item
 if mobj == 'ALL' then
  if direction == -1 or direction == 'Remove' then
   for i=#items-1,0,-1 do
    items:erase(i)
    if verbose then print('Removing item TYPE:SUBTYPE '..stype..':'..i) end
   end
  elseif direction == 1 or direction == 'Add' then
   for i=0,dfhack.items.getSubtypeCount(ind)-1 do
    local item_subtype = dfhack.items.getSubtypeDef(ind,i).subtype
    items:insert('#',item_subtype)
    if verbose then print('Adding item TYPE:SUBTYPE '..stype..':'..item_subtype) end
   end
  end
 else
  for i=0,dfhack.items.getSubtypeCount(ind)-1 do
   local item_sub = dfhack.items.getSubtypeDef(ind,i)
   if item_sub.id == mobj then
    item_subtype = item_sub.subtype
    break
   end
  end
  if direction == -1 or direction =='Remove' then
   for i=#items-1,0,-1 do
    if item_subtype == items[i] then
     items:erase(i)
     if verbose then print('Removing item TYPE:SUBTYPE '..stype..':'..item_subtype) end
    end
   end
  elseif direction == 1 or direction =='Add' then
   items:insert('#',item_subtype)
   if verbose then print('Adding item TYPE:SUBTYPE '..stype..':'..item_subtype) end
  end
 end
end

function changeMisc(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 sobj = string.upper(sobj)
 resources = civ.resources
 if stype == 'ALL' then
  if verbose then print('-type MISC:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'GLASS' then
  check = 'IS_GLASS'
  misc = resources.misc_mat.glass
 elseif stype == 'SAND' then
  check2 = 'SOIL_SAND'
  misc = resources.misc_mat.sand
 elseif stype == 'CLAY' then
  misc = resources.misc_mat.clay
 elseif stype == 'BOOZE' then
  check = 'ALCOHOL'
  misc = resources.misc_mat.booze
 elseif stype == 'CHEESE' then
  check = 'CHEESE'
  misc = resources.misc_mat.cheese
 elseif stype == 'POWDER' then
  check = 'POWDER_MISC'
  misc = resources.misc_mat.powders
 elseif stype == 'EXTRACT' then
  check = 'LIQUID_MISC'
  misc = resources.misc_mat.extracts
 elseif stype == 'MEAT' then
  check = 'MEAT'
  misc = resources.misc_mat.meat
 else
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 or direction == 'Remove' then
   for i=#misc.mat_type-1,0,-1 do
    misc.mat_type:erase(i)
   end
   for i=#misc.mat_index-1,0,-1 do
    misc.mat_index:erase(i)
   end
  elseif direction == 1 or direction == 'Add' then
   if verbose then print('ALL:ALL IS NOT CURRENTLY SUPPORTED') end
   return
  end
 else
  if sobj == 'NONE' then
   matinfo = dfhack.matinfo.find(mobj)
  else
   matinfo = dfhack.matinfo.find(mobj..':'..sobj)
  end
  if matinfo then
   mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
   mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
--  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
    if direction == -1 or direction == 'Remove' then
     for i=#refuse.mat_type-1,0,-1 do
      if misc.mat_type[i] == mat_type then
       if misc.mat_index[i] == mat_index then
        misc.mat_type:erase(i)
        misc.mat_index:erase(i)
        if verbose then print('Removing misc '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
       end
      end
     end
    elseif direction == 1 or direction == 'Add' then
     misc.mat_type:insert('#',mat_type)
     misc.mat_index:insert('#',mat_index)
     if verbose then print('Adding misc '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
    end
  else
   if verbose then print('Material not valid ['..mobj..':'..sobj..'] material') end
  end
 end
end

function changeNoble(civ,position,direction,verbose)
end

function changeOrganic(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 sobj = string.upper(sobj)
 resources = civ.resources
 if stype == 'ALL' then
  if verbose then print('-type ORGANIC:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'LEATHER' then
  organic = resources.organic.leather
  check = 'LEATHER'
 elseif stype == 'FIBER' then
  organic = resources.organic.fiber
  check = 'THREAD_PLANT'
 elseif stype == 'SILK' then
  organic = resources.organic.silk
  check = 'SILK'
 elseif stype == 'WOOL' then
  organic = resources.organic.wool
  check = 'YARN'
 elseif stype == 'WOOD' then
  organic = resources.organic.wood
  check = 'WOOD'
 elseif stype == 'PLANT' then
  organic = resources.plants
  check = 'STRUCTURAL_PLANT_MAT'
 elseif stype == 'SEED' then
  organic = resources.seeds
  check = 'SEED_MAT'
 else
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 or direction == 'Remove' then
   for i=#organic.mat_type-1,0,-1 do
    organic.mat_type:erase(i)
   end
   for i=#organic.mat_index-1,0,-1 do
    organic.mat_index:erase(i)
   end
  elseif direction == 1 or direction == 'Add' then
   for i,x in pairs(df.global.world.raws.creatures.all) do
    for j,y in pairs(x.material) do
     if y.flags[check] then
      organic.mat_type:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).type)
      organic.mat_index:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).index)
     end
    end
   end
  end
 else
  matinfo = dfhack.matinfo.find(mobj..':'..sobj)
  if matinfo then
   mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
   mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
--  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
    if direction == -1 or direction == 'Remove' then
     for i=#organic.mat_type-1,0,-1 do
      if organic.mat_type[i] == mat_type then
       if organic.mat_index[i] == mat_index then
        organic.mat_type:erase(i)
        organic.mat_index:erase(i)
        if verbose then print('Removing organic '..stype..' TYPE:SUBTYPE '..mobj..':'..sobj) end
       end
      end
     end
    elseif direction == 1 or direction == 'Add' then
     organic.mat_type:insert('#',mat_type)
     organic.mat_index:insert('#',mat_index)
     if verbose then print('Adding organic '..stype..' TYPE:SUBTYPE '..mobj..':'..sobj) end
    end
  else
   if verbose then print('Material not valid ['..mobj..':'..sobj..'] material') end
  end
 end
end

function changeProduct(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 sobj = string.upper(sobj)
 resources = civ.resources
 if stype == 'ALL' then
  if verbose then print('-type PRODUCT:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'PICK' then
  product = resources.metal.pick
 elseif stype == 'MELEE' then
  product = resources.metal.weapon
 elseif stype == 'RANGED' then
  product = resources.metal.ranged
 elseif stype == 'AMMO' then
  product = resources.metal.ammo
 elseif stype == 'AMMO2' then
  product = resources.metal.ammo2
 elseif stype == 'ARMOR' then
  product = resources.metal.armor
 elseif stype == 'ANVIL' then
  product = resources.metal.anvil
 elseif stype == 'CRAFTS' then
  product = resources.misc_mat.crafts
 elseif stype == 'BARRELS' then
  product = resources.misc_mat.barrels
 elseif stype == 'FLASKS' then
  product = resources.misc_mat.flasks
 elseif stype == 'QUIVERS' then
  product = resources.misc_mat.quivers
 elseif stype == 'BACKPACKS' then
  product = resources.misc_mat.backpacks
 elseif stype == 'CAGES' then
  product = resources.misc_mat.cages  
 else
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 or direction == 'Remove' then
   for i=#product.mat_type-1,0,-1 do
    product.mat_type:erase(i)
   end
   for i=#product.mat_index-1,0,-1 do
    product.mat_index:erase(i)
   end
  elseif direction == 1 or direction == 'Add' then
   if verbose then print('ALL:ALL IS NOT CURRENTLY SUPPORTED') end
   return
  end
 else
  matinfo = dfhack.matinfo.find(mobj..':'..sobj)
  if matinfo then
   mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
   mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
--  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
    if direction == -1 or direction == 'Remove' then
     for i=#product.mat_type-1,0,-1 do
      if product.mat_type[i] == mat_type then
       if product.mat_index[i] == mat_index then
        product.mat_type:erase(i)
        product.mat_index:erase(i)
        if verbose then print('Removing product '..stype..' TYPE:SUBTYPE '..mobj..':'..sobj) end
       end
      end
     end
    elseif direction == 1 or direction == 'Add' then
     product.mat_type:insert('#',mat_type)
     product.mat_index:insert('#',mat_index)
     if verbose then print('Adding product '..stype..' TYPE:SUBTYPE '..mobj..':'..sobj) end
    end
  else
   if verbose then print('Material not valid ['..mobj..':'..sobj..'] material') end
  end
 end
end

function changeRefuse(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 sobj = string.upper(sobj)
 resources = civ.resources
 if stype == 'ALL' then
  if verbose then print('-type REFUSE:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'BONE' then
  check = 'BONE'
  refuse = resources.refuse.bone
 elseif stype == 'SHELL' then
  check = 'SHELL'
  refuse = resources.refuse.shell
 elseif stype == 'PEARL' then
  check = 'PEARL'
  refuse = resources.refuse.pearl
 elseif stype == 'IVORY' then
  check = 'TOOTH'
  refuse = resources.refuse.ivory
 elseif stype == 'HORN' then
  check = 'HORN'
  refuse = resources.refuse.horn
 else
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 or direction == 'Remove' then
   for i=#refuse.mat_type-1,0,-1 do
    refuse.mat_type:erase(i)
   end
   for i=#refuse.mat_index-1,0,-1 do
    refuse.mat_index:erase(i)
   end
  elseif direction == 1 or direction == 'Add' then
   for i,x in pairs(df.global.world.raws.creatures.all) do
    for j,y in pairs(x.material) do
     if y.flags[check] then
      refuse.mat_type:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).type)
      refuse.mat_index:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).index)
     end
    end
   end
  end
 else
  matinfo = dfhack.matinfo.find(mobj..':'..sobj)
  if matinfo then
   mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
   mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
--  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
    if direction == -1 or direction == 'Remove' then
     for i=#refuse.mat_type-1,0,-1 do
      if refuse.mat_type[i] == mat_type then
       if refuse.mat_index[i] == mat_index then
        refuse.mat_type:erase(i)
        refuse.mat_index:erase(i)
        if verbose then print('Removing refuse '..stype..' TYPE:SUBTYPE '..mobj..':'..sobj) end
       end
      end
     end
    elseif direction == 1 or direction == 'Add' then
     refuse.mat_type:insert('#',mat_type)
     refuse.mat_index:insert('#',mat_index)
     if verbose then print('Adding refuse '..stype..' TYPE:SUBTYPE '..mobj..':'..sobj) end
    end
  else
   if verbose then print('Material not valid ['..mobj..':'..sobj..'] material') end
  end
 end
end

function changeSkill(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 resources = civ.resources
 if stype == 'ALL' then
  if direction == -1 or direction == 'Remove' then
   for skill,_ in pairs(resources.permitted_skill) do
    resources.permitted_skill[skill] = false
   end
  elseif direction == 1 or direction == 'Add' then
   for skill,_ in pairs(resources.permitted_skill) do
    resources.permitted_skill[skill] = true
   end
  end
 else
  if resources.permitted_skill[stype] then
   if direction == -1 then
    resources.permitted_skill[stype] = false
   elseif direction == 1 then
    resources.permitted_skill[stype] = true
   end
  else
   if verbose then print('Not a valid skill') end
   return
  end
 end
end

function changeEthic(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = tonumber(mobj)
 resources = civ.resources
 if stype == 'ALL' then
  for ethic,_ in pairs(resources.ethic) do
   resources.ethic[ethic] = mobj
  end
 else
  if resources.ethic[stype] then
   resources.ethic[stype] = mobj
  else
   if verbose then print('Not a valid ethic') end
   return
  end
 end
end

function changeValue(civ,stype,mobj,sobj,direction,verbose)
 if tonumber(civ) then civ = df.global.world.entities.all[tonumber(civ)] end
 if not civ then return false end
 stype = string.upper(stype)
 mobj = tonumber(mobj)
 resources = civ.resources
 if stype == 'ALL' then
  for value,_ in pairs(resources.values) do
   resources.values[value] = mobj
  end
  for value,_ in pairs(resources.values_2) do
   resources.values_2[value] = mobj
  end
 else
  if resources.values[stype] then
   resources.values[stype] = mobj
  elseif resources.values_2[stype] then
   resources.values_2[stype] = mobj
  else
   if verbose then print('Not a valid value') end
   return
  end
 end
end
