import os
import fnmatch
import csv
########
# INPUT TYPES
baseSTypes   = ['DESCRIPTION','NAME','GENERAL_BABY_NAME','BABYNAME','GENERAL_CHILD_NAME','CHILD_NAME',
               'COLOR','GLOWCOLOR','CREATURE_TILE','CREATURE_SOLDIER_TILE','SOLDIER_ALTTILE','ALTTILE','GLOWTILE',
               'MAXAGE','BABY','CHILD','POPULATION_NUMBER','CLUSTER_NUMBER','FREQUENCY','POP_RATIO','UNDERGROUND_DEPTH']
casteSTypes  = ['CASTE_NAME','CASTE_COLOR','CASTE_TILE','CASTE_ALTTILE','CASTE_GLOWTILE','CASTE_SOLDIER_TILE','CASTE_SOLDIER_ALTTILE',
               'CASTE_SPEECH','LITTERSIZE','SPEECH_FEMALE','SPEECH_MALE','CLUTCH_SIZE','EGG_SIZE','LAYS_UNUSUAL_EGGS']
verminSTypes = ['VERMIN_BITE','PENETRATE_POWER']
prodSTypes   = ['EXTRACT','EGG_MATERIAL','HIVE_PRODUCT','MILKABLE','WEBBER']
bodySTypes   = ['BODY','TENDONS','LIGAMENTS','BLOOD','PUS','RETRACT_INTO_BP','HOMEOTHERM','FIXED_TEMP','GENERAL_MATERIAL_FORCE_MULTIPLIER',
                'GRAVITATE_BODY_SIZE','REMAINS']
dietSTypes   = ['GOBBLE_VERMIN_CLASS','GOBBLE_VERMIN_CREATURE','GNAWER','GRAZER']
petSTypes    = ['PETVALUE','PETVALUE_DIVISOR','TRADE_CAPACITY']
senseSTypes  = ['SMELL_TRIGGER','LOW_LIGHT_VISION','ODOR_LEVEL','ORDER_STRING','VIEWRANGE','VISION_ARC']
sklSTypes    = ['SKILL_RATES','SKILL_LEARN_RATES','SKILL_RUST_RATES']
miscSTypes   = ['BEACH_FREQUENCY','BUILDINGDESTROYER','DIFFICULTY','GRASSTRAMPLE','PRONE_TO_RAGE','TIRGGERABLE_GROUP']
infoSTypes   = ['PREFSTRING','SPEECH','GNAWER','LAIR','LAIR_CHARACTERISTIC','LAIR_HUNTER_SPEECH']

#######
# BOOL TYPES
casteTTypes  = ['MALE','FEMALE','MULTIPLE_LITTER_RARE']
activeTypes  = ['ALL_ACTIVE','DIURNAL','CREPUSCULAR','MATUTINAL','NOCTURNAL','VESPERTINE','NO_AUTUMN','NO_SPRING','NO_SUMMER','NO_WINTER']
immuneTypes  = ['NO_DIZZINESS','NO_DRINK','NO_EAT','NO_FEVERS','NO_SLEEP','NOBREATH','NOEMOTION','NOEXERT','NOFEAR','NONAUSEA',
                'NOPAIN','NOSTUN','NOT_LIVING','NOTHOUGHT','PARALYZEIMMUNE','WEBIMMUNE','FIREIMMUNE','FIREIMMUNE_SUPER','TRAPAVOID']
verminTTypes = ['VERMIN_EATER','VERMIN_FISH','VERMIN_GROUNDER','VERMIN_HATEABLE','VERMIN_MICRO','VERMIN_NOFISH','VERMIN_NOROAM','VERMIN_NOTRAP',
                'VERMIN_ROTTER','VERMIN_SOIL','VERMIN_SOIL_COLONY','VERMINHUNTER','RETURNS_VERMIN_KILLS_TO_OWNER','REMAINS_ON_VERMIN_BITE_DEATH',
                'HUNTS_VERMIN','DIVE_HUNTS_VERMIN','DIE_WHEN_VERMIN_BITE','COLONY_EXTERNAL','ARTIFICIAL_HIVEABLE']
nightTTypes  = ['SPOUSE_CONVERSION_TARGET','BLOODSUCKER','CONVERTED_SPOUSE','SPOUSE_CONVERTER','NIGHT_CREATURE_BOGEYMAN','NIGHT_CREATURE_HUNTER']
genTTypes    = ['DEMON','GENERATED','UNIQUE_DEMON','TITAN','FEATURE_ATTACK_GROUP','FEATURE_BEAST']
petTTypes    = ['PET','PET_EXOTIC','MOUNT','MOUNT_EXOTIC','TRAINABLE','TRAINABLE_HUNTING','TRAINABLE_WAR','EQUIPMENT_WAGON','PACK_ANIMAL',
                'WAGON_PULLER','ADOPTS_OWNER','COMMON_DOMESTIC']
moveTTypes   = ['CANNOT_CLIMB','CANNOT_JUMP','FLIER','IMMOBILE','IMMOBILE_LAND','PATTERNFLIER','STANCE_CLIMBER','UNDERSWIM','SWIMS_LEARNED',
                'SWIMS_INNATE','NO_VEGETATION_PERTURB','NO_CONNECTIONS_FOR_MOVEMENT']
dietTTypes   = ['ALCOHOL_DEPENDENT','BONECARN','CARNIVORE','STANDARD_GRAZER']
typeTTypes   = ['ARENA_RESTRICTED','EVIL','GOOD','SAVAGE','FANCIFUL','MUNDANE','NATURAL','NATURAL_ANIMAL','POWER','SUPERNATURAL','UBIQUITOUS',
                'MEGABEAST','SEMIMEGABEAST','DOES_NOT_EXIST','LAIR_HUNTER']
intTTypes    = ['INTELLIGENT','STRANGE_MOODS','TRANCES','CANOPENDOORS','EQUIPS','CAN_LEARN','CAN_SPEAK','LOCKPICKER','NO_THOUGHT_CENTER_FOR_MOVEMENT',
                'SLOW_LEARNER','LISP','UTTERANCES']
senseTTypes  = ['EXTRAVISION','MAGMA_VISION','MULTIPART_FULL_VISION']
prodTTypes   = ['COOKABLE_LIVE','FISHITEM','HASSHELL','LAYS_EGGS','PEARL','THICKWEB','SMALL_REMAINS']
behavTTypes  = ['AT_PEACE_WITH_WILDLIFE','BENIGN','CRAZED','LARGE_PREDATOR','LARGE_ROAMING','LIKES_FIGHTING','LOOSE_CLUSTERS','MEANDERER','ROOT_AROUND',
                'OPPOSED_TO_LIFE','FLEEQUICK','MISCHIEVIOUS','MISCHIEVOUS','CURIOUSBEAST_EASTER','CURIOUSBEAST_GUZZLER','CURIOUSBEAST_ITEM','AMBUSHPREDATOR']
habttTTypes  = ['CAVE_ADAPT','AMPHIBIOUS','AQUATIC']
tokenTypes   = ['CANNOT_UNDEAD','IMMOLATE','LIGHT_GEN','NO_GENDER','NO_UNIT_TYPE_COLOR','REMAINS_UNDETERMINED','VEGETATION']
cntrlTypes   = ['LOCAL_POPS_CONTROLLABLE','LOCAL_POPS_PRODUCT_HEROES','OUTSIDER_CONTROLLABLE']
bodyTTypes   = ['GETS_WOUND_INFECTIONS','GETS_INFECTIONS_FROM_ROT','HAS_NERVES','NOBONES','NOMEAT','NOSKIN','NOSKULL','NOSMELLYROT',
                'NOSTUCKINS','NOT_BUTCHERABLE']
sklTTypes    = ['NO_PHYS_ATT_GAIN','NO_PHYS_ATT_RUST']

#######
# MULTI TYPES
baseMTypes  = ['BODY_SIZE','BIOME','CREATURE_CLASS','ORIENTATION']
moveMTypes  = ['GAIT']
dietMTypes  = ['SPECIFIC_FOOD']
typeMTypes  = ['SPHERE']
intMTypes   = ['PERSONALITY','PROFESSION_NAME','SOUND']
senseMTypes = ['SENSE_CREATURE_CLASS']
bodyMTypes  = ['BODYGLOSS','BODY_DETAIL_PLAN','TISSUE_LAYER','RELSIZE','BP_ADD_TYPE','SECRETION','SYNDROME_DILUTION_FACTOR','MATERIAL_FORCE_MULTIPLIER']
attMTypes   = ['PHYS_ATT_RANGE','PHYS_ATT_RATES','PHYS_ATT_CAP_PERC','MENT_ATT_RANGE','MENT_ATT_RATES','MENT_ATT_CAP_PERC']
sklMTypes   = ['NATURAL_SKILL','SKILL_RATE','SKILL_LEARN_RATE','SKILL_RUST_RATE']

#######
# DUAL TYPES
bodyDTypes = ['SELECT_TISSUE_LAYER','BODY_APPEARANCE_MODIFIER','SET_BP_GROUP','SET_TL_GROUP','EXTRA_BUTCHER_OBJECT','ITEMCORPSE','USE_MATERIAL',
              'USE_MATERIAL_TEMPLATE','MATERIAL','SELECT_MATERIAL','USE_TISSUE','USE_TISSUE_TEMPLATE','TISSUE']
dualTypes  = ['CAN_DO_INTERACTION','ATTACK','APPLY_CREATURE_VARIATION','HABIT_NUM']

########
wtf = ['USE_CASTE','GO_TO_END','GO_TO_START','GO_TO_TAG']
########
multiTokens = baseMTypes + moveMTypes + dietMTypes + typeMTypes + intMTypes + senseMTypes + bodyMTypes + attMTypes + sklMTypes
dualTokens  = bodyDTypes + dualTypes
boolTokens  = (casteTTypes + activeTypes + immuneTypes + verminTTypes + nightTTypes + genTTypes + petTTypes + moveTTypes + dietTTypes + typeTTypes + intTTypes +
               senseTTypes + prodTTypes + behavTTypes + habttTTypes + tokenTypes + cntrlTypes + bodyTTypes + sklTTypes)
inputTokens = baseSTypes + casteSTypes + verminSTypes + prodSTypes + bodySTypes + dietSTypes + petSTypes + senseSTypes + sklSTypes + miscSTypes + infoSTypes
########
tokenGroups = {'ACTIVE': ['b',activeTypes], 'MOVEMENT': ['b',moveTTypes], 'BASIC': ['b',typeTTypes], 'BEHAVIOR': ['b',behavTTypes], 'BODYTOKENS': ['b',bodyTTypes],
               'VERMIN': ['b',verminTTypes], 'NIGHT': ['b',nightTTypes], 'IMMUNE': ['b',immuneTypes], 'GENERATED': ['b',genTTypes], 'PETTOKENS': ['b',petTTypes],
               'DIETTOKENS': ['b',dietTTypes], 'INTELLECT': ['b',intTTypes], 'SENSES': ['b',senseTTypes],'PRODUCTION': ['b',prodTTypes],'HABITAT': ['b',habttTTypes],
               'SKILLTOKENS': ['b',sklTTypes], 'CONTROL': ['b',cntrlTypes], 'TOKENS': ['b',tokenTypes]}
tokenOrder = ['ACTIVE','MOVEMENT','BASIC','BEHAVIOR','BODYTOKENS','VERMIN','NIGHT','IMMUNE','GENERATED','PETTOKENS','DIETTOKENS','INTELLECT','SENSES','PRODUCTION',
              'HABITAT','SKILLTOKENS','CONTROL','TOKENS']
########
rawOrder = []
mweOrder = inputTokens + casteTTypes + tokenOrder + multiTokens # + dualTokens
########
fileTypes = ['ALL']

class creatures:
 def getRAW(self,dir):
  files = []
  for file in os.listdir(dir):
   if fnmatch.fnmatch(file, 'creature*.txt'):
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
    if totdat[j][i].partition(':')[0] == '[CREATURE':
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
    creatureData = rawData[entry[0]]
    rawData[entry[0]]['ALL'] = {}
    numbers = {}
    flags = {}
    numbers['ALL'] = {}
    flags['ALL'] = {}
    castes = ['ALL']
    for x in multiTokens:
     creatureData['ALL'][x] = []
    for x in dualTokens:
     numbers['ALL'][x] = 0
     flags['ALL'][x] = False
    for i in range(entry[1]+1,entry[2]):
     line = totdat[j][i]
     line = line.strip()
     lines = line.split('[')
     for k in range(1,len(lines)):
      check = lines[k].split(']')[0]
      aCheck = check.partition(':')
### Check if applied to creature or caste
      if aCheck[0] == 'CASTE' or aCheck[0] == 'SELECT_CASTE':
       castes = [aCheck[2]]
       if not creatureData.keys().count(aCheck[2]):
        rawData[entry[0]][aCheck[2]] = {}
        numbers[aCheck[2]] = {}
        flags[aCheck[2]] = {}
        for x in multiTokens:
         rawData[entry[0]][aCheck[2]][x] = []
        for x in dualTokens:
         numbers[aCheck[2]][x] = 0
         flags[aCheck[2]][x] = False
       continue
### Any additional castes?
      if aCheck[0] == 'SELECT_ADDITIONAL_CASTE':
       castes.append(aCheck[2])
       if not creatureData.keys().count(aCheck[2]):
        rawData[entry[0]][aCheck[2]] = {}
        numbers[aCheck[2]] = {}
        flags[aCheck[2]] = {}
        for x in multiTokens:
         rawData[entry[0]][aCheck[2]][x] = []
        for x in dualTokens:
         numbers[aCheck[2]][x] = 0
         flags[aCheck[2]][x] = False
       continue
### Checks
      for caste in castes:
       casteData = creatureData[caste]
       numData = numbers[caste]
       flgData = flags[caste]
       if boolTokens.count(aCheck[0]):
        casteData[aCheck[0]] = 'Y'
        for y in dualTokens: flgData[y] = False
       elif inputTokens.count(aCheck[0]):
        casteData[aCheck[0]] = aCheck[2]
        for y in dualTokens: flgData[y] = False
       elif multiTokens.count(aCheck[0]):
        casteData[aCheck[0]].append(aCheck[2])
        for y in dualTokens: flgData[y] = False
       elif dualTokens.count(aCheck[0]):
        for y in dualTokens: flgData[y] = False
        flgData[aCheck[0]] = True
        numData[aCheck[0]] += 1
        casteData[aCheck[0]+'_'+str(numData[aCheck[0]])] = [check]
       else:
        for x in dualTokens:
         if flgData[x]:
          casteData[x+'_'+str(numData[x])].append(check)
    rawData[entry[0]]['numbers'] = {}
    for x in dualTokens:
     rawData[entry[0]]['numbers'][x] = numbers['ALL'][x]
     if numbers['ALL'][x] > maxval[x]: maxval[x] = numbers['ALL'][x]
    if True:
     rawData[entry[0]]['TYPE'] = 'ALL'
  rawData['numbers'] = {}
  for x in dualTokens:
   rawData['numbers'][x] = maxval[x]
  self.rawData = rawData

 def getMWE(self,dir):
  csvfile = open('creatures.csv')
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
   files[x] = open('creature_'+x.lower()+'_MWE.txt','w')
   files[x].write('creature_'+x.lower()+'_MWE\n')
   files[x].write('\n[OBJECT:CREATURE]\n')

  for entry in data:
   if entry == 'numbers': continue
   output = data[entry]
   rawFile = files[output['TYPE']]

   rawFile.write('\n[CREATURE:'+entry+']\n')
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
  csvfile = open('creatures.csv','w')
  writer  = csv.writer(csvfile)

  header = ['BASE','TYPE','SUBTYPE']
  dualList = []
  for x in dualTokens:
   dualList = dualList + [x]*data['numbers'][x]
  header = header + mweOrder + dualList
  columns = mweOrder + dualList

  writer.writerow(header)
  for entry in data.keys():
   base = data[entry]
   numbers = {}
   for x in dualTokens:
    numbers[x] = 0
   if entry != 'numbers':
    for caste in base.keys():
     if caste == 'TYPE' or caste == 'numbers': continue
     row = []
     row = row + [base['TYPE']]
     row = row + [entry]
     row = row + [caste]
     output = base[caste]
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
