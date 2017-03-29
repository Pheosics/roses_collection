from tkinter import *
import os
import fnmatch
from tkinter import tix
from tkinter import filedialog
import random
from rcc_code.rcc_pickcreature import pickCreature
from rcc_code.rcc_generatecreature import generateCreature
from rcc_code.rcc_create import getCreature
from rcc_code.rcc_globals import rcc

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

if __name__ == '__main__':
 root = tix.Tk()

 canvas = tix.Canvas(root, width=1000, height=600)
 canvas.grid(row=0, column=0, sticky=N+S+E+W)
 root.grid_rowconfigure(0, weight=1)

 frame = tix.Frame(canvas)
 frame.rowconfigure(1, weight=1)
 frame.columnconfigure(1,weight=1)

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
    rcc.status[item]['All'] = stat_save
    for obj in rcc.data[item].keys():
     self.cl[item].setstatus(item+'.'+obj,stat_save)
     rcc.status[item][obj] = stat_save
   else:
    key1 = item.split('.')[0]
    key2 = item.split('.')[1]
    rcc.status[key1][key2] = self.cl[key1].getstatus(item)

  def checkAll(self):
   for type1 in rcc.checks[self.ty]:
    rcc.status[type1]['All'] = "on"
    self.cl[type1].setstatus(type1,"on")
    for type2 in rcc.data[type1].keys():
     self.cl[type1].setstatus(type1+'.'+type2,"on")
     rcc.status[type1][type2] = "on"

  def uncheckAll(self):
   for type1 in rcc.checks[self.ty]:
    rcc.status[type1]['All'] = "off"
    self.cl[type1].setstatus(type1,"off")
    for type2 in rcc.data[type1].keys():
     self.cl[type1].setstatus(type1+'.'+type2,"off")
     rcc.status[type1][type2] = "off"

  def makelist(self):
   listBalloon = tix.Balloon(self.t)
   c = 0
   self.cl = {}
   for type1 in rcc.checks[self.ty]:
    j = 0
    self.cl[type1] = tix.CheckList(self.t, width = 350, height=600, browsecmd=self.update)
    self.cl[type1].grid(row=0,column=c)
    self.cl[type1].hlist.add(type1, text=type1)
    self.cl[type1].setstatus(type1,rcc.status[type1]['All'])
    temp = list(rcc.data[type1].keys())
    temp.sort()
    for subtype in temp:
     j = j + 1
     hl = tix.Label(self.cl[type1],text="?")
     hl.place(in_=self.cl[type1],x=10,y=16*j+4,width=10,height=10)
#     hl.place_forget()
     self.cl[type1].hlist.add(type1+'.'+subtype,text=subtype)
     self.cl[type1].setstatus(type1+'.'+subtype,rcc.status[type1][subtype])
#     print(self.cl[type].subwidgets_all())
     listBalloon.bind_widget(hl,msg=''.join(rcc.store[type1][subtype]))
#     hl.place_forget()
    self.cl[type1].autosetmode()
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
   temp = list(rcc.args.keys())
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
     arg[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=rcc.numbers['args'][key][var].get(),variable=rcc.numbers['args'][key][var],autorepeat=False)
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
   temp = rcc.gaits
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
     speed[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=rcc.numbers['speed'][key][var].get(),variable=rcc.numbers['speed'][key][var],autorepeat=False)
     speed[key][var].subwidget('decr').destroy()
     speed[key][var].subwidget('incr').destroy()
     speed[key][var].grid(row=r,column=c,stick=tix.E,padx=10)

   bLabel.grid(row=0,column=0,columnspan=c)
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.grid(row=0,column=c+1)

 class variableWindow:
  def __init__(self,ty):
   self.t =Toplevel(root)
   self.ty = ty
   self.makelist()

  def close(self):
   self.t.destroy()

  def makelist(self):
   speedBalloon = tix.Balloon(self.t)

   variable = {}
   var_variables = ['percent']
   temp = rcc.variability
   temp.sort()
   labels = {}
   bLabel = tix.Label(self.t,text='Variability level between individual animals of the same creature\nPercent is assumed to be maximum variability\nIf 0 the BODY_APPEARANCE_MODIFIER tags will not be added')
   r = 0
   c = 1
   for key in temp:
    r = r + 1
    variable[key] = {}
    if r > 12:
     c = c + 1
     r = 1
    labels[key] = tix.Label(self.t,text=key.capitalize()+':').grid(row=r,column=c,stick=tix.W)
    for var in var_variables:
     r = r + 1
     variable[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=rcc.numbers['variable'][key][var].get(),variable=rcc.numbers['variable'][key][var],autorepeat=False)
     variable[key][var].subwidget('decr').destroy()
     variable[key][var].subwidget('incr').destroy()
     variable[key][var].grid(row=r,column=c,stick=tix.E,padx=10)

   bLabel.grid(row=0,column=0,columnspan=c)
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.grid(row=0,column=c+1)

 class attributeWindow:
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
   temp = rcc.phys_attributes
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
     attribute[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=rcc.numbers['attributes'][key][var].get(),variable=rcc.numbers['attributes'][key][var],autorepeat=False)
     attribute[key][var].subwidget('decr').destroy()
     attribute[key][var].subwidget('incr').destroy()
     attribute[key][var].grid(row=r,column=c,stick=tix.E,padx=10)
   advBalloon.bind_widget(labels['Phys_Atts'],msg='Physical attribute tokens [PHYS_ATT_RANGE:STRENGTH:a:b:c:d:e:f:g] are calculated as follows:\n  a is taken from a gaussian distribution with mean Min and sigma Sigma\n  g is taken from a gaussian distribution with mean Max and sigma Sigma\n  d = (a+g)/2\n  c/e = d -/+ 2*(g-d)/10\n  b/f = d -/+ 5*(g-d)/10\nIf Max is 0 then the attribute token is not added to the creature')

   r = 0
   c = 1
   temp = rcc.ment_attributes
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
     attribute[key][var] = tix.Control(self.t,label=var.capitalize(),min=0,value=rcc.numbers['attributes'][key][var].get(),variable=rcc.numbers['attributes'][key][var],autorepeat=False)
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
  def __init__(self):
   self.t =Toplevel(root)
   self.makelist()

  def close(self):
   self.t.destroy()

  def makelist(self):
   stext = tix.ScrolledText(self.t,width=800,height=1000)
   stext.subwidget('text').insert(tix.INSERT,'\n'.join(rcc.creature['Raws']))
   stext.grid(row=0,column=0)
   self.bb = tix.ButtonBox(self.t, orientation = tix.VERTICAL)
   self.bb.add('close', text='Close', command=self.close)
   self.bb.grid(row=0,column=1) 
   
 def makeNumbersTable(frame):
  numbersSubFrame = tix.Frame(frame)
  numbersSubFrame.rowconfigure(1)
  numbersSubFrame.columnconfigure(1)
  numbersBalloon = tix.Balloon(numbersSubFrame)

  rcc.numbers['args'] = {}
  for key in rcc.args:
   rcc.numbers['args'][key] = {}
   rcc.numbers['args'][key]['max'] = tix.IntVar()
   rcc.numbers['args'][key]['min'] = tix.IntVar()

  rcc.numbers['speed'] = {}
  for key in rcc.gaits:
   rcc.numbers['speed'][key] = {}
   rcc.numbers['speed'][key]['max'] = tix.IntVar()
   rcc.numbers['speed'][key]['min'] = tix.IntVar()

  rcc.numbers['attributes'] = {}
  for key in rcc.phys_attributes:
   rcc.numbers['attributes'][key] = {}
   rcc.numbers['attributes'][key]['max'] = tix.IntVar()
   rcc.numbers['attributes'][key]['min'] = tix.IntVar()
   rcc.numbers['attributes'][key]['sigma'] = tix.IntVar()
  for key in rcc.ment_attributes:
   rcc.numbers['attributes'][key] = {}
   rcc.numbers['attributes'][key]['max'] = tix.IntVar()
   rcc.numbers['attributes'][key]['min'] = tix.IntVar()
   rcc.numbers['attributes'][key]['sigma'] = tix.IntVar()   
   
  rcc.numbers['variable'] = {}
  for key in rcc.variability:
   rcc.numbers['variable'][key] = {}
   rcc.numbers['variable'][key]['percent'] = tix.IntVar()

  r=0
  c=0
  sizeLabel = tix.Label(numbersSubFrame,text='Sizes:')
  sizeLabel.grid(row=r,column=c,stick=tix.W) 
  rcc.numbers['size'] = {}
  creatureSize = {}
  size_variables = ['mean','sigma','min','vermin','tiny','trade']
  for var in size_variables:
   r = r + 1
   rcc.numbers['size'][var] = tix.IntVar()
   creatureSize[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=rcc.numbers['size'][var],autorepeat=False,integer=True)
   creatureSize[var].subwidget('decr').destroy()
   creatureSize[var].subwidget('incr').destroy()
   creatureSize[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(sizeLabel,msg='Size tokens [BODY_SIZE:x_1:y_1:a_1], [BODY_SIZE:x_2:y_2:a_2], and [BODY_SIZE:x_3:y_3:a_3] are calculated as follows:\n  a_3 is calculated by selecting a random number from a gaussian distribution with a mean Mean and sigma Sigma\n  a_1 is calculated by selecting a random number from a gaussian distribution with a mean a_3/100 and sigma Sigma/100\n  a_2 = a_1 + a_3*75%, if this is > a_3 then a_2 and a_3 are switched\n  x_1, y_1, y_2, and y_3 are all set to 0 for now\n  x_2 is taken from [BABY:n] (see Ages for calculation) such that x_2 = n + 1\n  x_3 is taken from [CHILD:n] (see Ages for calculation) such that x_3 = n + 2\nMin is the minimum size of any creature, if a_3 < Min then a_3 = Min\nVermin sets the maximum size needed for the #VERMIN flag, below this size #VERMIN is set to True\nTiny sets the maximum size needed for the #TINY flag, below this size #TINY is set to True\nTrade sets the minimum size needed for the #TRADE flag, above this size #TRADE is set to True\nMore information on the #VERMIN, #TINY, and #TRADE flags can be found in the readme')
  
  r=r+1
  ageLabel = tix.Label(numbersSubFrame,text='Ages:')
  ageLabel.grid(row=r,column=c,stick=tix.W) 
  rcc.numbers['age'] = {}
  creatureAge = {}
  age_variables = ['max','min','baby','child','delta']
  for var in age_variables:
   r = r + 1
   rcc.numbers['age'][var] = tix.IntVar()
   creatureAge[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=rcc.numbers['age'][var],autorepeat=False,integer=True)
   creatureAge[var].subwidget('decr').destroy()
   creatureAge[var].subwidget('incr').destroy()
   creatureAge[var].grid(row=r,column=c,stick=tix.E,padx=10)   
  numbersBalloon.bind_widget(ageLabel,msg='Ages tokens [MAX_AGE:a:b], [BABY:c], [CHILD:d] are calculated as follows:\n  a is chosen between Min and Max\n  b is chosen between Max and Max + Delta\n  c is chosen between Baby - Delta and Baby + Delta\n  d is chosen between Child - Delta and Child + Delta\nall choices are selected randomly from a triangular distribution\nif c > d then c is set to 0 and d is set to c\nif either c or d is 0 then that tag will not be added to the creature')

  r=0
  c=1
  popLabel = tix.Label(numbersSubFrame,text='Pop Numbers:')
  popLabel.grid(row=r,column=c,stick=tix.W) 
  rcc.numbers['population'] = {}
  creaturePopulation = {}
  pop_variables = ['max','min']
  for var in pop_variables:
   r = r + 1
   rcc.numbers['population'][var] = tix.IntVar()
   creaturePopulation[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=rcc.numbers['population'][var],autorepeat=False,integer=True)
   creaturePopulation[var].subwidget('decr').destroy()
   creaturePopulation[var].subwidget('incr').destroy()
   creaturePopulation[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(popLabel,msg='Population token [POPULATION_NUMBER:x:y] is calculated as follows:\n  x is chosen between 1 and Min\n  y is chosen between Min and Max\nchoices are selected randomly from a triangular distribution\nFor Vermin and Tiny creatures x = 250 and y = 500')

  r=r+1
  clusLabel = tix.Label(numbersSubFrame,text='Cluster Numbers:       ')
  clusLabel.grid(row=r,column=c,stick=tix.W) 
  rcc.numbers['cluster'] = {}
  creatureCluster = {}
  clus_variables = ['max','min']
  for var in clus_variables:
   r = r + 1
   rcc.numbers['cluster'][var] = tix.IntVar()
   creatureCluster[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=rcc.numbers['cluster'][var],autorepeat=False,integer=True)
   creatureCluster[var].subwidget('decr').destroy()
   creatureCluster[var].subwidget('incr').destroy()
   creatureCluster[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(clusLabel,msg='Cluster token [CLUSTER_NUMBER:x:y] is calculated as follows:\n  x is chosen between 1 and Min\n  y is chosen between Min and Max\nchoices are selected randomly from a triangular distribution\nFor Vermin and Tiny creatures the cluster token is not used')
  
  r=r+1
  intLabel = tix.Label(numbersSubFrame,text='Interactions:')
  intLabel.grid(row=r,column=c,stick=tix.W) 
  rcc.numbers['interaction'] = {}
  creatureInteraction = {}
  clus_variables = ['max','chance']
  for var in clus_variables:
   r = r + 1
   rcc.numbers['interaction'][var] = tix.IntVar()
   creatureInteraction[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=rcc.numbers['interaction'][var],autorepeat=False,integer=True)
   creatureInteraction[var].subwidget('decr').destroy()
   creatureInteraction[var].subwidget('incr').destroy()
   creatureInteraction[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(intLabel,msg='Max is the maximum number of interactions and one creature can have\nChance is the percent chance that each interaction slot is filled\nFor example, if Max is 3 and Chance is 50 then slot 1 will have a 50% chance of being filled, slot 2 will have a 50% chance of being filled, and slot 3 will have a 50% chance of being filled\nThis, of course, is dependent on their being 3 interactions that the creature meets the criteria for')

  r=r+1
  casteLabel = tix.Label(numbersSubFrame,text='Castes:')
  casteLabel.grid(row=r,column=c,stick=tix.W) 
  rcc.numbers['caste'] = {}
  creatureCaste = {}
  clus_variables = ['male','female','neutral']
  for var in clus_variables:
   r = r + 1
   rcc.numbers['caste'][var] = tix.IntVar()
   creatureCaste[var] = tix.Control(numbersSubFrame,label=var.capitalize(),min=0,variable=rcc.numbers['caste'][var],autorepeat=False,integer=True)
   creatureCaste[var].subwidget('decr').destroy()
   creatureCaste[var].subwidget('incr').destroy()
   creatureCaste[var].grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(casteLabel,msg='The maximum number of castes each creature can have which meets specific criteria\nMale sets the maximum number of castes with the #MALE LINK\nFemale sets the maximum number of castes with the #FEMALE LINK\nNeutral sets the maximum number of castes without the #MALE or #FEMALE LINK\nFor more information on LINKs and the #MALE and #FEMALE flags see the readme')
  
  r += 1
  subLabel = Label(numbersSubFrame,text='Subtypes:')
  subLabel.grid(row=r,column=c,stick=tix.W)
  r += 1
  rcc.numbers['subtypes'] = tix.IntVar()
  creatureSubtypes = tix.Control(numbersSubFrame,label='Max',min=0,value=0,variable=rcc.numbers['subtypes'],autorepeat=False,integer=True)
  creatureSubtypes.subwidget('decr').destroy()
  creatureSubtypes.subwidget('incr').destroy()
  creatureSubtypes.grid(row=r,column=c,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(subLabel,msg='Number of subtypes one creature can be, their total number of subtypes will be chosen between 0 and Max from a flat distribution')

  r = 0
  c = 2
  percLabel = Label(numbersSubFrame,text='Percents:')
  percLabel.grid(row=r,column=c,stick=tix.W)
  creaturePercentage = {}
  rcc.numbers['percents'] = {}
  temp = list(rcc.tokens.keys())
  temp.sort()
  for key in temp:
   r += 1
   rcc.numbers['percents'][key] = tix.IntVar()
   creaturePercentage[key] = tix.Control(numbersSubFrame,label='    '+key,min=0,value=0,variable=rcc.numbers['percents'][key],autorepeat=False,integer=True)
   creaturePercentage[key].subwidget('decr').destroy()
   creaturePercentage[key].subwidget('incr').destroy()
   creaturePercentage[key].grid(row=r,column=2,stick=tix.E,padx=10)
  numbersBalloon.bind_widget(percLabel,msg='Percentage chance given token will be true\nIf you wish to generate a set of creatures that all share a commonality you would set the percent to 100')

  numbersSubFrame.grid(row=1,column=1)
# Left Button Comands
 def attacks():
  checkWindow('Attacks')
 def materials():
  checkWindow('Materials')
 def bodyparts():
  checkWindow('BodyParts')
 def bodyparts2():
  checkWindow('BodyParts2')
 def attachments():
  checkWindow('Attachments')
 def internal():
  checkWindow('Internal')
 def face():
  checkWindow('FacialFeatures')
 def face2():
  checkWindow('FacialFeatures2')
 def biomes():
  checkWindow('Biomes')
# Bottom Button Commands
 def arguments():
  argWindow('Arguments')
 def speeds():
  speedWindow('Speeds')
 def attributes():
  attributeWindow('Advanced')
 def variable():
  variableWindow('Variable')
# Right Button Commands
 def sampleCreature():
  getCreature.createCreature(1)
  sampleWindow()
 def generate():
  getCreature()
 def defaults():
  rcc.fillDefaults(rcc.numbers)
 def close():
  return 

 canvas.create_window(0,0,anchor=NW,window=frame)
 frame.update_idletasks()
 canvas.config(scrollregion=canvas.bbox('all'))
 
 makeNumbersTable(frame)
 
 mainBalloon = tix.Balloon(frame)
 templateLabel = tix.Label(frame,text='Templates')
 templateLabel.grid(row=0,column=0)
 mainBalloon.bind_widget(templateLabel,msg='Select which templates you wish to be considered for adding to creatures\nBy default all templates are active')
 bb = tix.ButtonBox(frame, orientation = tix.VERTICAL)
 bb.add('attack', text='Attacks and Interactions', command=attacks)
 bb.add('base', text='Body Materials', command=materials)
 bb.add('body', text='Body Parts (Core)', command=bodyparts)
 bb.add('body2',text='Body Parts (Extremities)', command=bodyparts2)
 bb.add('attachments', text='Body Part Attachments', command=attachments)
 bb.add('internal', text='Organs, Bones, and Extracts', command=internal)
 bb.add('face', text='Facial Features (Large)', command=face)
 bb.add('face2',text='Facial Features (Small)', command=face2)
 bb.add('biome', text='Biomes, Types, and Castes', command=biomes)
 bb.grid(row=1,column=0)
 
 bb2 = tix.ButtonBox(frame,orientation = tix.HORIZONTAL)
 bb2.add('arg', text='Argument Values', command=arguments)
 bb2.add('speed',text='Gait Speeds', command=speeds)
 bb2.add('advanced',text='Attributes', command=attributes)
 bb2.add('variable',text='Variability', command=variable)
 bb2.grid(row=2,column=1)
 
 rcc.numbers['seed'] = tix.IntVar()
 seedStore = tix.Control(frame,label='Seed',min=0,variable=rcc.numbers['seed'],autorepeat=False,integer=True)
 seedStore.subwidget('decr').destroy()
 seedStore.subwidget('incr').destroy()
 seedStore.grid(row=0,column=2,stick=tix.E)
 mainBalloon.bind_widget(seedStore,msg='Seed used for random number generation, if left at 0 will use a random seed')
 
 rcc.numbers['number'] = tix.IntVar()
 creatureNumber = tix.Control(frame,label='    Creatures',min=0,variable=rcc.numbers['number'],autorepeat=False,integer=True)
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
