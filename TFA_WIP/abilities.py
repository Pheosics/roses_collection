import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Abilities*.csv'):
  files.append(dirs+'/'+fname)

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
 oname = 'Spells'+t+'txt'
 fout = open(oname.lower(),'w')
 fout.write(oname.lower()+'\n')
 fout.write('\n[OBJECT:SPELL]\n')
 for i in range(len(spells)):
  spell = spells[i]
  key = spell['Category'] + '_' + spell['Sphere'] + '_' + spell['School'] + '_' + spell['Spell']
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
