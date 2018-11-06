--= Enhanced Item Triggers
if itemCheck then
 if args.verbose then print('Setting up Enhanced Item Triggers') end
 for _,itemToken in ipairs(persistTable.GlobalTable.roses.EnhancedItemTable._children) do
  item = persistTable.GlobalTable.roses.EnhancedItemTable[itemToken]
  -- trigger/action triggers
  if item.OnEquip then
   if verbose then print('trigger/action -actionType Equip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Equip ]') end
   dfhack.run_command('trigger/action -actionType Equip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Equip ]')
   if verbose then print('trigger/action -actionType Unequip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Unequip ]') end
   dfhack.run_command('trigger/action -actionType Unequip -item '..itemToken..' -command [ enhanced/item-action -unit UNIT_ID -item ITEM_ID -action Unequip ]')
  end
  if item.OnAttack then
   if verbose then print('trigger/action -actionType Attack -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack ]') end
   dfhack.run_command('trigger/action -actionType Attack -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack ]')
  end
  if item.OnBlock then
   if verbose then print('trigger/action -actionType Block -item '..itemToken..' -command [ enhanced/item-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action Block ]') end
   dfhack.run_command('trigger/action -actionType Block -item '..itemToken..' -command [ enhanced/item-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action Block ]')
  end
  if item.OnDodge then
   if verbose then print('trigger/action -actionType Dodge -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Dodge ]') end
   dfhack.run_command('trigger/action -actionType Dodge -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Dodge ]')
  end
  if item.OnParry then
   if verbose then print('trigger/action -actionType Parry -item '..itemToken..' -command [ enhanced/item-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry ]') end
   dfhack.run_command('trigger/action -actionType Parry -item '..itemToken..' -command [ enhanced/item-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry ]')
  end
  if item.OnMove then
   if verbose then print('trigger/action -actionType Move -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Move ]') end
   dfhack.run_command('trigger/action -actionType Move -item '..itemToken..' -command [ enhanced/item-action -source UNIT_ID -item ITEM_ID -action Move ]')
  end
  if item.OnWound then
   if verbose then print('trigger/action -actionType Wound -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound ]') end
   dfhack.run_command('trigger/action -actionType Wound -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound ]')
  end
  if item.OnShoot then
   if verbose then print('trigger/action -actionType Shoot -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action Shoot ]') end
   dfhack.run_command('trigger/action -actionType Shoot -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action Shoot ]')
  end
  if item.OnReport then
   for _,reportType in ipairs(item.OnReport._children) do
    if verbose then print('trigger/action -actionType '..reportType..' -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action '..reportType..' ]') end
    dfhack.run_command('trigger/action -actionType '..reportType..' -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action '..reportType..' ]')
   end
  end
  -- trigger/projectile triggers
  if item.OnProjectileMove then
   if verbose then print('trigger/projectile -type Move -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -action ProjectileMove ]') end
   dfhack.run_command('trigger/projectile -type Move -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -action ProjectileMove ]')
  end
  if item.OnProjectileHit then
   if verbose then print('trigger/projectile -type Hit -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -action ProjectileHit ]') end
   dfhack.run_command('trigger/projectile -type Hit -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -action ProjectileHit ]')
  end
  if item.OnProjectileFired then
   if verbose then print('trigger/projectile -type Fired -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -action ProjectileFired ]') end
   dfhack.run_command('trigger/projectile -type Fired -item '..itemToken..' -command [ enhanced/item-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -action ProjectileFired ]')
  end
 end
end

--= Enhanced Material Triggers
if materialCheck then
 local function matTrigger(material,materialToken,triggerType,verbose)
  -- trigger/action triggers
  if material.OnEquip then
   if verbose then print('trigger/action -actionType Equip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Equip -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Equip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Equip -matType '..triggerType..' ]')
   if verbose then print('trigger/action -actionType Unequip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Unequip -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Unequip -material '..materialToken..' -command [ enhanced/material-action -unit UNIT_ID -item ITEM_ID -action Unequip -matType '..triggerType..' ]')
  end
  if material.OnAttack then
   if verbose then print('trigger/action -actionType Attack -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Attack -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -velocity ATTACK_VELOCITY -action Attack -matType '..triggerType..' ]')
  end
  if material.OnBlock then
   if verbose then print('trigger/action -actionType Block -material '..materialToken..' -command [ enhanced/material-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action BLOCK -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Block -material '..materialToken..' -command [ enhanced/material-action -source BLOCKER_ID -target BLOCKED_UNIT_ID -item ITEM_ID -action BLOCK -matType '..triggerType..' ]')
  end
  if material.OnDodge then
   if verbose then print('trigger/action -actionType Dodge -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Dodge -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Dodge -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Dodge -matType '..triggerType..' ]')
  end
  if material.OnParry then
   if verbose then print('trigger/action -actionType Parry -material '..materialToken..' -command [ enhanced/material-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Parry -material '..materialToken..' -command [ enhanced/material-action -source PARRIER_ID -target PARRIED_UNIT_ID -item ITEM_ID -action Parry -matType '..triggerType..' ]')
  end
  if material.OnMove then
   if verbose then print('trigger/action -actionType Move -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Move -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Move -material '..materialToken..' -command [ enhanced/material-action -source UNIT_ID -item ITEM_ID -action Move -matType '..triggerType..' ]')
  end
  if material.OnWound then
   if verbose then print('trigger/action -actionType Wound -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Wound -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -wound WOUND_ID -action Wound -matType '..triggerType..' ]')
  end
  if material.OnShoot then
   if verbose then print('trigger/action -actionType Shoot -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action Shoot -matType '..triggerType..' ]') end
   dfhack.run_command('trigger/action -actionType Shoot -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action Shoot -matType '..triggerType..' ]')
  end
  if material.OnReport then
   for _,reportType in ipairs(material.OnReport._children) do
    if verbose then print('trigger/action -actionType '..reportType..' -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action '..reportType..' -matType '..triggerType..' ]') end
    dfhack.run_command('trigger/action -actionType '..reportType..' -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -action '..reportType..' -matType '..triggerType..' ]')
   end
  end
  -- trigger/projectile triggers
  if material.OnProjectileMove then
   if verbose then print('trigger/projectile -type Move -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -matType '..triggerType..' -action ProjectileMove ]') end
   dfhack.run_command('trigger/projectile -type Move -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -matType '..triggerType..' -action ProjectileMove ]')
  end
  if material.OnProjectileHit then
   if verbose then print('trigger/projectile -type Hit -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -matType '..triggerType..' -action ProjectileHit ]') end
   dfhack.run_command('trigger/projectile -type Hit -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -matType '..triggerType..' -action ProjectileHit ]')
  end
  if material.OnProjectileFired then
   if verbose then print('trigger/projectile -type Fired -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -matType '..triggerType..' -action ProjectileFired ]') end
   dfhack.run_command('trigger/projectile -type Fired -material '..materialToken..' -command [ enhanced/material-action -source ATTACKER_ID -target DEFENDER_ID -item ITEM_ID -projectile PROJECTILE_ID -matType '..triggerType..' -action ProjectileFired ]')
  end
 end
 
 if verbose then print('Setting up Enhanced Material Triggers') end
 materials = persistTable.GlobalTable.roses.EnhancedMaterialTable
 for _,materialToken in pairs(materials.Inorganic._children) do
  material = materials.Inorganic[materialToken]
  materialToken = 'INORGANIC:'..materialToken
  matTrigger(material,materialToken,'Inorganic',verbose)
 end
 for _,token in pairs(materials.Creature._children) do
  for _,index in pairs(materials.Creature[token]._children) do
   if index ~= 'ALL' then
    material = materials.Creature[token][index]
    materialToken = 'CREATURE:'..token..':'..index
    matTrigger(material,materialToken,'Creature',verbose)
   end
  end
 end
 for _,token in pairs(materials.Plant._children) do
  for _,index in pairs(materials.Plant[token]._children) do
   if index ~= 'ALL' then
    material = materials.Plant[token][index]
    materialToken = 'PLANT:'..token..':'..index
    matTrigger(material,materialToken,'Plant',verbose)
   end
  end
 end
end

--= Enhanced Building Triggers
if buildingCheck then
 if verbose then print('Setting up Enhanced Building Triggers') end
 for _,buildingToken in pairs(persistTable.GlobalTable.roses.EnhancedBuildingTable._children) do
  building = persistTable.GlobalTable.roses.EnhancedBuildingTable[buildingToken]
  checks = ''
  if building.OutsideOnly   then checks = checks .. ' -location Outside'                         end
  if building.InsideOnly    then checks = checks .. ' -location Inside'                          end
  if building.MaxAmount     then checks = checks .. ' -maxNumber '     .. building.MaxAmount     end
  if building.MultiStory    then checks = checks .. ' -zLevels '       .. building.MultiStory    end
  if building.RequiredWater then checks = checks .. ' -requiredWater ' .. building.RequiredWater end
  if building.RequiredMagma then checks = checks .. ' -requiredMagma ' .. building.RequiredMagma end
  if building.RequiredBuildings then
   temp = ' -requiredBuilding [ '
   for _,bldg in pairs(building.RequiredBuildings._children) do
    num = building.RequiredBuildings[bldg]
    temp = temp..bldg..':'..num..' '
   end
   temp = temp..']'
   checks = checks .. temp
  end
  if building.ForbiddenBuildings then
   temp = ' -forbiddenBuilding [ '
   for _,bldg in pairs(building.ForbiddenBuildings._children) do
    num = building.ForbiddenBuildings[bldg]
    temp = temp..bldg..':'..num..' '
   end
   temp = temp..']'
   checks = checks .. temp
  end 
  if verbose then print('trigger/building -building '..buildingToken..checks..' -created -command [ enhanced/building -created -buildingID BUILDING_ID ]') end
  dfhack.run_command('trigger/building -building '..buildingToken..checks..' -created -command [ enhanced/building -created -buildingID BUILDING_ID ]')
  if verbose then print('trigger/building -building '..buildingToken..' -destroyed -command [ enhanced/building -destroyed -buildingToken BUILDING_TOKEN -buildingLocation BUILDING_LOCATION ]') end
  dfhack.run_command('trigger/building -building '..buildingToken..' -destroyed -command [ enhanced/building -destroyed -buildingToken BUILDING_TOKEN -buildingLocation BUILDING_LOCATION ]')
 end
end

--= Enhanced Reaction Triggers
if reactionCheck then
 if verbose then print('Setting up Enhanced Reaction Triggers') end
 for _,reactionToken in pairs(persistTable.GlobalTable.roses.EnhancedReactionTable._children) do
  reaction = persistTable.GlobalTable.roses.EnhancedReactionTable[reactionToken]
  if reaction.OnStart then
   checks = ' '
   if reaction.BaseDur and not reaction.DurReduction then checks = checks..'-delay '..reaction.BaseDur..' ' end
   if reaction.RequiredMagma then checks = checks..'-requiredMagma '..reaction.RequiredMagma..' ' end
   if reaction.RequiredWater then checks = checks..'-requiredWater '..reaction.RequiredWater..' ' end
   if verbose then print('trigger/reaction -reaction '..reactionToken..' -trigger onStart'..checks..'-command [ enhanced/reaction -type Start -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]') end
   dfhack.run_command('trigger/reaction -reaction '..reactionToken..' -trigger onStart'..checks..'-command [ enhanced/reaction -type Start -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ]  -job JOB_ID ]')
  end
  if reaction.OnFinish then
   if verbose then print('trigger/reaction -reaction '..reactionToken..' -trigger onFinish -command [ enhanced/reaction -type End -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]') end
   dfhack.run_command('trigger/reaction -reaction '..reactionToken..' -trigger onFinish -command [ enhanced/reaction -type End -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]')
  end
  if reaction.OnProduct then
   if verbose then print('trigger/reaction -reaction '..reactionToken..' -trigger onProduct -command [ enhanced/reaction -inputItems [ INPUT_ITEMS ] -outputItems [ OUTPUT_ITEMS ] -type Product -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]') end
   dfhack.run_command('trigger/reaction -reaction '..reactionToken..' -trigger onProduct -command [ enhanced/reaction -type Product -inputItems [ INPUT_ITEMS ] -outputItems [ OUTPUT_ITEMS ] -worker WORKER_ID -target TARGET_ID -reaction REACTION_NAME -building BUILDING_ID -location [ LOCATION ] -job JOB_ID ]')
  end
 end
end
