local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string

classSystem = false
featSystem = false
spellSystem = false
civSystem = false
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
 local persistTable = require 'persist-table'
 if persistTable.GlobalTable.roses then
  systems = persistTable.GlobalTable.roses.Systems
  if systems.Class == 'true' then classSystem = true end
  if systems.Feat == 'true' then featSystem = true end
  if systems.Spell == 'true' then spellSystem = true end
  if systems.Civilization == 'true' then civSystem = true end
  if systems.EnhancedCreature == 'true' then ECreatureSystem = true end
 end
 self.ClassSystem    = classSystem
 self.SpellSystem    = spellSystem
 self.FeatSystem     = featSystem
 self.CivSystem      = civSystem
 self.EnhancedSystem = ECreatureSystem

 -- Positioning
 --[[
 Main:
   |       X            |      Y         |       Z        |
 --|--------------------|----------------|----------------|
 A |                    |                |                |
 --|--------------------|----------------|----------------|
 B |                    |                |                |
 --|--------------------|----------------|----------------|
 C |                    |                |                |
 ----------------------------------------------------------
 Bottom UI:
 ]]

---- For now just set each cell to the same size
 AX = {anchor = {}, width = 40, height = 10}
 AY = {anchor = {}, width = 40, height = 10}
 AZ = {anchor = {}, width = 40, height = 10}
 BX = {anchor = {}, width = 40, height = 10}
 BY = {anchor = {}, width = 40, height = 10}
 BZ = {anchor = {}, width = 40, height = 10}
 CX = {anchor = {}, width = 40, height = 10}
 CY = {anchor = {}, width = 40, height = 10}
 CZ = {anchor = {}, width = 40, height = 10}
----
 X_width = math.max(AX.width,BX.width,CX.width)
 Y_width = math.max(AY.width,BY.width,CY.width)
 Z_width = math.max(AZ.width,BZ.width,CZ.width)
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

-- Create Frames
---- Main
 self:addviews{
   widgets.Panel{
     view_id = 'main',
     frame = { l = 0, r = 0 },
     frame_inset = 1,
     subviews = {
       widgets.List{
         view_id = 'AX',
         frame = {l = AX.anchor.left, t = AX.anchor.top, w = X_width, h = AX.height},
       },
       widgets.List{
         view_id = 'AY',
         frame = {l = AY.anchor.left, t = AY.anchor.top, w = Y_width, h = AY.height},
       },
       widgets.List{
         view_id = 'AZ',
         frame = {l = AZ.anchor.left, t = AZ.anchor.top, w = Z_width, h = AZ.height},
       },
       widgets.List{
         view_id = 'BX',
         frame = {l = BX.anchor.left, t = BX.anchor.top, w = X_width, h = BX.height},
       },
       widgets.List{
         view_id = 'BY',
         frame = {l = BY.anchor.left, t = BY.anchor.top, w = Y_width, h = BY.height},
       }
       widgets.List{
         view_id = 'BZ',
         frame = {l = BZ.anchor.left, t = BZ.anchor.top, w = Z_width, h = BZ.height},
       },
       widgets.List{
         view_id = 'CX',
         frame = {l = CX.anchor.left, t = CX.anchor.top, w = X_width, h = CX.height},
       },
       widgets.List{
         view_id = 'CY',
         frame = {l = CY.anchor.left, t = CY.anchor.top, w = Y_width, h = CY.height},
       },
       widgets.List{
         view_id = 'CZ',
         frame = {l = CZ.anchor.left, t = CZ.anchor.top, w = Z_width, h = CZ.height},
       },
     }
   }
 }
---- Bottom UI
 self:addviews{
   widgets.Panel{
     view_id = 'bottomView',
     frame = { b = 0, h = 1},
     subviews = {
       widgets.Label{
         view_id = 'bottom_ui',
         frame = { l = 0, t = 0},
         text = 'filled by updateBottom()'
       }
     }
   }
 }

 self.subviews.main.visible = true
 self.subviews.bottomView.visible = true

 self:fillMain()
 self:updateBottom()
end

function DetailedUnitView:fillMain()
 unit = self.target
 grid = {'AX', 'AY', 'AZ', 'BX', 'BY', 'BZ', 'CX', 'CY', 'CZ'}
 output = {}
 for i,g in pairs(grid) do
  output[g] = guiFunctions.getMainOutput(g, unit, self[g].width, self.ClassSystem)
  self.subviews[g]:setChoices(output[g])
 end
end

function DetailedUnitView:updateBottom()
  text = {
          { key = 'CUSTOM_SHIFT_A', text = ': ???  ', on_activate = self:callback('not_right_now') },
          { key = 'CUSTOM_SHIFT_B', text = ': ???  ', on_activate = self:callback('not_right_now') },
          { key = 'CUSTOM_SHIFT_C', text = ': ???  ', on_activate = self:callback('not_right_now') },
          { key = 'CUSTOM_SHIFT_D', text = ': ???  ', on_activate = self:callback('not_right_now') },
         }
  self.subviews.bottom_ui:setText(text)
end



function DetailedUnitView:not_right_now()

end

function DetailedUnitView:onInput(keys)
 if keys.LEAVESCREEN then
  self:dismiss()
 else
  DetailedUnitView.super.onInput(self, keys)
 end
end

function show_editor(trg)
 local screen = DetailedUnitView{target=trg}
 screen:show()
end

show_editor(getTargetFromScreens())
