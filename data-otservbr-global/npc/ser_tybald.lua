local internalNpcName = "Ser Tybald"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 134,
	lookHead = 97,
	lookBody = 19,
	lookLegs = 60,
	lookFeet = 115,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
	profession = "trader",
}
npcConfig.speechBubble = SPEECHBUBBLE_TRADE

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
    support = { "suporte" }, attack = { "ataque" },
    conjure = { "conjuracao", "conjuração" }, spell = { "magia", "magias" },
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

local woundNode = keywordHandler:addKeyword(dawnKeys({ "wound cleansing" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {wound cleansing} por nenhum custo? Respondei {sim} ou {nao}.",
})
woundNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "wound cleansing",
	vocation = { 4, 8 },
	price = 0,
	level = 8,
})

local brutalNode = keywordHandler:addKeyword(dawnKeys({ "brutal strike" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {brutal strike} por 1000 moedas de ouro? Respondei {sim} ou {nao}.",
})
brutalNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "brutal strike",
	vocation = { 4, 8 },
	price = 1000,
	level = 16,
})

local cureNode = keywordHandler:addKeyword(dawnKeys({ "cure poison" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {cure poison} por 150 moedas de ouro? Respondei {sim} ou {nao}.",
})
cureNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "cure poison",
	vocation = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
	price = 150,
	level = 10,
})

local greatLightNode = keywordHandler:addKeyword(dawnKeys({ "great light" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {great light} por 500 moedas de ouro? Respondei {sim} ou {nao}.",
})
greatLightNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "great light",
	vocation = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
	price = 500,
	level = 13,
})

local findPersonNode = keywordHandler:addKeyword(dawnKeys({ "find person" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {find person} por 80 moedas de ouro? Respondei {sim} ou {nao}.",
})
findPersonNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "find person",
	vocation = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
	price = 80,
	level = 8,
})

local magicRopeNode = keywordHandler:addKeyword(dawnKeys({ "magic rope" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {magic rope} por 200 moedas de ouro? Respondei {sim} ou {nao}.",
})
magicRopeNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "magic rope",
	vocation = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
	price = 200,
	level = 9,
})

local lightHealingNode = keywordHandler:addKeyword(dawnKeys({ "light healing" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {light healing} por nenhum custo? Respondei {sim} ou {nao}.",
})
lightHealingNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "light healing",
	vocation = { 1, 2, 3, 5, 6, 7, 9, 10 },
	price = 0,
	level = 8,
})

local conjureArrowNode = keywordHandler:addKeyword(dawnKeys({ "conjure arrow" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {conjure arrow} por 450 moedas de ouro? Respondei {sim} ou {nao}.",
})
conjureArrowNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "conjure arrow",
	vocation = { 3, 7 },
	price = 450,
	level = 13,
})

local levitateNode = keywordHandler:addKeyword(dawnKeys({ "levitate" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {levitate} por 500 moedas de ouro? Respondei {sim} ou {nao}.",
})
levitateNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "levitate",
	vocation = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
	price = 500,
	level = 12,
})

local hasteNode = keywordHandler:addKeyword(dawnKeys({ "haste" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {haste} por 600 moedas de ouro? Respondei {sim} ou {nao}.",
})
hasteNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "haste",
	vocation = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
	price = 600,
	level = 14,
})

local lightNode = keywordHandler:addKeyword(dawnKeys({ "light" }), StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Desejais aprender a magia {light} por nenhum custo? Respondei {sim} ou {nao}.",
})
lightNode:addChildKeyword(dawnKeys({ "yes" }), StdModule.learnSpell, {
	npcHandler = npcHandler,
	keepDialogOpen = true,
	premium = false,
	spellName = "light",
	vocation = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
	price = 0,
	level = 8,
})

keywordHandler:addKeyword(dawnKeys({ "healing" }), StdModule.say, { npcHandler = npcHandler, text = "Nesta categoria ensino '{Light healing}', '{Wound cleansing}', e '{Cure poison}'." })
keywordHandler:addKeyword(dawnKeys({ "support" }), StdModule.say, { npcHandler = npcHandler, text = "Nesta categoria ensino '{Find person}', '{Magic Rope}', '{Levitate}', '{Light}', '{Great Light}', e '{Haste}'." })
keywordHandler:addKeyword(dawnKeys({ "attack" }), StdModule.say, { npcHandler = npcHandler, text = "Nesta categoria ensino '{Brutal strike}' para Knights." })
keywordHandler:addKeyword(dawnKeys({ "conjure" }), StdModule.say, { npcHandler = npcHandler, text = "Nesta categoria ensino '{Conjure Arrow}' para Paladins." })
keywordHandler:addKeyword(dawnKeys({ "spell" }), StdModule.say, { npcHandler = npcHandler, text = "Posso ensinar magias de {cura}, {suporte}, {conjuracao} e {ataque}. Escolhei uma categoria." })
keywordHandler:addKeyword(dawnKeys({ "name" }), StdModule.say, { npcHandler = npcHandler, text = "Sou Ser Tybald. É uma honra orientar vosso treinamento." })
keywordHandler:addKeyword(dawnKeys({ "job" }), StdModule.say, { npcHandler = npcHandler, text = "Ensino magias para Knights e Paladins. Um guerreiro preparado conhece arma, cura e disciplina." })
keywordHandler:addKeyword(dawnKeys({ "dawnport" }), StdModule.say, { npcHandler = npcHandler, text = "Dawnport é nosso posto de treinamento. Garamond estuda a magia; eu preparo os guerreiros." })
keywordHandler:addKeyword(dawnKeys({ "inigo" }), StdModule.say, { npcHandler = npcHandler, text = "Inigo orienta os novos aventureiros e explica os caminhos do posto." })
keywordHandler:addKeyword(dawnKeys({ "coltrayne" }), StdModule.say, { npcHandler = npcHandler, text = "Coltrayne fornece armas e proteção aos aventureiros de Crystal." })
keywordHandler:addKeyword(dawnKeys({ "garamond" }), StdModule.say, { npcHandler = npcHandler, text = "Garamond ensina magias de Druid e Sorcerer." })
keywordHandler:addKeyword(dawnKeys({ "mr morris" }), StdModule.say, { npcHandler = npcHandler, text = "Morris é um companheiro antigo. Procurai-o para missões e caçadas." })
keywordHandler:addKeyword(dawnKeys({ "plunderpurse" }), StdModule.say, { npcHandler = npcHandler, text = "Plunderpurse guarda vosso ouro no banco." })
keywordHandler:addKeyword(dawnKeys({ "richard" }), StdModule.say, { npcHandler = npcHandler, text = "Richard cuida de comida e ferramentas; preparai provisões antes da jornada." })
keywordHandler:addKeyword(dawnKeys({ "ser tybald" }), StdModule.say, { npcHandler = npcHandler, text = "Ser é um título de respeito. Tybald é o nome pelo qual me conheceis." })
keywordHandler:addKeyword(dawnKeys({ "magic" }), StdModule.say, { npcHandler = npcHandler, text = "Cada vocação possui magias próprias. Conferi os requisitos e aprendei com o instrutor adequado." })
keywordHandler:addKeyword(dawnKeys({ "main" }), StdModule.say, { npcHandler = npcHandler, text = "No continente de Crystal, encontrareis instrutores em muitas cidades." })
keywordHandler:addKeyword(dawnKeys({ "tibia" }), StdModule.say, { npcHandler = npcHandler, text = "Crystal é nosso mundo. O continente oferece novos desafios; preparai-vos em Dawnport antes de partir." })
keywordHandler:addKeyword(dawnKeys({ "oressa" }), StdModule.say, { npcHandler = npcHandler, text = "Oressa cuida da cura e orienta a escolha de vocação no templo. Protegemos juntos os novos aventureiros." })
keywordHandler:addKeyword(dawnKeys({ "menesto" }), StdModule.say, { npcHandler = npcHandler, text = "Menesto é corajoso e guarda a chegada. A coragem deve andar junto da prudência." })
keywordHandler:addKeyword(dawnKeys({ "key" }), StdModule.say, { npcHandler = npcHandler, text = "Aceitai a busca da chave com Morris; Inigo vos indicará o próximo passo." })

npcHandler:setMessage(MESSAGE_GREET, "Saudações, aventureiro. Escolhei {cura}, {suporte}, {conjuracao} ou {ataque}.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Que os ventos vos favoreçam, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "A go-getter. I like that.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table

-- Each NPC owns its return memory and lesson pages; quest state stays authoritative.
local dawnMenu = "Escolhei {cura}, {suporte}, {ataque} ou {conjuracao}."
local dawnPersonality = "Ser Tybald, instrutor cortês e disciplinado"
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
