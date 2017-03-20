import os
import fnmatch
import random

class rcc:
 def read_templates():
 #TEMPLATES
  files = []
  
  for fname in os.listdir('templates/'):
   if fname.count('templates') > 0:
    files.append(os.getcwd()+'/templates/'+fname)

  types = ['DESCRIPTION','NAME','TEMPLATES','WEIGHT','GENUS','SPECIES','ARGS','TOKENS','ATTACKS','BODY','LINK','PERCENT','EXCEPT','BP_COLORS','REPLACEMENTS','ITERATIONS','RAW']

  data_dict = {}
  data_store = {}
  for fname in files:
#   try:
   f = open(fname)
   data = []
   for row in f:
    data.append(row)

   type1 = 'BLANK'
   template = 'BLANK'
   for i in range(len(data)):
    dstrip = data[i].strip()
    if dstrip.count('[TEMPLATE:') >= 1 and dstrip.count('=') == 0:
     type1 = dstrip.split(':')[1]
     template = dstrip.split(':')[2].split(']')[0]
     try:
      data_dict[type1][template] = {}
      data_store[type1][template] = []
      for subtype in types:
       data_dict[type1][template][subtype] = []
     except:
      data_dict[type1] = {}
      data_store[type1] = {}
      data_dict[type1][template] = {}
      data_store[type1][template] = []
      for subtype in types:
       data_dict[type1][template][subtype] = []
    elif dstrip.count('{') >= 1 and template != 'BLANK' and dstrip.count('=') == 0:
     entry = dstrip.split(':')[0].split('{')[1]
     data_dict[type1][template][entry] = dstrip.partition(':')[2].split('}')[0].split(',')
     data_store[type1][template].append(data[i])
    elif template != 'BLANK' and dstrip.count('=') == 0 and dstrip.count('[') >= 1:
     data_dict[type1][template]['RAW'].append(dstrip)
     data_store[type1][template].append(data[i])

  temp = {}
  dict_temp = {}
  store_temp = {}
  for type1 in data_dict.keys():
   temp[type1] = []
   dict_temp[type1] = {}
   store_temp[type1] = {}
   for template in data_dict[type1].keys():
    if data_dict[type1][template]['REPLACEMENTS']:
     num_replace = len(data_dict[type1][template]['REPLACEMENTS'])
     num_options = len(data_dict[type1][template]['REPLACEMENTS'][0].split(':'))
     for i in range(num_options):
      if template.count('REPLACE') == 0:
       new_template = template+'_'+str(i+1)
      else:
       new_template = template
       for k in range(num_replace):
        replace = '#REPLACE'+str(k+1)
        replacements = data_dict[type1][template]['REPLACEMENTS'][k]
        replacement = replacements.split(':')[i]
        new_template = new_template.replace(replace,replacement)
      dict_temp[type1][new_template] = {}
      store_temp[type1][new_template] = []
      for entry in data_dict[type1][template].keys():
       if entry != 'REPLACEMENTS':
        dict_temp[type1][new_template][entry] = []
        for j in range(len(data_dict[type1][template][entry])):
         dict_temp[type1][new_template][entry].append(data_dict[type1][template][entry][j])
         for k in range(num_replace):
          replace = '#REPLACE'+str(k+1)
          replacements = data_dict[type1][template]['REPLACEMENTS'][k]
          replacement = replacements.split(':')[i]
          dict_temp[type1][new_template][entry][j] = dict_temp[type1][new_template][entry][j].replace(replace,replacement)
      for j in range(len(data_store[type1][template])):
       if data_store[type1][template][j].count('REPLACEMENTS') == 0:
        store_temp[type1][new_template].append(data_store[type1][template][j])
        for k in range(num_replace):
         replace = '#REPLACE'+str(k+1)
         replacements = data_dict[type1][template]['REPLACEMENTS'][k]
         replacement = replacements.split(':')[i]
         store_temp[type1][new_template][-1] = store_temp[type1][new_template][-1].replace(replace,replacement)
     temp[type1].append(template)
  
  for type1 in temp.keys():
   for i in range(len(temp[type1])):
    del data_dict[type1][temp[type1][i]]
    del data_store[type1][temp[type1][i]]
   for key in dict_temp[type1].keys():
    data_dict[type1][key] = dict_temp[type1][key]
    data_store[type1][key] = store_temp[type1][key]

  temp = {}
  dict_temp = {}
  store_temp = {}
  for type1 in data_dict.keys():
   temp[type1] = []
   dict_temp[type1] = {}
   store_temp[type1] = {}
   for template in data_dict[type1].keys():
    if data_dict[type1][template]['ITERATIONS']:
     num_replace = len(data_dict[type1][template]['ITERATIONS'])
     num_options = len(data_dict[type1][template]['ITERATIONS'][0].split(':'))
     for i in range(num_options):
      if template.count('ITERATE') == 0:
       new_template = template+'_'+str(i+1)
      else:
       new_template = template
       for k in range(num_replace):
        replace = '#ITERATE'+str(k+1)
        replacements = data_dict[type1][template]['ITERATIONS'][k]
        replacement = replacements.split(':')[i]
        new_template = new_template.replace(replace,replacement)
      dict_temp[type1][new_template] = {}
      store_temp[type1][new_template] = []
      for entry in data_dict[type1][template].keys():
       if entry != 'ITERATIONS':
        dict_temp[type1][new_template][entry] = []
        for j in range(len(data_dict[type1][template][entry])):
         dict_temp[type1][new_template][entry].append(data_dict[type1][template][entry][j])
         for k in range(num_replace):
          replace = '#ITERATE'+str(k+1)
          replacements = data_dict[type1][template]['ITERATIONS'][k]
          replacement = replacements.split(':')[i]
          dict_temp[type1][new_template][entry][j] = dict_temp[type1][new_template][entry][j].replace(replace,replacement)
      for j in range(len(data_store[type1][template])):
       if data_store[type1][template][j].count('ITERATIONS') == 0:
        store_temp[type1][new_template].append(data_store[type1][template][j])
        for k in range(num_replace):
         replace = '#ITERATE'+str(k+1)
         replacements = data_dict[type1][template]['ITERATIONS'][k]
         replacement = replacements.split(':')[i]
         store_temp[type1][new_template][-1] = store_temp[type1][new_template][-1].replace(replace,replacement)
     temp[type1].append(template)

  for type1 in temp.keys():
   for i in range(len(temp[type1])):
    del data_dict[type1][temp[type1][i]]
    del data_store[type1][temp[type1][i]]
   for key in dict_temp[type1].keys():
    data_dict[type1][key] = dict_temp[type1][key]
    data_store[type1][key] = store_temp[type1][key]

  return data_dict,data_store

 def get_tokens(data):
  tokens = {}
  for key in data.keys():
   for subkey in data[key].keys():
    for tok in data[key][subkey]['PERCENT']:
     tokens[tok] = 1
  return tokens

 def get_args(data):
  args = {}
  for key in data.keys():
   for subkey in data[key].keys():
    for arg in data[key][subkey]['ARGS']:
     args[arg] = 1
  return args

 def fillDefaults(numbers):
  numbers['number'].set(10)
  numbers['size']['mean'].set(20000)
  numbers['size']['sigma'].set(2500)
  numbers['size']['min'].set(10)
  numbers['size']['vermin'].set(100)
  numbers['size']['tiny'].set(25)
  numbers['size']['trade'].set(25000)
  numbers['age']['max'].set(100)
  numbers['age']['min'].set(25)
  numbers['age']['baby'].set(1)
  numbers['age']['child'].set(10)
  numbers['age']['delta'].set(5)
  numbers['population']['max'].set(10)
  numbers['population']['min'].set(3)
  numbers['cluster']['max'].set(5)
  numbers['cluster']['min'].set(2)
  numbers['interaction']['max'].set(2)
  numbers['interaction']['chance'].set(50)
  numbers['caste']['male'].set(1)
  numbers['caste']['female'].set(1)
  numbers['subtypes'].set(3)
  numbers['speed']['WALK']['max'].set(80)
  numbers['speed']['WALK']['min'].set(5)
  numbers['speed']['SWIM']['max'].set(20)
  numbers['speed']['SWIM']['min'].set(1)
  numbers['speed']['FLY']['max'].set(0)
  numbers['speed']['FLY']['min'].set(0)
  numbers['speed']['CLIMB']['max'].set(6)
  numbers['speed']['CLIMB']['min'].set(1)
  numbers['speed']['CRAWL']['max'].set(6)
  numbers['speed']['CRAWL']['min'].set(1)

 creature = {}
 numbers = {}

 data,store = read_templates()
 args = get_args(data)
 tokens = get_tokens(data)
 status = {}
 for key in data.keys():
  status[key] = {}
  status[key]['All'] = "on"
  for subkey in data[key].keys():
   status[key][subkey] = "on"

 gaits = ['WALK','FLY','SWIM','CRAWL','CLIMB']
 gaits_cvs = {'WALK':'STANDARD_WALKING_GAITS',
              'FLY':'STANDARD_FLYING_GAITS',
              'SWIM':'STANDARD_SWIMMING_GAITS',
              'CRAWL':'STANDARD_CRAWLING_GAITS',
              'CLIMB':'STANDARD_CLIMBING_GAITS'
             }
 phys_attributes = ['STRENGTH','AGILITY','ENDURANCE','TOUGHNESS','RECUPERATION','RESISTANCE']
 ment_attributes = ['WILLPOWER','FOCUS','CREATIVITY','INTUITION','PATIENCE','MEMORY','KINESTHETIC',
                    'SPATIAL','EMPATHY','ANALYTICAL','LINGUISTIC','MUSICALITY','SOCIAL']
 active = {'CREPUSCULAR':'at dawn and dusk',
           'NOCTURNAL':'at night',
           'DIURNAL':'during the day',
           'MATUTINAL':'at dawn',
           'VESPERTINE':'at dusk',
           'ALL_ACTIVE':'all the time'
          }
 variability = ['HEIGHT','BROADNESS','LENGTH']
 checks = {'Attacks':['ATTACK','INTERACTION'],
           'Materials':['MATERIAL'],
           'BodyParts':['HEAD','TORSO','LEG','ARM'],
           'BodyParts2':['HAND','FINGER','FOOT','TOE'],
           'Attachments':['ATTACHMENT_HEAD','ATTACHMENT_TORSO','ATTACHMENT_LIMB','ATTACHMENT_MISC'],
           'Internal':['ORGANS','SKELETAL','EXTRACT'],
           'FacialFeatures':['EYE','EAR','NOSE','MOUTH'],
           'FacialFeatures2':['TONGUE','TOOTH','DETAILS'],
           'Biomes':['BIOME','TYPE','SUBTYPE','CASTE']
          }
 body_order = ['TORSO','HEAD','LEG','ARM','HAND','FOOT','FINGER','TOE','EAR','EYE','NOSE','MOUTH','TONGUE',
               'TOOTH','DETAILS','ORGANS','SKELETAL','ATTACHMENT_HEAD','ATTACHMENT_TORSO','ATTACHMENT_LIMB','ATTACHMENT_MISC']
 body_templates = {'TORSO':'Torso',
                   'HEAD':'Head',
                   'LEG':'Leg',
                   'ARM':'Arm',
                   'HAND':'Hand',
                   'FOOT':'Foot',
                   'FINGER':'Finger',
                   'TOE':'Toe',
                   'EAR':'Ear',
                   'EYE':'Eye',
                   'NOSE':'Nose',
                   'MOUTH':'Mouth',
                   'TONGUE':'Tongue',
                   'TOOTH':'Tooth',
                   'DETAILS':'Details',
                   'ORGANS':'Organs',
                   'SKELETAL':'Skeleton',
                   'ATTACHMENT_HEAD':'AttachmentHead',
                   'ATTACHMENT_TORSO':'AttachmentTorso',
                   'ATTACHMENT_LIMB':'AttachmentLimb',
                   'ATTACHMENT_MISC':'AttachmentMisc'
                  }
 speed_vals = [
 '9000:8900:8825:8775:9500:9900',
 '8390:8204:8040:4388:8989:9567',
 '7780:7508:7254:2925:8478:9233',
 '7171:6811:6469:2193:7967:8900',
 '6561:6115:5683:1755:7456:8567',
 '5951:5419:4898:1463:6944:8233',
 '5341:4723:4112:1254:6433:7900',
 '4732:4026:3327:1097:5922:7567',
 '4122:3330:2541:975:5411:7233',
 '3512:2634:1756:878:4900:6900',
 '3251:2446:1640:798:4600:6500',
 '2990:2257:1525:731:4300:6100',
 '2728:2069:1409:675:4000:5700',
 '2467:1880:1294:627:3700:5300',
 '2206:1692:1178:585:3400:4900',
 '1945:1504:1062:548:3100:4500',
 '1683:1315:947:516:2800:4100',
 '1422:1127:831:488:2500:3700',
 '1161:938:716:462:2200:3300',
 '900:750:600:439:1900:2900',
 '900:746:592:418:1900:2900',
 '900:742:584:399:1900:2900',
 '900:738:576:382:1900:2900',
 '900:734:568:366:1900:2900',
 '900:730:561:351:1900:2900',
 '900:726:553:338:1900:2900',
 '900:722:545:325:1900:2900',
 '900:718:537:313:1900:2900',
 '900:714:529:303:1900:2900',
 '900:711:521:293:1900:2900',
 '900:707:513:283:1900:2900',
 '900:703:505:274:1900:2900',
 '900:699:497:266:1900:2900',
 '900:695:489:258:1900:2900',
 '900:691:482:251:1900:2900',
 '900:687:474:244:1900:2900',
 '900:683:468:237:1900:2900',
 '900:679:458:231:1900:2900',
 '900:675:450:225:1900:2900',
 '900:657:438:219:1900:2900',
 '900:642:428:214:1900:2900',
 '900:627:418:209:1900:2900',
 '900:612:408:204:1900:2900',
 '900:597:398:199:1900:2900',
 '900:585:390:195:1900:2900',
 '900:573:382:191:1900:2900',
 '900:561:374:187:1900:2900',
 '900:549:366:183:1900:2900',
 '900:537:358:179:1900:2900',
 '900:528:352:176:1900:2900',
 '900:519:346:173:1900:2900',
 '900:507:338:169:1900:2900',
 '900:498:332:166:1900:2900',
 '900:489:326:163:1900:2900',
 '900:480:320:160:1900:2900',
 '900:471:314:157:1900:2900',
 '900:462:308:154:1900:2900',
 '900:453:302:151:1900:2900',
 '900:447:298:149:1900:2900',
 '900:438:292:146:1900:2900',
 '900:432:288:144:1900:2900',
 '900:426:284:142:1900:2900',
 '900:417:278:139:1900:2900',
 '900:411:274:137:1900:2900',
 '900:405:270:135:1900:2900',
 '900:399:266:133:1900:2900',
 '900:393:262:131:1900:2900',
 '900:387:258:129:1900:2900',
 '900:381:254:127:1900:2900',
 '900:375:250:125:1900:2900',
 '900:372:248:124:1900:2900',
 '900:366:244:122:1900:2900',
 '900:360:240:120:1900:2900',
 '900:357:238:119:1900:2900',
 '900:351:234:117:1900:2900',
 '900:345:230:115:1900:2900',
 '900:342:228:114:1900:2900',
 '900:336:224:112:1900:2900',
 '900:333:222:111:1900:2900',
 '900:327:218:109:1900:2900',
 '900:324:216:108:1900:2900',
 '900:321:214:107:1900:2900',
 '900:315:210:105:1900:2900',
 '900:312:208:104:1900:2900',
 '900:309:206:103:1900:2900',
 '900:306:204:102:1900:2900',
 '900:300:200:100:1900:2900'
 ]                                                                                                                                                           

 colors = ['BLACK','CLEAR','GRAY','SILVER','WHITE','TAUPE_ROSE','CHESTNUT','MAROON','RED','VERMILION','RUSSET','SCARLET',
           'BURNT_UMBER','TAUPE_MEDIUM','DARK_CHESTNUT','BURNT_SIENNA','RUST','AUBURN','MAHOGANY','PUMPKIN','CHOCOLATE',
           'TAUPE_PALE','TAUPE_DARK','DARK_PEACH','COPPER','LIGHT_BROWN','BRONZE','PALE_BROWN','DARK_BROWN','SEPIA',
           'OCHRE','BROWN','CINNAMON','TAN','RAW_UMBER','ORANGE','PEACH','TAUPE_SANDY','GOLDENROD','AMBER','DARK_TAN',
           'SAFFRON','ECRU','GOLD','PEARL','BUFF','FLAX','BRASS','GOLDEN_YELLOW','LEMON','CREAM','BEIGE','OLIVE','YELLOW',
           'IVORY','LIME','YELLOW_GREEN','DARK_OLIVE','CHARTREUSE','FERN_GREEN','MOSS_GREEN','GREEN','MINT_GREEN',
           'ASH_GRAY','EMERALD','SEA_GREEN','SPRING_GREEN','DARK_GREEN','JADE','AQUAMARINE','PINE_GREEN','TURQUOISE',
           'PALE_BLUE','TEAL','AQUA','LIGHT_BLUE','CERULEAN','SKY_BLUE','CHARCOAL','SLATE_GRAY','MIDNIGHT_BLUE','AZURE',
           'COBALT','LAVENDER','DARK_BLUE','BLUE','PERIWINKLE','DARK_VIOLET','AMETHYST','DARK_INDIGO','VIOLET','INDIGO',
           'PURPLE','HELIOTROPE','LILAC','PLUM','TAUPE_PURPLE','TAUPE_GRAY','FUCHSIA','MAUVE','LAVENDER_BLUSH','DARK_PINK',
           'MAUVE_TAUPE','DARK_SCARLET','PUCE','CRIMSON','PINK','CARDINAL','CARMINE','PALE_PINK','PALE_CHESTNUT'
          ]
 color_keys = ['BLACK','WHITE','RED','BROWN','YELLOW','GREEN','BLUE','ORANGE','PURPLE','PINK']
 color_groups = {'BLACK':['BLACK','CHARCOAL'],
                 'WHITE':['GRAY','SILVER','WHITE','IVORY','PEARL','ASH_GRAY'],
                 'RED':['TAUPE_ROSE','CHESTNUT','MAROON','RED','VERMILION','RUSSET','SCARLET'],
                 'BROWN':['PUMPKIN','CHOCOLATE','TAUPE_PALE','TAUPE_DARK','DARK_PEACH','COPPER','LIGHT_BROWN'],
                 'YELLOW':['SAFFRON','ECRU','GOLD','BUFF','FLAX','BRASS','GOLDEN_YELLOW','LEMON','CREAM','BEIGE','OLIVE','YELLOW'],
                 'GREEN':['LIME','YELLOW_GREEN','DARK_OLIVE','CHARTREUSE','FERN_GREEN','MOSS_GREEN','GREEN','MINT_GREEN','EMERALD','SEA_GREEN','SPRING_GREEN','DARK_GREEN','JADE','AQUAMARINE','PINE_GREEN'],
                 'BLUE':['TURQUOISE','PALE_BLUE','TEAL','AQUA','LIGHT_BLUE','CERULEAN','SKY_BLUE','MIDNIGHT_BLUE','AZURE','COBALT','LAVENDER','DARK_BLUE','BLUE'],
                 'ORANGE':['ORANGE','TAUPE_SANDY','GOLDENROD','AMBER','DARK_TAN','SAFFRON'],
                 'PURPLE':['DARK_VIOLET','AMETHYST','DARK_INDIGO','VIOLET','INDIGO','PURPLE','HELIOTROPE','LILAC','PLUM','TAUPE_PURPLE'],
                 'PINK':['FUCHSIA','MAUVE','LAVENDER_BLUSH','DARK_PINK','MAUVE_TAUPE','DARK_SCARLET','PUCE','CRIMSON','PINK','CARDINAL','CARMINE','PALE_PINK','PALE_CHESTNUT']
                 }
 color_names = {'BLACK':['black','charcoal'],
                'WHITE':['gray','silver','white','ivory'],
                'RED':['rose','maroon','red','scarlet'],
                'BROWN':['pale','light brown','copper','brown'],
                'YELLOW':['gold','brass','beige','yellow'],
                'GREEN':['green','emerald','jade'],
                'BLUE':['turquoise','teal','azure','cobalt','blue'],
                'ORANGE':['orange','sandy','amber'],
                'PURPLE':['violet','amethyst','purple'],
                'PINK':['crimson','pink','scarlet']
               }


 eye_colors = ['IRIS_EYE_AMETHYST','IRIS_EYE_AQUAMARINE','IRIS_EYE_BRASS','IRIS_EYE_BRONZE','IRIS_EYE_COBALT',
               'IRIS_EYE_COPPER','IRIS_EYE_EMERALD','IRIS_EYE_GOLD','IRIS_EYE_HELIOTROPE','IRIS_EYE_JADE',
               'IRIS_EYE_OCHRE','IRIS_EYE_RAW_UMBER','IRIS_EYE_RUST','IRIS_EYE_SILVER','IRIS_EYE_SLATE_GRAY',
               'IRIS_EYE_TURQUOISE'
              ]
 eye_color_names = {'IRIS_EYE_AMETHYST':'amethyst',
                    'IRIS_EYE_AQUAMARINE':'aquamarine',
                    'IRIS_EYE_BRASS':'brass',
                    'IRIS_EYE_BRONZE':'bronze',
                    'IRIS_EYE_COBALT':'cobalt',
                    'IRIS_EYE_COPPER':'copper',
                    'IRIS_EYE_EMERALD':'emerald',
                    'IRIS_EYE_GOLD':'golden',
                    'IRIS_EYE_HELIOTROPE':'purple',
                    'IRIS_EYE_JADE':'jade',
                    'IRIS_EYE_OCHRE':'brown',
                    'IRIS_EYE_RAW_UMBER':'brown',
                    'IRIS_EYE_RUST':'brown',
                    'IRIS_EYE_SILVER':'silver',
                    'IRIS_EYE_SLATE_GRAY':'gray',
                    'IRIS_EYE_TURQUOISE':'turquoise'
                   }

 part_keys = ['SCALE','CHITIN','SKIN','HAIR','FEATHER','HORN','TUSK','CREST','FRILL','BEAK','BILL']
 part_names = {'SCALE':'scaled',
               'CHITIN':'chitinous',
               'SKIN':'skinned',
               'HAIR':'haired',
               'FEATHER':'feathered',
               'HORN':'horned',
               'TUSK':'tusked',
               'CREST':'crested',
               'FRILL':'frilled',
               'BEAK':'beaked',
               'BILL':'billed'
              }

