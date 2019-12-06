local utils = require "utils"
split = utils.split_string

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