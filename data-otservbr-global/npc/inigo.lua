local internalNpcName = "Inigo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 472,
	lookHead = 59,
	lookBody = 114,
	lookLegs = 0,
	lookFeet = 94,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
	profession = "normal",
}
npcConfig.speechBubble = SPEECHBUBBLE_QUEST

npcConfig.voices = {
    interval = 15000, chance = 50,
    { text = "Saudações, aventureiro! Dizei oi: posso guiar vossos primeiros passos em Dawnport." },
    { text = "Precisais de ajuda com combate, vocações ou missões? Falai comigo!" },
    { text = "Antes de explorar, preparai comida, poções e uma corda. Posso indicar onde encontrá-las." },
    { text = "Não precisais aprender tudo de uma vez. Escolhei um assunto e caminharemos passo a passo." },
}
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval) npcHandler:onThink(npc, interval) end
npcType.onAppear = function(npc, creature) npcHandler:onAppear(npc, creature) end
npcType.onDisappear = function(npc, creature) npcHandler:onDisappear(npc, creature) end
npcType.onMove = function(npc, creature, fromPosition, toPosition) npcHandler:onMove(npc, creature, fromPosition, toPosition) end
npcType.onSay = function(npc, creature, type, message) npcHandler:onSay(npc, creature, type, message) end
npcType.onCloseChannel = function(npc, creature) npcHandler:onCloseChannel(npc, creature) end

local destinations = {
    richard = { 32056, 31881, 5, "Richard - comida e ferramentas" },
    hamish = { 32057, 31900, 5, "Hamish - poções e suprimentos" },
    garamond = { 32059, 31882, 4, "Garamond - magias de Druid e Sorcerer" },
    tybald = { 32071, 31882, 4, "Ser Tybald - magias de Knight e Paladin" },
    morris = { 32071, 31897, 4, "Mr Morris - missões e caçadas" },
    oressa = { 32064, 31892, 6, "Oressa - cura e escolha de vocação" },
    captain = { 32031, 31872, 6, "Captain Dreadnought - partida ao continente" },
    bank = { 32071, 31882, 5, "Plunderpurse - banco" },
    woblin = { 31987, 31883, 8, "Woblin - chave do dormitório" },
}
local function mark(player, destination)
    local d = destinations[destination]
    if not d or d[4] == "" then return false end
    player:addMapMark({ x = d[1], y = d[2], z = d[3] }, MAPMARK_FLAG, d[4])
    return true
end

local lessons = {
    start = { title = "primeiros passos", pages = {
        "Bem-vindo a Crystal! Dawnport é vossa ilha de aprendizado. Primeiro, aprendei a conversar e explorar; depois, experimentai uma vocação e enfrentai criaturas fracas. Dizei {proximo} para continuar.",
        "Para conversar, dizei oi e depois uma palavra destacada. Clicai no mapa para caminhar até um ponto acessível. Observai o andar do mapa: escadas levam a pisos diferentes. Dizei {proximo}.",
        "Preparai comida, corda e pá com {Richard}. Experimentai as vocações nos portões de treinamento. Caçai com cuidado até o nível 8; então escolhei {sair da ilha}. Dizei {ajuda} para escolher outro assunto.",
    }},
    combat = { title = "combate", pages = {
        "Selecionai uma criatura na lista de batalha para atacar. Começai com inimigos fracos e evitai ser cercado. Vigiai vossa vida e recuai antes que seja tarde. Dizei {proximo}.",
        "Após vencer, abri o corpo para recolher os despojos. Comei para recuperar vossas forças; poções e magias auxiliam durante a luta. {Hamish} fornece suprimentos. Dizei {proximo}.",
        "O modo ofensivo favorece o ataque; o defensivo favorece a defesa; o equilibrado fica entre ambos. Preparai um atalho de cura nas opções do cliente. Para outros conselhos, escolhei {magias}, {equipamentos} ou {ajuda}.",
    }},
    vocation = { title = "vocações", pages = {
        "Vossa vocação determina como lutais. Knight enfrenta inimigos de perto; Paladin usa armas à distância; Sorcerer usa magia ofensiva; Druid combina magia e cura; Monk usa técnicas marciais. Dizei {proximo}.",
        "Os portões de treinamento permitem experimentar as quatro vocações tradicionais. Observai as mensagens ao atravessá-los e testai armas e magias antes de decidir. Dizei {proximo}.",
        "A partir do nível 8, {Oressa} orienta a escolha definitiva das vocações tradicionais. Para Monk, procurai Ambassador Manop. A escolha definitiva exige cuidado. Perguntai sobre {knight}, {paladin}, {sorcerer}, {druid} ou {monk}; ou dizei {ajuda}.",
    }},
    spells = { title = "magias", pages = {
        "Magias servem para atacar, curar ou auxiliar vossa jornada. Precisais de mana e dos requisitos de nível e vocação. Configurai atalhos nas opções do cliente. Dizei {proximo}.",
        "{Garamond} ensina magias de Druid e Sorcerer. {Tybald} ensina magias de Knight e Paladin. Ao falar com um instrutor, perguntai sobre as magias disponíveis e conferi o preço antes de aceitar. Dizei {ajuda} para voltar ao menu.",
    }},
    equipment = { title = "equipamentos", pages = {
        "Preparai arma, proteção, comida, poções, corda e pá antes de sair. {Richard} vende comida e ferramentas; {Hamish} fornece poções; {Coltrayne} cuida de armas e armaduras. Dizei {proximo}.",
        "A corda permite subir em pontos de corda; a pá abre certas passagens e permite escavar. Usai comida para sustentar a recuperação. Reservai espaço e capacidade na mochila para os despojos. Dizei {proximo}.",
        "Guardai vosso ouro com {Plunderpurse}. Para comprar, cumprimentai o mercador e dizei loja. Os comerciantes de Dawnport também aceitam comandos em português. Perguntai pelo nome do fornecedor para marcar seu destino, ou dizei {ajuda}.",
    }},
    quests = { title = "missões", pages = {
        "{Morris} oferece missões opcionais: recuperar um amuleto, um diário, uma erva e uma chave; ou caçar trolls, goblins e minotauros. Cada tarefa concluída rende 50 moedas de ouro. Dizei {proximo}.",
        "Aceitai a missão antes de começar. As caçadas pedem 20 criaturas do tipo indicado; as buscas pedem recuperar ou colher o que Morris solicitou. Voltai a ele para entregar a tarefa. Dizei {proximo}.",
        "Com Morris, escolhei missoes, buscas ou cacadas; depois amuleto, diario, ervas, chave, trolls, goblins ou minotauros. Para a chave, perguntai-me sobre {chave}. As missões não são obrigatórias para partir. Dizei {ajuda}.",
    }},
    exit = { title = "sair da ilha", pages = {
        "Para a partida tradicional, alcançai o nível 8 e escolhei vossa vocação definitiva com {Oressa}. Concluí antes as tarefas que desejais fazer na ilha. Dizei {proximo}.",
        "Após a escolha, recolhei o equipamento no baú da sala da vocação. Depois procurai o {capitao} para escolher a cidade. Ele permite levar até 500 moedas de ouro carregadas; o excedente deve ser retirado ou doado. Dizei {proximo}.",
        "Para o caminho de Monk, falai com Ambassador Manop, segui suas instruções e visitai um santuário antes da partida para Blue Valley. Se ainda não alcançastes o nível 8, continuai o treinamento. Dizei {ajuda} para rever os assuntos.",
    }},
}
local function state(player) return player:kv():scoped("crystal-inigo-tutorial") end
local menu = "Escolhei um assunto: {primeiros passos}, {combate}, {vocacoes}, {magias}, {equipamentos}, {missoes} ou {sair da ilha}. Durante uma explicação, usai {proximo}, {anterior} ou {repetir}. Dizei {ajuda} para voltar ao menu."
local function showLesson(npc, player, id, page)
    local lesson = lessons[id]
    if not lesson then return end
    page = math.max(1, math.min(page, #lesson.pages))
    local kv = state(player)
    kv:set("lesson", id)
    kv:set("page", page)
    local indicated = {
        richard = "{Richard}", hamish = "{Hamish}", garamond = "{Garamond}",
        tybald = "{Tybald}", morris = "{Morris}", oressa = "{Oressa}",
        captain = "{capitao}", bank = "{Plunderpurse}",
    }
    local marked = false
    for destination, tag in pairs(indicated) do
        if lesson.pages[page]:find(tag, 1, true) then
            marked = mark(player, destination) or marked
        end
    end
    local mapNote = marked and " Marquei os destinos citados no mapa; conferi também o andar de cada marca." or ""
    npcHandler:say("[" .. lesson.title .. " - " .. page .. "/" .. #lesson.pages .. "] " .. lesson.pages[page] .. mapNote, npc, player)
end
local function contains(message, words)
    for _, word in ipairs(words) do if MsgContains(message, word) then return true end end
    return false
end
local function greetCallback(npc, creature)
    local player = Player(creature)
    local kv = state(player)
    local greeting
    if kv:get("met") then
        local lesson = lessons[kv:get("lesson")]
        greeting = "Bem-vindo de volta, |PLAYERNAME|! Alegra-me ver vosso progresso. "
        if lesson then greeting = greeting .. "Estávamos falando de " .. lesson.title .. ". Dizei {continuar} para retomar ou {ajuda} para escolher outro assunto." else greeting = greeting .. menu end
    else
        greeting = "Saudações, |PLAYERNAME|! Sou Inigo, vosso guia em Dawnport. Não precisais saber tudo agora: ensinarei um passo de cada vez. " .. menu
        kv:set("met", true)
    end
    npcHandler:setMessage(MESSAGE_GREET, greeting)
    return true
end
local topicAliases = {
    { "exit", { "sair da ilha", "mainland", "continente", "partir" } },
    { "start", { "primeiros passos", "play", "comecar", "começar", "npc", "conversar", "movimentacao", "movimentação", "explorar", "portal", "dawnport", "crystal" } },
    { "combat", { "combate", "combat", "fighting", "figthing", "monstros", "monsters", "atacar", "loot", "recuperacao", "recuperação", "offensive", "balanced", "defensive", "skills", "dying", "pvp", "skull", "players", "bless" } },
    { "vocation", { "vocacoes", "vocações", "vocation", "vocations", "train", "treinar" } },
    { "spells", { "magias", "spells", "mana", "aprender magias", "usar magias" } },
    { "equipment", { "equipamentos", "tools", "ferramentas", "food", "comida", "rope", "corda", "shovel", "pa", "pá", "fishing rod", "vara de pesca", "mochila", "pocoes", "poções" } },
    { "quests", { "missoes", "missões", "quest", "questing", "buscar objetos", "tarefas de caca", "tarefas de caça" } },
}
local function creatureSayCallback(npc, creature, type, message)
    local player = Player(creature)
    local playerId = player:getId()
    if not npcHandler:checkInteraction(npc, creature) then return false end
    if npcHandler:getTopic(playerId) > 0 and contains(message, { "no", "nao", "não", "cancelar" }) then
        npcHandler:setTopic(playerId, 0)
        npcHandler:say("Como desejardes, ficaremos em Dawnport. " .. menu, npc, creature)
        return true
    end
	if MsgContains(message, "rookgaard") and player:getLevel() <= 9 then
		if Player.getAccountStorage(player, Storage.Dawnport.Mainland, true) == 1 then
			npcHandler:say(
				"Rookgaard é uma ilha de treinamento alternativa. \z
			A viagem é definitiva. Desejais ir para lá? Respondei {sim} ou {nao}.",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 1)
		else
			npcHandler:say("Não posso autorizar essa viagem para vosso personagem. Continuai o treinamento em Dawnport; posso explicar como {sair da ilha}.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif (MsgContains(message, "yes") or MsgContains(message, "sim")) and npcHandler:getTopic(playerId) == 1 then
		npcHandler:say({
			"Atenção: esta viagem não permite retorno a Dawnport! \z
			Vossa vocação será removida e os equipamentos e produtos de Dawnport serão retirados conforme as regras de viagem. ...",
			"Desejais mesmo partir para Rookgaard? Dizei {confirmar} para partir ou {nao} para cancelar.",
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 2)
	elseif npcHandler:getTopic(playerId) == 2 and ((MsgContains(message, "yes") or MsgContains(message, "sim")) or MsgContains(message, "sure") or MsgContains(message, "leave") or MsgContains(message, "confirmar")) then
		local town = Town(TOWNS_LIST.ROOKGAARD)
		player:setTown(town)
		-- Change to none vocation, convert magic level and skills and set proper stats
		player:changeVocation(VOCATION.ID.NONE)
		player:teleportTo(town:getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

		local slots = {
			1,
			2,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
		}
		-- Cycle through the slots table and store the slot id in slot
		for index, value in pairs(slots) do
			-- Get the player's slot item and store it in item
			local item = player:getSlotItem(value)
			-- If the item exists meaning its not nil then continue
			if item and not table.contains({ 2853, 2854, 2920, 3355, 3562, 3559 }, item:getId()) then
				item:remove()
			end
		end
		local container = player:getSlotItem(CONST_SLOT_BACKPACK)
		local toBeDeleted = {}
		local allowedIds = {
			2853,
			2920,
			3003,
			3031,
		}
		if container and container:getSize() > 0 then
			for i = 0, container:getSize() do
				if player:getMoney() > 21465 then
					player:removeMoney(math.abs(21465 - player:getMoney()))
				end
				local item = container:getItem(i)
				if item then
					---@diagnostic disable-next-line: undefined-field
					if not table.contains(allowedIds, item:getId()) then
						toBeDeleted[#toBeDeleted + 1] = item.uid
					end
				end
			end
			if #toBeDeleted > 0 then
				for i, v in pairs(toBeDeleted) do
					local item = Item(v)
					if item then
						item:remove()
					end
				end
			end
		end
		player:addItem(3270, 1)
		player:addItem(2853, 1)
		player:addItem(2920, 1)
		player:addItem(3585, 1)
		player:addItem(3561, 1)
		npcHandler:say(
			"Como desejardes. Que vossa jornada em Rookgaard seja proveitosa! \z
		Ide em paz, aventureiro.",
			npc,
			creature
		)
		npcHandler:setTopic(playerId, 0)
	end
    local kv = state(player)
    local id = kv:get("lesson")
    local page = kv:get("page") or 1
    if contains(message, { "ajuda", "help", "menu", "hints", "dicas", "people" }) then
        npcHandler:setTopic(playerId, 0)
        npcHandler:say(menu, npc, creature)
        return true
    elseif contains(message, { "continuar", "repetir" }) then
        if lessons[id] then showLesson(npc, player, id, page) else npcHandler:say(menu, npc, creature) end
        return true
    elseif contains(message, { "proximo", "próximo", "next", "anterior", "voltar" }) then
        if lessons[id] then
            local direction = contains(message, { "anterior", "voltar" }) and -1 or 1
            showLesson(npc, player, id, page + direction)
        else npcHandler:say(menu, npc, creature) end
        return true
    end
    local guides = {
        { "richard", { "Richard vende comida, corda, pá e vara de pesca. Marquei sua loja no mapa, no andar 5.", "richard" } },
        { "hamish", { "Hamish fornece poções e suprimentos mágicos. Marquei seu destino no mapa, no andar 5.", "hamish" } },
        { "garamond", { "Garamond ensina magias de Druid e Sorcerer. Marquei seu destino no andar 4; usai as escadas do posto para subir.", "garamond" } },
        { "tybald", { "Ser Tybald ensina magias de Knight e Paladin. Marquei seu destino no andar 4; usai as escadas para subir.", "tybald" } },
        { "morris", { "Mr Morris oferece missões e tarefas de caça. Marquei seu destino no andar 4. Cumprimentai-o e dizei missoes.", "morris" } },
        { "oressa", { "Oressa cuida da cura e da escolha definitiva das quatro vocações tradicionais. Marquei o templo no andar 6, abaixo deste piso.", "oressa" } },
        { "capitao", { "Captain Dreadnought leva-vos ao continente após a escolha de vocação. Marquei o embarque no andar 6. Com ele, dizei viajar e escolhei a cidade.", "captain" } },
        { "captain", { "Marquei o embarque de Captain Dreadnought no andar 6. Ele orienta a escolha da cidade no continente.", "captain" } },
        { "plunderpurse", { "Plunderpurse guarda vosso ouro. Marquei o banco no andar 5. Podeis pedir saldo, depositar ou sacar.", "bank" } },
        { "banco", { "Marquei o banco de Plunderpurse no andar 5. Cumprimentai-o e escolhei saldo, depositar ou sacar.", "bank" } },
        { "woblin", { "Woblin possui a chave do dormitório. Marquei sua caverna a oeste, no andar 8. Aceitai primeiro a missão com Morris; depois dizei tesouro e recompensa a Woblin.", "woblin" } },
        { "chave", { "Aceitai a missão chave com Morris. Depois procurai Woblin: tesouro, recompensa, pescar Old Nasty, old nasty e sim. Marquei sua caverna a oeste no andar 8. Levai vara e minhocas.", "woblin" } },
    }
    for _, guide in ipairs(guides) do
        if MsgContains(message, guide[1]) then
            mark(player, guide[2][2])
            npcHandler:say(guide[2][1] .. " Dizei {continuar} para retomar a lição ou {ajuda} para o menu.", npc, creature)
            return true
        end
    end
    local vocations = {
        knight = "Knight luta de perto com espada, machado ou clava e possui boa resistência. Experimentai o portão de treinamento antes da escolha definitiva.",
        paladin = "Paladin luta à distância com arcos, lanças e outras armas, além de usar magia sagrada. Reservai munição e espaço para movimentar-vos.",
        sorcerer = "Sorcerer usa magia ofensiva de fogo, energia e morte. Mantende distância e cuidai de vossa mana.",
        druid = "Druid usa magia de gelo e terra e pode curar companheiros. Mantende distância e preparai magias de cura.",
        monk = "Monk usa técnicas marciais. Para seguir esse caminho, procurai Ambassador Manop. Ele orientará a visita aos santuários e a partida para Blue Valley.",
    }
    for name, text in pairs(vocations) do
        if MsgContains(message, name) then npcHandler:say(text .. " Dizei {continuar} ou {ajuda}.", npc, creature); return true end
    end
    if contains(message, { "nome", "name", "job", "trabalho" }) then
        npcHandler:say("Sou Inigo, antigo caçador e agora vosso mentor. Prefiro uma orientação clara a um enigma: perguntai o que precisardes. " .. menu, npc, creature)
        return true
    elseif contains(message, { "coltrayne" }) then
        npcHandler:say("Coltrayne fornece armas, armaduras e munição. Perguntai por loja ao encontrá-lo. Dizei {continuar} ou {ajuda}.", npc, creature)
        return true
    elseif contains(message, { "menesto" }) then
        npcHandler:say("Menesto guarda a caverna de chegada e orienta a subida. Aqui comigo podeis escolher cada assunto do treinamento. " .. menu, npc, creature)
        return true
    end
    for _, topic in ipairs(topicAliases) do
        if contains(message, topic[2]) then showLesson(npc, player, topic[1], 1); return true end
    end
    if npcHandler:getTopic(playerId) == 0 then npcHandler:say("Não compreendi vosso pedido, mas podemos ir com calma. " .. menu, npc, creature) end
    return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_FAREWELL, "Ide em paz, aventureiro. Voltai quando precisardes; retomaremos vossa lição.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Boa jornada! Estarei aqui para continuar vosso treinamento.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcType:register(npcConfig)
