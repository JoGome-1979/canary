local internalNpcName = "Captain Dreadnought"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 155,
	lookHead = 96,
	lookBody = 0,
	lookLegs = 78,
	lookFeet = 96,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
	profession = "sailor",
}
npcConfig.speechBubble = SPEECHBUBBLE_SAILOR

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Sem contrabando a bordo! Conferi os limites de produtos antes de partir." },
	{ text = "O Sea Cat levará vós e vosso equipamento ao continente!" },
	{ text = "Todos a bordo! Preparai a partida!" },
	{ text = "Vento ou tempestade, conheço meus portos!" },
	{ text = "Esta ilha é pequena. O mar chama por mim!" },
}

npcConfig.moneyToNeedDonation = 500 --value in gold coins (ex: 500 = 500gp, 10000 = 10k)

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

-- List of all towns to ask about and to sail to
local towns = {
	[TOWNS_LIST.AB_DENDRIEL] = {
		name = "Ab'dendriel",
		about = {
			"Ab'Dendriel é a cidade dos elfos, construída entre árvores.",
			"É uma opção para quem aprecia natureza. Preparai-vos para explorar os arredores.",
		},
		canBeSailed = true,
		isPremium = false,
		message = "Escolheis Ab'Dendriel como vosso novo lar?",
		destination = { x = 32734, y = 31668, z = 6 },
	},
	[TOWNS_LIST.ANKRAHMUN] = {
		name = "Ankrahmun",
		about = { "Ankrahmun fica no deserto, entre pirâmides e tumbas. Escolhei as caçadas conforme vosso nível." },
		canBeSailed = true,
		isPremium = true,
		message = "Escolheis Ankrahmun como vosso novo lar?",
		destination = { x = 33092, y = 32883, z = 6 },
	},
	[TOWNS_LIST.CARLIN] = {
		name = "Carlin",
		about = {
			"Carlin é governada por mulheres e possui regras firmes. Conferi os arredores antes de caçar.",
		},
		canBeSailed = true,
		isPremium = false,
		message = "Escolheis Carlin como vosso novo lar?",
		destination = { x = 32387, y = 31820, z = 6 },
	},
	[TOWNS_LIST.DARASHIA] = {
		name = "Darashia",
		about = {
			"Darashia foi construída em torno de um oásis. Há criaturas fracas e perigosas na região; escolhei com cuidado.",
		},
		canBeSailed = true,
		isPremium = true,
		message = "Escolheis Darashia como vosso novo lar?",
		destination = { x = 33289, y = 32481, z = 6 },
	},
	[TOWNS_LIST.EDRON] = {
		name = "Edron",
		about = {
			"Edron é uma cidade com castelo numa ilha ao nordeste de Crystal. Possui opções de treino para iniciantes.",
		},
		canBeSailed = true,
		isPremium = true,
		message = "Escolheis Edron como vosso novo lar?",
		destination = { x = 33175, y = 31764, z = 6 },
	},
	[TOWNS_LIST.KAZORDOON] = {
		name = "Kazordoon",
		about = { "Kazordoon é a cidade subterrânea dos anões. Não possui um porto atendido por este navio." },
		canBeSailed = false,
	},
	[TOWNS_LIST.LIBERTY_BAY] = {
		name = "Liberty Bay",
		about = {
			"Liberty Bay fica nas ilhas dos mares do sul. Há piratas e criaturas variadas; começai pelas caçadas adequadas ao vosso nível.",
		},
		canBeSailed = true,
		isPremium = true,
		message = "Escolheis Liberty Bay como vosso novo lar?",
		destination = { x = 32285, y = 32892, z = 6 },
	},
	[TOWNS_LIST.PORT_HOPE] = {
		name = "Port Hope",
		about = {
			"Port Hope fica em plena selva.",
			"Há macacos, hidras e tarântulas. Nem todo caminho é seguro para um iniciante!",
		},
		canBeSailed = true,
		isPremium = true,
		message = "Escolheis Port Hope como vosso novo lar?",
		destination = { x = 32527, y = 32784, z = 6 },
	},
	[TOWNS_LIST.SVARGROND] = {
		name = "Svargrond",
		about = {
			"Não vos levo a Svargrond por esta rota. Há requisitos próprios para morar lá.",
		},
		canBeSailed = false,
	},
	[TOWNS_LIST.THAIS] = {
		name = "Thais",
		about = {
			"Thais é um antigo reino de Crystal. Consultai o guia local ao chegar.",
		},
		canBeSailed = true,
		isPremium = false,
		message = "Escolheis Thais como vosso novo lar?",
		destination = { x = 32310, y = 32210, z = 6 },
	},
	[TOWNS_LIST.VENORE] = {
		name = "Venore",
		about = {
			"Venore é uma cidade de comerciantes, construída sobre um pântano. Consultai o guia ao chegar para conhecer caçadas adequadas.",
		},
		canBeSailed = true,
		isPremium = false,
		message = "Escolheis Venore como vosso novo lar?",
		destination = { x = 32954, y = 32022, z = 6 },
	},
	[TOWNS_LIST.YALAHAR] = {
		name = "Yalahar",
		about = {
			"Yalahar é uma grande cidade, mas não é atendida por esta viagem inicial.",
		},
		canBeSailed = false,
	},
}

local defaultTown = TOWNS_LIST.THAIS
local townNames = { all = "", free = "", premium = "" }

-- Function to build town names strings and adds additional data to sailable/premium towns about
local function buildStrings()
	local townsList = { all = {}, free = {}, premium = {} }
	for id, town in pairs(towns) do
		if town.canBeSailed then
			if town.isPremium then
				table.insert(townsList.premium, "{" .. town.name .. "}")
				town.about[1] = "Somente para viajantes {premium}! " .. town.about[1]
			else
				table.insert(townsList.premium, "{" .. town.name .. "}")
				table.insert(townsList.free, "{" .. town.name .. "}")
			end
			town.about[#town.about] = town.about[#town.about] .. " Posso {viajar} para lá, se desejardes."
		end
		table.insert(townsList.all, "{" .. town.name .. "}")
	end
	for list, townList in pairs(townsList) do
		if #townList == 1 then
			townNames[list] = townList[1]
		elseif #townList > 1 then
			table.sort(townList, function(a, b)
				return a:upper() < b:upper()
			end)
			local lastTown = table.remove(townList, #townList)
			townNames[list] = table.concat(townList, ", ") .. " ou " .. lastTown
		end
	end
end

buildStrings()

-- Function to handle donations and its messages
local function donationHandler(npc, creature, message, keywords, parameters, node)
	local player = Player(creature)
	local playerId = player:getId()

	if (parameters.confirm ~= true) and (parameters.decline ~= true) then
		npcHandler:say("Desejais doar " .. (player:getMoney() - npcConfig.moneyToNeedDonation) .. " moedas de ouro? A doação ajudará os órfãos.", npc, creature)
	elseif parameters.confirm == true then
		if player:getMoney() > npcConfig.moneyToNeedDonation then
			player:removeMoney((player:getMoney() - npcConfig.moneyToNeedDonation))
			npcHandler:say(
				"Doação recebida. Agora escolhei a {cidade} de destino.",
				npc,
				creature
			)
			npcHandler:resetNpc(npc, creature)
		else
			npcHandler:say("Vosso ouro já não excede o limite. Escolhei a cidade e conferi o que levareis.", npc, creature)
		end
	elseif parameters.decline == true then
		if player:getMoney() > npcConfig.moneyToNeedDonation then
			npcHandler:say("Pelos ventos! Só podeis carregar até " .. npcConfig.moneyToNeedDonation .. " moedas de ouro nesta partida. Retirai o excedente ou escolhei {doar} para o fundo dos órfãos.", npc, creature)
		end
	end
	return true
end

-- Function to handle town travel and its messages
local function townTravelHandler(npc, creature, message, keywords, parameters, node)
	local player = Player(creature)
	local playerId = player:getId()

	if (parameters.confirm ~= true) and (parameters.decline ~= true) and parameters.townId then
		local town = towns[parameters.townId]
		if town.canBeSailed == false then
			if player:isPremium() then
				npcHandler:say("Esse porto não é atendido nesta viagem. Escolhei entre " .. townNames.premium .. "?", npc, creature)
			else
				npcHandler:say("Esse porto não é atendido nesta viagem. Escolhei entre " .. townNames.free .. "?", npc, creature)
			end
		elseif town.isPremium == true and not player:isPremium() then
			npcHandler:say(
				"Esse destino exige uma conta premium. Escolhei outro porto disponível se não possuís essa condição.",
				npc,
				creature
			)
		else
			npcHandler:say(town.message .. " Confirmareis com {sim} ou cancelareis com {nao}?", npc, creature)
		end
	elseif parameters.confirm == true then
		-- Handle money excess at confirm or it may be dropped and picked up in previous steps
		if player:getMoney() > npcConfig.moneyToNeedDonation then
			npcHandler:say("Pelos ventos! Só podeis carregar até " .. npcConfig.moneyToNeedDonation .. " moedas de ouro nesta partida. Retirai o excedente ou escolhei {doar} para o fundo dos órfãos.", npc, creature)
			return true
		end
		local parentNode = node:getParent()
		local parentParameters = parentNode:getParameters()
		local townId = parentParameters.townId or parameters.townId
        local destination = towns[townId]
        if not destination or not destination.canBeSailed or (destination.isPremium and not player:isPremium()) then
            npcHandler:say("Esse destino não está disponível para vós. Escolhei outra {cidade}.", npc, creature)
            npcHandler:resetNpc(npc, creature)
            return true
        end
        if player:getLevel() < 8 or player:getStorageValue(Storage.Dawnport.DoorVocation) < 1 then
            npcHandler:say("Antes de partir, alcançai o nível 8 e escolhei vossa vocação com {Oressa}.", npc, creature)
            npcHandler:resetNpc(npc, creature)
            return true
        end
        if player:getStorageValue(Storage.Dawnport.Mainland) == 1 then
            npcHandler:say("Vossa partida já foi registrada.", npc, creature)
            npcHandler:resetNpc(npc, creature)
            return true
        end
		local town = Town(townId)
		player:setTown(town)
		player:teleportTo(towns[townId].destination)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(Storage.Dawnport.Mainland, 1)
		npcHandler:say(
			"Soltai as amarras! Ao chegar, falai com o guia do porto para encontrar lojas, banco e caminhos seguros.",
			npc,
			creature
		)
		npcHandler:resetNpc(npc, creature)
		npcHandler:removeInteraction(npc, creature)
	elseif parameters.decline == true then
		if player:isPremium() then
			npcHandler:say("Mudastes de ideia? Para qual cidade desejais partir: " .. townNames.premium .. "?", npc, creature)
		else
			npcHandler:say("Mudastes de ideia? Para qual cidade desejais partir: " .. townNames.free .. "?", npc, creature)
		end
		npcHandler.keywordHandler:moveUp(creature, 1)
	elseif (parameters.sailableTowns == true) and parameters.text then
		if player:isPremium() then
			npcHandler:say(string.gsub(parameters.text, "|TOWNS|", townNames.premium), npc, creature)
		else
			npcHandler:say(string.gsub(parameters.text, "|TOWNS|", townNames.free), npc, creature)
		end
	end
	return true
end
-- Other topics
keywordHandler:addKeyword(dawnKeys({ "name" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Ruby Dreadnought. Mas chamai-me Captain Dreadnought!",
})
keywordHandler:addKeyword(dawnKeys({ "job" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Comando este navio, o Sea Cat.",
})
keywordHandler:addKeyword(dawnKeys({ "ship" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Minha viagem inicial é gratuita. Preparai o equipamento, depois pedi {passagem}. Posso explicar as {cidades} antes de escolherdes.",
})
keywordHandler:addKeyword(dawnKeys({ "mainland" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "O continente oferece novas aventuras. Conhecei as regras do mundo e preparai-vos contra os monstros. Pedi {passagem}.",
})
keywordHandler:addKeyword(dawnKeys({ "rookgaard" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Não navego para Rookgaard. Inigo pode explicar as condições dessa rota.",
})
keywordHandler:addKeyword(dawnKeys({ "adventurers guild" }), StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"A Guilda dos Aventureiros ajuda os recém-chegados a Crystal. Usai a Adventurer's Stone nos templos das cidades para visitar sua sede.",
		"Recomendo conhecer a guilda após vossa chegada.",
	},
})
keywordHandler:addKeyword(dawnKeys({ "premium" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Alguns destinos exigem premium. Direi quais cidades estão disponíveis para vós.",
})
keywordHandler:addKeyword(dawnKeys({ "tibia" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Crystal é o nome de nosso mundo.",
})
-- Main topic nodes
local readyNode = keywordHandler:addKeyword(dawnKeys({ "yes" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Tendes todo o equipamento que desejais levar? Respondei {sim} ou {nao}.",
})
local notReadyNode = keywordHandler:addKeyword(dawnKeys({ "no" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Desejais conhecer as {cidades} de Crystal antes de escolher?",
})
-- Main subtopic nodes
-- hi, yes, ...
local defaultTownNode = readyNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Para iniciantes, recomendo {" .. towns[defaultTown].name .. "}. Falai com o guia local ao chegar.",
		"Também posso explicar as outras {cidades}. Desejais partir para {" .. towns[defaultTown].name .. "}?",
	},
})
readyNode:addChildKeyword(dawnKeys({ "no" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Preparai-vos com calma. Voltai quando estiverdes pronto para embarcar.",
	ungreet = true,
})
-- hi, no, ...
local aboutTownsNode = notReadyNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Posso explicar os destinos: " .. townNames.all .. ".",
})
local aboutSailNode = notReadyNode:addChildKeyword(dawnKeys({ "no" }), townTravelHandler, {
	sailableTowns = true,
	text = "Para onde desejais partir? Escolhei |TOWNS|.",
})
-- hi, yes, yes, ...
defaultTownNode:addChildKeyword(dawnKeys({ "yes" }), townTravelHandler, { confirm = true, townId = defaultTown })
defaultTownNode:addAliasKeyword({ towns[defaultTown].name:lower() })
defaultTownNode:addChildKeyword(dawnKeys({ "no" }), townTravelHandler, { decline = true })
-- Towns topic nodes
local townsNode = keywordHandler:addKeyword(dawnKeys({ "cities" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Sobre qual destino desejais saber: " .. townNames.all .. "?",
})
for id, town in pairs(towns) do
	local townNode = KeywordNode:new({ town.name:lower() }, StdModule.say, { npcHandler = npcHandler, text = town.about })
	townsNode:addChildKeywordNode(townNode)
	aboutTownsNode:addChildKeywordNode(townNode)
end
keywordHandler:addAliasKeyword(dawnKeys({ "city" }))
-- Sail topic nodes
local sailNode = keywordHandler:addKeyword(dawnKeys({ "sail" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Qual será vossa nova cidade? Informai seu nome.",
})
local confirmNode = KeywordNode:new(dawnKeys({ "yes" }), townTravelHandler, { confirm = true })
local declineNode = KeywordNode:new(dawnKeys({ "no" }), townTravelHandler, { decline = true })
for id, town in pairs(towns) do
	local townSailNode = KeywordNode:new({ town.name:lower() }, townTravelHandler, { townId = id })
	townSailNode:addChildKeywordNode(confirmNode)
	townSailNode:addChildKeywordNode(declineNode)
	sailNode:addChildKeywordNode(townSailNode)
	aboutSailNode:addChildKeywordNode(townSailNode)
end
keywordHandler:addAliasKeyword(dawnKeys({ "passage" }))
keywordHandler:addAliasKeyword(dawnKeys({ "travel" }))
-- Donate topic nodes
local donateNode = keywordHandler:addKeyword(dawnKeys({ "donate" }), donationHandler, {}, function(player)
	return player:getMoney() > npcConfig.moneyToNeedDonation
end)
donateNode:addChildKeywordNode(KeywordNode:new(dawnKeys({ "yes" }), donationHandler, { confirm = true }))
donateNode:addChildKeywordNode(KeywordNode:new(dawnKeys({ "no" }), donationHandler, { decline = true }))

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	local player = Player(creature)
	npcHandler:setMessage(MESSAGE_GREET, "Saudações, novo " .. player:getVocation():getName():lower() .. "! Desejais partir? Dizei {sim}, ou perguntai por {cidades}.")
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local currentNode = keywordHandler:getLastNode(creature)
	-- Handle other words for nodes while still handling (bye, farewell) keywords
	if #currentNode.children == 0 then
		npcHandler:say(
			"Responderei passo a passo. Usai {sim}, {nao} ou o nome da cidade indicada.",
			npc,
			creature
		)
	elseif currentNode == readyNode then
		npcHandler:say("Respondei {sim} para continuar ou {nao} para voltar à escolha.", npc, creature)
	elseif currentNode == notReadyNode then
		npcHandler:say("Escolhei {sim}, {nao} ou o nome de uma cidade disponível.", npc, creature)
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_FAREWELL, "Quando estiverdes preparado, voltai. O continente vos aguarda!")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table

-- Each NPC owns its return memory and lesson pages; quest state stays authoritative.
local dawnMenu = "Escolhei {passagem}, {cidades} ou {doar}."
local dawnPersonality = "Captain Dreadnought, capitã de voz firme"
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
