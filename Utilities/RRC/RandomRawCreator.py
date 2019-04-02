from rrc_code.plants import rrc_plants
from rrc_code.raws   import plantRaws
from rrc_code.templates import plantTemplates
import json

for i in range(1):
 plant = rrc_plants.get_plant()
 raw_string = plantRaws.get_raw(plant)
 print(raw_string+'\n')

