--unit/change-action
--@ module = true
local utils = require "utils"

local help = [====[

unit/change-action
==================
Purpose::
    Changes the information for a given action
	NOTE: Only tested with movement and attack actions at this point

Uses::
	functions/unit

Arguments::
    -unit <UNIT_ID>
    -action <ActionType>
        The type of action to modify
        Valid Values:
            All
            Move
            Attack
    -data [ <DATA_KEY> <DATA_VALUE> ... ]
        sets the cooresponding data key to the data value for each action
	-clear
		if present, removes the action(s)

Examples::
	* Set a timer of 200 for all current actions
		unit/change-action -unit \\UNIT_ID -action All -data [ timer 200 ]
	
	* Set the velocity of any attack actions 
		unit/change-action -unit \\UNIT_ID -action Attack -data [ velocity 500 ]
		
	* Remove all movement actions
		unit/change-action -unit \\UNIT_ID -action Move -clear
]====]

validArgs = utils.invert({
    "help",
    "unit",
    "data",
    "action",
	"clear",
	"args",
})

function changeAction(unit,actionType,data)
	local defunit = reqscript("functions/unit").UNIT
	unit = defunit(unit)
	actions = unit:getActions(actionType)
	for _,action in pairs(actions) do
		for k,_ in pairs(action.data) do
			if data[k] then action.data[k] = data[k] end
		end
	end
end

function removeAction(unit,actionType)
	local defunit = reqscript("functions/unit").UNIT
	unit = defunit(unit)
	actions = unit:getActions(actionType)
	for _,action in pairs(actions) do
		action:removeAction()
	end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in unit/action-change - "

	-- Print help message
	if args.help then
		print(help)
		return
	end
	
	-- Print valid argument list
	if args.args then
		printall(validArgs)
		return
	end

	-- Check for valid unit
	if args.unit and tonumber(args.unit) then unit = df.unit.find(tonumber(args.unit)) end
	if not unit then error(error_str .. "No valid unit selected") end

    -- Check for action options
	if not args.data and not args.clear then error(error_str .. "No action data declared") end

	
	-- Apply action change
	if args.clear then
		removeAction(unit,string.upper(args.action))
	else
		local data = {}
		for i = 1, #args.data, 2 do
			data[args.data[i]] = args.data[i+1]
			if args.data[i] == "timer" then -- Some actions have different names for 'timer'
				data["timer1"] = args.data[i+1]
				data["timer2"] = args.data[i+1]
			end
		end
		changeAction(unit,string.upper(args.action),data)
	end
end

if not dfhack_flags.module then
	main(...)
end