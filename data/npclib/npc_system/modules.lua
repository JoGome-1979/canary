-- Advanced NPC System by Jiddo

if Modules == nil then
	-- default words for greeting and ungreeting the npc. Should be a table containing all such words.
	FOCUS_GREETWORDS = { "hi", "hello", "oi", "ola", "olá" }
	FOCUS_FAREWELLWORDS = { "bye", "farewell", "tchau", "adeus" }

	FOCUS_TRADE_MESSAGE = { "trade", "offers", "ofertas", "loja" }

	-- The word for accepting/declining an offer. CAN ONLY CONTAIN ONE FIELD! Should be a table with a single string value.
	SHOP_YESWORD = { "yes", "sim" }
	SHOP_NOWORD = { "no", "não", "nao" }

	StdModule = {}

	--[[
	--NOTE: These callback function must be called with parameters.npcHandler = npcHandler
	-- In the parameters table or they will not work correctly

	Example:
	keywordHandler:addKeyword(
		{"offer"},
		StdModule.say,
		{
			npcHandler = npcHandler,
			text = "Tenho à venda poderosas armas para o combate corpo a corpo."
		}
	)
	]]
	function StdModule.say(npc, player, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.say called without any npcHandler instance.")
		end

		if parameters.onlyFocus == true and parameters.onlyUnfocus == true then
			error("StdModule.say conflicting parameters 'onlyFocus' and 'onlyUnfocus' both true")
		end

		local onlyFocus = (parameters.onlyFocus == nil or parameters.onlyFocus == true)
		if not npcHandler:checkInteraction(npc, player) and onlyFocus then
			return false
		end

		if npcHandler:checkInteraction(npc, player) and parameters.onlyUnfocus == true then
			return false
		end

		local cost, costMessage = (IsTravelFree() and 0) or parameters.cost, "%d moedas de ouro"
		if cost and cost > 0 then
			if parameters.discount then
				cost = cost - StdModule.travelDiscount(npc, player, parameters.discount)
			end

			costMessage = cost > 0 and string.format(costMessage, cost) or "gratuita"
		else
			costMessage = "gratuita"
		end

		local parseInfo = {
			[TAG_PLAYERNAME] = player:getName(),
			[TAG_TIME] = getFormattedWorldTime(),
			[TAG_BLESSCOST] = Blessings.getBlessingCost(player:getLevel(), false, (npc:getName() == "Kais" or npc:getName() == "Nomad") and true),
			[TAG_PVPBLESSCOST] = Blessings.getPvpBlessingCost(player:getLevel(), false),
			[TAG_TRAVELCOST] = costMessage,
		}
		if parameters.replacements then
			for k, v in pairs(parameters.replacements) do
				parseInfo[k] = v
			end
		end
		if parameters.text then
			npcHandler:say(npcHandler:parseMessage(parameters.text, parseInfo, player, message), npc, player)
		end

		if parameters.ungreet then
			npcHandler:resetNpc(npc, player)
			npcHandler:removeInteraction(npc, player)
		elseif parameters.reset then
			parseInfo = { [TAG_PLAYERNAME] = Player(player):getName() }
			npcHandler:say(npcHandler:parseMessage(parameters.text or parameters.message, parseInfo), npc, player)
			if parameters.reset then
				npcHandler:resetNpc(npc, player)
			elseif parameters.moveup then
				npcHandler.keywordHandler:moveUp(player, parameters.moveup)
			end
		end

		return true
	end

	function StdModule.promotePlayer(npc, player, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.promotePlayer called without any npcHandler instance.")
		end

		if not npcHandler:checkInteraction(npc, player) then
			return false
		end

		if player:getVocation():getBaseId() == VOCATION.BASE_ID.MONK and not parameters.monk then
			return false
		end

		if player:isPremium() or not parameters.premium then
			local promotion = player:getVocation():getPromotion()
			local hasPromotion = player:kv():get("promoted")
			if not promotion or hasPromotion then
				npcHandler:say("Já recebestes vossa promoção!", npc, player)
			elseif player:getLevel() < parameters.level then
				npcHandler:say(string.format("Lamento, aventureiro, mas só poderei promover-vos quando alcançardes o nível %d.", parameters.level), npc, player)
			elseif not player:removeMoneyBank(parameters.cost) then
				npcHandler:say("Não tendes ouro suficiente!", npc, player)
			else
				npcHandler:say(parameters.text, npc, player)
				player:setVocation(promotion)
				player:addMinorCharmEchoes(100)
				player:kv():set("promoted", true)
			end
		else
			npcHandler:say("Precisais de uma conta premium para receber vossa promoção.", npc, player)
		end
		npcHandler:resetNpc(npc, player)
		return true
	end

	function StdModule.learnSpell(npc, player, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.learnSpell called without any npcHandler instance.")
		end

		if not npcHandler:checkInteraction(npc, player) then
			return false
		end

		if player:isPremium() or not parameters.premium then
			if player:hasLearnedSpell(parameters.spellName) then
				npcHandler:say("Já conheceis esta magia.", npc, player)
			elseif not player:canLearnSpell(parameters.spellName) then
				npcHandler:say("Ainda não estais apto a aprender esta magia.", npc, player)
			elseif not player:removeMoneyBank(parameters.price) then
				npcHandler:say(string.format("Não tendes ouro suficiente. Esta magia custa %s moedas de ouro.", parameters.price), npc, player)
			else
				npcHandler:say(string.format("Aprendestes a magia '%s'.", parameters.spellName), npc, player)
				player:learnSpell(parameters.spellName)
			end
		else
			npcHandler:say(string.format("Precisais de uma conta premium para aprender '%s'.", parameters.spellName), npc, player)
		end

		npcHandler:resetNpc(npc, player)
		return true
	end

	function StdModule.bless(npc, player, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.bless called without any npcHandler instance.")
		end

		if not npcHandler:checkInteraction(npc, player) or Game.getWorldType() == WORLD_TYPE_PVP_ENFORCED then
			return false
		end

		local parseInfo = {
			[TAG_BLESSCOST] = Blessings.getBlessingCost(player:getLevel(), false, (npc:getName() == "Kais" or npc:getName() == "Nomad") and true),
			[TAG_PVPBLESSCOST] = Blessings.getPvpBlessingCost(player:getLevel(), false),
		}
		if player:hasBlessing(parameters.bless) then
			npcHandler:say("Já possuís esta bênção.", npc, player)
		elseif parameters.bless == 3 and player:getStorageValue(Storage.KawillBlessing) ~= 1 then
			npcHandler:say("Primeiro, deveis receber a bênção do grande geomante.", npc, player)
		elseif parameters.bless == 1 and #player:getBlessings() == 0 and not player:getItemById(3057, true) then
			npcHandler:say(
				"Não possuís nenhuma das outras bênçãos, tampouco um Amulet of Loss, \z
                           portanto, não há razão para conceder-vos esta proteção agora. \z
                           Lembrai-vos: ela protege apenas contra a perda dessas bênçãos e desse amuleto!",
				npc,
				player
			)
		elseif not player:removeMoneyBank(type(parameters.cost) == "string" and tonumber(npcHandler:parseMessage(parameters.cost, parseInfo)) or parameters.cost) then
			npcHandler:say("Ora, não tendes ouro suficiente.", npc, player)
		else
			npcHandler:say(parameters.text or "Recebestes a bênção de um dos sete deuses!", npc, player)
			if parameters.bless == 3 then
				player:setStorageValue(Storage.KawillBlessing, 0)
			end
			player:addBlessing(parameters.bless, 1)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		end

		npcHandler:resetNpc(npc, player)
		return true
	end

	function StdModule.travel(npc, player, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.travel called without any npcHandler instance.")
		end

		if not npcHandler:checkInteraction(npc, player) then
			return false
		end

		local cost = (IsTravelFree() and 0) or parameters.cost
		if cost and cost > 0 then
			if parameters.discount then
				cost = cost - StdModule.travelDiscount(npc, player, parameters.discount)

				if cost < 0 then
					cost = 0
				end
			end
		else
			cost = 0
		end

		local playerPosition = player:getPosition()

		if parameters.premium and not player:isPremium() then
			npcHandler:say("Lamento, viajante, mas precisais de uma conta premium para embarcar em nossos navios.", npc, player)
		elseif parameters.level and player:getLevel() < parameters.level then
			npcHandler:say("Deveis alcançar o nível " .. parameters.level .. " antes que eu possa permitir vossa viagem até lá.", npc, player)
		elseif player:isPzLocked() then
			npcHandler:say("Primeiro, livrai-vos dessas marcas de sangue! Não havereis de manchar meu transporte!", npc, player)
		elseif not player:removeMoneyBank(cost) then
			npcHandler:say("Não tendes ouro suficiente.", npc, player)
		else
			local hasExhaustion = player:kv():get("npc-exhaustion") or 0
			if hasExhaustion > os.time() then
				npcHandler:say("Aguardai três segundos antes de viajar novamente, aventureiro.", player)
				playerPosition:sendMagicEffect(CONST_ME_POFF)
			else
				npcHandler:removeInteraction(npc, player)
				npcHandler:say(parameters.text or "Içai as velas!", npc, player)

				local destination = parameters.destination
				if type(destination) == "function" then
					destination = destination(player)
				end

				player:kv():set("npc-exhaustion", os.time() + 3) -- 3 seconds
				player:teleportTo(destination)
				playerPosition:sendMagicEffect(CONST_ME_TELEPORT)
				player:addAchievementProgress("Ship's Kobold", 1250)

				-- What a foolish Quest - Mission 3
				if Storage.Quest.U8_1.WhatAFoolishQuest.PieBoxTimer ~= nil then
					if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.PieBoxTimer) > os.time() then
						if destination ~= Position(32660, 31957, 15) then -- kazordoon steamboat
							player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.PieBoxTimer, 1)
						end
					end
				end
			end
		end

		npcHandler:resetNpc(npc, player)
		return true
	end

	FocusModule = {
		npcHandler = nil,
		greetWords = nil,
		farewellWords = nil,
		greetCallback = nil,
		farewellCallback = nil,
		tradeCallback = nil,
	}

	-- Creates a new instance of FocusModule without an associated NpcHandler.
	function FocusModule:new()
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	-- Inits the module and associates handler to it
	-- Variables "greetCallback, farewellCallback and tradeCallback" are boolean value, true by default
	function FocusModule:init(handler, greetCallback, farewellCallback, tradeCallback)
		self.npcHandler = handler
		if greetCallback == false then
			return false
		end
		for i, word in pairs(FOCUS_GREETWORDS) do
			local obj = {}
			obj[#obj + 1] = word
			obj.callback = FOCUS_GREETWORDS.callback or FocusModule.messageMatcher
			handler.keywordHandler:addKeyword(obj, FocusModule.onGreet, { module = self })
		end

		if farewellCallback == false then
			return false
		end
		for i, word in pairs(FOCUS_FAREWELLWORDS) do
			local obj = {}
			obj[#obj + 1] = word
			obj.callback = FOCUS_FAREWELLWORDS.callback or FocusModule.messageMatcher
			handler.keywordHandler:addKeyword(obj, FocusModule.onFarewell, { module = self })
		end

		if tradeCallback == false then
			return false
		end
		for i, word in pairs(FOCUS_TRADE_MESSAGE) do
			local obj = {}
			obj[#obj + 1] = word
			obj.callback = FOCUS_TRADE_MESSAGE.callback or FocusModule.messageMatcher
			handler.keywordHandler:addKeyword(obj, FocusModule.onTradeRequest, { module = self })
		end
		return true
	end

	-- Set custom greeting messages
	function FocusModule:addGreetMessage(message)
		if not self.greetWords then
			self.greetWords = {}
		end

		if type(message) == "string" then
			table.insert(self.greetWords, message)
		else
			for i = 1, #message do
				table.insert(self.greetWords, message[i])
			end
		end
	end

	-- Set custom farewell messages
	function FocusModule:addFarewellMessage(message)
		if not self.farewellWords then
			self.farewellWords = {}
		end

		if type(message) == "string" then
			table.insert(self.farewellWords, message)
		else
			for i = 1, #message do
				table.insert(self.farewellWords, message[i])
			end
		end
	end

	-- Set custom greeting callback
	function FocusModule:setGreetCallback(callback)
		self.greetCallback = callback
	end

	-- Set custom farewell callback
	function FocusModule:setFarewellCallback(callback)
		self.farewellCallback = callback
	end

	-- Set custom trade callback
	function FocusModule:setTradeCallback(callback)
		self.tradeCallback = callback
	end

	-- Greeting callback function.
	function FocusModule.onGreet(npc, player, message, keywords, parameters)
		parameters.module.npcHandler:onGreet(npc, player, message)
		return true
	end

	-- Greeting callback function.
	function FocusModule.onTradeRequest(npc, player, message, keywords, parameters)
		parameters.module.npcHandler:onTradeRequest(npc, player, message)
		return true
	end

	-- UnGreeting callback function.
	function FocusModule.onFarewell(npc, player, message, keywords, parameters)
		parameters.module.npcHandler:onFarewell(npc, player)
		return true
	end

	-- Custom message matching callback function for greeting messages.
	function FocusModule.messageMatcher(keywords, message)
		for i, word in pairs(keywords) do
			if type(word) == "string" then
				if MsgContains(message, word) then
					return true
				end
			end
		end
		return false
	end

	KeywordModule = {
		npcHandler = nil,
	}

	function KeywordModule:new()
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	function KeywordModule:init(handler)
		self.npcHandler = handler
		return true
	end

	function KeywordModule:parseKeywords(data)
		for keys in string.gmatch(data, "[^;]+") do
			local i = 1

			local keywords = {}
			for temp in string.gmatch(keys, "[^,]+") do
				keywords[#keywords + 1] = temp
				i = i + 1
			end
		end
	end

	function KeywordModule:addKeyword(keywords, reply)
		self.npcHandler.keywordHandler:addKeyword(keywords, StdModule.say, {
			npcHandler = self.npcHandler,
			onlyFocus = true,
			text = reply,
			reset = true,
		})
	end

	TravelModule = {
		npcHandler = nil,
		destinations = nil,
		yesNode = nil,
		noNode = nil,
	}

	function TravelModule:new()
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	function TravelModule:init(handler)
    	self.npcHandler = handler

    	SHOP_YESWORD.callback = FocusModule.messageMatcher
    	SHOP_NOWORD.callback = FocusModule.messageMatcher

    	self.yesNode = KeywordNode:new(SHOP_YESWORD, TravelModule.onConfirm, { module = self })
    	self.noNode = KeywordNode:new(SHOP_NOWORD, TravelModule.onDecline, { module = self })
    	self.destinations = {}
    	return true
	end

	function TravelModule:parseDestinations(npc, data)
		for destination in string.gmatch(data, "[^;]+") do
			local i = 1

			local name = nil
			local x = nil
			local y = nil
			local z = nil
			local cost = nil
			local premium = false

			for temp in string.gmatch(destination, "[^,]+") do
				if i == 1 then
					name = temp
				elseif i == 2 then
					x = tonumber(temp)
				elseif i == 3 then
					y = tonumber(temp)
				elseif i == 4 then
					z = tonumber(temp)
				elseif i == 5 then
					cost = tonumber(temp)
				elseif i == 6 then
					premium = temp == "true"
				else
					logger.warn(
						"[TravelModule:parseDestinations] - Npc: {}] \z
                                Unknown parameter found in travel destination parameter. temp[{}], destination[{}]",
						npc:getName(),
						temp,
						destination
					)
				end
				i = i + 1
			end

			if name and x and y and z and cost then
				self:addDestination(name, { x = x, y = y, z = z }, cost, premium)
			else
				logger.warn("[TravelModule:parseDestinations] - Npc: {}] Parameter(s) missing for travel destination: x = {}, y = {}, z = {}", npc:getName(), x, y, z)
			end
		end
	end

	function TravelModule:addDestination(name, position, price, premium)
		self.destinations[#self.destinations + 1] = name

		local parameters = {
			cost = price,
			destination = position,
			premium = premium,
			module = self,
		}
		local keywords = {}
		keywords[#keywords + 1] = name

		local keywords2 = {}
		keywords2[#keywords2 + 1] = "bring me to " .. name
		local node = self.npcHandler.keywordHandler:addKeyword(keywords, TravelModule.travel, parameters)
		self.npcHandler.keywordHandler:addKeyword(keywords2, TravelModule.bringMeTo, parameters)
		self.npcHandler.keywordHandler:addKeyword({ "leve-me para " .. name }, TravelModule.bringMeTo, parameters)
		self.npcHandler.keywordHandler:addKeyword({ "me leve para " .. name }, TravelModule.bringMeTo, parameters)
		node:addChildKeywordNode(self.yesNode)
		node:addChildKeywordNode(self.noNode)

		self.npcHandler.keywordHandler:addKeyword(SHOP_YESWORD, TravelModule.onConfirm, { module = self })
		self.npcHandler.keywordHandler:addKeyword(SHOP_NOWORD, TravelModule.onDecline, { module = self })
	end

	-- TODO(Eduardo): Need fix this function, is not ok
	function TravelModule.travel(npc, player, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:checkInteraction(npc, player) then
			return false
		end

		local cost = (IsTravelFree() and 0) or parameters.cost

		module.npcHandler:say(string.format("Desejais viajar para '%s' por %d moedas de ouro?", keywords[1], cost), npc, player)
		return true
	end

	function TravelModule.onConfirm(npc, player, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:checkInteraction(npc, player) then
			return false
		end

		local npcHandler = module.npcHandler

		local cost = (IsTravelFree() and 0) or parameters.cost
		local destination = parameters.destination
		local premium = parameters.premium

		if player:isPremium() or not premium then
			if not player:removeMoneyBank(cost) then
				npcHandler:say("Não tendes ouro suficiente!", npc, player)
			elseif player:isPzLocked(player) then
				npcHandler:say("Livrai-vos dessas marcas de sangue antes de embarcar.", npc, player)
			else
				npcHandler:say("Foi uma honra negociar convosco. Que tenhais uma boa viagem!", npc, player)
				npcHandler:removeInteraction(npc, player)

				local position = player:getPosition()
				player:teleportTo(destination)

				position:sendMagicEffect(CONST_ME_TELEPORT)
				destination:sendMagicEffect(CONST_ME_TELEPORT)
			end
		else
			npcHandler:say("Somente aventureiros com uma conta premium podem viajar até lá.", npc, player)
		end

		npcHandler:resetNpc(npc, player)
		return true
	end

	-- onDecline keyword callback function. Generally called when the player sais "no" after wanting to buy an item.
	function TravelModule.onDecline(npc, player, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:checkInteraction(npc, player) then
			return false
		end
		local parseInfo = {
			[TAG_PLAYERNAME] = Player(player):getName(),
		}
		local msg = module.npcHandler:parseMessage(module.npcHandler:getMessage(MESSAGE_DECLINE), parseInfo)
		module.npcHandler:say(msg, npc, player)
		module.npcHandler:resetNpc(npc, player)
		return true
	end

	function TravelModule.bringMeTo(npc, player, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:checkInteraction(npc, player) then
			return false
		end

		local cost = parameters.cost
		local destination = Position(parameters.destination)

		if player:isPremium() or not parameters.premium then
			if player:removeMoneyBank(cost) then
				local position = player:getPosition()
				player:teleportTo(destination)

				position:sendMagicEffect(CONST_ME_TELEPORT)
				destination:sendMagicEffect(CONST_ME_TELEPORT)
			end
		end
		return true
	end

	function TravelModule.listDestinations(npc, player, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:checkInteraction(npc, player) then
			return false
		end

		local msg = "Posso levar-vos a "
		--local i = 1
		local maxn = #module.destinations
		for i, destination in pairs(module.destinations) do
			msg = msg .. destination
			if i == maxn - 1 then
				msg = msg .. " e "
			elseif i == maxn then
				msg = msg .. "."
			else
				msg = msg .. ", "
			end
		end

		module.npcHandler:say(msg, npc, player)
		module.npcHandler:resetNpc(npc, player)
		return true
	end
end
