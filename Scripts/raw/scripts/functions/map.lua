function getTileMat(x,y,z)
 return ''
end

-- Map Based Functions
usages = {}

--=                     Tile Changing Functions
usages[#usages+1] = [===[

Map Changing Functions
======================

changeInorganic(x,y,z,inorganic,dur)
  Purpose: 
  Calls:   
  Inputs:
  Returns: 

changeTemperature(x,y,z,temperature,dur)
  Purpose: 
  Calls:   
  Inputs:
  Returns: 

]===]

function changeInorganic(x,y,z,inorganic,dur)
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end
 local block=dfhack.maps.ensureTileBlock(pos)
 local current_inorganic = 'clear'
 if inorganic == 'clear' then
  for k = #block.block_events-1,0,-1 do
   if df.block_square_event_mineralst:is_instance(block.block_events[k]) then
    block.block_events:erase(k)
   end
  end
  return
 else
  if tonumber(inorganic) then
   inorganic = tonumber(inorganic)
  else
   inorganic = dfhack.matinfo.find(inorganic).index
  end
  if inorganic then
   ev=df.block_square_event_mineralst:new()
   ev.inorganic_mat=inorganic
   ev.flags.cluster_one=true
   block.block_events:insert("#",ev)
   dfhack.maps.setTileAssignment(ev.tile_bitmask,pos.x%16,pos.y%16,true)
  end
 end
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/map','changeInorganic',{pos.x,pos.y,pos.z,current_inorganic,0}) end
end

function changeTemperature(x,y,z,temperature,dur)
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end
 local block = dfhack.maps.ensureTileBlock(pos)
 local current_temperature = block.temperature_2[pos.x%16][pos.y%16]
 block.temperature_1[pos.x%16][pos.y%16] = temperature
 block.temperature_2[pos.x%16][pos.y%16] = temperature
 block.flags.update_temperature = false
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/map','changeTemperature',{pos.x,pos.y,pos.z,current_temperature,0}) end 
end

function setTileType(tiletype,x,y,z)
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end
 
 x = pos.x%16
 y = pos.y%16
 block = dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z) 
 if not block then return false end
 block.tiletype[x][y] = df.tiletype[tiletype]
 
 return true
end

--=                     Position Functions
usages[#usages+1] = [===[

Position Functions
==================

checkBounds(x,y,z)
  Purpose: Check if the given position is within map bounds
  Calls:   NONE
  Inputs:
           x = pos.x or {x, y, z}
           y = pos.y or nil
           z = pos.z or nil
  Returns: {x, y, z} of nearest valid position

checkFree(x,y,z)
  Purpose: Checks a positions occupancy and tiletype to see if there is anything blocking the tile
  Calls:   NONE
  Inputs:
           x = pos.x or {x, y, z}
           y = pos.y or nil
           z = pos.z or nil
  Returns: True/False depending on if the position is free

checkSurface(x,y,z)
  Purpose: Checks if a position is on the surface (outside but above a not outside)
  Calls:   NONE
  Inputs:
           x = pos.x or {x, y, z}
           y = pos.y or nil
           z = pos.z or nil
  Returns: True/False

getPositions(posType,options)
  Purpose: Get a table of {x, y, z} positions that satisfy the requirements
  Calls:   getEdgesPositions, getFillPositions, getPlanPositions
  Inputs:
           posType = Type of positions (Valid values: Edges, Fill, Plan)
           options = Table of options (target=unit.id, origin=unit.id, radius={x,y,z})
  Returns: Table of positions, # of positions

getPosition(posType,options)
  Purpose: Get an {x, y, z} position that satisfy the requirements
  Calls:   getPositionCenter, getPositionEdge, getPositionCavern, getPositionSurface, getPositionUnderground
           getPositionLocation, getPositionUnit, getPositionSurfaceFree, getPositionSky, getPositionRandom
  Inputs:
           posType = Type of positions (Valid values: Center, Edge, Cavern, Surface, SurfaceFree, Sky, Underground, Location, Unit, Random)
           options = Table of options (target=unit.id, unit=unit.id, location={x,y,z}, radius={x,y,z}, caveNumber=#)
  Returns: {x,y,z} position

]===]

function checkBounds(x,y,z)
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 if pos.x < 1 then pos.x = 1 end
 if pos.x > mapx-1 then pos.x = mapx-1 end
 if pos.y < 1 then pos.y = 1 end
 if pos.y > mapy-1 then pos.y = mapy-1 end
 if pos.z < 1 then pos.z = 1 end
 if pos.z > mapz-1 then pos.z = mapz-1 end
 return pos
end

function checkFree(x,y,z)
 free = false
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end

 x = pos.x%16
 y = pos.y%16
 block = dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z)
 if not block then return false end
 d = block.designation[x][y]
 o = block.occupancy[x][y]
 tt = block.tiletype[x][y]
 tt_bool = false
 if string.match(df.tiletype[tt],'Floor') then tt_bool = true end
 if string.match(df.tiletype[tt],'Pebbles') then tt_bool = true end
 if string.match(df.tiletype[tt],'Shrub') then tt_bool = true end
 if string.match(df.tiletype[tt],'Open') then tt_bool = true end
 if d.flow_size == 0  and o.building == 0 and tt_bool then
  free = true
 end

 return free
end

function checkSurface(x,y,z)
 surface = false
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end

 x = pos.x%16
 y = pos.y%16
 b1 = dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z)
 d1 = b1.designation[x][y]
 b2 = dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-1)
 d2 = b2.designation[x][y]
 
 if d1.outside and not d2.outside then
  surface = true
 end

 return surface
end

function getPositions(posType,options)
 options = options or {}
 target = options.target
 radius = options.radius or {0,0,0}
 posType = posType or 'Error'
 positions = {}
 n = 0
 if not target then return positions, n end
 if posType == 'Edges' then
  positions, n = getEdgesPositions(target,radius)
 elseif posType == 'Fill' then
  positions, n = getFillPositions(target,radius)
 elseif posType == 'Plan' then
  if options.file then
   positions, n = getPlanPositions(options.file,target,options.origin)
  end
 end
 return positions, n
end

function getEdgesPositions(pos,radius)
 local edges = {}
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or rx
 local rz = radius.z or radius[3] or rx
 local xpos = pos.x or pos[1]
 local ypos = pos.y or pos[2]
 local zpos = pos.z or pos[3]
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 edges.xmin = xpos - rx
 edges.xmax = xpos + rx
 edges.ymin = ypos - ry
 edges.ymax = ypos + ry
 edges.zmax = zpos + rz
 edges.zmin = zpos - rz
 if edges.xmin < 1 then edges.xmin = 1 end
 if edges.ymin < 1 then edges.ymin = 1 end
 if edges.zmin < 1 then edges.zmin = 1 end
 if edges.xmax > mapx then edges.xmax = mapx-1 end
 if edges.ymax > mapy then edges.ymax = mapy-1 end
 if edges.zmax > mapz then edges.zmax = mapz-1 end
 return edges, 6
end

function getFillPositions(pos,radius)
 local positions = {}
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xpos = pos.x or pos[1]
 local ypos = pos.y or pos[2]
 local zpos = pos.z or pos[3]
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 n = 0
 for k = 0,rz,1 do
  for j = 0,ry,1 do
   for i = 0,rx,1 do
    n = n+1
    positions[n] = {x = xpos+i, y = ypos+j, z = zpos+k}
    if positions[n].x < 1 then positions[n].x = 1 end
    if positions[n].y < 1 then positions[n].y = 1 end
    if positions[n].z < 1 then positions[n].z = 1 end
    if positions[n].x > mapx then positions[n].x = mapx-1 end
    if positions[n].y > mapy then positions[n].y = mapy-1 end
    if positions[n].z > mapz then positions[n].z = mapz-1 end
   end
  end
 end
 return positions,n
end

function getPlanPositions(file,target,origin)
 local xtar = target.x or target[1]
 local ytar = target.y or target[2]
 local ztar = target.z or target[3]
 local utils = require 'utils'
 local split = utils.split_string
 local iofile = io.open(file,"r")
 local data = iofile:read("*all")
 iofile:close()
 local splitData = split(data,',')
 local x = {}
 local y = {}
 local t = {}
 local xi = 0
 local yi = 1
 local xT = -1
 local yT = -1
 local xS = -1
 local yS = -1
 local xC = -1
 local yC = -1
 local n = 0
 local locations = {}
 for i,v in ipairs(splitData) do
  if split(v,'\n')[1] ~= v then
   xi = 1
   yi = yi + 1
  else
   xi = xi + 1
  end
  if v == 'T' or v == '\nT' then
   xT = xi
   yT = yi
  end
  if v == 'S' or v == '\nS' then
   xS = xi
   yS = yi
  end
  if v == 'C' or v == '\nC' then
   xC = xi
   yC = yi
  end
  if v == 'T' or v == '\nT' or v == '1' or v == '\n1' or v == 'C' or v == '\nC' then
   t[i] = true
  else
   t[i] = false
  end
  x[i] = xi
  y[i] = yi
 end
 if origin then
  xorg = origin.x or origin[1]
  yorg = origin.y or origin[2]
  zorg = origin.z or origin[3]
  xdis = math.abs(xorg-xtar)
  ydis = math.abs(yorg-ytar)
  if ztar ~= zorg then return locations,n end
  if xdis ~= 0 then
   xface = (xorg-xtar)/math.abs(xorg-xtar)
  else
   xface = 0
  end
  if ydis ~= 0 then
   yface = (yorg-ytar)/math.abs(yorg-ytar)
  else
   yface = 0
  end
  if xface == 0 and yface == 0 then
   xface = 0
   yface = 1
  end
  if xT == -1 and xS > 0 then
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
     xO = x[i] - xS
     yO = y[i] - yS
     xpos = -yface*xO+xface*yO
     ypos = xface*xO+yface*yO
     locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
     if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
      if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
       if yO < 0 and xO < 0 then
        locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
       elseif yO < 0 and xO > 0 then
        locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
       elseif yO > 0 and xO > 0 then
        locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
       elseif yO > 0 and xO < 0 then
        locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
       end
      end
     end
    end
   end
  elseif xT > 0 and xS == -1 then
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
     xO = x[i] - xT
     yO = y[i] - yT
     xpos = -yface*xO+xface*yO
     ypos = xface*xO+yface*yO
     locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
     if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
      if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
       if yO < 0 and xO < 0 then
        locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
       elseif yO < 0 and xO > 0 then
        locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
       elseif yO > 0 and xO > 0 then
        locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
       elseif yO > 0 and xO < 0 then
        locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
       end
      end
     end
    end
   end
  elseif xT > 0 and xS > 0 then -- For now just use the same case as above, in the future should add a way to check for both
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
     xO = x[i] - xT
     yO = y[i] - yT
     xpos = -yface*xO+xface*yO
     ypos = xface*xO+yface*yO
     locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
     if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
      if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
       if yO < 0 and xO < 0 then
        locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
       elseif yO < 0 and xO > 0 then
        locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
       elseif yO > 0 and xO > 0 then
        locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
       elseif yO > 0 and xO < 0 then
        locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
       end
      end
     end
    end
   end
  end
 else
  for i,v in ipairs(x) do
   if t[i] then
    n = n + 1
    locations[n] = {x = xtar + x[i] - xT, y = ytar + y[i] - yT, z = ztar}
   end
  end
 end
 return locations,n
end

function getPosition(posType,options)
 options = options or {}
 location = options.location or options.target
 unit = options.unit
 radius = options.radius or { 0, 0, 0}
 posType = posType or 'Random'
 if posType == 'Center' then
  pos = getPositionCenter(radius)
 elseif posType == 'Edge' then
  pos = getPositionEdge()
 elseif posType == 'Cavern' then
  n = options.caveNumber or -1
  pos = getPositionCavern(n)
 elseif posType == 'Surface' then
  pos = getPositionSurface(location)
 elseif posType == 'SurfaceFree' then
  pos = getPositionSurfaceFree()
 elseif posType == 'Sky' then
  pos = getPositionSky(location)
 elseif posType == 'Underground' then
  pos = getPositionUnderground(location)
 elseif posType == 'Location' then
  pos = getPositionLocationRandom(location,radius)
 elseif posType == 'Unit' then
  pos = getPositionUnitRandom(unit,radius)
 else
  pos = getPositionRandom()
 end
 return pos
end

function getPositionCenter(radius)
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 if tonumber(radius) then
  radius = tonumber(radius)
 else
  radius = 0
 end
 x = math.floor(mapx/2)
 y = math.floor(mapy/2)
 pos.x = rand:random(radius) + (rand:random(2)-1)*x
 pos.y = rand:random(radius) + (rand:random(2)-1)*y
 pos.z = rand:random(mapz)
 return pos
end

function getPositionEdge()
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 roll = rand:random(2)
 if roll == 1 then
  pos.x = 2
 else
  pos.x = mapx-1
 end
 roll = rand:random(2)
 if roll == 1 then
  pos.y = 2
 else
  pos.y = mapy-1
 end
 pos.z = rand:random(mapy)
 return pos
end

function getPositionRandom()
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = rand:random(mapx)
 pos.y = rand:random(mapy)
 pos.z = rand:random(mapz)
 return pos
end

function getPositionCavern(number)
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 for i = 1,mapx,1 do
  for j = 1,mapy,1 do
   for k = 1,mapz,1 do
    if dfhack.maps.getTileFlags(i,j,k).subterranean then
     if dfhack.maps.getTileBlock(i,j,k).global_feature >= 0 then
      for l,v in pairs(df.global.world.features.feature_global_idx) do
       if v == dfhack.maps.getTileBlock(i,j,k).global_feature then
        feature = df.global.world.features.map_features[l]
        if feature.start_depth == tonumber(number) or number == -1 then
         if df.tiletype.attrs[dfhack.maps.getTileType(i,j,k)].caption == 'stone floor' then
          n = n+1
          targetList[n] = {x = i, y = j, z = k}
         end
        end
       end
      end
     end
    else
     break
    end
   end
  end
 end
 pos = dfhack.script_environment('functions/misc').permute(targetList)
 return pos[1]
end

function getPositionSurface(location)
 local pos = {}
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1
 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = pos.z - j + 1
 pos = checkBounds(pos)
 return pos
end

function getPositionSurfaceFree()
 free = false
 location = getPositionRandom()
 while not free do
  pos = getPositionSurface(location)
  if checkFree(pos) then
   free = true
  else
   location = getPositionRandom()
  end
 end
 return pos
end

function getPositionSky(location)
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1
 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = rand:random(mapz-j)+j
 pos = checkBounds(pos)
 return pos
end

function getPositionUnderground(location)
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1
 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = rand:random(j-1)
 pos = checkBounds(pos)
 return pos
end

function getPositionLocationRandom(location,radius)
 lx = location.x or location[1]
 ly = location.y or location[2]
 lz = location.z or location[3]
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xmin = lx - rx
 local ymin = ly - ry
 local zmin = lz - rz
 local xmax = lx + rx
 local ymax = ly + ry
 local zmax = lz + rz
 pos.x = rand:random(xmax-xmin) + xmin
 pos.y = rand:random(ymax-ymin) + ymin
 pos.z = rand:random(zmax-zmin) + zmin
 pos = checkBounds(pos)
 return pos
end

function getPositionUnitRandom(unit,radius)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xmin = unit.pos.x - rx
 local ymin = unit.pos.y - ry
 local zmin = unit.pos.z - rz
 local xmax = unit.pos.x + rx
 local ymax = unit.pos.y + ry
 local zmax = unit.pos.z + rz
 pos.x = rand:random(xmax-xmin) + xmin
 pos.y = rand:random(ymax-ymin) + ymin
 pos.z = rand:random(zmax-zmin) + zmin
 pos = checkBounds(pos)
 return pos
end

--=                     Flow and Liquid Functions
usages[#usages+1] = [===[

Flow and Liquid Functions
=========================

spawnFlow(edges,offset,flowType,inorganic,density,static)
  Purpose: Spawn a type of flow in a given shape
  Calls:   NONE
  Inputs:
           edges     = {xmin=#,xmax=#,ymin=#,ymax=#,zmin=#,zmax=#} or {x=#,y=#,z=#} or {x,y,z}, position(s) where flow is spawned
           offset    = {x,y,z} or {x=#,y=#,z=#}, added to the edges value to get tiles where to spawn flow
           flowType  = Type of flow
           inorganic = INORGANIC_TOKEN to use if the flowType supports
           density   = # density of the flow to spawn
           static    = If present will stop the flow from expanding keeping it in the tiles it is spawned in
  Returns: The spawned flow

spawnLiquid(edges,offset,depth,magma,circle,taper)
  Purpose: Spawn water or magma of a given depth in a given shape
  Calls:   NONE
  Inputs:
           edges  = {xmin=#,xmax=#,ymin=#,ymax=#,zmin=#,zmax=#} or {x=#,y=#,z=#} or {x,y,z}, position(s) where flow is spawned
           offset = {x,y,z} or {x=#,y=#,z=#}, added to the edges value to get tiles where to spawn flow
           depth  = # (0-7) of liquid depth to spawn
           magma  = If present will spawn magma, if absent will spawn water
           circle = If present will turn the box of positions into a circle
           taper  = If present, center depth will be the provided depth, linearly decreasing to 0 at the edges
  Returns: NONE

getFlow(pos,flowType)
  Purpose: Get all the flows of the given type at the given position
  Calls:   NONE
  Inputs:
           pos      = {x=#,y=#,z=#} position to check
           flowType = Type of flow (Special value: ALL)
  Returns: Table of flows 

]===]

function spawnFlow(edges,offset,flowType,inorganic,density,static)
 local ox = offset.x or offset[1] or 0
 local oy = offset.y or offset[2] or 0
 local oz = offset.z or offset[3] or 0
 if edges.xmin then
  xmin = edges.xmin + ox
  xmax = edges.xmax + ox
  ymin = edges.ymin + oy
  ymax = edges.ymax + oy
  zmin = edges.zmin + oz
  zmax = edges.zmax + oz
 else
  xmin = edges.x + ox or edges[1] + ox
  ymin = edges.y + oy or edges[2] + oy
  zmin = edges.z + oz or edges[3] + oz
  xmax = edges.x + ox or edges[1] + ox
  ymax = edges.y + oy or edges[2] + oy
  zmax = edges.z + oz or edges[3] + oz
 end
 for x = xmin, xmax, 1 do
  for y = ymin, ymax, 1 do
   for z = zmin, zmax, 1 do
    block = dfhack.maps.ensureTileBlock(x,y,z)
    dsgn = block.designation[x%16][y%16]
    if not dsgn.hidden then
     flow = dfhack.maps.spawnFlow({x=x,y=y,z=z},flowType,0,inorganic,density)
     if static then flow.expanding = false end
    end
   end
  end
 end
 return flow
end

function spawnLiquid(edges,offset,depth,magma,circle,taper)
 local ox = offset.x or offset[1] or 0
 local oy = offset.y or offset[2] or 0
 local oz = offset.z or offset[3] or 0
 if edges.xmin then
  xmin = edges.xmin + ox
  xmax = edges.xmax + ox
  ymin = edges.ymin + oy
  ymax = edges.ymax + oy
  zmin = edges.zmin + oz
  zmax = edges.zmax + oz
 else
  xmin = edges.x + ox or edges[1] + ox
  ymin = edges.y + oy or edges[2] + oy
  zmin = edges.z + oz or edges[3] + oz
  xmax = edges.x + ox or edges[1] + ox
  ymax = edges.y + oy or edges[2] + oy
  zmax = edges.z + oz or edges[3] + oz
 end
 for x = xmin, xmax, 1 do
  for y = ymin, ymax, 1 do
   for z = zmin, zmax, 1 do
    if circle then
     if (math.abs(x-(xmax+xmin)/2)+math.abs(y-(ymax+ymin)/2)+math.abs(z-(zmax+zmin)/2)) <= math.sqrt((xmax-xmin)^2/4+(ymax-ymin)^2/4+(zmax-zmin)^2/4) then
      block = dfhack.maps.ensureTileBlock(x,y,z)
      dsgn = block.designation[x%16][y%16]
      if not dsgn.hidden then
       if taper then
        size = math.floor(depth-((xmax-xmin)*math.abs((xmax+xmin)/2-x)+(ymax-ymin)*math.abs((ymax+ymin)/2-y)+(zmax-zmin)*math.abs((zmax+zmin)/2-z))/depth)
        if size < 0 then size = 0 end
       else
        size = depth
       end
       dsgn.flow_size = size
       if magma then dsgn.liquid_type = true end
       flow = block.liquid_flow[x%16][y%16]
       flow.temp_flow_timer = 10
       flow.unk_1 = 10
       block.flags.update_liquid = true
       block.flags.update_liquid_twice = true
      end
     end
    else
     block = dfhack.maps.ensureTileBlock(x,y,z)
     dsgn = block.designation[x%16][y%16]
     if not dsgn.hidden then
      if taper then
       size = math.floor(depth-((xmax-xmin)*math.abs((xmax+xmin)/2-x)+(ymax-ymin)*math.abs((ymax+ymin)/2-y)+(zmax-zmin)*math.abs((zmax+zmin)/2-z))/depth)
       if size < 0 then size = 0 end
      else
       size = depth
      end
      flow = block.liquid_flow[x%16][y%16]
      flow.temp_flow_timer = 10
      flow.unk_1 = 10
      dsgn.flow_size = size
      if magma then dsgn.liquid_type = true end
      block.flags.update_liquid = true
      block.flags.update_liquid_twice = true
     end
    end
   end
  end
 end
end

function flowSource(n)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return end
 flowTable = persistTable.GlobalTable.roses.FlowTable

 n = tostring(n)
 flow = flowTable[n]
 if flow then
  x = tonumber(flow.x)
  y = tonumber(flow.y)
  z = tonumber(flow.z)
  density = tonumber(flow.Density)
  inorganic = tonumber(flow.Inorganic)
  flowType = tonumber(flow.FlowType)
  check = tonumber(flow.Check)
  pos = xyz2pos(x,y,z)
  flows = getFlow(pos,flowType)
  if #flows == 0 then
   dfhack.maps.spawnFlow(pos,flowType,0,inorganic,density)
  else
   flows[1].density = density
  end
  dfhack.timeout(check,'ticks',
                 function ()
                  dfhack.script_environment('functions/map').flowSource(n)
                 end
                )
 end
end

function flowSink(n)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return end
 flowTable = persistTable.GlobalTable.roses.FlowTable

 n = tostring(n)
 flow = flowTable[n]
 if flow then
  x = tonumber(flow.x)
  y = tonumber(flow.y)
  z = tonumber(flow.z)
  density = tonumber(flow.Density)
  inorganic = tonumber(flow.Inorganic)
  flowType = tonumber(flow.FlowType)
  check = tonumber(flow.Check)
  pos = xyz2pos(x,y,z)
  for _,flow in pairs(getFlow(pos,flowType)) do
   flow.density = density
  end
  dfhack.timeout(check,'ticks',
                 function ()
                  dfhack.script_environment('functions/map').flowSink(n)
                 end
                )
 end
end

function liquidSource(n)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return end
 liquidTable = persistTable.GlobalTable.roses.LiquidTable

 n = tostring(n)
 liquid = liquidTable[n]
 if liquid then
  x = tonumber(liquid.x)
  y = tonumber(liquid.y)
  z = tonumber(liquid.z)
  depth = tonumber(liquid.Depth)
  magma = liquid.Magma
  check = tonumber(liquid.Check)
  block = dfhack.maps.ensureTileBlock(x,y,z)
  dsgn = block.designation[x%16][y%16]
  flow = block.liquid_flow[x%16][y%16]
  flow.temp_flow_timer = 10
  flow.unk_1 = 10
  if dsgn.flow_size < depth then dsgn.flow_size = depth end
  if magma then dsgn.liquid_type = true end
  block.flags.update_liquid = true
  block.flags.update_liquid_twice = true
  dfhack.timeout(check,'ticks',
                 function ()
                  dfhack.script_environment('functions/map').liquidSource(n)
                 end
                )
 end                
end

function liquidSink(n)
 persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then return end
 liquidTable = persistTable.GlobalTable.roses.LiquidTable

 n = tostring(n)
 liquid = liquidTable[n]
 if liquid then
  x = tonumber(liquid.x)
  y = tonumber(liquid.y)
  z = tonumber(liquid.z)
  depth = tonumber(liquid.Depth)
  magma = liquid.Magma
  check = tonumber(liquid.Check)
  block = dfhack.maps.ensureTileBlock(x,y,z)
  dsgn = block.designation[x%16][y%16]
  flow = block.liquid_flow[x%16][y%16]
  flow.temp_flow_timer = 10
  flow.unk_1 = 10
  if dsgn.flow_size > depth then dsgn.flow_size = depth end
  if magma then dsgn.liquid_type = true end
  block.flags.update_liquid = true
  block.flags.update_liquid_twice = true
  dfhack.timeout(check,'ticks',
                 function ()
                  dfhack.script_environment('functions/map').liquidSink(n)
                 end
                )
 end
end

function getFlow(pos,flowType)
 flowType = flowType or 'ALL'
 flowType = string.upper(flowType)
 block = dfhack.maps.ensureTileBlock(pos)
 flows = block.flows
 flowOut = {}
 for i,flow in pairs(flows) do
  if flow.pos.x == pos.x and flow.pos.y == pos.y and flow.pos.z == pos.z then
   if flowType == 'ALL' or flowType == string.upper(df.flow_type[flow.type]) then
    flowOut[#flowOut+1] = flow
   end
  end
 end
 return flowOut
end

--=                     Plant Functions
usages[#usages+1] = [===[

Plant Functions
===============

getTree(pos,array)
  Purpose: Get the tree ID and the tree struct of the tree type at the given position
  Calls:   NONE
  Inputs:
           pos   = {x=#,y=#,z=#}
           array = df.global.world.plants.all or $.tree_dry or $.tree_wet
  Returns: Tree ID, Tree Struct

getTreePositions(tree)
  Purpose: Get the tile positions for every part of the tree
  Calls:   NONE
  Inputs:
           tree = Tree struct
  Returns: Table of positions
  
getShrub(pos,array)
  Purpose: Get the plant ID and the plant struct of the plant type at the given position
  Calls:   NONE
  Inputs:
           pos   = {x=#,y=#,z=#}
           array = df.global.world.plants.all or $.shrub_dry or $.shrub_wet
  Returns: Plant ID, Plant Struct

removeTree(pos)
  Purpose: Remove the tree and all connected parts at the given postion
  Calls:   getTree, getTreePositions
  Inputs:
           pos   = {x=#,y=#,z=#}
  Returns: NONE

removeShrub(pos)
  Purpose: Remove the plant at the given postion
  Calls:   getShrub, getTree
  Inputs:
           pos   = {x=#,y=#,z=#}
  Returns: NONE

]===]

function getTileFeature(objType,options)
 options = options or {}
 if not options.position then return end
 if objType == 'Tree' then
  i, struct = getTree(position,options.array)
 elseif objType == 'Shrub' then
  i, struct = getTree(position,options.array)
 end
 return i, struct
end

function getTree(pos,array)
 if not array then array = df.global.world.plants.all end
 for i,tree in pairs(array) do
  if tree.tree_info ~= nil then
   local x1 = tree.pos.x - math.floor(tree.tree_info.dim_x / 2)
   local x2 = tree.pos.x + math.floor(tree.tree_info.dim_x / 2)
   local y1 = tree.pos.y - math.floor(tree.tree_info.dim_y / 2)
   local y2 = tree.pos.y + math.floor(tree.tree_info.dim_y / 2)
   local z1 = tree.pos.z
   local z2 = tree.pos.z + tree.tree_info.body_height
   if ((pos.x >= x1 and pos.x <= x2) and (pos.y >= y1 and pos.y <= y2) and (pos.z >= z1 and pos.z <= z2)) then
    body = tree.tree_info.body[pos.z - tree.pos.z]:_displace((pos.y - y1) * tree.tree_info.dim_x + (pos.x - x1))
    if not body.blocked then
     if body.trunk or body.thick_branches_1 or body.thick_branches_2 or body.thick_branches_3 or body.thick_branches_4 or body.branches or body.twigs then
      return i,tree
     end
    end
   end
  end
 end
 return nil
end

function getShrub(pos,array)
 if not array then array = df.global.world.plants.all end
 for i,shrub in pairs(array) do
  if not shrub.tree_info then
   if pos.x == shrub.pos.x and pos.y == shrub.pos.y and pos.z == shrub.pos.z then
    return i,shrub
   end
  end
 end
end

function removeTree(pos)
 --erase from plants.all (but first get the tree positions)
 nAll,tree = getTree(pos,df.global.world.plants.all)
 positions = getTreePositions(tree)
 base = tree.pos.z
 --erase from plants.tree_dry
 nDry = getTree(pos,df.global.world.plants.tree_dry)
 --erase from plants.tree_wet
 nWet = getTree(pos,df.global.world.plants.tree_wet)
 --erase from map_block_columns
 x_column = math.floor(pos.x/16)
 y_column = math.floor(pos.y/16)
 --need to get 1st of 9 map block columns for plant information
 map_block_column = df.global.world.map.column_index[x_column-x_column%3][y_column-y_column%3]
 nBlock = getTree(pos,map_block_column.plants)
 
 if nAll   then df.global.world.plants.all:erase(nAll)      end
 if nDry   then df.global.world.plants.tree_dry:erase(nDry) end
 if nWet   then df.global.world.plants.tree_wet:erase(nWet) end
 if nBlock then map_block_column.plants:erase(nBlock)       end
 
 --Now change tiletypes for tree positions
 for _,position in ipairs(positions) do
  block = dfhack.maps.ensureTileBlock(position)
  if position.z == base then
   block.tiletype[position.x%16][position.y%16] = 350
  else
   block.tiletype[position.x%16][position.y%16] = df.tiletype['OpenSpace']
  end
  block.designation[position.x%16][position.y%16].outside = true
 end
end

function removeShrub(pos)
 --erase from plants.all
 n = getShrub(pos,df.global.world.plants.all)
 if n then df.global.world.plants.all:erase(n) end
 --erase from plants.shrub_dry
 n = getShrub(pos,df.global.world.plants.shrub_dry)
 if n then df.global.world.plants.shrub_dry:erase(n) end
 --erase from plants.tree_wet
 n = getShrub(pos,df.global.world.plants.shrub_wet)
 if n then df.global.world.plants.shrub_wet:erase(n) end
 --erase from map_block_columns
 x_column = math.floor(pos.x/16)
 y_column = math.floor(pos.y/16)
 --need to get 1st of 9 map block columns for plant information
 map_block_column = df.global.world.map.column_index[x_column-x_column%3][y_column-y_column%3]
 n = getTree(pos,map_block_column.plants)
 if n then map_block_column:erase(n) end
end

function getTreePositions(tree)
 n = 0
 nTrunk = 0
 nTwigs = 0
 nBranches = 0
 nTBranches = 0
 positions = {}
 positionsTrunk = {}
 positionsTwigs = {}
 positionsBranches = {}
 positionsTBranches = {}
 local x1 = tree.pos.x - math.floor(tree.tree_info.dim_x / 2)
 local x2 = tree.pos.x + math.floor(tree.tree_info.dim_x / 2)
 local y1 = tree.pos.y - math.floor(tree.tree_info.dim_y / 2)
 local y2 = tree.pos.y + math.floor(tree.tree_info.dim_y / 2)
 local z1 = tree.pos.z
 local z2 = tree.pos.z + math.floor(tree.tree_info.body_height / 2)
 for x = x1,x2 do
  for y = y1,y2 do
   for z = z1,z2 do
    pos = {x=x,y=y,z=z}
    body = tree.tree_info.body[pos.z-z1]:_displace((pos.y - y1) * tree.tree_info.dim_x + (pos.x - x1))
    if body.trunk then
     n = n + 1
     positions[n] = pos
     nTrunk = nTrunk + 1
     positionsTrunk[nTrunk] = pos
    elseif body.twigs then
     n = n + 1
     positions[n] = pos
     nTwigs = nTwigs + 1
     positionsTwigs[nTwigs] = pos
    elseif body.branches then
     n = n + 1
     positions[n] = pos
     nBranches = nBranches + 1
     positionsBranches[nBranches] = pos
    elseif body.thick_branches_1 or body.thick_branches_2 or body.thick_branches_3 or body.thick_branches_4 then
     n = n + 1
     positions[n] = pos
     nTBranches = nTBranches + 1
     positionsTBranches[nTBranches] = pos
    end
   end
  end
 end
 return positions,positionsTrunk,positionsTBranches,positionsBranches,positionsTwigs
end


--=                     Miscellanious Functions
usages[#usages+1] = [===[

Miscellanious Functions
=======================

findLocation(search)
  Purpose: Find a position on the map that satisfies the search criteria
  Calls:   NONE
  Inputs:
           search = Search table (e.g. { RANDOM, UNDERGROUND, CAVERN, 2 })
  Returns: Table of all positions that meet search criteria

]===]

function findLocation(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local x_map, y_map, z_map = dfhack.maps.getTileSize()
 x_map = x_map - 1
 y_map = y_map - 1
 z_map = z_map - 1
 local targetList = {}
 local target = nil
 local found = false
 local n = 1
 local rando = dfhack.random.new()
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   n = 1
   targetList = {{x = rando:random(x_map-1)+1,y = rando:random(y_map-1)+1,z = rando:random(z_map-1)+1}}
  elseif secondary == 'SURFACE' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionSurface(targetList[n])
   elseif tertiary == 'EDGE' then
    targetList[n] = getPositionEdge()
    targetList[n] = getPositionSurface(targetList[n])
   elseif tertiary == 'CENTER' then
    targetList[n] = getPositionCenter(quaternary)
    targetList[n] = getPositionSurface(targetList[n])
   end
  elseif secondary == 'UNDERGROUND' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionUnderground(targetList[n])
   elseif tertiary == 'CAVERN' then
    targetList[n] = getPositionCavern(quaternary)
   end
  elseif secondary == 'SKY' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionSky(targetList[n])
   elseif tertiary == 'EDGE' then
    targetList[n] = getPositionEdge()
    targetList[n] = getPositionSky(targetList[n])
   elseif tertiary == 'CENTER' then
    targetList[n] = getPositionCenter(quaternary)
    targetList[n] = getPositionSky(targetList[n])
   end
  end
 end
 target = targetList[1]
 return {target}
end

