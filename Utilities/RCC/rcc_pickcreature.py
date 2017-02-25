 class pickCreature: #Picks from the various templates using random number generation
  def getFlagsPercents(creature):
   creature['Flags'] = []
   for key in numbers['percents'].keys():
    if random.randint(1,100) < numbers['percents'][key].get():
     creature['Flags'].append(key)
   creature['Flags'].append('#MALE')
   creature['Flags'].append('#FEMALE')
   
  def getArgsNumbers(creature):
   creature['Args'] = {}
   for arg in args:
    creature['Args'][arg] = int(random.triangular(numbers['args'][arg]['min'].get(),numbers['args'][arg]['max'].get()))
    
  def getType(creature):
   creature['Type'] = ''
   creature['Names']['Type'] = []
   creature['Parts']['Type'] = []
   
   temp_array = []
   on = 0
   for key in status['TYPE'].keys():
    if status['TYPE'][key] == 'on' and key != 'All':
     temp_array.append(key)
     on += 1
   if len(temp_array) == 0:
    return

   i = 0
   while i < 1000:
    check = False
    type = temp_array[random.randint(0,on-1)]
    prob = ''
    if len(data['TYPE'][type]['LINK']) == 0:
     check = True
     prob = ''
    for link in data['TYPE'][type]['LINK']:
     if creature['Flags'].count(link) > 0:
      check = True
      prob = ''
     else:
      check = False
      prob = link
    if check:
     if len(data['TYPE'][type]['EXCEPT']) == 0:
      i = 9999
     for ex in data['TYPE'][type]['EXCEPT']:
      if creature['Flags'].count(ex) == 0:
       i = 9999
      else:
       i += 1
       break
    else:
     i += 1

   if i == 1000:
    print('Unable to get valid type from those available')
    print('Trouble link = '+prob)
   else:
    creature['Type'] = type
    for tok in data['TYPE'][type]['TOKENS']:
     creature['Flags'].append(tok)
    for bp in data['TYPE'][type]['BP_COLORS']:
     creature['Colors']['Parts'].append(bp)
    for bp in data['TYPE'][type]['BODY']:
     creature['Parts']['Type'].append(bp)
    creature['Names']['Type'] += data['TYPE'][type]['NAME']
    
  def getSize(creature):
   creature['Size'] = {}
   creature['Names']['Size'] = [''] #Currently size doesn't contribute to a creatures name
   max = int(random.gauss(numbers['size']['mean'].get(),numbers['size']['sigma'].get()))
   if max < numbers['size']['min'].get():
    max = numbers['size']['min']
   if max < numbers['size']['tiny'].get():
    creature['Flags'].append('#TINY')
   if max < numbers['size']['vermin'].get():
    creature['Flags'].append('#VERMIN')
   if max > numbers['size']['trade'].get() and creature['Flags'].count('#TRADE_ANIMAL') > 0:
    creature['Flags'].append('#TRADER')
   min = int(random.gauss(max/100,numbers['size']['sigma'].get()/100))
   if min < 1: min = 1
   mid = int(min + max*0.75)
   if mid > max:
    temp = max
    max = mid
    mid = temp
   creature['Size'] = [min,mid,max]
   
  def getSpeed(creature):
   creature['Speed'] = {}
   creature['Names']['Speed'] = [''] #Currently speed doesn't contribute to a creatures name
   for gait in gaits:
    creature['Speed'][gait.capitalize()] = int(random.triangular(numbers['speed'][gait]['min'].get(),numbers['speed'][gait]['max'].get()))
   
  def getPops(creature):
   creature['Names']['Population'] = [''] #Currently population numbers don't contribute to a creatures name
   min_pop = int(random.triangular(1,numbers['population']['min'].get()))
   max_pop = int(random.triangular(numbers['population']['min'].get(),numbers['population']['max'].get()))
   creature['Population'] = [min_pop,max_pop]
   if creature['Flags'].count('#VERMIN') > 0 or creature['Flags'].count('#TINY') > 0:
    creature['Population'] = [250,500]
   if creature['Population'][0] == 0 and creature['Population'][1] > 0: creature['Population'][0] = 1
   min_clus = int(random.triangular(1,numbers['cluster']['min'].get()))
   max_clus = int(random.triangular(numbers['cluster']['min'].get(),numbers['cluster']['max'].get()))
   creature['Cluster'] = [min_clus,max_clus]
   if creature['Flags'].count('#VERMIN') > 0 or creature['Flags'].count('#TINY') > 0:
    creature['Cluster'] = [0,0]
   if creature['Cluster'][0] == 0 and creature['Cluster'][1] > 0: creature['Cluster'][0] = 1
   
  def getAttributes(creature):
   creature['Attribute'] = {}
   creature['PhysAttribute'] = {}
   creature['MentAttribute'] = {}
   creature['Names']['Attributes'] = [''] #Currently attributes don't contribute to a creatures name
   for att in phys_attributes:
    if numbers['attributes'][att]['max'].get() > 0:
     g = random.gauss(numbers['attributes'][att]['max'].get(),numbers['attributes'][att]['sigma'].get())
     a = random.gauss(numbers['attributes'][att]['min'].get(),numbers['attributes'][att]['sigma'].get())
     d = (g+a)/2
     b,c,e,f = d-5*(g-d)/10,d-2*(g-d)/10,d+2*(g-d)/10,d+5*(g-d)/10
     creature['PhysAttribute'][att] = [int(a),int(b),int(c),int(d),int(e),int(f),int(g)]
   for att in ment_attributes:
    if numbers['attributes'][att]['max'].get() > 0:
     g = random.gauss(numbers['attributes'][att]['max'].get(),numbers['attributes'][att]['sigma'].get())
     a = random.gauss(numbers['attributes'][att]['min'].get(),numbers['attributes'][att]['sigma'].get())
     d = (g+a)/2
     b,c,e,f = d-5*(g-d)/10,d-2*(g-d)/10,d+2*(g-d)/10,d+5*(g-d)/10
     creature['MentAttribute'][att] = [int(a),int(b),int(c),int(d),int(e),int(f),int(g)]
   
  def getAge(creature):
   creature['Age'] = {}
   creature['Names']['Age'] = [''] #Currently age doesn't contribute to a creatures name
   min = random.triangular(numbers['age']['min'].get(),numbers['age']['max'].get())
   max = random.triangular(numbers['age']['max'].get(),numbers['age']['max'].get()+numbers['age']['delta'].get())
   creature['Age']['Max'] = [int(min),int(max)]
   creature['Age']['Baby'] = int(random.triangular(numbers['age']['baby'].get()-numbers['age']['delta'].get(),numbers['age']['baby'].get()+numbers['age']['delta'].get()))
   if creature['Age']['Baby'] < 0: creature['Age']['Baby'] = 0
   creature['Age']['Child'] = int(random.triangular(numbers['age']['child'].get()-numbers['age']['delta'].get(),numbers['age']['child'].get()+numbers['age']['delta'].get()))
   if creature['Age']['Child'] < 0: creature['Age']['Child'] = 0
   if creature['Age']['Baby'] > creature['Age']['Child']:
    creature['Age']['Child'] = creature['Age']['Baby']
    creature['Age']['Baby'] = 0
   creature['Names']['Age'] = ['']
   
  def getBiome(creature):
   creature['Biome'] = ''
   creature['Parts']['Biome'] = []
   creature['Names']['Biome'] = []
   temp_array = []
   on = 0
   for key in status['BIOME'].keys():
    if status['BIOME'][key] == 'on' and key != 'All':
     temp_array.append(key)
     on += 1
   if len(temp_array) == 0:
    print('No valid biome templates were found')
    print('Total Number of Biome Templates = ' + str(len(status['BIOME'])))
    print('Number of Biome Templates Enabled = ' + str(on))
    return
   i = 0
   while i < 1000:
    check = False
    biome = temp_array[random.randint(0,on-1)]
    prob = ''
    if len(data['BIOME'][biome]['LINK']) == 0:
     check = True
     prob = ''
    for link in data['BIOME'][biome]['LINK']:
     if creature['Flags'].count(link) > 0:
      check = True
      prob = ''
     else:
      check = False
      prob = link
    if check:
     if len(data['BIOME'][biome]['EXCEPT']) == 0:
      i = 9999
     for ex in data['BIOME'][biome]['EXCEPT']:
      if creature['Flags'].count(ex) == 0:
       i = 9999
      else:
       i += 1
       break
    else:
     i += 1
   if i == 1000:
    print('Unable to get valid biome from those available')
    print('Trouble link = '+prob)
   else:
    creature['Biome'] = biome
    for tok in data['BIOME'][biome]['TOKENS']:
     creature['Flags'].append(tok)
    for bp in data['BIOME'][biome]['BP_COLORS']:
     creature['Colors']['Parts'].append(bp)
    for bp in data['BIOME'][biome]['BODY']:
     creature['Parts']['Biome'].append(bp)
    creature['Names']['Biome'] += data['BIOME'][biome]['NAME']
    
  def getBody(creature):
   creature['Body'] = {}
   creature['Parts']['Body'] = []
   creature['Names']['Body'] = []
   body_parts = ['TORSO','HEAD','LEG','ARM','HAND','FOOT','EYE','EAR','MOUTH','NOSE','ORGANS','SKELETAL']
   for bodypart in body_parts:
    temp_array = []
    on = 0
    for key in status[bodypart].keys():
     if status[bodypart][key] == 'on' and key != 'All':
      temp_array.append(key)
      on += 1
    if len(temp_array) == 0:
     print('No valid '+bodypart.lower()+' templates were found')
     print('Total Number of '+bodypart.capitalize()+' Templates = ' + str(len(status[bodypart])))
     print('Number of '+bodypart.capitalize()+' Templates Enabled = ' + str(on))
     break
    i = 0
    while i < 1000:
     check = False
     part = temp_array[random.randint(0,on-1)]
     prob = ''
     if len(data[bodypart][part]['LINK']) == 0:
      check = True
      prob = ''
     for link in data[bodypart][part]['LINK']:
      if creature['Flags'].count(link) > 0:
       check = True
       prob = ''
      else:
       check = False
       prob = link
     if check:
      if len(data[bodypart][part]['EXCEPT']) == 0:
       i = 9999
      for ex in data[bodypart][part]['EXCEPT']:
       if creature['Flags'].count(ex) == 0:
        i = 9999
       else:
        i += 1
        break
     else:
      i += 1
    if i == 1000:
     continue
 #    print('Unable to get valid '+bodypart.lower()+' from those available')
 #    print('Trouble link = '+prob)
    else:
     creature['Body'][bodypart.capitalize()] = part
     for tok in data[bodypart][part]['TOKENS']:
      creature['Flags'].append(tok)
     for bp in data[bodypart][part]['BP_COLORS']:
      creature['Colors']['Parts'].append(bp)
     for bp in data[bodypart][part]['BODY']:
      creature['Parts']['Body'].append(bp)
     creature['Names']['Body'] += data[bodypart][part]['NAME']

   body_parts = ['ATTACHMENT_HEAD','ATTACHMENT_LIMB','ATTACHMENT_TORSO','ATTACHMENT_MISC']
   for bodypart in body_parts:
    temp_array = []
    on = 0
    for key in status[bodypart].keys():
     if status[bodypart][key] == 'on' and key != 'All':
      temp_array.append(key)
      on += 1
    if len(temp_array) == 0:
     print('No valid '+bodypart.lower()+' templates were found')
     print('Total Number of '+bodypart.capitalize()+' Templates = ' + str(len(status[bodypart])))
     print('Number of '+bodypart.capitalize()+' Templates Enabled = ' + str(on))
     break
    if random.randint(0,1) == 1:
     i = 0
    else:
     i = 2000
    while i < 1000:
     check = False
     part = temp_array[random.randint(0,on-1)]
     prob = ''
     if len(data[bodypart][part]['LINK']) == 0:
      check = True
      prob = ''
     for link in data[bodypart][part]['LINK']:
      if creature['Flags'].count(link) > 0:
       check = True
       prob = ''
      else:
       check = False
       prob = link
     if check:
      if len(data[bodypart][part]['EXCEPT']) == 0:
       i = 9999
      for ex in data[bodypart][part]['EXCEPT']:
       if creature['Flags'].count(ex) == 0:
        i = 9999
       else:
        i += 1
        break
     else:
      i += 1
    if i == 1000:
     continue
 #    print('Unable to get valid '+bodypart.lower()+' from those available')
 #    print('Trouble link = '+prob)
    elif i == 9999:
     creature['Body'][bodypart.capitalize()] = part
     for tok in data[bodypart][part]['TOKENS']:
      creature['Flags'].append(tok)
     for bp in data[bodypart][part]['BP_COLORS']:
      creature['Colors']['Parts'].append(bp)
     for bp in data[bodypart][part]['BODY']:
      creature['Parts']['Body'].append(bp)
     creature['Names']['Body'] += data[bodypart][part]['NAME']
     
  def getMaterials(creature):
   creature['Material'] = ''
   creature['Parts']['Material'] = []
   creature['Names']['Material'] = []
   temp_array = []
   on = 0
   for key in status['MATERIAL'].keys():
    if status['MATERIAL'][key] == 'on' and key != 'All':
     temp_array.append(key)
     on += 1
   if len(temp_array) == 0:
    print('No valid material templates were found')
    print('Total Number of Material Templates = ' + str(len(status['MATERIAL'])))
    print('Number of Material Templates Enabled = ' + str(on))
    return
   i = 0
   while i < 1000:
    check = False
    mat = temp_array[random.randint(0,on-1)]
    prob = ''
    if len(data['MATERIAL'][mat]['LINK']) == 0:
     check = True
     prob = ''
    for link in data['MATERIAL'][mat]['LINK']:
     if creature['Flags'].count(link) > 0:
      check = True
      prob = ''
     else:
      check = False
      prob = link
    if check:
     if len(data['MATERIAL'][mat]['EXCEPT']) == 0:
      i = 9999
     for ex in data['MATERIAL'][mat]['EXCEPT']:
      if creature['Flags'].count(ex) == 0:
       i = 9999
      else:
       i += 1
       break
    else:
     i += 1
   if i == 1000:
    print('Unable to get valid material from those available')
    print('Trouble link = '+prob)
   else:
    creature['Material'] = mat
    for tok in data['MATERIAL'][mat]['TOKENS']:
     creature['Flags'].append(tok)
    for bp in data['MATERIAL'][mat]['BP_COLORS']:
     creature['Colors']['Parts'].append(bp)
    for bp in data['MATERIAL'][mat]['BODY']:
     creature['Parts']['Material'].append(bp)
    creature['Names']['Material'] += data['MATERIAL'][mat]['NAME']
    
  def getCastes(creature):
   creature['Caste'] = {}
   creature['Caste']['Male'] = []
   creature['Caste']['Female'] = []
   creature['Caste']['Neutral'] = []
   creature['Parts']['Male'] = {}
   creature['Parts']['Female'] = {}
   creature['Parts']['Neutral'] = {}
   creature['Names']['Caste'] = [''] #Currently castes don't contribute to the name of the creature
   male_array = []
   female_array = []
   temp_array = []
   for key in status['CASTE'].keys():
    check = False
    if status['CASTE'][key] == 'on' and key != 'All':
     if len(data['CASTE'][key]['LINK']) == 0:
      temp_array.append(key)
      check = False
     else:
      for link in data['CASTE'][key]['LINK']:
       check = False
       if creature['Flags'].count(link) > 0:
        check = True
       else:
        check = False
        break
     if check:
      if data['CASTE'][key]['LINK'].count('#MALE') > 0:
       male_array.append(key)
      elif data['CASTE'][key]['LINK'].count('#FEMALE') > 0:
       female_array.append(key)
      else:
       temp_array.append(key)
   for i in range(numbers['caste']['male'].get()):
    if len(male_array) > 0:
     random.shuffle(male_array)
     num = random.randint(0,len(male_array)-1)
     caste = male_array[num]
     add = True
     for ex in data['CASTE'][caste]['EXCEPT']:
      if creature['Flags'].count(ex) > 0:
       add = False
     if add:
      creature['Caste']['Male'].append(caste)
      for tok in data['CASTE'][caste]['TOKENS']:
       creature['Flags'].append(tok)
      creature['Colors'][caste] = []
      for bp in data['CASTE'][caste]['BP_COLORS']:
       creature['Colors'][caste].append(bp)
      creature['Parts']['Male'][caste] = []
      for bp in data['CASTE'][caste]['BODY']:
       creature['Parts']['Male'][caste].append(bp)
     creature.update()
     male_array.pop(num)
   for i in range(numbers['caste']['female'].get()):
    if len(female_array) > 0:
     random.shuffle(female_array)
     num = random.randint(0,len(female_array)-1)
     caste = female_array[num]
     add = True
     for ex in data['CASTE'][caste]['EXCEPT']:
      if creature['Flags'].count(ex) > 0:
       add = False
     if add:
      creature['Caste']['Female'].append(caste)
      for tok in data['CASTE'][caste]['TOKENS']:
       creature['Flags'].append(tok)
      creature['Colors'][caste] = []
      for bp in data['CASTE'][caste]['BP_COLORS']:
       creature['Colors'][caste].append(bp)
      creature['Parts']['Female'][caste] = []
      for bp in data['CASTE'][caste]['BODY']:
       creature['Parts']['Female'][caste].append(bp)
     creature.update()
     female_array.pop(num)
   for i in range(numbers['caste']['neutral'].get()):
    if len(temp_array) > 0:
     random.shuffle(temp_array)
     num = random.randint(0,len(temp_array)-1)
     caste = temp_array[num]
     add = True
     for ex in data['CASTE'][caste]['EXCEPT']:
      if creature['Flags'].count(ex) > 0:
       add = False
     if add:
      creature['Caste']['Neutral'].append(caste)
      for tok in data['CASTE'][caste]['TOKENS']:
       creature['Flags'].append(tok)
      creature['Colors'][caste] = []
      for bp in data['CASTE'][caste]['BP_COLORS']:
       creature['Colors'][caste].append(bp)
      creature['Parts']['Neutral'][caste] = []
      for bp in data['CASTE'][caste]['BODY']:
       creature['Parts']['Neutral'][caste].append(bp)
     creature.update()
     temp_array.pop(num)
     
  def getSubTypes(creature):
   creature['SubType'] = []
   creature['Parts']['SubType'] = []
   creature['Names']['SubType'] = []
   temp_array = []
   on = 0
   for key in status['SUBTYPE'].keys():
    check = False
    if status['SUBTYPE'][key] == 'on' and key != 'All':
      if len(data['SUBTYPE'][key]['LINK']) == 0:
       check = True
      else:
       for link in data['SUBTYPE'][key]['LINK']:
        check = False
        if creature['Flags'].count(link) > 0:
         check = True
        else:
         check = False
         break
      if check:
       temp_array.append(key)
       on += 1
   for i in range(numbers['subtypes'].get()):
    if len(temp_array) > 0:
     stypen = random.randint(0,len(temp_array)-1)
     stype = temp_array[stypen]
     add = True
     for ex in data['SUBTYPE'][stype]['EXCEPT']:
      if creature['Flags'].count(ex) > 0:
       add = False
     if add:
      creature['SubType'].append(stype)
      for tok in data['SUBTYPE'][stype]['TOKENS']:
       creature['Flags'].append(tok)
      for bp in data['SUBTYPE'][stype]['BP_COLORS']:
       creature['Colors']['Parts'].append(bp)
      for bp in data['SUBTYPE'][stype]['BODY']:
       creature['Parts']['SubType'].append(bp)
      creature['Names']['SubType'] += data['SUBTYPE'][stype]['NAME']
     creature.update()
     temp_array.pop(stypen)
     
  def getInteractions(creature):
   creature['Interaction'] = []
   creature['Names']['Interaction'] = []
   if numbers['interaction']['max'].get() > 0:
    temp_array = []
    on = 0
    for key in status['INTERACTION'].keys():
     check = False
     if status['INTERACTION'][key] == 'on' and key != 'All':
       if len(data['INTERACTION'][key]['LINK']) == 0:
        check = True
       else:
        for link in data['INTERACTION'][key]['LINK']:
         check = False
         if creature['Flags'].count(link) > 0:
          check = True
         else:
          check = False
          break
       if check:
        temp_array.append(key)
        on += 1
    for i in range(numbers['interaction']['max'].get()):
     if len(temp_array) > 0 and random.randint(1,100) < numbers['interaction']['chance'].get():
      stypen = random.randint(0,len(temp_array)-1)
      stype = temp_array[stypen]
      add = True
      for ex in data['INTERACTION'][stype]['EXCEPT']:
       if creature['Flags'].count(ex) > 0:
        add = False
      if add:
       creature['Interaction'].append(stype)
       for tok in data['INTERACTION'][stype]['TOKENS']:
        creature['Flags'].append(tok)
       for bp in data['INTERACTION'][stype]['BP_COLORS']:
        creature['Colors']['Parts'].append(bp)
       for bp in data['INTERACTION'][stype]['BODY']:
        creature['Parts']['Interaction'].append(bp)
       creature['Names']['Interaction'] += data['INTERACTION'][stype]['NAME']
      creature.update()
      temp_array.pop(stypen)
      
  def getExtracts(creature):
   creature['Extract'] = []
   creature['Names']['Extract'] = []
   temp_array = []
   on = 0
   for key in status['EXTRACT'].keys():
    check = False
    if status['EXTRACT'][key] == 'on' and key != 'All':
      if len(data['EXTRACT'][key]['LINK']) == 0:
       check = True
      else:
       for link in data['EXTRACT'][key]['LINK']:
        check = False
        if creature['Flags'].count(link) > 0:
         check = True
        else:
         check = False
         break
      if check:
       temp_array.append(key)
       on += 1
   random.shuffle(temp_array)
   for extract in temp_array:
    add = True
    for ex in data['EXTRACT'][extract]['EXCEPT']:
     if creature['Flags'].count(ex) > 0:
      add = False
    if add:
     creature['Extract'].append(extract)
     for tok in data['EXTRACT'][extract]['TOKENS']:
      creature['Flags'].append(tok)
     for bp in data['EXTRACT'][extract]['BP_COLORS']:
      creature['Colors']['Parts'].append(bp)
     for bp in data['EXTRACT'][extract]['BODY']:
      creature['Parts']['Extract'].append(bp)
     creature['Names']['Extract'] += data['EXTRACT'][extract]['NAME']
     creature.update()
     
  def getAttacks(creature):
   creature['Attacks'] = []
   creature['Names']['Attack'] = [''] #Currently attacks don't contribute to creature names
   # Checks for attacks in the creature type
   for attack in data['TYPE'][creature['Type']]['ATTACKS']:
    if list(status['ATTACK'].keys()).count(attack) > 0 and status['ATTACK'][attack] == 'on':
     creature['Attacks'].append(attack)
   # Checks for attacks in the creature subtype
   for key in creature['SubType']:
    for attack in data['SUBTYPE'][key]['ATTACKS']:
     if list(status['ATTACK'].keys()).count(attack) > 0 and status['ATTACK'][attack] == 'on':
      creature['Attacks'].append(attack)    
   # Checks for attacks in the creature biome
   for attack in data['BIOME'][creature['Biome']]['ATTACKS']:
    if list(status['ATTACK'].keys()).count(attack) > 0 and status['ATTACK'][attack] == 'on':
     creature['Attacks'].append(attack)
   # Checks for attacks in the creature body
   for key in creature['Body'].keys():
    for attack in data[key.upper()][creature['Body'][key]]['ATTACKS']:
     if list(status['ATTACK'].keys()).count(attack) > 0 and status['ATTACK'][attack] == 'on':
      creature['Attacks'].append(attack)
   # Checks for attacks in the creature materials
   for attack in data['MATERIAL'][creature['Material']]['ATTACKS']:
    if list(status['ATTACK'].keys()).count(attack) > 0 and status['ATTACK'][attack] == 'on':
     creature['Attacks'].append(attack)
   # Checks for attacks in the creature interaction
   for key in creature['Interaction']:
    for attack in data['INTERACTION'][key]['ATTACKS']:
     if list(status['ATTACK'].keys()).count(attack) > 0 and status['ATTACK'][attack] == 'on':
      creature['Attacks'].append(attack)    
   # Checks for attacks in the creature extracts
   for key in creature['Extract']:
    for attack in data['EXTRACT'][key]['ATTACKS']:
     if list(status['ATTACK'].keys()).count(attack) > 0 and status['ATTACK'][attack] == 'on':
      creature['Attacks'].append(attack)
