local internalNpcName = "Plunderpurse"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 114,
	lookBody = 131,
	lookLegs = 0,
	lookFeet = 20,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
	profession = "banker",
}
npcConfig.speechBubble = SPEECHBUBBLE_BANKER

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Guardai vosso ouro com prudência!" },
	{ text = "Não carregueis todo vosso ouro! Guardai-o no banco." },
	{ text = "Depositai vosso ouro e caçai com a mochila mais leve!" },
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

local count = {}
local function greetCallback(npc, creature)
	local playerId = creature:getId()
	count[playerId] = nil
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	--Help
	if dawnContains(message, "bank account") then
		npcHandler:say({
			"Todo aventureiro possui uma conta. Vosso ouro fica disponível nas agências do Banco de Crystal.",
			"Escolhei serviços {basicos} ou {avancados}. Posso explicar antes de movimentar vosso ouro.",
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 0)
		return true
		--Balance
	elseif dawnContains(message, "balance") then
		npcHandler:setTopic(playerId, 0)
		if player:getBankBalance() >= 100000000 then
			npcHandler:say("Arrr, sois dos mais ricos de Crystal! Vosso saldo é de " .. player:getBankBalance() .. " moedas de ouro.", npc, creature)
			return true
		elseif player:getBankBalance() >= 10000000 then
			npcHandler:say("Dez milhões e a fortuna cresce! Vosso saldo é de " .. player:getBankBalance() .. " moedas de ouro.", npc, creature)
			return true
		elseif player:getBankBalance() >= 1000000 then
			npcHandler:say("Um milhão de moedas! Vosso saldo é de " .. player:getBankBalance() .. " moedas de ouro!", npc, creature)
			return true
		elseif player:getBankBalance() >= 100000 then
			npcHandler:say("Uma bela reserva. Vosso saldo é de " .. player:getBankBalance() .. " moedas de ouro.", npc, creature)
			return true
		else
			npcHandler:say("Vosso saldo é de " .. player:getBankBalance() .. " moedas de ouro.", npc, creature)
			return true
		end
		--Deposit
	elseif dawnContains(message, "deposit") then
		count[playerId] = player:getMoney()
		if count[playerId] < 1 then
			npcHandler:say("Não tendes ouro suficiente.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		elseif not isValidMoney(count[playerId]) then
			npcHandler:say("Não posso aceitar esse valor de depósito.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end
		if dawnContains(message, "all") then
			count[playerId] = player:getMoney()
			npcHandler:say("Desejais depositar " .. count[playerId] .. " moedas de ouro?", npc, creature)
			npcHandler:setTopic(playerId, 2)
			return true
		else
			if string.match(message, "%d+") then
				count[playerId] = getMoneyCount(message)
				if count[playerId] < 1 then
					npcHandler:say("Não tendes ouro suficiente.", npc, creature)
					npcHandler:setTopic(playerId, 0)
					return false
				end
				npcHandler:say("Desejais depositar " .. count[playerId] .. " moedas de ouro?", npc, creature)
				npcHandler:setTopic(playerId, 2)
				return true
			else
				npcHandler:say("Dizei-me quanto ouro desejais depositar, ou escolhei {tudo}.", npc, creature)
				npcHandler:setTopic(playerId, 1)
				return true
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		count[playerId] = dawnContains(message, "all") and player:getMoney() or getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:say("Desejais depositar " .. count[playerId] .. " moedas de ouro?", npc, creature)
			npcHandler:setTopic(playerId, 2)
			return true
		else
			npcHandler:say("Não tendes ouro suficiente.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if dawnContains(message, "yes") then
			if count[playerId] > 1500 or player:getBankBalance() >= 1500 then
				npcHandler:say("Não posso aceitar esse valor de depósito.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return false
			end
			if player:depositMoney(count[playerId]) then
				npcHandler:say("Acrescentamos " .. count[playerId] .. " moedas de ouro ao vosso {saldo}. Podeis {sacar} quando desejardes.", npc, creature)
			else
				npcHandler:say("Não tendes ouro suficiente.", npc, creature)
			end
		elseif dawnContains(message, "no") then
			npcHandler:say("Como desejardes. Posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
		--Withdraw
	elseif dawnContains(message, "withdraw") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:say("Desejais sacar " .. count[playerId] .. " moedas de ouro de vossa conta?", npc, creature)
				npcHandler:setTopic(playerId, 7)
			else
				npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
			return true
		else
			npcHandler:say("Dizei-me quanto ouro desejais sacar.", npc, creature)
			npcHandler:setTopic(playerId, 6)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:say("Desejais sacar " .. count[playerId] .. " moedas de ouro de vossa conta?", npc, creature)
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 7 then
		if dawnContains(message, "yes") then
			if player:getFreeCapacity() >= getMoneyWeight(count[playerId]) then
				if not player:withdrawMoney(count[playerId]) then
					npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
				else
					npcHandler:say("Aqui estão " .. count[playerId] .. " moedas de ouro. Posso ajudar-vos em algo mais?", npc, creature)
				end
			else
				npcHandler:say(
					"Não tendes espaço ou capacidade para todas essas moedas. Liberai vossa mochila antes de sacar.",
					npc,
					creature
				)
			end
			npcHandler:setTopic(playerId, 0)
		elseif dawnContains(message, "no") then
			npcHandler:say("Vossa vontade é lei! Voltai quando desejardes {sacar}.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
		--Money exchange
	elseif dawnContains(message, "change gold") then
		npcHandler:say("Quantas moedas de platina desejais receber?", npc, creature)
		npcHandler:setTopic(playerId, 14)
	elseif npcHandler:getTopic(playerId) == 14 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Não tendes moedas de ouro suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("Desejais trocar " .. count[playerId] * 100 .. " moedas de ouro por " .. count[playerId] .. " moedas de platina?", npc, creature)
			npcHandler:setTopic(playerId, 15)
		end
	elseif npcHandler:getTopic(playerId) == 15 then
		if dawnContains(message, "yes") then
			if player:removeItem(3031, count[playerId] * 100) then
				player:addItem(3035, count[playerId])
				npcHandler:say("Aqui tendes.", npc, creature)
			else
				npcHandler:say("Não tendes moedas de ouro suficientes.", npc, creature)
			end
		else
			npcHandler:say("Posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif dawnContains(message, "change platinum") then
		npcHandler:say("Desejais trocar platina por {ouro} ou {cristal}?", npc, creature)
		npcHandler:setTopic(playerId, 16)
	elseif npcHandler:getTopic(playerId) == 16 then
		if dawnContains(message, "gold") then
			npcHandler:say("Quantas moedas de platina desejais trocar por ouro?", npc, creature)
			npcHandler:setTopic(playerId, 17)
		elseif dawnContains(message, "crystal") then
			npcHandler:say("Quantas moedas de cristal desejais receber?", npc, creature)
			npcHandler:setTopic(playerId, 19)
		else
			npcHandler:say("Posso ajudar-vos em algo mais?", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 17 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Não tendes moedas de platina suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("Desejais trocar " .. count[playerId] .. " moedas de platina por " .. count[playerId] * 100 .. " moedas de ouro?", npc, creature)
			npcHandler:setTopic(playerId, 18)
		end
	elseif npcHandler:getTopic(playerId) == 18 then
		if dawnContains(message, "yes") then
			if player:removeItem(3035, count[playerId]) then
				player:addItem(3031, count[playerId] * 100)
				npcHandler:say("Aqui tendes.", npc, creature)
			else
				npcHandler:say("Não tendes moedas de platina suficientes.", npc, creature)
			end
		else
			npcHandler:say("Posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Não tendes moedas de platina suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("Desejais trocar " .. count[playerId] * 100 .. " moedas de platina por " .. count[playerId] .. " moedas de cristal?", npc, creature)
			npcHandler:setTopic(playerId, 20)
		end
	elseif npcHandler:getTopic(playerId) == 20 then
		if dawnContains(message, "yes") then
			if player:removeItem(3035, count[playerId] * 100) then
				player:addItem(3043, count[playerId])
				npcHandler:say("Aqui tendes.", npc, creature)
			else
				npcHandler:say("Não tendes moedas de platina suficientes.", npc, creature)
			end
		else
			npcHandler:say("Posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif dawnContains(message, "change crystal") then
		npcHandler:say("Quantas moedas de cristal desejais trocar por platina?", npc, creature)
		npcHandler:setTopic(playerId, 21)
	elseif npcHandler:getTopic(playerId) == 21 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Não tendes moedas de cristal suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("Desejais trocar " .. count[playerId] .. " moedas de cristal por " .. count[playerId] * 100 .. " moedas de platina?", npc, creature)
			npcHandler:setTopic(playerId, 22)
		end
	elseif npcHandler:getTopic(playerId) == 22 then
		if dawnContains(message, "yes") then
			if player:removeItem(3043, count[playerId]) then
				player:addItem(3035, count[playerId] * 100)
				npcHandler:say("Aqui tendes.", npc, creature)
			else
				npcHandler:say("Não tendes moedas de cristal suficientes.", npc, creature)
			end
		else
			npcHandler:say("Posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword(dawnKeys({ "dawnport" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Dawnport é nossa ilha de treinamento. Preparai-vos antes de partir.",
})
keywordHandler:addKeyword(dawnKeys({ "change" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Ouro e rum, arr! Mas primeiro os negócios: escolhei {depositar}, {sacar} ou {saldo}.",
})
keywordHandler:addKeyword(dawnKeys({ "bank" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Aqui podeis depositar e sacar ouro de vossa conta bancária.",
})
keywordHandler:addKeyword(dawnKeys({ "advanced" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "No continente de Crystal, encontrareis outros serviços bancários, como transferências e operações do mercado.",
})
keywordHandler:addKeyword(dawnKeys({ "name" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Abram Plunderpurse, a vosso serviço!",
})
keywordHandler:addKeyword(dawnKeys({ "functions" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Guardo vosso ouro enquanto caçais. Dizei {saldo} para consultar, {depositar} para guardar ou {sacar} para retirar.",
})
keywordHandler:addKeyword(dawnKeys({ "rookgaard" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Rookgaard? Inigo conhece as condições de viagem para essa ilha.",
})
keywordHandler:addKeyword(dawnKeys({ "job" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Sou um pira... um banqueiro, arr! Escolhei {saldo}, {depositar} ou {sacar}.",
})
keywordHandler:addKeyword(dawnKeys({ "mainland" }), StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Crystal é vasto e cheio de portos! Alguns destinos exigem premium; consultai o capitão antes de partir.",
		"Ao nível 8, escolhei vossa vocação definitiva e preparai a partida.",
	},
})
keywordHandler:addKeyword(dawnKeys({ "vocation" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Oressa orienta Knight, Sorcerer, Paladin e Druid; Manop orienta Monk.",
})
keywordHandler:addKeyword(dawnKeys({ "transfer" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Esse serviço fica disponível no continente. Aqui posso cuidar de depósitos, saques e moedas.",
})
keywordHandler:addKeyword(dawnKeys({ "inigo" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Inigo ensina os primeiros passos e conhece a ilha. Pedi {ajuda} a ele.",
})
keywordHandler:addKeyword(dawnKeys({ "coltrayne" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Coltrayne é um ferreiro reservado. Fornece boas armas e proteção.",
})
keywordHandler:addKeyword(dawnKeys({ "garamond" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Garamond ensina magias de Sorcerer e Druid.",
})
keywordHandler:addKeyword(dawnKeys({ "hamish" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Hamish prepara poções e suprimentos mágicos.",
})
keywordHandler:addKeyword(dawnKeys({ "richard" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Richard vende comida e ferramentas. Conferi vossa corda antes de explorar.",
})
keywordHandler:addKeyword(dawnKeys({ "mr morris" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Morris oferece tarefas. Perguntai por {missoes} ao visitá-lo.",
})
keywordHandler:addKeyword(dawnKeys({ "oressa" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Oressa ajuda com cura e escolha de vocação no templo.",
})
keywordHandler:addKeyword(dawnKeys({ "plunderpurse" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Plunderpurse é meu nome, arr! Vosso ouro será bem guardado.",
})
keywordHandler:addKeyword(dawnKeys({ "quest" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Missões? Procurai Mr Morris. Eu cuido das moedas.",
})
keywordHandler:addKeyword(dawnKeys({ "ser tybald" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Ser Tybald ensina magias de Knight e Paladin.",
})
keywordHandler:addKeyword(dawnKeys({ "wentworth" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Wentworth conhece a administração bancária; eu atendo neste posto.",
})
keywordHandler:addKeyword(dawnKeys({ "key" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "A chave? Morris começa a missão e Inigo fornece a pista.",
})

npcHandler:setMessage(
	MESSAGE_GREET,
	"Saudações, aventureiro! Escolhei {saldo}, {depositar}, {sacar}, {trocar ouro}, {trocar platina} ou {trocar cristal}."
)
npcHandler:setMessage(MESSAGE_FAREWELL, "Tenha um bom dia.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Tenha um bom dia.")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table

-- Each NPC owns its return memory and lesson pages; quest state stays authoritative.
local dawnMenu = "Escolhei {saldo}, {depositar}, {sacar}, {trocar ouro}, {trocar platina} ou {trocar cristal}."
local dawnPersonality = "Plunderpurse, banqueiro de modos de corsário"
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
