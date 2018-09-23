local utils = require 'utils'
local split = utils.split_string

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

dfhack.run_command('base/roses-init -testRun')
-- FUNCTIONS HELP FILE
file = io.open('Functions.txt','w')
io.output(file)

functions = {}
functions['unit']     = dfhack.script_environment('functions/unit')
functions['item']     = dfhack.script_environment('functions/item')
functions['building'] = dfhack.script_environment('functions/building')
functions['map']      = dfhack.script_environment('functions/map')
functions['wrapper']  = dfhack.script_environment('functions/wrapper')

for fname,f in pairs(functions) do
 writeall(string.upper(fname)..' FUNCTIONS')
 writeall(f.usages)
end
io.close()

-- SCRIPTS HELP FILE
dir = dfhack.getDFPath()..'/raw/scripts/'
file = io.open('Scripts.txt','w')
io.output(file)

s = {'unit','map','building','item'}
for _,folder in pairs(s) do
 writeall(string.upper(folder).. ' SCRIPTS')
 for _,fname in pairs(dfhack.internal.getDir(dir..folder..'/')) do
  if string.match(fname,'lua') then
   f = split(fname,'.lua')[1]
   output = dfhack.run_command_silent(folder..'/'..f..' -help')
   writeall(output)
  end
 end
end
io.close()