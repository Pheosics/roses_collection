--attack based functions, version 42.06a
usages = {}

--=                     Attack Functions
usages[#usages+1] = [===[

addAttack(unit,defenderID,attackBodyPartID,targetBodyPartID,attackItemID,attackID,accuracy,velocity,delay)
  Purpose: Add an attack action to the unit
  Calls: None
  Inputs:
        unit:                   Attacker unit ID or unit struct
        defenderID:             Defender unit ID
        attackBodyPartID:       Attacker's attacking body part ID (if using a body part attack)
        targetBodyPartID:       Defender's targeted body part ID
        attackItemID:           Attacker's attacking item ID (if using an item attack)
        attackID:               Attack ID number (found in unit.body.body_plan.attacks or item.subtype.attacks)
        accuracy:               Percent hit chance of attack
        velocity:               Velocity of attack
        delay:                  Time (in ticks) until attack is executed
  Returns: NA

getAttack(unit,category,type)
  Purpose: Get attack details of equipped weapons and/or body parts
  Calls: getAttackItem | getAttackUnit | unit.getInventoryType | unit.getAttack | item.getAttack
  Inputs:
        unit:                   Unit ID or unit struct
        category:               Category of attack (Valid values: Equipped, Created, or BodyPart)
        type:                   RAW Token of attack (e.g. PUNCH) (Special Value: Random)
  Returns: Table - { material momentum contact penetration sharpness item body_part }

getDefense(unit,category,type)
  Purpose: Get layer, tissue, and material information for a given body part
  Calls: checkCoverage | unit.getBodyRandom | unit.getBodyCategory | unit.getBodyToken | unit.getBodyType
  Inputs:
        unit:                   Unit ID or unit struct
        category:               Category of body part to check for (Valid values: Random, Category, Token, or Type)
        type:                   RAW token for above category (e.g. EYES, REYE, and SIGHT would all check eyes)
  Returns: Table - { layers tissues items materials body_part }

computeAttackValues(attacker,defender,attackCategory,attackType,defenseCategory,defenseType)
  Purpose:
  Calls: computeAttackValuesItems | computeAttackValuesLayers
  Inputs:
        attacker:               Attacking unit ID or unit struct
        defender:               Defending unit ID or unit struct
        attackCategory:         Category of attack (see getAttack for more information)
        attackType:             Type of attack (see getAttack for more information)
        defenseCategory:        Category of defense (see getDefense for more information)
        defenseType:            Type of defense (see getDefense for more information)
  Return: Numbers - momentum_deduction1, momentum_deduction2

NOTE: All computed values are based on Urist DaVinci's work.
]===]

function addAttack(unit,defender_id,body_id,target_id,item_id,attack_id,hitchance,velocity,delay,flags)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 action = df.unit_action:new()
 action.id = unit.next_action_id
 unit.next_action_id = unit.next_action_id + 1
 action.type = 1
 attack_action = action.data.attack
 attack_action.target_unit_id      = math.floor(tonumber(defender_id))
 attack_action.attack_item_id      = math.floor(tonumber(item_id))   or -1
 attack_action.target_body_part_id = math.floor(tonumber(target_id)) or -1
 attack_action.attack_body_part_id = math.floor(tonumber(body_id))   or -1
 attack_action.attack_velocity     = math.floor(tonumber(velocity))  or 0
 attack_action.attack_id           = math.floor(tonumber(attack_id)) or 0
 attack_action.attack_accuracy     = math.floor(tonumber(hitchance)) or 0
 attack_action.timer1              = math.floor(tonumber(delay))     or 0
 attack_action.timer2              = math.floor(tonumber(delay))     or 0
 if flags then
  for _,flag in ipairs(flags) do
   attack_action[string.lower(flag)] = true
  end
 end
 -- Unknown values
 attack_action.unk_28 = 1
 attack_action.unk_2c = 1
 attack_action.unk_38 = 1
 for i,x in pairs(attack_action.unk_4) do
  attack_action.unk_4[i] = 7
 end
 attack_action.unk_4.wrestle_type = -1
 unit.actions:insert('#',action)
end

function getAttack(unit,main_type,sub_type)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 local attack = {}
 if main_type == 'Equipped' then
  item = dfhack.script_environment('functions/unit').getInventoryType(unit,'WEAPON')[1]
  attack_id = dfhack.script_environment('functions/item').getAttack(item,sub_type)
  momentum,weight,material,velocity,item = getAttackItem(unit,item,attack_id)
  attack.item = item
  attack.material = material
  attack.momentum = momentum
  attack.contact = item.subtype.attacks[attack_id].contact
  attack.penetration = item.subtype.attacks[attack_id].penetration
  attack.sharpness = item.sharpness
 elseif main_type == 'Created' then
-- Created weapons not yet implemented
 elseif main_type == 'BodyPart' then
  attack_id, bp_id = dfhack.script_environment('functions/unit').getAttack(unit,sub_type)
  momentum,weight,material,velocity,body_part = getAttackUnit(unit,bp_id,attack_id)
  attack.body_part = body_part
  attack.material = material
  attack.momentum = momentum
  attack.contact = unit.body.body_plan.attacks[attack_id].contact_perc
  attack.penetration = unit.body.body_plan.attacks[attack_id].penetration_perc
  attack.sharpness = 1
 end
 return attack
end 

function getAttackItem(unit,item,attack)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if not unit or not item then return end
 
 material = dfhack.matinfo.decode(item.mat_type,item.mat_index).material

 weight = math.floor(item.subtype.size*material.solid_density/100000)
 weight_fraction = item.subtype.size*material.solid_density*10 - weight*1000000
 actweight=weight*1000 + weight_fraction/1000
 effweight=unit.body.size_info.size_cur/100+weight*100 + weight_fraction/10000

 vel_mod = item.subtype.attacks[attack].velocity_mult
 velocity = unit.body.size_info.size_base * dfhack.units.getPhysicalAttrValue(unit,0) * vel_mod/1000/effweight/1000
 if velocity == 0 then velocity = 1 end

 momentum = velocity*actweight/1000 + 1

 return momentum,weight,material,velocity,item
end

function getAttackUnit(unit,bp_id,attack)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 body_part = unit.body.body_plan.body_parts[bp_id]

 vel_mod = unit.body.body_plan.attacks[attack].velocity_modifier
 velocity = 100*dfhack.units.getPhysicalAttrValue(unit,0)/1000*vel_mod/1000
 if velocity == 0 then velocity = 1 end

 attacker_race = df.global.world.raws.creatures.all[unit.race]
 layerdata = body_part.layers[#body_part.layers-1]
 tisdata=attacker_race.tissue[layerdata.tissue_id]
 material = dfhack.matinfo.decode(tisdata.mat_type,tisdata.mat_index).material

 partsize = math.floor(unit.body.size_info.size_cur * body_part.relsize / unit.body.body_plan.total_relsize)
 weight = math.floor(partsize * material.solid_density/100)

 momentum = velocity*weight/1000 + 1

 return momentum,weight,material,velocity,body_part
end

function getDefense(unit,main_type,sub_type)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if main_type == 'Random' then
  bp_id = dfhack.script_environment('functions/unit').getBodyRandom(unit)
 elseif main_type == 'Category' then
  bp_id = dfhack.script_environment('functions/unit').getBodyCategory(unit,sub_type)[1]
 elseif main_type == 'Token' then
  bp_id = dfhack.script_environment('functions/unit').getBodyToken(unit,sub_type)[1]
 elseif main_type == 'Type' then
  bp_id = dfhack.script_environment('functions/unit').getBodyType(unit,sub_type)[1]
 end
 local target = {}
 target.layers = {}
 target.tissues = {}
 target.items = {}
 target.materials = {}
 target.body_part = unit.body.body_plan.body_parts[bp_id]
 for i,x in pairs(target.body_part.layers) do
  table.insert(target.layers,x)
  local defender_race = df.global.world.raws.creatures.all[unit.race]
  local tisdata=defender_race.tissue[x.tissue_id]
  table.insert(target.tissues,tisdata)
 end
 for i,x in pairs(unit.inventory) do
  if x.mode == 2 then
   if checkCoverage(unit,bp_id,x) then
    table.insert(target.items,x.item)
    table.insert(target.materials,dfhack.matinfo.decode(x.item).material)
   end
  end
 end
 return target
end

function checkCoverage(unit,bp_id,inventory_item)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 covers = false
 item = inventory_item.item
 itype = df.item_type[item:getType()]
 base_bp_id = inventory_item.body_part_id
 if base_bp_id == bp_id then
  covers = true
  return covers
 end
 step = 0
 connect = {base_bp_id}
 if itype == 'ARMOR' then
  ubstep = item.subtype.ubstep
  while step < ubstep do
   temp = {}
   for i,x in pairs(unit.body.body_plan.body_parts) do
    for j,y in pairs(connect) do
     if x.con_part_id == y and not x.flags.LOWERBODY and not x.flags.HEAD then
      if i == bp_id then
       covers = true
       return covers
      else
       table.insert(temp,i)
      end
     end
    end
   end
   connect = temp
   step = step + 1
  end
  step = 0
  for i,x in pairs(unit.body.body_plan.body_parts) do
   if x.flags.LOWERBODY then
    base_bp_id = i
    break
   end
  end
  if base_bp_id == bp_id then
   covers = true
   return covers
  end
  connect = {base_bp_id}
  lbstep = item.subtype.lbstep
  while step < lbstep do
   temp = {}
   for i,x in pairs(unit.body.body_plan.body_parts) do
    for j,y in pairs(connect) do
     if x.con_part_id == y and not x.flags.UPPERBODY and not x.flags.STANCE then
      if i == bp_id then
       covers = true
       return covers
      else
       table.insert(temp,i)
      end
     end
    end
   end
   connect = temp
   step = step + 1
  end
 elseif itype == 'HELM' then
  return covers
 elseif itype == 'GLOVES' then
  upstep = item.subtype.upstep
  while step < upstep do
   temp = {}
   for i,x in pairs(unit.body.body_plan.body_parts) do
    for j,y in pairs(connect) do
     if x.con_part_id == y and not x.flags.UPPERBODY and not x.flags.LOWERBODY then
      if i == bp_id then
       covers = true
       return covers
      else
       table.insert(temp,i)
      end
     end
    end
   end
   connect = temp
   step = step + 1
  end
 elseif itype == 'SHOES' then
  upstep = item.subtype.upstep
  while step < upstep do
   temp = {}
   for i,x in pairs(unit.body.body_plan.body_parts) do
    for j,y in pairs(connect) do
     if x.con_part_id == y and not x.flags.UPPERBODY and not x.flags.LOWERBODY then
      if i == bp_id then
       covers = true
       return covers
      else
       table.insert(temp,i)
      end
     end
    end
   end
   connect = temp
   step = step + 1
  end
 elseif itype == 'PANTS' then
  lbstep = item.subtype.lbstep
  while step < lbstep do
   temp = {}
   for i,x in pairs(unit.body.body_plan.body_parts) do
    for j,y in pairs(connect) do
     if x.con_part_id == y and not x.flags.UPPERBODY and not x.flags.STANCE then
      if i == bp_id then
       covers = true
       return covers
      else
       table.insert(temp,i)
      end
     end
    end
   end
   connect = temp
   step = step + 1
  end
 end
 return covers
end

function computeAttackValues(attacker,defender,attack_type,attack_subtype,defense_type,defense_subtype)
 if tonumber(attacker) then attacker = df.unit.find(tonumber(attacker)) end
 if tonumber(defender) then defender = df.unit.find(tonumber(defender)) end
 if not attacker or not defender then return end
 
 target = getDefense(defender,defense_type,defense_subtype)
 attack = getAttack(attacker,attack_type,attack_subtype)
 if target.items then momentum_deduction1 = computeAttackValuesItems(attacker,defender,attack,target) end
 if target.layers then momentum_deduction2 = computeAttackValuesLayers(attacker,defender,attack,target) end
 return momentum_deduction1,momentum_deduction2
end

function computeAttackValuesItems(attacker,defender,attack,target)
 ashyld = attack.material.strength.yield.SHEAR
 ashfrc = attack.material.strength.fracture.SHEAR
 for i,x in pairs(target.items) do
  factors = 1
  tshyld = target.materials[i].strength.yield.SHEAR
  tshfrc = target.materials[i].strength.fracture.SHEAR
  tshstr = target.materials[i].strength.strain_at_yield.SHEAR
  timyld = target.materials[i].strength.yield.IMPACT
  timfrc = target.materials[i].strength.fracture.IMPACT
  timstr = target.materials[i].strength.strain_at_yield.IMPACT
  part_size = defender.body.size_info.size_base*target.body_part.relsize/defender.body.body_plan.total_relsize
  coverage = x.subtype.props.coverage
  layer_size = x.subtype.props.layer_size
  step_factor = 1.00
  itype = df.item_type[x:getType()]
  if itype == 'ARMOR' then
   step_factor = step_factor + 0.25*x.subtype.ubstep + 0.25*x.subtype.lbstep
  elseif itype == 'HELM' then
   step_factor = step_factor
  elseif itype == 'GLOVES' then
   step_factor = step_factor + 0.25*x.subtype.upstep
  elseif itype == 'SHOES' then
   step_factor = step_factor + 0.25*x.subtype.upstep
  elseif itype == 'PANTS' then
   step_factor = step_factor + 0.25*x.subtype.lbstep
  end
  step_factor = math.max(3,step_factor)
  tvol = part_size*coverage*layer_size*step_factor/100/100
  if attack.item then contact_area = attack.contact end
  if attack.body_part then contact_area = (attacker.body.size_info.size_base*attack.body_part.relsize/attacker.body.body_plan.total_relsize ^ 0.666) * attack.contact/100 end
  if contact_area < tvol then tvol = contact_area end
  shear_cost_1 = tshyld*5000*factors/ashyld/attack.sharpness/1000
  shear_cost_2 = tshfrc*5000*factors/ashfrc/attack.sharpness/1000
  shear_cost_3 = tshfrc*tvol*5000*factors/ashfrc/attack.sharpness/1000
  blunt_cost_1 = tvol*timyld*factors/100/10/500
  blunt_cost_2 = tvol*(timfrc-timyld)*factors/100/10/500
  blunt_cost_3 = tvol*(timfrc-timyld)*factors/100/10/500
  if timstr >= 50000 or x.subtype.props.flags.STRUCTURAL_ELASTICITY_WOVEN_THREAD==true or 
                        x.subtype.props.flags.STRUCTURAL_ELASTICITY_CHAIN_METAL==true or 
                        x.subtype.props.flags.STRUCTURAL_ELASTICITY_CHAIN_ALL==true then
   blunt_cost_2 = 0
   blunt_cost_3 = 0
  end
  momentum_deduction = math.max(shear_cost_1,blunt_cost_1)/10
 end
 return momentum_deduction
end

function computeAttackValuesLayers(attacker,defender,attack,target)
 ashyld = attack.material.strength.yield.SHEAR
 ashfrc = attack.material.strength.fracture.SHEAR
 for i,x in pairs(target.layers) do
  factors = 1
  material=dfhack.matinfo.decode(target.tissues[i].mat_type,target.tissues[i].mat_index).material
  tshyld = material.strength.yield.SHEAR
  tshfrc = material.strength.fracture.SHEAR
  tshstr = material.strength.strain_at_yield.SHEAR
  timyld = material.strength.yield.IMPACT
  timfrc = material.strength.fracture.IMPACT
  timstr = material.strength.strain_at_yield.IMPACT
  part_size = defender.body.size_info.size_base*target.body_part.relsize/defender.body.body_plan.total_relsize
  part_thick = (part_size * 10000) ^ 0.333
  modpartfraction= x.part_fraction
  if target.tissues[i].flags.THICKENS_ON_ENERGY_STORAGE == true then
   modpartfraction = defender.counters2.stored_fat * modpartfraction / 2500 / 100
  end
  if target.tissues[i].flags.THICKENS_ON_STRENGTH == true then
   modpartfraction = dfhack.units.getPhysicalAttrValue(defender,0) * modpartfraction / 1000
  end
  layervolume = part_size * modpartfraction / target.body_part.fraction_total
  layerthick = part_thick * modpartfraction / target.body_part.fraction_total
  if layervolume == 0 then
   layervolume = 1
  end
  if layerthick == 0 then
   layerthick = 1
  end
  tvol = layervolume
  if attack.item then contact_area = attack.contact end
  if attack.body_part then contact_area = (attacker.body.size_info.size_base*attack.body_part.relsize/attacker.body.body_plan.total_relsize ^ 0.666) * attack.contact/100 end
  if contact_area < part_size^0.66 then tvol = tvol*(contact_area/(part_size^0.66)) end
  shear_cost_1 = tshyld*5000*factors/ashyld/attack.sharpness/1000
  shear_cost_2 = tshfrc*5000*factors/ashfrc/attack.sharpness/1000
  shear_cost_3 = tshfrc*tvol*5000*factors/ashfrc/attack.sharpness/1000
  blunt_cost_1 = tvol*timyld*factors/100/10/500
  blunt_cost_2 = tvol*(timfrc-timyld)*factors/100/10/500
  blunt_cost_3 = tvol*(timfrc-timyld)*factors/100/10/500
  if timstr >= 50000 then
   blunt_cost_2 = 0
   blunt_cost_3 = 0
  end
  momentum_deduction = math.max(shear_cost_1,blunt_cost_1)/10
 end
 return momentum_deduction
end
