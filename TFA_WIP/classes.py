import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Classes*.csv'):
  files.append(dirs+'/'+fname)

## Inorganic File
inout = open('inorganic_syndromes_classes.txt','w')
inout.write('inorganic_syndromes_classes\n')
inout.write('\n[OBJECT:INORGANIC]\n')
inout.write('\n [INORGANIC:SYSTEM_CLASS_NAMES]\n')
inout.write('  [USE_MATERIAL_TEMPLATE:SYSTEM_SYNDROMES]\n')

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
 ## Class File
 t = fname.split('Classes')[1].split('csv')[0]
 oname = 'Classes'+t+'txt'
 fout = open(oname.lower(),'w')
 fout.write(oname.lower()+'\n')
 fout.write('\n[OBJECT:CLASS]\n')

 ## Loop over all classes
 for i in range(-1,len(classes)):
  if i == -1:
   fout.write('\n CLASS:EXAMPLE_CLASS\n')
   fout.write('  NAME:Class Name\n')
   fout.write('  DESCRIPTION:A description of the class can go here, used for the Journal gui\n')
   fout.write('\n  These tags handle the classification of a class\n')
   fout.write('  SPHERE:SPHERE_TOKEN\n')
   fout.write('  SCHOOL:SCHOOL_TOKEN\n')
   fout.write('  DISCIPLINE:DISCIPLINE_TOKEN\n')
   fout.write('  SUBDISCIPLINE:SUBDISCIPLINE_TOKEN\n')
   fout.write('\n  #This is the number of levels the class has, effects later tags\n')
   fout.write('  LEVELS:#\n')
   fout.write('\n  #This is the amount of experience each level takes, it must have the same number of numbers as the levels\n')
   fout.write('  EXP:#:#...')
   fout.write('\n  #These tags represent the requirements to become the class\n')
   fout.write('  REQUIREMENT_CLASS:CLASS_TOKEN:#\n')
   fout.write('  REQUIREMENT_ATTRIBUTE:ATTRIBUTE_TOKEN:#\n')
   fout.write('  REQUIREMENT_SKILL:SKILL_TOKEN:#\n')
   fout.write('  REQUIREMENT_STAT:STAT_TOKEN:#\n')
   fout.write('  FORBIDDEN_CLASS:CLASS_TOKEN:#\n')
   fout.write('\n  #These tags are the bonuses a unit gets for reaching a certain level in a class, they are lost when the unit changes classes\n')
   fout.write('  BONUS_ATTRIBUTE:ATTRIBUTE_TOKEN:#:#...\n')
   fout.write('  BONUS_RESISTANCE:RESISTANCE_TOKEN:#:#...\n')
   fout.write('  BONUS_SKILL:SKILL_TOKEN:#:#...\n')
   fout.write('  BONUS_STAT:STAT_TOKEN:#:#...\n')
   fout.write('  BONUS_TRAIT:TRAIT_TOKEN:#:#...\n')
   fout.write('\n  #These tags are the bonuses a unit gets when leveling up in a certain class, these are permanent and are kept when changing classes\n')
   fout.write('  LEVELING_BONUS:ATTRIBUTE:ATTRIBUTE_TOKEN:#:#...\n')
   fout.write('  LEVELING_BONUS:RESISTANCE:RESISTANCE_TOKEN:#:#...\n')
   fout.write('  LEVELING:BONUS:SKILL:SKILL_TOKEN:#:#...\n')
   fout.write('  LEVELING_BONUS:STAT:STAT_TOKEN:#:#...\n')
   fout.write('  LEVELING_BONUS:TRAIT:TRAIT_TOKEN:#:#...\n')
   fout.write('\n  #The spells the class can learn go here, there can be as many as you want\n')
   fout.write('  SPELL:SPELL_TOKEN:#\n')
   continue

  # Class file
  clss = classes[i]
  key = clss['Class'].upper()
  fout.write('\n [CLASS:'+key+']\n')
  fout.write('  [NAME:'+clss['Name'] + ']\n')
  fout.write('  [DESCRIPTION:'+clss['Description']+']\n')
  fout.write('  [SPHERE:'+clss['Sphere']+']\n')
  fout.write('  [SCHOOL:'+clss['School']+']\n')
  fout.write('  [DISCIPLINE:'+clss['Discipline']+']\n')
  fout.write('  [SUBDISCIPLINE:'+clss['Sub Discipline']+']\n')
  fout.write('  [LEVELS:'+clss['Levels']+']\n')
  fout.write('  [EXP:'+clss['Experience']+']\n')
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

  # Inorganic file
  inout.write('  [SYNDROME]\n')
  inout.write('   [SYN_NAME:'+key+']\n')
  inout.write('   [SYN_CLASS:CLASS_NAME]\n')
  inout.write('   [CE_DISPLAY_NAME:START:0:NAME:'+clss['Name']+':'+clss['Names']+':'+clss['Adj']+']\n')  
 fout.close()
inout.close()


