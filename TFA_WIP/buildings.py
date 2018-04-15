import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Buildings*.csv'):
  files.append(dirs+'/'+fname)

for fname in files:
 buildings = []
 index = -1
 csvfile = open(fname)
 reader = csv.reader(csvfile)
 for row in reader:
  if row[0] == 'Category':
   header = row
   continue
  buildings.append({})
  index += 1
  for c in range(len(header)):
   buildings[index][header[c]] = row[c]
 csvfile.close()

 # Finished reading the file, now create output
 ## Class File
 t = fname.split('Buildings')[1].split('.csv')[0]
 oname = 'building'+t+'.txt'
 fout = open(oname.lower(),'w')
 fout.write(oname.lower()+'\n')
 fout.write('\n[OBJECT:BUILDING]\n')
 efile = open('Ebuildings'+t+'.txt','w')
 efile.write('Ebuildings'+t+'\n')
 efile.write('\n[OBJECT:ENHANCED_BUILDING]\n')

 ## Loop over all classes
 for i in range(len(buildings)):
  # Building file
  bldg = buildings[i]
  key = bldg['Race'] + '_' + bldg['Industry'] + '_' + bldg['Sub-Industry'] + '_' + bldg['Level']
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

  # Enhanced Building File
  efile.write('\n [BUILDING:'+key+']\n')
  efile.write('  [NAME:'+bldg['Name'] + ']\n')
  efile.write('  [DESCRIPTION:'+bldg['Description']+']\n')
  efile.write('  [STAGES:'+bldg['Stages']+']\n')
  if bldg['OutIn'] == 'Outside':
   efile.write('  [OUTSIDE_ONLY]\n')
  elif bldg['OutIn'] == 'Inside':
   efile.write('  [INSIDE_ONLY]\n')
  if bldg['Stories'] != '': efile.write('  [MULTI_STORY:'+bldg['Stories']+']\n')
  if bldg['Amount'] != '': efile.write('  [MAX_AMOUNT:'+bldg['Amount']+']\n')
  if bldg['Water'] != '': efile.write('  [REQUIRED_WATER:'+bldg['Water']+']\n')
  if bldg['Magma'] != '': efile.write('  [REQUIRED_MAGMA:'+bldg['Magma']+']\n')
  if bldg['Required'] != '': efile.write('  [REQUIRED_BUILDING:'+bldg['Required']+']\n')
  if bldg['Forbidden'] != '': efile.write('  [FORBIDDEN_BUILDING:'+bldg['Forbidden']+']\n')
  if bldg['Script'] != '':
   for s in bldg['Script'].split('\n'):
    fout.write('  [Script:'+s+']\n')

 fout.close()
 efile.close()
