local utils = require "utils"
local split = utils.split_string
local version = 1.0
local dfhackv = 44.12
local dfversn = 44.12
local scripts_dir = "/raw/scripts"
local systems_dir = "/raw/systems"
dfhack.internal.addScriptPath(dfhack.getDFPath()..systems_dir, true)
tables = reqscript("core/tables")
persistFileName = "RosesPersist.dat"

local s1 = ""
local s2 = "  "
local s3 = "    "
local s4 = "      "
local c1 = COLOR_GREEN
local c2 = COLOR_YELLOW
local c3 = COLOR_WHITE

-- DETECTION
local function detectCollection(verbose)
	-- Detect version and scripts/systems
	if verbose then
		dfhack.color(c1)
		print(s1.."Detecting Versions and Loaded Scripts/Systems...")
		
		---- Versions
		dfhack.color(c2)
		print(s2.."Versions:")
		dfhack.color(c3)
		print(s3.."Collection Version - "..tostring(version))
		print(s3.."DFHack Version - "..tostring(dfhackv))
		print(s3.."Dwarf Fortress Version - "..tostring(dfversn))
	end
	
	---- Scripts
	dfhack.color(c2)
	if verbose then print(s2.."Loaded Scripts:") end
	dfhack.color(c3)
	local scripts = {}
	local scriptCategories = {"unit","item","entity","building","map"}
	for _,category in pairs(scriptCategories) do
		if verbose then print(s3..category:upper()) end
		for _,name in pairs(dfhack.internal.getDir(dfhack.getDFPath()..scripts_dir.."/"..category.."/")) do
			if name ~= "." and name ~= ".." then
				scripts[#scripts+1] = category.."/"..split(name,".lua")[1]
				if verbose then print(s4..split(name,".lua")[1]) end
			end
		end
	end

	---- Systems
	dfhack.color(c2)
	if verbose then print(s2.."Loaded Systems:") end
	dfhack.color(c3)
	local systems = {}
	local systemCategories = {"enhanced"}
	for _,category in pairs(systemCategories) do
		if verbose then print(s3..category:upper()) end
		for _,name in pairs(dfhack.internal.getDir(dfhack.getDFPath()..systems_dir.."/"..category.."/")) do
			if name ~= "." and name ~= ".." then
				systems[#systems+1] = category.."/"..split(name,".lua")[1]
				if verbose then print(s4..split(name,".lua")[1]) end
			end
		end
	end
	dfhack.color(COLOR_RESET)
	
	return scripts, systems
end

-- INITIALIZATION
local function initializePersistentTables(verbose)
	-- Initialize persistent tables
	dfhack.color(c1)
	if verbose then print(s1.."Intializing Persistent Tables...") end
	persistTable = require "persist-table"

	---- Persist CommandDelays
	n = 0
	dfhack.color(c2)
	if verbose then print(s2.."CommandDelay Tables:") end
	persistTable.GlobalTable.persistCommandDelay = persistTable.GlobalTable.persistCommandDelay or {}
	delayTable = persistTable.GlobalTable.persistCommandDelay
	for _,i in pairs(delayTable._children) do
		delay = delayTable[i]
		local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
		if tonumber(delay.Tick) and currentTick < tonumber(delay.Tick) then
			n = n + 1
			local ticks = delay.Tick-currentTick
			dfhack.timeout(ticks, "ticks", function () dfhack.run_command(delay.Script) end)
		else
			delay = nil
		end
	end
	dfhack.color(c3)
	if verbose then print(s3.."Command Delays Loaded - "..tostring(n)) end

	---- Persist FunctionDelays
	n = 0
	dfhack.color(c2)
	if verbose then print(s2.."FunctionDelay Tables:") end
	persistTable.GlobalTable.persistFunctionDelay = persistTable.GlobalTable.persistFunctionDelay or {}
	delayTable = persistTable.GlobalTable.persistFunctionDelay
	for _,i in pairs(delayTable._children) do
		delay = delayTable[i]
		local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
		if currentTick >= tonumber(delay.Tick) then
			delay = nil
		else
			n = n + 1
			local ticks = delay.Tick-currentTick
			local environment = delay.Environment
			local functions = delay.Function
			local arguments = delay.Arguments._children
			dfhack.timeout(ticks, "ticks", function () dfhack.script_environment(environment)[functions](table.unpack(arguments)) end)
		end
	end
	dfhack.color(c3)
	if verbose then print(s3.."Function Delays Loaded - "..tostring(n)) end
	
	dfhack.color(COLOR_RESET)
end

local function initializeFileTables(scripts,systems,verbose)
	-- Initialize file tables
	dfhack.color(c1)
	if verbose then print(s1.."Intializing Tables from Files...") end
	
	local fname = nil
	savepath = dfhack.getSavePath()
	dfhack.color(c2)
	if verbose then print(s2.."Searching for "..persistFileName.." in "..savepath) end
	for _,f in pairs(dfhack.internal.getDir(savepath)) do
		if f == persistFileName then
			fname = savepath.."/"..persistFileName
			break
		end
	end
	dfhack.color(c3)
	if fname then
		if verbose then print(s3..fname.." found, loading saved tables") end
		tables.loadFile(fname)
	else
		if verbose then print(s3.."No save file found, initializing tables") end
		tables.initTables(scripts,systems)
	end
	
	dfhack.color(COLOR_RESET)
end

validArgs = utils.invert({
 "help",
 "forceReload",
 "testRun",
 "verbose",
 "clear",
})
local args = utils.processArgs({...}, validArgs)

scripts, systems = detectCollection(args.verbose)
initializePersistentTables(args.verbose)
initializeFileTables(scripts,systems,args.verbose)

local systemCheck = false
print("")
dfhack.color(c1)
print(s1.."Systems Loaded...")
local Table = tables.Tables
for system,n in pairs(Table.Systems) do
	systemCheck = true
	dfhack.color(c2)
	print(s2..system.." - "..tostring(n))
	dfhack.color(c3)
	for _,entry in pairs(Table[system]) do
		print(s3..entry.Name)
	end
end
if not systemCheck then
	dfhack.color(c2)
	print(s2.."None")
end
dfhack.color(COLOR_RESET)