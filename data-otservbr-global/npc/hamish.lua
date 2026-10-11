local internalNpcName = "Hamish"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 133,
	lookHead = 19,
	lookBody = 95,
	lookLegs = 87,
	lookFeet = 128,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
	profession = "trader",
}
npcConfig.speechBubble = SPEECHBUBBLE_TRADE

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Esse é o espírito!" },
	{ text = "Poções, varinhas e runas! Preparai vossa bolsa!" },
	{ text = "Subistes de nível? Conferi os requisitos de vossa varinha antes de comprar." },
	{ text = "Mana acabando? Pedi {pocoes} e preparai-vos!" },
	{ text = "Precisais de magia extra? Conferi as runas disponíveis." },
	{ text = "Contra vários monstros, usai recursos adequados e evitai ser cercado." },
	{ text = "Poções de vida ajudam durante a luta!" },
	{ text = "Conferi os serviços disponíveis para frascos e suprimentos na {loja}." },
	{ text = "Cuidado com minhas misturas! Escolhei {pocoes}, {varinhas} ou {runas}." },
	{ text = "Poções de mana para vossas magias!" },
}

local itemsTable = {
	["potions"] = {
		{ itemName = "health potion", clientId = 266, buy = 50 },
		{ itemName = "mana potion", clientId = 268, buy = 56 },
		{ itemName = "small health potion", clientId = 7876, buy = 20 },
	},
	["runes"] = {
		{ itemName = "blank rune", clientId = 3147, buy = 10 },
	},
	["wands"] = {
		{ itemName = "moonlight rod", clientId = 3070, buy = 1000 },
		{ itemName = "necrotic rod", clientId = 3069, buy = 5000 },
		{ itemName = "snakebite rod", clientId = 3066, buy = 500 },
		{ itemName = "wand of decay", clientId = 3072, buy = 5000 },
		{ itemName = "wand of dragonbreath", clientId = 3075, buy = 1000 },
		{ itemName = "wand of vortex", clientId = 3074, buy = 500 },
	},
}

npcConfig.shop = {}
for _, categoryTable in pairs(itemsTable) do
	for _, itemTable in ipairs(categoryTable) do
		table.insert(npcConfig.shop, itemTable)
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

keywordHandler:addKeyword(dawnKeys({ "name" }), StdModule.say, { npcHandler = npcHandler, text = "Hamish MacGuffin, alquimista a vosso serviço!" })
keywordHandler:addKeyword(dawnKeys({ "job" }), StdModule.say, { npcHandler = npcHandler, text = "Preparo poções e equipamento mágico. Dizei {loja} e conferi preço, nível e vocação antes de comprar." })
keywordHandler:addKeyword(dawnKeys({ "rookgaard" }), StdModule.say, { npcHandler = npcHandler, text = "Rookgaard? Não conheço. Inigo vos orientará." })
keywordHandler:addKeyword(dawnKeys({ "coltrayne" }), StdModule.say, { npcHandler = npcHandler, text = "Coltrayne é reservado, mas forja bom equipamento." })
keywordHandler:addKeyword(dawnKeys({ "inigo" }), StdModule.say, { npcHandler = npcHandler, text = "Inigo conhece a ilha e ensina os primeiros passos. Perguntai-lhe por {ajuda}." })
keywordHandler:addKeyword(dawnKeys({ "garamond" }), StdModule.say, { npcHandler = npcHandler, text = "Garamond é exigente, mas conhece muitas magias." })
keywordHandler:addKeyword(dawnKeys({ "wentworth" }), StdModule.say, { npcHandler = npcHandler, text = "Wentworth aprecia números; para o banco daqui, procurai Plunderpurse." })
keywordHandler:addKeyword(dawnKeys({ "richard" }), StdModule.say, { npcHandler = npcHandler, text = "Richard cuida de comida e ferramentas. É bom ter provisões antes da caçada." })
keywordHandler:addKeyword(dawnKeys({ "mr morris" }), StdModule.say, { npcHandler = npcHandler, text = "Morris reuniu nossa expedição e oferece tarefas para investigar Dawnport." })
keywordHandler:addKeyword(dawnKeys({ "oressa" }), StdModule.say, { npcHandler = npcHandler, text = "Oressa fica no templo. Ela cuida da cura e da escolha de vocação." })
keywordHandler:addKeyword(dawnKeys({ "plunderpurse" }), StdModule.say, { npcHandler = npcHandler, text = "Plunderpurse guarda vosso ouro. Não precisais carregá-lo todo numa caçada." })
keywordHandler:addKeyword(dawnKeys({ "ser tybald" }), StdModule.say, { npcHandler = npcHandler, text = "Ser Tybald ensina magias de Knight e Paladin." })
keywordHandler:addKeyword(dawnKeys({ "menesto" }), StdModule.say, { npcHandler = npcHandler, text = "Menesto guarda a caverna. Se precisardes de cura, procurai {Oressa}." })
keywordHandler:addKeyword(dawnKeys({ "potions" }), StdModule.say, { npcHandler = npcHandler, text = "Conferi as poções. Também podeis pedir {varinhas} ou {runas}." })
keywordHandler:addKeyword(dawnKeys({ "wands" }), StdModule.say, { npcHandler = npcHandler, text = "Conferi as varinhas. Também podeis pedir {pocoes} ou {runas}." })
keywordHandler:addKeyword(dawnKeys({ "runes" }), StdModule.say, { npcHandler = npcHandler, text = "Conferi as runas. Também podeis pedir {pocoes} ou {varinhas}." })
keywordHandler:addKeyword(dawnKeys({ "dawnport" }),
	StdModule.say,
	{ npcHandler = npcHandler, text = "Dawnport oferece treinamento, mas os monstros exigem cuidado. Preparai comida, cura e mana antes de explorar. Pedi {loja} para consultar meus suprimentos." }
)
keywordHandler:addKeyword(dawnKeys({ "main" }), StdModule.say, {
	npcHandler = npcHandler,
	text = "Ao nível 8, escolhei a vocação definitiva e preparai a partida para o continente de Crystal. Antes disso, treinai e experimentai as vocações.",
})
keywordHandler:addKeyword(dawnKeys({ "key" }), StdModule.say, { npcHandler = npcHandler, text = "A chave? Perguntai a Morris sobre a missão e a Inigo sobre Woblin." })

npcHandler:setMessage(MESSAGE_GREET, "Saudações! Minha alquimia está a vosso serviço. Escolhei {loja}, {pocoes}, {varinhas} ou {runas}.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Usai vossas runas com prudência!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Usai vossas runas com prudência!")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Escolhei com cuidado: {pocoes}, {varinhas} ou {runas}.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Vendestes %ix %s por %i moedas de ouro.", amount, name, totalCost))
end

npcType.onCheckItem = function(npc, player, clientId, subType) end


-- Each NPC owns its return memory and lesson pages; quest state stays authoritative.
local dawnMenu = "Escolhei {loja}, {pocoes}, {varinhas} ou {runas}."
local dawnPersonality = "Hamish, alquimista entusiasmado"
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
