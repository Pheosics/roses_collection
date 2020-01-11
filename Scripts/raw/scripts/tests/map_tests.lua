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
	local self = {map = dfhack.script_environment("functions/map").MAP()}
	
	local spawn_flow = function ()
		local Check = {}
		return nil
	end
	
	local spawn_liquid = function ()
		local Check = {}
		return nil
	end
	
	return {
		spawn_flow = spawn_flow,
		spawn_liquid = spawn_liquid
	}
end