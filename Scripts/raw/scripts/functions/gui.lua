local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'
local usages = {}

--= String Functions
function tchelper(first, rest)
  return first:upper()..rest:lower()
end
function center(str, length)
 local string1 = str
 local string2 = string.format("%"..tostring(math.floor((length-#string1)/2)).."s"..string1,"")
 local string3 = string.format(string2.."%"..tostring(math.ceil((length-#string1)/2)).."s","")
 return string3
end

--= Widget Functions
function insertWidgetInput(input,method,list,options)
 options = options or {}
 pen = options.pen or COLOR_WHITE
 width = options.width or 40
 rjustify = options.rjustify or false
 temp_list_length = 0
 
 if options.replacement then
  temp_list = {}
  if method == 'header' then
   for first,second in pairs(list.second) do
    temp_first = options.replacement[first] or #temp_list+1
    temp_second = options.replacement[second] or #temp_list+1
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
   list.second = temp_list
   list.length = temp_list_length
  else
   for first,second in pairs(list) do
    temp_first = options.replacement[first] or #temp_list+1
    temp_second = options.replacement[second] or #temp_list+1
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
   list = temp_list
  end
 else
  list.length = 0
  if type(list.second) == 'table' then
   for _,_ in pairs(list.second) do
    list.length = list.length + 1
   end
  end
 end
 
 if method == 'first' then
  for first,second in pairs(list) do
   if first ~= 'length' then
    table.insert(input,{text=first,pen=pen,width=width,rjustify=rjustify})
   end
  end
 elseif method == 'second' then
  for first,second in pairs(list) do
   if first ~= 'length' then
    table.insert(input,{text={{text=second,pen=pen,width=width,rjustify=rjustify}}})
   end
  end
 elseif method == 'center' then
  table.insert(input,{text=center(list,width),width=width,pen=pen,rjustify=rjustify})
 elseif method == 'header' then
  if type(list.second) == 'table' then
   local check = true
   if list.length == 0 then
    return input
--    table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text='--',rjustify=true,width=width-#list.header,pen=pen}}})
   else
    for first,second in pairs(list.second) do
     if options.fill == 'flags' then
      fill = first
     elseif options.fill == 'both' then
      fill = second..' ['..first..']'
     else
      fill = second
     end
     if check then
      table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
      check = false
     else
      table.insert(input,{text={{text='',width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
     end
    end
   end
  else
   if list.second == '' or list.second == '--' then
    return input
   else
    table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text=list.second,rjustify=true,width=width-#list.header,pen=pen}}})
   end
  end
 elseif method == 'headerpt' then
  if list.second then
   local check = true
   for _,x in pairs(list.second._children) do
    fill = list.second[x]
    if check then
     table.insert(input,{text={{text=list.header,width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
     check = false
    else
     table.insert(input,{text={{text='',width=#list.header,pen=pen},{text=fill,rjustify=true,width=width-#list.header,pen=pen}}})
    end
   end
  else
   return input
  end
 end
 return input
end


--=                      Detailed Unit Viewer Functions
usages[#usages+1] = [===[

]===]

--= Information Gathering Functions
function getBaseInfo(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local info = {}

 -- Unit Name
 info['Name'] = dfhack.TranslateName(dfhack.units.getVisibleName(unit))

 -- Unit Caste
 local sex = ''
 local race = df.global.world.raws.creatures.all[tonumber(unit.race)].name[0]
 if unit.sex == 1 then 
  sex = 'Male '
 elseif unit.sex == 0 then 
  sex = 'Female '
 end
 local caste = df.global.world.raws.creatures.all[tonumber(unit.race)].caste[tonumber(unit.caste)].caste_name[0]
 info['Caste'] = race:gsub("^%l", string.upper)..', '..sex..caste:gsub("(%a)([%w_']*)", tchelper)

 -- Unit Entity
 local ent, civ, mem = '', '', ''
 if unit.civ_id >= 0 then 
  ent = df.global.world.entities.all[unit.civ_id].name
  ent = dfhack.TranslateName(ent)
 end
 if unit.population_id >= 0 then 
  civ = df.global.world.entity_populations[unit.population_id].name
  civ = dfhack.TranslateName(civ)
 end
 if unit.hist_figure_id >= 0 then
  local hf = df.global.world.history.figures[unit.hist_figure_id]
  for _,link in pairs(hf.entity_links) do
   if link.entity_id ~= unit.civ_id then 
    mem = df.global.world.entities.all[link.entity_id].name
	mem = dfhack.TranslateName(mem)
   end
  end
 end
 info['Entity'] = ent
 info['Civilization'] = civ
 info['Membership'] = mem

 return info
end
function getMembershipInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Membership = {'A basic description of the units memberships goes here'}
  info.Worship    = {'A basic description of the units main workship goes here'}
 elseif Type == 'Detailed' then
  info.Membership = {}
  info.Worship    = {}
 end

 return info
end
function getClassInfo(unit,w,Type)
 local info = {}
 local persistTable = require 'persist-table'
 local unitTable  = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then return false end
 local classTable = persistTable.GlobalTable.roses.ClassTable
 unitClasses = unitTable[tostring(unit.id)].Classes
 
 if Type == 'Basic' then
  info.Current = {'A basic description of the units current class goes here'}
  info.Classes = {'A basic description of the units other classes goes here'}
 elseif Type == 'All' then
  info.Classes = {}
  for i,x in pairs(classTable._children) do
   info.Classes[x] = {}
   if unitClasses[x] then
    info.Classes[x].Exp   = unitClasses[x].Level
    info.Classes[x].Level = unitClasses[x].Experience
   else
    info.Classes[x].Exp   = 0
    info.Classes[x].Level = 0
   end
  end
 elseif Type == 'Learned' then
  info.Classes = {}
  for i,x in pairs(classTable._children) do
   if unitClasses[x] then
    info.Classes[x] = {}
    info.Classes[x].Exp   = unitClasses[x].Level
    info.Classes[x].Level = unitClasses[x].Experience
   end
  end
 elseif Type == 'Available' then
  info.Classes = {}
  for i,x in pairs(classTable._children) do
   if dfhack.script_environment('functions/class').checkRequirementsClass(unit,x) then
    info.Classes[x] = {}
    info.Classes[x].Exp   = unitClasses[x].Level
    info.Classes[x].Level = unitClasses[x].Experience
   end
  end
 elseif Type == 'Civ' then
  info.Classes = {}
  if unitTable.Civilization and unit.civ_id >= 0 then
   civTable = persistTable.GlobalTable.roses.EntityTable[tostring(unit.civ_id)].Civilization
   for i,x in pairs(classTable._children) do
    if civTable.Classes[x] then
     info.Classes[x] = {}
     if unitClasses[x] then
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

  info.RequiredClass     = {}
  for i,x in pairs(class.RequiredClass._children) do
   info.RequiredClass[x] = {}
   info.RequiredClass[x].Name  = classTable[x].Name
   info.RequiredClass[x].Level = class.RequiredClass[x]
   info.RequiredClass[x].Check = false
   if unitT.Classes[x] then
    if unitT.Classes[x].Level >= info.RequiredClass[x].Level then
     info.RequiredClass[x].Check = true
    end
   end
  end

  info.RequiredAttribute = {}
  for i,x in pairs(class.RequiredAttribute._children) do
   info.RequiredAttribute[x] = {}
   info.RequiredAttribute[x].Name  = x
   info.RequiredAttribute[x].Level = class.RequiredAttribute[x]
   info.RequiredAttribute[x].Check = false
   if unitT and unitT.Attributes[x] then
    if unitT.Attributes[x].Base >= info.RequiredAttribute[x].Level then
     info.RequiredAttribute[x].Check = true
    end
   end
  end

  info.RequiredSkill = {}
  for i,x in pairs(class.RequiredSkill._children) do
   info.RequiredSkill[x] = {}
   info.RequiredSkill[x].Name  = x
   info.RequiredSkill[x].Level = class.RequiredSkill[x]
   info.RequiredSkill[x].Check = true
   if unitT and unitT.Skills[x] then
    if unitT.Skills[x].Base >= info.RequiredSkill[x].Level then
     info.RequiredSkill[x].Check = true
    end
   end
  end

  info.ClassBonuses = {}
  local n = 1
  for i,t in pairs(class.Level['0'].Adjustments._children) do
   for j,x in pairs(class.Level['0'].Adjustments[t]._children) do
    info.ClassBonuses[n] = {}
    info.ClassBonuses[n].Type = t
    info.ClassBonuses[n].Name = x
    info.ClassBonuses[n].Level = class.Level['0'].Adjustments[t][x]
    n = n + 1
   end
  end

  info.LevelBonuses = {}
  n = 1
  for i,t in pairs(class.Level['0'].LevelBonus._children) do
   for j,x in pairs(class.Level['0'].LevelBonus[t]._children) do
    info.LevelBonuses[n] = {}
    info.LevelBonuses[n].Type = t
    info.LevelBonuses[n].Name = x
    info.LevelBonuses[n].Level = class.Level['0'].LevelBonus[t][x]
    n = n + 1
   end
  end

  info.Spells = {}
  n = 1
  for i,x in pairs(class.Spells._children) do
   info.Spells[n] = {}
   info.Spells[n].Name  = x
   info.Spells[n].Level = class.Spells[x].RequiredLevel
  end
 end

 return info
end
function getDescriptionInfo(unit,w,Type)
 local info = ''

 info = {'The creature description goes here'}

 return info
end
function getAppearanceInfo(unit,w,Type)
 local info = ''

 info = {'The units apperance goes here'}

 return info
end
function getThoughtInfo(unit,w,Type)
 local info = {}

 if     Type == 'Basic' then
  info.Thoughts    = {'Basic thought information goes here'}
  info.Preferences = {'Basic preference information goes here'}
  info.Traits      = {'Basic trait information goes here'}
 elseif Type == 'Detailed' then
  info.Thoughts    = {}
  info.Preferences = {}
  info.Traits      = {}
 end

 return info
end
function getHealthInfo(unit,w,Type)
 local info = {}
 syndromes, syndrome_details = dfhack.script_environment('functions/unit').getSyndrome(unit,'All','detailed')

 if Type == 'Basic' then
  info.Injury    = {'A basic description of any unit injuries goes here'}
  info.Syndromes = {'A basic description of any sickness goes here'}
 elseif Type == 'Detailed' then
  syndromes, syndrome_details = dfhack.script_environment('functions/unit').getSyndrome(unit,'All','detailed')
  info.Injury    = {}
  info.Syndromes = syndromes
  info.SyndromeDetails = syndrome_details
 end

 return info
end
function getAttributeInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Physical = {'A basic description of the units physical attributes goes here'}
  info.Mental   = {'A basic description of the units mental attributes goes here'}
 elseif Type == 'Detailed' then
  info.Physical = {}
  info.Mental   = {}
  info.Custom   = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit).Attributes
  for attr, tbl in pairs(unitTable) do
   name = attr:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   if df.physical_attribute_type[attr] then
    info.Physical[name] = tbl
   elseif df.mental_attribute_type[attr] then
    info.Mental[name] = tbl
   else
    info.Custom[name] = tbl
   end
  end 
 end

 return info
end
function getSkillInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Profession = {'A basic description of the units base profession skills goes here'}
  info.Misc       = {'A basic description of the units other skills goes here'}
 elseif Type == 'Detailed' then
  info.InGame = {}
  info.Custom = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit).Skills
  for skill, tbl in pairs(unitTable) do
   if df.job_skill[skill] then
    name = df.job_skill.attrs[skill].caption_noun
    info.InGame[name] = tbl
   else
    name = persistTable.GlobalTable.roses.BaseTable.CustomSkills[skill]
    info.Custom[name] = tbl
   end
  end
 end
 
 return info
end
function getStatResistanceInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Stats       = {'A basic description of the units stats goes here'}
  info.Resistances = {'A basic description of the units resistances goes here'}
 elseif Type == 'Detailed' then
  info.Stats        = {}
  info.Resistances  = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit)
  for stat,tbl in pairs(unitTable.Stats) do
   name = stat--:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   info.Stats[name] = tbl
  end
  for resistance,tbl in pairs(unitTable.Resistances) do
   name = resistance--:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   info.Resistances[name] = tbl
  end
 end

 return info
end

--= Output Generating Functions
function getMainOutput(grid,unit,w,check)
 --[[ LAYOUT
   |       X            |      Y         |       Z           |
 --|--------------------|----------------|-------------------|
 A | Base Information   | Description    | Attributes        |
 --|--------------------|----------------|-------------------|
 B | Membership/Worship | Appearance     | Skills            |
 --|--------------------|----------------|-------------------|
 C | Class Information  | Health         | Stats/Resistances |
 -------------------------------------------------------------
 ]]

 local insert = {}
 local titleColor = COLOR_LIGHTCYAN

 if     (grid == 'AX') then -- Base Information
  Info = getBaseInfo(unit)
  for h,s in pairs(Info) do
   insert = insertWidgetInput(insert, 'header', {header=h, second=s}, {width=w})
  end
 elseif (grid == 'AY') then -- Description
  Info = getDescriptionInfo(unit,w,'Basic')
  table.insert(insert,{text = {{text = center('Description',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info, {width=w})

 elseif (grid == 'AZ') then -- Attribute Information
  Info = getAttributeInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Attributes',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Physical, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Mental, {width=w})

 elseif (grid == 'BX') then -- Membership/Worship Information
  Info = getMembershipInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Membership and Worship',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Membership, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Worship, {width=w})

 elseif (grid == 'BY') then -- Appearance
  Info = getAppearanceInfo(unit,w,'Basic')
  table.insert(insert,{text = {{text = center('Appearance',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info, {width=w})

 elseif (grid == 'BZ') then -- Skills
  Info = getSkillInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Skills',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Profession, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Misc, {width=w})
 
 elseif (grid == 'CX') then -- Class Information
  if check then
   Info = getClassInfo(unit,w,'Basic')
   if Info then
    table.insert(insert,{text = {{text = center('Class Information',w), width = w, pen=titleColor}}})
    insert = insertWidgetInput(insert, 'second', Info.Current, {width=w})
    table.insert(insert,{text = { {text = '', width=w}}})
    insert = insertWidgetInput(insert, 'second', Info.Classes, {width=w})
   end
  end

 elseif (grid == 'CY') then -- Health Information
  Info = getHealthInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Health',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Injury, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Syndromes, {width=w})

 elseif (grid == 'CZ') then -- Stats and Resistances
  Info = getStatResistanceInfo(unit,w,'Basic')
  table.insert(insert,{text = { {text = center('Stats and Resistances',w), width = w, pen=titleColor}}})
  insert = insertWidgetInput(insert, 'second', Info.Stats, {width=w})
  table.insert(insert,{text = { {text = '', width=w}}})
  insert = insertWidgetInput(insert, 'second', Info.Resistances, {width=w})

 end

 return insert
end
function getDetailsOutput(grid,unit,w)
 --[[ LAYOUT
   |       X      |      Y      |
 --|--------------|-------------|
 A | Attributes   | Skills      |
 --|--------------|-------------|
 B | Resistances  | Stats       |
 --------------------------------
 ]]
 local insert = {}
 local titleColor = COLOR_LIGHTCYAN
 local headColor = COLOR_LIGHTMAGENTA
 local colColor = COLOR_WHITE
 local fgc = COLOR_LIGHTGREEN
 local hW

 if     grid == 'D_AX' then
  hW = w-38
  Info = getAttributeInfo(unit,0,'Detailed')
  table.insert(insert, {text = {{text=center('Attributes',w), width = w, pen=titleColor}}})
  table.insert(insert, {text = {{text=center('Physical',w), width = w, pen=headColor}}})
  table.insert(insert, {text = {
                                {text='',                        width=hW              },
                                {text='Current',  rjustify=true, width=9,  pen=colColor},
                                {text='Class',    rjustify=true, width=7,  pen=colColor},
                                {text='Item',     rjustify=true, width=6,  pen=colColor},
                                {text='Syndrome', rjustify=true, width=10, pen=colColor},
                                {text='Base',     rjustify=true, width=6,  pen=colColor}
                               }})
  for attr,tbl in pairs(Info.Physical) do
   table.insert(insert, {text = {
                                 {text=attr,                                  width=hW, pen=fgc},
                                 {text=tostring(tbl.Total),    rjustify=true, width=9,  pen=fgc},
                                 {text=tostring(tbl.Class),    rjustify=true, width=7,  pen=fgc},
                                 {text=tostring(tbl.Item),     rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Syndrome), rjustify=true, width=10, pen=fgc},
                                 {text=tostring(tbl.Base),     rjustify=true, width=6,  pen=fgc}
                                }})
  end
  table.insert(insert, {text = {{text=center('Mental',w), width = w, pen=headColor}}})
  table.insert(insert, {text = {
                                {text='',                        width=hW              },
                                {text='Current',  rjustify=true, width=9,  pen=colColor},
                                {text='Class',    rjustify=true, width=7,  pen=colColor},
                                {text='Item',     rjustify=true, width=6,  pen=colColor},
                                {text='Syndrome', rjustify=true, width=10, pen=colColor},
                                {text='Base',     rjustify=true, width=6,  pen=colColor}
                               }})
  for attr,tbl in pairs(Info.Mental) do
   table.insert(insert, {text = {
                                 {text=attr,                                  width=hW, pen=fgc},
                                 {text=tostring(tbl.Total),    rjustify=true, width=9,  pen=fgc},
                                 {text=tostring(tbl.Class),    rjustify=true, width=7,  pen=fgc},
                                 {text=tostring(tbl.Item),     rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Syndrome), rjustify=true, width=10, pen=fgc},
                                 {text=tostring(tbl.Base),     rjustify=true, width=6,  pen=fgc}
                                }})
  end

  table.insert(insert, {text = {{text=center('Custom',w), width = w, pen=headColor}}})
  table.insert(insert, {text = {
                                {text='',                        width=hW              },
                                {text='Current',  rjustify=true, width=9,  pen=colColor},
                                {text='Class',    rjustify=true, width=7,  pen=colColor},
                                {text='Item',     rjustify=true, width=6,  pen=colColor},
                                {text='Syndrome', rjustify=true, width=10, pen=colColor},
                                {text='Base',     rjustify=true, width=6,  pen=colColor}
                               }})
  for attr,tbl in pairs(Info.Custom) do
   table.insert(insert, {text = {
                                 {text=attr,                                  width=hW, pen=fgc},
                                 {text=tostring(tbl.Total),    rjustify=true, width=9,  pen=fgc},
                                 {text=tostring(tbl.Class),    rjustify=true, width=7,  pen=fgc},
                                 {text=tostring(tbl.Item),     rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Syndrome), rjustify=true, width=10, pen=fgc},
                                 {text=tostring(tbl.Base),     rjustify=true, width=6,  pen=fgc}
                                }})  
  end

 elseif grid == 'D_AY' then
  hW = w-39
  Info = getSkillInfo(unit,0,'Detailed')
  table.insert(insert, {text = {{text=center('Skills',w), width = w, pen=titleColor}}})
  table.insert(insert, {text = {{text=center('In Game',w), width = w, pen=headColor}}})
  table.insert(insert, {text = {
                                {text='',                       width=hW             },
                                {text='Current', rjustify=true, width=9, pen=colColor},
                                {text='Class',   rjustify=true, width=7, pen=colColor},
                                {text='Item',    rjustify=true, width=6, pen=colColor},
                                {text='Base',    rjustify=true, width=6, pen=colColor},
                                {text='Rust',    rjustify=true, width=6, pen=colColor},
                                {text='Exp',     rjustify=true, width=5, pen=colColor}
                               }})
  for skill,tbl in pairs(Info.InGame) do
   if (tbl.Total + tbl.Class + tbl.Item + tbl.Base + tbl.Exp) > 0 then
   table.insert(insert, {text = {
                                 {text=skill,                              width=hW, pen=fgc},
                                 {text=tostring(tbl.Total), rjustify=true, width=9,  pen=fgc},
                                 {text=tostring(tbl.Class), rjustify=true, width=7,  pen=fgc},
                                 {text=tostring(tbl.Item),  rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Base),  rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Rust),  rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Exp),   rjustify=true, width=5,  pen=fgc}
                                }})
   end
  end


  table.insert(insert, {text = {{text=center('Custom',w), width = w, pen=headColor}}})
  table.insert(insert, {text = {
                                {text='',                       width=hW             },
                                {text='Current', rjustify=true, width=9, pen=colColor},
                                {text='Class',   rjustify=true, width=7, pen=colColor},
                                {text='Item',    rjustify=true, width=6, pen=colColor},
                                {text='Base',    rjustify=true, width=6, pen=colColor},
                                {text='Rust',    rjustify=true, width=6, pen=colColor},
                                {text='Exp',     rjustify=true, width=5, pen=colColor}
                               }})
  for skill,tbl in pairs(Info.Custom) do
   table.insert(insert, {text = {
                                 {text=skill,                              width=hW, pen=fgc},
                                 {text=tostring(tbl.Total), rjustify=true, width=9,  pen=fgc},
                                 {text=tostring(tbl.Class), rjustify=true, width=7,  pen=fgc},
                                 {text=tostring(tbl.Item),  rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Base),  rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Rust),  rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Exp),   rjustify=true, width=5,  pen=fgc}
                                }})
  end

 elseif grid == 'D_BX' then
  hW = w - 38
  Info = getStatResistanceInfo(unit,0,'Detailed')
  table.insert(insert, {text = {{text=center('Stats',w), width = w, pen=titleColor}}})
  table.insert(insert, {text = {{text=center('Custom',w), width = w, pen=headColor}}})
  table.insert(insert, {text = {
                                {text='',                        width=hW              },
                                {text='Current',  rjustify=true, width=9,  pen=colColor},
                                {text='Class',    rjustify=true, width=7,  pen=colColor},
                                {text='Item',     rjustify=true, width=6,  pen=colColor},
                                {text='Syndrome', rjustify=true, width=10, pen=colColor},
                                {text='Base',     rjustify=true, width=6,  pen=colColor}
                               }})
  for stat,tbl in pairs(Info.Stats) do
   table.insert(insert, {text = {
                                 {text=stat,                                  width=hW, pen=fgc},
                                 {text=tostring(tbl.Total),    rjustify=true, width=9,  pen=fgc},
                                 {text=tostring(tbl.Class),    rjustify=true, width=7,  pen=fgc},
                                 {text=tostring(tbl.Item),     rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Syndrome), rjustify=true, width=10, pen=fgc},
                                 {text=tostring(tbl.Base),     rjustify=true, width=6,  pen=fgc}
                                }})
  end

 elseif grid == 'D_BY' then
  hW = w - 38
  Info = getStatResistanceInfo(unit,0,'Detailed')
  table.insert(insert, {text = {{text=center('Resistances',w), width = w, pen=titleColor}}})
  table.insert(insert, {text = {{text=center('Custom',w), width = w, pen=headColor}}})
  table.insert(insert, {text = {
                                {text='',                        width=hW              },
                                {text='Current',  rjustify=true, width=9,  pen=colColor},
                                {text='Class',    rjustify=true, width=7,  pen=colColor},
                                {text='Item',     rjustify=true, width=6,  pen=colColor},
                                {text='Syndrome', rjustify=true, width=10, pen=colColor},
                                {text='Base',     rjustify=true, width=6,  pen=colColor}
                               }})
  for resistance,tbl in pairs(Info.Resistances) do
   table.insert(insert, {text = {
                                 {text=resistance,                            width=hW, pen=fgc},
                                 {text=tostring(tbl.Total),    rjustify=true, width=9,  pen=fgc},
                                 {text=tostring(tbl.Class),    rjustify=true, width=7,  pen=fgc},
                                 {text=tostring(tbl.Item),     rjustify=true, width=6,  pen=fgc},
                                 {text=tostring(tbl.Syndrome), rjustify=true, width=10, pen=fgc},
                                 {text=tostring(tbl.Base),     rjustify=true, width=6,  pen=fgc}
                                }})
  end

 end

 return insert
end
function getHealthOutput(grid,unit,w)
 --[[ LAYOUT
   |      X       |      Y      |
 --|--------------|-------------|
 A | Health Stats | Syndromes   |
 --------------------------------
 ]]
 local insert = {}
 local titleColor = COLOR_LIGHTCYAN
 local headColor = COLOR_LIGHTMAGENTA
 local fgc = COLOR_WHITE
 local hW = w - 40
 Info = getHealthInfo(unit,w,'Detailed')

 if     grid == 'H_AX' then
  table.insert(insert, {text = {{text = center('Health',w), width = w, pen=titleColor}}})
 elseif grid == 'H_AY' then
  table.insert(insert, {text = {{text = center('Syndromes',w), width = w, pen=titleColor}}})
  table.insert(insert, {text = {
                                {text=center('Active Syndromes',hW), pen=headColor},
                                {text=center('Start',7),             pen=headColor},
                                {text=center('Peaks',7),             pen=headColor},
                                {text=center('Severity',10),         pen=headColor},
                                {text=center('Ends',6),              pen=headColor},
                                {text=center('Duration',10),         pen=headColor}
                               }})
  for i,x in pairs(Info.Syndromes) do
   table.insert(insert, {text = {{text = x[1], width = hW, pen=COLOR_LIGHTGREEN}}})
   for j,y in pairs(Info.SyndromeDetails[i]) do
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
    if y['end'] == -1 then
     ending = 'Permanent'
     duration = x[3]
    else
     ending = y['end']
     duration = x[3]
    end
    table.insert(insert, {text = {
                                  {text = effect,                  width = hW, pen=fgc},
                                  {text = y.start,  rjustify=true, width = 7,  pen=fgc},
                                  {text = y.peak,   rjustify=true, width = 7,  pen=fgc},
                                  {text = severity, rjustify=true, width = 10, pen=fgc},
                                  {text = ending,   rjustify=true, width = 6,  pen=fgc},
                                  {text = duration, rjustify=true, width = 10, pen=fgc}
                                 }})
   end
  end
 end

 return insert
end
function getThoughtsOutput(grid,unit,w)
 --[[ LAYOUT
   |    X     |      Y      |   Z    |
 --|----------|-------------|--------|
 A | Thoughts | Preferences | Traits |
 -------------------------------------
 ]]
 local insert = {}
 local titleColor = COLOR_LIGHTCYAN
 Info = getThoughtInfo(unit,w,'Detailed')
 
 if     grid == 'T_AX' then
  table.insert(insert,{text = {{text = center('Thoughts',w), width = w, pen=titleColor}}})
 elseif grid == 'T_AY' then
  table.insert(insert,{text = {{text = center('Preferences',w), width = w, pen=titleColor}}})
 elseif grid == 'T_AZ' then
  table.insert(insert,{text = {{text = center('Traits',w), width = w, pen=titleColor}}})
 end
 
 return insert
end
function getClassesOutput(grid,unit,w,choice)
 local insert = {}
 local titleColor = COLOR_LIGHTCYAN
 local headColor = COLOR_LIGHTMAGENTA
 local subColor = COLOR_YELLOW
 local fgc

 if grid == 'C_AX' then
  table.insert(insert,{text = {{text=center('Classes',w), width=w, pen=titleColor}}})
  table.insert(insert,{text = {
                               {text='Class',      width=21,                pen=headColor},
                               {text='Level',      width=7,  rjustify=true, pen=headColor},
                               {text='Experience', width=12, rjustify=true, pen=headColor},
                              }})
 elseif grid == 'C_BX' then
  Info = getClassInfo(unit,w,choice)
  if not Info then return insert end
  for token,tbl in pairs(Info.Classes) do
   name = persistTable.GlobalTable.roses.ClassTable[token].Name
   if tonumber(tbl.Level) > 0 or tonumber(tbl.Exp) > 0 then
    fgc = COLOR_LIGHTGREEN
   else
    fgc = COLOR_LIGHTRED
   end
   table.insert(insert, {text = {
                                 {text=name,                     width=21, pen=fgc},
                                 {text=tbl.Level, rjustify=true, width=7,  pen=fgc},
                                 {text=tbl.Exp,   rjustify=true, width=12, pen=fgc},
                                }})
  end
 elseif grid == 'C_ABY' then
  local token = choice.text[1].text
  Info = getClassInfo(unit,w,token)
  if not Info then return insert end
  table.insert(insert, {text = {{text=center(Info.Name,w), width=w, pen=titleColor}}})

  -- REQUIREMENTS
  table.insert(insert, {text = {{text='Requirements', width=w, pen=headColor }}})
  ---- CLASSES
  table.insert(insert, {text = {{text='Classes:', width=w, pen=subColor  }}})
  for i,x in pairs(Info.RequiredClass) do
   if x.Check then
    fgc = COLOR_LIGHTGREEN
   else
    fgc = COLOR_LIGHTRED
   end
   table.insert(insert, {text = {{text='Level '..x.Level..' '..x.Name, width=w, pen=fgc}}})
  end
  ---- ATTRIBUTES
  table.insert(insert, {text = {{text='Attributes:', width=w, pen=subColor}}})
  for i,x in pairs(Info.RequiredAttribute) do
   if x.Check then 
    fgc = COLOR_LIGHTGREEN
   else
    fgc = COLOR_LIGHTRED
   end
   table.insert(insert, {text = {{text=x.Level..' '..x.Name, width=w, pen=fgc}}})
  end
  ---- SKILLS
  table.insert(insert, {text = {{text='Skills:', width=w, pen=subColor}}})
  for i,x in pairs(Info.RequiredSkill) do
   if x.Check then 
    fgc = COLOR_LIGHTGREEN
   else 
    fgc = COLOR_LIGHTRED
   end
   table.insert(insert, {text = {{text='Level '..x.Level..' '..x.Name, width=w, pen=fgc}}})
  end

  -- CLASS BONUSES
  table.insert(insert, {text = {{text='Class Bonuses', width=w, pen=headColor }}})
  for i,x in pairs(Info.ClassBonus) do
   if x.Level > 0 then
    fgc = COLOR_LIGHTGREEN
   else
    fgc = COLOR_LIGHTRED
   end
   table.insert(insert, {text = {{text=x.Type..': '..x.Level..' '..x.Name, width=w, pen=fgc}}})
  end

  -- LEVELING BONUSES
  table.insert(insert, {text = {{text='Leveling Bonuses', width=w, pen=headColor }}})
  for i,x in pairs(Info.LevelBonus) do
   if x.Level > 0 then
    fgc = COLOR_LIGHTGREEN
   else 
    fgc = COLOR_LIGHTRED
   end
   table.insert(insert, {text = {{text=x.Type..': '..x.Level..' '..x.Name, width=w, pen=fgc}}})
  end

  -- SPELLS AND ABILITIES
  table.insert(insert, {text = {{text='Spells and Abilities', width=w, pen=headColor }}})
  for i,x in pairs(Info.Spells) do
   if x.Check > 0 then
    fgc = COLOR_WHITE
   else 
    fgc = COLOR_GREY
   end
   table.insert(insert, {text = {{text=x.Name, width=w, pen=fgc}}})
  end

 end

 return insert
end
function getFeatsOutput(gird,unit,w)
end
function getSpellsOutput(grid,unit,w)
end
