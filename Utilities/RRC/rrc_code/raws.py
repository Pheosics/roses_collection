import random
import json
import string

def fix_label(string):
    string = string.replace('_',' ')
    string = string.lower()
    string = string.capitalize()
    return string

def fix_string(string):
    #t = string.split()[0]
    #for i in range(1,len(string.split())):
    #    if string.split()[i][0].isupper():
    #        t += '.'
    #    t += ' '+string.split()[i]
    #string = t
    string = string.replace(' , ',', ')
    string = string.replace(' . ','')
    string = string.replace('..','.')
    string = string.replace('\n\n','\n')
    string = string.replace('\n\n','\n')
    # Fix A -> An for vowels
    # Fis is/are and other singular/plural issues
    # Fix and/but issues
    return string

#==================================================================================================
class GenerateRaws:
    def __init__(self,obj,configuration,world,raws,companion={}):
        self.colors = raws['colors']
        self.con   = configuration
        self.obj   = obj
        self.world = world

        self.get_raw(companion)

  #==================================================================================================
    def get_name(self):
        names = {}

        name = ''
        for v in self.obj['baseObjects']: # + self.obj['subObjects'] + self.obj['sourceObjects']:
            for w, item in self.obj[v].items():
                name += self.replace_special_chars(item.get('NAME',''),v,w)
        name = ' '.join(name.split()).lower()

        if name == '' or name == ' ':
            name = ''.join([random.choice(string.ascii_letters) for n in range(8)])

        names['singular']  = name
        names['plural']    = name + 's'
        names['adjective'] = name
        self.names = names
        self.obj['NAMES'] = names

  #==================================================================================================
    def get_description(self):
        str1 = ''
        for v in self.obj['baseObjects']:
            for w in self.obj[v].keys():
                tstr = self.obj[v][w].get('DESC','')
                tstr = self.replace_special_chars(tstr,v,w,desc=True)
                str1 += tstr + ' '
        str1 = ' '.join(str1.split()) + '\n'

        str2 = ''
        hstr = ''
        for v in self.obj['subObjects']:
            #hstr = fix_label(v.upper()) + ':'+'\n'
            n = 0
            for w,x in self.obj[v].items():
                tstr = x.get('DESC','')
                tstr = self.replace_special_chars(tstr,v,w,desc=True)
                tstr = ' '.join(tstr.split())
                if tstr != '': hstr += '  '+tstr + '\n'
                for s,y in x.get('SOURCE_OBJECTS',{}).items():
                    for t in y:
                        try:
                            tstr = self.obj[s.lower()][t+'_'+v.upper()].get('DESC','')
                            tstr = self.replace_special_chars(tstr,s.lower(),t+'_'+v.upper(),desc=True)
                        except:
                            tstr = self.obj[s.lower()][t].get('DESC','')
                            tstr = self.replace_special_chars(tstr,s.lower(),t,desc=True)
                        tstr = ' '.join(tstr.split())
                        hstr += '    '+tstr + '\n'
                n += 1
            #if n == 0: str2 += '    None\n'
            if n == 0: hstr = ''
            str2 += hstr + '\n'

        str3 = ''
        for v in self.obj['sourceObjects']:
            str3 = str3 + fix_label(v.upper()) + ':'+'\n'
            n = 0
            for w,x in self.obj[v].items():
                if self.obj['subObjects'].count(x['SOURCE_TYPE']) > 0: continue
                tstr = x.get('DESC','')
                tstr = self.replace_special_chars(tstr,v,w,desc=True)
                tstr = ' '.join(tstr.split())
                str3 += '    '+tstr + '\n'
                n += 1
            if n == 0: str3 = ' ' #'    None\n'
        str3 = str3[:-1]

        string = fix_string(str1 + str2 + str3)
        self.obj['description'] = string
  #==================================================================================================
    def get_colors(self):
        colors = self.colors
        colorValues = {}
        colorStates = {}

        for v in self.obj['baseObjects'] + self.obj['subObjects'] + self.obj['sourceObjects']:
            colorValues[v] = {}
            colorStates[v] = {}
            for w in self.obj[v].keys():
                colorValues[v][w] = {}
                colorStates[v][w] = {}
                for key in self.obj[v][w]['COLORS'].keys():
                    if self.obj[v][w]['COLORS'].get(key,'') == "ANY":
                        c_key   = list(colors.keys())[random.randint(0,len(colors.keys())-1)]
                        n = random.randint(0,len(colors[c_key]['Names'])-1)
                        value = colors[c_key]['Value']
                        name  = colors[c_key]['Names'][n]
                        try:
                            state = colors[c_key]['States'][n]
                        except:
                            state = colors[c_key]['States'][0]
                    elif self.obj[v][w]['COLORS'].get(key,'') != '':
                        name  = self.obj[v][w]['COLORS'].get(key,'')
                        value = ''
                        state = ''
                        for k,d in colors.items():
                            if d['Names'].count(name) > 0:
                                value = d['Value']
                                state = d['States'][0] # NEED TO GET ACTUAL INDEX -ME
                                break
                        if value == '': value = "0:0:0"
                        if state == '': state = "BLACK"
                    self.obj[v][w]['COLORS'][key] = name
                    colorValues[v][w][key] = value
                    colorStates[v][w][key] = state

        for v in self.obj['sourceObjects']:
            for k, w in self.obj[v].items():
                k1 = w['SOURCE_TYPE']
                k2 = w['SOURCE_KEY']
                for key in colorValues[k1][k2].keys():
                    colorValues[v][k][key] = colorValues[k1][k2][key]
                    colorStates[v][k][key] = colorStates[k1][k2][key]

        self.obj['colorValues'] = colorValues
        self.obj['colorStates'] = colorStates

  #==================================================================================================
    def get_prefstring(self):
        prefs = []

        for v in self.obj['baseObjects'] + self.obj['subObjects'] + self.obj['sourceObjects']:
            for w, item in self.obj[v].items():
                temp = self.replace_special_chars(item.get('PREF',''),v,w)
                if temp == '': continue
                prefs.append("[PREFSTRING:"+temp.lower().strip()+"]")

        self.obj['prefstring'] = '\n\t'.join(prefs)

  #==================================================================================================
    def get_rawstring(self):
        raws = {}
        order = self.obj['rawObjects']
        for k in order:
            raws[k] = []

        # First add sub sub objects raws to their source
        #for v in self.obj['sourceObjects']:
        #    for w in self.obj[v].keys():
        #        st = self.obj[v][w]['SOURCE_TYPE']
        #        sk = self.obj[v][w]['SOURCE_KEY']
        #        for rk in self.obj[st][sk].get('RAWS',{}).keys():
        #            temp = self.obj[v][w].get('RAWS',{}).get(rk,[])
        #            for j,string in enumerate(self.obj[v][w].get('RAWS',{}).get(rk,[])):
        #                temp[j] = self.replace_special_chars(string,v,w)
        #            self.obj[st][sk]['RAWS'][rk] += temp

        for v in self.obj['baseObjects'] + self.obj['subObjects'] + self.obj['sourceObjects']:
            for w in self.obj[v].keys():
                for k in self.obj[v][w].get('RAWS',{}).keys():
                    temp = self.obj[v][w]['RAWS'][k]
                    ins = ''
                    for j,string in enumerate(temp):
                        temp[j] = ins + self.replace_special_chars(string,v,w)
                        #ins = '\t'
                    raws[k] += temp
                for k in self.obj[v][w].get('COMPANION',{}).keys():
                    if k == 'NAME' or k == 'RAWS':
                        tstr = self.obj[v][w]['COMPANION'][k]
                        self.obj[v][w]['COMPANION'][k] = self.replace_special_chars(tstr,v,w)

        rawstring = ''
        if self.con['pretty_raws']:
            for k in order:
                test = ''.join(raws[k])
                if test.count('}{') > 0:
                    test = test.replace('}{',':')
                    test = test.replace('{','[')
                    test = test.replace('}',']')
                    raws[k] = [test]
                #rawstring += '\n|\n' + k + '\n|\n' + '\n'.join(raws[k]) + '\n'
                rawstring += '\n|\n' + '\n'.join(raws[k]) + '\n'
        else:
            for k in order:
                test = ''.join(raws[k])
                if test.count('}{') > 0:
                    test = test.replace('}{',':')
                    test = test.replace('{','[')
                    test = test.replace('}',']')
                    raws[k] = [test]
                rawstring += '\n\t'.join(raws[k]) + '\n'
        
        fix_list = ["USE_MATERIAL_TEMPLATE","GROWTH","INORGANIC","ATTACK","BODY_DETAIL_PLAN","SELECT_TISSUE_LAYER",
                    "PHYS_ATT_RANGE","MENT_ATT_RANGE","BODY_APPEARANCE_MODIFIER","CASTE","USE_TISSUE_TEMPLATE",
                    "SET_TL_GROUP","SET_BP_GROUP"]
        for x in fix_list:
            rawstring = rawstring.replace('\t['+x+':','['+x+':')
        self.raw_string = rawstring

  #==================================================================================================
    def replace_special_chars(self,string,k1,k2,desc=False):
        sobj = self.obj[k1][k2]
        names = self.obj.get('NAMES',{})
        colorValue = self.obj['colorValues'][k1][k2]
        colorState = self.obj['colorStates'][k1][k2]

        # Replace BIN strings (<_:_>)
        while string.count('<') > 0 and string.count('>') > 0:
            li = string.find('<')
            ri = string.find('>',li+1)
            grab = string[li:ri+1]
            bobj = int(grab[1:].split(':')[0]) - 1
            btyp = grab[:-1].split(':')[1]
            replace = sobj["BIN"][bobj][btyp]
            string = string.replace(grab,replace)

        # Replace LINK strings (&_:_&)
        while string.count('&') > 0:
            li = string.find('&')
            ri = string.find('&',li+1)
            grab = string[li:ri+1]
            n = int(grab[1:].split(':')[0])
            t = grab[:-1].split(':')[1].upper()
            try:
                link = sobj['LINK'][n-1]
            except:
                print(grab)
                print(sobj)
            if t == 'N':
                replace = sobj['LINK_OBJECTS'][link].get(t,{}).get(grab[:-1].split(':')[2],grab[1:-1])
                replace = str(replace)
            else:
                replace = sobj['LINK_OBJECTS'][link].get(t,grab[1:-1])
            if t == 'RAWS': replace = '\n'.join(replace)
            if t == 'DESC': replace = replace[0]
            #if replace[0] == '\t': replace = replace[1:]
            string = string.replace(grab,replace)
            self.obj['LINKS'].append(sobj['LINK_OBJECTS'][link]['TAG'])

        # Replace HOST strings (@_:_@)
        while string.count('@') > 0:
            li = string.find('@')
            ri = string.find('@',li+1)
            grab = string[li:ri+1]
            split = grab[1:-1].split(':')
            if len(split) == 2:
                cat = split[0]
                key = list(self.obj[cat].keys())[0]
                typ = split[1]
            else:
                cat = split[0]
                key = split[1]
                typ = split[2]
            replace = self.obj[cat][key].get(typ,grab[1:-1])
            if desc:
                string = string.replace(grab,replace)
            else:
                string = string.replace(grab,replace.upper())

        # Replace NUMBER strings ($_:_$)
        while string.count('$') > 0:
            li = string.find('$')
            ri = string.find('$',li+1)
            grab = string[li:ri+1]
            if grab[1:].split(':')[0] == 'N':
                nt = grab[1:].split(':')[1]
                n1 = str(self.obj['NUMBERS'][nt])
                n2 = int(grab[:-1].split(':')[2]) - 1
                nd = list(self.obj['numberObjects'][nt.lower()].keys())[1]
                nu = list(self.obj['numberObjects'][nt.lower()].keys())[-1]
                if int(n1) < int(nd): n1 = nd
                if int(n1) > int(nu): n1 = nu
                replace = self.obj['numberObjects'][nt.lower()][n1][n2]
            elif grab[1:].split(':')[0] == 'X':
                replace = grab[1:-1]
            elif grab[1:].split(':')[0] == 'Y':
                replace = grab[1:-1]
            else:
                n1 = int(grab[1:].split(':')[0])
                n2 = int(grab[:-1].split(':')[1])
                replace = str(random.randint(n1,n2))
            string = string.replace(grab,replace)

        # Replace OBJECT strings (#_)
        for key in sobj.keys():
            if key == 'COLORS' and string.count('#COLORS') > 0:
                for l, w in sobj['COLORS'].items():
                    string = string.replace('#COLORS_'+l,w)
            else:
                if string.count('#'+key) > 0:  string = string.replace('#'+key,sobj[key])
        string = string.replace('#TAG',self.obj['TAG'])

        # Replace SPECIAL strings (!_)
        string = string.replace('!PREFSTRING',    self.obj.get('prefstring','!PREFSTRING'))
        string = string.replace('!NAME_SINGULAR', names.get('singular','!NAME_SINGULAR'))
        string = string.replace('!NAME_PLURAL',   names.get('plural','!NAME_PLURAL'))
        string = string.replace('!NAME_ADJ',      names.get('adjective','!NAME_ADJ'))
        string = string.replace('!COLOR_RGB',     colorValue.get('BASE','!COLOR_RGB'))
        string = string.replace('!COLOR_STATE',   colorState.get('BASE','!COLOR_STATE'))
        string = string.replace('!TAG', self.obj['TAG'])
        string = string.replace('!n', '\n')

        # Evaluate equations ((_))
        while string.count('(') > 0 and string.count(')') > 0:
            li = string.find('(')
            ri = string.find(')',li+1)
            grab = string[li:ri+1]
            n = int(eval(grab[1:-1]))
            if n < 1: n = 1
            replace = str(n)
            string = string.replace(grab,replace)

        return string

  #==================================================================================================
    def get_raw(self,comp_obj):
        self.obj['LINKS'] = []
        material_source = self.con['mat_source']
        self.get_colors()
        self.get_name()

        # If this is a companion object, we need to replace certain values with the companion values
        # name, value, colors, links, ???
        if not comp_obj == {}:
            # NUMBERS
            self.obj['NUMBERS'] = comp_obj['NUMBERS']
            # NAMES
            singular = comp_obj['COMP_OBJ'].get('NAME',comp_obj['NAMES']['singular'])
            self.obj['NAMES']['singular']  = singular
            self.obj['NAMES']['plural']    = singular+'s'
            self.obj['NAMES']['adjective'] = singular
            for k,v in comp_obj['COMP_OBJ'].items():
                if k == "SOURCE" or k == "NAME" or k == "RAWS": continue
                cv = list(comp_obj[k].keys())[0]
                # colorValues
                if comp_obj['colorValues'][k][cv].get('BASE',False):
                    self.obj['colorValues'][k][v]['BASE'] = comp_obj['colorValues'][k][cv]['BASE']
                # colorStates
                if comp_obj['colorStates'][k][cv].get('BASE',False):
                    self.obj['colorStates'][k][v]['BASE'] = comp_obj['colorStates'][k][cv]['BASE']
                # colorNames
                self.obj[k][v]['COLORS'] = comp_obj[k][cv]['COLORS']
                # LINKS
                if comp_obj[k][cv].get('LINK',False):
                    self.obj[k][v]['LINK'] = comp_obj[k][cv]['LINK']
                    self.obj[k][v]['LINK_OBJECTS'] = comp_obj[k][cv]['LINK_OBJECTS'] 

        self.get_description()
        self.get_prefstring()
        self.get_rawstring()

        # Check if raws are valid and get the materials and items needed
        while self.raw_string.count('\n\t\n') > 0:
         self.raw_string = self.raw_string.replace('\n\t\n', '\n')
        while self.raw_string.count('\n\n') > 0:
         self.raw_string = self.raw_string.replace('\n\n', '\n')

        self.out = {}
        self.out['NAME']   = self.obj['NAMES'].get('singular','')
        self.out['TAG']    = self.obj['TAG']
        self.out['TOKENS'] = self.obj['TOKENS']
        self.out['LINKS']  = list(set(self.obj['LINKS']))
        self.out['N']      = self.obj['NUMBERS']
        self.out['DESC']   = self.obj['description'].split('\n')
        if self.out['DESC'][-1] == '': self.out['DESC'] = self.out['DESC'][:-1]
        self.out['RAWS']   = []
        for string in self.raw_string.split('\n'):
            if string != '': self.out['RAWS'].append(string)

        # Add any additional raws from other sources (like companions)
        if not comp_obj == {}:
            self.out['RAWS'].append(comp_obj['COMP_OBJ'].get('RAWS',''))



