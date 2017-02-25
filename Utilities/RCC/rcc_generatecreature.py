 class generateCreature: #Takes the picks from pickCreature and generates actual raws
  def createDescription(creature):
   creature['Description'] = {}
   creature['Description']['Basic'] = ''

   type_dc,subtype_dc,material_dc,biome_dc,extract_dc,interaction_dc = '','','','','',''
   torso_dc,head_dc,leg_dc,arm_dc,hand_dc,foot_dc = '','','','','',''
   torsoa_dc,heada_dc,limba_dc,misca_dc = '','','',''
   eye_dc,mouth_dc,nose_dc,ear_dc = '','','',''

   type_dc = ''.join(data['TYPE'][creature['Type']]['DESCRIPTION'])
   for key in creature['SubType']:
    subtype_dc = subtype_dc + ', ' + ''.join(data['SUBTYPE'][key]['DESCRIPTION'])
   material_dc = ''.join(data['MATERIAL'][creature['Material']]['DESCRIPTION'])
   biome_dc = ''.join(data['BIOME'][creature['Biome']]['DESCRIPTION'])

   if creature['Body'].get('Torso'): torso_dc = ''.join(data['TORSO'][creature['Body']['Torso']]['DESCRIPTION'])
   if creature['Body'].get('Attachment_torso'): torsoa_dc = ''.join(data['ATTACHMENT_TORSO'][creature['Body']['Attachment_torso']]['DESCRIPTION'])
   if creature['Body'].get('Head'): head_dc = ''.join(data['HEAD'][creature['Body']['Head']]['DESCRIPTION'])
   if creature['Body'].get('Attachment_head'): heada_dc = ''.join(data['ATTACHMENT_HEAD'][creature['Body']['Attachment_head']]['DESCRIPTION'])
   body_dc = torso_dc + ' ' + torsoa_dc + ', ' + head_dc + ' ' + heada_dc
   if creature['Body'].get('Leg'): leg_dc = ''.join(data['LEG'][creature['Body']['Leg']]['DESCRIPTION'])
   if creature['Body'].get('Arm'): arm_dc = ''.join(data['ARM'][creature['Body']['Arm']]['DESCRIPTION'])  
   if creature['Body'].get('Hand'): hand_dc = ''.join(data['HAND'][creature['Body']['Hand']]['DESCRIPTION'])
   if creature['Body'].get('Foot'): foot_dc = ''.join(data['FOOT'][creature['Body']['Foot']]['DESCRIPTION'])
   if creature['Body'].get('Attachment_limb'): limba_dc = ''.join(data['ATTACHMENT_LIMB'][creature['Body']['Attachment_limb']]['DESCRIPTION'])
   limb_dc = arm_dc + ' ' + hand_dc + ' and ' + leg_dc + ' ' + foot_dc
   if creature['Body'].get('Eye'): eye_dc = ''.join(data['EYE'][creature['Body']['Eye']]['DESCRIPTION'])
   if creature['Body'].get('Nose'): nose_dc = ''.join(data['NOSE'][creature['Body']['Nose']]['DESCRIPTION'])
   if creature['Body'].get('Mouth'): mouth_dc = ''.join(data['MOUTH'][creature['Body']['Mouth']]['DESCRIPTION'])
   if creature['Body'].get('Ear'): ear_dc = ''.join(data['EAR'][creature['Body']['Ear']]['DESCRIPTION'])
   if creature['Body'].get('Attachment_misc'): misca_dc = ''.join(data['ATTACHMENT_MISC'][creature['Body']['Attachment_misc']]['DESCRIPTION'])
   face_dc = eye_dc + ', ' + nose_dc + ', ' + mouth_dc + ', and ' + ear_dc
    
   extract_dc = ''
   for key in creature['Extract']:
    extract_dc = extract_dc + ', ' + ''.join(data['EXTRACT'][key]['DESCRIPTION'])
   interaction_dc = ''
   for key in creature['Interaction']:
    interaction_dc = interaction_dc + ' ' + ''.join(data['INTERACTION'][key]['DESCRIPTION'])
           
   description = type_dc + subtype_dc + '. '
   description = description + material_dc + ' with ' + body_dc + ' and ' + face_dc + '. It has ' + limb_dc + '. '
   description = description + 'It ' + biome_dc + '. ' + extract_dc + '. ' + interaction_dc
   description = description + '. Maximum Size: '+str(int(creature['Size'][2]/1000))+'kg'
    
   description = description.replace('..','.')
   description = description.replace('  ',' ')
   creature['Description']['Basic'] = description
    
   for caste in creature['Caste']['Male']:
    creature['Description'][caste] = ''.join(data['CASTE'][caste]['DESCRIPTION'])
    creature['Description'][caste] = '[DESCRIPTION:' + creature['Description']['Basic'] + ' ' + creature['Description'][caste] + ']'
   for caste in creature['Caste']['Female']:
    creature['Description'][caste] = ''.join(data['CASTE'][caste]['DESCRIPTION'])
    creature['Description'][caste] = '[DESCRIPTION:' + creature['Description']['Basic'] + ' ' + creature['Description'][caste] + ']'
   for caste in creature['Caste']['Neutral']:
    creature['Description'][caste] = ''.join(data['CASTE'][caste]['DESCRIPTION'])
    creature['Description'][caste] = '[DESCRIPTION:' + creature['Description']['Basic'] + ' ' + creature['Description'][caste] + ']'
    
  def createBodyToken(creature):
   creature['BodyToken'] = {}
   creature['BodyToken']['Basic'] = ['[BODY']
   creature['BodyToken']['Basic'] = creature['BodyToken']['Basic'] + creature['Parts']['Body']
   for key in creature['Parts'].keys():
    if key != 'Body' and key != 'Male' and key != 'Female' and key != 'Neutral':
     creature['BodyToken']['Basic'] = creature['BodyToken']['Basic'] + creature['Parts'][key]
   creature['BodyToken']['Basic'] = ':'.join(creature['BodyToken']['Basic']) +']'
   for caste in creature['Caste']['Male']:
    creature['BodyToken'][caste] = ':'.join(creature['Parts']['Male'][caste])
    creature['BodyToken'][caste] = '[BODY:' + creature['BodyToken'][caste] + ']'
   for caste in creature['Caste']['Female']:
    creature['BodyToken'][caste] = ':'.join(creature['Parts']['Female'][caste])
    creature['BodyToken'][caste] = '[BODY:' + creature['BodyToken'][caste] + ']'
   for caste in creature['Caste']['Neutral']:
    creature['BodyToken'][caste] = ':'.join(creature['Parts']['Neutral'][caste])
    creature['BodyToken'][caste] = '[BODY:' + creature['BodyToken'][caste] + ']'
    
  def createSpeedToken(creature):
   creature['SpeedToken'] = {}
   if creature['Flags'].count('#SWIMMING_GAITS') > 0 or creature['Flags'].count('#ONLY_SWIMMING') > 0:
    temp = creature['Speed']['Walk']
    creature['Speed']['Walk'] = creature['Speed']['Swim']
    creature['Speed']['Swim'] = temp
   if creature['Flags'].count('#ONLY_SWIMMING') > 0:
    creature['Speed']['Walk'] = 0
    creature['Speed']['Climb'] = 0
    creature['Speed']['Crawl'] = 0
    creature['Speed']['Fly'] = 0
   if creature['Flags'].count('#FLYING_GAITS') > 0 or creature['Flags'].count('#ONLY_FLYING') > 0:
    temp = creature['Speed']['Walk']
    creature['Speed']['Walk'] = creature['Speed']['Fly']
    creature['Speed']['Fly'] = temp
   if creature['Flags'].count('#ONLY_FLYING') > 0:
    creature['Speed']['Walk'] = 0
    creature['Speed']['Climb'] = 0
    creature['Speed']['Crawl'] = 0
    creature['Speed']['Swim'] = 0
   if creature['Flags'].count('#NOARMS') > 0:
    creature['Speed']['Climb'] = 0
   if creature['Flags'].count('#NOLEGS') > 0:
    creature['Speed']['Walk'] = 0
   for gait in gaits:
    if creature['Speed'][gait.capitalize()] > len(speed_vals)-1: creature['Speed'][gait.capitalize()] = len(speed_vals)-1
    if creature['Speed'][gait.capitalize()] > 0:
     creature['SpeedToken'][gait.capitalize()] = ''
     creature['SpeedToken'][gait.capitalize()] = '[APPLY_CREATURE_VARIATION:'+gaits_cvs[gait]+':'+speed_vals[creature['Speed'][gait.capitalize()]]+']'
     
  def createAgeToken(creature):
   creature['Age']['Raws'] = []
   creature['Age']['Raws'].append('[MAX_AGE:'+str(creature['Age']['Max'][0])+':'+str(creature['Age']['Max'][1])+']')
   if creature['Age']['Baby'] > 0:
    creature['Age']['Raws'].append('[BABY:'+str(creature['Age']['Baby'])+']')
   if creature['Age']['Child'] > 0:
    creature['Age']['Raws'].append('[CHILD:'+str(creature['Age']['Child'])+']')
    
  def createSizeToken(creature):
   creature['SizeToken'] = []
   creature['SizeToken'].append('[BODY_SIZE:0:0:'+str(creature['Size'][0])+']')
   creature['SizeToken'].append('[BODY_SIZE:'+str(creature['Age']['Baby']+1)+':0:'+str(creature['Size'][1])+']')
   creature['SizeToken'].append('[BODY_SIZE:'+str(creature['Age']['Child']+2)+':0:'+str(creature['Size'][2])+']')
   
  def createPopToken(creature):
   creature['PopTokens'] = []
   if creature['Population'][1] > 0:
    creature['PopTokens'].append('[POPULATION_NUMBER:'+str(creature['Population'][0])+':'+str(creature['Population'][1])+']')
   if creature['Cluster'][1] > 0:
    creature['PopTokens'].append('[CLUSTER_NUMBER:'+str(creature['Cluster'][0])+':'+str(creature['Cluster'][1])+']')
    
  def createAttributeToken(creature):
   creature['Attribute']['Raws'] = []
   for att in creature['PhysAttribute'].keys():
    a = creature['PhysAttribute'][att]
    for x in range(len(a)):
     a[x] = str(a[x])
    creature['Attribute']['Raws'].append('[PHYS_ATT_RANGE:'+att+':'+':'.join(a)+']')
   for att in creature['MentAttribute'].keys():
    a = creature['PhysAttribute'][att]
    for x in range(len(a)):
     a[x] = str(a[x])
    creature['Attribute']['Raws'].append('[MENT_ATT_RANGE:'+att+':'+':'.join(a)+']')
    
  def createColors(creature):
   creature['ColorTokens'] = {}
   creature['ColorTokens']['Basic'] = []
   creature['ColorTokens']['Caste'] = {}
   parts = list(set(creature['Colors']['Parts']))
   for part in parts:
    if part == 'EYE':
     random.shuffle(eye_colors)
     color_text = eye_colors[0]     
     creature['ColorTokens']['Basic'].append('[SET_TL_GROUP:BY_CATEGORY:EYE:'+part+']')
     creature['ColorTokens']['Basic'].append('[TL_COLOR_MODIFIER:'+color_text+':1]')
     creature['ColorTokens']['Basic'].append('[TLCM_NOUN:eyes:PLURAL]')
     colorName = eye_color_names[color_text]+' eyed'
    else:
     random.shuffle(color_keys)
     color_key = color_keys[0]
     color_array = color_groups[color_key]
     color_text = ':1:'.join(color_array)
     creature['ColorTokens']['Basic'].append('[SET_TL_GROUP:BY_CATEGORY:ALL:'+part+']')
     creature['ColorTokens']['Basic'].append('[TL_COLOR_MODIFIER:'+color_text+':1]')
     colorName = random.shuffle(color_group_names[color_key])[0]+' '+part_names[part]
    creature['Names'].append('ADJ:'+colorName)
   for key in creature['Colors'].keys():
    random.shuffle(colors)
    random.shuffle(eye_colors)
    if key != 'Parts':
     creature['ColorTokens']['Caste'][key] = []
     if len(creature['Colors'][key]) > 0:
      parts = list(set(creature['Colors'][key]))
      for part in parts:
       if part == 'EYE':
        creature['ColorTokens']['Caste'][key].append('[SET_TL_GROUP:BY_CATEGORY:EYE:'+part+']')
        creature['ColorTokens']['Caste'][key].append('[TL_COLOR_MODIFIER:'+eye_colors[i]+':1]')
        creature['ColorTokens']['Caste'][key].append('[TLCM_NOUN:eyes:PLURAL]')
       else:
        creature['ColorTokens']['Caste'][key].append('[SET_TL_GROUP:BY_CATEGORY:ALL:'+part+']')
        creature['ColorTokens']['Caste'][key].append('[TL_COLOR_MODIFIER:'+colors[i]+':1]')
       i += 1
       
  def createName(creature):
   creature['NameDict'] = {}
   no_name = True
   nADJ = 0
   nPREFIX = 0
   nMAIN = 0
   nSUFFIX = 0
   i = 0
   while no_name and i < 1000:
    creature['NameDict']['Adjectives'] = {}
    creature['NameDict']['Prefixes'] = {}
    creature['NameDict']['Mains'] = {}
    creature['NameDict']['Suffixes'] = {}
    for key in creature['Names'].keys():
     table = creature['Names'][key]
     random.shuffle(table)
     split = table[0].split(':')[0]
     if split == 'ADJ':
      creature['NameDict']['Adjectives'][table[0].split(':')[1]] = 1
      nADJ += 1
     if split == 'PREFIX':
      creature['NameDict']['Prefixes'][table[0].split(':')[1]] = 1
      nPREFIX += 1
     if split == 'MAIN':
      creature['NameDict']['Mains'][table[0].split(':')[1]] = 1
      nMAIN += 1
     if split == 'SUFFIX':
      creature['NameDict']['Suffixes'][table[0].split(':')[1]] = 1
      nSUFFIX += 1
    i += 1
    if nADJ >= 1 and nPREFIX >= 1 and nMAIN >= 1:
     no_name = False
   if i == 1000:
    creature['NameDict']['Adjectives'] = {}
    creature['NameDict']['Prefixes'] = {}
    creature['NameDict']['Mains'] = {}
    creature['NameDict']['Suffixes'] = {}
    for key in creature['Names'].keys():
     for entry in creature['Names'][key]:
      if entry.split(':')[0] == 'ADJ':
       creature['NameDict']['Adjectives'][entry.split(':')[1]] = 1
      if entry.split(':')[0] == 'PREFIX':
       creature['NameDict']['Prefixes'][entry.split(':')[1]] = 1
      if entry.split(':')[0] == 'MAIN':
       creature['NameDict']['Mains'][entry.split(':')[1]] = 1
      if entry.split(':')[0] == 'SUFFIX':
       creature['NameDict']['Suffixes'][entry.split(':')[1]] = 1
      
   num_adj = random.randint(1,2)
   num_prf = random.randint(0,1)
   num_man = random.randint(1,1)
   num_sff = random.randint(0,1)
   
   temp = list(creature['NameDict']['Adjectives'].keys())
   random.shuffle(temp)
   adjectives = temp[:num_adj]
   temp = list(creature['NameDict']['Prefixes'].keys())
   random.shuffle(temp)
   prefix = temp[:num_prf]
   temp = list(creature['NameDict']['Mains'].keys())
   random.shuffle(temp)
   main = temp[:num_man]
   temp = list(creature['NameDict']['Suffixes'].keys())
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
   creature['Name'] = name+':'+name+'s:'+name
   
  def createRaws(creature,j):
   creature['Raws'] = ['[CREATURE:RC_'+str(numbers['seed'].get())+'_'+str(j)+']']
   creature['Raws'].append('[NAME:'+creature['Name']+']')

   creature['Raws'].append('\n***** Type *****\n')
   x,y = 'TYPE','Type'
   if len(data[x][creature[y]]['ARGS']) > 0:
    for line in data[x][creature[y]]['RAW']:
     i = 1
     for arg in data[x][creature[y]]['ARGS']:
      line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
      i += 1
     creature['Raws'].append(line)
   else:
    creature['Raws'] += data[x][creature[y]]['RAW']

   creature['Raws'].append('\n***** Subtypes *****\n')
   x,y = 'SUBTYPE','SubType'
   for key in creature[y]:
    if len(data[x][key]['ARGS']) > 0:
     for line in data[x][key]['RAW']:
      i = 1
      for arg in data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
       i += 1
      creature['Raws'].append(line)
    else:
     creature['Raws'] += data[x][key]['RAW']

   creature['Raws'].append('\n***** Biomes *****\n')
   x,y = 'BIOME','Biome'
   if len(data[x][creature[y]]['ARGS']) > 0:
    for line in data[x][creature[y]]['RAW']:
     i = 1
     for arg in data[x][creature[y]]['ARGS']:
      line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
      i += 1
     creature['Raws'].append(line)
   else:
    creature['Raws'] += data[x][creature[y]]['RAW']

   creature['Raws'].append('\n***** Populations *****\n')
   creature['Raws'] += creature['PopTokens']
   
   creature['Raws'].append('\n***** Ages *****\n')
   creature['Raws'] += creature['Age']['Raws']
   
   creature['Raws'].append('\n***** Gaits *****\n')
   for gait in creature['SpeedToken'].keys():
    creature['Raws'].append(creature['SpeedToken'][gait])
    
   creature['Raws'].append('\n***** Sizes *****\n')
   creature['Raws'] += creature['SizeToken']
   
   creature['Raws'].append('\n***** Attributes *****\n')
   creature['Raws'] += creature['Attribute']['Raws']
   
   creature['Raws'].append('\n***** Body *****\n')
   creature['Raws'].append(creature['BodyToken']['Basic'])
   
   creature['Raws'].append('\n***** Materials *****\n')
   x,y = 'MATERIAL','Material'
   if len(data[x][creature[y]]['ARGS']) > 0:
    for line in data[x][creature[y]]['RAW']:
     i = 1
     for arg in data[x][creature[y]]['ARGS']:
      line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
      i += 1
     creature['Raws'].append(line)
   else:
    creature['Raws'] += data[x][creature[y]]['RAW']
   
   creature['Raws'].append('\n***** Extracts *****\n')
   x,y = 'EXTRACT','Extract'
   for key in creature[y]:
    if len(data[x][key]['ARGS']) > 0:
     for line in data[x][key]['RAW']:
      i = 1
      for arg in data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
       i += 1
      creature['Raws'].append(line)
    else:
     creature['Raws'] += data[x][key]['RAW']
    
   creature['Raws'].append('\n***** Interactions *****\n')
   x,y = 'INTERACTION','Interaction'
   for key in creature[y]:
    if len(data[x][key]['ARGS']) > 0:
     for line in data[x][key]['RAW']:
      i = 1
      for arg in data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
       i += 1
      creature['Raws'].append(line)
    else:
     creature['Raws'] += data[x][key]['RAW']
    
   creature['Raws'].append('\n***** Attacks *****\n')
   for attack in creature['Attacks']:
    creature['Raws'] += data['ATTACK'][attack]['RAW']
    
    
   creature['Raws'].append('\n***** Colors *****\n')
   creature['Raws'] += creature['ColorTokens']['Basic']
   
   creature['Raws'].append('\n***** Castes *****\n')
   x,y,z = 'CASTE','Caste','Male'
   for key in creature[y][z]:
    creature['Raws'].append('[CASTE:'+key+']')
    creature['Raws'].append(creature['Description'][key])
    creature['Raws'].append('[CASTE_NAME:'+creature['Name']+']')
    creature['Raws'].append(creature['BodyToken'][key])
    if len(data[x][key]['ARGS']) > 0:
     for line in data[x][key]['RAW']:
      i = 1
      for arg in data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
       i += 1
      creature['Raws'].append(line)
    else:
     creature['Raws'] += data[x][key]['RAW']
    creature['Raws'] += creature['ColorTokens']['Caste'][key]
   x,y,z = 'CASTE','Caste','Female'
   for key in creature[y][z]:
    creature['Raws'].append('[CASTE:'+key+']')
    creature['Raws'].append(creature['Description'][key])
    creature['Raws'].append('[CASTE_NAME:'+creature['Name']+']')
    creature['Raws'].append(creature['BodyToken'][key])
    if len(data[x][key]['ARGS']) > 0:
     for line in data[x][key]['RAW']:
      i = 1
      for arg in data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
       i += 1
      creature['Raws'].append(line)
    else:
     creature['Raws'] += data[x][key]['RAW']
    creature['Raws'] += creature['ColorTokens']['Caste'][key]
   x,y,z = 'CASTE','Caste','Neutral'
   for key in creature[y][z]:
    creature['Raws'].append('[CASTE:'+key+']')
    creature['Raws'].append(creature['Description'][key])
    creature['Raws'].append(creature['BodyToken'][key])
    if len(data[x][key]['ARGS']) > 0:
     for line in data[x][key]['RAW']:
      i = 1
      for arg in data[x][key]['ARGS']:
       line = line.replace('#ARG'+str(i),str(creature['Args'][arg]))
       i += 1
      creature['Raws'].append(line)
    else:
     creature['Raws'] += data[x][key]['RAW']
    creature['Raws'] += creature['ColorTokens']['Caste'][key]

   check = ' '.join(creature['Raws'])
   if check.count('[DESCRIPTION:') == 0:
    creature['Raws'].insert(1,'[DESCRIPTION:'+creature['Description']['Basic']+']')
   if check.count('[CASTE_NAME:') == 0:
    creature['Raws'].insert(3,'[CASTE_NAME:'+creature['Name']+']')
   
   for i in range(len(creature['Raws'])):
    creature['Raws'][i] = creature['Raws'][i].replace('#NAME',creature['Name'].split(':')[0])
    creature['Raws'][i] = creature['Raws'][i].replace('#DESC',creature['Description']['Basic'])
