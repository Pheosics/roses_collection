--unit/action-change.lua
local usage = [====[

unit/action-change
==================
Purpose::
    Changes the timer of a given action or interaction

Arguments::
    -unit #ID
    -action ActionType
        The type of action to modify
        Valid Values:
            All
            Move
            Attack
    -interaction Interaction
        The type of interaction to modify
        Valid Values:
            All
            INTERACTION_TOKEN
    -timer #
        what to set the timer of the action to
        lower values mean the unit will be able to act again sooner
        Special Token:
            clear (erases all actions of the valid action type)
            clearAll (erases all actions regardless of action type)
    -create
        If present, and timer is set to a positive number, will create
        an action of every type with the given timer delay

Examples::
    unit/action-change -unit \\UNIT_ID -action All -timer 200
    unit/action-change -unit \\UNIT_ID -interaction All -timer 5000
]====]

local utils = require 'utils'
validArgs = utils.invert({
    "help",
    "unit",
    "timer",
    "action",
    "interaction",
    "create",
})
local args = utils.processArgs({...}, validArgs)
local error_str = "Error in unit/action-change - "

-- Print help message
if args.help then
    print(usage)
    return
end

-- Check for valid unit
if args.unit and tonumber(args.unit) then unit = dfhack.script_environment("functions/unit").UNIT(args.unit) end
if not unit then error(error_str .. "No valid unit selected") end

-- Check for valid timer argument
if args.timer and tonumber(args.timer) then
    timer = tonumber(args.timer)
elseif string.lower(args.timer) == "clear" then
    timer = "clear"
elseif string.lower(args.timer) == "clearall" then
    timer = "clear"
    args.action = "ALL"
else
    error(error_str.."No valid timer set")
end

-- Apply action change
if args.action then
    if args.create and tonumber(timer) then
        for i = 0, 19 do
            if df.unit_action_type[i]:upper() ~= "TALK" then
                local action_data = df.unit_action:new().data[string.lower(df.unit_action_type[i])]
                for t,_ in pairs(action_data) do
                    if t == "timer" then
                        action_data.timer = timer
                        unit:addAction(df.unit_action_type[i],action_data)
                        break
                    elseif t == "timer1" or t == "timer2" then
                        action_data.timer1 = timer
                        action_data.timer2 = timer
                        unit:addAction(df.unit_action_type[i],action_data)
                        break
                    end
                end
            end
        end
    else
        local actions = unit:getActions(args.action)
        for _,action in pairs(actions) do
            if timer == "clear" then
                action:removeAction()
            else
                action:changeDelay(timer)
            end
        end
    end
end

-- Apply interaction change
if args.interaction then
    local interactions = unit:getInteractions("both",args.interaction)
    if timer == "clear" then timer = 0 end
    for _,interaction in pairs(interactions) do
        interaction:changeDelay(timer)
    end
end
