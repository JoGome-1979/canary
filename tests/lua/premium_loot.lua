-- Standalone regression tests. Run from the repository root.
MonsterType = {}
MESSAGE_LOOT, CHARM_GUT, ITEM_ATTRIBUTE_LOOTMESSAGE_SUFFIX = 1, 1, 1
MESSAGE_LOOT_PREMIUM = 59
INDEX_WHEREEVER, FLAG_NOLIMIT, RETURNVALUE_NOERROR = -1, 1, 0
ITEM_TYPE_CREATUREPRODUCT = 1
configKeys = { RATE_LOOT = 1 }
local rate = 1
configManager = { getNumber = function() return rate end, getBoolean = function() return false end }
local warnings = {}
logger = {
	warn = function(message) warnings[#warnings + 1] = message end,
	debug = function() end,
}
local randomCalls = 0
function getLootRandom()
	randomCalls = randomCalls + 1
	return 0
end

local types = {
	[1] = { name = "coin", stackable = true },
	[2] = { name = "bag", container = true },
	[3] = { name = "wand", charges = 10 },
	[4] = { name = "food", stackable = true },
	[5] = { name = "sword" },
}
function ItemType(id)
	local kind = assert(types[id], "unknown item type")
	return {
		getId = function() return id end,
		getName = function() return kind.name end,
		isStackable = function() return kind.stackable or false end,
		isContainer = function() return kind.container or false end,
		getCharges = function() return kind.charges or 0 end,
		getStackSize = function() return 100 end,
		getType = function() return 0 end,
	}
end
local players = {}
function Player(id) return players[id] end
local function makePlayer(id, premium, eligible)
	local player = { id = id, premium = premium, eligible = eligible ~= false, messages = {}, messageModes = {} }
	function player:isPremium() return self.premium end
	function player:canReceiveLoot() return self.eligible end
	function player:getGuid() return self.id end
	function player:getParty() return self.party end
	function player:getCharmMonsterType() return nil end
	function player:calculateLootFactor() return { factor = 1, msgSuffix = "" } end
	function player:sendTextMessage(mode, text)
		error("Lua must not send loot messages; the unified C++ death flow sends both")
	end
	players[id] = player
	return player
end
local callback
function EventCallback()
	callback = { register = function() end }
	return callback
end

local failItemId
local failCreationId
local function insertItem(self, item)
	assert(item.premium_loot_owner, "item inserted before its reservation was set")
	if item.id == failItemId then
		return 1
	end
	self.items[#self.items + 1] = item
	return RETURNVALUE_NOERROR
end
Game = {}
function Game.createItem(id, subtype)
	if id == failCreationId then return nil end
	return {
		id = id, subtype = subtype, items = {},
		count = types[id].stackable and subtype or 1,
		setCustomAttribute = function(self, key, value) self[key] = value end,
		setActionId = function(self, value) self.actionId = value end,
		setText = function(self, value) self.text = value end,
		isContainer = function() return types[id].container or false end,
		addItemEx = insertItem,
		remove = function(self) self.removed = true end,
	}
end
local function entry(id, count, extra)
	local result = {
		itemId = id, chance = 100000, minCount = count or 1, maxCount = count or 1,
		subType = -1, actionId = -1, text = "", childLoot = {},
	}
	for key, value in pairs(extra or {}) do result[key] = value end
	return result
end
local function makeType(premium)
	local result = setmetatable({ premium = premium or {}, normal = { entry(1, 2) } }, { __index = MonsterType })
	function result:getLoot() return self.normal end
	function result:getLootPremium() return self.premium end
	function result:isRewardBoss() return false end
	function result:name() return "dragon" end
	return result
end
local function run(owner, monsterType)
	local monster = { getType = function() return monsterType end, getName = function() return "dragon" end }
	local corpse = { items = {}, normalCalls = 0 }
	function corpse:getCorpseOwner() return owner and owner.id or 0 end
	function corpse:addLoot(normal)
		self.normal = normal
		self.normalCalls = self.normalCalls + 1
	end
	function corpse:getAttribute() return "" end
	function corpse:setAttribute() end
	corpse.addItemEx = insertItem
	callback.monsterOnDropLoot(monster, corpse)
	assert(corpse.normalCalls == 1, "normal loot rolled/inserted twice")
	if rate > 0 then assert(corpse.normal[1].count == 2, "normal loot changed") end
	return corpse
end
local function assertNoItems(corpse)
	assert(#corpse.items == 0)
end
local passed = 0
local function test(name, fn)
	randomCalls, failItemId, failCreationId, rate = 0, nil, nil, 1
	players = {}
	fn()
	passed = passed + 1
	print("PASS " .. name)
end

dofile("data/libs/functions/monstertype.lua")
dofile("data/scripts/eventcallbacks/monster/ondroploot__base.lua")

test("free solo and missing owner receive no premium", function()
	local owner = makePlayer(1, false)
	local mtype = makeType({ entry(1, 11) })
	assertNoItems(run(owner, mtype))
	assertNoItems(run(nil, mtype))
	assert(#owner.messages == 0)
end)
test("premium solo gets marked items without a Lua notification", function()
	local owner = makePlayer(1, true)
	local corpse = run(owner, makeType({ entry(1, 11) }))
	assert(#corpse.items == 1 and corpse.items[1].count == 11)
	assert(corpse.items[1].premium_loot_owner == 1)
	assert(#owner.messages == 0)
end)
test("Lua generation no longer depends on the message constant", function()
	MESSAGE_LOOT_PREMIUM = nil
	local owner = makePlayer(1, true)
	run(owner, makeType({ entry(1, 11) }))
	assert(#owner.messages == 0)
	MESSAGE_LOOT_PREMIUM = 59
end)
test("one roll is shared 6/5 with a free party leader excluded", function()
	local free = makePlayer(1, false)
	local a, b, tired = makePlayer(2, true), makePlayer(3, true), makePlayer(4, true, false)
	free.party = { getMembers = function() return { a, b, tired } end, getLeader = function() return free end }
	local corpse = run(free, makeType({ entry(1, 11) }))
	local counts = {}
	for _, item in ipairs(corpse.items) do counts[item.premium_loot_owner] = item.count end
	assert(#corpse.items == 2 and counts[2] + counts[3] == 11)
	assert(math.abs(counts[2] - counts[3]) == 1)
	assert(randomCalls == 2, "premium items were rolled once for each recipient")
	assert(#free.messages == 0 and #tired.messages == 0 and #a.messages == 0 and #b.messages == 0)
end)
test("charged items retain configured charges and duplicate entries", function()
	local owner = makePlayer(1, true)
	local corpse = run(owner, makeType({
		entry(3, 1, { subType = 17 }),
		entry(3, 1, { subType = 25 }),
	}))
	assert(#corpse.items == 2 and corpse.items[1].subtype == 17 and corpse.items[2].subtype == 25)
	assert(corpse.items[1].count == 1 and corpse.items[2].count == 1)
end)
test("same ID with different attributes remains separate", function()
	local owner = makePlayer(1, true)
	local corpse = run(owner, makeType({
		entry(5, 1, { actionId = 11, text = "first" }),
		entry(5, 1, { actionId = 22, text = "second" }),
	}))
	assert(#corpse.items == 2)
	assert(corpse.items[1].actionId == 11 and corpse.items[1].text == "first")
	assert(corpse.items[2].actionId == 22 and corpse.items[2].text == "second")
end)
test("nested child rolls preserve inserted contents", function()
	local owner = makePlayer(1, true)
	local corpse = run(owner, makeType({ entry(2, 1, { childLoot = {
		entry(2, 1, { childLoot = { entry(1, 7), entry(4, 1, { chance = 0 }) } }),
	} }) }))
	local bag = corpse.items[1]
	local nested = bag.items[1]
	assert(#bag.items == 1 and #nested.items == 1 and nested.items[1].count == 7)
	assert(bag.premium_loot_owner == 1 and nested.premium_loot_owner == 1 and nested.items[1].premium_loot_owner == 1)
	assert(#owner.messages == 0)
end)
test("unique and zero-chance entries", function()
	local owner = makePlayer(1, true)
	local corpse = run(owner, makeType({
		entry(5, 1, { unique = true }), entry(5, 1), entry(4, 1, { chance = 0 }),
	}))
	assert(#corpse.items == 1 and corpse.items[1].id == 5)
end)
test("large stacks preserve total quantity", function()
	local owner = makePlayer(1, true)
	local corpse = run(owner, makeType({ entry(1, 250) }))
	assert(#corpse.items == 3)
	local total = 0
	for _, item in ipairs(corpse.items) do
		assert(item.count <= 100)
		total = total + item.count
	end
	assert(total == 250)
end)
test("insertion and creation failures are not announced as received", function()
	local owner = makePlayer(1, true)
	failItemId = 1
	assertNoItems(run(owner, makeType({ entry(1, 11) })))
	assert(#owner.messages == 0)
	failItemId, failCreationId = nil, 5
	assertNoItems(run(owner, makeType({ entry(5) })))
	assert(#owner.messages == 0)
end)
test("failed child insertion leaves no phantom contents", function()
	local owner = makePlayer(1, true)
	failItemId = 1
	local corpse = run(owner, makeType({ entry(2, 1, { childLoot = { entry(1, 7) } }) }))
	assert(#corpse.items == 1 and #corpse.items[1].items == 0)
	assert(#owner.messages == 0)
end)
test("disabled loot rate, tired player and empty premium configuration", function()
	local owner = makePlayer(1, true)
	rate = 0
	assertNoItems(run(owner, makeType({ entry(1, 11) })))
	rate = 1
	owner.eligible = false
	assertNoItems(run(owner, makeType({ entry(1, 11) })))
	owner.eligible = true
	assertNoItems(run(owner, makeType({})))
	assert(#owner.messages == 0)
end)
test("legacy binary skips premium without breaking normal loot", function()
	local owner = makePlayer(1, true)
	local mtype = makeType({ entry(1, 11) })
	mtype.getLootPremium = nil
	assertNoItems(run(owner, mtype))
	assert(randomCalls == 1 and #owner.messages == 0)
end)
test("legacy registration skips safely and does not use the old global registry", function()
	dofile("data/scripts/lib/register_monster_type.lua")
	local warningCount = #warnings
	local mtype = makeType()
	mtype:createLootPremium({ { name = "coin", chance = 100000 } })
	assert(#warnings == warningCount + 1)
	assert(MonsterPremiumLoot == nil)
end)

test("premium registration preserves nested children", function()
	function isInteger(value) return type(value) == "number" and value % 1 == 0 end
	function Loot()
		local object = { children = {} }
		return setmetatable(object, { __index = function(_, key)
			if key == "addChildLoot" then
				return function(self, child) self.children[#self.children + 1] = child end
			elseif key == "setId" then
				return function(self, id) self.id = id end
			end
			return function() end
		end })
	end
	local mtype = makeType()
	function mtype:addLootPremium(loot) self.registered = loot end
	-- Explicit subType avoids ItemType name resolution in this structural test.
	mtype:createLootPremium({ { id = 2, subType = -1, chance = 100000, child = {
		{ id = 2, subType = -1, chance = 100000, child = {
			{ id = 1, subType = -1, chance = 100000 },
		} },
	} } })
	assert(mtype.registered.id == 2)
	assert(mtype.registered.children[1].id == 2)
	assert(mtype.registered.children[1].children[1].id == 1)
end)

print(string.format("%d premium loot scenarios passed; C++ and in-game checks are separate.", passed))
