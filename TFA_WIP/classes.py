import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Classes*.csv'):
  files.append(dirs+'/'+fname)

for fname in files:
 classes = []
 index = -1
 csvfile = open(fname)
 reader = csv.reader(csvfile)
 for row in reader:
  if row[0] == 'Category':
   header = row
   continue
  classes.append({})
  index += 1
  for c in range(len(header)):
   classes[index][header[c]] = row[c]
 csvfile.close()

 # Finished reading the file, now create output
 t = fname.split('Classes')[1].split('csv')[0]
 oname = 'Classes'+t+'txt'
 fout = open(oname.lower(),'w')
 fout.write(oname.lower()+'\n')
 fout.write('\n[OBJECT:CLASS]\n')
 for i in range(len(classes)):
  clss = classes[i]
  key = clss['Category'] + '_' + clss['Sphere'] + '_' + clss['School'] + '_' + clss['Name'].upper()
  fout.write('\n [CLASS:'+key+']\n')
  fout.write('  [NAME:'+clss['Name'] + ']\n')
  fout.write('  [DESCRIPTION:'+clss['Description']+']\n')
  fout.write('  [SPHERE:'+clss['Sphere']+']\n')
  fout.write('  [SCHOOL:'+clss['School']+']\n')
  fout.write('  [DISCIPLINE:'+clss['Discipline']+']\n')
  fout.write('  [SUBDISCIPLINE:'+clss['Sub Discipline']+']\n')
  fout.write('  [LEVELS:'+clss['Levels']+']\n')
  for s in clss['R Classes'].split('\n'):
   fout.write('  [REQUIREMENT_CLASS:'+s+']\n')
  for s in clss['R Attributes'].split('\n'):
   fout.write('  [REQUIREMENT_ATTRIBUTE:'+s+']\n')
  for s in clss['R Skills'].split('\n'):
   fout.write('  [REQUIREMENT_SKILL:'+s+']\n')
  for s in clss['R Stats'].split('\n'):
   fout.write('  [REQUIREMENT_Stat:'+s+']\n')
  for s in clss['F Classes'].split('\n'):
   fout.write('  [FORBIDDEN_CLASS:'+s+']\n')
  for s in clss['B Attributes'].split('\n'):
   fout.write('  [BONUS_ATTRIBUTE:'+s+']\n')
  for s in clss['B Resistances'].split('\n'):
   fout.write('  [BONUS_RESISTANCE:'+s+']\n')
  for s in clss['B Skills'].split('\n'):
   fout.write('  [BONUS_SKILL:'+s+']\n')
  for s in clss['B Stats'].split('\n'):
   fout.write('  [BONUS_STAT:'+s+']\n')
  for s in clss['B Traits'].split('\n'):
   fout.write('  [BONUS_TRAIT:'+s+']\n')
  for s in clss['LB Attributes'].split('\n'):
   fout.write('  [LEVELING_BONUS:ATTRIBUTE:'+s+']\n')
  for s in clss['LB Resistances'].split('\n'):
   fout.write('  [LEVELING_BONUS:RESISTANCE:'+s+']\n')
  for s in clss['LB Skills'].split('\n'):
   fout.write('  [LEVELING:BONUS:SKILL:'+s+']\n')
  for s in clss['LB Stats'].split('\n'):
   fout.write('  [LEVELING_BONUS:STAT:'+s+']\n')
  for s in clss['LB Traits'].split('\n'):
   fout.write('  [LEVELING_BONUS:TRAIT:'+s+']\n')
  for s in clss['Spells'].split('\n'):
   fout.write('  [SPELL:'+s+']\n')
 fout.close()
