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
local c4 = COLOR_RESET

local function print_color(color,str)
	dfhack.color(color)
	print(str)
end


-- DETECTION
local function detectCollection(verbose,test)
	-- Detect version and scripts/systems
	if verbose > 0 then print_color(c1, s1.."Detecting Versions and Loaded Scripts/Systems...") end
	
	if verbose > 1 then
		print_color(c2, s2.."Versions:")
		print_color(c3, s3.."Collection Version - "..tostring(version))
		print_color(c3, s3.."DFHack Version - "..tostring(dfhackv))
		print_color(c3, s3.."Dwarf Fortress Version - "..tostring(dfversn))
	end
	
	---- Scripts
	if verbose > 2 then print_color(c2, s2.."Found Scripts:") end
	local scripts = {}
	local scriptCategories = {"unit","item","entity","building","map"}
	for _,category in pairs(scriptCategories) do
		if verbose > 2 then print_color(c3, s3..category:upper()) end
		for _,name in pairs(dfhack.internal.getDir(dfhack.getDFPath()..scripts_dir.."/"..category.."/")) do
			if name ~= "." and name ~= ".." then
				scripts[#scripts+1] = category.."/"..split(name,".lua")[1]
				if verbose > 2 then print_color(c4, s4..split(name,".lua")[1]) end
			end
		end
	end

	---- Systems
	if verbose > 2 then print_color(c2, s2.."Found Systems:") end
	local systems = {}
	local systemCategories = {"enhanced"}
	for _,category in pairs(systemCategories) do
		if verbose > 2 then print_color(c3, s3..category:upper()) end
		for _,name in pairs(dfhack.internal.getDir(dfhack.getDFPath()..systems_dir.."/"..category.."/")) do
			if name ~= "." and name ~= ".." then
				systems[#systems+1] = category.."/"..split(name,".lua")[1]
				if verbose > 2 then print_color(c4, s4..split(name,".lua")[1]) end
			end
		end
	end
	dfhack.color(COLOR_RESET)
	
	return scripts, systems
end

-- INITIALIZATION
local function initializePersistentTables(verbose)
	-- Initialize persistent tables
	if verbose > 0 then print_color(c1, s1.."Intializing Persistent Tables...") end
	persistTable = require "persist-table"

	---- Persist CommandDelays
	n = 0
	if verbose > 1 then print_color(c2, s2.."CommandDelay Tables:") end
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
	if verbose > 1 then print_color(c3, s3.."Command Delays Loaded - "..tostring(n)) end

	---- Persist FunctionDelays
	n = 0
	if verbose > 1 then print_color(c2, s2.."FunctionDelay Tables:") end
	persistTable.GlobalTable.persistFunctionDelay = persistTable.GlobalTable.persistFunctionDelay or {}
	delayTable = persistTable.GlobalTable.persistFunctionDelay
	for _,i in pairs(delayTable._children) do
		delay = delayTable[i]
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
	if verbose > 1 then print_color(c3, s3.."Function Delays Loaded - "..tostring(n)) end
	
	dfhack.color(COLOR_RESET)
end

local function initializeFileTables(scripts,systems,verbose,test)
	-- Initialize file tables
	if verbose > 0 then print_color(c1, s1.."Intializing Tables from Files...") end
	
	local fname = nil
	savepath = dfhack.getSavePath()
	if verbose > 1 then print_color(c2, s2.."Searching for "..persistFileName.." in "..savepath) end
	if dfhack.internal.getDir(savepath) then
		for _,f in pairs(dfhack.internal.getDir(savepath)) do
			if f == persistFileName then
				fname = savepath.."/"..persistFileName
				break
			end
		end
	end
	if fname then
		if verbose > 1 then print_color(c3, s3..fname.." found, loading saved tables") end
		tables.loadFile(fname)
	else
		if verbose > 1 then print_color(c3, s3.."No save file found, initializing tables") end
		tables.initTables(scripts,systems,test,verbose)
	end
	
	dfhack.color(COLOR_RESET)
end

local function initializeSystems(systems,verbose)
	if verbose > 0 then print_color(c1, s1.."Systems Loaded...") end
	for _,systemFile in pairs(systems) do
		local system = reqscript(systemFile)
		local systemName = system.Name
		local n = tables.Tables.Systems[systemName] or 0
		
		system.initialize() -- This runs all necessary initialization steps and starts the event triggers
		
		if verbose > 1 then print_color(c2, s2..systemName.." - "..tostring(n)) end
		if verbose > 2 then print_color(c3, s3.."TODO") end
	end
end

validArgs = utils.invert({
 "help",
 "forceReload",
 "testRun",
 "clear",
 "v",
 "vv",
 "vvv",
 "vvvv",
 "verbose",
})
local args = utils.processArgs({...}, validArgs)
verbose = 0
if args.testRun then verbose = 5 end
if args.v then verbose = 1 end
if args.vv then verbose = 2 end
if args.vvv then verbose = 3 end
if args.vvvv then verbose = 4 end
if args.verbose then verbose = 5 end

scripts, systems = detectCollection(verbose,args.testRun)
initializePersistentTables(verbose)
initializeFileTables(scripts,systems,verbose,args.testRun)
initializeSystems(systems,verbose)

dfhack.color(COLOR_RESET)