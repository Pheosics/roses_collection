from rcc_code.rcc_pickcreature import pickCreature
from rcc_code.rcc_generatecreature import generateCreature
from rcc_code.rcc_globals import rcc
import random

class getCreature:
 def __init__(self):
  self.generateCreatures()

 def generateCreatures(self):
  if rcc.numbers['seed'].get() == 0:
   random.seed()
  else:
   random.seed(rcc.numbers['seed'].get())
  j = 1
  file = 'creature_rcc_'+str(rcc.numbers['seed'].get())+'_'+str(rcc.numbers['number'].get())+'.txt'
  ofile = open(file,'w')
  ofile.write(file+'\n')
  ofile.write('\n[OBJECT:CREATURE]\n')
  while j < rcc.numbers['number'].get():
   ofile.write('\n')
   self.createCreature(j)
   ofile.write('\n'.join(rcc.creature['Raws']))
   j += 1
  ofile.close()

 def createCreature(n):
  rcc.creature = {}
  rcc.creature['Parts'] = {}
  rcc.creature['Names'] = {}
  rcc.creature['Templates'] = []
  rcc.creature['Colors'] = {}
  rcc.creature['Colors']['Parts'] = []

  pickCreature.getFlagsPercents() #Computes token flags based on provided percentages
  pickCreature.getArgsNumbers()
  pickCreature.getSize() #Checks against #TRADE_ANIMAL and given sizes
  pickCreature.getSpeed() #No checks
  pickCreature.getPops() #No checks
  pickCreature.getAttributes()
  pickCreature.getAge()
  pickCreature.getActive()
  pickCreature.getTemplate('Type','TYPE',1,100)
  pickCreature.getTemplate('Biome','BIOME',1,100)
  pickCreature.getTemplate('Material','MATERIAL',1,100)
  for key in rcc.body_order:
   pickCreature.getTemplate(rcc.body_templates[key],key,1,100)
  pickCreature.getTemplate('SubType','SUBTYPE',rcc.numbers['subtypes'].get(),100)
  pickCreature.getTemplate('Extract','EXTRACT',999,100)
  pickCreature.getTemplate('Interaction','INTERACTION',rcc.numbers['interaction']['max'].get(),rcc.numbers['interaction']['chance'].get())
  pickCreature.getCastes()
  pickCreature.getAttacks() #Fill in the attack table from all the other 

  generateCreature.createDescription()
  generateCreature.createBodyToken()
  generateCreature.createSpeedToken()
  generateCreature.createActiveToken()
  generateCreature.createAgeToken()
  generateCreature.createSizeToken()
  generateCreature.createPopToken()
  generateCreature.createAttributeToken()
  generateCreature.createColors()
  generateCreature.createName()
  generateCreature.createBasicInformation()
  generateCreature.createRaws(n)
