import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Abilities*.csv'):
  files.append(dirs+'/'+fname)

## Inorganic File
inout = open('inorganic_syndromes_abilities.txt','w')
inout.write('inorganic_syndromes_abilities\n')
inout.write('\n[OBJECT:INORGANIC]\n')
inout.write('\n [INORGANIC:SYSTEM_CLASS_ABILITIES]\n')
inout.write('  [USE_MATERIAL_TEMPLATE:SYSTEM_SYNDROMES]\n')

for fname in files:
 spells = []
 index = -1
 csvfile = open(fname)
 reader = csv.reader(csvfile)
 for row in reader:
  if row[0] == 'Category':
   header = row
   continue
  spells.append({})
  index += 1
  for c in range(len(header)):
   spells[index][header[c]] = row[c]
 csvfile.close()

 # Finished reading the file, now create output
 t = fname.split('Abilities')[1].split('csv')[0]

 ## Interaction File Open
 teout = open('interaction_abilities'+t.lower()+'.txt','w')
 teout.write('interaction_abilities'+t.lower()+'\n')
 teout.write('\n[OBJECT:INTERACTION]\n')

 ## Ability File Open
 oname = 'Spells'+t+'txt'
 fout = open(oname.lower(),'w')
 fout.write(oname.lower()+'\n')
 fout.write('\n[OBJECT:SPELL]\n')
 for i in range(len(-1,spells)):
  if i == -1:
   fout.write('\n SPELL:EXAMPLE_SPELL\n')
   fout.write('  NAME:Example\n')
   fout.write('  DESCRIPTION:A description of the spell can go here for use in the Journal gui\n')
   fout.write('\n  #These tags handle the classification of the spell\n')
   fout.write('  SPHERE:SPHERE_TOKEN\n')
   fout.write('  SCHOOL:SCHOOL_TOKEN\n')
   fout.write('  DISCIPLINE:DISCIPLINE_TOKEN\n')
   fout.write('  SUBDISCIPLINE:SUBDISCIPLINE_TOKEN\n')
   fout.write('\n  #These tags define the requirements for learning the spell\n')
   fout.write('  LEVEL:#\n')
   fout.write('  REQUIREMENT_ATTRIBUTE:ATTRIBUTE_TOKEN:#\n')
   fout.write('  FORBIDDEN_CLASS:CLASS_TOKEN:#\n')
   fout.write('  FORBIDDEN_SPELL:SPELL_TOKEN\n')
   fout.write('  COST:#\n')
   fout.write('  UPGRADE:SPELL_TOKEN\n')
   fout.write('  EFFECT:A short description of the effect of the spell can go here\n')
   fout.write('\n  #These tags alter the casting values in some way\n')
   fout.write('  RESISTABLE\n')
   fout.write('  CAN_CRIT\n')
   fout.write('  HIT_MODIFIER:#\n')
   fout.write('  HIT_MODIFIER_PERC:#\n')
   fout.write('  PENETRATION:#\n')
   fout.write('  EXHAUSTION:#\n')
   fout.write('  CAST_TIME:#\n')
   fout.write('  EXP_GAIN:#\n')
   fout.write('  SKILL_GAIN:SKILL_TOKEN:#\n')
   fout.write('\n  #These tags are used if an equation needs to be calculated for a spells effect\n')
   fout.write('  SOURCE_PRIMARY_ATTRIBUTES:ATTRIBUTE_TOKEN\n')
   fout.write('  SOURCE_SECONDARY_ATTRIBUTES:ATTRIBUTE_TOKEN\n')
   fout.write('  TARGET_PRIMARY_ATTRIBUTES:ATTRIBUTE_TOKEN\n')
   fout.write('  TARGET_SECONDARY_ATTRIBUTES:ATTRIBUTE_TOKEN\n')
   fout.write('  EQUATION:EQUATION_TOKEN\n')
   fout.write('\n  #This is the script that will be called via modtools/interaction-trigger\n')
   fout.write('  TRIGGER_SCRIPT:The wrapper script that you want to be called to check targets goes here\n')
   fout.write('\n  #This(ese) is(are) the script(s) that will be called by the TRIGGER_SCRIPT script\n')
   fout.write('  SCRIPT:The actual script that you want the spell to call goes here, can have multiple\n')
   fout.write('\n  #This is the announcement that will be posted in the reports on successful completion of the spell\n')
   fout.write('  ANNOUNCEMENT:An anouncement string you want posted in the report logs\n')
   continue

  spell = spells[i]
  key = spell['Spell'].upper()

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

  ## Ability File Write
  fout.write('\n [SPELL:SPELL_'+key+']\n')
  fout.write('  [NAME:'+spell['Name'] + ']\n')
  fout.write('  [DESCRIPTION:'+spell['Description']+']\n')
  fout.write('  [SPHERE:'+spell['Sphere']+']\n')
  fout.write('  [SCHOOL:'+spell['School']+']\n')
  fout.write('  [DISCIPLINE:'+spell['Discipline']+']\n')
  fout.write('  [SUBDISCIPLINE:'+spell['Sub-Discipline']+']\n')
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
  if spell['Resist'] == 'T': fout.write('  [RESISTABLE]\n')
  if spell['Crit'] == 'T': fout.write('  [CAN_CRIT]\n')
  fout.write('  [HIT_MODIFIER:'+spell['Hit Mod']+']\n')
  fout.write('  [HIT_MODIFIER_PERC:'+spell['Hit Mpe']+']\n')
  fout.write('  [PENETRATION:'+spell['Pen']+']\n')
  fout.write('  [EXHAUSTION:'+spell['Exh']+']\n')
  fout.write('  [CAST_TIME:'+spell['Time']+']\n')
  fout.write('  [EXP_GAIN:'+spell['ExpGain']+']\n')
  fout.write('  [SKILL_GAIN:'+spell['SklGain']+']\n')
  fout.write('  [SOURCE_PRIMARY_ATTRIBUTES:'+':'.join(spell['Source Primary'].split('\n'))+']\n')
  fout.write('  [SOURCE_SECONDARY_ATTRIBUTES:'+':'.join(spell['Source Secondary'].split('\n'))+']\n')
  fout.write('  [TARGET_PRIMARY_ATTRIBUTES:'+':'.join(spell['Target Primary'].split('\n'))+']\n')
  fout.write('  [TARGET_SECONDARY_ATTRIBUTES:'+':'.join(spell['Target Secondary'].split('\n'))+']\n')
  fout.write('  [TRIGGER_SCRIPT:'+spell['Wrapper']+']\n')
  for s in spell['Spell Script'].split('\n'):
   fout.write('  [SCRIPT:'+s+']\n')
  fout.write('  [EQUATION:'+spell['Equation']+']\n')
  fout.write('  [ANNOUNCEMENT:'+spell['Announcement']+']\n')
 fout.close()
 teout.close()
inout.close()
