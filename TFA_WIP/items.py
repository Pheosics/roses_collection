import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Items*.csv'):
  files.append(dirs+'/'+fname)

items = []
index = -1
for fname in files:
 csvfile = open(fname)
 reader = csv.reader(csvfile)
 for row in reader:
  if row[0] == 'Category':
   header = row
   continue
  items.append({})
  index += 1
  for c in range(len(header)):
   items[index][header[c]] = row[c]
 csvfile.close()

# First find all the different Types
types = {}
files = {}
for i in range(len(items)):
 key = items[i]['Category'] + '_' + items[i]['Type']
 if types.has_key(key):
  types[key] += 1
 else:
  types[key] = 1
  oname = key.lower()
  files[key] = open('item_'+oname+'.txt','w')
  files[key].write('item_'+oname+'\n')
  files[key].write('\n[OBJECT:ITEM]\n')
  efile[key] = open('Eitems_'+oname+'.txt','w')
  efile[key].write('Eitems_'+oname+'\n')
  efile[key].write('\n[OBJECT:ENHANCED_ITEM]\n')

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

for i in range(len(items)):
 item = items[i]
 key = item['Category'] + '_' + item['Type']
 cat = item['Category']
 fout = files[key]
 fout.write('\n [ITEM_'+cat+':'+item['Item']+']\n')
 # Now we have to do something different for each category
 if cat == 'WEAPON':
 elif cat == 'ARMOR':
 elif cat == 'SHOES':
 elif cat == 'GLOVES':
 elif cat == 'HELM':
 elif cat == 'PANTS':
 elif cat == 'SHIELD':
 elif cat == 'SIEGEAMMO':
 elif cat == 'TOOL':
 elif cat == 'TOY':
 elif cat == 'TRAPCOMP':
 elif cat == 'AMMO':
 elif cat == 'FOOD':
 else

for key in files.keys():
 files[key].close()
 efile[key].close()
