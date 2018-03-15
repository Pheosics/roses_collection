import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Feats*.csv'):
  files.append(dirs+'/'+fname)

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
 for i in range(len(feats)):
  feat = feats[i]
  key = feat['Category'] + '_' + feat['Group'] + '_' + feat['Feat']
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
 fout.close()
