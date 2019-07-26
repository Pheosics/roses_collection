import random

#==================================================================================================
class GenerateObject:
    def __init__(self,extRaws,template,Type,configuration,world,n,force={}):
        types = template.template
        self.obj = {}
        self.obj['TAG'] = Type.upper() + '_' + str(n)
        self.obj['baseObjects']   = template.baseObjects
        self.obj['subObjects']    = template.subObjects
        self.obj['sourceObjects'] = template.sourceObjects
        self.obj['numberObjects'] = template.numberObjects
        self.obj['binObjects']    = template.binObjects
        self.obj['rawObjects']    = template.rawObjects
        self.obj['reservedKeys']  = template.reserved_keys
        self.extRaws = extRaws
        self.get_object(types,configuration,world,force)
        extRaws = self.extRaws
   
   #==================================================================================================
    def parse_bins(self,bIN):
        roll = random.randint(1,bIN['ROLL'])
        for i in range(bIN['BINS']):
            if roll <= bIN[i]['n']:
               b = bIN[i]
               break
        return b
   
   #==================================================================================================
    def parse_types(self,types,dOUT,single,force='ANY'):
        dIN = self.get_valid(types,force)
        valid = True
        t = {}
        if dIN['ROLL'] == 0: return dOUT, t
        roll = random.randint(1,dIN['ROLL'])
        for i in range(dIN['BINS']):
            if roll <= dIN[i]['n']:
                t = dIN[i]['object']
                break
        dOUT[t['TYPE']] = {}
        dOUT[t['TYPE']]['KEY'] = t['KEY']
        for key in dIN['KEYS']:
            if t.get(key,False):
                roll_key = random.randint(0,len(t[key])-1)
                choice = t[key][roll_key]
                dOUT[t['TYPE']][key] = choice
        dOUT[t['TYPE']]['COLORS'] = {}
        for key in t.get('COLORS',{}).keys():
            roll_key = random.randint(0,len(t['COLORS'][key])-1)
            choice = t['COLORS'][key][roll_key]
            dOUT[t['TYPE']]['COLORS'][key] = choice
        for key in self.obj['reservedKeys']:
            if key == 'COLORS': continue
            if key == '__comment': continue
            if t.get(key,False): dOUT[t['TYPE']][key]   = t[key]
        self.parse_object(t)
        return dOUT, t
   
   #==================================================================================================
    def get_valid(self,types,force="ANY"):
        obj = self.obj
        valid_types = {"ROLL": 0, "BINS": 0, "KEYS": types['KEYS']}
        tokens = obj['TOKENS']
        for key in range(types['BINS']):
            valid = True
            if force != 'ANY':
                if types[key]['object'].get('TYPE','NONE') != force:
                    valid = False
            for f_token in types[key]['object'].get('FORBIDDEN',[]):
                if f_token == 'NONE' or len(f_token) == 0: continue
                if tokens.count(f_token) >= 1:
                    valid = False
                    break
            for r_token in types[key]['object'].get('REQUIRED',[]):
                if r_token == 'NONE' or len(r_token) == 0: continue
                if tokens.count(r_token) == 0:
                    valid = False
                    break
            if valid:
                n = valid_types["BINS"]
                r = valid_types["ROLL"]
                w = types[key]['object']['WEIGHT']
                valid_types[n] = {}
                valid_types[n]['n'] = r + w
                valid_types[n]['object'] = types[key]['object']
                valid_types["ROLL"] = r + w
                valid_types["BINS"] = n + 1
        return valid_types
   
   #==================================================================================================
    def parse_object(self,obj):
        # Add template tokens and type to object tokens list
        self.obj['TOKENS'] += obj.get('TOKENS',[]) + [obj.get('TYPE','')]
   
        # Add template companions to object companion list
        self.obj['COMPANION'] += obj.get('COMPANION',[])
   
        # Add template numbers to object numbers
        for key,n in obj.get('N',{}).items():
            self.obj['NUMBERS'][key] = self.obj['NUMBERS'].get(key,0) + n
   
        # Add template external information to extRaws
        for key,raws in obj.get('EXTERNAL',{}).items():
            self.extRaws[key] = self.extRaws.get(key,{})
            self.extRaws[key][obj['KEY']] = raws
   
   #==================================================================================================
    def get_links(self,world):
        link = True
        keys = self.obj['baseObjects'] + self.obj['subObjects'] + self.obj['sourceObjects']
        for key in keys:
            for skey in self.obj[key].keys():
                self.obj[key][skey]['LINK_OBJECTS'] = {}
                for link in self.obj[key][skey].get('LINK',[]):
                     self.obj[key][skey]['LINK_OBJECTS'][link] = {}
                     ltype = link.split(':')[0]
                     ltokens = link.split(':')[1:]
                     llist = []
                     for wobjs in world.get(ltype,[]):
                         check = True
                         for token in ltokens:
                             if token == 'ANY':
                                 break
                             if wobjs.get('TOKENS',[]).count(token) == 0:
                                 check = False
                                 break
                         if check:
                             llist.append(wobjs)
                     if len(llist) > 0:
                         n = random.randint(0,len(llist)-1)
                         self.obj[key][skey]['LINK_OBJECTS'][link] = llist[n]
                     else:
                         link = False
   
        self.linked = link
   
   #==================================================================================================
    def get_object(self,types,configuration,world,force):
        self.linked = False
        attempt = 0
        while not self.linked:
            attempt += 1
            if attempt > 100:
                raise NameError('ERROR: unable to generate a suitable object')
            self.obj['TOKENS'] = []
            self.obj['COMPANION'] = []
            self.obj['NUMBERS'] = {}
            objects = {}
   
            # Evaluate Bin Objects
            for bkey in self.obj['binObjects']:
                self.obj[bkey] = self.parse_bins(types[bkey])
   
            # Get Base Objects
            for bkey in self.obj['baseObjects']:
                force_key = force.get(bkey,"ANY")
                self.obj[bkey], obj = self.parse_types(types[bkey], {}, True, force=force_key)
                objects[bkey] = obj
   
            # Get Sub Objects
            for skey in self.obj['subObjects']:
                self.obj[skey] = {}
                for bkey in self.obj['baseObjects']:
                    self.get_subobject(objects[bkey], types[skey], skey)
                self.obj['n_'+skey] = len(list(self.obj[skey].keys()))
   
            # Get Source Objects
            for ukey in self.obj['sourceObjects']:
                self.obj[ukey] = {}
                for skey in self.obj['baseObjects']:
                    self.get_sourceobject(types[ukey], skey, ukey)
                for skey in self.obj['subObjects']:
                    self.get_sourceobject(types[ukey], skey, ukey)
                self.obj['n_'+ukey] = len(list(self.obj[ukey].keys()))
   
            self.obj['TOKENS'] = list(set(' '.join(self.obj['TOKENS']).split()))
   
            # Get Links
            self.linked = True
            self.get_links(world)
   
   #==================================================================================================
    def get_subobject(self,base,types,subtype):
        dOUT = self.obj[subtype]
        base = base.get(subtype.upper(),{})
        m1 = base.get('MIN',0)
        m2 = base.get('MAX',0)
        m3 = len(base.get('REQUIRED',[]))
        if m2 <= m1:
            n  = m1
            m2 = m1
        else:
            n = random.randint(m1,m2)
        if n < m3: 
            n  = m3
            m2 = m3

        if n > 0:
            # Get required
            for r_key in base.get('REQUIRED',[]):
                if r_key == 'NONE': continue
                temp = {"ROLL": 0, "BINS": 0, "KEYS": types['KEYS']}
                b = 0
                temp[b-1] = {'n': 0}
                for i in range(types['BINS']):
                    if types[i]['object']['TYPE'] == r_key:
                        temp[b] = types[i]
                        temp[b]['n'] = temp[b-1]['n'] + types[i]['object']['WEIGHT']
                        temp['ROLL'] += types[i]['object']['WEIGHT']
                        temp['BINS'] += 1
                        b += 1
                if temp['BINS'] == 0:
                    raise NameError('ERROR: Unable to find REQUIRED object - '+r_key)
                dOUT, x = self.parse_types(temp, dOUT, False)
            # Fill in the rest
            temp = {"ROLL": 0, "BINS": 0, "KEYS": types['KEYS']}
            b = 0
            temp[b-1] = {'n': 0}
            for i in range(types['BINS']):
                if base.get('FORBIDDEN',[]).count(types[i]['object']['TYPE']) == 0:
                    temp[b] = types[i]
                    temp[b]['n'] = temp[b-1]['n'] + types[i]['object']['WEIGHT']
                    temp['ROLL'] += types[i]['object']['WEIGHT']
                    temp['BINS'] += 1
                    b += 1
            if temp['BINS'] != 0:
                attempt = 0
                while len(list(dOUT.keys())) < n:
                    attempt += 1
                    if attempt > 2*m2: break
                    dOUT, x = self.parse_types(temp, dOUT, False)
        self.obj[subtype] = dOUT
   
   #==================================================================================================
    def get_sourceobject(self,types,otype,stype):
        skey = stype.upper()
        for okey, base in self.obj[otype].items():
            self.obj[otype][okey]['SOURCE_OBJECTS'] = self.obj[otype][okey].get('SOURCE_OBJECTS',{})
            for k,v in enumerate(base.get(skey,[])):
                temp = {"BINS": 0, "KEYS": types['KEYS']}
                for i in range(types['BINS']):
                    sobj = types[i]['object']
                    if sobj['TYPE'] == v or v == 'ANY':
                        n = temp['BINS']
                        temp[n] = {}
                        temp[n]['object'] = sobj
                        temp['BINS'] = n + 1
                if temp['BINS'] > 0:
                    y, x = self.parse_types(temp, {}, False)
                    if v == 'ANY': v = x['TYPE']
                    v = v + '_' + otype.upper()
                    self.obj[stype][v] = y[x['TYPE']]
                    # Add information to source object
                    self.obj[otype][okey]["SOURCE_OBJECTS"][skey] = self.obj[otype][okey]['SOURCE_OBJECTS'].get(skey,[])
                    self.obj[otype][okey]["SOURCE_OBJECTS"][skey].append(x['TYPE'])
                    # Add information to source type
                    self.obj[stype][v]['SOURCE_KEY']  = okey
                    self.obj[stype][v]['SOURCE_TYPE'] = otype
                    self.obj[stype][v]['SOURCE_NAME'] = base.get('NOUN','')
