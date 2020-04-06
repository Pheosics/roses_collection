--@ module=true

info = {}
info["PLANT"] = [===[ TODO ]===]

--===============================================================================================--
--== PLANT CLASSES ==============================================================================--
--===============================================================================================--
PLANT = defclass(PLANT)

--===============================================================================================--
--== PLANT FUNCTIONS ============================================================================--
--===============================================================================================--
function PLANT:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(PLANT,key) then return rawget(PLANT,key) end
	return self._plant[key]
end
function PLANT:init(plant)
	if tonumber(plant) then plant = df.plant.find(tonumber(plant)) end
	self._plant = plant
	self.tree = false
	if plant.tree_info then self.tree = true end
end

function PLANT:getPositions()
	local positions = {}
	if self.tree then
		local tree = self._plant
		local x1 = tree.pos.x - tree.tree_info.extent_west.value
		local x2 = tree.pos.x + tree.tree_info.extent_east.value
		local y1 = tree.pos.y - tree.tree_info.extent_north.value
		local y2 = tree.pos.y + tree.tree_info.extent_south.value
		local z1 = tree.pos.z
		local z2 = tree.pos.z + tree.tree_info.body_height - 1
		for x = x1,x2 do
			for y = y1,y2 do
				for z = z1,z2 do
					pos = {x=x,y=y,z=z}
					body = tree.tree_info.body[pos.z-z1]:_displace((pos.y - y1) * tree.tree_info.dim_x + (pos.x - x1))
					if body.trunk then
						positions[#positions+1] = pos
					elseif body.twigs then
						positions[#positions+1] = pos
					elseif body.branches then
						positions[#positions+1] = pos
					end
				end
			end
		end
	else
		positions[1] = self._plant.pos
	end
	return positions
end

function PLANT:destroy()
	positions = self:getPositions()
	base = self._plant.pos
	
	-- Erase plant from correct arrays
	arrays = {"all","shrub_dry","shrub_wet"}
	if self.tree then arrays = {"all","tree_dry","tree_wet"} end
	for _, array in ipairs(arrays) do
		for i,plant in pairs(df.global.world.plants[array]) do
			if plant.pos == base then
				df.global.world.plants[array]:erase(i)
				break
			end
		end
	end
	
	-- Erase plant from correct map column
	x_column = math.floor(base.x/16)
	y_column = math.floor(base.y/16)
	map_block_column = df.global.world.map.column_index[x_column-x_column%3][y_column-y_column%3]
	for i,plant in pairs(map_block_column.plants) do
		if plant.pos == base then
			df.global.world.map.column_index[x_column-x_column%3][y_column-y_column%3].plants:erase(i)
			break
		end
	end
	
	--Now change tiletypes for plant positions
	for _,position in ipairs(positions) do
		block = dfhack.maps.ensureTileBlock(position)
		if position.z == base.z then
			block.tiletype[position.x%16][position.y%16] = 350
		else
			block.tiletype[position.x%16][position.y%16] = df.tiletype['OpenSpace']
		end
		block.designation[position.x%16][position.y%16].outside = true
	end
end
--===============================================================================================--
--===============================================================================================--
--===============================================================================================--