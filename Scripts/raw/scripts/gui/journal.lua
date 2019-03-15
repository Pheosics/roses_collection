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

function JournalUi:setViewDetails()
 self.ViewDetails = {
    ['main']          = {name='Main',
        num_cols = 5, num_rows = 3, 
        widths   = {{25,25,25,25,25},{25,25,25,25,25},{25,25,25,25,25}},
        heights  = {{10,10,10,10,10},{20,20,20,20,20},{15,15,15,40,15}},
        fill     = {'Arts',       'Buildings', 'Creatures', 'Entities',  nil,
                    'Inorganics', 'Items',     'Organics',  'Plants',    nil,
                    'Products',   'Reactions', 'Religions', 'Syndromes', nil},
        functions = {['Buildings']   = {function () self:viewChange('buildingView')  end,'B'},
                     ['Creatures']   = {function () self:viewChange('creatureView')  end,'C'},
                     ['Entities']    = {function () self:viewChange('entityView')    end,'E'},
                     ['Inorganics']  = {function () self:viewChange('inorganicView') end,'n'},
                     ['Items']       = {function () self:viewChange('itemView')      end,'I'},
                     ['Organics']    = {function () self:viewChange('organicView')   end,'O'},
                     ['Reactions']   = {function () self:viewChange('reactionView')  end,'R'},
                     ['Plants']      = {function () self:viewChange('plantView')     end,'P'},
                     ['Products']    = {function () self:viewChange('productView')   end,'r'},
                     ['Religions']   = {function () self:viewChange('religionView')  end,'g'},
                     ['Syndromes']   = {function () self:viewChange('syndromeView')  end,'S'},
                     ['Arts']        = {function () self:viewChange('artView')       end,'A'},
                     ['ClassSystem'] = {function () self:viewChange('classView')     end,'l'}}},
    ['helpView']       = {name='Help',
        num_cols = 2, num_rows = 2,
        widths   = {{60,60},{60,60}},
        heights  = {{30,30},{30,30}},
        fill     = {nil, nil, nil, nil}},
    ['religionView']   = {name='Gods and Forces', -- world.belief_systems, world.history.figures
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{40,40,99, 0},{40,40,50,50},{40,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'ReligionTypeList', 'on_select:1', 'on_select:2', nil,
                     nil,                nil,           'groupA',      'groupC',
                     nil,                nil,           'groupB',      'groupD'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'ReligionList','ReligionDetails'},
        on_groups = {['on_select:2']={'on_select:2','groupA','groupB','groupC','groupD'}},
        startFilter = 'ALL', filterFlags = {'ALL'}},
    ['syndromeView']   = {name='Syndromes and Interactions', -- raws.syndromes, raws.interactions
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{40,40,99, 0},{40,40,50,50},{40,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'SyndromeTypeList', 'on_select:1', 'on_select:2', nil,
                     nil,                nil,           'groupA',      'groupC',
                     nil,                nil,           'groupB',      'groupD'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'SyndromeList','SyndromeDetails'},
        on_groups = {['on_select:2']={'on_select:2','groupA','groupB','groupC','groupD'}},
        startFilter = 'ALL', filterFlags = {'ALL'}},
    ['artView']        = {name='Art Forms', -- world.poetic_forms, world.musical_forms, world.dance_forms, world.scales, world.rythms, world.written_contents?
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'ArtTypeList', 'on_select:1', 'on_select:2', nil,
                     nil,           nil,           'groupA',      'groupC',
                     nil,           nil,           'groupB',      'groupD'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'ArtList','ArtDetails'},
        on_groups = {['on_select:2']={'on_select:2','groupA','groupB','groupC','groupD'}},
        startFilter = 'ALL', filterFlags = {'ALL'}},
    ['productView']   = {name='Products',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'ProductTypeList', 'on_select:1', 'on_select:2',     nil,
                     nil,               nil,           'environmentInfo', 'materialInfo1',
                     nil,               nil,           'useInfo',         'materialInfo2'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'ProductList','ProductDetails'},
        on_groups = {['on_select:2']={'on_select:2','environmentInfo','useInfo','materialInfo1','materialInfo2'}},
        startFilter = 'ALL', filterFlags = {'ALL'}}, -- Filters based on material.flags
    ['classView']     = {name='Classes',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'ClassSystemTypes', 'on_select:1', 'on_select:2',   nil,
                     nil,                nil,           'group_A',       'group_B',
                     nil,                nil,           'group_C',       'group_D'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'ClassSystemList','ClassSystemDetails'},
        on_groups = {['on_select:2']={'on_select:2','group_A','group_B','group_D','group_C'}},
        startFilter = 'ALL', filterFlags = {'ALL'}},
    ['creatureView']  = {name='Creatures',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{40,40,80, 0},{40,40,40,40},{40,40,40,40}},
        heights   = {{40,40,10,10},{ 0, 0,20,20},{ 0, 0,20,20}},
        functions = {['materialInfo']   = {function () self:viewSwitch('organicView')   end,'M'}},
        fill      = {'CreatureList', 'on_select:1', 'on_select:2', nil,
                     nil,            nil,           'popInfo',     'baseInfo',
                     nil,            nil,           'flagInfo',    'materialInfo'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'CasteList','CreatureDetails'},
        on_groups = {['on_select:2']={'on_select:2','popInfo','baseInfo','flagInfo','materialInfo'}},
        startFilter = 'ALL', filterFlags = {'ALL','GOOD','EVIL','SAVAGE','CASTE_MEGABEAST'}, -- Filters based on creature_raw.flags
        filterKeys = {'CUSTOM_SHIFT_A','CUSTOM_SHIFT_G','CUSTOM_SHIFT_E','CUSTOM_SHIFT_S','CUSTOM_SHIFT_M'}}, 
    ['buildingView']  = {name='Buildings',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        functions = {['bldgReactions']   = {function () self:viewSwitch('reactionView')   end,'R'}},
        fill      = {'BuildingTypeList', 'on_select:1', 'on_select:2',   nil,
                     nil,                nil,           'bldgInfo',      'buildItems',
                     nil,                nil,           'bldgReactions', 'bldgDiagram'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'BuildingList','BuildingDetails'},
        on_groups = {['on_select:2']={'on_select:2','bldgInfo','buildItems','bldgReactions','bldgDiagram'}},
        startFilter = 'ALL', filterFlags = {'ALL'}}, -- No flags to filter on, need to decide if there should be a filter -ME
    ['itemView']      = {name='Items',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'ItemTypeList', 'on_select:1', 'on_select:2', nil,
                     nil,            nil,           'baseInfo',    'typeInfo',
                     nil,            nil,           'flagInfo',    'enhancedInfo'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'ItemList','ItemDetails'},
        on_groups = {['on_select:2']={'on_select:2','baseInfo','typeInfo','flagInfo','enhancedInfo'}},
        startFilter = 'ALL', filterFlags = {'ALL'}}, -- Flags for each different weapon type are different -ME
    ['reactionView']  = {name='Reactions',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{20,30,80, 0},{20,30,40,60},{20,30,40,60}},
        heights   = {{40,40,10,10},{ 0, 0,20,20},{ 0, 0,20,20}},
        fill      = {'ReactionTypeList', 'on_select:1', 'on_select:2',   nil,
                     nil,                nil,           'baseInfo',      'reagentInfo',
                     nil,                nil,           'enhancedInfo',  'productInfo'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'ReactionList','ReactionDetails'},
        on_groups = {['on_select:2']={'on_select:2','baseInfo','reagentInfo','productInfo','enhancedInfo'}},
        startFilter = 'ALL', filterFlags = {'ALL','FUEL','AUTOMATIC','ADVENTURE_MODE_ENABLED'}}, -- Filters based on reaction.flags
    ['inorganicView'] = {name='Inorganic Materials',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'MaterialTypeList', 'on_select:1', 'on_select:2',     nil,
                     nil,                nil,           'environmentInfo', 'materialInfo1',
                     nil,                nil,           'useInfo',         'materialInfo2'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'MaterialList','MaterialDetails'},
        on_groups = {['on_select:2']={'on_select:2','environmentInfo','useInfo','materialInfo1','materialInfo2'}},
        startFilter = 'ALL', filterFlags = {'ALL','SEDIMENTARY','METAMORPHIC'}}, -- Filters based on inorganic.flags
    ['organicView']   = {name='Organic Materials',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        fill      = {'MaterialTypeList', 'on_select:1', 'on_select:2',     nil,
                     nil,                nil,           'environmentInfo', 'materialInfo1',
                     nil,                nil,           'useInfo',         'materialInfo2'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'MaterialList','MaterialDetails'},
        on_groups = {['on_select:2']={'on_select:2','environmentInfo','useInfo','materialInfo1','materialInfo2'}},
        startFilter = 'ALL', filterFlags = {'ALL','ITEMS_SOFT','ITEMS_HARD'}}, -- Filters based on material.flags
    ['entityView']    = {name='Entities',
        num_cols  = 6, num_rows = 2, levels = 2,
        widths    = {{15,40,149, 0, 0, 0},{15,40,50,50,50,50}},
        heights   = {{40,40, 5, 5, 5, 5},{ 0, 0,100,100,100,100}},
        fill      = {'EntityTypeList', 'on_select:1', 'on_select:2',  nil,            nil,         nil,
                     nil,              nil,           'resourceInfo', 'positionInfo', 'moralInfo', 'baseInfo'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'EntityList','EntityDetails'},
        on_groups = {['on_select:2']={'on_select:2','baseInfo','resourceInfo','positionInfo','moralInfo'}},
        startFilter = 'ALL', filterFlags = {'ALL'}},
    ['plantView']     = {name='Plants',
        num_cols  = 4, num_rows = 3, levels = 2,
        widths    = {{15,40,99, 0},{15,40,50,50},{15,40,50,50}},
        heights   = {{40,40, 5, 5},{ 0, 0,25,25},{ 0, 0,25,25}},
        functions = {['materialInfo']   = {function () self:viewSwitch('organicView')   end,'M'}},
        fill      = {'PlantTypeList', 'on_select:1', 'on_select:2',   nil,
                     nil,             nil,           'baseInfo',      'materialInfo',
                     nil,             nil,           'typeInfo',      'growthInfo'},
        on_fills  = {'on_select:1', 'on_select:2', 'none', 'none',
                     'none',        'none',        'none', 'none',
                     'none',        'none',        'none', 'none'},
        on_select = {'PlantList','PlantDetails'},
        on_groups = {['on_select:2']={'on_select:2','baseInfo','materialInfo','typeInfo','growthInfo'}},
        startFilter = 'ALL', filterFlags = {'ALL','EVIL','GOOD'}, -- Filters based on plant_raw.flags
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
 self.Systems = {}
 for _,system in pairs(systems) do
  self.Systems[system] = false
 end
 if dfhack.findScript('base/roses-table') then
  roses = dfhack.script_environment('base/roses-table').roses
  for _,system in pairs(systems) do
   if roses and roses.Systems[system] and roses.Systems[system] > 0 then self.Systems[system] = true end
  end
 end
end

function JournalUi:onRenderBody(dc)
 view_id = self:getCurrentView()
 token = self.SelectedToken
 if view_id == 'buildingView' then
  cell = self.subviews[view_id..'_12'].frame
  la = math.floor(cell.l + cell.w/2+ 2)
  ta = math.floor(cell.t + 3)
  for _,bldg in pairs(df.global.world.raws.buildings.all) do
   if bldg.id == tonumber(token) then
    token = bldg.code
    t  = bldg.tile
    nx = math.floor(bldg.dim_x/2) - 1
    ny1 = bldg.dim_y - 1
    s  = bldg.build_stages
    for i = 0, bldg.dim_x-1 do
     for j = 0, bldg.dim_y-1 do
      dc:seek(i+la-(nx+2),j+ta):tile(t[s][i][j])
     end
    end
    break
   end
  end
  --if self.Systems.EnhancedBuilding and nx then
  -- for z = 2, 10 do
  --  la = la + nx + 2
  --  for _,bldg in pairs(df.global.world.raws.buildings.all) do
  --   if bldg.code == '!'..token..'_LEVEL_'..tostring(z) then
  --    t  = bldg.tile
  --    nx = bldg.dim_x - 1
  --    ny = bldg.dim_y - 1
  --    s  = bldg.build_stages
  --    dy = math.floor((ny1-ny)/2)
  --    for i = 0,nx do
  --     for j = 0,ny do
  --      dc:seek(i+la-(nx+1),j+ta+dy):tile(t[s][i][j])
  --     end
  --    end
  --    break
  --   end     
  --  end
  -- end
  --end
 end
end

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
 self.SelectedToken = 'NONE'
 self.baseChoices = {}
 
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

--= Screen and Positioning Functions (get the width, height, and anchor points for each screen and create the screens)
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
     a = widgets.Label{text={{text="Search",key='CHANGETAB',key_sep = '()',on_activate=function() self:enable_input(true) end},
                             {text=": "}},
                       frame={l=left,t=top}}
     b = widgets.EditField{view_id = n..'_edit',
                            frame   = {l = left+14, t = top, w = v.widths[i][j]-14, h = 1},
                            text_pen = textC,
                            active = false,
                            on_change=self:callback('text_input'),
                            on_submit=self:callback("enable_input",false)}
     x = widgets.List{view_id       = n,
                      frame         = {l = left, t = 1+top, w = v.widths[i][j], h = v.heights[i][j]},
                      on_select     = self:callback('fillOnSelect'),
                      on_submit     = self:callback('gmEditor'),
                      text_pen      = textC,
                      cursor_pen    = cursorC,
                      inactive_pen  = inactiveC,
                      on_select_num = num,
                      active        = false}
     table.insert(temp, a)
     table.insert(temp, b)
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
function JournalUi:fillView(view_id,token)
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
   local n = view_id .. '_' .. tostring(cell)
   width = self.subviews[n].frame.w
   output = outputFunction(self.AllInfo,self.ViewDetails[view_id],cell,check,token)
   self.subviews[n]:setChoices(output)
   self.baseChoices[n] = self.subviews[n]:getChoices()
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
 self.SelectedToken = selection.text[1].token
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
  local cell
  for i,x in pairs(v.fill) do
   if x == onstr then
    cell = i
    break
   end
  end
  if not cell then return end
  local n = view_id..'_'..tostring(cell)
  output,token = outputFunction(self.AllInfo,v,cell,selection)
  self.subviews[n]:setChoices(output)
  self.baseChoices[n] = self.subviews[n]:getChoices()
 end
 self.SelectedToken = selection.text[1].token
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
function JournalUi:fillHelp()
 -- Fill in the help section here!
 self:viewSwitch('helpView')
end

--= Filtering Functions (sets a special value to use in the filling functions and allows searching like a FilteredList)
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
function JournalUi:gmEditor()
 local m
 local n
 view_id = self:getCurrentView()
 token = tostring(self.SelectedToken)
 local q = #token:split(':')
 if not token then return end
 if view_id == 'buildingView' then
  if q == 2 then
   dfhack.run_command("gui/gm-editor df.global.world.raws.buildings['"..token:split(':')[2].."']")
  else
   dfhack.run_command('gui/gm-editor df.global.world.raws.buildings.all['..token..']')
  end
 elseif view_id == 'creatureView' then
  if q == 2 then
   for i,x in pairs(df.global.world.raws.creatures.all) do
    if x.creature_id == token:split(':')[1] then
     m = i
     for j,y in pairs(x.caste) do
      if y.caste_id == token:split(':')[2] then
       n = j
       break
      end
     end
     break
    end
   end
   if m and n then dfhack.run_command('gui/gm-editor df.global.world.raws.creatures.all['..tostring(m)..'].caste['..tostring(n)..']') end
  else
   for i,x in pairs(df.global.world.raws.creatures.all) do
    if x.creature_id == token then
     m = i
     break
    end
   end
   if m then dfhack.run_command('gui/gm-editor df.global.world.raws.creatures.all['..tostring(m)..']') end
  end
 elseif view_id == 'entityView' then
  if q == 2 then
   return
  else
   dfhack.run_command('gui/gm-editor df.global.world.entities.all['..token..']')
  end
 elseif view_id == 'inorganicView' then
   if dfhack.matinfo.find(token) then dfhack.run_command("gui/gm-editor dfhack.matinfo.find('"..token.."')") end
 elseif view_id == 'itemView' then
  if q == 2 then
   dfhack.run_command("gui/gm-editor df.global.world.raws.itemdefs['"..token:split(':')[2].."']")
  else
   for i,x in pairs(df.global.world.raws.itemdefs.all) do
    if x.id == token then
     n = i
     break
    end
   end
   if n then dfhack.run_command('gui/gm-editor df.global.world.raws.itemdefs.all['..tostring(n)..']') end
  end
 elseif view_id == 'organicView' then
  if dfhack.matinfo.find(token) then dfhack.run_command("gui/gm-editor dfhack.matinfo.find('"..token.."')") end
 elseif view_id == 'plantView' then
  if q == 2 then
   dfhack.run_command("gui/gm-editor df.global.world.raws.plants['"..token:split(':')[2].."']")
  else
   for i,x in pairs(df.global.world.raws.plants.all) do
    if x.id == token then
     n = i
     break
    end
   end
   if n then dfhack.run_command('gui/gm-editor df.global.world.raws.plants.all['..tostring(n)..']') end
  end
 elseif view_id == 'productView' then
  if dfhack.matinfo.find(token) then dfhack.run_command("gui/gm-editor dfhack.matinfo.find('"..token.."')") end
 elseif view_id == 'reactionView' then
  if q == 2 then
   return
  else
   for i,x in pairs(df.global.world.raws.reactions.reactions) do
    if x.code == token then
     n = i
     break
    end
   end
   if n then dfhack.run_command('gui/gm-editor df.global.world.raws.reactions.reactions['..tostring(n)..']') end
  end
 end
end
function JournalUi:text_input(new_text)
 local view_id = self:getCurrentView()
 local v1 = view_id .. '_1'
 local v2 = view_id .. '_2'
 local vc
 local list
 if self.subviews[v1..'_edit'].active then
  list = self.baseChoices[v1]
  vc = v1
 elseif self.subviews[v2..'_edit'].active then
  list = self.baseChoices[v2]
  vc = v2
 end
 local temp = {}
 if list then 
  for i,x in pairs(list) do
   if x.search_key then
    if string.match(x.search_key:lower(),new_text:lower()) then
     table.insert(temp,x)
    end
   end
  end
  self.subviews[vc]:setChoices(temp)
 end
end
function JournalUi:enable_input(enable)
 local view_id = self:getCurrentView()
 local v1 = view_id .. '_1'
 local v2 = view_id .. '_2'
 local disable = not enable
 if self.subviews[v1].active then
  self.subviews[v1..'_edit'].active = enable
  self.subviews[v1].active = disable
 elseif self.subviews[v2].active then
  self.subviews[v2..'_edit'].active = enable
  self.subviews[v2].active = disable
 elseif self.subviews[v1..'_edit'].active then
  self.subviews[v1..'_edit'].active = enable
  self.subviews[v1].active = disable
 elseif self.subviews[v2..'_edit'].active then
  self.subviews[v2..'_edit'].active = enable
  self.subviews[v2].active = disable  
 end
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
 table.insert(text, {key='HELP', text=': Help', on_activate = self:callback('fillHelp')})
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
function JournalUi:resetView(view_id)
 if view_id then
  self.subviews[view_id].visible = false
  self.subviews[view_id].active  = false
  self.PreviousView = view_id
 else
  self.PreviousView = 'main'
  for view,_ in pairs(self.ViewDetails) do
   self.subviews[view].visible = false
   self.subviews[view].active  = false
  end
 end
end
function JournalUi:viewChange(view_id)
 self:updateTop(view_id)
 self:updateBottom(view_id)
 self:resetView()
 self:fillView(view_id)
 self.subviews[view_id].visible = true
 self.subviews[view_id].active  = true
 if self.subviews[view_id..'_1'] then self.subviews[view_id..'_1'].active  = true end
end
function JournalUi:viewSwitch(view_id)
 current_view = self:getCurrentView()
 self:updateTop(view_id)
 self:updateBottom(view_id)
 self:resetView(current_view)
 self:fillView(view_id,self.SelectedToken)
 
 self.subviews[view_id].visible = true
 self.subviews[view_id].active  = true
 if self.subviews[view_id..'_1'] then self.subviews[view_id..'_1'].active  = true end
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
     self:viewChange(self.PreviousView)
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
