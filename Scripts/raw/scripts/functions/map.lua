--@ module=true

info = {}
info["MAP"]  = [===[ TODO ]===]
info["FLOW"] = [===[ TODO ]===]

flow_types = {
	MIASMA = df.flow_type.Miasma,
	STEAM = df.flow_type.Steam,
	MIST = df.flow_type.Mist,
	MATERIALDUST = df.flow_type.MaterialDust,
	MAGMAMIST = df.flow_type.MagmaMist,
	SMOKE = df.flow_type.Smoke,
	DRAGONFIRE = df.flow_type.Dragonfire,
	FIRE = df.flow_type.Fire,
	WEB = df.flow_type.Web,
	MATERIALGAS = df.flow_type.MaterialGas,
	MATERIALVAPOR = df.flow_type.MaterialVapor,
	OCEANWAVE = df.flow_type.OceanWave,
	SEAFOAM = df.flow_type.SeaFoam,
	ITEMCLOUD = df.flow_type.ItemCloud,
}

local openTileTypes = {"Floor","Pebbles","Shrub","Open"}
local positionTypes = {"CENTER","EDGE","UNIT"}
local positionSubtypes = {"CAVERN","SKY","SURFACE","UNDERGROUND"}
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
local function isFree(x,y,z)
	local pos = processXYZ(x,y,z)
	local free = false
	local tiletype = dfhack.maps.getTileType(pos)
	local designation, occupancy = dfhack.maps.getTileFlags(pos)
	if not tiletype then return false end
	
	-- Check that the tiletype is "open"
	local open = false
	for _,tt in pairs(openTileTypes) do
		if string.match(df.tiletype[tiletype],tt) then
			open = true
			break
		end
	end
	if not open then return false end
	
	-- Check that the tile isn't already occupied
	if designation.flow_size == 0  and occupancy.building == 0 then	free = true	end

	return free
end
local function checkBounds(x,y,z)
	local valid = true
	local pos = processXYZ(x,y,z)
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	if pos.x < 1 or pos.x > mapx-1 then valid = false end
	if pos.y < 1 or pos.y > mapy-1 then valid = false end
	if pos.z < 1 or pos.z > mapz-1 then valid = false end
	return valid
end
local function checkSurface(x,y,z)
	local surface = false
	local pos = processXYZ(x,y,z)
	
	local d1, _ = dfhack.maps.getTileFlags(pos.x,pos.y,pos.z)
	local d2, _ = dfhack.maps.getTileFlags(pos.x,pos.y,pos.z-1)
	
	if d1.outside and not d2.outside then
		surface = true
	end
	
	return surface
end
local function samePosition(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

--===============================================================================================--
--== MAP CLASSES ================================================================================--
--===============================================================================================--
MAP = defclass(MAP)    -- references <df.global.world.map>
FLOW = defclass(FLOW)  -- references <flow_info>

--===============================================================================================--
--== MAP FUNCTIONS ==============================================================================--
--===============================================================================================--
function MAP:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(MAP,key) then return rawget(MAP,key) end
	return self._map[key]
end
function MAP:init(initialize)
	--??
	self._map = df.global.world.map
	if initialize == true then
		self:_update()
	end
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
	for i = 2, mapx-1 do
		for j = 2, mapy-1 do
			outside = false
			for k = 2, mapz-1 do
				local pos = {x=i,y=j,z=k}
				previousOutside = outside
				block = dfhack.maps.ensureTileBlock(i,j,k)
				designation, _ = dfhack.maps.getTileFlags(i,j,k)
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

function MAP:createFlow(pos,flowType,density,inorganic,static)
	local x = pos.x or pos[1]
	local y = pos.y or pos[2]
	local z = pos.z or pos[3]
	flow = dfhack.maps.spawnFlow({x=x,y=y,z=z},flowType,0,inorganic,density)
	if static then flow.expanding = false end
end

function MAP:createLiquid(pos,depth,magma)
	local x = pos.x or pos[1]
	local y = pos.y or pos[2]
	local z = pos.z or pos[3]
	depth = depth or 7
	block = dfhack.maps.ensureTileBlock(x,y,z)
	dsgn = block.designation[x%16][y%16]
	dsgn.flow_size = math.min(depth,7)
	dsgn.liquid_type = magma or false
	flow = block.liquid_flow[x%16][y%16]
	flow.temp_flow_timer = 10
	flow.unk_1 = 10
	block.flags.update_liquid = true
	block.flags.update_liquid_twice = true
end

function MAP:getPlanPositions(pos,plan,origin)
	local xtar = pos.x or pos[1]
	local ytar = pos.y or pos[2]
	local ztar = pos.z or pos[3]
	local n = 0
	local locations = {}
	x, y, t, xT, yT, xS, yS = reqscript("functions/io").readPlan(plan)
	
	-- Determine center of plan
	if xT == -1 and xS == -1 then return locations, n end -- Has to have a source or target declared
    if xT ~= -1 and xS ~= -1 then return locations, n end -- For now can't accept a source and a target, will change later -ME
	if xT == -1 and xS ~= -1 then
		xCenter = xS
		yCenter = yS
	elseif xT ~= -1 and xS == -1 then
		xCenter = xT
		yCenter = yT
	end
		
	-- Get central in game position points, defaults to using the target position.
	-- If an origin position is also supplied will use that instead and determine the 
	-- relative facing between the target and the origin.
	local xPoint = xtar
	local yPoint = ytar
	local zPoint = ztar
	local xFace = 0
	local yFace = 0
	local diagonal = false
	if origin then
		if tonumber(origin) then origin = df.unit.find(tonumber(origin)).pos end
		xorg = origin.x or origin[1]
		yorg = origin.y or origin[2]
		zorg = origin.z or origin[3]
		if (xorg-xtar) ~= 0 then xFace = (xorg-xtar)/math.abs(xorg-xtar) end
		if (yorg-ytar) ~= 0 then yFace = (yorg-ytar)/math.abs(yorg-ytar) end
		xPoint = xorg
		yPoint = yorg
		zPoint = zorg
	end
	if xFace == 0 and yFace == 0 then yFace = 1 end -- Should actually be random, but for now just pick a direction -ME
	if xFace ~= 0 and yFace ~= 0 then diagonal = true end -- We had extra locations for diagonal directions
	
	-- Get in-game positions by computing the facing position offsets
	for i,tar in pairs(t) do
		if tar then
			n = n + 1
			xO = x[i] - xCenter
			yO = y[i] - yCenter
			xRot = -yFace*xO + xFace*yO -- -yFace because of the DF coordinate system
			yRot = xFace*xO + yFace*yO
			locations[n] = {x = xPoint + xRot, y = yPoint + yRot, z = zPoint}
			if diagonal and (xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0) then
				-- If origin is diagonal to target and plan position is an off diagonal position
				-- an extra point needs to be added to handle the gridded DF map
				n = n + 1
				xSign = xO/abs(xO)
				ySign = yO/abs(yO)
				Fx = xFace*xFace*(xFace - xSign*ySign*yFace)/2
				Fy = xFace*yFace*(xFace + xSign*ySign*yFace)/2
				locations[n] = {x = xPoint + xRot - ySign*Fx, y = yPoint + yRot - ySign*Fy, z = zPoint}
			end
		end
	end
	return locations
end

function MAP:getEdgePositions(pos,radius,shape)
	local edgePos = {}
	local shape = shape or "SQUARE"
	local rx = radius.x or radius[1] or 0
	local ry = radius.y or radius[2] or rx
	local rz = radius.z or radius[3] or rx
	local xpos = pos.x or pos[1]
	local ypos = pos.y or pos[2]
	local zpos = pos.z or pos[3]
	if shape == "SQUARE" then -- Inefficient, but for small radius it works fine
		for j = -ry, ry do
			for i = -rx, rx do
				if abs(i) == rx or abs(j) == ry then 
					if checkBounds(xpos+i,ypos+j,zpos) then edgePos[#fillPos+1] = {x=xpos+i, y=ypos+j, z=zpos} end					
				end
			end
		end
	elseif shape == "CIRCLE" then
		-- Doubt this actually works given the gridded nature of DF
		-- will need to update later -ME
		for j = -ry, ry do
			for i = -rx, rx do
				if i*i/rx*rx + j*j/ry*ry == 1 then
					if checkBounds(xpos+i,ypos+j,zpos) then edgePos[#fillPos+1] = {x=xpos+i, y=ypos+j, z=zpos} end					
				end
			end
		end
	elseif shape == "CUBE" then
		-- Add later if desired -ME
	elseif shape == "SPHERE" then
		-- Add later if desired -ME
	end
	return edgePos
end

function MAP:getFillPositions(pos,radius,shape)
	local fillPos = {}
	local shape = shape or "SQUARE"
	local rx = radius.x or radius[1] or 0
	local ry = radius.y or radius[2] or rx
	local rz = radius.z or radius[3] or rx
	local xpos = pos.x or pos[1]
	local ypos = pos.y or pos[2]
	local zpos = pos.z or pos[3]
	if shape == "SQUARE" then
		for j = -ry, ry do
			for i = -rx, rx do
				--if math.abs(i) ~= rx and math.abs(j) ~= ry then
					if checkBounds(xpos+i,ypos+j,zpos) then fillPos[#fillPos+1] = {x=xpos+i, y=ypos+j, z=zpos} end					
				--end
			end
		end
	elseif shape == "CIRCLE" then
		for j = -ry, ry do
			for i = -rx, rx do
				if math.abs(i) ~= rx and math.abs(j) ~= ry and i*i/rx*rx + j*j/ry*ry <= 1 then 
					if checkBounds(xpos+i,ypos+j,zpos) then fillPos[#fillPos+1] = {x=xpos+i, y=ypos+j, z=zpos} end					
				end
			end
		end
	elseif shape == "CUBE" then
		-- Add later if desired -ME
	elseif shape == "SPHERE" then
		-- Add later if desired -ME
	end
	return fillPos
end

function MAP:getCavernPosition(posType,posSubtype)
	local pos = {}
	local rand = dfhack.random.new()
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	local attempts = 0
	
	return pos
end

function MAP:getSkyPosition(posType,posSubtype)
	local pos = {}
	local rand = dfhack.random.new()
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	local attempts = 0
	
	return pos
end

function MAP:getSurfacePosition(posType,posSubtype)
	local pos = {}
	local rand = dfhack.random.new()
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	local attempts = 0
	
	return pos
end

function MAP:getUndergroundPosition(posType,posSubtype)
	local pos = {}
	local rand = dfhack.random.new()
	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	local attempts = 0
	
	return pos
end

-- Generic combination of the above getXPosition() functions
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
			check = isFree(pos)
			if not check then pos = {} end
		end
		attempts = attempts + 1
		if attempts > 1000 then break end
	end

	return pos
end

function MAP:getFlow(pos)
	local block = dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z)
	local flowOut
	for i, flow in pairs(block.flows) do
		if samePosition(flow.pos, pos) then
			flowOut = FLOW(flow)
			break
		end
	end
	return flowOut
end

function MAP:getDepth(pos)
	local x = pos.x or pos[1]
	local y = pos.y or pos[2]
	local z = pos.z or pos[3]
	return dfhack.maps.ensureTileBlock(x,y,z).designation[x%16][y%16].flow_size
end
--===============================================================================================--
--== MAP FLOW FUNCTIONS =========================================================================--
--===============================================================================================--
function FLOW:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(FLOW,key) then return rawget(FLOW,key) end
	return self._flow[key]
end
function FLOW:init(flow)
	self.Type = string.upper(df.flow_type[flow.type])
	self.Static = not flow.expanding
	if flow.mat_type >= 0 then
		self.Inorganic = dfhack.matinfo.getToken(flow.mat_type,flow.mat_index)
	else
		self.Inorganic = "NA"
	end
	self._flow = flow
end

function FLOW:getDensity()
	return self.density
end
--===============================================================================================--
--== MAP TILE FUNCTIONS =========================================================================--
--===============================================================================================--

--===============================================================================================--
--===============================================================================================--
--===============================================================================================--