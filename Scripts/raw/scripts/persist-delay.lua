local persistTable = require 'persist-table'

-- Set up delays for scripts run on the command line or through modtools scripts
function commandDelay(ticks,script)
	-- Set up the dfhack.timeout first
	id = dfhack.timeout(ticks,"ticks",function () dfhack.run_command(script) end)
	
	-- Set up the persist-table callback
	local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
	local runTick = currentTick + ticks
	local persistDelay = persistTable.GlobalTable.persistCommandDelay
	local currentNumber = persistDelay["nextID"] or "0"
	persistDelay[currentNumber] = {}
	persistDelay[currentNumber].ID = tostring(id)
	persistDelay[currentNumber].Tick = tostring(runTick)
	persistDelay[currentNumber].Command = script
	
	-- Update the nextID 
	persistDelay["nextID"] = tostring(math.floor(tonumber(currentNumber) + 1))
	
	return id
end

function functionDelay(ticks,env,func,args)
	-- Set up the dfhack.timeout first
	id = dfhack.timeout(ticks,"ticks",function () dfhack.script_environment(env)[func](table.unpack(arguments)) end)

	-- Set up the persist-table callback	
	local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
	local runTick = currentTick + ticks
	local persistDelay = persistTable.GlobalTable.persistFunctionDelay
	local currentNumber = persistDelay["nextID"] or "0"
	persistDelay[currentNumber] = {}
	persistDelay[currentNumber].ID = tostring(id)
	persistDelay[currentNumber].Tick = tostring(runTick)
	persistDelay[currentNumber].Environment = env
	persistDelay[currentNumber].Function = func
	persistDelay[currentNumber].Arguments = {}
	for i,x in ipairs(arguments) do
		persistDelay[currentNumber].Arguments[tostring(i)] = tostring(x)
	end

	-- Update the nextID 
	persistDelay["nextID"] = tostring(math.floor(tonumber(currentNumber) + 1))
	
	return id	
end