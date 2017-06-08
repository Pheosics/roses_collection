import os
import fnmatch
import csv
########
itemTypes   = ['ITEMS_HARD','ITEMS_BARRED','ITEMS_SCALED','ITEMS_METAL','ITEMS_WEAPON','ITEMS_WEAPON_RANGED','ITEMS_AMMO',
               'ITEMS_DIGGER','ITEMS_ARMOR','ITEMS_ANVIL','ITEMS_SOFT']
numTypes    = ['IMPACT','COMPRESSIVE','TENSILE','TORSION','SHEAR','BENDING']
numSubTypes = ['_YIELD','_FRACTURE','_STRAIN_AT_YIELD','_ELASTICITY']
numCombined = []
for x in numTypes:
 for a in numSubTypes:
  numCombined.append(x+a)
locTypes    = ['SEDIMENTARY','AQUIFER','SEDIMENTARY_OCEAN_SHALLOW','IGNEOUS_INTRUSIVE','IGNEOUS_EXTRUSIVE',
              'METAMORPHIC','SOIL','SOIL_SAND','SOIL_OCEAN','DEEP_SURFACE','DEEP_SPECIAL','SPECIAL','SEDIMENTARY_OCEAN_DEEP',
              'LAVA']
pointTypes  = ['MELTING_POINT','BOILING_POINT','IGNITE_POINT','HEATDAM_POINT','COLDDAM_POINT']
stateTypes  = ['STATE_NAME','STATE_NAME_ADJ','STATE_ADJ','STATE_COLOR']
stateSubTs  = ['ALL','ALL_SOLID','LIQUID','GAS','SOLID','SOLID_POWDER']
stateCombd  = []
for x in stateTypes:
 for a in stateSubTs:
  stateCombd.append(x+':'+a)
nameTypes   = ['BLOCK_NAME','STONE_NAME','IS_GEM','THREAD_METAL']
tokTypes    = ['IS_STONE','IS_CERAMIC','STOCKPILE_THREAD_METAL','NO_STONE_STOCKPILE','DISPLAY_UNGLAZED','CRYSTAL_GLASSABLE',
              'LIQUID_MISC_OTHER','UNDIGGABLE','WAFERS']
colorTypes  = ['BASIC_COLOR','BUILD_COLOR','DISPLAY_COLOR']
miscTypes   = ['TILE','ITEM_SYMBOL','MATERIAL_VALUE','SOLID_DENSITY','LIQUID_DENSITY','MOLAR_MASS','SPEC_HEAT','MAT_FIXED_TEMP']
lastTypes   = ['ABSORPTION','MAX_EDGE','HARDENS_WITH_WATER']
########
multiTokens = ['MATERIAL_REACTION_PRODUCT','REACTION_CLASS','METAL_ORE','ENVIRONMENT','ENVIRONMENT_SPEC'] + stateTypes
dualTokens  = ['SYNDROME']
boolTokens  = tokTypes + locTypes + itemTypes
inputTokens = ['USE_MATERIAL_TEMPLATE'] + numCombined + pointTypes + nameTypes + colorTypes + miscTypes + lastTypes
########
tokenGroups = {'TOKENS': ['b',tokTypes], 'LOCATION': ['b',locTypes]}
########
rawOrder = ['USE_MATERIAL_TEMPLATE'] + stateTypes + nameTypes + colorTypes + ['LOCATION','ENVIRONMENT','ENVIRONMENT_SPEC','METAL_ORE']
rawOrder = rawOrder + miscTypes + pointTypes + numCombined + itemTypes + lastTypes + ['TOKENS','REACTION_CLASS','MATERIAL_REACTION_PRODUCT']
mweOrder = ['USE_MATERIAL_TEMPLATE'] + stateTypes + nameTypes + colorTypes + ['LOCATION'] + miscTypes + pointTypes + numCombined + itemTypes + ['TOKENS'] + multiTokens
########
fileTypes = ['METAL','ORE','SOIL','STONE','GEM']

class inorganics:
 def getRAW(self,dir):
  files = []
  for file in os.listdir(dir):
   if fnmatch.fnmatch(file, 'inorganic*.txt'):
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
    if totdat[j][i].partition(':')[0] == '[INORGANIC':
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
    if rawData[entry[0]].keys().count('SOIL') or rawData[entry[0]].keys().count('SOIL_SAND') or rawData[entry[0]].keys().count('SOIL_OCEAN'):
     rawData[entry[0]]['TYPE'] = 'SOIL'
    elif len(rawData[entry[0]]['METAL_ORE']) > 0 or rawData[entry[0]].keys().count('THREAD_METAL'):
     rawData[entry[0]]['TYPE'] = 'ORE'
    elif rawData[entry[0]].keys().count('IS_GEM'):
     rawData[entry[0]]['TYPE'] = 'GEM'
    elif rawData[entry[0]].keys().count('IS_STONE'):
     rawData[entry[0]]['TYPE'] = 'STONE'
    else:
     rawData[entry[0]]['TYPE'] = 'METAL'
  rawData['numbers'] = {}
  for x in dualTokens:
   rawData['numbers'][x] = maxval[x]
  self.rawData = rawData

 def getMWE(self,dir):
  csvfile = open('inorganics.csv')
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
   files[x] = open('inorganic_'+x.lower()+'_MWE.txt','w')
   files[x].write('inorganic_'+x.lower()+'_MWE\n')
   files[x].write('\n[OBJECT:PLANT]\n')

  for entry in data:
   if entry == 'numbers': continue
   output = data[entry]
   rawFile = files[output['TYPE']]

   rawFile.write('\n[INORGANIC:'+entry+']\n')
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
  csvfile = open('inorganics.csv','w')
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
