local callback = EventCallback("MonsterOnDropLootBaseEvent")

local function getPremiumLootRecipients(owner)
	local recipients = {}
	if not owner then
		return recipients
	end

	local party = owner:getParty()
	local candidates = party and party:getMembers() or { owner }
	if party then
		table.insert(candidates, party:getLeader())
	end

	for _, player in ipairs(candidates) do
		if player:isPremium() and player:canReceiveLoot() then
			recipients[#recipients + 1] = player
		end
	end
	return recipients
end

local function splitPremiumLoot(lootTable, recipients)
	local shares = {}
	local totalPlayers = #recipients
	if totalPlayers == 0 then
		return shares
	end
	for index = 1, totalPlayers do
		shares[index] = {}
	end

	local function addShare(index, loot, count)
		if count <= 0 then
			return
		end
		local entry = {}
		for key, value in pairs(loot) do
			entry[key] = value
		end
		entry.count = count
		shares[index][#shares[index] + 1] = entry
	end

	for _, loot in ipairs(lootTable) do
		local amountEach = math.floor(loot.count / totalPlayers)
		local remainder = loot.count % totalPlayers
		local startIndex = math.random(totalPlayers)
		for offset = 0, totalPlayers - 1 do
			local index = ((startIndex - 1 + offset) % totalPlayers) + 1
			addShare(index, loot, amountEach + (offset < remainder and 1 or 0))
		end
	end
	return shares
end

-- Cria os itens fora do corpo e aplica a reserva antes de inseri-los.
local function addPremiumLootShare(container, share, ownerGuid)
	for _, loot in ipairs(share) do
		local itemId = loot.itemId
		local itemType = ItemType(itemId)
		local stackable = itemType:isStackable()
		local charged = itemType:getCharges() > 0
		local remaining = loot.count

		while remaining > 0 do
			local amount = stackable and math.min(remaining, itemType:getStackSize()) or 1
			local subType = amount
			if charged then
				subType = loot.subType and loot.subType >= 0 and loot.subType or itemType:getCharges()
			elseif not stackable and loot.subType and loot.subType >= 0 then
				subType = loot.subType
			end

			local item = Game.createItem(itemId, subType)
			if not item then
				logger.warn("Premium loot: could not create item {}", itemId)
				break
			end

			item:setCustomAttribute("premium_loot_owner", ownerGuid)
			if loot.actionId and loot.actionId > 0 then
				item:setActionId(loot.actionId)
			end
			if loot.text and loot.text ~= "" then
				item:setText(loot.text)
			end

			if item:isContainer() and loot.childLoot then
				addPremiumLootShare(item, loot.childLoot, ownerGuid)
			end

			local result = container:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
			if result ~= RETURNVALUE_NOERROR then
				item:remove()
				logger.warn("Premium loot: could not insert item {} into corpse/container", itemId)
				break
			end

			remaining = remaining - amount
		end
	end
end

function callback.monsterOnDropLoot(monster, corpse)
	local player = Player(corpse:getCorpseOwner())
	local factor = 1.0
	local msgSuffix = ""
	if player and player:canReceiveLoot() then
		local config = player:calculateLootFactor(monster)
		factor = config.factor
		msgSuffix = config.msgSuffix
	end
	local mType = monster:getType()
	if not mType then
		logger.warn("monsterOnDropLoot: monster '{}' has no type", monster:getName())
		return
	end

	local mTypeCharm = player and player:getCharmMonsterType(CHARM_GUT)
	local gut = mTypeCharm and mTypeCharm:raceId() == mType:raceId()

	local lootTable = mType:generateLootRoll({ factor = factor, gut = gut }, {}, player)
	corpse:addLoot(lootTable)
	local charmMessage = false
	local existingSuffix = corpse:getAttribute(ITEM_ATTRIBUTE_LOOTMESSAGE_SUFFIX) or ""
	for _, item in pairs(lootTable) do
		if item.gut and not charmMessage then
			charmMessage = true
			msgSuffix = msgSuffix .. (string.len(msgSuffix) > 0 and ", gut charm" or "gut charm")
		end
	end
	corpse:setAttribute(ITEM_ATTRIBUTE_LOOTMESSAGE_SUFFIX, existingSuffix .. msgSuffix)
	-- Um único sorteio premium, seguido da divisão entre os destinatários.
	local recipients = getPremiumLootRecipients(player)
	if #recipients > 0 then
		local premiumLoot = mType:generateLootPremiumRoll(
			{ factor = factor, gut = false },
			recipients[1]
		)
		local shares = splitPremiumLoot(premiumLoot, recipients)
		for index, recipient in ipairs(recipients) do
			addPremiumLootShare(corpse, shares[index], recipient:getGuid())
		end
	end

end

callback:register()
