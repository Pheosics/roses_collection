local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string

checkclass = true

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

UnitViewUi = defclass(UnitViewUi, gui.FramedScreen)
UnitViewUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Detailed unit viewer",
	             }

function UnitViewUi:init(args)
 self.target = args.target
-- Create frames
 self:addviews{
       widgets.Panel{
	   view_id = 'main',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
        widgets.Label{
		 view_id = 'unit',
         frame = { l = 0, t = 0, w = 10, h = 5},
         text = {
                { text = 'full_name', width = 10 },
                NEWLINE,
                { text = 'caste', width = 10 },
				NEWLINE,
				{ text = 'civilization', width = 10 },
                }
                },
		widgets.List{
		 view_id = 'creature_description',
         frame = { l = 10, t = 0, w = 10, h = 5},
                },          
		widgets.List{
		 view_id = 'basic_health',
         frame = { l = 20, t = 0, w = 10, h = 5},
                },
		widgets.List{
		 view_id = 'membership_and_worship',
         frame = { l = 0, t = 5, w = 10, h = 5},
                },
		widgets.List{
		 view_id = 'skills',
         frame = { l = 10, t = 5, w = 10, h = 5},
                },
		widgets.List{
		 view_id = 'emotions',
         frame = { l = 20, t = 5, w = 10, h = 5},
                },
		widgets.List{
		 view_id = 'thoughts_and_preferences',
         frame = { l = 10, t = 15, w = 10, h = 5},
                },
        widgets.List{
         view_id = 'physical_stats',
         frame = { l = 0, t = 10, w = 10, h = 5},
                },
		widgets.List{
		 view_id = 'attribute_description',
         frame = { l = 0, t = 15, w = 10, h = 5},
                },
        widgets.List{
         view_id = 'physical_desc',
         frame = { l = 0, t = 20, w = 10, h = 5},
                },
            }
		}
	}
end

function UnitViewUi:onRenderBody(dc)
 for _,page in pairs(df.global.texture.page) do
  if page.token == df.global.world.raws.creatures.all[tonumber(self.target.race)].creature_id then
   local tex=copyall(page.texpos)
   for i=0,page.page_dim_x-1 do
    for j=0,page.page_dim_y-1 do
     dc:seek(i,j):tile(0,tex[i+j*page.page_dim_x])
	end
   end
  end
 end
end
function UnitViewUi:onInput(keys)
 if keys.LEAVESCREEN then
  self:dismiss()
 else
  UnitViewUi.super.onInput(self, keys)
 end
end

function show_editor(trg)
 local screen = UnitViewUi{target=trg}
 screen:show()
end

show_editor(getTargetFromScreens())