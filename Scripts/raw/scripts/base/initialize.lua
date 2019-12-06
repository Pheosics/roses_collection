local utils = require "utils"
local version = 1.0
local dfhackv = 44.12
local dfversn = 44.12
dfhack.internal.addScriptPath("raw/systems/", true)

-- DETECTION
local function detectCollection()
	-- Detect version and scripts/systems
	dfhack.color(COLOR_GREEN)
	print("Detecting Versions and Loaded Scripts/Systems...")
	dfhack.color(COLOR_RESET)
	
	---- Versions
	dfhack.color(COLOR_YELLOW)
	print("  Versions:")
	dfhack.color(COLOR_RESET)
	print("    Collection Version - "..tostring(version))
	print("    DFHack Version - "..tostring(dfhackv))
	print("    Dwarf Fortress Version - "..tostring(dfversn))

	---- Scripts
	dfhack.color(COLOR_YELLOW)
	print("  Loaded Scripts:")
	dfhack.color(COLOR_RESET)
	local scripts = {}
	local scriptCategories = {"unit","item","entity","building"}
	for _,category in pairs(scriptCategories) do
		for _,name in pairs(dfhack.internal.getDir(dfhack.getSavePath().."/raw/scripts/"..category.."/")) do
			scripts[#scripts+1] = name
			print("    "..name)
		end
	end

	---- Systems
	dfhack.color(COLOR_YELLOW)
	print("  Loaded Systems:")
	dfhack.color(COLOR_RESET)
	local systems = {}
	local systemCategories = {"enhanced"}
	for _,category in pairs(systemCategories) do
		for _,name in pairs(dfhack.internal.getDir(dfhack.getSavePath().."/raw/systems/"..category.."/")) do
			systems[#systems+1] = name
			print("    "..name)
		end
	end
	
	return scripts, systems
end

-- INITIALIZATION
local function initializePersistentTables()
	-- Initialize persistent tables
	dfhack.color(COLOR_GREEN)
	print("Intializing Persistent Tables...")
	dfhack.color(COLOR_RESET)
	persistTable = require "persist-table"
	persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
	pT = persistTable.GlobalTable.roses

	---- Command Delays
	n = 0
	dfhack.color(COLOR_YELLOW)
	print("  CommandDelay Tables:")
	dfhack.color(COLOR_RESET)
	pT.CommandDelay = pT.CommandDelay or {}
	for _,i in pairs(pT.CommandDelay._children) do
		delay = pT.CommandDelay[i]
		local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
		if currentTick >= tonumber(delay.Tick) then
			delay = nil
		else
			n = n + 1
			local ticks = delay.Tick-currentTick
			dfhack.timeout(ticks,'ticks',
							function ()
								dfhack.run_command(delay.Script)
							end)
		end
	end
	print("    Command Delays Loaded - "..tostring(n))

	---- Script Environment Delays
	n = 0
	dfhack.color(COLOR_YELLOW)
	print("  EnvironmentDelay Tables:")
	dfhack.color(COLOR_RESET)
	pT.EnvironmentDelay = pT.EnvironmentDelay or {}
	for _,i in pairs(pT.EnvironmentDelay._children) do
		delay = pT.EnvironmentDelay[i]
		local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
		if currentTick >= tonumber(delay.Tick) then
			delay = nil
		else
			n = n + 1
			local ticks = delay.Tick-currentTick
			local environment = delay.Environment
			local functions = delay.Function
			local arguments = delay.Arguments._children
			dfhack.timeout(ticks,'ticks',
							function ()
								dfhack.script_environment(environment)[functions](table.unpack(arguments))
							end)
		end
	end
	print("    Script Environment Delays Loaded - "..tostring(n))
	
	---- Liquid Sources and Sinks
	n = 0
	dfhack.color(COLOR_YELLOW)
	print("  Liquid Tables:")
	dfhack.color(COLOR_RESET)
	pT.LiquidTable = pT.LiquidTable or {}
	for _,i in pairs(pT.LiquidTable ._children) do
		liquid = pT.LiquidTable[i]
		n = n + 1
		if liquid.Type == "Source" then
			--dfhack.script_environment('functions/map').liquidSource(i)
		elseif liquid.Type == "Sink" then
			--dfhack.script_environment('functions/map').liquidSink(i)
		end
	end
	print("    Liquid Sources and Sinks Loaded - "..tostring(n))
	
	---- Flow Sources and Sinks
	n = 0
	dfhack.color(COLOR_YELLOW)
	print("  Flow Tables:")
	dfhack.color(COLOR_RESET)
	pT.FlowTable = pT.FlowTable or {}
	for _,i in pairs(pT.FlowTable ._children) do
		flow = pT.FlowTable[i]
		n = n + 1
		if flow.Type == "Source" then
			--dfhack.script_environment('functions/map').flowSource(i)
		elseif flow.Type == "Sink" then
			--dfhack.script_environment('functions/map').flowSink(i)
		end
	end
	print("    Flow Sources and Sinks Loaded - "..tostring(n))
end

local function initializeFileTables(scripts,systems)
	-- Initialize file tables
	dfhack.color(COLOR_GREEN)
	print("Intializing Tables from Files...")
	dfhack.color(COLOR_RESET)
	
	local fname = nil
	savepath = dfhack.getSavePath()
	dfhack.color(COLOR_YELLOW)
	print("  Searching for RosesPersist.dat in "..savepath)
	dfhack.color(COLOR_RESET)
	for _,f in pairs(dfhack.internal.getDir(savepath)) do
		if f == "RosesPersist.dat" then
			fname = savepath.."/RosesPersist.dat"
			break
		end
	end
	if fname then
		print("    "..fname.." found, loading saved tables")
		dfhack.script_environment("base/tables").loadFile(fname)
	else
		print("    No save file found, initializing tables")
		dfhack.script_envrionment("base/tables").initTables(scripts,systems)
	end
end

validArgs = utils.invert({
 "help",
 "forceReload",
 "testRun",
 "verbose",
 "clear",
})
local args = utils.processArgs({...}, validArgs)

scripts, systems = detectCollection()
initializePersistentTables()
initializeFileTables(scripts,systems)


print("")
dfhack.color(COLOR_GREEN)
print("Systems Loaded...")
dfhack.color(COLOR_RESET)
local Table = dfhack.script_environment("base/tables").Tables
for system,n in pairs(Table.Systems) do
	dfhack.color(COLOR_YELLOW)
	print("  "..system.." - "..tostring(n))
	dfhack.color(COLOR_RESET)
	for _,entry in pairs(Table[system]) do
		print("    "..entry.Name)
	end
end