local utils = require "utils"
local eventful = require "plugins.eventful"
local split = utils.split_string
usages = {}

Tokens = {
	BLAH = {Type="Named",  Name="Blah", Names={Increment: 2, },
	
function makeSystemTable(systemTokens)
	local numEnhanced = 0
	local Table = {}
	dataFiles,dataInfoFiles,files = dfhack.script_environment("functions/io").readRaws("Building")
	if not dataFiles then return numEnhanced end

	for _,file in ipairs(files) do
		dataInfo = dataInfoFiles[file]
		data = dataFiles[file]
		for i,x in ipairs(dataInfo) do
			token      = x[1]
			startLine  = x[2]
			endLine    = x[3]
			Table[token] = {}
			ptable = Table[token]
			ptable.Scripts = {}
			scripts = 0
			enhanced = false
			for j = startLine,endLine,1 do
				test = data[j]:gsub("%s+","")
				test = split(test,":")[1]
				array = split(data[j],":")
				for k = 1, #array, 1 do
					array[k] = split(array[k],"}")[1]
					array[k] = tonumber(array[k]) or array[k]
				end
				if test == "[NAME" then -- Take raw name
					ptable.Name = split(array[2],"]")[1]
				elseif string.sub(test,1,1) == "[" then
					-- This is here so we skip unnecessary raw tokens
				elseif string.sub(test,1,1) == "{" then
					array[1] = split(test,"{")[2]
					if systemTokens[array[1]] then
						local enhanced = true
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
							script, frequency = dfhack.script_environment("functions/io").parseScript(data[j])
							temp.Script = script
							temp.Frequency = tonumber(frequency)
						end
						
						-- Place in table according to type
						if Type == "Main" then
							if tempKey then
								ptable[name] = ptable[name] or {}
								ptable[name][tempKey] = temp
							else
								ptable[name] = temp
							end
						elseif Type == "Sub" then
							if Subtype == "Set" then
								ptable[name] = ptable[name] or {}
								subtable = ptable[name]
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
			if scripts == 0 then ptable.Scripts = nil end
			if not enhanced then Table[token] = nil else numEnhanced = numEnhanced + 1 end
		end
	end

	return numEnhanced, Table
end