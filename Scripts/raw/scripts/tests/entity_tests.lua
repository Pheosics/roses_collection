
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
	for _,unit in pairs(df.global.world.units.active) do
		if dfhack.units.isCitizen(unit) then
			civ = dfhack.script_environment("functions/entity").ENTITY(unit.civ_id)
			break
		end
	end
	local self = {civEntity = civ,
				entityFunctions = dfhack.script_environment("functions/entity")}
	
	local resource_change = function ()
		local entity = self.civEntity
		local Check = {}
	
	---- 
		writeall("entity/resource-change -entity "..tostring(entity.id).." -remove -type CREATURE:PET -obj DRAGON:FEMALE")
		output = dfhack.run_command_silent("entity/resource-change -entity "..tostring(entity.id).." -remove -type CREATURE:PET -obj DRAGON:FEMALE")
		writeall(output)
		if entity:hasResource("CREATURE:PET","DRAGON:FEMALE") then
			Check[#Check+1] = "Failed to remove female dragons as a pet"
		end
		
	---- 
		writeall("entity/resource-change -entity "..tostring(entity.id).." -add -type INORGANIC:METAL -obj ADAMANTINE")
		output = dfhack.run_command_silent("entity/resource-change -entity "..tostring(entity.id).." -add -type INORGANIC:METAL -obj ADAMANTINE")
		writeall(output)
		if not entity:hasResource("INORGANIC:METAL","ADAMANTINE") then
			Check[#Check+1] = "Failed to add adamantine as a metal"
		end		

	---- 
		writeall("entity/resource-change -entity "..tostring(entity.id).." -remove -type ITEM:WEAPON -obj ITEM_WEAPON:ITEM_WEAPON_SWORD_SHORT")
		output = dfhack.run_command_silent("entity/resource-change -entity "..tostring(entity.id).." -remove -type ITEM:WEAPON -obj ITEM_WEAPON:ITEM_WEAPON_SWORD_SHORT")
		writeall(output)
		if entity:hasResource("ITEM:WEAPON","ITEM_WEAPON:ITEM_WEAPON_SWORD_SHORT") then
			Check[#Check+1] = "Failed to remove short sword as a weapon"
		end		
		
	---- 
		writeall("entity/resource-change -entity "..tostring(entity.id).." -add -type ORGANIC:MEAT -obj DRAGON:MUSCLE")
		output = dfhack.run_command_silent("entity/resource-change -entity "..tostring(entity.id).." -add -type ORGANIC:MEAT -obj DRAGON:MUSCLE")
		writeall(output)
		if not entity:hasResource("ORGANIC:MEAT","DRAGON:MUSCLE") then
			Check[#Check+1] = "Failed to add dragon meat"
		end		
		
	---- 
		writeall("entity/resource-change -entity "..tostring(entity.id).." -add -type PRODUCT:ARMOR -obj ADAMANTINE")
		output = dfhack.run_command_silent("entity/resource-change -entity "..tostring(entity.id).." -add -type PRODUCT:ARMOR -obj ADAMANTINE")
		writeall(output)
		if not entity:hasResource("PRODUCT:ARMOR","ADAMANTINE") then
			Check[#Check+1] = "Failed to add adamantine as an armor material"
		end		
				
		return Check
	end
	
	return {
		resource_change = resource_change,
	}
end