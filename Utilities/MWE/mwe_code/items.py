import os
import fnmatch
import csv
import re
#########
numTypes    = ['VALUE','SIZE','MATERIAL_SIZE','LEVEL']
nameTypes   = ['NAME','PREPLURAL','ADJECTIVE','CLASS']
armorTypes  = ['ARMORLEVEL','UBSTEP','LBSTEP','UPSTEP','COVERAGE','BLOCKCHANCE']
toolTypes   = ['TOOL_USE','TILE','CONTAINER_CAPACITY','DEFAULT_IMPROVEMENT']
trapTypes   = ['HITS']
matTypes    = ['SHAPED','HARD','METAL','LEATHER','SOFT','SCALED','BARRED','METAL_MAT','HARD_MAT',
               'METAL_WEAPON_MAT','WOOD_MAT','SHEET_MAT','STONE_MAT','CAN_STONE']
weaponTypes = ['SKILL','TWO_HANDED','MINIMUM_SIZE','RANGED','SHOOT_FORCE','SHOOT_MAXVEL']
tokenTypes  = ['METAL_ARMOR_LEVELS','CHAIN_METAL_TEXT','INCOMPLETE_ITEM','UNIMPROVABLE','NO_DEFAULT_JOB',
               'NO_DEFAULT_IMPROVEMENTS','IS_SCREW','IS_SPIKE','TRAINING']
elastTypes  = ['STRUCTURAL_ELASTICITY_CHAIN_ALL','STRUCTURAL_ELASTICITY_WOVEN_THREAD','STRUCTURAL_ELASTICITY_CHAIN_METAL']
layerTypes  = ['LAYER','LAYER_SIZE','LAYER_PERMIT']
#########
dualTokens  = ['ATTACK']
boolTokens  = matTypes + tokenTypes + elastTypes
inputTokens = nameTypes + numTypes + armorTypes + layerTypes + weaponTypes + toolTypes + trapTypes
multiTokens = []
#########
tokenGroups = {'MATS': ['b',matTypes], 'TOKENS': ['b',tokenTypes], 'ELASTICITY': ['b',elastTypes]}
#########
rawOrder = nameTypes + numTypes + armorTypes + layerTypes + weaponTypes + trapTypes + toolTypes + ['ELASTICITY','TOKENS','MATS','ATTACK']
mweOrder = nameTypes + numTypes + armorTypes + layerTypes + weaponTypes + trapTypes + toolTypes + ['ELASTICITY','TOKENS','MATS'] # + dualTokens
#########
fileTypes   = ['AMMO','ARMOR','PANTS','HELM','SHOES','WEAPON','TOOL','FOOD','TOY','TRAPCOMP','GLOVES','SIEGEAMMO','SHIELD']

class items:
 def getRAW(self,dir):
  files = []
  for file in os.listdir(dir):
   if fnmatch.fnmatch(file, 'item*.txt'):
    files.append(dir+file)

  totdat = [[]]*len(files)
  for i in range(len(files)):
   f = open(files[i])
   dat = []
   for row in f:
    dat.append(row)
   totdat[i] = dat
  f.close

  ddtot = [[]]*len(totdat)
  for j in range(len(totdat)):
   d = []
   for i in range(len(totdat[j])):
    if re.match('\[ITEM_.',totdat[j][i].partition(':')[0]):
     d.append([totdat[j][i].partition(':')[2].partition(']')[0], i,totdat[j][i].partition(':')[0]])
   dd = []
   for i in range(len(d)-1):
    dd.append([d[i][0], d[i][1], d[i+1][1], d[i][2]])
   dd.append([d[-1][0], d[-1][1], len(totdat[j]), d[-1][2]])
   ddtot[j] = dd

  rawData = {}
  maxval = {}
  for x in dualTokens:
   maxval[x] = 0
  for j in range(len(ddtot)):
   for entry in ddtot[j]:
    rawData[entry[0]] = {}
    rawData[entry[0]]['TYPE'] = entry[3].strip().split('_')[1]
    numbers = {}
    flags = {}
    for x in multiTokens:
     rawData[entry[0]][x] = []
    for x in dualTokens:
     numbers[x] = 0
     flags[x] = False
    for i in range(entry[1]+1,entry[2]):
     line = totdat[j][i]
     line = line.strip()
     lines = line.split('[')
     for k in range(1,len(lines)):
      nkeys = len(rawData[entry[0]].keys())
      check = lines[k].split(']')[0]
      aCheck = check.partition(':')
      if boolTokens.count(aCheck[0]):
       rawData[entry[0]][aCheck[0]] = 'Y'
       for y in dualTokens: flags[y] = False
      elif inputTokens.count(aCheck[0]):
       rawData[entry[0]][aCheck[0]] = aCheck[2]
       for y in dualTokens: flags[y] = False
      elif multiTokens.count(aCheck[0]):
       rawData[entry[0]][aCheck[0]].append(aCheck[2])
       for y in dualTokens: flags[y] = False
      elif dualTokens.count(aCheck[0]):
       for y in dualTokens: flags[y] = False
       flags[aCheck[0]] = True
       numbers[aCheck[0]] += 1
       rawData[entry[0]][aCheck[0]+'_'+str(numbers[aCheck[0]])] = [check]
      else: 
       for x in dualTokens:
        if flags[x]:
         rawData[entry[0]][x+'_'+str(numbers[x])].append(check)
    rawData[entry[0]]['numbers'] = {}
    for x in dualTokens:
     rawData[entry[0]]['numbers'][x] = numbers[x]
     if numbers[x] > maxval[x]: maxval[x] = numbers[x]
  rawData['numbers'] = {}
  for x in dualTokens:
   rawData['numbers'][x] = maxval[x]
  self.rawData = rawData

 def getMWE(self,dir):
  csvfile = open('items.csv')
  reader = csv.reader(csvfile)
  mweData = {}
  maxval = {}
  numbers = {}
  dualList = []
  for row in reader:
   if row[0] == 'BASE':
    for x in dualTokens:
     maxval[x] = row.count(x)
     numbers[x] = 0
     dualList = dualList + [x]*maxval[x]
     columns = mweOrder + dualList
    continue

   mweData[row[2]] = {}
   data = mweData[row[2]]
   data['TYPE'] = row[0]

   i = 3
   for c in columns:
    if dualTokens.count(c) == 1:
     if row[i] != '':
      numbers[c] += 1
      key = c + '_' + str(numbers[c])
      data[key] = row[i].split('\n')
    elif boolTokens.count(c) == 1:
      if row[i] != '': data[c] = row[i]
    elif inputTokens.count(c) == 1:
      if row[i] != '': data[c] = row[i]
    elif multiTokens.count(c) == 1:
      if row[i] != '': data[c] = row[i].split('\n')
    elif tokenGroups.keys().count(c) == 1:
     for x in tokenGroups[c][1]:
      if tokenGroups[c][0] == 'a':
       if row[i] != '':
        for line in row[i].split('\n'):
         part = line.partition('\n')
         data[part[0]] = part[2]
      elif tokenGroups[c][0] == 'b':
       if row[i] != '':
        for line in row[i].split('\n'):
         data[line] = 'Y'
    i += 1
   data['numbers'] = {}
   for x in dualTokens:
    data['numbers'][x] = numbers[x]
    numbers[x] = 0
  self.mweData = mweData
  csvfile.close()

 def writeRAW(self,data):
  files = {}
  for x in fileTypes:
   files[x] = open('item_'+x.lower()+'_MWE.txt','w')
   files[x].write('item_'+x.lower()+'\n')
   files[x].write('\n[OBJECT:ITEM]\n')

  for entry in data:
   if entry == 'numbers': continue
   output = data[entry]
   rawFile = files[output['TYPE']]

   rawFile.write('\n[ITEM_'+output['TYPE']+':'+entry+']\n')
   for c in rawOrder:
    if dualTokens.count(c) == 1:
     for i in range(1,output['numbers'][c]+1):
      key = c + '_' + str(i)
      if output.keys().count(key) == 1:
       rawFile.write('\t['+output[key][0]+']\n')
       for j in range(1,len(output[key])):
        rawFile.write('\t\t['+output[key][j]+']\n')
    elif boolTokens.count(c) == 1:
     if output.keys().count(c) == 1 and output[c] == 'Y': rawFile.write('\t['+c+']\n')
    elif inputTokens.count(c) == 1:
     if output.keys().count(c) == 1: rawFile.write('\t['+c+':'+output[c]+']\n')
    elif multiTokens.count(c) == 1:
     if output.keys().count(c) == 1: 
      for line in output[c]: 
       rawFile.write('\t['+c+':'+line+']\n')
    elif tokenGroups.keys().count(c) == 1:
     for x in tokenGroups[c][1]:
      if tokenGroups[c][0] == 'a':
       if output.keys().count(x) == 1: rawFile.write('\t['+x+':'+output[x]+']\n')
      elif tokenGroups[c][0] == 'b':
       if output.keys().count(x) == 1 and output[x] == 'Y': rawFile.write('\t['+x+']\n')
  for x in fileTypes:
   files[x].close()

 def writeMWE(self,data):
  csvfile = open('items.csv','w')
  writer  = csv.writer(csvfile)

  header = ['BASE','TYPE','SUBTYPE']
  dualList = []
  for x in dualTokens:
   dualList = dualList + [x]*data['numbers'][x]
  header = header + mweOrder + dualList
  columns = mweOrder + dualList

  writer.writerow(header)
  for entry in data.keys():
   row = []
   output = data[entry]
   numbers = {}
   for x in dualTokens:
    numbers[x] = 0
   if entry != 'numbers':
    row = row + [output['TYPE']]
    row = row + [output['TYPE']]
    row = row + [entry]

    for c in columns:
     line = ''
     if dualTokens.count(c) == 1:
      numbers[c] += 1
      key = c + '_' + str(numbers[c])
      if output.keys().count(key) == 1: line = '\n'.join(output[key])
     elif boolTokens.count(c) == 1:
      if output.keys().count(c) == 1: line = 'Y'
     elif inputTokens.count(c) == 1:
      if output.keys().count(c) == 1: line = output[c]
     elif multiTokens.count(c) == 1:
      if output.keys().count(c) == 1: line = '\n'.join(output[c])
     elif tokenGroups.keys().count(c) == 1:
      for x in tokenGroups[c][1]:
       if tokenGroups[c][0] == 'a':
        if output.keys().count(x) == 1: line = line + x + ':' + output[x] + '\n'
       elif tokenGroups[c][0] == 'b':
        if output.keys().count(x) == 1: line = line + x + '\n'
     row = row + [line.rstrip()]

    writer.writerow(row)
  csvfile.close()
