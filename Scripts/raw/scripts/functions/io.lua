local utils = require "utils"
split = utils.split_string

function readPlan(fileName)
	local iofile = io.open(plan,"r")
	local data = iofile:read("*all")
	iofile:close()
	local splitData = split(data,',')
	local x = {}
	local y = {}
	local t = {}
	local xi = 0
	local yi = 1
	local xT = -1
	local yT = -1
	local xS = -1
	local yS = -1
	for i,v in ipairs(splitData) do
		if split(v,'\n')[1] ~= v then
			xi = 1
			yi = yi + 1
		else
			xi = xi + 1
		end
		if v == 'T' or v == '\nT' then
			xT = xi
			yT = yi
		end
		if v == 'S' or v == '\nS' then
			xS = xi
			yS = yi
		end
		if v == 'T' or v == '\nT' or v == '1' or v == '\n1' or v == 'C' or v == '\nC' then
			t[i] = true
		else
			t[i] = false
		end
		x[i] = xi
		y[i] = yi
	end
	return x, y, t, xT, yT, xS, yS
end

function readRaws(rawType,test,verbose)
	if rawType == "Building" then
		tokenCheck = "[BUILDING"
		filename = "building"
	elseif rawType == "Creature" then
		tokenCheck = "[CREATURE"
		filename = "creature"
	elseif rawType == "Item" then
		tokenCheck = "[ITEM"
		filename = "item"
	elseif rawType == "Material" then
		tokenCheck = "[MATERIAL_TEMPLATE"
		filename = "material_template"
	elseif rawType == "Inorganic" then
		tokenCheck = "[INORGANIC"
		filename = "inorganic"
	elseif rawType == "PlantMat" then
		tokenCheck = "[PLANT"
		filename = "plant"
	elseif rawType == "AnimalMat" then
		tokenCheck = "[CREATURE"
		filename = "creature"
	elseif rawType == "Reaction" then
		tokenCheck = "[REACTION"
		filename = "reaction"
	else
		return
	end
	if verbose then print("Searching for a "..rawType.." file") end
	local files = {}
	local dir = dfhack.getDFPath()
	local locations = {"/raw/objects/"}
	local n = 1
	if test then
		filename = filename.."_test"
		locations = {"/raw/scripts/tests/raw_files"}
	end
	for _,location in ipairs(locations) do
		local path = dir..location
		if verbose then print("Looking in "..location) end
		if dfhack.internal.getDir(path) then
			for _,fname in pairs(dfhack.internal.getDir(path)) do
				if (split(fname,"_")[1] == filename or fname == filename..".txt") and string.match(fname,"txt") then
					files[n] = path..fname
					n = n + 1
				end
			end
		end
	end
	
	if #files >= 1 and verbose then
		print(rawType.." files found:")
		printall(files)
	elseif verbose then
		print("No "..rawType.." files found")
		return false
	end
	
	local data = {}
	local dataInfo = {}
	for _,file in ipairs(files) do
		data[file] = {}
		local iofile = io.open(file,"r")
		local lineCount = 1
		while true do
			local line = iofile:read("*line")
			if line == nil then break end
			data[file][lineCount] = line
			lineCount = lineCount + 1
		end
		iofile:close()
	
		dataInfo[file] = {}
		count = 1
		endline = 1
		for i,line in ipairs(data[file]) do
			endline = i
			sline = line:gsub("%s+","")
			if rawType == "Building" or rawType == "Item" then -- Buildings and items are different
				ls = split(split(sline,":")[1],"_")[1]
			else
				ls = split(sline,":")[1]
			end
			if ls == tokenCheck then
				dataInfo[file][count] = {split(split(sline,":")[2],"]")[1],i+1,0}
				if count > 1 then
					dataInfo[file][count-1][3] = i-1
				end
				count = count + 1
			end
		end
		dataInfo[file][count-1][3] = endline
	end
	
	return data, dataInfo, files
end

function parseScript(a)
	a = table.concat({select(2,table.unpack(split(a,":")))},":")
	n = string.find(string.reverse(a),":")
	script = string.sub(a,1,-(n+1))
	frequency = string.sub(a,-(n-1),-2)
	return script, frequency
end

function decode_creatureToken(creatureToken)
	local spl = split(creatureToken,":")
	if #spl ~= 2 then
		error "creature expected in the form RACE:CASTE (e.g. DWARF:MALE)"
	end
	local race = spl[1]:upper()
	local caste = spl[2]:upper()
	local creatures = {}
	for i,x in ipairs(df.global.world.raws.creatures.all) do
		if race == x.creature_id or race == "ALL" then
			creatures[i] = {}
			if race ~= "ALL" then break end
		end
	end
	for i,_ in pairs(creatures) do
		for j,y in ipairs(df.global.world.raws.creatures.all[i].caste) do
			if caste == y.caste_id or caste == "ALL" then
				creatures[i][j] = true
				if caste ~= "ALL" then break end
			end
		end
	end
	return creatures
end

function decode_inorganicToken(inorganicToken)
	local inorganicToken = inorganicToken:upper()
	local inorganics = {}
	if inorganicToken == "ALL_METALS" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_METAL"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_GEMS" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_GEM"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_STONE" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_STONE"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_GLASS" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["IS_GLASS"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_SAND" then
		for i,x in pairs(df.global.world.raws.inorganics) do
			if x.material.flags["SOIL_SAND"] then inorganics[i] = true end
		end
	elseif inorganicToken == "ALL_CLAY" then
		-- Does clay have a material flag??? -ME
		--for i,x in pairs(df.global.world.raws.inorganics) do
		--	if x.material.flags["???"] then inorganics[i] = true
		--end
	else
		matinfo = dfhack.matinfo.find(inorganicToken)
		inorganics[matinfo.index] = true
	end
	return inorganics
end

function decode_itemToken(itemToken)
	local spl = split(itemToken,":")
	if #spl ~= 2 then
		error "itemToken expected in the form ITEM_TYPE:ITEM_SUBTYPE (e.g. ITEM_WEAPON:ITEM_WEAPON_SWORD_SHOT)"
	end
	local itemType = spl[1]:upper()
	local itemSubType = spl[2]:upper()
	local items = {}
	if itemType == "ITEM_AMMO" then
		ind = df.item_type["AMMO"]
	elseif itemType == "ITEM_ARMOR" then
		ind = df.item_type["ARMOR"]
	elseif itemType == "ITEM_GLOVES" then
		ind = df.item_type["GLOVES"]
	elseif itemType == "ITEM_HELM" then
		ind = df.item_type["HELM"]
	elseif itemType == "ITEM_INSTRUMENT" then
		ind = df.item_type["INSTRUMENT"]
	elseif itemType == "ITEM_PANTS" then
		ind = df.item_type["PANTS"]
	elseif itemType == "ITEM_SHIELD" then
		ind = df.item_type["SHIELD"]
	elseif itemType == "ITEM_SIEGEAMMO" then
		ind = df.item_type["SIEGEAMMO"]
	elseif itemType == "ITEM_SHOES" then
		ind = df.item_type["SHOES"]
	elseif itemType == "ITEM_TOOL" then
		ind = df.item_type["TOOL"]
	elseif itemType == "ITEM_TOY" then
		ind = df.item_type["TOY"]
	elseif itemType == "ITEM_TRAPCOMP" then
		ind = df.item_type["TRAPCOMP"]
	elseif itemType == "ITEM_WEAPON" then
		ind = df.item_type["WEAPON"]
	end
	if itemSubType == "ALL" then
		for i=0,dfhack.items.getSubtypeCount(ind)-1 do
			items[dfhack.items.getSubtypeDef(ind,i).subtype] = true
		end
	else
		for i=0,dfhack.items.getSubtypeCount(ind)-1 do
			if dfhack.items.getSubtypeDef(ind,i).id == itemSubType then
				items[dfhack.items.getSubtypeDef(ind,i).subtype] = true
				break
			end
		end
	end
	return items
end

function decode_materialToken(materialToken)
	local spl = split(materialToken,":")
	if #spl == 1 then
		temp = {}
		temp[0] = decode_inorganicToken(materialToken)
		return temp
	else
		return decode_organicToken(materialToken)
	end
end

function decode_organicToken(organicToken)
	local organics = {}
	if dfhack.matinfo.find(organicToken) then
		local mat = dfhack.matinfo.find(organicToken)
		organics[mat.type] = {}
		organics[mat.type][mat.index] = true
		return organics
	end
	local spl = split(organicToken,":")
	if #spl ~= 3 then
		error("organicToken expected in the form ORGANIC_TYPE:ORGANIC_SUBTYPE:ORGANIC_MATERIAL (e.g. CREATURE:DWARF:MEAT) - " .. organicToken)
	end
	local organicType = spl[1]:upper()
	local organicSubType = spl[2]:upper()
	local organicMaterial = spl[3]:upper()
	if organicType == "CREATURE" then
		organicTable = df.global.world.raws.creatures.all
		for i,organic in pairs(organicTable) do
			if organic.creature_id == organicSubType or organicSubType == "ALL" then
				organics[i] = {}
			end
		end
	elseif organicType == "PLANT" then
		organicTable = df.global.world.raws.plants.all
		for i,organic in pairs(organicTable) do
			if organic.id == organicSubType or organicSubType == "ALL" then
				organics[i] = {}
				if organicSubType ~= "ALL" then break end
			end
		end
	else
		error "Unrecognized ORGANIC_TYPE (CREATURE or PLANT)"
	end
	for i,_ in pairs(organics) do
		for j,material in pairs(organicTable[i].material) do
			if material.id == organicMaterial or organicMaterial == "ALL" then
				organics[i][j] = true
				if organicMaterial ~= "ALL" then break end
			end
		end
	end
	return organics
end