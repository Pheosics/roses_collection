
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