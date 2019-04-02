import os

class plantTemplates:
 def read_templates():
  files = []
  for fname in os.listdir('templates/'):
   if fname.count('PLANT') > 0 and fname.count('.txt') > 0 :
    files.append(os.getcwd()+'/templates/'+fname)

  dicts = {'BASE': {}, 'GROWTH': {}, 'EXTRACTS': {}, 'FAIL': {}}
  dicts['BASE']    = {'ROLL': 0, 'BINS': 0, 'KEYS': ['NAME','SIZE','SHAPE']}
  dicts['GROWTH']  = {'ROLL': 0, 'BINS': 0, 'KEYS': ['NAME','FLAVOR','SMELL','SIZE','SHAPE','SHELL','SEED']}
  dicts['PRODUCT'] = {'ROLL': 0, 'BINS': 0, 'KEYS': ['NAME','ADJ']}
  dicts['FAIL'] = {'ROLL': 0, 'BINS': 0}

  for fname in files:
   print(fname)
   f = open(fname)
   data = f.readlines()
   f.close()
   n = -1
   d_type = 'FAIL'
   r = 'Type'
   p = 'FAIL'
   for line in data:
    sline = line.strip()
    if sline.count('[TEMPLATE:') == 1:
     d_type = sline.split(':')[1]

     n = dicts[d_type]['BINS']
     dicts[d_type][n] = {}
     dicts[d_type][n]['n'] = 0

     if d_type == 'BASE': 
      r = 'Type'
      dicts[d_type][n][r] = {}
      dicts[d_type][n][r]['GROWTHS'] = {'MIN': 0, 'MAX': 0, 'REQUIRED': [], 'FORBIDDEN': []}
     if d_type == 'GROWTH': 
      r = 'Growth'
      dicts[d_type][n][r] = {}
     if d_type == 'PRODUCT': 
      r = 'Product'
      dicts[d_type][n][r] = {}
      dicts[d_type][n][r]['SOURCE'] = {'n': 0}

     dicts[d_type][n][r]['COLORS'] = {}
     dicts[d_type][n][r]['EXCLUDE'] = []
     dicts[d_type]['BINS'] += 1
    else:
     sline = sline.replace('[','').replace(']','')
     a = sline.split(':')
     if a[0] == 'TYPE':
      dicts[d_type][n][r]['TYPE'] = a[1]
     elif a[0] == 'NAME':
      dicts[d_type][n][r]['NAME'] = a[1].split(',')
     elif a[0] == 'FREQUENCY':
      dicts[d_type][n][r]['WEIGHT'] = int(a[1])
      dicts[d_type][n]['n'] = dicts[d_type]['ROLL'] + int(a[1])
      dicts[d_type]['ROLL'] += int(a[1])
     elif a[0] == 'GROWTHS':
      dicts[d_type][n][r]['GROWTHS']['MIN'] = int(a[1])
      dicts[d_type][n][r]['GROWTHS']['MAX'] = int(a[2])
     elif a[0] == 'GROWTH_REQUIRED':
      if a[1] != 'NONE':
       dicts[d_type][n][r]['GROWTHS']['REQUIRED'] = a[1].split(',')
     elif a[0] == 'GROWTH_FORBIDDEN':
      if a[1] != 'NONE':
       dicts[d_type][n][r]['GROWTHS']['FORBIDDEN'] = a[1].split(',')
     elif a[0] == 'COLOR':
      dicts[d_type][n][r]['COLORS'][a[1]] = a[2].split(',')
     elif a[0] == 'SOURCE':
      i = dicts[d_type][n][r]['SOURCE']['n']
      dicts[d_type][n][r]['SOURCE'][i] = [a[1],a[2],a[3],a[4]]
      dicts[d_type][n][r]['SOURCE']['n'] = i + 1
     else:
      try:
       dicts[d_type][n][r][a[0]] = a[1].split(',')
      except:
       continue

  return dicts
