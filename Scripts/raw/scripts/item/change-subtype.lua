--item/change-subtype.lua
--@ module=true
local utils = require 'utils'
local getItem = reqscript("functions/item").getItem
local getUnit = reqscript("functions/unit").getUnit

local usage = [====[

item/change-subtype
====================
Purpose::
    Change the subtype of a given item or equipped item(s)
 
Arguments::
    -item #ID
        id of item to change
    -subtype ITEM_SUBTYPE
        Subtype to change item into
    -unit #ID
        id of unit to change if using -equipment
    -equipment ITEM_TYPE
        Type of equipment to check for
        Valid Types:
            ALL
            WEAPON
            ARMOR
            HELM
            SHOES
            SHIELD
            GLOVES
            PANTS
            AMMO
    -dur #ticks
        Length of time for change to last

Examples::
	* Change specific item's subtype for 3600 ticks
		item/change-subtype -item \\ITEM_ID -subtype ITEM_WEAPON_SWORD_SHORT -dur 3600
	* Change a units equipped ammo
		item/change-subtype -unit \\UNIT_ID -equipment AMMO -subtype ITEM_AMMO_BOLT_BROKEN

]====]

validArgs = utils.invert({
    "help",
    "unit",
    "item",
    "equipment",
    "subtype",
    "dur",
	"args",
})

function changeSubtype(item, subtype, dur)
	item = getItem(item)
    currentSubtype = item:getSubtype()
    item:changeSubtype(subtype)
    if dur > 1  then
        cmd = "item/change-subtype"
        cmd = cmd .. " -item " .. tostring(item.id)
        cmd = cmd .. " -subtype " .. currentSubtype
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
    end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in item/change-subtype - "

	-- Print Help Message
	if args.help then
		print(usage)
		return
	end

	-- Print valid argument list
	if args.args then
		printall(validArgs)
		return
	end
	
	-- Check for duration value, if negative return
	local dur = tonumber(args.dur) or 0
	if dur < 0 then return end

	-- Check for required tokens
	if not args.subtype then error(error_str.."No subtype change declared") end
	
	-- Check for valid items
	if args.item and tonumber(args.item) then
		items = {df.item.find(args.item)}
	elseif args.unit and tonumber(args.unit) then
		unit = getUnit(tonumber(args.unit))
		items = unit:getInventoryItems("TYPE",args.equipment)
	end
	if not items then
		error(error_str .. "No item or unit selected")
	end

	-- Apply changes
	for _, item in ipairs(items) do
		changeSubtype(item, args.subtype, dur)
    end
end

if not dfhack_flags.module then
	main(...)
end