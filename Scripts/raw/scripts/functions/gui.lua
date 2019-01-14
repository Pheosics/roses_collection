local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'
local strings = dfhack.script_environment('functions/text')
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
function getPronoun(unit)
 local str = 'It'
 if unit.sex == 0 then
  str = 'She'
 elseif unit.sex == 1 then
  str = 'He'
 end 
 return str
end
function get_hf_name (id)
  local hf = df.historical_figure.find (id)

  if hf ~= nil then
    if hf.name.has_name then
      return dfhack.TranslateName (hf.name, true) .. "/" .. dfhack.TranslateName (hf.name, false)
    else
      return df.global.world.raws.creatures.all [hf.race].name [0]
    end
  
  else  
    return "<Unknown>"
  end
end

--= Widget Functions
function insertWidgetInput(input,method,list,options, view_id)
 if not list then return input end
 options = options or {}
 local bgc        = options.bgc or COLOR_YELLOW
 local fgc        = options.fgc or COLOR_LIGHTGREEN
 local trueColor  = options.tgc or COLOR_LIGHTGREEN
 local falseColor = options.fac or COLOR_LIGHTRED
 local pen        = options.pen or COLOR_WHITE
 local nohead     = options.nohead or false
 local hastitle   = options.hastitle or false
 local colcolor   = options.column_color or COLOR_WHITE
 local colwidth   = options.column_width or 6
 local width      = options.width or 40
 local rjustify   = options.rjustify or false
 local viewScreen = view_id or ''
 local listHead   = options.list_head or ''
 local token      = options.token
 local order      = options.order
 local abbrvs = {Syndrome='Syn', Item='Items', Strength='Str', Severity='Sev'}

 if method == 'center' then
  table.insert(input, {text = {{text=center(list,width), width=width, pen=pen}}})

 elseif method == 'text' then
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

 elseif method == 'header' then
  if not list.second then
   if order then
    for i = 1, #order do
	 h = order[i]
	 s = list[h]
     table.insert(input, {text = { 
                                  {text=h,                width=#h,       pen=pen},
                                  {text=s, rjustify=true, width=width-#h, pen=pen}
                                 }})
    end
   else
    for h,s in pairs(list) do
     table.insert(input, {text = { 
                                  {text=h,                width=#h,       pen=pen},
                                  {text=s, rjustify=true, width=width-#h, pen=pen}
                                 }})
    end
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
   table.insert(temp_text, {text=listHead, width=hW, pen=colColor})
   for i = 1, #order do
    header = abbrvs[order[i]] or order[i]
    table.insert(temp_text, {text=center(header,colwidth), width=colwidth, pen=colColor})
   end
   table.insert(input, {text=temp_text})
  end
  for k,tbl in pairs(list) do
   temp_text = {}
   if type(k) == 'number' then
    key = tbl.Type
   else
    key = k
   end
   if hastitle then
    title = tbl.Title
   else
    title = key:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
   end
   if token then key = token..':'..key end
   if bgc == COLOR_BLACK then
    table.insert(temp_text, {text=title, width=hW, token=key, viewScreen=viewScreen})   
   else
    table.insert(temp_text, {text=title, width=hW, pen=bgc, token=key, viewScreen=viewScreen})
   end
   for i = 1, #order do
    table.insert(temp_text, {text=center(tostring(tbl[order[i]]),colwidth), width=colwidth, pen=fgc})
   end
   table.insert(input, {text=temp_text})
  end
 end

 return input
end

--=                      Journal Functions
usages[#usages+1] = [===[

]===]

--= Information Gathering Functions
function getJournalInfo(extras)
 local info = {}
 local vd = extras.ViewDetails
 
 info.Buildings = getBuildingInfo(vd['buildingView'],'List')
 
 info.Creatures = getCreatureInfo(vd['creatureView'],'List')
 
 info.Entities     = {}
 info.Entities.All = getEntityInfo(extras.CivSystem, 'All')
 
 info.Items = getItemInfo(vd['itemView'], 'List')
 
 info.Materials     = {}
 info.Materials.All = getMaterialInfo(extras.EnhancedMaterial,'All')
 
 info.Plants = getPlantInfo(vd['plantView'],'List')
 
 info.Reactions     = {}
 info.Reactions.All = getReactionInfo(extras.EnhancedReaction,'All')
 
 return info
end
function getBuildingInfo(extra,Type)
 local Table = df.global.world.raws.buildings
 local badTables = {}
 badTables['next_id'] = true
 local info  = {}
 
 if Type == 'List' then
  local sort  = extra.sortFlags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for bldgType,bldgTable in pairs(Table) do
   if not badTables[bldgType] then
    for j,bldg in pairs(bldgTable) do
     for _,flag in pairs(sort) do
      if flag == 'ALL' then  -- Right now there are no filters for buildings
       info[flag][bldgType] = info[flag][bldgType] or {}
       info[flag][bldgType][bldg.code] = bldg.id
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
  local sort  = extra.sortFlags --Sort by creature level flags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for i,creature in pairs(Table) do
   for _,flag in pairs(sort) do
    if flag == 'ALL' or creature.flags[flag] then  
     info[flag][creature.creature_id] = {}
     for j,caste in pairs(creature.caste) do
      info[flag][creature.creature_id][caste.caste_id] = {i,j}
     end
    end
   end
  end
 else
  i = tonumber(split(Type,':')[1])
  j = tonumber(split(Type,':')[2])
  creatureRaw = Table[i]
  casteRaw    = creatureRaw.caste[j]
  
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
  local sort  = extra.sortFlags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for itemType,itemTable in pairs(Table) do
   if not badTables[itemType] then
    for j,item in pairs(itemTable) do
     for _,flag in pairs(sort) do
      if flag == 'ALL' then  -- Right now there are no filters for items
       info[flag][itemType] = info[flag][itemType] or {}
       info[flag][itemType][item.id] = j
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
end
function getMaterialInfo(extra,Type)
end
function getReactionInfo(extra,Type)
end
function getPlantInfo(extra,Type)
 local Table = df.global.world.raws.plants
 local badTables = {}
 badTables['bushes_idx'] = true
 badTables['trees_idx'] = true
 badTables['grasses_idx'] = true
 local info  = {}
 
 if Type == 'List' then
  local sort  = extra.sortFlags
  for _,flag in pairs(sort) do
   info[flag] = {}
  end
  for plantType,plantTable in pairs(Table) do
   if not badTables[plantType] then
    for j,plant in pairs(plantTable) do
     for _,flag in pairs(sort) do
      if flag == 'ALL' or plant.flags[flag] then  
       info[flag][plantType] = info[flag][plantType] or {}
       info[flag][plantType][plant.id] = j
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
function getJournalOutput(Info,what,w,check,view_id)
 local insert = {}
 if     (what == 'MainList')         then
 elseif (what == 'CreatureList')     then
  insert = getOutputCreature(Info,what,w,check,view_id)
 elseif (what == 'CasteList')        then
  insert = getOutputCreature(Info,what,w,check,view_id)
 elseif (what == 'CreatureDetails')  then
  insert = getOutputCreature(Info,what,w,check,view_id)
 elseif (what == 'BuildingTypeList') then
  insert = getOutputBuilding(Info,what,w,check,view_id) 
 elseif (what == 'BuildingList')     then
  insert = getOutputBuilding(Info,what,w,check,view_id)
 elseif (what == 'BuildingDetails')  then
  insert = getOutputBuilding(Info,what,w,check,view_id)
 elseif (what == 'MaterialTypeList') then
 elseif (what == 'MaterialList')     then
 elseif (what == 'MaterialDetails')  then
 elseif (what == 'ReactionTypeList') then
 elseif (what == 'ReactionList')     then
 elseif (what == 'ReactionDetails')  then
 elseif (what == 'ItemTypeList')     then
  insert = getOutputItem(Info,what,w,check,view_id)
 elseif (what == 'ItemList')         then
  insert = getOutputItem(Info,what,w,check,view_id)
 elseif (what == 'ItemDetails')      then
  insert = getOutputItem(Info,what,w,check,view_id)
 elseif (what == 'EntityTypeList')   then
 elseif (what == 'EntityList')       then
 elseif (what == 'EntityDetails')    then
 elseif (what == 'PlantTypeList')    then
  insert = getOutputPlant(Info,what,w,check,view_id)
 elseif (what == 'PlantList')        then
  insert = getOutputPlant(Info,what,w,check,view_id)
 elseif (what == 'PlantDetails')     then
  insert = getOutputPlant(Info,what,w,check,view_id)
 else
  print('Unrecognized output request '..what)
 end
 return insert
end
function getOutputCreature(Info,what,w,check,view_id)
 local insert = {}
 if (what == 'CreatureList') then
  local info = Info.Creatures[check]
  if not info then return insert end
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK}
  insert = insertWidgetInput(insert, 'table', info, options, view_id)

 elseif (what == 'CasteList') then
  local info = Info.Creatures.ALL
  if not info then return insert end
  local token = check.text[1].token
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK, token=token}
  insert = insertWidgetInput(insert, 'table', info[token], options, view_id) 
  
 elseif (what == 'CreatureDetails') then
  local token = check.text[1].token
  x,y = table.unpack(split(token,':'))
  ids = Info.Creatures.ALL[x][y]
  id_str = tostring(ids[1])..':'..tostring(ids[2])
  info = getCreatureInfo(Info,id_str)
  if not info then return insert end
  -- Put detailed output here
 end

 return insert
end
function getOutputBuilding(Info,what,w,check,view_id)
 local insert = {}
 if     (what == 'BuildingTypeList') then
  local info = Info.Buildings[check]
  if not info then return insert end
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK, token=check}
  insert = insertWidgetInput(insert, 'table', info, options, view_id)
  
 elseif (what == 'BuildingList') then
  local str   = check.text[1].token
  local sort  = split(str,':')[1]
  local token = split(str,':')[2]
  local info = Info.Buildings[sort]
  if not info then return insert end
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK}
  insert = insertWidgetInput(insert, 'table', info[token], options, view_id)

 elseif (what == 'BuildingDetails') then
  local token = check.text[1].token
  local info = getBuildingInfo(Info,token)
  if not info then return insert end
  -- Put detailed output here
 end

 return insert
end
function getOutputItem(Info,what,w,check,view_id)
 local insert = {}
 if     (what == 'ItemTypeList') then
  local info = Info.Items[check]
  if not info then return insert end
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK, token=check}
  insert = insertWidgetInput(insert, 'table', info, options, view_id)
  
 elseif (what == 'ItemList') then
  local str   = check.text[1].token
  local sort  = split(str,':')[1]
  local token = split(str,':')[2]
  local info = Info.Items[sort]
  if not info then return insert end
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK}
  insert = insertWidgetInput(insert, 'table', info[token], options, view_id)

 elseif (what == 'ItemDetails') then
  local token = check.text[1].token
  local id_str = tostring(Info.Items['ALL']['all'][token])
  local info = getItemInfo(Info,id_str)
  if not info then return insert end
  -- Put detailed output here
 end

 return insert
end
function getOutputPlant(Info,what,w,check,view_id)
 local insert = {}
 if     (what == 'PlantTypeList') then
  local info = Info.Plants[check]
  if not info then return insert end
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK, token=check}
  insert = insertWidgetInput(insert, 'table', info, options, view_id)

 elseif (what == 'PlantList') then
  local str   = check.text[1].token
  local sort  = split(str,':')[1]
  local token = split(str,':')[2]
  local info = Info.Plants[sort]
  if not info then return insert end
  local order = {}
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK}
  insert = insertWidgetInput(insert, 'table', info[token], options, view_id)

 elseif (what == 'PlantDetails') then
  local token = check.text[1].token
  local id_str = tostring(Info.Plants['ALL']['all'][token])
  local info = getPlantInfo(Info,id_str)
  if not info then return insert end
  -- Put detailed output here
 end

 return insert
end
--=                      Detailed Unit Viewer Functions
usages[#usages+1] = [===[

]===]

--= Information Gathering Functions
function getUnitInfo(unit,extras)
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
 
 if extras.ClassSystem then
  info.Classes = {}
  info.Classes.Basic     = getClassInfo(unit,'Basic')
  info.Classes.All       = getClassInfo(unit,'All')
  info.Classes.Learned   = getClassInfo(unit,'Learned')
  info.Classes.Available = getClassInfo(unit,'Available')
  info.Classes.Civ       = getClassInfo(unit,'Civ')
 end
 if extras.FeatSystem then
  info.Feats = {}
  info.Feats.Basic   = getFeatInfo(unit,'Basic')
  info.Feats.All     = getFeatInfo(unit,'All')
  info.Feats.Learned = getFeatInfo(unit,'Learned')
  info.Feats.Class   = getFeatInfo(unit,'Class')
 end 
 if extras.SpellSystem then
  info.Spells = {}
  info.Spells.Basic   = getSpellInfo(unit,'Basic')
  info.Spells.All     = getSpellInfo(unit,'All')
  info.Spells.Learned = getSpellInfo(unit,'Learned')
  info.Spells.Class   = getSpellInfo(unit,'Class')
  info.Spells.Civ     = getSpellInfo(unit,'Civ')
 end

 return info
end
function getBaseInfo(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
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
 info.Age = math.floor(dfhack.units.getAge(unit))
 info.Profession = dfhack.units.getProfessionName(unit)
 
 return info
end
function getRelationshipInfo(unit,Type)
 local info = {}
 local Pronoun = getPronoun(unit)
 local hf = df.historical_figure.find (unit.hist_figure_id)
 local mother = nil
 local father = nil
 local spouse = nil
 local children = {}
 local deities = {}
 local orientation = 'Indeterminate'
 
 if hf ~= nil then         
  for i, histfig_link in ipairs (hf.histfig_links) do
   if histfig_link._type == df.histfig_hf_link_motherst then
    mother = get_hf_name (histfig_link.target_hf)
    if mother == "" then mother = nil end
        
   elseif histfig_link._type == df.histfig_hf_link_fatherst then
    father = get_hf_name (histfig_link.target_hf)
    if father == "" then father = nil end
          
   elseif histfig_link._type == df.histfig_hf_link_spousest then
    spouse = get_hf_name (histfig_link.target_hf)
    if spouse == "" then spouse = nil end
        
   elseif histfig_link._type == df.histfig_hf_link_childst then
    table.insert (children, get_hf_name (histfig_link.target_hf))
    if children [#children] == "" then  --  Presumed dead culled HF
     table.remove (children, #children)
    end
          
   elseif histfig_link._type == df.histfig_hf_link_deityst then
    table.insert (deities, {get_hf_name (histfig_link.target_hf), histfig_link.link_strength})   
   end
  end
 end

 -- Get orientation
 o_flags = unit.status.current_soul.orientation_flags
 if o_flags.indeterminate then
  orientation = 'Indeterminate'
 else
  if (o_flags.romance_male or o_flags.marry_male) and
     (o_flags.romance_female or o_flags.marry_female) then
   orientation = 'Bisexual'
  else
   if (o_flags.romance_male or o_flags.marry_male) then
    if unit.sex == 0 then orientation = 'Heterosexual' end
	if unit.sex == 1 then orientation = 'Homosexual' end
   elseif (o_flags.romance_female or o_flags.marry_female) then
    if unit.sex == 0 then orientation = 'Homosexual' end
	if unit.sex == 1 then orientation = 'Heterosexual' end
   end
  end
 end
 
 if Type == 'Basic' then
  info.Relationship = {} --strings.relationship_string(spouse,children,mother,father)
  info.Relationship.Mother = mother or 'Unknown'
  info.Relationship.Father = father or 'Unknown'
  info.Relationship.Spouse = spouse or 'None'
  info.Relationship.Children = tostring(#children) or '0'
  info.Relationship.Orientation = orientation
  info.Worship      = strings.worship_string(deities)
 elseif Type == 'Detailed' then
  info.Relationship = {}
  info.Worship      = {}
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
 local pronoun = getPronoun(unit)

 local list = strings.appearance_string(unit)

 if Type == 'Basic' then
  info = ''
 else
  info = list
 end
 
 return info
end
function getPersonalityInfo(unit,Type)
 local info = {}
 local pronoun = getPronoun(unit)
 
 if     Type == 'Basic' then
  info.Thoughts    = 'Basic thought information goes here'
  info.Preferences = 'Basic preference information goes here'
  info.Traits      = 'Basic trait information goes here'
 elseif Type == 'Detailed' then
  info.Thoughts    = {}
  for i, emo in pairs(unit.status.current_soul.personality.emotions) do
   n = #info.Thoughts + 1
   info.Thoughts[n] = {}
   info.Thoughts[n].Type = df.emotion_type[emo.type]
   info.Thoughts[n].Thought = df.unit_thought_type[emo.thought]
   info.Thoughts[n].Strength = emo.strength
   info.Thoughts[n].SubThought = emo.subthought
   info.Thoughts[n].Severity = emo.severity
   info.Thoughts[n].Remebered = emo.flags.remembered
   info.Thoughts[n].String = strings.thought_string(emo)
  end
  info.Preferences = {}
  for i, pref in pairs(unit.status.current_soul.preferences) do
   if pref.active then
    n = #info.Preferences+1
    info.Preferences[n] = {}
	ptype = df.unit_preference.T_type[pref.type]
	info.Preferences[n].Type    = ptype
	info.Preferences[n].SubType = '???'
    info.Preferences[n].String  = strings.preference_string(pref)
   end
  end
  info.Traits      = {}
  for trait, n in pairs(unit.status.current_soul.personality.traits) do
   i = #info.Traits + 1
   info.Traits[i] = {}
   info.Traits[i].Type     = trait
   info.Traits[i].Strength = n
   info.Traits[i].String   = strings.trait_string(trait,n)
  end
  info.Values      = {}
  for i, val in pairs(unit.status.current_soul.personality.values) do
   n = #info.Values + 1
   info.Values[n] = {}
   info.Values[n].Type     = df.value_type[val.type]
   info.Values[n].Strength = val.strength
   info.Values[n].String   = strings.value_string(val)
  end   
 end

 return info
end
function getHealthInfo(unit,Type)
 local info = {}
 local pronoun = getPronoun(unit)
 syndromes, syndrome_details = dfhack.script_environment('functions/unit').getSyndrome(unit,'All','detailed')

 local list = strings.appearance_string(unit)

 if Type == 'Basic' then
  info.Injury    = ''
  if not unit.health then info.Injury = pronoun..' has no current injuries' end
  info.Syndromes = ''
  if not unit.health then info.Syndromes = pronoun..' has no current illnesses' end
  
 elseif Type == 'Detailed' then
  syndromes, syndrome_details = dfhack.script_environment('functions/unit').getSyndrome(unit,'All','detailed')
  info.Injury    = list
  info.Syndromes = {}
  for i,x in pairs(syndromes) do
   info.Syndromes[x[1]] = {}
   for j,y in pairs(syndrome_details) do
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
    if y['end'] == -1 then
     ending = 'Permanent'
     duration = x[3]
    else
     ending = y['end']
     duration = x[3]
    end
	info.Syndromes[x[1]][n] = {}
	info.Syndromes[x[1]][n].Type  = effect
	info.Syndromes[x[1]][n].Start = y.start
	info.Syndromes[x[1]][n].Peaks = y.peak
	info.Syndromes[x[1]][n].Sev   = severity
	info.Syndromes[x[1]][n].End   = ending
	info.Syndromes[x[1]][n].Dur   = duration
   end
  end
 end

 return info
end
function getAttributeInfo(unit,Type)
 local info = {}
 local pronoun = getPronoun(unit)
 
 if Type == 'Basic' then
  info.Physical = pronoun..' is '
  for attribute,_ in pairs(unit.body.physical_attrs) do
   tempstr = strings.attribute_string(attribute,unit)
   if tempstr ~= "" then
    info.Physical = info.Physical..tempstr..', '
   end
  end
  if info.Physical == pronoun..' is ' then 
   info.Physical = info.Physical..'unremarkably average physically'
  end
  
  info.Mental   = pronoun..' has '
  for attribute,_ in pairs(unit.status.current_soul.mental_attrs) do
   tempstr = strings.attribute_string(attribute,unit)
   if tempstr ~= "" then
    info.Mental = info.Mental..tempstr..', '
   end
  end
  if info.Mental == pronoun..' has ' then 
   info.Mental = info.Mental..'unremarkably average mental attributes'
  end

  info.Custom   = '' -- No custom attribute strings yet
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
function getSkillInfo(unit,Type)
 local info = {}

 if Type == 'Basic' then
  info.Profession = '[X] Profession is '..df.profession[unit.profession]
  info.Misc       = '[X] Is a master at MINING'
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
 local persistTable = require 'persist-table'
 local unitTable  = persistTable.GlobalTable.roses.UnitTable
 local classTable = persistTable.GlobalTable.roses.ClassTable
 local unitClasses
 if unitTable[tostring(unit.id)] then
  unitClasses = unitTable[tostring(unit.id)].Classes
 else
  unitClasses = nil
 end
 
 if Type == 'Basic' then
  info.Current = 'A basic description of the units current class goes here'
  info.Classes = 'A basic description of the units other classes goes here'
 elseif Type == 'All' then
  info.Classes = {}
  for i,x in pairs(classTable._children) do
   info.Classes[x] = {}
   info.Classes[x].Title = classTable[x].Name
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
  for i,x in pairs(classTable._children) do
   if unitClasses and unitClasses[x] then
    info.Classes[x] = {}
    info.Classes[x].Title = classTable[x].Name
    info.Classes[x].Exp   = unitClasses[x].Level
    info.Classes[x].Level = unitClasses[x].Experience
   end
  end
 elseif Type == 'Available' then
  info.Classes = {}
  for i,x in pairs(classTable._children) do
   if dfhack.script_environment('functions/class').checkRequirementsClass(unit,x) then
    info.Classes[x] = {}
    info.Classes[x].Title = classTable[x].Name
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
   if not persistTable.GlobalTable.roses.EntityTable[tostring(unit.civ_id)] then return info end
   civTable = persistTable.GlobalTable.roses.EntityTable[tostring(unit.civ_id)].Civilization
   if not civTable then return info end
   for i,x in pairs(classTable._children) do
    if civTable.Classes[x] then
     info.Classes[x].Title = classTable[x].Name
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
     if unitT.Attributes[x].Base >= tonumber(class.RequiredAttribute[x]) then
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
     if unitT.Skills[x].Base >= tonumber(class.RequiredSkill[x]) then
      info.RequiredSkill[x].Check = true
     end
    end
   end
  end
  
  info.ClassBonuses = {}
  info.ClassBonuses.Attribute = {}
  info.ClassBonuses.Skill = {}
  info.ClassBonuses.Stat = {}
  info.ClassBonuses.Resistance = {}
  info.ClassBonuses.Order = {}
  info.ClassBonuses.Order.Attribute = {}
  info.ClassBonuses.Order.Skill = {}
  info.ClassBonuses.Order.Stat = {}
  info.ClassBonuses.Order.Resistance = {}
  for i = 0, 10 do
   r = tostring(i)
   if safe_index(class.Level,r,'Adjustments') then
    info.ClassBonuses.Attribute[r]  = {}
    info.ClassBonuses.Skill[r]      = {}
    info.ClassBonuses.Stat[r]       = {}
    info.ClassBonuses.Resistance[r] = {}
    for i,t in pairs(class.Level[r].Adjustments._children) do
     for j,x in pairs(class.Level[r].Adjustments[t]._children) do
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
--  info.ClassBonuses = {}
--  if class.Level['0'].Adjustments then
--   local n = 1
--   for i,t in pairs(class.Level['0'].Adjustments._children) do
--    for j,x in pairs(class.Level['0'].Adjustments[t]._children) do
--     info.ClassBonuses[n] = {}
--     info.ClassBonuses[n].Text = t..': '..class.Level['0'].Adjustments[t][x]..' '..x
--     info.ClassBonuses[n].Check = true
--     if tonumber(class.Level['0'].Adjustments[t][x]) < 0 then
--      info.ClassBonuses[n].Check = false
--     end
--     n = n + 1
--    end
--   end
--  end
   
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
function getFeatInfo(unit,Type)
 local info = {}
 local persistTable = require 'persist-table'
 local unitTable  = persistTable.GlobalTable.roses.UnitTable
 local featTable = persistTable.GlobalTable.roses.FeatTable
 local classTable = persistTable.GlobalTable.roses.ClassTable
 local unitFeats
 if unitTable[tostring(unit.id)] then
  unitFeats = unitTable[tostring(unit.id)].Feats
 else
  unitFeats = nil
 end

 if Type == 'Basic' then
  info.Current = 'A basic description of the units feats goes here'
 elseif Type == 'All' then
  info.Feats = {}
  for i,x in pairs(featTable._children) do
   info.Feats[x] = {}
   if unitFeats and unitFeats[x] then
    info.Feats[x].Learned = 'Yes'
   else
    info.Feats[x].Learned = 'No'
   end
  end
 elseif Type == 'Learned' then
  info.Feats = {}
  for i,x in pairs(featTable._children) do
   if unitFeats and unitFeats[x] then
    info.Feat[x] = {}
    info.Feats[x].Learned = 'Yes'
   end
  end
 elseif Type == 'Class' then
  info.Feats = {}
  if unitTable[tostring(unit.id)] and unitTable[tostring(unit.id)].Classes.Current ~= 'NONE' then
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
  if feat.RequiredClass then
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
  end

  info.RequiredFeat     = {}
  if feat.RequiredFeat then
   for i,x in pairs(feat.RequiredFeat._children) do
    info.RequiredFeat[x] = {}
    info.RequiredFeat[x].Text  = featTable[x].Name
    info.RequiredFeat[x].Check = false
    if unitT.Feats[x] then
     info.RequiredFeat[x].Check = true
    end
   end
  end

  info.Effects = {}
  if feat.Effect then
   n = 1
   for i,x in pairs(feat.Effect._children) do
    info.Effects[n] = {}
    info.Effects[n].Text  = x
    n = n + 1
   end
  end
 end

 return info
end
function getSpellInfo(unit,Type)
 local info = {}
 local persistTable = require 'persist-table'
 local unitTable  = persistTable.GlobalTable.roses.UnitTable
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 local classTable = persistTable.GlobalTable.roses.ClassTable
 local unitSpells
 if unitTable[tostring(unit.id)] then
  unitSpells = unitTable[tostring(unit.id)].Spells
 else
  unitSpells = nil
 end

 if Type == 'Basic' then
  info.Current = 'A basic description of the units feats goes here'
 elseif Type == 'All' then
  info.Spells = {}
  for i,x in pairs(spellTable._children) do
   info.Spells[x] = {}
   info.Spells[x].Learned = 'No'
   info.Spells[x].Active  = 'No'
   if unitSpells and unitSpells[x] and unitSpells[x] == 'true' then info.Spells[x].Learned = 'Yes' end
   if unitSpells and unitSpells.Active[x] then info.Spells[x].Active = 'Yes' end
  end
 elseif Type == 'Learned' then
  info.Spells = {}
  for i,x in pairs(spellTable._children) do
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
   for i,x in pairs(spellTable._children) do
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
  if unit.civ_id >= 0 and persistTable.GlobalTable.roses.EntityTable[tostring(unit.civ_id)] then
   civTable = persistTable.GlobalTable.roses.EntityTable[tostring(unit.civ_id)].Civilization
   if civTable then
    for i,x in pairs(spellTable._children) do
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
  for _,t in pairs(spell.Classification._children) do
   info.Classification[t] = spell.Classification[t]
  end

  info.SpellDetails = {}
  for _,t in pairs(spell.Details._children) do
   info.SpellDetails[t] = spell.Details[t]
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

--= Output Generating Functions
function getUnitOutput(Info,what,w,check,view_id)
 local insert = {}
 if (what == 'BaseInfo') then
  insert = getOutputBasic(Info,what,w,check,view_id)
 elseif (what == 'Description') then
  insert = getOutputBasic(Info,what,w,check,view_id)
 elseif (what == 'AttributesBasic') then
  insert = getOutputBasic(Info,what,w,check,view_id)
 elseif (what == 'RelationshipsBasic') then
  insert = getOutputBasic(Info,what,w,check,view_id)
 elseif (what == 'WorshipBasic') then
  insert = getOutputBasic(Info,what,w,check,view_id) 
 elseif (what == 'AppearanceBasic') then
  insert = getOutputBasic(Info,what,w,check,view_id)
 elseif (what == 'HealthBasic') then
  insert = getOutputBasic(Info,what,w,check,view_id)
 elseif (what == 'SkillBasic') then
  insert = getOutputBasic(Info,what,w,check,view_id)
 elseif (what == 'AttributesDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'SkillsDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'StatsDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'ResistancesDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'HealthDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'SyndromeDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'ThoughtsDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'PreferencesDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'ValuesDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'TraitsDetailed') then
  insert = getOutputDetailed(Info,what,w,check,view_id)
 elseif (what == 'ClassList') then
  insert = getOutputClassSystem(Info,what,w,check,view_id)
 elseif (what == 'ClassDetails') then
  insert = getOutputClassSystem(Info,what,w,check,view_id)
 elseif (what == 'FeatList') then
  insert = getOutputClassSystem(Info,what,w,check,view_id)
 elseif (what == 'FeatDetails') then
  insert = getOutputClassSystem(Info,what,w,check,view_id)
 elseif (what == 'SpellList') then
  insert = getOutputClassSystem(Info,what,w,check,view_id)
 elseif (what == 'SpellDetails') then 
  insert = getOutputClassSystem(Info,what,w,check,view_id)
 else
  print('Unrecognized output request '..what)
 end
 
 return insert
end
function getOutputBasic(Info,what,w,check,view_id)
 local insert = {}
 if (what == 'BaseInfo') then
  local order = {'Name','Caste','Age','Entity','Membership','Profession'}
  local info = Info.Base
  insert = insertWidgetInput(insert, 'header', info, {width=w, order=order})
 elseif (what == 'Description') then
  local info = Info.Description
  insert = insertWidgetInput(insert, 'center', 'Description', {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info,          {width=w})
 elseif (what == 'AttributesBasic') then
  local info = Info.Attributes.Basic
  insert = insertWidgetInput(insert, 'center', 'Attributes',  {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info.Physical, {width=w})
  insert = insertWidgetInput(insert, 'text',   info.Mental,   {width=w})
 elseif (what == 'RelationshipsBasic') then
  local info = Info.Relationships.Basic
  local order = {'Mother','Father','Spouse','Children','Orientation'}
  insert = insertWidgetInput(insert, 'center', 'Relationships',   {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'header', info.Relationship, {width=w, order=order})
 elseif (what == 'WorshipBasic') then
  local info = Info.Relationships.Basic
  insert = insertWidgetInput(insert, 'center', 'Worship',         {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info.Worship,      {width=w})  
 elseif (what == 'AppearanceBasic') then
  local info = Info.Appearance.Detailed
  local order = {'String'}
  insert = insertWidgetInput(insert, 'center', 'Appearance', {width=w, pen=titleColor})
  options = {width=w, order=order, column_width=25}
  for part,mods in pairs(info) do
   local count = 0
   for _ in pairs(mods) do count = count + 1 end
   if count > 0 then
    options.list_head = part:gsub("(%a)([%w_']*)", tchelper)
    insert = insertWidgetInput(insert, 'table', info[part], options)
   end
  end
 elseif (what == 'HealthBasic') then
  local info = Info.Health.Basic
  insert = insertWidgetInput(insert, 'center', 'Health',       {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info.Injury,    {width=w})
  insert = insertWidgetInput(insert, 'text',   info.Syndromes, {width=w})
 elseif (what == 'SkillBasic') then
  local info = Info.Skills.Basic
  insert = insertWidgetInput(insert, 'center', 'Skills',        {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info.Profession, {width=w})
  insert = insertWidgetInput(insert, 'text',   info.Misc,       {width=w})
 end
 return insert
end
function getOutputDetailed(Info,what,w,check,view_id)
 local insert = {}
 if (what == 'AttributesDetailed') then
  local order = {'Total', 'Class', 'Item', 'Syndrome'}
  local info = Info.Attributes.Detailed
  insert = insertWidgetInput(insert, 'center', 'Attributes',  {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'center', 'Physical',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  info.Physical, {width=w, order=order})
  insert = insertWidgetInput(insert, 'center', 'Mental',      {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  info.Mental,   {width=w, order=order})
  insert = insertWidgetInput(insert, 'center', 'Custom',      {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  info.Custom,   {width=w, order=order})
 elseif (what == 'SkillsDetailed') then
  local order = {'Total', 'Class', 'Item', 'Exp'}
  local info = Info.Skills.Detailed
  insert = insertWidgetInput(insert, 'center', 'Skills',    {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'center', 'In Game',   {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  info.InGame, {width=w, order=order})
  insert = insertWidgetInput(insert, 'center', 'Custom',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  info.Custom, {width=w, order=order})
 elseif (what == 'StatsDetailed') then
  local order = {'Total', 'Class', 'Item', 'Syndrome'}
  local info = Info.StatRes.Detailed
  insert = insertWidgetInput(insert, 'center', 'Stats',    {width=w, pen=titleColor})
  --insert = insertWidgetInput(insert, 'center', 'Custom',   {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  info.Stats, {width=w, order=order})
 elseif (what == 'ResistancesDetailed') then
  local order = {'Total', 'Class', 'Item', 'Syndrome'}
  local info = Info.StatRes.Detailed
  insert = insertWidgetInput(insert, 'center', 'Resistances',    {width=w, pen=titleColor})
  --insert = insertWidgetInput(insert, 'center', 'Custom',         {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'table',  info.Resistances, {width=w, order=order})
 elseif (what == 'HealthDetailed') then
  local info = Info.Health.Detailed
  insert = insertWidgetInput(insert, 'center', 'Health', {width=w, pen=titleColor})
  -- info.Injury  
 elseif (what == 'SyndromeDetailed') then
  local info = Info.Health.Detailed
  local order = {'Start','Peaks','Sev','End','Dur'}
  local hW = w - 25
  insert = insertWidgetInput(insert, 'center', 'Syndromes', {width=w, pen=titleColor})
  table.insert(insert, {text = { 
                                {text=center('Active',hW), pen=headColor},
                                {text=center('Start',5),   pen=headColor},
                                {text=center('Peaks',5),   pen=headColor},
                                {text=center('Sev',5),     pen=headColor},
                                {text=center('End',5),     pen=headColor},
                                {text=center('Dur',5),     pen=headColor}
                               }})
  for syn_name,syn_dets in pairs(info.Syndromes) do
   insert = insertWidgetInput(insert, 'text', syn_name,  {width=hW, pen=subColor})
   insert = insertWidgetInput(insert, 'table', syn_dets, {width=w, order=order, nohead=true, column_width=5})
  end
 elseif (what == 'ThoughtsDetailed') then
  local info = Info.Personality.Detailed
  local order = {'Thought'}
  insert = insertWidgetInput(insert, 'center', 'Thoughts', {width=w, pen=titleColor})
  if check then
   insert = insertWidgetInput(insert, 'table', info.Thoughts, {width=w, order=order, column_width=11})
  else
   for i,x in pairs(info.Thoughts) do
    insert = insertWidgetInput(insert, 'text', x.String, {width=w})
   end
  end
 elseif (what == 'PreferencesDetailed') then
  local info = Info.Personality.Detailed
  local order = {'SubType'}
  insert = insertWidgetInput(insert, 'center', 'Preferences', {width=w, pen=titleColor})
  if check then
   insert = insertWidgetInput(insert, 'table', info.Preferences, {width=w, order=order, column_width=9})
  else
   for i,x in pairs(info.Preferences) do
    insert = insertWidgetInput(insert, 'text', x.String, {width=w})
   end
  end
 elseif (what == 'ValuesDetailed') then
  local info = Info.Personality.Detailed
  local order = {'Strength'} 
  insert = insertWidgetInput(insert, 'center', 'Values', {width=w, pen=titleColor})
  if check then
   insert = insertWidgetInput(insert, 'table', info.Values, {width=w, order=order, column_width=10})
  else
   for i,x in pairs(info.Values) do
    insert = insertWidgetInput(insert, 'text', x.String, {width=w})
   end
  end
 elseif (what == 'TraitsDetailed') then
  local info = Info.Personality.Detailed
  local order = {'Strength'}
  insert = insertWidgetInput(insert, 'center', 'Traits', {width=w, pen=titleColor})
  if check then
   insert = insertWidgetInput(insert, 'table', info.Traits, {width=w, order=order, column_width=10})
  else
   for i,x in pairs(info.Traits) do
    if x.String ~= '' then
     insert = insertWidgetInput(insert, 'text', x.String, {width=w})
	end
   end
  end
 end
 return insert
end
function getOutputClassSystem(Info,what,w,check,view_id)
 local insert = {}
 if (what == 'ClassList') then
  local info = Info.Classes
  local order = {'Level', 'Exp'}
  if not info then return insert end
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK, hastitle=true}
  insert = insertWidgetInput(insert, 'table', info[check].Classes, options, view_id)
 elseif (what == 'ClassDetails') then
  local token = check.text[1].token
  local info = getClassInfo(Info.target,token)
  if not info then return insert end
  insert = insertWidgetInput(insert, 'center', info.Name,        {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info.Description, {width=w, pen=textColor})
  
  -- BASE INFO
  local order = {'Sphere','School','Levels'}
  insert = insertWidgetInput(insert, 'center', 'Basic Information', {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'header', info.BaseInfo, {width=w, pen=subColor, order=order})


  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',         {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'center', 'Classes',              {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredClass,     {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Attributes',           {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredAttribute, {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Skills',               {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredSkill,     {width=w, tgc=c1, fac=c2})

  -- CLASS BONUSES
  insert = insertWidgetInput(insert, 'center', 'Class Bonuses', {width=w, pen=headColor})
  --insert = insertWidgetInput(insert, 'list',   info.ClassBonuses, {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'table', info.ClassBonuses.Attribute, {width=w,order=info.ClassBonuses.Order.Attribute})

  -- LEVELING BONUSES
  insert = insertWidgetInput(insert, 'center', 'Level Bonuses', {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'list',   info.LevelBonus, {width=w, tgc=c1, fac=c2})

  -- SPELLS AND ABILITIES
  insert = insertWidgetInput(insert, 'center', 'Spells',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'list',   info.Spells, {width=w, tgc=COLOR_WHITE, fac=COLOR_GREY})
 elseif (what == 'FeatList') then
  local info = Info.Feats
  local order = {'Learned'}
  if not info then return insert end
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK}
  insert = insertWidgetInput(insert, 'table', info[check].Feats, options, view_id)
 elseif (what == 'FeatDetails') then
  local token = check.text[1].token
  local info = getFeatInfo(Info.target,token)
  if not info then return insert end
  insert = insertWidgetInput(insert, 'center', info.Name,        {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info.Description, {width=w, pen=textColor})

  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',     {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'center', 'Classes:',         {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredClass, {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Feats',            {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredFeat,  {width=w, tgc = c1, fac=c2})

  -- CLASS BONUSES
  insert = insertWidgetInput(insert, 'center', 'Effects',    {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'list',   info.Effects, {width=w, tgc=c1, fac=c2})
 elseif (what == 'SpellList') then
  local info = Info.Spells
  local order = {'Learned', 'Active'}
  if not info then return insert end
  local options = {width=w, order=order, column_width=7, nohead=true, bgc=COLOR_BLACK}
  insert = insertWidgetInput(insert, 'table', info[check].Spells, options, view_id)
 elseif (what == 'SpellDetails') then 
  local token = check.text[1].token
  local info = getSpellInfo(Info.target,token)
  if not info then return insert end
  local c_order = {'Type','Sphere','School','Discipline','SubDiscipline'}
  insert = insertWidgetInput(insert, 'center', info.Name,           {width=w, pen=titleColor})
  insert = insertWidgetInput(insert, 'text',   info.Description,    {width=w, pen=textColor})
  insert = insertWidgetInput(insert, 'header', info.Classification, {width=w, pen=subColor, order=c_order})
  insert = insertWidgetInput(insert, 'text',   info.Effect,         {width=w, pen=textColor})
  insert = insertWidgetInput(insert, 'text',   '         ',         {width=w, pen=textColor})

  -- REQUIREMENTS
  insert = insertWidgetInput(insert, 'center', 'Requirements',         {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'center', 'Classes',              {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredClass,     {width=w, tgc=c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Attributes',           {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredAttribute, {width=w, tgc = c1, fac=c2})
  insert = insertWidgetInput(insert, 'center', 'Spells',               {width=w, pen=subColor})
  insert = insertWidgetInput(insert, 'list',   info.RequiredSpell,     {width=w, tgc = c1, fac=c2})
  insert = insertWidgetInput(insert, 'text',   '         ',         {width=w, pen=textColor})

  -- DETAILS
  insert = insertWidgetInput(insert, 'center', 'Spell Details',   {width=w, pen=headColor})
  insert = insertWidgetInput(insert, 'header', info.SpellDetails, {width=w})
 end
 return insert
end