import json
import random

biome_source = 'raws'
material_source = 'local'

class plantRaws:
    f = open('templates/raws_PLANTS.json')
    raws = json.load(f)
    key_words    = raws['key_words']
    colors       = raws['colors']
    environments = raws['environments']
    raw_biomes   = raws['raw_biomes']
    Base         = raws['raw_base']
    Growths      = raws['raw_growth']
    Products     = raws['raw_product']
    name_list = {}
   
    def get_description(plant):
        base        = plant['base'][list(plant['base'].keys())[0]]
        rarity      = plant.get('rarity',"")
        season      = plant.get('season',"")
        temperature = plant.get('temperature',"")
        moisture    = plant.get('moisture',"")
        sunlight    = plant.get('sunlight',"")
        growths     = plant.get('growths',{})
        products    = plant.get('products',{})
        biome_str   = plant.get('biome_str',"")
       
        # A "SIZE" "SHAPE" "BASE_COLOR" "TYPE", with "PART_COLOR"
        str1 = 'A ' + base.get('SIZE','') + ' ' \
                    + base.get('SHAPE','') + ' ' \
                    + base['COLORS'].get('NAME','') + ' ' + base['NAME'] + '. '
        start = True
        for key in base['COLORS'].keys():
            if key == 'NAME': continue
            if start:
                str1 = str1[:-2] + ', with ' + base['COLORS'][key] + ' ' + key + ', '
                start = False
            else:
                str1 = str1 + base['COLORS'][key] + ' ' + key + ', '
        str1 = str1[:-2]
        str1 = str1.lower()
        str1 = ' '.join(str1.split())
       
        # It grows "SEASON" in "MOISTURE" "TEMPERATURE" environments and requires "SUNLIGHT"
        # Or, It grows "SEASON" in "BIOME(s)"
        if season == 'all year':
            str2 = 'it grows through the whole year'
        else:
            str2 = 'it grows in the ' + season
        if biome_source == 'environment':
            str2 = str2 + ' in ' + moisture + ' ' + temperature + ' environments and requires ' + sunlight
        elif biome_source == 'raws':
            str2 = str2 + ' in ' + biome_str
        str2 = str2.lower()
        str2 = ' '.join(str2.split())
       
        # It has "GROWTH_SIZE" "GROWTH_SHAPE" "GROWTH_BASE_COLOR" "GROWTH_TYPE"
        if growths.get('Number',0) == 0:
            str3 = 'it is completely bare'
        else:
            str3 = 'it has '
            for key in growths.keys():
                if key == 'Number': continue
                growth = growths[key]
                str3 = str3 + growth.get('SIZE','') + ' ' \
                            + growth.get('SHAPE','') + ' ' \
                            + growth['COLORS'].get('NAME','') + ' ' + growth['NAME'] + ', '
        str3 = str3[:-2]
        str3 = str3.lower()
        str3 = ', and'.join(str3.rsplit(',',1)) + '. '
      
        for key in growths.keys():
            if key == 'Number': continue
            growth = growths[key]
            smell_str = (' smell ' + growth['SMELL']) if growth['SMELL'] != '' else ''
            if growth['FLAVOR'] == 'inedible':
                taste_str = ' and are inedible'
            elif growth['FLAVOR'] == '' or growth['FLAVOR'] == "''":
                taste_str = ''
            else:
                taste_str = ' and taste ' + growth['FLAVOR']
            if smell_str == '': taste_str = taste_str[4:]
            js1 = ' with ' if growth.get('SHELL',False) or growth.get('SEED',False) else  ' '
            js2 = ' and '  if growth.get('SHELL',False) and growth.get('SEED',False) else  ' '
            js3 = ' and have ' if smell_str + taste_str != '' else ' have '
            str3 = str3 + 'the ' + growth['NAME'] + smell_str + taste_str
            str3 = str3 + js3 + growth['COLORS'].get('SHELL','') + ' ' + growth.get('SHELL','') 
            str3 = str3 + js2 + growth['COLORS'].get('SEED','')  + ' ' + growth.get('SEED','') + '. '
        str3 = str3[:-2]
        str3 = str3.lower()
        str3 = ' '.join(str3.split())
       
        # The "GROWTH_TYPE" smell "GROWTH_SMELL" and taste "GROWTH_FLAVOR", they can be used to "PRODUCT_TYPE" "PRODUCT_ADJ" "
        str4 = ''
        for key in products.keys():
            if key == 'Number': continue
            product = products[key]
            source  = product['SOURCE']
            product_str = product['ADJ'] + ' ' + product['NAME']
            str4 = str4 + 'The ' + source['NAME'] + ' can be used to ' + key + ' a ' + product_str + '. '
        str4 = str4[:-2]
        str4 = str4.lower()
        str4 = ' '.join(str4.split())
        
        description = str1 +'. '+ str2 +'. '+ str3 +'. '+ str4
      
        return description
   
    def get_name(plant):
     names = {}
     base     = plant['base'][list(plant['base'].keys())[0]]
     growths  = plant['growths']
     products = plant['products']
   
     #name_base = base['NAME']
     name_biome = plant['biome_name']
     #name_season = plant['season']
   
     #name_parts = []
     #name_growths = []
     #name_products = []
     #name_smells = []
     #name_flavors = []
     #for key in base['COLORS'].keys():
     # if key == 'NAME': continue
     # name_parts.append(base['COLORS'][key] + ' ' + key)
     #for key in growths.keys():
     # if key == 'Number': continue
     # name_growths.append(growths[key]['COLORS'].get('NAME','') + ' ' + growths[key]['NAME'])
     # name_growths.append(growths[key]['FLAVOR'] + ' ' + growths[key]['NAME'])
     # name_growths.append(growths[key]['SMELL'] + ' ' + growths[key]['NAME'])
     # name_smells.append(growths[key]['SMELL'])
     # name_flavors.append(growths[key]['FLAVOR'])
     #for key in products.keys():
     # if key == 'Number': continue
     # name_products.append(products[key]['ADJ'] + ' ' + products[key]['NAME'])
   
     str1 = base.get('SIZE','') + ' ' + base.get('SHAPE','') + ' ' \
          + base['COLORS'].get('NAME','') + ' ' + name_biome + ' ' + base['NAME']
     str1 = str1.lower()
     str1 = ' '.join(str1.split())
   
     names['singular']  = str1
     names['plural']    = str1 + 's'
     names['adjective'] = str1
     names['seed']      = str1 + ' seed'
     names['growths']   = {'HARD_SHELL':  'hard shell',
                           'SOFT_SHELL':  'soft shell',
                           'POD':         'pod',
                           'UNDERGROUND': 'underground',
                           'FLOWER':      'flower',
                           'LEAF':        'leaf',
                           'HERB':        'herb',
                           'GRAIN':       'grain'}
     for g_key in growths.keys():
      if g_key == 'Number': continue
      growth = growths[g_key]
      names['growths'][g_key] = growth.get('SIZE','') + ' ' \
                              + growth.get('SHAPE','') + ' ' \
                              + growth.get('COLORS',{}).get('NAME','') + ' ' \
                              + growth.get('NAME','')
     names['products'] = {'BREW':   'drink',
                          'MILL':   'powder',
                          'PRESS':  'paste',
                          'THRESH': 'thread',
                          'EXTRACT_VIAL':    'extract',
                          'EXTRACT_STILL':   'extract',
                          'EXTRACT_FARMERS': 'extract'}
     for key in products.keys():
      if key == 'Number': continue
      names['products'][key] = products[key]['ADJ'] + ' ' + products[key]['NAME']
   
     return names
   
    def get_prefstring(plant):
     prefstring = []
     base     = plant['base'][list(plant['base'].keys())[0]]
     growths  = plant['growths']
     products = plant['products']
   
     for key in base['COLORS'].keys():
      if key == 'NAME': continue
      prefstring.append('[PREFSTRING:' + base['COLORS'][key] + ' ' + key + ']')
   
     if growths['Number'] > 0:
      for key in growths.keys():
       if key == 'Number': continue
       growth = growths[key]
       prefstring.append('[PREFSTRING:' + growth.get('SIZE','') + ' ' \
                                        + growth.get('SHAPE','') + ' ' \
                                        + growth['COLORS'].get('NAME','') + ' ' + growth['NAME'] + ']')
       for key in growth['COLORS'].keys():
        if key == 'NAME' or key == 'SHELL' or key == 'SEED': continue
        prefstring.append('[PREFSTRING:' + growth['COLORS'][key] + ' ' + key + ']')
   
     if products['Number'] > 0:
      for p_key in products.keys():
       if p_key == 'Number': continue
       prefstring.append('[PREFSTRING:' + products[p_key]['ADJ'] + ' ' + products[p_key]['NAME'] + ']')
   
     return '\n'.join(prefstring)
   
    def get_habitat(plant):
     words = plantRaws.key_words
     t = plant['temperature']
     m = plant['moisture']
     s = plant['sunlight']
   
     # Get RAW season
     temp1 = plant['season'].replace(',','').split()
     temp2 = []
     for k in temp1:
      temp2.append(words.get(k,k))
     season = ''.join(temp2)
   
     # Get RAW environment (DRY, WET, EVIL, SAVAGE, GOOD)
     environment = words[m]
   
     # Get RAW Biomes
     if biome_source == 'environment':
      a,b,c,d = plant['STMS']
      temp1 = plantRaws.environments[str(b)][str(c)][str(d)]
      temp2 = []
      temp3 = []
      for k in temp1:
       temp2.append(plantRaws.raw_biomes[str(k)]['TOKEN'])
       temp3 = temp3 + plantRaws.raw_biomes[str(k)]['Name']
      biome = ''.join(temp2)
      biome_name = temp3[random.randint(0,len(temp3)-1)]
      biome_str = ''
     elif biome_source == 'raws':
      roll = random.randint(0,len(list(plantRaws.raw_biomes.keys()))-2)
      temp1 = plantRaws.raw_biomes[str(roll)]
      biome      = temp1['TOKEN']
      biome_name = temp1['Name'][random.randint(0,len(temp1['Name'])-1)]
      biome_str  = temp1['Description']   
   
     return season, environment, biome, biome_name, biome_str
   
    def parse_colors(plant):
     colors = plantRaws.colors
     colorValues = {}
   
     # Base COLORS
     colorValues['base'] = {}
     b_key = list(plant['base'].keys())[0]
     for key in plant['base'][b_key]['COLORS'].keys():
      if plant['base'][b_key]['COLORS'].get(key,'') == '!ANY':
       c_key   = list(colors.keys())[random.randint(0,len(colors.keys())-1)]
       value = colors[c_key]['Value']
       name  = colors[c_key]['Names'][random.randint(0,len(colors[c_key]['Names'])-1)]
      elif plant['base'][b_key]['COLORS'].get(key,'') != '':
       name  = plant['base'][b_key]['COLORS'].get(key,'')
       value = ''
       for d in colors:
        if d['Names'].count(name) > 0:
         value = d['Value']
         break
       if value == '': value = "0:0:0"
      plant['base'][b_key]['COLORS'][key] = name
      colorValues['base'][key] = value
   
     # Growth COLORS
     colorValues['growths'] = {}
     for g_key in plant['growths'].keys():
      if g_key == 'Number': continue
      colorValues['growths'][g_key] = {}
      for key in plant['growths'][g_key]['COLORS'].keys():
       if plant['growths'][g_key]['COLORS'].get(key,'') == '!ANY':
        c_key   = list(colors.keys())[random.randint(0,len(colors.keys())-1)]
        value = colors[c_key]['Value']
        name  = colors[c_key]['Names'][random.randint(0,len(colors[c_key]['Names'])-1)]
       elif plant['growths'][g_key]['COLORS'].get(key,'') != '':
        name  = plant['growths'][g_key]['COLORS'].get(key,'')
        value = ''
        for d in colors:
         if d['Names'].count(name) > 0:
          value = d['Value']
          break
        if value == '': value = "0:0:0"
       plant['growths'][g_key]['COLORS'][key] = name
       colorValues['growths'][g_key][key] = value
   
     # Product COLORS
     colorValues['products'] = {}
     for p_key in plant['products'].keys():
      if p_key == 'Number': continue
      product = plant['products'][p_key]
      if colorValues['growths'].get(product['SOURCE_KEY'],False):
       colorValues['products'][p_key] = colorValues['growths'][product['SOURCE_KEY']].get('NAME','0:0:0')
      elif colorValues['base'].get(product['SOURCE_KEY'],False):
       colorValues['products'][p_key] = colorValues['base'][product['SOURCE_KEY']].get('NAME','0:0:0')
      else:
       colorValues['products'][p_key] = '0:0:0'
   
     return plant, colorValues
   
    def get_raw(plant):
     season, environment, biome, plant['biome_name'], plant['biome_str'] = plantRaws.get_habitat(plant)
     plant, colorValues = plantRaws.parse_colors(plant)
     description = plantRaws.get_description(plant)
     name = plantRaws.get_name(plant)
     if plantRaws.name_list.get(name['singular'],False): return ''
     
     prefstring = plantRaws.get_prefstring(plant)
     base_raws = plantRaws.Base[list(plant['base'].keys())[0]]
   
     plantRaws.name_list[name['singular']] = True
     raws         = []
     seed         = []
     growths      = []
     products     = []
     seed_mat     = []
     growth_mats  = []
     product_mats = []
   
     # Get Base Raws
     raws = ['{DESCRIPTION:#DESCRIPTION}'] + base_raws['BASE']
     raws = raws + base_raws['BIOMES']
   
     structure = base_raws['STRUCTURE']
     structure_mat = ['\n\t'.join(base_raws['STRUCTURE_MAT'])]

     # Start Seed Raws
     seed     = base_raws['SEED']
     seed_mat = ['\n\t'.join(base_raws['SEED_MAT'])]
   
     # Get Growth Raws
     for key in plant['growths'].keys():
      if key == 'Number': continue
      growth = plant['growths'][key]
      growth_raws = plantRaws.Growths[key]
   
      ## Add Growths and their materials if using local material_source
      growths = growths + ['\n\t'.join(growth_raws['GROWTH'])]
      if material_source == 'local': 
       growth_mats = growth_mats + ['\n\t'.join(growth_raws['GROWTH_MAT'])]
       if ''.join(growth_raws['SEED_MAT']) != '': 
        seed_mat = seed_mat + ['\t'+'\n\t'.join(growth_raws['SEED_MAT'])]
       if ''.join(growth_raws['STRUCTURE_MAT']) != '':
        structure_mat = structure_mat + ['\t'+'\n\t'.join(growth_raws['STRUCTURE_MAT'])]
       for p_key in growth['PRODUCTS']:
        product_raws = plantRaws.Products[p_key]
        if ''.join(product_raws['GROWTH_MAT']) != '':
         growth_mats = growth_mats + ['\t'+'\n\t'.join(product_raws['GROWTH_MAT'])]
   
     ## Get Product Raws
     for p_key in plant['products'].keys():
      if p_key == 'Number': continue
      product_raws = plantRaws.Products[p_key]
      products = products + product_raws['PRODUCT']
      if material_source == 'local': 
       product_mats = product_mats + ['\n\t'.join(product_raws['PRODUCT_MAT'])]
       if ''.join(product_raws['SEED_MAT']) != '': 
        seed_mat = seed_mat + ['\t'+'\n\t'.join(product_raws['SEED_MAT'])]
       if ''.join(product_raws['STRUCTURE_MAT']) != '':
        structure_mat = structure_mat + ['\t'+'\n\t'.join(product_raws['STRUCTURE_MAT'])]
   
     # Put all the raws together
     structure = ['\n# Structure Details'] + structure_mat + structure
     growths   = ['\n# Growth Details']    + growth_mats   + growths
     products  = ['\n# Product Details']   + product_mats  + products
     seed      = ['\n# Seed Details']      + seed_mat      + seed
     raws = raws + structure + seed + growths + products
   
     if material_source == 'local':
      mat_str = 'LOCAL_PLANT_MAT'
     elif material_source == 'global':
      mat_str = 'PLANT_MAT:COMMON_PLANT'
   
     raw_string = '\n'.join(raws)
     # Replace RAW tokens
     raw_string = raw_string.replace('#DESCRIPTION', description)
     raw_string = raw_string.replace('#SEASONS',     season)
     raw_string = raw_string.replace('#ENVIRONMENT', environment)
     raw_string = raw_string.replace('#BIOME',       biome)
     raw_string = raw_string.replace('#PREFSTRING',  prefstring)
     raw_string = raw_string.replace('#PLANT_MAT',   mat_str)
     ## Base replacements
     raw_string = raw_string.replace('#NAME_SINGULAR', name['singular'])
     raw_string = raw_string.replace('#NAME_PLURAL',   name['plural'])
     raw_string = raw_string.replace('#NAME_ADJ',      name['adjective'])
     raw_string = raw_string.replace('#NAME_SEED',     name['seed'])
     raw_string = raw_string.replace('#COLOR_BASE', colorValues['base'].get('NAME','0:0:0'))
     raw_string = raw_string.replace('#COLOR_SEED', colorValues['base'].get('SEED','0:0:0'))
     raw_string = raw_string.replace('#COLOR_shell',colorValues['base'].get('shell','0:0:0'))
     ## Growth replacements
     for key in plantRaws.Growths.keys():
      raw_string = raw_string.replace('#NAME_GROWTH_'+key, name['growths'].get(key,key.lower().replace('_',' ')))
      raw_string = raw_string.replace('#COLOR_GROWTH_'+key, colorValues['growths'].get(key,{}).get('NAME','0:0:0'))
     ## Product replacements
     for key in plantRaws.Products.keys():
      raw_string = raw_string.replace('#NAME_PRODUCT_'+key, name['products'].get(key,key.lower().replace('_',' ')))
      raw_string = raw_string.replace('#COLOR_PRODUCT_'+key, colorValues['products'].get(key,'0:0:0'))
   
     return raw_string
