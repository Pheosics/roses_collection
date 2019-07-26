import json

class FinalizeRaws:
    def __init__(self,raws,world,order):
        print('Writing EXTERNAL raws')
        for key in raws.keys():
            if key == 'colors': continue
            self.write_EXTERNAL(raws,key)

        for i in range(len(list(order.keys()))):
            self.write_RAWS(world,order[i])

    def write_EXTERNAL(self,raws,ext):
        fname = ext.lower()+'_base_rrc.txt'
        f = open('raws/'+fname,'w')
        f.write(fname[:-4]+'\n')
        f.write('\n[OBJECT:'+ext+']\n')
        for key, item in raws[ext].items():
            f.write('\n['+ext+':'+key+']\n\t')
            f.write('\n\t'.join(item))
            f.write('\n')
        f.close()

    def write_RAWS(self,world,order):
        if order[1] == None: return
        Type = order[0]
        obj  = order[1]
        key  = order[2]
        if key == None: key = obj
        raws = world[Type]
        fname = key + '_rrc.txt'
        f = open('raws/'+fname,'w')
        f.write(fname[:-4]+'\n')
        f.write('\n[OBJECT:'+obj.upper()+']\n')
        for d in raws:
            f.write('\n['+key.upper()+':'+d['tag']+']\n\t')
            f.write('\n\t'.join(d['desc'])+'\n\t')
            f.write('\n\t'.join(d['raws']))
            f.write('\n')
        f.close()
