--@ module = true
local gui = require "gui"
local widgets = require "gui.widgets"
local utils = require "utils"
local split = utils.split_string

info = {}
info["GUI"] = [===[ TODO ]===]

local textC     = COLOR_WHITE
local cursorC   = COLOR_LIGHTRED
local inactiveC = COLOR_CYAN
local default_row_pad = 1
local default_col_pad = 4
local nkeys = {"A_MOVE_SW","A_MOVE_S","A_MOVE_SE","A_MOVE_W","A_MOVE_SAME_SQUARE","A_MOVE_E","A_MOVE_NW","A_MOVE_N","A_MOVE_NE"}
local ckeys = {"A","B","C","D","E","F","G","H"}
local ignoreStrings = {"=","!","*"}

local colorTables = {
	["DEFAULT"] = {
		["flagColor"]  = COLOR_YELLOW,       -- Color to assign flags like [NOPAIN] when shown
		["titleColor"] = COLOR_LIGHTCYAN,    -- Color of lines using the "center" method
		["headColor"]  = COLOR_LIGHTMAGENTA, -- Color of headers in the "header" and "table" method
		["subColor"]   = COLOR_YELLOW,       -- Color of the sub headers in the "header" method
		["textColor"]  = COLOR_WHITE,        -- Color of alphabetic characters and the color used for the "text" method
		["numColor"]   = COLOR_LIGHTGREEN,   -- Base color of all numbers not assigned a color bin
		["colColor"]   = COLOR_LIGHTMAGENTA, -- Color of column headers for the "table" method
		["falseColor"] = COLOR_LIGHTRED,     -- Color used when requirements aren"t met
		["trueColor"]  = COLOR_LIGHTGREEN,   -- Color used when requirements are met
		["keyColor"]   = COLOR_LIGHTRED,     -- Color of the keys used for titles that are "keyed"
		["binColors"]  = {                   -- Color overrides for textColor and numColor when assigned color bins
			[-4] = COLOR_LIGHTMAGENTA,
			[-3] = COLOR_LIGHTRED,
			[-2] = COLOR_YELLOW,
			[-1] = COLOR_BROWN,
			[0]  = COLOR_GREY,
			[1]  = COLOR_WHITE,
			[2]  = COLOR_GREEN,
			[3]  = COLOR_LIGHTGREEN,
			[4]  = COLOR_LIGHTCYAN}
		},
	["WHITE"] = {
		["flagColor"]  = COLOR_WHITE,
		["titleColor"] = COLOR_WHITE,
		["headColor"]  = COLOR_WHITE,
		["subColor"]   = COLOR_WHITE,
		["textColor"]  = COLOR_WHITE,
		["numColor"]   = COLOR_WHITE,
		["colColor"]   = COLOR_WHITE,
		["falseColor"] = COLOR_WHITE,
		["trueColor"]  = COLOR_WHITE,
		["keyColor"]   = COLOR_WHITE,
		["binColors"]  = {
			[-4] = COLOR_WHITE,
			[-3] = COLOR_WHITE,
			[-2] = COLOR_WHITE,
			[-1] = COLOR_WHITE,
			[0]  = COLOR_WHITE,
			[1]  = COLOR_WHITE,
			[2]  = COLOR_WHITE,
			[3]  = COLOR_WHITE,
			[4]  = COLOR_WHITE}
		}
}

local function tchelper(first, rest)
  return first:upper()..rest:lower()
end
local function center(str, length, tuple)
	local string1 = str
	if tuple then
		local string2 = string.format("%"..tostring(math.floor((length-#string1)/2)).."s","")
		local string3 = string.format("%"..tostring(math.ceil((length-#string1)/2)).."s","")
		return string1, string2, string3
	else
		local string2 = string.format("%"..tostring(math.floor((length-#string1)/2)).."s"..string1,"")
		local string3 = string.format(string2.."%"..tostring(math.ceil((length-#string1)/2)).."s","")
		return string3
	end
end
local function get_xy_cell(cols,rows,n,dir)
	if dir == 1 then -- turn xy into cell
	else             -- turn cell into xy
		local cell = 1
		local x = 1
		local y = 1
		local found = false
		for i = 1, rows do
			if found then break end
			for j = 1, cols do
				if cell == n then
					x = j
					y = i
					found = true
					break
				else
					cell = cell + 1
				end
			end
		end
	return y, x
	end
end
function get_order(tbl,ordering,Type)
	local orderOut = {}
	local order = ordering or "Alphabetical"
	local check = Type or "Title"
	
	if type(order) == "table" then
		orderOut = order
		for x,_ in pairs(tbl) do
			local present = false
			for _,y in pairs(order) do
				if x == y then present = true end
			end
			if not present then orderOut[#orderOut+1] = x end
		end
	else
		if order == "Alphabetical" then
			if check == "Key" then
				for x,_ in pairs(tbl) do
					orderOut[#orderOut+1] = x
				end
				table.sort(orderOut)
			elseif check == "Title" then
				tempOrder = {}
				for x,y in pairs(tbl) do
					tempOrder[#tempOrder+1] = y._title or y._header or x
				end
				table.sort(tempOrder)
				for i,z in pairs(tempOrder) do
					for x,y in pairs(tbl) do
						local key = y._title or y._header or x
						if key == z then
							orderOut[i] = x
							break
						end
					end
				end
			end
		end
	end
	return orderOut
end

local function parse_for_numbers(h, s, width, pens, flag, inText)
	local outText = inText or {}
	local pens = pens or {}
	local flagStr = flag or ""
	h = tostring(h)
	s = tostring(s)
	table.insert(outText, {text=h,  width=#h, pen=pens.penHead})
	table.insert(outText, {text='', width=width-#h-#s-#flagStr, pen=pens.penHead})
	for i = 1, #s do
		if s:sub(i,i) == '-' then pens.penNums = pens.penFalse end
		if tonumber(s:sub(i,i)) then
			pen = pens.penNums
		else
			pen = pens.penText
		end
		table.insert(outText, {text=s:sub(i,i), width=1, pen=pen})
	end
	table.insert(outText, {text=flagStr, width=#flagStr, pen=pens.penFlag})
	return outText
end

local function checkValid(name,struct,token)
	local check = true
	for _,str in pairs(ignoreStrings) do
		if name:find(str) then check = false end
	end
	if name == '' then check = false end
	
	if token then
		for _,str in pairs(ignoreStrings) do
			if token:find(str) then check = false end
		end
	end  
	-- Add check for resource availability, entity buildings/reactions, etc... -ME
	
	return check
end
local function parseFlags(flags,list)
	local info = list or {}
 
	for flag,bool in pairs(flags) do
		if bool and not tonumber(flag) then info[flag] = true end
	end
 
	return info
end
local function getSpecialInfo(allTable,token)
	local out = {}
	for a,b in pairs(allTable) do
		for c,d in pairs(b) do
			if split(c,':')[2] == token then
				out[a] = {}
				out[a]._title = a
				out[a]._key = c
			end
		end
	end
	return out
end
local function translateNumber(num,round)
	local out = tostring(num)
	local a = 1
	local b = 1
	local c = 1
	local d = 1
	if not out or not tonumber(num) then return num end
	num = tonumber(num)
	local str = out 
	if num >= 1000000 then
		a = tonumber(str:sub(#str-5,#str))
		b = a/1000000
		c = tonumber(str:sub(1,#str-6))
		d = c + b
		if round then d = math.floor(d) end
		out = tostring(d).."M"
	elseif num >= 10000 then
		a = tonumber(str:sub(#str-2,#str))
		b = a/1000
		b = math.floor(b*10 + 0.5)/10
		c = tonumber(str:sub(1,#str-3))
		d = c + b
		if round then d = math.floor(d) end
		out = tostring(d).."k"
	elseif num >= 1000 then
		out = str:sub(1,1)..","..str:sub(2)
	end
	
	return out
end
local function getOptimalWidth(width,info,list)
	local out = {}
	for i,x in pairs(list) do
		local n = {}
		for j,y in pairs(info) do
			n[#n+1] = #tostring(y[x])
		end
		n[#n+1] = #tostring(x)
		out[i] = math.max(table.unpack(n))+2
	end
	return out
end

--===============================================================================================--
--== GUI CLASSES ================================================================================--
--===============================================================================================--
GUI = defclass(GUI, gui.FramedScreen)
WIDGET = defclass(WIDGET)

--===============================================================================================--
--== GUI FUNCTIONS ==============================================================================--
--===============================================================================================--
function GUI:init(input)
	self:setViewDetails(input[1], input[2])
	self:setFillFunction(input[3])
	
	-- Top UI
	self:addviews{
		widgets.Panel{
			view_id  = "topView",
			frame    = {t = 0, h = 2},
			subviews = {
				widgets.Label{
					view_id = "topHeader",
					frame   = {l = 0, t = 0},
					text    = "Configuration"
				},
				widgets.Label{
					view_id = "top_ui",
					frame   = {l = 0, t = 1},
					text    = "filled by updateTop()"
				}
			}
		}
	}
	self.subviews.topView.visible = true -- Always true
 
	-- Bottom UI
	self:addviews{
		widgets.Panel{
			view_id  = "bottomView",
			frame    = { b = 0, h = 2},
			subviews = {
				widgets.Label{
					view_id = "bottomHeader",
					frame   = { l = 0, t = 0},
					text    = "Extras:"
				},
				widgets.Label{
					view_id = "bottom_ui",
					frame   = { l = 0, t = 1},
					text    = "filled by updateBottom()"
				}
			}
		}
	}
	self.subviews.bottomView.visible = true -- Always true
	
	-- Create Frames
	for v,vd in pairs(self.ViewDetails) do
		self:addScreen(v)
	end

	-- Fill Frames
	for v,_ in pairs(self.ViewDetails) do
		self:fillView(v)
	end
 
	self:viewChange('main')
end

function GUI:setViewDetails(mainViewDetails, subViewDetails)
	self.ColorScheme = "DEFAULT"
	self.ColorsText  = "Default"
	self.ViewDetails = {
		main = mainViewDetails,
		helpView = {
			name = "Help",
			levels = 1,
			num_cols = 1, 
			num_rows = 1,
			widths = {
				{120}},
			heights = {
				{60}},
			fill = {nil}
		}
	}
	for k, vd in pairs(subViewDetails or {}) do
		self.ViewDetails[k] = vd
	end
	
	self.ViewFilterValue = {}
	self.ScreenName = {}
	self.ExtraScripts = {}
	self.baseChoices = {}
	self.SelectedToken = ""
	
	for view, vd in pairs(self.ViewDetails) do
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
			y = split(x,":")[1]
			if y == "on_submit" then i_onsubmit = i_onsubmit + 1 end
			if y == "on_select" then i_onselect = i_onselect + 1 end
		end
		if i_onsubmit ~= n_onsubmit then error("Incorrect number of on_submit calls for viewscreen "..view) end
		if i_onselect ~= n_onselect then error("Incorrect number of on_select calls for viewscreen "..view) end
		
		-- set up the functions
		for k, v in pairs(vd.functions or {}) do
			if v[1] == "viewChange" then
				fnct = function () self:viewChange(v[2]) end
			elseif v[1] == "viewSwitch" then
				fnct = function () self:viewSwitch(v[2]) end
			else
				fnct = function () v[1](v[2]) end
			end
			vd.functions[k] = {fnct, v[3]}
		end
	end
end

function GUI:setFillFunction(fnct)
	self.FillFunction = fnct
end

function GUI:addViewDetails(subViewName, subViewDetails)
	self.ViewDetails[subViewName] = subViewDetails
end

function GUI:addScreen(view_id)
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

function GUI:getPositioning(view_id)
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
			n = view_id .. "_" .. tostring(cell)
			if v.on_fills then
				text = split(v.on_fills[cell],":")[1]
				num  = split(v.on_fills[cell],":")[2]
				if text == "on_submit" then
					x = widgets.List{
						view_id = n,
						frame = {
							l = left, 
							t = top,
							w = v.widths[i][j],
							h = v.heights[i][j]},
						on_submit = self:callback("fillOnSubmit"),
						text_pen      = textC,
						cursor_pen    = cursorC,
						inactive_pen  = inactiveC,
						on_submit_num = num}
				elseif text == "on_select" then
					a = widgets.Label{
						text = {
							{text = "Search", key= "CHANGETAB", key_sep = "()", on_activate=function() self:enable_input(true) end},
							{text=": "}},
						frame={l=left,t=top}}
					b = widgets.EditField{
						view_id = n.."_edit",
						frame = {
							l = left+14, 
							t = top,
							w = v.widths[i][j]-14, 
							h = 1},
						text_pen = textC,
						active = false,
						on_change=self:callback("text_input"),
						on_submit=self:callback("enable_input", false)}
					x = widgets.List{
						view_id = n,
						frame = {
							l = left, 
							t = 1+top, 
							w = v.widths[i][j], 
							h = v.heights[i][j]},
						on_select     = self:callback("fillOnSelect"),
						on_submit     = self:callback("gmEditor"),
						text_pen      = textC,
						cursor_pen    = cursorC,
						inactive_pen  = inactiveC,
						on_select_num = num,
						active        = false}
					table.insert(temp, a)
					table.insert(temp, b)
				else
					x = widgets.List{
						view_id = n,
						frame = {
							l = left,
							t = top, 
							w = v.widths[i][j], 
							h = v.heights[i][j]},
						text_pen     = textC,
						inactive_pen = textC} 
				end
			else
				x = widgets.List{
					view_id = n,
					frame = {
						l = left, 
						t = top, 
						w = v.widths[i][j], 
						h = v.heights[i][j]},
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

function GUI:fillView(view_id, token)
	local v = self.ViewDetails[view_id]
	if v.requires then
		if not self.Systems[v.requires] then return end
	end
	local check = self.ViewFilterValue[view_id] or false
	local cells = v.num_cols * v.num_rows
	for cell = 1, cells do
		if v.fill[cell] and not string.find(v.fill[cell],"on_submit")
		                and not string.find(v.fill[cell],"on_select")
		                and not string.find(v.fill[cell],"group") then
			choices = self:initializeChoices(v, cell)
			choices = self.FillFunction(choices, check, token)
			local n = view_id .. "_" .. tostring(cell)
			self.subviews[n]:setChoices(choices.Input)
			self.baseChoices[n] = self.subviews[n]:getChoices()
		end
	end
end

function GUI:fillOnSubmit(_, selection)
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
		choices = self:initializeChoices(v, cell)
		choices = self.FillFunction(choices, selection)
		local n = view_id.."_"..tostring(cell)
		self.subviews[n]:setChoices(choices.Input)
	end
 
	local levels = v.levels or 1
	if levels > 1 then
		pn = view_id.."_"..tostring(oncell)
		self.subviews[pn].active = false
		self.subviews[n].active = true
		self.subviews[view_id].CurrentLevel = self.subviews[view_id].CurrentLevel + 1
	end
	self.SelectedToken = selection.text[1].token
end

function GUI:fillOnSelect(_, selection)
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
		choices = self:initializeChoices(v, cell)
		choices = self.FillFunction(choices, selection)
		n = view_id.."_"..tostring(cell)
		self.subviews[n]:setChoices(choices.Input)
		self.baseChoices[n] = self.subviews[n]:getChoices()
	end
	self.SelectedToken = selection.text[1].token
end

function GUI:fillGroup(view_id, group, selection)
	local v = self.ViewDetails[view_id]
	for _,cellName in pairs(group) do
		cell = self:getCell(view_id,cellName)
		choices = self:initializeChoices(v, cell)
		choices = self.FillFunction(choices, selection)
		n = view_id.."_"..tostring(cell)
		self.subviews[n]:setChoices(choices.Input)
	end
end

function GUI:fillHelp()
 -- Fill in the help section here!
 self:viewSwitch("helpView")
end

function GUI:changeFilterValue(view_id, value)
	if value then 
		self.ViewFilterValue[view_id] = value
	else
		if self.ViewFilterValue[view_id] == true then
			self.ViewFilterValue[view_id] = false
		elseif self.ViewFilterValue[view_id] == false then
			self.ViewFilterValue[view_id] = true
		end
	end
	self:fillView(view_id)
	self:updateTop(view_id)
end

function GUI:text_input(new_text)
	local view_id = self:getCurrentView()
	local v1 = view_id .. "_1"
	local v2 = view_id .. "_2"
	local vc
	local list
	if self.subviews[v1.."_edit"].active then
		list = self.baseChoices[v1]
		vc = v1
	elseif self.subviews[v2.."_edit"].active then
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

function GUI:enable_input(enable)
	local view_id = self:getCurrentView()
	local v1 = view_id .. "_1"
	local v2 = view_id .. "_2"
	local disable = not enable
	if self.subviews[v1].active then
		self.subviews[v1.."_edit"].active = enable
		self.subviews[v1].active = disable
	elseif self.subviews[v2].active then
		self.subviews[v2.."_edit"].active = enable
		self.subviews[v2].active = disable
	elseif self.subviews[v1.."_edit"].active then
		self.subviews[v1.."_edit"].active = enable
		self.subviews[v1].active = disable
	elseif self.subviews[v2.."_edit"].active then
		self.subviews[v2.."_edit"].active = enable
		self.subviews[v2].active = disable  
	end
end

function GUI:gmEditor()
	local token = tostring(self.SelectedToken)
	if not token then return end
	local m
	local n
	local view_id = self:getCurrentView()
	local gmType = view_id -- This should be changed so that any GUI can access the gm-editor more easily, not just the journal
	local q = #token:split(":")
	if gmType == "buildingView" then
		if q == 2 then
			dfhack.run_command("gui/gm-editor df.global.world.raws.buildings['"..token:split(":")[2].."']")
		else
			dfhack.run_command("gui/gm-editor df.global.world.raws.buildings.all["..token.."]")
		end
	elseif gmType == "creatureView" then
		if q == 2 then
			for i,x in pairs(df.global.world.raws.creatures.all) do
				if x.creature_id == token:split(":")[1] then
					m = i
					for j,y in pairs(x.caste) do
						if y.caste_id == token:split(":")[2] then
							n = j
							break
						end
					end
					break
				end
			end
			if m and n then dfhack.run_command("gui/gm-editor df.global.world.raws.creatures.all["..tostring(m).."].caste["..tostring(n).."]") end
		else
			for i,x in pairs(df.global.world.raws.creatures.all) do
				if x.creature_id == token then
					m = i
					break
				end
			end
			if m then dfhack.run_command("gui/gm-editor df.global.world.raws.creatures.all["..tostring(m).."]") end
		end
	elseif gmType == "entityView" then
		if q == 2 then
			return
		else
			dfhack.run_command("gui/gm-editor df.global.world.entities.all["..token.."]")
		end
	elseif gmType == "inorganicView" then
		if dfhack.matinfo.find(token) then dfhack.run_command("gui/gm-editor dfhack.matinfo.find('"..token.."')") end
	elseif gmType == "itemView" then
		if q == 2 then
			dfhack.run_command("gui/gm-editor df.global.world.raws.itemdefs['"..token:split(":")[2].."']")
		else
			for i,x in pairs(df.global.world.raws.itemdefs.all) do
				if x.id == token then
					n = i
					break
				end
			end
			if n then dfhack.run_command("gui/gm-editor df.global.world.raws.itemdefs.all["..tostring(n).."]") end
		end
	elseif gmType == "organicView" then
		if dfhack.matinfo.find(token) then dfhack.run_command("gui/gm-editor dfhack.matinfo.find('"..token.."')") end
	elseif gmType == "plantView" then
		if q == 2 then
			dfhack.run_command("gui/gm-editor df.global.world.raws.plants['"..token:split(":")[2].."']")
		else
			for i,x in pairs(df.global.world.raws.plants.all) do
				if x.id == token then
					n = i
					break
				end
			end
			if n then dfhack.run_command("gui/gm-editor df.global.world.raws.plants.all["..tostring(n).."]") end
		end
	elseif gmType == "productView" then
		if dfhack.matinfo.find(token) then dfhack.run_command("gui/gm-editor dfhack.matinfo.find('"..token.."')") end
	elseif gmType == "reactionView" then
		if q == 2 then
			return
		else
			for i,x in pairs(df.global.world.raws.reactions.reactions) do
				if x.code == token then
					n = i
					break
				end
			end
			if n then dfhack.run_command("gui/gm-editor df.global.world.raws.reactions.reactions["..tostring(n).."]") end
		end
	end
end

function GUI:updateTop(screen)
	local cst = self.ColorsText
	local ft  = self.ViewFilterValue[screen] or "NA"
	local vt  = self.ScreenName[screen] or screen
	local text = {}
		table.insert(text, {text="Current View: ", pen=COLOR_LIGHTGREEN})
		table.insert(text, {text=vt.." "})
		table.insert(text, {text="Color Scheme: ", pen=COLOR_LIGHTGREEN})
		table.insert(text, {text=cst.." "})
		table.insert(text, {text="Filter: ", pen=COLOR_LIGHTGREEN})
		table.insert(text, {text=ft.." "})
		table.insert(text, {key="HELP", text=": Help", on_activate = self:callback("fillHelp")})
	self.subviews.top_ui:setText(text)
end

function GUI:updateBottom(screen)
	local text = {}
	local vd = self.ViewDetails[screen]
	if screen == "main" then
		runScript = {}
		for i,tbl in ipairs(self.ExtraScripts) do
			script = tbl[1]
			scargs = tbl[2]
			key = tbl[3] or nkeys[i]
			runScript[i] = script.." "..scargs
			if dfhack.findScript(script) then
				table.insert(text, {key=key, 
				                    text=": "..script.." ",
				                    on_activate = function () dfhack.run_command(runScript[i]) end}
				)
			end
		end
		table.insert(text, {text = "ESC: Close Viewer"})
		self.subviews.bottomHeader:setText({{text="Extras:"}})
	elseif vd then
		if vd.filterFlags then
			for i,flag in ipairs(vd.filterFlags) do
				if vd.filterKeys then
					key = vd.filterKeys[i]
				else
					key = "CUSTOM_SHIFT_"..ckeys[i]
				end
				table.insert(text, {key=key, 
				                    text=": "..flag.."  ",
				                    on_activate = function () self:changeFilterValue(screen, flag) end}
				)
			end
			self.subviews.bottomHeader:setText({{text="Filters:"}})
		end
		table.insert(text, {text = "ESC: Back  "})
	else
		print("Unrecognized view")
	end
	self.subviews.bottom_ui:setText(text)
end

function GUI:resetView(view_id)
	if view_id then
		self.subviews[view_id].visible = false
		self.subviews[view_id].active  = false
		self.PreviousView = view_id
	else
		self.PreviousView = "main"
		for view,_ in pairs(self.ViewDetails) do
			self.subviews[view].visible = false
			self.subviews[view].active  = false
		end
	end
end

function GUI:viewChange(view_id)
	self:updateTop(view_id)
	self:updateBottom(view_id)
	self:resetView()
	self:fillView(view_id)
	self.subviews[view_id].visible = true
	self.subviews[view_id].active  = true
	if self.subviews[view_id.."_1"] then 
		self.subviews[view_id.."_1"].active = true
	end
end

function GUI:viewSwitch(view_id)
	current_view = self:getCurrentView()
	self:updateTop(view_id)
	self:updateBottom(view_id)
	self:resetView(current_view)
	self:fillView(view_id)
 
	self.subviews[view_id].visible = true
	self.subviews[view_id].active  = true
	if self.subviews[view_id.."_1"] then
		self.subviews[view_id.."_1"].active = true
	end
end

function GUI:getCurrentView()
	local view_id = "main"
	for view,_ in pairs(self.ViewDetails) do
		if self.subviews[view].visible then
			view_id = view
			break
		end
	end
	return view_id
end

function GUI:getCell(view_id, fill_id, parent)
	local x = "fill"
	if parent then x = "on_fills" end
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

function GUI:initializeChoices(viewDetails, cell_id)
	-- Get the view_id
	local view_id = viewDetails.viewScreen

	-- Get the cell name
	local what = viewDetails.fill[cell_id]
	local twhat = split(what,':')[1]
	local nwhat = split(what,':')[2]
	if twhat == "on_submit" then what = viewDetails.on_submit[tonumber(nwhat)] end
	if twhat == "on_select" then what = viewDetails.on_select[tonumber(nwhat)] end

	-- Check for any functions associated with the cell
	local keyed = false
	if viewDetails.functions then
		keyed = viewDetails.functions[what]
	end
	
	-- Get the width of the cell
	x, y = get_xy_cell(viewDetails.num_cols,viewDetails.num_rows,cell_id,-1)
	local w = viewDetails.widths[x][y]
	local cell = {cell_id, what, w}
	return WIDGET({view_id, cell, keyed})
end

function GUI:onInput(keys)
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
  GUI.super.onInput(self, keys)
 end
end

--===============================================================================================--
--== WIDGET FUNCTIONS ===========================================================================--
--===============================================================================================--
function WIDGET:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(WIDGET,key) then return rawget(WIDGET,key) end
end
function WIDGET:init(input)
	local view_id = input[1]
	local cell = input[2]
	local keyed = input[3]
	self.Input = {}
	self.ViewID = view_id
	self.CellNumber = cell[1]
	self.CellName   = cell[2]
	self.CellWidth  = cell[3]
	self.Colors = colorTables["DEFAULT"] -- We should be able to pick this -ME
	self.Keyed = keyed
	self.listOptions  = {width=self.CellWidth, colOrder={}, view_id=view_id, cell=self.CellNumber}
	self.tokenOptions = {width=self.CellWidth, colOrder={}, view_id=view_id, cell=self.CellNumber, token=""}
	self.outToken = nil
end

function WIDGET:insert(Type, input, options)
	-- Get the base widget options
	local widget_options
	if not options or not options.baseType then
		widget_options = self.listOptions
	elseif options.baseType == "token" then
		widget_options = self.tokenOptions
	elseif options.baseType == "list" then
		widget_options = self.listOptions
	else
		widget_options = {}
	end
	
	-- Add any custom widget options that were passed in
	for k, v in pairs(options or {}) do
		widget_options[k] = v
	end
	
	-- Insert data based on insert type
	local uT = Type:upper()
	if uT == "CENTER" then
		self:insertCenter(input, widget_options)
	elseif uT == "HEADER" then
		self:insertHeader(input, widget_options)
	elseif uT == "TABLE" then
		self:insertTable(input, widget_options)
	elseif uT == "TEXT" then
		self:insertText(input, widget_options)
	elseif uT == "LIST" then
		self:insertList(input, widget_options)
	end
end

function WIDGET:insertCenter(text, options)
	-- Insert a string with appropriate white space padding and functions.
	if type(text) == 'table' then -- color from the data overrides color profiles
		options.pen = text._color or colors.titleColor
		text = text._string or text._text or ''
	end
	local penC  = options.pen or self.Colors.titleColor
	local keyC  = options.keyColor or self.Colors.keyColor
	local width = options.width or 40
 
	local temp_text = {}
	if self.Keyed then
		fnct  = self.Keyed[1]
		key   = self.Keyed[2]
		local key_str = (key:upper() == key) and "CUSTOM_SHIFT_"..key or "CUSTOM_"..key:upper()
		s1, s2, s3 = center(text,width,true)
		local x = s1:find(key)
		if x then
			table.insert(temp_text, {text=s2, width=#s2, pen=penC})
			table.insert(temp_text, {text=s1:sub(1,x-1), width=x-1, pen=penC})
			table.insert(temp_text, {key=key_str, on_activate=fnct, key_pen=keyC})
			table.insert(temp_text, {text=s1:sub(x+1,#s1), width=#s1-x, pen=penC})
			table.insert(temp_text, {text=s3, width=#s3, pen=penC})
		else
			table.insert(temp_text, {text=s2..s1..s3, width=width, pen=penC})
		end
	else
		table.insert(temp_text, {text=center(text,width), width=width, pen=penC})
	end

	table.insert(self.Input, {text = temp_text})
end

function WIDGET:insertText(text, options)
	-- Insert a block of text. If the text is larger than the width of
	-- the widget, the text will be wrapped
	local text = text or ""
	local rjustify = options.rjustify or false
	local pen      = options.pen or self.Colors.textColor
	local width    = options.width or 40
 
	if #text/width <= 1 then
		table.insert(self.Input, {text = {
			{text=text, pen=pen, width=width, rjustify=rjustify}}})
	else
		local wordList = split(text," ")
		local lineLength = 0
		local line = ""
		for _,word in pairs(wordList) do
			local wordLength = #word + 1
			lineLength = lineLength + wordLength
			if lineLength > width then
				table.insert(self.Input, {text = {
					{text=line, pen=pen, width=width, rjustify=rjustify}}})
				lineLength = wordLength
				line = ""
			end
			line = line..word.." "
		end
	end
end

function WIDGET:insertHeader(text, options)
	local text = text or ""
	local filling = options.filling or "second"
	local width   = options.width   or 40
	local pens = {
		penHead = self.Colors.headColor,
		penNums = self.Colors.numColor,
		penText = self.Colors.textColor,
		penFlag = self.Colors.flagColor,
		penFalse= self.Colors.falseColor}
			
	if options.replacement then
		text = reqscript("functions/text").listReplacement(text, options.replacement, options.replaceHeader)
	end
	
	local function insert(outStr, k, tbl)
		local check = true
		if type(tbl) == type(table) then
			if type(tbl._second) == type(table) then
				for first, second in pairs(tbl._second) do
					local header = (check) and tbl._header or ""
					local flagStr = (filling == "first"  or filling == "flag")   and "" or " ["..first.."]"
					local fillStr = (filling == "second" or filling == "string") and "" or second
					local temp_text = parse_for_numbers(header, fillStr, width, pens, flagStr)
					table.insert(outStr, {text = temp_text})
					check = false
				end
			else
				if not tbl._second or tbl._second == "" or tbl._second == "--" then return outStr end
				local temp_text = parse_for_numbers(tbl._header, tbl._second, width, pens)
				table.insert(outStr, {text = temp_text})
			end
		elseif k and tbl then
			local temp_text = parse_for_numbers(k, tbl, width, pens)
			table.insert(outStr, {text = temp_text})
		end
		return outStr
	end
 
	if options.rowOrder then
		for i = 1, #options.rowOrder do
			local k = options.rowOrder[i]
			local tbl = text[k]
			self.Input = insert(self.Input, k, tbl)
		end
	elseif text._second then
		self.Input = insert(self.Input, nil, text)
	else
		for k, tbl in pairs(text) do
			self.Input = insert(self.Input, k, tbl)
		end
	end
end

function WIDGET:insertTable(list, options)
	local colors  = self.Colors
	local nohead     = options.nohead or false
	local width      = options.width or 40
	local token      = options.token
	local colOrder   = options.colOrder or {"_string"}
	local headOrder  = options.headOrder
	local abbrvs = reqscript("functions/text").textAbbreviations
 
	local hW = width
	local hWh = width
	local colwidth = getOptimalWidth(width, list, colOrder)
	local headwidth = {}
	for i,_ in pairs(colOrder) do
		hW = hW - colwidth[i]
	end
	if headOrder then
		headwidth = getOptimalWidth(width, list, headOrder)
		for i,_ in pairs(headOrder) do
			hWh = hWh - headwidth[i]
		end
	end
 
	if not nohead and not headOrder then -- Puts column headers
		local temp_text = {}
		table.insert(temp_text, {text=options.list_head or '', width=hW, pen=colors.headColor})
		for i = 1, #colOrder do
			local header = abbrvs[colOrder[i]] or colOrder[i]
			table.insert(temp_text, {text=header, rjustify=true, width=colwidth[i], pen=colors.colColor})
		end
		table.insert(input, {text=temp_text})
	end
 
	local function insert(outStr,k,tbl)
		local temp_str = {}
  
		if not nohead and headOrder then
			local temp_text = {}
			local listHead = tbl._listHead or tbl._title or ''
			table.insert(temp_text, {text=listHead, width=hWh, pen=colors.headColor})
			for i = 1, #headOrder do
				local header = abbrvs[headOrder[i]] or headOrder[i]
				table.insert(temp_text, {text=center(header,headwidth[i]), width=headwidth[i], pen=colors.colColor})
			end
			table.insert(outStr, {text=temp_text})
			hW = hWh
		end  
  
		local key = tbl._key or tostring(k)
		local title = tbl._title or key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
		if tbl._mark then title = tbl._mark..' '..title end
		if token     then key   = token..':'..key end
		local penHead = tbl._colorHeaders or colors.headColor
		local penNums = tbl._colorNumbers or colors.numColor
		local penText = tbl._colorText    or colors.textColor  
		if tbl._colorBin then 
			penNums = colors.binColors[tbl._colorBin]
			penText = colors.binColors[tbl._colorBin] 
		end
		table.insert(temp_str, {text=title, width=hW, token=key, pen=penText})
  
		local order = colOrder
		local listwidth = colwidth
		if headOrder then
			order = headOrder
			listwidth = headwidth
		end
		for i = 1, #order do
			local text = tbl[order[i]]
			local pen = penText
			if tonumber(text) then pen = penNums end
			temp_str = parse_for_numbers('',text,listwidth[i],{penHead=penHead,penNums=penNums,penText=penText},'',temp_str)
		end
		table.insert(outStr, {text=temp_str})
  
		if tbl._second and type(tbl._second) == 'table' then
			local lengthS = tbl._second._length or #tbl._second
			for iS = 0, lengthS do
				if tbl._second[iS] then
					local second = tbl._second[iS]
					if colOrder then
						local temp_text = {}
						local listHead = second._listHead or second._title or ''
						table.insert(temp_text, {text=' '..listHead, width=hW, pen=colors.subColor})
						for i = 1, #colOrder do
							local header = abbrvs[colOrder[i]] or colOrder[i]
							table.insert(temp_text, {text=center(header,colwidth[i]), width=colwidth[i], pen=colors.colColor})
						end
						table.insert(outStr, {text=temp_text})
					end     
   
					local lengthT = second._length or #second
					for iT = 0, lengthT do
						if second[iT] then
							local third = second[iT]
							temp_str = {}
							local key = third._key or tostring(iT)
							local title = third._title or key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
							if second._mark then title = third._mark..' '..title end
							if token     then key   = token..':'..key end
							local penHead = third._colorHeaders or colors.textColor
							local penNums = third._colorNumbers or colors.numColor
							local penText = third._colorText    or colors.textColor  
							if third._colorBin then 
								penNums = colors.binColors[third._colorBin]
								penText = colors.binColors[third._colorBin] 
							end
							title = '  '..title
							if type(third) == 'table' then
								table.insert(temp_str, {text=title, width=hW, token=key, pen=penHead})   
								for i = 1, #colOrder do
									local text = third[colOrder[i]]
									local pen = penText
									if tonumber(text) then pen = penNums end
									table.insert(temp_str, {text=center(tostring(text),colwidth[i]), width=colwidth[i], pen=pen})
								end
							else
								table.insert(temp_str, {text=title, width=#title, token=key, pen=penHead})   
								table.insert(temp_str, {text=third, rjustify=true, width=width-#title, pen=penText})
							end
							table.insert(outStr, {text=temp_str})
						end
					end
				end
			end
		end
		return outStr
	end
 
	if options.rowOrder then
		for j = 1, #options.rowOrder do
			local k = options.rowOrder[j]
			local tbl = list[k]
			self.Input = insert(self.Input,k,tbl)
		end
	else
		for k,tbl in pairs(list) do
			self.Input = insert(self.Input,k,tbl)
		end
	end
end

function WIDGET:insertList(list, options)
	local colors  = self.Colors
	local width      = options.width or 40
	local viewScreen = options.view_id
	local viewCell   = options.cell
	local token      = options.token
	local colOrder   = options.colOrder or {'_string'}
	local rowOrder   = options.rowOrder
 
	if not viewScreen or not viewCell then return input end
 
	local hW = width
	local colwidth = getOptimalWidth(width,list,colOrder)
	for i,_ in pairs(colOrder) do
		hW = hW - colwidth[i]
	end  
 
	local function insert(outStr,k,tbl)
		local temp_str = {}
		if type(tbl) ~= 'table' then return outStr end
		local key = tbl._key or tostring(k)
		local title = tbl._title or key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
		if tbl._mark then title = tbl._mark..' '..title end
		if token     then key   = token..':'..key end
		local penHead = tbl._colorHeaders or colors.headColor
		local penNums = tbl._colorNumbers or colors.numColor
		local penText = tbl._colorText    or colors.textColor  
		table.insert(temp_str, {text=title, width=hW, token=key, viewScreen=viewScreen, viewScreenCell=viewCell})
		for i = 1, #colOrder do
			local text = tbl[colOrder[i]]
			local pen = penText
			if tonumber(text) then pen = penNums end
			table.insert(temp_str, {text=center(tostring(text),colwidth[i]), width=colwidth[i], pen=pen})
		end
		table.insert(outStr, {text=temp_str, search_key=title})
		return outStr
	end
 
	if rowOrder then
		for j = 1, #rowOrder do
			local k = rowOrder[j]
			local tbl = list[k]
			self.Input = insert(self.Input,k,tbl)
		end
	else
		for k,tbl in pairs(list) do
			self.Input = insert(self.Input,k,tbl)
		end
	end
end