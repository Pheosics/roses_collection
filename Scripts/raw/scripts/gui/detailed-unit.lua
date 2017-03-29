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
 test_length = 40
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
A   Caste              | Description    |                |
    Civilization       |                |                |
-----------------------|----------------|----------------|
B   Membership/Worship | Appearance     |                |
-----------------------|----------------|----------------|
C   Skills             | Attribute Desc |                |
----------------------------------------------------------
Bottom UI
]]
 AX = {anchor = {top = 0, left = 0}, width = test_length, height = 6}
 AY = {anchor = {top = 0, left = 0}, width = info.description.width, height = info.description.height+1}
 AZ = {anchor = {top = 0, left = 0}, width = 0, height = 0}
 BX = {anchor = {top = AX.height+1, left = 0}, width = math.max(info.membership.width,info.worship.width), height = info.membership.height+info.worship.height+3}
 BY = {anchor = {top = AY.height+1, left = 0}, width = info.appearance.width, height = info.appearance.height+1}
 BZ = {anchor = {top = AZ.height+1, left = 0}, width = 0, height = 0}
 CX = {anchor = {top = AX.height+BX.height+2, left = 0}, width = skillinfo.width, height = skillinfo.height+1}
 CY = {anchor = {top = AY.height+BY.height+2, left = 0}, width = math.max(info.attributes1.width,info.attributes2.width), height = info.attributes1.height+info.attributes2.height+3}
 CZ = {anchor = {top = 0, left = AX.width+AY.width+AZ.width+3}, width = 0, height = 0}
 X_width = math.max(AX.width,BX.width,CX.width)
 Y_width = math.max(AY.width,BY.width,CY.width)
 Z_width = math.max(AZ.width,BZ.width)
 AY.anchor.left = X_width+4
 AZ.anchor.left = X_width+Y_width+8
 BY.anchor.left = X_width+4
 BZ.anchor.left = X_width+Y_width+8
 CY.anchor.left = X_width+4
 
-- Create frames
 self:addviews{widgets.Panel{view_id = 'main',
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
 self:addviews{widgets.Panel{view_id = 'thoughtsView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
	   	widgets.List{
		 view_id = 'thoughtsViewDetailed',
         frame = { l = 0, t = 0},
                },
        widgets.List{
		 view_id = 'thoughtsViewDetailed2',
         frame = { l = 45, t = 0},
                }
		    }
        }
    }
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
 self:addviews{widgets.Panel{view_id = 'classView2',
       frame = { l = 51, r = 0},
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
         on_select = self:callback('checkClass'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         frame = { l = 0, t = 3},
                },
		    }
        }
    }

 self.subviews.attributeView.visible = false
 self.subviews.classView.visible = false
 self.subviews.classView2.visible = false
 self.subviews.syndromeView.visible = false
 self.subviews.thoughtsView.visible = false
 self.subviews.main.visible = true
 
 self:fillMain(full_name,caste,entity,civilization,membership,skills,info)
 self:detailsAttributes(p_attributes,m_attributes)
 self:detailsClasses()
 self:detailsSyndromes(syndromes,syndromes_detail)
 self:detailsThoughts(info)
 self:updateBottom()
end

function UnitViewUi:updateBottom()
 
    self.subviews.bottom_ui:setText(
        {
            { key = 'CUSTOM_SHIFT_A', text = ': Attribute Information  ', on_activate = self:callback('attributeView') }, 
            { key = 'CUSTOM_SHIFT_C', text = ': Class Information  ', on_activate = self:callback('classView') }, 
            { key = 'CUSTOM_SHIFT_S', text = ': Syndrome Information  ', on_activate = self:callback('syndromeView') },
            { key = 'CUSTOM_SHIFT_T', text = ': Thoughts and Preferences  ', on_activate = self:callback('thoughtsView') }
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
function UnitViewUi:syndromeView()
 self.subviews.syndromeView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:thoughtsView()
 self.subviews.thoughtsView.visible = true
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
 table.insert(in2,{text = {{text=center('Classes',40),width=30,pen=COLOR_LIGHTCYAN}}})
 table.insert(in2,{text = {
                             {text='Class',width=21,pen=COLOR_LIGHTMAGENTA},
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
                                {text=classTable[x].Name,width=21},
                                {text=tostring(unitClasses[x].Level),width=7,rjustify=true},
                                {text=tostring(unitClasses[x].Experience),width=12,rjustify=true},
                                }})
    else
     table.insert(input,{text = {
                                {text=classTable[x].Name,width=21},
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

function UnitViewUi:checkClass(index,choice)
 if not choice then return end
 input = {}
 target = self.target
 local name = choice.text[1].text
 local persistTable = require 'persist-table'
 local classTable = persistTable.GlobalTable.roses.ClassTable
 local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(target.id)].Classes
 local unitSpells  = persistTable.GlobalTable.roses.UnitTable[tostring(target.id)].Spells
 for _,x in pairs(classTable._children) do
  if classTable[x].Name == name then
   class = x
   break
  end
 end
 local currentClass = unitClasses.Current.Name
 if currentClass == 'NONE' then
  currentName = 'None'
 else
  currentName = classTable[currentClass].Name
 end
 for _,x in pairs(classTable._children) do
  if classTable[x].Name == unitClasses.Current.Name then
   currentClass = x
   break
  end
 end
 if not class then return end
 table.insert(input,{text = {{text='Current Class = '..currentName,width=20,pen=COLOR_WHITE}}})
 table.insert(input,{text = {{text=center(name,40),width=30,pen=COLOR_LIGHTCYAN}}})
 table.insert(input,{text = {{text='Requirements:',width=20,pen=COLOR_LIGHTMAGENTA}}})
 
 table.insert(input,{text = {{text='Classes:',width=30,pen=COLOR_YELLOW}}})
 local test = true
 if safe_index(classTable,class,"RequiredClass") then
  for _,x in pairs(classTable[class].RequiredClass._children) do
   local check = unitClasses[x].Level
   local level = classTable[class].RequiredClass[x]
   if tonumber(check) < tonumber(level) then
    fgc = COLOR_LIGHTRED
   else
    fgc = COLOR_LIGHTGREEN
   end
   table.insert(input,{text = {{text='Level '..classTable[class].RequiredClass[x]..' '..classTable[x].Name,width=30,rjustify=true,pen=fgc}}})
   test = false
  end
 end
 if test then table.insert(input,{text = {{text='None',width=30,rjustify=true,pen=COLOR_LIGHTGREEN}}}) end
 
 table.insert(input,{text = {{text='Attributes:',width=30,pen=COLOR_YELLOW}}})
 local test = true
 if safe_index(classTable,class,"RequiredAttribute") then
  for _,x in pairs(classTable[class].RequiredAttribute._children) do
   local total,base,change,classval,syndrome = dfhack.script_environment('functions/unit').getUnit(target,'Attributes',x)
   local check = total-change-classval-syndrome
   local value = classTable[class].RequiredAttribute[x]
   if tonumber(check) < tonumber(value) then
    fgc = COLOR_LIGHTRED
   else
    fgc = COLOR_LIGHTGREEN
   end
   table.insert(input,{text = {{text=classTable[class].RequiredAttribute[x]..' '..x,width=30,rjustify=true,pen=fgc}}})
   test = false
  end
 end
 if test then table.insert(input,{text = {{text='None',width=30,rjustify=true,pen=COLOR_LIGHTGREEN}}}) end
 
 table.insert(input,{text = {{text='Skills:',width=30,pen=COLOR_YELLOW}}})
 local test = true
 if safe_index(classTable,class,"RequiredSkill") then
  for _,x in pairs(classTable[class].RequiredSkill._children) do
   local total,base,change,classval,syndrome = dfhack.script_environment('functions/unit').getUnit(target,'Skills',x)
   local check = total-change-classval-syndrome
   local value = classTable[class].RequiredSkill[x]
   if tonumber(check) < tonumber(value) then
    fgc = COLOR_LIGHTRED
   else
    fgc = COLOR_LIGHTGREEN
   end
   table.insert(input,{text = {{text='Level '..classTable[class].RequiredSkill[x]..' '..x,width=30,rjustify=true,pen=fgc}}})
   test = false
  end
 end
 if test then table.insert(input,{text = {{text='None',width=30,rjustify=true,pen=COLOR_LIGHTGREEN}}}) end
 
 table.insert(input,{text = {{text='Traits:',width=30,pen=COLOR_YELLOW}}})
 local test = true
 if safe_index(classTable,class,"RequiredTrait") then
  for _,x in pairs(classTable[class].RequiredTrait._children) do
   local total,base,change,classval,syndrome = dfhack.script_environment('functions/unit').getUnit(target,'Traits',x)
   local check = total-change-classval-syndrome
   local value = classTable[class].RequiredTrait[x]
   if tonumber(check) < tonumber(value) then
    fgc = COLOR_LIGHTRED
   else
    fgc = COLOR_LIGHTGREEN
   end
   table.insert(input,{text = {{text=classTable[class].RequiredTrait[x]..' '..x,width=30,rjustify=true,pen=fgc}}})
   test = false
  end
 end
 if test then table.insert(input,{text = {{text='None',width=30,rjustify=true,pen=COLOR_LIGHTGREEN}}}) end
 
 table.insert(input,{text = {{text='',width=30,pen=COLOR_WHITE}}})
 table.insert(input,{text = {{text='Attribute Changes:',width=30,pen=COLOR_LIGHTMAGENTA}}})
 local test = true
 if safe_index(classTable,class,"BonusAttribute") then
  current = {}
  if currentClass and safe_index(classTable,currentClass,"BonusAttribute") then
   for _,x in pairs(classTable[currentClass].BonusAttribute._children) do
    current[x] = classTable[currentClass].BonusAttribute[x][tostring(unitClasses[currentClass].Level+1)]
   end
  end
  nextto = {}
  for _,x in pairs(classTable[class].BonusAttribute._children) do
   if unitClasses[class] then
    level = tostring(unitClasses[class].Level+1)
   else
    level = '1'
   end
   nextto[x] = classTable[class].BonusAttribute[x][level]
  end
  new = {}
  for str,val in pairs(current) do
   new[str] = -tonumber(val)
  end
  for str,val in pairs(nextto) do
   if new[str] then
    new[str] = new[str] + tonumber(val)
   else
    new[str] = tonumber(val)
   end
  end
  for str,val in pairs(new) do
   if val > 0 then 
    fgc = COLOR_LIGHTGREEN
    val = '+'..tostring(val)
   elseif val < 0 then 
    fgc = COLOR_LIGHTRED
    val = tostring(val)
   elseif val == 0 then 
    fgc = COLOR_WHITE 
    val = tostring(val)
   end
   table.insert(input,{text = {
                              {text=str,width=20,pen=fgc},
                              {text=val,width=10,rjustify=true,pen=fgc}
                              }})
   test = false
  end
 end
 if test then table.insert(input,{text = {{text='None',width=30,rjustify=true,pen=COLOR_WHITE}}}) end
 
 table.insert(input,{text = {{text='Skill Changes:',width=30,pen=COLOR_LIGHTMAGENTA}}})
 local test = true
 if safe_index(classTable,class,"BonusSkill") then
  current = {}
  if currentClass and safe_index(classTable,currentClass,"BonusSkill") then
   for _,x in pairs(classTable[currentClass].BonusSkill._children) do
    current[x] = classTable[currentClass].BonusSkill[x][tostring(unitClasses[currentClass].Level+1)]
   end
  end
  nextto = {}
  for _,x in pairs(classTable[class].BonusSkill._children) do
   if unitClasses[class] then
    level = tostring(unitClasses[class].Level+1)
   else
    level = '1'
   end
   nextto[x] = classTable[class].BonusSkill[x][level]
  end
  new = {}
  for str,val in pairs(current) do
   new[str] = -tonumber(val)
  end
  for str,val in pairs(nextto) do
   if new[str] then
    new[str] = new[str] + tonumber(val)
   else
    new[str] = tonumber(val)
   end
  end
  for str,val in pairs(new) do
   if val > 0 then 
    fgc = COLOR_LIGHTGREEN
    val = '+'..tostring(val)
   elseif val < 0 then 
    fgc = COLOR_LIGHTRED
    val = tostring(val)
   elseif val == 0 then 
    fgc = COLOR_WHITE 
    val = tostring(val)
   end
   table.insert(input,{text = {
                              {text=str,width=20,pen=fgc},
                              {text=val,width=10,rjustify=true,pen=fgc}
                              }})
   test = false
  end
 end
 if test then table.insert(input,{text = {{text='None',width=30,rjustify=true,pen=COLOR_WHITE}}}) end 
 
 table.insert(input,{text = {{text='Trait Changes:',width=30,pen=COLOR_LIGHTMAGENTA}}})
 local test = true
 if safe_index(classTable,class,"BonusTrait") then
  current = {}
  if currentClass and safe_index(classTable,currentClass,"BonusTrait") then
   for _,x in pairs(classTable[currentClass].BonusTrait._children) do
    current[x] = classTable[currentClass].BonusTrait[x][tostring(unitClasses[currentClass].Level+1)]
   end
  end
  nextto = {}
  for _,x in pairs(classTable[class].BonusTrait._children) do
   if unitClasses[class] then
    level = tostring(unitClasses[class].Level+1)
   else
    level = '1'
   end
   nextto[x] = classTable[class].BonusTrait[x][level]
  end
  new = {}
  for str,val in pairs(current) do
   new[str] = -tonumber(val)
  end
  for str,val in pairs(nextto) do
   if new[str] then
    new[str] = new[str] + tonumber(val)
   else
    new[str] = tonumber(val)
   end
  end
  for str,val in pairs(new) do
   if val > 0 then 
    fgc = COLOR_LIGHTGREEN
    val = '+'..tostring(val)
   elseif val < 0 then 
    fgc = COLOR_LIGHTRED
    val = tostring(val)
   elseif val == 0 then 
    fgc = COLOR_WHITE 
    val = tostring(val)
   end
   table.insert(input,{text = {
                              {text=str,width=20,pen=fgc},
                              {text=val,width=10,rjustify=true,pen=fgc}
                              }})
   test = false
  end
 end
 if test then table.insert(input,{text = {{text='None',width=30,rjustify=true,pen=COLOR_WHITE}}}) end
 
 input2 = {}
 table.insert(input2,{text = {{text='Leveling Bonuses:',width=30,pen=COLOR_LIGHTMAGENTA}}})
 table.insert(input2,{text = {{text='Attributes:',width=30,pen=COLOR_YELLOW}}})
 test = true
 if safe_index(classTable,class,"LevelBonus","Attribute") then
  if unitClasses[class] then
   level = tostring(unitClasses[class].Level+1)
  else
   level = '1'
  end
  for _,x in pairs(classTable[class].LevelBonus.Attribute._children) do
   table.insert(input2,{text = {
                               {text=x,width=20,pen=COLOR_WHITE},
                               {text=classTable[class].LevelBonus.Attribute[x][level],width=10,rjustify=true,pen=COLOR_WHITE}
                               }})
   test=false
  end
 end
 if test then table.insert(input2,{text = {{text='None',width=30,rjustify=true,pen=COLOR_WHITE}}}) end
 
 table.insert(input2,{text = {{text='Skills:',width=30,pen=COLOR_YELLOW}}})
 test = true
 if safe_index(classTable,class,"LevelBonus","Skill") then
  if unitClasses[class] then
   level = tostring(unitClasses[class].Level+1)
  else
   level = '1'
  end
  for _,x in pairs(classTable[class].LevelBonus.Skill._children) do
   table.insert(input2,{text = {
                               {text=x,width=20,pen=COLOR_WHITE},
                               {text=classTable[class].LevelBonus.Skill[x][level],width=10,rjustify=true,pen=COLOR_WHITE}
                               }})
   test=false
  end
 end
 if test then table.insert(input2,{text = {{text='None',width=30,rjustify=true,pen=COLOR_WHITE}}}) end
 
 table.insert(input2,{text = {{text='Traits:',width=30,pen=COLOR_YELLOW}}})
 test = true
 if safe_index(classTable,class,"LevelBonus","Trait") then
  if unitClasses[class] then
   level = tostring(unitClasses[class].Level+1)
  else
   level = '1'
  end
  for _,x in pairs(classTable[class].LevelBonus.Trait._children) do
   table.insert(input2,{text = {
                               {text=x,width=20,pen=COLOR_WHITE},
                               {text=classTable[class].LevelBonus.Trait[x][level],width=10,rjustify=true,pen=COLOR_WHITE}
                               }})
   test=false
  end
 end
 if test then table.insert(input2,{text = {{text='None',width=30,rjustify=true,pen=COLOR_WHITE}}}) end
 
 table.insert(input,{text = {{text='',width=30,pen=COLOR_WHITE}}})
 table.insert(input2,{text = {{text='Spells and Abilities:',width=30,pen=COLOR_LIGHTMAGENTA}}})
 test = true
 if safe_index(classTable,class,"Spells") then
  for _,x in pairs(classTable[class].Spells._children) do
   if unitSpells[x] == '1' then
    fgc = COLOR_WHITE
   else
    fgc = COLOR_GREY
   end
   if persistTable.GlobalTable.roses.SpellTable[x] then
    name = persistTable.GlobalTable.roses.SpellTable[x].Name
   else
    name = 'Unknown'
   end
   table.insert(input2,{text = {{text=name,width=30,pen=fgc}}})
   test = false
  end
 end
 if test then table.insert(input2,{text = {{text='None',width=30,rjustify=true,pen=COLOR_WHITE}}}) end
 
 local list = self.subviews.classViewDetailedDetails1
 list:setChoices(input)
 local list2 = self.subviews.classViewDetailedDetails2
 list2:setChoices(input2)
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

function UnitViewUi:detailsThoughts(info)
 local insert = {}
 local w_frame = 40
 table.insert(insert,{text = { {text = center('Thoughts',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.thoughts.text,{width=w_frame})
 table.insert(insert,{text={{text='',width=w_frame}}})
 table.insert(insert,{text = { {text = center('Traits',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.traits.text,{width=w_frame})
 local list = self.subviews.thoughtsViewDetailed
 list:setChoices(insert)
 
 insert = {}
 table.insert(insert,{text = { {text = center('Preferences',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.preferences.text,{width=w_frame})
 table.insert(insert,{text={{text='',width=w_frame}}})
 table.insert(insert,{text = { {text = center('Values',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 insert = guiFunctions.insertWidgetInput(insert,'second',info.values.text,{width=w_frame})
 local list = self.subviews.thoughtsViewDetailed2
 list:setChoices(insert)
end

function UnitViewUi:onInput(keys)
 if keys.LEAVESCREEN then
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
  elseif self.subviews.thoughtsView.visible then
   self.subviews.thoughtsView.visible = false
   self.subviews.main.visible = true
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