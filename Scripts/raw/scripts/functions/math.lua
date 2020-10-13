--@ module=true

-- 
function roll(percent, out_of)
	if percent == 100 then return true end
	if percent == 0   then return false end
	local out_of = out_of or 100
	local rand = dfhack.random.new()
	return 100*rand:random(out_of)/out_of < percent
end

-- Computes change needed according to mode, value, and current
function computeChange(mode, value, current)
	local change
	if mode == "+" or mode == "ADD" then
		change = value
	elseif mode == "-" or mode == "SUBTRACT" then
		change = -value
	elseif mode == "*" or mode == "MULTIPLY" then
		change = current*value - current
	elseif mode == "/" or mode == "DIVIDE" then 
		change = current/value - current	
	elseif mode == "." or mode == "SET" then
		change = value - current
	else
		change = value
	end
	return math.floor(change + 0.5)
end

-- Select a random item from a table
function selectRandom(tab)
	if #tab == 1 then
		return tab[1]
	else
		local rand = dfhack.random.new()
		return tab[rand:random(#tab)+1]
	end
end

-- Randomly permutes a given table. Returns permuted table
function permute(tab,zero)
	if zero then
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

function count(countType,countSubtype)
	local n = 0
	if countType == "BUILDING" then
		for _,bldg in pairs(df.global.world.buildings.all) do
			if bldg:getCustomType() >= 0 and bldg:getCustomType().code == countSubtype then
				n = n+1
			end
		end
	end
	return n
end