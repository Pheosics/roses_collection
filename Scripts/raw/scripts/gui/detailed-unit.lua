local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

classSystem     = false
featSystem      = false
spellSystem     = false
civSystem       = false
ECreatureSystem = false

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

function getTargetFromScreens()
 local my_trg
 if dfhack.gui.getSelectedUnit(true) then
  my_trg=dfhack.gui.getSelectedUnit(true)
 else
  qerror("No valid target found")
 end
 return my_trg
end

local guiFunctions = dfhack.script_environment('functions/gui')
 
DetailedUnitView = defclass(DetailedUnitView, gui.FramedScreen)
DetailedUnitView.ATTRS={
                        frame_style = gui.BOUNDARY_FRAME,
                        frame_title = "Detailed Unit Viewer",
	               }

function DetailedUnitView:init(args)
 self.target = args.target
 if persistTable.GlobalTable.roses then
  systems = persistTable.GlobalTable.roses.Systems
  if systems.Class            == 'true' then classSystem     = true end
  if systems.Feat             == 'true' then featSystem      = true end
  if systems.Spell            == 'true' then spellSystem     = true end
  if systems.Civilization     == 'true' then civSystem       = true end
  if systems.EnhancedCreature == 'true' then ECreatureSystem = true end
 end
 self.ClassSystem    = classSystem
 self.SpellSystem    = spellSystem
 self.FeatSystem     = featSystem
 self.CivSystem      = civSystem
 self.EnhancedSystem = ECreatureSystem

 -- Bottom UI
 self:addviews{
   widgets.Panel{
     view_id  = 'bottomView',
     frame    = { b = 0, h = 1},
     subviews = {
       widgets.Label{
         view_id = 'bottom_ui',
         frame   = { l = 0, t = 0},
         text    = 'filled by updateBottom()'
       }
     }
   }
 }
 self.subviews.bottomView.visible = true -- Alwayes true

 -- Create Frames
 ---- Main
 self:addMainScreen()     -- 3x3 - AX, AY, AZ, BX, BY, BZ, CX, CY, CZ

 ---- Sub Views
 self:addDetailsScreen()  -- 2x2 - D_AX, D_AY, D_BX, D_BY
 self:addHealthScreen()   -- 2x1 - H_AX, H_AY
 self:addThoughtsScreen() -- 3x1 - T_AX, T_AY, T_AZ
 self:addClassScreen()    -- ?x?
 self:addFeatScreen()     -- ?x?
 self:addSpellScreen()    -- ?x?

 -- Fill Frames
 self:fillMain()
 self:fillDetails()
 self:fillHealth()
 self:fillThoughts()
 if self.ClassSystem then self:fillClasses('Learned',false) end
 if self.FeatSystem  then self:fillFeats('Learned',false)   end
 if self.SpellSystem then self:fillSpells('Learned',false)  end

 -- Set Starting View
 self:viewMain()
end

--= Screen Functions (create the screens)
function DetailedUnitView:addMainScreen()
---- Main
 --[[ Positioning
 Main:
   |       X            |      Y         |       Z           |
 --|--------------------|----------------|-------------------|
 A | Base Information   | Description    | Attributes        |
 --|--------------------|----------------|-------------------|
 B | Membership/Worship | Appearance     | Skills            |
 --|--------------------|----------------|-------------------|
 C | Class Information  | Health         | Stats/Resistances |
 -------------------------------------------------------------
 Bottom UI:
  Details
 ]]
 self:getPositioningMain()
 self:addviews{
   widgets.Panel{
     view_id     = 'main',
     frame       = { l = 0, r = 0 },
     frame_inset = 1,
     subviews    = {
       widgets.List{
         view_id = 'AX',
         frame   = {l = self.AX.anchor.left, t = self.AX.anchor.top, w = self.X_width, h = self.AX.height},
       },
       widgets.List{
         view_id = 'AY',
         frame   = {l = self.AY.anchor.left, t = self.AY.anchor.top, w = self.Y_width, h = self.AY.height},
       },
       widgets.List{
         view_id = 'AZ',
         frame   = {l = self.AZ.anchor.left, t = self.AZ.anchor.top, w = self.Z_width, h = self.AZ.height},
       },
       widgets.List{
         view_id = 'BX',
         frame   = {l = self.BX.anchor.left, t = self.BX.anchor.top, w = self.X_width, h = self.BX.height},
       },
       widgets.List{
         view_id = 'BY',
         frame   = {l = self.BY.anchor.left, t = self.BY.anchor.top, w = self.Y_width, h = self.BY.height},
       },
       widgets.List{
         view_id = 'BZ',
         frame   = {l = self.BZ.anchor.left, t = self.BZ.anchor.top, w = self.Z_width, h = self.BZ.height},
       },
       widgets.List{
         view_id = 'CX',
         frame   = {l = self.CX.anchor.left, t = self.CX.anchor.top, w = self.X_width, h = self.CX.height},
       },
       widgets.List{
         view_id = 'CY',
         frame   = {l = self.CY.anchor.left, t = self.CY.anchor.top, w = self.Y_width, h = self.CY.height},
       },
       widgets.List{
         view_id = 'CZ',
         frame   = {l = self.CZ.anchor.left, t = self.CZ.anchor.top, w = self.Z_width, h = self.CZ.height},
       },
     }
   }
 }
end
function DetailedUnitView:addDetailsScreen()
------ Detailed Information
 --[[
 Detailed Information:
   |      X       |      Y      |      Z      |
 --|--------------|-------------|-------------|
 A |              |             | Resistances |
 --| Attributes   | Skills      |-------------|
 B |              |             | Stats       |
 ----------------------------------------------
 Bottom UI:
  Back
 ]]
 self:getPositioningDetails()
 self:addviews{
   widgets.Panel{
     view_id     = 'detailedView',
     frame       = { l = 0, r = 0 },
     frame_inset = 1,
     subviews    = {
       widgets.List{
         view_id = 'D_ABX',
         frame   = {l = self.D_ABX.anchor.left, t = self.D_ABX.anchor.top, w = self.D_X_width, h = self.D_ABX.height},
       },
       widgets.List{
         view_id = 'D_ABY',
         frame   = {l = self.D_ABY.anchor.left, t = self.D_ABY.anchor.top, w = self.D_Y_width, h = self.D_ABY.height},
       },
       widgets.List{
         view_id = 'D_AZ',
         frame   = {l = self.D_AZ.anchor.left, t = self.D_AZ.anchor.top, w = self.D_Z_width, h = self.D_AZ.height},
       },
       widgets.List{
         view_id = 'D_BZ',
         frame   = {l = self.D_BZ.anchor.left, t = self.D_BZ.anchor.top, w = self.D_Z_width, h = self.D_BZ.height},
       },
     }
   }
 }
end
function DetailedUnitView:addHealthScreen()
------ Health
 --[[
 Health Information:
   |      X       |      Y      |
 --|--------------|-------------|
 A | Health Stats | Syndromes   |
 --------------------------------
 Bottom UI:
  Back
 ]]
 self:getPositioningHealth()
 self:addviews{
   widgets.Panel{
     view_id     = 'healthView',
     frame       = { l = 0, r = 0 },
     frame_inset = 1,
     subviews    = {
       widgets.List{
         view_id = 'H_AX',
         frame   = {l = self.H_AX.anchor.left, t = self.H_AX.anchor.top, w = self.H_X_width, h = self.H_AX.height},
       },
       widgets.List{
         view_id = 'H_AY',
         frame   = {l = self.H_AY.anchor.left, t = self.H_AY.anchor.top, w = self.H_Y_width, h = self.H_AY.height},
       },
     }
   }
 }
end
function DetailedUnitView:addThoughtsScreen()
------ Thoughts
 --[[
 Thoughts and Preferences:
   |    X     |      Y      |   Z    |
 --|----------|-------------|--------|
 A | Thoughts | Preferences | Traits |
 -------------------------------------
 Bottom UI:
  Back
 ]]
 self:getPositioningThoughts()
 self:addviews{
   widgets.Panel{
     view_id     = 'thoughtView',
     frame       = { l = 0, r = 0 },
     frame_inset = 1, 
     subviews    = {
       widgets.List{
         view_id = 'T_AX',
         frame   = {l = self.T_AX.anchor.left, t = self.T_AX.anchor.top, w = self.T_X_width, h = self.T_AX.height},
       },
       widgets.List{
         view_id = 'T_AY',
         frame   = {l = self.T_AY.anchor.left, t = self.T_AY.anchor.top, w = self.T_Y_width, h = self.T_AY.height},
       },
       widgets.List{
         view_id = 'T_AZ',
         frame   = {l = self.T_AZ.anchor.left, t = self.T_AZ.anchor.top, w = self.T_Z_width, h = self.T_AZ.height},
       },
     }
   }
 }
end
function DetailedUnitView:addClassScreen()
------ Class Information
 --[[
 Classes:
   |      X       |      Y      |
 --|--------------|-------------|
 A | Header       |             |
 --|--------------| Details     |
 B | Class List   |             |
 --------------------------------
 Bottom UI:
  Back
 ]]
 self:getPositioningClasses()
 self:addviews{
   widgets.Panel{
     view_id     = 'classView',
     frame       = { l = 0, r = 0 },
     frame_inset = 1,
     subviews    = {
       widgets.List{
         view_id = 'C_AX',
         frame   = {l = self.C_AX.anchor.left, t = self.C_AX.anchor.top, w = self.C_X_width, h = self.C_AX.height},
       },
       widgets.List{
         view_id    = 'C_BX',
         frame      = {l = self.C_BX.anchor.left, t = self.C_BX.anchor.top, w = self.C_X_width, h = self.C_BX.height},
         on_submit  = self:callback('fillClasses'),
         text_pen   = dfhack.pen.parse{fg=COLOR_DARKGRAY, bg=0},
         cursor_pen = dfhack.pen.parse{fg=COLOR_YELLOW, bg=0},
       },
       widgets.List{
         view_id = 'C_ABY',
         frame   = {l = self.C_ABY.anchor.left, t = self.C_ABY.anchor.top, w = self.C_Y_width, h = self.C_ABY.height},
       },
     }
   }
 }
end
function DetailedUnitView:addFeatScreen()
 self:getPositioningFeats()
 self:addviews{
   widgets.Panel{
     view_id     = 'featView',
     frame       = { l = 0, r = 0 },
     frame_inset = 1,
     subviews    = {
     }   
   }
 }
end
function DetailedUnitView:addSpellScreen()
 self:getPositioningSpells()
 self:addviews{
   widgets.Panel{
     view_id     = 'spellView',
     frame       = { l = 0, r = 0 },
     frame_inset = 1,
     subviews    = {
     }   
   }
 }
end


--= Positioning Functions (get the width, height, and anchor points for each screen)
function DetailedUnitView:getPositioningMain()
---- For now just set each cell to the same size
 local AX = {anchor = {}, width = 40, height = 10}
 local AY = {anchor = {}, width = 40, height = 10}
 local AZ = {anchor = {}, width = 40, height = 10}
 local BX = {anchor = {}, width = 40, height = 10}
 local BY = {anchor = {}, width = 40, height = 10}
 local BZ = {anchor = {}, width = 40, height = 10}
 local CX = {anchor = {}, width = 40, height = 10}
 local CY = {anchor = {}, width = 40, height = 10}
 local CZ = {anchor = {}, width = 40, height = 10}
----
 local X_width = math.max(AX.width,BX.width,CX.width)
 local Y_width = math.max(AY.width,BY.width,CY.width)
 local Z_width = math.max(AZ.width,BZ.width,CZ.width)
----
 AX.anchor.top  = 0
 AY.anchor.top  = 0
 AZ.anchor.top  = 0
 AX.anchor.left = 0
 AY.anchor.left = X_width + 4
 AZ.anchor.left = X_width + Y_width + 8
----
 BX.anchor.top  = AX.height + 1
 BY.anchor.top  = AY.height + 1
 BZ.anchor.top  = AZ.height + 1
 BX.anchor.left = 0
 BY.anchor.left = X_width + 4
 BZ.anchor.left = X_width + Y_width + 8
----
 CX.anchor.top  = AX.height + BX.height + 2
 CY.anchor.top  = AY.height + BY.height + 2
 CZ.anchor.top  = AZ.height + BZ.height + 2
 CX.anchor.left = 0
 CY.anchor.left = X_width + 4
 CZ.anchor.left = X_width + Y_width + 8
----
 self.AX = AX
 self.AY = AY
 self.AZ = AZ
 self.BX = BX
 self.BY = BY
 self.BZ = BZ
 self.CX = CX
 self.CY = CY
 self.CZ = CZ
 self.X_width = X_width
 self.Y_width = Y_width
 self.Z_width = Z_width
end
function DetailedUnitView:getPositioningDetails()
---- For now just set each cell to the same size
 local ABX = {anchor = {}, width = 40, height = 40}
 local ABY = {anchor = {}, width = 40, height = 40}
 local AZ  = {anchor = {}, width = 40, height = 20}
 local BZ  = {anchor = {}, width = 40, height = 20}
----
 local X_width = ABX.width
 local Y_width = ABY.width
 local Z_width = math.max(AZ.width,BZ.width)
----
 ABX.anchor.top  = 0
 ABY.anchor.top  = 0
 ABX.anchor.left = 0
 ABY.anchor.left = X_width + 4
----
 AZ.anchor.top  = 0
 AZ.anchor.left = X_width + Y_width + 8
 BZ.anchor.top  = AZ.height + 1
 BZ.anchor.left = X_width + Y_width + 8
----
 self.D_ABX = ABX
 self.D_ABY = ABY
 self.D_AZ  = AZ
 self.D_BZ  = BZ
 self.D_X_width = X_width
 self.D_Y_width = Y_width
 self.D_Z_width = Z_width
end
function DetailedUnitView:getPositioningHealth()
---- For now just set each cell to the same size
 local AX = {anchor = {}, width = 60, height = 40}
 local AY = {anchor = {}, width = 60, height = 40}
----
 local X_width = AX.width
 local Y_width = AY.width
----
 AX.anchor.top  = 0
 AY.anchor.top  = 0
 AX.anchor.left = 0
 AY.anchor.left = X_width + 4
----
 self.H_AX = AX
 self.H_AY = AY
 self.H_X_width = X_width
 self.H_Y_width = Y_width
end
function DetailedUnitView:getPositioningThoughts()
---- For now just set each cell to the same size
 local AX = {anchor = {}, width = 40, height = 40}
 local AY = {anchor = {}, width = 40, height = 40}
 local AZ = {anchor = {}, width = 40, height = 40}
----
 local X_width = AX.width
 local Y_width = AY.width
 local Z_width = AZ.width
----
 AX.anchor.top = 0
 AY.anchor.top = 0
 AZ.anchor.top = 0
 AX.anchor.left = 0
 AY.anchor.left = X_width + 4
 AZ.anchor.left = X_width + Y_width + 8
----
 self.T_AX = AX
 self.T_AY = AY
 self.T_AZ = AZ
 self.T_X_width = X_width
 self.T_Y_width = Y_width
 self.T_Z_width = Z_width
end
function DetailedUnitView:getPositioningClasses()
 local AX  = {anchor = {}, width = 40, height = 3}
 local BX  = {anchor = {}, width = 40, height = 37}
 local ABY = {anchor = {}, width = 80, height = 40}
----
 local X_width = math.max(AX.width,BX.width)
 local Y_width = ABY.width
----
 AX.anchor.top  = 0
 AX.anchor.left = 0
----
 BX.anchor.top  = AX.height + 1
 BX.anchor.left = 0
----
 ABY.anchor.top  = 0
 ABY.anchor.left = X_width + 4 
----
 self.C_AX  = AX
 self.C_BX  = BX
 self.C_ABY = ABY
 self.C_X_width = X_width
 self.C_Y_width = Y_width
end
function DetailedUnitView:getPositioningFeats()
end
function DetailedUnitView:getPositioningSpells()
end

--= Filling Functions (call functions/gui to get the information to put on the screen)
function DetailedUnitView:fillMain()
 local unit = self.target
 local grid = {'AX', 'AY', 'AZ', 'BX', 'BY', 'BZ', 'CX', 'CY', 'CZ'}
 local output = {}
 for i,g in pairs(grid) do
  output[g] = guiFunctions.getMainOutput(g, unit, self[g].width, self.ClassSystem)
  self.subviews[g]:setChoices(output[g])
 end
end
function DetailedUnitView:fillDetails()
 local unit = self.target
 local grid = {'D_ABX', 'D_ABY', 'D_AZ', 'D_BZ'}
 local output = {}
 for i,g in pairs(grid) do
  output[g] = guiFunctions.getDetailsOutput(g, unit, self[g].width)
  self.subviews[g]:setChoices(output[g])
 end
end
function DetailedUnitView:fillHealth()
 local unit = self.target
 local grid = {'H_AX', 'H_AY'}
 local output = {}
 for i,g in pairs(grid) do
  output[g] = guiFunctions.getHealthOutput(g, unit, self[g].width)
  self.subviews[g]:setChoices(output[g])
 end
end
function DetailedUnitView:fillThoughts()
 local unit = self.target
 local grid = {'T_AX', 'T_AY', 'T_AZ'}
 local output = {}
 for i,g in pairs(grid) do
  output[g] = guiFunctions.getThoughtsOutput(g, unit, self[g].width)
  self.subviews[g]:setChoices(output[g])
 end
end
function DetailedUnitView:fillClasses(filter,details)
 local unit = self.target
 local output = {}
 if details == nil then return end
 
 if details then
  output = guiFunctions.getClassesOutput('C_ABY', unit, self.C_ABY.width, details)
  self.subviews.C_ABY:setChoices(output)
 else
  local grid = {'C_AX','C_BX'}
  local output = {}
  for i,g in pairs(grid) do
   output[g] = guiFunctions.getClassesOutput(g, unit, self[g].width, filter)
   self.subviews[g]:setChoices(output[g])
  end
 end
end
function DetailedUnitView:fillFeats(filter)
 local unit = self.target
end
function DetailedUnitView:fillSpells(filter)
 local unit = self.target
end

--= Viewing Functions (change which screen is active and visible)
function DetailedUnitView:updateBottom(screen)
 if      screen == 'Main' then
   text = {
           { key = 'CUSTOM_SHIFT_A', text = ': Details   ', on_activate = self:callback('viewDetails')  },
           { key = 'CUSTOM_SHIFT_H', text = ': Health    ', on_activate = self:callback('viewHealth')   },
           { key = 'CUSTOM_SHIFT_T', text = ': Thoughts  ', on_activate = self:callback('viewThoughts') },
          }
   if self.ClassSystem then table.insert(text, {key = 'CUSTOM_SHIFT_C', text = ': Classes  ', on_activate = self:callback('viewClasses')}) end
   if self.ClassSystem then table.insert(text, {key = 'CUSTOM_SHIFT_F', text = ': Feats    ', on_activate = self:callback('viewFeats')  }) end
   if self.ClassSystem then table.insert(text, {key = 'CUSTOM_SHIFT_S', text = ': Spells   ', on_activate = self:callback('viewSpells') }) end
  elseif screen == 'Details' then
   text = {
           { text = 'ESC: Back  '},
          }
  elseif screen == 'Health' then
   text = {
           { text = 'ESC: Back  '},
          }
  elseif screen == 'Thoughts' then
   text = {
           { text = 'ESC: Back  '},
          }
  elseif screen == 'Classes' then
   text = {
           { key = 'CUSTOM_SHIFT_A', text = ': Show All Classes          ', on_activate = function () self:fillClasses('All',false)       end },
           { key = 'CUSTOM_SHIFT_C', text = ': Show Civilization Classes ', on_activate = function () self:fillClasses('Civ',false)       end },
           { key = 'CUSTOM_SHIFT_K', text = ': Show Known Classes        ', on_activate = function () self:fillClasses('Learned',false)   end },
           { key = 'CUSTOM_SHIFT_V', text = ': Show Available Classes    ', on_activate = function () self:fillClasses('Available',false) end },
           { text = 'ESC: Back'}
          }
   text = {
           { text = 'ESC: Back  '},
          }
  elseif screen == 'Feats' then
   text = {
           { text = 'ESC: Back  '},
          }
  elseif screen == 'Spells' then
   text = {
           { text = 'ESC: Back  '},
          }
  end
  self.subviews.bottom_ui:setText(text)
end
function DetailedUnitView:viewMain()
 self:updateBottom('Main') 
 self.subviews.main.visible         = true
 self.subviews.detailedView.visible = false
 self.subviews.healthView.visible   = false
 self.subviews.thoughtView.visible  = false
 self.subviews.classView.visible    = false
 self.subviews.featView.visible     = false
 self.subviews.spellView.visible    = false
end
function DetailedUnitView:viewDetails()
 self:updateBottom('Details')
 self.subviews.main.visible         = false
 self.subviews.detailedView.visible = true
 self.subviews.healthView.visible   = false
 self.subviews.thoughtView.visible  = false
 self.subviews.classView.visible    = false
 self.subviews.featView.visible     = false
 self.subviews.spellView.visible    = false
end
function DetailedUnitView:viewHealth()
 self:updateBottom('Health')
 self.subviews.main.visible         = false
 self.subviews.detailedView.visible = false
 self.subviews.healthView.visible   = true
 self.subviews.thoughtView.visible  = false
 self.subviews.classView.visible    = false
 self.subviews.featView.visible     = false
 self.subviews.spellView.visible    = false
end
function DetailedUnitView:viewThoughts()
 self:updateBottom('Thoughts')
 self.subviews.main.visible         = false
 self.subviews.detailedView.visible = false
 self.subviews.healthView.visible   = false
 self.subviews.thoughtView.visible  = true
 self.subviews.classView.visible    = false
 self.subviews.featView.visible     = false
 self.subviews.spellView.visible    = false
end
function DetailedUnitView:viewClasses()
 self:updateBottom('Classes')
 self.subviews.main.visible         = false
 self.subviews.detailedView.visible = false
 self.subviews.healthView.visible   = false
 self.subviews.thoughtView.visible  = false
 self.subviews.classView.visible    = true
 self.subviews.featView.visible     = false
 self.subviews.spellView.visible    = false
end
function DetailedUnitView:viewFeats()
 self:updateBottom('Feats')
 self.subviews.main.visible         = false
 self.subviews.detailedView.visible = false
 self.subviews.healthView.visible   = false
 self.subviews.thoughtView.visible  = false
 self.subviews.classView.visible    = false
 self.subviews.featView.visible     = true
 self.subviews.spellView.visible    = false
end
function DetailedUnitView:viewSpells()
 self:updateBottom('Spells')
 self.subviews.main.visible         = false
 self.subviews.detailedView.visible = false
 self.subviews.healthView.visible   = false
 self.subviews.thoughtView.visible  = false
 self.subviews.classView.visible    = false
 self.subviews.featView.visible     = false
 self.subviews.spellView.visible    = true
end


--= Base Functions
function DetailedUnitView:onInput(keys)
 if keys.LEAVESCREEN then
  if self.subviews.main.visible then
   self:dismiss()
  else
   self:viewMain()
  end
 else
  DetailedUnitView.super.onInput(self, keys)
 end
end
function show_editor(trg)
 local screen = DetailedUnitView{target=trg}
 screen:show()
end

show_editor(getTargetFromScreens())
