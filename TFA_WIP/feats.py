import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Feats*.csv'):
  files.append(dirs+'/'+fname)

## Inorganic File
inout = open('inorganic_syndromes_feats.txt','w')
inout.write('inorganic_syndromes_feats\n')
inout.write('\n[OBJECT:INORGANIC]\n')
inout.write('\n [INORGANIC:SYSTEM_CLASS_FEATS]\n')
inout.write('  [USE_MATERIAL_TEMPLATE:SYSTEM_SYNDROMES]\n')

for fname in files:
 feats = []
 index = -1
 csvfile = open(fname)
 reader = csv.reader(csvfile)
 for row in reader:
  if row[0] == 'Category':
   header = row
   continue
  feats.append({})
  index += 1
  for c in range(len(header)):
   feats[index][header[c]] = row[c]
 csvfile.close()

 # Finished reading the file, now create output
 t = fname.split('Feats')[1].split('csv')[0]
 oname = 'Feats'+t+'txt'
 fout = open(oname.lower(),'w')
 fout.write(oname.lower()+'\n')
 fout.write('\n[OBJECT:FEAT]\n')
 for i in range(-1,len(feats)):
  if i == -1:
   fout.write('\n FEAT:EXAMPLE_FEAT\n')
   fout.write('  NAME:Feat Name\n')
   fout.write('  DESCRIPTION:A description of the feat can go here, used in the Journal gui\n')
   fout.write('  GROUP:GROUP_TOKEN\n')
   fout.write('  LEVEL:#\n')
   fout.write('  REQUIRED_CLASS:CLASS_TOKEN\n')
   fout.write('  REQUIRED_FEAT:FEAT_TOKEN\n')
   fout.write('  FORBIDDEN_CLASS:CLASS_TOKEN\n')
   fout.write('  FORBIDDEN_FEAT:FEAT_TOKEN\n')
   fout.write('  COST:#\n')
   fout.write('  SCRIPT:The script that is run when the feat is gained\n')
   continue

  feat = feats[i]
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

 fout.close()
inout.close()
