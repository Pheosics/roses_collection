import random
import json

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
    # Fix A -> An for vowels
    # Fis is/are and other singular/plural issues
    # Fix and/but issues
    return string

#==================================================================================================
class GenerateRaws:
    def __init__(self,obj,configuration,world,raws):
        self.colors = raws['colors']
        self.con   = configuration
        self.obj   = obj
        self.world = world

        self.get_raw()

  #==================================================================================================
    def get_name(self):
        names = {}

        name = ''
        for v in self.obj['baseObjects']: # + self.obj['subObjects'] + self.obj['sourceObjects']:
            for w, item in self.obj[v].items():
                name += self.replace_special_chars(item.get('NAME',''),v,w)
        name = ' '.join(name.split()).lower()

        names['singular']  = name
        names['plural']    = name + 's'
        names['adjective'] = name
        self.names = names

  #==================================================================================================
    def get_token(self):
        str1 = ''
        for v in self.obj['baseObjects']:
            tstr = self.obj[v].get('TYPE','')
            str1 += tstr + '_'
        str1 += 'XXXXX'

        self.obj['token'] = str1

  #==================================================================================================
    def get_description(self):
        str1 = ''
        for v in self.obj['baseObjects']:
            for w in self.obj[v].keys():
                tstr = self.obj[v][w].get('DESC','')
                tstr = self.replace_special_chars(tstr,v,w)
                str1 += tstr + ' '
        str1 = ' '.join(str1.split()) + '\n'

        str2 = ''
        for v in self.obj['subObjects']:
            str2 = str2 + fix_label(v.upper()) + ':'+'\n'
            n = 0
            for w,x in self.obj[v].items():
                tstr = x.get('DESC','')
                tstr = self.replace_special_chars(tstr,v,w)
                tstr = ' '.join(tstr.split())
                if tstr != '': str2 += '  '+tstr + '\n'
                for s,y in x.get('SOURCE_OBJECTS',{}).items():
                    for t in y:
                        tstr = self.obj[s.lower()][t+'_'+v.upper()].get('DESC','')
                        tstr = self.replace_special_chars(tstr,s.lower(),t+'_'+v.upper())
                        tstr = ' '.join(tstr.split())
                        str2 += '    '+tstr + '\n'
                n += 1
            if n == 0: str2 += '    None\n'

        str3 = ''
        for v in self.obj['sourceObjects']:
            str3 = str3 + fix_label(v.upper()) + ':'+'\n'
            n = 0
            for w,x in self.obj[v].items():
                if self.obj['subObjects'].count(x['SOURCE_TYPE']) > 0: continue
                tstr = x.get('DESC','')
                tstr = self.replace_special_chars(tstr,v,w)
                tstr = ' '.join(tstr.split())
                str3 += '    '+tstr + '\n'
                n += 1
            if n == 0: str3 = ' ' #'    None\n'
        str3 = str3[:-1]

        self.obj['description'] = fix_string(str1 + str2 + str3)

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
            #colorValues[v] = {}
            #colorStates[v] = {}
            for k, w in self.obj[v].items():
                #colorValues[v][k] = {}
                #colorStates[v][k] = {}
                k1 = w['SOURCE_TYPE']
                k2 = w['SOURCE_KEY']
                #self.obj[v][k]['COLORS'] = self.obj[k1][k2]['COLORS']
                for key in colorValues[k1][k2].keys():
                    colorValues[v][k][key] = colorValues[k1][k2][key]
                    colorStates[v][k][key] = colorStates[k1][k2][key]

        self.obj['colorValues'] = colorValues
        self.obj['colorStates'] = colorStates
        self.colorValues = colorValues
        self.colorStates = colorStates

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
                        ins = '\t'
                    raws[k] += temp

        rawstring = ''
        if self.con['pretty_raws'] == 'True':
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
                rawstring += '\n'.join(raws[k]) + '\n'
        self.raw_string = rawstring

  #==================================================================================================
    def replace_special_chars(self,string,k1,k2):
        sobj = self.obj[k1][k2]
        colorValue = self.colorValues[k1][k2]
        colorState = self.colorStates[k1][k2]

        # Replace BIN strings (<_:_>)
        while string.count('<') > 0 and string.count('>') > 0:
            li = string.find('<')
            ri = string.find('>',li+1)
            grab = string[li:ri+1]
            bobj = grab[1:].split(':')[0]
            btyp = grab[:-1].split(':')[1]
            replace = self.obj[bobj][btyp]
            string = string.replace(grab,replace)

        # Replace LINK strings (&_:_&)
        while string.count('&') > 0:
            li = string.find('&')
            ri = string.find('&',li+1)
            grab = string[li:ri+1]
            n = int(grab[1:].split(':')[0])
            t = grab[:-1].split(':')[1]
            link = sobj['LINK'][n-1]
            replace = sobj['LINK_OBJECTS'][link].get(t.lower(),grab[1:-1])
            if t == 'RAWS': replace = '\n'.join(replace)
            if t == 'DESC': replace = replace[0]
            string = string.replace(grab,replace)
            self.obj['LINKS'].append(link)

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
                replace = self.obj['numberObjects'][nt.lower()][n1][n2]
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

        # Replace SPECIAL strings (!_)
        string = string.replace('!PREFSTRING',    self.obj.get('prefstring','!PREFSTRING'))
        string = string.replace('!NAME_SINGULAR', self.names.get('singular','!NAME_SINGULAR'))
        string = string.replace('!NAME_PLURAL',   self.names.get('plural','!NAME_PLURAL'))
        string = string.replace('!NAME_ADJ',      self.names.get('adjective','!NAME_ADJ'))
        string = string.replace('!COLOR_RGB',     colorValue.get('BASE','!COLOR_RGB'))
        string = string.replace('!COLOR_STATE',   colorState.get('BASE','!COLOR_STATE'))
        string = string.replace('!n', '\n')

        # Evaluate equations ((_))
        while string.count('(') > 0 and string.count(')') > 0:
            li = string.find('(')
            ri = string.find(')',li+1)
            grab = string[li:ri+1]
            replace = str(eval(grab[1:-1]))
            string = string.replace(grab,replace)

        return string

  #==================================================================================================
    def get_raw(self):
        self.obj['LINKS'] = []
        material_source = self.con['material_source']
        self.names = {}
        self.get_colors()
        self.get_token()
        self.get_name()
        self.get_description()
        self.get_rawstring()

        # Check if raws are valid and get the materials and items needed
        while self.raw_string.count('\n\t\n') > 0:
         self.raw_string = self.raw_string.replace('\n\t\n', '\n')
        while self.raw_string.count('\n\n') > 0:
         self.raw_string = self.raw_string.replace('\n\n', '\n')

        self.out = {}
        self.out['name']   = self.names.get('singular','')
        self.out['tag']    = self.obj['TAG']
        self.out['desc']   = self.obj['description'].split('\n')
        self.out['TOKENS'] = self.obj['TOKENS']
        self.out['LINKS']  = self.obj['LINKS']
        self.out['N']      = self.obj['NUMBERS']
        self.out['raws']   = []
        for string in self.raw_string.split('\n'):
            if string != '': self.out['raws'].append(string)
