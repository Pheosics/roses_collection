import os
import fnmatch
import csv
from mwe_code.inorganics import inorganics
from mwe_code.plants import plants
from mwe_code.items import items
from mwe_code.buildings import buildings
from mwe_code.reactions import reactions
dir = '/u/mengel/Desktop/roses_collection/Utilities/MWE/raws/'
Type = 'Inorganics'
#Type = 'Plants'
#Type = 'Items'
#Type = 'Buildings'
#Type = 'Reactions'
#Directions = 'RAWtoMWE'
#Directions = 'MWEtoRAW'
Directions = 'RAWtoRAW'

if Type == 'Inorganics':
 func = inorganics()
elif Type == 'Plants':
 func = plants()
elif Type == 'Items':
 func = items()
elif Type == 'Buildings':
 func = buildings()
elif Type == 'Reactions':
 func = reactions()
elif Type == 'All':
 print('NYI')

if Directions == 'MWEtoRAW':
 func.getMWE(dir)
 func.writeRAW(func.mweData)
elif Directions == 'RAWtoMWE':
 func.getRAW(dir)
 func.writeMWE(func.rawData)
elif Directions == 'RAWtoRAW':
 func.getRAW(dir)
 func.writeRAW(func.rawData)
