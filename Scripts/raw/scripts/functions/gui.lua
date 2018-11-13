local utils = require 'utils'
local split = utils.split_string

-- Creature Tokens
--= Biomes
biomeTokens = { 
  ANY_LAND = 'Any Land',
  ALL_MAIN = 'All Main',
  ANY_OCEAN = 'Any Ocean',
  ANY_LAKE = 'Any Lake',
  ANY_TEMPERATE_LAKE = 'Temperate Lakes',
  ANY_TROPICAL_LAKE = 'Tropical Lakes',
  ANY_RIVER = 'Lives in any rivers',
  ANY_TEMPERATE_RIVER = 'Temperate Rivers',
  ANY_TROPICAL_RIVER = 'Tropical Rivers',
  ANY_POOL = 'Any Pool',
  NOT_FREEZING = 'Not Freezing',
  ANY_TEMPERATE = 'Any Temperate',
  ANY_TROPICAL = 'Any Tropical',
  ANY_FOREST = 'Any Forest',
  ANY_SHRUBLAND = 'Any Shrubland',
  ANY_GRASSLAND = 'Any Grassland',
  ANY_SAVANNA = 'Any Savanna',
  ANY_TEMPERATE_FOREST = 'Any Temperate Forest',
  ANY_TROPICAL_FOREST = 'Any Tropical Forest',
  ANY_TEMPERATE_BROADLEAF = 'Any Temperate Vegetation',
  ANY_TROPICAL_BROADLEAF = 'Any Tropical Vegetation',
  ANY_WETLAND = 'Any Wetland',
  ANY_TEMPERATE_WETLAND = 'Any Temperate Wetland',
  ANY_TROPICAL_WETLAND = 'Any Tropical Wetland',
  ANY_TEMPERATE_MARSH = 'Any Temperate Marsh',
  ANY_TROPICAL_MARSH = 'Any Tropical Marsh',
  ANY_TEMPERATE_SWAMP = 'Any Temperate Swamp',
  ANY_TROPICAL_SWAMP = 'Any Tropical Swamp',
  ANY_DESERT = 'Any Desert',
  MOUNTAIN = 'Mountains',
  MOUNTAINS = 'Mountains',
  GLACIER = 'Glaciers',
  TUNDRA = 'Tundra',
  SWAMP_TEMPERATE_FRESHWATER = 'Temperate Freshwater Swamp',
  SWAMP_TEMPERATE_SALTWATER = 'Temperate Saltwater Swamp',
  SWAMP_TROPICAL_FRESHWATER = 'Tropical Freshwater Swamp',
  SWAMP_TROPICAL_SALTWATER = 'Tropical Saltwater Swamp',
  SWAMP_MANGROVE = 'Mangrove Swamp',
  MARSH_TEMPERATE_FRESHWATER = 'Temperate Freshwater Marsh',
  MARSH_TEMPERATE_SALTWATER = 'Temperate Saltwater Marsh',
  MARSH_TROPICAL_FRESHWATER = 'Tropical Freshwater Marsh',
  MARSH_TROPICAL_SALTWATER = 'Tropical Saltwater Marsh',
  FOREST_TAIGA = 'Taiga',
  TAIGA = 'Taiga',
  FOREST_TEMPERATE_BROADLEAF = 'Temperate Broadleaf Forest',
  FOREST_TEMPERATE_CONIFER = 'Temperate Conifer Forest',
  FOREST_TROPICAL_DRY_BROADLEAF = 'Tropical Dry Broadleaf Forest',
  FOREST_TROPICAL_MOIST_BROADLEAF = 'Tropical Moist Broadleaf Forest',
  FOREST_TROPICAL_CONIFER = 'Tropical Conifer Forest',
  GRASSLAND_TEMPERATE = 'Temperate Grassland',
  GRASSLAND_TROPICAL = 'Tropical Grassland',
  SHRUBLAND_TEMPERATE = 'Temperate Shrubland',
  SHRUBLAND_TROPICAL = 'Tropical Shrubland',
  SAVANNA_TEMPERATE = 'Temperate Savanna',
  SAVANNA_TROPICAL = 'Tropical Savanna',
  OCEAN_ARCTIC = 'Arctic Ocean',
  OCEAN_TEMPERATE = 'Temperate Ocean',
  OCEAN_TROPICAL = 'Tropical Ocean',
  DESERT_BADLAND = 'Badlands',
  DESERT_ROCK = 'Rocky Wastes',
  DESERT_SAND = 'Sandy Desert',
  POOL_TEMPERATE_FRESHWATER = 'Temperate Freshwater Pool',
  POOL_TEMPERATE_BRACKISHWATER = 'Temperate Brackishwater Pool',
  POOL_TEMPERATE_SALTWATER = 'Temperate Saltwater Pool',
  POOL_TROPICAL_FRESHWATER = 'Tropical Freshwater Pool',
  POOL_TROPICAL_BRACKISHWATER = 'Tropical Brackishwater Pool',
  POOL_TROPICAL_SALTWATER = 'Tropical Saltwater Pool',
  LAKE_TEMPERATE_FRESHWATER = 'Temperate Freshwater Lake',
  LAKE_TEMPERATE_BRACKISHWATER = 'Temperate Brackishwater Lake',
  LAKE_TEMPERATE_SALTWATER = 'Temperate Saltwater Lake',
  LAKE_TROPICAL_FRESHWATER = 'Tropical Freshwater Lake',
  LAKE_TROPICAL_BRACKISHWATER = 'Tropical Brackishwater Lake',
  LAKE_TROPICAL_SALTWATER = 'Tropical Saltwater Lake',
  RIVER_TEMPERATE_FRESHWATER = 'Temperate Freshwater River',
  RIVER_TEMPERATE_BRACKISHWATER = 'Temperate Brackishwater River',
  RIVER_TEMPERATE_SALTWATER = 'Temperate Saltwater River',
  RIVER_TROPICAL_FRESHWATER = 'Tropical Freshwater River',
  RIVER_TROPICAL_BRACKISHWATER = 'Tropical Brackishwater River',
  RIVER_TROPICAL_SALTWATER = 'Tropical Saltwater River',
  SUBTERRANEAN_WATER = 'Subterranean Water',
  SUBTERRANEAN_CHASM = 'Subterranean Chasm',
  SUBTERRANEAN_LAVA = 'Subterranean Lava',
  BIOME_MOUNTAIN = 'Mountain',
  BIOME_GLACIER = 'Glacier',
  BIOME_TUNDRA = 'Tundra',
  BIOME_SWAMP_TEMPERATE_FRESHWATER = 'Temperate Freshwater Swamp',
  BIOME_SWAMP_TEMPERATE_SALTWATER = 'Temperate Saltwater Swamp',
  BIOME_MARSH_TEMPERATE_FRESHWATER = 'Temperate Freshwater Marsh',
  BIOME_MARSH_TEMPERATE_SALTWATER = 'Temperate Saltwater Marsh',
  BIOME_SWAMP_TROPICAL_FRESHWATER = 'Tropical Freshwater Swamp',
  BIOME_SWAMP_TROPICAL_SALTWATER = 'Tropical Saltwater Swamp',
  BIOME_SWAMP_MANGROVE = 'Mangrove Swamp',
  BIOME_MARSH_TROPICAL_FRESHWATER = 'Tropical Freshwater Marsh',
  BIOME_MARSH_TROPICAL_SALTWATER = 'Tropical Saltwater Marsh',
  BIOME_FOREST_TAIGA = 'Taiga',
  BIOME_FOREST_TEMPERATE_CONIFER = 'Temperate Coniferous Forest',
  BIOME_FOREST_TEMPERATE_BROADLEAF = 'Temperate Broadlead Forest',
  BIOME_FOREST_TROPICAL_CONIFER = 'Tropical Coniferous Forest',
  BIOME_FOREST_TROPICAL_DRY_BROADLEAF = 'Tropical Dry Broadleaf Forest',
  BIOME_FOREST_TROPICAL_MOIST_BROADLEAF = 'Tropical Moist Broadleaf Forest',
  BIOME_GRASSLAND_TEMPERATE = 'Temperate Grassland',
  BIOME_SAVANNA_TEMPERATE = 'Temperate Savanna',
  BIOME_SHRUBLAND_TEMPERATE = 'Temperate Shrubland',
  BIOME_GRASSLAND_TROPICAL = 'Tropical Grassland',
  BIOME_SAVANNA_TROPICAL = 'Tropical Savanna',
  BIOME_SHRUBLAND_TROPICAL = 'Tropical Shrubland',
  BIOME_DESERT_BADLAND = 'Badland Desert',
  BIOME_DESERT_ROCK = 'Rock Desert',
  BIOME_DESERT_SAND = 'Sand Desert',
  BIOME_OCEAN_TROPICAL = 'Tropical Ocean',
  BIOME_OCEAN_TEMPERATE = 'Temperate Ocean',
  BIOME_OCEAN_ARCTIC = 'Arctic Ocean',
  BIOME_SUBTERRANEAN_WATER = 'Underground Water',
  BIOME_SUBTERRANEAN_CHASM = 'Ungerground Chasm',
  BIOME_SUBTERRANEAN_LAVA = 'Underground Lava',
  BIOME_POOL_TEMPERATE_FRESHWATER = 'Temperate Freshwater Pool',
  BIOME_POOL_TEMPERATE_BRACKISHWATER = 'Temperate Brackishwater Pool',
  BIOME_POOL_TEMPERATE_SALTWATER = 'Temperate Saltwater Pool',
  BIOME_POOL_TROPICAL_FRESHWATER = 'Tropical Freshwater Pool',
  BIOME_POOL_TROPICAL_BRACKISHWATER = 'Tropical Brackishwater Pool',
  BIOME_POOL_TROPICAL_SALTWATER = 'Tropical Saltwater Pool',
  BIOME_LAKE_TEMPERATE_FRESHWATER = 'Temperate Freshwater Lake',
  BIOME_LAKE_TEMPERATE_BRACKISHWATER = 'Temperate Brackishwater Lake',
  BIOME_LAKE_TEMPERATE_SALTWATER = 'Temperate Saltwater Lake',
  BIOME_LAKE_TROPICAL_FRESHWATER = 'Tropical Freshwater Lake',
  BIOME_LAKE_TROPICAL_BRACKISHWATER = 'Tropical Brackishwater Lake',
  BIOME_LAKE_TROPICAL_SALTWATER = 'Tropical Saltwater Lake',
  BIOME_RIVER_TEMPERATE_FRESHWATER = 'Temperate Freshwater River',
  BIOME_RIVER_TEMPERATE_BRACKISHWATER = 'Temperate Brackishwater River',
  BIOME_RIVER_TEMPERATE_SALTWATER = 'Temperate Saltwater River',
  BIOME_RIVER_TROPICAL_FRESHWATER = 'Tropical Freshwater River',
  BIOME_RIVER_TROPICAL_BRACKISHWATER = 'Tropical Brackishwater River',
  BIOME_RIVER_TROPICAL_SALTWATER = 'Tropical Saltwater River'}

--= Habitats
habitatFlags = {
  AMPHIBIOUS = 'Amphibious',
  AQUATIC = 'Aquatic',
  GOOD = 'Living in good biomes',
  EVIL = 'Living in evil biomes',
  SAVAGE = 'Living in savage biomes'}

--= Activity
activeFlags = {
  ALL_ACTIVE = 'At all times',
  DIURNAL = 'During the day',
  NOCTURNAL = 'During the night',
  CREPUSCULAR = 'At dawn and dusk',
  VESPERTINE = 'At dusk',
  MATUTINAL = 'At dawn'}

--= Utility
utilityFlags = {
  COMMON_DOMESTIC = 'Domesticated',
  WAGON_PULLER = 'Can pull wagons',
  PACK_ANIMAL = 'Can haul goods',
  TRAINABLE_HUNTING = 'Can be trained to hunt',
  TRAINABLE_WAR = 'Can be trained for fighting',
  PET = 'Can be tamed',
  PET_EXOTIC = 'Can be tamed with difficulty',
  MOUNT = 'Can be used as a mount',
  MOUNT_EXOTIC = 'Can be used as a mount'}
 
--= Diet             
dietFlags = {
  NO_EAT = "Doesn't need food",
  NO_DRINK = "Doesn't need drink",
  BONECARN = 'Eats meat and bones',
  CARNIVORE = 'Only eats meat',
  GRAZER = 'Eats grass',
  GOBBLE_VERMIN = 'Eats vermin'}

--= Behavior
behaviorFlags = {
  MISCHIEVOUS = 'Mischievous',
  CURIOUSBEAST_ANY = 'Steals anything',
  CURIOUSBEAST_ITEM = 'Steals items',
  CURIOUSBEAST_GUZZLER = 'Steals drinks',
  CURIOUSBEAST_EATER = 'Steals food',
  TRAPAVOID = 'Avoids traps',
  CAVE_ADAPT = 'Dislikes leaving caves',
  HUNTS_VERMIN = 'Hunts vermin',
  SOUND_ALERT = 'Creates sounds when alerted',
  SOUND_PEACEFUL_INTERMITTENT = 'Creates sounds intermittently',
  CRAZED = 'Constantly berserk',
  FLEEQUICK = 'Quick to flee',
  AT_PEACE_WITH_WILDLIFE = 'At peace with wildlife',
  AMBUSHPREDATOR = 'Ambushes prey',
  OPPOSED_TO_LIFE = 'Hostile to the living'}

--= Movement
movementFlags = {
  FLIER = 'Can fly',
  IMMOBILE = 'Can not move',
  IMMOBILE_LAND = 'Can not move on land',
  MEANDERER = 'Meanders around',
  SWIMS_INNATE = 'Can swim',
  CANNOT_JUMP = 'Can not jump',
  STANCE_CLIMBER = 'can climb with its feet',
  CANNOT_CLIMB = 'Can not climb',
  SWIMS_LEARNED = 'Can learn to swim',
  VERMIN_MICRO = 'Moves in a swarm',
  UNDERSWIM = 'Swims underwater'}

--= Immunities
immuneFlags = {
  NO_DIZZINESS = 'Does not get dizzy',
  NO_FEVERS = 'Does not get fevers',
  NOEXERT = 'Does not get tired',
  NOPAIN = 'Does not feel pain',
  NOBREATHE = 'Does not breath',
  NOSTUN = 'Can not be stunned',
  PARALYZEIMMUNE = 'Can not be paralyzed',
  NONAUSEA = 'Does not get nauseous',
  NOEMOTION = 'Does not feel emotion',
  NOFEAR = 'Can not be scared',
  NO_SLEEP = "Doesn't need sleep",
  FIREIMMUNE = 'Immune to fire',
  FIREIMMUNE_SUPER = 'Immune to dragonfire',
  WEBIMMUNE = 'Does not get caught in webs'}

--= Bonuses
bonusFlags = {
  WEBBER = 'Creates webs',
  THICKWEB = 'Webs large targets',
  MAGMA_VISION = 'Can see in lava',
  IMMOLATE = 'Radiates fire',
  MULTIPART_FULL_VISION = 'Can see all around itself',
  CAN_SPEAK = 'Can speak',
  CAN_LEARN = 'Can learn',
  CANOPENDOORS = 'Can open doors',
  LOCKPICKER = 'Can pick locks',
  EQUIPS = 'Can wear items',
  LISP = 'Speaks with a lisp',
  LIGHT_GEN = 'Generates light',
  EXTRAVISION = 'Can see in the dark',
  SLOW_LEARNER = 'Slow learner',
  UTTERANCES = 'Unintelligible utterances'}

--= Body Flags
bodyFlags = {
  NOT_BUTCHERABLE = 'Can not be butchered',
  COOKABLE_LIVE = 'Can be cooked live',
  NOSKULL = 'Does not have a skull',
  NOSKIN = 'Does not have skin',
  NOBONES = 'Does not have bones',
  NOMEAT = 'Does not have meat',
  NOTHOUGHT = 'Does not have a brain',
  NO_THOUGHT_CENTER_FOR_MOVEMENT = 'Does not need a brain to move',
  VEGETATION = 'Made of swampstuff'}

--= Seasonal
seasonFlags = {
  NO_SPRING = 'Absent during the spring',
  NO_SUMMER = 'Absent during the summer',
  NO_AUTUMN = 'Absent during the fall',
  NO_WINTER = 'Absent during the winter'}

--= Types
typeCreatureFlags = {
  FANCIFUL = 'Fanciful',
  CASTE_MEGABEAST = 'Megabeast',
  CASTE_SEMIMEGABEAST = 'Semi-Megabeast',
  CASTE_BENIGN = 'Benign',
  CASTE_POWER = 'Power',
  CASTE_TITAN = 'Titan',
  CASTE_FEATURE_BEAST = 'Feature Beast',
  CASTE_UNIQUE_DEMON = 'Unique Demon',
  CASTE_DEMON = 'Demon',
  CASTE_NIGHT_CREATURE_ANY = 'Night Creature'}

-- Plant Flags
--= Seasonal
seasonPlantFlags = {
  SPRING = 'Grows during the spring',
  SUMMER = 'Grows during the summer',
  AUTUMN = 'Grows during the fall',
  WINTER = 'Grows during the winter',}

-- Material Flags
--= Edible
materialEdibleFlags = {
  EDIBLE_VERMIN = 'Vermin',
  EDIBLE_RAW = 'Raw',
  EDIBLE_COOKED = 'Cooked'}

--= Items
materialItemFlags = {
  ITEMS_WEAPON = 'Makes melee weapons',
  ITEMS_WEAPON_RANGED = 'Makes ranges weapons',
  ITEMS_ANVIL = 'Makes anvils',
  ITEMS_AMMO = 'Makes ammo',
  ITEMS_DIGGER = 'Makes digging items',
  ITEMS_ARMOR = 'Makes armor',
  ITEMS_DELICATE = 'Makes delicate items',
  ITEMS_SIEGE_ENGINE = 'Makes siege engine ammo',
  ITEMS_QUERN = 'Makes querns',
  ITEMS_METAL = 'Makes metal items',
  ITEMS_BARRED = 'Makes barred items',
  ITEMS_SCALED = 'Makes scaled items',
  ITEMS_LEATHER = 'Makes leather items',
  ITEMS_SOFT = 'Makes soft items',
  ITEMS_HARD = 'Makes hard items'}

--= Types
typeMaterialFlags = {
  IS_METAL = 'Metal',
  IS_GLASS = 'Glass',
  IS_STONE = 'Stone'}

-- Item Flags
--= Materials
itemCraftFlags = {
  SOFT = 'Soft',
  HARD = 'Hard',
  METAL = 'Metal',
  BARRED = 'Barred',
  SCALED = 'Scaled',
  LEATHER = 'Leather',
  METAL_MAT = 'Metal',
  STONE_MAT = 'Stone',
  WOOD_MAT = 'Wood',
  GLASS_MAT = 'Glass',
  CERAMIC_MAT = 'Ceramic',
  SHELL_MAT = 'Shell',
  BONE_MAT = 'Bone',
  HARD_MAT = 'Hard',
  SHEET_MAT = 'Sheet',
  THREAD_PLANT_MAT = 'Plant Thread',
  SILK_MAT = 'Silk',
  SOFT_MAT = 'Soft',
  METAL_WEAPON_MAT = 'Metal',
  CAN_STONE = 'Stone'}

--= Uses
itemUseFlags = {
  TRAINING = 'Training',
  FURNITURE = 'Furniture',
  LIQUID_COOKING = 'Cooking',
  LIQUID_SCOOP = 'Liquid Scoop',
  GRIND_POWDER_RECEPTACLE = 'Powder Receptacle',
  GRIND_POWDER_GRINDER = 'Powder Grinder',
  MEAT_CARVING = 'Meat Carving',
  MEAT_BONING = 'Meat Boning',
  MEAT_SLICING = 'Meat Slicing',
  MEAT_CLEAVING = 'Meat Cleaving',
  HOLD_MEAT_FOR_CARVING = 'Meat Holding',
  MEAL_CONTAINER = 'Meal Container',
  LIQUID_CONTAINER = 'Liquid Container',
  FOOD_STORAGE = 'Food Storage',
  HIVE = 'Artificial Hive',
  NEST_BOX = 'Nest Box',
  SMALL_OBJECT_STORAGE = 'Small Object Storage',
  TRACK_CART = 'Track Cart',
  HEAVY_OBJECT_HAULING = 'Heavy Object Hauling',
  STAND_AND_WORK_ABOVE = 'Stand and Work Above',
  ROLL_UP_SHEET = 'Roll Up Sheet',
  PROTECT_FOLDED_SHEETS = 'Protect Paper',
  CONTAIN_WRITING = 'Hold Writings',
  BOOKCASE = 'Hold Books'}

function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function center(str, length)
 local string1 = str
 local string2 = string.format("%"..tostring(math.floor((length-#string1)/2)).."s"..string1,"")
 local string3 = string.format(string2.."%"..tostring(math.ceil((length-#string1)/2)).."s","")
 return string3
end

function changeViewScreen(subviews,viewcheck,mode,base)
 for i = 1,viewcheck.baseNum do
  if subviews[viewcheck.base[i]].visible then
   n = i
   break
  end
 end
 
 if mode == 'base' then
  if not base then
   if n ~= viewcheck.baseNum then
    n = n + 1
   else
    n = 1
   end
   base = viewcheck.base[n]
  end
  for _,view in pairs(subviews) do
   view.visible = false
   view.active = false
  end
  subviews[base].active = true
  subviews[base].visible = true
  for _,view in pairs(viewcheck[base][1]) do
   subviews[view].visible = true
   subviews[view].active = true
   if subviews[view].edit then
    subviews[view].edit.visible = true
    subviews[view].edit.active = true
   end
  end
  if viewcheck.always then
   for _,view in ipairs(viewcheck.always) do
    subviews[view].visible = true
   end
  end
 elseif mode == 'up' then
  base = viewcheck.base[n]
  for i = 1, #viewcheck[base] do
   if subviews[viewcheck[base][i][1]].visible then
    if i == 1 then
     return false
    else
     for _,view in pairs(viewcheck[base][i]) do
      subviews[view].visible = false
      subviews[view].active = false
      if subviews[view].edit then
       subviews[view].edit.visible = false
       subviews[view].edit.active = false
      end
     end
     for _,view in pairs(viewcheck[base][i-1]) do
      subviews[view].visible = true
      subviews[view].active = true
      if subviews[view].edit then
       subviews[view].edit.visible = true
       subviews[view].edit.active = true
      end
     end     
    end
    return true
   end
  end 
 elseif mode == 'down' then
  base = viewcheck.base[n]
  for i = 1, #viewcheck[base] do
   if subviews[viewcheck[base][i][1]].visible then
    if i == #viewcheck[base] then
     return false
    else
     for _,view in pairs(viewcheck[base][i]) do
      subviews[view].visible = false
      subviews[view].active = false
      if subviews[view].edit then
       subviews[view].edit.visible = false
       subviews[view].edit.active = false
      end
     end
     for _,view in pairs(viewcheck[base][i+1]) do
      subviews[view].visible = true
      subviews[view].active = true
      if subviews[view].edit then
       subviews[view].edit.visible = true
       subviews[view].edit.active = true
      end
     end     
    end
    return true
   end
  end
 end
end

function makeWidgetList(widget,method,list,options)
 options = options or {}
 color = options.pen or COLOR_WHITE
 w = options.width or 40
 rjustify = options.rjustify or false

 if options.replacement then
  temp_list = {}
  for first,second in pairs(list) do
   temp_first = options.replacement[first] or #temp_list+1
   temp_second = options.replacement[second] or #temp_list+1
   temp_list[temp_first] = temp_second
  end
  list = temp_list
 end
 
 local input = {}
 if method == 'first' then
  for first,_ in pairs(list) do
   table.insert(input,{text=first,pen=color,width=w,rjustify=rjustify})
  end
 elseif method == 'second' then
  for _,second in pairs(list) do
   table.insert(input,{text=second,pen=color,width=w,rjustify=rjustify})
  end
 elseif method == 'center' then
  table.insert(input,{text=center(list,w),width=w,pen=color,rjustify=rjustify})
 end
 widget:setChoices(input)
end

function insertWidgetInput(input,method,list,options)
 options = options or {}
 pen = options.pen or COLOR_WHITE
 width = options.width or 40
 rjustify = options.rjustify or false
 temp_list_length = 0
 
 if options.replacement then
  temp_list = {}
  if method == 'header' then
   for first,second in pairs(list.second) do
    temp_first = options.replacement[first] or #temp_list+1
    temp_second = options.replacement[second] or #temp_list+1
    if tonumber(temp_second) and not tonumber(temp_first) then 
     temp_second = temp_first 
     temp_first = first
    elseif tonumber(temp_first) and not tonumber(temp_second) then
     temp_first = second
    end
    if not tonumber(temp_second) and not tonumber(temp_first) then
     temp_list[temp_first] = temp_second
     temp_list_length = temp_list_length + 1
    end
   end
   list.second = temp_list
   list.length = temp_list_length
  else
   for first,second in pairs(list) do
    temp_first = options.replacement[first] or #temp_list+1
    temp_second = options.replacement[second] or #temp_list+1
    if tonumber(temp_second) and not tonumber(temp_first) then 
     temp_second = temp_first 
     temp_first = first
    elseif tonumber(temp_first) and not tonumber(temp_second) then
     temp_first = second
    end
    if not tonumber(temp_second) and not tonumber(temp_first) then
     temp_list[temp_first] = temp_second
     temp_list_length = temp_list_length + 1
    end
   end
   list = temp_list
  end
 else
  list.length = 0
  if type(list.second) == 'table' then
   for _,_ in pairs(list.second) do
    list.length = list.length + 1
   end
  end
 end
 
 if method == 'first' then
  for first,second in pairs(list) do
   if first ~= 'length' then
    table.insert(input,{text=first,pen=pen,width=width,rjustify=rjustify})
   end
  end
 elseif method == 'second' then
  for first,second in pairs(list) do
   if first ~= 'length' then
    table.insert(input,{text={{text=second,pen=pen,width=width,rjustify=rjustify}}})
   end
  end
 elseif method == 'center' then
  table.insert(input,{text=center(list,width),width=width,pen=pen,rjustify=rjustify})
 elseif method == 'header' then
  if type(list.second) == 'table' then
   local check = true
   if list.length == 0 then
    return input
--    table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text='--',rjustify=true,width=width-#list.header,pen=pen}}})
   else
    for first,second in pairs(list.second) do
     if options.fill == 'flags' then
      fill = first
     elseif options.fill == 'both' then
      fill = second..' ['..first..']'
     else
      fill = second
     end
     if check then
      table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
      check = false
     else
      table.insert(input,{text={{text='',width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
     end
    end
   end
  else
   if list.second == '' or list.second == '--' then
    return input
   else
    table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text=list.second,rjustify=true,width=width-#list.header,pen=pen}}})
   end
  end
 elseif method == 'headerpt' then
  if list.second then
   local check = true
   for _,x in pairs(list.second._children) do
    fill = list.second[x]
    if check then
     table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
     check = false
    else
     table.insert(input,{text={{text='',width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
    end
   end
  else
   return input
  end
 end
 return input
end

--=                      Detailed Unit Viewer Functions
usages[#usages+1] = [===[

]===]

function getBaseInfo(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local info = {}

 -- Unit Name
 info['Name'] = dfhack.units.getVisibleName(unit)

 -- Unit Caste
 local sex = ''
 local race = df.global.world.raws.creatures.all[tonumber(unit.race)].name[0]
 if unit.sex == 1 then 
  sex = 'Male '
 elseif unit.sex == 0 then 
  sex = 'Female '
 end
 local caste = df.global.world.raws.creatures.all[tonumber(unit.race)].caste[tonumber(unit.caste)].caste_name[0]
 info['Caste'] = race:gsub("^%l", string.upper)..', '..sex..caste:gsub("(%a)([%w_']*)", tchelper)

 -- Unit Entity
 local ent, civ, mem = '', '', ''
 if unit.civ_id >= 0 then ent = df.global.world.entities.all[unit.civ_id].name end
 if unit.population_id >= 0 then civ = df.global.world.entity_populations[unit.population_id].name end
 if unit.hist_figure_id >= 0 then
  local hf = df.global.world.history.figures[unit.hist_figure_id]
  for _,link in pairs(hf.entity_links) do
   if link.entity_id ~= unit.civ_id then mem = df.global.world.entities.all[link.entity_id].name end
  end
 end
 info['Entity'] = ent
 info['Civilization'] = civ
 info['Membership'] = mem

 return info
end

function getMembershipInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Membership = 'A basic description of the units memberships goes here'
  info.Worship    = 'A basic description of the units main workship goes here'
 elseif Type == 'Detailed' then
  info.Membership = {}
  info.Worship    = {}
 end

 return info
end

function getClassInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Current = 'A basic description of the units current class goes here'
  info.Classes = 'A basic description of the units other classes goes here'
 elseif Type == 'Detailed' then
  info.Current = {}
  info.Classes = {}
 end

 return info
end

function getDescriptionInfo(unit,w,Type)
 local info = ''

 info = 'The creature description goes here'

 return info
end

function getAppearanceInfo(unit,w,Type)
 local info = ''

 info = 'The units apperance goes here'

 return info
end

function getHealthInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Injury   = 'A basic description of any unit injuries goes here'
  info.Sickness = 'A basic description of any sickness goes here'
 elseif Type == 'Detailed' then
  info.Injury   = {}
  info.Sickness = {}
 end

 return info
end

function getAttributeInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Physical = 'A basic description of the units physical attributes goes here'
  info.Mental   = 'A basic description of the units mental attributes goes here'
 elseif Type == 'Detailed' then
  info.Physical = {}
  info.Mental   = {}
 end

 return info
end

function getSkillInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Profession = 'A basic description of the units base profession skills goes here'
  info.Misc       = 'A basic description of the units other skills goes here'
 elseif Type == 'Detailed' then
  info.Profession = {}
  info.Misc       = {}
 end
 
 return info
end

function getStatResistanceInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Stats       = 'A basic description of the units stats goes here'
  info.Resistances = 'A basic description of the units resistances goes here'
 elseif Type == 'Detailed' then
  info.Stats        = {}
  info.Resistances  = {}
 end

 return info
end

function getMainOutput(grid,unit,w,check)
 local insert = {}
 local titleColor = COLOR_LIGHTCYAN

 if     (grid == 'AX') then
  Info = getBaseInfo(unit)
  for h,s in pairs(Info) do
   insert = insertWidgetInput(insert, 'header', {header=h, second=s}, {width=w})
  end
 elseif (grid == 'AY') then
  Info = getDescriptionInfo(unit,w,'Basic')
  table.insert(insert,{text = {{text = center('Description',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info, {width=w})

 elseif (grid == 'AZ') then
  Info = getAttributeInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Attributes',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Physical, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Mental, {width=w})

 elseif (grid == 'BX') then
  Info = getMembershipInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Membership and Worship',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Membership, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Worship, {width=w})

 elseif (grid == 'BY') then
  Info = getApperanceInfo(unit,w,'Basic')
  table.insert(insert,{text = {{text = center('Appearance',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info, {width=w})

 elseif (grid == 'BZ') then
  Info = getSkillInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Skills',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Profession, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Misc, {width=w})
 
 elseif (grid == 'CX') then
  if check then
   Info = getClassInfo(unit,w,'Basic')
   table.insert(insert,{text = {{text = center('Class Information',w), width = w, pen=titleColor}}})
   insert = insertWidgetInput(insert, 'second', Info.Current, {width=w})
   table.insert(insert,{text = { {text = '', width=w}}})
   insert = insertWidgetInput(insert, 'second', Info.Classes, {width=w})
  end

 elseif (grid == 'CY') then
  Info = getHealthInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Health',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Injury, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Sickness, {width=w})

 elseif (grid == 'CZ') then
  Info = getStatResistanceInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Stats and Resistances',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Stats, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Resistances, {width=w})

 end

 return insert
end
