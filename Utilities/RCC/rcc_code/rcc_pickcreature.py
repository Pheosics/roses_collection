from rcc_code.rcc_globals import rcc
import random

class pickCreature: #Picks from the various templates using random number generation
 def getFlagsPercents():
  rcc.creature['Flags'] = []
  for key in rcc.numbers['percents'].keys():
   if random.randint(1,100) < rcc.numbers['percents'][key].get():
    rcc.creature['Flags'].append(key)
    print(key)
  rcc.creature['Flags'].append('#MALE')
  rcc.creature['Flags'].append('#FEMALE')
  
 def getArgsNumbers():
  rcc.creature['Args'] = {}
  for arg in rcc.args:
   rcc.creature['Args'][arg] = int(random.triangular(rcc.numbers['args'][arg]['min'].get(),rcc.numbers['args'][arg]['max'].get()))

 def getSize():
  rcc.creature['Size'] = {}
  rcc.creature['Names']['Size'] = [''] #Currently size doesn't contribute to a rcc.creatures name
  maximum = int(random.gauss(rcc.numbers['size']['mean'].get(),rcc.numbers['size']['sigma'].get()))
  if maximum < rcc.numbers['size']['min'].get():
   maximum = rcc.numbers['size']['min']
  if maximum < rcc.numbers['size']['tiny'].get():
   rcc.creature['Flags'].append('#TINY')
  if maximum < rcc.numbers['size']['vermin'].get():
   rcc.creature['Flags'].append('#VERMIN')
  if maximum > rcc.numbers['size']['trade'].get() and rcc.creature['Flags'].count('#TRADE_ANIMAL') > 0:
   rcc.creature['Flags'].append('#TRADER')
  minimum = int(random.gauss(maximum/100,rcc.numbers['size']['sigma'].get()/100))
  if minimum < 1: minimum = 1
  mid = int(minimum + maximum*0.75)
  if mid > maximum:
   temp = maximum
   maximum = mid
   mid = temp
  rcc.creature['Size'] = [minimum,mid,maximum]
  
 def getSpeed():
  rcc.creature['Speed'] = {}
  rcc.creature['Names']['Speed'] = [''] #Currently speed doesn't contribute to a rcc.creatures name
  for gait in rcc.gaits:
   rcc.creature['Speed'][gait.capitalize()] = int(random.triangular(rcc.numbers['speed'][gait]['min'].get(),rcc.numbers['speed'][gait]['max'].get()))
  
 def getPops():
  rcc.creature['Names']['Population'] = [''] #Currently population rcc.numbers don't contribute to a rcc.creatures name
  min_pop = int(random.triangular(1,rcc.numbers['population']['min'].get()))
  max_pop = int(random.triangular(rcc.numbers['population']['min'].get(),rcc.numbers['population']['max'].get()))
  rcc.creature['Population'] = [min_pop,max_pop]
  if rcc.creature['Flags'].count('#VERMIN') > 0 or rcc.creature['Flags'].count('#TINY') > 0:
   rcc.creature['Population'] = [250,500]
  if rcc.creature['Population'][0] == 0 and rcc.creature['Population'][1] > 0: rcc.creature['Population'][0] = 1
  min_clus = int(random.triangular(1,rcc.numbers['cluster']['min'].get()))
  max_clus = int(random.triangular(rcc.numbers['cluster']['min'].get(),rcc.numbers['cluster']['max'].get()))
  rcc.creature['Cluster'] = [min_clus,max_clus]
  if rcc.creature['Flags'].count('#VERMIN') > 0 or rcc.creature['Flags'].count('#TINY') > 0:
   rcc.creature['Cluster'] = [0,0]
  if rcc.creature['Cluster'][0] == 0 and rcc.creature['Cluster'][1] > 0: rcc.creature['Cluster'][0] = 1
  
 def getAttributes():
  rcc.creature['Attribute'] = {}
  rcc.creature['PhysAttribute'] = {}
  rcc.creature['MentAttribute'] = {}
  rcc.creature['Names']['Attributes'] = [''] #Currently attributes don't contribute to a rcc.creatures name
  for att in rcc.phys_attributes:
   if rcc.numbers['attributes'][att]['max'].get() > 0:
    g = random.gauss(rcc.numbers['attributes'][att]['max'].get(),rcc.numbers['attributes'][att]['sigma'].get())
    a = random.gauss(rcc.numbers['attributes'][att]['min'].get(),rcc.numbers['attributes'][att]['sigma'].get())
    d = (g+a)/2
    b,c,e,f = d-5*(g-d)/10,d-2*(g-d)/10,d+2*(g-d)/10,d+5*(g-d)/10
    rcc.creature['PhysAttribute'][att] = [int(a),int(b),int(c),int(d),int(e),int(f),int(g)]
  for att in rcc.ment_attributes:
   if rcc.numbers['attributes'][att]['max'].get() > 0:
    g = random.gauss(rcc.numbers['attributes'][att]['max'].get(),rcc.numbers['attributes'][att]['sigma'].get())
    a = random.gauss(rcc.numbers['attributes'][att]['min'].get(),rcc.numbers['attributes'][att]['sigma'].get())
    d = (g+a)/2
    b,c,e,f = d-5*(g-d)/10,d-2*(g-d)/10,d+2*(g-d)/10,d+5*(g-d)/10
    rcc.creature['MentAttribute'][att] = [int(a),int(b),int(c),int(d),int(e),int(f),int(g)]
  
 def getAge():
  rcc.creature['Age'] = {}
  rcc.creature['Names']['Age'] = [''] #Currently age doesn't contribute to a rcc.creatures name
  minimum = random.triangular(rcc.numbers['age']['min'].get(),rcc.numbers['age']['max'].get())
  maximum = random.triangular(rcc.numbers['age']['max'].get(),rcc.numbers['age']['max'].get()+rcc.numbers['age']['delta'].get())
  rcc.creature['Age']['Max'] = [int(minimum),int(maximum)]
  rcc.creature['Age']['Baby'] = int(random.triangular(rcc.numbers['age']['baby'].get()-rcc.numbers['age']['delta'].get(),rcc.numbers['age']['baby'].get()+rcc.numbers['age']['delta'].get()))
  if rcc.creature['Age']['Baby'] < 0: rcc.creature['Age']['Baby'] = 0
  rcc.creature['Age']['Child'] = int(random.triangular(rcc.numbers['age']['child'].get()-rcc.numbers['age']['delta'].get(),rcc.numbers['age']['child'].get()+rcc.numbers['age']['delta'].get()))
  if rcc.creature['Age']['Child'] < 0: rcc.creature['Age']['Child'] = 0
  if rcc.creature['Age']['Baby'] > rcc.creature['Age']['Child']:
   rcc.creature['Age']['Child'] = rcc.creature['Age']['Baby']
   rcc.creature['Age']['Baby'] = 0
  rcc.creature['Names']['Age'] = ['']

 def getActive():
  rcc.creature['Active'] = random.choice(list(rcc.active.keys()))

 def getTemplate(name,template,number,chance):
  def checkTemplate(key,template):
   check = False
   checkEx = False
   if len(rcc.data[template][key]['LINK']) == 0:
    checkEx = True
    problem = ''
   else:
    for link in rcc.data[template][key]['LINK']:
     if rcc.creature['Flags'].count(link) > 0:
      checkEx = True
      problem = ''
     else:
      checkEx = False
      problem = link
      break
   if checkEx:
    if len(rcc.data[template][key]['EXCEPT']) == 0:
     check = True
    else:
     for ex in rcc.data[template][key]['EXCEPT']:
      if rcc.creature['Flags'].count(ex) >= 1:
       check = False
       break
      else:
       check = True
   return check

  if number == 1:
   rcc.creature[name] = ''
  else:
   rcc.creature[name] = []
  rcc.creature['Parts'][name] = []
  rcc.creature['Names'][name] = []
  if not number or number == 0:
   return
  if rcc.creature['Templates'].count(template): #This means a previous template has already included this template
   return
  temp_array = {}
  on = 0
  for key in rcc.status[template].keys(): #Adds all activated templates and their weightings if LINK and EXCEPT tests are passed
   if rcc.status[template][key] == 'on' and key != 'All':
    if checkTemplate(key,template): 
     if rcc.data[template][key]['WEIGHT']:
      temp_array[key] = int(rcc.data[template][key]['WEIGHT'][0])
     else:
      temp_array[key] = 100
     on += 1
  if on == 0:
   return
  
  i = 0
  n = 0
  while n < number:
   if len(temp_array.keys()) == 0 or random.randint(1,100) > chance:
    if len(temp_array.keys()) == 0:
     return
    n += 1
    continue
   rcc.creature.update()
   choice = random.choice([k for k in temp_array for dummy in range(temp_array[k])])
   if checkTemplate(choice,template):
    if number == 1:
     rcc.creature[name] = choice
    else:
     rcc.creature[name].append(choice)
    for tok in rcc.data[template][choice]['TOKENS']:
     rcc.creature['Flags'].append(tok)
    for bp in rcc.data[template][choice]['BP_COLORS']:
     rcc.creature['Colors']['Parts'].append(bp)
    for bp in rcc.data[template][choice]['BODY']:
     rcc.creature['Parts'][name].append(bp)
    rcc.creature['Names'][name] += rcc.data[template][choice]['NAME']
    rcc.creature['Templates'] += rcc.data[template][choice]['TEMPLATES']
    rcc.creature['Templates'].append(template)
    n += 1
    del temp_array[choice]
    rcc.creature.update()
   else:
    del temp_array[choice]

 def getCastes():
  rcc.creature['Caste'] = {}
  rcc.creature['Caste']['Male'] = []
  rcc.creature['Caste']['Female'] = []
  rcc.creature['Caste']['Neutral'] = []
  rcc.creature['Parts']['Male'] = {}
  rcc.creature['Parts']['Female'] = {}
  rcc.creature['Parts']['Neutral'] = {}
  rcc.creature['Names']['Caste'] = [''] #Currently castes don't contribute to the name of the rcc.creature
  male_array = {}
  female_array = {}
  temp_array = {}
  for key in rcc.status['CASTE'].keys():
   check = False
   if rcc.status['CASTE'][key] == 'on' and key != 'All':
    if len(rcc.data['CASTE'][key]['LINK']) == 0:
     if rcc.data['CASTE'][key]['WEIGHT']:
      temp_array[key] = int(rcc.data['CASTE'][key]['WEIGHT'][0])
     else:
      temp_array[key] = 100
     check = False
    else:
     for link in rcc.data['CASTE'][key]['LINK']:
      check = False
      if rcc.creature['Flags'].count(link) > 0:
       check = True
      else:
       check = False
       break
    if check:
     if rcc.data['CASTE'][key]['LINK'].count('#MALE') > 0:
      if rcc.data['CASTE'][key]['WEIGHT']:
       male_array[key] = int(rcc.data['CASTE'][key]['WEIGHT'][0])
      else:
       male_array[key] = 100
     elif rcc.data['CASTE'][key]['LINK'].count('#FEMALE') > 0:
      if rcc.data['CASTE'][key]['WEIGHT']:
       female_array[key] = int(rcc.data['CASTE'][key]['WEIGHT'][0])
      else:
       female_array[key] = 100
     else:
      if rcc.data['CASTE'][key]['WEIGHT']:
       temp_array[key] = int(rcc.data['CASTE'][key]['WEIGHT'][0])
      else:
       temp_array[key] = 100
  for i in range(rcc.numbers['caste']['male'].get()):
   if len(male_array.keys()) > 0:
    caste = random.choice([k for k in male_array for dummy in range(male_array[k])])
    add = True
    for ex in rcc.data['CASTE'][caste]['EXCEPT']:
     if rcc.creature['Flags'].count(ex) > 0:
      add = False
    if add:
     rcc.creature['Caste']['Male'].append(caste)
     for tok in rcc.data['CASTE'][caste]['TOKENS']:
      rcc.creature['Flags'].append(tok)
     rcc.creature['Colors'][caste] = []
     for bp in rcc.data['CASTE'][caste]['BP_COLORS']:
      rcc.creature['Colors'][caste].append(bp)
     rcc.creature['Parts']['Male'][caste] = []
     for bp in rcc.data['CASTE'][caste]['BODY']:
      rcc.creature['Parts']['Male'][caste].append(bp)
    rcc.creature.update()
    del male_array[caste]
  for i in range(rcc.numbers['caste']['female'].get()):
   if len(female_array.keys()) > 0:
    caste = random.choice([k for k in female_array for dummy in range(female_array[k])])
    add = True
    for ex in rcc.data['CASTE'][caste]['EXCEPT']:
     if rcc.creature['Flags'].count(ex) > 0:
      add = False
    if add:
     rcc.creature['Caste']['Female'].append(caste)
     for tok in rcc.data['CASTE'][caste]['TOKENS']:
      rcc.creature['Flags'].append(tok)
     rcc.creature['Colors'][caste] = []
     for bp in rcc.data['CASTE'][caste]['BP_COLORS']:
      rcc.creature['Colors'][caste].append(bp)
     rcc.creature['Parts']['Female'][caste] = []
     for bp in rcc.data['CASTE'][caste]['BODY']:
      rcc.creature['Parts']['Female'][caste].append(bp)
    rcc.creature.update()
    del female_array[caste]
  for i in range(rcc.numbers['caste']['neutral'].get()):
   if len(temp_array.keys()) > 0:
    caste = random.choice([k for k in temp_array for dummy in range(temp_array[k])])
    add = True
    for ex in rcc.data['CASTE'][caste]['EXCEPT']:
     if rcc.creature['Flags'].count(ex) > 0:
      add = False
    if add:
     rcc.creature['Caste']['Neutral'].append(caste)
     for tok in rcc.data['CASTE'][caste]['TOKENS']:
      rcc.creature['Flags'].append(tok)
     rcc.creature['Colors'][caste] = []
     for bp in rcc.data['CASTE'][caste]['BP_COLORS']:
      rcc.creature['Colors'][caste].append(bp)
     rcc.creature['Parts']['Neutral'][caste] = []
     for bp in rcc.data['CASTE'][caste]['BODY']:
      rcc.creature['Parts']['Neutral'][caste].append(bp)
    rcc.creature.update()
    del temp_array[caste]
    
 def getAttacks():
  rcc.creature['Attacks'] = []
  rcc.creature['Names']['Attack'] = [''] #Currently attacks don't contribute to rcc.creature names
  # Checks for attacks in the rcc.creature type
  for attack in rcc.data['TYPE'][rcc.creature['Type']]['ATTACKS']:
   if list(rcc.status['ATTACK'].keys()).count(attack) > 0 and rcc.status['ATTACK'][attack] == 'on':
    rcc.creature['Attacks'].append(attack)
  # Checks for attacks in the rcc.creature subtype
  for key in rcc.creature['SubType']:
   for attack in rcc.data['SUBTYPE'][key]['ATTACKS']:
    if list(rcc.status['ATTACK'].keys()).count(attack) > 0 and rcc.status['ATTACK'][attack] == 'on':
     rcc.creature['Attacks'].append(attack)    
  # Checks for attacks in the rcc.creature biome
  for attack in rcc.data['BIOME'][rcc.creature['Biome']]['ATTACKS']:
   if list(rcc.status['ATTACK'].keys()).count(attack) > 0 and rcc.status['ATTACK'][attack] == 'on':
    rcc.creature['Attacks'].append(attack)
  # Checks for attacks in the rcc.creature body
  for key in rcc.body_order:
   if not rcc.creature[rcc.body_templates[key]]:
    continue
   for attack in rcc.data[key][rcc.creature[rcc.body_templates[key]]]['ATTACKS']:
    if list(rcc.status['ATTACK'].keys()).count(attack) > 0 and rcc.status['ATTACK'][attack] == 'on':
     rcc.creature['Attacks'].append(attack)
  # Checks for attacks in the rcc.creature materials
  for attack in rcc.data['MATERIAL'][rcc.creature['Material']]['ATTACKS']:
   if list(rcc.status['ATTACK'].keys()).count(attack) > 0 and rcc.status['ATTACK'][attack] == 'on':
    rcc.creature['Attacks'].append(attack)
  # Checks for attacks in the rcc.creature interaction
  for key in rcc.creature['Interaction']:
   for attack in rcc.data['INTERACTION'][key]['ATTACKS']:
    if list(rcc.status['ATTACK'].keys()).count(attack) > 0 and rcc.status['ATTACK'][attack] == 'on':
     rcc.creature['Attacks'].append(attack)    
  # Checks for attacks in the rcc.creature extracts
  for key in rcc.creature['Extract']:
   for attack in rcc.data['EXTRACT'][key]['ATTACKS']:
    if list(rcc.status['ATTACK'].keys()).count(attack) > 0 and rcc.status['ATTACK'][attack] == 'on':
     rcc.creature['Attacks'].append(attack)
