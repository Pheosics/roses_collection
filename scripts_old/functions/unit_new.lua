
function Unit(unit)
  if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
  local self = {unit = unit,
                creature_raws = df.creature_raw.find(unit.race),
				caste_raws    = df.creature_raw.find(unit.race).caste[unit.caste]}
 
  -- GET Functions (All)
  local get_creature_classes = function () -- Returns a table of creature classes [key,value] where key = value
    local classes = {}
	for _,class in ipairs(self.caste_raws.creature_class) do classes[class.value] = class.value	end
    return classes
  end
  local get_creature_tokens  = function () -- Returns a table of creature tokens [key,value] where key = token, value = true/false
    local tokens = {}
	for k,v in pairs(self.creature_raws.flags) do tokens[k] = v end
	for k,v in pairs(self.caste_raws.flags)    do tokens[k] = v end
	return tokens
  end
  local get_syndrome_classes = function () -- Returns a table of active syndrome classes [key,value] where key = value = SYN_CLASS
    local classes = {}
	local syndromes = df.global.world.raws.syndromes.all
	for _,x in ipairs(self.unit.syndromes.active) do
	  for _,y in ipairs(syndromes[x.type].syn_class) do classes[y.value] = y.value end
	end
	return classes
  end
  local get_syndrome_names   = function () -- Returns a table of active syndrome names [key,value] where key = value = SYN_NAME
    local names = {}
	local syndromes = df.global.world.raws.syndromes.all
    for _,x in ipairs(self.unit.syndromes.active) do names[syndromes[x.type].syn_name] = syndromes[x.type].syn_name end
	return names
  end

  -- Get Functions (Specific)
  local get_attack_id        = function (v)   -- Returns an attack ID with name = v
    local attack = -1
    for i,attacks in pairs(self.unit.body.body_plan.attacks) do
      if attacks.name == v then
        attack = i
        break
      end
    end
	return attack
  end
  local get_counter_value    = function (v)   -- Returns the counter value on the unit
    local counter == string.lower(v)
	local value = 0
    if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
      value = self.unit.counters[counter]
    elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
      if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
      value = self.unit.counters2[counter]
    elseif counter == 'blood' or counter == 'infection' then
      value = self.unit.body[counter]
    end
    return value
  end
  local get_body_part_ids    = function (k,v) -- Returns a table of body part ids that meet a certain criteria
    local parts = {}
	local body = self.unit.body
	for j,y in ipairs(body.body_plan.body_parts) do
	  if not body.components.body_part_status[j].missing then
	    if  (string.lower(k) == 'category'  and y.category == v)
	     or (string.lower(k) == 'token'     and y.token == v)
	     or (string.lower(k) == 'flag'      and y.flags[v])
		 or (string.lower(k) == 'connected' and y.con_part_id == v) 
		  parts[#parts+1] = j 
		end
	  end
	end
	return parts
  end
  local get_body_part_layers = function (v)   -- Returns a table of global layer ids that are on body part v
    local layers = {}
    for i,x in pairs(self.unit.body.body_plan.layer_part) do
      if x == v then layers[#layers+1] = i end
    end
    return layers
  end
  local get_inventory_ids    = function (k,v) -- Returns a table of item ids that meet a certain criteria
    local items = {}
    local inventory = self.unit.inventory
    for _,x in ipairs(inventory) do
      if  (string.lower(k) == 'type' and df.item_type[x.item:getType()] == v)
	   or (string.lower(k) == 'mode' and x.mode == v)
	   or (string.lower(k) == 'part' and x.body_part_id == v) then
        items[#items+1] = x.item.id
      end
    end
    return items
  end
  
  -- GET Functions (Random and weighted)
  local get_attack_random    = function () -- Returns a random attack ID weighted by MAIN_ATTACK flag (100 to 1)
    local rand = dfhack.random.new()
    local weights = {}
    weights[0] = 0
    local n = 0
    for _,attacks in pairs(unit.body.body_plan.attacks) do
	  local x = 1
      if attacks.flags.main then x = 100 end
      n = n + 1
      weights[n] = weights[n-1] + x
    end 
    while not attack do
      local pick = rand:random(weights[n])
      for i = 1,n do
        if pick >= weights[i-1] and pick < weights[i] then attack = i-1 break end
      end
	  local bp_idx = self.unit.body.body_plan.attacks[attack].body_part_idx[0]
      if self.unit.body.components.body_part_status[bp_idx].missing then attack = nil end
    end
	return attack
  end
  local get_body_part_random = function () -- Returns a random body part ID weighted by the relative sizes
    local rand = dfhack.random.new()
    local weights = {}
    weights[0] = 0
    local n = 0
    for _,targets in pairs(unit.body.body_plan.body_parts) do
      n = n + 1
      weights[n] = weights[n-1] + targets.relsize 
    end
    while not target do
      pick = rand:random(weights[n])
      for i = 1,n do
        if pick >= weights[i-1] and pick < weights[i] then target = i-1 break end
      end
      if self.unit.body.components.body_part_status[target].missing then target = nil end
    end
	return target
   end
  
  -- HAS Functions
  local has_creature_class = function (v) -- Returns true/false/nil
    return get_creature_classes()[v] 
  end
  local has_creature_token = function (v) -- Returns true/false/nil
    return get_creature_tokens()[v]  
  end
  local has_syndrome_class = function (v) -- Returns true/false/nil
    return get_syndrome_classes()[v] 
  end
  local has_syndrome_name  = function (v) -- Returns true/false/nil
    return get_syndrome_names()[v]
  end
  
  return {
    -- GET Functions (All)
    getCreatureClasses = get_creature_classes,
	getCreatureTokens  = get_creature_tokens,
	getSyndromeClasses = get_syndrome_classes,
	getSyndromeNames   = get_syndrome_names,
	-- GET Functions (Specific)
	getAttackID         = get_attack_id,
	getCounterValue     = get_counter_value,
	getBodyPartIDs      = get_body_part_ids,
	getBodyPartLayerIDs = get_body_part_layers,
	getInventoryIDs     = get_inventory_ids,
	-- GET Functions (Random and weighted)
	getRandomAttackID   = get_attack_random,
	getRandomBodyPartID = get_body_part_random,
	-- HAS Functions
	hasCreatureClass = has_creature_class,
	hasCreatureToken = has_creature_token,
	hasSyndromeClass = has_syndrome_class,
	hasSyndromeName  = has_syndrome_name
  }
end

function getBodyParts(unit,partType,partSubType)
 return Unit(unit).getBodyPartIDs(partType,partSubType)
end
function getBodyPartLayers(unit,part)
 return Unit(unit).getBodyPartLayerIDs(part)
end
function getCreatureClasses(unit)
 return Unit(unit).getCreatureClasses()
end
function getCreatureTokens(unit)
 return Unit(unit).getCreatureTokens()
end
function getSyndromeClasses(unit)
 return Unit(unit).getSyndromeClasses()
end
function getSyndromeNames(unit)
 return Unit(unit).getSyndromeNames()
end

function hasCreatureClass(unit,class)
 return Unit(unit).hasCreatureClass(class)
end
function hasCreatureToken(unit,token)
 return Unit(unit).hasCreatureToken(token)
end
function hasSyndromeClass(unit,class)
 return Unit(unit).hasSyndromeClass(class)
end
function hasSyndromeName(unit,name)
 return Unit(unit).hasSyndromeName(name)
end
