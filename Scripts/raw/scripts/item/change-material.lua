--item/change-material.lua
--@ module=true
local utils = require 'utils'
defitem = reqscript("functions/item").ITEM

local usage = [====[

item/change-material
====================
Purpose::
    Change the material of a given item or equipped item(s)

Arguments::
    -item <ITEM_ID>
        id of item to change
    -material <MATERIAL_TYPE:MATERIAL_SUBTYPE>
        Material to change item into
    -unit <UNIT_ID>
        id of unit to change if using -equipment
    -equipment <ITEM_TYPE>
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
    -dur <#ticks>
        Length of time for change to last

Examples::
	* Change specific item's material to diamond for 3600 ticks
		item/change-material -item \\ITEM_ID -material INORGANIC:DIAMOND -dur 3600
	* Change a units weapon(s) to slade
		item/change-material -unit \\UNIT_ID -equipment WEAPON -mat INORGANIC:SLADE

]====]

validArgs = utils.invert({
    "help",
    "unit",
    "item",
    "equipment",
    "material",
    "dur",
	"args",
})

function changeMaterial(item, material, dur)
	item = defitem(item)
    currentMat = item:getMaterial()
    item:changeMaterial(material)
    if dur > 1  then
        cmd = "item/change-material"
        cmd = cmd .. " -item " .. tostring(item.id)
        cmd = cmd .. " -material " .. currentMat
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
    end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in item/change-material - "

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
	if not args.material then error(error_str.."No material change declared") end
	
	-- Check for valid items
	if args.item and tonumber(args.item) then
		items = {df.item.find(args.item)}
	elseif args.unit and tonumber(args.unit) then
		unit = reqscript("functions/unit").UNIT(tonumber(args.unit))
		items = unit:getInventoryItems("TYPE",args.equipment)
	end
	if not items then
		error(error_str .. "No item or unit selected")
	end

	-- Apply changes
	for _, item in ipairs(items) do
		changeMaterial(item, args.material, dur)
    end
end

if not dfhack_flags.module then
	main(...)
end