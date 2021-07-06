--@ module = true
local utils = require "utils"
local split = utils.split_string
local myIO = reqscript("functions/io")

function checkSystemTable(Name, ObjFuncFile, id)
	-- Make sure the object exists and has a systam table entry
	local systemTable = dfhack.script_environment("core/tables").Tables[Name]
	local defobject = reqscript("functions/"..ObjFuncFile:lower())["get"..ObjFuncFile]
	local object = defobject(id)
	if not object then return nil end
	
	local objectToken = object.Token
	if not systemTable[objectToken] then return nil end
	
	return object, systemTable[objectToken]
end

function makeSystemTable(system,test,verbose)
	local systemTokens = system.Tokens or {}
	local rawTokens = system.RawTokens or {}
	local fileType = system.RawFileType
	local numEnhanced = 0
	local Table = {}
	dataFiles,dataInfoFiles,files = myIO.readRaws(fileType,test,verbose)
	if not dataFiles then return numEnhanced end
	
	for _,file in ipairs(files) do
		dataInfo = dataInfoFiles[file]
		data = dataFiles[file]
		for i,x in ipairs(dataInfo) do
			local token      = x[1]
			local startLine  = x[2]
			local endLine    = x[3]
            local subtable   = {}
			local scripts    = 0
			local enhanced   = false
			local prevToken  = ""
			local prevName   = ""
			local prevKey    = ""
			if Table[token] then
				enhanced = true
			else
				Table[token] = {}
			end
			Table[token].Scripts = Table[token].Scripts or {}
			for j = startLine,endLine,1 do
				local process = false
				local Entry = {}
				local test = data[j]:gsub("%s+","")
				test = split(test,":")[1]
				local array = split(data[j],":")
				for k = 1, #array, 1 do
					array[k] = split(array[k],"}")[1]
					array[k] = tonumber(array[k]) or array[k]
				end
				if string.sub(test,1,1) == "[" then
					array[1] = split(split(test,"%[")[2],"]")[1]
					if rawTokens[array[1]] then
						process = true
						Entry = rawTokens[array[1]]
						for k = 1, #array, 1 do
							array[k] = split(array[k],"]")[1]
							array[k] = tonumber(array[k]) or array[k]
						end
					end
				elseif string.sub(test,1,1) == "{" then
					array[1] = split(split(test,"{")[2],"}")[1]
					if systemTokens[array[1]] then
						enhanced = true
						process = true
						Entry = systemTokens[array[1]]
						for k = 1, #array, 1 do
							array[k] = split(array[k],"}")[1]
							array[k] = tonumber(array[k]) or array[k]
						end
					end
				end
				if process then
					local Type = Entry.Type
					local Subtype = Entry.Subtype
					local name = Entry.Name

					-- Process system token string according to subtype
					local temp
					local tempKey
					if Subtype == "Boolean" then
						temp = true
					elseif Subtype == "String" then
						temp = array[2]
					elseif Subtype == "Number" then
						temp = tonumber(array[2])
					elseif Subtype == "Named" then
						temp = {}
						for key,i in pairs(Entry.Names) do
							temp[key] = tonumber(array[i]) or array[i]
						end
					elseif Subtype == "Table" then
						tempKey = array[2]
						temp = tonumber(array[3]) or array[3]
					elseif Subtype == "NamedTable" then
						tempKey = array[2]
						temp = {}
						for key,i in pairs(Entry.Names) do
							temp[key] = tonumber(array[i]) or array[i]
						end
					elseif Subtype == "List" then
						tempKey = "#LIST"
						temp = tonumber(array[2]) or array[2]
					elseif Subtype == "NamedList" then
						tempKey = "#LIST"
						temp = {}
						for key,i in pairs(Entry.Names) do
							temp[key] = tonumber(array[i]) or array[i]
						end
					elseif Subtype == "ScriptF" then
						temp = {}
						script, frequency = myIO.parseScript(data[j])
						temp.Script = script
						temp.Frequency = tonumber(frequency)
						scripts = scripts + 1
						tempKey = scripts
					elseif Subtype == "ScriptC" then
						temp = {}
						script, chance = myIO.parseScript(data[j])
						temp.Script = script
						temp.Chance = tonumber(chance)
						scripts = scripts + 1
						tempKey = scripts
					end
					
					-- Place in table according to type
					if Type == "Main" then
						if tempKey then
							Table[token][name] = Table[token][name] or {}
							if tempKey == "#LIST" then tempKey = #Table[token][name] + 1 end
							Table[token][name][tempKey] = temp
						else
							Table[token][name] = temp
						end
					elseif Type == "Sub" then
						if Subtype == "Set" then
							Table[token][name] = Table[token][name] or {}
							prevToken = token
							prevName = name
							prevKey = ""
						elseif Subtype == "SetTable" then
							Table[token][name] = Table[token][name] or {}
							Table[token][name][array[2]] = Table[token][name][array[2]] or {}
							prevToken = token
							prevName = name
							prevKey = array[2]
						else
							if prevKey == "" then
								if tempKey then
									Table[prevToken][prevName][name] = Table[prevToken][prevName][name] or {}
									if tempKey == "#LIST" then tempKey = #Table[prevToken][prevName][name] + 1 end
									Table[prevToken][prevName][name][tempKey] = temp
								else
									Table[prevToken][prevName][name] = temp
								end
							else
								if tempKey then
									Table[prevToken][prevName][prevKey][name] = Table[prevToken][prevName][prevKey][name] or {}
									if tempKey == "#LIST" then tempKey = #Table[prevToken][prevName][prevKey][name] + 1 end
									Table[prevToken][prevName][prevKey][name][tempKey] = temp
								else
									Table[prevToken][prevName][prevKey][name] = temp
								end
							end
						end
					else
						if string.match(Type,"-") then
							Type1 = split(Type,"-")[1]
							Type2 = split(Type,"-")[2]
							Table[token][Type1] = Table[token][Type1] or {}
							Table[token][Type2] = Table[token][Type2] or {}
							if tempKey then
								Table[token][Type1][name] = Table[token][Type1][name] or {}
								Table[token][Type2][name] = Table[token][Type2][name] or {}
								tempKey1 = tempKey
								tempKey2 = tempKey
								if tempKey == "#LIST" then tempKey1 = #Table[token][Type1][name] + 1 end
								if tempKey == "#LIST" then tempKey2 = #Table[token][Type2][name] + 1 end
								Table[token][Type1][name][tempKey1] = temp
								Table[token][Type2][name][tempKey2] = -temp
							else
								Table[token][Type1][name] = temp
								Table[token][Type2][name] = -temp
							end
						else
							Table[token][Type] = Table[token][Type] or {}
							if tempKey then
								Table[token][Type][name] = Table[token][Type][name] or {}
								if tempKey == "#LIST" then tempKey = #Table[token][Type][name] + 1 end
								Table[token][Type][name][tempKey] = temp
							else
								Table[token][Type][name] = temp
							end
						end
					end
				end
			end
			if scripts == 0 then Table[token].Scripts = nil end
			if not enhanced then Table[token] = nil else numEnhanced = numEnhanced + 1 end
		end
	end

	return numEnhanced, Table
end