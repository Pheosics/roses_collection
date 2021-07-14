--gui/journal.lua
local utils = require "utils"
local split = utils.split_string
local gui = require "gui"

local usage = [====[
]====]

validArgs = utils.invert({
    "help",
	"args",
})

mainViewDetails = {
	name = "Main",
	num_cols = 5,
	num_rows = 3, 
	widths = {
		{25,25,25,25,25},
		{25,25,25,25,25},
		{25,25,25,25,25}},
	heights = {
		{10,10,10,10,10},
		{20,20,20,20,20},
		{15,15,15,40,15}},
	fill = {
		"Arts",       "Buildings", "Creatures", "Entities",  nil,
		"Inorganics", "Items",     "Organics",  "Plants",    nil,
		"Products",   "Reactions", "Religions", "Syndromes", nil},
	functions = { --  {Function Name, Function Inputs, Function Key}
		Buildings   = {"viewChange",  "buildingView",  "B"}
--		Creatures   = {function () self:viewChange("creatureView")  end, "C"},
--		Entities    = {function () self:viewChange("entityView")    end, "E"},
--		Inorganics  = {function () self:viewChange("inorganicView") end, "n"},
--		Items       = {function () self:viewChange("itemView")      end, "I"},
--		Organics    = {function () self:viewChange("organicView")   end, "O"},
--		Reactions   = {function () self:viewChange("reactionView")  end, "R"},
--		Plants      = {function () self:viewChange("plantView")     end, "P"},
--		Products    = {function () self:viewChange("productView")   end, "r"},
--		Religions   = {function () self:viewChange("religionView")  end, "g"},
--		Syndromes   = {function () self:viewChange("syndromeView")  end, "S"},
--		Arts        = {function () self:viewChange("artView")       end, "A"},
--		ClassSystem = {function () self:viewChange("classView")     end, "l"}
	}
}

subViewDetails = {}
--subViewDetails["religionView"] = {
--	name = "Gods and Forces", -- world.belief_systems, world.history.figures
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{40,40,99, 0},
--		{40,40,50,50},
--		{40,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	fill = {
--		"ReligionTypeList", "on_select:1", "on_select:2", nil,
--		nil,                nil,           "groupA",      "groupC",
--		nil,                nil,           "groupB",      "groupD"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"ReligionList", "ReligionDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "groupA", "groupB", "groupC", "groupD"}},
--	startFilter = "ALL", 
--	filterFlags = {"ALL"}
--}
--subViewDetails["syndromeView"] = {
--	name = "Syndromes and Interactions", -- raws.syndromes, raws.interactions
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{40,40,99, 0},
--		{40,40,50,50},
--		{40,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	fill = {
--		"SyndromeTypeList", "on_select:1", "on_select:2", nil,
--		nil,                nil,           "groupA",      "groupC",
--		nil,                nil,           "groupB",      "groupD"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"SyndromeList", "SyndromeDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "groupA", "groupB", "groupC", "groupD"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL"}
--}
--subViewDetails["artView"] = {
--	name = "Art Forms", -- world.poetic_forms, world.musical_forms, world.dance_forms, world.scales, world.rythms, world.written_contents?
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{15,40,99, 0},
--		{15,40,50,50},
--		{15,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	fill = {
--		"ArtTypeList", "on_select:1", "on_select:2", nil,
--		nil,           nil,           "groupA",      "groupC",
--		nil,           nil,           "groupB",      "groupD"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"ArtList", "ArtDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "groupA", "groupB", "groupC", "groupD"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL"}
--}
--subViewDetails["productView"] = {
--	name = "Products",
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{15,40,99, 0},
--		{15,40,50,50},
--		{15,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	fill = {
--		"ProductTypeList", "on_select:1", "on_select:2",     nil,
--		nil,               nil,           "environmentInfo", "materialInfo1",
--		nil,               nil,           "useInfo",         "materialInfo2"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"ProductList", "ProductDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "environmentInfo", "useInfo", "materialInfo1", "materialInfo2"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL"}
--}
--subViewDetails["creatureView"] = {
--	name = "Creatures",
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{40,40,80, 0},
--		{40,40,40,40},
--		{40,40,40,40}},
--	heights = {
--		{40,40,10,10},
--		{ 0, 0,20,20},
--		{ 0, 0,20,20}},
--	functions = {
--		materialInfo = {"viewSwitch", "organicView", "M"}},
--	fill = {
--		"CreatureList", "on_select:1", "on_select:2", nil,
--		nil,            nil,           "popInfo",     "baseInfo",
--		nil,            nil,           "flagInfo",    "materialInfo"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"CasteList", "CreatureDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "popInfo", "baseInfo", "flagInfo", "materialInfo"}},
--	startFilter = "ALL", 
--	filterFlags = {"ALL", "GOOD", "EVIL", "SAVAGE", "CASTE_MEGABEAST"}, -- Filters based on creature_raw.flags
--	filterKeys = {"CUSTOM_SHIFT_A", "CUSTOM_SHIFT_G", "CUSTOM_SHIFT_E", "CUSTOM_SHIFT_S", "CUSTOM_SHIFT_M"}
--}
subViewDetails["buildingView"] = {
	name = "Buildings",
	levels   = 2,
	num_cols = 4,
	num_rows = 3,
	widths = {
		{15,40,99, 0},
		{15,40,50,50},
		{15,40,50,50}},
	heights = {
		{40,40, 5, 5},
		{ 0, 0,25,25},
		{ 0, 0,25,25}},
	functions = {
		bldgReactions = {"viewSwitch", "reactionView", "R"}},
	fill = {
		"BuildingTypeList", "on_select:1", "on_select:2",   nil,
		nil,                nil,           "bldgInfo",      "buildItems",
		nil,                nil,           "bldgReactions", "bldgDiagram"},
	on_fills = {
		"on_select:1", "on_select:2", "none", "none",
		"none",        "none",        "none", "none",
		"none",        "none",        "none", "none"},
	on_select = {"BuildingList", "BuildingDetails"},
	on_groups = {
		["on_select:2"] = {"on_select:2", "bldgInfo", "buildItems", "bldgReactions", "bldgDiagram"}},
	startFilter = "ALL",
	filterFlags = {"ALL"}
}
--subViewDetails["itemView"] = {
--	name = "Items",
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{15,40,99, 0},
--		{15,40,50,50},
--		{15,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	fill = {
--		"ItemTypeList", "on_select:1", "on_select:2", nil,
--		nil,            nil,           "baseInfo",    "typeInfo",
--		nil,            nil,           "flagInfo",    "enhancedInfo"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"ItemList", "ItemDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "baseInfo", "typeInfo", "flagInfo", "enhancedInfo"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL"}
--}
--subViewDetails["reactionView"] = {
--	name = "Reactions",
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{20,30,80, 0},
--		{20,30,40,60},
--		{20,30,40,60}},
--	heights = {
--		{40,40,10,10},
--		{ 0, 0,20,20},
--		{ 0, 0,20,20}},
--	fill = {
--		"ReactionTypeList", "on_select:1", "on_select:2",   nil,
--		nil,                nil,           "baseInfo",      "reagentInfo",
--		nil,                nil,           "enhancedInfo",  "productInfo"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"ReactionList", "ReactionDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "baseInfo", "reagentInfo", "productInfo", "enhancedInfo"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL", "FUEL", "AUTOMATIC", "ADVENTURE_MODE_ENABLED"}
--}
--subViewDetails["inorganicView"] = {
--	name = "Inorganic Materials",
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{15,40,99, 0},
--		{15,40,50,50},
--		{15,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	fill = {
--		"MaterialTypeList", "on_select:1", "on_select:2",     nil,
--		nil,                nil,           "environmentInfo", "materialInfo1",
--		nil,                nil,           "useInfo",         "materialInfo2"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"MaterialList", "MaterialDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "environmentInfo", "useInfo", "materialInfo1", "materialInfo2"}},
--	startFilter = "ALL", 
--	filterFlags = {"ALL", "SEDIMENTARY", "METAMORPHIC"}
--}
--subViewDetails["organicView"] = {
--	name = "Organic Materials",
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{15,40,99, 0},
--		{15,40,50,50},
--		{15,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	fill = {
--		"MaterialTypeList", "on_select:1", "on_select:2",     nil,
--		nil,                nil,           "environmentInfo", "materialInfo1",
--		nil,                nil,           "useInfo",         "materialInfo2"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"MaterialList", "MaterialDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "environmentInfo", "useInfo", "materialInfo1", "materialInfo2"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL", "ITEMS_SOFT", "ITEMS_HARD"}
--}
--subViewDetails["entityView"] = {
--	name = "Entities",
--	levels   = 2,
--	num_cols = 6,
--	num_rows = 2,
--	widths = {
--		{15,40,149, 0, 0, 0},
--		{15,40, 50,50,50,50}},
--	heights = {
--		{40,40,  5,  5,  5,  5},
--		{ 0, 0,100,100,100,100}},
--	fill = {
--		"EntityTypeList", "on_select:1", "on_select:2",  nil,            nil,         nil,
--		nil,              nil,           "resourceInfo", "positionInfo", "moralInfo", "baseInfo"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none", "none", "none",
--		"none",        "none",        "none", "none", "none", "none"},
--	on_select = {"EntityList", "EntityDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "baseInfo", "resourceInfo", "positionInfo", "moralInfo"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL"}
--}
--subViewDetails["plantView"] = {
--	name = "Plants",
--	levels   = 2,
--	num_cols = 4,
--	num_rows = 3,
--	widths = {
--		{15,40,99, 0},
--		{15,40,50,50},
--		{15,40,50,50}},
--	heights = {
--		{40,40, 5, 5},
--		{ 0, 0,25,25},
--		{ 0, 0,25,25}},
--	functions = {
--		materialInfo = {"viewSwitch", "organicView", "M"}},
--	fill = {
--		"PlantTypeList", "on_select:1", "on_select:2",   nil,
--		nil,             nil,           "baseInfo",      "materialInfo",
--		nil,             nil,           "typeInfo",      "growthInfo"},
--	on_fills = {
--		"on_select:1", "on_select:2", "none", "none",
--		"none",        "none",        "none", "none",
--		"none",        "none",        "none", "none"},
--	on_select = {"PlantList", "PlantDetails"},
--	on_groups = {
--		["on_select:2"] = {"on_select:2", "baseInfo", "materialInfo", "typeInfo", "growthInfo"}},
--	startFilter = "ALL",
--	filterFlags = {"ALL", "EVIL", "GOOD"},
--	filterKeys = {"CUSTOM_SHIFT_A", "CUSTOM_SHIFT_E", "CUSTOM_SHIFT_G"}
--}
--
function journalFill(widget, selection, token)
	if widget.ViewID == "main" then
		widget:insert("Center", widget.CellName)
  --insert = insertWidgetInput(insert, 'center', what, {width=w, keyed=keyed})
  --local Info = info[what]
  --if not Info then return insert end
  --insert = insertWidgetInput(insert, 'text',   Info._description, {width=w})
  --insert = insertWidgetInput(insert, 'header', Info._stats,       {width=w, rowOrder=get_order(Info._stats)})
	elseif widget.ViewID == "buildingView" then
		Building(widget, selection, token)
	--elseif widget.ViewID == "religionView" then
	--	Religion(widget)
	--elseif widget.ViewID == "syndromeView" then
	--	Syndrome(widget)
	--elseif widget.ViewID == "artView" then
	--	Art(widget)
	--elseif widget.ViewID == "productView" then
	--	Product(widget)
	--elseif widget.ViewID == "creatureView" then
	--	Creature(widget)
	--elseif widget.ViewID == "itemView" then
	--	Item(widget)
	--elseif widget.ViewID == "reactionView" then
	--	Reaction(widget)
	--elseif widget.ViewID == "inorganicView" then
	--	Inorganic(widget)
	--elseif widget.ViewID == "organicView" then
	--	Organic(widget)
	--elseif widget.ViewID == "entityView" then
	--	Entity(widget)
	--elseif widget.ViewID == "plantView" then
	--	Plant(widget)
	end
	return widget
end

function Building(widget, selection, token)
	if widget.CellName == "BuildingTypeList" then
		list = reqscript("functions/building").getTypeList(selection)
		options = {}
		options.baseType = "token"
		options.token = selection
		options.rowOrder = reqscript("functions/gui").get_order(list)
		widget:insert("List", list, options)
	elseif widget.CellName == "BuildingList" then
		if not selection.text then return end
		local str = split(selection.text[1].token, ":")
		list = reqscript("functions/building").getBuildingList(str[2])
		options = {}
		options.baseType = "list"
		options.rowOrder = reqscript("functions/gui").get_order(list)
		widget:insert("List", list, options)
	elseif widget.CellName == "BuildingDetails" then
		if not selection.text then return end
		local token = selection.text[1].token
		Info = reqscript("functions/building").getBuildingInfo(token) -- This needs to be moved back a level so we don't call it four times per building
		widget:insert("Center", Info.Name)
		widget:insert("Text", Info.Description or "")
	elseif widget.CellName == "bldgInfo" then
		if not selection.text then return end
		local token = selection.text[1].token
		Info = reqscript("functions/building").getBuildingInfo(token)
		local order = {"Build_Labor", "Dimensions", "Number_of_floors", "Outside_Only", "Inside_Only", "Required_Water_Depth", "Required_Magma_Depth"}
		widget:insert("Center", "Building Information")
		widget:insert("Header", Info, {rowOrder=order})
	elseif widget.CellName == "buildItems" then
		if not selection.text then return end
		local token = selection.text[1].token
		Info = reqscript("functions/building").getBuildingInfo(token)
		local headOrder = {"Item", "Material"}
		widget:insert("Center", "Build Items")
		widget:insert("Table", Info.BuildItems, {headOrder=headOrder})
	elseif widget.CellName == "bldgReactions" then
		if not selection.text then return end
		local token = selection.text[1].token
		Info = reqscript("functions/building").getBuildingInfo(token)
		widget:insert("Center", "Available Reactions")
		widget:insert("Header", Info.Reactions)
	elseif widget.CellName == "bldgDiagram" then
		widget:insert("Center", "Building Diagram")
	end
end

local function main(...)
	local args = utils.processArgs({...}, validArgs)
	local error_str = "Error in gui/journal - "

	-- Print Help Message
	if args.help then
		print(usage)
		return
	end

	-- Print valid argument list
	if args.args then
		printall(validArgs)
		return
	end
	
	journal = reqscript("functions/gui").GUI({mainViewDetails, subViewDetails, journalFill})
	--journal.ATTRS={
	--	frame_style = gui.BOUNDARY_FRAME,
	--	frame_title = "Journal and Compendium"}
	--journal:setFillFunction(journalFill)
	print("JOURNAL")
	printall(journal)
	--local screen = journal{}
	--print("SCREEN")
	--printall(screen)
	journal:show()
end

if not dfhack_flags.module then
	main(...)
end