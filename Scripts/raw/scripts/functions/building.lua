usages = {}

usages[#usages+1] = [===[
]===]

--===============================================================================================--
--== BUILDING FUNCTIONS =========================================================================--
--===============================================================================================--
BUILDING = {}
BUILDING.__index = BUILDING
setmetatable(BUILDING, {
	__call = function (cls, ...)
	local self = setmetatable({},cls)
	self:_init(...)
	return self
	end,
})
function BUILDING:_init(building)
	if tonumber(building) then building = df.building.find[tonumber(building)] end
	self.id = building.id
	self.category = ""
	self.type = df.building_type[building:getType()]
	self.subtype = building:getSubtype()
	self.customtype = building:getCustomType()
end

function BUILDING:addItem(item)
	local building = df.building.find(self.id)
	if tonumber(item) then item = df.item.find(item) end
	dfhack.items.moveToBuilding(item,building,2)
	item.flags.in_building = true
end

function BUILDING:changeSubtype(subtype)
	local building = df.building.find(self.id)
	for _,bldgRaw in ipairs(df.global.world.raws.buildings.all) do
		if bldgRaw.code == subtype then
			ctype = bldgRaw.id
			break
		end
	end
	if ctype then
		building.custom_type = ctype
		return true
	end
	return false
end

function BUILDING:getItems()
end

function BUILDING:destroy()
end

function BUILDING:getJobs()
end


function create() end

function destroy () end

function locate() end

function move() end
