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

local guiFunctions = dfhack.script_environment('functions/gui')
 
UnitViewUi = defclass(UnitViewUi, gui.FramedScreen)
UnitViewUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Detailed unit viewer",
	             }

function UnitViewUi:init(args)
 test_length = 30
-- Gather data
 full_name = guiFunctions.getUnitName(args.target)
 caste = guiFunctions.getCasteName(args.target)
 syndromes, syndromes_detail = guiFunctions.getSyndromes(args.target)
 interactions, t_interactions = guiFunctions.getInteractions(args.target)
 p_attributes, m_attributes = guiFunctions.getAttributes(args.target)
 skills, skillinfo = guiFunctions.getSkills(args.target)
 entity, civilization, membership = guiFunctions.getEntity(args.target)
 info = guiFunctions.getInfo(args.target,test_length)
 self.target = args.target

-- Positioning
---- Main Frame Layout
--[[
          X                   Y                 Z
    Name               |                |                |
A   Caste              | Description    | Basic Health   | Traits/Preferences
    Civilization       |                |                |
-----------------------|----------------|----------------|
B   Membership/Worship | Appearance     | Emotions       |
-----------------------|----------------|----------------|
C   Skills             | Attribute Desc |                |
----------------------------------------------------------
Bottom UI
]]
 AX = {anchor = {top = 0, left = 0}, width = test_length, height = 6}
 AY = {anchor = {top = 0, left = 0}, width = info.description.width, height = info.description.height+1}
 AZ = {anchor = {top = 0, left = 0}, width = info.wounds.width, height = info.wounds.height+1}
 BX = {anchor = {top = AX.height+1, left = 0}, width = math.max(info.membership.width,info.worship.width), height = info.membership.height+info.worship.height+3}
 BY = {anchor = {top = AY.height+1, left = 0}, width = info.appearance.width, height = info.appearance.height+1}
 BZ = {anchor = {top = AZ.height+1, left = 0}, width = info.thoughts.width, height = info.thoughts.height+1}
 CX = {anchor = {top = AX.height+BX.height+2, left = 0}, width = skillinfo.width, height = skillinfo.height+1}
 CY = {anchor = {top = AY.height+BY.height+2, left = 0}, width = math.max(info.attributes1.width,info.attributes2.width), height = info.attributes1.height+info.attributes2.height+3}
 CZ = {anchor = {top = 0, left = AX.width+AY.width+AZ.width+3}, width = math.max(info.traits.width,info.preferences.width,info.values.width), height = info.traits.height+info.preferences.height+info.values.height+5}
 X_width = math.max(AX.width,BX.width,CX.width)
 Y_width = math.max(AY.width,BY.width,CY.width)
 Z_width = math.max(AZ.width,BZ.width)
 AY.anchor.left = X_width+1
 AZ.anchor.left = X_width+Y_width+2
 BY.anchor.left = X_width+1
 BZ.anchor.left = X_width+Y_width+2
 CY.anchor.left = X_width+1
-- Create frames
 self:addviews{
       widgets.Panel{
	   view_id = 'main',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
        widgets.List{
		 view_id = 'AX',
         frame = { l = AX.anchor.left, t = AX.anchor.top, w = X_width, h = AX.height},
                },
		widgets.List{
		 view_id = 'AY',
         frame = { l = AY.anchor.left, t = AY.anchor.top, w = Y_width, h = AY.height},
                },          
		widgets.List{
		 view_id = 'AZ',
         frame = { l = AZ.anchor.left, t = AZ.anchor.top, w = Z_width, h = AZ.height},
                },
		widgets.List{
		 view_id = 'BX',
         frame = { l = BX.anchor.left, t = BX.anchor.top, w = X_width, h = BX.height},
                },
		widgets.List{
		 view_id = 'CX',
         frame = { l = CX.anchor.left, t = CX.anchor.top, w = X_width, h = CX.height},
                },
		widgets.List{
		 view_id = 'BZ',
         frame = { l = BZ.anchor.left, t = BZ.anchor.top, w = Z_width, h = BZ.height},
                },
		widgets.List{
		 view_id = 'CZ',
         frame = { l = CZ.anchor.left, t = CZ.anchor.top, w = CZ.width, h = CZ.height},
                },
		widgets.List{
		 view_id = 'CY',
         frame = {  l = CY.anchor.left, t = CY.anchor.top, w = Y_width, h = CY.height},
                },
        widgets.List{
         view_id = 'BY',
         frame = { l = BY.anchor.left, t = BY.anchor.top, w = Y_width, h = BY.height},
                },
		widgets.Label{
                    view_id = 'bottom_ui',
                    frame = { b = 0, h = 1 },
                    text = 'filled by updateBottom()'
                }
            }
		}
	}   
 self:addviews{widgets.Panel{view_id = 'attributeView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
	   	widgets.List{
		 view_id = 'attributeViewDetailed',
         frame = { l = 0, t = 0},
                },
		    }
        }
    }
 self:addviews{widgets.Panel{view_id = 'classView2',
       frame = { l = 71, r = 0},
       frame_inset = 1,
       subviews = {
        widgets.List{
		 view_id = 'classViewDetailedDetails1',
         frame = { l = 0, t = 0},
                },
        widgets.List{
		 view_id = 'classViewDetailedDetails2',
         frame = { l = 40, t = 2},
                }
            }
        },
       widgets.Panel{
	   view_id = 'classView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
       	widgets.List{
		 view_id = 'classViewDetailedTop',
         frame = { l = 0, t = 0},
                },
	   	widgets.List{
		 view_id = 'classViewDetailedClasses',
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         frame = { l = 0, t = 3},
                },
		    }
        }
    }
    --[[
 self:addviews{widgets.Panel{view_id = 'equipmentView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
    ]]
    --[[
 self:addviews{widgets.Panel{view_id = 'healthView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
    ]]
    --[[
 self:addviews{widgets.Panel{view_id = 'interactionView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
    ]]
    --[[
 self:addviews{widgets.Panel{view_id = 'spellbookView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }]]
    --[[
 self:addviews{widgets.Panel{view_id = 'legendsView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }]]
    --[[
 self:addviews{widgets.Panel{view_id = 'relationshipView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }]]
 self:addviews{widgets.Panel{view_id = 'syndromeView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
	   	widgets.List{
		 view_id = 'syndromeViewDetailed',
         frame = { l = 0, t = 0},
                },
		    }
        }
    }

 self.subviews.attributeView.visible = false
 self.subviews.classView.visible = false
 self.subviews.classView2.visible = false
 --[[
 self.subviews.equipmentView.visible = false
 self.subviews.healthView.visible = false
 self.subviews.interactionView.visible = false
 self.subviews.legendsView.visible = false
 self.subviews.spellbookView.visible = false
 self.subviews.relationshipView.visible = false
 ]]
 self.subviews.syndromeView.visible = false

 self.subviews.main.visible = true
 self:fillMain(full_name,caste,entity,civilization,membership,skills,info)
 self:detailsAttributes(p_attributes,m_attributes)
 self:detailsClasses()
 self:detailsSyndromes(syndromes,syndromes_detail)
 self:updateBottom()
end

function UnitViewUi:updateBottom()
    self.subviews.bottom_ui:setText(
        {
            { key = 'CUSTOM_SHIFT_A', text = ': Attribute Information  ', on_activate = self:callback('attributeView') }, 
            { key = 'CUSTOM_SHIFT_C', text = ': Class Information  ', on_activate = self:callback('classView') }, 
--            { key = 'CUSTOM_SHIFT_E', text = ': Equipment List  ', on_activate = self:callback('equipmentView') }, 
--            { key = 'CUSTOM_SHIFT_H', text = ': Health Information  ', on_activate = self:callback('healthView') }, 
--            NEWLINE,
--            { key = 'CUSTOM_SHIFT_I', text = ': Interaction Information  ', on_activate = self:callback('interactionView') }, 
--            { key = 'CUSTOM_SHIFT_L', text = ': Legends  ', on_activate = self:callback('legendsView') }, 
--            { key = 'CUSTOM_SHIFT_P', text = ': Spellbook  ', on_activate = self:callback('spellbookView') },
--            { key = 'CUSTOM_SHIFT_R', text = ': Relationship Information  ', on_activate = self:callback('relationshipView') }, 
            { key = 'CUSTOM_SHIFT_S', text = ': Syndrome Information  ', on_activate = self:callback('syndromeView') }
        })
end
function UnitViewUi:attributeView()
 self.subviews.attributeView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:classView()
 self.subviews.classView.visible = true
 self.subviews.classView2.visible = true
 self.subviews.main.visible = false
end
--[[function UnitViewUi:equipmentView()
 self.subviews.equipmentView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:healthView()
-- self.subviews.healthView.visible = true
-- self.subviews.main.visible = false
 local temp_screen = df.viewscreen_unitst:new()
 temp_screen.unit = target
 gui.simulateInput(temp_screen,'UNITVIEW_HEALTH')
end
function UnitViewUi:interactionView()
 self.subviews.interactionView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:legendsView()
-- self.subviews.legendsView.visible = true
-- self.subviews.main.visible = false
 local temp_screen = df.viewscreen_unitst:new()
 temp_screen.unit = target
 gui.simulateInput(temp_screen,'UNITVIEW_KILLS')
end
function UnitViewUi:spellbookView()
 self.subviews.spellbookView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:relationshipView()
-- self.subviews.relationshipView.visible = true
-- self.subviews.main.visible = false
 local temp_screen = df.viewscreen_unitst:new()
 temp_screen.unit = target
 gui.simulateInput(temp_screen,'UNITVIEW_RELATIONSHIPS')
end]]
function UnitViewUi:syndromeView()
 self.subviews.syndromeView.visible = true
 self.subviews.main.visible = false
end

function UnitViewUi:fillMain(name,caste,entity,civ,mem,skills,info)
--AX
 local insert = {}
 local w_frame = self.subviews.AX.frame.w
 insert = guiFunctions.insertWidgetInput(insert,'header',{header='Name',second=name},{width=w_frame})
 insert = guiFunctions.insertWidgetInput(insert,'header',{header='Caste',second=caste},{width=w_frame})
 insert = guiFunctions.insertWidgetInput(insert,'header',{header='Entity',second=entity},{width=w_frame})
 insert = guiFunctions.insertWidgetInput(insert,'header',{header='Civilization',second=civ},{width=w_frame})
 insert = guiFunctions.insertWidgetInput(insert,'header',{header='Membership',second=mem},{width=w_frame})
 local list = self.subviews.AX
 list:setChoices(insert)
--AY
 local insert = {}
 local w_frame = self.subviews.AY.frame.w
 table.insert(insert,{text = {{text = center('Description',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.description.text,{width=w_frame})
 local list = self.subviews.AY
 list:setChoices(insert)
--AZ
 local insert = {}
 local w_frame = self.subviews.AZ.frame.w
 table.insert(insert,{text = {{text = center('Basic Health',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.wounds.text,{width=w_frame})
 local list = self.subviews.AZ
 list:setChoices(insert)
--BX
 local insert = {}
 local w_frame = self.subviews.BX.frame.w
 table.insert(insert,{text = {{text = center('Membership and Worship',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.membership.text,{width=w_frame})
 table.insert(insert,{text={{text='',width=w_frame}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.worship.text,{width=w_frame})
 local list = self.subviews.BX
 list:setChoices(insert)
--BY
 local insert = {}
 local w_frame = self.subviews.BY.frame.w
 table.insert(insert,{text = { {text = center('Appearance',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.appearance.text,{width=w_frame})
 local list = self.subviews.BY
 list:setChoices(insert)
--BZ
 local insert = {}
 local w_frame = self.subviews.BZ.frame.w
 table.insert(insert,{text = { {text = center('Thoughts',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.thoughts.text,{width=w_frame})
 local list = self.subviews.BZ
 list:setChoices(insert)
--CX
 local insert = {}
 local w_frame = self.subviews.CX.frame.w
 table.insert(insert,{text = { {text = center('Skills',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 for key,val in pairs(skills) do
  insert = guiFunctions.insertWidgetInput(insert,'header',{header=key,second=tostring(val.level)..' '..tostring(val.experience)},{width=w_frame})
 end
 local list = self.subviews.CX
 list:setChoices(insert)
--CY
 local insert = {}
 local w_frame = self.subviews.CY.frame.w
 table.insert(insert,{text = { {text = center('Attributes',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.attributes1.text,{width=w_frame})
 table.insert(insert,{text={{text='',width=w_frame}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.attributes2.text,{width=w_frame})
 local list = self.subviews.CY
 list:setChoices(insert)
--CZ
 local insert = {}
 local w_frame = self.subviews.CZ.frame.w
 table.insert(insert,{text = { {text = center('Traits and Preferences',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.traits.text,{width=w_frame})
 table.insert(insert,{text={{text='',width=w_frame}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.preferences.text,{width=w_frame})
 table.insert(insert,{text={{text='',width=w_frame}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.values.text,{width=w_frame})
 local list = self.subviews.CZ
 list:setChoices(insert)
end

function UnitViewUi:detailsAttributes(p_attributes,m_attributes)
 attributes = {}
 a_len = 19
 n_len = 5
 table.insert(attributes, {text = {{text=center('Attributes',57), width = attribute_len,pen=COLOR_LIGHTCYAN}}})
 table.insert(attributes, {text = {{text=center('Physical',57), width = attribute_len,pen=COLOR_LIGHTMAGENTA}}})
 table.insert(attributes, {text = {
                                   {text=center('',19),width=19},
                                   {text='Current',rjustify=true,width=9,pen=COLOR_WHITE},
                                   {text='Class',rjustify=true,width=7,pen=COLOR_WHITE},
                                   {text='Item',rjustify=true,width=6,pen=COLOR_WHITE},
                                   {text='Syndrome',rjustify=true,width=10,pen=COLOR_WHITE},
                                   {text='Base',rjustify=true,width=6,pen=COLOR_WHITE}
                                  }})
 ttt = 0
 for i,x in pairs(p_attributes) do
  if ttt == 1 then
   if p_attributes[i]['Current'] >= p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif p_attributes[i]['Current'] < p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 0
  elseif ttt == 0 then
   if p_attributes[i]['Current'] >= p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif p_attributes[i]['Current'] < p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 1
  end
  table.insert(attributes, {text = {
	                                {text = i, width = a_len,pen = fgc},
		                            {text = tostring(p_attributes[i]['Current']), rjustify=true,width=9,pen = fgc},
                                    {text = tostring(p_attributes[i]['Class']), rjustify=true,width=7,pen = fgc},
                                    {text = tostring(p_attributes[i]['Item']), rjustify=true,width=6,pen = fgc},
                                    {text = tostring(p_attributes[i]['Syndrome']), rjustify=true,width=10,pen = fgc},
                                    {text = tostring(p_attributes[i]['Base']), rjustify=true,width=6,pen = fgc}
                                   }})
 end
 table.insert(attributes, {text = {{text=center('Mental',57), width = attribute_len,pen=COLOR_LIGHTMAGENTA}}})
 table.insert(attributes, {text = {
                                   {text=center('',19),width=19},
                                   {text='Current',rjustify=true,width=9,pen=COLOR_WHITE},
                                   {text='Class',rjustify=true,width=7,pen=COLOR_WHITE},
                                   {text='Item',rjustify=true,width=6,pen=COLOR_WHITE},
                                   {text='Syndrome',rjustify=true,width=10,pen=COLOR_WHITE},
                                   {text='Base',rjustify=true,width=6,pen=COLOR_WHITE}
                                  }})
 ttt = 0
 for i,x in pairs(m_attributes) do
  if ttt == 1 then
   if m_attributes[i]['Current'] >= m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif m_attributes[i]['Current'] < m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 0
  elseif ttt == 0 then
   if m_attributes[i]['Current'] >= m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif m_attributes[i]['Current'] < m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 1
  end
  table.insert(attributes, {text = {
	                                {text = i, width = a_len,pen = fgc},
		                            {text = tostring(m_attributes[i]['Current']), rjustify=true,width=9,pen = fgc},
                                    {text = tostring(m_attributes[i]['Class']), rjustify=true,width=7,pen = fgc},
                                    {text = tostring(m_attributes[i]['Item']), rjustify=true,width=6,pen = fgc},
                                    {text = tostring(m_attributes[i]['Syndrome']), rjustify=true,width=10,pen = fgc},
                                    {text = tostring(m_attributes[i]['Base']), rjustify=true,width=6,pen = fgc}
                                   }})
 end
 local list = self.subviews.attributeViewDetailed
 list:setChoices(attributes)
end

function UnitViewUi:detailsClasses()
 tar = self.target
 input = {}
 in2 = {}
 table.insert(in2,{text = {{text=center('Classes',60),width=60,pen=COLOR_LIGHTCYAN}}})
 table.insert(in2,{text = {
                             {text='Class',width=41,pen=COLOR_LIGHTMAGENTA},
                             {text='Level',width=7,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                             {text='Experience',width=12,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                            }})
 local persistTable = require 'persist-table'
 if persistTable.GlobalTable.roses then
  if persistTable.GlobalTable.roses.ClassTable then
   classTable = persistTable.GlobalTable.roses.ClassTable
   unitTable = persistTable.GlobalTable.roses.UnitTable
   if not unitTable[tostring(tar.id)] then
    dfhack.script_environment('functions/tables').makeUnitTable(tar.id)
   end
   unitClasses = unitTable[tostring(tar.id)].Classes
   for i,x in pairs(classTable._children) do
    if unitClasses[x] then
     table.insert(input,{text = {
                                {text=classTable[x].Name,width=41},
                                {text=tostring(unitClasses[x].Level),width=7,rjustify=true},
                                {text=tostring(unitClasses[x].Experience),width=12,rjustify=true},
                                }})
    else
     table.insert(input,{text = {
                                {text=classTable[x].Name,width=41},
                                {text='0',width=7,rjustify=true},
                                {text='0',width=12,rjustify=true},
                                }})  
    end
   end
  else
   table.insert(in2,{text = {{text='No Class Table Loaded',width=22,pen=COLOR_WHITE}}})
  end
 else
  table.insert(in2,{text = {{text='No Class Table Loaded',width=22,pen=COLOR_WHITE}}})
 end 
 local list = self.subviews.classViewDetailedClasses
 list:setChoices(input)
 local list = self.subviews.classViewDetailedTop
 list:setChoices(in2)
end

function UnitViewUi:detailsSyndromes(syndromes,details)
 detail = {}
 table.insert(detail, {
     text = {
	     {text=center('Active Syndromes',20), pen=COLOR_LIGHTCYAN},
		 {text=center('Start',6), pen=COLOR_LIGHTCYAN},
		 {text=center('Peak',6), pen=COLOR_LIGHTCYAN},
		 {text=center('Severity',10), pen=COLOR_LIGHTCYAN},
		 {text=center('End',6), pen=COLOR_LIGHTCYAN},
		 {text=center('Duration',10), pen=COLOR_LIGHTCYAN}
     }
   })
 for i,x in pairs(syndromes) do
  table.insert(detail, {
      text = {
	      {text = x[1],width = 20,pen=fgc}
      }
  })
  for j,y in pairs(details[i]) do
   if pcall(function() return y.sev end) then
    severity = y.sev
   else
    severity = 'NA'
   end
   effect = split(split(tostring(y._type),'creature_interaction_effect_')[2],'st>')[1]:gsub("(%a)([%w_']*)", tchelper)
   if y['end'] == -1 then
    ending = 'Permanent'
	duration = x[3]
   else
    ending = y['end']
    duration = x[3]
   end
   if y.start-x[3] <0 then
--    starting = 0
	startcolor = COLOR_LIGHTGREEN
   else
--    starting = y.start-x[3]
	startcolor = COLOR_LIGHTRED
   end
   if y.peak-x[3] <0 then
--    starting = 0
	peakcolor = COLOR_LIGHTGREEN
   else
--    starting = y.peak-x[3]
	peakcolor = COLOR_LIGHTRED
   end
   if y['end']-x[3] <0 then
	endcolor = COLOR_LIGHTGREEN
   else
	endcolor = COLOR_LIGHTRED
   end
   table.insert(detail, {
       text = {
	       {text = "    "..effect, width = 20,pen=COLOR_WHITE},
		   {text = y.start, rjustify=true,width = 6,pen=startcolor},
		   {text = y.peak, rjustify=true,width = 6,pen=peakcolor},
		   {text = severity, rjustify=true,width = 10,pen=COLOR_WHITE},
		   {text = ending, rjustify=true,width = 6,pen=endcolor},
		   {text = duration, rjustify=true,width = 10,pen=COLOR_WHITE}
           
       }
   })
  end
 end
 local list = self.subviews.syndromeViewDetailed
 list:setChoices(detail)
end

function UnitViewUi:onInput(keys)
 if keys.LEAVESCREEN then
--[[  if self.subviews.interactionView.visible then
   self.subviews.interactionView.visible = false
   self.subviews.main.visible = true]]
  if self.subviews.syndromeView.visible then
   self.subviews.syndromeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.attributeView.visible then
   self.subviews.attributeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.classView.visible then
   self.subviews.classView.visible = false
   self.subviews.classView2.visible = false
   self.subviews.main.visible = true
--[[  elseif self.subviews.equipmentView then
   self.subviews.equipmentView = false
   self.subviews.main.visible = true
  elseif self.subviews.interactionView.visible then
   self.subviews.interactionView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.syndromeView.visible then
   self.subviews.syndromeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.spellbookView.visible then
   self.subviews.spellbookView.visible = false
   self.subviews.main.visible = true]]  
  else
   self:dismiss()
  end
 else
  UnitViewUi.super.onInput(self, keys)
 end
end

function show_editor(trg)
 local screen = UnitViewUi{target=trg}
 screen:show()
end

show_editor(getTargetFromScreens())