--@ module = true
local utils = require "utils"
local split = utils.split_string
local repeats = require("repeat-util")
local eventful = require "plugins.eventful"
local myIO = reqscript("functions/io")

function startSystemTriggers(system)
	if not reqscript("core/tables").Tables[system.Name] then return end
	
	-- Eventful Triggers
	for k,t in pairs(system.EventfulFunctions) do
		for name,func in pairs(t) do
			eventful[k][name] = function(...) return func(...) end
		end
	end
	for Type,ticks in pairs(system.EventfulTypes) do
		eventful.enableEvent(eventful.eventType[Type],ticks)
	end
	
	-- Custom Triggers
	for Type,v in pairs(system.CustomTypes) do
		repeats.scheduleUnlessAlreadyScheduled(Type,v.ticks,"ticks",v.func)
	end
end

function checkSystemTable(Name, ObjFuncFile, id)
	-- Make sure the object exists and has a systam table entry
	local systemTable = dfhack.script_environment("core/tables").Tables[Name]
	local defobject = reqscript("functions/"..ObjFuncFile:lower())[ObjFuncFile:upper()]
	local object = defobject(id)
	if not object then return nil end
	
	local objectToken = object.Token
	if not systemTable[objectToken] then return nil end
	
	return object, systemTable[objectToken]
end

function makeSystemTable(system,test,verbose)
	local systemTokens = system.Tokens
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
            local subtable = {}
			local scripts = 0
			local enhanced = false
			Table[token] = {}
			Table[token].Scripts = {}
			for j = startLine,endLine,1 do
				local test = data[j]:gsub("%s+","")
				test = split(test,":")[1]
				local array = split(data[j],":")
				for k = 1, #array, 1 do
					array[k] = split(array[k],"}")[1]
					array[k] = tonumber(array[k]) or array[k]
				end
				if test == "[NAME" then -- Take raw name
					Table[token].Name = split(array[2],"]")[1]
				elseif string.sub(test,1,1) == "[" then
					-- This is here so we skip unnecessary raw tokens
				elseif string.sub(test,1,1) == "{" then
					array[1] = split(split(test,"{")[2],"}")[1]
					if systemTokens[array[1]] then
						enhanced = true
						local Type = systemTokens[array[1]].Type
						local Subtype = systemTokens[array[1]].Subtype
						local name = systemTokens[array[1]].Name

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
							for key,i in pairs(systemTokens[array[1]].Names) do
								temp[key] = tonumber(array[i]) or array[i]
							end
						elseif Subtype == "Table" then
							tempKey = array[2]
							temp = tonumber(array[3]) or array[3]
						elseif Subtype == "NamedTable" then
							tempKey = array[2]
							temp = {}
							for key,i in pairs(systemTokens[array[1]].Names) do
								temp[key] = tonumber(array[i]) or array[i]
							end							
						elseif Subtype == "Script" then
							temp = {}
							script, frequency = myIO.parseScript(data[j])
							temp.Script = script
							temp.Frequency = tonumber(frequency)
							scripts = scripts + 1
							tempKey = scripts
						end
						
						-- Place in table according to type
						if Type == "Main" then
							if tempKey then
								Table[token][name] = Table[token][name] or {}
								Table[token][name][tempKey] = temp
							else
								Table[token][name] = temp
							end
						elseif Type == "Sub" then
							if Subtype == "Set" then
								Table[token][name] = Table[token][name] or {}
								subtable = Table[token][name]
							else
								if tempKey then
									subtable[name][tempKey] = temp
								else
									subtable[name] = temp
								end
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