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

for i in range(len(items)):
 item = items[i]
 key = item['Category'] + '_' + item['Type']
 cat = item['Category']
 fout = files[key]
 fout.write('\n [ITEM_'+cat+':'+item['Item']+']\n')
 eout = efile[key]
 eout.write('\n [ITEM:'+item['Item']+']\n')
 # Now we have to do something different for each category
 if cat == 'WEAPON':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  if item['Adjective'] != '': fout.write('  [ADJECTIVE:'+item['Adjective']+']\n')
  fout.write('  [SIZE:'+item['Size']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  fout.write('  [TWO_HANDED:'+item['2HSize']+']\n')
  fout.write('  [MINIMUM_SIZE:'+item['MinSize']+']\n')
  fout.write('  [SKILL:'+item['Skill']+']\n')
  if item['Ranged'] != '': fout.write('  [RANGED:'+item['Ranged']+']\n')
  if item['ShotForce'] != '': fout.write('  [SHOOT_FORCE:'+item['ShotForce']+']\n')
  if item['ShotVel'] != '': fout.write('  [SHOOT_MAXVEL:'+item['ShotVel']+']\n')
  if item['Flags'] != '':
   for s in item['Flags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:1'] != '':
   for s in item['Attack:1'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:2'] != '':
   for s in item['Attack:2'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:3'] != '':
   for s in item['Attack:3'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:4'] != '':
   for s in item['Attack:4'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:5'] != '':
   for s in item['Attack:5'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:6'] != '':
   for s in item['Attack:6'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:7'] != '':
   for s in item['Attack:7'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:8'] != '':
   for s in item['Attack:8'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:9'] != '':
   for s in item['Attack:9'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:10'] != '':
   for s in item['Attack:10'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  ]SKILL:'+item['Skill']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### ARMOR #####
 elif cat == 'ARMOR':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  if item['Preplural'] != '': fout.write('  [PREPLURAL:'+item['Preplural']+']\n')
  if item['Placeholder'] != '': fout.write('  [MATERIAL_PLACEHOLDER:'+item['Placeholder']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  fout.write('  [ARMORLEVEL:'+item['ArmorLevel']+']\n')
  fout.write('  [UBSTEP:'+item['UBStep']+']\n')
  fout.write('  [LBSTEP:'+item['LBStep']+']\n')
  fout.write('  [LAYER:'+item['Layer']+']\n')
  fout.write('  [LAYER_SIZE:'+item['LayerSize']+']\n')
  fout.write('  [LAYER_PERMIT:'+item['LayerPermit']+']\n')
  fout.write('  [COVERAGE:'+item['Coverage']+']\n')
  if item['MatFlags'] != '':
   for s in item['MatFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['ElasticityFlags'] != '':
   for s in item['ElasticityFlags'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### SHOES #####
 elif cat == 'SHOES':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  fout.write('  [ARMORLEVEL:'+item['ArmorLevel']+']\n')
  fout.write('  [UPSTEP:'+item['UPStep']+']\n')
  fout.write('  [LAYER:'+item['Layer']+']\n')
  fout.write('  [LAYER_SIZE:'+item['LayerSize']+']\n')
  fout.write('  [LAYER_PERMIT:'+item['LayerPermit']+']\n')
  fout.write('  [COVERAGE:'+item['Coverage']+']\n')
  if item['MatFlags'] != '':
   for s in item['MatFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['ElasticityFlags'] != '':
   for s in item['ElasticityFlags'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### GLOVES #####
 elif cat == 'GLOVES':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  fout.write('  [ARMORLEVEL:'+item['ArmorLevel']+']\n')
  fout.write('  [UPSTEP:'+item['UPStep']+']\n')
  fout.write('  [LAYER:'+item['Layer']+']\n')
  fout.write('  [LAYER_SIZE:'+item['LayerSize']+']\n')
  fout.write('  [LAYER_PERMIT:'+item['LayerPermit']+']\n')
  fout.write('  [COVERAGE:'+item['Coverage']+']\n')
  if item['MatFlags'] != '':
   for s in item['MatFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['ElasticityFlags'] != '':
   for s in item['ElasticityFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  
  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### HELM #####
 elif cat == 'HELM':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  fout.write('  [ARMORLEVEL:'+item['ArmorLevel']+']\n')
  fout.write('  [LAYER:'+item['Layer']+']\n')
  fout.write('  [LAYER_SIZE:'+item['LayerSize']+']\n')
  fout.write('  [LAYER_PERMIT:'+item['LayerPermit']+']\n')
  fout.write('  [COVERAGE:'+item['Coverage']+']\n')
  if item['MatFlags'] != '':
   for s in item['MatFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['ElasticityFlags'] != '':
   for s in item['ElasticityFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  
  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### PANTS #####
 elif cat == 'PANTS':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  if item['Preplural'] != '': fout.write('  [PREPLURAL:'+item['Preplural']+']\n')
  if item['Placeholder'] != '': fout.write('  [MATERIAL_PLACEHOLDER:'+item['Placeholder']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  fout.write('  [ARMORLEVEL:'+item['ArmorLevel']+']\n')
  fout.write('  [LBSTEP:'+item['LBStep']+']\n')
  fout.write('  [LAYER:'+item['Layer']+']\n')
  fout.write('  [LAYER_SIZE:'+item['LayerSize']+']\n')
  fout.write('  [LAYER_PERMIT:'+item['LayerPermit']+']\n')
  fout.write('  [COVERAGE:'+item['Coverage']+']\n')
  if item['MatFlags'] != '':
   for s in item['MatFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['ElasticityFlags'] != '':
   for s in item['ElasticityFlags'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### SHIELD #####
 elif cat == 'SHIELD':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  fout.write('  [ARMORLEVEL:'+item['ArmorLevel']+']\n')
  fout.write('  [BLOCKCHANCE:'+item['BlockChance']+']\n')
  fout.write('  [UPSTEP:'+item['UPStep']+']\n')
  if item['MatFlags'] != '':
   for s in item['MatFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  
  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### SIEGEAMMO #####
 elif cat == 'SIEGEAMMO':
  fout.write('  [NAME:'+item['Name']+']\n')
  fout.write('  [CLASS:'+item['Class']+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnFired'] != '':
   eout.write('  [ON_PROJECTILE_FIRED]\n')
   for s in item['OnFired'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnHit'] != '':
   eout.write('  [ON_PROJECTILE_HIT]\n')
   for s in item['OnHit'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_PROJECTILE_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### TOOL #####
 elif cat == 'TOOL':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  if item['Adjective'] != '': fout.write('  [ADJECTIVE:'+item['Adjective']+']\n')
  fout.write('  [TILE:'+item['Tile']+']\n')
  fout.write('  [SIZE:'+item['Size']+']\n')
  fout.write('  [VALUE:'+item['Value']+']\n')
  if item['Use'] != '': fout.write('  [TOOL_USE:'+item['Use']+']\n')
  if item['Capacity'] != '': fout.write('  [CONTAINER_CAPACITY:'+item['Capacity']+']\n')
  if item['Improvement'] != '': fout.write('  [DEFAULT_IMPROVEMENT:'+item['Improvement']+']\n')
  if item['MatFlags'] != '':
   for s in item['Flags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Flags'] != '':
   for s in item['Flags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['MatSize'] != '': fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  if item['2HSize'] != '': fout.write('  [TWO_HANDED:'+item['2HSize']+']\n')
  if item['MinSize'] != '': fout.write('  [MINIMUM_SIZE:'+item['MinSize']+']\n')
  if item['Skill'] != '': fout.write('  [SKILL:'+item['Skill']+']\n')
  if item['Ranged'] != '': fout.write('  [RANGED:'+item['Ranged']+']\n')
  if item['ShotForce'] != '': fout.write('  [SHOOT_FORCE:'+item['ShotForce']+']\n')
  if item['ShotVel'] != '': fout.write('  [SHOOT_MAXVEL:'+item['ShotVel']+']\n')
  if item['Attack:1'] != '':
   for s in item['Attack:1'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:2'] != '':
   for s in item['Attack:2'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  ]SKILL:'+item['Skill']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnEquip'] != '':
   eout.write('  [ON_EQUIP]\n')
   for s in item['OnEquip'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnBlock'] != '':
   eout.write('  [ON_BLOCK]\n')
   for s in item['OnBlock'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnParry'] != '':
   eout.write('  [ON_PARRY]\n')
   for s in item['OnParry'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnDodge'] != '':
   eout.write('  [ON_DODGE]\n')
   for s in item['OnDodge'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### TOY #####
 elif cat == 'TOY':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  if item['Flags'] != '':
   for s in item['Flags'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')

##### TRAPCOMP #####
 elif cat == 'TRAPCOMP':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  if item['Adjective'] != '': fout.write('  [ADJECTIVE:'+item['Adjective']+']\n')
  fout.write('  [SIZE:'+item['Size']+']\n')
  fout.write('  [MATERIAL_SIZE:'+item['MatSize']+']\n')
  if item['MatFlags'] != '':
   for s in item['MatFlags'].split('\n'):
    fout.write('  ['+s+']\n')
  fout.write('  [HITS:'+item['Hits']+']\n')
  if item['Flags'] != '':
   for s in item['Flags'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:1'] != '':
   for s in item['Attack:1'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:2'] != '':
   for s in item['Attack:2'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:3'] != '':
   for s in item['Attack:3'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnAttack'] != '':
   eout.write('  [ON_ATTACK]\n')
   for s in item['OnAttack'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnWound'] != '':
   eout.write('  [ON_WOUND]\n')
   for s in item['OnWound'].split('\n'):
    eout.write('   ['+s+']\n')

##### AMMO #####
 elif cat == 'AMMO':
  fout.write('  [NAME:'+item['Name']+']\n')
  fout.write('  [CLASS:'+item['Class']+']\n')
  fout.write('  [SIZE:'+item['Size']+']\n')
  if item['Attack:1'] != '':
   for s in item['Attack:1'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:2'] != '':
   for s in item['Attack:2'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:3'] != '':
   for s in item['Attack:3'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:4'] != '':
   for s in item['Attack:4'].split('\n'):
    fout.write('  ['+s+']\n')
  if item['Attack:5'] != '':
   for s in item['Attack:5'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')
  if item['OnFired'] != '':
   eout.write('  [ON_PROJECTILE_FIRED]\n')
   for s in item['OnFired'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnHit'] != '':
   eout.write('  [ON_PROJECTILE_HIT]\n')
   for s in item['OnHit'].split('\n'):
    eout.write('   ['+s+']\n')
  if item['OnMove'] != '':
   eout.write('  [ON_PROJECTILE_MOVE]\n')
   for s in item['OnMove'].split('\n'):
    eout.write('   ['+s+']\n')

##### FOOD #####
 elif cat == 'FOOD':
  # Item File
  fout.write('  [NAME:'+item['Name']+']\n')
  fout.write('  [LEVEL:'+item['Level']+']\n')
  if item['Flags'] != '':
   for s in item['Flags'].split('\n'):
    fout.write('  ['+s+']\n')

  # Enhanced Item File
  eout.write('  [NAME:'+item['Name']+']\n')
  eout.write('  [DESCRIPTION:'+item['Description']+']\n')
  eout.write('  [CLASS:'+item['Class']+']\n')
  eout.write('  [LEVEL:'+item['Level']+']\n')
  eout.write('  [RARITY:'+item['Rarity']+']\n')

 else
  print('Unrecognized category: '+cat)

for key in files.keys():
 files[key].close()
 efile[key].close()
