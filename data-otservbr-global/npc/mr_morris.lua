local internalNpcName = "Mr Morris"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 289,
	lookHead = 115,
	lookBody = 114,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
	profession = "banker",
}
npcConfig.speechBubble = SPEECHBUBBLE_BANKER

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Tenho missões para aventureiros atentos. Interessado?" },
	{ text = "Uma investigação exige olhos atentos. Podeis ajudar-me?" },
	{ text = "Há trabalho de pesquisa e caça. Ofereceis vossos serviços?" },
	{ text = "Aventureiro, vossa ajuda será bem-vinda." },
	{
		text = "Precisamos conter os monstros da ilha. Perguntai-me por {cacadas}.",
	},
	{ text = "Tanto a investigar, tão pouco tempo!" },
	{ text = "Trazei os resultados de vossas missões." },
	{ text = "Precisais de uma tarefa? Perguntai por {missoes}." },
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if dawnContains(message, "amulet") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet) < 1 then
			npcHandler:say({
				"Dormovo perdeu um antigo amuleto antes de morrer. Recuperai-o para minha pesquisa e recebereis 50 moedas de ouro. Aceitais? {sim} ou {nao}.",
			}, npc, creature, 10)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet) == 2 and player:getItemCount(21379) >= 1 then
			npcHandler:say({
				"Encontrastes o amuleto de Dormovo. A pesquisa prosseguirá. Aqui estão vossas 50 moedas de ouro.",
			}, npc, creature, 0)
			player:removeItem(21379, 1)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet, 3)
			npcHandler:setTopic(playerId, 0)
		end
	elseif dawnContains(message, "log book") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheStolenLogBook) < 1 then
			npcHandler:say(
				"Os trolls roubaram nosso diário de expedição. Recuperai-o nas cavernas ao norte por 50 moedas de ouro. Aceitais? {sim} ou {nao}.",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TornLogBook) == 1 and player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheStolenLogBook) == 1 and player:getItemCount(21378) >= 1 then
			npcHandler:say(
				"Este é o diário! Ainda podemos ler as anotações. Aqui estão vossas 50 moedas de ouro.",
				npc,
				creature
			)
			player:removeItem(21378, 1)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheStolenLogBook, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif dawnContains(message, "herbs") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb) < 1 then
			npcHandler:say(
				"As salamandras destruíram as ervas Dawnfire de Oressa. Podeis colher novos brotos por 50 moedas de ouro? {sim} ou {nao}.",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb) == 2 then
			npcHandler:say(
				"Brotos frescos, excelente! Aqui estão vossas 50 moedas de ouro.",
				npc,
				creature
			)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb, 3)
			npcHandler:setTopic(playerId, 0)
		end
	elseif dawnContains(message, "key") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey) < 1 then
			npcHandler:say(
				"A chave do dormitório desapareceu. Investigai com {Inigo} e recuperai-a por 50 moedas de ouro. Aceitais? {sim} ou {nao}.",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey) == 4 then
			npcHandler:say("Trouxestes a {chave}? Confirmareis a entrega com {sim}.", npc, creature)
			npcHandler:setTopic(playerId, 5)
		end
	elseif dawnContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:say(
				"Missão aceita. Usai uma pá na areia marcada no mapa, em 32099, 31933, andar 7. Talvez preciseis de várias tentativas. Depois voltai com o {amuleto}.",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:say(
				"Missão aceita. Procurai o diário no recipiente marcado nas cavernas, em 32059, 31800, andar 10. Voltai com o {diario}.",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheStolenLogBook, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			npcHandler:say({
				"A erva Dawnfire ajuda a tratar mordidas. Precisamos de seus brotos.",
				"Procurai flores amarelas brilhantes em areia cinza clara, perto de vaga-lumes. Usai a planta e voltai dizendo {ervas}. A coleta será registrada em vossa missão.",
			}, npc, creature, 10)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.HerbFlower, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			npcHandler:say("Missão aceita. Falai com {Inigo} sobre a {chave}; ele vos indicará Woblin, a oeste. Voltai quando recuperardes a chave.", npc, creature)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
            if player:getItemCount(21392) < 1 then
                npcHandler:say("Não tendes a chave. Recuperai-a com Woblin antes da entrega.", npc, creature)
                npcHandler:setTopic(playerId, 0)
                return true
            end
			npcHandler:say("A chave do dormitório, finalmente! Boa investigação. Aqui estão vossas 50 moedas de ouro.", npc, creature)
			player:removeItem(21392, 1)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey, 5)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			npcHandler:say(
				"Tarefa aceita. Derrotai 20 criaturas do tipo escolhido e voltai a mim. Apenas mortes após aceitar contam. Cuidai de vossa vida!",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisTrollCount, 0)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			npcHandler:say(
				"Tarefa aceita. Derrotai 20 criaturas do tipo escolhido e voltai a mim. Apenas mortes após aceitar contam. Cuidai de vossa vida!",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblinCount, 0)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			npcHandler:say(
				"Tarefa aceita. Derrotai 20 criaturas do tipo escolhido e voltai a mim. Apenas mortes após aceitar contam. Cuidai de vossa vida!",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinosCount, 0)
			npcHandler:setTopic(playerId, 0)
		end
		--End mission
		--Start Task
	elseif dawnContains(message, "trolls") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll) < 1 then
			npcHandler:say({
				"Mountain Trolls roubaram provisões do posto. Precisamos reduzir suas investidas.",
				"Derrotai 20 Mountain Trolls por 50 moedas de ouro. Aceitais? {sim} ou {nao}.",
			}, npc, creature, 10)
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll) == 1 then
			if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisTrollCount) >= 20 then
				npcHandler:say("Tarefa concluída. Aqui estão vossas 50 moedas de ouro.", npc, creature)
				player:setStorageValue(14898, 1)
				player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll, 2)
				player:addItem(3031, 50)
			else
				npcHandler:say("Ainda faltam mortes. Voltai após derrotar 20 Mountain Trolls.", npc, creature)
			end
		end
	elseif dawnContains(message, "goblins") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin) < 1 then
			npcHandler:say({
				"Os Muglex Clan Footmen atacam nossas provisões. Precisamos conter esse grupo.",
				"Derrotai 20 Muglex Clan Footmen por 50 moedas de ouro. Aceitais? {sim} ou {nao}.",
			}, npc, creature, 10)
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin) == 1 then
			if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblinCount) >= 20 then
				npcHandler:say("Tarefa concluída. Aqui estão vossas 50 moedas de ouro.", npc, creature)
				player:setStorageValue(14899, 1)
				player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin, 2)
				player:addItem(3031, 50)
			else
				npcHandler:say("Voltai após derrotar 20 Muglex Clan Footmen.", npc, creature)
			end
		end
	elseif dawnContains(message, "minotaur") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos) < 1 then
			npcHandler:say({
				"Minotaur Bruisers são perigosos. Preparai equipamento e, se necessário, um grupo.",
				"Derrotai 20 Minotaur Bruisers por 50 moedas de ouro. Aceitais? {sim} ou {nao}.",
			}, npc, creature, 10)
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos) == 1 then
			if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinosCount) >= 20 then
				npcHandler:say("Tarefa concluída. Aqui estão vossas 50 moedas de ouro.", npc, creature)
				player:setStorageValue(14900, 1)
				player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos, 2)
				player:addItem(3031, 50)
			else
				npcHandler:say("Voltai após derrotar 20 Minotaur Bruisers.", npc, creature)
			end
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos) == 2 then
			npcHandler:say("Já recebestes a recompensa desta tarefa.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addKeyword(dawnKeys({ "quest" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Escolhei {buscas} para recuperar objetos ou {cacadas} para combater monstros. Todas são opcionais e rendem 50 moedas de ouro cada.",
})
keywordHandler:addKeyword(dawnKeys({ "mission" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Escolhei {buscas} para recuperar objetos ou {cacadas} para combater monstros. Todas são opcionais e rendem 50 moedas de ouro cada.",
})
keywordHandler:addKeyword(dawnKeys({ "fetch" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Escolhei uma busca: {amuleto}, {diario}, {ervas} ou {chave}. Explicarei a tarefa antes de pedir confirmação.",
})
keywordHandler:addKeyword(dawnKeys({ "kill" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Escolhei a caça: {trolls}, {goblins} ou {minotauros}. Cada tarefa pede 20 mortes após a aceitação.",
})
keywordHandler:addKeyword(dawnKeys({ "name" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Chamem-me Mr Morris.",
})
keywordHandler:addKeyword(dawnKeys({ "job" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Sou pesquisador. Organizo investigações e tarefas para os aventureiros do posto.",
})
keywordHandler:addKeyword(dawnKeys({ "dawnport" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Dawnport reúne vestígios antigos. Aqui aprendereis a explorar com cuidado.",
})
keywordHandler:addKeyword(dawnKeys({ "secrets of dawnport" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Estudo o portal e os vestígios da ilha. Por ora, posso dar-vos objetivos claros: {buscas} ou {cacadas}.",
})
keywordHandler:addKeyword(dawnKeys({ "archeological" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "As ruínas revelam os antigos habitantes da ilha. Recuperar objetos ajuda minha pesquisa.",
})
keywordHandler:addKeyword(dawnKeys({ "rookgaard" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Rookgaard é outra ilha de treinamento. Inigo pode explicar as condições de viagem.",
})
keywordHandler:addKeyword(dawnKeys({ "coltrayne" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Coltrayne fornece armas, armaduras e munição. Preparai-vos antes de caçar.",
})
keywordHandler:addKeyword(dawnKeys({ "garamond" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Garamond ensina magias de Druid e Sorcerer.",
})
keywordHandler:addKeyword(dawnKeys({ "hamish" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Hamish fornece poções e equipamento mágico para as caçadas.",
})
keywordHandler:addKeyword(dawnKeys({ "mr morris" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Mr Morris, exatamente. Agora, às tarefas!",
})
keywordHandler:addKeyword(dawnKeys({ "oressa" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Oressa ajuda na cura e na escolha definitiva de vocação.",
})
keywordHandler:addKeyword(dawnKeys({ "plunderpurse" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Plunderpurse guarda vosso ouro. Perguntai por {saldo} ao visitá-lo.",
})
keywordHandler:addKeyword(dawnKeys({ "inigo" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Inigo é nosso mentor. Ele explica cada assunto do treinamento e indica os caminhos.",
})
keywordHandler:addKeyword(dawnKeys({ "richard" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Richard fornece comida e ferramentas, incluindo corda e pá.",
})
keywordHandler:addKeyword(dawnKeys({ "ser tybald" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Ser Tybald ensina magias de Knight e Paladin.",
})
keywordHandler:addKeyword(dawnKeys({ "wentworth" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Wentworth conhece a administração bancária. Plunderpurse atende aqui no posto.",
})
keywordHandler:addKeyword(dawnKeys({ "menesto" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Menesto guarda a caverna de chegada. Inigo vos orientará no posto.",
})
keywordHandler:addKeyword(dawnKeys({ "woblin" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Woblin vive numa caverna a oeste e participa da busca da chave.",
})

npcHandler:setMessage(
	MESSAGE_GREET,
	"Saudações, aventureiro. Sou Mr Morris. Escolhei {buscas} ou {cacadas}; posso também mostrar vosso {progresso}."
)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_FAREWELL, "Vigiai vossa retaguarda, aventureiro.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Voltai quando estiverdes preparado.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table

-- Each NPC owns its return memory and lesson pages; quest state stays authoritative.
local dawnMenu = "Escolhei {buscas}, {cacadas} ou {progresso}."
local dawnPersonality = "Mr Morris, pesquisador metódico"
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
    if MsgContains(message, "progresso") then
        local q = Storage.Quest.U10_55.Dawnport
        local lines = {}
        for _, entry in ipairs({ {"Amuleto",q.TheLostAmulet,3}, {"Diário",q.TheStolenLogBook,2}, {"Ervas",q.TheRareHerb,3}, {"Chave",q.TheDormKey,5} }) do
            local value = player:getStorageValue(entry[2])
            lines[#lines+1] = entry[1] .. ": " .. (value >= entry[3] and "concluída" or value >= 1 and "em andamento; dizei o nome da missão" or "não iniciada")
        end
        for _, entry in ipairs({ {"Trolls",q.MorriskTroll,q.MorrisTrollCount}, {"Goblins",q.MorrisGoblin,q.MorrisGoblinCount}, {"Minotauros",q.MorrisMinos,q.MorrisMinosCount} }) do
            local accepted = player:getStorageValue(entry[2])
            lines[#lines+1] = entry[1] .. ": " .. (accepted >= 2 and "recompensa recebida" or accepted == 1 and math.max(0,player:getStorageValue(entry[3])) .. "/20" or "não iniciada")
        end
        dawnRawSay(npcHandler, table.concat(lines, "; ") .. ".", npc, player); return
    end
    if dawnContains(message,"amulet") or dawnContains(message,"log book") or dawnContains(message,"herbs") or dawnContains(message,"key") then
        local q=Storage.Quest.U10_55.Dawnport
        local entries={ {"amulet",q.TheLostAmulet,3,"Usai uma pá na areia em 32099, 31933, andar 7. Voltai com o amuleto."}, {"log book",q.TheStolenLogBook,2,"Recuperai o diário em 32059, 31800, andar 10, e voltai com o item."}, {"herbs",q.TheRareHerb,3,"Usai a planta Dawnfire com flores amarelas em areia clara e voltai com a coleta registrada."}, {"key",q.TheDormKey,5,"Falai com Inigo e depois com Woblin para trocar Old Nasty pela chave."} }
        for _,e in ipairs(entries) do
            if dawnContains(message,e[1]) then
                local progress=player:getStorageValue(e[2])
                if progress>=e[3] then dawnRawSay(npcHandler,"Já concluístes esta missão e recebestes a recompensa.",npc,player);return end
                if progress==1 and not (e[1]=="log book" and player:getStorageValue(q.TornLogBook)==1 and player:getItemCount(21378)>0) then dawnMark(player,e[4]);dawnRawSay(npcHandler,e[4],npc,player);return end
            end
        end
    end
    return dawnOriginalOnSay(npc, creature, type, message)
end

npcType:register(npcConfig)
