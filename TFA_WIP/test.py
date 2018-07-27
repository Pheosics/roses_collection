from odsreader import ODSReader as ods

# Races
racesOutside = ['Ashari','Coatl','Human','Triton']
racesBrimir  = ['Druegar','Dwarf','Gnome','Halfling','Hobbit']
racesAlfar   = ['Drow','Eladrin','Elf','Orc']
racesCorrupt = ['Goblin']
racesElder   = ['Dragons','Giants','Old Ones','Sylvan','Xecti']
racesGuild   = ['MagesGuild', 'HuntersGuild', 'ShadowGuild']

def sheetDim(sheet):
 n = 0
 intable = True
 while intable:
  try:
   if sheet[0][n] == '':
    intable = False
   else:
    n += 1
  except:
   intable = False
 m = 0
 intable = True
 while intable:
  try:
   if sheet[m][0] == '':
    intable = False
   else:
    m += 1
  except:
   intable = False
 return m,n

def readSheets(fname,sheets):
 f = ods(fname)
 table = []
 tNum = -1
 for sheet in sheets:
  if list(f.SHEETS.keys()).count(sheet) != 1: continue
  m,n = sheetDim(f.getSheet(sheet))
  categories = f.getSheet(sheet)[0][0:n]
  for i in range(1,m):
   table.append({})
   tNum += 1
   table[tNum]['Sheet'] = sheet
   for j in range(n):
    table[tNum][categories[j].strip()] = f.getSheet(sheet)[i][j].strip()
 return table

def writeEnhancedInformation(fout,table):
 fout.write('  {NAME:'+table['Name']+'}\n')
 fout.write('  {DESCRIPTION:'+table['Description']+'}\n')
 if table.get('Class','') != '':  fout.write('  {CLASS:'+table['Class']+'}\n')
 if table.get('Skill','') != '':  fout.write('  {SKILL:'+table['Skill']+'}\n')
 if table.get('Level','') != '':  fout.write('  {LEVEL:'+table['Level']+'}\n')
 if table.get('Rarity','') != '': fout.write('  {RARITY:'+table['Rarity']+'}\n')
 # Item and Material Specific Options
 if table.get('OnEquip','') != '':
  fout.write('  {ON_EQUIP}\n')
  for s in table['OnEquip'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnAttack','') != '':
  fout.write('  {ON_ATTACK}\n')
  for s in table['OnAttack'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnShoot','') != '':
  fout.write('  {ON_SHOOT}\n')
  for s in table['OnShoot'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnFired','') != '':
  fout.write('  {ON_PROJECTILE_FIRED}\n')
  for s in table['OnFired'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnWound','') != '':
  fout.write('  {ON_WOUND}\n')
  for s in table['OnWound'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnHit','') != '':
  fout.write('  {ON_PROJECTILE_HIT}\n')
  for s in table['OnHit'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnBlock','') != '':
  fout.write('  {ON_BLOCK}\n')
  for s in table['OnBlock'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnParry','') != '':
  fout.write('  {ON_PARRY}\n')
  for s in table['OnParry'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnDodge','') != '':
  fout.write('  {ON_DODGE}\n')
  for s in table['OnDodge'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnMove','') != '':
  fout.write('  {ON_MOVE}\n')
  for s in table['OnMove'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnProjMove','') != '':
  fout.write('  {ON_PROJECTILE_MOVE}\n')
  for s in table['OnProjMove'].split('\n'):
   fout.write('   {'+s+'}\n')
 if table.get('OnReport','') != '':
  fout.write('  {ON_Report}\n')
  for s in table['OnReport'].split('\n'):
   fout.write('   {'+s+'}\n')
 # Building Specific Options
 if table.get('Stages','') != '': fout.write('  {STAGES:'+table['Stages']+'}\n')
 if table.get('OutIn','') == 'Outside':
  fout.write('  {OUTSIDE_ONLY}\n')
 elif table.get('OutIn','') == 'Inside':
  fout.write('  {INSIDE_ONLY}\n')
 if table.get('Stories','') != '':   fout.write('  {MULTI_STORY:'+table['Stories']+'}\n')
 if table.get('Amount','') != '':    fout.write('  {MAX_AMOUNT:'+table['Amount']+'}\n')
 if table.get('Water','') != '':     fout.write('  {REQUIRED_WATER:'+table['Water']+'}\n')
 if table.get('Magma','') != '':     fout.write('  {REQUIRED_MAGMA:'+table['Magma']+'}\n')
 if table.get('Required','') != '':  fout.write('  {REQUIRED_BUILDING:'+table['Required']+'}\n')
 if table.get('Forbidden','') != '': fout.write('  {FORBIDDEN_BUILDING:'+table['Forbidden']+'}\n')
 if table.get('Script','') != '':
  for s in table['Script'].split('\n'):
   fout.write('  }Script:'+s+'}\n')

 return

class ClassSystem:
 def __init__(self):
  self.classSheets = ['Physical','Magical','Mixed']
  self.featSheets  = ['Physical','Magical','Mixed','Items','Special']
  self.spellSheets = ['Finesse','Might','Arcane','Elemental','Divine','Nature']
  self.classes = readSheets('Classes.ods',self.classSheets)
  self.feats = readSheets('Feats.ods',self.featSheets)
  self.spells = readSheets('Spells.ods',self.spellSheets)
  print('\nClassSystem')
  self.writeClasses()
  self.writeFeats()
  self.writeSpells()

 def writeClasses(self):
  print('Number of Classes: '+str(len(self.classes)))
  # Inorganic File
  inout = open('inorganic_syndromes_classes.txt','w')
  inout.write('inorganic_syndromes_classes\n')
  inout.write('\n[OBJECT:INORGANIC]\n')
  inout.write('\n [INORGANIC:SYSTEM_CLASS_NAMES]\n')
  inout.write('  [USE_MATERIAL_TEMPLATE:SYSTEM_SYNDROMES]\n')

  # Class Files
  files = {}
  for sheet in self.classSheets:
   files[sheet] = open('classes_'+sheet.lower()+'.txt','w')
   files[sheet].write('classes_'+sheet.lower()+'\n')
   files[sheet].write('\n[OBJECT:CLASS]\n')

  ## Loop over all classes
  for i in range(len(self.classes)):
   # Class file
   clss = self.classes[i]
   fout = files[clss['Sheet']]
   key = clss['Category'] + '_' + clss['Sphere'] + '_' + clss['School']
   if clss['Discipline'] != 'NONE': key = key + '_' + clss['Discipline']
   if clss['Sub Discipline'] != 'NONE': key = key + '_' + clss['Sub Discipline']
   fout.write('\n [CLASS:'+key+']\n')
   fout.write('  [KEY:'+clss['Class']+']\n')
   fout.write('  [NAME:'+clss['Name'] + ']\n')
   fout.write('  [DESCRIPTION:'+clss['Description']+']\n')
   fout.write('  [SPHERE:'+clss['Sphere']+']\n')
   fout.write('  [SCHOOL:'+clss['School']+']\n')
   fout.write('  [LEVELS:'+clss['Levels']+']\n')
   fout.write('  [EXP:'+clss['Experience']+']\n')
   for s in clss['R Classes'].split('\n'):
    if s != '': fout.write('  [REQUIREMENT_CLASS:'+s+']\n')
   for s in clss['R Attributes'].split('\n'):
    if s != '': fout.write('  [REQUIREMENT_ATTRIBUTE:'+s+']\n')
   for s in clss['R Skills'].split('\n'):
    if s != '': fout.write('  [REQUIREMENT_SKILL:'+s+']\n')
   for s in clss['R Stats'].split('\n'):
    if s != '': fout.write('  [REQUIREMENT_Stat:'+s+']\n')
   for s in clss['F Classes'].split('\n'):
    if s != '': fout.write('  [FORBIDDEN_CLASS:'+s+']\n')
   for s in clss['B Attributes'].split('\n'):
    if s != '': fout.write('  [BONUS_ATTRIBUTE:'+s+']\n')
   for s in clss['B Resistances'].split('\n'):
    if s != '': fout.write('  [BONUS_RESISTANCE:'+s+']\n')
   for s in clss['B Skills'].split('\n'):
    if s != '': fout.write('  [BONUS_SKILL:'+s+']\n')
   for s in clss['B Stats'].split('\n'):
    if s != '': fout.write('  [BONUS_STAT:'+s+']\n')
   for s in clss['B Traits'].split('\n'):
    if s != '': fout.write('  [BONUS_TRAIT:'+s+']\n')
   for s in clss['LB Attributes'].split('\n'):
    if s != '': fout.write('  [LEVELING_BONUS:ATTRIBUTE:'+s+']\n')
   for s in clss['LB Resistances'].split('\n'):
    if s != '': fout.write('  [LEVELING_BONUS:RESISTANCE:'+s+']\n')
   for s in clss['LB Skills'].split('\n'):
    if s != '': fout.write('  [LEVELING:BONUS:SKILL:'+s+']\n')
   for s in clss['LB Stats'].split('\n'):
    if s != '': fout.write('  [LEVELING_BONUS:STAT:'+s+']\n')
   for s in clss['LB Traits'].split('\n'):
    if s != '': fout.write('  [LEVELING_BONUS:TRAIT:'+s+']\n')
 
   for s in clss['Spell Groups'].split('\n'):
    if s == '': continue
    spellSphere = s.split('_')[0]
    spellSchool = s.split('_')[1].split(':')[0]
    spellLevel  = s.split(':')[1]
    for j in range(len(self.spells)):
     testLevel = int(spellLevel)
     while testLevel > 0:
      if self.spells[j]['Sphere'] == spellSphere and self.spells[j]['School'] == spellSchool and self.spells[j]['Lvl'] == str(testLevel):
       spellKey = spellSphere + '_' + spellSchool + '_' + self.spells[j]['Spell']
       fout.write('  [SPELL:'+spellKey+':1]\n')
      testLevel = testLevel - 1  
 
   for s in clss['Special Spells'].split('\n'):
    if s != '': fout.write('  [SPELL:'+s+']\n')

   # Inorganic file
   inout.write('  [SYNDROME]\n')
   inout.write('   [SYN_NAME:'+key+']\n')
   inout.write('   [SYN_CLASS:CLASS_NAME]\n')
   inout.write('   [CE_DISPLAY_NAME:START:0:NAME:'+clss['Name']+':'+clss['Names']+':'+clss['Adj']+']\n')

  for sheet in self.classSheets:
   files[sheet].close()
  inout.close()

  return

 def writeFeats(self):
  print('Number of Feats: '+str(len(self.feats)))
  # Inorganic File
  inout = open('inorganic_syndromes_feats.txt','w')
  inout.write('inorganic_syndromes_feats\n')
  inout.write('\n[OBJECT:INORGANIC]\n')
  inout.write('\n [INORGANIC:SYSTEM_CLASS_FEATS]\n')
  inout.write('  [USE_MATERIAL_TEMPLATE:SYSTEM_SYNDROMES]\n')

  files = {}
  for sheet in self.featSheets:
   files[sheet] = open('feats_'+sheet.lower()+'.txt','w')
   files[sheet].write('feats_'+sheet.lower()+'\n')
   files[sheet].write('\n[OBJECT:FEAT]\n')

  for i in range(len(self.feats)):
   feat = self.feats[i]
   fout = files[feat['Sheet']]
   key = feat['Feat'].upper()
   fout.write('\n [FEAT:'+key+']\n')
   fout.write('  [NAME:'+feat['Name'] + ']\n')
   fout.write('  [DESCRIPTION:'+feat['Description']+']\n')
   fout.write('  [GROUP:'+feat['Group']+']\n')
   fout.write('  [LEVEL:'+feat['Level']+']\n')
   for s in feat['R Classes'].split('\n'):
    fout.write('  [REQUIRED_CLASS:'+s+']\n')
   for s in feat['R Feats'].split('\n'):
    fout.write('  [REQUIRED_FEAT:'+s+']\n')
   for s in feat['F Classes'].split('\n'):
    fout.write('  [FORBIDDEN_CLASS:'+s+']\n')
   for s in feat['F Feats'].split('\n'):
    fout.write('  [FORBIDDEN_FEAT:'+s+']\n')
   fout.write('  [COST:'+feat['Cost']+']\n')
   fout.write('  [EFFECT:'+feat['Effect']+']\n')
   for s in feat['Scripts'].split('\n'):
    fout.write('  [SCRIPT:'+s+']\n')

   # Inorganic file
   inout.write('  [SYNDROME]\n')
   inout.write('   [SYN_NAME:'+key+']\n')
   inout.write('   [SYN_CLASS:FEAT]\n')
   inout.write('   [CE_SPEED_CHANGE:START:0:SPEED_ADD:1]\n')

  for sheet in self.featSheets:
   files[sheet].close()
  inout.close()

  return

 def writeSpells(self):
  print('Number of Spells: '+str(len(self.spells)))
  ## Inorganic File
  inout = open('inorganic_syndromes_spells.txt','w')
  inout.write('inorganic_syndromes_spells\n')
  inout.write('\n[OBJECT:INORGANIC]\n')
  inout.write('\n [INORGANIC:SYSTEM_CLASS_SPELLS]\n')
  inout.write('  [USE_MATERIAL_TEMPLATE:SYSTEM_SYNDROMES]\n')
  ## Spell Files
  files = {}
  for sheet in self.spellSheets:
   files[sheet] = open('spells_'+sheet.lower()+'.txt','w')
   files[sheet].write('spells_'+sheet.lower()+'\n')
   files[sheet].write('\n[OBJECT:SPELL]\n')
  ## Interaction Files
  ifiles = {}
  for sheet in self.spellSheets:
   ifiles[sheet] = open('interaction_spells_'+sheet.lower()+'.txt','w')
   ifiles[sheet].write('interaction_spells_'+sheet.lower()+'\n')
   ifiles[sheet].write('\n[OBJECT:INTERACTION]\n')

  ## Loop through spells
  for i in range(len(self.spells)):
   spell = self.spells[i]
   fout = files[spell['Sheet']]
   teout = ifiles[spell['Sheet']]
   key = spell['Spell'].upper()
 
   ## Spell File Write
   fout.write('\n [SPELL:SPELL_'+key+']\n')
   fout.write('  [NAME:'+spell['Name'] + ']\n')
   fout.write('  [DESCRIPTION:'+spell['Description']+']\n')
   if i == 0: fout.write('\n  #These tags handle the classification of the spell\n')
   fout.write('  [SPHERE:'+spell['Sphere']+']\n')
   fout.write('  [SCHOOL:'+spell['School']+']\n')
   fout.write('  [DISCIPLINE:'+spell['Discipline']+']\n')
   fout.write('  [SUBDISCIPLINE:'+spell['Sub-Discipline']+']\n')
   if i == 0: fout.write('\n  #These tags define the requirements for learning the spell\n')
   fout.write('  [LEVEL:'+spell['Lvl']+']\n')
   for s in spell['Req Attribute'].split('\n'):
    fout.write('  [REQUIREMENT_ATTRIBUTE:'+s+']\n')
   for s in spell['F Class'].split('\n'):
    fout.write('  [FORBIDDEN_CLASS:'+s+']\n')
   for s in spell['F Spell'].split('\n'):
    fout.write('  [FORBIDDEN_SPELL:'+s+']\n')
   fout.write('  [COST:'+spell['Cost']+']\n')
   if spell['Upgrade'] != '': fout.write('  [UPGRADE:'+spell['Upgrade']+']\n')
   fout.write('  [EFFECT:'+spell['Effect']+']\n')
   if i == 0: fout.write('\n  #These tags alter the casting values in some way\n')
   if spell['Resist'] == 'T': fout.write('  [RESISTABLE]\n')
   if spell['Crit'] == 'T': fout.write('  [CAN_CRIT]\n')
   fout.write('  [HIT_MODIFIER:'+spell['Hit Mod']+']\n')
   fout.write('  [HIT_MODIFIER_PERC:'+spell['Hit Mpe']+']\n')
   fout.write('  [PENETRATION:'+spell['Pen']+']\n')
   fout.write('  [EXHAUSTION:'+spell['Exh']+']\n')
   fout.write('  [CAST_TIME:'+spell['Time']+']\n')
   fout.write('  [EXP_GAIN:'+spell['ExpGain']+']\n')
   fout.write('  [SKILL_GAIN:'+spell['SklGain']+']\n')
   if i == 0: fout.write('\n  #These tags are used if an equation needs to be calculated for a spells effect\n')
   fout.write('  [SOURCE_PRIMARY_ATTRIBUTES:'+':'.join(spell['Source Primary'].split('\n'))+']\n')
   fout.write('  [SOURCE_SECONDARY_ATTRIBUTES:'+':'.join(spell['Source Secondary'].split('\n'))+']\n')
   fout.write('  [TARGET_PRIMARY_ATTRIBUTES:'+':'.join(spell['Target Primary'].split('\n'))+']\n')
   fout.write('  [TARGET_SECONDARY_ATTRIBUTES:'+':'.join(spell['Target Secondary'].split('\n'))+']\n')
   fout.write('  [EQUATION:'+spell['Equation']+']\n')
   if i == 0: fout.write('\n  #This is the script that will be called via modtools/interaction-trigger\n')
   fout.write('  [TRIGGER_SCRIPT:'+spell['Wrapper']+']\n')
   if i == 0: fout.write('\n  #This(ese) is(are) the script(s) that will be called by the TRIGGER_SCRIPT script\n')
   for s in spell['Spell Script'].split('\n'):
    fout.write('  [SCRIPT:'+s+']\n')
   if i == 0: fout.write('\n  #This is the announcement that will be posted in the reports on successful completion of the spell\n')
   fout.write('  [ANNOUNCEMENT:'+spell['Announcement']+']\n')
 
   ## Inorganic File Write
   inout.write('  [SYNDROME]\n')
   inout.write('   [SYN_NAME:'+key+']\n')
   inout.write('   [CE_CAN_DO_INTERACTION:START:0]\n')
   inout.write('    [CDI:ADV_NAME:'+spell['Name']+']\n')
   inout.write('    [CDI:INTERACTION:'+key+']\n')
   inout.write('    [CDI:TARGET:A:LINE_OF_SIGHT]\n')
   inout.write('    [CDI:TARGET_RANGE:A:'+spell['Range']+']\n')
   inout.write('    [CDI:WAIT_PERIOD:'+spell['Wait']+']\n')
 
   ## Interaction File Write
   teout.write('\n [INTERACTION:'+key+']\n')
   teout.write('  [I_SOURCE:CREATURE_ACTION]\n')
   teout.write('  [I_TARGET:A:CREATURE]\n')
   teout.write('   [IT_LOCATION:CONTEXT_CREATURE]\n')
   teout.write('  [I_EFFECT:ADD_SYNDROME]\n')
   teout.write('   [IE_TARGET:A]\n')
   teout.write('   [IE_IMMEDIATE]\n')
   teout.write('   [SYNDROME]\n')
   teout.write('    [CE_SPEED_CHANGE:START:0:END:1:SPEED_ADD:1]\n')

  for sheet in self.spellSheets:
   files[sheet].close()
   ifiles[sheet].close()
  inout.close()

  return

class CivilizationSystem:
 def __init__(self):
  civilizationSheets = racesOutside + racesBrimir + racesAlfar + racesCorrupt + racesElder + racesGuild
  entitySheets = racesOutside + racesBrimir + racesAlfar + racesCorrupt + racesElder + racesGuild
  self.civs = readSheets('Civilizations.ods',civilizationSheets)
  self.entities = readSheets('Entities.ods',entitySheets)
  print('\nCivilization System')
  self.writeCivs()
  self.writeEntities()

 def writeCivs(self):
  civilizations = {}
  for i in range(len(self.civs)):
   key = self.civs[i]['ID']
   lvl = int(self.civs[i]['Level'])
   if list(civilizations.keys()).count(key) == 0: civilizations[key] = {}
   civilizations[key][lvl] = self.civs[i]
  print('Number of Civilizations: '+str(len(civilizations)))
  return

 def writeEntities(self):
  entities = {}
  for i in range(len(self.entities)):
   key = self.entities[i]['ID']
   lvl = int(self.entities[i]['Level'])
   if list(entities.keys()).count(key) == 0: entities[key] = {}
   entities[key][lvl] = self.entities[i]
  print('Number of Entities: '+str(len(entities)))
  return

class EventSystem:
 def __init__(self):
  eventSheets = ['Random','Diplomatic','Power','Story']
  self.events = readSheets('Events.ods',eventSheets)
  print('\nEvent System')
  self.writeEvents()

 def writeEvents(self):
  print('Number of Events: '+str(len(self.events)))
  return

class EnhancedSystem:
 def __init__(self):
  self.buildingSheets  = racesOutside + racesBrimir + racesAlfar + racesCorrupt + ['Shared','Basic']
  self.creatureSheets  = ['Mundane','Magical','Fantasy','SemiMB','Megabeast','Races']
  self.itemSheets      = ['Ammo','Weapons','Armor','Clothes','Tools','Misc']
  self.inorganicSheets = ['Gems','Stones','Ores','Metals','Soils']
  self.plantSheets     = ['Crops','Trees','Grass','Magical']
  self.materialSheets  = ['Creature','Plant','Inorganic','Magical','Misc']
  self.reactionSheets  = racesOutside + racesBrimir + racesAlfar + racesCorrupt + racesElder + racesGuild + ['Shared','Basic']
  #self.buildings = readSheets('Buildings.ods',self.buildingSheets)
  #self.creatures = readSheets('Creatures.ods',self.creatureSheets)
  self.items     = readSheets('Items.ods',self.itemSheets)
  #self.inorganics = readSheets('Inorganics.ods',self.inorganicSheets)
  #self.plants     = readSheets('Plants.ods',self.plantSheets)
  #self.reactions = readSheets('Reactions.ods',self.reactionSheets)
  print('\nEnhanced Sytem')
  #self.writeBuildings()
  #self.writeCreatures()
  #self.writeInorganics()
  self.writeItems()
  #self.writePlants()
  #self.writeReactions()

 def writeBuildings(self):
  print('Number of Buildings Total: '+str(len(self.buildings)))
  files = {}
  for sheet in self.buildingSheets:
   files[sheet] = open('buildings_'+sheet.lower()+'.txt','w')
   files[sheet].write('buildings_'+sheet.lower()+'\n')
   files[sheet].write('\n[OBJECT:BUILDING]\n')

  ebn = 0
  for i in range(len(self.buildings)):
   bldg = self.buildings[i]
   fout = files[bldg['Sheet']]
   key = bldg['Race'] + '_' + bldg['Industry'] + '_' + bldg['Sub-Industry'] + '_' + bldg['Level']

   # Building Information
   fout.write('\n [BUILDING_WORKSHOP:'+key+']\n')
   fout.write('  [NAME:'+bldg['Name'] + ']\n')
   fout.write('  [NAME_COLOR:'+bldg['Color']+']\n')
   fout.write('  [DIM:'+bldg['Size']+']\n')
   fout.write('  [WORK_LOCATION:'+bldg['Work Loc']+']\n')
   fout.write('  [BUILD_LABOR:'+bldg['Labor']+']\n')
   if bldg['Key'] != '': fout.write('  [BUILD_KEY:'+bldg['Key']+']\n')
   if bldg['Blocks'] != '':
    for s in bldg['Blocks'].split('\n'):
     fout.write('  [BLOCK:'+s+']\n')
   if bldg['Tile:0'] != '':
    for s in bldg['Tile:0'].split('\n'):
     fout.write('  [TILE:0:'+s+']\n')
   if bldg['Color:0'] != '':
    for s in bldg['Color:0'].split('\n'):
     fout.write('  [COLOR:0:'+s+']\n')
   if bldg['Tile:1'] != '':
    for s in bldg['Tile:1'].split('\n'):
     fout.write('  [TILE:1:'+s+']\n')
   if bldg['Color:1'] != '':
    for s in bldg['Color:1'].split('\n'):
     fout.write('  [COLOR:1:'+s+']\n')
   if bldg['Tile:2'] != '':
    for s in bldg['Tile:2'].split('\n'):
     fout.write('  [TILE:2:'+s+']\n')
   if bldg['Color:2'] != '':
    for s in bldg['Color:2'].split('\n'):
     fout.write('  [COLOR:2:'+s+']\n')
   if bldg['Tile:3'] != '':
    for s in bldg['Tile:3'].split('\n'):
     fout.write('  [TILE:3:'+s+']\n')
   if bldg['Color:3'] != '':
    for s in bldg['Color:3'].split('\n'):
     fout.write('  [COLOR:3:'+s+']\n')
   if bldg['Building Items']:
    for s in bldg['Building Items'].split('\n'):
     fout.write('  '+s+'\n')
 
   # Enhanced Building Information
   if bldg['Description'] != '':
    ebn += 1
    fout.write('\n  #Enhanced Building Entries\n')
    writeEnhancedInormation(fout,bldg)

  print('Number of Enhanced Buildings: '+str(ebn))
  for sheet in self.buildingSheets:
   files[sheet].close()
  return

 def writeCreatures(self):
  print('Number of Creatures Total: '+str(len(self.creatures)))
  print('Number of Enhanced Creatures: ')
  return

 def writeInorganics(self):
  print('Number of Inorganics Total: '+str(len(self.inorganics)))
  print('Number of Enhanced Materials: '+str(len(self.materials)))
  return

 def writeItems(self):
  print('Number of Items Total: '+str(len(self.items)))
  files = {}
  types = {}
  ein = 0
  for i in range(len(self.items)):
   item = self.items[i]
   cat = item['Category']
   typ = item['Type']
   cls = item['Class']
   sheet = item['Sheet']
   key = cat + '_' + cls
   if list(types.keys()).count(key) != 0:
    types[key] += 1
   else:
    types[key] = 1
    files[key] = open('items_'+key.lower()+'.txt','w')
    files[key].write('items_'+key.lower()+'\n')
    files[key].write('\n[OBJECT:ITEM]\n')
   fout = files[key]
   fout.write('\n [ITEM_'+typ+':'+item['Item']+']\n')
   if item.get('Name','') != '':        fout.write('  [NAME:'+item['Name']+']\n')
   if item.get('PrePlural','') != '':   fout.write('  [PREPLURAL:'+item['PrePlural']+']\n')
   if item.get('PlaceHolder','') != '': fout.write('  [MATERIAL_PLACEHOLDER:'+item['PlaceHolder']+']\n')
   if item.get('Adjective','') != '':   fout.write('  [ADJECTIVE:'+item['Adjective']+']\n')
   if item.get('Tile','') != '':        fout.write('  [TILE:'+item['Tile']+']\n')
   if item.get('Value','') != '':       fout.write('  [VALUE:'+item['Value']+']\n')
   if item.get('Class','') != '':       fout.write('  [CLASS:'+item['Class']+']\n')
   if item.get('Level','') != '':       fout.write('  [LEVEL:'+item['Level']+']\n')
   if item.get('Use','') != '':         fout.write('  [TOOL_USE:'+item['Use']+']\n')
   if item.get('Capacity','') != '':    fout.write('  [CONTAINER_CAPACITY:'+item['Capacity']+']\n')
   if item.get('Improvement' != '':     fout.write('  [DEFAULT_IMPROVEMENT:'+item['Improvement']+']\n')
   if item.get('Size','') != '':        fout.write('  [SIZE:'+item['Size']+']\n')
   if item.get('MatSize','') != '':     fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
   if item.get('UBStep','') != '':      fout.write('  [UBSTEP:'+item['UBStep']+']\n')
   if item.get('LBStep','') != '':      fout.write('  [LBSTEP:'+item['LBStep']+']\n')
   if item.get('Layer','') != '':       fout.write('  [LAYER:'+item['Layer']+']\n')
   if item.get('LayerSize','') != '':   fout.write('  [LAYER_SIZE:'+item['LayerSize']+']\n')
   if item.get('LayerPermit','') != '': fout.write('  [LAYER_PERMIT:'+item['LayerPermit']+']\n')
   if item.get('Coverage','') != '':    fout.write('  [COVERAGE:'+item['Coverage']+']\n')
   if item.get('2HSize','') != '':      fout.write('  [TWO_HANDED:'+item['2HSize']+']\n')
   if item.get('MinSize','') != '':     fout.write('  [MINIMUM_SIZE:'+item['MinSize']+']\n')
   if item.get('Skill','') != '':       fout.write('  [SKILL:'+item['Skill']+']\n')
   if item.get('Ranged','') != '':      fout.write('  [RANGED:'+item['Ranged']+']\n')
   if item.get('ShotForce','') != '':   fout.write('  [SHOOT_FORCE:'+item['ShotForce']+']\n')
   if item.get('ShotVel','') != '':     fout.write('  [SHOOT_MAXVEL:'+item['ShotVel']+']\n')
   if item.get('ArmorLevel','') != '':  fout.write('  [ARMORLEVEL:'+item['ArmorLevel']+']\n')
   if item.get('BlockChance','') != '': fout.write('  [BLOCKCHANCE:'+item['BlockChance']+']\n')
   if item.get('UPStep','') != '':      fout.write('  [UPSTEP:'+item['UPStep']+']\n')
   if item.get('Flags','') != '':
    for s in item['Flags'].split('\n'):
     fout.write('  ['+s+']\n')
   if item.get('MatFlags','') != '':
    for s in item['MatFlags'].split('\n'):
     fout.write('  ['+s+']\n')
   if item.get('ElasticityFlags','') != '':
    for s in item['ElasticityFlags'].split('\n'):
     fout.write('  ['+s+']\n')
   if item.get('Hits','') != '': fout.write('  [HITS:'+item['Hits']+']\n')
   for j in range(1,11):
    if item.get('Attack:'+str(j),'') != '':
     for s in item['Attack:'+str(j)].split('\n'):
      fout.write('  ['+s+']\n')

   # Enhanced Item Information
   if item['Description'] == '': continue
    ein += 1
    fout.write('\n  # Enhanced Item Information\n')
    writeEnhancedInformation(fout,item)

  print('Number of Enhanced Items: '+str(ein))
  for key in list(files.keys()):
   files[key].close()
  return

 def writePlants(self):
  print('Number of Plants Total: '+str(len(self.plants)))
  files = {}
  for sheet in self.plantSheets:
   files[sheet] = open('plants_'+sheet.lower()+'.txt','w')
   files[sheet].write('plants_'+sheet.lower()+'\n')
   files[sheet].write('\n[OBJECT:PLANT]\n')

  epn = 0
  for i in range(len(self.plants)):
   plant = plants[i]
   fout = files[plant['Sheet']]
   fout.write('\n [PLANT:'+plant['Token']+']\n')
   if plant['Names'] != '':
    for s in plant['Names'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['Tiles'] != '':
    for s in plant['Tiles'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['Colors'] != '':
    for s in plant['Colors'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['Prefstring'] != '': fout.write('  [PREFSTRING:'+plant['Prefstring']+']\n')
   if plant['Alt Period'] != '': fout.write('  [ALT_PERIOD:'+plant['Alt Period']+']\n')
   if plant['Value'] != '': fout.write('  [VALUE:'+plant['Value']+']\n')
   if plant['Frequency'] != '': fout.write('  [FREQUENCY:'+plant['Frequency']+']\n')
   if plant['Clustersize'] != '': fout.write('  [CLUSTERSIZE:'+plant['Clustersize']+']\n')
   if plant['Growdur'] != '': fout.write('  [GROWDUR:'+plant['Growdur']+']\n')
   if plant['Season'] != '':
    for s in plant['Season'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['GrowFlags'] != '':
    for s in plant['GrowFlags'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['Biome'] != '':
    for s in plant['Biome'].split('\n'):
     fout.write('  [BIOME:'+s+']\n')
   if plant['Depth'] != '': fout.write('  [UNDERGROUND_DEPTH:'+plant['Depth']+']\n')
   if plant['Flags'] != '':
    for s in plant['Flags'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['Trunk'] != '':
    for s in plant['Trunk'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['Branch'] != '':
    for s in plant['Branch'].split('\n'):
     fout.write('  ['+s+']\n')
   if plant['Root'] != '':
    for s in plant['Root'].split('\n'):
     fout.write('  ['+s+']\n')
   for j in range(1,6):
    if plant['Template:'+str(j)] != '':
     for s in plant['Template:'+str(j)].split('\n'):
      if s.count('USE_MATERIAL') != 0:
       fout.write('  ['+s+']\n')
      else:
       fout.write('   ['+s+']\n')
   for j in range(1,5):
    if plant['Growth:'+str(j)] != '':
     for s in plant['Growth:'+str(j)].split('\n'):
      if s.count('GROWTH:') != 0:
       fout.write('  ['+s+']\n')
      else:
       fout.write('   ['+s+']\n')
   if plant['Products'] != '':
    for s in plant['Products'].split('\n'):
     fout.write('  ['+s+']\n')

   # Enhanced Item Information
   if plant['Description'] != '':
    epn += 1
    fout.write('\n  # Enhanced Plant Information\n')
    writeEnhancedInformation(fout,plant)

  print('Number of Enhanced Plants: '+str(epn))
  return

 def writeReactions(self):
  print('Number of Reactions Total: '+str(len(self.reactions)))
  print('Number of Enhanced Reactions: ')
  return

#ClassSystem()
#CivilizationSystem()
#EventSystem()
EnhancedSystem()
