from rcc_code.rcc_globals import rcc
import random

class generateCreature: #Takes the picks from pickCreature and generates actual raws
 def createDescription():
  rcc.creature['Description'] = {}
  rcc.creature['Description']['Basic'] = ''
  vowels = ('a','A','e','E','i','I','o','O','u','U')

  desc = {'Type':'','SubType':'','Material':'','Biome':'','Active':''}
  desc['Type'] = ''.join(rcc.data['TYPE'][rcc.creature['Type']]['DESCRIPTION'])
  desc['Material'] = ''.join(rcc.data['MATERIAL'][rcc.creature['Material']]['DESCRIPTION'])
  desc['Biome'] = ''.join(rcc.data['BIOME'][rcc.creature['Biome']]['DESCRIPTION'])
  desc['Active'] = rcc.active[rcc.creature['Active']]
  for key in rcc.body_order:
   string = rcc.body_templates[key]
   desc[string] = ''
   if rcc.creature[string]: desc[string] = ''.join(rcc.data[key][rcc.creature[string]]['DESCRIPTION'])
 
# Base Description
  base_dc = ''
## Type/Biome Description
  if desc['Type'] != '':
   if desc['Type'].startswith(vowels): 
    desc['Type'] = 'An ' + desc['Type']
   else:
    desc['Type'] = 'A ' + desc['Type']
   if desc['Biome'] != '':
    base_dc = desc['Type'] + ', it is found in ' + desc['Biome'] + '. '
   else:
    base_dc = desc['Type'] + '. '
  elif desc['Biome'] != '':
   base_dc = 'This creature is found in ' + desc['Biome'] + '. '
  base_dc = base_dc + 'It is active ' + desc['Active'] + '. '
## SubType Description
  subtype_dc = ''
  for key in rcc.creature['SubType']:
   temp_desc = ''.join(rcc.data['SUBTYPE'][key]['DESCRIPTION'])
   if temp_desc != '':
    subtype_dc = subtype_dc + ' ' + temp_desc + ','
  if subtype_dc != '':
   subtype_dc = 'It' + subtype_dc
   subtype_dc = subtype_dc[:-1] + '. '
   if subtype_dc.count(',') == 1:
    subtype_dc = subtype_dc.replace(', ',' and ')
   elif subtype_dc.count(',') > 1:
    subtype_dc = subtype_dc.rsplit(',',1)[0] + ', and' + subtype_dc.rsplit(',',1)[1]
##Combine
  base_dc = base_dc + subtype_dc

# Creature Description
## Body (Material and  Torso) Description
  body_dc = ''
  if desc['Torso'] != '':
   if desc['Material'] != '':
    body_dc = 'It has ' + desc['Torso'] + ' and is ' + desc['Material'] + '. '
   else:
    body_dc = 'It has ' + desc['Torso'] + '. '
  else:
   if desc['Material'] != '':
    body_dc = 'It is ' + desc['Material'] + '. '
## Full Head Description
  full_head_dc = ''
### Mouth Description
  if desc['Mouth'] != '':
   if desc['Tongue'] != '':
    desc['Mouth'] = desc['Mouth'] + ' with ' + desc['Tongue']
    if desc['Tooth'] != '':
     desc['Mouth'] = desc['Mouth'] + ' and ' + desc['Tooth']
   elif desc['Tooth'] != '':
    desc['Mouth'] = desc['Mouth'] + ' with ' + desc['Tooth']
  else:
   if desc['Tongue'] != '':
    if desc['Tooth'] != '':
     desc['Mouth'] = desc['Tongue'] + ' and ' + desc['Tooth']
    else:
     desc['Mouth'] = desc['Tongue']
   elif desc['Tooth'] != '':
    desc['Mouth'] = desc['Tooth'] 
### Face Description
  face_dc = ''
  if desc['Eye'] != '':
   face_dc = face_dc + ' ' + desc['Eye'] + ','
  if desc['Ear'] != '':
   face_dc = face_dc + ' ' + desc['Ear'] + ','
  if desc['Nose'] != '':
   face_dc = face_dc + ' ' + desc['Nose'] + ','
  if desc['Mouth'] != '':
   face_dc = face_dc + ' ' + desc['Mouth'] + ','
  if face_dc != '': 
   face_dc = face_dc[:-1]
   face_dc = face_dc[1:]
   if face_dc.count(',') == 1:
    face_dc = face_dc.replace(', ',' and ')
   elif face_dc.count(',') > 1:
    face_dc = face_dc.rsplit(',',1)[0] + ', and' + face_dc.rsplit(',',1)[1]
### Combined
  if desc['Head'] != '':
   if face_dc != '':
    full_head_dc = 'It has ' + desc['Head'] + ' with ' + face_dc + '. '
   else:
    full_head_dc = 'It has ' + desc['Head'] + '. '
  elif face_dc != '':
   full_head_dc = 'It has ' + face_dc + '. '
## Limb Description
  limb_dc = ''
### Arm Description
  if desc['Arm'] != '':
   if desc['Hand'] != '':
    desc['Arm'] = desc['Arm'] + ' with ' + desc['Hand']
### Leg Description
  if desc['Leg'] != '':
   if desc['Foot'] != '':
    desc['Leg'] = desc['Leg'] + ' with ' + desc['Foot']
### Combined
  if desc['Arm'] != '':
   if desc['Leg'] != '':
    limb_dc = 'It has ' + desc['Arm'] + ' and ' + desc['Leg'] + '. '
   else:
    limb_dc = 'It has ' + desc['Arm'] + '. '
  else:
   if desc['Leg'] != '':
    limb_dc = 'It has ' + desc['Leg'] + '. '
## Attachments Description
  attachment_dc = ''
  if desc['AttachmentHead'] != '':
   attachment_dc = attachment_dc + ' ' + desc['AttachmentHead'] + ','
  if desc['AttachmentTorso'] != '':
   attachment_dc = attachment_dc + ' ' + desc['AttachmentTorso'] + ','
  if desc['AttachmentLimb'] != '':
   attachment_dc = attachment_dc + ' ' + desc['AttachmentLimb'] + ','
  if desc['AttachmentMisc'] != '':
   attachment_dc = attachment_dc + ' ' + desc['AttachmentMisc'] + ','
  if attachment_dc != '':
   attachment_dc = 'It has' + attachment_dc
   attachment_dc = attachment_dc[:-1] + '. ' 
   if attachment_dc.count(',') == 1:
    attachment_dc = attachment_dc.replace(', ',' and ')
   elif attachment_dc.count(',') > 1:
    attachment_dc = attachment_dc.rsplit(',',1)[0] + ', and' + attachment_dc.rsplit(',',1)[1]
## Combined
  creature_dc = body_dc + full_head_dc + limb_dc + attachment_dc

# Extract Description 
  extract_dc = ''
  for key in rcc.creature['Extract']:
   desc = ''.join(rcc.data['EXTRACT'][key]['DESCRIPTION'])
   if desc != '':
    extract_dc = extract_dc + 'It ' + desc + '. '
# Interaction Description
  interaction_dc = ''
  for key in rcc.creature['Interaction']:
   desc = ''.join(rcc.data['INTERACTION'][key]['DESCRIPTION'])
   if desc != '':
    interaction_dc = interaction_dc + 'It ' + desc + '. '

  description = base_dc + creature_dc + extract_dc + interaction_dc
  description = description + 'Maximum Size: '+str(int(rcc.creature['Size'][2]/1000))+'kg.'
  description = description.replace('  ',' ')
 
  rcc.creature['Description']['Basic'] = description
   
  for caste in rcc.creature['Caste']['Male']:
   rcc.creature['Description'][caste] = ''.join(rcc.data['CASTE'][caste]['DESCRIPTION'])
   rcc.creature['Description'][caste] = '[DESCRIPTION:' + rcc.creature['Description']['Basic'] + ' ' + rcc.creature['Description'][caste] + ']'
  for caste in rcc.creature['Caste']['Female']:
   rcc.creature['Description'][caste] = ''.join(rcc.data['CASTE'][caste]['DESCRIPTION'])
   rcc.creature['Description'][caste] = '[DESCRIPTION:' + rcc.creature['Description']['Basic'] + ' ' + rcc.creature['Description'][caste] + ']'
  for caste in rcc.creature['Caste']['Neutral']:
   rcc.creature['Description'][caste] = ''.join(rcc.data['CASTE'][caste]['DESCRIPTION'])
   rcc.creature['Description'][caste] = '[DESCRIPTION:' + rcc.creature['Description']['Basic'] + ' ' + rcc.creature['Description'][caste] + ']'
   
 def createBodyToken():
  rcc.creature['BodyToken'] = {}
  exempt = []
  rcc.creature['BodyToken']['Basic'] = ['[BODY']
  for key in rcc.body_order:
   string = rcc.body_templates[key]
   rcc.creature['BodyToken']['Basic'] = rcc.creature['BodyToken']['Basic'] + rcc.creature['Parts'][string]
   exempt.append(string)
  for key in rcc.creature['Parts'].keys():
   if exempt.count(key) > 0 and key != 'Male' and key != 'Female' and key != 'Neutral':
    rcc.creature['BodyToken']['Basic'] = rcc.creature['BodyToken']['Basic'] + rcc.creature['Parts'][key]
  rcc.creature['BodyToken']['Basic'] = ':'.join(rcc.creature['BodyToken']['Basic']) +']'
  for caste in rcc.creature['Caste']['Male']:
   if len(rcc.creature['Parts']['Male'][caste]) > 0:
    rcc.creature['BodyToken'][caste] = ':'.join(rcc.creature['Parts']['Male'][caste])
    rcc.creature['BodyToken'][caste] = '[BODY:' + rcc.creature['BodyToken'][caste] + ']'
  for caste in rcc.creature['Caste']['Female']:
   if len(rcc.creature['Parts']['Female'][caste]) > 0:
    rcc.creature['BodyToken'][caste] = ':'.join(rcc.creature['Parts']['Female'][caste])
    rcc.creature['BodyToken'][caste] = '[BODY:' + rcc.creature['BodyToken'][caste] + ']'
  for caste in rcc.creature['Caste']['Neutral']:
   if rcc.creature['Parts']['Neutral'][caste] > 0:
    rcc.creature['BodyToken'][caste] = ':'.join(rcc.creature['Parts']['Neutral'][caste])
    rcc.creature['BodyToken'][caste] = '[BODY:' + rcc.creature['BodyToken'][caste] + ']'
   
 def createSpeedToken():
  rcc.creature['SpeedToken'] = {}
  if rcc.creature['Flags'].count('#SWIMMING_GAITS') > 0 or rcc.creature['Flags'].count('#ONLY_SWIMMING') > 0:
   temp = rcc.creature['Speed']['Walk']
   rcc.creature['Speed']['Walk'] = rcc.creature['Speed']['Swim']
   rcc.creature['Speed']['Swim'] = temp
  if rcc.creature['Flags'].count('#ONLY_SWIMMING') > 0:
   rcc.creature['Speed']['Walk'] = 0
   rcc.creature['Speed']['Climb'] = 0
   rcc.creature['Speed']['Crawl'] = 0
   rcc.creature['Speed']['Fly'] = 0
  if rcc.creature['Flags'].count('#FLYING_GAITS') > 0 or rcc.creature['Flags'].count('#ONLY_FLYING') > 0:
   temp = rcc.creature['Speed']['Walk']
   rcc.creature['Speed']['Walk'] = rcc.creature['Speed']['Fly']
   rcc.creature['Speed']['Fly'] = temp
  if rcc.creature['Flags'].count('#ONLY_FLYING') > 0:
   rcc.creature['Speed']['Walk'] = 0
   rcc.creature['Speed']['Climb'] = 0
   rcc.creature['Speed']['Crawl'] = 0
   rcc.creature['Speed']['Swim'] = 0
  if rcc.creature['Flags'].count('#NOARMS') > 0:
   rcc.creature['Speed']['Climb'] = 0
  if rcc.creature['Flags'].count('#NOLEGS') > 0:
   rcc.creature['Speed']['Walk'] = 0
  for gait in rcc.gaits:
   if rcc.creature['Speed'][gait.capitalize()] > len(rcc.speed_vals)-1: rcc.creature['Speed'][gait.capitalize()] = len(rcc.speed_vals)-1
   if rcc.creature['Speed'][gait.capitalize()] > 0:
    rcc.creature['SpeedToken'][gait.capitalize()] = ''
    rcc.creature['SpeedToken'][gait.capitalize()] = '[APPLY_CREATURE_VARIATION:'+rcc.gaits_cvs[gait]+':'+rcc.speed_vals[rcc.creature['Speed'][gait.capitalize()]]+']'

 def createActiveToken():
  rcc.creature['ActiveToken']= '['+rcc.creature['Active']+']'
    
 def createAgeToken():
  rcc.creature['Age']['Raws'] = []
  rcc.creature['Age']['Raws'].append('[MAX_AGE:'+str(rcc.creature['Age']['Max'][0])+':'+str(rcc.creature['Age']['Max'][1])+']')
  if rcc.creature['Age']['Baby'] > 0:
   rcc.creature['Age']['Raws'].append('[BABY:'+str(rcc.creature['Age']['Baby'])+']')
  if rcc.creature['Age']['Child'] > 0:
   rcc.creature['Age']['Raws'].append('[CHILD:'+str(rcc.creature['Age']['Child'])+']')
   
 def createSizeToken():
  rcc.creature['SizeToken'] = []
  rcc.creature['SizeToken'].append('[BODY_SIZE:0:0:'+str(rcc.creature['Size'][0])+']')
  rcc.creature['SizeToken'].append('[BODY_SIZE:'+str(rcc.creature['Age']['Baby']+1)+':0:'+str(rcc.creature['Size'][1])+']')
  rcc.creature['SizeToken'].append('[BODY_SIZE:'+str(rcc.creature['Age']['Child']+2)+':0:'+str(rcc.creature['Size'][2])+']')
  
 def createPopToken():
  rcc.creature['PopTokens'] = []
  if rcc.creature['Population'][1] > 0:
   rcc.creature['PopTokens'].append('[POPULATION_NUMBER:'+str(rcc.creature['Population'][0])+':'+str(rcc.creature['Population'][1])+']')
  if rcc.creature['Cluster'][1] > 0:
   rcc.creature['PopTokens'].append('[CLUSTER_NUMBER:'+str(rcc.creature['Cluster'][0])+':'+str(rcc.creature['Cluster'][1])+']')
   
 def createAttributeToken():
  rcc.creature['Attribute']['Raws'] = []
  for att in rcc.creature['PhysAttribute'].keys():
   a = rcc.creature['PhysAttribute'][att]
   for x in range(len(a)):
    a[x] = str(a[x])
   rcc.creature['Attribute']['Raws'].append('[PHYS_ATT_RANGE:'+att+':'+':'.join(a)+']')
  for att in rcc.creature['MentAttribute'].keys():
   a = rcc.creature['PhysAttribute'][att]
   for x in range(len(a)):
    a[x] = str(a[x])
   rcc.creature['Attribute']['Raws'].append('[MENT_ATT_RANGE:'+att+':'+':'.join(a)+']')
   
 def createColors():
  rcc.creature['ColorTokens'] = {}
  rcc.creature['ColorTokens']['Basic'] = []
  rcc.creature['ColorTokens']['Caste'] = {}
  rcc.creature['Names']['Colors'] = []
  parts = list(set(rcc.creature['Colors']['Parts']))
  for part in parts:
   if part == 'EYE':
    random.shuffle(rcc.eye_colors)
    color_text = rcc.eye_colors[0]     
    rcc.creature['ColorTokens']['Basic'].append('[SET_TL_GROUP:BY_CATEGORY:EYE:'+part+']')
    rcc.creature['ColorTokens']['Basic'].append('[TL_COLOR_MODIFIER:'+color_text+':1]')
    rcc.creature['ColorTokens']['Basic'].append('[TLCM_NOUN:eyes:PLURAL]')
    colorName = rcc.eye_color_names[color_text]+' eyed'
   else:
    random.shuffle(rcc.color_keys)
    color_key = rcc.color_keys[0]
    color_array = rcc.color_groups[color_key]
    color_text = ':1:'.join(color_array)
    rcc.creature['ColorTokens']['Basic'].append('[SET_TL_GROUP:BY_CATEGORY:ALL:'+part+']')
    rcc.creature['ColorTokens']['Basic'].append('[TL_COLOR_MODIFIER:'+color_text+':1]')
    random.shuffle(rcc.color_names[color_key])
    colorName = rcc.color_names[color_key][0]+' '+rcc.part_names[part]
   rcc.creature['Names']['Colors'].append('ADJ:'+colorName)
  for key in rcc.creature['Colors'].keys():
   random.shuffle(rcc.colors)
   random.shuffle(rcc.eye_colors)
   if key != 'Parts':
    rcc.creature['ColorTokens']['Caste'][key] = []
    if len(rcc.creature['Colors'][key]) > 0:
     parts = list(set(rcc.creature['Colors'][key]))
     for part in parts:
      if part == 'EYE':
       rcc.creature['ColorTokens']['Caste'][key].append('[SET_TL_GROUP:BY_CATEGORY:EYE:'+part+']')
       rcc.creature['ColorTokens']['Caste'][key].append('[TL_COLOR_MODIFIER:'+rcc.eye_colors[i]+':1]')
       rcc.creature['ColorTokens']['Caste'][key].append('[TLCM_NOUN:eyes:PLURAL]')
      else:
       rcc.creature['ColorTokens']['Caste'][key].append('[SET_TL_GROUP:BY_CATEGORY:ALL:'+part+']')
       rcc.creature['ColorTokens']['Caste'][key].append('[TL_COLOR_MODIFIER:'+rcc.colors[i]+':1]')
      i += 1
      
 def createName():
  rcc.creature['NameDict'] = {}
  no_name = True
  nADJ = 0
  nPREFIX = 0
  nMAIN = 0
  nSUFFIX = 0
  i = 0
  while no_name and i < 1000:
   rcc.creature['NameDict']['Adjectives'] = {}
   rcc.creature['NameDict']['Prefixes'] = {}
   rcc.creature['NameDict']['Mains'] = {}
   rcc.creature['NameDict']['Suffixes'] = {}
   for key in rcc.creature['Names'].keys():
    table = rcc.creature['Names'][key]
    random.shuffle(table)
    if len(table) > 0:
     split = table[0].split(':')[0]
     if split == 'ADJ':
      rcc.creature['NameDict']['Adjectives'][table[0].split(':')[1]] = 1
      nADJ += 1
     if split == 'PREFIX':
      rcc.creature['NameDict']['Prefixes'][table[0].split(':')[1]] = 1
      nPREFIX += 1
     if split == 'MAIN':
      rcc.creature['NameDict']['Mains'][table[0].split(':')[1]] = 1
      nMAIN += 1
     if split == 'SUFFIX':
      rcc.creature['NameDict']['Suffixes'][table[0].split(':')[1]] = 1
      nSUFFIX += 1
    i += 1
   if nADJ >= 1 and nPREFIX >= 1 and nMAIN >= 1:
    no_name = False
  if i == 1000:
   rcc.creature['NameDict']['Adjectives'] = {}
   rcc.creature['NameDict']['Prefixes'] = {}
   rcc.creature['NameDict']['Mains'] = {}
   rcc.creature['NameDict']['Suffixes'] = {}
   for key in rcc.creature['Names'].keys():
    for entry in rcc.creature['Names'][key]:
     if entry.split(':')[0] == 'ADJ':
      rcc.creature['NameDict']['Adjectives'][entry.split(':')[1]] = 1
     if entry.split(':')[0] == 'PREFIX':
      rcc.creature['NameDict']['Prefixes'][entry.split(':')[1]] = 1
     if entry.split(':')[0] == 'MAIN':
      rcc.creature['NameDict']['Mains'][entry.split(':')[1]] = 1
     if entry.split(':')[0] == 'SUFFIX':
      rcc.creature['NameDict']['Suffixes'][entry.split(':')[1]] = 1
     
  num_adj = random.randint(1,2)
  num_prf = random.randint(0,1)
  num_man = random.randint(1,1)
  num_sff = random.randint(0,1)
  
  temp = list(rcc.creature['NameDict']['Adjectives'].keys())
  random.shuffle(temp)
  adjectives = temp[:num_adj]
  temp = list(rcc.creature['NameDict']['Prefixes'].keys())
  random.shuffle(temp)
  prefix = temp[:num_prf]
  temp = list(rcc.creature['NameDict']['Mains'].keys())
  random.shuffle(temp)
  main = temp[:num_man]
  temp = list(rcc.creature['NameDict']['Suffixes'].keys())
  random.shuffle(temp)
  suffix = temp[:num_sff]
  
  adjectives = ' '.join(adjectives)
  prefix = ''.join(prefix)
  main = ' '.join(main)
  suffix = ''.join(suffix)
  if prefix != '':
   main = prefix+'-'+main
  if suffix != '':
   main = main+'-'+suffix
  
  name = adjectives+' '+main
  test = ':'+name+':'+name+'s:'+name
  test = test.replace(': ',':')
  name = test.split(':')[1].lower()
  rcc.creature['Name'] = name+':'+name+'s:'+name
 
 def createBasicInformation():
  tlist = []
  #CreatureTile (for now just set as c?)
  tlist.append("[CREATURE_TILE:'c']")
  #TileColor (for now just set as [7:0:0]?)
  tlist.append('[COLOR:7:0:0]')
  # PetValue
  size = rcc.creature['Size'][2]
  value = 50 + int(size/10000)
  tlist.append('[PETVALUE'+str(value)+']')
  rcc.creature['BasicInformation'] = tlist

 def createRaws(j):
  specialChecks = ['RELSIZE','BODYGLOSS','USE_MATERIAL','USE_TISSUE','POSITION','RELATION','[TISSUE_LAYER','TISSUE_LAYERS','BASIC_','PREFSTRING']
  special_raws_temp = []
  raws_temp = {}
  xs = ['TYPE','SUBTYPE','BIOME','EXTRACT','INTERACTION','MATERIAL']
  ys = ['Type','SubType','Biome','Extract','Interaction','Material']
  zs = ['Male','Female','Neutral']
  rcc.creature['Raws'] = ['[CREATURE:RC_'+str(rcc.numbers['seed'].get())+'_'+str(j)+']']
  rcc.creature['Raws'].append('[NAME:'+rcc.creature['Name']+']')
  rcc.creature['Raws'] += rcc.creature['BasicInformation']
  # Generate RAWS for each X Template
  for s in range(len(xs)):
   x = xs[s]
   y = ys[s]
   raws_temp[x] = []
   if type(rcc.creature[y]) == str: rcc.creature[y] = [rcc.creature[y]]
   for key in rcc.creature[y]:
    for line in rcc.data[x][key]['RAW']:
     i = 1
     if len(rcc.data[x][key]['ARGS']) > 0:
      i = 1
      for arg in rcc.data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(rcc.creature['Args'][arg]))
       i += 1
     specialCheck = True
     for key2 in specialChecks:
      if line.count(key2) >= 1:
       special_raws_temp.append(line)
       specialCheck = False
       break
     if specialCheck:
      raws_temp[x].append(line)
  # Generate RAWS for each body part
  for key in rcc.body_order:
   string = rcc.body_templates[key]
   if rcc.creature[string] != '':
    if len(rcc.data[key][rcc.creature[string]]['ARGS']) > 0:
     for line in rcc.data[key][rcc.creature[string]]['RAW']:
      i = 1
      for arg in rcc.data[key][rcc.creature[string]]['ARGS']:
       line = line.replace('#ARG'+str(i),sstr(rcc.creature['Args'][arg]))
       i += 1
      special_raws_temp.append(line)
    else:
     special_raws_temp += rcc.data[key][rcc.creature[string]]['RAW']
  # Break apart the special raws check array into various parts
  relsize,gloss,material,tissue,position,relation,layer,layers,prefstring,basic,left = [],[],[],[],[],[],[],[],[],[],[]
  for line in special_raws_temp:
   if line.count('RELSIZE') >= 1:
    relsize.append(line)
   elif line.count('BODYGLOSS') >= 1:
    gloss.append(line)
   elif line.count('USE_MATERIAL') >= 1:
    material.append(line)
   elif line.count('USE_TISSUE') >= 1:
    tissue.append(line)
   elif line.count('POSITION') >= 1:
    position.append(line)
   elif line.count('RELATION') >= 1:
    relation.append(line)
   elif line.count('[TISSUE_LAYER') >= 1:
    layer.append(line)
   elif line.count('TISSUE_LAYERS') >= 1:
    layers.append(line)
   elif line.count('BASIC_') >= 1:
    basic.append(line)
   elif line.count('PREFSTRING') >= 1:
    prefstring.append(line)
   else:
    left.append(line)
  # Generate RAWS for each CASTE template
  x,y = 'CASTE','Caste'
  raws_temp[x] = []
  for s in range(len(zs)):
   z = zs[s]
   for key in rcc.creature[y][z]:
    raws_temp[x].append('[CASTE:'+key+']')
    raws_temp[x].append(rcc.creature['Description'][key])
    raws_temp[x].append('[CASTE_NAME:'+rcc.creature['Name']+']')
    if list(rcc.creature['BodyToken'].keys()).count(key) > 0:
     raws_temp[x].append(rcc.creature['BodyToken'][key])
    if len(rcc.data[x][key]['ARGS']) > 0:
     for line in rcc.data[x][key]['RAW']:
      i = 1
      for arg in rcc.data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(rcc.creature['Args'][arg]))
       i += 1
      raws_temp[x].append(line)
    else:
     raws_temp[x] += rcc.data[x][key]['RAW']
    raws_temp[x] += rcc.creature['ColorTokens']['Caste'][key]

  # Put together the actual Raws
  ## Base Information (Creature Token, Name, Display Tile, Display Color, Pet Value, etc...)
  rcc.creature['Raws'] = ['[CREATURE:RC_'+str(rcc.numbers['seed'].get())+'_'+str(j)+']']
  rcc.creature['Raws'].append('[NAME:'+rcc.creature['Name']+']')
  rcc.creature['Raws'] += rcc.creature['BasicInformation']
  ## Number Information (Population and Cluster Number, Ages, Gaits, Size, Attributes, etc...)
  rcc.creature['Raws'].append('\n***** Numbers *****')
  rcc.creature['Raws'] += rcc.creature['PopTokens']
  rcc.creature['Raws'] += rcc.creature['Age']['Raws']
  for gait in rcc.creature['SpeedToken'].keys():
   rcc.creature['Raws'].append(rcc.creature['SpeedToken'][gait])
  rcc.creature['Raws'] += rcc.creature['SizeToken']
  rcc.creature['Raws'] += rcc.creature['Attribute']['Raws']
  ## TYPE Template Information
  rcc.creature['Raws'].append('\n***** Type *****')
  rcc.creature['Raws'] += raws_temp['TYPE']
  ## BIOME Template Information
  rcc.creature['Raws'].append('\n***** Biome *****')
  rcc.creature['Raws'] += raws_temp['BIOME']
  ## SUBTYPE Template Information
  rcc.creature['Raws'].append('\n***** SubType *****')
  rcc.creature['Raws'] += raws_temp['SUBTYPE']
  ## Prefstring Information (from the specialChecks)
  rcc.creature['Raws'].append('\n***** PrefString *****')
  rcc.creature['Raws'] += prefstring
  ## Body Information (Parts, BodyGloss, Relsizes, Positions, Relations, etc...)
  rcc.creature['Raws'].append('\n***** Body *****')
  rcc.creature['Raws'].append(rcc.creature['BodyToken']['Basic'])
  rcc.creature['Raws'].append('')
  rcc.creature['Raws'] += gloss
  rcc.creature['Raws'] += relsize
  rcc.creature['Raws'] += position
  rcc.creature['Raws'] += relation
  ## Material Information (Materials, Tissues, Layers, etc...)
  rcc.creature['Raws'].append('\n***** Materials *****')
  rcc.creature['Raws'] += basic
  rcc.creature['Raws'] += material
  rcc.creature['Raws'] += tissue
  rcc.creature['Raws'] += layers
  rcc.creature['Raws'] += layer
  rcc.creature['Raws'] += left
  ## Extract Information
  rcc.creature['Raws'].append('\n***** Extracts *****')
  rcc.creature['Raws'] += raws_temp['EXTRACT']
  ## Interaction Information
  rcc.creature['Raws'].append('\n***** Interactions *****')
  rcc.creature['Raws'] += raws_temp['INTERACTION']
  ## Attack Information
  rcc.creature['Raws'].append('\n***** Attacks *****')
  for attack in rcc.creature['Attacks']:
   rcc.creature['Raws'] += rcc.data['ATTACK'][attack]['RAW']
  ## Color Information
  rcc.creature['Raws'].append('\n***** Colors *****\n')
  rcc.creature['Raws'] += rcc.creature['ColorTokens']['Basic']
  ## Caste Information
  rcc.creature['Raws'].append('\n***** Castes *****\n')
  rcc.creature['Raws'] += raws_temp['CASTE']

  ## Check that there is a Description and Caste Name somewhere in the creature
  check = ' '.join(rcc.creature['Raws'])
  if check.count('[DESCRIPTION:') == 0:
   rcc.creature['Raws'].insert(1,'[DESCRIPTION:'+rcc.creature['Description']['Basic']+']')
  if check.count('[CASTE_NAME:') == 0:
   rcc.creature['Raws'].insert(3,'[CASTE_NAME:'+rcc.creature['Name']+']')
  
  ## Replace final arguments, #NAME and #DESC
  for i in range(len(rcc.creature['Raws'])):
   rcc.creature['Raws'][i] = rcc.creature['Raws'][i].replace('#NAME',rcc.creature['Name'].split(':')[0])
   rcc.creature['Raws'][i] = rcc.creature['Raws'][i].replace('#DESC',rcc.creature['Description']['Basic'])
