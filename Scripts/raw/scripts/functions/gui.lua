local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'
local usages = {}
local titleColor = COLOR_LIGHTCYAN
local headColor  = COLOR_LIGHTMAGENTA
local subColor   = COLOR_YELLOW
local textColor  = COLOR_WHITE
local numColor   = COLOR_LIGHTGREEN
local colColor   = COLOR_WHITE
local c1 = COLOR_LIGHTGREEN
local c2 = COLOR_LIGHTRED

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
 if not list then return input end
 options = options or {}
 local bgc        = options.bgc or COLOR_YELLOW
 local fgc        = options.fgc or COLOR_LIGHTGREEN
 local trueColor  = options.tgc or COLOR_LIGHTGREEN
 local falseColor = options.fac or COLOR_LIGHTRED
 local pen        = options.pen or COLOR_WHITE
 local order = options.order
 local nohead = options.nohead or false
 local colcolor = options.column_color or COLOR_WHITE
 local colwidth = options.column_width or 6
 local width = options.width or 40
 local rjustify = options.rjustify or false
 local abbrvs = {Total='Tot', Syndrome='Syn'}

 if method == 'center' then
  table.insert(input, {text = {{text=center(list,width), width=width, pen=pen}}})
 elseif method == 'text' then
  local temp_text = {}
  local n = math.floor(#list/width) + 1
  for i = 1,n do
   temp_text[#temp_text+1] = string.sub(list,1+width*(i-1),width*i)
  end
  for first,second in pairs(temp_text) do
   if first ~= 'length' then
    table.insert(input,{text = {{text=second, pen=pen, width=width, rjustify=rjustify}}})
   end
  end
 elseif method == 'header' then
  if not list.second then
   for h,s in pairs(list) do
    table.insert(input, {text = { 
                                 {text=h,                width=#h,       pen=pen},
                                 {text=s, rjustify=true, width=width-#h, pen=pen}
                                }})
   end
  elseif type(list.second) == 'table' then
   local check = true
   if list.length == 0 then
    return input
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
      table.insert(input, {text = { 
                                   {text=list.header,         width=#list.header,       pen=pen},
                                   {text=fill, rjustify=true, width=width-#list.header, pen=pen}
                                  }})
      check = false
     else
      table.insert(input, {text = { 
                                   {text='',                  width=#list.header,       pen=pen},
                                   {text=fill, rjustify=true, width=width-#list.header, pen=pen}
                                  }})
     end
    end
   end
  else
   if list.second == '' or list.second == '--' then
    return input
   else
    table.insert(input, {text = { 
                                 {text=list.header,                width=#list.header,       pen=pen},
                                 {text=list.second, rjustify=true, width=width-#list.header, pen=pen}
                                }})
   end
  end
 elseif method == 'list' then
  for i,x in pairs(list) do
   if x.Check then
    fgc = trueColor
   else 
    fgc = falseColor
   end
   table.insert(input, {text = {{text=x.Text, width=width, pen=fgc}}})
  end
 elseif method == 'table' then
  if not order then return input end
  hW = width - #order*colwidth
  if not nohead then
   temp_text = {}
   table.insert(temp_text, {text='', width=hW})
   for i = 1, #order do
    header = abbrvs[order[i]] or order[i]
    table.insert(temp_text, {text=center(header,colwidth), width=colwidth, pen=colColor})
   end
   table.insert(input, {text=temp_text})
  end
  for key,tbl in pairs(list) do
   temp_text = {}
   title = key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   table.insert(temp_text, {text=title, width=hW, pen=bgc, token=key})
   for i = 1, #order do
    table.insert(temp_text, {text=center(tostring(tbl[order[i]]),colwidth), width=colwidth, pen=fgc})
   end
   table.insert(input, {text=temp_text})
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
  info.Membership = 'A basic description of the units memberships goes here'
  info.Worship    = 'A basic description of the units main workship goes here'
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
  info.Current = 'A basic description of the units current class goes here'
  info.Classes = 'A basic description of the units other classes goes here'
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

  info.Name        = class.Name
  info.Description = class.Description
  info.Levels      = class.Levels

  info.RequiredClass     = {}
  if class.RequiredClass then
   for i,x in pairs(class.RequiredClass._children) do
    info.RequiredClass[x] = {}
    info.RequiredClass[x].Text  = 'Level '..class.RequiredClass[x]..' '..classTable[x].Name
    info.RequiredClass[x].Check = false
    if unitT.Classes[x] then
     if unitT.Classes[x].Level >= info.RequiredClass[x].Level then
      info.RequiredClass[x].Check = true
     end
    end
   end
  end
  
  info.RequiredAttribute = {}
  if class.RequiredAttribute then
   for i,x in pairs(class.RequiredAttribute._children) do
    info.RequiredAttribute[x] = {}
    info.RequiredAttribute[x].Text  = class.RequiredAttribute[x]..' '..x
    info.RequiredAttribute[x].Check = false
    if unitT and unitT.Attributes[x] then
     if unitT.Attributes[x].Base >= info.RequiredAttribute[x].Level then
      info.RequiredAttribute[x].Check = true
     end
    end
   end
  end
  
  info.RequiredSkill = {}
  if class.RequiredSkill then
   for i,x in pairs(class.RequiredSkill._children) do
    info.RequiredSkill[x] = {}
    info.RequiredSkill[x].Text  ='Level '..class.RequiredSkill[x]..' '..x
    info.RequiredSkill[x].Check = true
    if unitT and unitT.Skills[x] then
     if unitT.Skills[x].Base >= info.RequiredSkill[x].Level then
      info.RequiredSkill[x].Check = true
     end
    end
   end
  end
  
  info.ClassBonuses = {}
  if class.Level['0'].Adjustments then
   local n = 1
   for i,t in pairs(class.Level['0'].Adjustments._children) do
    for j,x in pairs(class.Level['0'].Adjustments[t]._children) do
     info.ClassBonuses[n] = {}
     info.ClassBonuses[n].Text = t..': '..class.Level['0'].Adjustments[t][x]..' '..x
     info.ClassBonuses[n].Check = true
     if tonumber(class.Level['0'].Adjustments[t][x]) < 0 then
      info.ClassBonuses[n].Check = false
     end
     n = n + 1
    end
   end
  end
  
  info.LevelBonuses = {}
  if class.Level['0'].LevelBonus then
   local n = 1
   for i,t in pairs(class.Level['0'].LevelBonus._children) do
    for j,x in pairs(class.Level['0'].LevelBonus[t]._children) do
     info.LevelBonuses[n] = {}
     info.LevelBonuses[n].Text = t..': '..class.Level['0'].LevelBonus[t][x]..' '..x
     info.LevelBonuses[n].Check = true
     if tonumber(class.Level['0'].LevelBonus[t][x]) < 0 then 
      info.LevelBonuses[n].Check = false
     end
     n = n + 1
    end
   end
  end
  
  info.Spells = {}
  if class.Spells then
   local n = 1
   for i,x in pairs(class.Spells._children) do
    info.Spells[n] = {}
    info.Spells[n].Text  = x
    info.Spells[n].Level = class.Spells[x].RequiredLevel
    n = n + 1
   end
  end
 end

 return info
end
function getFeatInfo(unit,w,Type)
 local info = {}
 local persistTable = require 'persist-table'
 local unitTable  = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then return false end
 local featTable = persistTable.GlobalTable.roses.FeatTable
 local classTable = persistTable.GlobalTable.roses.ClassTable
 unitFeats = unitTable[tostring(unit.id)].Feats

 if Type == 'Basic' then
  info.Current = 'A basic description of the units feats goes here'
 elseif Type == 'All' then
  info.Feats = {}
  for i,x in pairs(featTable._children) do
   info.Feats[x] = {}
   if unitFeats[x] then
    info.Feats[x].Learned = 'Yes'
   else
    info.Feats[x].Learned = 'No'
   end
  end
 elseif Type == 'Learned' then
  info.Feats = {}
  for i,x in pairs(featTable._children) do
   if unitFeat[x] then
    info.Feat[x] = {}
    info.Feats[x].Learned = 'Yes'
   end
  end
 elseif Type == 'Class' then
  info.Feats = {}
  if unitTable[tostring(unit.id)].Classes.Current ~= 'NONE' then
   currentClass = unitTable[tostring(unit.id)].Classes.Current
   for i,x in pairs(featTable._children) do
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
  for i,x in pairs(feat.RequiredClass._children) do
   info.RequiredClass[x] = {}
   info.RequiredClass[x].Text  = 'Level '..feat.RequiredClass[x]..' '..classTable[x].Name
   info.RequiredClass[x].Check = false
   if unitT.Classes[x] then
    if tonumber(unitT.Classes[x].Level) >= tonumber(feat.RequiredClass[x]) then
     info.RequiredClass[x].Check = true
    end
   end
  end

  info.RequiredFeat     = {}
  for i,x in pairs(feat.RequiredFeat._children) do
   info.RequiredFeat[x] = {}
   info.RequiredFeat[x].Text  = featTable[x].Name
   info.RequiredFeat[x].Check = false
   if unitT.Feats[x] then
    info.RequiredFeat[x].Check = true
   end
  end

  info.Effects = {}
  n = 1
  for i,x in pairs(feat.Effect._children) do
   info.Effects[n] = {}
   info.Effects[n].Text  = x
   n = n + 1
  end
 end

 return info
end
function getSpellInfo(unit,w,Type)
 local info = {}
 local persistTable = require 'persist-table'
 local unitTable  = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then return false end
 if not Type then return false end
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 local classTable = persistTable.GlobalTable.roses.ClassTable
 unitSpells = unitTable[tostring(unit.id)].Spells

 if Type == 'Basic' then
  info.Current = 'A basic description of the units feats goes here'
 elseif Type == 'All' then
  info.Spells = {}
  for i,x in pairs(spellTable._children) do
   info.Spells[x] = {}
   info.Spells[x].Learned = 'No'
   info.Spells[x].Active  = 'No'
   if unitSpells[x] and unitSpells[x] == 'true' then info.Spells[x].Learned = 'Yes' end
   if unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
  end
 elseif Type == 'Learned' then
  info.Spells = {}
  for i,x in pairs(featTable._children) do
   if unitSpells[x] and unitSpells[x] == 'true' then
    info.Spells[x] = {}
    info.Spells[x].Learned = 'Yes'
    info.Spells[x].Active  = 'No'
    if unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
   end
  end
 elseif Type == 'Class' then
  info.Spells = {}
  if unitTable[tostring(unit.id)].Classes.Current ~= 'NONE' then
   currentClass = unitTable[tostring(unit.id)].Classes.Current
   for i,x in pairs(spellTable._children) do
    if spellTable[x].RequiredClass and spellTable[x].RequiredClass[currentClass] then
     info.Spells[x] = {}
     info.Spells[x].Learned = 'No'
     info.Spells[x].Active  = 'No'
     if unitSpells[x] and unitSpells[x] == 'true' then info.Spells[x].Learned = 'Yes' end
     if unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
    end
   end
  end
 elseif Type == 'Civ' then
  info.Spells = {}
  if unitTable.Civilization and unit.civ_id >= 0 then
   civTable = persistTable.GlobalTable.roses.EntityTable[tostring(unit.civ_id)].Civilization
   for i,x in pairs(spellTable._children) do
    if civTable.Spells and civTable.Spells[x] then
     info.Spells[x] = {}
     info.Spells[x].Learned = 'No'
     info.Spells[x].Active  = 'No'
     if unitSpells[x] and unitSpells[x] == 'true' then info.Spells[x].Learned = 'Yes' end
     if unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
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
  info.Classification.Level = spell.Classification.Level
  for _,t in pairs(spell.Classification._children) do
   info.Classification[t] = spell.Classification[t]
  end

  info.Details = {}
  for _,t in pairs(spell.Details._children) do
   info.Details[t] = spell.Details[t]
  end

  info.RequiredClass = {}
  if spell.RequiredClass then
   for i,x in pairs(spell.RequiredClass._children) do
    info.RequiredClass[x] = {}
    info.RequiredClass[x].Text  = 'Level '..spell.RequiredClass[x]..' '..classTable[x].Name
    info.RequiredClass[x].Check = false
    if unitT.Classes[x] then
     if unitT.Classes[x].Level >= info.RequiredClass[x].Level then
      info.RequiredClass[x].Check = true
     end
    end
   end
  end

  info.RequiredSpell = {}
  if spell.RequiredSpell then
   for i,x in pairs(spell.RequiredSpell._children) do
    info.RequiredFeat[x] = {}
    info.RequiredFeat[x].Text  = spellTable[x].Name
    info.RequiredFeat[x].Check = false
    if unitT.Spells[x] then
     info.RequiredFeat[x].Check = true
    end
   end
  end
  
  info.RequiredAttribute = {}
  if spell.RequiredAttribute then
   for i,x in pairs(spell.RequiredAttribute._children) do
    info.RequiredAttribute[x] = {}
    info.RequiredAttribute[x].Text  = spell.RequiredAttribute[x]..' '..x
    info.RequiredAttribute[x].Check = false
    if unitT and unitT.Attributes[x] then
     if unitT.Attributes[x].Base >= info.RequiredAttribute[x].Level then
      info.RequiredAttribute[x].Check = true
     end
    end
   end
  end
 end
 
 return info
end
function getDescriptionInfo(unit,w,Type)
 local info = ''

 info = 'The creature description goes here'

 return info
end
function getAppearanceInfo(unit,w,Type)
 local info = ''

 info = 'The units apperance goes here'

 return info
end
function getThoughtInfo(unit,w,Type)
 local info = {}

 if     Type == 'Basic' then
  info.Thoughts    = 'Basic thought information goes here'
  info.Preferences = 'Basic preference information goes here'
  info.Traits      = 'Basic trait information goes here'
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
  info.Injury    = 'A basic description of any unit injuries goes here'
  info.Syndromes = 'A basic description of any sickness goes here'
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
  info.Physical = 'A basic description of the units physical attributes goes here'
  info.Mental   = 'A basic description of the units mental attributes goes here'
 elseif Type == 'Detailed' then
  info.Physical = {}
  info.Mental   = {}
  info.Custom   = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit).Attributes
  for attr, tbl in pairs(unitTable) do
   if df.physical_attribute_type[attr] then
    info.Physical[attr] = tbl
   elseif df.mental_attribute_type[attr] then
    info.Mental[attr] = tbl
   else
    info.Custom[attr] = tbl
   end
  end 
 end

 return info
end
function getSkillInfo(unit,w,Type)
 local info = {}

 if Type == 'Basic' then
  info.Profession = 'A basic description of the units base profession skills goes here'
  info.Misc       = 'A basic description of the units other skills goes here'
 elseif Type == 'Detailed' then
  info.InGame = {}
  info.Custom = {}
  unitTable = dfhack.script_environment('functions/unit').getUnitTable(unit).Skills
  for skill, tbl in pairs(unitTable) do
   if df.job_skill[skill] then
    if dfhack.units.getExperience(unit,df.job_skill[skill],true) > 0 then
     name = df.job_skill.attrs[skill].caption_noun
     info.InGame[name] = tbl
    end
   else
    if tbl.Exp + tbl.Total + tbl.Base > 0 then
     name = persistTable.GlobalTable.roses.BaseTable.CustomSkills[skill]
     info.Custom[name] = tbl
    end
   end
  end
 end
 
 return info
end
function getStatResistanceInfo(unit,w,Type)
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

 if     (grid == 'AX') then -- Base Information
  Info = getBaseInfo(unit)
  insert = insertWidgetInput(insert, 'header', Info, {width=w})
 elseif (grid == 'AY') then -- Description
  Info = getDescriptionInfo(unit,w,'Basic')
  insert = insertWidgetInput(insert, 'center', 'Description', {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info,          {width=w})

 elseif (grid == 'AZ') then -- Attribute Information
  Info = getAttributeInfo(unit,w,'Basic')
  insert = insertWidgetInput(insert, 'center', 'Attributes',  {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Physical, {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Mental,   {width=w})

 elseif (grid == 'BX') then -- Membership/Worship Information
  Info = getMembershipInfo(unit,w,'Basic')
  insert = insertWidgetInput(insert, 'center', 'Membership and Worship', {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Membership,          {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Worship,             {width=w})

 elseif (grid == 'BY') then -- Appearance
  Info = getAppearanceInfo(unit,w,'Basic')
  insert = insertWidgetInput(insert, 'center', 'Appearance', {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info,         {width=w})

 elseif (grid == 'BZ') then -- Skills
  Info = getSkillInfo(unit,w,'Basic')
  insert = insertWidgetInput(insert, 'center', 'Skills',        {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Profession, {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Misc,       {width=w})
 
 elseif (grid == 'CX') then -- Class Information
  if check then
   Info = getClassInfo(unit,w,'Basic')
   if Info then
    insert = insertWidgetInput(insert, 'center', 'Class Information', {width=w, pen=titleColor})
    insert = insertWidgetInput(insert, 'text',   Info.Current,        {width=w})
    insert = insertWidgetInput(insert, 'text',   Info.Classes,        {width=w})
   end
  end

 elseif (grid == 'CY') then -- Health Information
  Info = getHealthInfo(unit,w,'Basic')
  insert = insertWidgetInput(insert, 'center', 'Health',       {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Injury,    {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Syndromes, {width=w})

 elseif (grid == 'CZ') then -- Stats and Resistances
  Info = getStatResistanceInfo(unit,w,'Basic')
  insert = insertWidgetInput(insert, 'center', 'Stats and Resistances', {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Stats,              {width=w})
  insert = insertWidgetInput(insert, 'text',   Info.Resistances,        {width=w})

 end

 return insert
end
function getDetailsOutput(grid,unit,w)
 --[[ LAYOUT
   |      X       |      Y      |      Z      |
 --|--------------|-------------|-------------|
 A |              |             | Resistances |
 --| Attributes   | Skills      |-------------|
 B |              |             | Stats       |
 ----------------------------------------------
 ]]
 local insert = {}
 local hW = w - 24
 local orderA = {'Total', 'Class', 'Item', 'Syndrome'}
 local orderB = {'Total', 'Class', 'Item', 'Exp'}

 if     grid == 'D_ABX' then
  Info = getAttributeInfo(unit,0,'Detailed')
  insert = insertWidgetInput(insert, 'center', 'Attributes',  {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'center', 'Physical',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  Info.Physical, {width=w, order=orderA})
  insert = insertWidgetInput(insert, 'center', 'Mental',      {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  Info.Mental,   {width=w, order=orderA})
  insert = insertWidgetInput(insert, 'center', 'Custom',      {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  Info.Custom,   {width=w, order=orderA})

 elseif grid == 'D_ABY' then
  Info = getSkillInfo(unit,0,'Detailed')
  insert = insertWidgetInput(insert, 'center', 'Skills',    {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'center', 'In Game',   {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  Info.InGame, {width=w, order=orderB})
  insert = insertWidgetInput(insert, 'center', 'Custom',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  Info.Custom, {width=w, order=orderB})

 elseif grid == 'D_AZ' then
  Info = getStatResistanceInfo(unit,0,'Detailed')
  insert = insertWidgetInput(insert, 'center', 'Stats',     {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'center', 'Custom',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',   Info.Stats, {width=w, order=orderA})

 elseif grid == 'D_BZ' then
  Info = getStatResistanceInfo(unit,0,'Detailed')
  insert = insertWidgetInput(insert, 'center', 'Resistances',    {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'center', 'Custom',         {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  Info.Resistances, {width=w, order=orderA})

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
 local hW = w - 40
 Info = getHealthInfo(unit,w,'Detailed')

 if     grid == 'H_AX' then
  insert = insertWidgetInput(insert, 'center', 'Health', {width=w, pen=titleColor})
 elseif grid == 'H_AY' then
  insert = insertWidgetInput(insert, 'center', 'Syndromes', {width=w, pen=titleColor})
  table.insert(insert, {text = { 
                                {text=center('Active Syndromes',hW), pen=headColor},
                                {text=center('Start',7),             pen=headColor},
                                {text=center('Peaks',7),             pen=headColor},
                                {text=center('Severity',10),         pen=headColor},
                                {text=center('Ends',6),              pen=headColor},
                                {text=center('Duration',10),         pen=headColor}
                               }})
  for i,x in pairs(Info.Syndromes) do
   table.insert(insert, {text = {{text = x[1], width = hW, pen=subColor}}})
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
                                  {text = effect,                  width = hW, pen=numColor},
                                  {text = y.start,  rjustify=true, width = 7,  pen=numColor},
                                  {text = y.peak,   rjustify=true, width = 7,  pen=numColor},
                                  {text = severity, rjustify=true, width = 10, pen=numColor},
                                  {text = ending,   rjustify=true, width = 6,  pen=numColor},
                                  {text = duration, rjustify=true, width = 10, pen=numColor}
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
 Info = getThoughtInfo(unit,w,'Detailed')
 
 if     grid == 'T_AX' then
  insert = insertWidgetInput(insert, 'center', 'Thoughts', {width=w, pen=titleColor})
 elseif grid == 'T_AY' then
  insert = insertWidgetInput(insert, 'center', 'Preferences', {width=w, pen=titleColor})
 elseif grid == 'T_AZ' then
  insert = insertWidgetInput(insert, 'center', 'Traits', {width=w, pen=titleColor})
 end
 
 return insert
end
function getClassesOutput(grid,unit,w,choice)
 --[[ LAYOUT
   |      X       |      Y      |
 --|--------------|-------------|
 A | Header       |             |
 --|--------------| Details     |
 B | Class List   |             |
 --------------------------------
 ]]
 local insert = {}
 local orderA = {'Level','Exp'}

 if grid == 'C_AX' then
  insert = insertWidgetInput(insert, 'center', 'Classes', {width=w, pen=titleColor})

 elseif grid == 'C_BX' then
  Info = getClassInfo(unit,w,choice)
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'table',  Info.Classes, {width=w, order=orderA, column_width=7, nohead=true})
  
 elseif grid == 'C_ABY' then
  local token = choice.text[1].token
  Info = getClassInfo(unit,w,token)
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'center', Info.Name,        {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Description, {width=w, pen=textColor})

  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',         {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'center', 'Classes',              {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredClass,     {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Attributes:',          {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredAttribute, {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Skills:',              {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredSkill,     {width=w, tgc=c1, fac=c2})

  -- CLASS BONUSES
  insert = insertWidgetInput(insert, 'center', 'Class Bonuses', {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'list',   Info.ClassBonus, {width=w, tgc=c1, fac=c2})

  -- LEVELING BONUSES
  insert = insertWidgetInput(insert, 'center', 'Level Bonuses', {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'list',   Info.LevelBonus, {width=w, tgc=c1, fac=c2})

  -- SPELLS AND ABILITIES
  insert = insertWidgetInput(insert, 'center', 'Spells',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'list',   Info.Spells, {width=w, tgc=COLOR_WHITE, fac=COLOR_GREY})

 end

 return insert
end
function getFeatsOutput(grid,unit,w,choice)
 --[[ LAYOUT
   |      X       |      Y      |
 --|--------------|-------------|
 A | Header       |             |
 --|--------------| Details     |
 B | Feat List    |             |
 --------------------------------
 ]]
 local insert = {}
 local orderA = {'Learned'}

 if grid == 'F_AX' then
  insert = insertWidgetInput(insert, 'center', 'Feats', {width=w, pen=titleColor})

 elseif grid == 'F_BX' then
  Info = getFeatInfo(unit,w,choice)
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'table',  Info.Feats, {width=w, order=orderA, column_width=7, nohead=true})
  
 elseif grid == 'F_ABY' then
  local token = choice.text[1].token
  Info = getFeatInfo(unit,w,token)
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'center', Info.Name,        {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Description, {width=w, pen=textColor})

  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',     {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'center', 'Classes:',         {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredClass, {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Feats',            {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredFeat,  {width=w, tgc = c1, fac=c2})

  -- CLASS BONUSES
  insert = insertWidgetInput(insert, 'center', 'Effects',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'list',   Info.Effects, {width=w, tgc=c1, fac=c2})

 end

 return insert
end
function getSpellsOutput(grid,unit,w,choice)
 --[[ LAYOUT
   |      X       |      Y      |
 --|--------------|-------------|
 A | Header       |             |
 --|--------------| Details     |
 B | Spell List   |             |
 --------------------------------
 ]]
 local insert = {}
 local orderA = {'Learned','Active'}

 if grid == 'S_AX' then
  insert = insertWidgetInput(insert, 'center', 'Spells', {width=w, pen=titleColor})

 elseif grid == 'S_BX' then
  Info = getSpellInfo(unit,w,choice)
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'table',  Info.Spells, {width=w, order=orderA, column_width=7, nohead=true})
  
 elseif grid == 'S_ABY' then
  local token = choice.text[1].token
  Info = getSpellInfo(unit,w,token)
  if not Info then return insert end
  insert = insertWidgetInput(insert, 'center', Info.Name,           {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   Info.Description,    {width=w, pen=textColor})
  insert = insertWidgetInput(insert, 'header', Info.Classification, {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'text',   Info.Effect,         {width=w, pen=textColor})

  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',         {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'center', 'Classes',              {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredClass,     {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Attributes',           {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredAttribute, {width=w, tgc = c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Spells:',              {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   Info.RequiredSpell,     {width=w, tgc = c1, fac=c2})

  -- DETAILS
  insert = insertWidgetInput(insert, 'center', 'Spell Details',   {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'header', Info.SpellDetails, {width=w})

 end

 return insert
end
