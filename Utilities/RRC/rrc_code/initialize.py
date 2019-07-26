import json

class InitializeRaws:
    def __init__(self):
        self.raws = {}

        print('Reading templates/raws.json')
        f = open('templates/raws.json')
        raws = json.load(f)
        self.create_MATERIAL_TEMPLATE(raws['base_materials'])
        self.create_TISSUE_TEMPLATE(raws['base_tissues'])
        self.create_BODY(raws['raw_bodies'])
        self.create_BODY_DETAIL_PLAN(raws['raw_body_detail'])
        self.create_CREATURE_VARIATION_TEMPLATE(raws['raw_cvt'])
        self.raws['colors'] = raws['colors']

    def create_MATERIAL_TEMPLATE(self,raws):
        self.raws['MATERIAL_TEMPLATE'] = {}
        for key in raws.keys():
            if key == '__comment': continue
            self.raws['MATERIAL_TEMPLATE'][key] = raws[key]

    def create_TISSUE_TEMPLATE(self,raws):
        self.raws['TISSUE_TEMPLATE'] = {}
        for key in raws.keys():
            if key == '__comment': continue
            self.raws['TISSUE_TEMPLATE'][key] = raws[key]

    def create_BODY(self,raws):
        self.raws['BODY'] = {}
        for key in raws.keys():
            if key == '__comment': continue
            for part in raws[key].keys():
                if part == '__comment': continue
                self.raws['BODY'][part] = []
                for x,item in raws[key][part].items():
                    if x == '__comment': continue
                    self.raws['BODY'][part] += item

    def create_BODY_DETAIL_PLAN(self,raws):
        self.raws['BODY_DETAIL_PLAN'] = {}
        for key in raws.keys():
            if key == '__comment': continue
            for part in raws[key].keys():
                if part == '__comment': continue
                self.raws['BODY_DETAIL_PLAN'][part] = []
                for x,item in raws[key][part].items():
                    if x == '__comment': continue
                    self.raws['BODY_DETAIL_PLAN'][part] += item

    def create_CREATURE_VARIATION_TEMPLATE(self,raws):
        self.raws['CREATURE_VARIATION_TEMPLATE'] = {}
        for key in raws.keys():
            if key == '__comment': continue
            for part in raws[key].keys():
                if part == '__comment': continue
                self.raws['CREATURE_VARIATION_TEMPLATE'][part] = []
                for x,item in raws[key][part].items():
                    if x == '__comment': continue
                    self.raws['CREATURE_VARIATION_TEMPLATE'][part] += item
