local internalNpcName = "Ambassador Manop"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1816,
	lookHead = 40,
	lookBody = 9,
	lookLegs = 63,
	lookFeet = 63,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
	profession = "normal",
}
npcConfig.speechBubble = SPEECHBUBBLE_QUEST

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{
		text = "Harmonia. Conhecimento. Força.",
	},
}

local function addMainItems(player)
	local firstItems = {
		slots = {
			[CONST_SLOT_NECKLACE] = Game.createItem(50195),
			[CONST_SLOT_LEFT] = Game.createItem(50171),
			[CONST_SLOT_ARMOR] = Game.createItem(50257),
			[CONST_SLOT_LEGS] = Game.createItem(3559),
			[CONST_SLOT_FEET] = Game.createItem(3552),
		},
	}
	for slot, item in pairs(firstItems.slots) do
		local ret = player:addItemEx(item, false, slot)
		if not ret then
			player:addItemEx(item, false, INDEX_WHEREEVER, 0)
		end
	end
end

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
keywordHandler:addKeyword(dawnKeys({ "three-fold path" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Dizei {buscador} para conhecer os próximos passos de vosso caminho.",
})

keywordHandler:addKeyword(dawnKeys({ "pilgrimage" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "A {peregrinacao} é o Caminho Tríplice dos Monks. Primeiro aceitai meu {convite}, depois visitai um {santuario} e alcançai o nível 8.",
})

keywordHandler:addKeyword(dawnKeys({ "blue valley" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Blue Valley é o lar ancestral dos Merudri e o destino de nossa peregrinação.",
})

keywordHandler:addKeyword(dawnKeys({ "serenity" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Harmonia, conhecimento e força, guiados pelo autocontrole: assim cultivamos a serenidade.",
})

keywordHandler:addKeyword(dawnKeys({ "monks" }), StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"O Monk cultiva alma, mente e corpo. Treinai com disciplina para alcançar {serenidade}.",
		"Nossa força serve para defender e preservar. Usai a violência apenas quando necessária.",
		"Quando lutar for necessário, agi com firmeza e autocontrole.",
	},
})

keywordHandler:addKeyword(dawnKeys({ "merudri" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Somos Merudri, guerreiros Monks que protegem Blue Valley e cultivam {serenidade}.",
})

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local hasQuestLine = player:getStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.QuestLine) > 0
	local hasAtLeastOneShrine = player:getStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportFirstShrine) > 0 or player:getStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportSecondShrine) > 0 or player:getStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportThirdShrine) > 0 or player:getStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportFourthShrine) > 0

	-- Heal and help dialog
	if dawnContains(message, "invitation") and npcHandler:getTopic(playerId) == 0 then
		npcHandler:say("Sou Manop, representante dos Merudri. Posso explicar vosso caminho de Monk. Desejais aceitar meu convite? {sim} ou {nao}.", npc, creature)
		npcHandler:setTopic(playerId, 1)
	elseif dawnContains(message, "yes") and player:getVocation():getBaseId() == VOCATION.BASE_ID.MONK then
		if npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.QuestLine) < 1 then
			npcHandler:say("Convite aceito, {buscador}. Visitai pelo menos um dos quatro {santuarios} de Dawnport e alcançai o nível 8. Depois voltai e dizei {buscador}.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.QuestLine, 1)
			player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.Missions.TreeFoldPath, 1)
			player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportFirstShrine, 0)
			player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportSecondShrine, 0)
			player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportThirdShrine, 0)
			player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.DawnportFourthShrine, 0)
		elseif npcHandler:getTopic(playerId) == 2 and hasQuestLine and hasAtLeastOneShrine and player:getLevel() >= 8 and player:getStorageValue(Storage.Dawnport.Mainland) ~= 1 then
			removeMainlandSmugglingItems(player)
			local town = Town(TOWNS_LIST.THAIS)
			player:setTown(town)
			player:teleportTo(Position(33614, 31494, 7)) -- Teleport to Blue Valley
			addMainItems(player)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:setStorageValue(Storage.Dawnport.Mainland, 1)
			player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.Missions.TreeFoldPath, 2)
			-- Only initialize the counter: this acceptance branch can be reached again and
			-- shrines.lua uses it as the sole progress state -- resetting it would allow
			-- redoing the shrines and collecting their rewards again.
			if player:getStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.ShrinesCount) < 1 then
				player:setStorageValue(Storage.Quest.U14_15.TheWayOfTheMonk.ShrinesCount, 1)
			end
			npcHandler:setTopic(playerId, 0)
			npcHandler:say("Agora sois peregrino do Caminho Tríplice. Bem-vindo a Blue Valley!", npc, creature)
		end
	elseif dawnContains(message, "seeker") and npcHandler:getTopic(playerId) == 0 and player:getVocation():getBaseId() == VOCATION.BASE_ID.MONK then
		if not hasQuestLine then
            npcHandler:say("Começai pelo {convite}; depois visitai um {santuario}.", npc, creature)
        elseif player:getLevel() < 8 then
			npcHandler:say("Vosso treinamento prossegue. Alcançai o nível 8 antes de voltar para a partida.", npc, creature)
		elseif hasQuestLine and not hasAtLeastOneShrine then
			npcHandler:say("Antes da partida, visitai pelo menos um {santuario} de Dawnport. Marquei os quatro no mapa. Usai um deles e retornai.", npc, creature)
		else
            npcHandler:say({
                "O Caminho Tríplice vos levará a Blue Valley para continuar o treinamento de Monk.",
                "Ao confirmar, deixareis Dawnport e recebereis equipamento em Blue Valley. Não há retorno por este diálogo. Aceitais? {sim} ou {nao}.",
            }, npc, creature, 10)
			npcHandler:setTopic(playerId, 2)
		end
	end
	return true
end

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()
	npcHandler:setMessage(MESSAGE_GREET, "Saudações, viajante. Sou Manop. Escolhei {convite}, {peregrinacao}, {santuarios} ou {serenidade}.")
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:setMessage(MESSAGE_FAREWELL, "Boa viagem, peregrino.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Harmonia. Conhecimento. Força.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table

-- Each NPC owns its return memory and lesson pages; quest state stays authoritative.
local dawnMenu = "Escolhei {convite}, {buscador}, {santuarios}, {peregrinacao} ou {serenidade}."
local dawnPersonality = "Manop, mestre sereno dos Merudri"
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
    if MsgContains(message,"santuario") or MsgContains(message,"santuário") or MsgContains(message,"santuarios") or MsgContains(message,"santuários") then
        local text = "Marquei quatro santuários em Dawnport. Após aceitar o convite como Monk, usai pelo menos um, alcançai o nível 8 e voltai dizendo buscador."
        dawnMark(player,text); dawnRawSay(npcHandler,text,npc,player); return
    end
    if dawnContains(message,"invitation") and player:getVocation():getBaseId() ~= VOCATION.BASE_ID.MONK then
        dawnRawSay(npcHandler,"Este caminho exige que estejais treinando como Monk. Inigo pode orientar vosso treinamento.",npc,player);return
    end
    if dawnContains(message,"no") then npcHandler:setTopic(id,0);dawnRawSay(npcHandler,"Como desejardes. Preparai-vos com calma; falai de convite ou buscador quando retornardes.",npc,player);return end
    return dawnOriginalOnSay(npc, creature, type, message)
end

npcType:register(npcConfig)
