local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'
local guiFunctions = dfhack.script_environment('functions/gui')
local outputFunction = guiFunctions.getJournalOutput
local infoFunction   = guiFunctions.getJournalInfo
local textC     = COLOR_WHITE
local cursorC   = COLOR_LIGHTRED
local inactiveC = COLOR_CYAN
local ckeys = {'A','B','C','D','E','F','G','H','I','J','K'}
local extraScripts = {'librarian'}

validArgs = utils.invert({
 'help',
 'viewScreen',
 'target1',
 'target2',
})
local args = utils.processArgs({...}, validArgs)

JournalUi = defclass(JournalUi, gui.FramedScreen)
JournalUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Journal and Compendium",
                 }

views = {'main','creatureView','buildingView','itemView','reactionView','materialView','entityView','plantView'}
ViewDetails = {
               ['main']         = {
                                   num_cols = 3, num_rows = 3, 
                                   widths   = {{40,40,40},{40,40,40},{40,40,40}},
                                   heights  = {{15,15,15},{15,15,15},{15,15,15}},
                                   fill     = {'Buildings','Creatures','Entities',
                                               'Items','Materials','Reactions',
                                               'Plants',nil,nil},
                                   functions = {{function () self:viewChange('buildingView') end,'B'},
                                                {function () self:viewChange('creatureView') end,'C'},
                                                {function () self:viewChange('entityView')   end,'E'},
                                                {function () self:viewChange('itemView')     end,'I'},
                                                {function () self:viewChange('materialView') end,'M'},
                                                {function () self:viewChange('reactionView') end,'R'},
                                                {function () self:viewChange('plantView')    end,'P'},
                                                nil,nil}},
               ['creatureView'] = {
                                   num_cols  = 3, num_rows = 1, levels = 2,
                                   widths    = {{30,30,60}},
                                   heights   = {{40,40,40}},
                                   fill      = {'CreatureList','on_submit','on_select'},
                                   on_fills  = {'on_submit','on_select','none'},
                                   on_submit = 'CasteList', on_select = 'CreatureDetails',
                                   start     = 'ALL',
                                   sortFlags = {'ALL','GOOD','EVIL','SAVAGE','CASTE_MEGABEAST'}}, --These are flags found in creature_raw.flags
               ['buildingView'] = {
                                   num_cols  = 3, num_rows = 1, levels = 2,
                                   widths    = {{30,60}},
                                   heights   = {{40,40,40}},
                                   fill      = {'BuildingTypeList','on_submit','on_select'},
                                   on_fills  = {'on_submit','on_select','none'},
                                   on_submit = 'BuildingList', on_select = 'BuildingDetails',
                                   start     = 'ALL',
                                   sortFlags = {'ALL'}}, -- Right now there are no filters for buildings
               ['itemView']     = {
                                   num_cols  = 3, num_rows = 1, levels = 2,
                                   widths    = {{30,30,60}},
                                   heights   = {{40,40,40}},
                                   fill      = {'ItemTypeList','on_submit','on_select'},
                                   on_fills  = {'on_submit','on_select','none'},
                                   on_submit = 'ItemList', on_select = 'ItemDetails',
                                   start     = 'ALL',
                                   sortFlags = {'ALL'}}, -- Right now there are no filters for items
               ['reactionView'] = {
                                   num_cols  = 3,
                                   num_rows  = 1,
                                   widths    = {{30,30,60}},
                                   heights   = {{40,40,40}},
                                   fill      = {'ReactionTypeList','on_submit','on_select'},
                                   on_fills  = {'on_submit','on_select','none'},
                                   on_submit = 'ReactionList', on_select = 'ReactionDetails',
                                   start     = 'All'},
               ['materialView'] = {
                                   num_cols  = 3,
                                   num_rows  = 1,
                                   widths    = {{30,30,60}},
                                   heights   = {{40,40,40}},
                                   fill      = {'MaterialTypeList','on_submit','on_select'},
                                   on_fills  = {'on_submit','on_select','none'},
                                   on_submit = 'MaterialList',
                                   on_select = 'MaterialDetails',
                                   start     = 'All'},
               ['entityView']   = {
                                   num_cols  = 3,
                                   num_rows  = 1,
                                   widths    = {{30,30,60}},
                                   heights   = {{40,40,40}},
                                   fill      = {'EntityTypeList','on_submit','on_select'},
                                   on_fills  = {'on_submit','on_select','none'},
                                   on_submit = 'EntityList',
                                   on_select = 'EntityDetails',
                                   start     = 'All'},
               ['plantView']    = {
                                   num_cols  = 3, num_rows = 1, levels = 2,
                                   widths    = {{30,30,60}},
                                   heights   = {{40,40,40}},
                                   fill      = {'PlantTypeList','on_submit','on_select'},
                                   on_fills  = {'on_submit','on_select','none'},
                                   on_submit = 'PlantList', on_select = 'PlantDetails',
                                   start     = 'ALL',
                                   sortFlags = {'ALL','EVIL','GOOD'}}, --These are flags found in plant_raws.flags
               
}

function JournalUi:init()
 self:checkActiveSystems()
 
 -- Set Starting values for information fill
 self.ViewDetails = ViewDetails
 self.ViewCheckValue = {}
 for _,v in pairs(views) do
  if self.ViewDetails[v].start then
   self.ViewCheckValue[v] = self.ViewDetails[v].start
  else
   self.ViewCheckValue[v] = false
  end
 end
 
 -- Get All Information
 self.AllInfo = infoFunction(self)
 
 -- Bottom UI
 self:addviews{
   widgets.Panel{
     view_id  = 'bottomView',
     frame    = { b = 0, h = 2},
     subviews = {
       widgets.Label{
         view_id = 'bottomHeader',
         frame   = { l = 0, t = 0},
         text    = 'Extras:'
       },
       widgets.Label{
         view_id = 'bottom_ui',
         frame   = { l = 0, t = 1},
         text    = 'filled by updateBottom()'
       }
     }
   }
 }
 self.subviews.bottomView.visible = true -- Alwayes true

 -- Create Frames
 for v,_ in pairs(self.ViewDetails) do
  if v == 'main' then -- Special Main frame
   self:addviews{
     widgets.Panel{
       view_id  = v,
       frame    = {l = 0, r = 0},
       subviews = {
         widgets.Label{
         view_id = 'main_1',
         frame = {t=10,l=10},
         text ={
                {text="Dwarf Fortress Journal and Compendium"}, NEWLINE,
                {text=": Buildings ", key = "CUSTOM_SHIFT_B", on_activate=function () self:viewChange('buildingView') end}, NEWLINE,
                {text=": Creatures ", key = "CUSTOM_SHIFT_C", on_activate=function () self:viewChange('creatureView') end}, NEWLINE,
                {text=": Items     ", key = "CUSTOM_SHIFT_I", on_activate=function () self:viewChange('itemView')     end}, NEWLINE,
                {text=": Materials ", key = "CUSTOM_SHIFT_M", on_activate=function () self:viewChange('materialView') end}, NEWLINE,
                {text=": Plants    ", key = "CUSTOM_SHIFT_P", on_activate=function () self:viewChange('plantView')    end}, NEWLINE,
                {text=": Reactions ", key = "CUSTOM_SHIFT_R", on_activate=function () self:viewChange('reactionView') end}
               }}}}}
  else
   self:addScreen(v)
  end
 end

 -- Fill Frames
 for v,_ in pairs(self.ViewDetails) do
  self:fillView(v)
 end
 
 if args.viewScreen then
  self:viewChange(args.viewScreen)
  self.ExternalCall = true
  slct = 1
  if args.target1 then
   a = self.subviews[args.viewScreen..'_1']:getChoices()
   for i,val in pairs(a) do
    if args.target1 == val.text[1].token then
     slct = i
     break
    end
   end
  end
  self.subviews[args.viewScreen..'_1']:setSelected(slct)
  self:onInput({['SELECT']=true})
  slct = 1
  if args.target2 then
   b = self.subviews[args.viewScreen..'_2']:getChoices()
   for i,val in pairs(b) do
    if args.target2 == split(val.text[1].token,':')[2] then
     slct = i
     break
    end
   end
  end
  self.subviews[args.viewScreen..'_2']:setSelected(slct)
 else
  self:viewChange('main')
  self.ExternalCall = false
 end
end

function JournalUi:checkActiveSystems()
 if persistTable.GlobalTable.roses then
  systems = persistTable.GlobalTable.roses.Systems
  if systems.Class            == 'true' then classSystem     = true end
  if systems.Feat             == 'true' then featSystem      = true end
  if systems.Spell            == 'true' then spellSystem     = true end
  if systems.Civilization     == 'true' then civSystem       = true end
  if systems.EnhancedItem     == 'true' then EItemSystem     = true end
  if systems.EnhancedCreature == 'true' then ECreatureSystem = true end
  if systems.EnhancedMaterial == 'true' then EMaterialSystem = true end
  if systems.EnhancedBuilding == 'true' then EBuildingSystem = true end
  if systems.EnhancedReaction == 'true' then EReactionSystem = true end
 end
 self.ClassSystem      = classSystem
 self.SpellSystem      = spellSystem
 self.FeatSystem       = featSystem
 self.CivSystem        = civSystem
 self.EnhancedItem     = EItemSystem
 self.EnhancedCreature = ECreatureSystem
 self.EnhancedMaterial = EMaterialSystem
 self.EnhancedBuilding = EBuildingSystem
 self.EnhancedReaction = EReactionSystem
end

--= Screen Functions (create the screens)
function JournalUi:addScreen(view_id)
 local grid = self:getPositioning(view_id)
 self:addviews{
   widgets.Panel{
     view_id     = view_id,
     frame       = { l = 0, r = 0 },
     frame_inset = 1,
     subviews    = grid
   }
 }
 self.subviews[view_id].CurrentLevel = 1
end

--= Positioning Functions (get the width, height, and anchor points for each screen)
function JournalUi:getPositioning(view_id)
 local v = self.ViewDetails[view_id]
 local temp = {}
 local cell = 1
 local row_pad = v.row_pads or 1
 local col_pad = v.col_pads or 4
 for i = 1, v.num_rows do
  for j = 1, v.num_cols do
   top = 0
   if i ~= 1 then
    for ii = 1, i-1 do
     top = top + v.heights[ii][j] + row_pad
	end
   end
   left = 0
   if j ~= 1 then
    for jj = 1, j-1 do
	 left = left + v.widths[i][jj] + col_pad
	end
   end
   n = view_id .. '_' .. tostring(cell)
   if v.on_fills then
    if v.on_fills[cell] == 'on_submitselect' then
     x = widgets.List{view_id      = n,
                      frame        = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]},
 	 				  on_submit    = self:callback('fillOnSubmit'),
 					  on_select    = self:callback('fillOnSelect'),
 	 				  text_pen     = textC,
 					  cursor_pen   = cursorC,
 					  inactive_pen = inactiveC}
    elseif v.on_fills[cell] == 'on_submit' then
     x = widgets.List{view_id      = n,
                      frame        = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]},
 	 				  on_submit    = self:callback('fillOnSubmit'),
 	 				  text_pen     = textC,
 					  cursor_pen   = cursorC,
 					  inactive_pen = inactiveC}
    elseif v.on_fills[cell] == 'on_select' then
     x = widgets.List{view_id      = n,
                      frame        = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]},
 	 				  on_select    = self:callback('fillOnSelect'),
 	 				  text_pen     = textC,
 					  cursor_pen   = cursorC,
 					  inactive_pen = inactiveC}
    else
     x = widgets.List{view_id = n,
                      frame   = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]}} 
    end
   else
    x = widgets.List{view_id = n,
                     frame   = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]}} 
   end
   cell = cell + 1
   table.insert(temp, x)
  end
 end
 local grid = {}
 for i = #temp, 1, -1 do
  table.insert(grid, temp[i])
 end
 return grid
end

--= Filling Functions (call functions/gui to get the information to put on the screen)
function JournalUi:fillView(view_id)
 local v = self.ViewDetails[view_id]
 local check = self.ViewCheckValue[view_id] or false
 local cells = v.num_cols * v.num_rows
 for i = 1, cells do
  if v.fill[i] and v.fill[i] ~= 'on_submit' 
               and v.fill[i] ~= 'on_select'
               and v.fill[i] ~= 'on_submitselect' then
   n = view_id .. '_' .. tostring(i)
   width = self.subviews[n].frame.w
   output = outputFunction(self.AllInfo,v.fill[i],width,check,view_id)
   self.subviews[n]:setChoices(output)
  end
 end
end
function JournalUi:fillOnSubmit(x,selection)
 local view_id = selection.text[1].viewScreen
 local v = self.ViewDetails[view_id]
 local cell = self:getCell(view_id,'on_submit')
 local n = view_id..'_'..tostring(cell)
 local output = outputFunction(self.AllInfo,v.on_submit,self.subviews[n].width,selection,view_id)
 self.subviews[n]:setChoices(output)
 
 local levels = v.levels or 1
 if levels > 1 then
  pcell = self:getCell(view_id,'on_submit',true)
  pn = view_id..'_'..tostring(pcell)
  self.subviews[pn].active = false
  self.subviews[n].active = true
  self.subviews[view_id].CurrentLevel = self.subviews[view_id].CurrentLevel + 1
 end
end
function JournalUi:fillOnSelect(x,selection)
 local view_id = selection.text[1].viewScreen
 local v = self.ViewDetails[view_id]
 local cell = self:getCell(view_id,'on_select')
 local n = view_id..'_'..tostring(cell)
 local output = outputFunction(self.AllInfo,v.on_select,self.subviews[n].width,selection,view_id)
 self.subviews[n]:setChoices(output)
end

--= Check Functions (sets a special value to use in the filling functions)
function JournalUi:changeCheckValue(view_id,value)
 if value then 
  self.ViewCheckValue[view_id] = value
 else
  if self.ViewCheckValue[view_id] == true
   then self.ViewCheckValue[view_id] = false
  elseif self.ViewCheckValue[view_id] == false
   then self.ViewCheckValue[view_id] = true
  end
 end
 self:fillView(view_id)
end

--= Viewing Functions (change which screen is active and visible)
function JournalUi:updateBottom(screen)
 if screen == 'main' then
  text = {}
   -- Add other peoples scripts to the list if they are detected
   -- e.g. the Library script from PatrikLundell
  for i,script in ipairs(extraScripts) do
   if dfhack.findScript(script) then
    table.insert(text,{key='CUSTOM_SHIFT_'..ckeys[i], text=': '..script..' ', on_activate = function () dfhack.run_script(script) end})
   end
  end
  table.insert(text, { text = 'ESC: Close Journal  '})
  self.subviews.bottomHeader:setText({{text='Extras:'}})
 elseif ViewDetails[screen] then
  text = {}
  if self.ViewDetails[screen].sortFlags then
   for i,flag in ipairs(self.ViewDetails[screen].sortFlags) do
    table.insert(text,{key='CUSTOM_SHIFT_'..ckeys[i], text=': '..flag..'  ', on_activate = function () self:changeCheckValue(screen,flag) end})
   end
   self.subviews.bottomHeader:setText({{text='Filters:'}})
  end
  table.insert(text, { text = 'ESC: Back  '})
 else
  print('Unrecognized view')
 end
 self.subviews.bottom_ui:setText(text)
end
function JournalUi:resetView()
 for _,view in pairs(views) do
  self.subviews[view].visible = false
  self.subviews[view].active  = false
 end
end
function JournalUi:viewChange(view_id)
 self:updateBottom(view_id)
 self:resetView()
 
 self.subviews[view_id].visible = true
 self.subviews[view_id].active  = true
end
function JournalUi:getCurrentView()
 local view_id = 'main'
 for view,_ in pairs(self.ViewDetails) do
  if self.subviews[view].visible then
   view_id = view
   break
  end
 end
 return view_id
end
function JournalUi:getCell(view_id,fill_id,parent)
 local x = 'fill'
 if parent then x = 'on_fills' end
 local v = self.ViewDetails[view_id]
 local cell = 1
 local cells = v.num_cols * v.num_rows
 for i = 1, cells do
  if v[x] and v[x][i] and v[x][i] == fill_id then
   cell = i
   break
  end
 end
 
 return cell
end

--= Base Functions
function JournalUi:onInput(keys)
 if keys.LEAVESCREEN then
  if self.ExternalCall and args.target1 and args.target2 then
   self:dismiss()
  end
  view_id = self:getCurrentView()
  if view_id == 'main' then
   self:dismiss()
  else
   v = self.ViewDetails[view_id]
   levels = v.Levels or 1
   if self.subviews[view_id].CurrentLevel == 1 then
    if self.ExternalCall then
     self:dismiss()
    else
     self:viewChange('main')
    end
   else
    cn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel)
    pn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel-1)
    self.subviews[view_id].CurrentLevel = self.subviews[view_id].CurrentLevel - 1
    self.subviews[cn].active = false
    self.subviews[pn].active = true
   end
  end
 else
  JournalUi.super.onInput(self, keys)
 end
end

local screen = JournalUi{}
screen:show()
