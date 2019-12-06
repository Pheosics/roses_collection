--item/destroy.lua
local usage = [====[

item/destroy
===========
Purpose::

Function Calls::
      
Arguments::
	-item
		Item to be destroyed

Examples::

]====]

local utils = require "utils"
validArgs = utils.invert({
	"help",
	"item",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in item/destroy - "

if args.help then
	print(usage)
	return
end

if not args.item then error(error_str .. "No item declared") end
dfhack.items.remove(df.item.find(tonumber(args.item)))