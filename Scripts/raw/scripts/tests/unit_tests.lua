script = require "gui.script"
local defunit = reqscript("functions/unit").UNIT

function writeall(tbl)
 if not tbl then return end
 if type(tbl) == "table" then
  for _,text in pairs(tbl) do
   io.write(text.."\n")
  end
 elseif type(tbl) == "userdata" then
  io.write("userdata\n")
 else
  io.write(tbl.."\n")
 end
end

function tests()
	local civ = {}
	local non = {}
	for _,unit in pairs(df.global.world.units.active) do
		if dfhack.units.isCitizen(unit) then
			civ[#civ+1] = defunit(unit.id)
		elseif unit.training_level == 7 then
			non[#non+1] = defunit(unit.id)
		end
	end
	local self = {civUnits = civ,
				wildUnits = non}
	
	local attack = function ()
		local unitCheck = {}
		local attacker = self.civUnits[1]
		local defender = self.wildUnits[4]
		dfhack.script_environment("teleport").teleport(defender._unit,attacker.pos)
		
		---- Check that the script succeeds and adds an attack action with the calculated velocity, hit chance, and body part target
		dfhack.run_command_silent("unit/change-action -unit "..tostring(attacker.id).." -action Attack -clear")
		local cmd = "unit/attack -defender "..tostring(defender.id).." -attacker "..tostring(attacker.id)
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		check = false
		for _,action in pairs(attacker:getActions("Attack")) do
			if action.data.target_unit_id == defender.id then
				check = true
				break
			end
		end
		if not check then
			unitCheck[#unitCheck+1] = "Failed to assign attack action to attacking unit targeting defending unit"
		end
		
		---- Check that the script succeeds and adds 10 punch attacks against defenders head
		dfhack.run_command_silent("unit/change-action -unit "..tostring(attacker.id).." -action Attack -clear")
		cmd = "unit/attack -defender "..tostring(defender.id).." -attacker "..tostring(attacker.id).." -attack PUNCH -target HEAD -number 10 -velocity 100 -delay 10"
		writeall(cmd)
		dfhack.run_command(cmd)
		writeall(output)
		local n = 0
		local bps = defender:getBodyParts("CATEGORY","HEAD")
		for _,action in pairs(attacker:getActions("Attack")) do
			if action.data.target_unit_id == defender.id then
				if action.data.attack_velocity == 100 and action.data.target_body_part_id == bps[1].id then
					n = n + 1
				end
			end
		end
		if n ~= 10 then
			unitCheck[#unitCheck+1] = "Failed to add 10 100 velocity punches to the head of defender - " .. tostring(n)
		end
		
		return unitCheck
	end
	
	local butcher = function ()
		local unitCheck = {}
		local unit = self.wildUnits[3]
        local id = unit.id
		---- Check that the script fails because unit is still alive
		writeall("unit/butcher -unit "..tostring(unit.id))
		output = dfhack.run_command_silent("unit/butcher -unit "..tostring(unit.id))
		writeall(output)
		if dfhack.units.isKilled(unit._unit) then
			unitCheck[#unitCheck+1] = "Incorrectly killed the unit"
		end
		
		---- Check that the script succeeds in killing and then butchering the unit
		writeall("unit/butcher -unit "..tostring(unit.id).." -kill")
		output = dfhack.run_command_silent("unit/butcher -unit "..tostring(unit.id).." -kill")
		writeall(output)
		writeall("Pausing run_test.lua for 5 in-game ticks")
		script.sleep(5,"ticks")
		writeall("Resuming run_test.lua")
		if not dfhack.units.isKilled(unit._unit) then
			unitCheck[#unitCheck+1] = "Failed to kill unit"
		end
		if #unit.corpse_parts < 1 then
			unitCheck[#unitCheck+1] = "Failed to butcher unit"
		end

		-- Bring the unit back to life
        dfhack.run_command("full-heal -r -unit "..tostring(unit.id))
		return unitCheck
	end

	local change_action = function ()
		local unit = self.civUnits[1]
		local unitCheck = {}
		writeall("unit/change-action checks starting")
	
	---- Check that the script succeeds and adds an action of every type with a 500 tick cooldown
		local cmd = "unit/change-action -unit "..tostring(unit.id).." -data [ timer 500 ] -action All"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		local check = true
		local actions = unit:getActions("ALL")
		for _,action in pairs(actions) do
			local delay = action:getDelay()
			if delay >= 0 and delay < 500 then
				check = false
				break
			end
		end
		if not check then
			unitCheck[#unitCheck+1] = "Failed to change all timed actions to 500"
		end
		
		---- Check that the script succeeds and removes all actions from unit
		cmd = "unit/change-action -unit "..tostring(unit.id).." -action ALL -clear"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if #unit:getActions("ALL") > 0 then
			unitCheck[#unitCheck+1] = "Failed to remove all actions from unit"
		end
		
		return unitCheck
	end

	local change_attribute = function ()
		local unit = self.civUnits[1]
		local unitCheck = {}
		
	---- Check that the script succeeds and adds 50 strength to the unit
		local attribute = unit:getAttribute("STRENGTH")
		local val = attribute:getBaseValue()
		local cmd = "unit/change-attribute -unit "..tostring(unit.id).." -attribute [ STRENGTH +50 ]"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if attribute:getBaseValue() ~= val + 50 then
			unitCheck[#unitCheck+1] = "Failed to add 50 strength to unit "..tostring(val).." - "..tostring(attribute:getBaseValue())
		end		
		
		return unitCheck
	end

	local change_body = function ()
		local unit = self.wildUnits[2]
		local unitCheck = {}
	
	---- Check that the script succeeds and set the eyes of unit on fire for 50 ticks
		writeall("unit/change-body -unit "..tostring(unit.id).." -bodyPart FLAG:SIGHT -status [ on_fire true ] -dur 50")
		output = dfhack.run_command_silent("unit/change-body -unit "..tostring(unit.id).." -bodyPart FLAG:SIGHT -status [ on_fire true ] -dur 50")
		writeall(output)
		parts = unit:getBodyParts("FLAG","SIGHT")
		for _,part in pairs(parts) do
			if not part:getStatus("on_fire") then
				unitCheck[#unitCheck+1] = "Failed to set SIGHT body parts on fire"
			end
		end
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		for _,part in pairs(parts) do
			if part:getStatus("on_fire") then
				unitCheck[#unitCheck+1] = "Failed to turn off fire of SIGHT body parts"
			end
		end
		
		return unitCheck
	end

	local change_personality = function ()
		local unit = self.civUnits[1]
		local personality = unit:getPersonality()
		local unitCheck = {}
		
	---- Check that the script increases ELOQUENCY by 10 for 50 ticks
		local trait = personality:getTrait("ELOQUENCY")
		local cmd = "unit/change-personality -unit "..tostring(unit.id).." -trait [ ELOQUENCY +10 ] -dur 50"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		if personality:getTrait("ELOQUENCY") ~= trait + 10 then
			unitCheck[#unitCheck+1] = "Failed to increase units ELOQUENCY trait by 10 - " .. tostring(trait+10) .. " " .. tostring(personality:getTrait("ELOQUENCY"))
		end
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		if personality:getTrait("ELOQUENCY") ~= trait then
			unitCheck[#unitCheck+1] = "Failed to reset units ELOQUENCY trait - " .. tostring(trait) .. " " .. tostring(personality:getTrait("ELOQUENCY"))
		end		
		
		return unitCheck
	end

	local change_skill = function ()
		local unit = self.civUnits[1]
		local unitCheck = {}
		
	---- Check that the script succeeds and increases units dodging skill by 5 levels
		local skill = unit:getSkill("DODGING",true)
		local val = 0
		if skill then
			val = skill:getBaseValue("LEVEL")
		end
		cmd = "unit/change-skill -unit "..tostring(unit.id).." -skill [ DODGING +5 ] -add"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		skill = unit:getSkill("DODGING",true)
		if skill:getBaseValue("LEVEL") ~= val + 5 then
			unitCheck[#unitCheck+1] = "Failed to increase units dodging skill by 5 - " .. tostring(val+5) .. " " .. tostring(skill:getBaseValue("LEVEL"))
		end

	---- Check that the script succeeds and increases units mining skill experience by 500
		local skill = unit:getSkill("MINING",true)
		local val = 0
		if skill then
			val = skill:getEffectiveValue("EXPERIENCE")
		end
		cmd = "unit/change-skill -unit "..tostring(unit.id).." -skill [ MINING +500 ] -type Experience -add"
		writeall(cmd)
		output = dfhack.run_command_silent(cmd)
		writeall(output)
		skill = unit:getSkill("MINING",true)
		if skill:getEffectiveValue("EXPERIENCE") ~= val + 500 then
			unitCheck[#unitCheck+1] = "Failed to add 500 experience to units mining skill - " .. tostring(val+500) .. " " .. tostring(skill:getEffectiveValue("EXPERIENCE"))
		end
		
		return unitCheck
	end
	
	local propel = function ()
		local unitCheck = {}
		local unit = self.civUnits[3]

	---- Check that the script succeeds and turns the unit into a projectile
		writeall("unit/propel -unit "..tostring(unit.id).." -velocity [ 0 0 100 ] -mode Fixed")
		output = dfhack.run_command_silent("unit/propel -unit "..tostring(unit.id).." -velocity [ 0 0 100 ] -mode Fixed")
		--writeall(output)
		if not unit:hasFlag("projectile") then
			unitCheck[#unitCheck+1] = "Failed to turn unit into projectile"
		end
		
		return unitCheck
	end

	return {
		attack = attack,
		butcher = butcher,
		change_action = change_action,
		change_attribute = change_attribute,
		change_body = change_body,
		change_skill = change_skill,
		propel = propel,
	}
end