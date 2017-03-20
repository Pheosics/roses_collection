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
WET = 'Growing in wet conditions',
DRY = 'Growing in dry conditions',
GOOD = 'Growing in good biomes',
EVIL = 'Growing in evil biomes',
SAVAGE = 'Growing in savage biomes'
              }
seasonFlags = {
SPRING = 'Grows in the spring',
SUMMER = 'Grows in the summer',
AUTUMN = 'Grows in the fall',
WINTER = 'Grows in the winter',
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
       view_id = 'plantView',
       frame = { l = 31, r = 0},
       frame_inset = 1,
       subviews = {
        widgets.List{
         view_id = 'plantViewDetails',
         frame = {l = 0, t = 1},
                },
        widgets.List{
		 view_id = 'plantViewDetails1',
         frame = { l = 0, t = 4},
                },
        widgets.List{
		 view_id = 'plantViewDetails2',
         frame = { l = 45, t = 4},
                }
            }
        }
    }
-- Base Creature Sorting Frames
 self:addviews{
       widgets.Panel{
	   view_id = 'plantList',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
       	widgets.Label{
		 view_id = 'plantListHeader_Plants',
         frame = { l = 0, t = 0},
         text = {{text=center('Plants (All)',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'plantListPlants',
         on_submit = self:callback('selectPlant'),
         on_select = self:callback('plantDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'plantListHeader_Products',
         frame = { l = 0, t = 0},
         text = {{text=center('Plant Products',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'plantListProducts',
         on_select = self:callback('productDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
         view_id = 'plantBottom',
         frame = { b=0,l=0},
         text ={{text= ": All Plants ",key= "CURSOR_DOWNLEFT",on_activate=self:callback('changeType_All')},
                {text=": Trees ",key = "CURSOR_DOWN",on_activate=self:callback('changeType_Trees')},
                {text=": Bushes ",key = "CURSOR_DOWNRIGHT",on_activate=self:callback('changeType_Bushes')},
                {text=": Grasses ",key = "CURSOR_LEFT",on_activate=self:callback('changeType_Grasses')},
                NEWLINE,
                {text= ": Exit ",key= "LEAVESCREEN",},
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
         text = {{text=center('Biomes (All)',40),pen=COLOR_LIGHTCYAN}}
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
		 view_id = 'biomeListHeader_Plants',
         frame = { l = 0, t = 0},
         text = {{text=center('Plants (All)',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'biomeListPlants',
         on_submit = self:callback('selectPlant'),
         on_select = self:callback('plantDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'biomeListHeader_Products',
         frame = { l = 0, t = 0},
         text = {{text=center('Castes',40),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'biomeListProducts',
         on_select = self:callback('productDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
         view_id = 'biomeBottom',
         frame = { b=0,l=0},
         text ={{text= ": All Plants ",key= "CURSOR_DOWNLEFT",on_activate=self:callback('changeType_All')},
                {text=": Trees ",key = "CURSOR_DOWN",on_activate=self:callback('changeType_Trees')},
                {text=": Bushes ",key = "CURSOR_DOWNRIGHT",on_activate=self:callback('changeType_Bushes')},
                {text=": Grasses ",key = "CURSOR_LEFT",on_activate=self:callback('changeType_Grasses')},
                NEWLINE,
                {text= ": Exit ", key= "LEAVESCREEN",},
                {text=": Show All ",key = "CHANGETAB",on_activate=self:callback('changeSort')}}
               }
		    }
        }
    }

 self.viewcheck = {plantList = {
                                   {'plantListPlants','plantBottom','plantListHeader_Plants'},
                                   {'plantListProducts','plantListHeader_Products'}
                                  },
                   biomeList = {
                           {'biomeListBiomes','biomeBottom','biomeListHeader_Biomes'},
                           {'biomeListPlants','biomeListHeader_Plants'},
                           {'biomeListProducts','biomeListHeader_Products'}
                          }
                  }
 self.viewcheck.base = {'plantList','biomeList'}
 self.viewcheck.always = {'plantView','plantViewDetails','plantViewDetails1','plantViewDetails2'}
 self.viewcheck.baseNum = 2
 self.plantcheck = 'All'
 self:getPlants()
 self:getBiomes()

 self.subviews.plantList.view = true
 self.subviews.plantView.visible = true
 self.subviews.biomeList.view = true

 self.subviews.plantListPlants.active = true
 self.subviews.plantListPlants.edit.active = true
 self.subviews.plantListProducts.active = false
 self.subviews.plantListProducts.visible = false
 self.subviews.plantListHeader_Products.visible = false
 
 self.subviews.biomeList.visible = false
 self.subviews.biomeListBiomes.visible = false
 self.subviews.biomeListPlants.visible = false
 self.subviews.biomeListProducts.visible = false
 self.subviews.biomeList.active = false
 self.subviews.biomeBottom.visible = false
end
--[[
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
]]
function BestiaryUi:changeSort()
 guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'base')
end

function BestiaryUi:changeType_All()
 self.plantcheck = 'All'
 self.subviews.plantListHeader_Plants:setText({{text=center('Plants (All)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Biomes:setText({{text=center('Biomes (All)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Plants:setText({{text=center('Plants (All)',40),pen=COLOR_LIGHTCYAN}})
 self:getPlants()
 self:getBiomes()
end
function BestiaryUi:changeType_Trees()
 self.plantcheck = 'Trees'
 self.subviews.plantListHeader_Plants:setText({{text=center('Plants (Trees)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Biomes:setText({{text=center('Biomes (Trees)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Plants:setText({{text=center('Plants (Trees)',40),pen=COLOR_LIGHTCYAN}})
 self:getPlants()
 self:getBiomes()
end
function BestiaryUi:changeType_Bushes()
 self.plantcheck = 'Bushes'
 self.subviews.plantListHeader_Plants:setText({{text=center('Plants (Bushes)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Biomes:setText({{text=center('Biomes (Bushes)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Plants:setText({{text=center('Plants (Bushes)',40),pen=COLOR_LIGHTCYAN}})
 self:getPlants()
 self:getBiomes()
end
function BestiaryUi:changeType_Grasses()
 self.plantcheck = 'Grasses'
 self.subviews.plantListHeader_Plants:setText({{text=center('Plants (Grasses)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Biomes:setText({{text=center('Biomes (Grasses)',40),pen=COLOR_LIGHTCYAN}})
 self.subviews.biomeListHeader_Plants:setText({{text=center('Plants (Grasses)',40),pen=COLOR_LIGHTCYAN}})
 self:getPlants()
 self:getBiomes()
end

function BestiaryUi:getBiomes()
 if self.plantcheck == 'All' then
  plantList = df.global.world.raws.plants.all
 elseif self.plantcheck == 'Bushes' then
  plantList = df.global.world.raws.plants.bushes
 elseif self.plantcheck == 'Trees' then
  plantList = df.global.world.raws.plants.trees
 elseif self.plantcheck == 'Grasses' then
  plantList = df.global.world.raws.plants.grasses
 else
  plantList = df.global.world.raws.plants.all
 end
 biomes,climate = guiFunctions.getBiomePlants(biomeTokens,plantList)
 guiFunctions.makeWidgetList(self.subviews.biomeListBiomes,'first',biomes)
 self.biomes = biomes
end

function BestiaryUi:getPlants()
 if self.plantcheck == 'All' then
  plantList = df.global.world.raws.plants.all
 elseif self.plantcheck == 'Bushes' then
  plantList = df.global.world.raws.plants.bushes
 elseif self.plantcheck == 'Trees' then
  plantList = df.global.world.raws.plants.trees
 elseif self.plantcheck == 'Grasses' then
  plantList = df.global.world.raws.plants.grasses
 else
  plantList = df.global.world.raws.plants.all
 end
 local plants = {}
 for _,plant in pairs(plantList) do
  plants[#plants+1] = plant.name
 end
 guiFunctions.makeWidgetList(self.subviews.plantListPlants,'second',plants)
end

function BestiaryUi:selectBiome(input,choice)
 guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'down')
 guiFunctions.makeWidgetList(self.subviews.biomeListPlants,'second',self.biomes[choice.text])
end

function BestiaryUi:selectPlant(index,choice)
 if not choice then return end
 plant, products = guiFunctions.getPlantProducts(choice)
 if not plant then return end
 self.plant = plant

 guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'down')
 if self.subviews.plantListProducts.visible then
  guiFunctions.makeWidgetList(self.subviews.plantListProducts,'second',products)
 elseif self.subviews.biomeListProducts.visible then
  guiFunctions.makeWidgetList(self.subviews.biomeListProducts,'second',products)
 end
end

function BestiaryUi:plantDetails(index,choice)
 local input = {}
 local input2 = {}
 printall(choice)
 self.subviews.plantViewDetails1:setChoices(input)
 self.subviews.plantViewDetails2:setChoices(input2)
end

function BestiaryUi:productDetails(index,choice)
 local input = {}
 local input2 = {}
 printall(choice)
 self.subviews.plantViewDetails1:setChoices(input)
 self.subviews.plantViewDetails2:setChoices(input2)
end

function BestiaryUi:clearPlantDetails()
 input = {}
 self.subviews.plantViewDetails:setChoices(input)
 self.subviews.plantViewDetails1:setChoices(input)
 self.subviews.plantViewDetails2:setChoices(input)
end

function BestiaryUi:onInput(keys)
 if keys.LEAVESCREEN then
  check = guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'up')
  if check then
   self:clearPlantDetails()
  else
   self:dismiss()
  end
 end

 self.super.onInput(self,keys)
end

local screen = BestiaryUi{}
screen:show()