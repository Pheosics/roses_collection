import os
import fnmatch
import csv
import re

dirs = '.'
files = []
for fname in os.listdir(dirs):
 if fnmatch.fnmatch(fname, 'Civilizations*.csv'):
  files.append(dirs+'/'+fname)

for fname in files:
 civ = []
 level = -1
 csvfile = open(fname)
 reader = csv.reader(csvfile)
 for row in reader:
  if row[0] == 'ID':
   header = row
   continue
  civ.append({})
  level += 1
  for c in range(len(header)):
   civ[level][header[c]] = row[c]
 csvfile.close()

 # Finished reading the file, now create output
 t = fname.split('Civilizations')[1].split('csv')[0]
 oname = 'Civilizations'+t+'txt'
 fout = open(oname.lower(),'w')
 fout.write(oname.lower()+'\n')
 fout.write('\n[OBJECT:CIVILIZATION]\n')
 fout.write('\n [CIVILIZATION:'+civ[0]['ID']+']\n')
 fout.write('  [NAME:'+civ[0]['Name'] + ']\n')
 fout.write('  [LEVELS:'+str(level)+']\n')
 fout.write('  [LEVEL_METHOD:'+civ[0]['Lvl Method']+']\n')
 for lvl in range(len(civ)):
  level = civ[lvl]
  fout.write('\n  [LEVEL:'+str(lvl)+']\n')
  if lvl != 0: fout.write('   [LEVEL_NAME:'+level['Name']+']\n')
  if lvl != 0: fout.write('   [LEVEL_CHANGE_METHOD:'+level['Lvl Method']+']\n')
  # Level Requirements
  if lvl != 0: fout.write('\n')
  fout.write('   *LEVELING REQUIREMENTS\n')
  if level['Req Cn Max'] != '':
   for s in level['Req Cn Max'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:COUNTER_MAX:'+s+']\n')
  if level['Req Cn Min'] != '':
   for s in level['Req Cn Min'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:COUNTER_MIN:'+s+']\n')
  if level['Req Cn Eq'] != '':
   for s in level['Req Cn Eq'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:COUNTER_EQUAL:'+s+']\n')
  if level['Req Time'] != '': fout.write('    [LEVEL_REQUIREMENT:TIME:'+level['Req Time']+']\n')
  if level['Req Pop'] != '': fout.write('    [LEVEL_REQUIREMENT:POPULATION:'+level['Req Pop']+']\n')
  if level['Req Season'] != '': fout.write('    [LEVEL_REQUIREMENT:SEASON:'+level['Req Season']+']\n')
  if level['Req Cut'] != '': fout.write('    [LEVEL_REQUIREMENT:TREES_CUT:'+level['Req Cut']+']\n')
  if level['Req Rank'] != '': fout.write('    [LEVEL_REQUIREMENT:FORTRESS_RANK:'+level['Req Rank']+']\n')
  if level['Req Art'] != '': fout.write('    [LEVEL_REQUIREMENT:ARTIFACTS:'+level['Req Art']+']\n')
  if level['Req Tdeaths'] != '': fout.write('    [LEVEL_REQUIREMENT:TOTAL_DEATHS:'+level['Req Tdeaths']+']\n')
  if level['Req Tinsane'] != '': fout.write('    [LEVEL_REQUIREMENT:TOTAL_INSANITIES:'+level['Req Tinsane']+']\n')
  if level['Req Texec'] != '': fout.write('    [LEVEL_REQUIREMENT:TOTAL_EXECUTIONS:'+level['Req Texec']+']\n')
  if level['Req Mwaves'] != '': fout.write('    [LEVEL_REQUIREMENT:MIGRANT_WAVES:'+level['Req Mwaves']+']\n')
  if level['Req Prog'] != '':
   for s in level['Req Prog'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:PROGRESS_RANK:'+s+']\n')
  if level['Req Wealth'] != '':
   for s in level['Req Wealth'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:WEALTH:'+s+']\n')
  if level['Req Bldg'] != '':
   for s in level['Req Bldg'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:BUILDING:'+s+']\n')
  if level['Req Skill'] != '':
   for s in level['Req Skill'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:SKILL:'+s+']\n')
  if level['Req Class'] != '':
   for s in level['Req Class'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:CLASS:'+s+']\n')
  if level['Req Ekills'] != '':
   for s in level['Req Ekills'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:ENTITY_KILLS:'+s+']\n')
  if level['Req Edeaths'] != '':
   for s in level['Req Edeaths'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:ENTITY_DEATHS:'+s+']\n')
  if level['Req Ckills'] != '':
   for s in level['Req Ckills'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:CREATURE_KILLS:'+s+']\n')
  if level['Req Cdeaths'] != '':
   for s in level['Req Cdeaths'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:CREATURE_DEATHS:'+s+']\n')
  if level['Req Trades'] != '':
   for s in level['Req Trades'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:TRADES:'+s+']\n')
  if level['Req Sieges'] != '':
   for s in level['Req Sieges'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:SIEGES:'+s+']\n')
  if level['Req Diplomacy'] != '':
   for s in level['Req Diplomacy'].split('\n'):
    fout.write('    [LEVEL_REQUIREMENT:DIPLOMACY:'+s+']\n')
  # Level Remove
  fout.write('\n   *LEVEL REMOVALS\n')
  if level['LR Creature'] != '':
   for s in level['LR Creature'].split('\n'):
    fout.write('    [LEVEL_REMOVE:CREATURE:'+s+']\n')
  if level['LR Item'] != '':
   for s in level['LR Item'].split('\n'):
    fout.write('    [LEVEL_REMOVE:ITEM:'+s+']\n')
  if level['LR Inorganic'] != '':
   for s in level['LR Inorganic'].split('\n'):
    fout.write('    [LEVEL_REMOVE:INORGANIC:'+s+']\n')
  if level['LR Organic'] != '':
   for s in level['LR Organic'].split('\n'):
    fout.write('    [LEVEL_REMOVE:ORGANIC:'+s+']\n')
  if level['LR Refuse'] != '':
   for s in level['LR Refuse'].split('\n'):
    fout.write('    [LEVEL_REMOVE:REFUSE:'+s+']\n')
  if level['LR Product'] != '':
   for s in level['LR Product'].split('\n'):
    fout.write('    [LEVEL_REMOVE:PRODUCT:'+s+']\n')
  if level['LR Misc'] != '':
   for s in level['LR Misc'].split('\n'):
    fout.write('    [LEVEL_REMOVE:MISC:'+s+']\n')
  # Level Add
  fout.write('\n   *LEVEL ADDITIONS\n')
  if level['LA Creature'] != '':
   for s in level['LA Creature'].split('\n'):
    fout.write('    [LEVEL_ADD:CREATURE:'+s+']\n')
  if level['LA Item'] != '':
   for s in level['LA Item'].split('\n'):
    fout.write('    [LEVEL_ADD:ITEM:'+s+']\n')
  if level['LA Inorganic'] != '':
   for s in level['LA Inorganic'].split('\n'):
    fout.write('    [LEVEL_ADD:INORGANIC:'+s+']\n')
  if level['LA Organic'] != '':
   for s in level['LA Organic'].split('\n'):
    fout.write('    [LEVEL_ADD:ORGANIC:'+s+']\n')
  if level['LA Refuse'] != '':
   for s in level['LA Refuse'].split('\n'):
    fout.write('    [LEVEL_ADD:REFUSE:'+s+']\n')
  if level['LA Product'] != '':
   for s in level['LA Product'].split('\n'):
    fout.write('    [LEVEL_ADD:PRODUCT:'+s+']\n')
  if level['LA Misc'] != '':
   for s in level['LA Misc'].split('\n'):
    fout.write('    [LEVEL_ADD:MISC:'+s+']\n')
  # Level Change
  fout.write('\n   *LEVEL CHANGES\n')
  if level['LC Ethics'] != '':
   for s in level['LC Ethics'].split('\n'):
    fout.write('    [LEVEL_CHANGE_ETHICS:'+s+']\n')
  if level['LC Values'] != '':
   for s in level['LC Values'].split('\n'):
    fout.write('    [LEVEL_CHANGE_VALUES:'+s+']\n')
  if level['LC Skills'] != '':
   for s in level['LC Skills'].split('\n'):
    fout.write('    [LEVEL_CHANGE_SKILLS:'+s+']\n')
  if level['LC Classes'] != '':
   for s in level['LC Classes'].split('\n'):
    fout.write('    [LEVEL_CHANGE_CLASSES:'+s+']\n')
  # Level Positions
   # Too complicated to do right now, think about it for later
 fout.close()
