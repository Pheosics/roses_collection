-- Functions used in the wrapper script, v42.06a
local utils = require 'utils'
local split = utils.split_string
usages = {}

--=                     Location Based Targeting Checks
usages[#usages+1] = [===[

Location Based Targeting Checks
===============================

checkPosition(source,targetList,target,verbose)

isSelectedLocation(source,pos,args)

]===] 

function checkPosition(source,targetList,target)
 if not target then target = 'all' end
 n = 0
 list = {}
 target = string.upper(target)
 for i,pos in pairs(targetList) do
  block = dfhack.maps.ensureTileBlock(pos)
  occupancy = block.occupancy[pos.x%16][pos.y%16]
  designation = block.designation[pos.x%16][pos.y%16]
  tiletype = dfhack.maps.getTileType(pos)
  type_mat = df.tiletype_material[df.tiletype.attrs[tiletype].material]
  if target == 'ABOVE' then
   if pos.z > source.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'BELOW' then
   if pos.z < source.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'LEVEL' then
   if pos.z == source.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'LEVELABOVE'then
   if pos.z >= source.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'LEVELBELOW' then
   if pos.z <= source.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'NOTLEVEL' then
   if not pos.z == source.z then
    n = n + 1
    list[n] = pos
   end
  else
   n = #targetList
   list = targetList
   break
  end
 end
 return list,n
end

function isSelectedLocation(source,pos,args)
 local selected = true
 if args.test then test = true end

 checks = {'checkTree','checkPlant','checkInorganic','checkFlow','checkLiquid'}

 for _,check in ipairs(checks) do
  if args[check] and (selected or test) then
   selected = _G[check](source,unit,args[check])
  end
 end
  
 return selected
end

function checkTree(source,pos,argument,relation)
 tiletype = dfhack.maps.getTileType(pos)
 type_mat = df.tiletype_material[df.tiletype.attrs[tiletype].material]
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  relation = string.lower(split(arg,':')[1])
  tree = string.upper(split(arg,':')[2])
  if type_mat ~= 'TREE' then
   if relation == 'required' then
    return false
   elseif relation == 'forbidden' then
    return true
   end
  end
  if tree == 'ANY' then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end   
  else
   tree_mat = dfhack.script_environment('functions/map').getTreeMaterial(pos)
   if tree_mat.plant.id == tree then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end
   end
  end
 end
end

function checkPlant(source,pos,argument)
 tiletype = dfhack.maps.getTileType(pos)
 type_mat = df.tiletype_material[df.tiletype.attrs[tiletype].material]
 if type_mat ~= 'PLANT' then
  if relation == 'required' then
   return false
  elseif relation == 'forbidden' then
   return true
  end
 end
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  relation = string.lower(split(arg,':')[1])
  plant = string.upper(split(arg,':')[2])
  if type_mat ~= 'PLANT' then
   if relation == 'required' then
    return false
   elseif relation == 'forbidden' then
    return true
   end
  end
  if plant == 'ANY' then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end   
  else
   shrub_mat = dfhack.script_environment('functions/map').getShrubMaterial(pos)
   if shrub_mat.plant.id == plant then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end
   end
  end
 end
end

function checkInorganic(source,pos,argument)
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkFlow(source,pos,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  relation = string.lower(split(arg,':')[1])
  flow = string.upper(split(arg,':')[2])
  flows = dfhack.script_environment('functions/map').getFlow(pos,flow)
  if #flows > 0 then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end   
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkLiquid(source,pos,argument)
 relation = string.lower(split(argument,':')[1])
 liquidtype = string.upper(split(argument,':')[2])
 block = dfhack.maps.ensureTileBlock(pos)
 designation = block.designation[pos.x%16][pos.y%16]
 if liquidtype == 'ANY' then
  if designation.flow_size > 0 then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end
  end
 elseif liquidtype == 'WATER' then
  if designation.flow_size > 0 and not designation.liquid_type then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end
  end
 elseif liquidtype == 'MAGMA' then
  if designation.flow_size > 0 and designation.liquid_type then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end
  end 
 end
end

--=                     Unit Based Targeting Checks
usages[#usages+1] = [===[

Unit Based Targeting Checks
===========================

checkUnitLocation(center,radius)

checkTarget(source,targetList,target)

isSelectedUnit(source,unit,args)

]===]

function checkUnitLocation(center,radius)
 if radius then
  rx = tonumber(radius.x) or tonumber(radius[1]) or 0
  ry = tonumber(radius.y) or tonumber(radius[2]) or 0
  rz = tonumber(radius.z) or tonumber(radius[3]) or 0
 else
  rx = 0
  ry = 0
  rz = 0
 end
 local targetList = {}
 local selected = {}
 n = 1
 unitList = df.global.world.units.active
 if rx <= 0 and ry <= 0 and rz <= 0 then
  targetList[n] = center
 else
  local xmin = center.pos.x - rx
  local ymin = center.pos.y - ry
  local zmin = center.pos.z - rz
  local xmax = center.pos.x + rx
  local ymax = center.pos.y + ry
  local zmax = center.pos.z + rz
  targetList[n] = center
  for i,unit in ipairs(unitList) do
   if unit.pos.x <= xmax and unit.pos.x >= xmin and unit.pos.y <= ymax and unit.pos.y >= ymin and unit.pos.z <= zmax and unit.pos.z >= zmin and unit ~= center then
    n = n + 1
    targetList[n] = unit
   end
  end
 end
 return targetList,n
end

function checkTarget(source,targetList,target)
 if not target then target = 'all' end
 n = 0
 list = {}
 target = string.upper(target)
 for i,unit in pairs(targetList) do
  if target == 'ENEMY' then
   if unit.invasion_id > 0 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'FRIENDLY' then
   if unit.invasion_id == -1 and unit.civ_id ~= -1 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'CIV' then
   if source.civ_id == unit.civ_id then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'RACE' then
   if source.race == unit.race then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'CASTE' then
   if source.race == unit.race and source.caste == unit.caste then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'GENDER' then
   if source.sex == unit.sex then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'WILD' then
   if unit.training_level == 9 and unit.civ_id == -1 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'DOMESTIC' then
   if unit.training_level == 7 and unit.civ_id == source.civ_id then
    n = n + 1
    list[n] = unit
   end
  else
   n = #targetList
   list = targetList
   break
  end
 end
 return list,n
end

function isSelectedUnit(source,unit,args)
 local selected = true
 if args.test then test = true end

 checks = {'checkAttribute','checkSkill','checkTrait','checkAge','checkSpeed',
           'checkClass','checkCreature','checkSyndrome','checkToken',
           'checkNoble','checkProfession','checkEntity','checkPathing'}

 for _,check in ipairs(checks) do
  if args[check] and (selected or test) then
   selected = _G[check](source,unit,args[check])
  end
 end

 return selected
end

function checkAge(source,target,argument)
 sage = dfhack.units.getAge(source)
 tage = dfhack.units.getAge(target)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  relation = string.lower(split(x,':')[1])
  value = tonumber(split(x,':')[2])
  if relation == 'max' then
   if tage > value then return false end
  elseif relation == 'min' then
   if tage < value then return false end
  elseif relation == 'greater' then
   if tage/sage < value then return false end
  elseif relation == 'less' then
   if sage/tage < value then return false end
  end
 end
 return true
end

function checkAttribute(source,target,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  relation = string.lower(split(x,':')[1])
  attribute = split(x,':')[2]
  value = tonumber(split(x,':')[3])
  sattribute = dfhack.script_environment('functions/unit').getUnitTable(source)
  sattribute = sattribute..Attributes[attribute].Total
  tattribute = dfhack.script_environment('functions/unit').getUnitTable(target)
  tattribute = tattribute..Attributes[attribute].Total
  if relation == 'max' then
   if tattribute > value then return false end
  elseif relation == 'min' then
   if tattribute < value then return false end
  elseif relation == 'greater' then
   if tattribute/sattribute < value then return false end
  elseif relation == 'less' then
   if sattribute/tattribute < value then return false end
  end
 end
 return true
end

function checkClass(source,target,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  selected = dfhack.script_environment('functions/unit').checkClass(target,class)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkCreature(source,target,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  selected = dfhack.script_environment('functions/unit').checkCreatureRace(target,check)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkEntity(source,target,argument)
-- sentity = df.global.world.entities[source.civ_id].entity_raw.code
 if target.civ_id < 0 then return false end
 tentity = df.global.world.entities.all[target.civ_id].entity_raw.code
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  selected = check == tentity
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkNoble(source,target,argument)
-- snoble = dfhack.units.getNoblePositions(source)
 tnoble = dfhack.units.getNoblePositions(target)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  if tnoble then
   for j,y in pairs(tnoble) do
    position = y.position.code
    selected = position == check
    if relation == 'required' then
	 if selected then return true end
    elseif relation == 'immune' then
     if selected then return false end
    end
   end
  else
   if relation == 'required' then
    return false
   elseif relation == 'immune' then
    return true
   end   
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkPathing(source,target,argument)
 tgoal = target.path.goal
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  n = df.unit_path_goal[check]
  selected = n == tgoal
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkProfession(source,target,argument)
-- sprof = source.profession
 tprof = target.profession
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  n = df.profession[check]
  selected = n == tprof
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkSkill(source,target,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  relation = string.lower(split(x,':')[1])
  skill = split(x,':')[2]
  value = tonumber(split(x,':')[3])
  sskill = dfhack.script_environment('functions/unit').getUnitTable(source)
  sskill = sskill.Skills[skill].Total
  tskill = dfhack.script_environment('functions/unit').getUnitTable(target)
  tSkill = tSkill.Skills[skill].Total
  if relation == 'max' then
   if tskill > value then return false end
  elseif relation == 'min' then
   if tskill < value then return false end
  elseif relation == 'greater' then
   if tskill/sskill < value then return false end
  elseif relation == 'less' then
   if sskill/tskill < value then return false end
  end
 end
 return true
end

function checkSpeed(source,target,argument)
 sspeed = dfhack.units.computeMovementSpeed(source)
 tspeed = dfhack.units.computeMovementSpeed(target)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  relation = string.lower(split(x,':')[1])
  value = tonumber(split(x,':')[2])
  if relation == 'max' then
   if tspeed > value then return false end
  elseif relation == 'min' then
   if tspeed < value then return false end
  elseif relation == 'greater' then
   if tspeed/sspeed < value then return false end
  elseif relation == 'less' then
   if sspeed/tspeed < value then return false end
  end
 end
 return true
end

function checkSyndrome(source,target,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  selected = dfhack.script_environment('functions/unit').checkCreatureSyndrome(target,check)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkToken(source,target,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  relation = string.lower(split(x,':')[1])
  check = split(x,':')[2]
  selected = dfhack.script_environment('functions/unit').checkCreatureToken(target,check)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkTrait(source,target,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  relation = string.lower(split(x,':')[1])
  trait = split(x,':')[2]
  value = tonumber(split(x,':')[3])
  strait = dfhack.script_environment('functions/unit').getUnitTable(source)
  strait = strait.Traits[trait].Total
  ttrait = dfhack.script_environment('functions/unit').getUnitTable(target)
  ttrait = ttrait.Traits[trait].Total
  if relation == 'max' then
   if ttrait > value then return false end
  elseif relation == 'min' then
   if ttrait < value then return false end
  elseif relation == 'greater' then
   if ttrait/strait < value then return false end
  elseif relation == 'less' then
   if strait/ttrait < value then return false end
  end
 end
 return true
end

--=                     Item Based Targeting Checks
usages[#usages+1] = [===[

Item Based Targeting Checks
===========================

checkItemLocation(center,radius)

checkItem(source,targetList,target)

isSelectedItem(source,item,args)

]===]

function checkItemLocation(center,radius)
 if radius then
  rx = tonumber(radius.x) or tonumber(radius[1]) or 0
  ry = tonumber(radius.y) or tonumber(radius[2]) or 0
  rz = tonumber(radius.z) or tonumber(radius[3]) or 0
 else
  rx = 0
  ry = 0
  rz = 0
 end
 local targetList = {}
 local selected = {}
 n = 0
 itemList = df.global.world.items.all
 if rx < 0 and ry < 0 and rz < 0 then
  return targetList, n
 else
  local xmin = center.x - rx
  local ymin = center.y - ry
  local zmin = center.z - rz
  local xmax = center.x + rx
  local ymax = center.y + ry
  local zmax = center.z + rz
  for i,item in ipairs(itemList) do
   pos = {}
   pos.x, pos.y, pos.z = dfhack.items.getPosition(item)
   if pos.x and pos.y and pos.z then
    if pos.x <= xmax and pos.x >= xmin and pos.y <= ymax and pos.y >= ymin and pos.z <= zmax and pos.z >= zmin then
     n = n + 1
     targetList[n] = item
    end
   end
  end
 end
 return targetList,n
end

function checkItem(source,targetList,target)
 if not target then target = 'all' end
 n = 0
 list = {}
 target = string.upper(target)
 for i,item in pairs(targetList) do
  if target == 'INVENTORY' then
   if item.flags.in_inventory then
    n = n + 1
    list[n] = item
   end
  elseif target == 'ONGROUND' then
   if item.flags.on_ground then
    n = n + 1
    list[n] = item
   end
  elseif target == 'ARTIFACT' then
   if item.flags.artifact then
    n = n + 1
    list[n] = item
   end
  elseif target == 'ONFIRE' then
   if item.flags.on_fire then
    n = n + 1
    list[n] = item
   end
  elseif target == 'PROJECTILE' then
   if dfhack.items.getGeneralRef(item,df.general_ref_type['PROJECTILE']) then
    n = n + 1
    list[n] = item
   end
  else
   n = #targetList
   list = targetList
   break
  end
 end
 return list,n
end

function isSelectedItem(source,item,args)
 local selected = true
 if args.test then test = true end
 
 checks = {'checkItemType','checkMaterial','checkCorpse'}
 
 for _,check in ipairs(checks) do 
  if args[check] and (selected or test) then
   selected = _G[check](source,item,args[check])
  end
 end

 return selected
end

function checkItemType(source,item,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  temp = string.upper(arg)
  splitArg = split(temp,':')
  relation = splitArg[1]
  if #splitArg == 2 then
   if item:getType() == dfhack.items.findType(temp) then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  elseif #splitArg == 3 then
   if item:getType() == dfhack.items.findType(temp) and item:getSubtype() == dfhack.items.findSubType(temp) then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  end
 end
end

function checkMaterial(source,item,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  temp = string.upper(arg)
  splitArg = split(temp,':')
  relation = splitArg[1]
  if #splitArg == 2 then
   if item.mat_type() == dfhack.matinfo.find(temp)['type'] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  elseif #splitArg == 3 then
   if item.mat_type() == dfhack.matinfo.find(temp)['type'] and item.mat_index() == dfhack.matinfo.find(temp)['index'] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  end
 end
end

function checkCorpse(source,item,argument)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  temp = string.upper(arg)
  splitArg = split(temp,':')
  relation = splitArg[1]
  if not df.item_corpsest:is_instance(item) then
   if relation == 'required' then
    return false
   elseif relation == 'forbidden' then
    return true
   end
  end 
  if #splitArg == 2 then
   if df.global.world.raws.creatures.all[item.race].creature_id == splitArg[2] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  elseif #splitArg == 3 then
   if df.global.world.raws.creatures.all[item.race].creature_id == splitArg[2] and df.global.world.raws.creatures.all[item.race].caste[item.caste].caste_id == splitArg[3] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  end
 end
end

--=                     Equation Functions
usages[#usages+1] = [===[

Equation Functions
==================

getValue

]===]

function getValue(equation,target,source,center,targetList,selected,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 
 check = {'source','SOURCE','target','TARGET'}
 for _,unit in pairs(check) do
  if unit == 'SOURCE' or unit == 'source' then unitID = source.id end
  if unit == 'TARGET' or unit == 'target' then unitID = target.id end
  while equation:find(unit) do
   look = string.match(equation..'+',unit..".(.-)[+%-*/]")
   array = split(look,"%.")
   if string.upper(array[1]) == 'ATTRIBUTE' then
    total = dfhack.script_environment('functions/unit').trackAttribute(unitID,string.upper(array[2]),nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'SKILL' then
    total = dfhack.script_environment('functions/unit').trackSkill(unitID,string.upper(array[2]),nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'TRAIT' then
    total = dfhack.script_environment('functions/unit').trackTrait(unitID,string.upper(array[2]),nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'COUNTER' then
    total = dfhack.script_environment('functions/unit').getCounter(unitID,string.lower(array[2]))
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'RESISTANCE' then
    total = dfhack.script_environment('functions/unit').trackResistance(unitID,look,nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   end
  end
 end
 
 equals = assert(load("return "..equation))
 value = equals()
 return value
end

