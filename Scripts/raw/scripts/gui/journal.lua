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

JournalUi = defclass(JournalUi, gui.FramedScreen)
JournalUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Bestiary",
	             }

function JournalUi:init()
-- Create frames
-- Creature Detail Frames
 self:addviews{
       widgets.Panel{
       view_id = 'creatureView',
       frame = { l = 0, r = 0},
       frame_inset = 1,
       subviews = {
                widgets.Label{
         view_id = 'creatureBottom',
         frame = {t=1,l=1},
         text ={{text=": Bestiary ",key = "CHANGETAB",on_activate=self:callback('bestiary')},
                NEWLINE,
                {text= ": Exit ",key= "LEAVESCREEN",} 
               }
                },
                }
            }
        }
end

function JournalUi:bestiary()
 dfhack.run_command('gui/bestiary')
end

function JournalUi:onInput(keys)
 if keys.LEAVESCREEN then
  self:dismiss()
 end

 self.super.onInput(self,keys)
end

local screen = JournalUi{}
screen:show()