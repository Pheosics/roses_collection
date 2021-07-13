--@ module=true

info = {}
info["BUILDING"] = [===[ TODO ]===]

hardcoded_bldgs = { -- df.building_type
	WORKSHOP = { -- df.workshop_type
		CARPENTERS = df.workshop_type.Carpenters,
		FARMERS = df.workshop_type.Farmers,
		MASONS = df.workshop_type.Masons,
		CRAFTSDWARFS = df.workshop_type.Craftsdwarfs,
		JEWELERS = df.workshop_type.Jewelers,
		METALSMITHSFORGE = df.workshop_type.MetalsmithsForge,
		MAGMAFORGE = df.workshop_type.MagmaForge,
		BOWYERS = df.workshop_type.Bowyers,
		MECHANICS = df.workshop_type.Mechanics,
		SIEGE = df.workshop_type.Siege,
		BUTCHERS = df.workshop_type.Butchers,
		LEATHERWORKS = df.workshop_type.Leatherworks,
		TANNERS = df.workshop_type.Tanners,
		CLOTHIERS = df.workshop_type.Clothiers,
		FISHERY = df.workshop_type.Fishery,
		STILL = df.workshop_type.Still,
		LOOM = df.workshop_type.Loom,
		QUERN = df.workshop_type.Quern,
		KENNELS = df.workshop_type.Kennels,
		ASHERY = df.workshop_type.Ashery,
		KITCHEN = df.workshop_type.Kitchen,
		DYERS = df.workshop_type.Dyers,
		TOOL = df.workshop_type.Tool,
		MILLSTONE = df.workshop_type.Millstone,
		CUSTOM = df.workshop_type.Custom,
	},
	FURNACE = { -- df.furnace_type
		WOOD_FURNACE = df.furnace_type.WoodFurnace,
		SMELTER = df.furnace_type.Smelter,
		GLASS_FURNACE = df.furnace_type.GlassFurnace,
		MAGMA_SMELTER = df.furnace_type.MagmaSmelter,
		MAGMA_GLASS_FURNACE = df.furnace_type.MagmaGlassFurnace,
		MAGMA_KILN = df.furnace_type.MagmaKiln,
		KILN = df.furnace_type.Kiln,
		CUSTOM = df.furnace_type.Custom
	},
	CIVZONE = { -- df.civzone_type
		HOME = df.civzone_type.Home,
		DEPOT = df.civzone_type.Depot,
		STOCKPILE = df.civzone_type.Stockpile,
		NOBLEQUARTERS = df.civzone_type.NobleQuarters,
		MEADHALL = df.civzone_type.MeadHall,
		THRONEROOM = df.civzone_type.ThroneRoom,
		ACTIVITYZONE = df.civzone_type.ActivityZone,
		TEMPLE = df.civzone_type.Temple,
		KITCHEN = df.civzone_type.Kitchen,
		CAPTIVEROOM = df.civzone_type.CaptiveRoom,
		TOWERTOP = df.civzone_type.TowerTop,
		COURTYARD = df.civzone_type.Courtyard,
		TREASURY = df.civzone_type.Treasury,
		GUARDPOST = df.civzone_type.GuardPost,
		ENTRANCE = df.civzone_type.Entrance,
		SECRETLIBRARY = df.civzone_type.SecretLibrary,
		LIBRARY = df.civzone_type.Library,
		PLOT = df.civzone_type.Plot,
		MARKETSTALL = df.civzone_type.MarketStall,
		CAMPGROUND = df.civzone_type.Campground,
		COMMANDTENT = df.civzone_type.CommandTent,
		TENT = df.civzone_type.Tent,
		COMMANDTENTBLD = df.civzone_type.CommandTentBld,
		TENTBLD = df.civzone_type.TentBld,
		MECHANISMROOM = df.civzone_type.MechanismRoom,
		DUNGEONCELL = df.civzone_type.DungeonCell,
		ANIMALPIT = df.civzone_type.AnimalPit,
		CLOTHPIT = df.civzone_type.ClothPit,
		TANNINGPIT = df.civzone_type.TanningPit,
		CLOTHCLOTHINGPIT = df.civzone_type.ClothClothingPit,
		LEATHERCLOTHINGPIT = df.civzone_type.LeatherClothingPit,
		BONECARVINGPIT = df.civzone_type.BoneCarvingPit,
		GEMCUTTINGPIT = df.civzone_type.GemCuttingPit,
		WEAPONSMITHINGPIT = df.civzone_type.WeaponsmithingPit,
		BOWMAKINGPIT = df.civzone_type.BowmakingPit,
		BLACKSMITHINGPIT = df.civzone_type.BlacksmithingPit,
		ARMORSMITHINGPIT = df.civzone_type.ArmorsmithingPit,
		METALCRAFTINGPIT = df.civzone_type.MetalCraftingPit,
		LEATHERWORKINGPIT = df.civzone_type.LeatherworkingPit,
		CARPENTRYPIT = df.civzone_type.CarpentryPit,
		STONEWORKINGPIT = df.civzone_type.StoneworkingPit,
		FORGINGPIT = df.civzone_type.ForgingPit,
		FIGHTINGPIT = df.civzone_type.FightingPit,
		ANIMALWORKSHOP = df.civzone_type.AnimalWorkshop,
		CLOTHWORKSHOP = df.civzone_type.ClothWorkshop,
		TANNINGWORKSHOP = df.civzone_type.TanningWorkshop,
		CLOTHCLOTHINGWORKSHOP = df.civzone_type.ClothClothingWorkshop,
		LEATHERCLOTHINGWORKSHOP = df.civzone_type.LeatherClothingWorkshop,
		BONECARVINGWORKSHOP = df.civzone_type.BoneCarvingWorkshop,
		GEMCUTTINGWORKSHOP = df.civzone_type.GemCuttingWorkshop,
		WEAPONSMITHINGWORKSHOP = df.civzone_type.WeaponsmithingWorkshop,
		BOWMAKINGWORKSHOP = df.civzone_type.BowmakingWorkshop,
		BLACKSMITHINGWORKSHOP = df.civzone_type.BlacksmithingWorkshop,
		ARMORSMITHINGWORKSHOP = df.civzone_type.ArmorsmithingWorkshop,
		METALCRAFTINGWORKSHOP = df.civzone_type.MetalCraftingWorkshop,
		LEATHERWORKINGWORKSHOP = df.civzone_type.LeatherworkingShop,
		CARPENTRYWORKSHOP = df.civzone_type.CarpentryWorkshop,
		STONEWORKINGWORKSHOP = df.civzone_type.StoneworkingWorkshop,
		FORGINGWORKSHOP = df.civzone_type.ForgingWorkshop,
	},
	CONSTRUCTION = { -- df.construction_type
		FORTIFICATION = df.construction_type.Fortification,
		WALL = df.construction_type.Wall,
		FLOOR = df.construction_type.Floor,
		UPSTRAIR = df.construction_type.UpStair,
		DOWNSTAIR = df.construction_type.DownStair,
		UPDOWNSTAIR = df.construction_type.UpDownStair,
		RAMP = df.construction_type.Ramp,
		TRACKN = df.construction_type.TrackN,
		TRACKS = df.construction_type.TrackS,
		TRACKE = df.construction_type.TrackE,
		TRACKW = df.construction_type.TrackW,
		TRACKNS = df.construction_type.TrackNS,
		TRACKNE = df.construction_type.TrackNE,
		TRACKNW = df.construction_type.TrackNW,
		TRACKSE = df.construction_type.TrackSE,
		TRACKSW = df.construction_type.TrackSW,
		TRACKEW = df.construction_type.TrackEW,
		TRACKNSE = df.construction_type.TrackNSE,
		TRACKNSW = df.construction_type.TrackNSW,
		TRACKNEW = df.construction_type.TrackNEW,
		TRACKSEW = df.construction_type.TrackSEW,
		TRACKNSEW = df.construction_type.TrackNSEW,
		TRACKRAMPN = df.construction_type.TrackRampN,
		TRACKRAMPS = df.construction_type.TrackRampS,
		TRACKRAMPE = df.construction_type.TrackRampE,
		TRACKRAMPW = df.construction_type.TrackRampW,
		TRACKRAMPNS = df.construction_type.TrackRampNS,
		TRACKRAMPNE = df.construction_type.TrackRampNE,
		TRACKRAMPNW = df.construction_type.TrackRampNW,
		TRACKRAMPSE = df.construction_type.TrackRampSE,
		TRACKRAMPSW = df.construction_type.TrackRampSW,
		TRACKRAMPEW = df.construction_type.TrackRampEW,
		TRACKRAMPNSE = df.construction_type.TrackRampNSE,
		TRACKRAMPNSW = df.construction_type.TrackRampNSW,
		TRACKRAMPNEW = df.construction_type.TrackRampNEW,
		TRACKRAMPSEW = df.construction_type.TrackRampSEW,
		TRACKRAMPNSEW = df.construction_type.TrackRampNSEW,
	},
	SHOP = { -- df.shop_type
		GENERALSTORE = df.shop_type.GeneralStore,
		CRAFTSMARKET = df.shop_type.CraftsMarket,
		CLOTHINGSHOP = df.shop_type.ClothingShop,
		EXOTICCLOTHINGSHOP = df.shop_type.ExoticClothingShop,
	},
	SIEGEENGINE = { -- df.siegeengine_type
		CATAPULT = df.siegeengine_type.Catapult,
		BALLISTA = df.siegeengine_type.Ballista,
	},
	TRAP = { --df.trap_type
		LEVER = df.trap_type.Lever,
		PRESSUREPLATE = df.trap_type.PressurePlate,
		CAGETRAP = df.trap_type.CageTrap,
		STONEFALLTRAP = df.trap_type.StoneFallTrap,
		WEAPONTRAP = df.trap_type.WeaponTrap,
		TRACKSTOP = df.trap_type.TrackStop,
	},
}

--===============================================================================================--
--== BUILDING CLASSES ===========================================================================--
--===============================================================================================--
local BUILDING = defclass(BUILDING) -- references <building>
function getBuilding(building) return BUILDING(building) end

--===============================================================================================--
--== BUILDING FUNCTIONS =========================================================================--
--===============================================================================================--
function BUILDING:__index(key,...)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(BUILDING,key) then return rawget(BUILDING,key) end
	return self._building[key]
end
function BUILDING:__tostring()
	return self.type..":"..self.subtype..":"..self.customtype
end
function BUILDING:init(building)
	if tonumber(building) then building = df.building.find(tonumber(building)) end
	if not building then return nil end
	self.id = building.id
	self.type_id = building:getType()
	self.subtype_id = building:getSubtype()
	self.customtype_id = building:getCustomType()
	self.type = df.building_type[self.type_id]:upper()
	if hardcoded_bldgs[self.type] then
		self.subtype = df[self.type:lower().."_type"][self.subtype_id]:upper()
	else
		self.subtype = "NONE"
	end
	if self.customtype_id >= 0 then
		self.customtype = df.global.world.raws.buildings.all[self.customtype_id].code -- Is this true? -ME
		self.subtype = "CUSTOM"
		self.Token = self.customtype
	else
		self.customtype = "NONE"
		self.Token = self.subtype
	end
	self._building = building
	
	-- dfhack.buildings Functions
	self.dfhack_functions = {}
	for name, func in pairs(dfhack.buildings) do
		self.dfhack_functions[name] = function(...) return func(self._building, ...) end
	end
end

function BUILDING:addItem(item)
	local building = df.building.find(self.id)
	if tonumber(item) then item = df.item.find(item) end
	dfhack.items.moveToBuilding(item,building,2)
	item.flags.in_building = true
end

function BUILDING:changeCustomtype(custom)
	local building = df.building.find(self.id)
	local ctype = -1
	for _,bldgRaw in ipairs(df.global.world.raws.buildings.all) do
		if bldgRaw.code == custom then
			ctype = bldgRaw.id
			break
		end
	end
	if ctype >= 0 then
		building:setCustomType(ctype) -- vmethod
		return true
	end
	return false
end

function BUILDING:changeSubtype(subtype)
	local building = df.building.find(self.id)
	local stype = hardcoded_bldgs[self.type:upper()][subtype:upper()]
	if stype >= 0 then
		building:setSubtype(stype) -- vmethod
		return true
	end
	return false
end

--===============================================================================================--
--== ENHANCED BUILDING FUNCTIONS ================================================================--
--===============================================================================================--
function BUILDING:count() -- For now only counts custom buildings as custom buildings are the only ones that can be "enhanced"
	local number = 0
	for _,bldg in pairs(df.global.world.buildings.all) do
		if bldg:getCustomType() >= 0 and df.global.world.raws.buildings.all[bldg:getCustomType()].code == self.customtype then
			number = number+1
		end
	end
	return number
end

function BUILDING:deconstruct()
	dfhack.buildings.deconstruct(self._building)
end

function BUILDING:nearbyMagma()
	local amount = 0
	for z = self._building.z - 1, self._building.z do
		for y = self.building.y1 - 1, self._building.y2 + 1 do
			for x = self.building.x1 - 1, self._building.x2 + 1 do
				local flags = dfhack.maps.getTileFlags(x,y,z)
				if flags.liquid_type then amount = amount + flags.flow_size end
			end
		end
	end
	return amount
end

function BUILDING:nearbyWater()
	local amount = 0
	for z = self._building.z - 1, self._building.z do
		for y = self._building.y1 - 1, self._building.y2 + 1 do
			for x = self._building.x1 - 1, self._building.x2 + 1 do
				local flags = dfhack.maps.getTileFlags(x,y,z)
				if not flags.liquid_type then amount = amount + flags.flow_size end
			end
		end
	end
	return amount
end

function BUILDING:isInside()
	local z = self._building.z
	local inside = true
	for x = self._building.x1, self._building.x2 do
		for y = self._building.y1, self._building.y2 do
			if dfhack.maps.getTileFlags(x,y,z).outside then inside = false end
		end
	end
	return inside
end

function BUILDING:isOutside()
	local z = self._building.z
	local outside = true
	for x = self._building.x1, self._building.x2 do
		for y = self._building.y1, self._building.y2 do
			if not dfhack.maps.getTileFlags(x,y,z).outside then outside = false end
		end
	end
	return outside
end

--===============================================================================================--
--== GUI BUILDING FUNCTIONS =====================================================================--
--===============================================================================================--
local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function getTypeList(filter)
	filter = filter or "ALL"
	local list = {}
	for k, _ in pairs(hardcoded_bldgs) do
		if filter == "ALL" then
			list[#list+1] = k
		end
	end
	return list
end

function getBuildingList(buildingType)
	local list = {}
	for k, _ in pairs(hardcoded_bldgs[buildingType]) do
		list[#list+1] = k
	end
	return list
end

function getBuildingInfo(building)
	local info  = {}
	local n = 0
	local bldgRaw = df.building_def.find(building)

	-- Vanilla building entries
	info.Name = {}
	info.Name._string = bldgRaw.name
	info.Name._color = {
		fg = bldgRaw.name_color[0],
		bg = bldgRaw.name_color[1],
		bold = bldgRaw.name_color[2]}


	info.Dimensions = tostring(bldgRaw.dim_x).." by "..tostring(bldgRaw.dim_y)
	info.Build_Labor = bldgRaw.labor_description
	
	info.BuildItems = {}
	for i,item in pairs(bldgRaw.build_items) do
		info.BuildItems[i] = {}
		info.BuildItems[i]._listHead = "Quantity"
		info.BuildItems[i]._title = tostring(item.quantity)
		if item.mat_type == -1 then
			info.BuildItems[i].Material = "Any"
		else
			info.BuildItems[i].Material = dfhack.matinfo.decode(item.mat_type,item.mat_index):toString()
			info.BuildItems[i].Material = info.BuildItems[i].Material:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
		end
		if item.item_type >= 0 and item.item_subtype >= 0 then
			info.BuildItems[i].Item = dfhack.items.getSubtypeDef(item.item_type,item.item_subtype).name
		else
			info.BuildItems[i].Item = df.item_type[item.item_type]
		end
		info.BuildItems[i].Item  = info.BuildItems[i].Item:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
		info.BuildItems[i]._second = {}
		info.BuildItems[i]._second[1] = {}
		info.BuildItems[i]._second[1]._listHead = "Flags"
		n = 0
		for flag,bool in pairs(item.flags1) do
			if bool then
				n = n + 1
				info.BuildItems[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
			end
		end
		for flag,bool in pairs(item.flags2) do
			if bool then
				n = n + 1
				info.BuildItems[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
			end
		end
		for flag,bool in pairs(item.flags3) do
			if bool then
				n = n + 1
				info.BuildItems[i]._second[1][n] = flag:gsub("%_"," "):gsub("(%a)([%w_']*)", tchelper)
			end
		end
	end

 
	info.Reactions = {}
	info.Reactions._header = "Reactions"
	info.Reactions._second = {}
	n = 0
	for _,reaction in pairs(df.global.world.raws.reactions.reactions) do
		for i,id in pairs(reaction.building.custom) do
			if id ~= -1 then
				ctype = id
				mtype = reaction.building.type[i]
				stype = reaction.building.subtype[i]
				if ctype == bldgRaw.id and 
				   mtype == bldgRaw.building_type and 
				   stype == bldgRaw.building_subtype then
					n = n + 1
					info.Reactions._second[n] = reaction.name
					break
				end
			end
		end
	end
end