script = require "gui.script"

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
	for i,bldg in pairs(df.global.world.raws.buildings.all) do
		if bldg.code == "TEST_BUILDING_1" then ctype1 = i end
		if bldg.code == "TEST_BUILDING_2" then ctype2 = i end
	end
	local self = {buildingFunctions = dfhack.script_environment("functions/building"),
				  map = dfhack.script_environment("functions/map").MAP(),
				  ctype1 = ctype1, ctype2 = ctype2}
	
	local create = function ()
		local Check = {}
		if not self.ctype1 or not self.ctype2 then return nil end
		
	---- Check that the script creates a quern (only vanilla building it can make)
		location = self.map:getPosition("SURFACE",true)
		loc_str = tostring(location.x) .. " " .. tostring(location.y) .. " " .. tostring(location.z)
		writeall("building/create -location [ "..loc_str.." ] -type Workshop -subtype 17 -test")
		output = dfhack.run_command_silent("building/create -location [ "..loc_str.." ] -type Workshop -subtype 17 -test")
		writeall(output)
		if not dfhack.buildings.findAtTile(location) then
			Check[#Check+1] = "Failed to create Quern"
		else
			self.buildingVanilla = dfhack.buildings.findAtTile(location)
		end

	---- Check that the script creates TEST_BUILDING_1
		location = self.map:getPosition("SURFACE",true)
		loc_str = tostring(location.x).." "..tostring(location.y).." "..tostring(location.z)
		writeall("building/create -location [ "..loc_str.." ] -type Workshop -subtype TEST_BUILDING_1 ")
		output = dfhack.run_command_silent("building/create -location [ "..loc_str.." ] -type Workshop -subtype TEST_BUILDING_1")
		writeall(output)
		if not dfhack.buildings.findAtTile(location) then
			Check[#Check+1] = "Failed to create TEST_BUILDING_1"
		else
			self.buildingCustom = dfhack.buildings.findAtTile(location)
		end
		
		return Check
	end
	
	local subtype_change = function ()
		local Check = {}
		if not self.buildingVanilla or not self.buildingCustom then return nil end

	---- Check that script fails to change vanilla building
		writeall("building/subtype-change -building "..tostring(self.buildingVanilla.id).." -subtype TEST_BUILDING_2")
		output = dfhack.run_command_silent("building/subtype-change -building "..tostring(self.buildingVanilla.id).." -subtype TEST_BUILDING_2")
		writeall(output)
		if self.buildingVanilla.custom_type > 0 then 
			Check[#Check+1] = "Vanilla building incorrectly changed to a custom building"
		end
	
	---- Check that the script succeeds in changing the subtype from TEST_BUILDING_1 to TEST_BUILDING_2 for 50 ticks
		writeall("building/subtype-change -building "..tostring(self.buildingCustom.id).." -subtype TEST_BUILDING_2 -dur 50)")
		output = dfhack.run_command_silent("building/subtype-change -building "..tostring(self.buildingCustom.id).." -subtype TEST_BUILDING_2 -dur 50")
		writeall(output)
		if self.buildingCustom.custom_type ~= self.ctype2 then
			Check[#Check+1] = "Test Building 1 did not correctly change to Test Building 2"
		end
		---- Pause script for 75 ticks
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		if self.buildingCustom.custom_type ~= self.ctype1 then
			Check[#Check+1] = "Test Building 2 did not revert back to Test Building 1"
		end	

		return Check
	end
	
	return {
		create = create,
		subtype_change = subtype_change
	}
end