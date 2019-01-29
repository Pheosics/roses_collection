local gui = require 'gui'
local widgets =require 'gui.widgets'
local utils = require 'utils'
local split = utils.split_string

local guiFunctions = dfhack.script_environment('functions/gui')
local outputFunction = guiFunctions.getJournalOutput
local infoFunction   = guiFunctions.getJournalInfo
local colorTables    = guiFunctions.colorTables

local textC     = COLOR_WHITE
local cursorC   = COLOR_LIGHTRED
local inactiveC = COLOR_CYAN
local default_row_pad = 1
local default_col_pad = 4
local nkeys = {'A_MOVE_SW','A_MOVE_S','A_MOVE_SE','A_MOVE_W','A_MOVE_SAME_SQUARE','A_MOVE_E','A_MOVE_NW','A_MOVE_N','A_MOVE_NE'}
local ckeys = {'A','B','C','D','E','F','G','H'}
local extraScripts = {{'librarian',''}}

validArgs = utils.invert({
 'help',
 'viewScreen',
 'target1',
 'target2',
 'colorScheme',
})
local args = utils.processArgs({...}, validArgs)

JournalUi = defclass(JournalUi, gui.FramedScreen)
JournalUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Journal and Compendium",
                 }

function JournalUi:init()
 self:setViewDetails()
 self:checkActiveSystems()
 
 -- Get All Information
 self.AllInfo = infoFunction(self.target,self)
 self.AllInfo.Systems = self.Systems
 self.ColorsScheme = args.colorScheme or 'DEFAULT'
 if colorTables[self.ColorsScheme] then
  cs = self.ColorsScheme:lower()
  self.ColorsText = cs:sub(1,1):upper()..cs:sub(2)
 else
  self.ColorsScheme = 'DEFAULT'
  self.ColorsText   = 'Default'
 end
 self.AllInfo.ColorScheme = self.ColorsScheme
 
 -- Top UI
 self:addviews{
   widgets.Panel{
     view_id  = 'topView',
     frame    = {t = 0, h = 2},
     subviews = {
       widgets.Label{
         view_id = 'topHeader',
         frame   = {l = 0, t = 0},
         text    = 'Configuration'
       },
       widgets.Label{
         view_id = 'top_ui',
         frame   = {l = 0, t = 1},
         text    = 'filled by updateTop()'
       }
     }
   }
 }
 self.subviews.topView.visible = true -- Always true
 
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
  self:addScreen(v)
 end

 -- Fill Frames
 for v,_ in pairs(self.ViewDetails) do
  self:fillView(v)
 end
 
 self:viewChange('main')
 
 if args.viewScreen then
  self.ExternalCall = true
  self:viewChange(args.viewScreen)
  if args.target1 then
   choices = self.subviews[args.viewScreen..'_1']:getChoices()
   for a,b in pairs(choices) do
    if b.text[1].token == args.target1 then
     self.subviews[args.viewScreen..'_1']:setSelected(a)
     break
    end
   end
  end
 end
end

function JournalUi:setViewDetails()
 self.ViewDetails = {
    ['main']         = {name='Main',
        num_cols = 3, num_rows = 3, 
        widths   = {{40,40,40},{40,40,40},{40,40,40}},
        heights  = {{15,15,15},{15,15,15},{15,15,15}},
        fill     = {'Buildings','Creatures','Entities',
                    'Items','Materials','Reactions',
                    'Plants','Gods',nil},
        functions = {{function () self:viewChange('buildingView') end,'B'},
                     {function () self:viewChange('creatureView') end,'C'},
                     {function () self:viewChange('entityView')   end,'E'},
                     {function () self:viewChange('itemView')     end,'I'},
                     {function () self:viewChange('materialView') end,'M'},
                     {function () self:viewChange('reactionView') end,'R'},
                     {function () self:viewChange('plantView')    end,'P'},
                     {function () self:viewChange('godView')      end,'G'},
                     nil}},
    ['godView']      = {name='Gods and Forces',
        num_cols = 2, num_rows = 1,
        widths   = {{60,60}},
        heights  = {{40,40}},
        fill     = {nil,nil}},
    ['classView']    = {name='Classes',
        num_cols = 2, num_rows = 1,
        widths   = {{60,60}},
        heights  = {{40,40}},
        fill     = {nil,nil}},
    ['featView']     = {name='Feats',
        num_cols = 2, num_rows = 1,
        widths   = {{60,60}},
        heights  = {{40,40}},
        fill     = {nil,nil}},
    ['spellView']    = {name='Spells',
        num_cols = 2, num_rows = 1,
        widths   = {{60,60}},
        heights  = {{40,40}},
        fill     = {nil,nil}},
    ['creatureView'] = {name='Creatures',
        design = [===[ 
                       |           |         |  Creature Header  |
                       | Creatures | Castes  | Habitat |  Stats  |
                       |           |         |  Facts  |  Body   |
                 ]===],
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{30,20,80, 0},{30,20,40,40},{30,20,40,40}},
        heights   = {{40,40,10,10},{ 0, 0,20,20},{ 0, 0,20,20}},
        fill      = {'CreatureList', 'on_select:1', 'on_select:2',   nil,
                     nil,            nil,           'group_Habitat', 'group_Stats',
                     nil,            nil,           'group_Facts',   'group_BodyInfo'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'CasteList','CreatureDetails'},
        on_groups = {['on_select:2']={'on_select:2','group_Habitat','group_Stats','group_BodyInfo','group_Facts'}},
        startFilter = 'ALL', filterFlags = {'ALL','GOOD','EVIL','SAVAGE','CASTE_MEGABEAST'}, --These are flags found in creature_raw.flags
        filterKeys = {'CUSTOM_SHIFT_A','CUSTOM_SHIFT_G','CUSTOM_SHIFT_E','CUSTOM_SHIFT_S','CUSTOM_SHIFT_M'}}, 
    ['buildingView'] = {name='Buildings',
        num_cols  = 3, num_rows = 1, levels = 2,
        widths    = {{30,30,60}},
        heights   = {{40,40,40}},
        fill      = {'BuildingTypeList','on_submit:1','on_submit:2'},
        on_fills  = {'on_submit:1','on_submit:2','none'},
        on_submit = {'BuildingList','BuildingDetails'},
        startFilter = 'ALL', filterFlags = {'ALL'}, -- Right now there are no filters for buildings
        filterKeys = {'CUSTOM_SHIFT_A'}},
    ['itemView']     = {name='Items',
        num_cols  = 3, num_rows = 1, levels = 2,
        widths    = {{30,30,60}},
        heights   = {{40,40,40}},
        fill      = {'ItemTypeList','on_submit:1','on_submit:2'},
        on_fills  = {'on_submit:1','on_submit:2','none'},
        on_submit = {'ItemList','ItemDetails'},
        startFilter = 'ALL', filterFlags = {'ALL'}, -- Right now there are no filters for items
        filterKeys = {'CUSTOM_SHIFT_A'}},
    ['reactionView'] = {name='Reactions',
        num_cols  = 3, num_rows = 1, levels = 2,
        widths    = {{30,30,60}},
        heights   = {{40,40,40}},
        fill      = {'ReactionTypeList','on_submit:1','on_submit:2'},
        on_fills  = {'on_submit:1','on_submit:2','none'},
        on_submit = {'ReactionList','ReactionDetails'},
        startFilter = 'ALL', filterFlags = {'ALL'},
        filterKeys = {'CUSTOM_SHIFT_A'}},
    ['materialView'] = {name='Materials',
        num_cols  = 3, num_rows = 1, levels = 2,
        widths    = {{30,30,60}},
        heights   = {{40,40,40}},
        fill      = {'MaterialTypeList','on_submit:1','on_submit:2'},
        on_fills  = {'on_submit:1','on_submit:2','none'},
        on_submit = {'MaterialList','MaterialDetails'},
        startFilter = 'ALL', filterFlags = {'ALL'}},
    ['entityView']   = {name='Entities',
        num_cols  = 3, num_rows = 1, levels = 2,
        widths    = {{30,30,60}},
        heights   = {{40,40,40}},
        fill      = {'EntityTypeList','on_submit:1','on_submit:2'},
        on_fills  = {'on_submit:1','on_submit:2','none'},
        on_submit = {'EntityList','EntityDetails'},
        startFilter = 'ALL', filterFlags = {'ALL'},
        filterKeys = {'CUSTOM_SHIFT_A'}},
    ['plantView']    = {name='Plants',
        num_cols  = 3, num_rows = 1, levels = 2,
        widths    = {{30,30,60}},
        heights   = {{40,40,40}},
        fill      = {'PlantTypeList','on_submit:1','on_submit:2'},
        on_fills  = {'on_submit:1','on_submit:2','none'},
        on_submit = {'PlantList','PlantDetails'},
        startFilter = 'ALL', filterFlags = {'ALL','EVIL','GOOD'}, --These are flags found in plant_raws.flags
        filterKeys = {'CUSTOM_SHIFT_A','CUSTOM_SHIFT_E','CUSTOM_SHIFT_G'}},
}

 -- Process the view details
 self.ViewFilterValue = {}
 self.ScreenName = {}
 for view,vd in pairs(self.ViewDetails) do
  self.ScreenName[view] = vd.name or view
  
  -- set the viewscreen as an actual argument
  vd.viewScreen = view
  
  -- set the starting filter state
  self.ViewFilterValue[view] = vd.startFilter or false
  
  -- count the number of on_submit and on_select calls
  i_onsubmit = 0
  n_onsubmit = 0
  i_onselect = 0
  n_onselect = 0
  if vd.on_submit then n_onsubmit = #vd.on_submit end
  if vd.on_select then n_onselect = #vd.on_select end
  for i,x in pairs(vd.fill) do
   y = split(x,':')[1]
   if y == 'on_submit' then i_onsubmit = i_onsubmit + 1 end
   if y == 'on_select' then i_onselect = i_onselect + 1 end
  end
  if i_onsubmit ~= n_onsubmit then error('Incorrect number of on_submit calls for viewscreen '..view) end
  if i_onselect ~= n_onselect then error('Incorrect number of on_select calls for viewscreen '..view) end
 end
end

function JournalUi:checkActiveSystems()
 local systems = {'Class','Feat','Spell','Civilization','EnhancedItem',
                  'EnhancedBuilding','EnhancedCreature','EnhancedMaterial',
                  'EnhancedReaction'}
 roses = dfhack.script_environment('base/roses-init').roses
 self.Systems = {}
 for _,system in pairs(systems) do
  if roses.Systems and roses.Systems[system] and roses.Systems[system] > 0 then
   self.Systems[system] = true
  else
   self.Systems[system] = false
  end
 end
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
 local row_pad = v.row_pads or default_row_pad
 local col_pad = v.col_pads or default_col_pad
 for i = 1, v.num_rows do
  for j = 1, v.num_cols do
   top = 2
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
    text = split(v.on_fills[cell],':')[1]
    num  = split(v.on_fills[cell],':')[2]
    if text == 'on_submit' then
     x = widgets.List{view_id       = n,
                      frame         = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]},
                      on_submit     = self:callback('fillOnSubmit'),
                      text_pen      = textC,
                      cursor_pen    = cursorC,
                      inactive_pen  = inactiveC,
                      on_submit_num = num}
    elseif text == 'on_select' then
     x = widgets.List{view_id       = n,
                      frame         = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]},
                      on_select     = self:callback('fillOnSelect'),
                      text_pen      = textC,
                      cursor_pen    = cursorC,
                      inactive_pen  = inactiveC,
                      on_select_num = num}
    else
     x = widgets.List{view_id = n,
                      frame   = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]},
                      text_pen     = textC,
                      inactive_pen = textC} 
    end
   else
    x = widgets.List{view_id = n,
                     frame   = {l = left, t = top, w = v.widths[i][j], h = v.heights[i][j]},
                     text_pen     = textC,
                     inactive_pen = textC} 
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
 if v.requires then
  if not self.Systems[v.requires] then return end
 end
 local check = self.ViewFilterValue[view_id] or false
 local cells = v.num_cols * v.num_rows
 for cell = 1, cells do
  if v.fill[cell] and not string.find(v.fill[cell],'on_submit')
                  and not string.find(v.fill[cell],'on_select')
                  and not string.find(v.fill[cell],'group') then
   n = view_id .. '_' .. tostring(cell)
   width = self.subviews[n].frame.w
   output = outputFunction(self.AllInfo,self.ViewDetails[view_id],cell,check)
   self.subviews[n]:setChoices(output)
  end
 end
end
function JournalUi:fillOnSubmit(_,selection)
 if not selection or not selection.text or not selection.text[1] then return end
 local view_id = selection.text[1].viewScreen
 local v = self.ViewDetails[view_id]
 local oncell = selection.text[1].viewScreenCell
 local onstr = v.on_fills[oncell]
 if v.on_groups and v.on_groups[onstr] then
  self:fillGroup(view_id,v.on_groups[onstr],selection)
 else
  for i,x in pairs(v.fill) do
   if x == onstr then
    cell = i
    break
   end
  end
  if not cell then return end
  local n = view_id..'_'..tostring(cell)
  local output = outputFunction(self.AllInfo,v,cell,selection)
  self.subviews[n]:setChoices(output)
 end
 
 local levels = v.levels or 1
 if levels > 1 then
  pn = view_id..'_'..tostring(oncell)
  self.subviews[pn].active = false
  self.subviews[n].active = true
  self.subviews[view_id].CurrentLevel = self.subviews[view_id].CurrentLevel + 1
 end
end
function JournalUi:fillOnSelect(_,selection)
 if not selection or not selection.text or not selection.text[1] then return end
 local view_id = selection.text[1].viewScreen
 local v = self.ViewDetails[view_id]
 local oncell = selection.text[1].viewScreenCell
 local onstr = v.on_fills[oncell]
 if v.on_groups and v.on_groups[onstr] then
  self:fillGroup(view_id,v.on_groups[onstr],selection)
 else
  for i,x in pairs(v.fill) do
   if x == onstr then
    cell = i
    break
   end
  end
  if not cell then return end
  local n = view_id..'_'..tostring(cell)
  local output = outputFunction(self.AllInfo,v,cell,selection)
  self.subviews[n]:setChoices(output)
 end
end
function JournalUi:fillGroup(view_id,group,selection)
 local v = self.ViewDetails[view_id]
 for _,cellName in pairs(group) do
  cell = self:getCell(view_id,cellName)
  n = view_id..'_'..tostring(cell)
  output = outputFunction(self.AllInfo,v,cell,selection)
  self.subviews[n]:setChoices(output)
 end
end

--= Filtering Functions (sets a special value to use in the filling functions)
function JournalUi:changeFilterValue(view_id,value)
 if value then 
  self.ViewFilterValue[view_id] = value
 else
  if self.ViewFilterValue[view_id] == true
   then self.ViewFilterValue[view_id] = false
  elseif self.ViewFilterValue[view_id] == false
   then self.ViewFilterValue[view_id] = true
  end
 end
 self:fillView(view_id)
 self:updateTop(view_id)
end

--= Viewing Functions (change which screen is active and visible)
function JournalUi:updateTop(screen)
 local text = {}
 local cst = self.ColorsText or 'Default'
 local ft  = self.ViewFilterValue[screen] or 'NA'
 local vt  = self.ScreenName[screen] or screen
 table.insert(text, {text='Current View: ', pen=COLOR_LIGHTGREEN})
 table.insert(text, {text=vt..' '})
 table.insert(text, {text='Color Scheme: ', pen=COLOR_LIGHTGREEN})
 table.insert(text, {text=cst..' '})
 table.insert(text, {text='Filter: ', pen=COLOR_LIGHTGREEN})
 table.insert(text, {text=ft..' '})
 self.subviews.top_ui:setText(text)
end
function JournalUi:updateBottom(screen)
 local text = {}
 local vd = self.ViewDetails[screen]
 if screen == 'main' then
  runScript = {}
  for i,tbl in ipairs(extraScripts) do
   script = tbl[1]
   scargs = tbl[2]
   key = tbl[3] or nkeys[i]
   runScript[i] = script..' '..scargs
   if dfhack.findScript(script) then
    table.insert(text,{key=key, text=': '..script..' ', on_activate = function () dfhack.run_command(runScript[i]) end})
   end
  end
  table.insert(text, {text = 'ESC: Close Viewer'})
  self.subviews.bottomHeader:setText({{text='Extras:'}})
 elseif vd then
  if vd.filterFlags then
   for i,flag in ipairs(vd.filterFlags) do
    if vd.filterKeys then
     key = vd.filterKeys[i]
    else
     key = 'CUSTOM_SHIFT_'..ckeys[i]
    end
    table.insert(text,{key=key, text=': '..flag..'  ', on_activate = function () self:changeFilterValue(screen,flag) end})
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
 for view,_ in pairs(self.ViewDetails) do
  self.subviews[view].visible = false
  self.subviews[view].active  = false
 end
end
function JournalUi:viewChange(view_id)
 self:updateTop(view_id)
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
   levels = v.levels or 1
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
 elseif keys.CURSOR_LEFT then
  view_id = self:getCurrentView()
  if self.subviews[view_id].CurrentLevel == 1 then return end -- Do nothing if at the lowest level
  cn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel)
  pn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel-1)
  self.subviews[view_id].CurrentLevel = self.subviews[view_id].CurrentLevel - 1
  self.subviews[cn].active = false
  self.subviews[pn].active = true
 elseif keys.CURSOR_RIGHT then
  view_id = self:getCurrentView()
  v = self.ViewDetails[view_id]
  levels = v.levels or 1
  if self.subviews[view_id].CurrentLevel == levels then return end -- Do nothing if at the highest level
  cn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel)
  pn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel+1)
  self.subviews[view_id].CurrentLevel = self.subviews[view_id].CurrentLevel + 1
  self.subviews[cn].active = false
  self.subviews[pn].active = true  
 else
  JournalUi.super.onInput(self, keys)
 end
end

local screen = JournalUi{}
screen:show()
