--@ module=true
local functionDelay = reqscript("persist-delay").functionDelay

local actions_already_checked=actions_already_checked or {}
things_to_do_every_action=things_to_do_every_action or {}
number_of_projectiles=number_of_projectiles or df.global.proj_next_id

function checkForActions()
	for _,something_to_do_to_every_action in pairs(things_to_do_every_action) do
		something_to_do_to_every_action[5]=something_to_do_to_every_action[5]+1 or 0
	end
	for k,unit in ipairs(df.global.world.units.active) do
		local unit_id=unit.id
		actions_already_checked[unit_id]=actions_already_checked[unit_id] or {}
		local unit_action_checked=actions_already_checked[unit_id]
		for _,action in ipairs(unit.actions) do
			local action_id=action.id
			if action.type > 0 then
				for kk,something_to_do_to_every_action in pairs(things_to_do_every_action) do
					if something_to_do_to_every_action[1] then 
						if something_to_do_to_every_action[5]>1 or (unit_id==something_to_do_to_every_action[3] and action_id==something_to_do_to_every_action[4]) then
							things_to_do_every_action[kk]=nil
						else
							something_to_do_to_every_action[1](unit_id,action,intable.unpack(something_to_do_to_every_action[2]))
						end
					end
				end
				if not unit_action_checked[action_id] then
					--reqscript("enhanced/unit").onUnitAction(unit_id,action)
					reqscript("enhanced/items").onItemAction(unit_id,action)
					unit_action_checked[action_id]=true
				end
			end
		end
	end
end

function checkForNewProjectiles()
	old_projectile_id = number_of_projectiles
	new_projectile_id = df.global.proj_next_id
	if old_projectile_id == new_projectile_id then return end
	diff_projectile_id = new_projectile_id - old_projectile_id
	i = 0
	items = {}
	while i < diff_projectile_id do
		found = false
		projectile = df.global.world.proj_list
		while not found do
			projectile = projectile.next
			if projectile then
				if projectile.item.id == old_projectile_id + i then
					items[i+1] = projectile.item
					found = true
				end
			else
				items[i+1] = nil
				found = true
			end
		end
		i = i + 1
	end
	for j,item in ipairs(items) do
		reqscript("enhanced/items").onItemProjectile(item)
	end
	number_of_projectiles = new_projectile_id
end

function repeatingScriptTrigger(Type, id, script, frequency, delayID)
	if df[Type].find(id) then
		dfhack.run_command(script)
		if tonumber(frequency) <= 0 then return end
		functionDelay(frequency,"functions/custom-events","repeatingScriptTrigger",{Type,id,script,frequency,delayID},delayID)
	end	
end

function delayJob(job,delay) -- Should this be a persistent delay? Probably...
	if delay <= 0 then
		job.completion_timer = 1
		return
	end
	if job.completion_timer == -1 then
		dfhack.timeout(1,'ticks',function () delayJob(job,delay) end)
	else
		delay = delay - 1
		job.completion_timer = 10
		dfhack.timeout(1,'ticks',function () delayJob(job,delay) end)
	end
end