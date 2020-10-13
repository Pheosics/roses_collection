--item/change-quality.lua
--@ module=true
local utils = require 'utils'
local getItem = reqscript("functions/item").getItem
local getUnit = reqscript("functions/unit").getUnit

local usage = [====[

item/change-quality
====================
Purpose::
    Change the quality of a given item or equipped item(s)

Arguments::
    -item <ITEM_ID>
        id of item to change
    -quality <#>
        Quality to set item to
    -upgrade
        If present will increase quality by 1
    -downgrade
        If present will decrease quality by 1
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
	* Upgrade units equipment by 1 quality level for 3600 ticks
		item/change-quality -unit \\UNIT_ID -equipment ALL -upgrade -dur 3600
	* Set items quality to 4
		item/change-quality -item \\ITEM_ID -quality 4

]====]

validArgs = utils.invert({
    "help",
    "unit",
    "item",
    "equipment",
    "quality",
    "dur",
    "upgrade",
    "downgrade",
	"args",
})

function changeQuality(item, quality, dur)
	item = getItem(item)
	current = item:getQuality() --vmethod
	item:changeQuality(quality)
    if dur > 1  then
        cmd = "item/change-quality"
        cmd = cmd .. " -item " .. tostring(item.id)
        cmd = cmd .. " -quality " .. tostring(current)
        dfhack.script_environment("persist-delay").commandDelay(dur,cmd)
    end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in item/change-quality - "

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
	if not args.quality and not args.upgrade and not args.downgrade then error(error_str.."No quality change declared") end
	
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
		currentQuality = item:getQuality() --vmethod
		if args.quality then
			change = tonumber(args.quality)
		elseif args.upgrade then
			change = currentQuality + 1
		elseif args.downgrade then
			change = currentQuality - 1
		end
		changeQuality(item, change, dur)
    end
end

if not dfhack_flags.module then
	main(...)
end