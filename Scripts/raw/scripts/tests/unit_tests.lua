script = require "gui.script"

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
			civ[#civ+1] = dfhack.script_environment("functions/unit").UNIT(unit.id)
		elseif unit.training_level == 7 then
			non[#non+1] = dfhack.script_environment("functions/unit").UNIT(unit.id)
		end
	end
	local self = {civUnits = civ,
				wildUnits = non,
				unitFunctions = dfhack.script_environment("functions/unit")}
	
	local action_change = function ()
		local unit = self.civUnits[1]
		local unitCheck = {}
		writeall("unit/action-change checks starting")
	
	---- Check that the script succeeds and adds an action of every type with a 500 tick cooldown
		writeall("unit/action-change -unit "..tostring(unit.id).." -timer 500 -action All -create")
		output = dfhack.run_command_silent("unit/action-change -unit "..tostring(unit.id).." -timer 500 -action All -create")
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
			unitCheck[#unitCheck+1] = "Failed to add a 500 tick action for each action to unit"
		end
		
		---- Check that the script succeeds and removes all actions from unit
		writeall("unit/action-change -unit "..tostring(unit.id).." -action ALL -timer clearAll")
		output = dfhack.run_command_silent("unit/action-change -unit "..tostring(unit.id).." -action ALL -timer clearAll")
		writeall(output)
		if #unit:getActions("ALL") > 0 then
			unitCheck[#unitCheck+1] = "Failed to remove all actions from unit"
		end
		
		---- Check that the script succeeds and adds 100 ticks to all interaction cooldowns
		writeall("unit/action-change -unit "..tostring(unit.id).." -timer 100 -interaction All")
		output = dfhack.run_command_silent("unit/action-change -unit "..tostring(unit.id).." -timer 100 -interaction All")
		writeall(output)
		check = true
		for _,interaction in pairs(unit:getInteractions()) do
			local delay = interaction:getDelay()
			if delay > 0 and delay < 100 then
				check = false
				break
			end
		end
		if not check  then
			unitCheck[#unitCheck+1] = "Failed to increase interaction delay by 100 ticks"
		end
		
		return unitCheck
	end
	
	local attack = function ()
		local unitCheck = {}
		local attacker = self.civUnits[1]
		local defender = self.wildUnits[4]
		defender:changePosition(attacker:getPosition())
		
		---- Check that the script succeeds and adds an attack action with the calculated velocity, hit chance, and body part target
		writeall("unit/attack -defender "..tostring(defender.id).." -attacker "..tostring(attacker.id))
		output = dfhack.run_command_silent("unit/attack -defender "..tostring(defender.id).." -attacker "..tostring(attacker.id))
		--writeall(output)
		check = false
		for _,action in pairs(attacker:getActions("Attack")) do
			local data = action:getData()
			if data.target_unit_id == defender.id then
				check = true
				break
			end
		end
		if not check then
			unitCheck[#unitCheck+1] = "Failed to assign attack action to attacking unit targeting defending unit"
		end
		
		---- Check that the script succeeds and adds 10 punch attacks against defenders head
		writeall("unit/attack -defender "..tostring(defender.id).." -attacker "..tostring(attacker.id).." -attack PUNCH -target HEAD -number 10 -velocity 100 -delay 10")
		dfhack.run_command("unit/attack -defender "..tostring(defender.id).." -attacker "..tostring(attacker.id).." -attack PUNCH -target HEAD -number 10 -velocity 100 -delay 10")
		--writeall(output)
		local n = 0
		local bps = defender:getBodyParts("CATEGORY","HEAD")
		for _,action in pairs(attacker:getActions("Attack")) do
			local data = action:getData()
			if data.target_unit_id == defender.id then
				if data.attack_velocity == 100 and data.target_body_part_id == bps[1].id then
					n = n + 1
				end
			end
		end
		if n ~= 10 then
			unitCheck[#unitCheck+1] = "Failed to add 10 100 velocity punches to the head of defender - " .. tostring(n)
		end
		
		return unitCheck
	end

	local attribute_change = function ()
		local unit = self.civUnits[1]
		local unitCheck = {}
		
	---- Check that the script succeeds and adds 50 strength to the unit
		local attribute = unit:getAttribute("STRENGTH")
		local val = attribute:getBaseValue()
		writeall("unit/attribute-change -unit "..tostring(unit.id).." -attribute STRENGTH -amount 50 -mode fixed")
		--output = dfhack.run_command_silent("unit/attribute-change -unit "..tostring(unit.id).." -attribute STRENGTH -amount 50 -mode fixed")
		output = dfhack.run_command_silent("unit/attribute-change -unit "..tostring(unit.id).." -attribute STRENGTH -amount 50 -mode fixed")
		writeall(output)
		if attribute:getBaseValue() ~= val + 50 then
			unitCheck[#unitCheck+1] = "Failed to add 50 strength to unit "..tostring(val).." - "..tostring(attribute:getBaseValue())
		end		
		
		return unitCheck
	end

	local body_change = function ()
		local unit = self.wildUnits[2]
		local unitCheck = {}
	
	---- Check that the script succeeds and set the eyes of unit on fire for 50 ticks
		writeall("unit/body-change -unit "..tostring(unit.id).." -partType Flag -bodyPart SIGHT -status Fire -dur 50")
		output = dfhack.run_command_silent("unit/body-change -unit "..tostring(unit.id).." -partType Flag -bodyPart SIGHT -status Fire -dur 50")
		writeall(output)
		parts = unit:getBodyParts("FLAGS","SIGHT")
		for _,part in pairs(parts) do
			if not part:getStatus("fire") then
				unitCheck[#unitCheck+1] = "Failed to set SIGHT body parts on fire"
			end
		end
		writeall("Pausing run_test.lua for 75 in-game ticks")
		script.sleep(75,"ticks")
		writeall("Resuming run_test.lua")
		for _,part in pairs(parts) do
			if part:getStatus("fire") then
				unitCheck[#unitCheck+1] = "Failed to turn off fire of SIGHT body parts"
			end
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
		if unit:_dfhack("isKilled") then
			unitCheck[#unitCheck+1] = "Incorrectly killed the unit"
		end
		
		---- Check that the script succeeds in killing and then butchering the unit
		writeall("unit/butcher -unit "..tostring(unit.id).." -kill")
		output = dfhack.run_command_silent("unit/butcher -unit "..tostring(unit.id).." -kill")
		writeall(output)
		writeall("Pausing run_test.lua for 5 in-game ticks")
		script.sleep(5,"ticks")
		writeall("Resuming run_test.lua")
		if not unit:_dfhack("isKilled") then
			unitCheck[#unitCheck+1] = "Failed to kill unit"
		end
		if #unit:_struct().corpse_parts < 1 then
			unitCheck[#unitCheck+1] = "Failed to butcher unit"
		end

		-- Bring the unit back to life
        dfhack.run_command("full-heal -r -unit "..tostring(unit.id))
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
	
	local skill_change = function ()
		local unit = self.civUnits[1]
		local unitCheck = {}
		
	---- Check that the script succeeds and increases units dodging skill by 5 levels
		local skill = unit:getSkill("DODGING")
		local val = 0
		if skill then
			val = skill:getBaseValue("LEVEL")
		end
		writeall("unit/skill-change -unit "..tostring(unit.id).." -skill DODGING -amount 5 -mode Fixed -add")
		output = dfhack.run_command_silent("unit/skill-change -unit "..tostring(unit.id).." -skill DODGING -amount 5 -mode Fixed -add")
		--writeall(output)
		skill = unit:getSkill("DODGING")
		if skill:getBaseValue("LEVEL") ~= val + 5 then
			unitCheck[#unitCheck+1] = "Failed to increase units dodging skill by 5 - " .. tostring(val) .. " " .. tostring(skill:getBaseValue("LEVEL"))
		end

	---- Check that the script succeeds and increases units mining skill experience by 500
		local skill = unit:getSkill("MINING")
		local val = 0
		if skill then
			val = skill:getEffectiveValue("EXPERIENCE")
		end
		writeall("unit/skill-change -unit "..tostring(unit.id).." -skill MINING -amount 500 -type Experience -mode Fixed -add")
		output = dfhack.run_command_silent("unit/skill-change -unit "..tostring(unit.id).." -skill MINING -amount 500 -type Experience -mode Fixed -add")
		writeall(output)
		skill = unit:getSkill("MINING")
		if skill:getEffectiveValue("EXPERIENCE") ~= val + 500 then
			unitCheck[#unitCheck+1] = "Failed to add 500 experience to units mining skill - " .. tostring(val) .. " " .. tostring(skill:getEffectiveValue("EXPERIENCE"))
		end
		
		return unitCheck
	end
	
	local trait_change = function ()
		local unit = self.civUnits[1]
		local unitCheck = {}

	---- Check that the script succeeds and lowers the units greed trait by 5
		local trait = unit:getTrait("GREED")
		local val = trait:getBaseValue()
		writeall("unit/trait-change -unit "..tostring(unit.id).." -trait GREED -amount 5 -mode Fixed")
		output = dfhack.run_command_silent("unit/trait-change -unit "..tostring(unit.id).." -trait GREED -amount 5 -mode Fixed")
		--writeall(output)
		if trait:getBaseValue() ~= val+5 then
			unitCheck[#unitCheck+1] = "Failed to increase GREED trait by 5 - " .. tostring(val) .. " " .. tostring(trait:getBaseValue())
		end
		
		return unitCheck
	end

	return {
		action_change = action_change,
		attack = attack,
		attribute_change = attribute_change,
		body_change = body_change,
		butcher = butcher,
		propel = propel,
		skill_change = skill_change,
		trait_change = trait_change,
	}
end