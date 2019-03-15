-- This file contains a text translation for various flags and tokens in the 
-- game that don't have a simple translation, or benefit from some additional
-- information. As well as the text used to generate description strings
function fixString(str)
 local outStr = ''
 if str == '' then return str end
 local array = str:split(',')
 local n = #array
 if str:endswith(',') or str:endswith(', ') then n = n - 1 end
 if     n == 0 then
  outStr = array[1]
 elseif n == 1 then
  outStr = array[1]
 elseif n == 2 then
  outStr = array[1]..' and'..array[2]
 else
  for i = 1, n-1 do
   outStr = outStr..array[i]..','
  end
  outStr = outStr..' and'..array[n]
 end
 return outStr
end
local function getPronoun(unit)
 local str1 = 'It'
 local str2 = 'Its'
 if unit.sex == 0 then
  str1 = 'She'
  str2 = 'Her'
 elseif unit.sex == 1 then
  str1 = 'He'
  str2 = 'His'
 end 
 return str1, str2
end
local function get_hf_name(id,translate)
  local hf = df.historical_figure.find (id)

  if hf ~= nil then
    if hf.name.has_name then
      return dfhack.TranslateName (hf.name, translate)
    else
      return df.global.world.raws.creatures.all [hf.race].name [0]
    end
  
  else  
    return "<Unknown>"
  end
end

-- Flags
-- These are english translations for various flags
-- e.g. NOPAIN = 'Does not feel pain'
creatureFlags  = { -- For flags found in creature_raw.flags and caste_raw.flags
 ['ALL_FLAGS'] = {},
 
-- Biomes
 ['BIOME_FLAGS'] = {
  ANY_LAND                              = 'Any Land',
  ALL_MAIN                              = 'All Main',
  ANY_OCEAN                             = 'Any Ocean',
  ANY_LAKE                              = 'Any Lake',
  ANY_TEMPERATE_LAKE                    = 'Temperate Lakes',
  ANY_TROPICAL_LAKE                     = 'Tropical Lakes',
  ANY_RIVER                             = 'Lives in any rivers',
  ANY_TEMPERATE_RIVER                   = 'Temperate Rivers',
  ANY_TROPICAL_RIVER                    = 'Tropical Rivers',
  ANY_POOL                              = 'Any Pool',
  NOT_FREEZING                          = 'Not Freezing',
  ANY_TEMPERATE                         = 'Any Temperate',
  ANY_TROPICAL                          = 'Any Tropical',
  ANY_FOREST                            = 'Any Forest',
  ANY_SHRUBLAND                         = 'Any Shrubland',
  ANY_GRASSLAND                         = 'Any Grassland',
  ANY_SAVANNA                           = 'Any Savanna',
  ANY_TEMPERATE_FOREST                  = 'Any Temperate Forest',
  ANY_TROPICAL_FOREST                   = 'Any Tropical Forest',
  ANY_TEMPERATE_BROADLEAF               = 'Any Temperate Vegetation',
  ANY_TROPICAL_BROADLEAF                = 'Any Tropical Vegetation',
  ANY_WETLAND                           = 'Any Wetland',
  ANY_TEMPERATE_WETLAND                 = 'Any Temperate Wetland',
  ANY_TROPICAL_WETLAND                  = 'Any Tropical Wetland',
  ANY_TEMPERATE_MARSH                   = 'Any Temperate Marsh',
  ANY_TROPICAL_MARSH                    = 'Any Tropical Marsh',
  ANY_TEMPERATE_SWAMP                   = 'Any Temperate Swamp',
  ANY_TROPICAL_SWAMP                    = 'Any Tropical Swamp',
  ANY_DESERT                            = 'Any Desert',
  MOUNTAIN                              = 'Mountains',
  MOUNTAINS                             = 'Mountains',
  GLACIER                               = 'Glaciers',
  TUNDRA                                = 'Tundra',
  SWAMP_TEMPERATE_FRESHWATER            = 'Temperate Freshwater Swamp',
  SWAMP_TEMPERATE_SALTWATER             = 'Temperate Saltwater Swamp',
  SWAMP_TROPICAL_FRESHWATER             = 'Tropical Freshwater Swamp',
  SWAMP_TROPICAL_SALTWATER              = 'Tropical Saltwater Swamp',
  SWAMP_MANGROVE                        = 'Mangrove Swamp',
  MARSH_TEMPERATE_FRESHWATER            = 'Temperate Freshwater Marsh',
  MARSH_TEMPERATE_SALTWATER             = 'Temperate Saltwater Marsh',
  MARSH_TROPICAL_FRESHWATER             = 'Tropical Freshwater Marsh',
  MARSH_TROPICAL_SALTWATER              = 'Tropical Saltwater Marsh',
  FOREST_TAIGA                          = 'Taiga',
  TAIGA                                 = 'Taiga',
  FOREST_TEMPERATE_BROADLEAF            = 'Temperate Broadleaf Forest',
  FOREST_TEMPERATE_CONIFER              = 'Temperate Conifer Forest',
  FOREST_TROPICAL_DRY_BROADLEAF         = 'Tropical Dry Broadleaf Forest',
  FOREST_TROPICAL_MOIST_BROADLEAF       = 'Tropical Moist Broadleaf Forest',
  FOREST_TROPICAL_CONIFER               = 'Tropical Conifer Forest',
  GRASSLAND_TEMPERATE                   = 'Temperate Grassland',
  GRASSLAND_TROPICAL                    = 'Tropical Grassland',
  SHRUBLAND_TEMPERATE                   = 'Temperate Shrubland',
  SHRUBLAND_TROPICAL                    = 'Tropical Shrubland',
  SAVANNA_TEMPERATE                     = 'Temperate Savanna',
  SAVANNA_TROPICAL                      = 'Tropical Savanna',
  OCEAN_ARCTIC                          = 'Arctic Ocean',
  OCEAN_TEMPERATE                       = 'Temperate Ocean',
  OCEAN_TROPICAL                        = 'Tropical Ocean',
  DESERT_BADLAND                        = 'Badlands',
  DESERT_ROCK                           = 'Rocky Wastes',
  DESERT_SAND                           = 'Sandy Desert',
  POOL_TEMPERATE_FRESHWATER             = 'Temperate Freshwater Pool',
  POOL_TEMPERATE_BRACKISHWATER          = 'Temperate Brackishwater Pool',
  POOL_TEMPERATE_SALTWATER              = 'Temperate Saltwater Pool',
  POOL_TROPICAL_FRESHWATER              = 'Tropical Freshwater Pool',
  POOL_TROPICAL_BRACKISHWATER           = 'Tropical Brackishwater Pool',
  POOL_TROPICAL_SALTWATER               = 'Tropical Saltwater Pool',
  LAKE_TEMPERATE_FRESHWATER             = 'Temperate Freshwater Lake',
  LAKE_TEMPERATE_BRACKISHWATER          = 'Temperate Brackishwater Lake',
  LAKE_TEMPERATE_SALTWATER              = 'Temperate Saltwater Lake',
  LAKE_TROPICAL_FRESHWATER              = 'Tropical Freshwater Lake',
  LAKE_TROPICAL_BRACKISHWATER           = 'Tropical Brackishwater Lake',
  LAKE_TROPICAL_SALTWATER               = 'Tropical Saltwater Lake',
  RIVER_TEMPERATE_FRESHWATER            = 'Temperate Freshwater River',
  RIVER_TEMPERATE_BRACKISHWATER         = 'Temperate Brackishwater River',
  RIVER_TEMPERATE_SALTWATER             = 'Temperate Saltwater River',
  RIVER_TROPICAL_FRESHWATER             = 'Tropical Freshwater River',
  RIVER_TROPICAL_BRACKISHWATER          = 'Tropical Brackishwater River',
  RIVER_TROPICAL_SALTWATER              = 'Tropical Saltwater River',
  SUBTERRANEAN_WATER                    = 'Subterranean Water',
  SUBTERRANEAN_CHASM                    = 'Subterranean Chasm',
  SUBTERRANEAN_LAVA                     = 'Subterranean Lava',
  BIOME_MOUNTAIN                        = 'Mountain',
  BIOME_GLACIER                         = 'Glacier',
  BIOME_TUNDRA                          = 'Tundra',
  BIOME_SWAMP_TEMPERATE_FRESHWATER      = 'Temperate Freshwater Swamp',
  BIOME_SWAMP_TEMPERATE_SALTWATER       = 'Temperate Saltwater Swamp',
  BIOME_MARSH_TEMPERATE_FRESHWATER      = 'Temperate Freshwater Marsh',
  BIOME_MARSH_TEMPERATE_SALTWATER       = 'Temperate Saltwater Marsh',
  BIOME_SWAMP_TROPICAL_FRESHWATER       = 'Tropical Freshwater Swamp',
  BIOME_SWAMP_TROPICAL_SALTWATER        = 'Tropical Saltwater Swamp',
  BIOME_SWAMP_MANGROVE                  = 'Mangrove Swamp',
  BIOME_MARSH_TROPICAL_FRESHWATER       = 'Tropical Freshwater Marsh',
  BIOME_MARSH_TROPICAL_SALTWATER        = 'Tropical Saltwater Marsh',
  BIOME_FOREST_TAIGA                    = 'Taiga',
  BIOME_FOREST_TEMPERATE_CONIFER        = 'Temperate Coniferous Forest',
  BIOME_FOREST_TEMPERATE_BROADLEAF      = 'Temperate Broadlead Forest',
  BIOME_FOREST_TROPICAL_CONIFER         = 'Tropical Coniferous Forest',
  BIOME_FOREST_TROPICAL_DRY_BROADLEAF   = 'Tropical Dry Broadleaf Forest',
  BIOME_FOREST_TROPICAL_MOIST_BROADLEAF = 'Tropical Moist Broadleaf Forest',
  BIOME_GRASSLAND_TEMPERATE             = 'Temperate Grassland',
  BIOME_SAVANNA_TEMPERATE               = 'Temperate Savanna',
  BIOME_SHRUBLAND_TEMPERATE             = 'Temperate Shrubland',
  BIOME_GRASSLAND_TROPICAL              = 'Tropical Grassland',
  BIOME_SAVANNA_TROPICAL                = 'Tropical Savanna',
  BIOME_SHRUBLAND_TROPICAL              = 'Tropical Shrubland',
  BIOME_DESERT_BADLAND                  = 'Badland Desert',
  BIOME_DESERT_ROCK                     = 'Rock Desert',
  BIOME_DESERT_SAND                     = 'Sand Desert',
  BIOME_OCEAN_TROPICAL                  = 'Tropical Ocean',
  BIOME_OCEAN_TEMPERATE                 = 'Temperate Ocean',
  BIOME_OCEAN_ARCTIC                    = 'Arctic Ocean',
  BIOME_SUBTERRANEAN_WATER              = 'Underground Water',
  BIOME_SUBTERRANEAN_CHASM              = 'Ungerground Chasm',
  BIOME_SUBTERRANEAN_LAVA               = 'Underground Lava',
  BIOME_POOL_TEMPERATE_FRESHWATER       = 'Temperate Freshwater Pool',
  BIOME_POOL_TEMPERATE_BRACKISHWATER    = 'Temperate Brackishwater Pool',
  BIOME_POOL_TEMPERATE_SALTWATER        = 'Temperate Saltwater Pool',
  BIOME_POOL_TROPICAL_FRESHWATER        = 'Tropical Freshwater Pool',
  BIOME_POOL_TROPICAL_BRACKISHWATER     = 'Tropical Brackishwater Pool',
  BIOME_POOL_TROPICAL_SALTWATER         = 'Tropical Saltwater Pool',
  BIOME_LAKE_TEMPERATE_FRESHWATER       = 'Temperate Freshwater Lake',
  BIOME_LAKE_TEMPERATE_BRACKISHWATER    = 'Temperate Brackishwater Lake',
  BIOME_LAKE_TEMPERATE_SALTWATER        = 'Temperate Saltwater Lake',
  BIOME_LAKE_TROPICAL_FRESHWATER        = 'Tropical Freshwater Lake',
  BIOME_LAKE_TROPICAL_BRACKISHWATER     = 'Tropical Brackishwater Lake',
  BIOME_LAKE_TROPICAL_SALTWATER         = 'Tropical Saltwater Lake',
  BIOME_RIVER_TEMPERATE_FRESHWATER      = 'Temperate Freshwater River',
  BIOME_RIVER_TEMPERATE_BRACKISHWATER   = 'Temperate Brackishwater River',
  BIOME_RIVER_TEMPERATE_SALTWATER       = 'Temperate Saltwater River',
  BIOME_RIVER_TROPICAL_FRESHWATER       = 'Tropical Freshwater River',
  BIOME_RIVER_TROPICAL_BRACKISHWATER    = 'Tropical Brackishwater River',
  BIOME_RIVER_TROPICAL_SALTWATER        = 'Tropical Saltwater River',
 },
  
-- Habitats
 ['HABITAT_FLAGS'] = {
  AMPHIBIOUS = 'Amphibious',
  AQUATIC    = 'Aquatic',
  GOOD       = 'Living in good biomes',
  EVIL       = 'Living in evil biomes',
  SAVAGE     = 'Living in savage biomes',
 },
 
-- Activity
 ['ACTIVITY_FLAGS'] = {
  ALL_ACTIVE  = 'At all times',
  DIURNAL     = 'During the day',
  NOCTURNAL   = 'During the night',
  CREPUSCULAR = 'At dawn and dusk',
  VESPERTINE  = 'At dusk',
  MATUTINAL   = 'At dawn',
  NO_SPRING   = 'Absent during the spring',
  NO_SUMMER   = 'Absent during the summer',
  NO_AUTUMN   = 'Absent during the fall',
  NO_WINTER   = 'Absent during the winter',
 },
 
-- Utility
 ['UTILITY_FLAGS'] = {
  COMMON_DOMESTIC   = 'Domesticated',
  WAGON_PULLER      = 'Can pull wagons',
  PACK_ANIMAL       = 'Can haul goods',
  TRAINABLE_HUNTING = 'Can be trained to hunt',
  TRAINABLE_WAR     = 'Can be trained for fighting',
  PET               = 'Can be tamed',
  PET_EXOTIC        = 'Can be tamed with difficulty',
  MOUNT             = 'Can be used as a mount',
  MOUNT_EXOTIC      = 'Can be used as a mount',
 },
 
-- Diet 
 ['DIET_FLAGS'] = {            
  NO_EAT        = 'Does not need food',
  NO_DRINK      = 'Does not need drink',
  BONECARN      = 'Eats meat and bones',
  CARNIVORE     = 'Only eats meat',
  GRAZER        = 'Eats grass',
  GOBBLE_VERMIN = 'Eats vermin',
 },
 
-- Behavior
 ['BEHAVIOR_FLAGS'] = {
  MISCHIEVOUS                 = 'Mischievous',
  CURIOUSBEAST_ANY            = 'Steals anything',
  CURIOUSBEAST_ITEM           = 'Steals items',
  CURIOUSBEAST_GUZZLER        = 'Steals drinks',
  CURIOUSBEAST_EATER          = 'Steals food',
  TRAPAVOID                   = 'Avoids traps',
  CAVE_ADAPT                  = 'Dislikes leaving caves',
  HUNTS_VERMIN                = 'Hunts vermin',
  SOUND_ALERT                 = 'Creates sounds when alerted',
  SOUND_PEACEFUL_INTERMITTENT = 'Creates sounds intermittently',
  CRAZED                      = 'Constantly berserk',
  FLEEQUICK                   = 'Quick to flee',
  AT_PEACE_WITH_WILDLIFE      = 'At peace with wildlife',
  AMBUSHPREDATOR              = 'Ambushes prey',
  OPPOSED_TO_LIFE             = 'Hostile to the living',
 },
 
-- Movement
 ['MOVEMENT_FLAGS'] = {
  FLIER          = 'Can fly',
  IMMOBILE       = 'Can not move',
  IMMOBILE_LAND  = 'Can not move on land',
  MEANDERER      = 'Meanders around',
  SWIMS_INNATE   = 'Can swim',
  CANNOT_JUMP    = 'Can not jump',
  STANCE_CLIMBER = 'Climbs with its feet',
  CANNOT_CLIMB   = 'Can not climb',
  SWIMS_LEARNED  = 'Can learn to swim',
  VERMIN_MICRO   = 'Moves in a swarm',
  UNDERSWIM      = 'Swims underwater',
 },
 
-- Immunities
 ['IMMUNITY_FLAGS'] = {
  NO_DIZZINESS     = 'Does not get dizzy',
  NO_FEVERS        = 'Does not get fevers',
  NOEXERT          = 'Does not get tired',
  NOPAIN           = 'Does not feel pain',
  NOBREATHE        = 'Does not breath',
  NOSTUN           = 'Can not be stunned',
  PARALYZEIMMUNE   = 'Can not be paralyzed',
  NONAUSEA         = 'Does not get nauseous',
  NOEMOTION        = 'Does not feel emotion',
  NOFEAR           = 'Can not be scared',
  NO_SLEEP         = 'Does not need sleep',
  FIREIMMUNE       = 'Immune to fire',
  FIREIMMUNE_SUPER = 'Immune to dragonfire',
  WEBIMMUNE        = 'Does not get caught in webs',
 },
 
-- Bonuses
 ['BONUS_FLAGS'] = {
  WEBBER                = 'Creates webs',
  THICKWEB              = 'Webs large targets',
  MAGMA_VISION          = 'Can see in lava',
  IMMOLATE              = 'Radiates fire',
  MULTIPART_FULL_VISION = 'Can see all around itself',
  CAN_SPEAK             = 'Can speak',
  CAN_LEARN             = 'Can learn',
  CANOPENDOORS          = 'Can open doors',
  LOCKPICKER            = 'Can pick locks',
  EQUIPS                = 'Can wear items',
  LISP                  = 'Speaks with a lisp',
  LIGHT_GEN             = 'Generates light',
  EXTRAVISION           = 'Can see in the dark',
  SLOW_LEARNER          = 'Slow learner',
  UTTERANCES            = 'Unintelligible utterances',
 },
 
-- Body Flags
 ['BODY_FLAGS'] = {
  NOT_BUTCHERABLE                = 'Can not be butchered',
  COOKABLE_LIVE                  = 'Can be cooked live',
  NOSKULL                        = 'Does not have a skull',
  NOSKIN                         = 'Does not have skin',
  NOBONES                        = 'Does not have bones',
  NOMEAT                         = 'Does not have meat',
  NOTHOUGHT                      = 'Does not have a brain',
  NO_THOUGHT_CENTER_FOR_MOVEMENT = 'Does not need a brain to move',
  VEGETATION                     = 'Made of swampstuff',
 },
 
-- Types
 ['TYPE_FLAGS'] = {
  FANCIFUL                 = 'Fanciful',
  CASTE_MEGABEAST          = 'Megabeast',
  CASTE_SEMIMEGABEAST      = 'Semi-Megabeast',
  CASTE_BENIGN             = 'Benign',
  CASTE_POWER              = 'Power',
  CASTE_TITAN              = 'Titan',
  CASTE_FEATURE_BEAST      = 'Feature Beast',
  CASTE_UNIQUE_DEMON       = 'Unique Demon',
  CASTE_DEMON              = 'Demon',
  CASTE_NIGHT_CREATURE_ANY = 'Night Creature',
 }
}
plantFlags     = { -- For flags found in plant_raw.flags
 ['ALL_FLAGS'] = {},

-- Biomes
 ['BIOME_FLAGS'] = {
  ANY_LAND                              = 'Any Land',
  ALL_MAIN                              = 'All Main',
  ANY_OCEAN                             = 'Any Ocean',
  ANY_LAKE                              = 'Any Lake',
  ANY_TEMPERATE_LAKE                    = 'Temperate Lakes',
  ANY_TROPICAL_LAKE                     = 'Tropical Lakes',
  ANY_RIVER                             = 'Lives in any rivers',
  ANY_TEMPERATE_RIVER                   = 'Temperate Rivers',
  ANY_TROPICAL_RIVER                    = 'Tropical Rivers',
  ANY_POOL                              = 'Any Pool',
  NOT_FREEZING                          = 'Not Freezing',
  ANY_TEMPERATE                         = 'Any Temperate',
  ANY_TROPICAL                          = 'Any Tropical',
  ANY_FOREST                            = 'Any Forest',
  ANY_SHRUBLAND                         = 'Any Shrubland',
  ANY_GRASSLAND                         = 'Any Grassland',
  ANY_SAVANNA                           = 'Any Savanna',
  ANY_TEMPERATE_FOREST                  = 'Any Temperate Forest',
  ANY_TROPICAL_FOREST                   = 'Any Tropical Forest',
  ANY_TEMPERATE_BROADLEAF               = 'Any Temperate Vegetation',
  ANY_TROPICAL_BROADLEAF                = 'Any Tropical Vegetation',
  ANY_WETLAND                           = 'Any Wetland',
  ANY_TEMPERATE_WETLAND                 = 'Any Temperate Wetland',
  ANY_TROPICAL_WETLAND                  = 'Any Tropical Wetland',
  ANY_TEMPERATE_MARSH                   = 'Any Temperate Marsh',
  ANY_TROPICAL_MARSH                    = 'Any Tropical Marsh',
  ANY_TEMPERATE_SWAMP                   = 'Any Temperate Swamp',
  ANY_TROPICAL_SWAMP                    = 'Any Tropical Swamp',
  ANY_DESERT                            = 'Any Desert',
  MOUNTAIN                              = 'Mountains',
  MOUNTAINS                             = 'Mountains',
  GLACIER                               = 'Glaciers',
  TUNDRA                                = 'Tundra',
  SWAMP_TEMPERATE_FRESHWATER            = 'Temperate Freshwater Swamp',
  SWAMP_TEMPERATE_SALTWATER             = 'Temperate Saltwater Swamp',
  SWAMP_TROPICAL_FRESHWATER             = 'Tropical Freshwater Swamp',
  SWAMP_TROPICAL_SALTWATER              = 'Tropical Saltwater Swamp',
  SWAMP_MANGROVE                        = 'Mangrove Swamp',
  MARSH_TEMPERATE_FRESHWATER            = 'Temperate Freshwater Marsh',
  MARSH_TEMPERATE_SALTWATER             = 'Temperate Saltwater Marsh',
  MARSH_TROPICAL_FRESHWATER             = 'Tropical Freshwater Marsh',
  MARSH_TROPICAL_SALTWATER              = 'Tropical Saltwater Marsh',
  FOREST_TAIGA                          = 'Taiga',
  TAIGA                                 = 'Taiga',
  FOREST_TEMPERATE_BROADLEAF            = 'Temperate Broadleaf Forest',
  FOREST_TEMPERATE_CONIFER              = 'Temperate Conifer Forest',
  FOREST_TROPICAL_DRY_BROADLEAF         = 'Tropical Dry Broadleaf Forest',
  FOREST_TROPICAL_MOIST_BROADLEAF       = 'Tropical Moist Broadleaf Forest',
  FOREST_TROPICAL_CONIFER               = 'Tropical Conifer Forest',
  GRASSLAND_TEMPERATE                   = 'Temperate Grassland',
  GRASSLAND_TROPICAL                    = 'Tropical Grassland',
  SHRUBLAND_TEMPERATE                   = 'Temperate Shrubland',
  SHRUBLAND_TROPICAL                    = 'Tropical Shrubland',
  SAVANNA_TEMPERATE                     = 'Temperate Savanna',
  SAVANNA_TROPICAL                      = 'Tropical Savanna',
  OCEAN_ARCTIC                          = 'Arctic Ocean',
  OCEAN_TEMPERATE                       = 'Temperate Ocean',
  OCEAN_TROPICAL                        = 'Tropical Ocean',
  DESERT_BADLAND                        = 'Badlands',
  DESERT_ROCK                           = 'Rocky Wastes',
  DESERT_SAND                           = 'Sandy Desert',
  POOL_TEMPERATE_FRESHWATER             = 'Temperate Freshwater Pool',
  POOL_TEMPERATE_BRACKISHWATER          = 'Temperate Brackishwater Pool',
  POOL_TEMPERATE_SALTWATER              = 'Temperate Saltwater Pool',
  POOL_TROPICAL_FRESHWATER              = 'Tropical Freshwater Pool',
  POOL_TROPICAL_BRACKISHWATER           = 'Tropical Brackishwater Pool',
  POOL_TROPICAL_SALTWATER               = 'Tropical Saltwater Pool',
  LAKE_TEMPERATE_FRESHWATER             = 'Temperate Freshwater Lake',
  LAKE_TEMPERATE_BRACKISHWATER          = 'Temperate Brackishwater Lake',
  LAKE_TEMPERATE_SALTWATER              = 'Temperate Saltwater Lake',
  LAKE_TROPICAL_FRESHWATER              = 'Tropical Freshwater Lake',
  LAKE_TROPICAL_BRACKISHWATER           = 'Tropical Brackishwater Lake',
  LAKE_TROPICAL_SALTWATER               = 'Tropical Saltwater Lake',
  RIVER_TEMPERATE_FRESHWATER            = 'Temperate Freshwater River',
  RIVER_TEMPERATE_BRACKISHWATER         = 'Temperate Brackishwater River',
  RIVER_TEMPERATE_SALTWATER             = 'Temperate Saltwater River',
  RIVER_TROPICAL_FRESHWATER             = 'Tropical Freshwater River',
  RIVER_TROPICAL_BRACKISHWATER          = 'Tropical Brackishwater River',
  RIVER_TROPICAL_SALTWATER              = 'Tropical Saltwater River',
  SUBTERRANEAN_WATER                    = 'Subterranean Water',
  SUBTERRANEAN_CHASM                    = 'Subterranean Chasm',
  SUBTERRANEAN_LAVA                     = 'Subterranean Lava',
  BIOME_MOUNTAIN                        = 'Mountain',
  BIOME_GLACIER                         = 'Glacier',
  BIOME_TUNDRA                          = 'Tundra',
  BIOME_SWAMP_TEMPERATE_FRESHWATER      = 'Temperate Freshwater Swamp',
  BIOME_SWAMP_TEMPERATE_SALTWATER       = 'Temperate Saltwater Swamp',
  BIOME_MARSH_TEMPERATE_FRESHWATER      = 'Temperate Freshwater Marsh',
  BIOME_MARSH_TEMPERATE_SALTWATER       = 'Temperate Saltwater Marsh',
  BIOME_SWAMP_TROPICAL_FRESHWATER       = 'Tropical Freshwater Swamp',
  BIOME_SWAMP_TROPICAL_SALTWATER        = 'Tropical Saltwater Swamp',
  BIOME_SWAMP_MANGROVE                  = 'Mangrove Swamp',
  BIOME_MARSH_TROPICAL_FRESHWATER       = 'Tropical Freshwater Marsh',
  BIOME_MARSH_TROPICAL_SALTWATER        = 'Tropical Saltwater Marsh',
  BIOME_FOREST_TAIGA                    = 'Taiga',
  BIOME_FOREST_TEMPERATE_CONIFER        = 'Temperate Coniferous Forest',
  BIOME_FOREST_TEMPERATE_BROADLEAF      = 'Temperate Broadlead Forest',
  BIOME_FOREST_TROPICAL_CONIFER         = 'Tropical Coniferous Forest',
  BIOME_FOREST_TROPICAL_DRY_BROADLEAF   = 'Tropical Dry Broadleaf Forest',
  BIOME_FOREST_TROPICAL_MOIST_BROADLEAF = 'Tropical Moist Broadleaf Forest',
  BIOME_GRASSLAND_TEMPERATE             = 'Temperate Grassland',
  BIOME_SAVANNA_TEMPERATE               = 'Temperate Savanna',
  BIOME_SHRUBLAND_TEMPERATE             = 'Temperate Shrubland',
  BIOME_GRASSLAND_TROPICAL              = 'Tropical Grassland',
  BIOME_SAVANNA_TROPICAL                = 'Tropical Savanna',
  BIOME_SHRUBLAND_TROPICAL              = 'Tropical Shrubland',
  BIOME_DESERT_BADLAND                  = 'Badland Desert',
  BIOME_DESERT_ROCK                     = 'Rock Desert',
  BIOME_DESERT_SAND                     = 'Sand Desert',
  BIOME_OCEAN_TROPICAL                  = 'Tropical Ocean',
  BIOME_OCEAN_TEMPERATE                 = 'Temperate Ocean',
  BIOME_OCEAN_ARCTIC                    = 'Arctic Ocean',
  BIOME_SUBTERRANEAN_WATER              = 'Underground Water',
  BIOME_SUBTERRANEAN_CHASM              = 'Ungerground Chasm',
  BIOME_SUBTERRANEAN_LAVA               = 'Underground Lava',
  BIOME_POOL_TEMPERATE_FRESHWATER       = 'Temperate Freshwater Pool',
  BIOME_POOL_TEMPERATE_BRACKISHWATER    = 'Temperate Brackishwater Pool',
  BIOME_POOL_TEMPERATE_SALTWATER        = 'Temperate Saltwater Pool',
  BIOME_POOL_TROPICAL_FRESHWATER        = 'Tropical Freshwater Pool',
  BIOME_POOL_TROPICAL_BRACKISHWATER     = 'Tropical Brackishwater Pool',
  BIOME_POOL_TROPICAL_SALTWATER         = 'Tropical Saltwater Pool',
  BIOME_LAKE_TEMPERATE_FRESHWATER       = 'Temperate Freshwater Lake',
  BIOME_LAKE_TEMPERATE_BRACKISHWATER    = 'Temperate Brackishwater Lake',
  BIOME_LAKE_TEMPERATE_SALTWATER        = 'Temperate Saltwater Lake',
  BIOME_LAKE_TROPICAL_FRESHWATER        = 'Tropical Freshwater Lake',
  BIOME_LAKE_TROPICAL_BRACKISHWATER     = 'Tropical Brackishwater Lake',
  BIOME_LAKE_TROPICAL_SALTWATER         = 'Tropical Saltwater Lake',
  BIOME_RIVER_TEMPERATE_FRESHWATER      = 'Temperate Freshwater River',
  BIOME_RIVER_TEMPERATE_BRACKISHWATER   = 'Temperate Brackishwater River',
  BIOME_RIVER_TEMPERATE_SALTWATER       = 'Temperate Saltwater River',
  BIOME_RIVER_TROPICAL_FRESHWATER       = 'Tropical Freshwater River',
  BIOME_RIVER_TROPICAL_BRACKISHWATER    = 'Tropical Brackishwater River',
  BIOME_RIVER_TROPICAL_SALTWATER        = 'Tropical Saltwater River',
 },

-- Habitats
 ['HABITAT_FLAGS'] = {
  WET    = 'Grows in wet environments',
  DRY    = 'Grows in dry environments',
  GOOD   = 'Grows in good biomes',
  EVIL   = 'Grows in evil biomes',
  SAVAGE = 'Grows in savage biomes',
 },
 
-- Seasonal
 ['SEASONAL_FLAGS'] = {
  ALL_SEASON = 'Grows throught the year',
  NO_WINTER = 'Does not grow in the winter',
  NO_SPRING = 'Does not grow in the spring',
  NO_SUMMER = 'Does not grow in the summer',
  NO_AUTUMN = 'Does not grow in the fall',
  SPRING = 'Grows during the spring',
  SUMMER = 'Grows during the summer',
  AUTUMN = 'Grows during the fall',
  WINTER = 'Grows during the winter',
 },
 
 ['USE_FLAGS'] = {
  DRINK = '',
  THREAD = '',
  EXTRACT_BARREL = '',
  EXTRACT_VIAL = '',
  EXTRACT_STILL_VIAL = '',
  MILL = ''
 }
}
itemFlags      = { -- For flags found in itemdef_XXX.flags 
 ['ALL_FLAGS'] = {},
 
-- Uses
 ['USE_FLAGS'] = {
  TRAINING                = 'Training',
  FURNITURE               = 'Furniture',
  LIQUID_COOKING          = 'Cooking',
  LIQUID_SCOOP            = 'Liquid Scoop',
  GRIND_POWDER_RECEPTACLE = 'Powder Receptacle',
  GRIND_POWDER_GRINDER    = 'Powder Grinder',
  MEAT_CARVING            = 'Meat Carving',
  MEAT_BONING             = 'Meat Boning',
  MEAT_SLICING            = 'Meat Slicing',
  MEAT_CLEAVING           = 'Meat Cleaving',
  HOLD_MEAT_FOR_CARVING   = 'Meat Holding',
  MEAL_CONTAINER          = 'Meal Container',
  LIQUID_CONTAINER        = 'Liquid Container',
  FOOD_STORAGE            = 'Food Storage',
  HIVE                    = 'Artificial Hive',
  NEST_BOX                = 'Nest Box',
  SMALL_OBJECT_STORAGE    = 'Small Object Storage',
  TRACK_CART              = 'Track Cart',
  HEAVY_OBJECT_HAULING    = 'Heavy Object Hauling',
  STAND_AND_WORK_ABOVE    = 'Stand and Work Above',
  ROLL_UP_SHEET           = 'Roll Up Sheet',
  PROTECT_FOLDED_SHEETS   = 'Protect Paper',
  CONTAIN_WRITING         = 'Hold Writings',
  BOOKCASE                = 'Hold Books',
 }
}
inorganicFlags = { -- For flags found in inorganic_raw.flags
 ['ALL_FLAGS'] = {},
 
-- Seasonal
 ['ENVIRONMENT_FLAGS'] = {
   SEDIMENTARY = 'Sedimentary',
   IGNEOUS_INTRUSIVE = 'Igneous intrusive',
   IGNEOUS_EXTRUSIVE = 'Igneous extrusive',
   METAMORPHIC = 'Metamorphic',
   SOIL = 'Soil',
   SOIL_ANY = 'Soil'
 }
}
materialFlags  = { -- For flags found in material.flags
 ['ALL_FLAGS'] = {},
 
-- Items
 ['ITEM_FLAGS'] = {
  ITEMS_WEAPON        = 'melee weapons',
  ITEMS_WEAPON_RANGED = 'ranges weapons',
  ITEMS_ANVIL         = 'anvils',
  ITEMS_AMMO          = 'ammo',
  ITEMS_DIGGER        = 'digging items',
  ITEMS_ARMOR         = 'armor',
  ITEMS_DELICATE      = 'delicate items',
  ITEMS_SIEGE_ENGINE  = 'siege engine ammo',
  ITEMS_QUERN         = 'querns',
  ITEMS_METAL         = 'metal items',
  ITEMS_BARRED        = 'barred items',
  ITEMS_SCALED        = 'scaled items',
  ITEMS_LEATHER       = 'leather items',
  ITEMS_SOFT          = 'soft items',
  ITEMS_HARD          = 'hard items',
 },
 
-- Types
 ['TYPE_FLAGS'] = {
  IS_METAL = 'Metal',
  IS_GLASS = 'Glass',
  IS_STONE = 'Stone',
 },
 
-- Materials
 ['MATERIAL_FLAGS'] = {
  SOFT             = 'Soft',
  HARD             = 'Hard',
  METAL            = 'Metal',
  BARRED           = 'Barred',
  SCALED           = 'Scaled',
  LEATHER          = 'Leather',
  METAL_MAT        = 'Metal',
  STONE_MAT        = 'Stone',
  WOOD_MAT         = 'Wood',
  GLASS_MAT        = 'Glass',
  CERAMIC_MAT      = 'Ceramic',
  SHELL_MAT        = 'Shell',
  BONE_MAT         = 'Bone',
  HARD_MAT         = 'Hard',
  SHEET_MAT        = 'Sheet',
  THREAD_PLANT_MAT = 'Plant Thread',
  SILK_MAT         = 'Silk',
  SOFT_MAT         = 'Soft',
  METAL_WEAPON_MAT = 'Metal',
  CAN_STONE        = 'Stone',
 },
 
-- Edible
 ['EDIBLE_FLAGS'] = {
  EDIBLE_VERMIN = 'Vermin',
  EDIBLE_RAW    = 'Raw',
  EDIBLE_COOKED = 'Cooked',
 }
}

-- Populate the ALL_FLAGS category for each of the XXXFlags
for flagType,flags in pairs(creatureFlags)  do
 for flag,str in pairs(flags) do
  creatureFlags.ALL_FLAGS[flag] = str
 end
end
for flagType,flags in pairs(plantFlags)     do
 for flag,str in pairs(flags) do
  plantFlags.ALL_FLAGS[flag] = str
 end
end
for flagType,flags in pairs(inorganicFlags) do
 for flag,str in pairs(flags) do
  inorganicFlags.ALL_FLAGS[flag] = str
 end
end
for flagType,flags in pairs(itemFlags)      do
 for flag,str in pairs(flags) do
  itemFlags.ALL_FLAGS[flag] = str
 end
end
for flagType,flags in pairs(materialFlags)  do
 for flag,str in pairs(flags) do
  materialFlags.ALL_FLAGS[flag] = str
 end
end

function inorganic_string(inorganic)

end

-- Health Strings (Wounds and Syndromes)
function wound_string(bp,bp_status)
 -- Missing and On fire are treated special and returned solo, the rest is combined with loss > damage
 local outStr = ''
 local bp_name = bp.name_singular[0].value
 if bp_status.missing then
  outStr = bp_name..' is missing'
  return outStr
 elseif bp_status.on_fire then
  outStr = bp_name..' is on fire'
  return outStr
 else
  outStr = bp_name
  
  -- Skin Check
  if bp_status.skin_damage then 
   outStr = outStr..' skin is damaged,' 
  end
  
  -- Muscle Check
  if bp_status.muscle_loss then
   outStr = outStr..' muscles are gone,'
  elseif bp_status.muscle_damage then
   outStr = outStr..' muscles are damaged,'
  end
  
  -- Bone Check
  if bp_status.bone_loss then
   outStr = outStr..' bones are gone,'
  elseif bp_status.bone_damage then
   outStr = outStr..' bones are damaged,'
  end
  
  -- Organ Check
  if bp_status.organ_loss then
   outStr = outStr..' organs are gone,'
  elseif bp_status.organ_damage then
   outStr = outStr..' organs are damaged,'
  end
  if bp_status.spilled_guts then
   outStr = outStr..' guts are spilled,'
  end
  
  -- Nerve Check
  if bp_status.motor_nerve_severed then
   outStr = outStr..' motor nerves are severed,'
  end
  if bp_status.sensory_nerve_severed then
   outStr = outStr..' sensory nerves are severed,'
  end
  
  if outStr == bp_name then
   outStr = nil
  else
   outStr = fixString(outStr)
  end
  
  return outStr
 end
end
function syndrome_string(syndrome)
 local outStr
 
 return outStr
end

-- These tables and functions are needed for generating the appearance string
modifiers = { 
 [df.appearance_modifier_type.HEIGHT]          = {
   [-3] = 'extremely short',
   [-2] = 'very short',
   [-1] = 'short',
   [0]  = 'average height',
   [1]  = 'tall',
   [2]  = 'very tall',
   [3]  = 'extremely tall'},
 [df.appearance_modifier_type.BROADNESS]       = {
   [-3] = 'extremely narrow',
   [-2] = 'narrow',
   [-1] = 'somewhat narrow',
   [0]  = 'average width',
   [1]  = 'somewhat broad',
   [2]  = 'broad',
   [3]  = 'extraordinarily broad'},
 [df.appearance_modifier_type.LENGTH]          = {
   [-3] = 'extremely short',
   [-2] = 'very short',
   [-1] = 'somewhat short',
   [0]  = 'average length',
   [1]  = 'long',
   [2]  = 'very long',
   [3]  = 'extremely long'},
 [df.appearance_modifier_type.CLOSE_SET]       = {
   [-3] = 'incredibly wide set',
   [-2] = 'very wide set',
   [-1] = 'wide set',
   [0]  = 'slightly wide set',
   [1]  = 'slightly close set',
   [2]  = 'very close set',
   [3]  = 'incredibly close-set'},
 [df.appearance_modifier_type.DEEP_SET]        = {
   [-3] = 'bulging',
   [-2] = 'protruding',
   [-1] = 'slightly protruding',
   [0]  = 'slightly deep set',
   [1]  = 'deep set',
   [2]  = 'very deep set',
   [3]  = 'deeply sunken'},
 [df.appearance_modifier_type.HIGH_POSITION]   = {
   [-3] = 'extremely low',
   [-2] = 'very low',
   [-1] = 'low',
   [0]  = 'average',
   [1]  = 'high',
   [2]  = 'very high',
   [3]  = 'incredibly high'},
 [df.appearance_modifier_type.LARGE_IRIS]      = {
   [-3] = 'tiny',
   [-2] = 'very thin',
   [-1] = 'thin',
   [0]  = 'average size',
   [1]  = 'large',
   [2]  = 'very large',
   [3]  = 'huge'},
 [df.appearance_modifier_type.WRINKLY]         = {
   [-3] = 'extremely smooth',
   [-2] = 'very smooth',
   [-1] = 'smooth',
   [0]  = 'normal',
   [1]  = 'slightly wrinkled',
   [2]  = 'wrinkled',
   [3]  = 'extremely wrinkled'},
 [df.appearance_modifier_type.CURLY]           = {
   [-3] = 'incredibly straight',
   [-2] = 'very straight',
   [-1] = 'straight',
   [0]  = 'normal',
   [1]  = 'slightly wavy',
   [2]  = 'wavy',
   [3]  = 'curly'},
 [df.appearance_modifier_type.CONVEX]          = {
   [-3] = 'incredibly concave',
   [-2] = 'very concave',
   [-1] = 'concave',
   [0]  = 'straight',
   [1]  = 'convex',
   [2]  = 'very convex',
   [3]  = 'incredibly convex'},
 [df.appearance_modifier_type.DENSE]           = {
   [-3] = 'incredibly sparse',
   [-2] = 'very sparse',
   [-1] = 'sparse',
   [0]  = 'average density',
   [1]  = 'dense',
   [2]  = 'quite dense',
   [3]  = 'extremely dense'},
 [df.appearance_modifier_type.THICKNESS]       = {
   [-3] = 'extremely thin',
   [-2] = 'very thin',
   [-1] = 'thin',
   [0]  = 'average thickness',
   [1]  = 'thick',
   [2]  = 'very thick',
   [3]  = 'extremely thick'},
 [df.appearance_modifier_type.UPTURNED]        = {
   [-3] = 'sharply hooked',
   [-2] = 'hooked',
   [-1] = 'slightly hooked',
   [0]  = 'straight',
   [1]  = 'slightly upturned',
   [2]  = 'upturned',
   [3]  = 'incredibly upturned'},
 [df.appearance_modifier_type.SPLAYED_OUT]     = {
   [-3] = 'very flattened',
   [-2] = 'flattened',
   [-1] = 'slightly flattened',
   [0]  = 'averagely splayed',
   [1]  = 'slightly splayed out',
   [2]  = 'splayed out',
   [3]  = 'extremely splayed out'},
 [df.appearance_modifier_type.HANGING_LOBES]   = {
   [-3] = 'fused lobed',
   [-2] = 'nearly fused lobes',
   [-1] = 'slightly fused lobes',
   [0]  = 'average lobes',
   [1]  = 'hanging lobes',
   [2]  = 'large hanging lobes',
   [3]  = 'great swinging lobes'},
 [df.appearance_modifier_type.GAPS]            = {
   [-3] = 'tangled',
   [-2] = 'snarled',
   [-1] = 'overlapping',
   [0]  = 'straight',
   [1]  = 'slightly gapped',
   [2]  = 'gapped',
   [3]  = 'widely-spaced'},
 [df.appearance_modifier_type.HIGH_CHEEKBONES] = {
   [-3] = 'very low',
   [-2] = 'low',
   [-1] = 'slightly lowered',
   [0]  = 'average',
   [1]  = 'slightly raised',
   [2]  = 'high',
   [3]  = 'very high'},
 [df.appearance_modifier_type.BROAD_CHIN]      = {
   [-3] = 'extremely narrow',
   [-2] = 'very narrow',
   [-1] = 'narrow',
   [0]  = 'average',
   [1]  = 'broad',
   [2]  = 'very broad',
   [3]  = 'extremely broad'},
 [df.appearance_modifier_type.JUTTING_CHIN]    = {
   [-3] = 'deeply recessed',
   [-2] = 'recessed',
   [-1] = 'sunken',
   [0]  = 'average',
   [1]  = 'protruding',
   [2]  = 'prominent',
   [3]  = 'jutting'},
 [df.appearance_modifier_type.SQUARE_CHIN]     = {
   [-3] = 'very round',
   [-2] = 'round',
   [-1] = 'curved',
   [0]  = 'average',
   [1]  = 'angular',
   [2]  = 'square',
   [3]  = 'box'},
 [df.appearance_modifier_type.ROUND_VS_NARROW] = {
   [-3] = 'slit',
   [-2] = 'extremely narrow',
   [-1] = 'narrow',
   [0]  = 'elliptical',
   [1]  = 'oblong',
   [2]  = 'round',
   [3]  = 'perfectly round'},
 [df.appearance_modifier_type.GREASY]          = {
   [-3] = 'crinkly',
   [-2] = 'very dry',
   [-1] = 'dry',
   [0]  = 'normal',
   [1]  = 'somewhat greasy',
   [2]  = 'greasy',
   [3]  = 'very greasy'},
 [df.appearance_modifier_type.DEEP_VOICE]      = {
   [-3] = 'squeeky',
   [-2] = 'high pitched',
   [-1] = 'slightly raised',
   [0]  = 'normal pitch',
   [1]  = 'slightly lowered',
   [2]  = 'fairly deep',
   [3]  = 'very deep'},
 [df.appearance_modifier_type.RASPY_VOICE]     = {
   [-3] = 'crystal clear',
   [-2] = 'very clear',
   [-1] = 'clear',
   [0]  = 'normal',
   [1]  = 'scratchy',
   [2]  = 'raspy',
   [3]  = 'guttural'},
}
styles    = {
  [df.tissue_style_type.NEATLY_COMBED] = 'is neatly combed',
  [df.tissue_style_type.BRAIDED]       = 'is braided',
  [df.tissue_style_type.DOUBLE_BRAIDS] = 'is arranged in double braids',
  [df.tissue_style_type.PONY_TAILS]    = 'is tied in a pony tail',
  [df.tissue_style_type.CLEAN_SHAVEN]  = 'is clean shaven'
}
local function color_string(pattern)
 local strOut = ''
 local colors = df.global.world.raws.descriptors.colors

 if     df.pattern_type[pattern.pattern] == 'STRIPES' then
  if #pattern.colors == 1 then
   strOut = colors[pattern.colors[0]].name..' with '..colors[pattern.colors[1]].name..' stripes'
  else
   strOut = colors[pattern.colors[0]].name..' with rainbow stripes'
  end
 elseif df.pattern_type[pattern.pattern] == 'SPOTS' then
  strOut = colors[pattern.colors[0]].name..' with '..colors[pattern.colors[1]].name..' spots'
 elseif df.pattern_type[pattern.pattern] == 'MOTTLED' then
  strOut = 'mottled '..colors[pattern.colors[0]].name..' and '..colors[pattern.colors[1]].name
 elseif df.pattern_type[pattern.pattern] == 'IRIS_EYE' then
  strOut = colors[pattern.colors[2]].name
 elseif df.pattern_type[pattern.pattern] == 'PUPIL_EYE' then
  strOut = colors[pattern.colors[1]].name
 else
  strOut = colors[pattern.colors[0]].name
 end
   
 return strOut
end
local function hair_string(bin,y,x)
 local strOut = ''
 local patterns = df.global.world.raws.descriptors.patterns
 local colors = df.global.world.raws.descriptors.colors

 if     bin == 1 then
  strOut = colors[patterns[x].colors[0]].name ..' with a touch of '..colors[patterns[y].colors[0]].name
 elseif bin == 2 then
  strOut = colors[patterns[x].colors[0]].name ..' with streaks of '..colors[patterns[y].colors[0]].name
 elseif bin == 3 then
  strOut = colors[patterns[x].colors[0]].name ..' mixed with '..colors[patterns[y].colors[0]].name
 elseif bin == 4 then
  strOut = colors[patterns[y].colors[0]].name ..' mixed with '..colors[patterns[x].colors[0]].name
 elseif bin == 5 then
  strOut = colors[patterns[y].colors[0]].name ..' with streaks of '..colors[patterns[x].colors[0]].name
 elseif bin == 6 then
  strOut = colors[patterns[y].colors[0]].name ..' with a touch of '..colors[patterns[x].colors[0]].name
 end
 
 return strOut
end
function appearance_detail(unit)
 local raw = df.global.world.raws.creatures.all[unit.race].caste[unit.caste]
 local patterns = df.global.world.raws.descriptors.patterns
 local colors = df.global.world.raws.descriptors.colors
 local appearance = unit.appearance

 local body = {}
 local skin = {}
 local eyes = {}
 local hair = {}
 local ears = {}
 local nose = {}
 local otherColors = {}
 local otherHairs = {}
 local parts = {}
 
 for i,style in pairs(raw.tissue_styles) do
  for j,n in pairs(style.list_idx) do
   otherHairs[style.noun] = {PartName   = style.noun, 
	                         StyleToken = df.tissue_style_type[appearance.tissue_style[n]]}
   partN  = style.part_idx[j]
   layerN = style.layer_idx[j]
   bpart  = raw.body_info.body_parts[partN].layers[layerN]
   for k,idx in pairs(bpart.bp_modifiers) do
    x = raw.bp_appearance.modifier_idx[idx]
	val = appearance.bp_modifiers[idx]
    modifier = raw.bp_appearance.modifiers[x]
    y = 6
    for jdx,k in pairs(modifier.desc_range) do
     if val < k then
      y = jdx
      break
     end
    end
    y = y - 3
	
	Type = df.appearance_modifier_type[modifier.type]
	otherHairs[style.noun][Type] = {}
	otherHairs[style.noun][Type].n = val
	otherHairs[style.noun][Type].y = y
   end
  end
 end 
 hair = otherHairs.hair
 if not hair then hair = {} end
 otherHairs.hair = nil

 temp1 = {}
 temp2 = {}
 for i,n in pairs(appearance.colors) do
  x = raw.color_modifiers[i].pattern_index[n]
  part = raw.color_modifiers[i].part
  if part == 'skin' then 
   skin.ColorToken = patterns[x].id
   skin.ColorString = color_string(patterns[x])
  elseif part == 'eyes' then
   eyes.ColorToken = patterns[x].id
   eyes.ColorString = color_string(patterns[x])
  elseif part == 'hair' then
   temp1[#temp1+1] = raw.color_modifiers[i]
   temp2[#temp2+1] = n
  else
   colorstring = color_string(patterns[x])
   partstring = raw.color_modifiers[i].part
   otherColors[part] = {PartName    = part, 
                        PartString  = partstring, 
						ColorToken  = patterns[x].id, 
						ColorString = colorstring}
  end
 end
 if #temp1 == 1 then
  x = temp1[1].pattern_index[temp2[1]]
  hair.ColorToken = patterns[x].id
  hair.ColorString = colors[patterns[x].colors[0]].name
 else
  unitAge = dfhack.units.getAge(unit)*336
  mod1 = 1
  mod2 = 1
  found = false
  for i,mod in pairs(temp1) do
   if unitAge >= mod.start_date and unitAge <= mod.end_date then
    mod1 = i-1
    mod2 = i
    found = true
   elseif not found and unitAge > mod.end_date then
    mod1 = i
    mod2 = i
   end
  end
  x = temp1[mod2].pattern_index[temp2[mod2]]
  y = temp1[mod1].pattern_index[temp2[mod1]]
  hair.ColorToken = patterns[x].id
  if mod1 == mod2 then
   hair.ColorString = colors[patterns[x].colors[0]].name
  else
   d = (temp1[mod2].end_date - temp1[mod2].start_date)/6
   bin = 6
   for i = 1,6 do
    if unitAge < temp1[mod2].start_date + i*d then
     bin = i
     break
    end
   end
   hair.ColorString = hair_string(bin,x,y)
  end
 end
 
 for i,n in pairs(appearance.bp_modifiers) do
  x = raw.bp_appearance.modifier_idx[i]
  modifier = raw.bp_appearance.modifiers[x]
  partname = modifier.noun
  y = 6
  for j,k in pairs(modifier.desc_range) do
   if n < k then
    y = j
    break
   end
  end
  y = y - 3
  if partname == '' then
   pn = modifier.body_parts[0]
   bodypart = raw.body_info.body_parts[pn]
   partname = bodypart.name_singular[0].value
  end
  if partname == 'eyes' then
   eyes[df.appearance_modifier_type[modifier.type]] = {}
   eyes[df.appearance_modifier_type[modifier.type]].n = n
   eyes[df.appearance_modifier_type[modifier.type]].y = y
  elseif partname == 'ears' then
   ears[df.appearance_modifier_type[modifier.type]] = {}
   ears[df.appearance_modifier_type[modifier.type]].n = n
   ears[df.appearance_modifier_type[modifier.type]].y = y
  elseif partname == 'nose' then
   nose[df.appearance_modifier_type[modifier.type]] = {}
   nose[df.appearance_modifier_type[modifier.type]].n = n
   nose[df.appearance_modifier_type[modifier.type]].y = y
  elseif partname == 'hair' then
   -- Skip hair, already did it
  elseif partname == 'skin' then
   if df.appearance_modifier_type[modifier.type] == 'WRINKLY' then -- Why did I seperate this out?
    skin.Wrinkles_n = n
	skin.Wrinkles_y = y
   end
  else
   parts[partname] = parts[partname] or {}
   parts[partname][df.appearance_modifier_type[modifier.type]] = parts[partname][df.appearance_modifier_type[modifier.type]] or {}
   parts[partname][df.appearance_modifier_type[modifier.type]].n = n
   parts[partname][df.appearance_modifier_type[modifier.type]].y = y
  end
 end
 
 for i,n in pairs(appearance.body_modifiers) do
  modifier = raw.body_appearance_modifiers[i]
  y = 6
  for j,k in pairs(modifier.desc_range) do
   if n < k then
    y = j
    break
   end
  end
  y = y - 3
  body[df.appearance_modifier_type[modifier.type]] = body[df.appearance_modifier_type[modifier.type]] or {}
  body[df.appearance_modifier_type[modifier.type]].n = n
  body[df.appearance_modifier_type[modifier.type]].y = y
 end
 
 local list = {}
 -- Body appearance
 list.Body = {}
 for Type,_ in pairs(body) do
  list.Body[Type] = {Part='Body', Type=Type, Value=body[Type].n, Bin=body[Type].y, _colorBin=body[Type].y}
  list.Body[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Body[Type].Bin]  
 end
 -- Skin appearance
 list.Skin = {}
 list.Skin.Color   = {Part='Skin',Type='Color',Value=skin.ColorToken, Bin='--', String=skin.ColorString}
 list.Skin.WRINKLY = {Part='Skin',Type='WRINKLY',Value=skin.Wrinkles_n, Bin=skin.Wrinkles_y}
 list.Skin.WRINKLY.String = modifiers[df.appearance_modifier_type.WRINKLY][skin.Wrinkles_y]
 -- Eye appearance
 list.Eyes = {}
 list.Eyes.Color = {Part='Eyes', Type='Color', Value=eyes.ColorToken, Bin='--', String=eyes.ColorString}
 for Type,_ in pairs(eyes) do
  if Type ~= 'ColorToken' and Type ~= 'ColorString' then
   list.Eyes[Type] = {Part='Eyes', Type=Type, Value=eyes[Type].n, Bin=eyes[Type].y, _colorBin=eyes[Type].y}
   list.Eyes[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Eyes[Type].Bin]
  end
 end
 -- Hair appearance
 list.Hair = {}
 list.Hair.Color  = {Part='Hair', Type='Color', Value=hair.ColorToken, Bin='--', String=hair.ColorString}
 list.Hair.Style  = {Part='Hair', Type='Style', Value=hair.StyleToken, Bin='--', String=styles[df.tissue_style_type[hair.StyleToken]]}
 for Type,_ in pairs(hair) do
  if Type ~= 'ColorToken' and Type ~= 'ColorString' and Type ~= 'StyleToken' and Type ~= 'PartName' then
   list.Hair[Type] = {Part='Hair', Type=Type, Value=hair[Type].n, Bin=hair[Type].y, _colorBin=hair[Type].y}
   list.Hair[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Hair[Type].Bin]
  end
 end
 -- Ear appearance
 list.Ears = {}
 for Type,_ in pairs(ears) do
  list.Ears[Type] = {Part='Ears', Type=Type, Value=ears[Type].n, Bin=ears[Type].y, _colorBin=ears[Type].y}
  list.Ears[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Ears[Type].Bin]
 end 
 -- Nose appearance
 list.Nose = {}
 for Type,_ in pairs(nose) do
  list.Nose[Type] = {Part='Nose', Type=Type, Value=nose[Type].n, Bin=nose[Type].y, _colorBin=nose[Type].y}
  list.Nose[Type].String = modifiers[df.appearance_modifier_type[Type]][list.Nose[Type].Bin]
 end
 -- Other colors
 list.OtherColors = {}
 for i,other in pairs(otherColors) do
  --list.OtherColors[i] = {}
  list.OtherColors[i] = {Part=other.PartName, Type='Color', Value=other.ColorToken, Bin='--', String=other.ColorString}
 end
 -- Other hair styles (can they be colored differently???)
 for i,other in pairs(otherHairs) do
  list[i] = {}
  list[i].Style  = {Part=other.PartName, Type='Style', Value=other.StyleToken, Bin='--', String=styles[df.tissue_style_type[other.StyleToken]]}
  for Type,_ in pairs(other) do
   if Type ~= 'StyleToken' and Type ~= 'PartName' then
    list[i][Type] = {Part=other.PartName, Type=Type, Value=other[Type].n, Bin=other[Type].y, _colorBin=other[Type].y}
	list[i][Type].String = modifiers[df.appearance_modifier_type[Type]][list[i][Type].Bin]
   end
  end
 end
 -- Body part modifier(s)
 for i,part in pairs(parts) do
  list[i] = {}
  for j,Type in pairs(part) do
   list[i][j] = {Part=i, Type=j, Value=Type.n, Bin=Type.y, _colorBin=Type.y}
   list[i][j].String = modifiers[df.appearance_modifier_type[j]][list[i][j].Bin]
  end
 end
 
 return list
end
function appearance_description(unit)
 local list = appearance_detail(unit)
 local strings = {}
 local strTemps = {}
 local strOut = ''
 p1,p2 = getPronoun(unit)

 -- Need to actually generate the strings associated with the details
 for bp, tbl in pairs(list) do
  strings[bp] = {}
  for x, y in pairs(tbl) do
   if df.appearance_modifier_type[x] then
    strings[bp][x] = modifiers[df.appearance_modifier_type[x]][y.Bin]
   elseif x == 'Color' then
    strings[bp][x] = y.String
   elseif x == 'Style' then
    strings[bp][x] = styles[df.tissue_style_type[y.Value]]
   end
  end
 end

 strTemps['Body'] = ''
 if strings['Body'] then
  s1 = ''
  s2 = ''
  a = strings['Body'].HEIGHT or ''
  if a ~= '' then s1 = 'is '..a end
  b = strings['Body'].BROADNESS or ''
  if b ~= '' then s2 = 'a '..b..' frame' end
  if s2 ~= '' and s1 == '' then
   strTemps['Body'] = p1..' has '..s2..'. '
  elseif s1 ~= '' and s2 == '' then
   strTemps['Body'] = p1..' '..s1..'. '
  elseif s1 ~= '' and s2 ~= '' then
   strTemps['Body'] = p1..' '..s1..' with '..s2..'. '
  end
 end
 strTemps['Hair'] = ''
 if strings['Hair'] then
  if strings['Hair'].Style == 'clean shaven' then
   strTemps['Hair'] = p2..' hair is clean shaven. '
  else
   s1 = ''
   a = strings['Hair'].LENGTH or ''
   if a ~= '' then s1 = s1..' '..a..',' end
   b = strings['Hair'].CURLY  or ''
   if b ~= '' then s1 = s1..' '..b..',' end
   c = strings['Hair'].DENSE  or ''
   if c ~= '' then s1 = s1..' '..c..',' end
   d = strings['Hair'].Style  or ''
   if d ~= '' then s1 = s1..' '..d..',' end
   s1 = fixString(s1)
   e = strings['Hair'].Color  or ''
   if e ~= '' and s1 ~= '' then s1 = e..', '..s1 end
   if e ~= '' and s1 == '' then s1 = e end
   if s1 ~= '' then strTemps['Hair'] = p2..' hair is '..s1..'. ' end
  end
 end
 strTemps['Eyes'] = ''
 if strings['Eyes'] then
  s1 = ''
  a = strings['Eyes'].LARGE_IRIS or ''
  if a ~= '' then s1 = s1..' '..a..',' end
  b = strings['Eyes'].DEEP_SET or ''
  if b ~= '' then s1 = s1..' '..b..',' end
  c = strings['Eyes'].CLOSE_SET or ''
  if c ~= '' then s1 = s1..' '..c..',' end
  d = strings['Eyes'].ROUND_VS_NARROW or ''
  if d ~= '' then s1 = s1..' '..d..',' end
  s1 = fixString(s1)
  e = strings['Eyes'].Color or ''
  if e ~= '' and s1 ~= '' then 
   s1 = e..', '..s1 
  elseif e ~= '' and s1 == '' then
   s1 = e
  end
  if s1 ~= '' then strTemps['Eyes'] = p2..' eyes are '..s1..'. ' end
 end
 strTemps['Skin'] = ''
 if strings['Skin'] then
  s1 = ''
  a = strings['Skin'].WRINKLY or ''
  if a ~= '' then s1 = a..', ' end
  b = strings['Skin'].Color or ''
  if b ~= '' then s1 = s1..b..' colored' end
  if s1 ~= '' then strTemps['Skin'] = p1..' has '..s1..' skin. ' end
 end
 strTemps['Skull'] = ''
 if strings['skull'] then
  s1 = ''
  a = strings['skull'].BROAD_CHIN or ''
  if a ~= '' then s1 = s1..' '..a..',' end
  b = strings['skull'].SQUARE_CHIN or ''
  if b ~= '' then s1 = s1..' '..b..',' end
  c = strings['skull'].JUTTING_CHIN or ''
  if c ~= '' then s1 = s1..' '..c..',' end
  if s1 ~= '' then
   s1 = fixString(s1)
   strTemps['Skull'] = p2..' chin is '..s1..'. '
  end
 end
 strTemps['Head'] = ''
 if strings['head'] then
  s1 = ''
  s2 = ''
  a = strings['head'].HEIGHT or ''
  b = strings['head'].BROADNESS or ''
  if a ~= '' and b ~= '' then
   s1 = a..' and '..b
  else
   s1 = a..b
  end
  c = strings['skull'].HIGH_CHEEKBONES or ''
  if c ~= '' then s2 = c..' cheekbones' end
  if s1 == '' and s2 ~= '' then
   strTemps['Head'] = p2..' head has '..s2..'. '
  elseif s1 ~= '' and s2 == '' then
   strTemps['Head'] = p2..' head is '..s1..'. '
  elseif s1 ~= '' and s2 ~= '' then
   strTemps['Head'] = p2..' head is '..s1..' with '..s2..'. '
  end
 end
 strOut = strTemps['Body']..strTemps['Skin']..strTemps['Eyes']..strTemps['Hair']..strTemps['Head']..strTemps['Skull']

 return strOut
end

-- Attributes 
-- Physical (unit.body.phys_attrs)
-- Mental (unit.status.curren_soul.personality.mental_attrs)
-- To reference the correct string, convert value into -4 to 4 bins based on average
--  < -1000 | - 750 | -500 | -250 | 250 | 500 | 750 | 1000 >
-- -4      -3      -2     -1      0     1     2     3      4
-- string = attributes_phys[ATTRIBUTE_TOKEN][bin]
attributes_phys = { 
  [df.physical_attribute_type.STRENGTH]           = {
    [-4] = "unfathomably weak",
    [-3] = "unquestionably weak",
    [-2] = "very weak",
    [-1] = "weak",
    [0]  = "average strength",
    [1]  = "strong",
    [2]  = "very strong",
    [3]  = "mighty",
    [4]  = "unbelievably strong"},
  [df.physical_attribute_type.AGILITY]            = {
    [-4] = "abysmally clumsy",
    [-3] = "totally clumsy",
    [-2] = "quite clumsy",
    [-1] = "clumsy",
    [0]  = "average agility",
    [1]  = "agile",
    [2]  = "very agile",
    [3]  = "extremely agile",
    [4]  = "amazingly agile"},
  [df.physical_attribute_type.TOUGHNESS]          = {
    [-4] = "shockingly fragile",
    [-3] = "remarkably flimsy",
    [-2] = "very flimsy",
    [-1] = "flimsy",
    [0]  = "average toughness",
    [1]  = "tough",
    [2]  = "quite durable",
    [3]  = "incredibly tough",
    [4]  = "basically unbreakable"},
  [df.physical_attribute_type.ENDURANCE]          = {
    [-4] = "truly quick to tire",
    [-3] = "extremely quick to tire",
    [-2] = "very quick to tire",
    [-1] = "quick to tire",
    [0]  = "average endurance",
    [1]  = "slow to tire",
    [2]  = "very slow to tire",
    [3]  = "indefatigable",
    [4]  = "absolutely inexhaustible"},
  [df.physical_attribute_type.RECUPERATION]       = {
    [-4] = "shockingly slow to heal",
    [-3] = "really slow to heal",
    [-2] = "very slow to heal",
    [-1] = "slow to heal",
    [0]  = "average recuperation",
    [1]  = "quick to heal",
    [2]  = "quite quick to heal",
    [3]  = "increadibly quick to heal",
    [4]  = "possessed of amazing recuperative powers"},
  [df.physical_attribute_type.DISEASE_RESISTANCE] = {
    [-4] = "stunningly susceptible to disease",
	[-3] = "really susceptible to disease",
	[-2] = "quite susceptible to disease",
	[-1] = "susceiptible to disease",
	[0]  = "average disease resistance",
	[1]  = "rarely sick",
	[2]  = "very rarely sick",
	[3]  = "almost never sick",
	[4]  = "virtually never sick"}}
attributes_ment = {
  [df.mental_attribute_type.ANALYTICAL_ABILITY] = {
    [-4] = "a stunning lack of analytical ability",
    [-3] = "a lousy intellect",
    [-2] = "very bad analytical abilities",
    [-1] = "poor analytic abilities",
    [0]  = "average analytical ability",
    [1]  = "a good intellect",
    [2]  = "a sharp intellect",
    [3]  = "great analytical abilities",
    [4]  = "awesome intellectual powers"},
  [df.mental_attribute_type.FOCUS]              = {
    [-4] = "the absolute inability to focus",
    [-3] = "really poor focus",
    [-2] = "quite poor focus",
    [-1] = "poor focus",
    [0]  = "average focus",
    [1]  = "the ability to focus",
    [2]  = "very good focus",
    [3]  = "a great ability to focus",
    [4]  = "unbreakable focus"},
  [df.mental_attribute_type.WILLPOWER]          = {
    [-4] = "absolutely no willpower",
    [-3] = "next to no willpower",
    [-2] = "a large deficit of willpower",
    [-1] = "little willpower",
    [0]  = "average willpower",
    [1]  = "willpower",
    [2]  = "a lot of willpower",
    [3]  = "an iron will",
    [4]  = "an unbreakable will"},
  [df.mental_attribute_type.CREATIVITY]         = {
    [-4] = "next to no creative talent",
    [-3] = "lousy creativity",
    [-2] = "poor creativity",
    [-1] = "meager creativity",
    [0]  = "average creativity",
    [1]  = "good creativity",
    [2]  = "very good creativity",
    [3]  = "great creativity",
    [4]  = "a boundless creative imagination"},
  [df.mental_attribute_type.INTUITION]          = {
    [-4] = "horrible intuition",
    [-3] = "lousy intuition",
    [-2] = "very bad intuition",
    [-1] = "bad intuition",
    [0]  = "average intuition",
    [1]  = "good intuition",
    [2]  = "very good intuition",
    [3]  = "great intuition",
    [4]  = "uncanny intuition"},
  [df.mental_attribute_type.PATIENCE]           = {
    [-4] = "no patience at all",
    [-3] = "very little patience",
    [-2] = "little patience",
    [-1] = "a shortage of patience",
    [0]  = "average patience",
    [1]  = "a sum of patience",
    [2]  = "a great deal of patience",
    [3]  = "a deep well of patience",
    [4]  = "absolutely boundless patience"},
  [df.mental_attribute_type.MEMORY]             = {
    [-4] = "little memory to speak of",
    [-3] = "a really bad memory",
    [-2] = "a poor memory",
    [-1] = "an iffy memory",
    [0]  = "average memory",
    [1]  = "a good memory",
    [2]  = "a great memory",
    [3]  = "an amazing memory",
    [4]  = "an astonishing memory"},
  [df.mental_attribute_type.LINGUISTIC_ABILITY] = {
    [-4] = "difficulty with words and language",
    [-3] = "very little linguistic ability",
    [-2] = "little linguistic ability",
    [-1] = "a little difficulty with words",
    [0]  = "average linguistic ability",
    [1]  = "a way with words",
    [2]  = "a natural inclination toward language",
    [3]  = "a great affinity for language",
    [4]  = "an astonishing ability with languages and words"},
  [df.mental_attribute_type.SPATIAL_SENSE]      = {
    [-4] = "no sense for spatial relationships",
    [-3] = "an atrocious spatial sense",
    [-2] = "poor spatial senses",
    [-1] = "a questionable spatial sense",
    [0]  = "average spatial sense",
    [1]  = "a good spatial sense",
    [2]  = "a great feel for the surrounding space",
    [3]  = "an amazing spatial sense",
    [4]  = "a stunning feel for spatial relationships"},
  [df.mental_attribute_type.MUSICALITY]         = {
    [-4] = "absolutely no feel for music at all",
    [-3] = "next to no natural musical ability",
    [-2] = "little natural inclination toward music",
    [-1] = "an iffy sense for music",
    [0]  = "average musicality",
    [1]  = "a feel for music",
    [2]  = "a natural ability with music",
    [3]  = "a great musical sense",
    [4]  = "an astonishing knock for music"},
  [df.mental_attribute_type.KINESTHETIC_SENSE]  = {
    [-4] = "an unbelievably atrocious sense of the position of own body",
    [-3] = "a very clumsy kinesthetic sense",
    [-2] = "a poor kinesthetic sense",
    [-1] = "a meager kinesthetic sense",
    [0]  = "average kinesthetic sense",
    [1]  = "a good kinesthetic sense",
    [2]  = "a very good sense of the position of own body",
    [3]  = "a great kinesthetic sense",
    [4]  = "an astounding feel for the position of own body"},
  [df.mental_attribute_type.EMPATHY]            = {
    [-4] = "the utter inability to judge others' emotions",
    [-3] = "next to no empathy",
    [-2] = "a very bad sense of empathy",
    [-1] = "poor empathy",
    [0]  = "average empathy",
    [1]  = "an ability to read emotions fairly well",
    [2]  = "a very good sense of empathy",
    [3]  = "a great sense of empathy",
    [4]  = "an absolutely remarkable sense of others' emotions"},
  [df.mental_attribute_type.SOCIAL_AWARENESS]   = {
    [-4] = "an absolute inability to understand social relationships",
    [-3] = "a lack of understanding of social relationships",
    [-2] = "a poor ability to manage or understand social relationships",
    [-1] = "a meager ability with social relationships",
    [0]  = "average social awareness",
    [1]  = "a good feel for social relationships",
    [2]  = "a very good feel for social relationships",
    [3]  = "a great feel for social relationships",
    [4]  = "a shockingly profound feel for social relationships"}}
function attribute_string(attribute,v,n)
 -- v = current attribute value
 -- n = CREATURE:CASTE attribute ranges
 local bin = 0
 local str = ""
 d = v-n[3]
 if d >= 1000 then
  bin = 4
 elseif d >= 750 then
  bin = 3
 elseif d >= 500 then
  bin = 2
 elseif d >= 250 then
  bin = 1
 elseif d < -250 then
  bin = -1
 elseif d < -500 then
  bin = -2
 elseif d < -750 then
  bin = -3
 elseif d < -1000 then
  bin = -4
 end
 if df.physical_attribute_type[attribute] then
  str = attributes_phys[df.physical_attribute_type[attribute]][bin]
 elseif df.mental_attribute_type[attribute] then
  str = attributes_ment[df.mental_attribute_type[attribute]][bin]
 else
  bin = 0 -- Figure out the bin
  str = "" -- No custom attribute strings yet
 end
 return str, bin
end
function attribute_description(unit,Type)
 local strOut = ''
 local pronoun = getPronoun(unit)
 
 if Type == 'Physical' then
  plusStr  = ''
  minusStr = ''
  for attribute,_ in pairs(unit.body.physical_attrs) do
   range = df.global.world.raws.creatures.all[unit.race].caste[unit.sex].attributes.phys_att_range[attribute]
   value = unit.body.physical_attrs[attribute].value
   tempstr, bin = attribute_string(attribute,value,range)
   if     bin > 0 then
    plusStr = plusStr..tempstr..', '
   elseif bin < 0 then
    minusStr = minusStr..tempstr..', '
   end
  end
  plusStr = fixString(plusStr)
  minusStr = fixString(minusStr)
  if plusStr == '' and minusStr == '' then
   strOut = pronoun..' is unremarkably average physically'
  elseif plusStr == '' then
   strOut = pronoun..' is '..minusStr
  elseif minusStr == '' then
   strOut = pronoun..' is '..plusStr
  else
   strOut = pronoun..' is '..plusStr..', but '..minusStr
  end
  
 elseif Type == 'Mental' then
  plusStr  = ''
  minusStr = ''
  for attribute,_ in pairs(unit.status.current_soul.mental_attrs) do
   range = df.global.world.raws.creatures.all[unit.race].caste[unit.sex].attributes.ment_att_range[attribute]
   value = unit.status.current_soul.mental_attrs[attribute].value
   tempstr, bin = attribute_string(attribute,value,range)
   if     bin > 0 then
    plusStr = plusStr..tempstr..', '
   elseif bin < 0 then
    minusStr = minusStr..tempstr..', '
   end
  end
  plusStr = fixString(plusStr)
  minusStr = fixString(minusStr)
  if plusStr == '' and minusStr == '' then
   strOut = pronoun..' has unremarkably average mental attributes'
  elseif plusStr == '' then
   strOut = pronoun..' has '..minusStr
  elseif minusStr == '' then
   strOut = pronoun..' has '..plusStr
  else
   strOut = pronoun..' has '..plusStr..', but '..minusStr
  end 
 end
 
 return strOut
end

-- Skills
skills = {
  ['Gathering']   = {
    ['MINING']      = true,
    ['WOODCUTTING'] = true,
    ['TRAPPING']    = true,
    ['HERBALISM']   = true,
    ['FISH']        = true},
  ['Crafting']    = {
    ['CARPENTRY']       = true,
    ['DETAILSTONE']     = true,
    ['MASONRY']         = true,
    ['TANNER']          = true,
    ['WEAVING']         = true,
    ['BREWING']         = true,
    ['ALCHEMY']         = true,
    ['CLOTHESMAKING']   = true,
    ['CHEESEMAKING']    = true,
    ['COOK']            = true,
    ['SMELT']           = true,
    ['EXTRACT_STRAND']  = true,
    ['FORGE_WEAPON']    = true,
    ['FORGE_ARMOR']     = true,
    ['FORGE_FURNITURE'] = true,
    ['CUTGEM']          = true,
    ['ENCRUSTGEM']      = true,
    ['WOODCRAFT']       = true,
    ['STONECRAFT']      = true,
    ['METALCRAFT']      = true,
    ['GLASSMAKER']      = true,
    ['LEATHERWORK']     = true,
    ['BONECARVE']       = true,
    ['SIEGECRAFT']      = true,
    ['BOWYER']          = true,
    ['MECHANICS']       = true,
    ['WOOD_BURNING']    = true,
    ['DESIGNBUILDING']  = true,
    ['LYE_MAKING']      = true,
    ['SOAP_MAKING']     = true,
    ['POTASH_MAKING']   = true,
    ['DYER']            = true,
    ['KNAPPING']        = true,
    ['POTTERY']         = true,
    ['GLAZING']         = true,
    ['PRESSING']        = true,
    ['SPINNING']        = true,
    ['WAX_WORKING']     = true,
    ['PAPERMAKING']     = true,
    ['BOOKBINDING']     = true},
  ['Farming']     = {
    ['ANIMALTRAIN']    = true,
    ['ANIMCALCARE']    = true,
    ['DISSECT_FISH']   = true,
    ['DISSECT_VERMIN'] = true,
    ['PROCESSFISH']    = true,
    ['BUTCHER']        = true,
    ['MILLING']        = true,
    ['PROCESSPLANTS']  = true,
    ['MILK']           = true,
    ['PLANT']          = true,
    ['TRACKING']       = true,
    ['SHEARING']       = true,
    ['BEEKEEPING']     = true,
    ['GELD']           = true},
  ['Military']    = {
    ['AXE'] = true,
    ['SWORD'] = true,
    ['DAGGER'] = true,
    ['MACE'] = true,
    ['HAMMER'] = true,
    ['SPEAR'] = true,
    ['CROSSBOW'] = true,
    ['SHIELD'] = true,
    ['ARMOR'] = true,
    ['SIEGEOPERATE'] = true,
    ['PIKE'] = true,
    ['WHIP'] = true,
    ['BOW'] = true,
    ['BLOWGUN'] = true,
    ['THROW'] = true,
    ['SNEAK'] = true,
    ['DISCIPLINE'] = true,
    ['SITUATIONAL_AWARENESS'] = true,
    ['COORDINATION'] = true,
    ['BALANCE'] = true,
    ['MELEE_COMBAT'] = true,
    ['RANGED_COMBAT'] = true,
    ['WRESTLING'] = true,
    ['BITE'] = true,
    ['GRASP_STRIKE'] = true,
    ['STANCE_STRIKE'] = true,
    ['DODGING'] = true,
    ['MISC_WEAPON'] = true,
    ['MILITARY_TACTICS'] = true,},
  ['Health']      = {
    ['DRESS_WOUNDS'] = true,
    ['DIAGNOSE']     = true,
    ['SURGERY']      = true,
    ['SET_BONE']     = true,
    ['SUTURE']       = true},
  ['Performance'] = {
    ['WRITING']    = true,
    ['PROSE']      = true,
    ['POETRY']     = true,
    ['DANCE']      = true,
    ['MAKE_MUSIC'] = true,
    ['SING_MUSIC'] = true,
    ['PLAY_KEYBOARD_INSTRUMENT']   = true,
    ['PLAY_STRINGED_INSTRUMENT']   = true,
    ['PLAY_WIND_INSTRUMENT']       = true,
    ['PLAY_PERCUSSION_INSTRUMENT'] = true},
  ['Social']      = {
    ['PERSUASION'] = true,
    ['NEGOTIATION'] = true,
    ['JUDGING_INTENT'] = true,
    ['APPRAISAL'] = true,
    ['ORGANIZATION'] = true,
    ['RECORD_KEEPING'] = true,
    ['LYING'] = true,
    ['INTIMIDATION'] = true,
    ['CONVERSATION'] = true,
    ['COMEDY'] = true,
    ['FLATTERY'] = true,
    ['CONSOLE'] = true,
    ['PACIFY'] = true,
    ['KNOWLEDGE_ACQUISITION'] = true,
    ['CONCENTRATION'] = true,
    ['READING'] = true,
    ['SPEAKING'] = true,
    ['LEADERSHIP'] = true,
    ['TEACHING'] = true,
    ['CRITICAL_THINKING'] = true,
    ['LOGIC'] = true,},
  ['Science']     = {
    ['MATHEMATICS']     = true,
    ['ASTRONOMY']       = true, 
    ['CHEMSITRY']       = true,
    ['GEOGRAPHY']       = true,
    ['OPTICS_ENGINEER'] = true,
    ['FLUID_ENGINEER']  = true,
    ['MAGIC_NATURE']    = true}
}

-- Traits/Facets (unit.status.current_soul.personality.traits)
-- To reference the correct string use type and convert strength into -3 to 3 bins
--  <  10  |  25  |  40  |  61  |  76  |  91  >
-- -3     -2     -1      0      1      2      3
-- string = traits[unit.status.current_soul.personality.traits[#]][bin]
traits = {
  ['LOVE_PROPENSITY']       = {
   [-3] = 'never falls in love or develops positive feelings toward anything',
   [-2] = 'is not the type to fall in love or even develop positive feelings',
   [-1] = 'does not easily fall in love and rarely develops positive sentiments',
   [0]  = '',
   [1]  = 'can easily fall in love or develop positive sentiments',
   [2]  = 'very easily falls into love and develops positive feelings',
   [3]  = 'is always in love with somebody and easily develops positive feelings'},
  ['HATE_PROPENSITY']       = {
   [-3] = 'never feels hatred toward anyone or anything',
   [-2] = 'very rarely develops negative feelings toward things',
   [-1] = 'does not easily hate or develop negative feelings',
   [0]  = '',
   [1]  = 'is quick to form negative views about things',
   [2]  = 'is prone to hatreds and often develops negative feelings',
   [3]  = 'is often inflamed by hatred and easily develops hatred toward things'},
  ['ENVY_PROPENSITY']       = {
   [-3] = 'never envies others their status, situation or possessions',
   [-2] = 'is rarely jealous',
   [-1] = "doesn't often feel envious of others",
   [0]  = '',
   [1]  = 'often feels envious of others',
   [2]  = 'is prone to strong feelings of jealousy',
   [3]  = 'is consumed by overpowering feelings of jealousy'},
  ['CHEER_PROPENSITY']      = {
   [-3] = 'is never the slightest bit cheerful about anything',
   [-2] = 'is dour as a rule',
   [-1] = 'is rarely happy or enthusiastic',
   [0]  = '',
   [1]  = 'is often cheerful',
   [2]  = 'can be very happy and optimistic',
   [3]  = 'often feels filled with joy'},
  ['DEPRESSION_PROPENSITY'] = {
   [-3] = 'never feels discouraged',
   [-2] = 'almost never feels discouraged',
   [-1] = 'rarely feels discouraged',
   [0]  = '',
   [1]  = 'often feels discouraged',
   [2]  = 'is often sad and dejected',
   [3]  = 'is frequently depressed'},
  ['ANGER_PROPENSITY']      = {
   [-3] = 'never becomes angry',
   [-2] = 'is very slow to anger',
   [-1] = 'is slow to anger',
   [0]  = '',
   [1]  = 'is quick to anger',
   [2]  = 'is very quick to anger',
   [3]  = 'is in a constant state of internal rage'},
  ['ANXIETY_PROPENSITY']    = {
   [-3] = 'has an incredibly calm demeanor',
   [-2] = 'has a very calm demeanor',
   [-1] = 'has a calm demeanor',
   [0]  = '',
   [1]  = 'is often nervous',
   [2]  = 'is always tense and jittery',
   [3]  = 'is a nervous wreck'},
  ['LUST_PROPENSITY']       = {
   [-3] = 'never feels lustful passions',
   [-2] = 'rarely looks on others with lust',
   [-1] = 'does not often feel lustful',
   [0]  = '',
   [1]  = 'often feels lustful',
   [2]  = 'is prone to strong feelings of lust',
   [3]  = 'is constantly ablaze with feelings of lust'},
  ['STRESS_VULNERABILITY']  = {
   [-3] = 'is impervious to the effects of stress',
   [-2] = 'is confident under pressure',
   [-1] = 'can handle stress',
   [0]  = '',
   [1]  = "doesn't handle stress well",
   [2]  = 'cracks easily under pressure',
   [3]  = 'becomes completely helpless in stressful situations'},
  ['GREED']                 = {
   [-3] = 'often neglects their own wellbeing, having no interest in material goods',
   [-2] = 'desires little for themselves in the way of possessions',
   [-1] = "doesn't focus on material goods",
   [0]  = '',
   [1]  = 'has a greedy streak',
   [2]  = 'is very greedy',
   [3]  = 'is as avaricious as they come, obsessed with acquiring wealth'},
  ['IMMODERATION']          = {
   [-3] = 'never feels tempted to overindulge in anything',
   [-2] = 'only rarely feels strong cravings or urges',
   [-1] = "doesn't often experience strong cravings or urges",
   [0]  = '',
   [1]  = 'occasionally overindulges',
   [2]  = 'feels strong urges and seeks short-term rewards',
   [3]  = 'is ruled by irresistible cravings and urges'},
  ['VIOLENT']               = {
   [-3] = 'would flee even the most necessary battle to avoid any form of physical confrontation',
   [-2] = 'does not enjoy participating in physical confrontations',
   [-1] = 'tends to avoid any physical confrontations',
   [0]  = '',
   [1]  = 'likes to brawl',
   [2]  = 'would never pass up a chance for a good fistfight',
   [3]  = 'is given to rough-and-tumble brawling, even to the point of starting fights for no reason'},
  ['PERSEVERENCE']          = {
   [-3] = 'drops any activity at the slightest hint of difficulty or even the suggestion of effort being required',
   [-2] = "doesn't stick with things if even minor difficulties arise",
   [-1] = 'has a noticeable lack of perseverance',
   [0]  = '',
   [1]  = 'is stubborn',
   [2]  = 'is very stubborn',
   [3]  = 'is unbelievably stubborn, and will stick with even the most futile action once their mind is made up'},
  ['WASTEFULNESS']          = {
   [-3] = 'cuts any corners possible when working on a project, regardless of the consequences, rather than wasting effort or resources',
   [-2] = 'is stingy with resources on projects and refuses to expend any extra effort',
   [-1] = 'tends to be a little tight with resources when working on projects',
   [0]  = '',
   [1]  = 'tends to be a little wasteful when working on projects',
   [2]  = 'is not careful with resources when working on projects and often spends unnecessary effort',
   [3]  = 'is completely careless with resources when completing projects, and invariably wastes a lot of time and effort'},
  ['DISCORD']               = {
   [-3] = 'would be deeply satisfied if everyone could live as one in complete harmony',
   [-2] = 'feels best when everyone gets along without any strife or contention',
   [-1] = 'prefers that everyone live as harmoniously as possible',
   [0]  = '',
   [1]  = "doesn't mind a little tumult and discord in day-to-day living",
   [2]  = 'finds a chaotic mess preferable to the boredom of harmonious living',
   [3]  = 'revels in chaos and discord, and encourages it whenever possible'},
  ['FRIENDLINESS']          = {
   [-3] = 'is a dyed-in-the-wool quarreler, never missing a chance to lash out in verbal hostility',
   [-2] = 'is unfriendly and disagreeable',
   [-1] = 'is somewhat quarrelsome',
   [0]  = '',
   [1]  = 'is a friendly individual',
   [2]  = 'is very friendly and always tries to say nice things to others',
   [3]  = 'is quite a bold flatterer, extremely friendly but just a little insufferable'},
  ['POLITENESS']            = {
   [-3] = 'is a vulgar being who does not care a lick for even the most basic rules of civilized living',
   [-2] = 'is very impolite and inconsiderate of propriety',
   [-1] = 'could be considered rude',
   [0]  = '',
   [1]  = 'is quite polite',
   [2]  = 'is very polite and observes appropriate rules of decorum when possible',
   [3]  = 'exhibits a refined politeness and is determined to keep the guiding rules of etiquette and decorum as if life itself depended on it'},
  ['DISDAIN_ADVICE']        = {
   [-3] = 'is unable to make decisions without a great deal of input from others',
   [-2] = 'relies on the advice of others during decision making',
   [-1] = 'tends to ask others for help with difficult decisions',
   [0]  = '',
   [1]  = 'has a tendency to go it alone, without considering the advice of others',
   [2]  = 'dislikes receiving advice, preferring to keep their own counsel',
   [3]  = 'disdains even the best advice of associates and family, relying strictly on their own counsel'},
  ['BRAVERY']               = {
   [-3] = 'is a coward, completely overwhelmed by fear when confronted with danger',
   [-2] = 'has great trouble mastering fear when confronted by danger',
   [-1] = 'is somewhat fearful in the face of imminent danger',
   [0]  = '',
   [1]  = 'is brave in the face of imminent danger',
   [2]  = 'is incredibly brave in the face of looming danger, perhaps a bit foolhardy',
   [3]  = 'is utterly fearless when confronted with danger, to the point of lacking common sense'},
  ['CONFIDENCE']            = {
   [-3] = 'has no confidence at all in their talent and abilities',
   [-2] = 'lacks confidence in their abilities',
   [-1] = 'sometimes acts with little determination and confidence',
   [0]  = '',
   [1]  = 'is generally quite confident of their abilities when undertaking specific ventures',
   [2]  = 'is extremely confident of themselves in situations requiring their skills',
   [3]  = 'presupposes success in any venture requiring [their skills with what could be called blind overconfidence'},
  ['VANITY']                = {
   [-3] = 'could not care less about their appearance, talents or other personal vanities',
   [-2] = 'takes no pleasure in their talents and appearance',
   [-1] = 'is not inherently proud of their talents and accomplishments',
   [0]  = '',
   [1]  = 'is pleased by their own appearance and talents',
   [2]  = 'is greatly pleased by their own looks and accomplishments',
   [3]  = 'is completely wrapped up in their own appearance, abilities and other personal matters'},
  ['AMBITION']              = {
   [-3] = 'has no ambition whatsoever',
   [-2] = 'is not driven and rarely feels the need to pursue even a modest success',
   [-1] = "isn't particularly ambitious",
   [0]  = '',
   [1]  = 'is quite ambitious',
   [2]  = 'is very ambitious, always looking for a way to better their situation',
   [3]  = 'has a relentless drive, completely consumed by ambition'},
  ['GRATITUDE']             = {
   [-3] = 'does not feel the slightest need to reciprocate favors that others do for them, no matter how major the help or how much they needed it',
   [-2] = 'accepts favors without developing a sense of obligation, preferring to act as the current situation demands',
   [-1] = 'takes offered help and gifts without feeling particularly grateful',
   [0]  = '',
   [1]  = 'is grateful when others help them out and tries to return favors',
   [2]  = 'feels a strong need to reciprocate any favor done for them',
   [3]  = 'unerringly returns favors and has a profound sense of gratitude for the kind actions of others'},
  ['IMMODESTY']             = {
   [-3] = 'cleaves to an austere lifestyle, disdaining even minor immodesties in appearance',
   [-2] = 'presents themselves modestly and frowns on any flashy accoutrements',
   [-1] = 'prefers to present themselves modestly',
   [0]  = '',
   [1]  = "doesn't mind wearing something special now and again",
   [2]  = 'likes to present themselves boldly, even if it would offend an average sense of modesty',
   [3]  = 'always presents themselves as extravagantly as possible, displaying a magnificent image to the world'},
  ['HUMOR']                 = {
   [-3] = 'is utterly humorless',
   [-2] = 'does not find most jokes humorous',
   [-1] = 'has little interest in joking around',
   [0]  = '',
   [1]  = 'has an active sense of humor',
   [2]  = 'finds the humor in most situations',
   [3]  = 'finds something humorous in everything, no matter how serious or inappropriate'},
  ['VENGEFUL']              = {
   [-3] = 'has no sense of vengeance or retribution',
   [-2] = 'does not generally seek retribution for past wrongs',
   [-1] = "doesn't tend to hold on to grievances",
   [0]  = '',
   [1]  = 'tends to hang on to grievances',
   [2]  = 'has little time for forgiveness and will generally seek retribution',
   [3]  = 'is vengeful and never forgets or forgives past grievances'},
  ['PRIDE']                 = {
   [-3] = 'is completely convinced of their own worthlessness',
   [-2] = 'has a low sense of self-esteem',
   [-1] = 'is very humble',
   [0]  = '',
   [1]  = 'thinks they are fairly important in the grand scheme of things',
   [2]  = 'has an overinflated sense of self-worth',
   [3]  = 'is absorbed in delusions of self-importance'},
  ['CRUELTY']               = {
   [-3] = 'always acts with mercy and compassion at the forefront of their considerations',
   [-2] = 'is easily moved to mercy',
   [-1] = 'often acts with compassion',
   [0]  = '',
   [1]  = 'generally acts impartially and is rarely moved to mercy',
   [2]  = 'is sometimes cruel',
   [3]  = 'is deliberately cruel to those unfortunate enough to be subject to their sadism'},
  ['SINGLEMINDED']          = {
   [-3] = 'is a complete scatterbrain, unable to focus on a single matter for more than a passing moment',
   [-2] = 'is somewhat scatterbrained',
   [-1] = 'can occasionally lose focus on the matter at hand',
   [0]  = '',
   [1]  = 'generally acts with a narrow focus on the current activity',
   [2]  = 'can be very single-minded',
   [3]  = 'pursues matters with a single-minded focus, often overlooking other matters'},
  ['HOPEFUL']               = {
   [-3] = 'despairs of anything positive happening in the future and lives without feelings of hope',
   [-2] = 'is a pessimist',
   [-1] = 'tends to assume the worst of two outcomes will be the one that comes to pass',
   [0]  = '',
   [1]  = 'generally finds themselves quite hopeful about the future',
   [2]  = 'is an optimist',
   [3]  = 'has such a developed sense of optimism that they always assumes the best outcome will eventually occur, no matter what'},
  ['CURIOUS']               = {
   [-3] = 'is incurious and never seeks out knowledge or information to satisfy themselves',
   [-2] = 'is very rarely moved by curiosity',
   [-1] = "isn't particularly curious about the world",
   [0]  = '',
   [1]  = 'is curious and eager to learn',
   [2]  = 'is very curious, sometimes to their detriment',
   [3]  = 'is implacably curious, without any respect for propriety or privacy'},
  ['BASHFUL']               = {
   [-3] = 'is shameless, absolutely unfazed by the thoughts of others',
   [-2] = 'is generally unhindered by the thoughts of others concerning their actions',
   [-1] = 'is not particularly interested in what others think of them',
   [0]  = '',
   [1]  = 'tends to consider what others think of them',
   [2]  = 'is bashful',
   [3]  = 'is gripped by a crippling shyness'},
  ['PRIVACY']               = {
   [-3] = 'is private to the point of paranoia, unwilling to reveal even basic information about themselves',
   [-2] = 'has a strong tendency toward privacy',
   [-1] = 'tends not to reveal personal information',
   [0]  = '',
   [1]  = 'tends to share their own experiences and thoughts with others',
   [2]  = 'is not a private person and freely shares details of their life',
   [3]  = 'shares intimate details of life without sparing a thought to repercussions or propriety'},
  ['PERFECTIONIST']         = {
   [-3] = 'is frustratingly sloppy and careless with every task they sets to carry out',
   [-2] = 'is inattentive to detail in their own work',
   [-1] = "doesn't try to get things done perfectly",
   [0]  = '',
   [1]  = 'tries to do things correctly each time',
   [2]  = 'is a perfectionist',
   [3]  = 'is obsessed with details and will often take a great deal of extra time to make sure things are done the right way'},
  ['CLOSEMINDED']           = {
   [-3] = 'easily changes their mind and will generally go with the prevailing view on anything',
   [-2] = 'often finds themselves changing their mind to agree with somebody else',
   [-1] = "doesn't cling tightly to ideas and is open to changing their mind",
   [0]  = '',
   [1]  = 'tends to be a bit stubborn in changing their mind about things',
   [2]  = 'is intellectually stubborn, rarely changing their mind during a debate regardless of the merits',
   [3]  = 'is completely closed-minded and never changes their mind after forming an initial idea'},
  ['TOLERANT']              = {
   [-3] = 'cannot tolerate differences in culture, lifestyle or appearance',
   [-2] = 'is made deeply uncomfortable by differences in culture or appearance',
   [-1] = 'is somewhat uncomfortable around those that appear unusual or live differently from them',
   [0]  = '',
   [1]  = 'is quite comfortable with others that have a different appearance or culture',
   [2]  = 'is very comfortable around others that are different from them',
   [3]  = 'is not bothered in the slightest by deviations from the norm or even extreme differences in lifestyle or appearance'},
  ['EMOTIONALLY_OBSESSIVE'] = {
   [-3] = "does not have feelings of emotional attachment and has never felt even a moment's connection with another being",
   [-2] = 'forms only fleeting and rare emotional bonds with others',
   [-1] = 'tends to form only tenuous emotional bonds with others',
   [0]  = '',
   [1]  = 'has a tendency toward forming deep emotional bonds with others',
   [2]  = 'forms strong emotional bonds with others, at times to [their detriment',
   [3]  = "is emotionally obsessive, forming life-long attachments even if they aren't reciprocated"},
  ['SWAYED_BY_EMOTIONS']    = {
   [-3] = 'is never moved by the emotions of others',
   [-2] = 'does not generally respond to emotional appeals',
   [-1] = 'tends not to be swayed by emotional appeals',
   [0]  = '',
   [1]  = 'tends to be swayed by the emotions of others',
   [2]  = 'is swayed by emotional appeals',
   [3]  = "is buffeted by others' emotions and can't help but to respond to them"},
  ['ALTRUISM']              = {
   [-3] = 'feels helping others is an imposition on theirtime',
   [-2] = 'dislikes helping others',
   [-1] = 'does not go out of their way to help others',
   [0]  = '',
   [1]  = 'finds helping others emotionally rewarding',
   [2]  = 'finds helping others very emotionally rewarding',
   [3]  = 'is truly fulfilled by assisting those in need'},
  ['DUTIFULNESS']           = {
   [-3] = 'hates vows, obligations, promises and other binding elements that could restrict them',
   [-2] = 'dislikes obligations and will try to avoid being bound by them',
   [-1] = 'finds obligations confining',
   [0]  = '',
   [1]  = 'has a sense of duty',
   [2]  = 'has a strong sense of duty',
   [3]  = 'has a profound sense of duty and obligation'},
  ['THOUGHTLESSNESS']       = {
   [-3] = 'never acts without prolonged deliberation, even to their own detriment and the harm of those around them',
   [-2] = 'can get caught up in internal deliberations when action is necessary',
   [-1] = 'tends to think before acting',
   [0]  = '',
   [1]  = 'can sometimes act without deliberation',
   [2]  = "doesn't generally think before acting",
   [3]  = 'never deliberates before acting, to the point of being considered thoughtless'},
  ['ORDERLINESS']           = {
   [-3] = 'is completely oblivious to any conception of neatness and will just leave things strewn about without a care',
   [-2] = 'is sloppy with their living space',
   [-1] = 'tends to make a small mess with their own possessions',
   [0]  = '',
   [1]  = 'tries to keep their things orderly',
   [2]  = 'lives an orderly life, organized and neat',
   [3]  = 'is obsessed with order and structure in their own life, with everything kept in its proper place'},
  ['TRUST']                 = {
   [-3] = 'sees others as selfish and conniving',
   [-2] = 'does not trust others',
   [-1] = 'is slow to trust others',
   [0]  = '',
   [1]  = 'is trusting',
   [2]  = 'is very trusting',
   [3]  = 'is naturally trustful of everybody'},
  ['GREGARIOUSNESS']        = {
   [-3] = 'considers spending time alone much more important than associating with others',
   [-2] = 'prefers to be alone',
   [-1] = 'tends to avoid crowds',
   [0]  = '',
   [1]  = 'enjoys the company of others',
   [2]  = 'enjoys being in crowds',
   [3]  = 'truly treasures the company of others'},
  ['ASSERTIVENESS']         = {
   [-3] = 'would never under any circumstances speak up or otherwise put forth their point of view in a discussion',
   [-2] = 'only rarely tries to assert themselves in conversation',
   [-1] = 'tends to be passive in discussions',
   [0]  = '',
   [1]  = 'is assertive',
   [2]  = 'has an overbearing personality',
   [3]  = 'is assertive to the point of aggression, unwilling to let others get a word in edgewise when they have something to say'},
  ['ACTIVITY_LEVEL']        = {
   [-3] = 'has an utterly languid pace of easy living, calm and slow',
   [-2] = 'lives at a slow-going and leisurely pace',
   [-1] = 'likes to take it easy',
   [0]  = '',
   [1]  = 'lives a fast-paced life',
   [2]  = 'lives at a high-energy kinetic pace',
   [3]  = 'is driven by a bouncing frenetic energy'},
  ['EXCITEMENT_SEEKING']    = {
   [-3] = 'does everything in their power to avoid excitement and stress',
   [-2] = 'actively avoids exciting or stressful situations',
   [-1] = "doesn't seek out excitement",
   [0]  = '',
   [1]  = 'likes a little excitement now and then',
   [2]  = 'seeks out exciting and adventurous situations',
   [3]  = 'never fails to seek out the most stressful and even dangerous situations'},
  ['IMAGINATION']           = {
   [-3] = 'is interested only in facts and the real world',
   [-2] = 'is grounded in reality',
   [-1] = "isn't given to flights of fancy",
   [0]  = '',
   [1]  = 'has an active imagination',
   [2]  = 'is given to flights of fancy to the point of distraction',
   [3]  = 'is bored by reality and would rather disappear utterly and forever into a world of made-up fantasy'},
  ['ABSTRACT_INCLINED']     = {
   [-3] = 'is concerned only with matters practical to the situation at hand, with absolutely no inclination toward abstract discussion',
   [-2] = 'dislikes abstract discussions and would much rather focus on practical examples',
   [-1] = 'likes to keep things practical, without delving too deeply into the abstract',
   [0]  = '',
   [1]  = 'has a tendency to consider ideas and abstractions over practical applications',
   [2]  = 'strongly prefers discussions of ideas and abstract concepts over handling specific practical issues',
   [3]  = 'eschews practical concerns for philosophical discussion, puzzles, riddles and the world of ideas'},
  ['ART_INCLINED']          = {
		   [-3] = 'is completely unmoved by art or the beauty of nature',
		   [-2] = 'is not readily moved by art or natural beauty',
		   [-1] = 'does not have a great aesthetic sensitivity',
		   [0]  = '',
		   [1]  = 'is moved by art and natural beauty',
		   [2]  = 'greatly moved by art and natural beauty',
		   [3]  = 'can easily become absorbed in art and the beauty of the natural world'}
}
function trait_string(trait,strength)
 local bin = 0
 if strength > 90 then
  bin = 3
 elseif strength > 75 then
  bin = 2
 elseif strength > 60 then
  bin = 1
 elseif strength < 10 then
  bin = -3
 elseif strength < 25 then
  bin = -2
 elseif strength < 40 then
  bin = -1
 end
 return traits[trait][bin], bin
end

-- Goals/Dreams (unit.status.current_soul.personality.dreams)
-- To reference the correct string use dream.type
-- string = goals[unit.status.current_soul.personality.dreams[#].type]
goals = { -- Taken directly from Patrik Lundell's thoughts.lua script
  [df.goal_type.STAY_ALIVE]                  = "**staying alive",
  [df.goal_type.MAINTAIN_ENTITY_STATUS]      = "**maintaining entity status",
  [df.goal_type.START_A_FAMILY]              = "raising a family",
  [df.goal_type.RULE_THE_WORLD]              = "ruling the world",
  [df.goal_type.CREATE_A_GREAT_WORK_OF_ART]  = "creating a great work of art",
  [df.goal_type.CRAFT_A_MASTERWORK]          = "crafting a masterwork someday",
  [df.goal_type.BRING_PEACE_TO_THE_WORLD]    = "bringing lasting peace to the world",
  [df.goal_type.BECOME_A_LEGENDARY_WARRIOR]  = "becoming a legendary warrior",
  [df.goal_type.MASTER_A_SKILL]              = "mastering a skill",
  [df.goal_type.FALL_IN_LOVE]                = "falling in love",
  [df.goal_type.SEE_THE_GREAT_NATURAL_SITES] = "seeing the great natural places of the world",
  [df.goal_type.IMMORTALITY]                 = "**immortality",
  [df.goal_type.MAKE_A_GREAT_DISCOVERY]      = "making a great discovery"}
function goal_description(unit)
 local outStr = ''
 local outColor = COLOR_YELLOW
 local personality = unit.status.current_soul.personality
 local pronoun = getPronoun(unit)

 for i, dream in ipairs (personality.dreams) do
  if goals[dream.type] then
   outStr = outStr..goals[dream.type]..", "
  end
 end
 if outStr == '' then
  outStr = pronoun.." has no dreams"
 else
  outStr = pronoun.." dreams of "..outStr
  outStr = fixString(outStr)
 end
  
 return outStr, outColor
end

-- Values (unit.status.current_soul.personality.values)
-- To reference the correct string use value.type and convert value.strength into -3 to 3 bins
--  < -40  |  -25  |  -10  |  10  |  25  |  40  >
-- -3     -2      -1       0      1      2      3
-- string = values[unit.status.current_soul.personality.values[#].type][strength_bin]
values = { -- List taken directly from Patrik Lundell's thoughts.lua script
  [df.value_type.LAW]             = { 
   [-3] = "finds the idea of law abhorrent",
   [-2] = "disdains the law",
   [-1] = "does not respect the law",
   [0]  = "doesn't feel strongly about the law",
   [1]  = "respects the law",
   [2]  = "has a great deal of respect for the law",
   [3]  = "is an absolute believer in the rule of law"},    
  [df.value_type.LOYALTY]         = { 
   [-3] = "is disgusted by the idea of loyalty",
   [-2] = "disdains loyalty",
   [-1] = "views loyalty unfavorably",
   [0]  = "doesn't particularly value loyalty",
   [1]  = "values loyalty",
   [2]  = "greatly prizes loyalty",
   [3]  = "has the highest regard for loyalty"},
  [df.value_type.FAMILY]          = { 
   [-3] = "finds the idea of family loathsome",
   [-2] = "lacks any respect for family",
   [-1] = "is put off by family",
   [0]  = "does not care about family one way or the other",
   [1]  = "values family",
   [2]  = "values family greatly",
   [3]  = "sees family as one of the most important things in life"},
  [df.value_type.FRIENDSHIP]      = { 
   [-3] = "finds the whole idea of friendship disgusting",
   [-2] = "is completely put off by the idea of friends",
   [-1] = "finds friendship burdensome",
   [0]  = "does not care about friendship",
   [1]  = "thinks friendship is important",
   [2]  = "sees friendship as one of the finer things in life",
   [3]  = "believes friendship is the key to the ideal life"},
  [df.value_type.POWER]           = { 
   [-3] = "finds the acquisition and use of power abhorrent and would have all masters toppled",
   [-2] = "hates those who wield power over others",
   [-1] = "has a negative view of those who exercise power over others",
   [0]  = "doesn't find power particularly praiseworthy",
   [1]  = "respects power",
   [2]  = "sees power over others as something to strive for",
   [3]  = "believes that the acquisition of power over others is the ideal goal in life and worthy of the highest respect"},
  [df.value_type.TRUTH]           = { 
   [-3] = "is repelled by the idea of honesty and lies without compunction",
   [-2] = "sees lying as an important means to an end",
   [-1] = "finds blind honesty foolish",
   [0]  = "does not particularly value the truth",
   [1]  = "values honesty",
   [2]  = "believes that honesty is a high ideal",
   [3]  = "believes the truth is inviolable regardless of the cost"},
  [df.value_type.CUNNING]         = {
   [-3] = "is utterly disgusted by guile and cunning",
   [-2] = "holds shrewd and crafty individuals in the lowest esteem",
   [-1] = "sees guile and cunning as indirect and somewhat worthless",
   [0] = "does not really value cunning and guile",
   [1] = "values cunning",
   [2] = "greatly respects the shrewd and guileful",
   [3] = "holds well-laid plans and shrewd deceptions in the highest regard"},
  [df.value_type.ELOQUENCE]       = {
   [-3] = "sees artful speech and eloquence as a wasteful form of deliberate deception and treats it as such",
   [-2] = "finds [him]self somewhat disgusted with eloquent speakers",
   [-1] = "finds eloquence and artful speech off-putting",
   [0] = "doesn't value eloquence so much",
   [1] = "values eloquence",
   [2] = "deeply respects eloquent speakers",
   [3] = "believes that artful speech and eloquent expression are of the highest ideals"},
  [df.value_type.FAIRNESS]        = {
   [-3] = "is disgusted by the idea of fairness and will freely cheat anybody at any time",
   [-2] = "finds the idea of fair-dealing foolish and cheats whenever [he] finds it profitable",
   [-1] = "sees life as unfair and doesn't mind it that way",
   [0] = "does not care about fairness",  -- one way or the other?
   [1] = "respects fair-dealing and fair-play",
   [2] = "has great respect for fairness",
   [3] = "holds fairness as one of the highest ideals and despises cheating of any kind"},
  [df.value_type.DECORUM]         = {
   [-3] = "is affronted of the whole notion of maintaining decorum and finds so-called dignified people disgusting",
   [-2] = "sees those that attempt to maintain dignified and proper behavior as vain and offensive",
   [-1] = "finds maintaining decorum a silly, fumbling waste of time",
   [0] = "doesn't care very much about decorum",
   [1] = "values decorum, dignity and proper behavior",
   [2] = "greatly respects those that observe decorum and maintain their dignity",
   [3] = "views decorum as a high ideal and is deeply offended by those that fail to maintain it"},
  [df.value_type.TRADITION]       = {
   [-3] = "is disgusted by tradition and would flout any [he] encounters if given a chance",
   [-2] = "find the following of tradition foolish and limiting",
   [-1] = "disregards tradition",
   [0] = "doesn't have any strong feelings about tradition",
   [1] = "values tradition",
   [2] = "is a firm believer in the value of tradition",
   [3] = "holds the maintenance of tradition as one of the highest ideals"},
  [df.value_type.ARTWORK]         = {
   [-3] = "finds art offensive and would have it destroyed whenever possible",
   [-2] = "sees the whole pursuit of art as silly",
   [-1] = "finds artwork boring",
   [0] = "doesn't care about art one way or another",
   [1] = "values artwork",
   [2] = "greatly respects artists and their work",
   [3] = "believes that the creation and appreciation of artwork is one of the highest ideals"},
  [df.value_type.COOPERATION]     = {
   [-3] = "is thoroughly disgusted by cooperation",
   [-2] = "views cooperation as a low ideal not worthy of any respect",
   [-1] = "dislikes cooperation",
   [0] = "doesn't see cooperation as valuable",
   [1] = "values cooperation",
   [2] = "sees cooperation as very important in life",
   [3] = "places cooperation as one of the highest ideals"},
  [df.value_type.INDEPENDENCE]    = {
   [-3] = "hates freedom and would crush the independent spirit wherever it is found",
   [-2] = "sees freedom and independence as completely worthless",
   [-1] = "finds the idea of independence and freedom somewhat foolish",
   [0] = "doesn't really value independence one way or another",
   [1] = "values independence",
   [2] = "treasures independence",
   [3] = "believes that freedom and independence are completely non-negotiable and would fight to defend them"},
  [df.value_type.STOICISM]        = {
   [-3] = "sees concealment of emotions as a betrayal and tries [his] best never to associate with such secretive fools",
   [-2] = "feels that those who attempt to conceal their emotions are vain and foolish",
   [-1] = "sees no value in holding back complaints and concealing emotions",
   [0] = "doesn't see much value in being stoic",
   [1] = "believes it is important to conceal emotions and refrain from complaining",
   [2] = "thinks it is of the utmost importance to present a bold face and never grouse, complain, and even show emotion",
   [3] = "views any show of emotion as offensive"},
  [df.value_type.INTROSPECTION]   = {
   [-3] = "finds the whole idea of introspection completely offensive and contrary to the ideals of a life well-lived",
   [-2] = "thinks that introspection is valueless and those that waste time in self-examination are deluded fools",
   [-1] = "finds introspection to be a waste of time",
   [0] = "doesn't really see the value in self-examination",
   [1] = "sees introspection as important",
   [2] = "deeply values introspection",
   [3] = "feels that introspection and all forms of self-examination are the keys to a good life and worthy of respect"},
  [df.value_type.SELF_CONTROL]    = {
   [-3] = "has abandoned any attempt at self-control and finds the whole concept deeply offensive",
   [-2] = "sees the denial of impulses as a vain and foolish pursuit",
   [-1] = "finds those that deny their impulses somewhat stiff",
   [0] = "doesn't particularly value self-control",
   [1] = "values self-control",
   [2] = "finds moderation and self-control to be very important",
   [3] = "believes that self-mastery and the denial of impulses are of the highest ideals"},
  [df.value_type.TRANQUILITY]     = {
   [-3] = "is disgusted by tranquility and would that the world would constantly churn with noise and activity",
   [-2] = "is greatly disturbed by quiet and a peaceful existence",
   [-1] = "prefers a noisy, bustling life to boring days without activity",
   [0] = "doesn't have a preference between tranquility and tumult",
   [1] = "values tranquility and a peaceful day",
   [2] = "strongly values tranquility and quiet",
   [3] = "views tranquility as one of the highest ideals"},
  [df.value_type.HARMONY]         = {
   [-3] = "believes deeply that chaos and disorder are the truest expressions of life and would disrupt harmony wherever it is found",
   [-2] = "can't fathom why anyone would want to live in an orderly and harmonious society",
   [-1] = "doesn't respect a society that has settled into harmony without debate and strife",
   [0] = "sees equal parts of harmony and discord as parts of life",
   [1] = "values a harmonious existence",
   [2] = "strongly believes that a peaceful and ordered society without dissent is best",
   [3] = "would have the world operate in complete harmony without the least bit of strife and disorder"},
  [df.value_type.MERRIMENT]       = {
   [-3] = "is appalled by merrymaking, parties and other such worthless activities",
   [-2] = "is disgusted by merrymakers",
   [-1] = "sees merrymaking as a waste",
   [0] = "doesn't really value merrymaking",
   [1] = "finds merrymaking and parying worthwhile activities",
   [2] = "truly values merrymaking and parties",
   [3] = "believes that little is better in life than a good party"},
  [df.value_type.CRAFTSMANSHIP]   = {
   [-3] = "views craftdwarfship with disgust and would desecrate a so-called masterwork or two if [he] could get away with it",
   [-2] = "sees the pursuit of good craftdwarfship as a total waste",
   [-1] = "considers craftdwarfship to be relatively worthless",
   [0] = "doesn't particularly care about crafdwarfship",
   [1] = "values good craftdwarfship",
   [2] = "has a great deal of respect for worthy craftdwarfship",
   [3] = "holds craftdwarfship to be of the highest ideals and celebrates talented artisans and their masterworks"},
  [df.value_type.MARTIAL_PROWESS] = {
   [-3] = "abhors those who pursue the mastery of weapons and skill with fighting",
   [-2] = "thinks that the pursuit of the skills of warfare and fighting is a low pursuit indeed",
   [-1] = "finds those that develop skills with weapons and fighting distasteful",
   [0] = "does not really value skills related to fighting",
   [1] = "values martial prowess",
   [2] = "deeply respects skill at arms",
   [3] = "believes that martial prowess defines the good character of an individual"},
  [df.value_type.SKILL]           = {
   [-3] = "sees the whole idea of taking time to master a skill as appalling",
   [-2] = "believes that the time taken to master a skill is a horrible waste",
   [-1] = "finds the pursuit of skill mastery off-putting",
   [0] = "doesn't care if others take the time to master skills",
   [1] = "respects the development of skill",
   [2] = "really respects those that take the time to master a skill",
   [3] = "believes that the mastery of a skill is one of the highest pursuits"},
  [df.value_type.HARD_WORK]       = {
   [-3] = "finds the proposition that one should work hard in life utterly abhorrent",
   [-2] = "thinks working hard is an abject idiocy",
   [-1] = "sees working hard as a foolish waste of time",
   [0] = "doesn't really see the point of working hard",
   [1] = "values hard work",
   [2] = "deeply respects those that work hard at their labors",
   [3] = "believes that hard work is one of the highest ideals and a key to the good life"},
  [df.value_type.SACRIFICE]       = {
   [-3] = "thinks that the whole concept of sacrifice for others is truly disgusting",
   [-2] = "finds sacrifice to be the height of folly",
   [-1] = "sees sacrifice as wasteful and foolish",
   [0] = "doesn't particularly respect sacrifice as a virtue",
   [1] = "values sacrifice",
   [2] = "believes that those who sacrifice for others should be deeply respected",
   [3] = "sacrifice to be one of the highest ideals"},
  [df.value_type.COMPETITION]     = {
   [-3] = "finds the very idea of competition obscene",
   [-2] = "deeply dislikes competition",
   [-1] = "sees competition as wasteful and silly",
   [0] = "doesn't have strong views on competition",
   [1] = "sees competition as reasonably important",
   [2] = "views competition as a crucial driving force of the world",
   [3] = "holds the idea of competition among the most important and would encourage it whenever possible"},
  [df.value_type.PERSEVERENCE]    = {
   [-3] = "finds the notion that one would persevere through adversity completely abhorrent",
   [-2] = "thinks there is something deeply wrong with people the persevere through adversity",
   [-1] = "sees perseverance in the face of adversity as bull-headed and foolish",
   [0] = "doesn't think much about the idea of perseverance",
   [1] = "respects perseverance",
   [2] = "greatly respects individuals that persevere through their trials and labors",
   [3] = "believes that perseverance is one of the greatest qualities somebody can have"},
  [df.value_type.LEISURE_TIME]    = {
   [-3] = "believes that those that take leisure time are evil and finds the whole idea disgusting",
   [-2] = "is offended by leisure time and leisurely living",
   [-1] = "finds leisure time wasteful", --  also "prefers a noisy, bustling life to boring days without activity",?
   [0] = "doesn't think one way or the other about leisure time",
   [1] = "values leisure time",
   [2] = "treasures leisure time and thinks it is very important in life",
   [3] = "believes it would be a fine thing if all time were leisure time"},
  [df.value_type.COMMERCE]        = {
   [-3] = "holds the view that commerce is a vile obscenity",
   [-2] = "finds those that engage in trade and commerce to be fairly disgusting",
   [-1] = "is somewhat put off by trade and commerce",
   [0] = "doesn't particularly respect commerce",
   [1] = "respects commerce",
   [2] = "really respects commerce and those that engage in trade",
   [3] = "sees engaging in commerce as a high ideal in life"},
  [df.value_type.ROMANCE]         = {
   [-3] = "finds even the abstract idea of romance repellent",
   [-2] = "is somewhat disgusted by romance",
   [-1] = "finds romance distasteful",
   [0] = "doesn't care one way or the other about romance",
   [1] = "values romance",
   [2] = "thinks romance is very important in life",
   [3] = "sees romance as one of the highest ideals"},
  [df.value_type.NATURE]          = {
   [-3] = "would just as soon have nature and the great outdoors burned to ashes and converted into a great mining pit",
   [-2] = "has a deep dislike for the natural world",
   [-1] = "finds nature somewhat disturbing",
   [0] = "doesn't care about nature one way or another",
   [1] = "values nature",
   [2] = "has a deep respect for animals, plants and the natural world",
   [3] = "holds nature to be of greater value than most aspects of civilization"},
  [df.value_type.PEACE]           = {
   [-3] = "thinks that the world should be engaged into perpetual warfare",
   [-2] = "believes war is preferable to peace in general",
   [-1] = "sees was as a useful means to an end",
   [0] = "doesn't particularly care between war and peace",
   [1] = "values peace over war",
   [2] = "believes that peace is always preferable to war",
   [3] = "believes that the idea of war is utterly repellent and would have peace at all costs"},
  [df.value_type.KNOWLEDGE]       = {
   [-3] = "sees the attainment and preservation of knowledge as an offensive enterprise engaged in by arrogant fools",
   [-2] = "thinks the quest for knowledge is a delusional fantasy",
   [-1] = "finds the pursuit of knowledge to be a waste of effort",
   [0] = "doesn't see the attainment of knowledge as important",
   [1] = "values knowledge",
   [2] = "views the pursuit of knowledge as deeply important",
   [3] = "finds the quest for knowledge to be of the very highest value"}
}
function value_string(value)
 local strength_bin = 3
 if     value.strength < -40 then
  strength_bin = -3
 elseif value.strength < -25 then
  strength_bin = -2
 elseif value.strength < -10 then
  strength_bin = -1
 elseif value.strength <= 10 then
  strength_bin = 0
 elseif value.strength <= 25 then
  strength_bin = 1
 elseif value.strength <= 40 then
  strength_bin = 2
 end
 return values[value.type][strength_bin], strength_bin
end

-- The following tables are all needed in order to get the thoughts/emotions strings
needs = { -- Taken from Patrik Lundell's thoughts.lua script and translated into a table
  [df.need_type.Socialize]       = "being away from people for too long",
  [df.need_type.DrinkAlcohol]    = "being kept from alcohol for too long",
  [df.need_type.PrayOrMedidate]  = "being unable to pray for too long",
  [df.need_type.StayOccupied]    = "being unoccupied for too long",
  [df.need_type.BeCreative]      = "doing nothing creative for so long",
  [df.need_type.Excitement]      = "leading an unexciting life for so long",
  [df.need_type.LearnSomething]  = "not learning anything for so long",
  [df.need_type.BeWithFamily]    = "being away from family for too long",
  [df.need_type.HearEloquence]   = "being unable to hear eloquent speech for so long",
  [df.need_type.UpholdTradition] = "being away from traditions for too long",
  [df.need_type.SelfExamination] = "a lack of introspection for too long",
  [df.need_type.MakeMerry]       = "being unable to make merry for son long",
  [df.need_type.CraftObject]     = "being unable to practice a craft for too long",
  [df.need_type.MartialTraining] = "being unable to practice a martial art for too long",
  [df.need_type.PracticeSkill]   = "being unable to practice a skill for too long",
  [df.need_type.TakeItEasy]      = "being unable to take it easy for so long",
  [df.need_type.MakeRomance]     = "being unable to make romance for so long",
  [df.need_type.SeeAnimal]       = "being away from animals for so long",
  [df.need_type.SeeGreatBeast]   = "being away from great beasts for so long",
  [df.need_type.AcquireObject]   = "being unable to acquire something for too long",
  [df.need_type.EatGoodMeal]     = "a lack of decent meals for too long",
  [df.need_type.Fight]           = "being unable to fight for too long",
  [df.need_type.CauseTrouble]    = "a lack of trouble-making for too long",
  [df.need_type.Argue]           = "being unable to argue for too long",
  [df.need_type.BeExtravagant]   = "being unable to be extravagant for so long",
  [df.need_type.Wander]          = "being unable to wander for too long",
  [df.need_type.HelpSomebody]    = "being unable to help anybody for too long",
  [df.need_type.ThinkAbstractly] = "a lack of abstract thinking for too long",
  [df.need_type.AdmireArt]       = "being unable to admire art for so long"
}
emotions = { -- Taken directly from Patrik Lundell's thoughts.lua script
  [df.emotion_type.ANYTHING]              = {false, "ANYTHING", "remembering"},
  [df.emotion_type.ACCEPTANCE]            = {true,  "accepting", "remembering"},
  [df.emotion_type.ADORATION]             = {false, "adoration", "remembering"},
  [df.emotion_type.AFFECTION]             = {false, "affection", "remembering"},
  [df.emotion_type.AGITATION]             = {true,  "agitated", "dwelling upon"},
  [df.emotion_type.AGGRAVATION]           = {true,  "aggravated", "dwelling upon"},
  [df.emotion_type.AGONY]                 = {false, "agony", "reliving"},
  [df.emotion_type.ALARM]                 = {true,  "alarmed", "reliving"},
  [df.emotion_type.ALIENATION]            = {false, "alienated", "dwelling upon"},
  [df.emotion_type.AMAZEMENT]             = {true,  "amazed", "remembering"},
  [df.emotion_type.AMBIVALENCE]           = {true,  "ambivalent", "remembering"},
  [df.emotion_type.AMUSEMENT]             = {true,  "amused", "remembering"},
  [df.emotion_type.ANGER]                 = {true,  "angry", "dwelling upon"},
  [df.emotion_type.ANGST]                 = {true,  "existential crisis", "dwelling upon", "in "},
  [df.emotion_type.ANGUISH]               = {true,  "anguish", "reliving", "in "},
  [df.emotion_type.ANNOYANCE]             = {true,  "annoyed", "dwelling upon"},
  [df.emotion_type.ANXIETY]               = {false, "anxious", "dwelling upon"},
  [df.emotion_type.APATHY]                = {true,  "apathetic", "remembering"},
  [df.emotion_type.AROUSAL]               = {true,  "aroused", "remembering"},
  [df.emotion_type.ASTONISHMENT]          = {true,  "astonished", "remembering"},
  [df.emotion_type.AVERSION]              = {false, "aversion", "dwelling upon"},
  [df.emotion_type.AWE]                   = {true,  "awe", "remembering", "in "},
  [df.emotion_type.BITTERNESS]            = {false, "bitter", "dwelling upon"},
  [df.emotion_type.BLISS]                 = {true,  "blissful", "remembering"},
  [df.emotion_type.BOREDOM]               = {true,  "bored", "dwelling upon"},
  [df.emotion_type.CARING]                = {false, "caring", "remembering"},
  [df.emotion_type.CONFUSION]             = {true,  "confused", "dwelling upon"},
  [df.emotion_type.CONTEMPT]              = {true,  "contemptuous", "dwelling upon"},
  [df.emotion_type.CONTENTMENT]           = {true,  "content", "remembering"},
  [df.emotion_type.DEFEAT]                = {false, "defeated", "dwelling upon"},
  [df.emotion_type.DEJECTION]             = {true,  "dejected", "dwelling upon"},
  [df.emotion_type.DELIGHT]               = {true,  "delighted", "remembering"},
  [df.emotion_type.DESPAIR]               = {true,  "despair", "dwelling upon", "in "},
  [df.emotion_type.DISAPPOINTMENT]        = {false, "disappointed", "dwelling upon"},
  [df.emotion_type.DISGUST]               = {true,  "disgusted", "dwelling upon"},
  [df.emotion_type.DISILLUSIONMENT]       = {true,  "disillusioned", "dwelling upon"},
  [df.emotion_type.DISLIKE]               = {false, "dislike", "dwelling upon"},
  [df.emotion_type.DISMAY]                = {true,  "dismayed", "reliving"},
  [df.emotion_type.DISTRESS]              = {true,  "distressed", "reliving"},
  [df.emotion_type.DISPLEASURE]           = {false, "displeasure", "dwelling upon"},
  [df.emotion_type.DOUBT]                 = {true,  "doubt", "dwelling upon", "in "},
  [df.emotion_type.EAGERNESS]             = {true,  "eager", "remembering"},
  [df.emotion_type.ELATION]               = {true,  "elated", "remembering"},
  [df.emotion_type.EMBARRASSMENT]         = {true,  "embarrassed", "dwelling upon"},
  [df.emotion_type.EMPATHY]               = {false, "empathy", "remembering"},
  [df.emotion_type.EMPTINESS]             = {false, "empty", "dwelling upon"},
  [df.emotion_type.ENJOYMENT]             = {false, "enjoyment", "remembering"},
  [df.emotion_type.ENTHUSIASM]            = {true,  "enthusiastic", "remembering"},
  [df.emotion_type.EUPHORIA]              = {false, "euphoric", "remembering"},
  [df.emotion_type.EXASPERATION]          = {true,  "exasperated", "dwelling upon"},
  [df.emotion_type.EXCITEMENT]            = {true,  "excited", "remembering"},
  [df.emotion_type.EXHILARATION]          = {true,  "exhilarated", "remembering"},
  [df.emotion_type.EXPECTANCY]            = {true,  "expectant", "remembering"},
  [df.emotion_type.FEAR]                  = {true,  "afraid", "reliving"},
  [df.emotion_type.FEROCITY]              = {false, "ferocity", "reliving"},
  [df.emotion_type.FONDNESS]              = {false, "fondness", "remembering"},
  [df.emotion_type.FREEDOM]               = {false, "free", "remembering"},
  [df.emotion_type.FRIGHT]                = {true,  "frightened", "reliving"},
  [df.emotion_type.FRUSTRATION]           = {true,  "frustrated", "dwelling upon"},
  [df.emotion_type.GAIETY]                = {false, "gaiety", "remembering"},
  [df.emotion_type.GLEE]                  = {true,  "gleeful", "remembering"},
  [df.emotion_type.GLOOM]                 = {true,  "gloomy", "dwelling upon"},
  [df.emotion_type.GLUMNESS]              = {false, "glum", "dwelling upon"},
  [df.emotion_type.GRATITUDE]             = {false, "gratitude", "remembering"},
  [df.emotion_type.GRIEF]                 = {nil,   "grieved", "dwelling upon"},
  [df.emotion_type.GRIM_SATISFACTION]     = {false, "grim satisfaction", "remembering"},
  [df.emotion_type.GROUCHINESS]           = {true,  "grouchy", "dwelling upon"},
  [df.emotion_type.GRUMPINESS]            = {true,  "grumpy", "dwelling upon"},
  [df.emotion_type.GUILT]                 = {false, "guilty", "dwelling upon"},
  [df.emotion_type.HAPPINESS]             = {false, "happy", "remembering"},
  [df.emotion_type.HATRED]                = {false, "hateful", "dwelling upon"},
  [df.emotion_type.HOPE]                  = {false, "hope", "remembering"},
  [df.emotion_type.HOPELESSNESS]          = {false, "hopeless", "dwelling upon"},
  [df.emotion_type.HORROR]                = {true,  "horrified", "reliving"},
  [df.emotion_type.HUMILIATION]           = {false, "humiliated", "dwelling upon"},
  [df.emotion_type.INSULT]                = {false, "insulted", "dwelling upon"},
  [df.emotion_type.INTEREST]              = {true,  "interested", "remembering"},
  [df.emotion_type.IRRITATION]            = {true,  "insulted", "dwelling upon"},
  [df.emotion_type.ISOLATION]             = {false, "isolated", "dwelling upon"},
  [df.emotion_type.JOLLINESS]             = {true,  "jolly", "remembering"},
  [df.emotion_type.JOVIALITY]             = {false, "jovial", "remembering"},
  [df.emotion_type.JOY]                   = {false, "joy", "remembering"},
  [df.emotion_type.JUBILATION]            = {true,  "jubilant", "remembering"},
  [df.emotion_type.LOATHING]              = {false, "loathing", "dwelling upon"},
  [df.emotion_type.LONELINESS]            = {false, "lonely", "dwelling upon"},
  [df.emotion_type.LOVE]                  = {false, "love", "remembering"},
  [df.emotion_type.LUST]                  = {false, "lustful", "remembering"},
  [df.emotion_type.MISERY]                = {false, "miserable", "dwelling upon"},
  [df.emotion_type.MORTIFICATION]         = {true,  "mortified", "dwelling upon"},
  [df.emotion_type.NERVOUSNESS]           = {false, "nervous", "dwelling upon"},
  [df.emotion_type.NOSTALGIA]             = {false, "nostalgic", "remembering"},
  [df.emotion_type.OPTIMISM]              = {false, "optimistic", "remembering"},
  [df.emotion_type.OUTRAGE]               = {true,  "outraged", "dwelling upon"},
  [df.emotion_type.PANIC]                 = {nil,   "panicked", "reliving"},
  [df.emotion_type.PATIENCE]              = {false, "patient", "remembering"},
  [df.emotion_type.PASSION]               = {false, "passionate", "remembering"},
  [df.emotion_type.PESSIMISM]             = {true,  "pessimistic", "dwelling upon"},
  [df.emotion_type.PLEASURE]              = {false, "pleasure", "remembering"},
  [df.emotion_type.PRIDE]                 = {true,  "proud", "remembering"},
  [df.emotion_type.RAGE]                  = {nil,   "rages", "reliving"},
  [df.emotion_type.RAPTURE]               = {true,  "enraptured", "remembering"},
  [df.emotion_type.REJECTION]             = {false, "rejected", "dwelling upon"},
  [df.emotion_type.RELIEF]                = {true,  "relieved", "remembering"},
  [df.emotion_type.REGRET]                = {false, "regretful", "dwelling upon"},
  [df.emotion_type.REMORSE]               = {false, "remorseful", "dwelling upon"},
  [df.emotion_type.REPENTANCE]            = {false, "repentant", "dwelling upon"},
  [df.emotion_type.RESENTMENT]            = {true,  "resentful", "dwelling upon"},
  [df.emotion_type.RIGHTEOUS_INDIGNATION] = {false, "indignant", "dwelling upon"},
  [df.emotion_type.SADNESS]               = {false, "sad", "dwelling upon"},
  [df.emotion_type.SATISFACTION]          = {false, "satisfied", "remembering"},
  [df.emotion_type.SELF_PITY]             = {false, "self-pity", "dwelling upon"},
  [df.emotion_type.SERVILE]               = {false, "servile", "remembering"},
  [df.emotion_type.SHAKEN]                = {true,  "shaken", "reliving"},
  [df.emotion_type.SHAME]                 = {true,  "ashamed", "dwelling upon"},
  [df.emotion_type.SHOCK]                 = {true,  "shocked", "reliving"},
  [df.emotion_type.SUSPICION]             = {true,  "suspicious", "dwelling upon"},
  [df.emotion_type.SYMPATHY]              = {false, "sympathy", "remembering"},
  [df.emotion_type.TENDERNESS]            = {false, "tenderness", "remembering"},
  [df.emotion_type.TERROR]                = {true,  "terrified", "reliving"},
  [df.emotion_type.THRILL]                = {true,  "thrilled", "remembering"},
  [df.emotion_type.TRIUMPH]               = {false, "triumph", "remembering"},
  [df.emotion_type.UNEASINESS]            = {true,  "uneasy", "dwelling upon"},
  [df.emotion_type.UNHAPPINESS]           = {false, "unhappy", "dwelling upon"},
  [df.emotion_type.VENGEFULNESS]          = {false, "vengeful", "dwelling upon"},
  [df.emotion_type.WONDER]                = {false, "wonder", "remembering"},
  [df.emotion_type.WORRY]                 = {true,  "worried", "dwelling upon"},
  [df.emotion_type.WRATH]                 = {false, "wrathful", "reliving"},
  [df.emotion_type.ZEAL]                  = {false, "zealous", "remembering"},
  [df.emotion_type.RESTLESS]              = {false, "restless", "dwelling upon"},
  [df.emotion_type.ADMIRATION]            = {false, "admiration", "remembering"}
}
thoughts = { -- Taken directly from Patrik Lundell's thoughts.lua script
  [df.unit_thought_type.None]                      = {
    ["caption"] = ""},
  [df.unit_thought_type.Conflict]                  = {
    ["caption"] = "{while in }conflict"}, 
  [df.unit_thought_type.Trauma]                    = {
    ["caption"] = "{after }experiencing trauma"},
  [df.unit_thought_type.WitnessDeath]              = {
    ["caption"]    = "{after }seeing [subthought] die", 
    ["subthought"] = {"df.global.world.incidents.all id",
                      (function (subthought) 
                         return incident_victim (subthought)
                       end)}},
  [df.unit_thought_type.UnexpectedDeath]           = {
    ["caption"]          = "{at }the unexpected death of somebody",                                                  
    ["extended_caption"] = "{at }the unexpected death of [subthought]",
    ["subthought"]       = {"hf id",
                            (function (subthought)
                               return hf_name (subthought)
                             end)}},
  [df.unit_thought_type.Death]                     = {
    ["caption"]          = "{at }somebody's death",  
    ["extended_caption"] = "{at }[subthought]'s death",
    ["subthought"]       = {"hf id",
                            (function (subthought)
                               return hf_name (subthought)
                             end)}},
  [df.unit_thought_type.Kill]                      = {
    ["caption"]       = "{while }killing somebody",  
    ["extra_caption"] = "{while }killing [subthought]",
    ["subthought"]    = {"df.global.world.incidents.all id",
                         (function (subthought) 
                            return incident_victim (subthought)
                          end)}},
  [df.unit_thought_type.LoveSeparated]             = {
    ["caption"]          = "{at }being separated from a loved one",  
    ["extended_caption"] = "{at }being separated from [subthought]",
    ["subthought"]       = {"df.global.world.historical_figure.all id",
                           (function (subthought)
                              return hf_name (subthought)
                            end)}},
  [df.unit_thought_type.LoveReunited]              = {
    ["caption"]          = "{after }being reunited with a loved one",
    ["extended_caption"] = "{after }being reunited with [subthought]",
    ["subthought"]       = {"df.global.world.historical_figure.all id",
                            (function (subthought)
                              return hf_name (subthought)
                             end)}},
  [df.unit_thought_type.JoinConflict]              = {
    ["caption"] = "{when }joining an existing conflict"}, 
  [df.unit_thought_type.MakeMasterwork]            = {
    ["caption"] = "{after }producing a masterwork"}, 
  [df.unit_thought_type.MadeArtifact]              = {
    ["caption"]          = "{after }creating an artifact",  
    ["extended_caption"] = "{after }creating [subthought]",
    ["subthought"]       = {"df.global.world.artifacts.all id",
                            (function (subthought)
                               return artifact_name (subthought)
                             end)}},
  [df.unit_thought_type.MasterSkill]               = {
    ["caption"]    = "{upon }mastering [subthought]",  
    ["subthought"] = {"df.job_skill value",
                      (function (subthought)
                         return skill_name (subthought)
                       end)}},
  [df.unit_thought_type.NewRomance]                = {
    ["caption"]          = "{as [he] was caught up in }a new romance",  
    ["extended_caption"] = "Oh, [subthought]...",
    ["subthought"]       = {"df.global.world.historical_figure.all id",
                            (function (subthought)
                               return hf_name (subthought)
                             end)}},
  [df.unit_thought_type.BecomeParent]              = {
    ["caption"] = "{after }becoming a parent"}, 
  [df.unit_thought_type.NearConflict]              = {
    ["caption"] = "being near to a conflict"},  
  [df.unit_thought_type.CancelAgreement]           = {
    ["caption"] = "{after }an agreement was cancelled"},  
  [df.unit_thought_type.JoinTravel]                = {
    ["caption"] = "{upon }joining a traveling group"},  
  [df.unit_thought_type.SiteControlled]            = {
    ["caption"] = "{after }a site was controlled"},  
  [df.unit_thought_type.TributeCancel]             = {
    ["caption"] = "{after }a tribute cancellation"},  
  [df.unit_thought_type.Incident]                  = {
    ["caption"]       = "{after }an incident",                   
    ["extra_caption"] = "{after }an incident with [subthought]",
    ["subthought"]    = {"df.global.world.incidents.all id",
                         (function (subthought) 
                            return incident_victim (subthought)
                          end)}},
  [df.unit_thought_type.HearRumor]                 = {
    ["caption"] = "{after }hearing a rumor"},  
  [df.unit_thought_type.MilitaryRemoved]           = {
    ["caption"] = "{after }being removed from a military group"},  
  [df.unit_thought_type.StrangerWeapon]            = {
    ["caption"] = "{when }a stranger advanced with a weapon"},  
  [df.unit_thought_type.StrangerSneaking]          = {
    ["caption"] = "{after }seeing a stranger sneaking around"},  
  [df.unit_thought_type.SawDrinkBlood]             = {
    ["caption"] = "{after }witnessing a night creature drinking blood"}, 
  [df.unit_thought_type.Complained]                = {
    ["caption"]    = "[subthought]",  
    ["subthought"] = {"request enum",
                      (function (subthought)
                         return complained_thought (subthought)
                       end)}},
  [df.unit_thought_type.ReceivedComplaint]         = {
    ["caption"]    = "{while }being [subthought] by an unhappy citizen",  
    ["subthought"] = {"request enum",
                      (function (subthought)
                         return received_complaint_thought (subthought)
                       end)}},
  [df.unit_thought_type.AdmireBuilding]            = {
    ["caption"]    = "{near }a [severity][subthought]", 
    ["subthought"] = {"df.building_type value",
                      (function (subthought)
                        return building_of (subthought)
                      end)},
    ["severity"]   = {"building quality value",
                      (function (severity)
                         return building_quality_of (severity)
                       end)}},   
  [df.unit_thought_type.AdmireOwnBuilding]         = {
    ["caption"]    = "{near }[his] own [severity][subthought]", 
    ["subthought"] = {"df.building_type value",
                      (function (subthought)
                         return building_of (subthought)
                       end)},
    ["severity"]   = {"building quality value",
                      (function (severity)
                         return building_quality_of (severity)
                       end)}},                                                 
  [df.unit_thought_type.AdmireArrangedBuilding]    = {
    ["caption"]    = "{near }a [severity]tastefully arranged [subthought]", 
    ["subthought"] = {"df.building_type value",
                      (function (subthought)
                        return building_of (subthought)
                       end)},
    ["severity"]   = {"building quality value",
                      (function (severity)
                        return building_quality_of (severity)
                       end)}},
  [df.unit_thought_type.AdmireOwnArrangedBuilding] = {
    ["caption"]    = "{near }[his] own [severity]tastefully arranged [subthought]",
    ["subthought"] = {"df.building_type value",
                      (function (subthought)
                         return building_of (subthought)
                       end)},
    ["severity"]   = {"building quality value",
                      (function (severity)
                         return building_quality_of (severity)
                       end)}},
  [df.unit_thought_type.LostPet]                   = {
    ["caption"] = "{after }losing a pet"},  
  [df.unit_thought_type.ThrownStuff]               = {
    ["caption"] = "{after }throwing something"},  
  [df.unit_thought_type.JailReleased]              = {
    ["caption"] = "{after }being released from confinement"}, 
  [df.unit_thought_type.Miscarriage]               = {
    ["caption"] = "{after }a miscarriage"},  
  [df.unit_thought_type.SpouseMiscarriage]         = {
    ["caption"] = "{after }[his] spouse's miscarriage"},  
  [df.unit_thought_type.OldClothing]               = {
    ["caption"] = "{to be }wearing old clothing"}, 
  [df.unit_thought_type.TatteredClothing]          = {
    ["caption"] = "{to be }wearing tattered clothing"}, 
  [df.unit_thought_type.RottedClothing]            = {
    ["caption"] = "{to have }clothes rot off of [his] body"},  
  [df.unit_thought_type.GhostNightmare]            = {
    ["caption"]    = "{after }being tormented in nightmares by [subthought]",
    ["subthought"] = {"df.unit_relationship_type value",
                      (function (subthought)
                         return unit_relationship_text_of (subthought)
                       end)}},
  [df.unit_thought_type.GhostHaunt]                = {
    ["caption"]    = "{after }being [severity] by [subthought]",  
    ["subthought"] = {"df.unit_relationship_type value",
                      (function (subthought)
                         return unit_relationship_text_of (subthought)
                       end)},
    ["severity"]   = {"haunt enum value",
                      (function (severity)
                         return haunt_enum_text_of (severity)
                       end)}},
  [df.unit_thought_type.Spar]                      = {
    ["caption"] = "{after }a sparring session"},  
  [df.unit_thought_type.UnableComplain]            = {
    ["caption"]    = "{after }being unable to [subthought]",  
    ["subthought"] = {"request enum",
                      (function (subthought)
                         return unable_complain_thought (subthought)
                       end)}},
  [df.unit_thought_type.LongPatrol]                = {
    ["caption"] = "{during }long patrol duty"},  
  [df.unit_thought_type.SunNausea]                 = {
    ["caption"] = "{after }being nauseated by the sun"},  
  [df.unit_thought_type.SunIrritated]              = {
    ["caption"] = "{at }being out in the sunshine again"}, 
  [df.unit_thought_type.Drowsy]                    = {
    ["caption"] = "{when |being }drowsy"}, 
  [df.unit_thought_type.VeryDrowsy]                = {
    ["caption"] = "{when |being }utterly sleep-deprived"},  
  [df.unit_thought_type.Thirsty]                   = {
    ["caption"] = "{when |being }thirsty"}, 
  [df.unit_thought_type.Dehydrated]                = {
    ["caption"] = "{when |being}dehydrated"},  
  [df.unit_thought_type.Hungry]                    = {
    ["caption"] = "{when |being }hungry"}, 
  [df.unit_thought_type.Starving]                  = {
    ["caption"] = "{when |being }starving"}, 
  [df.unit_thought_type.MajorInjuries]             = {
    ["caption"] = "{after }suffering a major injury"}, 
  [df.unit_thought_type.MinorInjuries]             = {
    ["caption"] = "{after }suffering a minor injury"}, 
  [df.unit_thought_type.SleepNoise]                = {
    ["caption"]  = "{after }[severity]",  
    ["severity"] = {"sleep noise enum",
                    (function (severity)
                       return sleep_noise_text (severity)
                     end)}},
  [df.unit_thought_type.Rest]                      = {
    ["caption"] = "{after }being able to rest and recuperate"},  
  [df.unit_thought_type.FreakishWeather]           = {
    ["caption"] = "{when |being }caught in freakish weather"}, 
  [df.unit_thought_type.Rain]                      = {
    ["caption"] = "{when |being }caught in the rain"}, 
  [df.unit_thought_type.SnowStorm]                 = {
    ["caption"] = "{when |being }caught in a snow storm"},  
  [df.unit_thought_type.Miasma]                    = {
    ["caption"] = "{after }retching on a miasma"}, 
  [df.unit_thought_type.Smoke]                     = {
    ["caption"] = "{after }choking on smoke underground"}, 
  [df.unit_thought_type.Waterfall]                 = {
    ["caption"] = "being near to a waterfall"},  
  [df.unit_thought_type.Dust]                      = {
    ["caption"] = "{after }choking on dust underground"}, 
  [df.unit_thought_type.Demands]                   = {
    ["caption"] = "considering the state of demands"},  
  [df.unit_thought_type.ImproperPunishment]        = {
    ["caption"] = "that a criminal could not be properly punished"},  
  [df.unit_thought_type.PunishmentReduced]         = {
    ["caption"] = "{to have |having }[his] punishment reduced"},  
  [df.unit_thought_type.Elected]                   = {
    ["caption"] = "{to be |being }elected"},  
  [df.unit_thought_type.Reelected]                 = {
    ["caption"] = "{to be |being }re-elected"},  
  [df.unit_thought_type.RequestApproved]           = {
    ["caption"] = "having a request approved"},  
  [df.unit_thought_type.RequestIgnored]            = {
    ["caption"] = "having a request ignored"},  
  [df.unit_thought_type.NoPunishment]              = {
    ["caption"] = "that nobody could be punished for a failure"},  
  [df.unit_thought_type.PunishmentDelayed]         = {
    ["caption"] = "{to have |having }[his] punishment delayed"},  
  [df.unit_thought_type.DelayedPunishment]         = {
    ["caption"] = "{after }the delayed punishment of a criminal"},  
  [df.unit_thought_type.ScarceCageChain]           = {
    ["caption"] = "considering the scarcity of cages and chains"},  
  [df.unit_thought_type.MandateIgnored]            = {
    ["caption"] = "having a mandate ignored"},  
  [df.unit_thought_type.MandateDeadlineMissed]     = {
    ["caption"] = "having a mandate deadline missed"},  
  [df.unit_thought_type.LackWork]                  = {
    ["caption"] = "{after }the lack of work last season"},  
  [df.unit_thought_type.SmashedBuilding]           = {
    ["caption"] = "{after }smashing up a building"},  
  [df.unit_thought_type.ToppledStuff]              = {
    ["caption"] = "{after }toppling something over"},  
  [df.unit_thought_type.NoblePromotion]            = {
    ["caption"] = "{after }receiving a higher rank of nobility"},  
  [df.unit_thought_type.BecomeNoble]               = {
    ["caption"] = "{after }entering the nobility"},  
  [df.unit_thought_type.Cavein]                    = {
    ["caption"] = "{after }being knocked out during a cave-in"}, 
  [df.unit_thought_type.MandateDeadlineMet]        = {
    ["caption"] = "{to have |having }a mandate deadline met"},  
  [df.unit_thought_type.Uncovered]                 = {
    ["caption"] = "{to be |being }uncovered"},  
  [df.unit_thought_type.NoShirt]                   = {
    ["caption"] = "{to have |having }no shirt"},  
  [df.unit_thought_type.NoShoes]                   = {
    ["caption"] = "{to have |having}no shoes"},  
  [df.unit_thought_type.EatPet]                    = {
    ["caption"] = "{after }being forced to eat a treasured pet to survive"},  
  [df.unit_thought_type.EatLikedCreature]          = {
    ["caption"] = "{after }being forced to eat a beloved creature to survive"},  
  [df.unit_thought_type.EatVermin]                 = {
    ["caption"]          = "{after }being forced to eat vermin to survive",  
    ["extended_caption"] = "{after }being forced to eat [subthought] to survive",
    ["subthought"]       = {"df.global.world.raws.creatures.all index",
                            (function (subthought)
                               return df.global.world.raws.creatures.all [subthought].name [1]
                             end)}},
  [df.unit_thought_type.FistFight]                 = {
    ["caption"] = "{after }starting a fist fight"},  
  [df.unit_thought_type.GaveBeating]               = {
    ["caption"] = "{after }punishing somebody with a beating"},  
  [df.unit_thought_type.GotBeaten]                 = {
    ["caption"] = "{after }being beating"},  
  [df.unit_thought_type.GaveHammering]             = {
    ["caption"] = "{after }beating somebody with a hammer"},  
  [df.unit_thought_type.GotHammered]               = {
    ["caption"] = "{after }being beaten with a hammer"},  
  [df.unit_thought_type.NoHammer]                  = {
    ["caption"] = "{after }being unable to find a hammer"},  
  [df.unit_thought_type.SameFood]                  = {
    ["caption"] = "eating the same old food"},  
  [df.unit_thought_type.AteRotten]                 = {
    ["caption"] = "{after }eating rotten food"},  
  [df.unit_thought_type.GoodMeal]                  = {
    ["caption"]  = "{after }eating [severity]", 
    ["severity"] = {"df.item_quality value",
                    (function (severity)
                       return food_quality_of (severity)
                     end)}},
  [df.unit_thought_type.GoodDrink]                 = {
    ["caption"]  = "{after }having [severity] drink", 
    ["severity"] = {"df.item_quality value",
                    (function (severity)
                       return drink_quality_of (severity)
                     end)}},
  [df.unit_thought_type.MoreChests]                = {
    ["caption"] = "not having enough chests"},  
  [df.unit_thought_type.MoreCabinets]              = {
    ["caption"] = "not having enough cabinets"},  
  [df.unit_thought_type.MoreWeaponRacks]           = {
    ["caption"] = "not having enough weapon racks"},  
  [df.unit_thought_type.MoreArmorStands]           = {
    ["caption"] = "not having enough armor stands"},  
  [df.unit_thought_type.RoomPretension]            = {
    ["caption"]    = "{by }a lesser's pretentious [subthought] arrangements", 
    ["subthought"] = {"undefined room_type enum",
                      (function (subthought)
                         return pretention_room_of (subhtought)
                       end)}},
  [df.unit_thought_type.LackTables]                = {
    ["caption"] = "{at }the lack of dining tables"},  
  [df.unit_thought_type.CrowdedTables]             = {
    ["caption"] = "eating at a crowded table"},  
  [df.unit_thought_type.DiningQuality]             = {
    ["caption"]  = "dining in [severity] dining room",  
    ["severity"] = {"df.item_quality value",
                    (function (severity)
                       return dining_room_quality_of (severity)
                     end)}},
  [df.unit_thought_type.NoDining]                  = {
    ["caption"] = "being without a proper dining room"},  
  [df.unit_thought_type.LackChairs]                = {
    ["caption"] = "{at }the lack of chairs"},  
  [df.unit_thought_type.TrainingBond]              = {
    ["caption"] = "{after }forming a bond with an animal training partner"}, 
  [df.unit_thought_type.Rescued]                   = {
    ["caption"] = "{after }being rescued"},  
  [df.unit_thought_type.RescuedOther]              = {
    ["caption"] = "{after }bringing somebody to rest in bed"},  
  [df.unit_thought_type.SatisfiedAtWork]           = {
    ["caption"]          = "{at }work",  
    ["extended_caption"] = "{at }work with [subthought]",
    ["subthought"]       = {"df.job_type enum value",
                            (function (subthought)
                               return string.lower (df.job_type.attrs [subthought].caption)
                             end)}},
  [df.unit_thought_type.TaxedLostProperty]         = {
    ["caption"] = "{after }losing property to the tax collector's escorts"},  
  [df.unit_thought_type.Taxed]                     = {
    ["caption"] = "{after }being taxed"},  
  [df.unit_thought_type.LackProtection]            = {
    ["caption"] = "not having adequate protection"},  
  [df.unit_thought_type.TaxRoomUnreachable]        = {
    ["caption"] = "{after }being unable to reach a room for tax collection"},  
  [df.unit_thought_type.TaxRoomMisinformed]        = {
    ["caption"] = "{after }being misinformed about a room for tax collection"},  
  [df.unit_thought_type.PleasedNoble]              = {
    ["caption"] = "having pleased a noble"},  
  [df.unit_thought_type.TaxCollectionSmooth]       = {
    ["caption"] = "that the tax collection went smoothly"},  
  [df.unit_thought_type.DisappointedNoble]         = {
    ["caption"] = "having disappointed a noble"},  
  [df.unit_thought_type.TaxCollectionRough]        = {
    ["caption"] = "that the tax collection didn't go smoothly"},  
  [df.unit_thought_type.MadeFriend]                = {
    ["caption"] = "{after }making a friend"}, 
  [df.unit_thought_type.FormedGrudge]              = {
    ["caption"] = "{after }forming a grudge"},  
  [df.unit_thought_type.AnnoyedVermin]             = {
  ["caption"] = "{after }being accosted by [subthought]", 
  ["subthought"] = {"df.global.world.raws.creatures.all index",
  (function (subthought)
  return df.global.world.raws.creatures.all [subthought].name [1]
  end)}},
  [df.unit_thought_type.NearVermin]                = {
  ["caption"] = "{after }being near [subthought]",  
  ["subthought"] = {"df.global.world.raws.creatures.all index",
  (function (subthought)
  return df.global.world.raws.creatures.all [subthought].name [1]
  end)}},
  [df.unit_thought_type.PesteredVermin]            = {
  ["caption"] = "{after }being pestered by [subthought]", 
  ["subthought"] = {"df.global.world.raws.creatures.all index",
  (function (subthought)
  return df.global.world.raws.creatures.all [subthought].name [1]
  end)}},
  [df.unit_thought_type.AcquiredItem]              = {
    ["caption"] = "{after }a satisfying acquisition"}, 
  [df.unit_thought_type.AdoptedPet]                = {
  ["caption"] =  "{after }adopting a new pet",  
  ["extended_caption"] = "{after }adopting a new pet [subthought]",
  ["subthought"] = {"df.global.world.raws.creatures.all index",
  (function (subthought)
  return df.global.world.raws.creatures.all [subthought].name [0]
  end)}},
  [df.unit_thought_type.Jailed]                    = {
    ["caption"] = "{after }being confined"}, 
  [df.unit_thought_type.Bath]                      = {
    ["caption"] = "{after }a bath"}, 
  [df.unit_thought_type.SoapyBath]                 = {
    ["caption"] = "{after }a soapy bath"},  
  [df.unit_thought_type.SparringAccident]          = {
    ["caption"] = "{after }killing somebody by accident while sparring"},  
  [df.unit_thought_type.Attacked]                  = {
    ["caption"] = "{after }being attacked"}, 
  [df.unit_thought_type.AttackedByDead]            = {
    ["caption"] = "{after }being attacked by the dead",
    ["extended_caption"] = "{after }being attacked by dead [subthought]",
    ["subthought"] = {"HF id",
    (function (subthought)
    return hf_name (subthought) 
    end)}},
  [df.unit_thought_type.SameBooze]                 = {
    ["caption"] = "drinking the same old booze"},  
  [df.unit_thought_type.DrinkBlood]                = {
    ["caption"] = "{while |being }forced to drink bloody water"},  
  [df.unit_thought_type.DrinkSlime]                = {
    ["caption"] = "{while |being }forced to drink slime"},  
  [df.unit_thought_type.DrinkVomit]                = {
    ["caption"] = "{while |being }forced to drink vomit"},  
  [df.unit_thought_type.DrinkGoo]                  = {
    ["caption"] = "{while |being }forced to drink gooey water"},  
  [df.unit_thought_type.DrinkIchor]                = {
    ["caption"] = "{while |being}forced to drink ichorous water"},  
  [df.unit_thought_type.DrinkPus]                  = {
    ["caption"] = "[while |being }forced to drink purulent water"},  
  [df.unit_thought_type.NastyWater]                = {
    ["caption"] = "drinking nasty water"},  
  [df.unit_thought_type.DrankSpoiled]              = {
    ["caption"] = "{after }drinking something spoiled"},  
  [df.unit_thought_type.LackWell]                  = {
    ["caption"] = "{after }drinking water without a well"},  
  [df.unit_thought_type.NearCaged]                 = {
    ["caption"] = "{after }being near to a [subthought] in a cage",  
    ["subthought"] = {"df.global.world.raws.creature.all index",
    (function (subthought)
    return df.global.world.raws.creatures.all [subthought].name [0]
    end)}},
  [df.unit_thought_type.NearCagedHated]            = {
    ["caption"] = "{after }being near to a [animal] in a cage",
    ["subthought"] = {"df.global.world.raws.creature.all index",
    (function (subthought)
    return df.global.world.raws.creatures.all [subthought].name [0]
    end)}},
  [df.unit_thought_type.LackBedroom]               = {
    ["caption"] = "{after }sleeping without a proper room"},  
  [df.unit_thought_type.BedroomQuality]            = {
    ["caption"] = "{after }sleeping in a [severity]", 
    ["severity"] = {"df.item_quality value",
    (function (severity)
    return bedroom_quality_of (severity)
    end)}},
  [df.unit_thought_type.SleptFloor]                = {
    ["caption"] = "{after }sleeping on the floor"},  
  [df.unit_thought_type.SleptMud]                  = {
    ["caption"] = "{after }sleeping in the mud"},  
  [df.unit_thought_type.SleptGrass]                = {
    ["caption"] = "{after }sleeping in the grass"},  
  [df.unit_thought_type.SleptRoughFloor]           = {
    ["caption"] = "{after }sleeping on a rough cave floor"},  
  [df.unit_thought_type.SleptRocks]                = {
    ["caption"] = "{after }sleeping on rocks"},  
  [df.unit_thought_type.SleptIce]                  = {
    ["caption"] = "{after }sleeping on ice"},  
  [df.unit_thought_type.SleptDirt]                 = {
    ["caption"] = "{after }sleeping in the dirt"},  
  [df.unit_thought_type.SleptDriftwood]            = {
    ["caption"] = "{after }sleeping on a pile of driftwood"},  
  [df.unit_thought_type.ArtDefacement]             = {
    ["caption"] = "{after }suffering the travesty of art defacement"},  
  [df.unit_thought_type.Evicted]                   = {
    ["caption"] = "{after }being evicted"},  
  [df.unit_thought_type.GaveBirth]                 = {
    ["caption"] = "{after }giving birth to [subthought_severity]",  
    ["subthought_severity"] = {"gender, child_count",
    (function (subthought, severity)
    return child_birth_of (subthought, severity)
    end)}},
  [df.unit_thought_type.SpouseGaveBirth]           = {
    ["caption"] = "[subthought_severity]",  
    ["subthought_severity"] = {"df.unit_relationship_type value, child_count",
    (function (subthought, severity)
    return spouse_birth_of (subthought, severity)
    end)}},
  [df.unit_thought_type.ReceivedWater]             = {
    ["caption"] = "{after }receiving water"}, 
  [df.unit_thought_type.GaveWater]                 = {
    ["caption"] = "{after }giving somebody water"}, 
  [df.unit_thought_type.ReceivedFood]              = {
    ["caption"] = "{after }receiving food"}, 
  [df.unit_thought_type.GaveFood]                  = {
    ["caption"] = "{after }giving somebody food"},  
  [df.unit_thought_type.Talked]                    = {
    ["caption"] = "talking with [subthought]", 
    ["subthought"] = {"df.unit_relationship_type value",
    (function (subthought)
    local prefix = "a "
    if subthought == df.unit_relationship_type.Spouse then  
    prefix = "the "
    end
    
    return prefix .. string.lower (df.unit_relationship_type [subthought])
    end)}},
  [df.unit_thought_type.OfficeQuality]             = {
    ["caption"] = "conducted meeting in a [severity]", 
    ["severity"] = {"df.item_quality value",
    (function (severity)
    return office_quality_of (severity)
    end)}},
  [df.unit_thought_type.MeetingInBedroom]          = {
    ["caption"] = "having to conduct an official meeting in a bedroom"},  
  [df.unit_thought_type.MeetingInDiningRoom]       = {
    ["caption"] = "having to conduct an official meeting in a dining room"},  
  [df.unit_thought_type.NoRooms]                   = {
    ["caption"] = "not having any rooms"},  
  [df.unit_thought_type.TombQuality]               = {
    ["caption"] = "having a [severity] tomb after gaining another year",
    ["severity"] = {"df.item_quality value",
    (function (severity)
    return tomb_quality_of (severity)
    end)}},
  [df.unit_thought_type.TombLack]                  = {
    ["caption"] = "{about }not having a tomb after gaining another year"},  
  [df.unit_thought_type.TalkToNoble]               = {
    ["caption"] = "{after }talking to a pillar of society",  
    ["extended_caption"] = "{after }talking to the [subthought]",
    ["subthought"] = {"noble HF id",
    (function (subthought)
    local site = df.global.world.world_data.active_site [0]
    local entity = df.historical_entity.find (site.entity_links [1].entity_id)
    local title = "<unknown>"
    
    for i, assignment in ipairs (entity.positions.assignments) do
    if assignment.histfig == subthought then
    local hf = df.historical_figure.find (subthought)
    
    if hf.sex == 0 and entity.positions.own [assignment.position_id].name_female [0] ~= "" then
    title = entity.positions.own [assignment.position_id].name_female [0]
    
    elseif hf.sex == 1 and entity.positions.own [assignment.position_id].name_male [0] ~= "" then
    title = entity.positions.own [assignment.position_id].name_male [0]
    
    else                                                                    
    title = entity.positions.own [assignment.position_id].name [0]
    end
    
    break
    end
    end
    
    return title .. " " .. hf_name (subthought)
    end)}},
  [df.unit_thought_type.InteractPet]               = {
    ["caption"] = "{after }interacting with a pet", 
    ["extended_caption"] = "{after }interacting with a pet [subthought]",
    ["subthought"] = {"df.global.world.raws.creatures.all index",
    (function (subthought)
    return df.global.world.raws.creatures.all [subthought].name [0]
    end)}},
  [df.unit_thought_type.ConvictionCorpse]          = {
    ["caption"] = "{after }a long-dead corpse was convicted of a crime"},  
  [df.unit_thought_type.ConvictionAnimal]          = {
    ["caption"] = "{after }an animal was convicted of a crime"},  
  [df.unit_thought_type.ConvictionVictim]          = {
    ["caption"] = "{after }the bizarre conviction against all reason of the victim of a crime"},  
  [df.unit_thought_type.ConvictionJusticeSelf]     = {
    ["caption"] = "{upon }receiving justice through a criminal's conviction"},  
  [df.unit_thought_type.ConvictionJusticeFamily]   = {
    ["caption"] = "when a family member received justice through a criminal's conviction"},  
  [df.unit_thought_type.Decay]                     = {
    ["caption"] = "after being forced to endure the decay of [subthought]",  
    ["subthought"] = {"df.unit_relationship_type value",
    (function (subthought)
    return decay_of (subthought)
    end)}},
  [df.unit_thought_type.NeedsUnfulfilled]          = {
    ["caption"] = "{after }[subthought_severity]",
    ["subthought_severity"] = {"df.need_type value, (HF id)",
    (function (subthought, severity)
    return unfulfulled_need_of (subthought, severity)
    end)}},
  [df.unit_thought_type.Prayer]                    = {
    ["caption"] = "{after }communing with [subthought]", 
    ["subthought"] = {"HF id",
    (function (subthought)
    return hf_name (subthought)
    end)}},
  [df.unit_thought_type.DrinkWithoutCup]           = {
    ["caption"] = "{after }having a drink without using a goblet, cup or mug"}, 
  [df.unit_thought_type.ResearchBreakthrough]      = {
    ["caption"] = "{after }making a breakthrough concerning [subthought_severity]",  
    ["subthought_severity"] = {"knowledge_scholar_category_flag index, flag index",
    (function (subthought, severity)
    return get_topic (subthought, severity)
    end)}},
  [df.unit_thought_type.ResearchStalled]           = {
    ["caption"] = "{after }being unable to advance the study of [subthought_severity]",  
    ["subthought_severity"] = {"knowledge_scholar_category_flag index, flag index",
    (function (subthought, severity)
    return get_topic (subthought, severity)
    end)}},
  [df.unit_thought_type.PonderTopic]               = {
    ["caption"] = "{after }pondering [subthought_severity]",  
    ["subthought_severity"] = {"knowledge_scholar_category_flag index, flag index",
    (function (subthought, severity)
    return get_topic (subthought, severity)
    end)}},
  [df.unit_thought_type.DiscussTopic]              = {
    ["caption"] = "{after }discussing [subthought_severity]",  
    ["subthought_severity"] = {"knowledge_scholar_category_flag index, flag index",
    (function (subthought, severity)
    return get_topic (subthought, severity)
    end)}},
  [df.unit_thought_type.Syndrome]                  = {
    ["caption"] = "{due to }[subthought]", 
    ["subthought"] = {"df.global.world.raws.syndromes.all id",
    (function (subthought)
    return df.syndrome.find (subthought).syn_name
    end)}},
  [df.unit_thought_type.Perform]                   = {
    ["caption"] = "{while }performing", 
    ["extended_caption"] = "{while} [subthought_self]",
    ["subthought_self"] = {"df.global.world.incidents.all id, hfid",
    (function (subthought, self)
    return Perform_Of (subthought, self)
    end)}},                                     
  [df.unit_thought_type.WatchPerform]              = {
    ["caption"] = "{after }watching a performance",  
    ["extended_caption"] = "{after }watching [subthought]",
    ["subthought"] = {"df.global.world.incidents.all id",
    (function (subthought)
    return Watch_Perform_Of (subthought)
    end)}},
  [df.unit_thought_type.RemoveTroupe]              = {
    ["caption"] = "{after }being removed from a performance troupe"},  
  [df.unit_thought_type.LearnTopic]                = {
    ["caption"] = "{after }learning about [subthought_severity]", 
    ["subthought_severity"] = {"knowledge_scholar_category_flag index, flag index",
    (function (subthought, severity)
    return get_topic (subthought, severity)
    end)}},
  [df.unit_thought_type.LearnSkill]                = {
    ["caption"] = "{after }learning about [subthought]", 
    ["subthought"] = {"df.job_skill value",
    (function (subthought)
    return string.lower (df.job_skill [subthought])
    end)}},
  [df.unit_thought_type.LearnBook]                 = {
    ["caption"] = "{after }learning [subthought]", 
    ["subthought"] = {"df.global.world.written_contents.all id",
    (function (subthought)
    return df.written_content.find (subthought).title
    end)}},
  [df.unit_thought_type.LearnInteraction]          = {
    ["caption"] = "{after }learning [subthought]",
    ["subthought"] = {"#df.global.world.raws.interactions id",
    (function (subthought)
    if #df.global.world.raws.interactions [subthought].sources > 0 then
    return df.global.world.raws.interactions [subthought].sources [0].name
    
    else
    return "powerful secrets."
    end
    end)}},
  [df.unit_thought_type.LearnPoetry]               = {
    ["caption"] = "{after  }learning [subthought]",  
    ["subthought"] = {"df.global.world.poetic_forms.all id",
    (function (subthought)
    return dfhack.TranslateName (df.poetic_form.find (subthought).name, true)
    end)}},
  [df.unit_thought_type.LearnMusic]                = {
    ["caption"] = "{after }learning [subthought]", 
    ["subthought"] = {"df.global.world.musical_forms.all id",
    (function (subthought)
    return dfhack.TranslateName (df.musical_form.find (subthought).name, true)
    end)}},
  [df.unit_thought_type.LearnDance]                = {
    ["caption"] = "{after }learning [subthought]",
    ["subthought"] = {"df.global.world.dance_forms.all id",
    function (subthought)
    return dfhack.TranslateName (df.dance_form.find (emotion.subthought).name, true)
    end}},
  [df.unit_thought_type.TeachTopic]                = {
    ["caption"] = "{after }teaching [subthought_severity]",  
    ["subthought_severity"] = {"knowledge_scholar_category_flag index, flag index",
    (function (subthought, severity)
    return get_topic (subthought, severity)
    end)}},
  [df.unit_thought_type.TeachSkill]                = {
    ["caption"] = "{after }teaching [subthought]", 
    ["subthought"] = {"df.job_skill value",
    (function (subthought)
    return string.lower (df.job_skill [subthought])
    end)}},
  [df.unit_thought_type.ReadBook]                  = {
    ["caption"] = "{after }reading [subthought]",  
    ["subthought"] = {"written contents.all index",
    (function (subthought)
    return df.written_content.find (subthought).title
    end)}},
  [df.unit_thought_type.WriteBook]                 = {
    ["caption"] = "{after }writing [subthought]",
    ["subthought"] = {"written contents.all index",
    (function (subthought)
    return df.written_content.find (subthought).title
    end)}},
  [df.unit_thought_type.BecomeResident]            = {
    ["caption"] = "{after }being granted residency",  
    ["extended_caption"] = "{after }being granted residency at [subthought]",
    ["subthought"] = {"site id",
    (function (subthought)
    return dfhack.TranslateName (df.world_site.find (subthought).name, true)
    end)}},
  [df.unit_thought_type.BecomeCitizen]             = {
    ["caption"] = "{after }being granted citizenship",  
    ["extended_caption"] = "{after }becoming a citizen of [subthought]",
    ["subthought"] = {"df.historical_entity id",
    (function (subthought)
    return dfhack.TranslateName (df.historical_entity.find (subthought).name, true)
    end)}},
  [df.unit_thought_type.DenyResident]              = {
    ["caption"] = "{after }being denied residency",  
    ["extended_caption"] = "{after }being denied residency at [subthought]",
    ["subthought"] = {"site id",
    (function (subthought)
    return dfhack.TranslateName (df.world_site.find (subthought).name, true)
    end)}},
  [df.unit_thought_type.DenyCitizen]               = {
    ["caption"] = "{after }being denied citizenship",  
    ["extended_caption"] = "after being refused to become a citizen of [subthought]",
    ["subthought"] = {"df.historical_entity id",
    (function (subthought)
    return dfhack.TranslateName (df.historical_entity.find (subthought).name, true)
    end)}},
  [df.unit_thought_type.LeaveTroupe]               = {
    ["caption"] = "{after }leaving a performance troupe"},  
  [df.unit_thought_type.MakeBelieve]               = {
    ["caption"] = "{after }playing make believe"}, 
  [df.unit_thought_type.PlayToy]                   = {
    ["caption"] = "{after }playing with [subthought]", 
    ["subthought"] = {"df.global.world.raws.itemdefs.toys index",
    (function (subthought)
    return df.global.world.raws.itemdefs.toys [subthought].name
    end)}},
  [df.unit_thought_type.DreamAbout]                = {
    ["caption"] = "*DREAMABOUT*"},  
  [df.unit_thought_type.Dream]                     = {
    ["caption"] = "*DREAM*"},  
  [df.unit_thought_type.Nightmare]                 = {
    ["caption"] = "*NIGHTMARE*"},  
  [df.unit_thought_type.Argument]                  = {
    ["caption"] = "{after }getting into an argument", 
    ["extended_caption"] = "{after }getting into an argument with [subthought]",
    ["subthought"] = {"HF id",
    (function (subthought)
    return dfhack.TranslateName (df.historical_figure.find (subthought).name, true)
    end)}},
  [df.unit_thought_type.CombatDrills]              = {
    ["caption"] = "{after }combat drills"},  
  [df.unit_thought_type.ArcheryPractice]           = {
    ["caption"] = "{after }practicing at the archery target"},  
  [df.unit_thought_type.ImproveSkill]              = {
    ["caption"] = "{upon }improving [subthought]", 
    ["subthought"] = {"df.job_skill value",
    (function (subthought)
    return string.lower (df.job_skill [subthought])
    end)}},
  [df.unit_thought_type.WearItem]                  = {
    ["caption"] = "{after }putting on a [severity] item",
    ["severity"] = {"df.item_quality value",
    (function (severity)
    return item_quality_of (severity)
    end)}},
  [df.unit_thought_type.RealizeValue]              = {
    ["caption"] = "{after }realizing the [level] of [value]", 
    ["subthought_severity"] = {"df.value_type value, value strength",
    (function (subthought, severity)
    return realize_value_of (subthought, severity)
    end)}},
  [df.unit_thought_type.OpinionStoryteller]        = {
    ["caption"] = "*OPINIONSTORYTELLER*"},  
  [df.unit_thought_type.OpinionRecitation]         = {
    ["caption"] = "*OPIOIONRECITATION*"},  
  [df.unit_thought_type.OpinionInstrumentSimulation] = {
    ["caption"] = "*OPINIONINSTRUMENTSIMULATION*"},  
  [df.unit_thought_type.OpinionInstrumentPlayer]   = {
    ["caption"] = "*OPINIONINSTRUMENTPLAYER*"},  
  [df.unit_thought_type.OpinionSinger]             = {
    ["caption"] = "*OPINIONSINGER*"},  
  [df.unit_thought_type.OpinionChanter]            = {
    ["caption"] = "*OPINIONCHANTER*"},  
  [df.unit_thought_type.OpinionDancer]             = {
    ["caption"] = "*OPINIONDANCER*"},  
  [df.unit_thought_type.OpinionStory]              = {
    ["caption"] = "*OPINIONSTORY*"},  
  [df.unit_thought_type.OpinionPoetry]             = {
    ["caption"] = "*OPINIONPOETRY*"},  
  [df.unit_thought_type.OpinionMusic]              = {
    ["caption"] = "*OPINIONMUSIC*"},  
  [df.unit_thought_type.OpinionDance]              = {
    ["caption"] = "*OPINIONDANCE*"},  
  [df.unit_thought_type.Defeated]                  = {
    ["caption"] = "after defeating somebody"},   
  [df.unit_thought_type.FavoritePossession]        = {
    ["caption"] = "*FAVORITEPOSSESSION*"},  
  [df.unit_thought_type.PreserveBody]              = {
    ["caption"] = "*PRESERVEBODY*"},  
  [df.unit_thought_type.Murdered]                  = {
    ["caption"] = "after murdering somebody"},  
  [df.unit_thought_type.HistEventCollection]       = {
    ["caption"] = "*HISTEVENTCOLLECTION*"},  
  [df.unit_thought_type.ViewOwnDisplay]            = {
    ["caption"] = "{after }viewing [subthought] in a personal museum",
    ["subthought"] = {"df.global.world.artifacts.all id ELSE df.global.world.items.all id",
    (function (subthought)
    return display_name (subthought)
    end)}},
  [df.unit_thought_type.ViewDisplay]               = {
    ["caption"] = "{after }viewing [subthought] on display", 
    ["subthought"] = {"df.global.world.artifacts.all id ELSE df.global.world.items.all id",
    (function (subthought)
    return display_name (subthought)
    end)}},
  [df.unit_thought_type.AcquireArtifact]           = {
    ["caption"] = "{after }acquiring [subthought]",
    ["subthought"] = {"df.global.world.artifacts.all id",
    (function (subthought)
    local artifact = df.artifact_record.find (subthought)
    
    if artifact then
    return dfhack.TranslateName (artifact.name, true)
    
    else
    return "an unknown artifact"
    end
    end)}},
  [df.unit_thought_type.DenySanctuary]             = {
    ["caption"] = "{after }a child was turned away from sanctuary"},  
  [df.unit_thought_type.CaughtSneaking]            = {
    ["caption"] = "{after }being caught sneaking"},  
  [df.unit_thought_type.GaveArtifact]              = {
    ["caption"] = "{after }[subthought] was given away",
    ["subthought"] = {"df.global.world.artifacts.all id",
    (function (subthought)
    local artifact = df.artifact_record.find (subthought)
    
    if artifact then
    return dfhack.TranslateName (artifact.name, true)
    
    else
    return "an unknown artifact"
    end
    end)}},
  [df.unit_thought_type.SawDeadBody]               = {
    ["caption"] = "{after }seeing [subthought]'s dead body",  
    ["subthought"] = {"df.global.world.incidents.all id",
    (function (subthought) 
    return incident_victim (subthought)
    end)}},
  [241]                                            = {
    ["caption"] = "{after }being expelled"},  
  [242]                                            = {
    ["caption"]    = "{after }[subthought] was expelled",
    ["subthought"] = {"df.global.world.historical_figure.all id",
                      (function (subthought)
                         return hf_name (subthought)
                       end)}}
}
function thought_string(thought) -- Still need to do more work on this
 local str = ''

 if thoughts[thought.thought].extended_caption then
  str = thoughts[thought.thought].extended_caption
 else
  str = thoughts[thought.thought].caption
 end
 
 for token,_ in pairs(thoughts[thought.thought]) do
  if token ~= 'caption' and token ~= 'extended_caption' then
   str = str:gsub(token,thoughts[thought.thought][token][1])
  end
 end
 
 str = emotions[thought.type][2] .. ' ' .. str
 return str
end

focus = { -- Needs affect focus levels
  [df.need_type.Socialize]       = {
    [-1] = 'after being away from people',
    [1]  = 'after spending time with people'},
  [df.need_type.DrinkAlcohol]    = {
    [-1] = 'after being kept from alcohol',
    [1]  = 'after drinking'},
  [df.need_type.PrayOrMedidate]  = {
    [-1] = 'after being unable to pray', 
    [1]  = 'after communing with their god'},
  [df.need_type.StayOccupied]    = {
    [-1] = 'after being unoccupied', 
    [1]  = 'after staying occupied'},
  [df.need_type.BeCreative]      = {
    [-1] = 'after doing nothing creative',
    [1]  = 'after doing something creative'},
  [df.need_type.Excitement]      = {
    [-1] = 'after leading an unexciting life',
    [1]  = 'after doing something exciting'},
  [df.need_type.LearnSomething]  = {
    [-1] = 'after not learning anything',
    [1]  = 'after learning something'},
  [df.need_type.BeWithFamily]    = {
    [-1] = 'after being away from family',
    [1]  = 'after being with family'},
  [df.need_type.BeWithFriends]   = {
    [-1] = 'after being away from friends',
    [1]  = 'after being with friends'},
  [df.need_type.HearEloquence]   = {
    [-1] = 'after being unable to hear an eloquent speach', 
    [1]  = 'after hearing an eloquent speach'},
  [df.need_type.UpholdTradition] = {
    [-1] = 'after being away from tradition', 
    [1]  = 'after upholding tradition'},
  [df.need_type.SelfExamination] = {
    [-1] = 'after a lack of introspection', 
    [1]  = 'after self-examination'},
  [df.need_type.MakeMerry]       = {
    [-1] = 'after being unable to make merry',
    [1]  = 'after making merry'},
  [df.need_type.CraftObject]     = {
    [-1] = 'after being unable to practice a craft',
    [1]  = 'after practicing a craft'},
  [df.need_type.MartialTraining] = {
    [-1] = 'after being unable to practice a martial art',
    [1]  = 'after practicing a martial art'},
  [df.need_type.PracticeSkill]   = {
    [-1] = 'after being unable to practice a skill',
    [1]  = 'after practicing a skill'},
  [df.need_type.TakeItEasy]      = {
    [-1] = 'after being unable to take it easy',
    [1]  = 'after taking it easy'},
  [df.need_type.MakeRomance]     = {
    [-1] = 'after being unable to make romance', 
    [1]  = 'after making romance'},
  [df.need_type.SeeAnimal]       = {
    [-1] = 'after being away from animals', 
    [1]  = 'after seeing animals'},
  [df.need_type.SeeGreatBeast]   = {
    [-1] = 'after being away from great beasts', 
    [1]  = 'after seeing a great beast'},
  [df.need_type.AcquireObject]   = {
    [-1] = 'after being unable to aquire something',
    [1]  = 'after acquiring something'},
  [df.need_type.EatGoodMeal]     = {
    [-1] = 'after a lack of decent meals',
    [1]  = 'after eating a good meal'},
  [df.need_type.Fight]           = {
    [-1] = 'after being unable to fight',
    [1]  = 'after fighting'},
  [df.need_type.CauseTrouble]    = {
    [-1] = 'after a lack of trouble-making',
    [1]  = 'after causing trouble'},
  [df.need_type.Argue]           = {
    [-1] = 'after being unable to argue',
    [1]  = 'after arguing'},
  [df.need_type.BeExtravagant]   = {
    [-1] = 'after being unable to be extravagant', 
    [1]  = 'after being extravagant'},
  [df.need_type.Wander]          = {
    [-1] = 'after being unable to wander', 
    [1]  = 'after wandering'},
  [df.need_type.HelpSomebody]    = {
    [-1] = 'after being unable to help anybody',
    [1]  = 'after helping somebody'},
  [df.need_type.ThinkAbstractly] = {
    [-1] = 'after a lack of abstract thinking', 
    [1]  = 'after thinking abstractly'},
  [df.need_type.AdmireArt]       = {
    [-1] = 'after being unable to admire art',
    [1]  = 'after admiring art'}
}
function focus_string(need_type,focus_level)
 local outStr = ''
 local outColor = 0

 if     focus_level > 299    then --unfettered +1
  outStr = 'unfettered '..focus[need_type][1]
  outCheck = 3
 elseif focus_level > 199    then --level-headed +1
  outStr = 'level-headed '..focus[need_type][1]
  outCheck = 2
 elseif focus_level > 99     then --untroubled +1
  outStr = 'untroubled '..focus[need_type][1]
  outCheck = 1
 elseif focus_level > -999   then --not distracted -1
  outStr = 'not distracted '..focus[need_type][-1]
  outColor = 0
 elseif focus_level > -9999  then --unfocused -1
  outStr = 'unfocused '..focus[need_type][-1]
  outColor = -1
 elseif focus_levle > -99999 then --distracted -1
  outStr = 'distracted '..focus[need_type][-1]
  outColor = -2
 else                             --badly distracted -1
  outStr = 'badly distracted '..focus[need_type][-1]
  outColor = -3
 end
 
 return outStr, outColor
end
function focus_description(unit)
 local outStr = ''
 local outColor = 0
 local personality = unit.status.current_soul.personality
 local pronoun = getPronoun(unit)
 
 if personality.undistracted_focus > personality.current_focus then
  if personality.undistracted_focus > personality.current_focus + 20 then
   outStr = pronoun..' is badly distracted by unmet needs'
   outColor = -3
  else
   outStr = pronoun..' is unfocused by unmet needs'
   outColor = -1
  end
 elseif personality.undistracted_focus < personality.current_focus then
  if personality.undistracted_focus <= personality.current_focus + 20 then
   outStr = pronoun..' is very focused with satisfied needs'
   outColor = 3
  else
   outStr = pronoun..' is somewhat focused with satisfied needs'
   outColor = 1
  end
 else
  outStr = pronoun..' is undistracted by unmet needs'
  outColor = 0
 end
 
 return outStr, outColor
end

stress = {
 ['Harrowed'] = 'has been utterly harrowed by the nightmare that is their tragic life',       -- 50000 >
 ['Haggard']  = 'has become haggard and drawn due to the tremendous stresses placed on them', -- 25000 - 49999
 ['Stressed'] = 'has been under a great deal of stress over the long term',                   -- 10000 - 24999
 ['Normal']   = 'is not stressed'}                                                            -- 9999  <
function stress_description(unit)
 local outStr = ''
 local outColor = 0
 local stress_level = unit.status.current_soul.personality.stress_level
 local cutoffs = dfhack.units.getStressCutoffs(unit)
 local pronoun = getPronoun(unit)
 
 if     stress_level > cutoffs[0] then
  outStr = stress['Harrowed']
  outColor = -3
 elseif stress_level > cutoffs[1] then
  outStr = stress['Haggard']
  outColor = -2
 elseif stress_level > cutoffs[2]  then
  outStr = stress['Stressed']
  outColor = -1
 else -- There are negative cutoffs as well, not sure they actually do anything
  outStr = stress['Normal']
  outColor = 0
 end
 outstr = pronoun..' '..outStr
 
 return outStr, outColor
end

function preference_string(preference) -- Taken from Patrik Lundell's thoughts.lua script
 local str = ''
 local bin = 3
 if preference.type == df.unit_preference.T_type.LikeMaterial then
  if preference.mattype == 0 then
   str = "likes " .. string.lower (df.global.world.raws.inorganics [preference.matindex].id)
  else
   local material = dfhack.matinfo.decode (preference.mattype, preference.matindex)
   if material and material.mode == "plant" then   
    if preference.mat_state <= 0 then     
     str = "likes " .. string.lower (df.global.world.raws.plants.all [preference.matindex].id) 
	       .. " " .. string.lower (material.material.id)
    else
     str = "likes "..material.material.state_name [preference.mat_state]
    end
                       
   elseif material and material.mode == "creature" then
    str = "likes " .. material.material.prefix .. " " .. string.lower (material.material.id)
                       
   else
    str = "likes "..df.global.world.raws.mat_table.builtin [preference.mattype].state_name [0]
   end          
  end
   
 elseif preference.type == df.unit_preference.T_type.LikeCreature then
  str = "likes " .. df.global.world.raws.creatures.all [preference.creature_id].name [1] ..
        " for their " .. df.global.world.raws.creatures.all [preference.creature_id].prefstring [0].value
                   --### Weirdo. Seems there's an RNG seed for prefstring when there are multiple.
   
 elseif preference.type == df.unit_preference.T_type.LikeFood then
  local material = dfhack.matinfo.decode (preference.mattype, preference.matindex)
  if preference.matindex ~= -1 and 
    (material.mode == "plant" or
     material.mode == "creature") then
   str = "prefers to consume "
       
   if preference.item_type == df.item_type.DRINK or 
      preference.item_type == df.item_type.LIQUID_MISC then  --  The state in the preferences seems locked to Solid
    str = str .. material.material.state_name.Liquid
       
   else                
    if material.material.prefix == "" then
     str = str .. material.material.state_name.Solid
         
    else
     str = str .. material.material.prefix .. " " .. material.material.state_name.Solid
    end
   end            
     
  else
   str = "prefers to consume " .. df.global.world.raws.creatures.all [preference.mattype].name [0]
  end
     
 elseif preference.type == df.unit_preference.T_type.HateCreature then
  str = "absolutely detests " .. df.global.world.raws.creatures.all [preference.creature_id].name [1]
  bin = -3
   
 elseif preference.type == df.unit_preference.T_type.LikeItem then
  if preference.item_subtype == -1 then
   str = "likes " .. string.lower (df.item_type [preference.item_type]) .."s"
  else
   if preference.item_type == df.item_type.WEAPON then
    str = "likes " .. df.global.world.raws.itemdefs.weapons [preference.item_subtype].name_plural
       
   elseif preference.item_type == df.item_type.TRAPCOMP then
    str = "likes " .. df.global.world.raws.itemdefs.trapcomps [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.TOY then
    str = "likes " .. df.global.world.raws.itemdefs.toys [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.TOOL then
    str = "likes " .. df.global.world.raws.itemdefs.tools [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.INSTRUMENT then
    str = "likes " .. df.global.world.raws.itemdefs.instruments [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.ARMOR then
    str = "likes " .. df.global.world.raws.itemdefs.armor [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.AMMO then
    str = "likes " .. df.global.world.raws.itemdefs.ammo [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.SIEGEAMMO then
    str = "likes " .. df.global.world.raws.itemdefs.siege_ammo [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.GLOVES then
    str = "likes " .. df.global.world.raws.itemdefs.gloves [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.SHOES then
    str = "likes " .. df.global.world.raws.itemdefs.shoes [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.SHIELD then
    str = "likes " .. df.global.world.raws.itemdefs.shields [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.HELM then
    str = "likes " .. df.global.world.raws.itemdefs.helms [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.PANTS then
    str = "likes " .. df.global.world.raws.itemdefs.pants [preference.item_subtype].name_plural
   
   elseif preference.item_type == df.item_type.FOOD then
    str = "likes " .. df.global.world.raws.itemdefs.food [preference.item_subtype].name_plural
   
   else
    str = "likes " .. string.lower (df.item_type [preference.item_type]) .."s"
    --### Don't know how to process the subtype...
   end
  end
   
 elseif preference.type == df.unit_preference.T_type.LikePlant or
        preference.type == df.unit_preference.T_type.LikeTree then
  str = "likes " .. df.global.world.raws.plants.all [preference.plant_id].name_plural .. 
        " for their " .. df.global.world.raws.plants.all [preference.plant_id].prefstring [0].value
   
 elseif preference.type == df.unit_preference.T_type.LikeColor then
  str = "likes the color " .. df.global.world.raws.descriptors.colors [preference.color_id].name
   
 elseif preference.type == df.unit_preference.T_type.LikeShape then
  str = "likes the shape of " .. df.global.world.raws.descriptors.shapes [preference.shape_id].name_plural
   
 elseif preference.type == df.unit_preference.T_type.LikePoeticForm then
  str = "likes the words of " .. dfhack.TranslateName (df.global.world.poetic_forms.all [preference.poetic_form_id].name, true)
             
 elseif preference.type == df.unit_preference.T_type.LikeMusicalForm then
  str = "likes the sound of " .. dfhack.TranslateName (df.global.world.musical_forms.all [preference.musical_form_id].name, true)
   
 elseif preference.type == df.unit_preference.T_type.LikeDanceForm then
  str = "likes the sight of " .. dfhack.TranslateName (df.global.world.dance_forms.all [preference.dance_form_id].name, true)
 end

 return str, bin
end

local function orientation_string(unit)
 local orientation = 'Indeterminate'

 -- Get orientation
 o_flags = unit.status.current_soul.orientation_flags
 if o_flags.indeterminate then
  orientation = 'Indeterminate'
 else
  if (o_flags.romance_male or o_flags.marry_male) and
     (o_flags.romance_female or o_flags.marry_female) then
   orientation = 'Bisexual'
  else
   if (o_flags.romance_male or o_flags.marry_male) then
    if unit.sex == 0 then orientation = 'Heterosexual' end
	if unit.sex == 1 then orientation = 'Homosexual' end
   elseif (o_flags.romance_female or o_flags.marry_female) then
    if unit.sex == 0 then orientation = 'Homosexual' end
	if unit.sex == 1 then orientation = 'Heterosexual' end
   end
  end
 end
 
 return orientation
end
local function worship_string(deities) --Modified from Patrik Lundell's thoughts.lua script
 local function worship_strength (strength)
  if strength < 10 then
   return " dubious "
  elseif strength < 25 then
   return " casual "
  elseif strength >= 90 then
   return " ardent "
  elseif strength >= 75 then
   return " faithful "
  else 
   return " "
  end
 end

 local str = ''
 if #deities ~= 0 then
  str = 'Is'      
  for l = 1, #deities do
   str = str .. " a " .. worship_strength(deities[l][2]) .. "worshiper of " .. deities[l][1]
  end
 end

 if str == '' then str = 'Not a worshiper of anything' end
 return str 
end
local function friend_lt(f1, f2) -- Taken from Patrik Lundell's thoughts.lua script
  local f1_relation_level = 3   --  Passing Acquaintance
  local f2_relation_level = 3
  
  if #f1.attitude > 0 then
    if f1.attitude [0] == 1 or    --  Friend
       f1.attitude [0] == 2 or    --  Grudge
       f1.attitude [0] == 3 then  --  Bonded
      f1_relation_level = 1      --  Friend/Grudge/Bonded
    
    elseif f1.attitude [0] == 7 then
      f1_relation_level = 2      --  Friendly Terms
    end
  end
  
  if #f2.attitude > 0 then
    if f2.attitude [0] == 1 or    --  Friend
       f2.attitude [0] == 2 or    --  Grudge
       f2.attitude [0] == 3 then  --  Bonded
      f2_relation_level = 1      --  Friend/Grudge/Bonded
      
    elseif f2.attitude [0] == 7 then
      f2_relation_level = 2      --  Friendly Terms
    end
  end
  
  if f1_relation_level > f2_relation_level then
    return true
  
  elseif f1_relation_level < f2_relation_level then
    return false
  end
  
  if f1_relation_level == 1 then  --  Friend/Grudge/Bonded
    return f1.histfig_id > f2.histfig_id
  end
  
  if f1.rank == f2.rank then
    return f1.histfig_id > f2.histfig_id
    
  else
    return f1.rank < f2.rank
  end
end
function relationship_string(unit) --Modified from Patrik Lundell's thoughts.lua script
 local mother
 local father
 local spouse
 local children = {}
 local deities = {}
 local master
 local apprentices = {}
 local pronoun
 local Pronoun
 local child_type
 local friends = {}
 local outTable = {}
 local Family = {}
 local Friends = {}
 local Grudges = {}
 local MasterApprentice = {}
 
 p1, p2 = getPronoun(unit)
 hf = df.historical_figure.find(unit.hist_figure_id)
 if hf ~= nil then
  for i, histfig_link in ipairs (hf.histfig_links) do
   if histfig_link._type == df.histfig_hf_link_motherst then
    mother = get_hf_name (histfig_link.target_hf)
    if mother == "" then
     mother = nil
    end
        
   elseif histfig_link._type == df.histfig_hf_link_fatherst then
    father = get_hf_name (histfig_link.target_hf)
    if father == "" then
     father = nil
    end
          
   elseif histfig_link._type == df.histfig_hf_link_spousest then
    spouse = get_hf_name (histfig_link.target_hf)
    if spose == "" then
     spouse = nil
    end
        
   elseif histfig_link._type == df.histfig_hf_link_childst then
    table.insert (children, get_hf_name (histfig_link.target_hf))
    if children [#children] == "" then  --  Presumed dead culled HF
     table.remove (children, #children)
    end
          
   elseif histfig_link._type == df.histfig_hf_link_deityst then
    table.insert (deities, {get_hf_name (histfig_link.target_hf), histfig_link.link_strength})
        
   elseif histfig_link._type == df.histfig_hf_link_masterst then
    master = get_hf_name (histfig_link.target_hf)
    if master == "" then
     master = nil
    end
          
   elseif histfig_link._type == df.histfig_hf_link_apprenticest then
    table.insert (apprentices, get_hf_name (histfig_link.target_hf))
    if apprentices [#apprentices] == "" then
     table.remove (apprentices, #apprentices)
    end
          
   elseif histfig_link._type == df.histfig_hf_link_pet_ownerst then
    --### Pet owner.
        
   elseif histfig_link._type == df.histfig_hf_link_former_masterst then
    --### bard
        
   elseif histfig_link._type == df.histfig_hf_link_former_apprenticest then
    --### bard
        
   elseif histfig_link._type == df.histfig_hf_link_loverst then

   end
  end

  if spouse then
   Family[#Family+1] = 'Is married to '..spouse
  else
   Family[#Family+1] = 'Is not married'
  end
  if #children == 0 then
   Family[#Family+1] = 'Has no children'
  else
   Family[#Family+1] = 'Has '..tostring(#children)..' children'
   for i = 1, #children do
    Family[#Family+1] = children[i]
   end
  end
      
  if mother and father then
   Family[#Family+1] = 'Is the '..child_type..' of '..mother..' and '..father
  elseif mother then
   Family[#Family+1] = 'Is the '..child_type..' of '..mother
  elseif father then
   Family[#Family+1] = 'Is the '..child_type..' of '..father
  end
      
  if master then
   MasterApprentice[#MasterApprentice+1] = 'Is an apprentice under '..master
  end
      
  if #apprentices ~= 0 then
   MasterApprentice[#MasterApprentice+1] = 'Is the master of '..tostring(#apprentices)
   for i = 1, #apprentices do
    MasterApprentice[#MasterApprentice+1] = apprentices[i]
   end
  end

  if hf.info.relationships ~= nil then
   for k, relation in ipairs (hf.info.relationships.list) do
    table.insert (friends, relation)
   end
      
   for k = 1, #friends - 1 do
    for l = k + 1, #friends do
     if friend_lt (friends [k], friends [l]) then
      temp = friends [k]
      friends [k] = friends [l]
      friends [l] = temp
     end
    end
   end      
      
   for k, relation in ipairs (friends) do
    tempStr = ''
    if relation.rank > 0 then
     if #relation.attitude == 0 then
      tempStr = "Passing Acquaintance " --.. tostring (relation.rank) .. " "
          
     elseif relation.attitude [0] == 1 then
      tempStr = "Friend " --.. tostring (relation.counter [0]) .. " " .. tostring (relation.rank) .. " "
          
     elseif relation.attitude [0] == 2 then
      tempStr = 'Grudge '
          
     elseif relation.attitude [0] == 3 then
      tempStr = "Bonded "
          
     elseif relation.attitude [0] == 7 then
      tempStr = "Friendly Terms " --.. tostring (relation.counter [0]) .. " " .. tostring (relation.rank) .. " "
        
     end
     if tempStr == 'Grudge ' then
      Grudges[#Grudges+1] = tempStr..get_hf_name (relation.histfig_id)
     else
      Friends[#Friends+1] = tempStr..get_hf_name (relation.histfig_id)
     end
    end
   end
  end
 end
 
 outTable.Mother = mother or 'Unknown'
 outTable.Father = father or 'Unknown'
 outTable.Spouse = spouse or 'None'
 outTable.Children = children
 outTable.Worship = worship_string(deities)
 outTable.Orientation = orientation_string(unit)
 outTable.Family = Family
 outTable.Friends = Friends
 outTable.Grudges = Grudges
 outTable.MasterApprentice = MasterApprentice
 
 return outTable
end