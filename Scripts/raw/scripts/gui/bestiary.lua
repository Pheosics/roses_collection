local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string

function center(str, length)
 local string1 = str
 local string2 = string.format("%"..tostring(math.floor((length-#string1)/2)).."s"..string1,"")
 local string3 = string.format(string2.."%"..tostring(math.ceil((length-#string1)/2)).."s","")
 return string3
end

function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local guiFunctions = dfhack.script_environment('functions/gui')

biomeTokens = {
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
                BIOME_RIVER_TROPICAL_SALTWATER = 'Tropical Saltwater River'
              }
habitatFlags = {
AMPHIBIOUS = 'Amphibious',
AQUATIC = 'Aquatic',
GOOD = 'Living in good biomes',
EVIL = 'Living in evil biomes',
SAVAGE = 'Living in savage biomes'
              }
activeFlags = {
ALL_ACTIVE = 'At all times',
DIURNAL = 'During the day',
NOCTURNAL = 'During the night',
CREPUSCULAR = 'At dawn and dusk',
VESPERTINE = 'At dusk',
MATUTINAL = 'At dawn',
              }
utilityFlags = {
COMMON_DOMESTIC = 'Domesticated',
WAGON_PULLER = 'Can pull wagons',
PACK_ANIMAL = 'Can haul goods',
TRAINABLE_HUNTING = 'Can be trained to hunt',
TRAINABLE_WAR = 'Can be trained for fighting',
PET = 'Can be tamed',
PET_EXOTIC = 'Can be tamed with difficulty',
MOUNT = 'Can be used as a mount',
MOUNT_EXOTIC = 'Can be used as a mount',
               }               
dietFlags = {
NO_EAT = "Doesn't need food",
NO_DRINK = "Doesn't need drink",
BONECARN = 'Eats meat and bones',
CARNIVORE = 'Only eats meat',
GRAZER = 'Eats grass',
GOBBLE_VERMIN = 'Eats vermin',
            }
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
OPPOSED_TO_LIFE = 'Hostile to the living',
                }
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
UNDERSWIM = 'Swims underwater',
                }
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
WEBIMMUNE = 'Does not get caught in webs',
              }
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
UTTERANCES = 'Unintelligible utterances',
             }              
bodyFlags = {
NOT_BUTCHERABLE = 'Can not be butchered',
COOKABLE_LIVE = 'Can be cooked live',
NOSKULL = 'Does not have a skull',
NOSKIN = 'Does not have skin',
NOBONES = 'Does not have bones',
NOMEAT = 'Does not have meat',
NOTHOUGHT = 'Does not have a brain',
NO_THOUGHT_CENTER_FOR_MOVEMENT = 'Does not need a brain to move',
VEGETATION = 'Made of swampstuff',
            }              
seasonFlags = {
NO_SPRING = 'Absent during the spring',
NO_SUMMER = 'Absent during the summer',
NO_AUTUMN = 'Absent during the fall',
NO_WINTER = 'Absent during the winter',
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

BestiaryUi = defclass(BestiaryUi, gui.FramedScreen)
BestiaryUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Bestiary",
	             }

function BestiaryUi:init()
-- Create frames
-- Creature Detail Frames
 self:addviews{
       widgets.Panel{
       view_id = 'creatureView',
       frame = { l = 31, r = 0},
       frame_inset = 1,
       subviews = {
        widgets.List{
         view_id = 'creatureViewDetails',
         frame = {l = 0, t = 1},
                },
        widgets.List{
		 view_id = 'creatureViewDetails1',
         frame = { l = 0, t = 4},
                },
        widgets.List{
		 view_id = 'creatureViewDetails2',
         frame = { l = 45, t = 4},
                }
            }
        }
    }
-- Base Creature Sorting Frames
 self:addviews{
       widgets.Panel{
	   view_id = 'creatureList',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
       	widgets.Label{
		 view_id = 'creatureListHeader_Creatures',
         frame = { l = 0, t = 0},
         text = {{text=center('Creatures',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'creatureListCreatures',
         on_submit = self:callback('selectCreature'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'creatureListHeader_Castes',
         frame = { l = 0, t = 0},
         text = {{text=center('Castes',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'creatureListCastes',
         on_select = self:callback('creatureDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
         view_id = 'creatureBottom',
         frame = { b=0,l=1},
         text ={{text= ": Exit ",key= "LEAVESCREEN",},
                {text=": Sort by Biome ",key = "CHANGETAB",on_activate=self:callback('changeSort')}
               }
                }
		    }
        },
       widgets.Panel{
	   view_id = 'biomeList',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
       	widgets.Label{
		 view_id = 'biomeListHeader_Biomes',
         frame = { l = 0, t = 0},
         text = {{text=center('Biomes',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'biomeListBiomes',
         on_submit = self:callback('selectBiome'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'biomeListHeader_Creatures',
         frame = { l = 0, t = 0},
         text = {{text=center('Creatures',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'biomeListCreatures',
         on_submit = self:callback('selectCreature'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'biomeListHeader_Castes',
         frame = { l = 0, t = 0},
         text = {{text=center('Castes',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'biomeListCastes',
         on_select = self:callback('creatureDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
         view_id = 'biomeBottom',
         frame = { b=0,l=1},
         text ={{text= ": Exit ", key= "LEAVESCREEN",},
                {text=": Show All Creatures ",key = "CHANGETAB",on_activate=self:callback('changeSort')}}
               }
		    }
        }
    }

 self.viewcheck = {creatureList = {
                                   {'creatureListCreatures','creatureBottom','creatureListHeader_Creatures'},
                                   {'creatureListCastes','creatureListHeader_Castes'}
                                  },
                   biomeList = {
                           {'biomeListBiomes','biomeBottom','biomeListHeader_Biomes'},
                           {'biomeListCreatures','biomeListHeader_Creatures'},
                           {'biomeListCastes','biomeListHeader_Castes'}
                          }
                  }
 self.viewcheck.base = {'creatureList','biomeList'}
 self.viewcheck.always = {'creatureView','creatureViewDetails','creatureViewDetails1','creatureViewDetails2'}
 self.viewcheck.baseNum = 2

 self:getCreatures()
 self:getBiomes()

 self.subviews.creatureList.view = true
 self.subviews.creatureView.visible = true
 self.subviews.biomeList.view = true

 self.subviews.creatureListCreatures.active = true
 self.subviews.creatureListCreatures.edit.active = true
 self.subviews.creatureListCastes.active = false
 self.subviews.creatureListCastes.visible = false
 self.subviews.creatureListHeader_Castes.visible = false
 
 self.subviews.biomeList.visible = false
 self.subviews.biomeListBiomes.visible = false
 self.subviews.biomeListCreatures.visible = false
 self.subviews.biomeListCastes.visible = false
 self.subviews.biomeList.active = false
 self.subviews.biomeBottom.visible = false
end

function BestiaryUi:onRenderBody(dc)
 if self.subviews.creatureListCastes.active then
  for _,page in pairs(df.global.texture.page) do
   if page.token == self.creature.creature_id then
    local tex=copyall(page.texpos)
    for i=0,page.page_dim_x-1 do
     for j=0,page.page_dim_y-1 do
      dc:seek(i,j+30):tile(0,tex[i+j*page.page_dim_x])
     end
	end
   end
  end
 end
end

function BestiaryUi:changeSort()
 guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'base')
end

function BestiaryUi:getBiomes()
 biomes,climate = guiFunctions.getBiomeCreatures(biomeTokens)
 guiFunctions.makeWidgetList(self.subviews.biomeListBiomes,'first',biomes)
 self.biomes = biomes
end

function BestiaryUi:getCreatures()
 local creatureList = df.global.world.raws.creatures.alphabetic
 local creatures = {}
 for _,creature in pairs(creatureList) do
  creatures[#creatures+1] = creature.name[0]
 end
 guiFunctions.makeWidgetList(self.subviews.creatureListCreatures,'second',creatures)
end

function BestiaryUi:selectBiome(input,choice)
 guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'down')
 guiFunctions.makeWidgetList(self.subviews.biomeListCreatures,'second',self.biomes[choice.text])
end

function BestiaryUi:selectCreature(index,choice)
 if not choice then return end
 creature, castes = guiFunctions.getCreatureCastes(choice)
 if not creature then return end
 self.creature = creature

 guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'down')
 if self.subviews.creatureListCastes.visible then
  guiFunctions.makeWidgetList(self.subviews.creatureListCastes,'second',castes)
 elseif self.subviews.biomeListCastes.visible then
  guiFunctions.makeWidgetList(self.subviews.biomeListCastes,'second',castes)
 end
end

function BestiaryUi:creatureDetails(index,choice)
 local input = {}
 local input2 = {}
 local header = {}
 local creature = self.creature
 local caste = self.creature.caste[index-1]
 local info = guiFunctions.getCreatureRaws(creature,caste)

 for _,second in pairs(split(info.description,'\n')) do
  table.insert(header,{text={{text=second,pen=COLOR_LIGHTCYAN,width=85}}})
 end
 self.subviews.creatureViewDetails:setChoices(header)

 input = guiFunctions.insertWidgetInput(input,'header',{header='Creature Name:',second=creature.name[0]})
 input = guiFunctions.insertWidgetInput(input,'header',{header='Caste Name:',second=caste.caste_name[0]})
 input = guiFunctions.insertWidgetInput(input,'header',{header='Average Life:',second=tostring(info.maxage)..' years'})
 input = guiFunctions.insertWidgetInput(input,'header',{header='Adult Size:',second=tostring(info.adultsize)..' kg'})
 input = guiFunctions.insertWidgetInput(input,'header',{header='Biomes:',second=info.flags},{replacement=biomeTokens})
 input = guiFunctions.insertWidgetInput(input,'header',{header='Habitat:',second=info.flags},{replacement=habitatFlags})
 input = guiFunctions.insertWidgetInput(input,'header',{header='Seasons:',second=info.flags},{replacement=seasonFlags})
 input = guiFunctions.insertWidgetInput(input,'header',{header='Active Times:',second=info.flags},{replacement=activeFlags})
 
 local list = self.subviews.creatureViewDetails1
 list:setChoices(input)
 
 input2 = guiFunctions.insertWidgetInput(input2,'header',{header='Utility:',second=info.flags},{replacement=utilityFlags})
 input2 = guiFunctions.insertWidgetInput(input2,'header',{header='Behaviors:',second=info.flags},{replacement=behaviorFlags})
 input2 = guiFunctions.insertWidgetInput(input2,'header',{header='Diet:',second=info.flags},{replacement=dietFlags})
 input2 = guiFunctions.insertWidgetInput(input2,'header',{header='Movement:',second=info.flags},{replacement=movementFlags})
 local list = self.subviews.creatureViewDetails2
 list:setChoices(input2)
end

function BestiaryUi:clearCreatureDetails()
 input = {}
 self.subviews.creatureViewDetails:setChoices(input)
 self.subviews.creatureViewDetails1:setChoices(input)
 self.subviews.creatureViewDetails2:setChoices(input)
end

function BestiaryUi:onInput(keys)
 if keys.LEAVESCREEN then
  check = guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'up')
  if check then
   self:clearCreatureDetails()
  else
   self:dismiss()
  end
 end

 self.super.onInput(self,keys)
end

local screen = BestiaryUi{}
screen:show()