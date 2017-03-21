-- Creature Tokens
---- Biomes
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
---- Habitats
habitatFlags = {
AMPHIBIOUS = 'Amphibious',
AQUATIC = 'Aquatic',
GOOD = 'Living in good biomes',
EVIL = 'Living in evil biomes',
SAVAGE = 'Living in savage biomes'}
---- Activity
activeFlags = {
ALL_ACTIVE = 'At all times',
DIURNAL = 'During the day',
NOCTURNAL = 'During the night',
CREPUSCULAR = 'At dawn and dusk',
VESPERTINE = 'At dusk',
MATUTINAL = 'At dawn'}
---- Utility
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
---- Diet             
dietFlags = {
NO_EAT = "Doesn't need food",
NO_DRINK = "Doesn't need drink",
BONECARN = 'Eats meat and bones',
CARNIVORE = 'Only eats meat',
GRAZER = 'Eats grass',
GOBBLE_VERMIN = 'Eats vermin'}
---- Behavior
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
---- Movement
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
---- Immunities
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
---- Bonuses
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
---- Body Flags
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
---- Seasonal
seasonFlags = {
NO_SPRING = 'Absent during the spring',
NO_SUMMER = 'Absent during the summer',
NO_AUTUMN = 'Absent during the fall',
NO_WINTER = 'Absent during the winter'}
---- Types
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
---- Seasonal
seasonPlantFlags = {
SPRING = 'Grows during the spring',
SUMMER = 'Grows during the summer',
AUTUMN = 'Grows during the fall',
WINTER = 'Grows during the winter',}

-- Material Flags
---- Edible
materialEdibleFlags = {
EDIBLE_VERMIN = 'Vermin',
EDIBLE_RAW = 'Raw',
EDIBLE_COOKED = 'Cooked'
}
---- Items
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
ITEMS_HARD = 'Makes hard items'
}
---- Types
typeMaterialFlags = {
IS_METAL = 'Metal',
IS_GLASS = 'Glass',
IS_STONE = 'Stone'
}

-- Item Flags
---- Materials
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
CAN_STONE = 'Stone'
}
---- Uses
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
BOOKCASE = 'Hold Books'
}

unusedFlags = {
--AMPHIBIOUS = 'Amphibious',
--AQUATIC = 'Aquatic',
--LARGE_PREDATOR = 'A predator',
--FISHITEM = 'Needs to be cleaned',
--MILKABLE = 'Milkable',
--BENIGN = 'Benign',
--VERMIN_NOROAM = false
--VERMIN_NOTRAP = true
--VERMIN_NOFISH = false
--HAS_NERVES = true
--NO_UNIT_TYPE_COLOR = false
--NO_CONNECTIONS_FOR_MOVEMENT = false
--SECRETION = 'Secrets substance',
--BLOOD = 'Has blood',
--TRANCES = 'Can enter martial trances',
--NOSTUCKINS = 'Weapons can not get stuck',
--PUS = 'Has pus',
--ITEMCORPSE = 'Leaves a special corpse',
--GETS_WOUND_INFECTIONS = 'Wounds can become infected',
--NOSMELLYROT = 'Rot does not produce miasma',
--REMAINS_UNDETERMINED = false
--LAIR_HUNTER = 'Hunts adventurers in its lair',
--LIKES_FIGHTING = false
--VERMIN_HATEABLE = false
--MAGICAL = false
--NATURAL = 'Natural',
--BABY = false
--CHILD = false
--MULTIPLE_LITTER_RARE = false
--FEATURE_ATTACK_GROUP = false
--LAYS_EGGS = 'Lays eggs'
--MEGABEAST = false
--SEMIMEGABEAST = false
--ALL_ACTIVE = true
--DIURNAL = false
--NOCTURNAL = false
--CREPUSCULAR = false
--MATUTINAL = false
--VESPERTINE = false
--GETS_INFECTIONS_FROM_ROT = 'Can get infections from necrotic tissue',
--ALCOHOL_DEPENDENT = 'Needs alcohol to function',
--POWER = false
--CASTE_TILE = false
--CASTE_COLOR = false
--FEATURE_BEAST = false
--TITAN = false
--UNIQUE_DEMON = false
--DEMON = false
--MANNERISM_LAUGH = false
--MANNERISM_SMILE = false
--MANNERISM_WALK = false
--MANNERISM_SIT = false
--MANNERISM_BREATH = false
--MANNERISM_POSTURE = false
--MANNERISM_STRETCH = false
--MANNERISM_EYELIDS = false
--NIGHT_CREATURE_ANY = false
--NIGHT_CREATURE_HUNTER = false
--NIGHT_CREATURE_BOGEYMAN = false
--CONVERTED_SPOUSE = false
--SPOUSE_CONVERTER = false
--SPOUSE_CONVERSION_TARGET = false
--DIE_WHEN_VERMIN_BITE = 'Dies after attacking',
--REMAINS_ON_VERMIN_BITE_DEATH = false
--COLONY_EXTERNAL = 'Hovers around its colony',
--LAYS_UNUSUAL_EGGS = 'Lays a special egg',
--RETURNS_VERMIN_KILLS_TO_OWNER = 'Returns vermin to its owner',
--ADOPTS_OWNER = 'Adopts an owner',
--NO_PHYS_ATT_GAIN = 'Can not gain physical skills',
--NO_PHYS_ATT_RUST = 'Can not lose physical skills',
--BLOODSUCKER = 'Will drain blood from victims',
--NO_VEGETATION_PERTURB = false
--DIVE_HUNTS_VERMIN = 'Hunts vermin from the air',
--LOCAL_POPS_CONTROLLABLE = false
--OUTSIDER_CONTROLLABLE = false
--LOCAL_POPS_PRODUCE_HEROES = false
--STRANGE_MOODS = false
             }

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
  for first,_ in pairs(list) do
   table.insert(input,{text=first,pen=pen,width=width,rjustify=rjustify})
  end
 elseif method == 'second' then
  for _,second in pairs(list) do
   table.insert(input,{text=second,pen=pen,width=width,rjustify=rjustify})
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
 end
 return input
end

-- For CompendiumUi
function getShow(choice,frame) -- Gets the list of objects (creature, plant, item, material, etc...)
 if frame == 'Creatures' then
  return getShowCreatures(choice)
 elseif frame == 'Plants' then
  return getShowPlants(choice)
 elseif frame == 'Items' then
  return getShowItems(choice)
 elseif frame == 'Inorganics' then
  return getShowInorganics(choice)
 elseif frame == 'Food' then
  return getShowFood(choice)
 elseif frame == 'Organics' then
  return getShowOrganics(choice)
 elseif frame == 'Buildings' then
  return getShowBuildings(choice)
 elseif frame == 'Reactions' then
  return getShowReactions(choice)
 end
end

function getShowCreatures(choice)
 local creatureList = df.global.world.raws.creatures.all
 local creatures = {}
 local creatureNames = {}
 local creatureIDs = {}
 for id,creature in pairs(creatureList) do
  if choice == 'All Creatures' then
   creatures[#creatures+1] = creature
   creatureNames[#creatureNames+1] = creature.name[0]
   creatureIDs[#creatureIDs+1] = id
  elseif choice == 'GOOD Creatures' then
   if creature.flags.GOOD then
    creatures[#creatures+1] = creature
    creatureNames[#creatureNames+1] = creature.name[0]
    creatureIDs[#creatureIDs+1] = id
   end
  elseif choice == 'EVIL Creatures' then
   if creature.flags.EVIL then
    creatures[#creatures+1] = creature
    creatureNames[#creatureNames+1] = creature.name[0]
    creatureIDs[#creatureIDs+1] = id
   end
  elseif choice == 'SAVAGE Creatures' then
   if creature.flags.SAVAGE then
    creatures[#creatures+1] = creature
    creatureNames[#creatureNames+1] = creature.name[0]
    creatureIDs[#creatureIDs+1] = id
   end
  end
 end
 return creatures,creatureNames,creatureIDs
end

function getShowPlants(choice)
 local plants = {}
 local plantNames = {}
 local plantIDs = {}
 if choice == 'All Plants' then
  array = df.global.world.raws.plants.all
 elseif choice == 'Trees' then
  array = df.global.world.raws.plants.trees
 elseif choice == 'Bushes' then
  array = df.global.world.raws.plants.bushes
 elseif choice == 'Grasses' then
  array = df.global.world.raws.plants.grasses
 end
 for _,plant in pairs(array) do
  plants[#plants+1] = plant
  plantNames[#plantNames+1] = plant.name
  plantIDs[#plantIDs+1] = plant.anon_1
 end
 return plants,plantNames,plantIDs
end

function getShowItems(choice)
 local items = {}
 local itemNames = {}
 local itemIDs = {}
 if choice == 'All Items' then
  array = df.global.world.raws.itemdefs.all
 elseif choice == 'Weapons' then
  array = df.global.world.raws.itemdefs.weapons
 elseif choice == 'Helms' then
  array = df.global.world.raws.itemdefs.helms
 elseif choice == 'Armor' then
  array = df.global.world.raws.itemdefs.armor
 elseif choice == 'Gloves' then
  array = df.global.world.raws.itemdefs.gloves
 elseif choice == 'Pants' then
  array = df.global.world.raws.itemdefs.pants
 elseif choice == 'Shoes' then
  array = df.global.world.raws.itemdefs.shoes
 elseif choice == 'Shields' then
  array = df.global.world.raws.itemdefs.shields
 elseif choice == 'Ammo' then
  array = df.global.world.raws.itemdefs.ammo
 elseif choice == 'Siege Ammo' then
  array = df.global.world.raws.itemdefs.siege_ammo
 elseif choice == 'Trap Components' then
  array = df.global.world.raws.itemdefs.trapcomps
 elseif choice == 'Toys' then
  array = df.global.world.raws.itemdefs.toys
 elseif choice == 'Tools' then
  array = df.global.world.raws.itemdefs.tools
 elseif choice == 'Instruments' then
  array = df.global.world.raws.itemdefs.instruments
 elseif choice == 'Food' then
  array = df.global.world.raws.itemdefs.food
 end
 for _,item in pairs(array) do
  items[#items+1] = item
  itemNames[#itemNames+1] = item.name
  itemIDs[#itemIDs+1] = item.id
 end
 return items,itemNames,itemIDs
end

function getShowInorganics(choice)
 local materials = {}
 local materialNames = {}
 local materialIDs = {}
 array = df.global.world.raws.inorganics
 for id,inorganic in pairs(array) do
  if choice == 'All Inorganics' then
   materials[#materials+1] = inorganic
   materialNames[#materialNames+1] = inorganic.material.state_name.Solid
   materialIDs[#materialIDs+1] = id
  elseif choice == 'Metal' then
   if inorganic.material.flags.IS_METAL then
    materials[#materials+1] = inorganic
    materialNames[#materialNames+1] = inorganic.material.state_name.Solid
    materialIDs[#materialIDs+1] = id   
   end
  elseif choice == 'Glass' then
   if inorganic.material.flags.IS_GLASS then
    materials[#materials+1] = inorganic
    materialNames[#materialNames+1] = inorganic.material.state_name.Solid
    materialIDs[#materialIDs+1] = id   
   end  
  elseif choice == 'Stone' then
   if inorganic.material.flags.IS_STONE then
    materials[#materials+1] = inorganic
    materialNames[#materialNames+1] = inorganic.material.state_name.Solid
    materialIDs[#materialIDs+1] = id   
   end
  elseif choice == 'Gem' then
   if inorganic.material.flags.IS_GEM then
    materials[#materials+1] = inorganic
    materialNames[#materialNames+1] = inorganic.material.state_name.Solid
    materialIDs[#materialIDs+1] = id   
   end
  end
 end
 return materials,materialNames,materialIDs
end

function getShowOrganics(choice)
 local materials = {}
 local materialNames = {}
 local materialIDs = {}
 local x = df.global.world.raws.mat_table.organic_types
 local y = df.global.world.raws.mat_table.organic_indexes
 for i,mattype in pairs(x[choice]) do
  matindex = y[choice][i]
  material = dfhack.matinfo.decode(mattype,matindex).material
  materials[#materials+1] = material
  if choice == 'PlantLiquid' or choice == 'CreatureLiquid' or choice == 'MiscLiquid' then
   materialNames[#materialNames+1] = material.prefix..' '..material.state_name.Liquid
  else
   materialNames[#materialNames+1] = material.prefix..' '..material.state_name.Solid
  end
  materialIDs[#materialIDs+1] = {mattype,matindex}
 end
 return materials,materialNames,materialIDs
end

function getShowFood(choice)
 local materials = {}
 local materialNames = {}
 local materialIDs = {}
 local x = df.global.world.raws.mat_table.organic_types
 local y = df.global.world.raws.mat_table.organic_indexes
 local z = df.global.world.raws.creatures.all
 if choice == 'Eggs' or choice == 'Fish' or choice == 'UnpreparedFish' then
  for i,creatureID in pairs(x[choice]) do
   casteID = y[choice][i]
   caste = z[creatureID].caste[casteID]
   materials[#materials+1] = caste
   materialNames[#materialNames+1] = caste.caste_name[0]..' '..choice
   materialIDs[#materialIDs+1] = {creatureID,casteID}
  end
 else
  for i,mattype in pairs(x[choice]) do
   matindex = y[choice][i]
   material = dfhack.matinfo.decode(mattype,matindex).material
   materials[#materials+1] = material
   if choice == 'PlantDrink' or choice == 'CreatureDrink' or choice == 'AnyDrink' or choice == 'CookableLiquid' then
    materialNames[#materialNames+1] = material.prefix..' '..material.state_name.Liquid
   else
    materialNames[#materialNames+1] = material.prefix..' '..material.state_name.Solid
   end
   materialIDs[#materialIDs+1] = {mattype,matindex}
  end
 end
 return materials,materialNames,materialIDs
end

function getShowBuildings(choice)
 local buildings = {}
 local buildingNames = {}
 local buildingIDs = {}
 if choice == 'All Buildings' then
  array = df.global.world.raws.buildings.all
 elseif choice == 'Workshops' then
  array = df.global.world.raws.buildings.workshops
 elseif choice == 'Furnaces' then
  array = df.global.world.raws.buildings.furnaces
 end
 for _,building in pairs(array) do
  buildings[#buildings+1] = building
  buildingNames[#buildingNames+1] = building.name
  buildingIDs[#buildingIDs+1] = building.id
 end
 return buildings,buildingNames,buildingIDs
end

function getShowReactions(choice)
 local reactions = {}
 local reactionNames = {}
 local reactionIDs = {}
 if choice == 'All Reactions' then
  array = df.global.world.raws.reactions
 end
 for _,reaction in pairs(array) do
  reactions[#reactions+1] = reaction
  reactionNames[#reactionNames+1] = reaction.name
  reactionIDs[#reactionIDs+1] = reaction.index
 end
 return reactions,reactionNames,reactionIDs
end

function getSort(list,frame,choice)
 if frame == 'Creatures' then
  return getSortCreatures(list,choice)
 elseif frame == 'Plants' then
  return getSortPlants(list,choice)
 elseif frame == 'Items' then
  return getSortItems(list,choice)
 elseif frame == 'Inorganics' then
  return getSortInorganics(list,choice)
 elseif frame == 'Organics' then
  return getSortOrganics(list,choice)
 elseif frame == 'Food' then
  return getSortFood(list,choice)
 elseif frame == 'Buildings' then
  return getSortBuildings(list,choice)
 elseif frame == 'Reactions' then
  return getSortReactions(list,choice)
 end
end

function getSortCreatures(list,choice)
 local utils = require 'utils'
 local split = utils.split_string
 local out = {}
 for _,x in pairs(list) do
  for flag,check in pairs(x.flags) do
   if check then
    if choice == 'Biome' then
     if split(flag,'_')[1] == 'BIOME' then
      out[biomeTokens[flag]] = out[biomeTokens[flag]] or {}
      out[biomeTokens[flag]][#out[biomeTokens[flag]]+1] = x.name[0]
     end
    elseif choice == 'Type' then
     if typeCreatureFlags[flag] then
      out[flag] = out[flag] or {}
      out[flag][#out[flag]+1] = x.name[0]
     end
    end
   end
  end
 end
 return out
end

function getSortPlants(list,choice)
 local utils = require 'utils'
 local split = utils.split_string
 local out = {}
 for _,x in pairs(list) do
  for flag,check in pairs(x.flags) do
   if check then
    if choice == 'Biome' then
     if split(flag,'_')[1] == 'BIOME' then
      out[biomeTokens[flag]] = out[biomeTokens[flag]] or {}
      out[biomeTokens[flag]][#out[biomeTokens[flag]]+1] = x.name
     end
    end
   end
  end
 end 
 return out
end

function getSortItems(list,choice)
 local out = {}

 return out
end

function getSortInorganics(list,choice)
 local out = {}
 for _,x in pairs(list) do
  if choice == 'Environment' then
   for _,loc in pairs(x.environment.location) do
    out[df.environment_type[loc]] = out[df.environment_type[loc]] or {}
    out[df.environment_type[loc]][#out[df.environment_type[loc]]+1] = x.material.state_name.Solid
   end
   for _,loc in pairs(x.environment_spec.mat_index) do
    out[dfhack.matinfo.decode(0,loc).inorganic.id] = out[dfhack.matinfo.decode(0,loc).inorganic.id] or {}
    out[dfhack.matinfo.decode(0,loc).inorganic.id][#out[dfhack.matinfo.decode(0,loc).inorganic.id]] = x.material.state_name.Solid
   end
  end
 end
 return out
end

function getSortOrganics(list,choice)

end

function getSortFood(list,choice)

end

function getSortBuildings(list,choice)
 local out = {}

 if choice == 'Entity' then

 end

 return out
end

function getSortReactions(list,choice)
 local out = {}

 if choice == 'Building' then

 elseif choice == 'Entity' then

 end

 return out
end

function getEntry(name,dict,frame) -- Gets sub-objects of an object (castes for a creature, products for a plant, nothing for items, nothing for materials)
 id = dict[name]
 if frame == 'Creatures' then
  return getEntryCreature(id)
 elseif frame == 'Plants' then
  return getEntryPlant(id)
 elseif frame == 'Items' then
  return getEntryItems(id)
 elseif frame == 'Inorganics' then
  return getEntryInorganic(id)
 elseif frame == 'Organics' then
  return getEntryOrganic(id)
 elseif frame == 'Food' then
  return getEntryFood(id)
 elseif frame == 'Buildings' then
  return getEntryBuilding(id)
 elseif frame == 'Reactions' then
  return getEntryReaction(id)
 end
end

function getEntryCreature(id)
 print(id)
 local creature = df.global.world.raws.creatures.all[id]
 local castes = {}
 if not creature then 
  return nil, nil
 end
 for _,caste in pairs(creature.caste) do
  if caste.gender == 0 then
   castes[#castes+1] = caste.caste_name[0]..' (F)'
  elseif caste.gender == 1 then
   castes[#castes+1] = caste.caste_name[0]..' (M)'
  else
   castes[#castes+1] = caste.caste_name[0]..' (N)'
  end
 end
 return creature, castes
end

function getEntryPlant(id)
 local plant = df.global.world.raws.plants.all[id]
 local products = {}
 if not plant then 
  return nil, nil
 end
--[[
 for _,material in pairs(plant.material) do
  if material.flags.LIQUID_MISC or material.flags.ALCOHOL then
   mat_name = material.state_name.Liquid
  else
   mat_name = material.state_name.Solid
  end
  a = string.gsub(mat_name,'%p','')
  b = string.gsub(name,'%p','')
  if string.find(a,b) then
   product = mat_name
  else
   product = name..' '..mat_name
  end
  products[#products+1] = product
 end
]]
 products = {plant.name}
 return plant, products
end

function getEntryItems(id)
 local item = nil
 local item2 = {}
 for _,x in pairs(df.global.world.raws.itemdefs.all) do
  if x.id == id then
   item = x
   break
  end
 end
 if not item then
  return nil,nil
 end
 item2 = {item.name}
 return item,item2
end

function getEntryInorganic(id)
 local material = df.global.world.raws.inorganics[id]
 local material2 = {}
 if not material then
  return nil,nil
 end
 material2 = {material.material.state_name.Solid}
 return material,material2
end

function getEntryOrganic(id)

end

function getEntryFood(id)

end

function getEntryBuilding(id)
 local building = nil
 local building2 = {}
 
 if not building then
  return nil,nil
 end
 building2 = {building.name}
 return building,building2
end

function getEntryReaction(id)
 local reaction = nil
 local reaction2 = {}
 
 if not reaction then
  return nil,nil
 end
 reaction2 = {reaction.name}
 return reaction,reaction2
end

function getDetails(frame,entry,index) -- Gets details for creatures, plants, items, materials
 if frame == 'Creatures' then
  info = getCreatureDetails(entry,index)
  return makeCreatureOutput(info)
 elseif frame == 'Plants' then
  info = getPlantDetails(entry)
  return makePlantOutput(info)
 elseif frame == 'Items' then
  info = getItemDetails(entry)
  return makeItemOutput(info)
 elseif frame == 'Inorganics' then
  info = getInorganicDetails(entry)
  return makeInorganicOutput(info)
 elseif frame == 'Organics' then
  info = getOrganicDetails(entry)
  return makeOrganicOutput(info)
 elseif frame == 'Food' then
  info = getFoodDetails(entry)
  return makeFoodOutput(info)
 elseif frame == 'Buildings' then
  info = getBuildingDetails(entry)
  return makeBuildingOutput(info)
 elseif frame == 'Reactions' then
  info = getReactionDetails(entry)
  return makeReactionOutput(info)
 end
end

function getItemDetails(item)
 local input = {}
 local input2 = {}
 local header = {}
 local persistTable = require 'persist-table'
 local gt = persistTable.GlobalTable
 local temp = {}
 for key,val in pairs(item) do
  temp[key] = val
 end
 item = temp
 local info = {}
 info.header = ''
 info.name = item.name or ''
 info.class = ''
 info.description = item.description or ''
 info.armorlevel = item.armorlevel or ''
 info.upstep = item.upstep or ''
 info.ubstep = item.ubstep or ''
 info.lbstep = item.lbstep or ''
 info.value = item.value or ''
 info.size = item.size or ''
 info.materialsize = item.material_size or ''
 info.level = item.level or ''
 info.layer = ''
 info.layersize = ''
 info.layerpermit = ''
 info.coverage = ''
 if item.props then
  info.layer = item.props.layer
  info.layersize = item.props.layer_size
  info.layerpermit = item.props.layer_permit
  info.coverage = item.props.coverage
 end
 info.ammoclass = item.ammo_class or ''
 info.blockchance = item.blockchance or ''
 info.twohanded = item.two_handed or ''
 info.minimumsize = item.minimum_size or ''
 info.shootforce = item.shoot_force or ''
 info.shootvelocity = item.shoot_maxvel or ''
 info.capacity = item.container_capacity or ''
 info.hits = item.hits or ''
 -- Get Attacks
 info.attacks = {}
 if item.attacks then
  for _,attack in pairs(item.attacks) do
   info.attacks[#info.attacks+1] = attack.verb_2nd
  end
 end
 -- Get Flags
 info.flags = {}
 if item.props then
  for flag,check in pairs(item.props.flags) do
   if check then
    info.flags[#info.flags+1] = flag
   end
  end
 end
 if item.flags then
  for flag,check in pairs(item.flags) do
   if check then
    info.flags[#info.flags+1] = flag
   end
  end
 end
 if item.base_flags then
  for flag,check in pairs(item.base_flags) do
   if check then
    info.flags[#info.flags+1] = flag
   end
  end
 end
 if item.tool_use then
  for _,id in pairs(item.tool_use) do
   info.flags[#info.flags+1] = df.tool_uses[id]
  end
 end
 return info
end

function makeItemOutput(info)
 local utils = require 'utils'
 local split = utils.split_string
 local input = {}
 local input2 = {}
 local header = {}
-- Header Information
 table.insert(header,{text={{text=center(info.header,85),pen=COLOR_LIGHTRED,width=85}}})
 table.insert(header,{text={{text=center('Description',85),width=85,pen=COLOR_YELLOW}}})
 for _,second in pairs(split(info.description,'\n')) do
  table.insert(header,{text={{text=second,pen=COLOR_WHITE,width=85}}})
 end
-- Left Column Information (Name, Class, Value, Material Size, Materials, Uses) 
 table.insert(input,{text={{text=center('Details',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='Item Name:',second=info.name},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Class:',second=info.class},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Value:',second=info.value},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Material Size:',second=info.materialsize},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Size:',second=info.size},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Container Capacity:',second=info.capacity},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Materials:',second=info.flags},{replacement=itemCraftFlags,pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Uses:',second=info.flags},{replacement=itemUseFlags,pen=COLOR_LIGHTGREEN})
-- Right Column Information (Offensive Stats, Defensive Stats, Instrument Stats)
 table.insert(input2,{text={{text=center('Offensive Details',40),width=40,pen=COLOR_YELLOW}}})
 input2 = insertWidgetInput(input2,'header',{header='Min Size:',second=info.minimumsize},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Two Handed:',second=info.twohanded},{pen=COLOR_LIGHTGREEN}) 
 input2 = insertWidgetInput(input2,'header',{header='Attacks:',second=info.attacks},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Ammo Class:',second=info.ammoclass},{pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Hits:',second=info.hits},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Shoot Force:',second=info.shootforce},{pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Shoot Velocity:',second=info.shootvelocity},{pen=COLOR_LIGHTCYAN})
 table.insert(input2,{text={{text=center('Defensive Details',40),width=40,pen=COLOR_YELLOW}}})
 input2 = insertWidgetInput(input2,'header',{header='Block Chance:',second=info.blockchance},{pen=COLOR_LIGHTCYAN}) 
 input2 = insertWidgetInput(input2,'header',{header='Layer:',second=info.layer},{pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Layer Size:',second=info.layersize},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Layer Permit:',second=info.layerpermit},{pen=COLOR_LIGHTGREEN}) 
 input2 = insertWidgetInput(input2,'header',{header='Armor Level:',second=info.armorlevel},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Coverage:',second=info.coverage},{pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Up Step:',second=info.upstep},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='UB Step:',second=info.ubstep},{pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='LB Step:',second=info.lbstep},{pen=COLOR_LIGHTCYAN})
 return header,input,input2
end

function getInorganicDetails(inorganic)
 local persistTable = require 'persist-table'
 local gt = persistTable.GlobalTable
 local info = {}
 info.header = ''
 info.description = ''
 info.class = ''
 info.rarity = ''
 info.name = inorganic.material.state_name.Solid
 info.solid_density = inorganic.material.solid_density
 info.liquid_density = inorganic.material.liquid_density
 info.molar_mass = inorganic.material.molar_mass
 info.value = inorganic.material.material_value
 info.absorption = inorganic.material.strength.absorption
 info.maxedge = inorganic.material.strength.max_edge
 info.yield = inorganic.material.strength.yield
 info.fracture = inorganic.material.strength.fracture
 info.strain = inorganic.material.strength.strain_at_yield
 info.specheat = inorganic.material.heat.spec_heat
 info.heatdam = inorganic.material.heat.heatdam_point
 info.colddam = inorganic.material.heat.colddam_point
 info.ignite = inorganic.material.heat.ignite_point
 info.melting = inorganic.material.heat.melting_point
 info.boiling = inorganic.material.heat.boiling_point
 info.fixedtemp = inorganic.material.heat.mat_fixed_temp
 -- Get Reaction Products
 info.reactionproducts = {}
 for id,x in pairs(inorganic.material.reaction_product.id) do
  mattype = inorganic.material.reaction_product.material.mat_type[id]
  matindex = inorganic.material.reaction_product.material.mat_index[id]
  mat = dfhack.matinfo.decode(0,30).material
  info.reactionproducts[#info.reactionproducts+1] = x.value..' '..mat.state_name.Solid
 end
 -- Get Reaction Classes
 info.reactionclasses = {}
 for _,class in pairs(inorganic.material.reaction_class) do
  info.reactionclasses[#info.reactionclasses+1] = class.value
 end
 -- Get Syndromes
 info.syndromes = {}
 for _,syndrome in pairs(inorganic.material.syndrome) do
  info.syndromes[#info.syndromes+1] = syndrome.syn_name
 end
 -- Get Flags
 info.flags = {}
 for flag,check in pairs(inorganic.material.flags) do
  if check then
   info.flags[#info.flags+1] = flag
  end
 end
 for flag,check in pairs(inorganic.flags) do
  if check then
   info.flags[#info.flags+1] = flag
  end
 end
 -- 
 if safe_index(gt,"roses","EnhancedMaterialTable","Inorganic",inorganic.id) then
  materialTable = gt.roses.EnhancedMaterialTable.Inorganic[inorganic.id]
  if materialTable.Description then info.description = materialTable.Description end
  if materialTable.Class then info.class = materialTable.Class end
  if materialTable.Rarity then info.rarity = materialTable.Rarity end
 end
 return info
end

function makeInorganicOutput(info)
 local utils = require 'utils'
 local split = utils.split_string
 local input = {}
 local input2 = {}
 local header = {}
-- Header Information
 table.insert(header,{text={{text=center(info.header,85),pen=COLOR_LIGHTRED,width=85}}})
 table.insert(header,{text={{text=center('Description',85),width=85,pen=COLOR_YELLOW}}})
 for _,second in pairs(split(info.description,'\n')) do
  table.insert(header,{text={{text=second,pen=COLOR_WHITE,width=85}}})
 end
-- Left Column Information 
 table.insert(input,{text={{text=center('Details',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='Item Name:',second=info.name},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Class:',second=info.class},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Rarity:',second=info.rarity},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Value:',second=info.value},{pen=COLOR_LIGHTGREEN})
 table.insert(input,{text={{text=center('Densities',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='Solid Density:',second=info.solid_density},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Liquid Density:',second=info.liquid_density},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Molar Mass:',second=info.molar_mass},{pen=COLOR_LIGHTCYAN})
 table.insert(input,{text={{text=center('Temperatures',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='Specific Heat:',second=info.specheat},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Fixed Temp:',second=info.fixedtemp},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='HeatDam Point:',second=info.heatdam},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='ColdDam Point:',second=info.colddam},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Ignite Point:',second=info.ignite},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Melting Point:',second=info.melting},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Boiling Point:',second=info.boiling},{pen=COLOR_LIGHTGREEN})
 table.insert(input,{text={{text=center('Syndromes',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='',second=info.syndromes},{pen=COLOR_LIGHTCYAN})
 table.insert(input,{text={{text=center('Reaction Classes',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='',second=info.reactionclasses},{pen=COLOR_LIGHTGREEN})
 table.insert(input,{text={{text=center('Reaction Products',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='',second=info.reactionproducts},{pen=COLOR_LIGHTCYAN})
-- Right Column Information
 table.insert(input2,{text={{text=center('Numbers',40),width=40,pen=COLOR_YELLOW}}})
 input2 = insertWidgetInput(input2,'header',{header='Max Edge:',second=info.maxedge},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Absorption:',second=info.absorption},{pen=COLOR_LIGHTGREEN})
 table.insert(input2,{text={{text=center('Strain',40),width=40,pen=COLOR_YELLOW}}})
 for key,val in pairs(info.strain) do
  input2 = insertWidgetInput(input2,'header',{header=key..':',second=tostring(val)},{pen=COLOR_LIGHTCYAN})
 end
 table.insert(input2,{text={{text=center('Fracture',40),width=40,pen=COLOR_YELLOW}}})
 for key,val in pairs(info.fracture) do
  input2 = insertWidgetInput(input2,'header',{header=key..':',second=tostring(val)},{pen=COLOR_LIGHTGREEN})
 end
 table.insert(input2,{text={{text=center('Yield',40),width=40,pen=COLOR_YELLOW}}})
 for key,val in pairs(info.yield) do
  input2 = insertWidgetInput(input2,'header',{header=key..':',second=tostring(val)},{pen=COLOR_LIGHTCYAN})
 end
 return header,input,input2
end

function getOrganicDetails(building)
 local info = {}
 
 return info
end

function makeOrganicOutput(info)
 local input = {}
 local input2 = {}
 local header = {}

 return header,input,input2
end

function getFoodDetails(building)
 local info = {}
 
 return info
end

function makeFoodOutput(info)
 local input = {}
 local input2 = {}
 local header = {}

 return header,input,input2
end

function getBuildingDetails(building)
 local info = {}
 
 return info
end

function makeBuildingOutput(info)
 local input = {}
 local input2 = {}
 local header = {}

 return header,input,input2
end

function getReactionDetails(reaction)
 local info = {}
 
 return info
end

function makeReactionOutput(info)
 local input = {}
 local input2 = {}
 local header = {}

 return header,input,input2
end

function getCreatureDetails(creature,caste) -- Gets all the details of a creature/caste combination
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 local gt = persistTable.GlobalTable
 local creature = creature
 if caste then caste = creature.caste[caste] end
 local info = {}
 info.creaturename = creature.name[0]
 info.castename = ''
 info.attacks = {}
 info.flags = {}
 info.interactions = {}
 info.biomes = {}
 info.products = {}
 info.butcher_corpse = {}
 info.extra_butcher = {}
 info.attributes = {}
 info.skills = {}
 info.item_corpse = ''
 info.description = ''
-- Get Caste Specific Information
 if caste then
  info.header = 'Press ESC to Return to Creature Details and List'
  info.castename = caste.caste_name[0]
-- Get Corpse, Butcher Results, and Extra Butcher Objects
  info.item_corpse = dfhack.script_environment('functions/unit').getItemCorpse(caste)
  if info.item_corpse == 'Corpse' then
   info.butcher_corpse[#info.butcher_corpse+1] = 'Butcher Products'
   info.butcher_corpse[#info.butcher_corpse+1] = 'will go here'
  else
   info.butcher_corpse[#info.butcher_corpse+1] = 'NA'
  end
  info.extra_butcher[1] = 'Extra Butcher Objects'
  info.extra_butcher[2] = 'will go here'
-- Get Products (milk, eggs, honey, etc...), Extracts, and Special Attack Injections
  if caste.extracts.milkable_mat >= 0 then
   matinfo = dfhack.matinfo.decode(caste.extracts.milkable_mat,caste.extracts.milkable_matidx)
   c = matinfo.creature.name[0]
   m = matinfo.material.state_name.Solid
   info.products[#info.products+1] = c..' '..m
  end
  if caste.extracts.webber_mat >= 0 then
   matinfo = dfhack.matinfo.decode(caste.extracts.webber_mat,caste.extracts.webber_matidx)
   c = matinfo.creature.name[0]
   m = matinfo.material.state_name.Solid
   info.products[#info.products+1] = c..' '..m
  end
  for i,matid in ipairs(caste.extracts.extract_mat) do
   matinfo = dfhack.matinfo.decode(matid,caste.extracts.extract_matidx[i])
   c = matinfo.creature.name[0]
   m = matinfo.material.state_name.Liquid
   info.products[#info.products+1] = c..' '..m
  end
  for _,attack in pairs(caste.body_info.attacks) do
   for i,special in pairs(attack.specialattack_mat_type) do
    matinfo = dfhack.matinfo.decode(special[i],attack.specialattack_mat_index[i])
    m = matinfo.material.state_name.Liquid
    info.products[#info.products+1] = m
   end
  end
-- Get Numbers (Size, Age, Skills, Attributes, etc...)
  info.adultsize = caste.misc.adult_size/100
  info.maxage = (caste.misc.maxage_min + caste.misc.maxage_max)/2
  if info.maxage <= 0 then 
   info.maxage = 'NA'
  else
   info.maxage = tostring(info.maxage)..' years'
  end
  for attribute,x in pairs(caste.attributes.phys_att_range) do
   if safe_index(gt,"roses","EnhancedCreatureTable",creature.creature_id,caste.caste_id,attribute) then
    info.attributes[attribute] = table.concat(gt.roses.EnhancedCreatureTable[creature.creature_id][caste.caste_id][attribute],':')
   else
    a = {x[0],x[3],x[6]}
    info.attributes[attribute] = table.concat(a,':')
   end
  end
  for attribute,x in pairs(caste.attributes.ment_att_range) do
   if safe_index(gt,"roses","EnhancedCreatureTable",creature.creature_id,caste.caste_id,attribute) then
    info.attributes[attribute] = table.concat(gt.roses.EnhancedCreatureTable[creature.creature_id][caste.caste_id][attribute],':')
   else
    a = {x[0],x[3],x[6]}
    info.attributes[attribute] = table.concat(a,':')
   end
  end
-- Get Possible Classes
  if safe_index(gt,"roses","EnhancedCreatureTable",creature.creature_id,caste.caste_id,"Classes") then
   info.classes = {}
   for _,x in pairs(gt.roses.EnhancedCreatureTable[creature.creature_id][caste.caste_id].Classes._children) do
    if safe_index(gt,"roses","ClassTable",x) then
     key = gt.roses.ClassTable[x].Name
    else
     key = x
    end
    info.classes[key] = gt.roses.EnhancedCreatureTable[creature.creature_id][caste.caste_id].Classes[x].Level
   end
  end
-- Get Description broken into multiple lines
  local n = math.floor(#caste.description/85)+1
  for i = 1,n do
   info.description = info.description..string.sub(caste.description,1+85*(i-1),85*i)..'\n'
  end
-- Get names of attacks
  for _,attack in pairs(caste.body_info.attacks) do
   info.attacks[attack.name] = attack.verb_2nd
  end
-- Get names of interactions
  for _,interaction in pairs(caste.body_info.interactions) do
   info.interactions[#info.interactions+1] = interaction.unk.adv_name
  end
-- Get Creature and Caste flags
  for flag,check in pairs(creature.flags) do
   if check then
    info.flags[#info.flags+1] = flag
   end
  end
  for flag,check in pairs(caste.flags) do
   if check then
    info.flags[#info.flags+1] = flag
   end
  end
-- Get Biomes from the actual raws
  for _,line in pairs(creature.raws) do
   if split(line.value,':')[1] == '[BIOME' then
    info.biomes[#info.biomes+1] = split(split(line.value,':')[2],']')[1]
   end
  end
  if #info.biomes == 0 then info.biomes = info.flags end
 else
  info.header = 'Press ENTER to View Caste Information'
 end
 return info
end

function makeCreatureOutput(info)
 local utils = require 'utils'
 local split = utils.split_string
 local input = {}
 local input2 = {}
 local header = {}
-- Header Information (Creature Description)
 table.insert(header,{text={{text=center(info.header,85),pen=COLOR_LIGHTRED,width=85}}})
 table.insert(header,{text={{text=center('Description',85),width=85,pen=COLOR_YELLOW}}})
 for _,second in pairs(split(info.description,'\n')) do
  table.insert(header,{text={{text=second,pen=COLOR_WHITE,width=85}}})
 end
-- Left Column Information (Name, Lifespan, Size, Environment, Attributes, Natural Skills, Available Classes)
 table.insert(input,{text={{text=center('Details',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='Creature Name:',second=info.creaturename},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Caste Name:',second=info.castename},{pen=COLOR_LIGHTGREEN})
 table.insert(input,{text={{text=center('Numbers',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='Average Life:',second=info.maxage},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Adult Size:',second=tostring(info.adultsize)..' kg'},{pen=COLOR_LIGHTGREEN})
 table.insert(input,{text={{text=center('Environment ',40),width=40,pen=COLOR_YELLOW}}})
 input = insertWidgetInput(input,'header',{header='Biomes:',second=info.biomes},{replacement=biomeTokens,pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Habitat:',second=info.flags},{replacement=habitatFlags,pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Seasons:',second=info.flags},{replacement=seasonFlags,pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Active Times:',second=info.flags},{replacement=activeFlags,pen=COLOR_LIGHTGREEN})
 table.insert(input,{text={{text=center('Attributes',40),width=40,pen=COLOR_YELLOW}}})
 color = COLOR_LIGHTCYAN
 for key,val in pairs(info.attributes) do
  input = insertWidgetInput(input,'header',{header=string.lower(key),second=val},{pen=color})
  if color == COLOR_LIGHTCYAN then 
   color = COLOR_LIGHTGREEN
  else
   color = COLOR_LIGHTCYAN
  end
 end
 table.insert(input,{text={{text=center('Natural Skills',40),width=40,pen=COLOR_YELLOW}}})
 skills = 0
 for key,val in pairs(info.skills) do
  input = insertWidgetInput(input,'header',{header=string.lower(key),second=val},{pen=color})
  if color == COLOR_LIGHTCYAN then 
   color = COLOR_LIGHTGREEN
  else
   color = COLOR_LIGHTCYAN
  end
  skills = skills + 1
 end
 if skills == 0 then
  table.insert(input,{text={{text=center('No Natural Skills',40),width=40,pen=color}}})
 end
 if info.classes then
  table.insert(input,{text={{text=center('Available Classes',40),width=40,pen=COLOR_YELLOW}}})
  for key,val in pairs(info.classes) do
   input = insertWidgetInput(input,'header',{header=string.lower(key),second=val},{pen=color})
   if color == COLOR_LIGHTCYAN then
    color = COLOR_LIGHTGREEN
   else
    color = COLOR_LIGHTCYAN
   end
  end
 end
-- Right Column Information (Attacks, Interactions, Flags, Corpse, Products, Extracts)
 table.insert(input2,{text={{text=center('Attacks and Interactions',40),width=40,pen=COLOR_YELLOW}}})
 input2 = insertWidgetInput(input2,'header',{header='Attacks:',second=info.attacks},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Interactions:',second=info.interactions},{pen=COLOR_LIGHTGREEN}) 
 table.insert(input2,{text={{text=center('Flags',40),width=40,pen=COLOR_YELLOW}}})
 input2 = insertWidgetInput(input2,'header',{header='Utility Flags:',second=info.flags},{replacement=utilityFlags,fill='flags',pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Behavior Flags:',second=info.flags},{replacement=behaviorFlags,fill='flags',pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Diet Flags:',second=info.flags},{replacement=dietFlags,fill='flags',pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Movement Flags:',second=info.flags},{replacement=movementFlags,fill='flags',pen=COLOR_LIGHTCYAN})
 table.insert(input2,{text={{text=center('Corpse, Products, and Extracts',40),width=40,pen=COLOR_YELLOW}}})
 table.insert(input2,{text={{text='Corpse:',width=10,pen=COLOR_LIGHTGREEN},{text=info.item_corpse,rjustify=true,width=30,pen=COLOR_LIGHTGREEN}}})
 input2 = insertWidgetInput(input2,'header',{header='Butcher Parts:',second=info.butcher_corpse},{pen=COLOR_LIGHTCYAN})
 input2 = insertWidgetInput(input2,'header',{header='Extra Butcher:',second=info.extra_butcher},{pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Extracts:',second=info.products},{pen=COLOR_LIGHTCYAN})
 return header,input,input2
end

function getPlantDetails(plant)
 local persistTable = require 'persist-table'
 local gt = persistTable.GlobalTable
 local info = {}
 info.flags = {}
 info.growths = {}
 info.description = 'None'
 info.class = '--'
 info.rarity = '--'
 info.name = plant.name
 info.header = ''
 info.growdur = plant.growdur
 info.value = plant.value
 info.frequency = plant.frequency
 info.clustersize = plant.clustersize
 info.products = {}
-- Check for Enhanced Material Plant
 if safe_index(gt,"roses","EnhancedMaterialTable","Plant",plant.id,"ALL") then
  local plantTable = gt.roses.EnhancedMaterialTemplate.Plants[plant.id].ALL
  if plantTable.Description then info.description = plantTable.Description end
  if plantTable.Class then info.description = plantTable.Class end
  if plantTable.Rarity then info.rarity = plantTable.Rarity end
  if plantTable.Name then info.name = plantTable.Name end
 end
-- Get Flags
 for flag,check in pairs(plant.flags) do
  if check then
   info.flags[#info.flags+1] = flag
  end
 end
-- Get Growths
 for _,growth in pairs(plant.growths) do
  info.growths[#info.growths+1] = growth.name
 end
-- Get Products
 if plant.material_defs.type_basic_mat >= 0 then info.structure = 'Structural Mat' end
 if plant.material_defs.type_tree >= 0 then info.products[#info.products+1] = dfhack.matinfo.decode(plant.material_defs.type_tree,plant.material_defs.idx_tree).material.state_name.Solid end
 if plant.material_defs.type_drink >= 0 then info.products[#info.products+1] = dfhack.matinfo.decode(plant.material_defs.type_drink,plant.material_defs.idx_drink).material.state_name.Liquid end
 if plant.material_defs.type_thread >= 0 then info.products[#info.products+1] = dfhack.matinfo.decode(plant.material_defs.type_thread,plant.material_defs.idx_thread).material.state_name.Solid end
 if plant.material_defs.type_mill >= 0 then info.products[#info.products+1] = dfhack.matinfo.decode(plant.material_defs.type_mill,plant.material_defs.idx_mill).material.state_name.Solid end
 if plant.material_defs.type_extract_vial >= 0 then info.products[#info.products+1] = dfhack.matinfo.decode(plant.material_defs.type_extract_vial,plant.material_defs.idx_extract_vial).material.state_name.Solid end
 if plant.material_defs.type_extract_barrel >= 0 then info.products[#info.products+1] = dfhack.matinfo.decode(plant.material_defs.type_extract_barrel,plant.material_defs.idx_extract_barrel).material.state_name.Solid end
 if plant.material_defs.type_extract_still_vial >= 0 then info.products[#info.products+1] = dfhack.matinfo.decode(plant.material_defs.type_extract_still_vial,plant.material_defs.idx_extract_still_vial).material.state_name.Solid end
 return info
end

function makePlantOutput(info)
 local input = {}
 local input2 = {}
 local header = {}
-- Header Information
 table.insert(header,{text={{text=center(info.header,85),pen=COLOR_LIGHTRED,width=85}}})
 table.insert(header,{text={{text=center('Description',85),pen=COLOR_YELLOW,width=85}}})
 table.insert(header,{text={{text=info.description,pen=COLOR_WHITE,width=85}}})
-- Left Column Information (Name, Class, Rarity, Numbers, Environment)  
 table.insert(input,{text={{text=center('Details',40),pen=COLOR_YELLOW,width=40}}})
 input = insertWidgetInput(input,'header',{header='Plant Name:',second=info.name},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Class:',second=info.class},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Rarity:',second=info.rarity},{pen=COLOR_LIGHTCYAN})
 table.insert(input,{text={{text=center('Numbers',40),pen=COLOR_YELLOW,width=40}}})
 input = insertWidgetInput(input,'header',{header='Value:',second=info.value},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Frequency:',second=info.frequency},{pen=COLOR_LIGHTCYAN})
 input = insertWidgetInput(input,'header',{header='Cluster Size:',second=info.clustersize},{pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Grow Duration:',second=info.growdur},{pen=COLOR_LIGHTCYAN})
 table.insert(input,{text={{text=center('Environment',40),pen=COLOR_YELLOW,width=40}}})
 input = insertWidgetInput(input,'header',{header='Biomes:',second=info.flags},{replacement=biomeTokens,pen=COLOR_LIGHTGREEN})
 input = insertWidgetInput(input,'header',{header='Seasons:',second=info.flags},{replacement=seasonPlantFlags,pen=COLOR_LIGHTCYAN})
-- Right Column Information (Products and Growths)
 table.insert(input2,{text={{text=center('Products and Growths',40),pen=COLOR_YELLOW,width=40}}})
 input2 = insertWidgetInput(input2,'header',{header='Products:',second=info.products},{pen=COLOR_LIGHTGREEN})
 input2 = insertWidgetInput(input2,'header',{header='Growths:',second=info.growths},{pen=COLOR_LIGHTCYAN})
 return header, input, input2
end

-- For UnitViewUi
function getUnitName(unit,translate)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 name = dfhack.units.getVisibleName(unit)
 name = dfhack.TranslateName(name,translate)
 return name,nickname
end

function getCasteName(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 race = df.global.world.raws.creatures.all[tonumber(unit.race)].name[0]
 if unit.sex == 1 then 
  sex = 'Male '
 elseif unit.sex == 0 then 
  sex = 'Female ' 
 else
  sex = ''
 end
 caste = df.global.world.raws.creatures.all[tonumber(unit.race)].caste[tonumber(unit.caste)].caste_name[0]
 name = race:gsub("^%l", string.upper)..', '..sex..caste:gsub("(%a)([%w_']*)", tchelper)
 return name
end

function getSyndromes(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 syn = {}
 syn_detail = {}
 for i,x in pairs(unit.syndromes.active) do
  curticks = x.ticks
  endticks = -1
  for j,y in pairs(df.global.world.raws.syndromes.all[tonumber(x.type)].ce) do
   if y['end'] > endticks then endticks = y['end'] end
  end
  if endticks == -1 then
   duration = 'Permenant'
  else
   duration = tostring(endticks-curticks)
  end
  syn[i+1] = {df.global.world.raws.syndromes.all[tonumber(x.type)].syn_name:gsub("(%a)([%w_']*)", tchelper),duration,curticks}
  if syn[i+1][1] == '' then
   syn[i+1][1] = 'Unknown'
  end
  syn_detail[i+1] = df.global.world.raws.syndromes.all[tonumber(x.type)].ce
 end
 if #syn == 0 then
  syn[1] = {'None','',''}
  syn_detail[1] = {}
 end
 return syn, syn_detail
end

function getInteractions(unit)
 local utils = require 'utils'
 local split = utils.split_string
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 ints = {}
 t_ints = {}
 for i,x in pairs(df.global.world.raws.creatures.all[tonumber(unit.race)].caste[tonumber(unit.caste)].body_info.interactions) do
  s = -1
  check = false
  name = false
  for j,y in pairs(df.global.world.raws.creatures.all[tonumber(unit.race)].raws) do
   if split(y.value,':')[1] == '[CAN_DO_INTERACTION' then
    s = s + 1
    if s == i then
     check = true
    elseif s > i then
     break
    end
   end
   if check then
    if split(y.value,':')[2] == 'ADV_NAME' then
     ints[i+1] = split(split(y.value,':')[3],']')[1]
     name = true
	end
   end
  end
  if not name then
   ints[i+1] = 'Unknown'
  end
 end
 if #ints == 0 then
  ints[1] = 'None'
 end
 s = 0
 for i,x in pairs(unit.syndromes.active) do
  for j,y in pairs(df.global.world.raws.syndromes.all[tonumber(x.type)].ce) do
   if y._type == df['creature_interaction_effect_can_do_interactionst'] then
    t_ints[s+1] = y.name
	s = s + 1
   end
  end
 end 
 if #t_ints == 0 then
  t_ints[1] = 'None'
 end
 return ints, t_ints
end

function getAttributes(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 p_atts = {}
 m_atts = {}
 local persistTable = require 'persist-table'
 if persistTable.GlobalTable.roses then
  for i,x in pairs(unit.body.physical_attrs) do
   local total,base,change,class,item,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,i,nil,nil,nil,nil,'get')
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)] = {}
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Base'] = base
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Current'] = total
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Class'] = class
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Item'] = item
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Syndrome'] = syndrome
  end
  for i,x in pairs(unit.status.current_soul.mental_attrs) do
   local total,base,change,class,item,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,i,nil,nil,nil,nil,'get')
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)] = {}
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Base'] = base
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Current'] = total
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Class'] = class
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Item'] = item
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Syndrome'] = syndrome
  end
 else
  for i,x in pairs(unit.body.physical_attrs) do
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)] = {}
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Base'] = dfhack.units.getPhysicalAttrValue(unit,df.physical_attribute_type[i])
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Current'] = dfhack.units.getPhysicalAttrValue(unit,df.physical_attribute_type[i])
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Class'] = 0
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Item'] = 0
   p_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Syndrome'] = 0
  end
  for i,x in pairs(unit.status.current_soul.mental_attrs) do
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)] = {}
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Base'] = dfhack.units.getMentalAttrValue(unit,df.mental_attribute_type[i])
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Current'] = dfhack.units.getMentalAttrValue(unit,df.mental_attribute_type[i])
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Class'] = 0
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Item'] = 0
   m_atts[i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)]['Syndrome'] = 0
  end
 end
 return p_atts, m_atts
end

function getSkills(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 skl = {}
 for i,x in pairs(unit.status.current_soul.skills) do
  skl[df.job_skill.attrs[x.id].caption_noun] = {df.skill_rating[dfhack.units.getEffectiveSkill(unit,x.id)],dfhack.units.getExperience(unit,x.id),df.job_skill[x.id]}
 end
 return skl
end

function getEntity(unit,translate)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 ent = ''
 civ = ''
 mem = ''
 if unit.civ_id >= 0 then
  ent = df.global.world.entities.all[unit.civ_id].name
  ent = dfhack.TranslateName(ent,translate)
 end
 if unit.population_id >= 0 then
  civ = df.global.world.entity_populations[unit.population_id].name
  civ = dfhack.TranslateName(civ,translate)
 end
 if unit.hist_figure_id >= 0 then
  hf = df.global.world.history.figures[unit.hist_figure_id]
  for _,link in pairs(hf.entity_links) do
   if link.entity_id ~= unit.civ_id then
    mem = df.global.world.entities.all[link.entity_id].name
    mem = dfhack.TranslateName(mem,translate)
   end
  end
 end
 return ent, civ, mem
end

function getInfo(tar)
 local gui = require 'gui'
 local utils = require 'utils'
 local split = utils.split_string
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 game_mode = df.global.gamemode
 if game_mode == 0 then
  local temp_screen = df.viewscreen_unitst:new()
  temp_screen.unit = tar
  gui.simulateInput(temp_screen,1)
 elseif game_mode == 1 then
  local temp_screen = df.viewscreen_dungeon_monsterstatusst:new()
  temp_screen.unit = tar
  gui.simulateInput(temp_screen,291)
 end
 local read_screen = dfhack.gui.getCurViewscreen()
 local info = ''
 local info_pars = {}
 local no_color = {}
 local colors = {}
 local information = {}
 information.quote = ''
 information.age = ''
 information.wounds = ''
 information.preferences = ''
 information.attributes = {'',''}
 local a_num = 1
 information.worship = ''
 information.membership = ''
 information.values = ''
 information.thoughts = ''
 information.description = ''
 information.appearance = ''
 information.traits = ''
 local check = 0
 for i,x in pairs(read_screen.src_text) do
  info = info..' '..x.value
 end
 dfhack.screen.dismiss(read_screen)
 local info_temp = split(info,'%[B%]')
 i = 0
 for k,v in pairs(info_temp) do
  temp = split(v,'%[P%]')
  for l,w in pairs(temp) do
   info_pars[i] = w
   i = i + 1
  end
 end
 for k,v in ipairs(info_pars) do
  no_color[k] = string.gsub(v,"%[C:.:.:.%]","")
  colors[k] = string.sub(v,1,9)
  if string.find(string.sub(v,1,18),"%[C:.:.:.%]",9) then
   colors[k] = string.sub(v,10,18)
  end
 end
 for k,vv in ipairs(no_color) do
  v = info_pars[k]
  if string.find(vv,'"') == 1 then
   information.quote = string.gsub(v,'%[C:.:.:.%]','')
  elseif colors[k] == '[C:3:0:1]' then
   information.worship = string.gsub(v,'%[C:.:.:.%]','')
   check = 1
  elseif colors[k] == '[C:1:0:1]' then
   information.membership = string.gsub(v,'%[C:.:.:.%]','')
   check = 1
  elseif colors[k] == '[C:6:0:1]' then
   information.age = string.gsub(v,'%[C:.:.:.%]','')
   check = 1
  elseif colors[k] == '[C:2:0:0]' or colors[k] == '[C:4:0:0]' then
   information.attributes[a_num] = string.gsub(v,'%[C:.:.:.%]','')
   a_num = a_num + 1
   check = 2
  elseif colors[k] == '[C:2:0:1]' then
   information.preferences = string.gsub(v,'%[C:.:.:.%]','')
   check = 2
  elseif colors[k] == '[C:4:0:1]' then
   information.wounds = string.gsub(v,'%[C:.:.:.%]','')
   check = 1
  elseif (colors[k] == '[C:7:0:0]' or colors[k] == '[C:7:0:1]') and check == 0 then
   information.thoughts = string.gsub(v,'%[C:.:.:.%]','')
   check = 1
  elseif (colors[k] == '[C:7:0:0]' or colors[k] == '[C:7:0:1]') and check == 1 then
   information.appearance = string.gsub(v,'%[C:.:.:.%]','')
   check = 2
  elseif (colors[k] == '[C:7:0:0]' or colors[k] == '[C:7:0:1]') and check == 2 then
   information.values = string.gsub(v,'%[C:.:.:.%]','')
   check = 3
  elseif (colors[k] == '[C:7:0:0]' or colors[k] == '[C:7:0:1]') and check == 3 then
   information.traits = string.gsub(v,'%[C:.:.:.%]','')
   check = 4
  end
 end
 information.description = no_color[#no_color]
 return information
end
