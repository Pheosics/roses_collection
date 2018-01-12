script = require 'gui.script'
persistTable = require 'persist-table'

function printplus(text,color)
 color = color or COLOR_WHITE
 dfhack.color(color)
  dfhack.println(text)
 dfhack.color(COLOR_RESET)
 io.write(text..'\n')
end

function writeall(tbl)
 if not tbl then return end
 if type(tbl) == 'table' then
  for _,text in pairs(tbl) do
   io.write(text..'\n')
  end
 elseif type(tbl) == 'userdata' then
  io.write('userdata\n')
 else
  io.write(tbl..'\n')
 end
end

-- Open external output file
file = io.open('run_test_output.txt','w')
io.output(file)

-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')
roses = persistTable.GlobalTable.roses

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ROSES SCRIPT CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
script.start(dfhack.script_environment('run_test_script_building').script_check())
script.start(dfhack.script_environment('run_test_script_flow').script_check())
script.start(dfhack.script_environment('run_test_script_item').script_check())
script.start(dfhack.script_environment('run_test_script_tile').script_check())
script.start(dfhack.script_environment('run_test_script_unit').script_check())
script.start(dfhack.script_environment('run_test_script_wrapper').script_check())

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- ROSES SYSTEM CHECKS -----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
script.start(dfhack.script_environment('run_test_system_civilization').script_check())
script.start(dfhack.script_environment('run_test_system_class').script_check())
script.start(dfhack.script_environment('run_test_system_enhanced').script_check())
script.start(dfhack.script_environment('run_test_system_event').script_check())

