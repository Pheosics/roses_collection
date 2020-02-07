script = require "gui.script"
local defentity = reqscript("functions/entity").ENTITY

function writeall(tbl)
 if not tbl then return end
 if type(tbl) == "table" then
  for _,text in pairs(tbl) do
   io.write(text.."\n")
  end
 elseif type(tbl) == "userdata" then
  io.write("userdata\n")
 else
  io.write(tbl.."\n")
 end
end

function tests()
	local self = {}
	
	local change_resource = function ()
		local entity = defentity(df.global.ui.civ_id)
		local Check = {}
	
	---- Check changing creature resources
		cmd = "entity/change-resource -entity "..tostring(entity.id).." -remove -type CREATURE:PET -obj DRAGON:FEMALE"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if entity:hasResource("CREATURE:PET","DRAGON:FEMALE") then
			Check[#Check+1] = "Failed to remove female dragons as a pet"
		end
		
	---- Check changing inorganic resources
		cmd = "entity/change-resource -entity "..tostring(entity.id).." -add -type INORGANIC:METAL -obj ADAMANTINE"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not entity:hasResource("INORGANIC:METAL","ADAMANTINE") then
			Check[#Check+1] = "Failed to add adamantine as a metal"
		end		

	---- Check changing item resources
		cmd = "entity/change-resource -entity "..tostring(entity.id).." -remove -type ITEM:WEAPON -obj ITEM_WEAPON:ITEM_WEAPON_SWORD_SHORT"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if entity:hasResource("ITEM:WEAPON","ITEM_WEAPON:ITEM_WEAPON_SWORD_SHORT") then
			Check[#Check+1] = "Failed to remove short sword as a weapon"
		end		
		
	---- Check changing organic resources
		cmd = "entity/change-resource -entity "..tostring(entity.id).." -add -type ORGANIC:MEAT -obj DRAGON:MUSCLE"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not entity:hasResource("ORGANIC:MEAT","DRAGON:MUSCLE") then
			Check[#Check+1] = "Failed to add dragon meat"
		end		
		
	---- Check changing product resources
		cmd = "entity/change-resource -entity "..tostring(entity.id).." -add -type PRODUCT:ARMOR -obj ADAMANTINE"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not entity:hasResource("PRODUCT:ARMOR","ADAMANTINE") then
			Check[#Check+1] = "Failed to add adamantine as an armor material"
		end		
				
		return Check
	end
	
	return {
		change_resource = change_resource,
	}
end