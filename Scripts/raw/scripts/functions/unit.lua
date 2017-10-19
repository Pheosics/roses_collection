--unit based functions, version 42.06a
--[[
 trackCore(unit,strname,kind,Table,func,change,value,syndrome,alter)
 trackAttribute(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 trackResistance(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 trackSkill(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 trackStat(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 trackTrait(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 trackCreate(unit,summoner,dur,alter,syndrome,cb_id)
 trackSide(unit,civ_id,pop_id,inv_id,trn,regx,regy,regp,pet,stype,dur,alter,syndrome,cb_id)
 trackTransform(unit,race,caste,dur,alter,syndrome,cb_id)

 changeAttribute(unit,attribute,change,dur,track,syndrome,cb_id)
 changeCounter(unit,counter,change,dur)
 changeResistance(unit,resistance,change,dur,track,syndrome,cb_id)
 changeSkill(unit,skill,change,dur,track,syndrome,cb_id)
 changeStat(unit,stat,change,dur,track,syndrome,cb_id)
 changeTrait(unit,trait,change,dur,track,syndrome,cb_id)
 changeBody(unit,part,changeType,change,dur)
 changeLife(unit,corpsepart,change,reference,regrow,syndrome,dur)
 changeWound(unit,bp_id,gl_id,regrow)
 changeEmotion(unit,thought,subthought,emotion,strength,severity,task,number,dur,syndrome,cb_id)
 changeFlag(unit,flag,clear)
 changeSide(unit,side,side_type,dur,track,syndrome,civ_id,pop_id,inv_id,trn,regx,regy,regp,cb_id)
 changeSyndrome(unit,syndromes,change,dur)
 transform(unit,race,caste,dur,track,syndrome,cb_id)
 move(unit,location)
 removal(unit,remType)

 checkClass(unit,class)
 checkClassCreature(unit,class)
 checkClassSyndrome(unit,class)
 checkCreatureRace(unit,creature)
 checkCreatureToken(unit,token)
 checkDistance(unit,location,distance)

 getUnit(unit,strType,strKind)
 getAttack(unit,attack_type)
 getBodyRandom(unit)
 getBodyCategory(unit,category)
 getBodyFlag(unit,flag)
 getBodyToken(unit,token)
 getBodyConnectedParts(unit,parts)
 getBodyPartGlobalLayers(unit,part)
 getBodyCorpseParts(unit)
 getEmotion(unit,emotion,thought)
 getSyndrome(unit,class,what)
 getInventoryType(unit,item_type)
 getCounter(unit,counter)

 create(location,raceID,casteID,refUnit,side,name,dur,track,syndrome,cb_id)
 createHistFig()
 createName()
 createNemesis()
 createUnit()

 makeProjectile(unit,velocity)

 findUnit(search)
]]
---------------------------------------------------------------------------------------
----------- Track changes in the persist-table and handle termination -----------------
---------------------------------------------------------------------------------------
function trackCore(unit,strname,kind,Table,func,change,value,syndrome,dur,alter)
 if alter == 'track' then -- Track changes to the unit for both durational effects and permanent effects
  typeTable = Table[kind]
  if dur > 0 then 
   statusTable = typeTable.StatusEffects
   typeTable.Change = tostring(typeTable.Change + change)
   local statusNumber = #statusTable._children -- If the change has a duration add a status effect to the StatusEffects table
   statusTable[tostring(statusNumber+1)] = {}
   statusTable[tostring(statusNumber+1)].End = tostring(math.floor(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur))
   statusTable[tostring(statusNumber+1)].Change = tostring(math.floor(change))
   statusTable[tostring(statusNumber+1)].Linked = 'False'
   if syndrome then -- If the change has an associated syndrome, link the StatusEffects table and the SyndromeTrack table together
    trackTable = unitTable[tostring(unit.id)].SyndromeTrack
    statusTable[tostring(math.floor(statusNumber+1))].Linked = 'True'
    if not trackTable[syndrome] then
     trackTable[syndrome] = {}
    end
    if not trackTable[syndrome][strname] then
     trackTable[syndrome][strname] = {}
    end
    if not trackTable[syndrome][strname][kind] then
     trackTable[syndrome][strname][kind] = {}
    end
    trackTable[syndrome][strname][kind].Number = tostring(math.floor(statusNumber+1))
    trackTable[syndrome][strname][kind].CallBack = tostring(cb_id)
   end
  else
   typeTable.Base = tostring(math.floor(value)) -- No need for associating syndromes with permanent changes, if requested can add at a later time.
  end 
 elseif alter == 'end' then -- If the change ends naturally, revert the change
  typeTable = Table[kind]
  statusTable = typeTable.StatusEffects
  typeTable.Change = tostring(math.floor(typeTable.Change - change))
  for i = #statusTable._children,1,-1 do -- Remove any naturally ended effects
   if statusTable[i] then
    if tonumber(statusTable[i].End) <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     if statusTable[i].Linked == 'True' and syndrome then
      trackTable = unitTable[tostring(unit.id)].SyndromeTrack
      if trackTable[syndrome][strname][kind].Number == i then trackTable[syndrome][strname] = nil end
     end
     statusTable[i] = nil
     changeSyndrome(unit.id,syndrome,'erase')
    end
   end
  end
 elseif alter == 'terminate' then
  trackTable = unitTable[tostring(unit.id)].SyndromeTrack
  if syndrome then name = syndrome end
  if trackTable[name] then
   if trackTable[name][strname] then
    for _,kindA in pairs(trackTable[name][strname]._children) do
     typeTable = Table[kindA]
     statusTable = typeTable.StatusEffects
     local statusNumber = trackTable[name][strname][kindA].Number
     local callback = trackTable[name][strname][kindA].CallBack
     typeTable.Change = tostring(math.floor(typeTable.Change - statusTable[statusNumber].Change))
     func(unit.id,kindA,-tonumber(statusTable[statusNumber].Change),0,nil,nil)
     dfhack.timeout_active(callback,nil)
     dfhack.script_environment('persist-delay').environmentDelete(callback)
     statusTable[statusNumber] = nil
    end
    trackTable[name][strname] = nil
    changeSyndrome(unit.id,syndrome,'erase')
   end
  end
 elseif alter == 'terminateClass' then -- If the change ends by force, check the syndrome tracker to determine effects
  local trackTable = unitTable[tostring(unit.id)].SyndromeTrack
  syndromeNames = checkSyndrome(unit.id,syndrome,'class')
  for _,name in pairs(syndromeNames) do
   if trackTable[name] then
    if trackTable[name][strname] then
     for _,kindA in pairs(trackTable[name][strname]._children) do
      typeTable = Table[kindA]
      statusTable = typeTable.StatusEffects
      local statusNumber = trackTable[name][strname][kindA].Number
      local callback = trackTable[name][strname][kindA].CallBack
      typeTable.Change = tostring(typeTable.Change - statusTable[statusNumber].Change)
      func(unit.id,kindA,-tonumber(statusTable[statusNumber].Change),0,nil,nil)
      dfhack.timeout_active(callback,nil)
      dfhack.script_environment('persist-delay').environmentDelete(callback)
      statusTable[statusNumber] = nil
     end
     trackTable[name][strname] = nil
     changeSyndrome(unit.id,syndrome,'erase')
    end
   end
  end
 elseif alter == 'class' then -- Track changes associated with a class
  typeTable = Table[kind]
  typeTable.Class = tostring(math.floor(change + typeTable.Class))
 elseif alter == 'item' then -- Track changes associated with an item
  typeTable = Table[kind]
  typeTable.Item = tostring(math.floor(change + typeTable.Item))
 end
end

----------- Basic Tracking (Attribute, Resistance, Skill, Stat, Trait) ----------------
function trackAttribute(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 -- Tracks changes to a units attributes
 -- Make sure base/roses-init is loaded
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return "base/roses-init not loaded"
 end
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 -- Initialize the UnitTable for the unit id if necessary
 unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 if not unitTable.Attributes[kind] then
  dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit.id,'Attributes',kind)
 end
 -- Track!
 trackCore(unit,'Attribute',kind,unitTable.Attributes,changeAttribute,change,value,syndrome,dur,alter)
end

function trackResistance(unit,kind,change,value,dur,alter,syndrome,cb_id)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return
 end
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 if not unitTable.Resistances[kind] then
  dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit.id,'Resistances',kind)
 end
 -- Track!
 trackCore(unit,'Resistance',kind,unitTable.Resistances,changeResistance,change,value,syndrome,dur,alter)
end

function trackSkill(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 -- Tracks changes to a units skills
 -- Make sure base/roses-init is loaded
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return "base/roses-init not loaded"
 end
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 -- Initialize the UnitTable for the unit id if necessary
 unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 if not unitTable.Skills[kind] then
  dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit.id,'Skills',kind)
 end
 -- Track!
 trackCore(unit,'Skill',kind,unitTable.Skills,changeSkill,change,value,syndrome,dur,alter)
end

function trackStat(unit,kind,change,value,dur,alter,syndrome,cb_id)
 -- Make sure base/roses-init is loaded
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return "base/roses-init not loaded"
 end
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 -- Initialize the UnitTable for the unit id if necessary
 unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 if not unitTable.Stats[kind] then
  dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit.id,'Stats',kind)
 end
 -- Track!
 trackCore(unit,'Stat',kind,unitTable.Stats,changeStat,change,value,syndrome,dur,alter)
end

function trackTrait(unit,kind,current,change,value,dur,alter,syndrome,cb_id)
 -- Tracks changes to a units traits
 -- Make sure base/roses-init is loaded
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return "base/roses-init not loaded"
 end
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 -- Initialize the UnitTable for the unit id if necessary
 unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 if not unitTable[tostring(unit.id)].Traits[kind] then
  dfhack.script_environment('functions/tables').makeUnitTableTrait(unit.id,kind)
 end
 -- Track!
 trackCore(unit,'Trait',kind,unitTable.Traits,changeTrait,change,value,syndrome,dur,alter)
end

-------------- Complex Tracking (Create, Side, Transform) -------------------
function trackCreate(unit,summoner,dur,syndrome,cb_id)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return
 end
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if tonumber(summoner) then
  summoner = df.unit.find(tonumber(summoner))
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 if not unitTable[tostring(unit.id)].General.Summoned then
  dfhack.script_environment('functions/tables').makeUnitTableSummon(unit.id)
 end

 summonedTable = unitTable[tostring(unit.id)].General.Summoned
 if alter == 'track' then
  summonedTable.Creator = tostring(summoner.id)
  if syndrome then summonedTable.Syndrome = syndrome end
  if dur > 0 then
   summonedTable.End = tostring(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
  end
 elseif alter == 'end' then
  unitTable[tostring(unit.id)] = nil
 elseif alter == 'terminate' then
  if unitTable[tostring(unit.id)].General.Summoned.Syndrome == syndrome then removal(unit,'created') end
  unitTable[tostring(unit.id)] = nil
 elseif alter == 'terminateClass' then
  syndromeNames = checkSyndrome(unit.id,syndrome,'class')
  for _,name in pairs(syndromeNames) do
   if unitTable[tostring(unit.id)].General.Summoned.Syndrome == name then 
    removal(unit,'created')
    unitTable[tostring(unit.id)] = nil
    break
   end
  end
 end
end

function trackSide(unit,civ_id,pop_id,inv_id,trn,regx,regy,regp,pet,stype,dur,alter,syndrome,cb_id)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if tonumber(side) then
  side = df.unit.find(tonumber(side))
 end
 
 local persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return "base/roses-init not loaded"
 end 
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 if not unitTable[tostring(unit.id)].General.Side then
  dfhack.script_environment('functions/tables').makeUnitTableSide(unit.id)
 end

 sideTable = unitTable[tostring(unit.id)].General.Side
 statusTable = sideTable.StatusEffects

 if alter == 'track' then
--[[
  sideTable.Current.Civ = tostring(unit.civ_id)
  sideTable.Current.Pop = tostring(unit.population_id)
  sideTable.Current.Inv = tostring(unit.invasion_id)
  sideTable.Current.Trn = tostring(unit.training_level)
  sideTable.Current.Rgx = tostring(unit.animal.population.region_x)
  sideTable.Current.Rgy = tostring(unit.animal.population.region_y)
  sideTable.Current.Pid = tostring(unit.animal.population.population_idx)
  sideTable.Current.Pet = tostring(unit.relations.pet_owner_id)
]]
  if tonumber(dur) > 0 then
   local statusNumber = #statusTable._children -- If the change has a duration add a status effect to the StatusEffects table
   statusTable[tostring(statusNumber+1)] = {}
   statusTable[tostring(statusNumber+1)].End = tostring(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[tostring(statusNumber+1)].Civ = tostring(civ_id)
   statusTable[tostring(statusNumber+1)].Pop = tostring(pop_id)
   statusTable[tostring(statusNumber+1)].Inv = tostring(inv_id)
   statusTable[tostring(statusNumber+1)].Trn = tostring(trn)
   statusTable[tostring(statusNumber+1)].Rgx = tostring(regx)
   statusTable[tostring(statusNumber+1)].Rgy = tostring(regy)
   statusTable[tostring(statusNumber+1)].Pid = tostring(regp)
   statusTable[tostring(statusNumber+1)].Pet = tostring(pet)
   statusTable[tostring(statusNumber+1)].Type = tostring(stype)
   statusTable[tostring(statusNumber+1)].Linked = 'False'
   if syndrome then -- If the change has an associated syndrome, link the StatusEffects table and the SyndromeTrack table together
    local trackTable = unitTable[tostring(unit.id)].SyndromeTrack  
    statusTable[tostring(statusNumber+1)].Linked = 'True'
    if not trackTable[syndrome] then
     trackTable[syndrome] = {}
    end
    if not trackTable[syndrome].General then
     trackTable[syndrome].General = {}
    end
    if not trackTable[syndrome].General.Side then
     trackTable[syndrome].General.Side = {}
    end
    trackTable[syndrome].General.Side.Number = tostring(statusNumber+1)
    trackTable[syndrome].General.Side.Callback = tostring(cb_id)
   end
  elseif tonumber(dur) == 0 then
--[[
   sideTable.Base.Civ = tostring(unit.civ_id)
   sideTable.Base.Pop = tostring(unit.population_id)
   sideTable.Base.Inv = tostring(unit.invasion_id)
   sideTable.Base.Trn = tostring(unit.training_level)
   sideTable.Base.Rgx = tostring(unit.animal.population.region_x)
   sideTable.Base.Rgy = tostring(unit.animal.population.region_y)
   sideTable.Base.Pid = tostring(unit.animal.population.population_idx)
   sideTable.Base.Pet = tostring(unit.relations.pet_owner_id)
]]
  end
 elseif alter == 'end' then
--[[
  sideTable.Current.Civ = tostring(civ_id)
  sideTable.Current.Pop = tostring(pop_id)
  sideTable.Current.Inv = tostring(inv_id)
  sideTable.Current.Trn = tostring(trn)
  sideTable.Current.Rgx = tostring(regx)
  sideTable.Current.Rgy = tostring(regy)
  sideTable.Current.Pid = tostring(regp)
  sideTable.Current.Pet = tostring(side_id)
]]
  for i = #statusTable._children,1,-1 do -- Remove any naturally ended effects
   if statusTable[i] then
    if tonumber(statusTable[i].End) <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     if statusTable[i].Linked == 'True' and syndrome then
      local trackTable = unitTable[tostring(unit.id)].SyndromeTrack
      if trackTable[syndrome].General.Side.Number == i then trackTable[syndrome].General = nil end
     end
     statusTable[i] = nil
     changeSyndrome(unit.id,syndrome,'erase')
    end
   end
  end
 elseif alter == 'terminate' then
  local trackTable = unitTable[tostring(unit.id)].SyndromeTrack
  if syndrome then name = syndrome end
  local statusNumber = trackTable[name].General.Side.Number
  local callback = trackTable[name].General.Side.Callback
  Table = statusTable[statusNumber]
--[[
  sideTable.Current.Civ = tostring(Table.Civ)
  sideTable.Current.Pop = tostring(Table.Pop)
  sideTable.Current.Inv = tostring(Table.Inv)
  sideTable.Current.Trn = tostring(Table.Trn)
  sideTable.Current.Rgx = tostring(Table.Rgx)
  sideTable.Current.Rgy = tostring(Table.Rgy)
  sideTable.Current.Pid = tostring(Table.Pid)
  sideTable.Current.Pet = tostring(Table.Pet)
]]
  changeSide(unit,Table.Pet,Table.Type,-2,nil,nil,Table.Civ,Table.Pop,Table.Inv,Table.Trn,Table.Rgx,Table.Rgy,Table.Pid,nil)
  dfhack.timeout_active(callback,nil)
  dfhack.script_environment('persist-delay').environmentDelete(callback)
  statusTable[statusNumber] = nil
  trackTable[name].General.Side = nil
  changeSyndrome(unit.id,syndrome,'erase')
 elseif alter == 'terminateClass' then -- If the change ends by force, check the syndrome tracker to determine effects
  local trackTable = unitTable[tostring(unit.id)].SyndromeTrack
  syndromeNames = checkSyndrome(unit.id,syndrome,'class')
  for _,name in pairs(syndromeNames) do
   if trackTable[name] then
    if trackTable[name].General then
     if trackTable[name].General.Side then
      local statusNumber = trackTable[name].General.Side.Number
      local callback = trackTable[name].General.Side.Callback
      Table = statusTable[statusNumber]
--[[
      sideTable.Current.Civ = tostring(Table.Civ)
      sideTable.Current.Pop = tostring(Table.Pop)
      sideTable.Current.Inv = tostring(Table.Inv)
      sideTable.Current.Trn = tostring(Table.Trn)
      sideTable.Current.Rgx = tostring(Table.Rgx)
      sideTable.Current.Rgy = tostring(Table.Rgy)
      sideTable.Current.Pid = tostring(Table.Pid)
      sideTable.Current.Pet = tostring(Table.Pet)
]]
      changeSide(unit,Table.Pet,Table.Type,-2,nil,nil,Table.Civ,Table.Pop,Table.Inv,Table.Trn,Table.Rgx,Table.Rgy,Table.Pid,nil)
      dfhack.timeout_active(callback,nil)
      dfhack.script_environment('persist-delay').environmentDelete(callback)
      statusTable[statusNumber] = nil
      trackTable.General.Side = nil
      changeSyndrome(unit.id,syndrome,'erase')
     end
    end
   end
  end
 end
end

function trackTransformation(unit,race,caste,dur,alter,syndrome,cb_id)
 -- Tracks changes to a units race and caste
 -- Make sure base/roses-init is loaded
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return "base/roses-init not loaded"
 end
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 -- Initialize the UnitTable for the unit id if necessary
 unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
 end
 if not unitTable[tostring(unit.id)].General.Transform then
  dfhack.script_environment('functions/tables').makeUnitTableTransform(unit.id)
 end
 -- Track!
 tTable = unitTable[tostring(unit.id)].General.Transform
 if alter == 'track' then
  if dur > 0 then
   tTable.Race.Current = tostring(race)
   tTable.Caste.Current = tostring(caste)
   statusTable = tTable.StatusEffects
   statusNumber = #statusTable._children
   statusTable[tostring(statusNumber+1)] = {}
   statusTable[tostring(statusNumber+1)].End = tostring(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[tostring(statusNumber+1)].Race = tostring(unit.race)
   statusTable[tostring(statusNumber+1)].Caste = tostring(unit.caste)
   statusTable[tostring(statusNumber+1)].Linked = 'False'
   if syndrome then
    trackTable = unitTable[tostring(unit.id)].SyndromeTrack
    statusTable[tostring(statusNumber+1)].Linked = 'True'
    if not trackTable[syndrome] then
     trackTable[syndrome] = {}
    end
    if not trackTable[syndrome]['Transform'] then
     trackTable[syndrome]['Transform'] = {}
    end
    trackTable[syndrome]['Transform'].Number = tostring(statusNumber+1)
    trackTable[syndrome]['Transform'].CallBack = tostring(cb_id)
   end
  else
   tTable.Race.Base = tostring(race)
   tTable.Caste.Base = tostring(caste)
   tTable.Race.Current = tostring(race)
   tTable.Caste.Current = tostring(caste)
  end
 elseif alter == 'end' then
  tTable.Race.Current = tostring(race)
  tTable.Caste.Current = tostring(caste)
  statusTable = tTable.StatusEffects
  for i = #statusTable._children,1,-1 do -- Remove any naturally ended effects
   if statusTable[i] then
    if tonumber(statusTable[i].End) <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     if statusTable[i].Linked == 'True' and syndrome then
      trackTable = unitTable[tostring(unit.id)].SyndromeTrack
      if trackTable[syndrome]['Transform'].Number == i then trackTable[syndrome]['Transform'] = nil end
     end
     statusTable[i] = nil
     changeSyndrome(unit.id,syndrome,'erase')
    end
   end
  end  
 elseif alter == 'terminate' then
  trackTable = unitTable[tostring(unit.id)].SyndromeTrack
  if syndrome then name = syndrome end
  if trackTable[name] then
   if trackTable[name]['Transform'] then
    statusTable = typeTable.StatusEffects
    local statusNumber = trackTable[name]['Transform'].Number
    local callback = trackTable[name]['Transform'].CallBack
    tTable.Race.Current = statusTable[statusNumber].Race
    tTable.Caste.Current = statusTable[statusNumber].Caste
    transform(unit.id,statusTable[statusNumber].Race,statusTable[statusNumber].Caste,0,nil,nil,nil)
    dfhack.timeout_active(callback,nil)
    dfhack.script_environment('persist-delay').environmentDelete(callback)
    statusTable[statusNumber] = nil
   end
   trackTable[name][strname] = nil
   changeSyndrome(unit.id,syndrome,'erase')
  end
 elseif alter == 'terminateClass' then
  trackTable = unitTable[tostring(unit.id)].SyndromeTrack
  syndromeNames = checkSyndrome(unit.id,syndrome,'class')
  for _,name in pairs(syndromeNames) do
   if trackTable[name] then
    if trackTable[name]['Transform'] then
     statusTable = typeTable.StatusEffects
     local statusNumber = trackTable[name]['Transform'].Number
     local callback = trackTable[name]['Transform'].CallBack
     tTable.Race.Current = statusTable[statusNumber].Race
     tTable.Caste.Current = statusTable[statusNumber].Caste
     transform(unit.id,statusTable[statusNumber].Race,statusTable[statusNumber].Caste,0,nil,nil,nil)
     dfhack.timeout_active(callback,nil)
     dfhack.script_environment('persist-delay').environmentDelete(callback)
     statusTable[statusNumber] = nil
    end
    trackTable[name][strname] = nil
    changeSyndrome(unit.id,syndrome,'erase')
   end
  end
 elseif alter == 'get' then
  return unit.race,unit.caste,tTable.Race.Base,tTable.Caste.Base
 end
end
---------------------------------------------------------------------------------------
-------------------------------- Make changes to the unit -----------------------------
---------------------------------------------------------------------------------------
---- Basic unit changes (Attribute, Counter, Resistance, Skill, Stat, Trait) ----
function changeAttribute(unit,attribute,change,dur,track,syndrome,cb_id)
 -- Add/Subtract given amount from declared attribute of a unit.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 dfhack.script_environment('functions/enhanced').enhanceCreature(unit)

 local int16 = 30000000
 local current = 0
 local value = 0
 if df.physical_attribute_type[attribute] then
  current = unit.body.physical_attrs[attribute].value
  value = math.floor(current + change)
 if value > int16 then
  change = int16 - current
  value = int16
 end
 if value < 0 then
  change = current
  value = 0
 end
  unit.body.physical_attrs[attribute].value = value
  current = unit.body.physical_attrs[attribute].value
 elseif df.mental_attribute_type[attribute] then
  current = unit.status.current_soul.mental_attrs[attribute].value
  value = math.floor(current+change)
 if value > int16 then
  change = int16 - current
  value = int16
 end
 if value < 0 then
  change = current
  value = 0
 end
  unit.status.current_soul.mental_attrs[attribute].value = value
  if value > unit.status.current_soul.mental_attrs[attribute].max_value then unit.status.current_soul.mental_attrs[attribute].max_value = value + 1 end
  current = unit.status.current_soul.mental_attrs[attribute].value
 else
  persistTable = require 'persist-table'
  if not persistTable.GlobalTable.roses then
   print('Invalid attribute id')
   return
  end
  if persistTable.GlobalTable.roses.BaseTable.CustomAttributes[attribute] then
   _,current = getUnit(unit,'Attributes',attribute)
   value = math.floor(current + change)
   if value > int16 then
    change = int16 - current
    value = int16
   end
   if value < 0 then
    change = current
    value = 0
   end
  else
   print('Invalid attribute id')
   return
  end
 end

 if syndrome and not track == 'end' then changeSyndrome(unit,syndrome,'add') end 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeAttribute',{unit.id,attribute,-change,0,'end',syndrome,nil}) end
 if track then trackAttribute(unit.id,attribute,current,change,value,dur,track,syndrome,cb_id) end
end

function changeCounter(unit,counter,change,dur)
 -- Add/Subtract given amount from declared counter of a unit.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 local value = 0
 local int16 = 3000000
 local current = 0
 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness' or counter == 'suffocation') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger_timer' or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' then
  location = unit.body
 elseif counter == 'reset' then
  unit.body.blood_count=unit.body.blood_max
  unit.counters.winded = 0
  unit.counters.stunned = 0
  unit.counters.suffocation = 0
  unit.counters.pain = 0
  unit.counters.nausea = 0
  unit.counters.dizziness = 0
  unit.counters2.paralysis = 0
  unit.counters2.numbness = 0
  unit.counters2.exhaustion = 0
  unit.counters2.fever = 0
  return  
 else
  print('Invalid counter token declared')
  print(counter)
  return
 end
 current = location[counter]

 value = math.floor(current + change)
 if value > int16 then
  change = int16 - current
  value = int16
 end
 if value < 0 then
  change = current
  value = 0
 end
 location[counter] = value

 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeCounter',{unit.id,counter,-change}) end
end

function changeResistance(unit,resistance,change,dur,track,syndrome,cb_id)
 -- Add/Subtract given amount from resistance of a unit.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
-- For if Toady ever implements actual in game resistances
 value = change
--
 if syndrome and not track == 'end' then changeSyndrome(unit,syndrome,'add') end 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeResistance',{unit.id,resistance,-change,0,'end',syndrome,nil}) end
 if track then trackResistance(unit.id,resistance,change,value,dur,track,syndrome,cb_id) end
end

function changeSkill(unit,skill,change,dur,track,syndrome,cb_id)
 -- Add/Subtract given amount from declared skill of a unit.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 utils = require 'utils'
 dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
 change = change or 0
 
 local skills = unit.status.current_soul.skills
 local skillid = df.job_skill[skill]
 local value = 0
 local found = false
 local current = 0
 if skillid then
  for i,x in ipairs(skills) do
   if x.id == skillid then
    found = true
    token = x
    current = token.rating
    break
   end
  end
  if not found then
   utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = 0},'id')
   skills = unit.status.current_soul.skills
   for i,x in ipairs(skills) do
    if x.id == skillid then
     found = true
     token = x
     current = token.rating
     break
    end
   end
  end
 else
  persistTable = require 'persist-table'
  if not persistTable.GlobalTable.roses then
   print('Invalid skill id')
   return
  end
  if persistTable.GlobalTable.roses.BaseTable.CustomSkills[skill] then
   _,current = getUnit(unit,'Skills',skill)
   token = {}
  else
   print('Invalid skill id')
   return
  end
 end
  
 value = math.floor(current+change)
 if value > 20 then
  change = 20 - current
  value = 20
 end
 if value < 0 then
  change = current
  value = 0
 end
 token.rating = value
 if syndrome and not track == 'end' then changeSyndrome(unit,syndrome,'add') end 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeSkill',{unit.id,skill,-change,0,'end',syndrome,nil}) end
 if track then trackSkill(unit.id,skill,current,change,value,dur,track,syndrome,cb_id) end
end

function changeSkillExperience(unit,skill,change,dur,track,syndrome,cb_id)
 -- Add/Subtract given amount from declared skill of a unit.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 utils = require 'utils'
 dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
 change = change or 0
 
 local skills = unit.status.current_soul.skills
 local skillid = df.job_skill[skill]
 local value = 0
 local found = false
 local current = 0
 if skillid then
  for i,x in ipairs(skills) do
   if x.id == skillid then
    found = true
    token = x
    current = token.experience
    break
   end
  end
  if not found then
   utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = 0},'id')
   skills = unit.status.current_soul.skills
   for i,x in ipairs(skills) do
    if x.id == skillid then
     found = true
     token = x
     current = token.experience
     break
    end
   end
  end
 else
  persistTable = require 'persist-table'
  if not persistTable.GlobalTable.roses then
   print('Invalid skill id')
   return
  end
  if persistTable.GlobalTable.roses.BaseTable.CustomSkills[skill] then
   _,current = getUnit(unit,'Skills',skill)
   token = {}
  else
   print('Invalid skill id')
   return
  end
 end
  
 value = math.floor(current+change)
 if value > 20 then
  change = 20 - current
  value = 20
 end
 if value < 0 then
  change = current
  value = 0
 end
 token.rating = value
 if syndrome and not track == 'end' then changeSyndrome(unit,syndrome,'add') end 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeSkill',{unit.id,skill,-change,0,'end',syndrome,nil}) end
 if track then trackSkill(unit.id,skill,current,change,value,dur,track,syndrome,cb_id) end
end

function changeStat(unit,stat,change,dur,track,syndrome,cb_id)
 -- Add/Subtract given amount from a stat of a unit.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
-- For if Toady ever implements actual in game stats
 value = change
--
 if syndrome and not track == 'end' then changeSyndrome(unit,syndrome,'add') end 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeStat',{unit.id,stat,-change,0,'end',syndrome,nil}) end
 if track then trackStat(unit.id,stat,change,value,dur,track,syndrome,cb_id) end
end

function changeTrait(unit,trait,change,dur,track,syndrome,cb_id)
 -- Add/Subtract given amount from declared trait of a unit.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 local value = 0
 local current = 0
 current = unit.status.current_soul.personality.traits[trait]
 value = math.floor(current + change)
 if value > 100 then
  change = 100 - current
  value = 100
 end
 if value < 0 then
  change = current
  value = 0
 end
 unit.status.current_soul.personality.traits[trait] = value

 if syndrome and not track == 'end' then changeSyndrome(unit,syndrome,'add') end 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeTrait',{unit.id,trait,-change,0,'end',syndrome,nil}) end
 if track then trackTrait(unit.id,trait,current,change,value,dur,track,syndrome,cb_id) end
end

-------------- Body based unit changes (Body, Life, Wound) ------------------
function changeBody(unit,part,changeType,change,dur)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 dfhack.script_environment('functions/enhanced').enhanceCreature(unit)

 if changeType == 'Temperature' then
  if change == 'Fire' then
   unit.body.components.body_part_status[part].on_fire = not unit.body.components.body_part_status[part].on_fire
   unit.flags3.body_temp_in_range = not unit.flags3.body_temp_in_range
   change = 'Fire'
  else
   unit.status2.body_part_temperature[part].whole=math.floor(tonumber(unit.status2.body_part_temperature[part].whole + change))
  end
 elseif changeType == 'Size' then
  unit.body.size_info.size_cur = math.floor(tonumber(unit.body.size_info.size_cur + change))
 elseif changeType == 'Area' then
  unit.body.size_info.area_cur = math.floor(tonumber(unit.body.size_info.area_cur + change))
 elseif changeType == 'Length' then
  unit.body.size_info.length_cur = math.floor(tonumber(unit.body.size_info.length_cur + change))
 end

 if dur > 0 then
  if change == 'Fire' then
   dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeBody',{unit.id,part,changeType,change,0})
  else
   dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeBody',{unit.id,part,changeType,-change,0})
  end
 end
end

function changeLife(unit,corpsepart,change,reference,regrow,syndrome,dur)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if tonumber(corpsepart) then corpsepart = df.item.find(tonumber(corpsepart)) end

 if df.item_corpsest:is_instance(corpsepart) then
  unitold=unit
  unit.flags2.slaughter = false
  unit.flags3.scuttle = false
  unit.flags1.dead = false
  unit.flags2.killed = false
  unit.flags3.ghostly = false
  changeCounter(unit,'reset')
  if change == 'Resurrect' then
   unit.flags1.zombie=false
   tissue = 'All'
   if reference then changeSide(unit,reference,'Civilian',dur) end
   if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay('functions/unit','removal',unit.id,'resurrected') end
   if syndrome then changeSyndrome(unit,'Resurrected Unit','add') end
  elseif change == 'Animate' then
   if reference then 
    changeSide(unit,reference,'Civilian',dur)
   else
    changeSide(unit,unitold,'Undead',dur)
   end
   unit.flags1.zombie=true
   tissue = 0
   if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay('functions/unit','removal',unit.id,'animated') end
   if syndrome then changeSyndrome(unit,'Animated Unit','add') end
  end
 elseif df.item_corpsepiecest:is_instance(corpsepart) then
  unitold = unit
  if change == 'Resurrect' then
   unit = create(unitold.pos,unitold.race,unitold.caste,unitold,'Corpse Piece',dur,'track','Resurrected Body Part')
   if reference then 
    changeSide(unit,reference,'Civilian',dur)
   else
    changeSide(unit,unitold,'Civilian',dur)
   end
   tissue = 'All'
  elseif change == 'Animate' then
   unit = create(unitold.pos,unitold.race,unitold.caste,unitold,'Corpse Piece',dur,'track','Animated Body Part')
   if reference then 
    changeSide(unit,reference,'Civilian',dur)
   else
    changeSide(unit,unitold,'Undead',dur)
   end
   unit.flags1.zombie=true
   tissue = 0
   if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay('functions/unit','removal',unit.id,'created') end
  end
 else
  print('Corpse item is neither of type item_corpsest or item_corpsepiecest')
  return
 end

 if syndrome then changeSyndrome(unit,syndrome,'add',dur) end

 for comp_type,_ in pairs(unit.body.components) do
  for comp_id,_ in pairs(unit.body.components[comp_type]) do
   if comp_type == 'body_part_status' or comp_type == 'layer_status' then
    for end_val,_ in pairs(unit.body.components[comp_type][comp_id]) do
     unit.body.components[comp_type][comp_id][end_val] = corpsepart.body.components[comp_type][comp_id][end_val]
    end
   else
    unit.body.components[comp_type][comp_id] = corpsepart.body.components[comp_type][comp_id]
   end
  end
 end
 dfhack.script_environment('functions/unit').changeWound(unit,'All',tissue,regrow)
 if not regrow then
  for i = #unitold.corpse_parts-1,0,-1 do
   if unitold.corpse_parts[i] == corpsepart.id then
    unitold.corpse_parts:erase(i)
    dfhack.script_environment('functions/item').removal(corpsepart)
    break
   end
  end
 end
end

function changeWound(unit,bp_id,gl_id,regrow)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local function falsify(x,check)
  x.on_fire = false
  x.organ_loss = false
  x.organ_damage = false
  x.muscle_loss = false
  x.muscle_damage = false
  x.bone_loss = false
  x.bone_damage = false
  x.skin_damage = false
  x.motor_nerve_severed = false
  x.sensory_nerve_severed = false
  if check then
   x.missing = false
   x.severed_or_jammed = false
  end
 end
 
 if bp_id == 'All' then
  v=unit.body.components.body_part_status
  unit.flags2.breathing_good = true
  unit.flags2.breathing_problem = false
  unit.flags2.vision_good = true
  unit.flags2.vision_damaged = false
  unit.flags2.vision_missing = false
  changeCounter(unit,'reset')
  if regrow then
   for i = #unit.corpse_parts-1,0,-1 do
    item = df.item.find(unitold.corpse_parts[i])
    unitold.corpse_parts:erase(i)
    dfhack.script_environment('functions/item').removal(item)   
   end
  end
  for i=0,#v-1,1 do
   if regrow and v[i].missing then
    falsify(v[i],true)
   elseif not v[i].missing then
    falsify(v[i],false)
   end
   unit.status2.limbs_stand_count = unit.status2.limbs_stand_max
   unit.status2.limbs_grasp_count = unit.status2.limbs_grasp_max
  end
  if gl_id == 'All' then
   v=unit.body.components
   for i=0,#v.layer_wound_area - 1,1 do
    v.layer_status[i].whole = 0
    v.layer_wound_area[i] = 0
    v.layer_cut_fraction[i] = 0
    v.layer_dent_fraction[i] = 0
    v.layer_effect_fraction[i] = 0
   end
  end
 elseif tonumber(bp_id) then
  if regrow then
   for i = #unit.corpse_parts-1,0,-1 do
    if unit.corpse_parts[i] == corpsepart.id then
     unitold.corpse_parts:erase(i)
     dfhack.script_environment('functions/item').removal(corpsepart)
     break
    end
   end
  end
  if regrow and unit.body.components.body_part_status[bp_id].missing then
   falsify(unit.body.components.body_part_status[bp_id],true)
  elseif not unit.body.components.body_part_status[bp_id].missing then
   falsify(unit.body.components.body_part_status[bp_id],false) 
  end
  if unit.body.body_plan.body_parts[bp_id].flags.STANCE then
   unit.status2.limbs_stand_count = unit.status2.limbs_stand_count + 1
   if unit.status2.limbs_stand_count > unit.status2.limbs_stand_max then unit.status2.limbs_stand_count = unit.status2.limbs_stand_max end
  end
  if unit.body.body_plan.body_parts[bp_id].flags.GRASP then
   unit.status2.limbs_grasp_count = unit.status2.limbs_grasp_count + 1
   if unit.status2.limbs_grasp_count > unit.status2.limbs_grasp_max then unit.status2.limbs_grasp_count = unit.status2.limbs_grasp_max end
  end
  if unit.body.body_plan.body_parts[bp_id].flags.SIGHT then
   unit.flags2.vision_good = true
   unit.flags2.vision_damaged = false
   unit.flags2.vision_missing = false  
  end
  if unit.body.body_plan.body_parts[bp_id].flags.BREATHE then
   unit.flags2.breathing_good = true
   unit.flags2.breathing_problem = false 
  end
  if gl_id == 'All' then
   layers = checkBodyPartGlobalLayers(unit,bp_id)
   for _,ly_id in pairs(layers) do
    unit.body.components.layer_status[ly_id].whole = 0
    unit.body.components.layer_wound_area[ly_id] = 0
    unit.body.components.layer_cut_fraction[ly_id] = 0
    unit.body.components.layer_dent_fraction[ly_id] = 0
    unit.body.components.layer_effect_fraction[ly_id] = 0
   end
  end
 end
end

-------------- Actoion based unit changes (Actoions and Interactions) ------------------
function changeAction(unit,action_type,timer)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if timer == 'clear' then
  actions = unit.actions
  for i = #actions-1,0,-1 do
   if actions[i]['type'] == df.unit_action_type[action_type] then
    unit.actions:erase(i)
   end
  end
 elseif timer == 'clearAll' then
  actions = unit.actions
  for i = #actions-1,0,-1 do
   unit.actions:erase(i)
  end
 else
  action = df.unit_action:new()
  action.id = unit.next_action_id
  unit.next_action_id = unit.next_action_id + 1 
  action.type = df.unit_action_type[action_type]
  data = action.data[string.lower(action_type)]
  for t,_ in pairs(data) do
   if t == 'timer' then
    data.timer = timer
    unit.actions:insert('#',action)
    return
   elseif t == 'timer1' then
    data.timer1 = timer
    data.timer2 = timer
    unit.actions:insert('#',action)
    return
   end
  end
 end
end

function changeInteraction(unit,interaction_id,timer,types)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if timer == 'clear' or timer == 'clearAll' then timer = 0 end
 if types == 'Innate' or types == 'Both' then
  for i,id in ipairs(unit.curse.own_interaction) do
   if id == interaction_id then
    unit.curse.own_interaction_delay[i] = timer
    break
   end
  end 
 end
 if types == 'Learned' or types == 'Both' then
  for i,id in ipairs(unit.curse.interaction_id) do
   if id == interaction_id then
    unit.curse.interaction_delay[i] = timer
    break
   end
  end  
 end
end

------------- Complex changes (Emotion, Flags, Side, Syndrome, Transform) ---------------
function changeEmotion(unit,thought,subthought,emotion,strength,severity,task,number,dur,syndrome,cb_id)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local emotions=unit.status.current_soul.personality.emotions
 if task == 'Add' then -- Taken from Putnam's add-thought.lua
  emotions:insert('#',{new=df.unit_personality.T_emotions,
                       type=emotion,
                       unk2=1,
                       strength=strength,
                       thought=thought,
                       subthought=subthought,
                       severity=severity,
                       --flags=0,
                       unk7=0,
                       year=df.global.cur_year,
                       year_tick=df.global.cur_year_tick
                      })
  local divider=df.emotion_type.attrs[emotion].divider
  if divider~=0 then
   unit.status.current_soul.personality.stress_level=unit.status.current_soul.personality.stress_level+math.ceil(severity/df.emotion_type.attrs[emotion].divider)
  end
 elseif task == 'Recent' then
  local list = checkEmotion(unit,emotion,thought)
  for i = #list-1,#list-1-number,-1 do
   emotions:erase(i)
  end
 elseif task == 'Random' then
  local list = checkEmotion(unit,emotion,thought)
  list = dfhack.script_environment('functions/misc').permute(list)
  for i = #list-1,#list-1-number,-1 do
   emotions:erase(i)
  end
 elseif task == 'All' then
  local list = checkEmotion(unit,emotion,thought)
  for i = #list-1,0,-1 do
   emotions:erase(i)
  end
 end
end

function changeFlag(unit,flag,clear) -- from modtools/create-unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 for _,k in ipairs(df.unit_flags1) do
  if flag == k then
   if clear then
    unit.flags1[k] = false
   else
    unit.flags1[k] = true
   end
  end
 end
 for _,k in ipairs(df.unit_flags2) do
  if flag == k then
   if clear then
    unit.flags2[k] = false
   else
    unit.flags2[k] = true
   end
  end
 end
 for _,k in ipairs(df.unit_flags3) do
  if flag == k then
   if clear then
    unit.flags3[k] = false
   else
    unit.flags3[k] = true
   end
  end
 end
end

function changeSide(unit,side,side_type,dur,track,syndrome,civ_id,pop_id,inv_id,trn,regx,regy,regp,cb_id)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 -- Check if using another unit as reference, or actual numbers
 if not civ_id then
  if tonumber(side) then
   side = df.unit.find(tonumber(side))
  end
  civ_id = side.civ_id
  pop_id = side.population_id
  inv_id = side.invasion_id
  trn = side.training_level
  regx = side.animal.population.region_x
  regy = side.animal.population.region_y
  regp = side.animal.population.population_idx
  side_id = side.id
 else
  side_id = tonumber(side)
 end

 save_civ = unit.civ_id
 save_pop = unit.population_id
 save_inv = unit.invasion_id
 save_id = unit.relationship_ids.Pet
 save_trn = unit.training_level
 save_regx = unit.animal.population.region_x
 save_regy = unit.animal.population.region_y
 save_regp = unit.animal.population.population_idx
 save_type = 'Return'

 if unit.flags1.active_invader then
  save_type = 'Invasion'
 end
 if save_id >= 0 then
  save_type = 'Pet'
 end
 if dfhack.units.isCitizen(unit) then
  save_type = 'Civilian'
 end
 
 unit.civ_id = civ_id
 unit.population_id = pop_id
 unit.invasion_id = inv_id
 unit.flags1.active_invader = false
 unit.animal.population.region_x = regx
 unit.animal.population.region_y = regy
 unit.animal.population.population_idx = regp
 unit.relationship_ids.Pet = -1
 unit.flags1.tame = false 
 if side_type == 'Civilian' then
-- Civilian Changes
 elseif side_type == 'Ally' then
  unit.population_id = -1
 elseif side_type == 'Friend' then
  unit.civ_id = -1
  unit.population_id = -1
 elseif side_type == 'Neutral' then
  unit.civ_id = -1
  unit.population_id = -1
  unit.animal.population.region_x = 1
  unit.animal.population.region_y = 1
  unit.animal.population.population_idx = 1
  unit.training_level = 9
 elseif side_type == 'Enemy' then
  unit.flags2.resident = true
  unit.civ_id = 1
  unit.population_id = -1
 elseif side_type == 'Pet' then
  unit.population_id = -1
  unit.flags1.tame = true
  unit.training_level = 7
  unit.relationship_ids.Pet = side_id
 elseif side_type == 'Domestic' then
  unit.population_id = -1
  unit.flags1.tame = true
  unit.training_level = 7
 elseif side_type == 'Invasion' then
  unit.invasion_id = inv_id
  unit.flags1.active_invader = true
 elseif side_type == 'Undead' then
  unit.civ_id = -1
  unit.population_id = -1
  unit.animal.population.region_x = 1
  unit.animal.population.region_y = 1
  unit.animal.population.population_idx = 1
  unit.training_level = 9
 end

 if syndrome then changeSyndrome(unit,syndrome,'add') end  
 if tonumber(dur) > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeSide',{unit.id,save_id,save_type,0,'end',syndrome,save_civ,save_pop,save_inv,save_trn,save_regx,save_regy,save_regp,nil}) end
 if track then trackSide(unit,save_civ,save_pop,save_inv,save_trn,save_regx,save_regy,save_regp,save_id,save_type,dur,track,syndrome,cb_id) end
 return unit.civ_id,unit.population_id
end

function changeSyndrome(unit,syndromes,change,dur) -- references modtools/add-syndrome with alterations
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(syndromes) ~= 'table' then syndromes = {syndromes} end
 unitID = tostring(unit.id)
 for _,syndrome in pairs(syndromes) do
  if change == 'add' then
   dfhack.run_command('modtools/add-syndrome -target '..unitID..' -syndrome '..syndrome)
  elseif change == 'erase' then
   dfhack.run_command('modtools/add-syndrome -target '..unitID..' -syndrome '..syndrome..' -erase')
  elseif change == 'eraseClass' then
  elseif change == 'terminate' then
   local persistTable = require 'persist-table'
   if not persistTable.GlobalTable.roses then
    return "base/roses-init not loaded"
   end
   local unitTable = persistTable.GlobalTable.roses.UnitTable
   if not unitTable[tostring(unit.id)] then
    dfhack.script_environment('functions/tables').makeUnitTable(unit.id)
   end
   local trackTable = unitTable[tostring(unit.id)].SyndromeTrack
   if trackTable[syndrome] then
    if trackTable[syndrome].Attribute then
     trackAttribute(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    end
    if trackTable[syndrome].Skill then
     trackSkill(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    end
    if trackTable[syndrome].Trait then
     trackTrait(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    end
    if trackTable[syndrome].Resistance then
     trackResistance(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    end
    if trackTable[syndrome].General then
     if trackTable[syndrome].General.Side then
      trackSide(unit.id,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,change,syndrome,nil)
     end
    end
    if unitTable[tostring(unit.id)].General.Summoned.Syndrome == syndrome then
     trackCreate(unit.id,nil,nil,change,syndrome,nil)
    end
   end
  elseif change == 'terminateClass' then
   if checkClassSyndrome(unit,syndrome) then
    trackAttribute(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    trackSkill(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    trackTrait(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    trackResistance(unit.id,nil,nil,nil,nil,nil,change,syndrome,nil)
    trackSide(unit.id,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,change,syndrome,nil)
    trackCreate(unit.id,nil,nil,change,syndrome,nil)
   end
  elseif change == 'alterDuration' then
   for _,syn in pairs(unit.syndromes.active) do
    if syndrome == df.global.world.raws.syndromes.all[syn.type].syn_name then
     current_ticks = syn.ticks
     new_ticks = current_ticks + dur
     if new_ticks < 0 then new_ticks = 0 end
     syn.ticks = new_ticks
     for _,symptom in pairs(syn.symptoms) do
      symptom.ticks = new_ticks
      for i,_ in pairs(symptom.target_ticks) do
       symptom.target_ticks[i] = new_ticks
      end
     end
    end
   end
  elseif change == 'alterDurationClass' then
   _,ids = checkSyndrome(unit,syndrome,'class')
   for _,id in pairs(ids) do
    for _,syn in pairs(unit.syndromes.active) do
     if id == df.global.world.raws.syndromes.all[syn.type].id then
      current_ticks = syn.ticks
      new_ticks = current_ticks + dur
      if new_ticks < 0 then new_ticks = 0 end
      syn.ticks = new_ticks
      for _,symptom in pairs(syn.symptoms) do
       symptom.ticks = new_ticks
       for i,_ in pairs(symptom.target_ticks) do
        symptom.target_ticks[i] = new_ticks
       end
      end
     end
    end
   end
  end
  if dur > 0 and change == 'add' then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeSyndrome',{unit.id,syndrome,'erase',0}) end
 end
end

function transform(unit,race,caste,dur,track,syndrome,cb_id)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 cur_race = unit.race
 cur_caste = unit.caste
 
 unit.enemy.normal_race = race
 unit.enemy.normal_caste = caste
 unit.enemy.were_race = race
 unit.enemy.were_caste = caste

 if syndrome and not track == 'end' then
  changeSyndrome(unit,syndrome,'add')
 end
 
 local inventoryItems = {}
 for _,item in ipairs(unit.inventory) do
  table.insert(inventoryItems, item:new());
 end

 dfhack.timeout(1, 'ticks', function()
  for _,item in ipairs(inventoryItems) do
   dfhack.items.moveToInventory(item.item, unit, item.mode, item.body_part_id)
   item:delete()
  end
  inventoryItems = {}
 end)
 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','transform',{unit.id,cur_race,cur_caste,0,'end',syndrome,nil}) end
 
 if track then trackTransformation(unit,race,caste,dur,track,syndrome,cb_id) end
end

----------------------- Misc changes (move, removal) -----------------------
function move(unit,location)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 pos = {}
 pos.x = tonumber(location.x) or tonumber(location[1]) or tonumber(unit.pos.x)
 pos.y = tonumber(location.y) or tonumber(location[2]) or tonumber(unit.pos.y)
 pos.z = tonumber(location.z) or tonumber(location[3]) or tonumber(unit.pos.z)
 if pos.x < 0 or pos.y < 0 or pos.z < 0 then
  return
 end
 local unitoccupancy = dfhack.maps.getTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
 local newoccupancy = dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16]
 if newoccupancy.unit then
  unit.flags1.on_ground=true
 end
 unit.pos.x = pos.x
 unit.pos.y = pos.y
 unit.pos.z = pos.z
 if not unit.flags1.on_ground then unitoccupancy.unit = false else unitoccupancy.unit_grounded = false end
end

function removal(unit,remType)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 
 if remType == 'created' then
-- Need to actually remove the unit
  unit.flags1.left = true
  trackCreate(unit,nil,nil,'end',nil,nil)
 elseif remType == 'animated' then
  unit.flags1.dead = true
 elseif remType == 'resurrected' then
  unit.flags1.dead = true
 end
end

---------------------------------------------------------------------------------------
----------------- Check unit for desired things (Return True/False) -------------------
---------------------------------------------------------------------------------------
function checkClass(unit,class) -- Returns true if either checkClassCreature or checkClassSyndrome is true
 check, x = checkClassCreature(unit,class)
 if check then return true,x end
 check, x = checkClassSyndrome(unit,class)
 if check then return true,x end
 return false,''
end

function checkClassCreature(unit,class) -- Returns true if unit has the CREATURE_CLASS class
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(class) ~= 'table' then class = {class} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local unitracename = unitraws.creature_id
 local castename = casteraws.caste_id
 local unitclasses = casteraws.creature_class
 for _,unitclass in ipairs(unitclasses) do
  for _,x in ipairs(class) do
   if x == unitclass.value then
    return  true, x
   end
  end
 end
 return false, ''
end

function checkClassSyndrome(unit,class) -- Returns true if the unit has the SYN_CLASS class
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(class) ~= 'table' then class = {class} end

 local actives = unit.syndromes.active
 local syndromes = df.global.world.raws.syndromes.all
 for _,x in ipairs(actives) do
  printall(syndromes[x.type])
  local synclass=syndromes[x.type].syn_class
  for _,y in ipairs(synclass) do
   for _,z in ipairs(class) do
    if z == y.value then
     return  true, z
    end
   end
  end
 end
 return false, ''
end

function checkCreatureRace(unit,creature) -- Returns true if unit is given creature (in format CREATURE:CASTE or CREATURE:ANY)
 local utils = require 'utils'
 local split = utils.split_string
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(creature) ~= 'table' then creature = {creature} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local unitracename = unitraws.creature_id
 local castename = casteraws.caste_id
 for _,x in ipairs(creature) do
  local xsplit = split(x,':')
  if xsplit[1] == unitracename and (xsplit[2] == castename or xsplit[2] == 'ANY') then
   return true
  end
 end
 return false
end

function checkCreatureSyndrome(unit,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(syndrome) ~= 'table' then syndrome = {syndrome} end
 
 local actives = unit.syndromes.active
 local syndromes = df.global.world.raws.syndromes.all
 for _,x in ipairs(actives) do
  for _,y in ipairs(syndrome) do
   if syndromes[x.type].syn_name == y then
    return true
   end
  end
 end
 return false
end

function checkCreatureToken(unit,token) -- Returns true if unit has the given token (e.g. AMPHIBIOUS, LARGE_PREDATOR, MEGABEAST, etc...)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(token) ~= 'table' then token = {token} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local flags1 = unitraws.flags
 local flags2 = casteraws.flags
 local tokens = {}
 for k,v in pairs(flags1) do
  tokens[k] = v
 end
 for k,v in pairs(flags2) do
  tokens[k] = v
 end

 for _,x in ipairs(token) do
  if tokens[x] then
   return true
  end
 end
 return false
end

function checkDistance(unit,location,distance) -- Returns true if unit is within certain distance from given position
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if tonumber(distance) then distance = {distance, distance, distance} end

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local x = location[1]
 local y = location[2]
 local z = location[3]
 local rx = distance[1]
 local ry = distance[2]
 local rz = distance[3]

 local xmin = x - rx
 local xmax = x + rx
 local ymin = y - ry
 local ymax = y + ry
 local zmin = z - rz
 local zmax = z + rz
 if xmin < 1 then xmin = 1 end
 if ymin < 1 then ymin = 1 end
 if zmin < 1 then zmin = 1 end
 if xmax > mapx then xmax = mapx-1 end
 if ymax > mapy then ymax = mapy-1 end
 if zmax > mapz then zmax = mapz-1 end
 if (unit.pos.x >= xmin and unit.pos.x <= xmax and unit.pos.y >= ymin and unit.pos.y <= ymax and unit.pos.z >= zmin and unit.pos.z <= zmax) then
  return true
 end
 return false
end

---------------------------------------------------------------------------------------
------------------- Get something from a unit for desired things ----------------------
---------------------------------------------------------------------------------------
function getUnit(unit,strType,strKind,initialize)
 -- Make sure we have the unit itself and not just the id.
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 base = 0
 change = 0
 class = 0
 item = 0
 total = 0
 syndrome = 0
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  typeTable = {}
  if strType == 'Attributes' then
   if df.physical_attribute_type[strkind] then
    if unit.curse.attr_change then
     total = (unit.body.physical_attrs[strKind].value+unit.curse.attr_change.phys_att_add[strKind])*unit.curse.attr_change.phys_att_perc[strKind]/100
     syndrome = total - unit.body.physical_attrs[strKind].value
    else
     total = unit.body.physical_attrs[strKind].value
    end
   elseif df.mental_attribute_type[strKind] then
    if unit.curse.attr_change then
     total = (unit.status.current_soul.mental_attrs[strKind].value+unit.curse.attr_change.ment_att_add[strKind])*unit.curse.attr_change.ment_att_perc[strKind]/100
     syndrome = total - unit.status.current_soul.mental_attrs[strKind].value
    else
     total = unit.status.current_soul.mental_attrs[strKind].value
    end
   end
  elseif strType == 'Resistances' then
   -- No Resistances in the base game
  elseif strType == 'Skills' then
   if df.job_skill[strKind] then
    total = dfhack.units.getNominalSkill(unit,df.job_skill[strKind])
   end
  elseif strType == 'Stats' then
   -- No Stat in the base game
  elseif strType == 'Traits' then
   typeTable = unitTable.Traits
   if unit.status.current_soul.personality.traits[strKind] then
    total = unit.status.current_soul.personality.traits[strKind]
   end
  end
  base = total - syndrome
 else
 -- Initialize the UnitTable for the unit id if necessary
  unitTable = persistTable.GlobalTable.roses.UnitTable
  if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit.id) end
  unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
  if strType == 'Attributes' then
   typeTable = unitTable.Attributes
   if df.physical_attribute_type[strKind] then
    if unit.curse.attr_change then
     total = (unit.body.physical_attrs[strKind].value+unit.curse.attr_change.phys_att_add[strKind])*unit.curse.attr_change.phys_att_perc[strKind]/100
     syndrome = total - unit.body.physical_attrs[strKind].value
    else
     total = unit.body.physical_attrs[strKind].value
    end
   elseif df.mental_attribute_type[strKind] then
    if unit.curse.attr_change then
     total = (unit.status.current_soul.mental_attrs[strKind].value+unit.curse.attr_change.ment_att_add[strKind])*unit.curse.attr_change.ment_att_perc[strKind]/100
     syndrome = total - unit.status.current_soul.mental_attrs[strKind].value
    else
     total = unit.status.current_soul.mental_attrs[strKind].value
    end
   elseif persistTable.GlobalTable.roses.BaseTable.CustomAttributes[strKind] then
    total = 'ADD'
   end
  elseif strType == 'Resistances' then
   typeTable = unitTable.Resistances
  elseif strType == 'Skills' then
   typeTable = unitTable.Skills
   if df.job_skill[strKind] then
    total = dfhack.units.getNominalSkill(unit,df.job_skill[strKind])
   else
    total = 'ADD'
   end
  elseif strType == 'Stats' then
   typeTable = unitTable.Stats
   total = 'ADD'
  elseif strType == 'Traits' then
   if unit.status.current_soul.personality.traits[strKind] then
    total = unit.status.current_soul.personality.traits[strKind]
   else
    total = 'ADD'
   end
  end
  --
  if not typeTable[strKind] then
--   dfhack.script_environment('functions/table').makeUnitTableSecondary(unit,strTable,strKind)
   if total == 'ADD' then total = 0 end
   base = total-syndrome
   change = change
   class = class
   item = item
   total = total
  else
   base = tonumber(typeTable[strKind].Base)
   change = tonumber(typeTable[strKind].Change)
   class = tonumber(typeTable[strKind].Class)
   item = tonumber(typeTable[strKind].Item)
   if total == 'ADD' then total = base + change + class + item end
   if initialize then base = total-syndrome-change-class-item end
  end
 end
 return total,base,change,class,item,syndrome
end

function getAttack(unit,attack_type) -- Returns an attack number for either a random attack or a given attack and the body part id associated with the attack
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if attack_type == 'Random' then
  local rand = dfhack.random.new()
  local totwght = 0
  local weights = {}
  weights[0] = 0
  local n = 1
  for _,attacks in pairs(unit.body.body_plan.attacks) do
   if attacks.flags.main then
    totwght = totwght + 100
    weights[n] = weights[n-1] + 100
   else
    totwght = totwght + 1
    weights[n] = weights[n-1] + 1
   end
   n = n + 1
  end 
  while not attack do
   pick = rand:random(totwght)
   for i = 1,n do
    if pick >= weights[i-1] and pick < weights[i] then
     attack = i-1
     break
    end
   end
   if unit.body.components.body_part_status[unit.body.body_plan.attacks[attack].body_part_idx[0]].missing then attack = nil end
  end
 else
  for i,attacks in pairs(unit.body.body_plan.attacks) do
   if attacks.name == attack then
    attack = i
    break
   end
  end
 end
 return attack, unit.body.body_plan.attacks[attack].body_part_idx[0]
end

function getBodyRandom(unit) -- Returns random body part number weighted for relative size of body parts
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local rand = dfhack.random.new()
 local totwght = 0
 local weights = {}
 weights[0] = 0
 local n = 1
 for _,targets in pairs(unit.body.body_plan.body_parts) do
  totwght = totwght + targets.relsize
  weights[n] = weights[n-1] + targets.relsize
  n = n + 1  
 end
 while not target do
  pick = rand:random(totwght)
  for i = 1,n do
   if pick >= weights[i-1] and pick < weights[i] then
    target = i-1
    break
   end
  end
  if unit.body.components.body_part_status[target].missing then target = nil end
 end
 return target
end

function getBodyCategory(unit,category) -- Returns a table of body part numbers for body parts that match given category
 -- Check a unit for body parts that match a given category(s)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(category) == 'string' then category = {category} end
 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(category) do
   if y.category == x and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function getBodyToken(unit,token) -- Returns a table of body part numbers for body parts that match given token
 -- Check a unit for body parts that match a given token(s).
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(token) == 'string' then token = {token} end

 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(token) do
   if y.token == x and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function getBodyFlag(unit,flag) -- Returns a table of body part numbers for body parts that match given flag
 -- Check a unit for body parts that match a given flag(s).
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(flag) == 'string' then flag = {flag} end

 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(flag) do
   if y.flags[x] and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function getBodyConnectedParts(unit,parts) -- Returns a table of body part numbers for body parts connected to the given body part (contains the given body part)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(parts) ~= 'table' then parts = {parts} end
 for i,x in pairs(parts) do
  for j,y in pairs(unit.body.body_plan.body_parts) do
   if y.con_part_id == x then
    table.insert(parts,j)
   end
  end
 end
 return parts
end

function getBodyPartGlobalLayers(unit,part)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 global_layers = {}
 for i,x in pairs(unit.body.body_plan.layer_part) do
  if x == part then table.insert(global_layers,i) end
 end
 return global_layers
end

function getBodyCorpseParts(unit) -- Returns a table with three components, Unit, Corpse, and Parts. Unit is the unit id of the unit. Corpse is the item id of the units item_corpsest (i.e. it's upper body). Parts is a table of the item id's of the units item_corpsepartsst (i.e. non upper body parts)
 if df.item_corpsest:is_instance(unit) then
  unit = df.unit.find(unit.unit_id)
 elseif df.item_corpsepiecest:is_instance(unit) then
  unit = df.unit.find(unit.unit_id)
 elseif tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 corpseparts = {Unit=unit.id,Corpse=false,Parts={}}
 for _,id in pairs(unit.corpse_parts) do
  item = df.item.find(id)
  if df.item_corpsest:is_instance(item) then
   corpseparts.Corpse = item.id
  elseif df.item_corpsepiecest:is_instance(item) then
   table.insert(corpseparts.Parts,item.id)
  end
 end
 return corpseparts
end

function getEmotion(unit,emotion,thought) -- Returns a table of emotion numbers that match given emotion/thought
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 thought = df.unit_thought_type[thought]
 emotion = df.emotion_type[emotion]
 local list = {}
 local l = 1
 local emotions=unit.status.current_soul.personality.emotions
 for i,x in pairs(emotions) do
  if thought then
   if thought == x.thought then
    if emotion then
     if emotion == x.emotion then
      list[l] = i
      l = l + 1
     end
    else
     list[l] = i
     l = l + 1
    end
   end
  elseif emotion then
   if emotion == x.emotion then
    list[l] = i
    l = l + 1
   end
  else
   list[l] = i
   l = l + 1   
  end
 end
 return list
end

function getSyndrome(unit,class,what) -- Returns table of syndrome names and ids matching given SYN_CLASS or SYN_NAME
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(class) ~= 'table' then class = {class} end

 local actives = unit.syndromes.active
 local syndromes = df.global.world.raws.syndromes.all
 local names = {}
 local ids = {}
 local ida = {}
 i = 0
 if what == 'class' then
  for j,x in pairs(actives) do
   local synclass=syndromes[x.type].syn_class
   for _,y in ipairs(synclass) do
    for _,z in ipairs(class) do
     if z == y.value then
      i = i + 1
      names[i] = syndromes[x.type].syn_name
      ids[i] = syndromes[x.type].id
      ida[i] = j
     end
    end
   end
  end
 elseif what == 'name' then
  for j,x in pairs(actives) do
   for _,y in ipairs(class) do
    if syndromes[x.type].syn_name == y then
     i = i + 1
     names[i] = y
     ids[i] = syndromes[x.type].id
     ida[i] = j
    end
   end
  end
 end
 return names, ids, ida
end

function getInventoryType(unit,item_type) -- Returns table of item ids for items of a given type
 -- Check a unit for any inventory items of a given type(s).
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(item_type) == 'string' then item_type = {item_type} end

 local items = {}
 local inventory = unit.inventory
 local a = 1
 for _,x in ipairs(inventory) do
  for _,y in ipairs(item_type) do
   if df.item_type[x.item:getType()] == y or y == 'ALL' then
    items[a] = x.item.id
    a = a + 1
   end
  end
 end
 return items
end

function getInventoryBodyPart(unit,bodyPart) -- Returns a table of item ids currently equipped to a given body part number
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(bodyPart) ~= 'table' then bodyPart = {bodyPart} end
 
 local items = {}
 local inventory = unit.inventory
 for _,x in ipairs(inventory) do
  for _.y in ipairs(bodyPart) do
   if x.body_part_id == y then
    items[#items+1] = x.item.id
   end
  end
 end
 return items
end

function getInventoryMode(unit,mode) -- Returns a table of item ids currently equipped with the given mode
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if type(mode) ~= 'table' then mode = {mode} end

 local items = {}
 local inventory = unit.inventory
 for _,x in ipairs(inventory) do
  for _.y in ipairs(mode) do
   if x.mode == y then
    items[#items+1] = x.item.id
   end
  end
 end
 return items
end

function getCounter(unit,counter) -- Returns one of the counter values of a unit (e.g. webbed, suffocation, pain, etc...)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' then
  location = unit.body
 else
  return 0
 end
 return location[counter] 
end

function getItemCorpse(caste)
 item_type = caste.misc.itemcorpse_itemtype
 item_subtype = caste.misc.itemcorpse_itemsubtype
 mat_type = caste.misc.itemcorpse_materialtype
 mat_index = caste.misc.itemcorpse_materialindex
 if caste.flags.ITEMCORPSE then
  if item_subtype >= 0 then
   item = dfhack.items.getSubtypeDef(item_type,item_subtype).name
  else
   item = string.lower(df.item_type[item_type])
  end
  mat = dfhack.matinfo.decode(mat_type,mat_index).material.state_name.Solid
  itemcorpse = mat..' '..item
 else
  itemcorpse = 'Corpse'
 end
 return itemcorpse
end
---------------------------------------------------------------------------------------
------ The following function just reference modtools/create-unit, this allows --------
------ me to change certain features of that code without altering it directly --------
---------------------------------------------------------------------------------------
function create(pos,creature,options)
 script = require 'gui.script'

 options = options or {}
 number = options.number or 1
 reference = options.reference or 'LOCAL'
 side = options.side or 'NEUTRAL'
 name = options.name
 dur = options.duration or 0
 track = options.track
 syndrome = options.syndrome
 equip = options.equipment
 skills = options.skills
 classes = options.classes

 persistTable = require 'persist-table'
 roses = persistTable.GlobalTable.roses
 -- Get location for unit placement (either x,y,z coordinates or a special position token)
 local location = {}
 if pos == 'EDGE' then
  -- So far let's just assume it's an x,y,z coordinate
  return
 else
  location.x = pos.x or pos[1]
  location.y = pos.y or pos[2]
  location.z = pos.z or pos[3]
 end

 -- Get creature's race and caste
 local race = nil
 local caste = nil
 if creature then
  race_token = split(creature,':')[1]
  caste_token = split(creature,':')[2]
  for i,x in ipairs(df.global.world.raws.creatures.all) do
   if x.creature_id == race_token then
    raceID = i
    race = x
    break
   end
  end
  if not race then
   print('Invalid race')
   return
  end
  if caste_token == 'RANDOM' then
   caste = dfhack.script_environment('functions/misc').permute(race.caste)[1]
   casteID = caste.id
   casteIDs = {}
   for i,x in pairs(race.caste) do
    casteIDs[i] = x.id
   end
  else
   for i,x in ipairs(race.caste) do
    if x.caste_id == caste_token then
     casteID= i
     caste = x
     break
    end
   end
  end
  if not caste then
   print('Invalid caste')
   return
  end
 else
  print('No unit declared')
  return
 end

 -- Get civ_id and group_id (actually do that per unit basis)
 local civ_id = -1
 local group_id = -1

 -- Start to create units
 function createMultiple()
  for n = 1, number do
   df.global.pause_state = true
   -- Create Unit
   local id
   if caste_token == 'RANDOM' then
    local index = math.random(0,#casteIDs-1)
    id = createUnit(raceID,casteIDs[index],location)
   else
    id = createUnit(raceID,casteID,location)
   end
   unit = df.unit.find(id)
   -- Assign ids (e.g. civ_id, population_id, etc...)
   civ_id, group_id = changeSide(unit,reference,side,0)
   if civ_id ~= -1 then
    createNemesis(unit,civ_id,group_id)
   end
   -- Assign unit a name
   if name then
    createName(unit,name)
   end
   -- Equip unit with items
   if equip then
    items,parts,modes = createEquipment(unit,equip)
    for i,item in pairs(items) do
     dfhack.script_environment('functions/item').equip(item,unit,parts[i],modes[i])
    end
   end
   -- Add skills to unit
   if skills then
    skill, level = createSkills(unit,skills)
    for i,x in pairs(skill) do
     changeSkill(unit,x,level[i])
    end
   end
   -- Assign a class to unit (based on the Class System)
   if classes then
    class, level = createClass(unit,classes)
    if class then dfhack.script_environment('functions/class').changeClass(class,level) end
   end
   -- Enhance unit (based on the Enhanced System)
   if roses then
    if safe_index(roses,'EnhancedCreatureTable') then
     dfhack.script_environment('functions/enhanced').enhanceCreature(unit)
    end
   end
   -- Add a syndrome, set up a duration, and track changes
   if syndrome then changeSyndrome(unit,syndrome,'add') end
   if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','removal',{unit.id,'created',nil}) end
   if track then trackCreate(unit,reference,dur,syndrome,cb_id) end
 
   df.global.pause_state = false
   script.sleep(5,'ticks')
  end
 end

 script.start(createMultiple)
 return
end

function createClass(unit,classes)
 local class = nil
 local level = nil

 utils = require 'utils'
 split = utils.split_string
 class = split(class,':')
 if class[1] == 'CIVILIZATION' then
  -- Classes avaiable to the civilization (using Civilization System) will go here
 elseif class[1] == 'ITEMS' then
  -- Classes based on equipped items will be chosen
 elseif class[1] == 'RANDOM' then
  -- A random class will be chosen
 elseif class[1] == 'TEMPLATE' then
  -- Classes from a template file will go here
 else
  -- A specific class will go here
 end

 return class, level
end

function createEquipment(unit,equip)
 utils = require 'utils'
 split = utils.split_string

 equipment = split(equip,':')
 items = {}
 parts = {}
 modes = {}

 entities = {}
 for _,x in pairs(df.global.world.raws.entities) do
  entities[x.code] = x
 end
 if entities[equipment[1]] then
  -- Item Options: Based off of entity raws
  -- Mat Options: Random
  raw = entities[equipment[1]]
  availItems = {weapon=raw.weapon_id,armor=raw.armor_id,helm=raw.helm_id,gloves=raw.gloves_id,
				shoes=raw.shoes_id,pants=raw.pants_id,shield=raw.shield_id,ammo=raw.ammo_id}
  value = tonumber(equipment[2])
 elseif equipment[1] == 'CIV' then
  -- Item Options: Items available to the units civ
  -- Mat Options: Materials available to the units civ
  civ = df.historic_entity.find(unit.civ_id)
  rsr = civ.resources
  mtl = civ.resources.metal
  availItems = {weapon=rsr.weapon_type,armor=rsr.armor_type,helm=rsr.helm_type,gloves=rsr.gloves_type,
                shoes=rsr.shoes_type,pants=rsr.pants_type,shield=rsr.ammo_type,ammo=rsr.ammo_type}
  availMats  = {weapon=mtl.weapon,armor=mtl.armor,ammo=mtl.ammo,leather=rsr.organic.leather,cloth=rsr.organic.fiber}
  value = tonumber(equipment[2])
 elseif equipment[1] == 'TEMPLATE' then
  -- Item Options: Items read from a template
  -- Mat Options: Materials read from a template
  template = equipment[2]
  persistTable = require 'persist-table'
  roses = persistTable.GlobalTable.roses
  if safe_index(roses,'EquipmentTemplates',template) then
   tmp = roses.EquipmentTemplates[template]
   availItems = {weapon=tmp.Weapons,armor=tmp.Armor,helm=tmp.Helms,gloves=tmp.Gloves,
                 shoes=tmp.Shoes,pants=tmp.Pants,shield=tmp.Shields,ammo=tmp.Ammo}
   availMats  = {weapon=tmp.WeaponMats,armor=tmp.ArmorMats,ammo=tmp.AmmoMats,leather=tmp.Leathers,cloth=tmp.Cloths}
   value = tmp.Value
  else
   return items, parts, modes
  end
 elseif equipment[1] == 'RANDOM' then
  -- Item Options: Random
  -- Mat Options: Random
  value = tonumber(equipment[2])
 elseif equipment[1] == 'UNIFORM' then -- Unsure if this will actually work
  -- Item Options: Items from a uniform
  -- Mat Options: Materials from a uniform
  value = 0
 end

 return items, parts, modes 
end

function createHistFig(unit,he,he_group) --Taken from modtools/create-unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 local hf=df.historical_figure:new()
 hf.id=df.global.hist_figure_next_id
 hf.race=unit.race
 hf.caste=unit.caste
 hf.profession = unit.profession
 hf.sex = unit.sex
 df.global.hist_figure_next_id=df.global.hist_figure_next_id+1
 hf.appeared_year = df.global.cur_year

 hf.born_year = unit.birth_year
 hf.born_seconds = unit.birth_time
 hf.curse_year = unit.curse_year
 hf.curse_seconds = unit.curse_time
 hf.birth_year_bias = unit.birth_year_bias
 hf.birth_time_bias = unit.birth_time_bias
 hf.old_year = unit.old_year
 hf.old_seconds = unit.old_time
 hf.died_year = -1
 hf.died_seconds = -1
 hf.name:assign(unit.name)
 hf.civ_id = unit.civ_id
 hf.population_id = unit.population_id
 hf.breed_id = -1
 hf.unit_id = unit.id

 df.global.world.history.figures:insert("#",hf)

 hf.info = df.historical_figure_info:new()
 hf.info.unk_14 = df.historical_figure_info.T_unk_14:new() -- hf state?
 unk_14.region_id = -1; unk_14.beast_id = -1; unk_14.unk_14 = 0
 hf.info.unk_14.unk_18 = -1; hf.info.unk_14.unk_1c = -1
 -- set values that seem related to state and do event
 --change_state(hf, dfg.ui.site_id, region_pos)

 --lets skip skills for now
 --local skills = df.historical_figure_info.T_skills:new() -- skills snap shot
 -- ...
 -- note that innate skills are automaticaly set by DF
 hf.info.skills = {new=true}


 he.histfig_ids:insert('#', hf.id)
 he.hist_figures:insert('#', hf)
 if he_group then
  he_group.histfig_ids:insert('#', hf.id)
  he_group.hist_figures:insert('#', hf)
  hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=he_group.id,link_strength=100})
 end
 unit.flags1.important_historical_figure = true
 unit.flags2.important_historical_figure = true
 unit.hist_figure_id = hf.id
 unit.hist_figure_id2 = hf.id

 hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=unit.civ_id,link_strength=100})

 --add entity event
 local hf_event_id=df.global.hist_event_next_id
 df.global.hist_event_next_id=df.global.hist_event_next_id+1
 df.global.world.history.events:insert("#",{new=df.history_event_add_hf_entity_linkst,year=unit.birth_year,
                                            seconds=unit.birth_time,id=hf_event_id,civ=hf.civ_id,histfig=hf.id,
                                            link_type=0})
 return hf
end

function createName(unit,name) -- Taken from modtools/create-unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 entityRaws = nil
 if name == 'Random' then
  -- Take a random entity and assign a name based off of that entity
  local index = math.random(0,#df.global.world.raws.entities-1)
  entityRaws = df.global.world.raws.entities[index]
 elseif name == 'Animal' then
  -- For now don't name animals
  return
 else
  -- Pick name from specific entity or from current civs entity 
  entities = {}
  for i,x in pairs(df.global.world.raws.entities) do
   entities[x.code] = x
  end
  if entities[name] then
   entityRaws = entities[name]
  elseif name == 'Civ' then
   if unit.civ_id ~= -1 then
    entityRaws = df.historical_entity.find(unit.civ_id).entity_raw
   else
    --No civ to assign name based on
    return
   end
  end
 end
 
 -- If an entity_raw was found for the declared name variable then use that
 -- Else assume the name variable represents an actual name (e.g. "John Robert Smith")
 if entityRaws then
  translation = entityRaws.translation
  translationIndex = -1
  for i,x in ipairs(df.global.world.raws.language.translations) do
   if x.name == translation then
    translationIndex = i
    break
   end
  end
  local language_word_table = entityRaws.symbols.symbols1[0]
  function randomWord()
   local index = math.random(0, #language_word_table.words[0] - 1)
   return index
  end
  local firstName = randomWord()
  local lastName1 = randomWord()
  local lastName2 = randomWord()
  local language = nil
  for _,lang in pairs(df.global.world.raws.language.translations) do
   if lang.name == entityRaws.translation then
    language = lang
   end
  end
  if language then
   first = language.words[firstName].value
  else
   first = df.language_word.find(language_word_table.words[0][firstName]).forms[language_word_table.parts[0][firstName]]
  end
  word0 = language_word_table.words[0][lastName1]
  part0 = language_word_table.parts[0][lastName1]
  word1 = language_word_table.words[0][lastName2]
  part1 = language_word_table.words[0][lastName2]
 else
  utils = require 'utils'
  split = utils.split_string
  nameTable = split(name,' ')
  first = nameTable[1] or ''
  word0 = nameTable[2] or ''
  part0 = 'Noun'
  word1 = nameTable[3] or ''
  part1 = 'Noun'
  translationIndex = -1
 end

 local name = unit.status.current_soul.name
 name.words[0] = word0
 name.parts_of_speech[0] = part0
 name.words[1] = word1
 name.parts_of_speech[1] = part1
 name.first_name = first
 name.has_name = true
 name.language = translationIndex
 unit.name:assign(name)
 if unit.hist_figure_id ~= -1 then
  local histfig = df.historical_figure.find(unit.hist_figure_id)
  histfig.name:assign(name)
 end
end

function createNemesis(unit,civ_id,group_id) -- Taken from modtools/create-unit
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 local function  allocateNewChunk(hist_entity)
  hist_entity.save_file_id=df.global.unit_chunk_next_id
  df.global.unit_chunk_next_id=df.global.unit_chunk_next_id+1
  hist_entity.next_member_idx=0
  print("allocating chunk:",hist_entity.save_file_id)
 end

 local function allocateIds(nemesis_record,hist_entity)
  if hist_entity.next_member_idx==100 then
    allocateNewChunk(hist_entity)
  end
  nemesis_record.save_file_id=hist_entity.save_file_id
  nemesis_record.member_idx=hist_entity.next_member_idx
  hist_entity.next_member_idx=hist_entity.next_member_idx+1
 end

 local id=df.global.nemesis_next_id
 local nem=df.nemesis_record:new()

 nem.id=id
 nem.unit_id=unit.id
 nem.unit=unit
 nem.flags:resize(4)
  --not sure about these flags...
 --[[
 nem.flags[4]=true
 nem.flags[5]=true
 nem.flags[6]=true
 nem.flags[7]=true
 nem.flags[8]=true
 nem.flags[9]=true
 --]]
 --[[for k=4,8 do
 nem.flags[k]=true
 end]]
 nem.unk10=-1
 nem.unk11=-1
 nem.unk12=-1
 df.global.world.nemesis.all:insert("#",nem)
 df.global.nemesis_next_id=id+1
 unit.general_refs:insert("#",{new=df.general_ref_is_nemesisst,nemesis_id=id})
 unit.flags1.important_historical_figure=true

 nem.save_file_id=-1

 local he=df.historical_entity.find(civ_id)
 he.nemesis_ids:insert("#",id)
 he.nemesis:insert("#",nem)
 local he_group
 if group_id and group_id~=-1 then
  he_group=df.historical_entity.find(group_id)
 end
 if he_group then
  he_group.nemesis_ids:insert("#",id)
  he_group.nemesis:insert("#",nem)
 end
 allocateIds(nem,he)
 nem.figure=createHistFig(unit,he,he_group)
end

function createSkills(unit,skills)
 local skill = {}
 local level = {}

 utils = require 'utils'
 split = utils.split_string
 table = split(skills,':')
 if table[1] == 'TEMPLATE' then
  -- Skills from a template file will go here
 elseif table[1] == 'ITEMS' then
  -- Skills based on equipped items will go here
 elseif table[1] == 'RANDOM' then
  -- Random skills will go here
 else
  -- A specific skill will go here
 end

 return skill, level
end

function createUnit(race_id,caste_id,location) -- Taken from modtools/create-unit
 local view_x = df.global.window_x
 local view_y = df.global.window_y
 local view_z = df.global.window_z

 local curViewscreen = dfhack.gui.getCurViewscreen()
 local dwarfmodeScreen = df.viewscreen_dwarfmodest:new()
 curViewscreen.child = dwarfmodeScreen
 dwarfmodeScreen.parent = curViewscreen
 local oldMode = df.global.ui.main.mode
 df.global.ui.main.mode = df.ui_sidebar_mode.LookAround

 local gui = require 'gui'

 if not dfhack.world.isArena() then
  --This is already populated in arena mode, so don't clear it then (#994)
  df.global.world.arena_spawn.race:resize(0)
  df.global.world.arena_spawn.race:insert(0,race_id)

  df.global.world.arena_spawn.caste:resize(0)
  df.global.world.arena_spawn.caste:insert(0,caste_id)

  df.global.world.arena_spawn.creature_cnt:resize(0)
  df.global.world.arena_spawn.creature_cnt:insert(0,0)
 end

 local old_gametype = df.global.gametype
 df.global.gametype = df.game_type.DWARF_ARENA
 gui.simulateInput(dwarfmodeScreen, 'D_LOOK_ARENA_CREATURE')

 -- move cursor to location instead of moving unit later, corrects issue of missing mapdata when moving the created unit.
 if location then
  df.global.cursor.x = tonumber(location[1])
  df.global.cursor.y = tonumber(location[2])
  df.global.cursor.z = tonumber(location[3])
 end

 local spawnScreen = dfhack.gui.getCurViewscreen()
 if dfhack.world.isArena() then
  -- Just modify the current screen in arena mode (#994)
  spawnScreen.race:insert(0, race_id)
  spawnScreen.caste:insert(0, caste_id)
 end
 gui.simulateInput(spawnScreen, 'SELECT')

 df.global.gametype = old_gametype

 curViewscreen.child = nil
 dwarfmodeScreen:delete()
 df.global.ui.main.mode = oldMode

 local id = df.global.unit_next_id-1
 df.global.window_x = view_x
 df.global.window_y = view_y
 df.global.window_z = view_z
 return id
end

---------------------------------------------------------------------------------------

function makeProjectile(unit,velocity) -- Turns a unit into a projectile with a given velocity [vx, vy, vz]
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end

 local vx = velocity[1]
 local vy = velocity[2]
 local vz = velocity[3]
 local count=0
 local l = df.global.world.proj_list
 local lastlist=l
 l=l.next
 while l do
  count=count+1
  if l.next==nil then
   lastlist=l
  end
  l = l.next
 end

 newlist = df.proj_list_link:new()
 lastlist.next=newlist
 newlist.prev=lastlist
 proj = df.proj_unitst:new()
 newlist.item=proj
 proj.link=newlist
 proj.id=df.global.proj_next_id
 df.global.proj_next_id=df.global.proj_next_id+1
 proj.unit=unit
 proj.origin_pos.x=unit.pos.x
 proj.origin_pos.y=unit.pos.y
 proj.origin_pos.z=unit.pos.z
 proj.prev_pos.x=unit.pos.x
 proj.prev_pos.y=unit.pos.y
 proj.prev_pos.z=unit.pos.z
 proj.cur_pos.x=unit.pos.x
 proj.cur_pos.y=unit.pos.y
 proj.cur_pos.z=unit.pos.z
 proj.flags.no_impact_destroy=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.speed_x=vx
 proj.speed_y=vy
 proj.speed_z=vz
 unitoccupancy = dfhack.maps.ensureTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
 if not unit.flags1.on_ground then
  unitoccupancy.unit = false
 else
  unitoccupancy.unit_grounded = false
 end
 unit.flags1.projectile=true
 unit.flags1.on_ground=false
end

---------------------------------------------------------------------------------------

function findUnit(search)
 local persistTable = require 'persist-table'
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local unitList = df.global.world.units.active
 local targetList = {}
 local target = nil
 local n = 0
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   n = 1
   targetList = unitList
  elseif secondary == 'POPULATION' then
   for i,x in pairs(unitList) do
    if dfhack.units.isCitizen(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'CIVILIZATION' then
   for i,x in pairs(unitList) do
    if x.civ_id == df.global.ui.civ_id then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'INVADER' then
   for i,x in pairs(unitList) do
    if x.invasion_id >= 0 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'MALE' then
   for i,x in pairs(unitList) do
    if x.sex == 0 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'FEMALE' then
   for i,x in pairs(unitList) do
    if x.sex == 1 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'PROFESSION' then
   for i,x in pairs(unitList) do
    if tertiary == dfhack.units.getProfessionName(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'CLASS' then
   for i,x in pairs(unitList) do
    if persistTable.GlobalTable.roses.UnitTable[x.id] then
     if persistTable.GlobalTable.roses.UnitTable[x.id].Classes.Current.Name == tertiary then
      n = n + 1
      targetList[n] = x
     end
    end
   end
  elseif secondary == 'SKILL' then
   for i,x in pairs(unitList) do
    if dfhack.units.getEffectiveSkill(x,df.job_skill[tertiary]) >= tonumber(quaternary) then
     n = n + 1
     targetList[n] = x
    end
   end
  else
   for i,x in pairs(unitList) do
    creature = df.global.world.raws.creatures.all[x.race].creature_id
    caste = df.global.world.raws.creatures.all[x.race].caste[x.caste].caste_id
    if secondary == creature then
     if tertiary == caste or tertiary == 'NONE' then
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
  return {}
 end
end
