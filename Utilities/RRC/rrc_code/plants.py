import random
from rrc_code.templates import plantTemplates

rarity_bins = {'ROLL': 1111, 'BINS': 4,
               0: {'n': 1000, 'r': 0, 't': 'Common'},
               1: {'n': 1100, 'r': 1, 't': 'Uncommon'},
               2: {'n': 1110, 'r': 2, 't': 'Rare'},
               3: {'n': 1111, 'r': 3, 't': 'Legendary'}}

season_bins = {'ROLL': 130, 'BINS': 13,
               0:  {'n': 10,  'r': 0,  't': 'winter'},
               1:  {'n': 20,  'r': 1,  't': 'spring'},
               2:  {'n': 30,  'r': 2,  't': 'summer'},
               3:  {'n': 40,  'r': 3,  't': 'autumn'},
               4:  {'n': 50,  'r': 4,  't': 'spring and summer'},
               5:  {'n': 60,  'r': 5,  't': 'summer and autumn'},
               6:  {'n': 70,  'r': 6,  't': 'autumn and winter'},
               7:  {'n': 80,  'r': 7,  't': 'winter and spring'},
               8:  {'n': 90,  'r': 8,  't': 'spring, summer, and autumn'},
               9:  {'n': 100, 'r': 9,  't': 'summer, autumn, and winter'},
               10: {'n': 110, 'r': 10, 't': 'autumn, winter, and spring'},
               11: {'n': 120, 'r': 11, 't': 'winter, spring, and summer'},
               12: {'n': 130, 'r': 12, 't': 'all year'}}
 
temperature_bins = {'ROLL': 120, 'BINS': 5,
                    0: {'n': 10,  'r': 0, 't': 'scorching'},
                    1: {'n': 50,  'r': 1, 't': 'tropical'},
                    2: {'n': 90,  'r': 2, 't': 'temperate'},
                    3: {'n': 110, 'r': 3, 't': 'tundra'},
                    4: {'n': 120, 'r': 4, 't': 'arctic'}}

moisture_bins = {'ROLL':101, 'BINS': 6,
                 0: {'n': 20,  'r': 0, 't': 'wet'},
                 1: {'n': 60,  'r': 1, 't': 'humid'},
                 2: {'n': 40,  'r': 2, 't': 'sub-humid'},
                 3: {'n': 80,  'r': 3, 't': 'semi-arid'},
                 4: {'n': 100, 'r': 4, 't': 'arid'},
                 5: {'n': 101, 'r': 5, 't': 'water'}}

sunlight_bins = {'ROLL':101, 'BINS':6,
                 0: {'n': 20,  'r': 0, 't': 'full sunlight'},
                 1: {'n': 40,  'r': 1, 't': 'partial sunlight'},
                 2: {'n': 60,  'r': 2, 't': 'some sunlight'},
                 3: {'n': 80,  'r': 3, 't': 'little sunlight'},
                 4: {'n': 100, 'r': 4, 't': 'mostly darkness'},
                 5: {'n': 101, 'r': 5, 't': 'complete darkness'}}

types = plantTemplates.read_templates()
base_types    = types['BASE']
growth_types  = types['GROWTH']
product_types = types['PRODUCT']

class rrc_plants:

 def parse_types(dIN,dOUT,Type):
  valid = True
  t = {}
  roll = random.randint(1,dIN['ROLL'])
  for i in range(dIN['BINS']):
   if roll <= dIN[i]['n']:
    t = dIN[i][Type]
    break
  try:
   for e_key in t['EXCLUDE']:
    if dOUT.get(e_key,False):
     valid = False
  except:
   valid = False

  if valid:
   dOUT[t['TYPE']] = {}
   dOUT[t['TYPE']]['r'] = i
   for key in dIN['KEYS']:
    roll_key = random.randint(0,len(t[key])-1)
    choice = t[key][roll_key]
    dOUT[t['TYPE']][key] = choice

   dOUT[t['TYPE']]['COLORS'] = {}
   for key in t['COLORS'].keys():
    roll_key = random.randint(0,len(t['COLORS'][key])-1)
    choice = t['COLORS'][key][roll_key]
    dOUT[t['TYPE']]['COLORS'][key] = choice

  return dOUT, t

 def parse_bins(bIN):
  roll = random.randint(1,bIN['ROLL'])
  for i in range(bIN['BINS']):
   if roll <= bIN[i]['n']:
    b = bIN[i]
    break
  return b['t'], b['r']

 def get_products(base, growths):
  products = {}
  for i in range(product_types['BINS']):
   valid = False
   product = product_types[i]['Product']
   if products.get(product['TYPE'],False): continue
   for j in range(product['SOURCE']['n']):
    s = product['SOURCE'][j]
    if s[0] == 'BASE':
     continue
    elif s[0] == 'GROWTH':
     if growths.get(s[1],False):
      if growths[s[1]].get(s[2],False):
       if s[3] == 'ANY' or s[3] == growths[s[1]][s[2]]:
        if random.randint(1,100) <= product['WEIGHT']:
         valid = True
         source = growths[s[1]]
         source_key = s[1]
         break
   if valid:
    growths[source_key]['PRODUCTS'].append(product['TYPE'])
    products[product['TYPE']] = {}
    products[product['TYPE']]['SOURCE'] = source
    products[product['TYPE']]['SOURCE_KEY'] = source_key
    for key in product_types['KEYS']:
     roll = random.randint(0,len(product[key])-1)
     choice = product[key][roll]
     if choice.count('#') == 1:
      choice = source.get(choice[1:],'')
     products[product['TYPE']][key] = choice

  products['Number'] = len(list(products.keys()))

  return products

 def get_growths(base):
  growth_n = random.randint(base['GROWTHS']['MIN'],base['GROWTHS']['MAX'])
  if len(base['GROWTHS']['REQUIRED']) > growth_n: growth_n = len(base['GROWTHS']['REQUIRED'])  

  growths = {}
  if growth_n > 0:
      # First get required growths
      for r_key in base['GROWTHS']['REQUIRED']:
          temp = {}
          temp['KEYS'] = growth_types['KEYS']
          temp['ROLL'] = 0
          temp['BINS'] = 0
          b = 0
          temp[b-1] = {'n':0}
          for i in range(growth_types['BINS']):
              if growth_types[i]['Growth']['TYPE'] == r_key:
                  temp[b] = growth_types[i]
                  temp[b]['n'] = temp[b-1]['n'] + growth_types[i]['Growth']['WEIGHT']
                  temp['ROLL'] += growth_types[i]['Growth']['WEIGHT']
                  temp['BINS'] += 1
                  b += 1
          if temp['BINS'] == 0:
              raise NameError('ERROR: Unable to find REQUIRED growth - '+r_key)
          growths, x = rrc_plants.parse_types(temp,growths,"Growth")
      
      # Next fill in other growths
      temp = {}
      temp['KEYS'] = growth_types['KEYS']
      temp['ROLL'] = 0
      temp['BINS'] = 0
      b = 0
      temp[b-1] = {'n':0}
      for i in range(growth_types['BINS']):
          if base['GROWTHS']['FORBIDDEN'].count(growth_types[i]['Growth']['TYPE']) == 0:
              temp[b] = growth_types[i]
              temp[b]['n'] = temp[b-1]['n'] + growth_types[i]['Growth']['WEIGHT']
              temp['ROLL'] += growth_types[i]['Growth']['WEIGHT']
              temp['BINS'] += 1
              b += 1

      if temp['BINS'] != 0:
          attempt = 0
          while len(list(growths.keys())) < growth_n:
              attempt += 1
              if attempt > 100: break
              growths, x = rrc_plants.parse_types(growth_types,growths,"Growth")

  for key in growths.keys():
   growths[key]['PRODUCTS'] = []
  growths['Number'] = len(list(growths.keys()))

  return growths

 def get_plant():
  plant = {}

  # Get Base Type
  plant['base'], base = rrc_plants.parse_types(base_types,{},'Type')

  # Get Rarity
  plant['rarity'] = rrc_plants.parse_bins(rarity_bins)

  # Get STMS
  plant['STMS'] = [0,0,0,0]
  plant['season'],      plant['STMS'][0] = rrc_plants.parse_bins(season_bins)
  plant['temperature'], plant['STMS'][1] = rrc_plants.parse_bins(temperature_bins)
  plant['moisture'],    plant['STMS'][2] = rrc_plants.parse_bins(moisture_bins)
  plant['sunlight'],    plant['STMS'][3] = rrc_plants.parse_bins(sunlight_bins)

  # Get Growths
  plant['growths'] = rrc_plants.get_growths(base)

  # Get Products
  plant['products'] = rrc_plants.get_products(base,plant['growths'])

  return plant
