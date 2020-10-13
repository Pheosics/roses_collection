-- Miscellanious functions, v42.06a
--[[
 getChange(current,value,mode)
 permute(tahle)
 changeCounter(counter,amount,extra)
 checkCounter(counter,extra)
 getCounter(counter,extra)
]]
function getChange(current,value,mode)
 local change = 0
 if mode:upper() == 'FIXED' then
  change = tonumber(value)
 elseif mode:upper() == 'PERCENT' then
  local percent = tonumber(value)/100
  change = current*percent - current
 elseif mode:upper() == 'SET' then
  change = tonumber(value) - current
 else
  change = tonumber(value)
 end 
 return change
end

function permute(tab)
 -- Randomly permutes a given table. Returns permuted table
 if true then
  n = #tab-1
  for i = 0, n do
   local j = math.random(i, n)
   tab[i], tab[j] = tab[j], tab[i]
  end
  return tab
 else
  n = #tab
  for i = 1, n do
   local j = math.random(i, n)
   tab[i], tab[j] = tab[j], tab[i]
  end
  return tab
 end
end

function changeCounter(counter,amount,extra)
 roses = dfhack.script_environment('base/roses-table').roses
 if not roses or not tonumber(amount) then return end
 
 local utils = require 'utils'
 local split = utils.split_string
 counterTable = roses.CounterTable
 counters = split(counter,':')
 for i,x in pairs(counters) do
  if i == #counters then
   endc = x
   break
  end
  if (x == '!UNIT' or x == '!BUILDING' or x == '!ITEM') then
   if not counterTable[extra] then
    counterTable[extra] = {}
   end
   counterTable = counterTable[extra]
  elseif not counterTable[x] then
   if i ~= #counters then
    counterTable[x] = {}
   end
   counterTable = counterTable[x]
  else
   counterTable = counterTable[x]
  end
 end
 if not counterTable[endc] then
  counterTable[endc] = 0
 end
 counterTable[endc] = counterTable[endc] + amount

 return counterTable[endc]
end
