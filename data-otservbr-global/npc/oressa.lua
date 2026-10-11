local internalNpcName = "Oressa"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 148,
	lookHead = 114,
	lookBody = 78,
	lookLegs = 96,
	lookFeet = 114,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
	profession = "sailor",
}
npcConfig.speechBubble = SPEECHBUBBLE_SAILOR

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{
		text = "Preparai a partida: os itens de treinamento são retirados na escolha definitiva. Conferi vossa mochila antes de confirmar.",
	},
	{ text = "Escolhei vosso caminho com calma. Posso explicar cada vocação." },
	{ text = "Ferido? Perguntai por {cura}." },
	{ text = "Ao nível 8, posso orientar vossa vocação e partida." },
	{ text = "Knight, Paladin, Druid ou Sorcerer: explicarei antes de pedir vossa confirmação." },
	{ text = "Crystal precisa de aventureiros preparados. Treinai antes de partir." },
	{ text = "Ferido ou envenenado? Posso verificar se precisais de cura." },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

-- Local tutorial helpers: aliases never rewrite player or recipient names.
local dawnAliases = {
    yes = { "sim" }, no = { "não", "nao" }, name = { "nome" }, job = { "trabalho" },
    help = { "ajuda" }, trade = { "loja", "comercio", "comércio", "troca" }, offer = { "ofertas" },
    quest = { "missao", "missão", "missoes", "missões" }, mission = { "missao", "missão" },
    fetch = { "buscas", "buscar" }, kill = { "cacadas", "caçadas", "cacar", "caçar" },
    amulet = { "amuleto" }, ["log book"] = { "diario", "diário" }, herbs = { "ervas", "erva" },
    key = { "chave" }, precious = { "tesouro" }, reward = { "recompensa" }, minotaur = { "minotauros" },
    ready = { "pronto" }, heal = { "cura", "curar" }, healing = { "cura", "curar" }, healer = { "curadora" },
    vocation = { "vocacao", "vocação", "vocacoes", "vocações" }, choosing = { "escolher" }, choose = { "escolher" },
    decided = { "decidido" }, distance = { "distancia", "distância" }, close = { "perto" },
    bow = { "arco" }, spear = { "lanca", "lança" }, magic = { "magia", "magias" }, death = { "morte" },
    doors = { "portas" }, temple = { "templo" }, spells = { "magias" },
    ["healing spells"] = { "cura" }, ["support spells"] = { "suporte" },
    ["attack spells"] = { "ataque" }, ["conjure spells"] = { "conjuracao", "conjuração" },
    invitation = { "convite" }, seeker = { "buscador" }, pilgrimage = { "peregrinacao", "peregrinação" },
    serenity = { "serenidade" }, ["three-fold path"] = { "caminho triplice", "caminho tríplice" },
    balance = { "saldo" }, deposit = { "depositar", "deposito", "depósito" }, withdraw = { "sacar", "saque" },
    all = { "tudo" }, ["bank account"] = { "conta bancaria", "conta bancária" }, bank = { "banco" },
    basic = { "basicos", "básicos" }, advanced = { "avancados", "avançados" }, money = { "dinheiro", "ouro" },
    ["change gold"] = { "trocar ouro" }, ["change platinum"] = { "trocar platina" },
    ["change crystal"] = { "trocar cristal" }, gold = { "ouro" }, crystal = { "cristal" },
    sail = { "viajar" }, passage = { "passagem" }, travel = { "viajar" }, city = { "cidade" }, cities = { "cidades" },
    donate = { "doar" }, ship = { "navio" }, mainland = { "continente" }, tibia = { "crystal" },
    containers = { "recipientes" }, food = { "comida" }, equipment = { "equipamentos" }, others = { "outros" },
    potions = { "pocoes", "poções" }, wands = { "varinhas" }, runes = { "runas" },
    rope = { "corda" }, tools = { "ferramentas" },
}
local function dawnContains(message, keyword)
    if MsgContains(message, keyword) then return true end
    for _, alias in ipairs(dawnAliases[keyword:lower()] or {}) do
        if MsgContains(message, alias) then return true end
    end
    return false
end
local function dawnKeys(keys)
    if #keys ~= 1 or keys.callback then return keys end
    local aliases = dawnAliases[keys[1]:lower()]
    if not aliases then return keys end
    local out = { keys[1], callback = FocusModule.messageMatcher }
    for _, alias in ipairs(aliases) do out[#out + 1] = alias end
    return out
end
local function dawnMark(player, text)
    local locations = {
        { "inigo", 32070, 31900, 5, "Inigo - primeiros passos" },
        { "richard", 32056, 31881, 5, "Richard - comida e ferramentas" },
        { "hamish", 32057, 31900, 5, "Hamish - poções" },
        { "garamond", 32059, 31882, 4, "Garamond - magias" },
        { "tybald", 32071, 31882, 4, "Ser Tybald - magias" },
        { "morris", 32071, 31897, 4, "Mr Morris - missões" },
        { "oressa", 32064, 31892, 6, "Oressa - templo" },
        { "dreadnought", 32031, 31872, 6, "Captain Dreadnought - embarque" },
        { "plunderpurse", 32071, 31882, 5, "Plunderpurse - banco" },
        { "woblin", 31987, 31883, 8, "Woblin - chave" },
    }
    local lower = text:lower()
    for _, d in ipairs(locations) do
        if lower:find(d[1], 1, true) then
            player:addMapMark({ x = d[2], y = d[3], z = d[4] }, MAPMARK_FLAG, d[5])
        end
    end
    if lower:find("32099", 1, true) then
        player:addMapMark({ x = 32099, y = 31933, z = 7 }, MAPMARK_FLAG, "Amuleto - usar pá na areia")
    end
    if lower:find("32059, 31800", 1, true) then
        player:addMapMark({ x = 32059, y = 31800, z = 10 }, MAPMARK_FLAG, "Diário - recipiente na caverna")
    end
    if lower:find("santu", 1, true) then
        for _, pos in ipairs({ {32046,31861,5}, {32082,31879,5}, {32048,31888,6}, {32067,31915,6} }) do
            player:addMapMark({ x=pos[1], y=pos[2], z=pos[3] }, MAPMARK_FLAG, "Santuário de Monk - usar")
        end
    end
end


npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

-- Basic keywords
keywordHandler:addKeyword(dawnKeys({ "name" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Sou Oressa Fourwinds, curadora deste templo.",
})
keywordHandler:addKeyword(dawnKeys({ "healer" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Se estiverdes ferido, pedi {cura}. Verificarei vossas necessidades.",
})
keywordHandler:addKeyword(dawnKeys({ "job" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Posso ajudar com {cura} e com a escolha de {vocacao}.",
})
keywordHandler:addKeyword(dawnKeys({ "doors" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Cada sala contém o equipamento de uma vocação: Sorcerer, Paladin, Knight ou Druid.",
	"Ao nível 8, falai comigo para escolher a vocação. Depois, recolhei o equipamento no baú da sala correspondente.",
	"A escolha definitiva não pode ser desfeita por este diálogo. Conhecei as opções antes de confirmar.",
})
keywordHandler:addKeyword(dawnKeys({ "inigo" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Inigo orienta os primeiros passos e indica onde encontrar cada serviço.",
})
keywordHandler:addKeyword(dawnKeys({ "richard" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Richard fornece comida e ferramentas. Preparai vossa mochila com ele.",
})
keywordHandler:addKeyword(dawnKeys({ "coltrayne" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Coltrayne é reservado, mas fornece armas e proteção.",
})
keywordHandler:addKeyword(dawnKeys({ "morris" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Morris oferece buscas e caçadas opcionais. Ele explicará cada tarefa.",
})
keywordHandler:addKeyword(dawnKeys({ "hamish" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Hamish prepara poções e suprimentos mágicos.",
})
keywordHandler:addKeyword(dawnKeys({ "menesto" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Menesto precisa de cuidados? Obrigada por avisar. Também posso orientar vossa {cura}.",
})
keywordHandler:addKeyword(dawnKeys({ "dawnport" }), StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Dawnport é uma ilha de treinamento. Aqui podeis conhecer vossas habilidades antes de decidir.",
		"Meu papel é cuidar dos aventureiros de Crystal e orientar a escolha de seu caminho.",
	},
})
keywordHandler:addKeyword(dawnKeys({ "rookgaard" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Ouvi falar de Rookgaard. Inigo conhece os caminhos.",
})
keywordHandler:addKeyword(dawnKeys({ "key" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "A chave desapareceu. Aceitai a busca com Morris e perguntai a Inigo.",
})

--From topic of vocation to topic of the "yes" message (choosing vocation)
local topicTable = {
	[5] = VOCATION.ID.KNIGHT,
	[6] = VOCATION.ID.PALADIN,
	[7] = VOCATION.ID.DRUID,
	[8] = VOCATION.ID.SORCERER,
}

local vocationRoomPositions = {
	[5] = { x = 32068, y = 31884, z = 6 },
	[6] = { x = 32059, y = 31884, z = 6 },
	[7] = { x = 32073, y = 31884, z = 6 },
	[8] = { x = 32054, y = 31884, z = 6 },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local health = player:getHealth()

	local vocationDefaultMessages = {
		"A vocação define vossas habilidades. Crystal possui Knight, Sorcerer, Paladin, Druid e Monk. Posso orientar as quatro primeiras; Manop orienta Monk.",
		"Os quatro portões de treinamento no piso superior permitem testar as vocações tradicionais e seus equipamentos.",
		"Experimentai com calma. Ao alcançar o nível 8, podereis escolher uma vocação definitiva.",
		"Escolhei com cuidado. A confirmação muda vossa vocação e retira os itens de treinamento conforme as regras da ilha.",
		"Quando estiverdes preparado, dizei {escolher} ou o nome da vocação.",
	}

	-- Heal and help dialog
	if dawnContains(message, "healing") and npcHandler:getTopic(playerId) == 0 then
		if player:getLevel() < 8 then
			if health < 40 or player:getCondition(CONDITION_POISON) then
				if health < 40 then
					player:addHealth(40 - health)
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
				end
				if player:getCondition(CONDITION_POISON) then
					player:removeCondition(CONDITION_POISON)
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
				end
				npcHandler:say("Estais ferido. Cuidarei de vossas feridas.", npc, creature)
				npcHandler:setTopic(playerId, 0)
			else
				return npcHandler:say("Não precisais de minha cura neste momento.", npc, creature)
			end
		end
	elseif dawnContains(message, "help") and npcHandler:getTopic(playerId) == 0 then
		if not player:getCondition(CONDITION_POISON) and health >= 40 then
			return npcHandler:say("Não precisais de minha cura neste momento.", npc, creature)
		end
		if health < 40 or player:getCondition(CONDITION_POISON) then
			if health < 40 then
				player:addHealth(40 - health)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			end
			if player:getCondition(CONDITION_POISON) then
				player:removeCondition(CONDITION_POISON)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			end
			npcHandler:say("Estais ferido. Cuidarei de vossas feridas.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		-- Vocation dialog
	elseif npcHandler:getTopic(playerId) == 0 and dawnContains(message, "vocation") then
		npcHandler:say(vocationDefaultMessages, npc, creature, 10)
		npcHandler:setTopic(playerId, 0)
		-- Choosing dialog start
	elseif (dawnContains(message, "choosing") or dawnContains(message, "choose")) and npcHandler:getTopic(playerId) == 0 then
		if player:getLevel() >= 8 then
			npcHandler:say(
				"Vamos escolher com calma. Preferis lutar à {distancia} ou de {perto}?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 2)
		else
			npcHandler:say(vocationDefaultMessages, npc, creature, 10)
			npcHandler:setTopic(playerId, 0)
		end
	elseif dawnContains(message, "distance") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:say("Preferis {arco} e {lanca}, ou desejais usar {magia}?", npc, creature)
		npcHandler:setTopic(playerId, 3)
		-- knight
	elseif dawnContains(message, "close") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:say({
			"Knight é o caminho do combate próximo, usando armas e escudos.",
			"Knights possuem boa resistência e capacidade de carga. Seu estilo favorece o combate próximo.",
			"Usam espadas, machados e clavas, além de magias úteis para combate e cura.",
			"Desejais tornar-vos Knight? A escolha é definitiva. Respondei {sim} ou {nao}.",
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 5)
		-- Paladin
	elseif (dawnContains(message, "bow") or dawnContains(message, "spear")) and npcHandler:getTopic(playerId) == 3 then
		npcHandler:say({
			"Paladin favorece mobilidade e ataques à distância.",
			"Paladins combinam resistência, combate à distância e magia sagrada.",
			"Planejai vossa distância e munição. Movimento e preparação fazem parte desse estilo.",
			"A magia sagrada auxilia contra criaturas profanas e mortos-vivos.",
			"Desejais tornar-vos Paladin? A escolha é definitiva. Respondei {sim} ou {nao}.",
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 6)
		-- Mage
	elseif dawnContains(message, "magic") and npcHandler:getTopic(playerId) == 3 then
		npcHandler:say(
			"Preferis {curar} aliados e usar gelo e terra, ou usar fogo, energia e {morte}?",
			npc,
			creature
		)
		npcHandler:setTopic(playerId, 4)
		-- Druid
	elseif dawnContains(message, "heal") and npcHandler:getTopic(playerId) == 4 then
		npcHandler:say({
			"Druid combina cura de aliados com magia da natureza.",
			"Druids usam gelo e terra e podem curar seus companheiros.",
			"Sua proteção física e capacidade de carga são menores; distância e mana são importantes.",
			"Desejais tornar-vos Druid? A escolha é definitiva. Respondei {sim} ou {nao}.",
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 7)
		-- Sorcerer
	elseif dawnContains(message, "death") and npcHandler:getTopic(playerId) == 4 then
		npcHandler:say({
			"Sorcerer é o caminho da magia ofensiva.",
			"Sorcerers usam fogo, energia e morte para enfrentar os inimigos.",
			"São vulneráveis no combate próximo. Preparai mana, cura e espaço para recuar.",
			"Desejais tornar-vos Sorcerer? A escolha é definitiva. Respondei {sim} ou {nao}.",
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 8)
		-- Choosing dialog start
	elseif dawnContains(message, "decided") and npcHandler:getTopic(playerId) == 0 then
		npcHandler:say("Qual {vocacao} desejais conhecer ou escolher: {knight}, {sorcerer}, {paladin} ou {druid}?", npc, creature)
		-- Say vocations name
	elseif dawnContains(message, "sorcerer") and npcHandler:getTopic(playerId) == 0 then
		local message = {
			"Sorcerers usam magia ofensiva de fogo, energia e morte.",
			"Podem atingir vários inimigos com magias, mas precisam cuidar de sua defesa e mana.",
			"Se preferis magia ofensiva e combate à distância, considerai Sorcerer.",
		}

		if player:getLevel() >= 8 then
			table.insert(message, "Desejais tornar-vos Sorcerer?" .. " Respondei {sim} para confirmar ou {nao} para cancelar.")
			npcHandler:setTopic(playerId, 8)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
	elseif dawnContains(message, "druid") and npcHandler:getTopic(playerId) == 0 then
		local message = {
			"Druids usam gelo e terra e curam seus aliados.",
			"Podem atacar vários inimigos, mas devem preservar a distância e a mana.",
			"Se desejais curar aliados e usar magia da natureza, considerai Druid.",
		}

		if player:getLevel() >= 8 then
			table.insert(message, "Desejais tornar-vos Druid?" .. " Respondei {sim} para confirmar ou {nao} para cancelar.")
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
	elseif dawnContains(message, "paladin") and npcHandler:getTopic(playerId) == 0 then
		local message = {
			"Paladins usam ataques à distância, com resistência intermediária e magia sagrada.",
			"Sua força depende de treinamento, armas, munição e boa posição.",
			"Podem usar magia sagrada contra criaturas profanas e mortos-vivos.",
			"Se preferis atacar enquanto mantendes distância, considerai Paladin.",
		}

		if player:getLevel() >= 8 then
			table.insert(message, "Desejais tornar-vos Paladin?" .. " Respondei {sim} para confirmar ou {nao} para cancelar.")
			npcHandler:setTopic(playerId, 6)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
	elseif dawnContains(message, "knight") and npcHandler:getTopic(playerId) == 0 then
		local message = {
			"Knights enfrentam inimigos de perto, com boa resistência e capacidade de carga.",
			"Usam espadas, machados e clavas, além de magias para apoiar o combate.",
			"Se desejais resistir na linha de frente, considerai Knight.",
		}
		if player:getLevel() >= 8 then
			table.insert(message, "Desejais tornar-vos Knight? Respondei {sim} ou {nao}.")
			npcHandler:setTopic(playerId, 5)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
	elseif dawnContains(message, "monk") and npcHandler:getTopic(playerId) == 0 then
		npcHandler:say("Para seguir o caminho de Monk, falai com Ambassador Manop. Eu não confirmarei Knight nessa conversa.", npc, creature)
		npcHandler:setTopic(playerId, 0)
	elseif (npcHandler:getTopic(playerId) >= 5) and (npcHandler:getTopic(playerId) <= 8) then
		if dawnContains(message, "yes") then
            if player:getLevel() < 8 then
                npcHandler:say("Alcançai o nível 8 antes da escolha definitiva.", npc, creature)
                npcHandler:setTopic(playerId, 0)
                return true
            end
			for index, value in pairs(topicTable) do
				if npcHandler:getTopic(playerId) == index then
					if player:getStorageValue(Storage.Dawnport.DoorVocation) == -1 then
						-- Change to new vocation, convert magic level and skills and set proper stats
						player:changeVocation(value)
						player:setStorageValue(Storage.Dawnport.DoorVocation, value)
						if configManager.getBoolean(configKeys.TELEPORT_PLAYER_TO_VOCATION_ROOM) then
							local position = vocationRoomPositions[index]
							player:teleportTo(Position(position.x, position.y, position.z))
							player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
							player:addItem(3035, 10)
						end
					else
						npcHandler:setTopic(playerId, 0)
						return true
					end
				end
			end
			-- Remove Mainland smuggling items
			removeMainlandSmugglingItems(player)
			npcHandler:say({
				"Que assim seja. Erguei-vos como " .. player:getVocation():getName():upper() .. "!",
				"Entrai na sala de vossa vocação e abri seu baú para recolher o equipamento. Depois segui para o embarque.",
				"Falai com Captain Dreadnought para viajar ao continente. Que vossa jornada seja segura!",
			}, npc, creature, 10)
			npcHandler:setTopic(playerId, 0)
		elseif dawnContains(message, "no") then
			local vocationMessage = {
				[5] = "{paladin}, {sorcerer} ou {druid}",
				[6] = "{knight}, {sorcerer} ou {druid}",
				[7] = "{knight}, {paladin} ou {sorcerer}",
				[8] = "{knight}, {paladin} ou {druid}",
			}
			npcHandler:say({
				"Como desejardes. Para conhecer outra vocação, escolhei " .. vocationMessage[npcHandler:getTopic(playerId)] .. "; explicarei esse caminho.",
			}, npc, creature, 10)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getLevel() >= 8 then
		npcHandler:setMessage(
			MESSAGE_GREET,
			"Saudações. Ao nível 8, posso ajudar-vos a {escolher} vossa {vocacao}. Se já decidistes, dizei o nome dela."
		)
	else
		npcHandler:setMessage(
			MESSAGE_GREET,
			"Bem-vindo ao templo de Dawnport. Escolhei {cura} ou {vocacao}; explicarei um passo de cada vez."
		)
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:setMessage(MESSAGE_FAREWELL, "Ide em paz, aventureiro.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Ide em paz.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table

-- Each NPC owns its return memory and lesson pages; quest state stays authoritative.
local dawnMenu = "Escolhei {cura}, {vocacao}, {escolher}, {knight}, {paladin}, {druid}, {sorcerer} ou {monk}."
local dawnPersonality = "Oressa, curadora paciente"
local dawnRawSay = npcHandler.say
local function dawnState(player)
    return player:kv():scoped("crystal-dawnport-" .. internalNpcName:lower():gsub(" ", "-"))
end
local function dawnPage(npc, player, index)
    local kv = dawnState(player)
    local total = kv:get("page-count") or 0
    if total < 1 then dawnRawSay(npcHandler, dawnMenu, npc, player); return end
    index = math.max(1, math.min(index, total))
    kv:set("page-index", index)
    local text = kv:get("page-" .. index) or dawnMenu
    dawnMark(player, text)
    dawnRawSay(npcHandler, "[" .. index .. "/" .. total .. "] " .. text ..
        (index < total and " Dizei {proximo} para continuar ou {ajuda} para voltar ao menu." or " Dizei {repetir} para rever ou {ajuda} para o menu."), npc, player)
end
function npcHandler:say(message, npc, creature, delay, textType)
    local player = Player(creature)
    if not player then return end
    local kv = dawnState(player)
    -- Greeting must not discard the explanation saved from a previous visit.
    local greeting = self:getMessage(MESSAGE_GREET)
    if type(message) == "string" and greeting and message == greeting:gsub("|PLAYERNAME|", function() return player:getName() end) then
        dawnRawSay(self, message, npc, player, delay, textType)
        return
    end
    if type(message) == "table" and #message > 1 then
        kv:set("page-count", #message)
        for i, text in ipairs(message) do kv:set("page-" .. i, text) end
        dawnPage(npc, player, 1)
    else
        kv:set("page-count", 0)
        local text = type(message) == "table" and message[1] or message
        if text then dawnMark(player, text); dawnRawSay(self, text, npc, player, delay, textType) end
    end
end
local dawnOriginalGreet = npcHandler:getCallback(CALLBACK_GREET)
npcHandler:setCallback(CALLBACK_GREET, function(npc, creature, message)
    local player = Player(creature)
    local kv = dawnState(player)
    local returning = kv:get("met")
    if dawnOriginalGreet and dawnOriginalGreet(npc, creature, message) == false then return false end
    keywordHandler:reset(player)
    npcHandler:setTopic(player:getId(), 0)
    local greeting
    -- Preserve original greet side effects while requiring fresh transaction confirmation.
    if returning then
        greeting = "Bem-vindo de volta, |PLAYERNAME|! " .. dawnMenu
    else
        greeting = "Saudações, |PLAYERNAME|! Sou " .. dawnPersonality .. ". " .. dawnMenu
    end
    if (kv:get("page-count") or 0) > 0 then
        greeting = greeting .. " Dizei {continuar} para rever vossa explicação. Qualquer operação exige nova confirmação nesta conversa."
    end
    kv:set("met", true)
    npcHandler:setMessage(MESSAGE_GREET, greeting)
    return true
end)
local function dawnOriginalOnSay(npc, creature, speechType, message)
    return npcHandler:onSay(npc, creature, speechType, message)
end
npcType.onSay = function(npc, creature, type, message)
    local player = Player(creature)
    if not player or not npcHandler:checkInteraction(npc, creature) then
        return dawnOriginalOnSay(npc, creature, type, message)
    end
    local kv = dawnState(player)
    local id = player:getId()
    if dawnContains(message, "help") or MsgContains(message, "menu") then
        keywordHandler:reset(player)
        npcHandler:setTopic(id, 0)
        dawnRawSay(npcHandler, dawnMenu .. " Usai {proximo}, {anterior}, {repetir} ou {continuar} durante as explicações.", npc, player)
        return
    end
    if MsgContains(message, "proximo") or MsgContains(message, "próximo") then
        dawnPage(npc, player, (kv:get("page-index") or 1) + 1); return
    elseif MsgContains(message, "anterior") then
        dawnPage(npc, player, (kv:get("page-index") or 1) - 1); return
    elseif MsgContains(message, "continuar") or MsgContains(message, "repetir") then
        dawnPage(npc, player, kv:get("page-index") or 1); return
    end
    if dawnContains(message, "yes") and (kv:get("page-index") or 0) < (kv:get("page-count") or 0) then
        dawnRawSay(npcHandler, "Antes de confirmar, lede a orientação completa. Dizei {proximo}.", npc, player)
        return
    end
    if dawnContains(message, "no") then kv:set("page-count", 0) end
    
    return dawnOriginalOnSay(npc, creature, type, message)
end

npcType:register(npcConfig)
