import rrc_code.objects    as rrcObjects
import rrc_code.raws       as rrcRaws
import rrc_code.initialize as rrcInitialize
import rrc_code.finalize   as rrcFinalize
from rrc_code.templates import Templates
import json
import time
import inspect
import copy

world = {}
ordering = { 
    0:  ['syndromes',   None,               None],
    1:  ['materials',   "material_template","material_template"],
    2:  ['environments',None,               None],
    3:  ['inorganics',  "inorganic",       "inorganic"],
    4:  ['spells',      None,              None],
    5:  ['plants',      "plant",           "plant"],
    6:  ['weapons',     "item",            "item_weapon"],
    7:  ['creatures',   "creature",        "creature"],
    8:  ['buildings',   "building",        "building"],
    9:  ['reactions',   "reaction",        "reaction"],
    10: ['entities',    "entity",          "entity"]
}

def get_counts(count,raws,obj):
    for key in obj['baseObjects'] + obj['subObjects']:
        count[key] = count.get(key,{})
        for k,v in obj[key].items():
            count[key][v['TYPE']] = count[key].get(v['TYPE'],0) + 1

    for key in obj['sourceObjects']:
        count[key] = count.get(key,{})
        for k,v in obj[key].items():
            count[key][v['TYPE']] = count[key].get(v['TYPE'],0) + 1

    count['TOTAL'] = count.get('TOTAL',0) + 1
    return count

def print_counts(count,start,con,Type):
    n = count.get('TOTAL',0)
    if n == 0: n = con['n_'+Type]
    num = con['n_'+Type]
    print('Created ' + str(n) + ' '+ Type.ljust(13) + ' out of ' +str(num) + \
          ' in ' + str(round(time.time()-start,1)) + ' seconds')
    if con['details'] == 'True' and n > 1:
        for key in count.keys():
            if key == 'TOTAL': continue
            p = 18
            print(key, len(list(count[key])))
            for c_key, x in sorted(count[key].items(), reverse=True, key=lambda kv:(kv[1],kv[0])):
                x = count[key][c_key]
                print('\t'+c_key.ljust(p)+':','\t'+str(x),'\t'+str(round(100*x/n,1))+'%')

def create(Type,con,world,extRaws):
    start = time.time()
    count = {}
    n = con['n_'+Type]
    i = 0
    force = {}
    template = Templates(Type.upper())
    while i < con['n_'+Type]:
        obj = rrcObjects.GenerateObject(extRaws,copy.deepcopy(template),Type,con,world,i,force=force).obj
        #print(json.dumps(obj,indent=4))
        raw = rrcRaws.GenerateRaws(obj,con,world,extRaws)
        raw_string = raw.raw_string
        if len(raw.out['raws']) == 0: continue
        count = get_counts(count,raw,obj)
        world[Type].append(raw.out)
        i += 1
    if con['n_'+Type] == 1 and con['details'] == 'True':
        print(raw.obj['token'])
        print(raw.obj['description'])
        print(raw_string)
    print_counts(count,start,con,Type)
    return world[Type]

if __name__ == '__main__':
    print('RANDOM WORLD CREATOR STARTING\n')
    f = open('configuration.json')
    con = json.load(f)
    f.close()

    raws = rrcInitialize.InitializeRaws().raws
    for i in range(len(list(ordering.keys()))):
        Type = ordering[i][0]
        world[Type] = []
        if con['n_'+Type] > 0:
            world[Type] = create(Type,con,world,raws)
            if con['json_output'] == 'False': continue
            with open(Type+'.json','w') as outfile:
                json.dump(world[Type], outfile, indent=4)
        else:
            print('No '+Type+' created')
            world[Type] = []
    rrcFinalize.FinalizeRaws(raws,world,ordering)
