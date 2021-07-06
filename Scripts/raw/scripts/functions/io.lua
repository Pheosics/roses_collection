--@ module=true
local utils = require "utils"
split = utils.split_string

--
function locationString(x,y,z)
	if x and y and z then
		return ""..tostring(x).." "..tostring(y).." "..tostring(z)
	elseif x and x.x then
		return ""..tostring(x.x).." "..tostring(x.y).." "..tostring(x.z)
	elseif x and x[1] then
		return ""..tostring(x[1]).." "..tostring(x[2]).." "..tostring(x[3])
	else
		return ""
	end
end

function gsub_script(script,Table)
	for k,v in pairs(Table) do
		script = script:gsub(k:upper(), tostring(v))
	end
	return script
end

-- Read a PLAN file name for determining positions
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

-- Read raws and parse the information into a single table
function readRaws(rawType,test,verbose)
	local tokenCheck = ""
	local fileName = ""
	local baseSub = nil
	local subTokens = nil
	if rawType == "Building" then
		tokenCheck = "[BUILDING"
		filename = "building"
	elseif rawType == "Creature" then
		tokenCheck = "[CREATURE"
		filename = "creature"
		baseSub = "ALL"
		subTokens = {"[CASTE", "[SELECT_CASTE"}
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
		if verbose then print("No valid rawType found "..rawType) end
		return
	end
	local files = {}
	local location = "/raw/objects/"
	if test then location = "/raw/scripts/tests/raw_files/" end
	if verbose then print("Searching for "..rawType.." files in "..location) end
	local path = dfhack.getDFPath()..location
	if dfhack.internal.getDir(path) then
		for _,fname in pairs(dfhack.internal.getDir(path)) do
			if (split(fname,"_")[1] == filename or fname == filename..".txt") and string.match(fname,"txt") then
				files[#files+1] = path..fname
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
		local count = 1
		local endline = 1
		local token = ""
		local subToken = baseSub or nil
		for i,line in ipairs(data[file]) do
			endline = i
			sline = line:gsub("%s+","")
			if rawType == "Building" or rawType == "Item" then -- Buildings and items are different
				ls = split(split(sline,":")[1],"_")[1]
			else
				ls = split(sline,":")[1]
			end
			if ls == tokenCheck then
				token = split(split(sline,":")[2],"]")[1]
				if subToken then
					dataInfo[file][count] = {token..":"..subToken,i+1,0}
				else
					dataInfo[file][count] = {token,i+1,0}
				end
				if count > 1 then
					dataInfo[file][count-1][3] = i-1
				end
				count = count + 1
			end
			if subTokens then
				for _, v in pairs(subTokens) do
					if ls == v then
						subToken = split(split(sline,":")[2],"]")[1]
						dataInfo[file][count] = {token..":"..subToken,i+1,0}
						if count > 1 then
							dataInfo[file][count-1][3] = i-1
						end
						count = count + 1
					end
				end
			end		
		end
		dataInfo[file][count-1][3] = endline
		
		if subTokens then
			tempTable = {}
			baseTable = {}
			subTables = {}
			nTables = {}
			for _, v in pairs(dataInfo[file]) do
				key = v[1]
				k1 = split(key,":")[1]
				k2 = split(key,":")[2]
				nTables[k1] = nTables[k1] or 0
				nTables[k1] = nTables[k1] + 1
				if k2 == baseSub then
					baseTable[k1] = baseTable[k1] or {}
					baseTable[k1][#baseTable[k1]+1] = {nTables[k1], v[2], v[3]}
				else
					subTables[k1] = subTables[k1] or {}
					subTables[k1][k2] = subTables[k1][k2] or {}
					subTables[k1][k2][nTables[k1]] = {v[2], v[3]}
				end
			end
			for k1, _ in pairs(baseTable) do
				if subTables[k1] then
					for k2, _ in pairs(subTables[k1]) do
						for _, t in pairs(baseTable[k1]) do
							subTables[k1][k2][t[1]] = {t[2], t[3]}
						end
						for _, t in pairs(subTables[k1][k2]) do
							tempTable[#tempTable+1] = {k1..":"..k2, t[1], t[2]}
						end
					end
				end
			end
			
			dataInfo[file] = tempTable
		end
				
	end
	
	return data, dataInfo, files
end

-- Parse a script string used in command line and modtools script calls
function parseScript(a)
	a = table.concat({select(2,table.unpack(split(a,":")))},":")
	n = string.find(string.reverse(a),":")
	script = string.sub(a,1,-(n+1))
	frequency = string.sub(a,-(n-1),-2)
	return script, frequency
end

-- Return a table of race_id and caste_id's that match a given token
function decode_creatureToken(creatureToken)
	local spl = split(creatureToken,":")
	if #spl ~= 2 then error "creature expected in the form RACE:CASTE (e.g. DWARF:MALE)" end
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

function find_creatureToken(unit_id)
	local unit = df.unit.find(unit_id)
	local race = unit.race
	local caste = unit.caste
	local creature_id = df.global.world.raws.creatures.all[race].creature_id
	local caste_id = df.global.world.raws.creatures.all[race].caste[caste].caste_id
	return creature_id..":"..caste_id
end

-- Return a table of inorganic material index's base on a token
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

-- Return a table of item ids based on an item token
function decode_itemToken(itemToken)
	local spl = split(itemToken,":")
	if #spl ~= 2 then error "itemToken expected in the form ITEM_TYPE:ITEM_SUBTYPE (e.g. ITEM_WEAPON:ITEM_WEAPON_SWORD_SHOT)" end
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

-- Shortcut for decode_inorganicToken and decode_organicToken
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

-- Returns a table of material type ids and indexes based on the provided token
function decode_organicToken(organicToken)
	local organics = {}
	if dfhack.matinfo.find(organicToken) then
		local mat = dfhack.matinfo.find(organicToken)
		organics[mat.type] = {}
		organics[mat.type][mat.index] = true
		return organics
	end
	local spl = split(organicToken,":")
	if #spl ~= 3 then error("organicToken expected in the form ORGANIC_TYPE:ORGANIC_SUBTYPE:ORGANIC_MATERIAL (e.g. CREATURE:DWARF:MEAT) - " .. organicToken) end
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