local utils = require 'utils'
local split = utils.split_string
local strings = dfhack.script_environment('functions/text')
local usages = {}

colorTables = {
  ['DEFAULT'] = {
    ['flagColor'] = COLOR_YELLOW,
    ['titleColor'] = COLOR_LIGHTCYAN,
    ['headColor']  = COLOR_LIGHTMAGENTA,
    ['subColor']   = COLOR_YELLOW,
    ['textColor']  = COLOR_WHITE,
    ['numColor']   = COLOR_LIGHTGREEN,
    ['colColor']   = COLOR_MAGENTA,
    ['falseColor'] = COLOR_LIGHTRED,
    ['trueColor']  = COLOR_LIGHTGREEN,
    ['keyColor']   = COLOR_RED,
    ['binColors']  = {
                      [-3] = COLOR_LIGHTRED,
                      [-2] = COLOR_YELLOW,
                      [-1] = COLOR_BROWN,
                      [0]  = COLOR_GREY,
                      [1]  = COLOR_WHITE,
                      [2]  = COLOR_GREEN,
                      [3]  = COLOR_LIGHTGREEN}},
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
                      [-3] = COLOR_WHITE,
                      [-2] = COLOR_WHITE,
                      [-1] = COLOR_WHITE,
                      [0]  = COLOR_WHITE,
                      [1]  = COLOR_WHITE,
                      [2]  = COLOR_WHITE,
                      [3]  = COLOR_WHITE}}
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
  cell = 1
  x = 1
  y = 1
  found = false
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
function get_order(tbl,ordering)
 local orderOut = {}
 local order = ordering or 'Alphabetical'
 
 if order == 'Alphabetical' then
  for x,_ in pairs(tbl) do
   orderOut[#orderOut+1] = x
  end
  table.sort(orderOut)
 end
 
 return orderOut
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
    Options: width, order, mark, token, list_head, hastitle, nohead, column_color, column_width, fgc, bgc
    
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
  str = list._string or list._text or ''
  list = str
 end
 
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
  str = list._text or list._string or ''
  list = str
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
  local penHead = colors.headColor
  local penNums = colors.numColor
  local penText = colors.textColor
  local penFlag = colors.flagColor
  if type(tbl) == 'table' then
   penHead = tbl._colorHeaders or penHead
   penNums = tbl._colorNumbers or penNums
   penText = tbl._colorText    or penText
   if type(tbl._second) == 'table' then
    local check = true
    if tbl._length and tbl._length == 0 then return outStr end
    for first,second in pairs(tbl._second) do
     flagStr = ' ['..first..']'
     fillStr = second
     if filling == 'first' or filling == 'flag' then
      fillStr = ''
     elseif filling == 'second' or filling == 'string' then
      flagStr = ''
     end
     if tonumber(fill) then 
      pen = penNums
     else
      pen = penText
     end
     if check then
      table.insert(outStr, {text = {
                                    {text=tbl._header,            width=#tbl._header,                pen=penHead},
                                    {text=fillStr, rjustify=true, width=width-#tbl._header-#flagStr, pen=pen},
                                    {text=flagStr, rjustify=true, width=#flagStr,                    pen=penFlag}
                                   }})
      check = false
     else
      table.insert(outStr, {text = { 
                                    {text='',                     width=#tbl._header,                pen=penHead},
                                    {text=fillStr, rjustify=true, width=width-#tbl._header-#flagStr, pen=pen},
                                    {text=flagStr, rjustify=true, width=#flagStr,                    pen=penFlag}
                                   }})
     end
    end    
   else
    if tbl._second == '' or tbl._second == '--' then return outStr end
    if tonumber(tbl._second) then
     pen = penNums
    else
     pen = penText
    end
    table.insert(outStr, {text = {
                                  {text=tbl._header,                width=#tbl._header,       pen=penHead},
                                  {text=tbl._second, rjustify=true, width=width-#tbl._header, pen=pen}
                                 }})
   end   
  else
   h = k
   s = tbl
   if tonumber(s) then
    pen = penNums
   else
    pen = penText
   end
   table.insert(outStr, {text = { 
                                 {text=h,                width=#h,       pen=penHead},
                                 {text=s, rjustify=true, width=width-#h, pen=pen}
                                }})
  end
  
  return outStr
 end
 
 if replacement then
  temp_list = {}
  temp_list_length = 0
  for first,second in pairs(list) do
   temp_first = replacement[first] or #temp_list + 1
   temp_second = replacement[second] or #temp_list + 1
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
   k = order[i]
   tbl = list[k]
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
 local hastitle   = options.hastitle or false
 local colwidth   = options.column_width or 6
 local width      = options.width or 40
 local rjustify   = options.rjustify or false
 local listHead   = options.list_head or ''
 local token      = options.token
 local colOrder   = options.colOrder or {'_string'}
 local rowOrder   = options.rowOrder
 local headOrder  = options.headOrder
 local keyed      = options.keyed
 local mark       = options.mark
 local scrollList = options.scrollList

 local abbrvs = {Syndrome='Syn', Item='Items', Strength='Str', Severity='Sev', Throat='Voice',
                 Penetration='Pen', Nausea='Nas'}

 hW = width - #colOrder*colwidth
 if not nohead and not headOrder then -- Puts column headers
  local temp_text = {}
  table.insert(temp_text, {text=listHead, width=hW, pen=colors.headColor})
  for i = 1, #colOrder do
   header = abbrvs[colOrder[i]] or colOrder[i]
   table.insert(temp_text, {text=center(header,colwidth), width=colwidth, pen=colors.colColor})
  end
  table.insert(input, {text=temp_text})
 end
 
 local function insert(outStr,k,tbl)
  local temp_str = {}
  
  if not nohead and headOrder then
   local temp_text = {}
   local listHead = tbl._listHead or tbl._title or ''
   table.insert(temp_text, {text=listHead, width=hW, pen=colors.headColor})
   for i = 1, #headOrder do
    header = abbrvs[headOrder[i]] or headOrder[i]
    table.insert(temp_text, {text=center(header,colwidth), width=colwidth, pen=colors.colColor})
   end
   table.insert(outStr, {text=temp_text})
  end  
  
  local key = tbl._key or tostring(k)
  local title = tbl._title or key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  if tbl._mark then title = tbl._mark..' '..title end
  if token     then key   = token..':'..key end
  penHead = tbl._colorHeaders or colors.textColor
  penNums = tbl._colorNumbers or colors.numColor
  penText = tbl._colorText    or colors.textColor  
  if tbl._colorBin then 
   penNums = colors.binColors[tbl._colorBin]
   penText = colors.binColors[tbl._colorBin] 
  end
  table.insert(temp_str, {text=title, width=hW, token=key, pen=penHead})
  
  if headOrder then
   order = headOrder
  else
   order = colOrder
  end
  for i = 1, #order do
   text = tbl[order[i]]
   if tonumber(text) then
    pen = penNums
   else
    pen = penText
   end
   table.insert(temp_str, {text=center(tostring(text),colwidth), width=colwidth, pen=pen})
  end
  table.insert(outStr, {text=temp_str})
  
  if tbl._second and type(tbl._second) == 'table' then
   lengthS = tbl._second._length or #tbl._second
   for iS = 0, lengthS do
    if tbl._second[iS] then
     second = tbl._second[iS]
     if not nohead and colOrder then
      local temp_text = {}
      local listHead = second._listHead or second._title or ''
      table.insert(temp_text, {text=' '..listHead, width=hW, pen=colors.headColor})
      for i = 1, #colOrder do
       header = abbrvs[colOrder[i]] or colOrder[i]
       table.insert(temp_text, {text=center(header,colwidth), width=colwidth, pen=colors.colColor})
      end
      table.insert(outStr, {text=temp_text})
     end     
   
     lengthT = second._length or #second
     for iT = 0, lengthT do
      if second[iT] then
       third = second[iT]
       temp_str = {}
       local key = third._key or tostring(iT)
       local title = third._title or key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
       if second._mark then title = third._mark..' '..title end
       if token     then key   = token..':'..key end
       penHead = third._colorHeaders or colors.textColor
       penNums = third._colorNumbers or colors.numColor
       penText = third._colorText    or colors.textColor  
       if third._colorBin then 
        penNums = colors.binColors[third._colorBin]
        penText = colors.binColors[third._colorBin] 
       end
       table.insert(temp_str, {text='  '..title, width=hW, token=key, pen=penHead})   
       for i = 1, #colOrder do
        text = third[colOrder[i]]
        if tonumber(text) then
         pen = penNums
        else
         pen = penText
        end
        table.insert(temp_str, {text=center(tostring(text),colwidth), width=colwidth, pen=pen})
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
 
 if rowOrder then
  for j = 1, #rowOrder do
   k = rowOrder[j]
   tbl = list[k]
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
 local colwidth   = options.column_width or 6
 local width      = options.width or 40
 local viewScreen = options.view_id
 local viewCell   = options.cell
 local token      = options.token
 local colOrder   = options.colOrder or {'_string'}
 local rowOrder   = options.rowOrder
 
 if not viewScreen or not viewCell then return input end
 hW = width - #colOrder*colwidth
 
 local function insert(outStr,k,tbl)
  local temp_str = {}
  if type(tbl) ~= 'table' then print(k,tbl) end
  local key = tbl._key or tostring(k)
  local title = tbl._title or key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
  if tbl._mark then title = tbl._mark..' '..title end
  if token     then key   = token..':'..key end
  penHead = tbl._colorHeaders or colors.headColor
  penNums = tbl._colorNumbers or colors.numColor
  penText = tbl._colorText    or colors.textColor  
  table.insert(temp_str, {text=title, width=hW, token=key, viewScreen=viewScreen, viewScreenCell=viewCell})
  for i = 1, #colOrder do
   text = tbl[colOrder[i]]
   if tonumber(text) then
    pen = penNums
   else
    pen = penText
   end
   table.insert(temp_str, {text=center(tostring(text),colwidth), width=colwidth, pen=pen})
  end
  table.insert(outStr, {text=temp_str})
  return outStr
 end
 
 if rowOrder then
  for j = 1, #rowOrder do
   k = rowOrder[j]
   tbl = list[k]
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
 
 info.Buildings = getBuildingInfo(vd['buildingView'],'List')
 info.Creatures = getCreatureInfo(vd['creatureView'],'List')
 info.Entities  = getEntityInfo  (vd['entityView'],  'List')
 info.Items     = getItemInfo    (vd['itemView'],    'List')
 info.Materials = getMaterialInfo(vd['materialView'],'List')
 info.Plants    = getPlantInfo   (vd['plantView'],   'List')
 info.Reactions = getReactionInfo(vd['reactionView'],'List')
 
 return info
end
function getBuildingInfo(extra,Type)
 local Table = df.global.world.raws.buildings
 local badTables = {}
 badTables['next_id'] = true
 local info  = {}
 
 if Type == 'List' then
  info._description = 'building compendium'
  info._stats = {}
  local sort  = extra.filterFlags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for bldgType,bldgTable in pairs(Table) do
   if not badTables[bldgType] then
    info._stats[bldgType] = tostring(#bldgTable)
    for j,bldg in pairs(bldgTable) do
     for _,flag in pairs(sort) do
      if flag == 'ALL' then  -- Right now there are no filters for buildings
       info[flag][bldgType] = info[flag][bldgType] or {}
       info[flag][bldgType][bldg.code] = {}
       info[flag][bldgType][bldg.code]._title = bldg.name
       info[flag][bldgType][bldg.code].ID = bldg.id
      end
     end
    end
   end
  end
 else
  local bldgRaw
  for i,bldg in pairs(Table['all']) do
   if bldg.code == Type then
    bldgRaw = bldg
    break
   end
  end
  
  -- Add building detail information here
 end
 
 return info
end
function getCreatureInfo(extra,Type)
 local Table = df.global.world.raws.creatures.all
 local info  = {}
 
 if Type == 'List' then
  info._description = 'creature compendium'
  info._stats = {}
  local sort  = extra.filterFlags --Sort by creature level flags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for i,creature in pairs(Table) do
   for _,flag in pairs(sort) do
    info._stats[flag] = 0
    if flag == 'ALL' or creature.flags[flag] then
     info[flag][creature.creature_id] = {}
     info._stats[flag] = info._stats[flag] + 1
     for j,caste in pairs(creature.caste) do
      info[flag][creature.creature_id][caste.caste_id] = {i,j}
     end
    end
   end
  end
  for i,j in pairs(info._stats) do
   info._stats[i] = tostring(j)
  end
 else
  i = tonumber(split(Type,':')[1])
  j = tonumber(split(Type,':')[2])
  creatureRaw = Table[i]
  casteRaw    = creatureRaw.caste[j]
  flagStrings = strings.creatureFlags
  
  info.Name = creatureRaw.name[0]
  info.CasteName = casteRaw.caste_name[0]
  if info.Name == info.CasteName then 
   if casteRaw.gender == 0 then
    info.CasteName = 'Female '..info.CasteName
   elseif casteRaw.gender == 1 then
    info.CasteName = 'Male '..info.CasteName
   end
  end
  
  info.Flags = {}
  for flag,bool in pairs(creatureRaw.flags) do
   if bool then info.Flags[flag] = true end
  end
  for flag,bool in pairs(casteRaw.flags) do
   if bool then info.Flags[flag] = true end
  end  

  -- Treat biomes special so we can accurately grab things like [BIOME:NOT_FREEZING]
  info.Biome = {}
  for _,line in pairs(creatureRaw.raws) do
   if split(line.value,':')[1] == '[BIOME' then
    flag = split(split(line.value,':')[2],']')[1]
    info.Biome[flag] = true
   end
  end
  
  info.PopNumbers = {}
  info.PopNumbers.MaxAge = 0
  info.PopNumbers.Frequency = creatureRaw.frequency
  info.PopNumbers.Clusters = tostring(creatureRaw.cluster_number[1])..':'..tostring(creatureRaw.cluster_number[0])
  info.PopNumbers.Population = tostring(creatureRaw.population_number[1])..':'..tostring(creatureRaw.population_number[0])
  
  info.StatNumbers = {}
  info.StatNumbers.Speed = 0
  info.StatNumbers.Size = 0
  
  info.Attacks = {}
  info.Attacks._header = 'Attacks'
  info.Attacks._second = {}
  for _,attack in pairs(casteRaw.body_info.attacks) do
   info.Attacks._second[attack.verb_2nd] = attack.verb_2nd
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
   n = n + 1
   matinfo = dfhack.matinfo.decode(casteRaw.extracts.milkable_mat,casteRaw.extracts.milkable_matidx)
   info.Products._second[n] = matinfo.material.state_name.Liquid
  end
  if casteRaw.extracts.webber_mat >= 0 then
   n = n + 1
   matinfo = dfhack.matinfo.decode(casteRaw.extracts.webber_mat,casteRaw.extracts.webber_matidx)
   info.Products._second[n] = matinfo.material.state_name.Solid
  end  
  for i,matid in pairs(casteRaw.extracts.extract_mat) do
   n = n + 1
   matinfo = dfhack.matinfo.decode(matid,casteRaw.extracts.extract_matidx[i])
   info.Products._second[n] = matinfo.material.state_name.Liquid
  end
  if n == 0 then info.Products._second[1] = 'None' end
  
  info.Description = casteRaw.description
  
  
  -- Add creature detail information here
 end
 
 return info
end
function getItemInfo(extra,Type)
 local Table = df.global.world.raws.itemdefs
 local badTables = {}
 badTables['tools_by_type'] = true
 local info  = {}
 
 if Type == 'List' then
  info._description = 'item compendium'
  info._stats = {}
  local sort  = extra.filterFlags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for itemType,itemTable in pairs(Table) do
   if not badTables[itemType] then
    info._stats[itemType] = tostring(#itemTable)
    for j,item in pairs(itemTable) do
     for _,flag in pairs(sort) do
      if flag == 'ALL' then  -- Right now there are no filters for items
       info[flag][itemType] = info[flag][itemType] or {}
       info[flag][itemType][item.id] = {}
       info[flag][itemType][item.id]._title = item.name
       info[flag][itemType][item.id].ID = j
      end
     end
    end
   end
  end
 else
  local itemRaw = Table.all[tonumber(Type)]
  
  -- Add item detail information here
 end
 
 return info
end
function getEntityInfo(extra,Type)
 local Table -- = df.global.world.raws
 local badTables = {}
 local info  = {}
 
 if Type == 'List' then
  info._description = 'building compendium'
  info._stats = {}

 else
  local entityRaw
  
 end
 
 return info
end
function getMaterialInfo(extra,Type)
 local Table -- = df.global.world.raws
 local badTables = {}
 local info  = {}
 
 if Type == 'List' then
  info._description = 'building compendium'
  info._stats = {}

 else
  local entityRaw
  
 end
 
 return info
end
function getReactionInfo(extra,Type)
 local Table -- = df.global.world.raws
 local badTables = {}
 local info  = {}
 
 if Type == 'List' then
  info._description = 'building compendium'
  info._stats = {}

 else
  local entityRaw
  
 end
 
 return info
end
function getPlantInfo(extra,Type)
 local Table = df.global.world.raws.plants
 local badTables = {}
 badTables['bushes_idx'] = true
 badTables['trees_idx'] = true
 badTables['grasses_idx'] = true
 local info  = {}
 
 if Type == 'List' then
  info._description = 'plant compendium'
  info._stats = {}
  local sort  = extra.filterFlags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for plantType,plantTable in pairs(Table) do
   if not badTables[plantType] then
    info._stats[plantType] = tostring(#plantTable)
    for j,plant in pairs(plantTable) do
     for _,flag in pairs(sort) do
      if flag == 'ALL' or plant.flags[flag] then  
       info[flag][plantType] = info[flag][plantType] or {}
       info[flag][plantType][plant.id] = {}
       info[flag][plantType][plant.id]._title = plant.name
       info[flag][plantType][plant.id].ID = j
      end
     end
    end
   end
  end
 else
  local plantRaw = Table.all[tonumber(Type)]
  
  -- Add item detail information here
 end
 
 return info
end

--= Output Generating Functions
function getJournalOutput(info,viewDetails,cell,check)
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
  keyed = viewDetails.functions[cell]
 end
 colorKey = info.ColorScheme
 
 local listOptions  = {width=w, colOrder={}, column_width=1, view_id=view_id, cell=cell}
 local tokenOptions = {width=w, colOrder={}, column_width=1, view_id=view_id, cell=cell, token=''}
 
 if (view_id == 'main') then
  insert = insertWidgetInput(insert, 'center', what,              {width=w, keyed=keyed})
  local Info = info[what]
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'text',   Info._description, {width=w})
  insert = insertWidgetInput(insert, 'header', Info._stats,       {width=w, rowOrder=get_order(Info._stats)})

 elseif (view_id == 'creatureView') then
  if (what == 'CreatureList')     then
   local Info = info.Creatures[check]
   if not Info then return insert end
   local options = {width=w, colOrder={}, column_width=7, view_id=view_id, cell=cell, rowOrder=get_order(Info)}
   insert = insertWidgetInput(insert, 'list', Info, options)
  elseif (what == 'CasteList')        then
   if not check.text then return end
   local Info = info.Creatures.ALL
   if not Info then return insert end
   local token = check.text[1].token
   local options = {width=w, colOrder={}, column_width=7, view_id=view_id, cell=cell, token=token, rowOrder=get_order(Info[token])}
   insert = insertWidgetInput(insert, 'list', Info[token], options) 
  else
   insert = getOutputCreature(info,w,check,what)
  end
  
 elseif (view_id == 'buildingView') then
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
   insert = getOutputBuilding(info,w,check,what)  
  end
  
 elseif (view_id == 'materialView') then 
  if (what == 'MaterialTypeList') then
 
  elseif (what == 'MaterialList')     then
 
  else
   insert = getOutputMaterial(info,w,check,what)
  end
  
 elseif (view_id == 'reactionView') then
  if (what == 'ReactionTypeList') then
 
  elseif (what == 'ReactionList')     then

  else
   insert = getOutputReaction(info,w,check,what)
  end
  
 elseif (view_id == 'itemView') then
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
   insert = getOutputItem(info,w,check,what)
  end
  
 elseif (view_id == 'entityView') then
  if (what == 'EntityTypeList')   then
 
  elseif (what == 'EntityList')       then

  else
   insert = getOutputEntity(info,w,check,what)
  end
  
 elseif (view_id == 'plantView') then
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
   insert = getOutputPlant(info,w,check,what)
  end
 
 else
  print('Unrecognized view_id '..view_id)
 end
 
 return insert
end
function getOutputCreature(info,w,check,what)
 local insert = {}
 
 if not check.text then return end
 local token = check.text[1].token
 x,y = table.unpack(split(token,':'))
 ids = info.Creatures.ALL[x][y]
 id_str = tostring(ids[1])..':'..tostring(ids[2])
 Info = getCreatureInfo(info,id_str)
 if not Info then return insert end
  -- Put detailed output here
 local flags = strings.creatureFlags
 
 if what == 'CreatureDetails' then
  insert = insertWidgetInput(insert, 'center', Info.Name, {width=w})
  insert = insertWidgetInput(insert, 'center', Info.CasteName, {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Description, {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Category',replacement=flags.TYPE_FLAGS})
 elseif what == 'group_Habitat' then
  local numbersOrder = {'MaxAge','Frequency','Population','Clusters'}
  insert = insertWidgetInput(insert, 'header', Info.PopNumbers, {width=w,rowOrder=numbersOrder})
  insert = insertWidgetInput(insert, 'header', Info.Biome, {width=w,replaceHeader='Biomes',replacement=flags.BIOME_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Active',replacement=flags.ACTIVITY_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Habitat',replacement=flags.HABITAT_FLAGS})
 elseif what == 'group_Stats' then
  local numbersOrder = {'Size','Speed'}
  insert = insertWidgetInput(insert, 'header', Info.StatNumbers, {width=w,rowOrder=numbersOrder}) 
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Movement',replacement=flags.MOVEMENT_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Attacks, {width=w})
  insert = insertWidgetInput(insert, 'header', Info.Interactions, {width=w})
 elseif what == 'group_Facts' then
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Utility',replacement=flags.UTILITY_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Behavior',replacement=flags.BEHAVIOR_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Diet',replacement=flags.DIET_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Immunities',replacement=flags.IMMUNITY_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Special',replacement=flags.BONUS_FLAGS})
 elseif what == 'group_BodyInfo' then
  insert = insertWidgetInput(insert, 'header', Info.Flags, {width=w,replaceHeader='Body',replacement=flags.BODY_FLAGS})
  insert = insertWidgetInput(insert, 'header', Info.Products, {width=w})
 else
  print('Unrecognized output request for view '..view_id..' '..what)
 end 

 return insert
end
function getOutputBuilding(info,w,check,what)
 local insert = {}

 if not check.text then return end
 local token = check.text[1].token
 local Info = getBuildingInfo(info,token)
 if not Info then return insert end
 -- Put detailed output here

 return insert
end
function getOutputItem(info,w,check,what)
 local insert = {}

 if not check.text then return end
 local token = check.text[1].token
 local id_str = tostring(info.Items['ALL']['all'][token])
 local Info = getItemInfo(info,id_str)
 if not Info then return insert end
 -- Put detailed output here

 return insert
end
function getOutputPlant(info,w,check,what)
 local insert = {}

 if not check.text then return end 
 local token = check.text[1].token
 local id_str = tostring(info.Plants['ALL']['all'][token])
 local Info = getPlantInfo(info,id_str)
 if not Info then return insert end
  -- Put detailed output here

 return insert
end
function getOutputMaterial(info,w,check,what)
 local insert = {}
 
 return insert
end
function getOutputReaction(info,w,check,what)
 local insert = {}
 
 return insert
end
function getOutputEntity(info,w,check,what)
 local insert = {}
 
 return insert
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
function getClassInfo(unit,Type)
 local info = {}
 roses = dfhack.script_environment('base/roses-init').roses
 local unitTable  = roses.UnitTable
 local classTable = roses.ClassTable
 local unitClasses
 if unitTable[tostring(unit.id)] then
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
 roses = dfhack.script_environment('base/roses-init').roses
 local unitTable  = roses.UnitTable
 local featTable  = roses.FeatTable
 local classTable = roses.ClassTable
 local unitFeats
 if unitTable[tostring(unit.id)] then
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
 roses = dfhack.script_environment('base/roses-init').roses
 local unitTable  = roses.UnitTable
 local spellTable = roses.SpellTable
 local classTable = roses.ClassTable
 local unitSpells
 if unitTable[tostring(unit.id)] then
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
  keyed = viewDetails.functions[cell]
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
 
 elseif (what == 'ClassesList' or what == 'FeatsList' or what == 'SpellsList') then
  local n = split(what,'List')[1]
  local Info = info[n]
  if not Info then return insert end
  local order = Info._order
  local options = {width=w, order=order, column_width=7, view_id=view_id, cell=cell}
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
  local order = {'Name','Caste','Age','Entity','Membership','Position'}
  insert = insertWidgetInput(insert, 'header',  info.Base, {width=w, rowOrder=order})
  
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
 
 elseif (what == 'ClassBasic') then
  if not info.Classes then return insert end
  insert = insertWidgetInput(insert, 'center', 'Class Information', {width=w, keyed=keyed})
  if info.Classes then insert = insertWidgetInput(insert, 'header', info.Classes.Basic, {width=w, rowOrder={'Current','Level','Experience'}}) end
  if info.Spells  then insert = insertWidgetInput(insert, 'header', info.Spells.Basic,  {width=w, rowOrder={'Active_Spells','Known_Spells'}}) end
  if info.Feats   then insert = insertWidgetInput(insert, 'header', info.Feats.Basic,   {width=w, rowOrder={'Feats_Known','Feat_Points'}}) end
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
   colwidth=25
  elseif check == 'Numbers' then
   order = {'Value','Bin'}
   colwidth=10
  end
  insert = insertWidgetInput(insert, 'center', 'Appearance', {width=w})
  options = {width=w, colOrder=order, column_width=colwidth}
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
   colwidth=25
  elseif check == 'Value' then
   order = {'Value','Bin'}
   colwidth=10
  end
  insert = insertWidgetInput(insert, 'center', 'Appearance', {width=w})
  options = {width=w, colOrder=order, column_width=colwidth}
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
   colwidth = w
   nohead = true
   listHead = ''
  elseif check == 'Numbers' then
   order = {}
   if info.Systems.Class then table.insert(order,'Class') end
   if info.Systems.EnhancedItem then table.insert(order,'Item') end
   table.insert(order,'Syndrome')
   table.insert(order,'Total')
   colwidth = 7
   nohead = false
   listHead = 'Attribute'
  end
  local options = {width=w, colOrder=order, nohead=nohead, column_width=colwidth}
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
   colWidth = 15
  elseif check == 'Numbers' then
   order = {}
   if info.Systems.Class then table.insert(order,'Class') end
   if info.Systems.EnhancedItem then table.insert(order,'Item') end
   table.insert(order,'Level')
   table.insert(order,'Exp')
   colWidth = 7
  end
  local skillTypes = {'Crafting','Gathering','Farming','Military','Performance','Social','Science','Other','Custom'}
  insert = insertWidgetInput(insert, 'center', 'Skills', {width=w})
  insert = insertWidgetInput(insert, 'table',  Info.Labors, {width=w, colOrder=order, list_head='Labors', column_width=colWidth})
  for _,x in pairs(skillTypes) do
   if Info[x] and #Info[x] > 0 then
    insert = insertWidgetInput(insert, 'table', Info[x], {width=w, colOrder=order, list_head=x, column_width=colWidth})
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
   insert = insertWidgetInput(insert, 'table', syn_dets, {width=w, colOrder=order, column_width=7, list_head=syn_name})
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