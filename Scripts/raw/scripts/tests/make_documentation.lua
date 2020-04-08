local utils = require "utils"
local split = utils.split_string
dfhack.run_command("core/initialize")
scripts = dfhack.script_environment("core/initialize").scripts
systems = dfhack.script_environment("core/initialize").systems

file = io.open("script_documentation.txt","w")
io.output(file)
io.write("[center][size=24pt]Current Scripts[/size][/center]\n")
previousType = ""
for _,script in pairs(scripts) do
	scriptType = split(script,"/")[1]
	if scriptType ~= previousType then
		previousType = scriptType
		io.write("[center][size=18pt]"..scriptType.." Scripts[/size][/center]\n")
	end
	output = dfhack.run_command_silent(script.." -help")
	io.write("[spoiler="..script.."]\n")
	io.write(output)
	io.write("[/spoiler]\n")
end
io.close()

file = io.open("system_documentation.txt","w")
io.output(file)
io.write("[center][size=24pt]Current Systems[/size][/center]\n")
io.write("[center][size=18pt]Enhanced System[/size][/center]\n")
io.write("[b]Purpose:[/b] The Enhanced System takes the raws as they are now and adds new token options to them. These additional tokens are declared in curly brackets {} and so are not read by DF itself, but instead by the system.\n")
io.write("[b]System Modules:[/b] Enhanced Buildings, Enhanced Items\n")
previousType = ""
for _,systemFile in pairs(systems) do
	system = reqscript(systemFile)
	io.write("[center][size=14pt]"..system.Name.."[/size][/center]\n")
	io.write("[b]Raw File Type:[/b] "..system.RawFileType.."\n")
	io.write("[b]Accepted Tokens:[/b] (in no particular order yet)\n")
	io.write("[list]\n")
	for key, token in pairs(system.Tokens) do
		entry = "{"..key
		if token.Subtype == "Boolean" then
			--pass
		elseif token.Subtype == "Number" then
			entry = entry..":#"
		elseif token.Subtype == "String" then
			entry = entry..":string"
		elseif token.Subtype == "Table" then
			entry = entry..":A:B"
		elseif token.Subtype == "Named" then
			for k,n in pairs(token.Names) do
				entry = entry..":"..k:lower()
			end
		elseif token.Subtype == "NamedTable" then
			entry = entry..":A"
			for k,n in pairs(token.Names) do
				entry = entry..":"..k:lower()
			end
		end
		entry = entry.."}"
		io.write("[li]"..entry.." - "..token.Purpose.."[/li]\n")
	end
	io.write("[/list]\n")
end
io.close()