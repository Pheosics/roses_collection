-- Map Based Functions
usages = {}

local openTileTypes = {"Floor","Pebbles","Shrub","Open"}
local positionTypes = {"CENTER","EDGE","UNIT"}
local positionSubtypes = {"CAVERN","SKY","SURFACE","UNDERGROUND"}

local function checkTypes(x,y)
	if not x then return nil end
	local check = nil
	for _,k in pairs(y) do
		if x == k then
			check = k
			break
		end
	end
	return check
end

local function processXYZ(x,y,z)
	local pos = {}
	if y == nil and z == nil then
		pos.x = x.x or x[1]
		pos.y = x.y or x[2]
		pos.z = x.z or x[3]
	else
		pos.x = x
		pos.y = y
		pos.z = z
	end
	return pos
end

--===============================================================================================--
--== MAP FUNCTIONS ==============================================================================--
--===============================================================================================--
MAP = {}
MAP.__index = MAP
setmetatable(MAP, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function MAP:_init()
	self.last_updated = df.global.cur_year_tick
end
function MAP:_update()
	self.last_updated = df.global.cur_year_tick
	self.surface     = {}
	self.sky         = {}
	self.underground = {}
	self.caverns     = {}
	self.caverns[0]  = {}
	self.caverns[1]  = {}
	self.caverns[2]  = {}
	self.magma_core  = {}
	self.underworld  = {}
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	for i = 1, mapx do
		for j = 1, mapy do
			outside = false
			for k = 2, mapz-1 do
				local pos = {x=i,y=j,z=k}
				previousOutside = outside
				block = dfhack.maps.ensureTileBlock(i,j,k)
				designation = block.designation[i%16][j%16]
				if designation.subterranean then
					self.underground[#self.underground + 1] = pos
				else
					if not previousOutside then
						self.surface[#self.surface + 1] = pos
					else
						self.sky[#self.sky + 1] = pos
					end
					outside = true
				end
				if block.global_feature >= 0 then
					for l,v in pairs(df.global.world.features.feature_global_idx) do
						if v == block.global_feature then
							feature = df.global.world.features.map_features[l]
							break
						end
					end
					if not feature then break end
					if feature.start_depth == 4 then
						self.underworld[#self.underworld + 1] = pos
					elseif feature.start_depth == 3 then
						self.magma_core[#self.magma_core + 1] = pos
					else
						n = feature.start_depth
						self.caverns[n][#self.caverns[n] + 1] = pos
					end
				end
			end
		end
	end
end
		  
function MAP:checkBounds(x,y,z)
	local pos = processXYZ(x,y,z)
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	if pos.x < 1 then pos.x = 1 end
	if pos.x > mapx-1 then pos.x = mapx-1 end
	if pos.y < 1 then pos.y = 1 end
	if pos.y > mapy-1 then pos.y = mapy-1 end
	if pos.z < 1 then pos.z = 1 end
	if pos.z > mapz-1 then pos.z = mapz-1 end
	return pos
end

function MAP:checkSurface(x,y,z)
	local surface = false
	local pos = processXYZ(x,y,z)
	
	local d1 = dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z).designation[pos.x%16][pos.y%16]
	local d2 = dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-1).designation[pos.x%16][pos.y%16]
	
	if d1.outside and not d2.outside then
		surface = true
	end
	
	return surface
end

function MAP:findPositions(position,posType,radius)
	local edgePos = {}
	local fillPos = {}
	local rx = radius.x or radius[1] or 0
	local ry = radius.y or radius[2] or rx
	local rz = radius.z or radius[3] or rx
	local xpos = pos.x or pos[1]
	local ypos = pos.y or pos[2]
	local zpos = pos.z or pos[3]
	for k = -rz, rz do
		for j = -ry, ry do
			for i = -rx, rx do
				if abs(i) == rx or abs(j) == ry or abs(k) == rz then 
					edgePos[#edgePos+1] = {x=xpos+i, y=ypos+j, z=zpos+k}
					edgePos[#edgePos] = self:checkBounds(edgePos[#edgePos])
				else
					fillPos[#fillPos+1] = {x=xpos+i, y=ypos+j, z=zpos+k}
					fillPos[#fillPos] = self:checkBounds(fillPos[#fillPos])					
				end
			end
		end
	end
	if posType == "EDGES" then
		return edgePos
	elseif posType == "FILL" then
		return fillPos
	end
end

-- If position type and position subtype are declared they must be the first two arguments
function MAP:getPosition(...)
	local pos = {}
	local args = {...}
	local posType = checkTypes(args[1],positionTypes) or "RANDOM"
	local posSubtype = checkTypes(args[1],positionSubtypes) or checkTypes(args[2],positionSubtypes) or "RANDOM"
	local free = false
	local radius = {0,0}
	local unit = nil
	local cavern = 1
	for i,v in ipairs(args) do
		if type(v) == "number" then cavern = v end
		if type(v) == "boolean" then free = v end
		if type(v) == "table" then radius = v end
		if type(v) == "userdata" then unit = v end -- For now only user data is from unit
	end

	local rand = dfhack.random.new()
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	local attempts = 0
	while not pos.z do
		if posType == "RANDOM" then
			pos.x = rand:random(mapx)
			pos.y = rand:random(mapy)
		elseif posType == "CENTER" then
			x = math.floor(mapx/2)
			y = math.floor(mapy/2)
			pos.x = rand:random(x-radius[1],x+radius[1]+1)
			pos.y = rand:random(y-radius[2],y+radius[2]+1)
		elseif posType == "EDGE" then
			roll = rand:random(4)
			if roll == 0 then
				pos.x = 1
				pos.y = rand:random(mapy)
			elseif roll == 1 then
				pos.x = rand:random(mapx)
				pos.y = 1
			elseif roll == 2 then
				pos.x = mapx-1
				pos.y = rand:random(mapy)
			elseif roll == 3  then
				pos.x = rand:random(mapx)
				pos.y = mapy-1
			end
		elseif posType == "UNIT" then
			if not unit then return nil end
			x = unit.pos.x
			y = unit.pos.y
			pos.x = rand:random(x-radius[1],x+radius[1]+1)
			pos.y = rand:random(y-radius[2],y+radius[2]+1)
			pos.z = unit.pos.z
		end
		
		if posSubtype == "RANDOM" then
			if posType ~= "UNIT" then
				pos.z = rand:random(mapz)
			end
		elseif posSubtype == "CAVERN" then
			-- Find a better way to get cavern positions than looping through entire map
		else
			local j = 1
			local outside = true
			while outside do
				block = dfhack.maps.ensureTileBlock(pos.x,pos.y,mapz-j)
				if not block then print(pos.x,pos.y,mapz,j) end
				designation = block.designation[pos.x%16][pos.y%16]
				outside = designation.outside
				j = j + 1
			end
			if posSubtype == "SKY"         then	pos.z = mapz - rand:random(j) end
			if posSubtype == "SURFACE"     then	pos.z = mapz - j              end
			if posSubtype == "UNDERGROUND" then	pos.z = mapz - j - rand:random(mapz-j) end
		end

		if free then
			check = self:checkFree(pos)
			if not check then pos = {} end
		end
		attempts = attempts + 1
		if attempts > 1000 then break end
	end
	
	return pos
end


--===============================================================================================--
--== TILE FUNCTIONS =============================================================================--
--===============================================================================================--
TILE = {}
TILE.__index = TILE
setmetatable(TILE, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function TILE:_init(x,y,z)
	local pos = processXYZ(x,y,z)
	self.pos = pos
	self.x = pos.x
	self.x16 = pos.x%16
	self.y = pos.y
	self.y16 = pos.y%16
	self.z = pos.z
end

function TILE:isFree()
	local free = false
	local block = self:block()
	if not block then return false end
	
	-- Check that the tiletype is "open"
	local tiletype = block.tiletype[self.x16][self.y16]
	local open = false
	for _,tt in pairs(openTileTypes) do
		if string.match(df.tiletype[tiletype],tt) then
			open = true
			break
		end
	end
	if not open then return false end
	
	-- Check that the tile isn't already occupied
	local designation = block.designation[self.x16][self.y16]
	local occupancy   = block.occupancy[self.x16][self.y16]
	if designation.flow_size == 0  and occupancy.building == 0 then	free = true	end

	return free
end

function TILE:block()
	return dfhack.maps.ensureTileBlock(self.x,self.y,self.z)
end

function TILE:designation()
	local block = self:block()
	if not block then 
		return nil
	else
		return block.designation[self.x16][self.y16]
	end
end

function TILE:occupancy()
	local block = self:block()
	if not block then 
		return nil
	else
		return block.occupancy[self.x16][self.y16]
	end
end
