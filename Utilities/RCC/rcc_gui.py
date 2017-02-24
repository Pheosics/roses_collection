from tkinter import *
import os
import fnmatch
from tkinter import tix
from tkinter import filedialog
import random

# SPECIAL TOKENS
#VERMIN - Checks if the creature is the correct size for vermin (defined by Size: Vermin)
#TINY - Checks if the creature is the correct size for tiny vermin (defined by Size: Tiny)
#TRADER - Checks if the creature is the correct size for a trading animal (defined by Size: Trade)
#MALE - Used for defining male castes in TEMPLATE:CASTE - LINK
#FEMALE - Used for defining female castes in TEMPLATE:CASTE - LINK
#DESC - Used to fill in the creature description when creating raws, very little use for this as the script currently creates a description for each caste already
#NAME - Used to fill the the creatue name when creating raws, very useful, allows for naming of things directly in the templates
#ARG1, #ARG2, #ARG3, etc... - Used to fill in the arguments provided in TEMPLATE - ARGS
#SWIMMING_GAITS - If this tag is present in a creature (no matter which template the creature recieved it from) will alter the gaits, flipping the WALK and SWIM gaits
#ONLY_SWIMMING - Same effect as above, but removes all other gaits (WALK, CLIMB, CRAWL, FLY) 
#FLYING_GAITS - If this tag is present in a creature (no matter which template the creature recieved it from) will alter the gaits, moving WALK to FLY and CRAWL to WALK
#ONLY_FLYING - Same effect as above, but removes all other gaits (WALK, CLIMB, CRAWL, SWIM)
#NOARMS - Removes the CLIMB gait
#NOLEGS - Removes the WALK gait

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
part_keys = ['SCALE','CHITIN','SKIN','HAIR','FEATHER','HORN','TUSK']
part_names = {'SCALE':'scaled',
              'CHITIN':'chitinous',
              'SKIN':'skinned',
              'HAIR':'haired',
              'FEATHER':'feathered',
              'HORN':'horned',
              'TUSK':'tusked'
             }
def read_templates():
#TEMPLATES
 files = []
 for file in os.listdir():
  if file.count('templates') > 0:
   files.append(file)

 types = ['DESCRIPTION','NAME','ARGS','TOKENS','ATTACKS','BODY','LINK','PERCENT','EXCEPT','BP_COLORS','RAW']

 data_dict = {}
 data_store = {}
 for file in files:
#  try:
  f = open(file)
  data = []
  for row in f:
   data.append(row)

  type = 'BLANK'
  template = 'BLANK'
  for i in range(len(data)):
   dstrip = data[i].strip()
   if dstrip.count('[TEMPLATE:') >= 1:
    type = dstrip.split(':')[1]
    template = dstrip.split(':')[2].split(']')[0]
    try:
     data_dict[type][template] = {}
     data_store[type][template] = []
     for subtype in types:
      data_dict[type][template][subtype] = []
    except:
     data_dict[type] = {}
     data_store[type] = {}
     data_dict[type][template] = {}
     data_store[type][template] = []
     for subtype in types:
      data_dict[type][template][subtype] = []
   elif dstrip.count('{') >= 1 and template != 'BLANK':
    entry = dstrip.split(':')[0].split('{')[1]
    data_dict[type][template][entry] = dstrip.partition(':')[2].split('}')[0].split(',')
    data_store[type][template].append(data[i])
   elif template != 'BLANK':
    data_dict[type][template]['RAW'].append(dstrip)
    data_store[type][template].append(data[i])


#  except:
#   print('No file found:',file)
# data_dict['BLANK'] = data_dict['BLANK'].clear()
# data_store['BLANK'] = data_store['BLANK'].clear()

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
 
if __name__ == '__main__':
 root = tix.Tk()

 canvas = tix.Canvas(root, width=1000, height=500)
 canvas.grid(row=0, column=0, sticky=N+S+E+W)
 root.grid_rowconfigure(0, weight=1)

 frame = tix.Frame(canvas)
 frame.rowconfigure(1, weight=1)
 frame.columnconfigure(1,weight=1)

 data,store = read_templates()
 tokens = get_tokens(data)
 args = get_args(data)
 gaits = ['WALK','FLY','SWIM','CRAWL','CLIMB']
 gaits_cvs = { 'WALK':'STANDARD_WALKING_GAITS','FLY':'STANDARD_FLYING_GAITS','SWIM':'STANDARD_SWIMMING_GAITS','CRAWL':'STANDARD_CRAWLING_GAITS','CLIMB':'STANDARD_CLIMBING_GAITS'}
 phys_attributes = ['STRENGTH','AGILITY','ENDURANCE','TOUGHNESS','RECUPERATION','RESISTANCE']
 ment_attributes = ['WILLPOWER','FOCUS','CREATIVITY','INTUITION','PATIENCE','MEMORY','KINESTHETIC','SPATIAL','EMPATHY','ANALYTICAL','LINGUISTIC','MUSICALITY','SOCIAL']
 active = {'CREPUSCULAR':'at dawn and dusk','NOCTURNAL':'at night','DIURNAL':'during the day','MATUTINAL':'at dawn','VESPERTINE':'at dusk','ALL_ACTIVE':'all the time'}
 status = {}
 for key in data.keys():
  status[key] = {}
  status[key]['All'] = "on"
  for subkey in data[key].keys():
   status[key][subkey] = "on"

 checks = {}
 checks['Attacks'] = ['ATTACK','INTERACTION']
 checks['Materials'] = ['MATERIAL']
 checks['BodyParts'] = ['HEAD','TORSO','LEG','ARM','HAND','FOOT']
 checks['Attachments'] = ['ATTACHMENT_HEAD','ATTACHMENT_TORSO','ATTACHMENT_LIMB','ATTACHMENT_MISC']
 checks['Internal'] = ['ORGANS','SKELETAL','EXTRACT']
 checks['FacialFeatures'] = ['EYE','EAR','NOSE','MOUTH']
 checks['Biomes'] = ['BIOME','TYPE','SUBTYPE','CASTE']

 class checkWindow:
  def __init__(self,ty):
   self.t =Toplevel(root)
   self.ty = ty
   self.makelist()

  def close(self):
   self.t.destroy()

  def update(self,item):
   if len(item.split('.')) == 1:
    stat_save = self.cl[item].getstatus(item)
    status[item]['All'] = stat_save
    for obj in data[item].keys():
     self.cl[item].setstatus(item+'.'+obj,stat_save)
     status[item][obj] = stat_save
   else:
    key1 = item.split('.')[0]
    key2 = item.split('.')[1]
    status[key1][key2] = self.cl[key1].getstatus(item)

  def checkAll(self):
   for type in checks[self.ty]:
    status[type]['All'] = "on"
    self.cl[type].setstatus(type,"on")
    for type2 in data[type].keys():
     self.cl[type].setstatus(type+'.'+type2,"on")
     status[type][type2] = "on"

  def uncheckAll(self):
   for type in checks[self.ty]:
    status[type]['All'] = "off"
    self.cl[type].setstatus(type,"off")
    for type2 in data[type].keys():
     self.cl[type].setstatus(type+'.'+type2,"off")
     status[type][type2] = "off"

  def makelist(self):
   listBalloon = tix.Balloon(self.t)
   c = 0
   self.cl = {}
   for type in checks[self.ty]:
    j = 0
    self.cl[type] = tix.CheckList(self.t, width = 250, height=400, browsecmd=self.update)
    self.cl[type].grid(row=0,column=c)
    self.cl[type].hlist.add(type, text=type)
    self.cl[type].setstatus(type,status[type]['All'])
    temp = list(data[type].keys())
    temp.sort()
    for subtype in temp:
     j = j + 1
     hl = tix.Label(self.cl[type],text="?")
     hl.place(in_=self.cl[type],x=235,y=13*j,width=10)
#     hl.place_forget()
     self.cl[type].hlist.add(type+'.'+subtype,text=subtype)
     self.cl[type].setstatus(type+'.'+subtype,status[type][subtype])
#     print(self.cl[type].subwidgets_all())
     listBalloon.bind_widget(hl,msg=''.join(store[type][subtype]))
#     hl.place_forget()
    self.cl[type].autosetmode()
    c = c + 1
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.add('check', text='Check All', command=self.checkAll)
   self.bb.add('uncheck', text='Uncheck All', command=self.uncheckAll)
   self.bb.grid(row=0,column=c)
 class argWindow:
  def __init__(self,ty):
   self.t =Toplevel(root)
   self.ty = ty
   self.makelist()

  def close(self):
   self.t.destroy()

  def makelist(self):
   argsBalloon = tix.Balloon(self.t)
   
   arg = {}
   arg_variables = ['max','min']
   temp = list(args.keys())
   temp.sort()
   labels = {}
   bLabel = tix.Label(self.t,text='All arguments found in the Templates\nWhen each creature is generated a value is chosen for each argument\nThe value is selected from a triangular distribution between Min and Max')
   r = 0
   c = 1
   for key in temp:
    r = r + 1
    arg[key] = {}
    if r > 12:
     c = c + 1
     r = 1
    labels[key] = tix.Label(self.t,text=key.capitalize()+':').grid(row=r,column=c,stick=tix.W)
    for var in arg_variables:
     r = r + 1
     arg[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=numbers['args'][key][var].get(),variable=numbers['args'][key][var],autorepeat=False)
     arg[key][var].subwidget('decr').destroy()
     arg[key][var].subwidget('incr').destroy()
     arg[key][var].grid(row=r,column=c,stick=tix.E,padx=10)   
   
   bLabel.grid(row=0,column=0,columnspan=c)
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.grid(row=0,column=c+1)
 class speedWindow:
  def __init__(self,ty):
   self.t =Toplevel(root)
   self.ty = ty
   self.makelist()

  def close(self):
   self.t.destroy()

  def makelist(self):
   speedBalloon = tix.Balloon(self.t)

   speed = {}
   speed_variables = ['max','min']
   temp = gaits
   temp.sort()
   labels = {}
   bLabel = tix.Label(self.t,text='Speed of various gaits in kph\nChosen from a triangular distribution between Min and Max\nSee the readme for additional information')
   r = 0
   c = 1
   for key in temp:
    r = r + 1
    speed[key] = {}
    if r > 12:
     c = c + 1
     r = 1
    labels[key] = tix.Label(self.t,text=key.capitalize()+':').grid(row=r,column=c,stick=tix.W)
    for var in speed_variables:
     r = r + 1
     speed[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=numbers['speed'][key][var].get(),variable=numbers['speed'][key][var],autorepeat=False)
     speed[key][var].subwidget('decr').destroy()
     speed[key][var].subwidget('incr').destroy()
     speed[key][var].grid(row=r,column=c,stick=tix.E,padx=10)

   bLabel.grid(row=0,column=0,columnspan=c)
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.grid(row=0,column=c+1)
 class advancedWindow:
  def __init__(self,ty):
   self.t =Toplevel(root)
   self.ty = ty
   self.makelist()

  def close(self):
   self.t.destroy()

  def makelist(self):
   advBalloon = tix.Balloon(self.t)
   r = 0
   c = 0
   attribute = {}
   attribute_variables = ['max','min','sigma']
   temp = phys_attributes
   temp.sort()
   labels = {}
   labels['Phys_Atts'] = tix.Label(self.t,text='Physical\nAttributes')
   labels['Phys_Atts'].grid(row=r,column=c)
   for key in temp:
    r = r + 1
    attribute[key] = {}
    labels[key] = tix.Label(self.t,text=key.capitalize()+':').grid(row=r,column=c,stick=tix.W)
    for var in attribute_variables:
     r = r + 1
     attribute[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=numbers['attributes'][key][var].get(),variable=numbers['attributes'][key][var],autorepeat=False)
     attribute[key][var].subwidget('decr').destroy()
     attribute[key][var].subwidget('incr').destroy()
     attribute[key][var].grid(row=r,column=c,stick=tix.E,padx=10)
   advBalloon.bind_widget(labels['Phys_Atts'],msg='Physical attribute tokens [PHYS_ATT_RANGE:STRENGTH:a:b:c:d:e:f:g] are calculated as follows:\n  a is taken from a gaussian distribution with mean Min and sigma Sigma\n  g is taken from a gaussian distribution with mean Max and sigma Sigma\n  d = (a+g)/2\n  c/e = d -/+ 2*(g-d)/10\n  b/f = d -/+ 5*(g-d)/10\nIf Max is 0 then the attribute token is not added to the creature')

   r = 0
   c = 1
   temp = ment_attributes
   temp.sort()
   labels = {}
   for key in temp:
    r = r + 1
    if r >= 23:
     r = 1
     c += 1
    attribute[key] = {}
    labels[key] = tix.Label(self.t,text=key.capitalize()+':').grid(row=r,column=c,stick=tix.W)
    for var in attribute_variables:
     r = r + 1
     attribute[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=numbers['attributes'][key][var].get(),variable=numbers['attributes'][key][var],autorepeat=False)
     attribute[key][var].subwidget('decr').destroy()
     attribute[key][var].subwidget('incr').destroy()
     attribute[key][var].grid(row=r,column=c,stick=tix.E,padx=10)
   labels['Ment_Atts'] = tix.Label(self.t,text='Mental\nAttributes')
   labels['Ment_Atts'].grid(row=0,column=1,columnspan=c)
   advBalloon.bind_widget(labels['Ment_Atts'],msg='Mental attribute tokens [MENT_ATT_RANGE:WILLPOWER:a:b:c:d:e:f:g] are calculated as follows:\n  a is taken from a gaussian distribution with mean Min and sigma Sigma\n  g is taken from a gaussian distribution with mean Max and sigma Sigma\n  d = (a+g)/2\n  c/e = d -/+ 2*(g-d)/10\n  b/f = d -/+ 5*(g-d)/10\nIf Max is 0 then the attribute token is not added to the creature')
   
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.grid(row=0,column=c+1)
 class sampleWindow:
  def __init__(self,ty):
   self.t =Toplevel(root)
   self.ty = ty
   self.makelist()

  def close(self):
   self.t.destroy()

  def makelist(self):
   stext = tix.ScrolledText(self.t)
   stext.subwidget('text').insert(tix.INSERT,'\n'.join(self.ty['Raws']))
   stext.grid(row=0,column=0)
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.grid(row=0,column=1) 
   
 def makeNumbersTable(numbers,frame,tokens):
  numbersSubFrame = tix.Frame(frame)
  numbersSubFrame.rowconfigure(1)
  numbersSubFrame.columnconfigure(1)
  numbersBalloon = tix.Balloon(numbersSubFrame)

  numbers['args'] = {}
  for key in args:
   numbers['args'][key] = {}
   numbers['args'][key]['max'] = tix.IntVar()
   numbers['args'][key]['min'] = tix.IntVar()

  numbers['speed'] = {}
  for key in gaits:
   numbers['speed'][key] = {}
   numbers['speed'][key]['max'] = tix.IntVar()
   numbers['speed'][key]['min'] = tix.IntVar()

  numbers['attributes'] = {}
  for key in phys_attributes:
   numbers['attributes'][key] = {}
   numbers['attributes'][key]['max'] = tix.IntVar()
   numbers['attributes'][key]['min'] = tix.IntVar()
   numbers['attributes'][key]['sigma'] = tix.IntVar()
  for key in ment_attributes:
   numbers['attributes'][key] = {}
   numbers['attributes'][key]['max'] = tix.IntVar()
   numbers['attributes'][key]['min'] = tix.IntVar()
   numbers['attributes'][key]['sigma'] = tix.IntVar()   
   
  r=0
  c=0
  sizeLabel = tix.Label(numbersSubFrame,text='Sizes:')
  sizeLabel.grid(row=r,column=c,stick=tix.W) 
  numbers['size'] = {}
  creatureSize = {}
  size_variables = ['mean','sigma','min','vermin','tiny','trade']
  for var in size_variables:
   r = r + 1
   numbers['size'][var] = tix.IntVar()
   creatureSize[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=numbers['size'][var],autorepeat=False,integer=True)
   creatureSize[var].subwidget('decr').destroy()
   creatureSize[var].subwidget('incr').destroy()
   creatureSize[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(sizeLabel,msg='Size tokens [BODY_SIZE:x_1:y_1:a_1], [BODY_SIZE:x_2:y_2:a_2], and [BODY_SIZE:x_3:y_3:a_3] are calculated as follows:\n  a_3 is calculated by selecting a random number from a gaussian distribution with a mean Mean and sigma Sigma\n  a_1 is calculated by selecting a random number from a gaussian distribution with a mean a_3/100 and sigma Sigma/100\n  a_2 = a_1 + a_3*75%, if this is > a_3 then a_2 and a_3 are switched\n  x_1, y_1, y_2, and y_3 are all set to 0 for now\n  x_2 is taken from [BABY:n] (see Ages for calculation) such that x_2 = n + 1\n  x_3 is taken from [CHILD:n] (see Ages for calculation) such that x_3 = n + 2\nMin is the minimum size of any creature, if a_3 < Min then a_3 = Min\nVermin sets the maximum size needed for the #VERMIN flag, below this size #VERMIN is set to True\nTiny sets the maximum size needed for the #TINY flag, below this size #TINY is set to True\nTrade sets the minimum size needed for the #TRADE flag, above this size #TRADE is set to True\nMore information on the #VERMIN, #TINY, and #TRADE flags can be found in the readme')
  
  r=r+1
  ageLabel = tix.Label(numbersSubFrame,text='Ages:')
  ageLabel.grid(row=r,column=c,stick=tix.W) 
  numbers['age'] = {}
  creatureAge = {}
  age_variables = ['max','min','baby','child','delta']
  for var in age_variables:
   r = r + 1
   numbers['age'][var] = tix.IntVar()
   creatureAge[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=numbers['age'][var],autorepeat=False,integer=True)
   creatureAge[var].subwidget('decr').destroy()
   creatureAge[var].subwidget('incr').destroy()
   creatureAge[var].grid(row=r,column=c,stick=tix.E,padx=10)   
  numbersBalloon.bind_widget(ageLabel,msg='Ages tokens [MAX_AGE:a:b], [BABY:c], [CHILD:d] are calculated as follows:\n  a is chosen between Min and Max\n  b is chosen between Max and Max + Delta\n  c is chosen between Baby - Delta and Baby + Delta\n  d is chosen between Child - Delta and Child + Delta\nall choices are selected randomly from a triangular distribution\nif c > d then c is set to 0 and d is set to c\nif either c or d is 0 then that tag will not be added to the creature')

  r=0
  c=1
  popLabel = tix.Label(numbersSubFrame,text='Pop Numbers:')
  popLabel.grid(row=r,column=c,stick=tix.W) 
  numbers['population'] = {}
  creaturePopulation = {}
  pop_variables = ['max','min']
  for var in pop_variables:
   r = r + 1
   numbers['population'][var] = tix.IntVar()
   creaturePopulation[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=numbers['population'][var],autorepeat=False,integer=True)
   creaturePopulation[var].subwidget('decr').destroy()
   creaturePopulation[var].subwidget('incr').destroy()
   creaturePopulation[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(popLabel,msg='Population token [POPULATION_NUMBER:x:y] is calculated as follows:\n  x is chosen between 1 and Min\n  y is chosen between Min and Max\nchoices are selected randomly from a triangular distribution\nFor Vermin and Tiny creatures x = 250 and y = 500')

  r=r+1
  clusLabel = tix.Label(numbersSubFrame,text='Cluster Numbers:       ')
  clusLabel.grid(row=r,column=c,stick=tix.W) 
  numbers['cluster'] = {}
  creatureCluster = {}
  clus_variables = ['max','min']
  for var in clus_variables:
   r = r + 1
   numbers['cluster'][var] = tix.IntVar()
   creatureCluster[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=numbers['cluster'][var],autorepeat=False,integer=True)
   creatureCluster[var].subwidget('decr').destroy()
   creatureCluster[var].subwidget('incr').destroy()
   creatureCluster[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(clusLabel,msg='Cluster token [CLUSTER_NUMBER:x:y] is calculated as follows:\n  x is chosen between 1 and Min\n  y is chosen between Min and Max\nchoices are selected randomly from a triangular distribution\nFor Vermin and Tiny creatures the cluster token is not used')
  
  r=r+1
  intLabel = tix.Label(numbersSubFrame,text='Interactions:')
  intLabel.grid(row=r,column=c,stick=tix.W) 
  numbers['interaction'] = {}
  creatureInteraction = {}
  clus_variables = ['max','chance']
  for var in clus_variables:
   r = r + 1
   numbers['interaction'][var] = tix.IntVar()
   creatureInteraction[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=numbers['interaction'][var],autorepeat=False,integer=True)
   creatureInteraction[var].subwidget('decr').destroy()
   creatureInteraction[var].subwidget('incr').destroy()
   creatureInteraction[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(intLabel,msg='Max is the maximum number of interactions and one creature can have\nChance is the percent chance that each interaction slot is filled\nFor example, if Max is 3 and Chance is 50 then slot 1 will have a 50% chance of being filled, slot 2 will have a 50% chance of being filled, and slot 3 will have a 50% chance of being filled\nThis, of course, is dependent on their being 3 interactions that the creature meets the criteria for')

  r=r+1
  casteLabel = tix.Label(numbersSubFrame,text='Castes:')
  casteLabel.grid(row=r,column=c,stick=tix.W) 
  numbers['caste'] = {}
  creatureCaste = {}
  clus_variables = ['male','female','neutral']
  for var in clus_variables:
   r = r + 1
   numbers['caste'][var] = tix.IntVar()
   creatureCaste[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=numbers['caste'][var],autorepeat=False,integer=True)
   creatureCaste[var].subwidget('decr').destroy()
   creatureCaste[var].subwidget('incr').destroy()
   creatureCaste[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(casteLabel,msg='The maximum number of castes each creature can have which meets specific criteria\nMale sets the maximum number of castes with the #MALE LINK\nFemale sets the maximum number of castes with the #FEMALE LINK\nNeutral sets the maximum number of castes without the #MALE or #FEMALE LINK\nFor more information on LINKs and the #MALE and #FEMALE flags see the readme')
  
  r += 1
  subLabel = Label(numbersSubFrame,text='Subtypes:')
  subLabel.grid(row=r,column=c,stick=tix.W)
  r += 1
  numbers['subtypes'] = tix.IntVar()
  creatureSubtypes = tix.Control(numbersSubFrame,label='Max',min=0,value=0,variable=numbers['subtypes'],autorepeat=False,integer=True)
  creatureSubtypes.subwidget('decr').destroy()
  creatureSubtypes.subwidget('incr').destroy()
  creatureSubtypes.grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(subLabel,msg='Number of subtypes one creature can be, their total number of subtypes will be chosen between 0 and Max from a flat distribution')

  r = 0
  c = 2
  percLabel = Label(numbersSubFrame,text='Percents:')
  percLabel.grid(row=r,column=c,stick=tix.W)
  creaturePercentage = {}
  numbers['percents'] = {}
  temp = list(tokens.keys())
  temp.sort()
  for key in temp:
   r += 1
   numbers['percents'][key] = tix.IntVar()
   creaturePercentage[key] = tix.Control(numbersSubFrame,label='    '+key,min=0,value=0,variable=numbers['percents'][key],autorepeat=False,integer=True)
   creaturePercentage[key].subwidget('decr').destroy()
   creaturePercentage[key].subwidget('incr').destroy()
   creaturePercentage[key].grid(row=r,column=2,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(percLabel,msg='Percentage chance given token will be true\nIf you wish to generate a set of creatures that all share a commonality you would set the percent to 100')

  numbersSubFrame.grid(row=1,column=1)

 def fillDefaults():
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
  
 def generateCreatures():
  if numbers['seed'].get() == 0:
   random.seed()
  else:
   random.seed(numbers['seed'].get())
  j = 1
  file = 'creature_rcc_'+str(numbers['seed'].get())+'_'+str(numbers['number'].get())+'.txt'
  ofile = open(file,'w')
  ofile.write(file+'\n')
  ofile.write('\n[OBJECT:CREATURE]\n')
  while j < numbers['number'].get():
   ofile.write('\n')
   creature = createCreature(j)
   ofile.write('\n'.join(creature['Raws']))
   j += 1
  ofile.close()
 
 def createCreature(n):
  creature = {}
  creature['Parts'] = {}
  creature['Names'] = []
  creature['Colors'] = {}
  creature['Colors']['Parts'] = []

  pickCreature.getFlagsPercents(creature) #Computes token flags based on provided percentages
  pickCreature.getArgsNumbers(creature)
  pickCreature.getSize(creature) #Checks against #TRADE_ANIMAL and given sizes
  pickCreature.getSpeed(creature) #No checks
  pickCreature.getPops(creature) #No checks
  pickCreature.getAttributes(creature)
  pickCreature.getAge(creature)
  pickCreature.getType(creature) #Checks against percentages
  pickCreature.getBiome(creature) #Checks against links and percentages
  pickCreature.getBody(creature) #Checks against links and percentages
  pickCreature.getMaterials(creature) #Checks against links and percentages
  pickCreature.getCastes(creature)
  pickCreature.getSubTypes(creature) #Checks against all current tokens and percentages, and takes as many as are in max subtypes
  pickCreature.getExtracts(creature) #Checks against all current tokens and percentages, and takes as many as are valid
  pickCreature.getInteractions(creature) #Checks against all current tokens and percentages, and takes as many as are in max interactions, with respect to interactions chance
  pickCreature.getAttacks(creature) #Fill in the attack table from all the other 
  
  generateCreature.createDescription(creature)
  generateCreature.createBodyToken(creature)
  generateCreature.createSpeedToken(creature)
  generateCreature.createAgeToken(creature)
  generateCreature.createSizeToken(creature)
  generateCreature.createPopToken(creature)
  generateCreature.createAttributeToken(creature)
  generateCreature.createColors(creature)
  generateCreature.createName(creature)
  generateCreature.createRaws(creature,n)

  return creature

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
    creature['Names'] += data['TYPE'][type]['NAME']
  def getSize(creature):
   creature['Size'] = {}
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
   for gait in gaits:
    creature['Speed'][gait.capitalize()] = int(random.triangular(numbers['speed'][gait]['min'].get(),numbers['speed'][gait]['max'].get()))
  def getPops(creature):
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
  def getBiome(creature):
   creature['Biome'] = ''
   creature['Parts']['Biome'] = []
   
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
    creature['Names'] += data['BIOME'][biome]['NAME']
  def getBody(creature):
   creature['Body'] = {}
   creature['Parts']['Body'] = []
   
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
     creature['Names'] += data[bodypart][part]['NAME']

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
     creature['Names'] += data[bodypart][part]['NAME']
  def getMaterials(creature):
   creature['Material'] = ''
   creature['Parts']['Material'] = []
   
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
    creature['Names'] += data['MATERIAL'][mat]['NAME']
  def getCastes(creature):
   creature['Caste'] = {}
   creature['Caste']['Male'] = []
   creature['Caste']['Female'] = []
   creature['Caste']['Neutral'] = []
   creature['Parts']['Male'] = {}
   creature['Parts']['Female'] = {}
   creature['Parts']['Neutral'] = {}
   
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
      creature['Names'] += data['SUBTYPE'][stype]['NAME']
     creature.update()
     temp_array.pop(stypen)
  def getInteractions(creature):
   creature['Interaction'] = []

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
       creature['Names'] += data['INTERACTION'][stype]['NAME']
      creature.update()
      temp_array.pop(stypen)
  def getExtracts(creature):
   creature['Extract'] = []

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
     creature['Names'] += data['EXTRACT'][extract]['NAME']
     creature.update()
  def getAttacks(creature):
   creature['Attacks'] = []

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
   creature['NameDict']['Adjectives'] = {}
   creature['NameDict']['Prefixes'] = {}
   creature['NameDict']['Mains'] = {}
   creature['NameDict']['Suffixes'] = {}
   
   for entry in creature['Names']:
    if entry.split(':')[0] == 'ADJ':
     creature['NameDict']['Adjectives'][entry.split(':')[1]] = 1
    if entry.split(':')[0] == 'PREFIX':
     creature['NameDict']['Prefixes'][entry.split(':')[1]] = 1
    if entry.split(':')[0] == 'MAIN':
     creature['NameDict']['Mains'][entry.split(':')[1]] = 1
    if entry.split(':')[0] == 'SUFFIX':
     creature['NameDict']['Suffixes'][entry.split(':')[1]] = 1
     
   num_adj = random.randint(0,2)
   num_prf = random.randint(0,1)
   num_man = random.randint(1,2)
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
   
   name = ' '.join(adjectives)+' '+''.join(prefix)+' '.join(main)+''.join(suffix)
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
# Button Comands
 def attacks():
  checkWindow('Attacks')
 def materials():
  checkWindow('Materials')
 def bodyparts():
  checkWindow('BodyParts')
 def attachments():
  checkWindow('Attachments')
 def internal():
  checkWindow('Internal')
 def face():
  checkWindow('FacialFeatures')
 def biomes():
  checkWindow('Biomes')
 def arguments():
  argWindow('Arguments')
 def speeds():
  speedWindow('Speeds')
 def close():
  return
 def sampleCreature():
  creature = createCreature(1)
  sampleWindow(creature)
 def advanced():
  advancedWindow('Advanced')
 def generate():
  generateCreatures()
 def defaults():
  fillDefaults()
 

 canvas.create_window(0,0,anchor=NW,window=frame)
 frame.update_idletasks()
 canvas.config(scrollregion=canvas.bbox('all'))
 
 numbers = {}
 makeNumbersTable(numbers,frame,tokens)
 
 mainBalloon = tix.Balloon(frame)
 templateLabel = tix.Label(frame,text='Templates')
 templateLabel.grid(row=0,column=0)
 mainBalloon.bind_widget(templateLabel,msg='Select which templates you wish to be considered for adding to creatures\nBy default all templates are active')
 bb = tix.ButtonBox(frame, orientation = tix.VERTICAL)
 bb.add('attack', text='Attacks and Interactions', command=attacks)
 bb.add('base', text='Body Materials', command=materials)
 bb.add('body', text='Body Parts', command=bodyparts)
 bb.add('attachments', text='Body Part Attachments', command=attachments)
 bb.add('internal', text='Organs, Bones, and Extracts', command=internal)
 bb.add('face', text='Facial Features', command=face)
 bb.add('biome', text='Biomes, Types, and Castes', command=biomes)
 bb.grid(row=1,column=0)
 
 bb2 = tix.ButtonBox(frame,orientation = tix.HORIZONTAL)
 bb2.add('arg', text='Argument Values', command=arguments)
 bb2.add('speed',text='Gait Speeds', command=speeds)
 bb2.add('advanced',text='Advanced Options', command=advanced)
 bb2.grid(row=2,column=1)
 
 numbers['seed'] = tix.IntVar()
 seedStore = tix.Control(frame,label='Seed',min=0,variable=numbers['seed'],autorepeat=False,integer=True)
 seedStore.subwidget('decr').destroy()
 seedStore.subwidget('incr').destroy()
 seedStore.grid(row=0,column=2,stick=tix.E)
 mainBalloon.bind_widget(seedStore,msg='Seed used for random number generation, if left at 0 will use a random seed')
 
 numbers['number'] = tix.IntVar()
 creatureNumber = tix.Control(frame,label='    Creatures',min=0,variable=numbers['number'],autorepeat=False,integer=True)
 creatureNumber.subwidget('decr').destroy()
 creatureNumber.subwidget('incr').destroy()
 creatureNumber.grid(row=0,column=3,stick=tix.E)
 mainBalloon.bind_widget(creatureNumber,msg='Total number of creatures to generate')
  
 bb3 = tix.ButtonBox(frame,orientation = tix.VERTICAL)
 bb3.add('sample', text='Create Sample', command=sampleCreature)
 bb3.add('fill', text='Generate Creatures', command=generate)
 bb3.add('defaults',text='Defaults',command=defaults)
 bb3.grid(row=1,column=3)
 
 root.update()
 root.mainloop()
