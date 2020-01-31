--@ module=true

function computeChange(mode, value, current)
	local change
	if mode == "+" or mode == "ADD" then
		change = value
	elseif mode == "-" or mode == "SUBTRACT" then
		change = -value
	elseif mode == "*" or mode == "MULTIPLY" then
		change = current*value - current
	elseif mode == "/" or mode == "DIVIDE" then 
		change = = current/value - current	
	elseif mode == "." or mode == "SET" then
		change = value - current
	else
		change = value
	end
	return math.floor(change + 0.5)
end

function selectRandom(tab)
	if #tab == 1 then
		return tab[1]
	else
		local rand = dfhack.random.new()
		return tab[rand:random(#tab)+1]
	end
end

function permute(tab,zero)
	-- Randomly permutes a given table. Returns permuted table
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