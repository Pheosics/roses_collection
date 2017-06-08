import os
import fnmatch
import csv
########
numTypes    = ['FREQUENCY','CLUSTERSIZE','VALUE','GROWDUR','ALT_PERIOD']
nameTypes   = ['NAME','NAME_PLURAL','ADJ','PREFSTRING','ALL_NAMES']
seasonTypes = ['SUMMER','AUTUMN','SPRING','WINTER','GOOD','EVIL','SAVAGE','WET','DRY']
prodTypes   = ['BASIC_MAT','SEED','TREE','DRINK','MILL','THREAD','EXTRACT_BARREL','EXTRACT_VIAL','EXTRACT_STILL_VIAL']
tileTypes   = ['PICKED_TILE','SHRUB_TILE','DEAD_SHRUB_TILE','TREE_TILE','GRASS_TILES','ALT_GRASS_TILES']
colorTypes  = ['PICKED_COLOR','SHRUB_COLOR','DEAD_SHRUB_COLOR','GRASS_COLORS']
branchTypes = ['HEAVY_BRANCH_DENSITY','BRANCH_DENSITY','HEAVY_BRANCH_RADIUS','BRANCH_RADIUS']
trunkTypes  = ['TRUNK_PERIOD','MAX_TRUNK_HEIGHT','MAX_TRUNK_DIAMETER','TRUNK_WIDTH_PERIOD','TRUNK_BRANCHING']
rootTypes   = ['ROOT_DENSITY','ROOT_RADIUS']
tokenTypes  = ['STANDARD_TILE_NAMES','SAPLING','GRASS']
miscTypes   = ['UNDERGROUND_DEPTH']
#########
dualTokens  = ['GROWTH','USE_MATERIAL_TEMPLATE']
boolTokens  = seasonTypes + tokenTypes
inputTokens = numTypes + nameTypes + prodTypes + tileTypes + colorTypes + branchTypes + trunkTypes + rootTypes + miscTypes
multiTokens = ['BIOME']
#########
tokenGroups = {'TRUNK': ['a',trunkTypes], 'BRANCH': ['a',branchTypes], 'ROOT': ['a',rootTypes], 'TOKENS': ['b',tokenTypes]}
#########
rawOrder = nameTypes + numTypes + tileTypes + colorTypes + seasonTypes + ['BIOME'] + miscTypes + ['TRUNK','BRANCH','ROOT','TOKENS','USE_MATERIAL_TEMPLATE','GROWTH'] + prodTypes
mweOrder = nameTypes + numTypes + tileTypes + colorTypes + seasonTypes + ['BIOME'] + miscTypes + prodTypes + ['TRUNK','BRANCH','ROOT','TOKENS'] # + dualTokens
#########
fileTypes = ['TREE','GRASS','CROP']

class plants:
 def getRAW(self,dir):
  files = []
  for file in os.listdir(dir):
   if fnmatch.fnmatch(file, 'plant*.txt'):
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
    if totdat[j][i].partition(':')[0] == '[PLANT':
     d.append([totdat[j][i].partition(':')[2].partition(']')[0], i])
   dd = []
   for i in range(len(d)-1):
    dd.append([d[i][0], d[i][1], d[i+1][1]])
   dd.append([d[-1][0], d[-1][1], len(totdat[j])])
   ddtot[j] = dd

  rawData = {}
  maxval = {}
  for x in dualTokens:
   maxval[x] = 0
  for j in range(len(ddtot)):
   for entry in ddtot[j]:
    rawData[entry[0]] = {}
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
    if rawData[entry[0]].keys().count('GRASS'):
     rawData[entry[0]]['TYPE'] = 'GRASS'
    elif rawData[entry[0]].keys().count('SAPLING'):
     rawData[entry[0]]['TYPE'] = 'TREE'
    else:
     rawData[entry[0]]['TYPE'] = 'CROP'
  rawData['numbers'] = {}
  for x in dualTokens:
   rawData['numbers'][x] = maxval[x]
  self.rawData = rawData

 def getMWE(self,dir):
  csvfile = open('plants.csv')
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

   mweData[row[1]] = {}
   data = mweData[row[1]]
   data['TYPE'] = row[0]

   i = 2
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
   files[x] = open('plant_'+x.lower()+'_MWE.txt','w')
   files[x].write('plant_'+x.lower()+'_MWE\n')
   files[x].write('\n[OBJECT:PLANT]\n')

  for entry in data:
   if entry == 'numbers': continue
   output = data[entry]
   rawFile = files[output['TYPE']]

   rawFile.write('\n[PLANT:'+entry+']\n')
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
  csvfile = open('plants.csv','w')
  writer  = csv.writer(csvfile)

  header = ['BASE','TYPE']
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
