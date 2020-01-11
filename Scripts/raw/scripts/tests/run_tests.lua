script = require "gui.script"

function printplus(text,color)
	color = color or COLOR_WHITE
	dfhack.color(color)
	dfhack.println(text)
	dfhack.color(COLOR_RESET)
	io.write(text.."\n")
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

scriptChecks = {}
scriptCategories = {"unit","item","entity","building","map"}

function scriptCheck()
	for _,scripts in pairs(scriptCategories) do
		file = io.open("rto_"..scripts..".txt","w")
		io.output(file)
		printplus(scripts:upper().." Script Tests Starting")
		tests = dfhack.script_environment("tests/"..scripts.."_tests").tests()
		if tests.Order then
			for _,name in pairs(tests.Order) do
				func = tests[name]
				writeall(scripts.."/"..name.." checks starting")
				check = func()
				if not check then
					printplus("NOT CHECKED: "..name,COLOR_YELLOW)
				elseif #check == 0 then
					printplus("PASSED: "..name,COLOR_GREEN)
				else
					printplus("FAILED: "..name,COLOR_RED)
					writeall(check)
				end
				scriptChecks[scripts.."_"..name] = check
				writeall(scripts.."/"..name.." checks finished")
				writeall("")
			end
		else
			for name,func in pairs(tests) do
				writeall(scripts.."/"..name.." checks starting")
				check = func()
				if not check then
					printplus("NOT CHECKED: "..name,COLOR_YELLOW)
				elseif #check == 0 then
					printplus("PASSED: "..name,COLOR_GREEN)
				else
					printplus("FAILED: "..name,COLOR_RED)
					writeall(check)
				end
				scriptChecks[scripts.."_"..name] = check
				writeall(scripts.."/"..name.." checks finished")
				writeall("")
			end
		end
		io.close()
	end
end

dfhack.run_command("base/initialize -testRun -verbose")

script.start(scriptCheck)