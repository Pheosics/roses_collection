script = require 'gui.script'

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
file = io.open('rto_event.txt','w')
io.output(file)

-- Initialize base/roses-init
printplus('Running base/roses-init with no systems loaded')
printplus('base/roses-init -verbose -testRun')
dfhack.run_command_silent('base/roses-init -verbose -testRun')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('')
printplus('Running Base commands:')
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/persist-delay')
output = dfhack.run_command_silent('base/persist-delay -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/liquids-update')
output = dfhack.run_command_silent('base/liquids-update -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/flows-update')
output = dfhack.run_command_silent('base/flows-update -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-death')
output = dfhack.run_command_silent('base/on-death -verbose')
writeall(output)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
printplus('Running base/on-time')
output = dfhack.run_command_silent('base/on-time -verbose')
writeall(output)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENT SYSTEM CHECKS -------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function system_checks()
 printplus('Event System Checks Starting',COLOR_CYAN)
 eventCheck = {}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  printplus('')
  printplus('base/roses-init -eventSystem -verbose -testRun')
  output = dfhack.run_command_silent('base/roses-init -eventSystem -verbose -testRun')
  writeall(output)

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  writeall('Forcing Test Event 1 to trigger, both effects should fail')
  output = dfhack.run_command_silent('events/trigger -event TEST_EVENT_1 -force -verbose')
  writeall(output)
  roses = dfhack.script_environment('base/roses-init').roses
  if not roses.CounterTable.TEST_EVENT_1_EFFECT_1 then
   eventCheck[#eventCheck + 1] = 'Test Event 1 Effect 1 not triggered'
  end
  if not roses.CounterTable.TEST_EVENT_1_EFFECT_2 then
   eventCheck[#eventCheck + 1] = 'Test Event 1 Effect 2 not triggered'
  end

  ----
  writeall('Test Event 2 should occur within 1 in-game day, if successful a random location and random unit id will be printed')
  writeall('Pausing run_test.lua for 3200 in-game ticks')
  script.sleep(3200,'ticks')
  writeall('Resuming run_test.lua')
  roses = dfhack.script_environment('base/roses-init').roses
  if roses.CounterTable.TEST_EVENT_2_EFFECT_1 then
   eventCheck[#eventCheck + 1] = 'Test Event 2 Effect 1 incorrectly triggered'
  end
  if roses.CounterTable.TEST_EVENT_2_EFFECT_2 then
   eventCheck[#eventCheck + 1] = 'Test Event 2 Effect 2 incorrectly triggered'
  end

  ---- Print PASS/FAIL
  if #eventCheck == 0 then
   printplus('PASSED: Event System - Base',COLOR_GREEN)
  else
   printplus('FAILED: Event System - Base',COLOR_RED)
   writeall(eventCheck)
  end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 printplus('Event System Checks Finished',COLOR_CYAN)

 io.close()
end

script.start(system_checks)
