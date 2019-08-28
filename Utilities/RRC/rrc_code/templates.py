import os
import json
import glob
import copy

reserved_keys = ['RAWS', 'TYPE','WEIGHT','TOKENS','COLORS','REQUIRED','FORBIDDEN',
                 'SOURCE', 'DESC', 'LINK', 'N', 'EXTERNAL', 'KEY', 'SOURCE_KEY', 
                 'SOURCE_TYPE', 'SOURCE_NAME', 'SOURCE_OBJECTS', 'LINK_OBJECTS', 
                 'NAME', 'BIN', 'PREF', 'UNIQUE', 'REPEAT', '__comment']
joinStr = 'asdbaksjdj'

class Templates:
    def __init__(self,template):
        self.reserved_keys = reserved_keys
        self.join_templates(template)
        self.read_templates()
        #self.process_templates()

    def join_templates(self,template):
        files = glob.glob('templates/templates_'+template+'*')
        jd = {}
        for fname in files:
            f = open(fname)
            json_dict = json.load(f)
            f.close()
            self.rawObjects    = json_dict.get('raw_order',[])
            self.baseObjects   = json_dict.get('baseObjects',[])
            self.subObjects    = json_dict.get('subObjects',[])
            self.sourceObjects = json_dict.get('sourceObjects',[])
            self.numberObjects = json_dict.get('numberObjects',[])
            self.binObjects    = json_dict.get('binObjects',[])
            keys = self.baseObjects + self.subObjects + self.sourceObjects + self.numberObjects + self.binObjects
            for key in keys:
                self.reserved_keys.append(key.upper())
                jd[key] = jd.get(key,{})
                if json_dict.get(key,False): jd[key] = {**jd[key], **json_dict[key]}
        self.json_dict = jd

    def read_templates(self):
        json_dict = self.json_dict
        dicts = {}
        for key in json_dict.keys():
            if self.numberObjects.count(key) > 0: 
                continue
            elif self.binObjects.count(key) > 0:
                dicts[key] = {'ROLL': 0, 'BINS': 0}
                for t_key in json_dict[key].keys():
                    if t_key == '__comment': continue
                    n = dicts[key]['BINS']
                    w = json_dict[key][t_key]['n']
                    dicts[key][n] = {}
                    dicts[key][n]['n'] = dicts[key]['ROLL'] + w
                    for b_key in json_dict[key][t_key].keys():
                        if b_key == 'n': continue
                        dicts[key][n][b_key] = json_dict[key][t_key][b_key]
                    dicts[key]['ROLL'] = dicts[key]['ROLL'] + w
                    dicts[key]['BINS'] = n + 1
                continue
            dicts[key] = {'ROLL': 0, 'BINS': 0, 'KEYS': [], 'TYPES': []}
            for t_key in json_dict[key].keys():
                if t_key == "__comment": continue
                json_dict[key][t_key]['TYPE'] = json_dict[key][t_key].get('TYPE',t_key)
                json_dict[key][t_key]['WEIGHT'] = json_dict[key][t_key].get('WEIGHT',100)
                if json_dict[key][t_key].get('REPEAT',False):
                    for rk,rv in json_dict[key][t_key]['REPEAT'].items():
                        n = dicts[key]['BINS']
                        w = json_dict[key][t_key].get('WEIGHT',100)
                        dicts[key][n] = {}
                        dicts[key][n]['n'] = dicts[key]['ROLL'] + int(w*rv[0])
                        dicts[key][n]['object'] = copy.deepcopy(json_dict[key][t_key])
                        dicts[key][n]['object']['WEIGHT'] = int(w*rv[0])
                        dicts[key][n]['object']['KEY'] = t_key + '_' + rk
                        dicts[key][n]['object']['UNIQUE'] = json_dict[key][t_key].get('UNIQUE',True)
                        for ek, ev in json_dict[key][t_key].get('EXTERNAL',{}).items():
                            temp1 = []
                            for i in range(1,len(rv)):
                                temp2 = joinStr.join(ev)
                                for j in range(len(rv[i])):
                                    jStr = '^' + str(j+1)
                                    temp2 = temp2.replace(jStr,rv[i][j])
                                if temp2.split(joinStr) == temp1: continue
                                temp1 += temp2.split(joinStr)
                            dicts[key][n]['object']['EXTERNAL'][ek] = temp1
                        for ek, ev in json_dict[key][t_key].get('RAWS',{}).items():
                            temp1 = []
                            for i in range(1,len(rv)):
                                temp2 = joinStr.join(ev)
                                for j in range(len(rv[i])):
                                    jStr = '^' + str(j+1)
                                    temp2 = temp2.replace(jStr,rv[i][j])
                                if temp2.split(joinStr) == temp1: continue
                                temp1 += temp2.split(joinStr)
                            dicts[key][n]['object']['RAWS'][ek] = temp1
                        dicts[key]['ROLL'] = dicts[key]['ROLL'] + int(w*rv[0])
                        dicts[key]['BINS'] = n + 1
                        dicts[key][n]['object'].pop('REPEAT')
                else:
                    json_dict[key][t_key]['TYPE'] = json_dict[key][t_key].get('TYPE',t_key)
                    json_dict[key][t_key]['WEIGHT'] = json_dict[key][t_key].get('WEIGHT',100)
                    n = dicts[key]['BINS']
                    w = json_dict[key][t_key]['WEIGHT']
                    dicts[key][n] = {}
                    dicts[key][n]['n'] = dicts[key]['ROLL'] + w
                    dicts[key][n]['object'] = json_dict[key][t_key]
                    dicts[key][n]['object']['KEY'] = t_key
                    dicts[key][n]['object']['UNIQUE'] = json_dict[key][t_key].get('UNIQUE',True)
                    dicts[key]['ROLL'] = dicts[key]['ROLL'] + w
                    dicts[key]['BINS'] = n + 1
                for s_key in json_dict[key][t_key].keys():
                    if reserved_keys.count(s_key) == 0:
                        dicts[key]['KEYS'].append(s_key)
                if dicts[key]['TYPES'].count(json_dict[key][t_key]['TYPE']) == 0:
                    dicts[key]['TYPES'].append(json_dict[key][t_key]['TYPE'])
                dicts[key]['KEYS'] = list(set(dicts[key]['KEYS']))
            if dicts[key]['BINS'] == 0: 
                dicts.pop(key)
                if self.baseObjects.count(key) > 0: self.baseObjects.remove(key)
                if self.subObjects.count(key) > 0: self.subObjects.remove(key)
                if self.sourceObjects.count(key) > 0: self.sourceObjects.remove(key)
        temp = {}
        for key in self.numberObjects:
            temp[key] = json_dict.get(key,{})
        self.numberObjects = temp

        self.template = dicts 
