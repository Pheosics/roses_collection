function checkLocation(center,radius,verbose)
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
 if rx < 0 and ry < 0 and rz < 0 then
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

function checkTarget(source,targetList,target,verbose)
 if not target then target = 'all' end
 n = 0
 list = {}
 
 for i,unit in pairs(targetList) do
  if target == 'enemy' or target == 'Enemy' then
   if unit.invasion_id > 0 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'friendly' or target == 'Friendly' then
   if unit.invasion_id == -1 and unit.civ_id ~= -1 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'civ' or target == 'Civ' then
   if source.civ_id == unit.civ_id then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'race' or target == 'Race' then
   if source.race == unit.race then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'caste' or target == 'Caste' then
   if source.race == unit.race and source.caste == unit.caste then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'gender' or target == 'Gender' then
   if source.sex == unit.sex then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'wild' or target == 'Wild' then
   if unit.training_level == 9 and unit.civ_id == -1 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'domestic' or target == 'Domestic' then
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

function checkAge(source,target,argument,relation,verbose)
 local selected = true
 sage = dfhack.units.getAge(source)
 tage = dfhack.units.getAge(target)

 value = tonumber(argument)
 if relation == 'max' then
  if tage > value then return false end
 elseif relation == 'min' then
  if tage < value then return false end
 elseif relation == 'greater' then
  if tage/sage < value then return false end
 elseif relation == 'less' then
  if sage/tage < value then return false end
 end
 
 return selected
end

function checkAttribute(source,target,argument,relation,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  attribute = split(x,':')[1]
  value = tonumber(split(x,':')[2])
  sattribute = dfhack.script_environment('functions/unit').trackAttribute(source,attribute,nil,nil,nil,nil,'get')
  tattribute = dfhack.script_environment('functions/unit').trackAttribute(target,attribute,nil,nil,nil,nil,'get')
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

function checkClass(source,target,argument,relation,verbose)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkClass(target,x)
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

function checkCreature(source,target,argument,relation,verbose)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkCreatureRace(target,x)
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

function checkEntity(source,target,argument,relation,verbose)
-- sentity = df.global.world.entities[source.civ_id].entity_raw.code
 if target.civ_id < 0 then return false end
 tentity = df.global.world.entities[target.civ_id].entity_raw.code
 
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = x == tentity
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

function checkNoble(source,target,argument,relation,verbose)
-- snoble = dfhack.units.getNoblePositions(source)
 tnoble = dfhack.units.getNoblePositions(target)
 
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  if tnoble then
   for j,y in pairs(tnoble) do
    position = y.position.code
    selected = position == x
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

function checkProfession(source,target,argument,relation,verbose)
-- sprof = source.profession
 tprof = target.profession
 
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  n = df.profession[x]
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

function checkSkill(source,target,argument,relation,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  skill = split(x,':')[1]
  value = tonumber(split(x,':')[2])
  sskill = dfhack.script_environment('functions/unit').trackSkill(source,skill,nil,nil,nil,nil,'get')
  tskill = dfhack.script_environment('functions/unit').trackSkill(target,skill,nil,nil,nil,nil,'get')
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

function checkSpeed(source,target,argument,relation,verbose)
 sspeed = dfhack.units.computeMovementSpeed(source)
 tspeed = dfhack.units.computeMovementSpeed(target)
 
 value = tonumber(argument)
 if relation == 'max' then
  if tspeed > value then return false end
 elseif relation == 'min' then
  if tspeed < value then return false end
 elseif relation == 'greater' then
  if tspeed/sspeed < value then return false end
 elseif relation == 'less' then
  if sspeed/tspeed < value then return false end
 end
 
 return true
end

function checkSyndrome(source,target,argument,relation,verbose)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkCreatureSyndrome(target,x)
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

function checkToken(source,target,argument,relation,verbose)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkCreatureToken(target,x)
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

function checkTrait(source,target,argument,relation,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  trait = split(x,':')[1]
  value = tonumber(split(x,':')[2])
  strait = dfhack.script_environment('functions/unit').trackTrait(source,trait,nil,nil,nil,nil,'get')
  ttrait = dfhack.script_environment('functions/unit').trackTrait(target,trait,nil,nil,nil,nil,'get')
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

function isSelected(source,unit,args)
 local selected = true

 if args.maxAttribute and selected then
  selected = checkAttribute(source,unit,args.maxAttribute,'max',args.verbose)
 end
 if args.minAttribute and selected then
  selected = checkAttribute(source,unit,args.minAttribute,'min',args.verbose)
 end
 if args.gtAttribute and selected then
  selected = checkAttribute(source,unit,args.gtAttribute,'greater',args.verbose)
 end
 if args.ltAttribute and selected then
  selected = checkAttribute(source,unit,args.ltAttribute,'less',args.verbose)
 end
 
 if args.maxSkill and selected then
  selected = checkSkill(source,unit,args.maxSkill,'max',args.verbose)
 end
 if args.minSkill and selected then
  selected = checkSkill(source,unit,args.minSkill,'min',args.verbose)
 end
 if args.gtSkill and selected then
  selected = checkSkill(source,unit,args.gtSkill,'greater',args.verbose)
 end
 if args.ltSkill and selected then
  selected = checkSkill(source,unit,args.ltSkill,'less',args.verbose)
 end
 
 if args.maxTrait and selected then
  selected = checkTrait(source,unit,args.maxTrait,'max',args.verbose)
 end
 if args.mintrait and selected then
  selected = checkTrait(source,unit,args.minTrait,'min',args.verbose)
 end
 if args.gtTrait and selected then
  selected = checkTrait(source,unit,args.gtTrait,'greater',args.verbose)
 end
 if args.ltTrait and selected then
  selected = checkTrait(source,unit,args.ltTrait,'less',args.verbose)
 end
 
 if args.maxAge and selected then
  selected = checkAge(source,unit,args.maxAge,'max',args.verbose)
 end
 if args.minAge and selected then
  selected = checkAge(source,unit,args.minAge,'min',args.verbose)
 end
 if args.gtAge and selected then
  selected = checkAge(source,unit,args.gtAge,'greater',args.verbose)
 end
 if args.ltAge and selected then
  selected = checkAge(source,unit,args.ltAge,'less',args.verbose)
 end
 
 if args.maxSpeed and selected then
  selected = checkSpeed(source,unit,args.maxSpeed,'max',args.verbose)
 end
 if args.minSpeed and selected then
  selected = checkSpeed(source,unit,args.minSpeed,'min',args.verbose)
 end
 if args.gtSpeed and selected then
  selected = checkSpeed(source,unit,args.gtSpeed,'greater',args.verbose)
 end
 if args.ltSpeed and selected then
  selected = checkSpeed(source,unit,args.ltSpeed,'less',args.verbose)
 end
 
 if args.requiredClass and selected then
  selected = checkClass(source,unit,args.requiredClass,'required',args.verbose)
 end 
 if args.immuneClass and selected then
  selected = checkClass(source,unit,args.immuneClass,'immune',args.verbose)
 end 
 
 if args.requiredCreature and selected then
  selected = checkCreature(source,unit,args.requiredCreature,'required',args.verbose)
 end 
 if args.immuneCreature and selected then
  selected = checkCreature(source,unit,args.immuneCreature,'immune',args.verbose)
 end
 
 if args.requiredSyndrome and selected then
  selected = checkSyndrome(source,unit,args.requiredSyndrome,'required',args.verbose)
 end 
 if args.immuneSyndrome and selected then
  selected = checkSyndrome(source,unit,args.immuneSyndrome,'immune',args.verbose)
 end

 if args.requiredToken and selected then
  selected = checkToken(source,unit,args.requiredToken,'required',args.verbose)
 end 
 if args.immuneToken and selected then
  selected = checkToken(source,unit,args.immuneToken,'immune',args.verbose)
 end
 
 if args.requiredNoble and selected then
  selected = checkNoble(source,unit,args.requiredNoble,'required',args.verbose)
 end 
 if args.inoble and selected then
  selected = checkNoble(source,unit,args.inoble,'immune',args.verbose)
 end
 
 if args.requiredProfesion and selected then
  selected = checkProfession(source,unit,args.requiredProfesion,'required',args.verbose)
 end 
 if args.immuneProfession and selected then
  selected = checkProfession(source,unit,args.immuneProfession,'immune',args.verbose)
 end
 
 if args.requiredEntity and selected then
  selected = checkEntity(source,unit,args.requiredEntity,'required',args.verbose)
 end 
 if args.immuneEntity and selected then
  selected = checkEntity(source,unit,args.immuneEntity,'immune',args.verbose)
 end

 return selected
end