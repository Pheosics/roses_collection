local utils = require 'utils'
local split = utils.split_string
local strings = dfhack.script_environment('functions/text')
local ignoreStrings = {'=','!','*'}
local usages = {}

colorTables = {
  ['DEFAULT'] = {
    ['flagColor']  = COLOR_YELLOW,       -- Color to assign flags like [NOPAIN] when shown
    ['titleColor'] = COLOR_LIGHTCYAN,    -- Color of lines using the 'center' method
    ['headColor']  = COLOR_LIGHTMAGENTA, -- Color of headers in the 'header' and 'table' method
    ['subColor']   = COLOR_YELLOW,       -- Color of the sub headers in the 'header' method
    ['textColor']  = COLOR_WHITE,        -- Color of alphabetic characters and the color used for the 'text' method
    ['numColor']   = COLOR_LIGHTGREEN,   -- Base color of all numbers not assigned a color bin
    ['colColor']   = COLOR_LIGHTMAGENTA, -- Color of column headers for the 'table' method
    ['falseColor'] = COLOR_LIGHTRED,     -- Color used when requirements aren't met
    ['trueColor']  = COLOR_LIGHTGREEN,   -- Color used when requirements are met
    ['keyColor']   = COLOR_LIGHTRED,     -- Color of the keys used for titles that are "keyed"
    ['binColors']  = {                   -- Color overrides for textColor and numColor when assigned color bins
                      [-4] = COLOR_LIGHTMAGENTA,
                      [-3] = COLOR_LIGHTRED,
                      [-2] = COLOR_YELLOW,
                      [-1] = COLOR_BROWN,
                      [0]  = COLOR_GREY,
                      [1]  = COLOR_WHITE,
                      [2]  = COLOR_GREEN,
                      [3]  = COLOR_LIGHTGREEN,
                      [4]  = COLOR_LIGHTCYAN}},
  ['WHITE']    = {
    ['flagColor'] = COLOR_WHITE,
    ['titleColor'] = COLOR_WHITE,
    ['headColor']  = COLOR_WHITE,
    ['subColor']   = COLOR_WHITE,
    ['textColor']  = COLOR_WHITE,
    ['numColor']   = COLOR_WHITE,
    ['colColor']   = COLOR_WHITE,
    ['falseColor'] = COLOR_WHITE,
    ['trueColor']  = COLOR_WHITE,
    ['keyColor']   = COLOR_WHITE,
    ['binColors']  = {
                      [-4] = COLOR_WHITE,
                      [-3] = COLOR_WHITE,
                      [-2] = COLOR_WHITE,
                      [-1] = COLOR_WHITE,
                      [0]  = COLOR_WHITE,
                      [1]  = COLOR_WHITE,
                      [2]  = COLOR_WHITE,
                      [3]  = COLOR_WHITE,
                      [4]  = COLOR_WHITE}}
}
colorKey = 'DEFAULT'

--= Helper Functions
function tchelper(first, rest)
  return first:upper()..rest:lower()
end
function center(str, length, tuple)
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
function get_xy_cell(cols,rows,n,dir)
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
 local order = ordering or 'Alphabetical'
 local check = Type or 'Title'
 
 if type(order) == 'table' then
  orderOut = order
  for x,_ in pairs(tbl) do
   local present = false
   for _,y in pairs(order) do
    if x == y then present = true end
   end
   if not present then orderOut[#orderOut+1] = x end
  end
 else
  if order == 'Alphabetical' then
   if check == 'Key' then
    for x,_ in pairs(tbl) do
     orderOut[#orderOut+1] = x
    end
    table.sort(orderOut)
   elseif check == 'Title' then
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
function parse_for_numbers(h,s,width,pens,flag,inText)
 local outText = inText or {}
 local pens = pens or {}
 local flagStr = flag or ''
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
function checkValid(name,struct,token)
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
function parseFlags(flags,list)
 local info = list or {}
 
 for flag,bool in pairs(flags) do
  if bool and not tonumber(flag) then info[flag] = true end
 end
 
 return info
end
function getSpecialInfo(allTable,token)
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
function translateNumber(num,round)
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
  out = tostring(d)..'M'
 elseif num >= 10000 then
  a = tonumber(str:sub(#str-2,#str))
  b = a/1000
  b = math.floor(b*10 + 0.5)/10
  c = tonumber(str:sub(1,#str-3))
  d = c + b
  if round then d = math.floor(d) end
  out = tostring(d)..'k'
 elseif num >= 1000 then
  out = str:sub(1,1)..','..str:sub(2)
 end
 
 return out
end
function getOptimalWidth(width,info,list)
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

--= Widget Functions
usages[#usages+1] = [===[

insertWidgetInput
=================

methods
  center
    Purpose: Places a piece of text in the middle of the provided width
    Extras:  Can also add a function call with a key input when using the 'keyed' option
    Options: width, pen, kgc keyed
    
  text
    Purpose: Automatically wraps long strings to match the provided width
    Extras:  If provided as a table will look for String or Text for the string and Color as a seperate coloring
    Options: width, pen, rjustify
    
  header:
    Purpose: Make a key - value set of strings where a single key can have multiple values
    Extras:
    Options: width, pen, order, fill
    
  table:
    Purpose:
    Extras:
    Options: width, order, mark, token, list_head, hastitle, nohead, column_color, fgc, bgc
    
list

options
  bgc (COLOR_YELLOW)
  fgc (COLOR_LIGHTGREEN)
  kgc (COLOR_LIGHTRED)
  pen (COLOR_WHITE)
  cgc (COLOR_WHITE)
  nohead (false)
  hastitle (false)
  column_width (6)
  width (40)
  rjustify (false)
  list_head ('')
  token (nil)
  order (nil)
  keyed (nil)
  mark (nil)
  alternate (nil)
  fill ('')

view_id

]===]

function insertWidgetInput(input,method,list,options)
 if not list then return input end
 options = options or {}
 local colors = colorTables[colorKey]

 if method == 'center' then
  input = insertCenter(input,list,colors,options)

 elseif method == 'text' then -- Places text into multi-line output depending on length of strings and width of cell
  input = insertText(input,list,colors,options)

 elseif method == 'header' then
  input = insertHeader(input,list,colors,options)
  
 elseif method == 'table' then
  input = insertTable(input,list,colors,options)
  
 elseif method == 'list' then
  input = insertList(input,list,colors,options)
  
 end

 return input
end
function insertCenter(input,list,colors,options)
 local keyed   = options.keyed
 local pen     = colors.titleColor -- default color for the Center insert type is titleColor
 local width   = options.width or 40
 
 if type(list) == 'table' then -- color from the data overrides color profiles
  pen = list._color or colors.titleColor
  list = list._string or list._text or ''
 end
 list = list:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
 
 local temp_text = {}
 if keyed then
  fnct = keyed[1]
  key  = keyed[2]
  if key:upper() == key then
   key_str = 'CUSTOM_SHIFT_'..key
  else
   key_str = 'CUSTOM_'..key:upper()
  end
  s1, s2, s3 = center(list,width,true)
  temp_text = {}
  table.insert(temp_text, {text=s2, width=#s2, pen=pen})
  found = false
  for i = 1, #s1 do
   if s1:sub(i,i) == key and not found then
    table.insert(temp_text, {key=key_str, on_activate=fnct, key_pen=colors.keyColor})
    found = true
   else
    table.insert(temp_text, {text=s1:sub(i,i), width=1, pen=pen})
   end
  end
  table.insert(temp_text, {text=s3, width=#s3, pen=pen})
 else
  table.insert(temp_text, {text=center(list,width), width=width, pen=pen})
 end

 table.insert(input, {text = temp_text})
 return input
end
function insertText(input,list,colors,options)
 local rjustify = options.rjustify or false
 local pen = colors.textColor -- default color for the Text insert type is textColor
 local width   = options.width or 40
 
 if type(list) == 'table' then -- color from the data overrides color profiles
  if list._color then
   pen = list._color
  elseif list._colorBin then
   pen = colors.binColors[list._colorBin]
  end
  pen = pen or colors.textColor
  list = list._text or list._string or ''
 end
 
 local n = math.floor(#list/width) + 1
 if n == 1 then
  table.insert(input,{text = {{text=list:sub(1,1):upper()..list:sub(2), pen=pen, width=width, rjustify=rjustify}}})
 else
  local temp_text = {}
  local alist = split(list,' ')
  local l = 0
  local i = 1
  temp_text[i] = ''
  for _,t in pairs(alist) do
   l = l + #t + 1
   if l > width then
    i = i + 1
    l = #t+1
    temp_text[i] = ' '
   end
   temp_text[i] = temp_text[i]..t..' '
  end
  temp_text[1] = temp_text[1]:sub(1,1):upper()..temp_text[1]:sub(2)
  for i,second in pairs(temp_text) do
   table.insert(input,{text = {{text=second, pen=pen, width=width, rjustify=rjustify}}})
  end
 end
 
 return input
end
function insertHeader(input,list,colors,options)
 local order   = options.rowOrder
 local filling = options.filling    or 'second'
 local width   = options.width      or 40
 local replacement = options.replacement
 local replaceHeader = options.replaceHeader or ''
 
 local function insert(outStr,k,tbl)
  local temp_text = {}
  local penHead = colors.headColor
  local penNums = colors.numColor
  local penText = colors.textColor
  local penFlag = colors.flagColor
  if type(tbl) == 'table' then
   local penHead = tbl._colorHeaders or penHead
   local penNums = tbl._colorNumbers or penNums
   local penText = tbl._colorText    or penText
   if type(tbl._second) == 'table' then
    local check = true
    if tbl._length and tbl._length == 0 then return outStr end
    for first,second in pairs(tbl._second) do
     local header = ''
     local flagStr = ' ['..first..']'
     local fillStr = second:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
     if filling == 'first' or filling == 'flag' then
      fillStr = ''
     elseif filling == 'second' or filling == 'string' then
      flagStr = ''
     end
     if check then
      header = tbl._header:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
      check = false
     end
     local pens = {penHead=penHead,penNums=penNums,penText=penText,penFlag=penFlag,penFalse=colors.falseColor}
     temp_text = parse_for_numbers(header,fillStr,width,pens,flagStr)
     table.insert(outStr, {text = temp_text})
    end
   else
    if not tbl._second or tbl._second == '' or tbl._second == '--' then return outStr end
    local h = tbl._header:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
    local s = tostring(tbl._second):gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
    temp_text = parse_for_numbers(h,s,width,{penHead=penHead,penNums=penNums,penText=penText,penFlag=penFlag})
    table.insert(outStr, {text = temp_text})
   end
  elseif k and tbl then
   local h = tostring(k):gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   local s = tostring(tbl):gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   temp_text = parse_for_numbers(h,s,width,{penHead=penHead,penNums=penNums,penText=penText,penFlag=penFlag})
   table.insert(outStr, {text = temp_text})
  end
  
  return outStr
 end
 
 if replacement then
  local temp_list = {}
  local temp_list_length = 0
  for first,second in pairs(list) do
   local temp_first = replacement[first] or #temp_list + 1
   local temp_second = replacement[second] or #temp_list + 1
   if tonumber(temp_second) and not tonumber(temp_first) then
    temp_second = temp_first
    temp_first = first
   elseif tonumber(temp_first) and not tonumber(temp_second) then
    temp_first = second
   end
   if not tonumber(temp_second) and not tonumber(temp_first) then
    temp_list[temp_first] = temp_second
    temp_list_length = temp_list_length + 1
   end
  end
  list = {}
  list._header = replaceHeader
  list._second = temp_list
  list._length = temp_list_length
 end
 
 if order then
  for i = 1, #order do
   local k = order[i]
   local tbl = list[k]
   input = insert(input,k,tbl)
  end
 elseif list._second then
  input = insert(input,nil,list)
 else
  for k,tbl in pairs(list) do
   input = insert(input,k,tbl)
  end
 end
 
 return input
end
function insertTable(input,list,colors,options)
 local nohead     = options.nohead or false
 local width      = options.width or 40
 local token      = options.token
 local colOrder   = options.colOrder or {'_string'}
 local headOrder  = options.headOrder

 local abbrvs = {Syndrome='Syn', Strength='Str', Severity='Sev', Throat='Voice',
                 Penetration='Pen', Nausea='Nas', Velocity='Vel', Prepare='Prep', Recover='Rcvr',
                 Contact='Con', Duration='Dur', Probability='Prob'}
 
 local hW = width
 local hWh = width
 local colwidth = getOptimalWidth(width,list,colOrder)
 local headwidth = {}
 for i,_ in pairs(colOrder) do
  hW = hW - colwidth[i]
 end
 if headOrder then
  headwidth = getOptimalWidth(width,list,headOrder)
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
  
  --table.insert(outStr, {text=temp_str})
  return outStr
 end
 
 if options.rowOrder then
  for j = 1, #options.rowOrder do
   local k = options.rowOrder[j]
   local tbl = list[k]
   input = insert(input,k,tbl)
  end
 else
  for k,tbl in pairs(list) do
   input = insert(input,k,tbl)
  end
 end
 
 return input
end
function insertList(input,list,colors,options)
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
   input = insert(input,k,tbl)
  end
 else
  for k,tbl in pairs(list) do
   input = insert(input,k,tbl)
  end
 end
 
 return input
end

--=                      Journal Functions
usages[#usages+1] = [===[

]===]

--= Information Gathering Functions
function getJournalInfo(target,extras)
 local info = {}
 local vd = extras.ViewDetails
 
 info.Arts       = getJournalList(vd['artView'],      'Art')
 info.Buildings  = getJournalList(vd['buildingView'], 'Building')
 info.Creatures  = getJournalList(vd['creatureView'], 'Creature')
 info.Entities   = getJournalList(vd['entityView'],   'Entity')
 info.Inorganics = getJournalList(vd['inorganicView'],'Inorganic')
 info.Items      = getJournalList(vd['itemView'],     'Item')
 info.Organics   = getJournalList(vd['organicView'],  'Organic')
 info.Plants     = getJournalList(vd['plantView'],    'Plant')
 info.Products   = getJournalList(vd['productView'],  'Product')
 info.Reactions  = getJournalList(vd['reactionView'], 'Reaction')  
 --info.Religions  = getJournalList(vd['religionView'], 'Religion')
 info.Syndromes  = getJournalList(vd['syndromeView'], 'Syndrome')
 
 if extras.Systems.Class then info.Class_System = getJournalList(vd['classView'],'ClassSystem') end
 
 return info
end
function getJournalList(ViewDetails,Type)
 local info = {}
 local str = Type..' Compendium'
 info._description = ViewDetails.Description or str
 local sort = ViewDetails.filterFlags
 local listTypes = {}
 local Tables = {}
 local subTables = {}
 local badTables = {}
 
 if Type == 'Art' then
  Tables = {df.global.world.poetic_forms.all, df.global.world.musical_forms.all,
            df.global.world.dance_forms.all, df.global.world.scales.all, df.global.world.rhythms.all}
  for _,Table in pairs(Tables) do
   for _,artTable in pairs(Table) do
    artType = tostring(artTable._type):split(': ')[2]:split('>')[1]
    for _,flag in pairs(sort) do
     if flag == 'ALL' then -- No filters for arts
      info[flag] = info[flag] or {}
      info[flag][artType] = info[flag][artType] or {}
      info[flag][artType][artTable.id] = {}
      if artType == 'rhythm' or artType == 'scale' then
       name = artType..'_'..tostring(artTable.id)
      else
       name = dfhack.TranslateName(artTable.name)
      end
      info[flag][artType][artTable.id]._title = name
      info[flag][artType][artTable.id].ID = artTable.id
     end; end; end; end; end
 if Type == 'Building'  then
  Tables = {df.global.world.raws.buildings} -- all, workshops, and furnaces
  badTables['next_id'] = true
  for _,Table in pairs(Tables) do
   for bldgType,bldgTable in pairs(Table) do
    if not badTables[bldgType] then
     for j,bldg in pairs(bldgTable) do
      for _,flag in pairs(sort) do
       if not checkValid(bldg.name,bldg,bldg.code) then break end
       if flag == 'ALL' then  -- Right now there are no filters for buildings
        info[flag] = info[flag] or {}
        info[flag][bldgType] = info[flag][bldgType] or {}
        info[flag][bldgType][bldg.id] = {}
        info[flag][bldgType][bldg.id]._title = bldg.name
        info[flag][bldgType][bldg.id].ID = bldg.code
       end; end; end; end; end; end; end
 if Type == 'Creature'  then
  Tables = {df.global.world.raws.creatures.all}
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for _,Table in pairs(Tables) do
   for i,creature in pairs(Table) do
    for _,flag in pairs(sort) do
     if flag == 'ALL' or creature.flags[flag] then
      info[flag][creature.creature_id] = {}
      for j,caste in pairs(creature.caste) do
       info[flag][creature.creature_id][caste.caste_id] = {i,j}
      end; end; end; end; end; end
 if Type == 'Entity'    then
  Tables = {df.global.world.entities.all}
  listTypes = {['ALL'] = 'All'}
  for _,x in pairs(df.global.world.raws.entities) do
   if not x.flags.GENERATED then listTypes[x.code] = x.code end
  end
  for _,Table in pairs(Tables) do
   for _,entity in pairs(Table) do
    local entityRaw  = entity.entity_raw
    if not entityRaw.flags.GENERATED then
     local entityCode = entityRaw.code
     local name = dfhack.TranslateName(entity.name)
     for _,flag in pairs(sort) do
      if not checkValid(name,entity) then break end
      if flag == 'ALL' or entityRaw.flags[flag] then
       info[flag] = info[flag] or {}
       info[flag]['ALL'] = info[flag]['ALL'] or {}
       info[flag]['ALL'][entity.id] = {}
       info[flag]['ALL'][entity.id]._title = name
       info[flag]['ALL'][entity.id].ID     = entity.id
   
       info[flag][entityCode] = info[flag][entityCode] or {}
       info[flag][entityCode][entity.id] = {}
       info[flag][entityCode][entity.id]._title = name
       info[flag][entityCode][entity.id].ID     = entity.id
      end; end; end; end; end; end
 if Type == 'Inorganic' then
  Tables    = {df.global.world.raws.inorganics}
  listTypes = {['ALL']      = 'All',
               ['IS_STONE'] = 'Stones',
               ['IS_METAL'] = 'Metals',
               ['IS_GEM']   = 'Gems',
               ['IS_GLASS'] = 'Glass'}
                     
  for i,Table in pairs(Tables) do
   for _,object in pairs(Table) do -- object = df.inorganic
    tokenA = object.id
    for _,subobject in pairs({object.material}) do -- subobject = df.material
     token = 'INORGANIC:'..tokenA
     Types = {'ALL'}
     for flag,_ in pairs(listTypes) do
      if flag ~= 'ALL' then
       if subobject.flags[flag] then Types[#Types+1] = flag end
      end
     end
     for _,lType in pairs(Types) do
      name = dfhack.matinfo.toString(dfhack.matinfo.find(token))
      if not checkValid(name,token) then break end
      for _,flag in pairs(sort) do
       if flag == 'ALL' or object.flags[flag] then
        info[flag] = info[flag] or {}
        info[flag][lType] = info[flag][lType] or {}
        info[flag][lType]._title = listTypes[lType]
        info[flag][lType][token] = {}
        info[flag][lType][token]._title = name
        info[flag][lType][token].ID = token
       end; end; end; end; end; end; end
 if Type == 'Item'      then
  Tables = {df.global.world.raws.itemdefs}
  badTables['tools_by_type'] = true
  for _,Table in pairs(Tables) do
   for itemType,itemTable in pairs(Table) do
    if not badTables[itemType] then
     for j,item in pairs(itemTable) do
      for _,flag in pairs(sort) do
       if not checkValid(item.name,item) then break end
       local b = {}
       for k,v in pairs(item) do
        b[k] = v
       end
       name = b.name or ''
       adj  = b.adjective or ''
       if adj ~= '' then name = adj..' '..name end
       if flag == 'ALL' then  -- Right now there are no filters for items
        info[flag] = info[flag] or {}
        info[flag][itemType] = info[flag][itemType] or {}
        info[flag][itemType][item.id] = {}
        info[flag][itemType][item.id]._title = name:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
        info[flag][itemType][item.id].ID = j
       end; end; end; end; end; end; end
 if Type == 'Organic' or Type == 'Product' then
  if Type == 'Organic' then
   listTypes = {['Bone']       = 'Bone', --BONE
                ['Shell']      = 'Shell', --SHELL
                ['Tooth']      = 'Ivory', --TOOTH
                ['Horn']       = 'Horn', --HORN
                ['Pearl']      = 'Pearl', --PEARL
                ['Leather']    = 'Leather', --LEATHER
                ['Silk']       = 'Silk', --SILK
                ['Wood']       = 'Wood', --WOOD
                ['PlantFiber'] = 'Thread', --THREAD_PLANT
                ['Yarn']       = 'Yarn', --YARN
                ['Seed']       = 'Seeds', --SEED_MAT
                ['Leaf']       = 'Leaves'} --LEAF_MAT
  elseif Type == 'Product' then
   listTypes = {['PlantDrink']     = 'Plant Drink', --ALCOHOL_PLANT
                ['CreatureDrink']  = 'Creature Drink', --ALCOHOL_CREATURE
                ['PlantCheese']    = 'Plant Cheese', --CHEESE_PLANT
                ['CreatureCheese'] = 'Creature Cheese', --CHEESE_CREATURE
                ['PlantPowder']    = 'Plant Powder', --POWDER_MISC_PLANT
                ['CreaturePowder'] = 'Creature Powder', --POWDER_MISC_CREATURE
                ['PlantLiquid']    = 'Plant Liquid', --LIQUID_MISC_PLANT
                ['CreatureLiquid'] = 'Creature Liquid', --LIQUID_MISC_CREATURE
                ['MiscLiquid']     = 'Misc Liquid'} --LIQUID_MISC_OTHER

  end
  for matTable,_ in pairs(listTypes) do
   Tables[matTable]    = df.global.world.raws.mat_table.organic_types[matTable]
   subTables[matTable] = df.global.world.raws.mat_table.organic_indexes[matTable]
  end
  for typeTable,Table in pairs(Tables) do
   for j,typeID in pairs(Table) do
    local matinfo = dfhack.matinfo.decode(typeID,subTables[typeTable][j])
    local token   = matinfo:getToken()
    local title   = matinfo:toString()
    local object  = matinfo.creature or matinfo.plant
    local subobject = matinfo.material
    for _,flag in pairs(sort) do
     if not checkValid(title,token) then break end
     if flag == 'ALL' or subobject.flags[flag] then
      info[flag] = info[flag] or {}
      info[flag][typeTable] = info[flag][typeTable] or {}
      info[flag][typeTable]._title = listTypes[typeTable]
      info[flag][typeTable][token] = {}
      info[flag][typeTable][token]._title = title
      info[flag][typeTable][token].ID = token
     end; end; end; end; end
 if Type == 'Plant'     then
  Tables = {df.global.world.raws.plants}
  badTables['bushes_idx'] = true
  badTables['trees_idx'] = true
  badTables['grasses_idx'] = true
  for _,Table in pairs(Tables) do
   for plantType,plantTable in pairs(Table) do
    if not badTables[plantType] then
     for _,plant in pairs(plantTable) do
      for _,flag in pairs(sort) do
       if not checkValid(plant.name,plant) then break end
       if flag == 'ALL' or plant.flags[flag] then  
        info[flag] = info[flag] or {}
        info[flag][plantType] = info[flag][plantType] or {}
        info[flag][plantType][plant.id] = {}
        info[flag][plantType][plant.id]._title = plant.name
        info[flag][plantType][plant.id].ID = plant.index
       end; end; end; end; end; end; end
 if Type == 'Reaction'  then
  listTypes = {['ALL'] = 'All'}
  for _,category in pairs(df.global.world.raws.reactions.reaction_categories) do
   if checkValid(category.name) then listTypes[category.id] = category.name end
  end
  for _,reaction in pairs(df.global.world.raws.reactions.reactions) do
   for _,flag in pairs(sort) do
    if not checkValid(reaction.name,reaction) then break end
    info[flag] = info[flag] or {}
    if flag == 'ALL' or reaction.flags[flag] then
     info[flag].ALL = info[flag].ALL or {}
     info[flag].ALL._title = 'All'
     info[flag].ALL[reaction.code] = {}
     info[flag].ALL[reaction.code]._title = reaction.name
     info[flag].ALL[reaction.code].ID = reaction.index
     if listTypes[reaction.category] then
      info[flag][reaction.category] = info[flag][reaction.category] or {}
      info[flag][reaction.category]._title = listTypes[reaction.category]
      info[flag][reaction.category][reaction.code] = {}
      info[flag][reaction.category][reaction.code]._title = reaction.name
      info[flag][reaction.category][reaction.code].ID = reaction.index
     end; end; end; end; end
 if Type == 'Religion'  then
  -- Gods
  -- Powers
  -- Belief System
  -- Artifacts???
  -- Megabeasts and Semimegabeasts?
 end
 if Type == 'Syndrome' then
  Tables = {df.global.world.raws.syndromes.all,df.global.world.raws.interactions,
            df.global.world.raws.effects.all}
  for _,Table in pairs(Tables) do
   for _,typeTable in pairs(Table) do
    typeType = tostring(typeTable._type):split(': ')[2]:split('>')[1]
    typeType = typeType:gsub('creature_interaction_effect_','')
    for _,flag in pairs(sort) do
     if flag == 'ALL' then
      info[flag] = info[flag] or {}
      info[flag][typeType] = info[flag][typeType] or {}
      info[flag][typeType][typeTable.id] = {}
      if typeType == 'syndrome' then
       name = typeTable.syn_name
      elseif typeType == 'interaction' then
       name = typeTable.name
      else
       name = typeType..'_'..tostring(typeTable.id)
      end
      info[flag][typeType][typeTable.id]._title = name
      info[flag][typeType][typeTable.id].ID = typeTable.id
     end; end; end; end; end
 if Type == 'ClassSystem' then
  if not dfhack.findScript('base/roses-table') then return end
  roses = dfhack.script_environment('base/roses-table').roses
  local classTable = roses.ClassTable
  local featTable  = roses.FeatTable
  local spellTable = roses.SpellTable
  
  info.ALL = {} -- For now we won't filter the ClassSystem -ME
  info.ALL.Classes = {}
  for x,_ in pairs(classTable) do
   info.ALL.Classes[x] = {}
   info.ALL.Classes[x]._title = classTable[x].Name
  end
  info.ALL.Feats = {}
  for x,_ in pairs(featTable) do
   info.ALL.Feats[x] = {}
   info.ALL.Feats[x]._title = featTable[x].Name
  end
  info.ALL.Spells = {}
  for x,_ in pairs(spellTable) do
   info.ALL.Spells[x] = {}
   info.ALL.Spells[x]._title = spellTable[x].Name
  end
 end
 
 info._stats = {}
 if Type == 'Creature' then
  for _,flag in pairs(sort) do
   info._stats[flag] = 0
   for _,_ in pairs(info[flag]) do
    info._stats[flag] = info._stats[flag] + 1
   end
   info._stats[flag] = tostring(info._stats[flag])
  end  
 else
  for lType,_ in pairs(info.ALL) do
   x = 0 -- Start at -1 for the _title entry
   for _,_ in pairs(info.ALL[lType]) do
    x = x + 1
   end
   info._stats[lType] = {}
   info._stats[lType]._header = listTypes[lType] or lType
   info._stats[lType]._second = x
  end
 end
 
 return info
end
function getArtInfo()
end
function getBuildingInfo(bldgRaw,system)
 local info  = {}
 local n = 0
 local enhancedRaw = {}
 if system then -- Enhanced Building system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
  if roses and roses.EnhancedBuildingTable[bldgRaw.code] then
   enhancedRaw = roses.EnhancedBuildingTable[bldgRaw.code]
  end
 end
 
 -- Vanilla building entries
 info.Name = {}
 info.Name._color = {fg=bldgRaw.name_color[0],bg=bldgRaw.name_color[1],bold=bldgRaw.name_color[2]}
 info.Name._string = bldgRaw.name

 info.Dimensions = tostring(bldgRaw.dim_x)..' by '..tostring(bldgRaw.dim_y)
 info.Build_Labor = bldgRaw.labor_description
 info.BuildItems = {}
 for i,item in pairs(bldgRaw.build_items) do
  info.BuildItems[i] = {}
  info.BuildItems[i]._listHead = 'Quantity'
  info.BuildItems[i]._title = tostring(item.quantity)
  if item.mat_type == -1 then
   info.BuildItems[i].Material = 'Any'
  else
   info.BuildItems[i].Material = dfhack.matinfo.decode(item.mat_type,item.mat_index):toString()
   info.BuildItems[i].Material = info.BuildItems[i].Material:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  end
  if item.item_type >= 0 and item.item_subtype >= 0 then
   info.BuildItems[i].Item = dfhack.items.getSubtypeDef(item.item_type,item.item_subtype).name
  else
   info.BuildItems[i].Item = df.item_type[item.item_type]
  end
  info.BuildItems[i].Item  = info.BuildItems[i].Item:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  info.BuildItems[i]._second = {}
  info.BuildItems[i]._second[1] = {}
  info.BuildItems[i]._second[1]._listHead = 'Flags'
  n = 0
  for flag,bool in pairs(item.flags1) do
   if bool then
    n = n + 1
    info.BuildItems[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  for flag,bool in pairs(item.flags2) do
   if bool then
    n = n + 1
    info.BuildItems[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  for flag,bool in pairs(item.flags3) do
   if bool then
    n = n + 1
    info.BuildItems[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
 end
 
 info.Reactions = {}
 info.Reactions._header = 'Reactions'
 info.Reactions._second = {}
 n = 0
 for _,reaction in pairs(df.global.world.raws.reactions.reactions) do
  for i,id in pairs(reaction.building.custom) do
   if id ~= -1 then
    ctype = id
    mtype = reaction.building.type[i]
    stype = reaction.building.subtype[i]
    if ctype == bldgRaw.id and mtype == bldgRaw.building_type and stype == bldgRaw.building_subtype then
     n = n + 1
     info.Reactions._second[n] = reaction.name
     break
    end
   end
  end
 end

 -- Enhanced Building System entries
 info.Description = enhancedRaw.Description or ''
 info.Required_Magma_Depth = enhancedRaw.RequiredMagma or tostring(bldgRaw.needs_magma)
 if info.Required_Magma_Depth:upper() == 'FALSE' then info.Required_Magma_Depth = '0' end
 if info.Required_Magma_Depth:upper() == 'TRUE'  then info.Required_Magma_Depth = '1' end
 info.Required_Water_Depth = enhancedRaw.RequiredWater or '0'
 info.Number_of_floors = enhancedRaw.MultiStory or '1'
 info.Outside_Only = enhancedRaw.OutsideOnly
 info.Inside_Only  = enhancedRaw.InsideOnly
 
 return info
end
function getCreatureInfo(creatureRaw,casteRaw,system)
 local info  = {}
 local n = 0
 local enhancedRaw = {}
 if system then -- Enhanced Creature system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
  if roses and roses.EnhancedCreatureTable[creatureRaw.creature_id] then
   if roses.EnhancedCreatureTable[creatureRaw.creature_id][casteRaw.caste_id] then
    enhancedRaw = roses.EnhancedCreatureTable[creatureRaw.creature_id][casteRaw.caste_id]
   end
  end
 end
 
 info.Name = {}
 info.Name._color = {fg=creatureRaw.color[0],bg=creatureRaw.color[1],bold=creatureRaw.color[2]}
 info.Name._string = creatureRaw.name[0]
 
 info.CasteName = {}
 info.CasteName._color = {fg=casteRaw.caste_color[0],bg=casteRaw.caste_color[1],bold=casteRaw.caste_color[2]}
 info.CasteName._string = casteRaw.caste_name[0]
 if info.Name == info.CasteName then 
  if casteRaw.gender == 0 then
   info.CasteName = 'Female '..info.CasteName
  elseif casteRaw.gender == 1 then
   info.CasteName = 'Male '..info.CasteName
  end
 end
 
 info.Flags = parseFlags(creatureRaw.flags)
 info.Flags = parseFlags(casteRaw.flags,info.Flags)

 -- Get rid of unnecessary flags
 local flagPairs = {['AMPHIBIOUS'] = 'AQUATIC',
                    ['SWIMS_LEARNED'] = 'SWIMS_INNATE',
                    ['SWIMS_INNATE']  = 'UNDERSWIM',
                    ['IMMOBILE_LAND'] = 'IMMOBILE',
                    ['CURIOUSBEAST_ITEM'] = 'CURIOUSBEAST_ANY',
                    ['CURIOUSBEAST_GUZZLER'] = 'CURIOUSBEAST_ANY',
                    ['CURIOUSBEAST_EATER'] = 'CURIOUSBEAST_ANY',
                    ['CARNIVORE'] = 'BONECARN'}
 for flagA,flagB in pairs(flagPairs) do
  if info.Flags[flagA] and info.Flags[flagB] then info.Flags[flagA] = nil end
 end
 
 -- Treat biomes special so we can accurately grab things like [BIOME:NOT_FREEZING]
 info.Biome = {}
 for _,line in pairs(creatureRaw.raws) do
  if split(line.value,':')[1] == '[BIOME' then
   info.Biome[split(split(line.value,':')[2],']')[1]] = true
  end
 end
 
 info.PopNumbers = {}
 if casteRaw.misc.maxage_max > 0 then
  info.PopNumbers.Maximum_Age = tostring(casteRaw.misc.maxage_max)..' years'
 else
  info.PopNumbers.Maximum_Age = 'Unknown'
 end
 info.PopNumbers.Frequency = tostring(creatureRaw.frequency)..' %'
 info.PopNumbers.Caste_Frequency = tostring(casteRaw.misc.pop_ratio)..' %'
 if creatureRaw.cluster_number[1] == creatureRaw.cluster_number[0] then
  info.PopNumbers.Group_Size = creatureRaw.cluster_number[1]
 else
  info.PopNumbers.Group_Size = tostring(creatureRaw.cluster_number[1])..' to '..tostring(creatureRaw.cluster_number[0])
 end
 info.PopNumbers.Population_Size = tostring(creatureRaw.population_number[1])..' to '..tostring(creatureRaw.population_number[0])
 
 info.StatNumbers = {}
 info.StatNumbers.Speed = {}
 for _,gait in pairs({'WALK','FLY','SWIM','CLIMB','CRAWL'}) do
  local speed = dfhack.script_environment('functions/unit').getSpeed(casteRaw,gait)
  if speed then
   info.StatNumbers.Speed[gait] = {}
   info.StatNumbers.Speed[gait]._header = 'Max '..gait:lower()..'ing speed'
   info.StatNumbers.Speed[gait]._second = tostring(speed)..' km/h'
  end
 end
 info.StatNumbers.Adult_Size = tostring(casteRaw.misc.adult_size/100.0)..' kg'
 
 info.Attacks = {}
 info.Attacks._header = 'Attacks'
 info.Attacks._second = {}
 for _,attack in pairs(casteRaw.body_info.attacks) do
  local verb = attack.verb_2nd
  info.Attacks._second[verb] = verb -- using verb instead of n means we won't get 5 coupies of Scratch
 end

 info.Interactions = {}
 info.Interactions._header = 'Interactions'
 info.Interactions._second = {}
 n = 0
 for _,interaction in pairs(casteRaw.body_info.interactions) do
  n = n + 1
  info.Interactions._second[n] = interaction.interaction.adv_name
 end
 if n == 0 then info.Interactions._second[1] = 'None' end
 
 info.Products = {}
 info.Products._header = 'Products'
 info.Products._second = {}
 n = 0
 if casteRaw.extracts.milkable_mat >= 0 then
  matinfo = dfhack.matinfo.decode(casteRaw.extracts.milkable_mat,casteRaw.extracts.milkable_matidx)
  if matinfo and matinfo:toString() then
   n = n + 1
   info.Products._second[n] = matinfo:toString()
  end
 end
 if casteRaw.extracts.webber_mat >= 0 then
  matinfo = dfhack.matinfo.decode(casteRaw.extracts.webber_mat,casteRaw.extracts.webber_matidx)
  if matinfo and matinfo:toString() then
   n = n + 1
   info.Products._second[n] = matinfo:toString()
  end
 end
 for i,matid in pairs(casteRaw.extracts.egg_material_mattype) do
  matinfo = dfhack.matinfo.decode(matid,casteRaw.extracts.egg_material_matindex[i])
  if matinfo and matinfo:toString() then
   n = n + 1
   info.Products._second[n] = matinfo:toString()
  end
 end 
 for i,matid in pairs(casteRaw.extracts.lays_unusual_eggs_mattype) do
  matinfo = dfhack.matinfo.decode(matid,casteRaw.extracts.lays_unusual_eggs_matindex[i])
  iteminfo = dfhack.items.getSubtypeDef(lays_unusual_eggs_itemtype[i],lays_unusual_eggs_itemsubtype[i])
  if matinfo and matinfo:toString() and iteminfo then
   n = n + 1
   info.Products._second[n] = matinfo:toString()..' '..iteminfo.name
  end
 end   
 --if n == 0 then info.Products._second[1] = 'None' end
 
 info.Extracts = {}
 info.Extracts._header = 'Extracts'
 info.Extracts._second = {}
 n = 0
 for i,matid in pairs(casteRaw.extracts.extract_mat) do
  matinfo = dfhack.matinfo.decode(matid,casteRaw.extracts.extract_matidx[i])
  if matinfo and matinfo:toString() then
   n = n + 1
   info.Extracts._second[n] = matinfo:toString()
  end
 end
 --if n == 0 then info.Extracts._second[1] = 'None' end
 
 info.Secretions = {}
 info.Secretions._header = 'Secretions'
 info.Secretions._second = {}
 n = 0
 for i,secretion in pairs(casteRaw.secretion) do
  matinfo = dfhack.matinfo.decode(secretion.mat_type,secretion.mat_index)
  if matinfo and matinfo:toString() then
   n = n + 1
   info.Secretions._second[n] = matinfo:toString()
  end
 end
 --if n == 0 then info.Extracts._second[1] = 'None' end

 local matFlags = {MEAT=true,BONE=true,TOOTH=true,HORN=true,LEATHER=true,YARN=true}
 info.Materials = {}
 for _,mat in pairs(creatureRaw.tissue) do
  matinfo = dfhack.matinfo.decode(mat.mat_type,mat.mat_index)
  if matinfo then
   for flag,_ in pairs(matFlags) do
    if matinfo.material.flags[flag] then
     info.Materials[flag] = info.Materials[flag] or {}
     info.Materials[flag]._header = flag
     info.Materials[flag]._second = info.Materials[flag]._second or {}
     info.Materials[flag]._second[#info.Materials[flag]._second+1] = matinfo:toString()
    end
   end
  end
 end
 
 info.Description = casteRaw.description
 
 return info
end
function getEntityInfo(entity,system)
 local info = {}
 local n = 0
 entityRaw = entity.entity_raw
 if system then -- Civilization system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
 -- if roses and roses.CivilizationTable[creatureRaw.creature_id] then
 --  if roses.EnhancedCreatureTable[creatureRaw.creature_id][casteRaw.caste_id] then
 --   enhancedRaw = roses.EnhancedCreatureTable[creatureRaw.creature_id][casteRaw.caste_id]
 --  end
 -- end
 end 
 
 info.Name = dfhack.TranslateName(entity.name)
 info.Flags = parseFlags(entityRaw.flags)
 
 info.Religion = {}
 info.Religion.Spheres = {}
 info.Religion.Spheres._header = 'Spheres'
 info.Religion.Spheres._second = {}
 for i,x in pairs(entityRaw.religion_sphere) do
  info.Religion.Spheres._second[i] = df.sphere_type[x]
 end
 
 info.Positions = {}
 for i,position in pairs(entityRaw.positions) do
  info.Positions[i] = {}
  info.Positions[i]._listHead = 'Position'
  info.Positions[i]._title = position.name[0]
  info.Positions[i].Precedence = position.precedence
  info.Positions[i]._second = {}
  info.Positions[i]._second[1] = {}
  info.Positions[i]._second[1]._listHead = 'Responsibilities'
  n = 0
  for flag,bool in pairs(position.responsibilities) do
   if bool and not tonumber(flag) then
    n = n + 1
    info.Positions[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  if n == 0 then info.Positions[i]._second[1][1] = 'None' end
 end
 
 info.Buildings = {}
 info.Buildings._header = 'Buildings'
 info.Buildings._second = {}
 for i,x in pairs(entityRaw.workshops.permitted_building_id) do
  info.Buildings._second[i] = df.global.world.raws.buildings.all[x].name
 end

 info.Reactions = {}
 info.Reactions._header = 'Reactions'
 info.Reactions._second = {}
 for i,x in pairs(entityRaw.workshops.permitted_reaction_id) do
  info.Reactions._second[i] = df.global.world.raws.reactions.reactions[x].name
 end

 info.Values = {}
 n = 0
 for i,x in pairs(entity.resources.values) do
  if df.value_type[i] then
   local val = {}
   val.type = df.value_type[i]
   val.strength = x
   n = n + 1
   info.Values[n] = {}
   info.Values[n]._key     = df.value_type[val.type]
   info.Values[n].Type     = df.value_type[val.type]
   info.Values[n].Strength = val.strength
   info.Values[n]._string, info.Values[n]._colorBin  = strings.value_string(val)
  end
 end
  
 info.Ethics = {}
 n = 0
 for i,x in pairs(entity.resources.ethic) do
  n = n + 1
  info.Ethics[n] = {}
  info.Ethics[n]._key = i
  info.Ethics[n]._title = i:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  info.Ethics[n].Value = df.ethic_response[x]:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
 end
 
 return info
end
function getInorganicInfo(inorganicMatInfo,system)
 local info = {}
 local n = 0
 local inorganicRaw = inorganicMatInfo.inorganic
 local materialRaw = inorganicMatInfo.material
 local enhancedRaw = {}
 if system then -- Enhanced Material system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
  if roses and roses.EnhancedMaterialTable['INORGANIC:'..inorganicRaw.id] then
   enhancedRaw = roses.EnhancedMaterialTable['INORGANIC:'..inorganicRaw.id]
  end
 end
 local mat_id = inorganicMatInfo.index

 info.Name = {}
 info.Name._color = COLOR_WHITE
 info.Name._string = inorganicMatInfo:toString()
 info.Description = enhancedRaw.Description or ''
 
 info.Alloy = {}
 info.Alloy._header = ''
 info.Alloy._second = {}
 n = 0
 for _,reaction in pairs(df.global.world.raws.reactions.reactions) do
  for _,product in pairs(reaction.products) do
   if product.mat_type == 0 and product.mat_index == mat_id then
    local alloy_string = ''
    for _,reagent in pairs(reaction.reagents) do
     matinfo = dfhack.matinfo.decode(reagent.mat_type,reagent.mat_index)
     if matinfo then
      matstring = matinfo:toString()
      alloy_string = alloy_string..matstring..', '
     end
    end
    if alloy_string ~= '' then
     n = n + 1
     alloy_string = strings.fixString(alloy_string)
     info.Alloy._second[n] = alloy_string
    end
    break
   end
  end
 end
 if n == 0 then info.Alloy._second[1] = 'None' end
 local n_alloy = n
 
 info.Environment = {}
 info.Environment._header = ''
 info.Environment._second = {}
 n = 0
 if inorganicRaw.flags then
  for flag,bool in pairs(inorganicRaw.flags) do
   if bool and strings.inorganicFlags.ENVIRONMENT_FLAGS[flag] then
    n = n + 1
    info.Environment._second[n] = strings.inorganicFlags.ENVIRONMENT_FLAGS[flag]..' environments'
   end
  end
 end
 if inorganicRaw.environment then
  for i,id in pairs(inorganicRaw.environment.location) do
   local probability = inorganicRaw.environment.probability[i]
   local environment = df.environment_type[id]:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   local inclusion = df.inclusion_type[inorganicRaw.environment.type[i]]
   if inclusion then
    n = n + 1
    if inclusion == 'VEIN' then inclusion = 'veins' end
    if inclusion == 'CLUSTER' then inclusion = 'clusters' end
    if inclusion == 'CLUSTER_SMALL' then inclusion = 'small clusters' end
    if inclusion == 'CLUSTER_ONE' then inclusion = 'single tiles' end
    info.Environment._second[n] = inclusion..' in '..environment..' environments'
   end
  end
 end
 if inorganicRaw.environment_spec then
  for i,id in pairs(inorganicRaw.environment_spec.mat_index) do
   local matstring = dfhack.matinfo.decode(0,id):toString()
   local inclusion = df.inclusion_type[inorganicRaw.environment_spec.inclusion_type[i]]
   local probability = inorganicRaw.environment_spec.probability[i]
   if inclusion then
    n = n + 1
    if inclusion == 'VEIN' then inclusion = 'veins' end
    if inclusion == 'CLUSTER' then inclusion = 'clusters' end
    if inclusion == 'CLUSTER_SMALL' then inclusion = 'small clusters' end
    if inclusion == 'CLUSTER_ONE' then inclusion = 'single tiles' end
    info.Environment._second[n] = inclusion..' in '..matstring
   end
  end
 end
 for j,inorganic in pairs(df.global.world.raws.inorganics) do
  for i,id in pairs(inorganic.metal_ore.mat_index) do
   if id == mat_id then
    n = n + 1
    local probability = inorganic.metal_ore.probability[i]
    local matstring = dfhack.matinfo.decode(0,j):toString()
    info.Environment._second[n] = probability..'% of '..matstring..' ore'
   end
  end
 end
 if n == 0 then 
  if n_alloy == 0 then
   info.Environment._second[1] = 'Unknown'
  else
   info.Environment._second[1] = 'Alloy Material'
  end
 end
 
 info.Ore = {}
 info.Ore._header = ''
 info.Ore._second = {}
 n = 0
 if inorganicRaw.metal_ore then
  for i,id in pairs(inorganicRaw.metal_ore.mat_index) do
   n = n + 1
   local matstring = dfhack.matinfo.decode(0,id):toString()
   local probability = inorganicRaw.metal_ore.probability[i]
   info.Ore._second[n] = probability..'% '..matstring
  end
 end
 if n == 0 then info.Ore._second[1] = 'None' end
 
 info.Material = getMaterialInfo(materialRaw)
 
 -- Enhanced Material System entries
 info.Description = enhancedRaw.Description or ''
 
 return info
end
function getItemInfo(itemRaw,system)
 local info  = {}
 local n = 0
 local enhancedRaw = {}
 --if Type then -- Enhanced Item system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
  if roses and roses.EnhancedItemTable[itemRaw.id] then
   enhancedRaw = roses.EnhancedItemTable[itemRaw.id]
  end
 --end
 
 local b = {}
 for k,v in pairs(itemRaw) do
  b[k] = v
 end
 
 -- Vanilla Stuff
 local name = b.name or ''
 local adj = b.adjective or ''
 if adj ~= '' then name = adj..' '..name end
 info.Name = name:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
 info.Value = b.value or '--'
 info.Size = b.size
 info.Mat_Size = b.material_size
 if b.minimum_size then info.Min_Size = tostring(b.minimum_size/100.0)..' kg' end
 if b.two_handed then info.Two_Hand_Size = tostring(b.two_handed/100.0)..' kg' end
 info.Description = b.description or ''
 info.Capacity = b.container_capacity
 info.Armor_Level = b.armorlevel
 if b.props then
  info.Layer = b.props.layer
  info.Layer_Size = b.props.layer_size
  info.Layer_Permit = b.props.layer_permit
  info.Coverage = b.props.coverage 
  info.Flags = parseFlags(b.flags)
 end
 info.UB_Step = b.ubstep
 info.UP_Step = b.upstep
 info.LB_Step = b.lbstep
 info.Block_Chance = b.blockchance
 if b.flags then info.Flags = parseFlags(b.flags,info.Flags) end
 if b.skill_melee and df.job_skill[b.skill_melee] then info.Melee_Skill = df.job_skill[b.skill_melee] end
 if b.skill_ranged and b.skill_ranged >= 0 then 
  info.Range_Skill = df.job_skill[b.skill_ranged]
  info.Shot_Force = b.shoot_force
  info.Shot_Velocity = b.shoot_maxvel
  info.Ammo = b.ranged_ammo
 end
 if b.attacks then
  info.Attacks = {}
  n = 0
  for i,attack in pairs(itemRaw.attacks) do
   n = n + 1
   info.Attacks[i] = {}
   info.Attacks[i]._title = attack.verb_2nd
   info.Attacks[i].Contact = translateNumber(attack.contact,true)
   info.Attacks[i].Penetration = translateNumber(attack.penetration,true)
   info.Attacks[i].Velocity = translateNumber(attack.velocity_mult,true)
   info.Attacks[i].Prepare = attack.prepare
   info.Attacks[i].Recover = attack.recover
   if attack.edged then
    info.Attacks[i]._mark = '(E)'
   end
  end
  if n == 0 then 
   info.Attacks = nil
   info.MeleeSkill = nil
  end
 end
 info.Ammo_Class = b.ammo_class
 if b.tool_use then
  info.Uses = {}
  info.Uses._header = 'Tool Uses'
  info.Uses._second = {}
  for i,x in pairs(b.tool_use) do
   info.Uses._second[i] = df.tool_uses[x]
  end
 end    
 info.Type = tostring(itemRaw):split(':')[1]:split('_')[2]:sub(1,-3)
 info.Type = info.Type:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
 
 -- Enhanced Stuff
 info.Description = enhancedRaw.Description or ''
 info.Class = enhancedRaw.Class
 local onTables = {'OnEquip','OnAttack'}
 for _,t in pairs(onTables) do
  if enhancedRaw[t] then
   info[t] = {}
   for k,v in pairs(enhancedRaw[t]) do
    if k:find('Attacker') then
     q,w = k:find('Attacker')
     x = k:sub(q,w)..' '..k:sub(w+1)
    elseif k:find('Defender') then
     q,w = k:find('Defender')
     x = k:sub(q,w)..' '..k:sub(w+1)
    else
     x = k
    end
    if type(v) == 'table' then
     info[t][k] = {}
     info[t][k]._header = x..' Change'
     info[t][k]._second = {}
     n = 0
     for a,b in pairs(v) do
      n = n + 1
      c = b
      if tonumber(b) and tonumber(b) > 0 then c = '+'..tostring(c) end
      info[t][k]._second[n] = tostring(c)..' '..tostring(a)
     end  
    else
     if k == 'Chance' and tonumber(v) == 100 then
      --continue
     else
      info[t][k] = {}
      info[t][k]._header = x
      info[t][k]._second = v
     end      
    end
   end
  end
 end
 
 return info
end
function getMaterialInfo(material)
 local info = {}
 local n = 0
 
 info.BaseStats = {}
 --info.BaseStats._rowOrder = {}
 if material.solid_density       > 0 then info.BaseStats.Solid_Density  = material.solid_density       end
 if material.liquid_density      > 0 then info.BaseStats.Liquid_Density = material.liquid_density      end
 if material.molar_mass          > 0 then info.BaseStats.Molar_Mass     = material.molar_mass          end
 if material.material_value      > 0 then info.BaseStats.Value          = material.material_value      end
 if material.strength.absorption > 0 then info.BaseStats.Absorption     = material.strength.absorption end
 if material.strength.max_edge   > 0 then info.BaseStats.Max_Edge       = material.strength.max_edge   end
 for k,v in pairs(info.BaseStats) do
  info.BaseStats[k] = translateNumber(v)
  if k == 'Value' then info.BaseStats[k] = tostring(info.BaseStats[k])..' Urists' end
 end
 
 info.Temperature = {}
 --info.Temperature._rowOrder = {}
 if material.heat.spec_heat      > 0 then info.Temperature.Specific_Heat = material.heat.spec_heat      end
 if material.heat.ignite_point   > 0 then info.Temperature.Ignite_Point  = material.heat.ignite_point   end
 if material.heat.melting_point  > 0 then info.Temperature.Melting_Point = material.heat.melting_point  end
 if material.heat.boiling_point  > 0 then info.Temperature.Boiling_Point = material.heat.boiling_point  end
 if material.heat.mat_fixed_temp > 0 then info.Temperature.Fixed_Temp    = material.heat.mat_fixed_temp end
 if material.heat.heatdam_point  > 0 then info.Temperature.Heat_Damage   = material.heat.heatdam_point  end
 if material.heat.colddam_point  > 0 then info.Temperature.Cold_Damage   = material.heat.colddam_point  end
 for k,v in pairs(info.Temperature) do
  info.Temperature[k] = translateNumber(v)
 end
 
 info.Strength = {}
 info.Strength._rowOrder = {'BENDING','SHEAR','TORSION','IMPACT','TENSILE','COMPRESSIVE'}
 info.Strength._colOrder = {'Yield','Strain','Fracture'}
 for t,v in pairs(material.strength.yield) do
  info.Strength[t] = {}
 end
 for t,v in pairs(material.strength.yield) do
  info.Strength[t].Yield = translateNumber(v)
 end
 for t,v in pairs(material.strength.fracture) do
  info.Strength[t].Fracture = translateNumber(v)
 end
 for t,v in pairs(material.strength.strain_at_yield) do
  info.Strength[t].Strain = translateNumber(v)
 end
 
 info.Syndromes = {}
 for i,syndrome in pairs(material.syndrome) do
  info.Syndromes[i] = {}
  info.Syndromes[i]._listHead = 'Syndrome'
  info.Syndromes[i]._title = syndrome.syn_name:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  info.Syndromes[i].Injected = tostring(syndrome.flags.SYN_INJECTED)
  info.Syndromes[i].Inhaled = tostring(syndrome.flags.SYN_INHALED)
  info.Syndromes[i].Ingested = tostring(syndrome.flags.SYN_INGESTED)
  info.Syndromes[i].Contact = tostring(syndrome.flags.SYN_CONTACT)
  info.Syndromes[i]._second = {}
  info.Syndromes[i]._second[1] = {}
  info.Syndromes[i]._second[1]._listHead = 'Syndrome Effects'
  n = 0
  for _,effect in pairs(syndrome.ce) do
   a = split(tostring(effect),'creature_interaction_effect_')[2]
   if a then
    a = split(a,'st:')[1]
    if a ~= 'flash_symbol' and a ~= 'display_name' and a ~= 'phys_att_change' and
       a ~= 'add_simple_flag' and a ~= 'remove_simple_flag' and a ~= 'change_personality' then
     n = n + 1
     info.Syndromes[i]._second[1][n] = {}
     info.Syndromes[i]._second[1][n]._title = a:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
     info.Syndromes[i]._second[1][n].Severity = effect.sev
     dur = effect['end'] - effect.start
     if dur < 0 then dur = 'Perm' end
     info.Syndromes[i]._second[1][n].Duration = dur
     info.Syndromes[i]._second[1][n].Probability = effect.prob
     info.Syndromes[i]._second[1][n].Resist = tostring(effect.flags.RESISTABLE)
    end
   end
  end
 end
 
 info.Flags = parseFlags(material.flags)
 
 return info
end
function getOrganicInfo(organicMatInfo,system)
 local info = {}
 local n = 0
 local materialRaw = organicMatInfo.material
 local objectRaw = organicMatInfo[organicMatInfo.mode]
 local enhancedRaw = {}
 if system then -- Enhanced Material system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
  if roses and roses.EnhancedMaterialTable['XXX'] then
   enhancedRaw = roses.EnhancedMaterialTable['XXX'] -- Need to distinguish between plant and creature mats
  end
 end
 
 info.Name = {}
 info.Name._color = COLOR_WHITE
 info.Name._string = organicMatInfo:toString()
 info.Description = enhancedRaw.Description or ''

 info.Origin = {}
 if organicMatInfo.mode == 'plant' then
  info.Origin.Plant = objectRaw.name
  info.Origin.Flags = parseFlags(objectRaw.flags)
  info.Origin._flags = strings.plantFlags.BIOME_FLAGS
  info.Origin._order = {'Plant'}
 elseif organicMatInfo.mode == 'creature' then
  info.Origin.Creature = objectRaw.name[0]
  info.Origin.Flags = {}
  for _,line in pairs(objectRaw.raws) do
   if split(line.value,':')[1] == '[BIOME' then
    info.Origin.Flags[split(split(line.value,':')[2],']')[1]] = true
   end
  end
  info.Origin._flags = strings.creatureFlags.BIOME_FLAGS
  info.Origin._order = {'Creature'}
 elseif organicMatInfo.mode == 'inorganic' then
  info.Origin._flags = strings.inorganicFlags.ENVIRONMENT_FLAGS
 end
 
 info.Material = getMaterialInfo(materialRaw)
  
 return info
end
function getPlantInfo(plantRaw,system)
 local info  = {}
 local enhancedRaw = {} -- There is no Enhanced Plant system yet -ME

 info.Name = {}
 info.Name._text = plantRaw.name
 info.Name._color = COLOR_WHITE
 
 local growStuff = {'value','frequency','clustersize','growdur','underground_depth_min',
                    'underground_depth_max'}
 info.GrowInfo = {}
 info.GrowInfo._order = growStuff
 for _,x in pairs(growStuff) do
  if plantRaw[x] > 0 then
   info.GrowInfo[x] = plantRaw[x]
  end
 end
 
 local treeStuff = {'trunk_period','heavy_branch_density','light_branch_density',
                    'max_trunk_height','heavy_branch_radius','light_branch_radius',
                    'trunk_branching','max_trunk_diameter','trunk_width_period',
                    'cap_period','cap_radius','root_density','root_radius','tree_drown_level',
                    'sapling_drown_level'}
                   --'root_name','trunk_name','heavy_branch_name','light_branch_name', -- For now don't include part names
                   --'twig_name','cap_name',
 local shrubStuff = {'shrub_drown_level'}
 local grassStuff = {}
 
 info.Type = 'UNKNOWN'
 info.TypeInfo = {}
 if plantRaw.flags.TREE then
  stuff = treeStuff
  info.Type = 'Tree Information'
 elseif plantRaw.flags.GRASS then
  stuff = grassStuff
  info.Type = 'Grass Information'
 else
  stuff = shrubStuff
  info.Type = 'Plant Information'
 end
 for _,x in pairs(stuff) do
  info.TypeInfo[x] = plantRaw[x]
 end
  
 info.Growths = {}
 for i,growth in pairs(plantRaw.growths) do
  info.Growths[i] = {}
  info.Growths[i]._listHead = 'Growth'
  info.Growths[i]._title = growth.name
  info.Growths[i].Density = growth.density
  info.Growths[i]._second = {}
  info.Growths[i]._second[1] = {}
  info.Growths[i]._second[1]._listHead = 'Growth Locations'
  n = 0
  for flag,bool in pairs(growth.locations) do
   if bool and not tonumber(flag) then
    n = n + 1
    info.Growths[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  if n == 0 then info.Growths[i]._second[1][1] = 'Plant' end
  info.Growths[i]._second[2] = {}
  info.Growths[i]._second[2]._listHead = 'Growth Behaviors'
  n = 0
  for flag,bool in pairs(growth.behavior) do
   if bool and not tonumber(flag) then
    n = n + 1
    info.Growths[i]._second[2][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  if n == 0 then info.Growths[i]._second[2] = nil end
 end
 
 local matStuff = {STRUCTURE='basic_mat',WOOD='tree',SEED='seed',THREAD='thread'}
 info.Materials = {}
 info.Materials._order = {'STRUCTURE','SEED','THREAD','WOOD'}
 for y,x in pairs(matStuff) do
  if plantRaw.material_defs['type_'..x] >= 0 then
   mat_type = plantRaw.material_defs['type_'..x]
   mat_index = plantRaw.material_defs['idx_'..x]
   matinfo = dfhack.matinfo.decode(mat_type,mat_index)
   if matinfo then
    info.Materials[y] = matinfo:toString()
   end
  end
 end
 
 local prodStuff = {DRINK='drink',POWDER='mill',EXTRACT_VIAL='extract_vial',
                    EXTRACT_BARREL='extract_barrel',EXTRACT_STILL='extract_still_vial'}
 info.Products = {}
 info.Products._order = {'DRINK','POWDER','EXTRACT_VIAL','EXTRACT_BARREL','EXTRACT_STILL'}
 for y,x in pairs(prodStuff) do
  if plantRaw.material_defs['type_'..x] >= 0 then
   mat_type = plantRaw.material_defs['type_'..x]
   mat_index = plantRaw.material_defs['idx_'..x]
   matinfo = dfhack.matinfo.decode(mat_type,mat_index)
   if matinfo then
    info.Products[y] = matinfo:toString()
   end
  end
 end
 
 info.Flags = parseFlags(plantRaw.flags)
 if info.Flags.SUMMER and info.Flags.WINTER and info.Flags.SPRING and info.Flags.AUTUMN then
  info.Flags.SUMMER = nil
  info.Flags.WINTER = nil
  info.Flags.SPRING = nil
  info.Flags.AUTUMN = nil
  info.Flags.ALL_SEASON = true
 end
 
 return info
end
function getProductInfo(productMatInfo,system)
 local info = {}
 local materialRaw = productMatInfo.material
 local objectRaw = productMatInfo[productMatInfo.mode]
 local enhancedRaw = {}
 if system then -- Enhanced Material system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
  if roses and roses.EnhancedMaterialTable['XXX'] then
   enhancedRaw = roses.EnhancedMaterialTable['XXX'] -- Need to distinguish between plant and creature mats
  end
 end

 info.Name = {}
 info.Name._color = COLOR_WHITE
 info.Name._string = productMatInfo:toString()
 info.Description = enhancedRaw.Description or ''
 
 info.Origin = {}
 if productMatInfo.mode == 'plant' then
  info.Origin.Plant = objectRaw.name
  info.Origin.Flags = parseFlags(objectRaw.flags)
  info.Origin._flags = strings.plantFlags.BIOME_FLAGS
  info.Origin._order = {'Plant'}
 elseif productMatInfo.mode == 'creature' then
  info.Origin.Creature = objectRaw.name[0]
  info.Origin.Flags = {}
  for _,line in pairs(objectRaw.raws) do
   if split(line.value,':')[1] == '[BIOME' then
    info.Origin.Flags[split(split(line.value,':')[2],']')[1]] = true
   end
  end
  info.Origin._flags = strings.creatureFlags.BIOME_FLAGS
  info.Origin._order = {'Creature'}
 elseif productMatInfo.mode == 'inorganic' then
  info.Origin._flags = strings.inorganicFlags.ENVIRONMENT_FLAGS
 end
 
 info.Material = getMaterialInfo(materialRaw)
 
 return info
end
function getReactionInfo(reactionRaw,system)
 local info  = {}
 local n = 0
 local enhancedRaw = {}
 if Type then -- Enhanced Reaction system is loaded
  roses = dfhack.script_environment('base/roses-table').roses
  if roses and roses.EnhancedReactionTable[reactionRaw.code] then
   enhancedRaw = roses.EnhancedReactionTable[reactionRaw.code]
  end
 end
 
 info.Name = reactionRaw.name
 info.Category = 'None'
 for i,x in pairs(df.global.world.raws.reactions.reaction_categories) do
  if x.id == reactionRaw.category then
   info.Category = x.name
  end
 end
 
 info.Skill = df.job_skill[reactionRaw.skill]

 info.Buildings = {}
 info.Buildings._header = 'Buildings'
 info.Buildings._second = {}
 n = 0
 for i,x in pairs(reactionRaw.building.custom) do
  n = n + 1
  if x >= 0 then
   info.Buildings._second[n] = df.global.world.raws.buildings.all[x].name
  else
   if df.building_type[reactionRaw.building.type[i]] == 'Workshop' then
    info.Buildings._second[n] = df.workshop_type[reactionRaw.building.subtype[i]]
   elseif df.building_type[reactionRaw.building.type[i]] == 'Furnace' then
    info.Buildings._second[n] = df.furnace_type[reactionRaw.building.subtype[i]]
   end
  end
  if not info.Buildings._second[n] then n = n - 1 end
 end
 
 info.Reagents = {}
 for i,item in pairs(reactionRaw.reagents) do
  info.Reagents[i] = {}
  info.Reagents[i]._listHead = 'Code'
  info.Reagents[i]._title = item.code:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  if item.mat_type == -1 then
   info.Reagents[i].Material = 'Any'
  else
   info.Reagents[i].Material = dfhack.matinfo.decode(item.mat_type,item.mat_index):toString()
   info.Reagents[i].Material = info.Reagents[i].Material:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  end
  if item.item_type >= 0 and item.item_subtype >= 0 then
   info.Reagents[i].Item = dfhack.items.getSubtypeDef(item.item_type,item.item_subtype).name
  else
   info.Reagents[i].Item = df.item_type[item.item_type]
  end
  info.Reagents[i].Item  = info.Reagents[i].Item:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  info.Reagents[i].Quantity  = tostring(item.quantity)
  info.Reagents[i]._second = {}
  info.Reagents[i]._second[1] = {}
  info.Reagents[i]._second[1]._listHead = 'Flags'
  n = 0
  for flag,bool in pairs(item.flags) do
   if bool then
    n = n + 1
    info.Reagents[i]._second[1][n] = tostring(flag):gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  for flag,bool in pairs(item.flags1) do
   if bool then
    n = n + 1
    info.Reagents[i]._second[1][n] = tostring(flag):gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  for flag,bool in pairs(item.flags2) do
   if bool then
    n = n + 1
    info.Reagents[i]._second[1][n] = tostring(flag):gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
  for flag,bool in pairs(item.flags3) do
   if bool then
    n = n + 1
    info.Reagents[i]._second[1][n] = tostring(flag):gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
  end
 end
 
 info.Products = {}
 for i,item in pairs(reactionRaw.products) do
  info.Products[i] = {}
  if item.mat_type == -1 then
   if item.flags.GET_MATERIAL_SAME then
    info.Products[i].Material = 'Same as '..item.get_material.reagent_code
   elseif item.flags.GET_MATERIAL_PRODUCT then
    info.Products[i].Material = 'Product'
   else
    info.Products[i].Material = 'Any'
   end
  else
   info.Products[i].Material = dfhack.matinfo.decode(item.mat_type,item.mat_index):toString()
  end
  if df.reaction_product_item_improvementst:is_instance(item) then
   info.Products[i]._listHead = 'Improvement'   
   info.Products[i]._title = '--'
   info.Products[i].Item = df.improvement_type[item.improvement_type]
  else
   info.Products[i]._listHead = 'Quantity'
   info.Products[i]._title = tostring(item.count)
   if item.item_type >= 0 and item.item_subtype >= 0 then
    info.Products[i].Item = dfhack.items.getSubtypeDef(item.item_type,item.item_subtype).name
   else
    info.Products[i].Item = df.item_type[item.item_type]
   end
  end
  info.Products[i].Item = info.Products[i].Item:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
 end
 
 return info
end
function getReligionInfo()
end
function getSyndromeInfo()
end
function getClassSystemInfo(extra,Type)
 local info = {}
 if not dfhack.findScript('base/roses-table') then return end
 roses = dfhack.script_environment('base/roses-table').roses
 local classTable = roses.ClassTable
 local featTable  = roses.FeatTable
 local spellTable = roses.SpellTable
 
 return info
end

--= Output Generating Functions
function getJournalOutput(info,viewDetails,cell,check,special)
 local insert = {}
 local what = viewDetails.fill[cell]
 local twhat = split(what,':')[1]
 local nwhat = split(what,':')[2]
 if twhat == 'on_submit' then what = viewDetails.on_submit[tonumber(nwhat)] end
 if twhat == 'on_select' then what = viewDetails.on_select[tonumber(nwhat)] end
 local view_id = viewDetails.viewScreen
 x, y = get_xy_cell(viewDetails.num_cols,viewDetails.num_rows,cell,-1)
 local w = viewDetails.widths[x][y]
 local keyed = false
 if viewDetails.functions then
  keyed = viewDetails.functions[what]
 end
 colorKey = info.ColorScheme
 local listOptions  = {width=w, colOrder={}, view_id=view_id, cell=cell}
 local tokenOptions = {width=w, colOrder={}, view_id=view_id, cell=cell, token=''}
 local outToken = nil

 if (view_id == 'main') then
  insert = insertWidgetInput(insert, 'center', what, {width=w, keyed=keyed})
  local Info = info[what]
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'text',   Info._description, {width=w})
  insert = insertWidgetInput(insert, 'header', Info._stats,       {width=w, rowOrder=get_order(Info._stats)})
 end
 if (view_id == 'artView') then
  if (what == 'ArtTypeList') then
   local Info = info.Arts[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'ArtList')     then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Arts[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)
  else
   --insert = getOutputArt()
  end
 end
 if (view_id == 'buildingView') then
  if (what == 'BuildingTypeList') then
   local Info = info.Buildings[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'BuildingList')     then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Buildings[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)
  else
   insert = getOutputBuilding(info,w,check,what,keyed)  
  end
 end 
 if (view_id == 'creatureView') then
  if (what == 'CreatureList')     then
   local Info = info.Creatures[check]
   if not Info then return insert end
   listOptions.rowOrder=get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, listOptions)
  elseif (what == 'CasteList')        then
   if not check.text then return end
   local Info = info.Creatures.ALL
   if not Info then return insert end
   local token = check.text[1].token
   tokenOptions.token    = token
   tokenOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], tokenOptions) 
  else
   insert = getOutputCreature(info,w,check,what,keyed)
  end
 end
 if (view_id == 'entityView') then
  if (what == 'EntityTypeList')   then
   local Info = info.Entities[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions) 
  elseif (what == 'EntityList')       then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Entities[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)
  else
   insert = getOutputEntity(info,w,check,what,keyed)
  end
 end 
 if (view_id == 'inorganicView') then 
  if (what == 'MaterialTypeList') then
   local Info = info.Inorganics[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions) 
  elseif (what == 'MaterialList')     then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Inorganics[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions) 
  else
   insert = getOutputInorganic(info,w,check,what,keyed)
  end
 end
 if (view_id == 'itemView') then
  if (what == 'ItemTypeList')     then
   local Info = info.Items[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'ItemList')         then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Items[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)
  else
   insert = getOutputItem(info,w,check,what,keyed)
  end
 end 
 if (view_id == 'organicView') then 
  if (what == 'MaterialTypeList') then
   if special then
    Info = {[special]={['_title']=special}}
    tokenOptions.token = 'Special'
   else
    Info = info.Organics[check]
    if not Info then return insert end
    tokenOptions.token = check
    tokenOptions.rowOrder = get_order(Info)
   end
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'MaterialList')     then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   if sort == 'Special' then
    Info = getSpecialInfo(info.Organics.ALL,token)
    insert = insertWidgetInput(insert, 'list', Info, listOptions) 
   else
    local Info = info.Organics[sort]
    if not Info then return insert end
    listOptions.rowOrder = get_order(Info[token])
    insert = insertWidgetInput(insert, 'list', Info[token], listOptions) 
   end 
  else
   insert = getOutputOrganic(info,w,check,what,keyed)
  end
 end
 if (view_id == 'plantView') then
  if (what == 'PlantTypeList')    then
   local Info = info.Plants[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'PlantList')        then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Plants[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)
  else
   insert = getOutputPlant(info,w,check,what,keyed)
  end
 end
 if (view_id == 'productView') then
  if (what == 'ProductTypeList') then
   local Info = info.Products[check]
   if not Info then return insert end
   tokenOptions.token    = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)  
  elseif (what == 'ProductList')     then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Products[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)  
  else
   insert = getOutputProduct(info,w,check,what,keyed)
  end
 end 
 if (view_id == 'reactionView') then
  if (what == 'ReactionTypeList') then
   local Info = info.Reactions[check]
   if not Info then return insert end
   tokenOptions.token    = check
   tokenOptions.rowOrder = get_order(Info,'Alphabetical','Title')
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)   
  elseif (what == 'ReactionList')     then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Reactions[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)  
  else
   insert = getOutputReaction(info,w,check,what,keyed)
  end
 end 
 if (view_id == 'religionView') then
  if (what == 'ReligionTypeList') then
   --local Info = info.Religions[check]
   --if not Info then return insert end
   --tokenOptions.token = check
   --tokenOptions.rowOrder = get_order(Info)
   --insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'ReligionList')     then
   --if not check.text then return end
   --local str   = check.text[1].token
   --local sort  = split(str,':')[1]
   --local token = split(str,':')[2]
   --local Info = info.Religions[sort]
   --if not Info then return insert end
   --listOptions.rowOrder = get_order(Info[token])
   --insert = insertWidgetInput(insert, 'list', Info[token], listOptions)
  else
   --insert = getOutputReligion()
  end
 end
 if (view_id == 'syndromeView') then
  if (what == 'SyndromeTypeList') then
   local Info = info.Syndromes[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'SyndromeList')     then
   if not check.text then return end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.Syndromes[sort]
   if not Info then return insert end
   listOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], listOptions)
  else
   --insert = getOutputSyndrome()
  end
 end
 if (view_id == 'classView') then
  if (what == 'ClassSystemTypes') then
   if not info.ClassSystem then return insert end
   local Info = info.ClassSystem[check]
   if not Info then return insert end
   tokenOptions.token = check
   tokenOptions.rowOrder = get_order(Info)
   insert = insertWidgetInput(insert, 'list', Info, tokenOptions)
  elseif (what == 'ClassSystemList') then
   if not check.text then return end
   if not info.ClassSystem then return insert end
   local str   = check.text[1].token
   local sort  = split(str,':')[1]
   local token = split(str,':')[2]
   local Info = info.ClassSystem[sort]
   if not Info then return insert end
   tokenOptions.token = token
   tokenOptions.rowOrder = get_order(Info[token])
   insert = insertWidgetInput(insert, 'list', Info[token], tokenOptions)  
  else
   return
   --insert = getOutputClassSystem(info,w,check,what,view_id)
  end
 end
 
 return insert
end
function getOutputArt()
end
function getOutputBuilding(info,w,check,what,keyed)
 local insert = {}

 if not check.text then return end
 local token = check.text[1].token -- token is the building id
 local bldgRaw = df.building_def.find(token)
 local Info = getBuildingInfo(bldgRaw,info.Systems.EnhancedBuilding)
 if not Info then return insert end

 if what == 'BuildingDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name,        {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Description, {width=w})
 elseif what == 'bldgInfo' then
  local order = {'Build_Labor','Dimensions','Number_of_floors','Outside_Only','Inside_Only','Required_Water_Depth','Required_Magma_Depth'}
  insert = insertWidgetInput(insert, 'center', 'Building Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info, {width=w,rowOrder=order})
 elseif what == 'buildItems' then
  local headOrder = {'Item','Material'}
  insert = insertWidgetInput(insert, 'center', 'Build Items', {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.BuildItems, {width=w, headOrder=headOrder, colOrder={}})
 elseif what == 'bldgReactions' then
  insert = insertWidgetInput(insert, 'center', 'Available Reactions', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header', Info.Reactions, {width=w})
 elseif what == 'bldgDiagram' then
  insert = insertWidgetInput(insert, 'center', 'Building Diagram', {width=w})
 else
  print('Unrecognized output request for view '..what)
 end
 
 return insert
end
function getOutputCreature(info,w,check,what,keyed)
 local insert = {}
 
 if not check.text then return end
 local token = check.text[1].token
 x,y = table.unpack(split(token,':'))
 ids = info.Creatures.ALL[x][y]
 local creatureRaw = df.global.world.raws.creatures.all[tonumber(ids[1])]
 local casteRaw = creatureRaw.caste[tonumber(ids[2])]
 Info = getCreatureInfo(creatureRaw,casteRaw,info.Systems.EnhancedCreature)
 if not Info then return insert end
  -- Put detailed output here
 local flags = strings.creatureFlags
 local fill = 'string'
 
 if what == 'CreatureDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
  insert = insertWidgetInput(insert, 'center', Info.CasteName, {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Description, {width=w})
 elseif what == 'popInfo' then
  local numbersOrder = {'Maximum_Age','Frequency','Caste_Frequency','Population_Size','Group_Size'}
  insert = insertWidgetInput(insert, 'center', 'Population Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.PopNumbers, {width=w,rowOrder=numbersOrder})
  insert = insertWidgetInput(insert, 'header', Info.Biome, {width=w, replaceHeader='Biomes',  replacement=flags.BIOME_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w, replaceHeader='Active',  replacement=flags.ACTIVITY_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w, replaceHeader='Habitat', replacement=flags.HABITAT_FLAGS, filling=fill})
 elseif what == 'baseInfo' then
  local numbersOrder = {'Adult_Size'}
  insert = insertWidgetInput(insert, 'center', 'Individual Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.StatNumbers, {width=w,rowOrder=numbersOrder}) 
  insert = insertWidgetInput(insert, 'header', Info.StatNumbers.Speed, {width=w,rowOrder={'WALK','FLY','SWIM','CRAWL','CLIMB'}})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Movement',replacement=flags.MOVEMENT_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Attacks, {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Interactions, {width=w})
 elseif what == 'flagInfo' then
  insert = insertWidgetInput(insert, 'center', 'Flags', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Body',replacement=flags.BODY_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Utility',replacement=flags.UTILITY_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Behavior',replacement=flags.BEHAVIOR_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Diet',replacement=flags.DIET_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Immunities',replacement=flags.IMMUNITY_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Special',replacement=flags.BONUS_FLAGS, filling=fill})
 elseif what == 'materialInfo' then
  insert = insertWidgetInput(insert, 'center', 'Materials and Products', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header', Info.Materials, {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Products, {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Extracts, {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Secretions, {width=w})
 else
  print('Unrecognized output request for view '..what)
 end 

 return insert
end
function getOutputEntity(info,w,check,what,keyed)
 local insert = {}

 if not check.text then return end 
 local token = check.text[1].token -- token is the entity id
 local entity = df.historical_entity.find(token)
 local Info = getEntityInfo(entity,info.Systems.Civilization)
 if not Info then return end
 
 if what == 'EntityDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
 elseif what == 'baseInfo' then
 
 elseif what == 'resourceInfo' then
  insert = insertWidgetInput(insert, 'center', 'Buildings and Reactions', {width=w})
  insert = insertWidgetInput(insert, 'header', Info, {width=w, rowOrder={'Buildings','Reactions'}})
 elseif what == 'positionInfo' then
  insert = insertWidgetInput(insert, 'center', 'Positions', {width=w})
  insert = insertWidgetInput(insert, 'table', Info.Positions, {width=w, headOrder={'Precedence'}, colOrder={}})
 elseif what == 'moralInfo' then
  insert = insertWidgetInput(insert, 'center', 'Ethics and Values', {width=w})
  insert = insertWidgetInput(insert, 'table', Info.Ethics, {width=w, colOrder={'Value'}, list_head='Ethic'})
  for i,x in pairs(Info.Values) do
   insert = insertWidgetInput(insert, 'text', x, {width=w})
  end
 else
  print('Unrecognized output request for view '..what)
 end
 
 return insert
end
function getOutputInorganic(info,w,check,what,keyed)
 local insert = {}

 if not check.text then return end 
 local token = check.text[1].token -- token is the matinfo string
 local matinfo = dfhack.matinfo.find(token)
 local Info = getInorganicInfo(matinfo,info.Systems.EnhancedMaterial)
 if not Info then return end
 flags = strings.materialFlags
 fill = 'string'
 
 if what == 'MaterialDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
  insert = insertWidgetInput(insert, 'center', Info.Description, {width=w})
 elseif what == 'environmentInfo' then
  insert = insertWidgetInput(insert, 'center', 'Found In', {width=w})
  for _,str in pairs(Info.Environment._second) do
   insert = insertWidgetInput(insert, 'text', str, {width=w})
  end
  insert = insertWidgetInput(insert, 'text', '', {width=w})
  insert = insertWidgetInput(insert, 'center', 'Ore Composition', {width=w})
  for _,str in pairs(Info.Ore._second) do
   insert = insertWidgetInput(insert, 'text', str, {width=w})
  end
  insert = insertWidgetInput(insert, 'text', '', {width=w})
  insert = insertWidgetInput(insert, 'center', 'Alloy Composition', {width=w})
  for _,str in pairs(Info.Alloy._second) do
   insert = insertWidgetInput(insert, 'text', str, {width=w})
  end
  
 elseif what == 'useInfo' then
  insert = insertWidgetInput(insert, 'center', 'Material Uses', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.Flags, {width=w, replaceHeader='Makes', replacement=flags.ITEM_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Material.Flags, {width=w, replaceHeader='Edibility', replacement=flags.EDIBLE_FLAGS, filling=fill})
  local headOrder = {'Ingested','Inhaled','Injected','Contact'}
  local colOrder  = {'Probability','Severity','Duration','Resist'}
  insert = insertWidgetInput(insert, 'table',  Info.Material.Syndromes, {width=w, headOrder=headOrder, colOrder=colOrder}) 
  
 elseif what == 'materialInfo1' then
  insert = insertWidgetInput(insert, 'center', 'Material Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.BaseStats, {width=w})
  insert = insertWidgetInput(insert, 'text', '', {width=w})
  insert = insertWidgetInput(insert, 'center', 'Material Temperature', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.Temperature, {width=w})
  
 elseif what == 'materialInfo2' then
  local temp = Info.Material.Strength
  insert = insertWidgetInput(insert, 'center', 'Material Strengths', {width=w})
  insert = insertWidgetInput(insert, 'table',  temp, {width=w, rowOrder=temp._rowOrder, colOrder=temp._colOrder})
  
 else
  print('Unrecognized output request for view '..what)
 end
 
 return insert
end
function getOutputItem(info,w,check,what,keyed)
 local insert = {}
 if not check.text then return end
 local token = check.text[1].token -- token is the item subtype without the item type
 local id = info.Items['ALL']['all'][token].ID
 local itemRaw = df.global.world.raws.itemdefs.all[id]
 local Info = getItemInfo(itemRaw,info.Systems.EnhancedItem)
 if not Info or not Info.Name then return insert end
 local flags = strings.itemFlags
 local fill = 'flag'
 
 if what == 'ItemDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Type,        {width=w})
  insert = insertWidgetInput(insert, 'center', Info.Name,        {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Description, {width=w})
 elseif what == 'baseInfo' then
  local order = {'Value','Size','Min_Size','Two_Hand_Size','Mat_Size'}
  insert = insertWidgetInput(insert, 'center', 'Base Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info, {width=w, rowOrder=order})
 elseif what == 'typeInfo' then
   local colOrder = {'Contact','Penetration','Velocity','Prepare','Recover'}
   local rowOrder = {'Melee_Skill','Block_Chance','Armor_Level','UP_Step','UB_Step','LB_Step',
                     'Coverage','Layer','Layer_Size','Layer_Permit','Range_Skill','Ammo','Ammo_Class',
                     'Shot_Force','Shot_Velocity','Capacity'}
   insert = insertWidgetInput(insert, 'center', Info.Type..' Information', {width=w})
   insert = insertWidgetInput(insert, 'header', Info, {width=w, rowOrder=rowOrder})
   if Info.Attacks then
    insert = insertWidgetInput(insert, 'table',  Info.Attacks, {width=w, list_head='Attack', colOrder=colOrder})
   end
   if Info.Uses then
    insert = insertWidgetInput(insert, 'header', Info.Uses, {width=w})
   end    

 elseif what == 'flagInfo' then
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,  replacement=flags.MATERIAL_FLAGS, filling=fill})
 elseif what == 'enhancedInfo' then
  if Info.OnEquip then
   insert = insertWidgetInput(insert, 'center', 'On Equip', {width=w})
   insert = insertWidgetInput(insert, 'header', Info.OnEquip, {width=w, rowOrder=get_order(Info.OnEquip,{'Chance'})})
  end
  if Info.OnAttack then
   insert = insertWidgetInput(insert, 'center', 'On Attack', {width=w})
   insert = insertWidgetInput(insert, 'header', Info.OnAttack, {width=w, rowOrder=get_order(Info.OnAttack,{'Chance'})})
  end
 else
  print('Unrecognized output request for view '..what)
 end

 return insert
end
function getOutputOrganic(info,w,check,what,keyed)
 local insert = {}
 
 if not check.text then return end 
 local token = check.text[1].token -- token is the matinfo string
 local matinfo = dfhack.matinfo.find(token:upper())
 local Info = getOrganicInfo(matinfo,info.Systems.EnhancedMaterial)
 if not Info then return end
 flags = strings.materialFlags
 fill = 'string'
 
 if what == 'MaterialDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
  insert = insertWidgetInput(insert, 'center', Info.Description, {width=w})
 elseif what == 'environmentInfo' then
  insert = insertWidgetInput(insert, 'center', 'Origin Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Origin, {width=w, rowOrder=Info.Origin._order}) 
  insert = insertWidgetInput(insert, 'header', Info.Origin.Flags, {width=w, replaceHeader='Biomes', replacement=Info.Origin._flags, filling=fill})
 elseif what == 'useInfo' then
  insert = insertWidgetInput(insert, 'center', 'Material Uses', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.Flags, {width=w, replaceHeader='Makes', replacement=flags.ITEM_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Material.Flags, {width=w, replaceHeader='Edibility', replacement=flags.EDIBLE_FLAGS, filling=fill})
  local headOrder = {'Ingested','Inhaled','Injected','Contact'}
  local colOrder  = {'Probability','Severity','Duration','Resist'}
  --insert = insertWidgetInput(insert, 'center', 'Syndromes', {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Material.Syndromes, {width=w, headOrder=headOrder, colOrder=colOrder})
 elseif what == 'materialInfo1' then
  insert = insertWidgetInput(insert, 'center', 'Material Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.BaseStats, {width=w})
  insert = insertWidgetInput(insert, 'text', '', {width=w})
  insert = insertWidgetInput(insert, 'center', 'Material Temperature', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.Temperature, {width=w})  
 elseif what == 'materialInfo2' then
  local temp = Info.Material.Strength
  insert = insertWidgetInput(insert, 'center', 'Material Strengths', {width=w})
  insert = insertWidgetInput(insert, 'table',  temp, {width=w, rowOrder=temp._rowOrder, colOrder=temp._colOrder})
 else
  print('Unrecognized output request for view '..what)
 end
 
 return insert
end
function getOutputPlant(info,w,check,what,keyed)
 local insert = {}

 if not check.text then return end 
 local token = check.text[1].token -- token is the plant code
 local id = info.Plants['ALL']['all'][token].ID
 local plantRaw = df.plant_raw.find(id)
 local Info = getPlantInfo(plantRaw,info.Systems.EnhancedMaterial)
 if not Info then return insert end
 flags = strings.plantFlags
 fill = 'string'
 
 if what == 'PlantDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
 elseif what == 'baseInfo' then
  insert = insertWidgetInput(insert, 'header', Info.GrowInfo, {width=w, rowOrder=Info.GrowInfo._order})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w, replaceHeader='Seasons', replacement=flags.SEASONAL_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w, replaceHeader='Biomes',  replacement=flags.BIOME_FLAGS,    filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w, replaceHeader='Habitat', replacement=flags.HABITAT_FLAGS,  filling=fill})
 elseif what == 'typeInfo' then
  --insert = insertWidgetInput(insert, 'center', Info.Type,     {width=w})
  --insert = insertWidgetInput(insert, 'header', Info.TypeInfo, {width=w})
 elseif what == 'materialInfo' then
  insert = insertWidgetInput(insert, 'center', 'Materials and Products',    {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header', Info.Materials, {width=w, rowOrder=Info.Materials._order})
  insert = insertWidgetInput(insert, 'header', Info.Products, {width=w, rowOrder=Info.Products._order})
 elseif what == 'growthInfo' then
  insert = insertWidgetInput(insert, 'center', 'Growths',    {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Growths, {width=w, headOrder={'Density'}, colOrder={}})
 else
  print('Unrecognized output request for view '..what)
 end

 return insert
end
function getOutputProduct(info,w,check,what,keyed)
 local insert = {}

 if not check.text then return end 
 local token = check.text[1].token -- token is the matinfo string
 local matinfo = dfhack.matinfo.find(token)
 local Info = getProductInfo(matinfo,info.Systems.EnhancedMaterial)
 if not Info then return end
 flags = strings.materialFlags
 fill = 'string'
 
 if what == 'ProductDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
  insert = insertWidgetInput(insert, 'center', Info.Description, {width=w})
 elseif what == 'environmentInfo' then
  insert = insertWidgetInput(insert, 'center', 'Origin Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Origin, {width=w, rowOrder=Info.Origin._order}) 
  insert = insertWidgetInput(insert, 'header', Info.Origin.Flags, {width=w, replaceHeader='Biomes', replacement=Info.Origin._flags, filling=fill})
 elseif what == 'useInfo' then
  insert = insertWidgetInput(insert, 'center', 'Product Uses', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.Flags, {width=w, replaceHeader='Makes', replacement=flags.ITEM_FLAGS, filling=fill})
  insert = insertWidgetInput(insert, 'header', Info.Material.Flags, {width=w, replaceHeader='Edibility', replacement=flags.EDIBLE_FLAGS, filling=fill})
  local headOrder = {'Ingested','Inhaled','Injected','Contact'}
  local colOrder  = {'Probability','Severity','Duration','Resist'}
  --insert = insertWidgetInput(insert, 'center', 'Syndromes', {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Material.Syndromes, {width=w, headOrder=headOrder, colOrder=colOrder}) 
 elseif what == 'materialInfo1' then
  insert = insertWidgetInput(insert, 'center', 'Material Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.BaseStats, {width=w})
  insert = insertWidgetInput(insert, 'text', '', {width=w})
  insert = insertWidgetInput(insert, 'center', 'Material Temperature', {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Material.Temperature, {width=w})
 elseif what == 'materialInfo2' then
 
 else
  print('Unrecognized output request for view '..what)
 end
 
 return insert
end
function getOutputReaction(info,w,check,what,keyed)
 local insert = {}

 if not check.text then return end 
 local token = check.text[1].token -- token is the reaction code
 local id = info.Reactions['ALL']['ALL'][token].ID
 local reactionRaw = df.reaction.find(id)
 local Info = getReactionInfo(reactionRaw,info.Systems.EnhancedReaction)
 if not Info then return insert end
 
 if what == 'ReactionDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
 elseif what == 'baseInfo' then
  insert = insertWidgetInput(insert, 'center', 'Basic Information', {width=w})
  insert = insertWidgetInput(insert, 'header', Info , {width=w, rowOrder={'Category','Skill','Buildings'}})
 elseif what == 'reagentInfo' then
  local headOrder = {'Quantity','Item','Material'}
  insert = insertWidgetInput(insert, 'center', 'Reagents', {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Reagents, {width=w, headOrder=headOrder, colOrder={}})
 elseif what == 'productInfo' then
  local headOrder = {'Item','Material'}
  insert = insertWidgetInput(insert, 'center', 'Products', {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Products, {width=w, headOrder=headOrder, colOrder={}})
 elseif what == 'enhancedInfo' then
  insert = insertWidgetInput(insert, 'center',  '', {width=w})
 else
  print('Unrecognized output request for view '..what)
 end
 return insert
end
function getOutputReligion()
end
function getOutputSyndrome()
end

--=                      Detailed Unit Viewer Functions
usages[#usages+1] = [===[

]===]

--= Information Gathering Functions
function getDUVInfo(unit,extras)
 local info = {}
 
 info.Base = getBaseInfo(unit)
 info.Description = getDescriptionInfo(unit)
 
 info.Appearance = {}
 info.Appearance.Basic = getAppearanceInfo(unit,'Basic')
 info.Appearance.Detailed = getAppearanceInfo(unit,'Detailed')

 info.Relationships = {}
 info.Relationships.Basic    = getRelationshipInfo(unit,'Basic')
 info.Relationships.Detailed = getRelationshipInfo(unit,'Detailed')
 
 info.Personality = {}
 info.Personality.Basic    = getPersonalityInfo(unit,'Basic')
 info.Personality.Detailed = getPersonalityInfo(unit,'Detailed')

 info.Health = {}
 info.Health.Basic    = getHealthInfo(unit,'Basic')
 info.Health.Detailed = getHealthInfo(unit,'Detailed')
 
 info.Attributes = {}
 info.Attributes.Basic    = getAttributeInfo(unit,'Basic')
 info.Attributes.Detailed = getAttributeInfo(unit,'Detailed')
 
 info.Skills = {}
 info.Skills.Basic    = getSkillInfo(unit,'Basic')
 info.Skills.Detailed = getSkillInfo(unit,'Detailed')
 
 info.StatRes = {}
 info.StatRes.Basic    = getStatResistanceInfo(unit,'Basic')
 info.StatRes.Detailed = getStatResistanceInfo(unit,'Detailed')
 
 info.Inventory = {}
 info.Inventory.Basic    = getInventoryInfo(unit,'Basic')
 info.Inventory.Detailed = getInventoryInfo(unit,'Detailed')
 
 if extras.Systems.Class then
  info.Classes = {}
  info.Classes._order = {'Level','Exp'}
  info.Classes.Basic     = getClassInfo(unit,'Basic')
  info.Classes.Learned   = getClassInfo(unit,'Learned')
  info.Classes.Available = getClassInfo(unit,'Available')
 end
 if extras.Systems.Feat then
  info.Feats = {}
  info.Feats._order = {'Learned'}
  info.Feats.Basic   = getFeatInfo(unit,'Basic')
  info.Feats.Learned = getFeatInfo(unit,'Learned')
  info.Feats.Class   = getFeatInfo(unit,'Class')
 end 
 if extras.Systems.Spell then
  info.Spells = {}
  info.Spells._order = {'Learned','Active'}
  info.Spells.Basic   = getSpellInfo(unit,'Basic')
  info.Spells.Learned = getSpellInfo(unit,'Learned')
  info.Spells.Class   = getSpellInfo(unit,'Class')
 end

 return info
end
function getBaseInfo(unit)
 local info = {}
 local hf = df.historical_figure.find(unit.hist_figure_id)
 
 -- Unit Name
 info.Name = dfhack.TranslateName(dfhack.units.getVisibleName(unit))
 
 -- Unit Caste
 local sex = ''
 local race = df.global.world.raws.creatures.all[tonumber(unit.race)].name[0]
 if unit.sex == 1 then 
  sex = 'Male '
 elseif unit.sex == 0 then 
  sex = 'Female '
 end
 local caste = df.global.world.raws.creatures.all[tonumber(unit.race)].caste[tonumber(unit.caste)].caste_name[0]
 info.Caste = race:gsub("^%l", string.upper)..', '..sex..caste:gsub("(%a)([%w_']*)", tchelper)

 -- Unit Entity
 local ent, civ, mem = '', '', ''
 if unit.civ_id >= 0 then 
  ent = df.global.world.entities.all[unit.civ_id].name
  ent = dfhack.TranslateName(ent)
 end
 if unit.hist_figure_id >= 0 then
  local hf = df.historical_figure.find(unit.hist_figure_id)
  for _,link in pairs(hf.entity_links) do
   if link.entity_id ~= unit.civ_id then 
    mem = df.global.world.entities.all[link.entity_id].name
	mem = dfhack.TranslateName(mem)
   end
  end
 end
 info.Entity = ent
 info.Membership = mem
 info.Age = tostring(math.floor(dfhack.units.getAge(unit)))
 
 info.Position = {}
 info.Position._header = 'Positions'
 info.Position._second = {}
 name = 'name'
 if unit.sex == 1 then name = 'name_male' end
 if unit.sex == 0 then name = 'name_female' end
 n = 0
 if dfhack.units.getNoblePositions(unit) then
  for i,noble in pairs(dfhack.units.getNoblePositions(unit)) do
   n = n + 1
   pos = noble.position
   if pos[name][0] ~= '' then
    pos_name = pos[name][0]
   else
    pos_name = pos.name[0]
   end
   info.Position._second[n] = pos_name:gsub("(%a)([%w_']*)", tchelper)
  end
 else
  info.Position._second[1] = 'None'
 end
 info.Position._length = #info.Position._second
 
 info.Measurements = {}
 info.Measurements.Speed = 0
 for _,gait in pairs({'WALK','FLY','SWIM','CRAWL','CLIMB'}) do
  speed = dfhack.script_environment('functions/unit').getSpeed(unit,gait)
  if speed and speed > info.Measurements.Speed then info.Measurements.Speed = speed end
 end
 info.Measurements.Speed = tostring(info.Measurements.Speed)..' km/h'
 info.Measurements.Size  = unit.body.size_info.size_cur
 info.Measurements.Area  = unit.body.size_info.area_cur
 info.Measurements.Length = unit.body.size_info.length_cur
 info.Measurements.Hunger = unit.counters2.hunger_timer -- replace with string for hunger (e.g. Starving) -ME
 info.Measurements.Thirst = unit.counters2.thirst_timer -- replace with string for thirst (e.g. Thirsty) -ME
 info.Measurements.Sleepy = unit.counters2.sleepiness_timer -- replace with string for sleepiness (e.g. Drowsy) -ME

 return info
end
function getRelationshipInfo(unit,Type)
 local info = {}
 
 relationshipTable = strings.relationship_string(unit)
 if Type == 'Basic' then
  info.Mother = relationshipTable.Mother
  info.Father = relationshipTable.Father
  info.Spouse = relationshipTable.Spouse
  info.Children = tostring(#relationshipTable.Children)
  info.Orientation = relationshipTable.Orientation
  info.Friends = tostring(#relationshipTable.Friends)
  info.Grudges = tostring(#relationshipTable.Grudges)
  info.Worship = relationshipTable.Worship
 elseif Type == 'Detailed' then
  info.Family = relationshipTable.Family
  info.Friends = relationshipTable.Friends
  info.Grudges = relationshipTable.Grudges
  info.MasterApprentice = relationshipTable.MasterApprentice
  info.Worship = relationshipTable.Worship
 end

 return info
end
function getDescriptionInfo(unit,Type)
 local info = ''

 info = df.global.world.raws.creatures.all[unit.race].caste[unit.caste].description

 return info
end
function getAppearanceInfo(unit,Type)
 local info = {}

 if Type == 'Basic' then
  info = strings.appearance_description(unit)
 else
  info = strings.appearance_detail(unit)
 end
 
 return info
end
function getPersonalityInfo(unit,Type)
 local info = {}
 personality = unit.status.current_soul.personality
 
 if     Type == 'Basic' then
  info.Stress = {}
  info.Dreams = {}
  info.Focus  = {}
  
  info.Stress._text, info.Stress._colorBin = strings.stress_description(unit)
  info.Dreams._text, info.Dreams._color    = strings.goal_description(unit)
  info.Focus._text,  info.Focus._colorBin  = strings.focus_description(unit)
  
 elseif Type == 'Detailed' then
  info.Thoughts = {}
  for i, emo in pairs(personality.emotions) do
   n = #info.Thoughts + 1
   info.Thoughts[n] = {}
   tbl = info.Thoughts[n]
   tbl._key = df.emotion_type[emo.type]
   tbl.Type       = df.emotion_type[emo.type]
   tbl.Thought    = df.unit_thought_type[emo.thought]
   tbl.Strength   = emo.strength
   tbl.SubThought = emo.subthought
   tbl.Severity   = emo.severity
   tbl.Remebered  = emo.flags.remembered
   tbl._string    = strings.thought_string(emo)
  end
  
  info.Preferences = {}
  for i, pref in pairs(unit.status.current_soul.preferences) do
   if pref.active then
    n = #info.Preferences+1
    info.Preferences[n] = {}
    tbl = info.Preferences[n]
	ptype = df.unit_preference.T_type[pref.type]
    tbl._key  = ptype
	tbl.Type    = ptype
	tbl.SubType = '???'
    tbl._string, tbl._colorBin = strings.preference_string(pref)
   end
  end
  
  info.Traits = {}
  for trait, n in pairs(personality.traits) do
   i = #info.Traits + 1
   info.Traits[i] = {}
   tbl = info.Traits[i]
   tbl._key   = trait
   tbl.Type     = trait
   tbl.Strength = n
   tbl._string, tbl._colorBin  = strings.trait_string(trait,n)
  end

  info.Values = {}
  for i, val in pairs(personality.values) do
   n = #info.Values + 1
   info.Values[n] = {}
   tbl = info.Values[n]
   tbl._key   = df.value_type[val.type]
   tbl.Type     = df.value_type[val.type]
   tbl.Strength = val.strength
   tbl._string, tbl._colorBin  = strings.value_string(val)
  end
  
  info.Needs = {}
  for i, need in pairs(personality.needs) do
   n = #info.Needs + 1
   info.Needs[n] = {}
   tbl = info.Needs[n]
   tbl._key   = df.need_type[need.id]
   tbl.Type     = df.need_type[need.id]
   tbl.Strength = need.focus_level
   tbl._string, tbl._colorBin = strings.focus_string(need.id,need.focus_level)
  end
 end

 return info
end
function getHealthInfo(unit,Type)
 local info = {}
 syndromes, syndrome_details = dfhack.script_environment('functions/unit').getSyndrome(unit,'All','detailed')

 if Type == 'Basic' then
  info.Injury = {}
  bp_status = unit.body.components.body_part_status
  for i,status in pairs(bp_status) do
   bp = unit.body.body_plan.body_parts[i]
   info.Injury[#info.Injury+1] = strings.wound_string(bp,status)
  end
  if #info.Injury == 0 then info.Injury[1] = 'has no current injuries' end
  
  info.Syndromes = 0
  wounds = unit.body.wounds
  for _,wound in pairs(wounds) do
   syndrome = df.syndrome.find(wound.syndrome_id)
   if syndrome then
    info.Syndromes = info.Syndromes + 1
   end
  end
  
 elseif Type == 'Detailed' then
  info.Wounds = {}
  
  n = 1
  wounds = unit.body.wounds
  for i,wound in pairs(wounds) do
   if wound.syndrome_id == -1 then
    info.Wounds[n] = {}
    info.Wounds[n].Age = wound.age
    info.Wounds[n]._listHead = ''
    info.Wounds[n]._second = {}
    for j,part in pairs(wound.parts) do
     bp = unit.body.body_plan.body_parts[part.body_part_id]
     lx = bp.layers[part.layer_idx]
     
     info.Wounds[n]._second._length = part.body_part_id
     info.Wounds[n]._second[part.body_part_id] = info.Wounds[n]._second[part.body_part_id] or {}
     
     tbl1 = info.Wounds[n]._second[part.body_part_id]
     tbl1._length = part.layer_idx
     tbl1._title = bp.name_singular[0].value
     
     tbl1[part.layer_idx] = {}
     tbl2 = tbl1[part.layer_idx]
     tbl2._title = lx.layer_name:lower()
     tbl2.Strain = part.strain
     tbl2.ContactArea = part.contact_area
     tbl2.SurfacePerc = part.surface_perc
     tbl2.Bleed = part.bleeding
     tbl2.Pain = part.pain
     tbl2.Penetration = part.cur_penetration_perc
     tbl2.Nausea = part.nausea
     
    end
    n = n + 1
   end
  end

  info.Syndromes = {}
  syndromes, syndrome_details = dfhack.script_environment('functions/unit').getSyndrome(unit,'All','detailed')
  for i,x in pairs(syndromes) do
   info.Syndromes[x[1]] = {}
   for j,y in pairs(syndrome_details[i]) do
    n = #info.Syndromes[x[1]] + 1
    if pcall(function() return y.sev end) then
     severity = y.sev
    else
     severity = 'NA'
    end
    effect = split(tostring(y._type),'creature_interaction_effect_')[2]
    if not effect then
     effect = 'NA'
    else
     effect = split(effect,'st>')[1]:gsub("(%a)([%w_']*)", tchelper)
    end
    effect = "    "..effect
    if not y['end'] or y['end'] == -1 then
     finish = 'Permanent'
     duration = x[3]
    else
     finish = y['end']
     duration = x[3]
    end
	info.Syndromes[x[1]][n] = {}
	info.Syndromes[x[1]][n].Type  = effect
	info.Syndromes[x[1]][n].Start = y.start
	info.Syndromes[x[1]][n].Peaks = y.peak
	info.Syndromes[x[1]][n].Sev   = severity
	info.Syndromes[x[1]][n].End   = finish
	info.Syndromes[x[1]][n].Dur   = duration
   end
  end
 end

 return info
end
function getAttributeInfo(unit,Type)
 local info = {}
 
 if Type == 'Basic' then
  info.Physical = strings.attribute_description(unit,'Physical')
  info.Mental   = strings.attribute_description(unit,'Mental')
  info.Custom   = '' -- Add possibility of custom attribute strings -ME
 elseif Type == 'Detailed' then
  info.Physical = {}
  info.Mental   = {}
  info.Custom   = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit).Attributes
  raw = df.global.world.raws.creatures.all[unit.race].caste[unit.sex].attributes
  for attr, tbl in pairs(unitTable) do
   if df.physical_attribute_type[attr] then
    info.Physical[attr] = tbl
    info.Physical[attr].String, bin = strings.attribute_string(attr,tbl.Base,raw.phys_att_range[attr])
    info.Physical[attr]._colorBin = bin
   elseif df.mental_attribute_type[attr] then
    info.Mental[attr] = tbl
    info.Mental[attr].String, bin = strings.attribute_string(attr,tbl.Base,raw.ment_att_range[attr])
    info.Mental[attr]._colorBin = bin
   else
    info.Custom[attr] = tbl
    info.Custom[attr].String = ''
   end
  end 
 end

 return info
end
function getSkillInfo(unit,Type)
 local info = {}
 local noTrack = {'HAUL','CLEAN','CIVILIANS','RECOVER','ROAD',
                  'CONSTRUCTION','VEHICLES','LEVER'}
 skillList = strings.skills
 
 if Type == 'Basic' then
  info.Profession = {}
  info.Profession._header = 'Profession'
  info.Profession._second = dfhack.units.getProfessionName(unit,true)
  info.Profession._colorText  = dfhack.units.getProfessionColor(unit,true)

  info.Labors = {}
  info.Labors._header = 'Labors'
  info.Labors._second = {}
  n = 0
  for l,b in pairs(unit.status.labors) do
   if b then
    check = true
    for _,track in pairs(noTrack) do
     if string.find(l,track) then check = false end
    end
    if check then
     n = n + 1
     info.Labors._second[n] = l:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
    end
   end
  end
  info.Labors._length = #info.Labors._second

  info.Legendary  = {}
  info.Legendary._header = 'Legendary Skills'
  info.Legendary._second = {}
  n = 0
  for _,skill in pairs(unit.status.current_soul.skills) do
   if skill.rating >= 15 then
    n = n + 1
    info.Legendary._second[n] = df.job_skill.attrs[skill.id].caption_noun
   end
  end
  if n == 0 then info.Legendary._second[1] = 'None' end
  info.Legendary._length = #info.Legendary._second
  
 elseif Type == 'Detailed' then
  info.Labors = {}
  info.Other  = {}
  info.Custom = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit).Skills
  for skill, tbl in pairs(unitTable) do
   if df.job_skill[skill] then
    name = df.job_skill.attrs[skill].caption_noun
    -- Determine if the skill is associated with a currently active labor
    if df.job_skill.attrs[skill].labor >= 0 and unit.status.labors[df.job_skill.attrs[skill].labor] then
     info.Labors[name] = tbl
     info.Labors[name].Level = info.Labors[name].Total
     info.Labors[name].String = df.skill_rating[info.Labors[name].Level]
    elseif dfhack.units.getExperience(unit,df.job_skill[skill],true) > 0 then -- Only add skills with some experience in them
     found = false
     for skillType, skillTypeList in pairs(skillList) do
      if skillTypeList[skill] then
       found = true
       info[skillType] = info[skillType] or {}
       n = #info[skillType] + 1
       info[skillType][n] = tbl
       info[skillType][n]._title = name
       info[skillType][n].Level = info[skillType][n].Total
       info[skillType][n].String = df.skill_rating[info[skillType][n].Level]
      end
     end
     if not found then
      n = #info.Other+1
      info.Other[n] = tbl
      info.Other[n]._title = name
      info.Other[n].String = df.skill_rating[info.Other[n].Level]
     end
    end
   else
    if tbl.Exp + tbl.Total + tbl.Base > 0 then
     n = #info.Custom+1
     name = roses.BaseTable.CustomSkills[skill]
     info.Custom[n] = tbl
     info.Custom[n]._title = name
     info.Custom[n].Level = info.Custom[n].Total
    end
   end
  end
 end
 
 return info
end
function getStatResistanceInfo(unit,Type)
 local info = {}

 if Type == 'Basic' then
  info.Stats       = 'A basic description of the units stats goes here'
  info.Resistances = 'A basic description of the units resistances goes here'
 elseif Type == 'Detailed' then
  info.Stats        = {}
  info.Resistances  = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
  for stat,tbl in pairs(unitTable.Stats) do
   info.Stats[stat] = tbl
  end
  for resistance,tbl in pairs(unitTable.Resistances) do
   info.Resistances[resistance] = tbl
  end
 end

 return info
end
function getInventoryInfo(unit,Type)
 local info = {}
 
 if Type == 'Basic' then
  n = 0
  for _,invItem in pairs(unit.inventory) do
   if invItem.mode == 1 or invItem.mode == 2 then
    n = n + 1
    bp = unit.body.body_plan.body_parts[invItem.body_part_id]
    itemname = invItem.item.subtype.name
    matinfo = dfhack.matinfo.decode(invItem.item.mat_type,invItem.item.mat_index)
    matstr  = dfhack.matinfo.toString(matinfo)
    info[bp.token] = info[bp.token] or {}
    info[bp.token]._header = bp.name_singular[0].value
    info[bp.token]._second = info[bp.token]._second or {}
    info[bp.token]._second[#info[bp.token]._second + 1] = matstr..' '..itemname
   end
  end
 else
  inventoryItems = {}
  info.Inventory = {}
  for i = 0, 10 do
   mode = df.unit_inventory_item.T_mode[i]
   info.Inventory[mode] = {}
   info.Inventory[mode]._second = {}
   info.Inventory[mode]._second._length = 0
  end
  for _,invItem in pairs(unit.inventory) do
   bpid = invItem.body_part_id
   bp   = unit.body.body_plan.body_parts[bpid]
   item = invItem.item
   inventoryItems[item.id] = true
   matinfo = dfhack.matinfo.decode(item.mat_type,item.mat_index)
   matstr  = dfhack.matinfo.toString(matinfo)
   mode = df.unit_inventory_item.T_mode[invItem.mode]
   info.Inventory[mode]._second[bpid] = info.Inventory[mode]._second[bpid] or {}
   info.Inventory[mode]._second[bpid]._listHead = bp.name_singular[0].value
   if bpid > info.Inventory[mode]._second._length then info.Inventory[mode]._second._length = bpid end
   n = #info.Inventory[mode]._second[bpid] + 1
   info.Inventory[mode]._second[bpid][n] = {}
   info.Inventory[mode]._second[bpid][n].Material = matstr
   info.Inventory[mode]._second[bpid][n]._title   = item.subtype.name
   info.Inventory[mode]._second[bpid][n].Wear     = item.wear
   info.Inventory[mode]._second[bpid][n]._key     = item.subtype.id
  end

  info.OwnedItems = {}
  n = 0
  for _,itemid in pairs(unit.owned_items) do
   if not inventoryItems[itemid] then
    item = df.item.find(itemid)
    matinfo = dfhack.matinfo.decode(item.mat_type,item.mat_index)
    matstr  = dfhack.matinfo.toString(matinfo)
    n = n + 1
    info.OwnedItems[n] = {}
    info.OwnedItems[n]._title = item.subtype.name
    info.OwnedItems[n].Material = matstr
    info.OwnedItems[n].Wear = item.wear
    info.OwnedItems[n]._key = item.subtype.id
   end
  end
  
  info.OwnedBldgs = {}
  for _,bldgid in pairs(unit.owned_buildings) do
  
  end
 end
 
 return info
end
function getClassInfo(unit,Type)
 local info = {}
 if not dfhack.findScript('base/roses-table') then return end
 roses = dfhack.script_environment('base/roses-table').roses
 local unitTable  = roses.UnitTable
 local classTable = roses.ClassTable
 local unitClasses
 if not tonumber(unit) and unitTable[tostring(unit.id)] then
  unitClasses = unitTable[tostring(unit.id)].Classes
 else
  unitClasses = nil
 end
 
 if Type == 'Basic' then
  info.Current    = 'None'
  info.Level      = '--'
  info.Experience = '--'
  if unitClasses and unitClasses.Current ~= 'NONE' then 
   info.Current    = classTable[unitClasses.Current].Name
   info.Level      = unitClasses[unitClasses.Current].Level
   info.Experience = unitClasses[unitClasses.Current].Experience
  end
 elseif Type == 'All' then
  info.Classes = {}
  for x,_ in pairs(classTable) do
   info.Classes[x] = {}
   info.Classes[x]._title = classTable[x].Name
   if unitClasses and unitClasses[x] then
    info.Classes[x].Exp   = unitClasses[x].Level
    info.Classes[x].Level = unitClasses[x].Experience
   else
    info.Classes[x].Exp   = 0
    info.Classes[x].Level = 0
   end
  end
 elseif Type == 'Learned' then
  info.Classes = {}
  for x,_ in pairs(classTable) do
   if unitClasses and unitClasses[x] then
    info.Classes[x] = {}
    info.Classes[x]._title = classTable[x].Name
    info.Classes[x].Exp   = unitClasses[x].Level
    info.Classes[x].Level = unitClasses[x].Experience
   end
  end
 elseif Type == 'Available' then
  info.Classes = {}
  for x,_ in pairs(classTable) do
   if dfhack.script_environment('functions/class').checkRequirementsClass(unit,x) then
    info.Classes[x] = {}
    info.Classes[x]._title = classTable[x].Name
    if unitClasses and unitClasses[x] then
     info.Classes[x].Exp   = unitClasses[x].Level
     info.Classes[x].Level = unitClasses[x].Experience
    else
     info.Classes[x].Exp   = 0
     info.Classes[x].Level = 0
    end
   end
  end
 elseif Type == 'Civ' then
  info.Classes = {}
  if unit.civ_id >= 0 then
   if not roses.EntityTable[tostring(unit.civ_id)] then return info end
   civTable = roses.EntityTable[tostring(unit.civ_id)].Civilization
   if not civTable then return info end
   for x,_ in pairs(classTable) do
    if civTable.Classes[x] then
     info.Classes[x]._title = classTable[x].Name
     info.Classes[x] = {}
     if unitClasses and unitClasses[x] then
      info.Classes[x].Exp   = unitClasses[x].Level
      info.Classes[x].Level = unitClasses[x].Experience
     else
      info.Classes[x].Exp   = 0
      info.Classes[x].Level = 0
     end
    end
   end
  end

 else
  if not classTable[Type] then return false end
  class = classTable[Type]
  unitT = dfhack.script_environment('functions/unit').getUnitTable(unit)

  info.Name        = class.Name
  info.Description = class.Description
  
  info.BaseInfo = {}
  info.BaseInfo.Levels = class.Levels or '0'
  info.BaseInfo.Sphere = class.Sphere or 'None'
  info.BaseInfo.School = class.School or '--'

  info.RequiredClass     = {}
  n = 0
  if class.RequiredClass then
   for x,_ in pairs(class.RequiredClass) do
    n = n + 1
    info.RequiredClass[x] = {}
    info.RequiredClass[x].Class = classTable[x].Name
    info.RequiredClass[x].Level = class.RequiredClass[x]
    info.RequiredClass[x].Color = falseColor
    if unitT.Classes[x] then
     if unitT.Classes[x].Level >= info.RequiredClass[x].Level then
      info.RequiredClass[x].Color = trueColor
     end
    end
   end
  end
  if n == 0 then 
   info.RequiredClass.None = {}
   info.RequiredClass.None.Class = 'None'
   info.RequiredClass.None.Level = '--'
   info.RequiredClass.None.Color = trueColor
  end

  info.RequiredAttribute = {}
  n = 0
  if class.RequiredAttribute then
   for x,_ in pairs(class.RequiredAttribute) do
    n = n + 1
    info.RequiredAttribute[x] = {}
    info.RequiredAttribute[x].Attribute = x
    info.RequiredAttribute[x].Amount = class.RequiredAttribute[x]
    info.RequiredAttribute[x].Color = falseColor
    if unitT and unitT.Attributes[x] then
     if unitT.Attributes[x].Base >= tonumber(class.RequiredAttribute[x]) then
      info.RequiredAttribute[x].Color = trueColor
     end
    end
   end
  end
  if n == 0 then 
   info.RequiredAttribute.None = {}
   info.RequiredAttribute.None.Attribute = 'None'
   info.RequiredAttribute.None.Amount = '--'
   info.RequiredAttribute.None.Color = trueColor
  end
  
  info.RequiredSkill = {}
  n = 0
  if class.RequiredSkill then
   for x,_ in pairs(class.RequiredSkill) do
    n = n + 1
    info.RequiredSkill[x] = {}
    info.RequiredSkill[x].Skill = x
    info.RequiredSkill[x].Level = class.RequiredSkill[x]
    info.RequiredSkill[x].Color = falseColor
    if unitT and unitT.Skills[x] then
     if unitT.Skills[x].Base >= tonumber(class.RequiredSkill[x]) then
      info.RequiredSkill[x].Color = trueColor
     end
    end
   end
  end
  if n == 0 then 
   info.RequiredSkill.None = {}
   info.RequiredSkill.None.Skill = 'None'
   info.RequiredSkill.None.Level = '--'
   info.RequiredSkill.None.Color = trueColor
  end
  
  info.ClassBonuses = {}
  info.ClassBonuses.Attribute  = {}
  info.ClassBonuses.Skill      = {}
  info.ClassBonuses.Stat       = {}
  info.ClassBonuses.Resistance = {}
  info.ClassBonuses.Order = {}
  info.ClassBonuses.Order.Attribute  = {}
  info.ClassBonuses.Order.Skill      = {}
  info.ClassBonuses.Order.Stat       = {}
  info.ClassBonuses.Order.Resistance = {}
  for i = 0, 10 do
   r = tostring(i)
   if safe_index(class.Level,r,'Adjustments') then
    info.ClassBonuses.Attribute[r]  = {}
    info.ClassBonuses.Skill[r]      = {}
    info.ClassBonuses.Stat[r]       = {}
    info.ClassBonuses.Resistance[r] = {}
    for t,_ in pairs(class.Level[r].Adjustments) do
     for x,_ in pairs(class.Level[r].Adjustments[t]) do
	  info.ClassBonuses[t][r][x] = class.Level[r].Adjustments[t][x]
	  info.ClassBonuses.Order[t][x] = x
	 end
    end
   end
  end

  temp = {}
  n = 1
  for i,x in pairs(info.ClassBonuses.Order.Attribute) do
   temp[n] = x
   n = n+1
  end
  info.ClassBonuses.Order.Attribute = temp
   
  info.LevelBonuses = {}
  -- Mimic the adjustments table(s) -ME
  
  info.Spells = {}
  if class.Spells then
   local n = 1
   for x,_ in pairs(class.Spells) do
    info.Spells[x] = {}
    info.Spells[x].Spell = x
    info.Spells[x].Level = class.Spells[x].RequiredLevel
    n = n + 1
   end
  end
 end

 return info
end
function getFeatInfo(unit,Type)
 local info = {}
 if not dfhack.findScript('base/roses-table') then return end
 roses = dfhack.script_environment('base/roses-table').roses
 local unitTable  = roses.UnitTable
 local featTable  = roses.FeatTable
 local classTable = roses.ClassTable
 local unitFeats
 if not tonumber(unit) and unitTable[tostring(unit.id)] then
  unitFeats = unitTable[tostring(unit.id)].Feats
 else
  unitFeats = nil
 end

 if Type == 'Basic' then
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
  info.Feats_Known = #unitTable.Feats
  info.Feat_Points = unitTable.Feats.Points

 elseif Type == 'All' then
  info.Feats = {}
  for x,_ in pairs(featTable) do
   info.Feats[x] = {}
   if unitFeats and unitFeats[x] then
    info.Feats[x].Learned = 'Yes'
   else
    info.Feats[x].Learned = 'No'
   end
  end
 elseif Type == 'Learned' then
  info.Feats = {}
  for x,_ in pairs(featTable) do
   if unitFeats and unitFeats[x] then
    info.Feats[x] = {}
    info.Feats[x].Learned = 'Yes'
   end
  end
 elseif Type == 'Class' then
  info.Feats = {}
  if unitTable[tostring(unit.id)] and unitTable[tostring(unit.id)].Classes.Current ~= 'NONE' then
   currentClass = unitTable[tostring(unit.id)].Classes.Current
   for x,_ in pairs(featTable) do
    if featTable[x].RequiredClass and featTable[x].RequiredClass[currentClass] then
     info.Feats[x] = {}
     if unitFeats[x] then
      info.Feats[x].Learned = 'Yes'
     else
      info.Feats[x].Learned = 'No'
     end
    end
   end
  end

 else
  if not featTable[Type] then return false end
  feat = featTable[Type]
  unitT = dfhack.script_environment('functions/unit').getUnitTable(unit)

  info.Name        = feat.Name
  info.Description = feat.Description
  info.Cost        = feat.Cost

  info.RequiredClass     = {}
  if feat.RequiredClass then
   for x,_ in pairs(feat.RequiredClass) do
    info.RequiredClass[x] = {}
    info.RequiredClass[x].Class = classTable[x].Name
    info.RequiredClass[x].Level = feat.RequiredClass[x]
    info.RequiredClass[x].Color = falseColor
    if unitT.Classes[x] then
     if tonumber(unitT.Classes[x].Level) >= tonumber(feat.RequiredClass[x]) then
      info.RequiredClass[x].Color = trueColor
     end
    end
   end
  end

  info.RequiredFeat     = {}
  if feat.RequiredFeat then
   for x,_ in pairs(feat.RequiredFeat) do
    info.RequiredFeat[x] = {}
    info.RequiredFeat[x].Feat  = featTable[x].Name
    info.RequiredFeat[x].Color = falseColor
    if unitT.Feats[x] then
     info.RequiredFeat[x].Color = trueColor
    end
   end
  end

  info.Effects = {}
  if feat.Effect then
   n = 1
   for x,_ in pairs(feat.Effect) do
    info.Effects[n] = {}
    info.Effects[n].Effect = x
    n = n + 1
   end
  end
 end

 return info
end
function getSpellInfo(unit,Type)
 local info = {}
 if not dfhack.findScript('base/roses-table') then return end
 roses = dfhack.script_environment('base/roses-table').roses
 local unitTable  = roses.UnitTable
 local spellTable = roses.SpellTable
 local classTable = roses.ClassTable
 local unitSpells
 if not tonumber(unit) and unitTable[tostring(unit.id)] then
  unitSpells = unitTable[tostring(unit.id)].Spells
 else
  unitSpells = nil
 end

 if Type == 'Basic' then
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
  info.Known_Spells = #unitTable.Spells.Learned
  info.Active_Spells = #unitTable.Spells.Active

 elseif Type == 'All' then
  info.Spells = {}
  for x,_ in pairs(spellTable) do
   info.Spells[x] = {}
   info.Spells[x].Learned = 'No'
   info.Spells[x].Active  = 'No'
   if unitSpells and unitSpells[x] and unitSpells[x] == 'true' then info.Spells[x].Learned = 'Yes' end
   if unitSpells and unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
  end
 elseif Type == 'Learned' then
  info.Spells = {}
  for x,_ in pairs(spellTable) do
   if unitSpells and unitSpells[x] and unitSpells[x] == 'true' then
    info.Spells[x] = {}
    info.Spells[x].Learned = 'Yes'
    info.Spells[x].Active  = 'No'
    if unitSpells and unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
   end
  end
 elseif Type == 'Class' then
  info.Spells = {}
  if unitTable[tostring(unit.id)] and unitTable[tostring(unit.id)].Classes.Current ~= 'NONE' then
   currentClass = unitTable[tostring(unit.id)].Classes.Current
   for x,_ in pairs(spellTable) do
    if spellTable[x].RequiredClass and spellTable[x].RequiredClass[currentClass] then
     info.Spells[x] = {}
     info.Spells[x].Learned = 'No'
     info.Spells[x].Active  = 'No'
     if unitSpells and unitSpells[x] and unitSpells[x] == 'true' then info.Spells[x].Learned = 'Yes' end
     if unitSpells and unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
    end
   end
  end
 elseif Type == 'Civ' then
  info.Spells = {}
  if unit.civ_id >= 0 and roses.EntityTable[tostring(unit.civ_id)] then
   civTable = roses.EntityTable[tostring(unit.civ_id)].Civilization
   if civTable then
    for x,_ in pairs(spellTable) do
     if civTable.Spells and civTable.Spells[x] then
      info.Spells[x] = {}
      info.Spells[x].Learned = 'No'
      info.Spells[x].Active  = 'No'
      if unitSpells and unitSpells[x] and unitSpells[x] == 'true' then info.Spells[x].Learned = 'Yes' end
      if unitSpells and unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
     end
    end
   end
  end

 else
  if not spellTable[Type] then return false end
  spell = spellTable[Type]
  unitT = dfhack.script_environment('functions/unit').getUnitTable(unit)

  info.Name        = spell.Name
  info.Description = spell.Description
  info.Effect      = spell.Effect
  info.Upgrade     = spell.Upgrade or 'NA'

  info.Classification = {}
  info.Classification.Level = spell.Classification.Level or '0'
  for t,_ in pairs(spell.Classification) do
   info.Classification[t] = spell.Classification[t]
  end

  info.SpellDetails = {}
  for t,_ in pairs(spell.Details) do
   info.SpellDetails[t] = spell.Details[t]
  end

  info.RequiredClass = {}
  if spell.RequiredClass then
   for x,_ in pairs(spell.RequiredClass) do
    info.RequiredClass[x] = {}
    info.RequiredClass[x].Class = classTable[x].Name
    info.RequiredClass[x].Level = spell.RequiredClass[x]
    info.RequiredClass[x].Color = falseColor
    if unitT.Classes[x] then
     if unitT.Classes[x].Level >= info.RequiredClass[x].Level then
      info.RequiredClass[x].Color = trueColor
     end
    end
   end
  end

  info.RequiredSpell = {}
  if spell.RequiredSpell then
   for x,_ in pairs(spell.RequiredSpell) do
    info.RequiredFeat[x] = {}
    info.RequiredFeat[x].Spell = spellTable[x].Name
    info.RequiredFeat[x].Color = falseColor
    if unitT.Spells[x] then
     info.RequiredFeat[x].Color = trueColor
    end
   end
  end
  
  info.RequiredAttribute = {}
  if spell.RequiredAttribute then
   for x,_ in pairs(spell.RequiredAttribute) do
    info.RequiredAttribute[x] = {}
    info.RequiredAttribute[x].Attribute = x
    info.RequiredAttribute[x].Amount    = spell.RequiredAttribute[x]
    info.RequiredAttribute[x].Color = falseColor
    if unitT and unitT.Attributes[x] then
     if unitT.Attributes[x].Base >= info.RequiredAttribute[x].Level then
      info.RequiredAttribute[x].Color = trueColor
     end
    end
   end
  end
 end
 
 return info
end

--= Output Generating Functions
function getDUVOutput(info,viewDetails,cell,check)
 local insert = {}
 
 local what = viewDetails.fill[cell]
 local twhat = split(what,':')[1]
 local nwhat = split(what,':')[2]
 if twhat == 'on_submit' then what = viewDetails.on_submit[tonumber(nwhat)] end
 if twhat == 'on_select' then what = viewDetails.on_select[tonumber(nwhat)] end
 local view_id = viewDetails.viewScreen
 x, y = get_xy_cell(viewDetails.num_cols,viewDetails.num_rows,cell,-1)
 local w = viewDetails.widths[x][y]
 local keyed = false
 if viewDetails.functions then
  keyed = viewDetails.functions[what]
 end
 colorKey = info.ColorScheme

 if (view_id == 'main') then
  insert = getOutputMainView(info,what,w,check,keyed)
 elseif (view_id == 'detailedView') then
  insert = getOutputDetailedView(info,what,w,check,keyed)
 elseif (view_id == 'personalityView') then
  insert = getOutputPersonalityView(info,what,w,check,keyed)
 elseif (view_id == 'appearanceView') then
  insert = getOutputAppearanceView(info,what,w,check,keyed)
 elseif (view_id == 'relationshipView') then
  insert = getOutputRelationshipView(info,what,w,check,keyed)
 elseif (view_id == 'healthView') then
  insert = getOutputHealthView(info,what,w,check,keyed)
 elseif (view_id == 'inventoryView') then
  insert = getOutputInventoryView(info,what,w,check,keyed)

 elseif (what == 'ClassesList' or what == 'FeatsList' or what == 'SpellsList') then
  local n = split(what,'List')[1]
  local Info = info[n]
  if not Info then return insert end
  local order = Info._order
  local options = {width=w, colOrder=order, view_id=view_id, cell=cell}
  insert = insertWidgetInput(insert, 'list', Info[check][n], options)
 
 elseif (what == 'ClassDetails' or what == 'FeatDetails' or what == 'SpellDetails') then
  insert = getOutputClassSystem(info,what,w,check,view_id)
 
 else
  print('Unrecognized output request '..what)
 end
 
 return insert
end
function getOutputMainView(info,what,w,check,keyed)
 local insert = {}
 local colors = colorTables[colorKey]

 if (what == 'BaseInfo') then
  insert = insertWidgetInput(insert, 'center', 'Basic Information', {width=w,keyed=keyed})
  local order = {'Name','Caste','Age','Entity','Membership','Position'}
  insert = insertWidgetInput(insert, 'header', info.Base, {width=w, rowOrder=order})
  
  insert = insertWidgetInput(insert, 'text', '', {width=w})
  insert = insertWidgetInput(insert, 'center', 'Statistics', {width=w})
  order = {'Speed','Size','Area','Length','Hunger','Thirst','Sleepy'}
  insert = insertWidgetInput(insert, 'header',  info.Base.Measurements, {width=w, rowOrder=order})
  
 elseif (what == 'Description') then
  insert = insertWidgetInput(insert, 'center', 'Description',    {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'text',   info.Description, {width=w})

 elseif (what == 'AttributesBasic') then
  insert = insertWidgetInput(insert, 'center', 'Attributes',                   {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'text',   info.Attributes.Basic.Physical, {width=w})
  insert = insertWidgetInput(insert, 'text',   info.Attributes.Basic.Mental,   {width=w})

 elseif (what == 'RelationshipsBasic') then
  local Info = info.Relationships.Basic
  local order = {'Mother','Father','Spouse','Children','Orientation','Friends','Grudges'}
  insert = insertWidgetInput(insert, 'center', 'Relationships and Worship', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header', Info,                        {width=w, rowOrder=order})
  insert = insertWidgetInput(insert, 'text',   Info.Worship,                {width=w})  

 elseif (what == 'AppearanceBasic') then
  local Info = info.Appearance.Basic
  local order = {'String'}
  insert = insertWidgetInput(insert, 'center', 'Appearance', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'text',   Info,         {width=w})  

 elseif (what == 'HealthBasic') then
  local Info = info.Health.Basic
  insert = insertWidgetInput(insert, 'center', 'Health', {width=w, keyed=keyed})
  for _,injury in pairs(Info.Injury) do
   insert = insertWidgetInput(insert, 'text', injury, {width=w})
  end
  insert = insertWidgetInput(insert, 'header', Info, {width=w, rowOrder={'Syndromes'}})
 
 elseif (what == 'SkillsBasic') then
  local Info = info.Skills.Basic
  local order = {'Profession','Labors','Legendary'}
  insert = insertWidgetInput(insert, 'center', 'Skills', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header',  Info,    {width=w, rowOrder=order})
 
 elseif (what == 'PersonalityBasic') then
  local Info = info.Personality.Basic
  insert = insertWidgetInput(insert, 'center', 'Personality',    {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'text', Info.Stress, {width=w})
  insert = insertWidgetInput(insert, 'text', Info.Focus,  {width=w})
  insert = insertWidgetInput(insert, 'text', Info.Dreams, {width=w})
 
 elseif (what == 'InventoryBasic') then
  local Info  = info.Inventory.Basic
  local order = {'HD','UB','LB'}
  insert = insertWidgetInput(insert, 'center', 'Inventory', {width=w,keyed=keyed})
  insert = insertWidgetInput(insert, 'header',  Info,       {width=w,rowOrder=get_order(Info,order)})
  
 elseif (what == 'ClassBasic') then
  if not info.Classes then return insert end
  insert = insertWidgetInput(insert, 'center', 'Class Information', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header', info.Classes.Basic,  {width=w, rowOrder={'Current','Level','Experience'}})
  
 elseif (what == 'FeatBasic') then
  if not info.Feats then return insert end
  insert = insertWidgetInput(insert, 'center', 'Feat Information', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header', info.Feats.Basic,   {width=w, rowOrder={'Feats_Known','Feat_Points'}})
  
 elseif (what == 'SpellBasic') then
  if not info.Spells then return insert end
  insert = insertWidgetInput(insert, 'center', 'Spell Information', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'header', info.Spells.Basic,   {width=w, rowOrder={'Active_Spells','Known_Spells'}})
  
 end
 
 return insert
end
function getOutputInventoryView(info,what,w,check,keyed)
 local insert =  {}
 local colors = colorTables
 
 if (what == 'InventoryDetailed') then
  local Info = info.Inventory.Detailed
  local rowOrder = {'Weapon','Worn','Strapped','Hauled','Piercing','StuckIn',
                    'WrappedAround','SewnInto','Flask','Pet','InMouth'}
  local colOrder = {'Material','Wear'}
  local headOrder = {}
  local options = {width=w, colOrder=colOrder, rowOrder=rowOrder, headOrder=headOrder, nohead=true}
  insert = insertWidgetInput(insert,'center','Inventory',{width=w})
  insert = insertWidgetInput(insert, 'table', Info.Inventory, options)
  
 elseif (what == 'OwnedDetailed') then
  local Info = info.Inventory.Detailed
  insert = insertWidgetInput(insert,'center','Owned Items',{width=w})
 
 end
 
 return insert
end
function getOutputPersonalityView(info,what,w,check,keyed)
 local insert = {}
 local colors = colorTables
 
 if (what == 'ThoughtsDetailed') then
  local Info = info.Personality.Detailed
  insert = insertWidgetInput(insert, 'center', 'Thoughts', {width=w})
  if check == 'Strings' then
   for i,x in pairs(Info.Thoughts) do
    insert = insertWidgetInput(insert, 'text', x, {width=w})
   end
  elseif check == 'Numbers' then
   local order = {'Thought'}
   insert = insertWidgetInput(insert, 'table',  Info.Thoughts, {width=w, colOrder=order, nohead=true})
  end
  
 elseif (what == 'NeedsDetailed') then
  local Info = info.Personality.Detailed
  insert = insertWidgetInput(insert, 'center', 'Focus', {width=w})
  if check == 'Strings' then
   for i,x in pairs(Info.Needs) do
    if x.String ~= '' then
     insert = insertWidgetInput(insert, 'text', x, {width=w})
    end
   end
  elseif check == 'Numbers' then
   local order = {'Strength'}
   insert = insertWidgetInput(insert, 'table',  Info.Needs, {width=w, colOrder=order, nohead=true})
  end
  
 elseif (what == 'PreferencesDetailed') then
  local Info = info.Personality.Detailed
  insert = insertWidgetInput(insert, 'center', 'Preferences', {width=w})
  if check == 'Strings' then
   for i,x in pairs(Info.Preferences) do
    insert = insertWidgetInput(insert, 'text', x, {width=w})
   end
  elseif check == 'Numbers' then
   local order = {'SubType'}
   insert = insertWidgetInput(insert, 'table',  Info.Preferences, {width=w, colOrder=order, nohead=true})
  end
  
 elseif (what == 'ValuesDetailed') then
  local Info = info.Personality.Detailed
  insert = insertWidgetInput(insert, 'center', 'Values', {width=w})
  if check == 'Strings' then 
   for i,x in pairs(Info.Values) do
    insert = insertWidgetInput(insert, 'text', x, {width=w})
   end
  elseif check == 'Numbers' then
   local order = {'Strength'}
   insert = insertWidgetInput(insert, 'table',  Info.Values, {width=w, colOrder=order, nohead=true})
  end
  
 elseif (what == 'TraitsDetailed') then
  local Info = info.Personality.Detailed
  insert = insertWidgetInput(insert, 'center', 'Traits', {width=w})
  if check == 'Strings' then
   for i,x in pairs(Info.Traits) do
    if x._string ~= '' then
     insert = insertWidgetInput(insert, 'text', x, {width=w})
    end
   end
  elseif check == 'Numbers' then
   local order = {'Strength'}
   insert = insertWidgetInput(insert, 'table',  Info.Traits, {width=w, colOrder=order, nohead=true})
  end
 end
 
 return insert
end
function getOutputAppearanceView(info,what,w,check,keyed)
 local insert = {}
 local colors = colorTables
 local main_parts = {}
 main_parts['Body'] = true
 main_parts['Head'] = true
 main_parts['Eyes'] = true
 main_parts['Hair'] = true
 main_parts['Nose'] = true
 main_parts['Skin'] = true
 main_parts['Ears'] = true
 main_parts['Skull'] = true
 
 if (what == 'AppearanceDetailedMain') then
  local Info = info.Appearance.Detailed
  if check == 'String' then
   order = {'String'}
  elseif check == 'Numbers' then
   order = {'Value','Bin'}
  end
  insert = insertWidgetInput(insert, 'center', 'Appearance', {width=w})
  options = {width=w, colOrder=order}
  for part,mods in pairs(Info) do
   local count = 0
   for _ in pairs(mods) do count = count + 1 end
   if count > 0 then
    options.list_head = part:gsub("(%a)([%w_']*)", tchelper)
    if main_parts[options.list_head] then
     insert = insertWidgetInput(insert, 'table', Info[part], options)
    end
   end
  end

 elseif (what == 'AppearanceDetailedSub') then
  local Info = info.Appearance.Detailed
  if check == 'String' then
   order = {'String'}
  elseif check == 'Value' then
   order = {'Value','Bin'}
  end
  insert = insertWidgetInput(insert, 'center', 'Appearance', {width=w})
  options = {width=w, colOrder=order}
  for part,mods in pairs(Info) do
   local count = 0
   for _ in pairs(mods) do count = count + 1 end
   if count > 0 then
    options.list_head = part:gsub("(%a)([%w_']*)", tchelper)
    if not main_parts[options.list_head] then
     insert = insertWidgetInput(insert, 'table', Info[part], options)
    end
   end
  end
 end
 
 return insert
end
function getOutputDetailedView(info,what,w,check,keyed)
 local insert = {}
 local colors = colorTables
 
 if (what == 'AttributesDetailed') then
  local Info = info.Attributes.Detailed
  if check == 'String' then
   order = {'String'}
   nohead = true
   listHead = ''
  elseif check == 'Numbers' then
   order = {}
   if info.Systems.Class then table.insert(order,'Class') end
   if info.Systems.EnhancedItem then table.insert(order,'Item') end
   table.insert(order,'Syndrome')
   table.insert(order,'Total')
   nohead = false
   listHead = 'Attribute'
  end
  local options = {width=w, colOrder=order, nohead=nohead}
  insert = insertWidgetInput(insert, 'center', 'Attributes',  {width=w})
  options.list_head = 'Physical'
  options.rowOrder = get_order(Info.Physical)
  insert = insertWidgetInput(insert, 'table',  Info.Physical, options)
  options.list_head = 'Mental'
  options.rowOrder = get_order(Info.Mental)
  insert = insertWidgetInput(insert, 'table',  Info.Mental,   options)
  options.list_head = 'Cutoms'
  options.rowOrder = get_order(Info.Custom)
  insert = insertWidgetInput(insert, 'table',  Info.Custom,   options)
  
 elseif (what == 'SkillsDetailed') then
  local Info = info.Skills.Detailed
  if check == 'String' then
   order = {'String'}
  elseif check == 'Numbers' then
   order = {}
   if info.Systems.Class then table.insert(order,'Class') end
   if info.Systems.EnhancedItem then table.insert(order,'Item') end
   table.insert(order,'Level')
   table.insert(order,'Exp')
  end
  local skillTypes = {'Crafting','Gathering','Farming','Military','Performance','Social','Science','Other','Custom'}
  insert = insertWidgetInput(insert, 'center', 'Skills', {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Labors, {width=w, colOrder=order, list_head='Labors'})
  for _,x in pairs(skillTypes) do
   if Info[x] and #Info[x] > 0 then
    insert = insertWidgetInput(insert, 'table', Info[x], {width=w, colOrder=order, list_head=x})
   end
  end
 
 elseif (what == 'StatsDetailed') then
  local Info = info.StatRes.Detailed
  local order = {}
  if info.Systems.Class then table.insert(order,'Class') end
  if info.Systems.EnhancedItem then table.insert(order,'Item') end
  table.insert(order,'Syndrome')
  table.insert(order,'Total')
  insert = insertWidgetInput(insert, 'center', 'Stats',    {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Stats, {width=w, colOrder=order, list_head='Custom'})
 
 elseif (what == 'ResistancesDetailed') then
  local Info = info.StatRes.Detailed
  local order = {}
  if info.Systems.Class then table.insert(order,'Class') end
  if info.Systems.EnhancedItem then table.insert(order,'Item') end
  table.insert(order,'Syndrome')
  table.insert(order,'Total')
  insert = insertWidgetInput(insert, 'center', 'Resistances',    {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Resistances, {width=w, colOrder=order, list_head='Custom'})
  
 end
 
 return insert
end
function getOutputRelationshipView(info,what,w,check,keyed)
 local insert  = {}
 local colors = colorTables
 
 if (what == 'RelationshipsFamily') then
  local Info = info.Relationships.Detailed
  insert = insertWidgetInput(insert, 'center', 'Family',   {width=w})
  for i = 1, #Info.Family do
   insert = insertWidgetInput(insert, 'text', Info.Family[i], {width=w})
  end
  
 elseif (what == 'RelationshipsFriends') then
  local Info = info.Relationships.Detailed
  insert = insertWidgetInput(insert, 'center', 'Friends',   {width=w})
  for i = 1, #Info.Friends do
   insert = insertWidgetInput(insert, 'text', Info.Friends[i], {width=w})
  end
 
 elseif (what == 'RelationshipsGrudges') then
  local Info = info.Relationships.Detailed
  insert = insertWidgetInput(insert, 'center', 'Grudges',   {width=w})
  for i = 1, #Info.Grudges do
   insert = insertWidgetInput(insert, 'text', Info.Grudges[i], {width=w})
  end
 
 elseif (what == 'RelationshipsMaster') then
  local Info = info.Relationships.Detailed
  insert = insertWidgetInput(insert, 'center', 'Master and Apprentice',   {width=w})
  for i = 1, #Info.MasterApprentice do
   insert = insertWidgetInput(insert, 'text', Info.MasterApprentice[i], {width=w})
  end
 
 elseif (what == 'RelationshipsWorship') then
  local Info = info.Relationships.Detailed
  insert = insertWidgetInput(insert, 'center', 'Worship', {width=w, keyed=keyed})
  insert = insertWidgetInput(insert, 'text', Info.Worship, {width=w})
  
 end
 
 return insert
end
function getOutputHealthView(info,what,w,check,keyed)
 local insert = {}
 local colors = colorTables
 
 if (what == 'HealthDetailed') then
  local Info = info.Health.Detailed
  local woundOrder = {'Age'}
  local partOrder = {'Penetration','Bleed','Pain','Nausea','Strain'}
  insert = insertWidgetInput(insert, 'center', 'Wounds', {width=w})
  insert = insertWidgetInput(insert, 'table', Info.Wounds, {width=w, colOrder=partOrder, headOrder=woundOrder, list_head='Wounds'})
  
 elseif (what == 'SyndromeDetailed') then
  local Info = info.Health.Detailed
  local order = {'Start','Peaks','Sev','End','Dur'}
  local hW = w - 25
  insert = insertWidgetInput(insert, 'center', 'Syndromes', {width=w})
  for syn_name,syn_dets in pairs(Info.Syndromes) do
   insert = insertWidgetInput(insert, 'table', syn_dets, {width=w, colOrder=order, list_head=syn_name})
  end
 end
 
 return insert
end
function getOutputClassSystem(Info,what,w,check,view_id)
 local insert = {}
 local colors = colorTables
 
 if (what == 'ClassDetails') then
  if not check.text then return end
  local token = check.text[1].token
  local info = getClassInfo(Info.target,token)
  if not info then return insert end
  insert = insertWidgetInput(insert, 'center', info.Name,        {width=w})
  insert = insertWidgetInput(insert, 'text',   info.Description, {width=w})
  
  -- BASE INFO
  local order = {'Sphere','School','Levels'}
  insert = insertWidgetInput(insert, 'center', 'Basic Information', {width=w})
  insert = insertWidgetInput(insert, 'header', info.BaseInfo, {width=w, rowOrder=order})


  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',         {width=w})
  insert = insertWidgetInput(insert, 'table',  info.RequiredClass,     {width=w, colOrder={'Level'},  list_head='Class'})
  insert = insertWidgetInput(insert, 'table',  info.RequiredAttribute, {width=w, colOrder={'Amount'}, list_head='Attribute'})
  insert = insertWidgetInput(insert, 'table',  info.RequiredSkill,     {width=w, colOrder={'Level'},  list_head='Skill'})

  -- CLASS BONUSES
  insert = insertWidgetInput(insert, 'center', 'Class Bonuses', {width=w})
  insert = insertWidgetInput(insert, 'table',  info.ClassBonuses.Attribute, {width=w,colOrder=info.ClassBonuses.Order.Attribute})

  -- LEVELING BONUSES
  insert = insertWidgetInput(insert, 'center', 'Level Bonuses', {width=w})
  insert = insertWidgetInput(insert, 'table',  info.LevelBonus, {width=w})

  -- SPELLS AND ABILITIES
  insert = insertWidgetInput(insert, 'center', 'Spells',    {width=w})
  insert = insertWidgetInput(insert, 'table',  info.Spells, {width=w, colOrder={'Level'}, list_head='Spell'})

 elseif (what == 'FeatDetails') then
  if not check.text then return end
  local token = check.text[1].token
  local info = getFeatInfo(Info.target,token)
  if not info then return insert end
  insert = insertWidgetInput(insert, 'center', info.Name,        {width=w})
  insert = insertWidgetInput(insert, 'text',   info.Description, {width=w})

  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',     {width=w})
  insert = insertWidgetInput(insert, 'table',  info.RequiredClass, {width=w, colOrder={'Level'}, list_head='Class'})
  insert = insertWidgetInput(insert, 'table',  info.RequiredFeat,  {width=w, colOrder={'--'},    list_head='Feat'})

  -- EFFECTS
  insert = insertWidgetInput(insert, 'center', 'Effects',    {width=w})
  insert = insertWidgetInput(insert, 'table',  info.Effects, {width=w, colOrder={'--'}, nohead=true})

 elseif (what == 'SpellDetails') then 
  if not check.text then return end
  local token = check.text[1].token
  local info = getSpellInfo(Info.target,token)
  if not info then return insert end
  local c_order = {'Type','Sphere','School','Discipline','SubDiscipline'}
  insert = insertWidgetInput(insert, 'center', info.Name,           {width=w})
  insert = insertWidgetInput(insert, 'text',   info.Description,    {width=w})
  insert = insertWidgetInput(insert, 'header', info.Classification, {width=w, rowOrder=c_order})
  insert = insertWidgetInput(insert, 'text',   info.Effect,         {width=w})
  insert = insertWidgetInput(insert, 'text',   '         ',         {width=w})

  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',         {width=w})
  insert = insertWidgetInput(insert, 'table',  info.RequiredClass,     {width=w, colOrder={'Level'},  list_head='Class'})
  insert = insertWidgetInput(insert, 'table',  info.RequiredAttribute, {width=w, colOrder={'Amount'}, list_head='Attribute'})
  insert = insertWidgetInput(insert, 'table',  info.RequiredSpell,     {width=w, colOrder={'--'},     list_head='Spell'})
  insert = insertWidgetInput(insert, 'text',   '         ',            {width=w})

  -- DETAILS
  insert = insertWidgetInput(insert, 'center', 'Spell Details',   {width=w})
  insert = insertWidgetInput(insert, 'header', info.SpellDetails, {width=w})
 end
 return insert
end