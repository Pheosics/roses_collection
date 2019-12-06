-- Unit Based Functions
int16 = 30000000
skillCap = 50
utils = require 'utils'
split = utils.split_string
usages = {}

function tchelper(first, rest)
  return first:upper()..rest:lower()
end

--=                     Unit Table Functions
usages[#usages+1] = [===[

Unit Table Functions 
====================

makeUnitTable(unit)
  Purpose: Create a persistant table to track information of a given unit
  Calls:   NONE
  Inputs:
           unit = The unit struct or unit ID to make the table for
  Returns: NONE

getUnitTable(unit)
  Purpose: Collects all information from the game and the units persistant table into an easily accessible lua table
  Calls:   NONE
  Inputs:
           unit = The unit struct or unit ID to gather information for
  Returns: Table of information about the unit
]===]

function makeUnitTable(unit)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not unit then return end
 
 roses.UnitTable[unit.id] = {}
 unitTable = roses.UnitTable[unit.id]
 
 -- Basic Unit Information (Attributes, Skills, Traits, Resistances, Stats, etc...)
 unitTable.Attributes = {}
 unitTable.Skills = {}
 unitTable.Traits = {}
 unitTable.Resistances = {}
 unitTable.Stats = {}
 
 -- Misc Unit Information
 unitTable.General = {}
 unitTable.General.Side = {}
 unitTable.General.Transform = {}
 unitTable.General.Transform.Race = {}
 unitTable.General.Transform.Caste = {}
 unitTable.General.Transform.StatusEffects = {}
 unitTable.General.Summoned = {}
 unitTable.General.Kills = 0
 unitTable.General.Deaths = 0
 
 -- Tracking Unit Information
 unitTable.SyndromeTrack = {}
 
 -- Needed for the Civilization System
 if unit.civ_id >= 0 and roses.CivilizationTable then
  unitTable.Civilization = ''
  if safe_index(roses.EntityTable,unit.civ_id,'Civilization') then
   unitTable.Civilization = roses.EntityTable[unit.civ_id].Civilization.Name
  end
 end
 
 -- Needed for the Class System
 --if roses.Systems.Class then
  unitTable.Classes = {}
  unitTable.Feats = {}
  unitTable.Spells = {}
  unitTable.Classes.Current = 'NONE'
  unitTable.Feats.Points = 0
  unitTable.Spells.Active = {}
 --end
end

function getUnitTable(unit,detailed)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 if not roses then
  unitTable = nil
  baseTable = nil
 else
  unitPersist = roses.UnitTable
  if not unitPersist[unit.id] then
   unitTable = nil
  else
   unitTable = unitPersist[unit.id]
  end
  baseTable = roses.BaseTable
 end

 local outTable = {}

 outTable.Attributes = {}
 -- Physical Attributes
 for attribute,_ in pairs(unit.body.physical_attrs) do
  outTable.Attributes[attribute] = {}
  x = unit.body.physical_attrs[attribute].value
  if unit.curse.attr_change then
   y = unit.curse.attr_change.phys_att_add[attribute]
   z = unit.curse.attr_change.phys_att_perc[attribute]/100
   outTable.Attributes[attribute].Total    = (x + y)*z
   outTable.Attributes[attribute].Syndrome = outTable.Attributes[attribute].Total - x
  else
   outTable.Attributes[attribute].Total    = x
   outTable.Attributes[attribute].Syndrome = 0
  end
  if unitTable and unitTable.Attributes[attribute] then 
   outTable.Attributes[attribute].Base   = unitTable.Attributes[attribute].Base
   outTable.Attributes[attribute].Item   = unitTable.Attributes[attribute].Item
   outTable.Attributes[attribute].Class  = unitTable.Attributes[attribute].Class
   outTable.Attributes[attribute].Change = unitTable.Attributes[attribute].Change
  else
   outTable.Attributes[attribute].Base   = x
   outTable.Attributes[attribute].Item   = 0
   outTable.Attributes[attribute].Class  = 0
   outTable.Attributes[attribute].Change = 0
  end
 end
 -- Mental Attributes
 for attribute,_ in pairs(unit.status.current_soul.mental_attrs) do
  outTable.Attributes[attribute] = {}
  x = unit.status.current_soul.mental_attrs[attribute].value
  if unit.curse.attr_change then
   y = unit.curse.attr_change.ment_att_add[attribute]
   z = unit.curse.attr_change.ment_att_perc[attribute]/100
   outTable.Attributes[attribute].Total    = (x + y)*z
   outTable.Attributes[attribute].Syndrome = outTable.Attributes[attribute].Total - x
  else
   outTable.Attributes[attribute].Total    = x
   outTable.Attributes[attribute].Syndrome = 0
  end
  if unitTable and unitTable.Attributes[attribute] then 
   outTable.Attributes[attribute].Base   = unitTable.Attributes[attribute].Base
   outTable.Attributes[attribute].Item   = unitTable.Attributes[attribute].Item
   outTable.Attributes[attribute].Class  = unitTable.Attributes[attribute].Class
   outTable.Attributes[attribute].Change = unitTable.Attributes[attribute].Change
  else
   outTable.Attributes[attribute].Base   = x
   outTable.Attributes[attribute].Item   = 0
   outTable.Attributes[attribute].Class  = 0
   outTable.Attributes[attribute].Change = 0
  end
 end
 -- Custom Attributes
 if baseTable then
  for n,attribute in pairs(baseTable.CustomAttributes) do
   outTable.Attributes[attribute] = {}
   if unitTable and unitTable.Attributes[attribute] then
    outTable.Attributes[attribute].Base     = unitTable.Attributes[attribute].Base
    outTable.Attributes[attribute].Item     = unitTable.Attributes[attribute].Item
    outTable.Attributes[attribute].Class    = unitTable.Attributes[attribute].Class
    outTable.Attributes[attribute].Change   = unitTable.Attributes[attribute].Change
    outTable.Attributes[attribute].Syndrome = 0
    outTable.Attributes[attribute].Total    = (unitTable.Attributes[attribute].Base
                                              +unitTable.Attributes[attribute].Item
                                              +unitTable.Attributes[attribute].Class
                                              +unitTable.Attributes[attribute].Change)
   else
    outTable.Attributes[attribute].Base     = 0
    outTable.Attributes[attribute].Item     = 0
    outTable.Attributes[attribute].Class    = 0
    outTable.Attributes[attribute].Change   = 0
    outTable.Attributes[attribute].Syndrome = 0
    outTable.Attributes[attribute].Total    = 0
   end
  end
 end

 outTable.Resistances = {}
 -- Custom Resistances (no in game resistances currently)
 if baseTable then
  for n,resistance in pairs(baseTable.CustomResistances) do
   outTable.Resistances[resistance] = {}
   if unitTable and unitTable.Resistances[resistance] then
    outTable.Resistances[resistance].Base     = unitTable.Resistances[resistance].Base
    outTable.Resistances[resistance].Item     = unitTable.Resistances[resistance].Item
    outTable.Resistances[resistance].Class    = unitTable.Resistances[resistance].Class
    outTable.Resistances[resistance].Change   = unitTable.Resistances[resistance].Change
    outTable.Resistances[resistance].Syndrome = 0
    outTable.Resistances[resistance].Total    = (unitTable.Resistances[resistance].Base
                                                +unitTable.Resistances[resistance].Item
                                                +unitTable.Resistances[resistance].Class
                                                +unitTable.Resistances[resistance].Change)
   else
    outTable.Resistances[resistance].Base     = 0
    outTable.Resistances[resistance].Item     = 0
    outTable.Resistances[resistance].Class    = 0
    outTable.Resistances[resistance].Change   = 0
    outTable.Resistances[resistance].Syndrome = 0
    outTable.Resistances[resistance].Total    = 0
   end
  end
 end

 outTable.Skills = {}
 -- In Game Skills
 for id = 1, 134 do
  skill = df.job_skill[id]
  outTable.Skills[skill] = {}
  outTable.Skills[skill].Exp      = dfhack.units.getExperience(unit,id,false)
  outTable.Skills[skill].Total    = dfhack.units.getNominalSkill(unit,id,false)
  outTable.Skills[skill].Rust     = outTable.Skills[skill].Total - dfhack.units.getNominalSkill(unit,id,true)
  if unitTable and unitTable.Skills[skill] then
   outTable.Skills[skill].Base   = unitTable.Skills[skill].Base
   outTable.Skills[skill].Item   = unitTable.Skills[skill].Item
   outTable.Skills[skill].Class  = unitTable.Skills[skill].Class
   outTable.Skills[skill].Change = unitTable.Skills[skill].Change
  else
   outTable.Skills[skill].Base = outTable.Skills[skill].Total
   outTable.Skills[skill].Item   = 0
   outTable.Skills[skill].Class  = 0
   outTable.Skills[skill].Change = 0
  end
 end
 -- Custom Skills
 if baseTable then
  for skill,_ in pairs(baseTable.CustomSkills) do
   outTable.Skills[skill] = {}
   if unitTable and unitTable.Skills[skill] then
    outTable.Skills[skill].Base     = unitTable.Skills[skill].Base
    outTable.Skills[skill].Item     = unitTable.Skills[skill].Item
    outTable.Skills[skill].Class    = unitTable.Skills[skill].Class
    outTable.Skills[skill].Change   = unitTable.Skills[skill].Change
    outTable.Skills[skill].Total    = (unitTable.Skills[skill].Base
                                      +unitTable.Skills[skill].Item
                                      +unitTable.Skills[skill].Class
                                      +unitTable.Skills[skill].Change)
    outTable.Skills[skill].Exp      = 0
    outTable.Skills[skill].Rust     = 0
   else
    outTable.Skills[skill].Base     = 0
    outTable.Skills[skill].Item     = 0
    outTable.Skills[skill].Class    = 0
    outTable.Skills[skill].Change   = 0
    outTable.Skills[skill].Total    = 0
    outTable.Skills[skill].Exp      = 0
    outTable.Skills[skill].Rust     = 0
   end
  end
 end 


 outTable.Stats = {}
 -- Custom Stats (no in game stats currently)
 if baseTable then
  for n,stat in pairs(baseTable.CustomStats) do
   outTable.Stats[stat] = {}
   if unitTable and unitTable.Stats[stat] then
    outTable.Stats[stat].Base     = unitTable.Stats[stat].Base
    outTable.Stats[stat].Item     = unitTable.Stats[stat].Item
    outTable.Stats[stat].Class    = unitTable.Stats[stat].Class
    outTable.Stats[stat].Change   = unitTable.Stats[stat].Change
    outTable.Stats[stat].Syndrome = 0
    outTable.Stats[stat].Total    = (unitTable.Stats[stat].Base
                                    +unitTable.Stats[stat].Item
                                    +unitTable.Stats[stat].Class
                                    +unitTable.Stats[stat].Change)
   else                                   
    outTable.Stats[stat].Base     = 0
    outTable.Stats[stat].Item     = 0
    outTable.Stats[stat].Class    = 0
    outTable.Stats[stat].Change   = 0
    outTable.Stats[stat].Syndrome = 0
    outTable.Stats[stat].Total    = 0
   end
  end
 end 

 outTable.Traits = {}
 for trait,value in pairs(unit.status.current_soul.personality.traits) do
  outTable.Traits[trait] = {}
  outTable.Traits[trait].Total    = unit.status.current_soul.personality.traits[trait]
  outTable.Traits[trait].Base     = outTable.Traits[trait].Total
  outTable.Traits[trait].Item     = 0
  outTable.Traits[trait].Class    = 0
  outTable.Traits[trait].Change   = 0
  outTable.Traits[trait].Syndrome = 0
 end

 outTable.Classes = {}
 if unitTable then
  for x,_ in pairs(roses.ClassTable) do
   if unitTable.Classes[x] then
    outTable.Classes[x] = {}
    outTable.Classes[x].Level      = unitTable.Classes[x].Level
    outTable.Classes[x].Experience = unitTable.Classes[x].Experience
   end
  end
 end
 
 outTable.Feats = {}
 outTable.Feats.Points = 0
 n = 0
 if unitTable then
  outTable.Feats.Points = unitTable.Feats.Points
  for x,_ in pairs(unitTable.Feats) do
   if x ~= 'Points' then
    n = n + 1
    outTable.Feats[n] = x
   end
  end
 end
 
 outTable.Spells = {}
 outTable.Spells.Active = {}
 outTable.Spells.Learned = {}
 n_learned = 0
 n_active  = 0
 if unitTable then
  for x,y in pairs(unitTable.Spells) do
   if x == 'Active' then
    for spell,_ in pairs(y) do
     n_active = n_active + 1
     outTable.Spells.Active[n_active] = spell
    end
   else
    n_learned = n_learned + 1
    outTable.Spells.Learned[n_learned] = spell
   end
  end
 end
 
 -- Fill out all information from unit if required
 if detailed then
  outTable.Details = {}
  -- Nothing for right now, thinking about adding Thoughts, Preferences, Dreams, etc...
  -- but not sure that it would be any better than just reading directly from the unit.
 end
 
 return outTable
end

--=                     Tracking Functions
usages[#usages+1] = [===[

Tracking Functions                                
==================

trackCore(unit,strname,kind,change,syndrome,dur,alter,cb_id)
  Purpose: Tracks all changes to a units attributes, resistances, skills, stats, and traits 
  Calls:   trackStart, trackEnd, trackTerminate, changeAttribute, changeResistance, changeSkill, changeStat, changeTrait
  Inputs:
           unit     = The unit struct or unit ID of the unit to track
           strname  = Tracked type (Valid Values: Attribute, Resistance, Skill, Stat, Trait)
           kind     = Tracked subtype (e.g. STRENGTH for a strname of Attribute)
           change   = Amount of change
           syndrome = SYN_NAME of a syndrome to associate with the change
           dur      = Length of change in in-game ticks
           alter    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           cb_id    = If dur > 0 then the cb_id is needed to properly track the change
  Returns: NONE
  
trackTransformation(unit,race,caste,dur,alter,syndrome,cb_id)
  Purpose: Tracks changes to a units race and caste
  Calls:   changeRace
  Inputs:
           unit     = The unit struct or unit ID of the unit to track
           race     = Race ID the unit turned into
           caste    = Caste ID the unit turned into
           dur      = Length of change in in-game ticks
           alter    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           syndrome = SYN_NAME of a syndrome to associate with the change
           cb_id    = If dur > 0 then the cb_id is needed to properly track the change
  Returns:
]===]

function trackCore(unit,strname,kind,change,syndrome,dur,alter,cb_id)
 if alter == 'terminated' then return end
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not unit then return end
 
 if not roses.UnitTable[unit.id] then makeUnitTable(unit) end
 roses = dfhack.script_environment('base/roses-table').roses
 
 if strname == 'Attribute' then
  Table = roses.UnitTable[unit.id]['Attributes']
  func = changeAttribute
 elseif strname == 'Resistance' then
  Table = roses.UnitTable[unit.id]['Resistances']
  func = changeResistance
 elseif strname == 'Skill' then
  Table = roses.UnitTable[unit.id]['Skills']
  func = changeSkill
 elseif strname == 'Stat' then
  Table = roses.UnitTable[unit.id]['Stats']
  func = changeStat
 elseif strname == 'Trait' then
  Table = roses.UnitTable[unit.id]['Traits']
  func = changeTrait
 end

 if not Table[kind] then
  Table[kind] = {}
  Table[kind].Base = 0
  Table[kind].Change = 0
  Table[kind].Class = 0
  Table[kind].Item = 0
  Table[kind].StatusEffects = {}
 end

 alter = alter or 'track'
 alter = string.lower(alter)
 if alter == 'track' then -- Track changes to the unit for both durational effects and permanent effects
  trackStart(unit,Table,strname,kind,change,dur,syndrome,cb_id)
 elseif alter == 'end' then -- If the change ends naturally, revert the change
  trackEnd(unit,Table,strname,kind,change,syndrome)
 elseif alter == 'terminate' or alter == 'terminateclass' then
  trackTerminate(unit,Table,strname,func,syndrome,alter)
 elseif alter == 'class' then -- Track changes associated with a class
  Table[kind].Class = change + Table[kind].Class
 elseif alter == 'item' then -- Track changes associated with an item
  Table[kind].Item = change + Table[kind].Item
 end
end

function trackStart(unit,Table,strname,kind,change,dur,syndrome,cb_id)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not unit then return end

 typeTable = Table[kind]
 if dur > 0 then 
  statusTable = typeTable.StatusEffects
  typeTable.Change = typeTable.Change + change
  statusNumber = #statusTable -- If the change has a duration add a status effect to the StatusEffects table
  statusTable[statusNumber+1] = {}
  statusTable[statusNumber+1].End = math.floor(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
  statusTable[statusNumber+1].Change = math.floor(change)
  statusTable[statusNumber+1].Linked = false
  if syndrome then -- If the change has an associated syndrome, link the StatusEffects table and the SyndromeTrack table together
   changeSyndrome(unit,syndrome,'add')
   trackTable = roses.UnitTable[unit.id].SyndromeTrack
   statusTable[statusNumber+1].Linked = true
   if not trackTable[syndrome] then
    trackTable[syndrome] = {}
   end
   if not trackTable[syndrome][strname] then
    trackTable[syndrome][strname] = {}
   end
   if not trackTable[syndrome][strname][kind] then
    trackTable[syndrome][strname][kind] = {}
   end
   trackTable[syndrome][strname][kind].Number = math.floor(statusNumber+1)
   trackTable[syndrome][strname][kind].CallBack = cb_id
  end
 else
  typeTable.Base = typeTable.Base + change -- No need for associating syndromes with permanent changes, if requested can add at a later time.
 end
end

function trackEnd(unit,Table,strname,kind,change,syndrome)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not unit then return end

 typeTable = Table[kind]
 statusTable = typeTable.StatusEffects
 typeTable.Change = math.floor(typeTable.Change - change)
 for i = #statusTable,1,-1 do -- Remove any naturally ended effects
  if statusTable[i] then
   if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
    if statusTable[i].Linked and syndrome then
     trackTable = roses.UnitTable[unit.id].SyndromeTrack
     if trackTable[syndrome][strname][kind].Number == i then trackTable[syndrome][strname] = nil end
    end
    statusTable[i] = nil
    if syndrome then changeSyndrome(unit.id,syndrome,'erase') end
   end
  end
 end
end

function trackTerminate(unit,Table,strname,func,syndrome,alter)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not unit then return end

 -- If the change ends by force, check the syndrome tracker to determine effects                           --*
 if alter == 'terminate' then
  trackTable = roses.UnitTable[unit.id].SyndromeTrack
  name = syndrome or 'NONE'
  if trackTable[name] then
   if trackTable[name][strname] then
    for kindA,_ in pairs(trackTable[name][strname]) do
     typeTable = Table[kindA]
     statusTable = typeTable.StatusEffects
     local statusNumber = trackTable[name][strname][kindA].Number
     local callback = trackTable[name][strname][kindA].CallBack
     typeTable.Change = typeTable.Change - statusTable[statusNumber].Change
     func(unit.id,kindA,-statusTable[statusNumber].Change,0,'terminated',nil)
     dfhack.timeout_active(callback,nil)
     dfhack.script_environment('persist-delay').environmentDelete(callback)
     statusTable[statusNumber] = nil
    end
    trackTable[name][strname] = nil
    changeSyndrome(unit.id,syndrome,'erase')
   end
  end
 elseif alter == 'terminateclass' then
  local trackTable = roses.UnitTable[unit.id].SyndromeTrack
  syndromeNames = checkSyndrome(unit.id,syndrome,'class')
  for _,name in pairs(syndromeNames) do
   if trackTable[name] then
    if trackTable[name][strname] then
     for kindA,_ in pairs(trackTable[name][strname]) do
      typeTable = Table[kindA]
      statusTable = typeTable.StatusEffects
      local statusNumber = trackTable[name][strname][kindA].Number
      local callback = trackTable[name][strname][kindA].CallBack
      typeTable.Change = typeTable.Change - statusTable[statusNumber].Change
      func(unit.id,kindA,-statusTable[statusNumber].Change,0,'terminate',nil)
      dfhack.timeout_active(callback,nil)
      dfhack.script_environment('persist-delay').environmentDelete(callback)
      statusTable[statusNumber] = nil
     end
     trackTable[name][strname] = nil
     changeSyndrome(unit.id,syndrome,'erase')
    end
   end
  end
 end
end

function trackTransformation(unit,race,caste,dur,alter,syndrome,cb_id)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not roses or not unit then return end
 
 if not roses.UnitTable[unit.id] then makeUnitTable(unit) end
 roses = dfhack.script_environment('base/roses-table').roses
 
 tTable = roses.UnitTable[unit.id].General.Transform
 alter = alter or 'track'
 if alter == 'track' then
  if dur > 0 then
   tTable.Race.Current = race
   tTable.Caste.Current = caste
   statusTable = tTable.StatusEffects
   statusNumber = #statusTable
   statusTable[statusNumber+1] = {}
   statusTable[statusNumber+1].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[statusNumber+1].Race = unit.race
   statusTable[statusNumber+1].Caste = unit.caste
   statusTable[statusNumber+1].Linked = false
   if syndrome then
    trackTable = roses.UnitTable[unit.id].SyndromeTrack
    statusTable[statusNumber+1].Linked = true
    if not trackTable[syndrome] then
     trackTable[syndrome] = {}
    end
    if not trackTable[syndrome]['Transform'] then
     trackTable[syndrome]['Transform'] = {}
    end
    trackTable[syndrome]['Transform'].Number = statusNumber+1
    trackTable[syndrome]['Transform'].CallBack = cb_id
   end
  else
   tTable.Race.Base     = race
   tTable.Caste.Base    = caste
   tTable.Race.Current  = race
   tTable.Caste.Current = caste
  end
 elseif alter == 'end' then
  tTable.Race.Current = race
  tTable.Caste.Current = caste
  statusTable = tTable.StatusEffects
  for i = #statusTable,1,-1 do -- Remove any naturally ended effects
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     if statusTable[i].Linked and syndrome then
      trackTable = roses.UnitTable[unit.id].SyndromeTrack
      if trackTable[syndrome]['Transform'].Number == i then trackTable[syndrome]['Transform'] = nil end
     end
     statusTable[i] = nil
     changeSyndrome(unit.id,syndrome,'erase')
    end
   end
  end  
 elseif alter == 'terminate' then
  trackTable = roses.UnitTable[unit.id].SyndromeTrack
  if syndrome then name = syndrome end
  if trackTable[name] then
   if trackTable[name]['Transform'] then
    statusTable = typeTable.StatusEffects
    local statusNumber = trackTable[name]['Transform'].Number
    local callback = trackTable[name]['Transform'].CallBack
    tTable.Race.Current = statusTable[statusNumber].Race
    tTable.Caste.Current = statusTable[statusNumber].Caste
    changeRace(unit.id,statusTable[statusNumber].Race,statusTable[statusNumber].Caste,0,'terminated',syndrome)
    dfhack.timeout_active(callback,nil)
    dfhack.script_environment('persist-delay').environmentDelete(callback)
    statusTable[statusNumber] = nil
   end
   trackTable[name][strname] = nil
   changeSyndrome(unit.id,syndrome,'erase')
  end
 elseif alter == 'terminateClass' then
  trackTable = roses.UnitTable[unit.id].SyndromeTrack
  syndromeNames = checkSyndrome(unit.id,syndrome,'class')
  for _,name in pairs(syndromeNames) do
   if trackTable[name] then
    if trackTable[name]['Transform'] then
     statusTable = typeTable.StatusEffects
     local statusNumber = trackTable[name]['Transform'].Number
     local callback = trackTable[name]['Transform'].CallBack
     tTable.Race.Current = statusTable[statusNumber].Race
     tTable.Caste.Current = statusTable[statusNumber].Caste
     changeRace(unit.id,statusTable[statusNumber].Race,statusTable[statusNumber].Caste,0,'terminated',syndrome)
     dfhack.timeout_active(callback,nil)
     dfhack.script_environment('persist-delay').environmentDelete(callback)
     statusTable[statusNumber] = nil
    end
    trackTable[name][strname] = nil
    changeSyndrome(unit.id,syndrome,'erase')
   end
  end
 end
end

--=                     Number Changing Functions
usages[#usages+1] = [===[

Number Changing Functions 
=========================

changeAttribute(unit,attribute,change,dur,track,syndrome)
  Purpose: Change a units attribute (temporarily or permanently) and track the change
  Calls:   trackCore
  Inputs:
           unit      = Unit struct or unit ID
           attribute = ATTRIBUTE_TOKEN of attribute to change
           change    = Amount to change attribute by
           dur       = Length of change in in-game ticks
           track     = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           syndrome  = SYN_NAME of a syndrome to associate with the change
  Returns: NONE
  
changeCounter(unit,counter,change,dur)
  Purpose: Change the "counter" value of a unit (e.g. webbed, dazed, winded, etc...)
  Calls:   NONE
  Inputs:
           unit    = Unit struct or unit ID
           counter = Counter to change, see function for valid values
           change  = Amount to change the counter by
           dur     = Length of change in in-game ticks (most counters decrease or increase naturally)
  Returns: NONE
  
changeResistance(unit,resistance,change,dur,track,syndrome)
  Purpose: Change a units resistance (temporarily or permanently) and track the change
  Calls:   trackCore
  Inputs:
           unit       = Unit struct or unit ID
           resistance = RESISTANCE_TOKEN of resistance to change
           change     = Amount to change resistance by
           dur        = Length of change in in-game ticks
           track      = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           syndrome   = SYN_NAME of a syndrome to associate with the change
  Returns: NONE
  
changeSkill(unit,skill,change,dur,track,syndrome)
  Purpose: Change a units skill levle (temporarily or permanently) and track the change
  Calls:   trackCore
  Inputs:
           unit     = Unit struct or unit ID
           skill    = SKILL_TOKEN of skill to change
           change   = Amount to change skill level by
           dur      = Length of change in in-game ticks
           track    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           syndrome = SYN_NAME of a syndrome to associate with the change
  Returns: NONE
  
changeStat(unit,stat,change,dur,track,syndrome)
  Purpose: Change a units stat (temporarily or permanently) and track the change
  Calls:   trackCore
  Inputs:
           unit     = Unit struct or unit ID
           stat     = STAT_TOKEN of stat to change
           change   = Amount to change stat by
           dur      = Length of change in in-game ticks
           track    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           syndrome = SYN_NAME of a syndrome to associate with the change
  Returns: NONE
  
changeTrait(unit,trait,change,dur,track,syndrome)
  Purpose: Change a units trait (temporarily or permanently) and track the change
  Calls:   trackCore
  Inputs:
           unit     = Unit struct or unit ID
           trait    = TRAIT_TOKEN of trait to change
           change   = Amount to change trait by
           dur      = Length of change in in-game ticks
           track    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           syndrome = SYN_NAME of a syndrome to associate with the change
  Returns: NONE
]===]

function changeAttribute(unit,attribute,change,dur,track,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 unitTable = getUnitTable(unit)
 if not unitTable.Attributes[attribute] then
  print('functions/unit.changeAttribute: Invalid Attribute Token - '..attribute)
  return
 end 
 current = unitTable.Attributes[attribute].Base
 value = math.floor(current + change)
 if value > int16 then
  value = int16
  change = int16 - current
 elseif value < 0 then
  value = 0
  change = 0 - current
 end
 
 if df.physical_attribute_type[attribute] then -- Physical Attributes
  unit.body.physical_attrs[attribute].value = value
 elseif df.mental_attribute_type[attribute] then -- Mental Attributes
  unit.status.current_soul.mental_attrs[attribute].value = value
 else                                            -- Custom Attributes
  -- Nothing needs to be done for custom attributes right now, all handled by tracking
 end
 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeAttribute',{unit.id,attribute,-change,0,'end',syndrome}) end
 trackCore(unit,'Attribute',attribute,change,syndrome,dur,track,cb_id)
end

function changeCounter(unit,counter,change,dur)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness' or counter == 'suffocation') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger_timer' or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' or counter == 'blood_count' or counter == 'infection_level' then
  if counter == 'blood' then counter = 'blood_count' end
  if counter == 'infection' then counter = 'infection_level' end
  location = unit.body
 elseif counter == 'reset' then
  unit.body.blood_count=unit.body.blood_max
  unit.counters.winded = 0
  unit.counters.stunned = 0
  unit.counters.suffocation = 0
  unit.counters.pain = 0
  unit.counters.nausea = 0
  unit.counters.dizziness = 0
  unit.counters2.paralysis = 0
  unit.counters2.numbness = 0
  unit.counters2.exhaustion = 0
  unit.counters2.fever = 0
  return  
 else
  print('functions/unit.changeCounter: Invalid Counter Token - '..counter)
  return
 end
 current = location[counter]

 value = math.floor(current + change)
 if value > int16 then
  change = int16 - current
  value = int16
 end
 if value < 0 then
  change = current
  value = 0
 end
 location[counter] = value

 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeCounter',{unit.id,counter,-change}) end
end

function changeResistance(unit,resistance,change,dur,track,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 unitTable = getUnitTable(unit)
 if not unitTable.Resistances[resistance] then
  print('functions/unit.changeResistance: Invalid Resistance Token - '..resistance)
  return
 end
 current = unitTable.Resistances[resistance].Base
 value = math.floor(current + change)
 -- Nothing needed because all resistances are currently custom only
 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeResistance',{unit.id,resistance,-change,0,'end',syndrome}) end
 trackCore(unit,'Resistance',resistance,change,syndrome,dur,track,cb_id)
end

function changeSkill(unit,skill,change,dur,track,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 unitTable = getUnitTable(unit)
 if not unitTable.Skills[skill] then
  print('functions/unit.changeSkill: Invalid Skill Token - '..skill)
  return
 end
 current = unitTable.Skills[skill].Total
 value = current + change
 if value > skillCap then
  value = skillCap
  change = skillCap - current
 elseif value < 0 then
  value = 0
  change = 0 - current
 end

 if df.job_skill[skill] then -- In game skills
  local skillid = df.job_skill[skill]
  local found = false
  for i,x in ipairs(unit.status.current_soul.skills) do
   if x.id == skillid then
    found = true
    x.rating = value
    break
   end
  end
  if not found then
   utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = value},'id')
  end
 else -- Custom skills
  -- Nothing needed for changing custom skills
 end
 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeSkill',{unit.id,attribute,-change,0,'end',syndrome}) end
 trackCore(unit,'Skill',skill,change,syndrome,dur,track,cb_id)
end

function changeStat(unit,stat,change,dur,track,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 unitTable = getUnitTable(unit)
 if not unitTable.Stats[stat] then
  print('functions/unit.changeStat: Invalid Stat Token - '..stat)
  return
 end
 current = unitTable.Stats[stat].Base
 value = math.floor(current + change)
 -- Nothing needed because all stats are currently custom only
 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeStat',{unit.id,stat,-change,0,'end',syndrome}) end
 trackCore(unit,'Stat',stat,change,syndrome,dur,track,cb_id)
end

function changeTrait(unit,trait,change,dur,track,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 unitTable = getUnitTable(unit)
 if not unitTable.Traits[trait] then
  print('functions/unit.changeTrait: Invalid Trait Token - '..trait)
  return
 end
 current = unitTable.Traits[trait].Base
 value = math.floor(current + change)
 if value > 100 then
  value = 100
  change = 100 - current
 elseif value < 0 then
  value = 0
  change = 0 - current
 end
 unit.status.current_soul.personality.traits[trait] = value
 --if not track then track = 'track' end -- Not Needed because there are no custom traits currently
 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeTrait',{unit.id,stat,-change,0,'end',syndrome}) end
 trackCore(unit,'Trait',trait,change,syndrome,dur,track,cb_id)
end

--=                     Action Changing Functions
usages[#usages+1] = [===[

Action Changing Functions
=========================

changeAction(unit,action_type,timer)
  Purpose: Changes the timer on a units action, allowing them to act more often
  Calls:   NONE
  Inputs:
           unit        = Unit struct or unit ID
           action_type = Action type (Valid Values: Move, Attack, Block, Dodge, etc...)
           timer       = Number to set timer on action to (Special Values: clear, clearAll)
  Returns: NONE
  
changeInteraction(unit,interaction_id,timer,types)
  Purpose: Changes the delay timer on a units interaction, allowing them to occur more or less frequently
  Calls:   NONE
  Inputs:
           unit           = Unit struct or unit ID
           interaction_id = Interaction ID number
           timer          = Number to set timer on action to (Special Values: clear, clearAll)
           types          = Interaction Type (Valid Values: Innate, Learned, Both)
  Returns: NONE
]===]

function changeAction(unit,action_type,timer)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 if timer == 'clear' then
  actions = unit.actions
  for i = #actions-1,0,-1 do
   if actions[i]['type'] == df.unit_action_type[action_type] then
    unit.actions:erase(i)
   end
  end
 elseif timer == 'clearAll' then
  actions = unit.actions
  for i = #actions-1,0,-1 do
   unit.actions:erase(i)
  end
 else
  action = df.unit_action:new()
  action.id = unit.next_action_id
  unit.next_action_id = unit.next_action_id + 1 
  action.type = df.unit_action_type[action_type]
  data = action.data[string.lower(action_type)]
  for t,_ in pairs(data) do
   if t == 'timer' then
    data.timer = timer
    unit.actions:insert('#',action)
    return
   elseif t == 'timer1' then
    data.timer1 = timer
    data.timer2 = timer
    unit.actions:insert('#',action)
    return
   end
  end
 end
end

function changeInteraction(unit,interaction_id,timer,types)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 if timer == 'clear' or timer == 'clearAll' then timer = 0 end
 if types == 'Innate' or types == 'Both' then
  for i,id in ipairs(unit.curse.own_interaction) do
   if id == interaction_id then
    unit.curse.own_interaction_delay[i] = timer
    break
   end
  end 
 end
 if types == 'Learned' or types == 'Both' then
  for i,id in ipairs(unit.curse.interaction_id) do
   if id == interaction_id then
    unit.curse.interaction_delay[i] = timer
    break
   end
  end  
 end
end

--=                     Body Changing Functions
usages[#usages+1] = [===[ 

Body Changing Functions
=======================

changeBody(unit,part,changeType,change,dur)
  Purpose: Changes a units body and body parts size or temperature
  Calls:   NONE
  Inputs:
           unit       = Unit struct or unit ID
           part       = Body part ID
           changeType = Type of change (Valid Values: Temperature, Size, Area, Length)
           change     = Amount of change (Special Value: fire - sets body part on fire)
           dur        = Length of change in in-game ticks
  Returns: NONE
  
changeLife()
  Purpose:
  Calls:
  Inputs:
  Returns: NONE
  
changeRace(unit,race,caste,dur,track,syndrome)
  Purpose:
  Calls:   trackTransformation
  Inputs:
           unit     = Unit struct or unit ID
           race     = Race ID to transform into
           caste    = Caste ID to transform into
           dur      = Length of transformation in in-game ticks
           track    = Type of tracking (Valid Values: track, end, terminate, terminateClass, terminated)
           syndrome = SYN_NAME of a syndrome to associate with the transformation
  Returns: NONE
  
changeWound()
  Purpose:
  Calls:
  Inputs:
  Returns: NONE
]===]

function changeBody(unit,part,changeType,change,dur)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 changeType = string.upper(changeType)
 
 if changeType == 'TEMPERATURE' then
  if change == 'Fire' then
   unit.body.components.body_part_status[part].on_fire = not unit.body.components.body_part_status[part].on_fire
   unit.flags3.body_temp_in_range = not unit.flags3.body_temp_in_range
  else
   unit.status2.body_part_temperature[part].whole=math.floor(tonumber(unit.status2.body_part_temperature[part].whole + change))
  end
 elseif changeType == 'SIZE' then
  unit.body.size_info.size_cur = math.floor(tonumber(unit.body.size_info.size_cur + change))
 elseif changeType == 'AREA' then
  unit.body.size_info.area_cur = math.floor(tonumber(unit.body.size_info.area_cur + change))
 elseif changeType == 'LENGTH' then
  unit.body.size_info.length_cur = math.floor(tonumber(unit.body.size_info.length_cur + change))
 end

 if dur > 0 then
  if change == 'Fire' then
   dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeBody',{unit.id,part,changeType,change,0})
  else
   dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeBody',{unit.id,part,changeType,-change,0})
  end
 end
end

function changeLife()
 if change == 'Resurrect' then
 elseif change == 'Animate' then
 elseif change == 'DeResurrect' then
 elseif change == 'DeAnimate' then
 elseif change == 'DeSummon' then
 elseif change == 'Kill' then
 end
end

function changeRace(unit,race,caste,dur,track,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 
 trackTransformation(unit,race,caste,dur,track,syndrome,cb_id)
 cur_race = unit.race
 cur_caste = unit.caste
 
 unit.enemy.normal_race = race
 unit.enemy.normal_caste = caste
 unit.enemy.were_race = race
 unit.enemy.were_caste = caste
 
 local inventoryItems = {}
 for _,item in ipairs(unit.inventory) do
  table.insert(inventoryItems, item:new());
 end

 dfhack.timeout(1, 'ticks', function()
 for _,item in ipairs(inventoryItems) do
  dfhack.items.moveToInventory(item.item, unit, item.mode, item.body_part_id)
  item:delete()
 end
  inventoryItems = {}
 end)
 
 if dur > 0 then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeRace',{unit.id,cur_race,cur_caste,0,'end',syndrome}) end
end

function changeWound()

end

--=                     Syndrome Changing Functions
usages[#usages+1] = [===[

Syndrome Changing Functions
===========================

changeSyndrome(unit,syndromes,change,dur)
  Purpose: Make changes to a units syndromes by adding, erasing, terminating, or altering their duration
  Calls:   modtools/add-syndrome | trackCore | checkSyndrome
  Inputs:
           unit      = Unit struct or unit ID
           syndromes = SYN_NAME of syndromes to change (or SYN_CLASS)
           change    = Type of change (Valid Values: add, erase, eraseClass, terminate, terminateClass, alterDuration, alterDurationClass)
           dur       = Length syndrome will last in in-game ticks (or amount of ticks to change syndrome length by)
  Returns: NONE
]===]

function changeSyndrome(unit,syndromes,change,dur)
 roses = dfhack.script_environment('base/roses-table').roses
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return end
 if (change == 'terminate' or change == 'terminateClass') and not roses then return end

 if type(syndromes) ~= 'table' then syndromes = {syndromes} end
 unitID = tostring(unit.id)
 for _,syndrome in pairs(syndromes) do
  if change == 'add' then
   dfhack.run_command('modtools/add-syndrome -target '..unitID..' -syndrome '..syndrome)
  elseif change == 'erase' then
   dfhack.run_command('modtools/add-syndrome -target '..unitID..' -syndrome '..syndrome..' -erase')
  elseif change == 'eraseClass' then
   dfhack.run_command('modtools/add-syndrome -target '..unitID..' -eraseClass '..syndrome)
  elseif change == 'terminate' or change == 'terminateClass' then
   if not roses.UnitTable[unit.id] then return end
   local trackTable = roses.UnitTable[unit.id].SyndromeTrack
   if trackTable[syndrome] then
    trackCore(unit,'Attribute',nil,nil,syndrome,nil,change,nil)
    trackCore(unit,'Resistance',nil,nil,syndrome,nil,change,nil)
    trackCore(unit,'Skill',nil,nil,syndrome,nil,change,nil)
    trackCore(unit,'Stat',nil,nil,syndrome,nil,change,nil)
   end
  elseif change == 'alterDuration' then
   for _,syn in pairs(unit.syndromes.active) do
    if syndrome == df.global.world.raws.syndromes.all[syn.type].syn_name then
     current_ticks = syn.ticks
     new_ticks = current_ticks + dur
     if new_ticks < 0 then new_ticks = 0 end
     syn.ticks = new_ticks
     for _,symptom in pairs(syn.symptoms) do
      symptom.ticks = new_ticks
      for i,_ in pairs(symptom.target_ticks) do
       symptom.target_ticks[i] = new_ticks
      end
     end
    end
   end
  elseif change == 'alterDurationClass' then
   _,ids = checkSyndrome(unit,syndrome,'class')
   for _,id in pairs(ids) do
    for _,syn in pairs(unit.syndromes.active) do
     if id == df.global.world.raws.syndromes.all[syn.type].id then
      current_ticks = syn.ticks
      new_ticks = current_ticks + dur
      if new_ticks < 0 then new_ticks = 0 end
      syn.ticks = new_ticks
      for _,symptom in pairs(syn.symptoms) do
       symptom.ticks = new_ticks
       for i,_ in pairs(symptom.target_ticks) do
        symptom.target_ticks[i] = new_ticks
       end
      end
     end
    end
   end
  end
  if dur > 0 and change == 'add' then cb_id = dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeSyndrome',{unit.id,syndrome,'erase',0}) end
 end
end

--=                     Boolean Functions
usages[#usages+1] = [===[

Boolean Functions
=================

checkClass(unit,class)
  Purpose: Checks if a unit has the given class, either as a CREATURE_CLASS or SYNDROME_CLASS
  Calls:   checkClassCreature | checkClassSyndrome
  Inputs:
           unit  = Unit struct or unit ID
           class = CREATURE_CLASS or SYNDROME_CLASS
  Returns: True/False
  
checkCreatureRace(unit,creature)
  Purpose: Checks if a unit belongs to a given RACE:CASTE combo
  Calls:   NONE
  Inputs:
           unit     = Unit struct or unit ID
           creature = RACE:CASTE (or RACE:ANY)
  Returns: True/False
  
checkCreatureSyndrome(unit,syndrome)
  Purpose: Checks if a unit has a syndrome with the given SYN_NAME
  Calls:   NONE
  Inputs:
           unit     = Unit struct or unit ID
           syndrome = SYN_NAME
  Returns: True/False
  
checkCreatureToken(unit,token)
  Purpose: Checks if the unit has the given token
  Calls:   NONE
  Inputs:
           unit  = Unit struct or unit ID
           token = TOKEN (e.g. MEGABEAST, GRAZER, etc...)
  Returns: True/False
  
checkDistance(unit,location,distance)
  Purpose: Checks if the unit is within a specific distance of given location
  Calls:   NONE
  Inputs:
           unit     = Unit struct or unit ID
           location = { x, y, z }
           distance = # or { x, y, z }
  Returns: True/False
]===]

function checkClass(unit,class)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 check, x = checkClassCreature(unit,class)
 if check then return true,x end
 check, x = checkClassSyndrome(unit,class)
 if check then return true,x end
 return false,''
end

function checkClassCreature(unit,class)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not class then return false end
 if type(class) ~= 'table' then class = {class} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local unitracename = unitraws.creature_id
 local castename = casteraws.caste_id
 local unitclasses = casteraws.creature_class
 for _,unitclass in ipairs(unitclasses) do
  for _,x in ipairs(class) do
   if x == unitclass.value then
    return  true, x
   end
  end
 end
 return false, ''
end

function checkClassSyndrome(unit,class)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not class then return false end
 if type(class) ~= 'table' then class = {class} end

 local actives = unit.syndromes.active
 local syndromes = df.global.world.raws.syndromes.all
 for _,x in ipairs(actives) do
  printall(syndromes[x.type])
  local synclass=syndromes[x.type].syn_class
  for _,y in ipairs(synclass) do
   for _,z in ipairs(class) do
    if z == y.value then
     return  true, z
    end
   end
  end
 end
 return false, ''
end

function checkCreatureRace(unit,creature)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not creature then return false end
 if type(creature) ~= 'table' then creature = {creature} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local unitracename = unitraws.creature_id
 local castename = casteraws.caste_id
 for _,x in ipairs(creature) do
  local xsplit = split(x,':')
  if xsplit[1] == unitracename and (xsplit[2] == castename or xsplit[2] == 'ANY') then
   return true
  end
 end
 return false
end

function checkCreatureSyndrome(unit,syndrome)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not syndrome then return false end
 if type(syndrome) ~= 'table' then syndrome = {syndrome} end
 
 local actives = unit.syndromes.active
 local syndromes = df.global.world.raws.syndromes.all
 for _,x in ipairs(actives) do
  for _,y in ipairs(syndrome) do
   if syndromes[x.type].syn_name == y then
    return true
   end
  end
 end
 return false
end

function checkCreatureToken(unit,token)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not token then return false end
 if type(token) ~= 'table' then token = {token} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local flags1 = unitraws.flags
 local flags2 = casteraws.flags
 local tokens = {}
 for k,v in pairs(flags1) do
  tokens[k] = v
 end
 for k,v in pairs(flags2) do
  tokens[k] = v
 end

 for _,x in ipairs(token) do
  if tokens[x] then
   return true
  end
 end
 return false
end

function checkDistance(unit,location,distance)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not distance then return false end
 if tonumber(distance) then distance = {distance, distance, distance} end

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local x = location[1]
 local y = location[2]
 local z = location[3]
 local rx = distance[1]
 local ry = distance[2]
 local rz = distance[3]

 local xmin = x - rx
 local xmax = x + rx
 local ymin = y - ry
 local ymax = y + ry
 local zmin = z - rz
 local zmax = z + rz
 if xmin < 1 then xmin = 1 end
 if ymin < 1 then ymin = 1 end
 if zmin < 1 then zmin = 1 end
 if xmax > mapx then xmax = mapx-1 end
 if ymax > mapy then ymax = mapy-1 end
 if zmax > mapz then zmax = mapz-1 end
 if (unit.pos.x >= xmin and unit.pos.x <= xmax and unit.pos.y >= ymin and unit.pos.y <= ymax and unit.pos.z >= zmin and unit.pos.z <= zmax) then
  return true
 end
 return false
end

--=                     Body Part Functions
usages[#usages+1] = [===[

Body Part Functions
===================

getBodyParts(unit,partType,partSubType)
  Purpose: Get a table of body part ids that match the given Type and SubType search
  Calls:   getBodyCategory | getBodyToken | getBodyFlag | getBodyConnectedParts | getBodyPartGlobalLayers
  Inputs:
           unit        = Unit struct or unit ID
           partType    = Part search type (Valid Values: Category, Token, Flag, Connected, Layers)
           partSubType = Part search subtype, depends on the partType
  Returns: Table of Body Part IDs
  
getBodyRandom(unit)
  Purpose: Get the body part ID of a random body part weighted by their size
  Calls:   NONE
  Inputs:
           unit = Unit struct or unit ID
  Returns: Body Part ID
]===]

function getBodyParts(unit,partType,partSubType)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not partType then return {} end
 
 partType = string.lower(partType)
 if partType == 'category' then
  return getBodyCategory(unit,partSubType)
 elseif partType == 'token' then
  return getBodyToken(unit,partSubType)
 elseif partType == 'flag' then
  return getBodyFlag(unit,partSubType)
 elseif partType == 'connected' then
  return getBodyConnectedParts(unit,partSubType)
 elseif partType == 'layers' then
  return getBodyPartGlobalLayers(unit,partSubType)
 else
  print('functions/unit.getBodyParts: Unrecognized part type - '..partType)
  return {}
 end
end

function getBodyCategory(unit,category)
 -- Check a unit for body parts that match a given category(s)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not category then return {} end
 if type(category) == 'string' then category = {category} end
 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(category) do
   if y.category == x and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function getBodyToken(unit,token)
 -- Check a unit for body parts that match a given token(s).
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not token then return {} end
 if type(token) == 'string' then token = {token} end

 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(token) do
   if y.token == x and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function getBodyFlag(unit,flag)
 -- Check a unit for body parts that match a given flag(s).
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not flag then return {} end
 if type(flag) == 'string' then flag = {flag} end

 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(flag) do
   if y.flags[x] and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function getBodyConnectedParts(unit,parts)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not parts then return {} end
 if type(parts) ~= 'table' then parts = {parts} end
 for i,x in pairs(parts) do
  for j,y in pairs(unit.body.body_plan.body_parts) do
   if y.con_part_id == x then
    table.insert(parts,j)
   end
  end
 end
 return parts
end

function getBodyPartGlobalLayers(unit,part)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not part then return {} end
 global_layers = {}
 for i,x in pairs(unit.body.body_plan.layer_part) do
  if x == part then table.insert(global_layers,i) end
 end
 return global_layers
end

function getBodyRandom(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return  end
 local rand = dfhack.random.new()
 local totwght = 0
 local weights = {}
 weights[0] = 0
 local n = 1
 for _,targets in pairs(unit.body.body_plan.body_parts) do
  totwght = totwght + targets.relsize
  weights[n] = weights[n-1] + targets.relsize
  n = n + 1  
 end
 while not target do
  pick = rand:random(totwght)
  for i = 1,n do
   if pick >= weights[i-1] and pick < weights[i] then
    target = i-1
    break
   end
  end
  if unit.body.components.body_part_status[target].missing then target = nil end
 end
 return target
end

--=                     Corpse Functions
usages[#usages+1] = [===[

Corpse Functions
================

getBodyCorpseParts(unit)
  Purpose: Get a list of all the units corpse part IDs and corpse ID
  Calls:   NONE
  Inputs:
           unit = Unit struct or unit ID
  Returns: Table of corpse part IDs and corpse ID
  
getItemCorpse(caste)
  Purpose: Get the item corpse the creature creates when they die
  Calls:   NONE
  Inputs:
           unit = Unit struct or unit ID
  Returns: String of item corpse item and mat or 'Corpse'  
]===]

function getBodyCorpseParts(unit)
 if df.item_corpsest:is_instance(unit) then
  unit = df.unit.find(unit.unit_id)
 elseif df.item_corpsepiecest:is_instance(unit) then
  unit = df.unit.find(unit.unit_id)
 elseif tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if not unit then return {Unit=-1,Corpse=false,Parts={}} end
 corpseparts = {Unit=unit.id,Corpse=false,Parts={}}
 for _,id in pairs(unit.corpse_parts) do
  item = df.item.find(id)
  if df.item_corpsest:is_instance(item) then
   corpseparts.Corpse = item.id
  elseif df.item_corpsepiecest:is_instance(item) then
   table.insert(corpseparts.Parts,item.id)
  end
 end
 return corpseparts
end

function getItemCorpse(caste)
 item_type = caste.misc.itemcorpse_itemtype
 item_subtype = caste.misc.itemcorpse_itemsubtype
 mat_type = caste.misc.itemcorpse_materialtype
 mat_index = caste.misc.itemcorpse_materialindex
 if caste.flags.ITEMCORPSE then
  if item_subtype >= 0 then
   item = dfhack.items.getSubtypeDef(item_type,item_subtype).name
  else
   item = string.lower(df.item_type[item_type])
  end
  mat = dfhack.matinfo.decode(mat_type,mat_index).material.state_name.Solid
  itemcorpse = mat..' '..item
 else
  itemcorpse = 'Corpse'
 end
 return itemcorpse
end

--=                     Inventory Functions
usages[#usages+1] = [===[

Inventory Functions
===================

getInventory(unit,inventoryType,inventorySubType)
  Purpose: Get the item ids of a unit inventory based on given criteria
  Calls:   getInventoryType | getInventoryBodyPart | getInventoryMode
  Inputs:
           unit             = Unit struct or unit ID
           inventoryType    = Inventory search type (Valid Values: ItemType, BodyPart, Mode)
           inventorySubType = Inventory search subtype, depends on inventory search type
  Returns: Table of item IDs
]===]

function getInventory(unit,inventoryType,inventorySubType)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not inventoryType then return {} end
 inventoryType = string.lower(inventoryType)
 if inventoryType == 'itemtype' then
  return getInventoryType(unit,inventorySubType)
 elseif inventoryType == 'bodypart' then
  return getInventoryBodyPart(unit,inventorySubType)
 elseif inventoryType == 'mode' then
  return getInventoryMode(unit,inventorySubType)
 else
  print('functions/unit.getInventory: Unrecognized inventory type - '..inventoryType)
  return {}
 end  
end

function getInventoryType(unit,item_type)
 -- Check a unit for any inventory items of a given type(s).
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not item_type then return {} end
 if type(item_type) == 'string' then item_type = {item_type} end

 local items = {}
 local inventory = unit.inventory
 local a = 1
 for _,x in ipairs(inventory) do
  for _,y in ipairs(item_type) do
   if df.item_type[x.item:getType()] == y or y == 'ALL' then
    items[a] = x.item.id
    a = a + 1
   end
  end
 end
 return items
end

function getInventoryBodyPart(unit,bodyPart)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not bodyPart then return {} end
 if type(bodyPart) ~= 'table' then bodyPart = {bodyPart} end
 
 local items = {}
 local inventory = unit.inventory
 for _,x in ipairs(inventory) do
  for _,y in ipairs(bodyPart) do
   if x.body_part_id == y then
    items[#items+1] = x.item.id
   end
  end
 end
 return items
end

function getInventoryMode(unit,mode)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not mode then return {} end
 if type(mode) ~= 'table' then mode = {mode} end

 local items = {}
 local inventory = unit.inventory
 for _,x in ipairs(inventory) do
  for _,y in ipairs(mode) do
   if x.mode == y then
    items[#items+1] = x.item.id
   end
  end
 end
 return items
end

--=                     Miscellanious Get Functions
usages[#usages+1] = [===[

Miscellanious Get Functions
===========================

getAttack(unit,attack_type)
  Purpose: Get the attack ID and associated body part ID of a random or specific attack
  Calls:   NONE
  Inputs:
           unit        = Unit struct or unit ID
           attack_type = ATTACK_TOKEN (e.g. PUNCH) or Random
  Returns: Attack ID, Body Part ID of attack
  
getEmotion(unit,emotion,thought)
  Purpose: Get a list of all the emotions that satisfy the given emotion/thought combination
  Calls:
  Inputs:
           unit    = Unit struct or unit ID
           emotion = EMOTION_TOKEN
           thought = THOUGHT_TOKEN
  Returns: Table of unit emotion IDs
  
getSyndrome(unit,class,what)
  Purpose: Get the syndrome names and ids of all syndromes that match a given SYN_NAME or SYN_CLASS
  Calls:   NONE
  Inputs:
           unit  = Unit struct or unit ID
           class = SYN_NAME or SYN_CLASS
           what  = (Valid Values: name, class)
  Returns: Table of SYN_NAME, Table of syndrome IDs, Table of units syndrome IDs
  
getCounter(unit,counter)
  Purpose: Get the value of a units specific counter
  Calls:   NONE
  Inputs:
           unit    = Unit struct or unit ID
           counter = Counter token (e.g. webbed)
  Returns: Value of counter
  
getSpeed(unit,what)
  Purpose: Get the kph value of a units gait information
  Calls:   NONE
  Inputs:
           unit = Unit struct, unit ID, or caste raw
           what = (Valid Values: WALK, SWIM, CRAWL, CLIMB, FLY)
  Returns: value of speed in kph, returns nil if the unit does not have any gait information
]===]

function getAttack(unit,attack_type)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not attack_type then return end
 if attack_type == 'Random' then
  local rand = dfhack.random.new()
  local totwght = 0
  local weights = {}
  weights[0] = 0
  local n = 1
  for _,attacks in pairs(unit.body.body_plan.attacks) do
   if attacks.flags.main then
    totwght = totwght + 100
    weights[n] = weights[n-1] + 100
   else
    totwght = totwght + 1
    weights[n] = weights[n-1] + 1
   end
   n = n + 1
  end 
  while not attack do
   pick = rand:random(totwght)
   for i = 1,n do
    if pick >= weights[i-1] and pick < weights[i] then
     attack = i-1
     break
    end
   end
   if unit.body.components.body_part_status[unit.body.body_plan.attacks[attack].body_part_idx[0]].missing then attack = nil end
  end
 else
  for i,attacks in pairs(unit.body.body_plan.attacks) do
   if attacks.name == attack_type then
    attack = i
    break
   end
  end
 end
 return attack, unit.body.body_plan.attacks[attack].body_part_idx[0]
end

function getEmotion(unit,emotion,thought)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not emotion or not thought then return {} end
 thought = df.unit_thought_type[thought]
 emotion = df.emotion_type[emotion]
 local list = {}
 local l = 1
 local emotions=unit.status.current_soul.personality.emotions
 for i,x in pairs(emotions) do
  if thought then
   if thought == x.thought then
    if emotion then
     if emotion == x.emotion then
      list[l] = i
      l = l + 1
     end
    else
     list[l] = i
     l = l + 1
    end
   end
  elseif emotion then
   if emotion == x.emotion then
    list[l] = i
    l = l + 1
   end
  else
   list[l] = i
   l = l + 1   
  end
 end
 return list
end

function getSyndrome(unit,class,what)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not class or not what then return end
 if type(class) ~= 'table' then class = {class} end

 local actives = unit.syndromes.active
 local syndromes = df.global.world.raws.syndromes.all
 local names = {}
 local ids = {}
 local ida = {}
 i = 0
 if what == 'class' then
  for j,x in pairs(actives) do
   local synclass=syndromes[x.type].syn_class
   for _,y in ipairs(synclass) do
    for _,z in ipairs(class) do
     if z == y.value then
      i = i + 1
      names[i] = syndromes[x.type].syn_name
      ids[i] = syndromes[x.type].id
      ida[i] = j
     end
    end
   end
  end
 elseif what == 'name' then
  for j,x in pairs(actives) do
   for _,y in ipairs(class) do
    if syndromes[x.type].syn_name == y then
     i = i + 1
     names[i] = y
     ids[i] = syndromes[x.type].id
     ida[i] = j
    end
   end
  end
 elseif what == 'detailed' then
  syn = {}
  syn_detail = {}
  for i,x in pairs(unit.syndromes.active) do
   curticks = x.ticks
   endticks = -1
   for j,y in pairs(df.global.world.raws.syndromes.all[tonumber(x.type)].ce) do
    if y['end'] > endticks then endticks = y['end'] end
   end
   if endticks == -1 then
    duration = 'Permenant'
   else
    duration = tostring(endticks-curticks)
   end
   n = #syn+1
   syn[n] = {df.global.world.raws.syndromes.all[tonumber(x.type)].syn_name:gsub("(%a)([%w_']*)", tchelper),duration,curticks}
   if syn[n][1] == '' then
    syn[n][1] = 'Unknown'
   end
   syn_detail[#syn_detail+1] = df.global.world.raws.syndromes.all[tonumber(x.type)].ce
  end
  if #syn == 0 then
   syn[1] = {'None','',''}
   syn_detail[1] = {}
  end
  return syn, syn_detail
 end
 return names, ids, ida
end

function getCounter(unit,counter)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not counter then return 0 end
 
 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' then
  location = unit.body
 else
  return 0
 end
 return location[counter] 
end

function getWound(unit,class,what)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return {} end
 local outTable = {}
 
 wounds = unit.body.wounds
 for i,wound in pairs(wounds) do
  outTable[i] = {}
  outTable[i].ID = wound.id
  outTable[i].Age = wound.age
  --outTable[i].Attacker = df.unit.find(wound.attacker_unit_id)
  --outTable[i].Syndrome = df.syndrome.find(wound.syndrome_id)
  --outTable[i].Curse    = wound.curse
  --outTable[i].Flags = wound.flags
  outTable[i].Parts = {}
  for j,part in pairs(wound.parts) do
   outTable[i].Parts[j] = {}
   outTable[i].Parts[j].BP_ID = part.body_part_id
   outTable[i].Parts[j].LX_ID = part.layer_idx
   outTable[i].Parts[j].Strain = part.strain
  end
 end
 
 return outTable
end

function getSpeed(unit,what)
 local gait
 local speed = 0
 what = what or 'WALK'
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if unit._type == df.caste_raw then -- check if we fed it a unit or a caste raw
  gait = unit.body_info.gait_info[what]
 else
  gait = df.creature_raw.find(unit.race).caste[unit.caste].body_info.gait_info[what]
 end
 if not gait then return nil end
 if #gait == 0 then return nil end
 local top_speed = gait[0].full_speed
 
 if     top_speed >= 8775 then 
  speed = 1
 elseif top_speed >= 4388 then 
  speed = 2
 elseif top_speed >= 2925 then 
  speed = 3
 elseif top_speed >= 2193 then 
  speed = 4
 elseif top_speed >= 1755 then 
  speed = 5
 elseif top_speed >= 1463 then 
  speed = 6
 elseif top_speed >= 1254 then 
  speed = 7
 elseif top_speed >= 1097 then 
  speed = 8
 elseif top_speed >= 975 then  
  speed = 9
 elseif top_speed >= 878 then 
  speed = 10
 elseif top_speed >= 798 then 
  speed = 11
 elseif top_speed >= 731 then 
  speed = 12
 elseif top_speed >= 675 then 
  speed = 13
 elseif top_speed >= 627 then 
  speed = 14
 elseif top_speed >= 585 then 
  speed = 15
 elseif top_speed >= 548 then 
  speed = 16
 elseif top_speed >= 516 then 
  speed = 17
 elseif top_speed >= 488 then 
  speed = 18
 elseif top_speed >= 462 then 
  speed = 19
 elseif top_speed >= 439 then 
  speed = 20
 elseif top_speed >= 418 then 
  speed = 21
 elseif top_speed >= 399 then 
  speed = 22
 elseif top_speed >= 382 then 
  speed = 23
 elseif top_speed >= 366 then 
  speed = 24
 elseif top_speed >= 351 then 
  speed = 25
 elseif top_speed >= 338 then 
  speed = 26
 elseif top_speed >= 325 then 
  speed = 27
 elseif top_speed >= 313 then 
  speed = 28
 elseif top_speed >= 303 then 
  speed = 29
 elseif top_speed >= 293 then 
  speed = 30
 elseif top_speed >= 283 then 
  speed = 31
 elseif top_speed >= 274 then 
  speed = 32
 elseif top_speed >= 266 then 
  speed = 33
 elseif top_speed >= 258 then 
  speed = 34
 elseif top_speed >= 251 then 
  speed = 35
 elseif top_speed >= 244 then 
  speed = 36
 elseif top_speed >= 237 then 
  speed = 37
 elseif top_speed >= 231 then 
  speed = 38
 elseif top_speed >= 225 then 
  speed = 39
 elseif top_speed >= 219 then 
  speed = 40
 elseif top_speed >= 214 then 
  speed = 41
 elseif top_speed >= 209 then 
  speed = 42
 elseif top_speed >= 204 then 
  speed = 43
 elseif top_speed >= 199 then 
  speed = 44
 elseif top_speed >= 195 then 
  speed = 45
 elseif top_speed >= 191 then 
  speed = 46
 elseif top_speed >= 187 then 
  speed = 47
 elseif top_speed >= 183 then 
  speed = 48
 elseif top_speed >= 179 then 
  speed = 49
 elseif top_speed >= 176 then 
  speed = 50
 elseif top_speed >= 173 then 
  speed = 51
 elseif top_speed >= 169 then 
  speed = 52
 elseif top_speed >= 166 then 
  speed = 53
 elseif top_speed >= 163 then 
  speed = 54
 elseif top_speed >= 160 then 
  speed = 55
 elseif top_speed >= 157 then 
  speed = 56
 elseif top_speed >= 154 then 
  speed = 57
 elseif top_speed >= 151 then 
  speed = 58
 elseif top_speed >= 149 then 
  speed = 59
 elseif top_speed >= 146 then 
  speed = 60
 elseif top_speed >= 144 then 
  speed = 61
 elseif top_speed >= 142 then 
  speed = 62
 elseif top_speed >= 139 then 
  speed = 63
 elseif top_speed >= 137 then 
  speed = 64
 elseif top_speed >= 135 then 
  speed = 65
 elseif top_speed >= 133 then 
  speed = 66
 elseif top_speed >= 131 then 
  speed = 67
 elseif top_speed >= 129 then 
  speed = 68
 elseif top_speed >= 127 then 
  speed = 69
 elseif top_speed >= 125 then 
  speed = 70
 elseif top_speed >= 124 then 
  speed = 71
 elseif top_speed >= 122 then 
  speed = 72
 elseif top_speed >= 120 then 
  speed = 73
 elseif top_speed >= 119 then 
  speed = 74
 elseif top_speed >= 117 then 
  speed = 75
 elseif top_speed >= 115 then 
  speed = 76
 elseif top_speed >= 114 then 
  speed = 77
 elseif top_speed >= 112 then 
  speed = 78
 elseif top_speed >= 111 then 
  speed = 79
 elseif top_speed >= 109 then 
  speed = 80
 elseif top_speed >= 108 then 
  speed = 81
 elseif top_speed >= 107 then 
  speed = 82
 elseif top_speed >= 105 then 
  speed = 83
 elseif top_speed >= 104 then 
  speed = 84
 elseif top_speed >= 103 then 
  speed = 85
 elseif top_speed >= 102 then 
  speed = 86
 elseif top_speed >= 100 then 
  speed = 87
 else
  speed = 88
 end
 
 return speed
end

--=                     Miscellanious Functions
usages[#usages+1] = [===[

Miscellanious Functions
=======================

move(unit,location)
  Purpose: Move a unit to a new location
  Calls:   NONE
  Inputs:  unit     = Unit struct or unit ID
           location = { x, y, z }
  Returns: NONE

makeProjectile(unit,velocity)
  Purpose: Turn a unit into a projectile
  Calls:   NONE
  Inputs:
           unit     = Unit struct or unit ID
           velocity = { x, y, z }
  Returns: NONE
  
findUnit(search)
  Purpose: Find a unit on the map that satisfies the search criteria
  Calls:   NONE
  Inputs:
           search = Search table (e.g. { RANDOM, PROFESSION, CARPENTER })
  Returns: Table of all units that meet search criteria
  
]===]

function move(unit,location)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not location then return end
 pos = {}
 pos.x = tonumber(location.x) or tonumber(location[1]) or tonumber(unit.pos.x)
 pos.y = tonumber(location.y) or tonumber(location[2]) or tonumber(unit.pos.y)
 pos.z = tonumber(location.z) or tonumber(location[3]) or tonumber(unit.pos.z)
 if pos.x < 0 or pos.y < 0 or pos.z < 0 then
  return
 end
 local unitoccupancy = dfhack.maps.getTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
 local newoccupancy = dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16]
 if newoccupancy.unit then
  unit.flags1.on_ground=true
 end
 unit.pos.x = pos.x
 unit.pos.y = pos.y
 unit.pos.z = pos.z
 if not unit.flags1.on_ground then unitoccupancy.unit = false else unitoccupancy.unit_grounded = false end
end

function makeProjectile(unit,velocity)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit or not velocity then return end
 local vx = velocity[1]
 local vy = velocity[2]
 local vz = velocity[3]
 local count=0
 local l = df.global.world.proj_list
 local lastlist=l
 l=l.next
 while l do
  count=count+1
  if l.next==nil then
   lastlist=l
  end
  l = l.next
 end

 newlist = df.proj_list_link:new()
 lastlist.next=newlist
 newlist.prev=lastlist
 proj = df.proj_unitst:new()
 newlist.item=proj
 proj.link=newlist
 proj.id=df.global.proj_next_id
 df.global.proj_next_id=df.global.proj_next_id+1
 proj.unit=unit
 proj.origin_pos.x=unit.pos.x
 proj.origin_pos.y=unit.pos.y
 proj.origin_pos.z=unit.pos.z
 proj.prev_pos.x=unit.pos.x
 proj.prev_pos.y=unit.pos.y
 proj.prev_pos.z=unit.pos.z
 proj.cur_pos.x=unit.pos.x
 proj.cur_pos.y=unit.pos.y
 proj.cur_pos.z=unit.pos.z
 proj.flags.no_impact_destroy=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.speed_x=vx
 proj.speed_y=vy
 proj.speed_z=vz
 unitoccupancy = dfhack.maps.ensureTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
 if not unit.flags1.on_ground then
  unitoccupancy.unit = false
 else
  unitoccupancy.unit_grounded = false
 end
 unit.flags1.projectile=true
 unit.flags1.on_ground=false
end

function findUnit(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local unitList = df.global.world.units.active
 local targetList = {}
 local target = nil
 local n = 0
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   n = 1
   targetList = unitList
  elseif secondary == 'POPULATION' then
   for i,x in pairs(unitList) do
    if dfhack.units.isCitizen(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'CIVILIZATION' then
   for i,x in pairs(unitList) do
    if x.civ_id == df.global.ui.civ_id then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'INVADER' then
   for i,x in pairs(unitList) do
    if x.invasion_id >= 0 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'MALE' then
   for i,x in pairs(unitList) do
    if x.sex == 0 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'FEMALE' then
   for i,x in pairs(unitList) do
    if x.sex == 1 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'PROFESSION' then
   for i,x in pairs(unitList) do
    if tertiary == dfhack.units.getProfessionName(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'SKILL' then
   for i,x in pairs(unitList) do
    if dfhack.units.getEffectiveSkill(x,df.job_skill[tertiary]) >= tonumber(quaternary) then
     n = n + 1
     targetList[n] = x
    end
   end
  else
   for i,x in pairs(unitList) do
    creature = df.global.world.raws.creatures.all[x.race].creature_id
    caste = df.global.world.raws.creatures.all[x.race].caste[x.caste].caste_id
    if secondary == creature then
     if tertiary == caste or tertiary == 'NONE' then
      n = n + 1
      targetList[n] = x
     end
    end
   end
  end
 end
 if n > 0 then
  targetList = dfhack.script_environment('functions/misc').permute(targetList)
  target = targetList[1]
  return {target}
 else
  return {}
 end
end

--=                     Unit Creation Functions
usages[#usages+1] = [===[

Unit Creation Functions 
=======================

create()
  Purpose:
  Calls:
  Inputs:
  Returns:
  
createClass(unit,classes)
  Purpose:
  Calls:
  Inputs:
  Returns:
  
createEquipment(unit,equip)
  Purpose:
  Calls:
  Inputs:
  Returns:
  
createSkills(unit,skills)
  Purpose:
  Calls:
  Inputs:
  Returns:
]===]

function create()

end

function createClass(unit,classes)
 local class = nil
 local level = nil

 class = split(classes,':')
 if class[1] == 'CIVILIZATION' then
  -- Classes avaiable to the civilization (using Civilization System) will go here
 elseif class[1] == 'ITEMS' then
  -- Classes based on equipped items will be chosen
 elseif class[1] == 'RANDOM' then
  -- A random class will be chosen
 elseif class[1] == 'TEMPLATE' then
  -- Classes from a template file will go here
 else
  -- A specific class will go here
 end

 return class, level
end

function createEquipment(unit,equip)
 equipment = split(equip,':')
 items = {}
 parts = {}
 modes = {}

 entities = {}
 for _,x in pairs(df.global.world.raws.entities) do
  entities[x.code] = x
 end
 if entities[equipment[1]] then
  -- Item Options: Based off of entity raws
  -- Mat Options: Random
  raw = entities[equipment[1]]
  availItems = {weapon=raw.weapon_id,armor=raw.armor_id,helm=raw.helm_id,gloves=raw.gloves_id,
                shoes=raw.shoes_id,pants=raw.pants_id,shield=raw.shield_id,ammo=raw.ammo_id}
  value = tonumber(equipment[2])
 elseif equipment[1] == 'CIV' then
  -- Item Options: Items available to the units civ
  -- Mat Options: Materials available to the units civ
  civ = df.historic_entity.find(unit.civ_id)
  rsr = civ.resources
  mtl = civ.resources.metal
  availItems = {weapon=rsr.weapon_type,armor=rsr.armor_type,helm=rsr.helm_type,gloves=rsr.gloves_type,
                shoes=rsr.shoes_type,pants=rsr.pants_type,shield=rsr.ammo_type,ammo=rsr.ammo_type}
  availMats  = {weapon=mtl.weapon,armor=mtl.armor,ammo=mtl.ammo,leather=rsr.organic.leather,cloth=rsr.organic.fiber}
  value = tonumber(equipment[2])
 elseif equipment[1] == 'TEMPLATE' then
  -- Item Options: Items read from a template
  -- Mat Options: Materials read from a template
  template = equipment[2]
  roses = dfhack.script_environment('base/roses-table').roses
  if safe_index(roses,'EquipmentTemplates',template) then
   tmp = roses.EquipmentTemplates[template]
   availItems = {weapon=tmp.Weapons,armor=tmp.Armor,helm=tmp.Helms,gloves=tmp.Gloves,
                 shoes=tmp.Shoes,pants=tmp.Pants,shield=tmp.Shields,ammo=tmp.Ammo}
   availMats  = {weapon=tmp.WeaponMats,armor=tmp.ArmorMats,ammo=tmp.AmmoMats,leather=tmp.Leathers,cloth=tmp.Cloths}
   value = tmp.Value
  else
   return items, parts, modes
  end
 elseif equipment[1] == 'RANDOM' then
  -- Item Options: Random
  -- Mat Options: Random
  value = tonumber(equipment[2])
 elseif equipment[1] == 'UNIFORM' then -- Unsure if this will actually work
  -- Item Options: Items from a uniform
  -- Mat Options: Materials from a uniform
  value = 0
 end

 return items, parts, modes 
end

function createSkills(unit,skills)
 local skill = {}
 local level = {}

 table = split(skills,':')
 if table[1] == 'TEMPLATE' then
  -- Skills from a template file will go here
 elseif table[1] == 'ITEMS' then
  -- Skills based on equipped items will go here
 elseif table[1] == 'RANDOM' then
  -- Random skills will go here
 else
  -- A specific skill will go here
 end

 return skill, level
end
