--@ module=true
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

function loadCommandDelays()
	local n = 0
	local delayTable = persistTable.GlobalTable.persistCommandDelay
	for _,i in pairs(delayTable._children) do
		local delay = delayTable[i]
		local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
		if i == "nextID" or not delay then
			-- Skip
		elseif currentTick >= tonumber(delay.Tick) then
			delayTable[i] = nil
		else
			n = n + 1
			local ticks = delay.Tick-currentTick
			dfhack.timeout(ticks, "ticks", function () dfhack.run_command(delay.Script) end)
		end
	end
	return n
end

function functionDelay(ticks,env,func,args,delayID)
	-- Set up the persist-table callback	
	local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
	local runTick = currentTick + ticks
	local persistDelay = persistTable.GlobalTable.persistFunctionDelay
	local currentNumber = persistDelay["nextID"] or "0"
	if delayID then 
		currentNumber = delayID
	else
		args[#args+1] = currentNumber
	end
	
	-- Set up the dfhack.timeout first
	id = dfhack.timeout(ticks,"ticks",function () dfhack.script_environment(env)[func](table.unpack(args)) end)

	-- Fill in the persist-table
	persistDelay[currentNumber] = {}
	persistDelay[currentNumber].ID = tostring(id)
	persistDelay[currentNumber].Tick = tostring(runTick)
	persistDelay[currentNumber].Environment = env
	persistDelay[currentNumber].Function = func
	persistDelay[currentNumber].Arguments = {}
	for i,x in ipairs(args) do
		persistDelay[currentNumber].Arguments[tostring(i)] = tostring(x)
	end

	-- Update the nextID 
	if not delayID then persistDelay["nextID"] = tostring(math.floor(tonumber(currentNumber) + 1)) end
	
	return id	
end

function loadFunctionDelays()
	local n = 0
	local delayTable = persistTable.GlobalTable.persistFunctionDelay
	for _,i in pairs(delayTable._children) do
		local delay = delayTable[i]
		local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
		if i == "nextID" or not delay then
			-- Skip
		elseif currentTick >= tonumber(delay.Tick) then
			delayTable[i] = nil
		else
			n = n + 1
			local ticks = delay.Tick-currentTick
			local env = delay.Environment
			local func = delay.Function
			local args = {}
			for j = 1, #delay.Arguments._children do
				args[j] = delay.Arguments[tostring(j)]
			end
			dfhack.timeout(ticks, "ticks", function () dfhack.script_environment(env)[func](table.unpack(args)) end)
		end
	end
	return n
end

function classDelay(ticks,class,args)
	-- Set up the persist-table callback	
	local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
	local runTick = currentTick + ticks
	local persistDelay = persistTable.GlobalTable.persistClassDelay
	local currentNumber = persistDelay["nextID"] or "0"

	local id = -1
	if class == "unit" then
		id = dfhack.timeout(ticks, "ticks", function ()
			local unit = reqscript("functions/unit").getUnit(args[1])
			local temp = unit[args[2]][args[3]] + args[4]
		end)
	end
	if id == -1 then return end
	
	-- Fill in the persist-table
	persistDelay[currentNumber] = {}
	persistDelay[currentNumber].ID = tostring(id)
	persistDelay[currentNumber].Tick = tostring(runTick)
	persistDelay[currentNumber].Class = class
	persistDelay[currentNumber].Arguments = {}
	for i,x in ipairs(args) do
		persistDelay[currentNumber].Arguments[tostring(i)] = tostring(x)
	end
	
	-- Update the nextID 
	persistDelay["nextID"] = tostring(math.floor(tonumber(currentNumber) + 1))
end

function loadClassDelays()
	local n = 0
	local delayTable = persistTable.GlobalTable.persistClassDelay
	for _,i in pairs(delayTable._children) do
		local delay = delayTable[i]
		local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
		if i == "nextID" or not delay then
			-- Skip
		elseif currentTick >= tonumber(delay.Tick) then
			delayTable[i] = nil
		else
			n = n + 1
			local ticks = delay.Tick-currentTick
			local class = delay.Class
			local args = {}
			for j = 1, #delay.Arguments._children do
				args[j] = delay.Arguments[tostring(j)]
			end
			if class == "unit" then
				dfhack.timeout(ticks, "ticks", function () 
					local unit = reqscript("functions/unit").getUnit(args[1])
					local temp = unit[args[2]][args[3]] + args[4]
				end)
			end
		end
	end
	return n
end