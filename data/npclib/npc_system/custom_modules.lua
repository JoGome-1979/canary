-- Custom modules used by the NPC system
function registerHealKeyword(keywordHandler, npcHandler, text, condition, effect, minimumHealth)
	keywordHandler:addKeyword({ "heal", "curar", "cura", callback = FocusModule.messageMatcher }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
		return player:getCondition(condition) ~= nil
	end, function(player)
		if minimumHealth then
			local health = player:getHealth()
			if health < minimumHealth then
				player:addHealth(minimumHealth - health)
			end
		end

		player:removeCondition(condition)
		player:getPosition():sendMagicEffect(effect)
	end)
end

local travelDiscounts = {
	["postman"] = { price = 10, storage = Storage.Quest.ExampleQuest, value = 1 },
}

function StdModule.travelDiscount(npc, player, discounts)
	local discountPrice = 0
	local discount = 0
	if type(discounts) == "string" then
		discount = travelDiscounts[discounts]
		if discount and player:getStorageValue(discount.storage) >= discount.value then
			return discount.price
		end
	else
		for i = 1, #discounts do
			discount = travelDiscounts[discounts[i]]
			if discount and player:getStorageValue(discount.storage) >= discount.value then
				discountPrice = discountPrice + discount.price
			end
		end
	end

	return discountPrice
end

function StdModule.kick(npc, player, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	if npcHandler == nil then
		logger.error("StdModule.travel called without any npcHandler instance.")
	end

	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	npcHandler:removeInteraction(npc, player)
	npcHandler:say(parameters.text or "Retirai-vos!", npc, player)

	local destination = parameters.destination
	if type(destination) == "table" then
		destination = destination[math.random(#destination)]
	end

	Player(player):teleportTo(destination, true)

	npcHandler:resetNpc(npc, player)
	return true
end

local GreetModule = {}
function GreetModule.greet(npc, player, message, keywords, parameters)
	if not parameters.npcHandler:isInRange(npc, player) then
		return true
	end

	if parameters.npcHandler:checkInteraction(npc, player) then
		NpcDialog.add(player, npc:getId())
		NpcDialog.sendWindow(player)
		return true
	end

	local parseInfo = { [TAG_PLAYERNAME] = Player(player):getName() }
	parameters.npcHandler:say(parameters.npcHandler:parseMessage(parameters.text, parseInfo), npc, player)
	parameters.npcHandler:setInteraction(npc, player)
	NpcDialog.add(player, npc:getId())
	NpcDialog.sendWindow(player)
	return true
end

function GreetModule.farewell(npc, player, message, keywords, parameters)
	if not parameters.npcHandler:checkInteraction(npc, player) then
		return false
	end

	local parseInfo = { [TAG_PLAYERNAME] = Player(player):getName() }
	parameters.npcHandler:say(parameters.npcHandler:parseMessage(parameters.text, parseInfo), npc, player)
	parameters.npcHandler:resetNpc(npc, player)
	parameters.npcHandler:removeInteraction(npc, player)
	NpcDialog.remove(player, npc:getId())
	NpcDialog.sendWindow(player)
	return true
end

-- Adds a keyword which acts as a greeting word
function KeywordHandler:addGreetKeyword(keys, parameters, condition, action)
	local localKeys = keys
	localKeys.callback = FocusModule.messageMatcherDefault
	return self:addKeyword(localKeys, GreetModule.greet, parameters, condition, action)
end

-- Function adapted to be able to create a single call to the NPC and per function
function KeywordHandler:addCustomGreetKeyword(keys, callbackFunction, parameters, condition, action)
	local localKeys = keys
	localKeys.callback = FocusModule.messageMatcherDefault
	return self:addKeyword(localKeys, callbackFunction, parameters, condition, action)
end

-- Adds a keyword which acts as a farewell word
function KeywordHandler:addFarewellKeyword(keys, parameters, condition, action)
	local localKeys = keys
	localKeys.callback = FocusModule.messageMatcherDefault
	return self:addKeyword(localKeys, GreetModule.farewell, parameters, condition, action)
end

-- Adds a keyword which acts as a spell word
function KeywordHandler:addSpellKeyword(keys, parameters)
	local localKeys = keys
	localKeys.callback = FocusModule.messageMatcherDefault

	local npcHandler, spellName, price, vocationId = parameters.npcHandler, parameters.spellName, parameters.price, parameters.vocation

	local spellKeyword = self:addKeyword(localKeys, StdModule.say, {
		npcHandler = npcHandler,
		text = string.format("Desejais aprender a magia '%s' por %s?\z ", spellName, price > 0 and price .. " moedas de ouro" or "nenhum custo"),
	}, function(player)
		-- This will register for all client id vocations
		local vocationClientId = player:getVocation():getBaseId()
		if type(vocationId) == "table" then
			return table.contains(vocationId, vocationClientId)
		else
			return vocationId == vocationClientId
		end
	end)

	spellKeyword:addChildKeyword({ "yes", "sim", callback = FocusModule.messageMatcher }, StdModule.learnSpell, {
		npcHandler = npcHandler,
		spellName = spellName,
		level = parameters.level,
		price = price,
	})
	spellKeyword:addChildKeyword({ "no", "não", "nao", callback = FocusModule.messageMatcher }, StdModule.say, {
		npcHandler = npcHandler,
		text = "Talvez em outra ocasião.",
		reset = true,
	})
end

local hints = {
    [-1] = "Se não souberdes o significado de um ícone à direita, colocai o cursor sobre ele e aguardai um instante.",
    [0] = "Para enviar uma mensagem privada, clicai com o botão direito sobre um aventureiro ou seu nome e escolhei a opção de mensagem. Também podeis abrir um canal privado e informar o nome do destinatário.",
    [1] = "Ao clicar num objeto ou aventureiro, usai SHIFT para olhar, CTRL para usar e ALT para atacar, conforme os controles de vosso cliente.",
    [2] = "Clicai no mapa para caminhar automaticamente até um local, desde que seja acessível e não esteja demasiado distante.",
    [3] = "Para abrir ou fechar os painéis de habilidades, batalha ou amigos, clicai nos respectivos botões de vosso cliente.",
    [4] = "Vossa capacidade limita o peso que podeis carregar. Ela aumenta a cada nível.",
    [5] = "Vigiai vossa barra de vida. Se deixardes de recuperar vida, comei algo.",
    [6] = "Mantende-vos bem alimentado para recuperar vida por mais tempo.",
    [7] = "Após derrotar uma criatura, procurai os despojos em seu corpo. As regras de proteção do saque dependem do combate e do servidor.",
    [8] = "Cuidado ao enfrentar várias criaturas ao mesmo tempo! Até pequenos inimigos podem tornar-se uma ameaça quando vos cercam.",
    [9] = "Podeis obter comida de criaturas, colher mirtilos ou preparar pão. Com uma vara de pesca e minhocas, também podeis pescar.",
    [10] = {
        "Para preparar pão, colhei trigo com uma foice e usai-o numa pedra de moinho para obter farinha. ...",
        "Usai a farinha com água para preparar massa e depois levai-a ao forno. Com leite em vez de água, podeis preparar massa de bolo.",
    },
    [11] = "Preservai vossa vida! Recuar é mais prudente do que morrer. A morte pode custar experiência e habilidades, conforme vossas proteções.",
    [12] = "No modo de combate ofensivo, causais mais dano, mas também ficais mais vulnerável.",
    [13] = "Se estiverdes ferido e precisardes recuar, o modo de combate defensivo pode reduzir os golpes recebidos.",
    [14] = "Algumas criaturas fogem. Ativai a opção de perseguir o oponente para segui-las.",
    [15] = "Quanto mais fundo numa masmorra, maiores podem ser os perigos. Avançai com cautela, pois a morte pode custar experiência e habilidades.",
    [16] = "Devido à perspectiva, alguns objetos em Crystal, como escadas, janelas e lampiões, parecem ocupar outro lugar. Tentai clicar no piso onde sua base se encontra.",
    [17] = "Para negociar com outro aventureiro, clicai com o botão direito no item, escolhei a opção de troca e depois clicai no destinatário.",
    [18] = "Escadas e entradas de masmorras aparecem como pontos amarelos no mapa.",
    [19] = "Podeis conseguir comida caçando, colhendo mirtilos ou preparando pão. Também podeis comprá-la de um mercador.",
    [20] = "Recipientes de missões costumam anunciar o que encontrastes em vez de abrir como um recipiente comum. Muitos concedem sua recompensa apenas uma vez.",
    [21] = "Recuai antes de arriscar vossa vida. A morte pode reduzir vossa experiência e habilidades.",
    [22] = "Para formar um grupo, clicai com o botão direito num aventureiro e escolhei a opção de convite. O líder pode ativar a experiência compartilhada no menu de seu próprio personagem.",
    [23] = "Podeis configurar atalhos para magias, itens e mensagens nas opções de vosso cliente.",
    [24] = "Para seguir outro aventureiro, clicai nele com o botão direito e escolhei a opção de seguir.",
    [25] = "Convidai vossos amigos para um grupo pelo menu do botão direito. Se receberdes um convite, abri o menu de vosso personagem e escolhei entrar no grupo.",
    [26] = "Formai grupos com aventureiros em quem confiais. Conhecei as regras de combate de vosso mundo antes de treinar contra companheiros.",
    [27] = "O líder pode ativar a experiência compartilhada pelo menu de seu personagem. O grupo deve cumprir os requisitos desse recurso.",
    [28] = "Não tenho mais conselhos por ora. Se desejardes ouvir minhas {dicas} novamente, basta pedir.",
}

function StdModule.rookgaardHints(npc, player, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	if npcHandler == nil then
		error("StdModule.say called without any npcHandler instance.")
	end

	if not npcHandler:checkInteraction(npc, player) or not IsRunningGlobalDatapack() then
		return false
	end

	local hintId = player:getStorageValue(Storage.RookgaardHints)
	npcHandler:say(hints[hintId], npc, player)
	if hintId >= #hints then
		player:setStorageValue(Storage.RookgaardHints, -1)
	else
		player:setStorageValue(Storage.RookgaardHints, hintId + 1)
	end
	return true
end
