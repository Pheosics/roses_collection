import json

class InitializeRaws:
    def __init__(self):
        self.raws = {}

        print('Reading templates/raws.json')
        f = open('templates/raws.json')
        raws = json.load(f)
        self.create_BASE_1('MATERIAL_TEMPLATE',  raws['base_materials'])
        self.create_BASE_1('TISSUE_TEMPLATE',    raws['base_tissues'])
        self.create_BASE_1('INORGANIC',          raws['base_inorganics'])
        self.create_BASE_2('BODY',               raws['raw_bodies'])
        self.create_BASE_1('BODY_DETAIL_PLAN',   raws['raw_body_detail'])
        self.create_BASE_2('CREATURE_VARIATION', raws['raw_cvt'])
        self.raws['colors'] = raws['colors']

    def create_BASE_1(self,name,raws):
        self.raws[name] = {}
        for key in raws.keys():
            if key == '__comment': continue
            self.raws[name][key] = raws[key]

    def create_BASE_2(self,name,raws):
        self.raws[name] = {}
        for key in raws.keys():
            if key == '__comment': continue
            for part in raws[key].keys():
                if part == '__comment': continue
                self.raws[name][part] = []
                for x,item in raws[key][part].items():
                    if x == '__comment': continue
                    self.raws[name][part] += item
