
function selectRandom(tab)
	if #tab == 1 then
		return tab[1]
	else
		local rand = dfhack.random.new()
		return tab[rand:random(#tab)+1]
	end
end