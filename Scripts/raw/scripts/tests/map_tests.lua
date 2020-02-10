script = require "gui.script"
local map = reqscript("functions/map").MAP(false)

local function posString(a)
	return tostring(a.x) .. " " .. tostring(a.y) .. " " .. tostring(a.z)
end

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
	
	local spawn_flow = function ()
		local Check = {}
		local location = map:getPosition("SURFACE",true)
		if not location.x then return nil end
		local loc_str = posString(location)
		cmd = "map/spawn-flow -pos [ "..loc_str.." ] -type MaterialDust -inorganic OBSIDIAN -static -density 100"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		local flow = map:getFlow(location)
		if not flow then 
			Check[#Check+1] = "Failed to create flow"
		else
			if not flow.Type == "MATERIALDUST" then Check[#Check+1] = "Incorrect flow type - "..flow.Type end
			if not flow:getDensity() == 100 then Check[#Check+1] = "Incorrect flow density - "..tostring(flow:getDensity()) end
			if not flow.Inorganic == "OBSIDIAN" then Check[#Check+1] = "Incorrect flow inorganic - "..flow.Inorganic end
			if not flow.Static then Check[#Check+1] = "Flow is not static" end
		end
		
		return Check
	end
	
	local spawn_liquid = function ()
		local Check = {}
		local location = map:getPosition("SURFACE",true)
		if not location.x then return nil end
		local loc_str = posString(location)
		cmd = "map/spawn-liquid -pos [ "..loc_str.." ] -depth 1 -shape SQUARE -radius [ 1 1 ]"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		for i = -1, 1 do
			for j = -1, 1 do
				local pos = location
				pos.x = pos.x + i
				pos.y = pos.y + j
				local ps = posString(pos)
				local n = map:getDepth(pos)
				if not n == 1 then Check[#Check+1] = "Incorrect water depth - "..tostring(n).." - at position - "..ps end
			end
		end
		return Check
	end
	
	return {
		spawn_flow = spawn_flow,
		spawn_liquid = spawn_liquid
	}
end