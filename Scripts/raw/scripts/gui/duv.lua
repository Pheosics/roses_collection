local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'
local guiFunctions = dfhack.script_environment('functions/gui')
local outputFunction = guiFunctions.getUnitOutput
local infoFunction   = guiFunctions.getUnitInfo
local textC     = COLOR_WHITE
local cursorC   = COLOR_LIGHTRED
local inactiveC = COLOR_CYAN
local ckeys = {'A','B','C','D','E','F','G','H','I','J','K'}

DetailedUnitView = defclass(DetailedUnitView, gui.FramedScreen)
DetailedUnitView.ATTRS={
                        frame_style = gui.BOUNDARY_FRAME,
                        frame_title = "Detailed Unit Viewer"}

views = {'main','detailedView','healthView','thoughtView','relationshipView','classView','featView','spellView'}
ViewDetails = {
               ['main'] = {
				            num_cols = 3,
				            num_rows = 3,
							col_pads = 4,
							row_pads = 1,
							widths   = {{40,40,40},
							            {40,40,40},
										{40,40,40}},
							heights  = {{6, 10,60},
							            {10,10, 0},
										{10,10, 0}},
							fill     = {'BaseInfo','Description','AppearanceBasic',
										'WorshipBasic','HealthBasic',nil,
										'RelationshipsBasic','AttributesBasic',nil}},
			   ['detailedView']     = {
				                    num_cols = 3,
									num_rows = 2,
									col_pads = 4,
									row_pads = 1,
									widths   = {{45,45,45},
									            {45,45,45}},
									heights  = {{40,40,20},
									            {0,0,20}},
									fill     = {'AttributesDetailed','SkillsDetailed','StatsDetailed',
												nil,nil,'ResistancesDetailed'}},
			   ['healthView']       = {
				                  num_cols = 2,
								  num_rows = 1,
								  col_pads = 4,
								  row_pads = 1,
								  widths   = {{60,60}},
								  heights  = {{40,40}},
								  fill     = {'HealthDetailed','SyndromeDetailed'}},
			   ['thoughtView']      = {
				                  num_cols = 3,
								  num_rows = 2,
								  col_pads = 4,
								  row_pads = 1,
								  widths   = {{40,40,40},
								              {40,40,40}},
								  heights  = {{40,20,40},
								              {0,20,0}},
								  fill     = {'ThoughtsDetailed','PreferencesDetailed','TraitsDetailed',
											  nil,'ValuesDetailed',nil}},
			   ['relationshipView'] = {
				                        num_cols = 2,
										num_rows = 1,
										col_pads = 4,
										row_pads = 1,
										widths = {{60,60}},
										heights = {{40,40}},
										fill = {nil,nil}},
			   ['classView']        = {
				                 num_cols = 2,
								 num_rows = 1,
								 col_pads = 4,
								 row_pads = 1,
								 widths   = {{40,80}},
								 heights  = {{40,40}},
								 fill     = {'ClassList','on_submit'},
                                 on_fills = {'on_submit','none'},
								 on_submit = 'ClassDetails',
								 start     = 'All',
                                 sortFlags = {'All','Civ','Learned','Available'}},
			   ['featView']         = {
				                num_cols = 2,
								num_rows = 1,
								col_pads = 4,
								row_pads = 1,
								widths   = {{40,80}},
								heights  = {{40,40}},
								fill     = {'FeatList','on_submit'},
                                on_fills = {'on_submit','none'},
								on_submit = 'FeatDetails',
								start     = 'All',
                                sortFlags = {'All','Class','Learned'}},
			   ['spellView']        = {
				                 num_cols = 2,
								 num_rows = 1,
								 col_pads = 4,
								 row_pads = 1,
								 widths   = {{40,80}},
								 heights  = {{40,40}},
								 fill     = {'SpellList','on_submit'},
                                 on_fills = {'on_submit','none'},
								 on_submit = 'SpellDetails',
								 start     = 'All',
                                 sortFlags = {'All','Civ','Learned','Class'}}
}

function DetailedUnitView:init(args)
 self.target = args.target
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
 self.AllInfo = infoFunction(self.target,self)
 self.AllInfo.target = self.target
 
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
end

function DetailedUnitView:checkActiveSystems()
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
function DetailedUnitView:addScreen(view_id)
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
function DetailedUnitView:getPositioning(view_id)
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
function DetailedUnitView:fillView(view_id)
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
function DetailedUnitView:fillOnSubmit(x,selection)
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
function DetailedUnitView:fillOnSelect(x,selection)
 local view_id = selection.text[1].viewScreen
 local v = self.ViewDetails[view_id]
 local cell = self:getCell(view_id,'on_select')
 local n = view_id..'_'..tostring(cell)
 local output = outputFunction(self.AllInfo,v.on_select,self.subviews[n].width,selection,view_id)
 self.subviews[n]:setChoices(output)
end

--= Check Functions (sets a special value to use in the filling functions)
function DetailedUnitView:changeCheckValue(view_id,value)
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
function DetailedUnitView:updateBottom(screen)
 if screen == 'main' then
   text = { 
           { key = 'CUSTOM_SHIFT_A', text = ': Attributes  ',    on_activate = function () self:viewChange('detailedView')     end},
           { key = 'CUSTOM_SHIFT_H', text = ': Health  ',        on_activate = function () self:viewChange('healthView')       end},
           { key = 'CUSTOM_SHIFT_P', text = ': Personality  ',   on_activate = function () self:viewChange('thoughtView')      end},
		   { key = 'CUSTOM_SHIFT_R', text = ': Relationships  ', on_activate = function () self:viewChange('relationshipView') end},
          }
   if self.ClassSystem then 
    table.insert(text, {key = 'CUSTOM_SHIFT_C', text = ': Classes  ', on_activate = function () self:viewChange('classView') end}) 
   end
   if self.ClassSystem then 
    table.insert(text, {key = 'CUSTOM_SHIFT_F', text = ': Feats  ',   on_activate = function () self:viewChange('featView')  end}) 
   end
   if self.ClassSystem then 
    table.insert(text, {key = 'CUSTOM_SHIFT_S', text = ': Spells  ',  on_activate = function () self:viewChange('spellView') end}) 
   end
  table.insert(text, { text = 'ESC: Close Viewer  '})
  self.subviews.bottomHeader:setText({{text='Details:'}})
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
function DetailedUnitView:resetView()
 for _,view in pairs(views) do
  self.subviews[view].visible = false
  self.subviews[view].active  = false
 end
end
function DetailedUnitView:viewChange(view_id)
 self:updateBottom(view_id)
 self:resetView()
 
 self.subviews[view_id].visible = true
 self.subviews[view_id].active  = true
end
function DetailedUnitView:getCurrentView()
 local view_id = 'main'
 for view,_ in pairs(self.ViewDetails) do
  if self.subviews[view].visible then
   view_id = view
   break
  end
 end
 return view_id
end
function DetailedUnitView:getCell(view_id,fill_id,parent)
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
function DetailedUnitView:onInput(keys)
 if keys.LEAVESCREEN then
  view_id = self:getCurrentView()
  if view_id == 'main' then
   self:dismiss()
  else
   v = self.ViewDetails[view_id]
   levels = v.Levels or 1
   if self.subviews[view_id].CurrentLevel == 1 then
    self:viewChange('main')
   else
    cn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel)
    pn = view_id..'_'..tostring(self.subviews[view_id].CurrentLevel-1)
    self.subviews[view_id].CurrentLevel = self.subviews[view_id].CurrentLevel - 1
    self.subviews[cn].active = false
    self.subviews[pn].active = true
   end
  end
 else
  DetailedUnitView.super.onInput(self, keys)
 end
end
function show_editor(trg)
 local screen = DetailedUnitView{target=trg}
 screen:show()
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

show_editor(getTargetFromScreens())
