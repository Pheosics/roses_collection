
script = require "gui.script"
local defbldg = reqscript("functions/building").getBuilding
local map = reqscript("functions/map").getMap()

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
	
	local create = function ()
		local Check = {}
		
	---- Check that the script creates a hardcoded building (Quern)
		location = map:getPosition("SURFACE",true)
		loc_str = tostring(location.x) .. " " .. tostring(location.y) .. " " .. tostring(location.z)
		cmd = "building/create -location [ "..loc_str.." ] -type Workshop -subtype Quern"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not dfhack.buildings.findAtTile(location) then
			Check[#Check+1] = "Failed to create WORKSHOP:QUERN"
		else
			self.quern = dfhack.buildings.findAtTile(location)
		end

	---- Check that the script creates a raw based building (SCREW_PRESS)
		location = map:getPosition("SURFACE",true)
		loc_str = tostring(location.x).." "..tostring(location.y).." "..tostring(location.z)
		cmd = "building/create -location [ "..loc_str.." ] -type Workshop -subtype SCREW_PRESS"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not dfhack.buildings.findAtTile(location) then
			Check[#Check+1] = "Failed to create WORKSHOP:SCREW_PRESS"
		else
			self.screwpress = dfhack.buildings.findAtTile(location)
		end
		
	---- Check that the script creates a multitile building (MASONS)
		location = map:getPosition("SURFACE",true)
		loc_str = tostring(location.x) .. " " .. tostring(location.y) .. " " .. tostring(location.z)
		cmd = "building/create -location [ "..loc_str.." ] -type Workshop -subtype MASONS"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not dfhack.buildings.findAtTile(location) then
			Check[#Check+1] = "Failed to create WORKSHOP:MASONS"
		else
			self.masons = dfhack.buildings.findAtTile(location)
		end

		return Check
	end
	
	local change_subtype = function ()
		local Check = {}
		if not self.quern or not self.masons then return nil end

	---- Check that script changes the quern into a millstone
		local quern = defbldg(self.quern)
		cmd = "building/change-subtype -building "..tostring(quern.id).." -subtype MILLSTONE"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not df.building.find(quern.id):getSubtype() == df.workshop_type.Millstone then 
			Check[#Check+1] = "Quern not changed into millstone"
		end
	
	---- Check that the script succeeds in changing the subtype from MASONS to CARPENTERS for 50 ticks
		local masons = defbldg(self.masons)
		cmd = "building/change-subtype -building "..tostring(masons.id).." -subtype CARPENTERS -dur 50"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if not df.building.find(masons.id):getSubtype() == df.workshop_type.Carpenters then
			Check[#Check+1] = "MASONS did not correctly change to CARPENTERS"
		end
		---- Pause script for 75 ticks
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		if not df.building.find(masons.id):getSubtype() == df.workshop_type.Masons then
			Check[#Check+1] = "CARPENTERS did not revert back to MASONS"
		end	

		return Check
	end
	
	return {
		create = create,
		change_subtype = change_subtype,
		order = {"create", "change_subtype"}
	}
end