script = require "gui.script"
local defitem = reqscript("functions/item").getItem

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

function mostRecentItem()
	item = df.item.find(df.global.item_next_id - 1)
	return defitem(item)
end
 
function tests()
	local civ = {}
	local non = {}
	for _,unit in pairs(df.global.world.units.active) do
		if dfhack.units.isCitizen(unit) then
			civ[#civ+1] = reqscript("functions/unit").getUnit(unit.id)
		elseif unit.training_level == 7 then
			non[#non+1] = reqscript("functions/unit").getUnit(unit.id)
		end
	end
	local self = {civUnits = civ,
				wildUnits = non}
	
	local create = function ()
		local unit = self.civUnits[1]
		local Check = {}
  
	---- Checks that the script succeeds and creates a steel short sword
		writeall("item/create -creator "..tostring(unit.id).." -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -dur 20")
		output = dfhack.run_command_silent("item/create -creator "..tostring(unit.id).." -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -dur 20")
		writeall(output)
		local item = mostRecentItem()
		if item:getSubtype() ~= "ITEM_WEAPON_SWORD_SHORT" then
			Check[#Check+1] = "Failed to create short sword"
		end
		local id = item.id
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		if df.item.find(id) then
			Check[#Check+1] = "Short sword was not correctly removed"
		end

		return Check
	end
	
	local change_material = function ()
		local unit = self.civUnits[1]
		local Check = {}
		dfhack.run_command_silent("item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -creator "..tostring(unit.id))
		item = mostRecentItem()
		
	---- Check that the script succeeds and changes the steel short sword into a brain short sword
		cmd = "item/change-material -item "..tostring(item.id).." -material CREATURE:DWARF:BRAIN"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if item:getMaterial() ~= "CREATURE:DWARF:BRAIN" then
			Check[#Check+1] = "Failed to change short sword material - CREATURE:DWARF:BRAIN " .. item:getMaterial()
		end
		
	---- Check that the script succeeds and changed the entire units inventory into adamantine for 50 ticks
		cmd = "item/change-material -unit "..tostring(unit.id).." -equipment ALL -material INORGANIC:ADAMANTINE -dur 50"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		items = unit:getInventoryItems("ALL")
		for _,v in pairs(items) do
			if defitem(v):getMaterial() ~= "INORGANIC:ADAMANTINE" then
				Check[#Check+1] = "Failed to change an inventory item material to INORGANIC:ADAMANTINE"
			end
		end
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		for _,v in pairs(items) do
			if defitem(v):getMaterial() == "INORGANIC:ADAMANTINE" then
				Check[#Check+1] = "Failed to reset an inventory item material from INORGANIC:ADAMANTINE"
			end
		end
		
		return Check
	end
	
	local change_quality = function ()
		local unit = self.civUnits[1]
		local Check = {}
		dfhack.run_command_silent("item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -quality 2 -creator "..tostring(unit.id))
		item = mostRecentItem()
		
	---- Check that the script succeeds and changes the quality of the item by 1
		cmd = "item/change-quality -item "..tostring(item.id).." -upgrade"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if item:getQuality() ~= 3 then
			Check[#Check+1] = "Failed to increase item quality by 1 - "..tostring(3) .. " " tostring(item:getQuality())
		end
		
	---- Check that the script succeeds and changes the quality of the entire units inventory to masterwork for 50 ticks
		cmd = "item/change-quality -unit "..tostring(unit.id).." -equipment ALL -quality 5 -dur 50"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		items = unit:getInventoryItems("ALL")
		for _,v in pairs(items) do
			if defitem(v):getQuality() ~= 5 then
				Check[#Check+1] = "Failed to set inventory item quality to 5"
			end
		end
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		for _,v in pairs(items) do
			if defitem(v):getQuality() == 5 then
				Check[#Check+1] = "Failed to reset inventory item quality"
			end
		end
		
		return Check
	end
	
	local change_subtype = function ()
		local unit = self.civUnits[1]
		local Check = {}
		dfhack.run_command_silent("item/create -item WEAPON:ITEM_WEAPON_SWORD_SHORT -material INORGANIC:STEEL -creator "..tostring(unit.id))
		item = mostRecentItem()
		
		---- Check that the script succeeds and changes short sword to long sword and creates a tracking table
		cmd = "item/change-subtype -item "..tostring(item.id).." -subtype ITEM_WEAPON_SWORD_LONG"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if item:getSubtype() ~= "ITEM_WEAPON_SWORD_LONG" then
			Check[#Check+1] = "Failed to change the short sword into a long sword"
		end
		
		---- Check that the script succeeds and changes the pants unit is wearing into greaves for 50 ticks
		cmd = "item/change-subtype -unit "..tostring(unit.id).." -equipment PANTS -subtype ITEM_PANTS_GREAVES -dur 50"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		items = unit:getInventoryItems("TYPE","PANTS")
		for _,v in pairs(items) do
			if defitem(v):getSubtype() ~= "ITEM_PANTS_GREAVES" then
				Check[#Check+1] = "Failed to change pants equipment to ITEM_PANTS_GREAVES"
			end
		end
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		for _,v in pairs(items) do
			if defitem(v):getSubtype() == "ITEM_PANTS_GREAVES" then
				Check[#Check+1] = "Failed to reset pants equipment subtype"
			end
		end
		
		return Check
	end

	local projectile = function ()
		local unitSource = self.civUnits[1]
		local unitTarget = self.wildUnits[1]
		local Check = {}
		
	---- Check that the script succeeds and creates an iron bolt shooting from source to target
		local projid = df.global.proj_next_id
		local itemid = df.global.item_next_id
        cmd = "item/projectile -unitSource "..tostring(unitSource.id).." -unitTarget "..tostring(unitTarget.id).." -item AMMO:ITEM_AMMO_BOLT -material INORGANIC:IRON"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if df.global.proj_next_id ~= projid + 1 and df.global.item_next_id ~= itemid + 1 then
			Check[#Check+1] = "Failed to create 1 shooting projectile"
		end
		
	---- Check that the script succeeds and creates 10 iron bolts falling from 5 z levels above the source
		local projid = df.global.proj_next_id
		local itemid = df.global.item_next_id
        cmd = "item/projectile -unitSource "..tostring(unitSource.id).." -type Falling -item AMMO:ITEM_AMMO_BOLT -material INORGANIC:IRON -height 5 -number 10"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if df.global.proj_next_id ~= projid + 10 and df.global.item_next_id ~= itemid + 10 then
			Check[#Check+1] = "Failed to create 10 falling projectiles"
		end
		
		return Check
	end
	
	return {
		create = create,
		change_material = change_material,
		change_quality = change_quality,
		change_subtype = change_subtype,
		projectile = projectile,
	}
end