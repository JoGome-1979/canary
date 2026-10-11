local internalNpcName = "Ruprecht"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 59,
	lookBody = 115,
	lookLegs = 115,
	lookFeet = 38,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
	profession = "trader",
}
npcConfig.speechBubble = SPEECHBUBBLE_TRADE

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

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

local storeTable = {}
local itemsTable = {
	["gingerbreadman"] = { itemId = 6500, count = 1 },
	["christmas cookie tray"] = { itemId = 20310, count = 1 },
	["gingerbread recipe"] = { itemId = 174, count = 10 },
	["jewel case"] = { itemId = 7527, count = 25 },
	["santa hat"] = { itemId = 6531, count = 50 },
	["santa backpack"] = { itemId = 10346, count = 75 },
	["snow flake tapestry"] = { itemId = 20315, count = 75 },
	["santa doll"] = { itemId = 6511, count = 100 },
	["snowman doll"] = { itemId = 10339, count = 150 },
	["snow globe"] = { itemId = 20311, count = 150 },
	["frazzlemaw santa"] = { itemId = 20308, count = 250 },
	["leaf golem santa"] = { itemId = 20309, count = 250 },
	["santa music box"] = { itemId = 20313, count = 250 },
	["santa teddy"] = { itemId = 10338, count = 500 },
	["maxxen santa"] = { itemId = 21952, count = 250 },
	["present bag"] = { itemId = 6496, count = 1 },
	["ferumbras' teddy santa"] = { itemId = 22879, count = 250 },
	["nightmare beast santa"] = { itemId = 29947, count = 250 },
	["orclops santa"] = { itemId = 24394, count = 250 },
	["raccoon santa"] = { itemId = 35692, count = 250 },
	["santa fox"] = { itemId = 27591, count = 250 },
	["santa leech"] = { itemId = 32746, count = 250 },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "offers") then
		local text = "Tenho estas ofertas: "
		for i, v in pairs(itemsTable) do
			text = text .. "{" .. i .. "}, "
		end
		npcHandler:say(text, npc, creature)
	end

	if npcHandler:getTopic(playerId) == 0 then
		local table = itemsTable[message]
		if table then
			if table.itemId ~= 6496 then
				npcHandler:say("Então você deseja trocar " .. message .. ", por " .. table.count .. " fichas de Natal?", npc, creature)
				storeTable[playerId] = message
				npcHandler:setTopic(playerId, 1)
			else
				npcHandler:say("Então você deseja trocar " .. message .. " por " .. table.count .. " ficha(s) de Natal?", npc, creature)
				storeTable[playerId] = 6526
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			if tonumber(storeTable[playerId]) == 6526 then
				if player:removeItem(6496, 1) then
					npcHandler:say("Obrigado, aqui está sua ficha de Natal.", npc, creature)
					player:addItem(6526, 1)
					npcHandler:setTopic(playerId, 0)
				else
					npcHandler:say("Você não tem uma sacola de presentes.", npc, creature)
					npcHandler:setTopic(playerId, 0)
				end
				return false
			end
			if player:removeItem(6526, itemsTable[storeTable[playerId]].count) then
				npcHandler:say("Obrigado, aqui está seu item: " .. storeTable[playerId] .. ".", npc, creature)
				player:addItem(itemsTable[storeTable[playerId]].itemId, 1)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:say("Você não tem fichas suficientes.", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif npcHandler:getTopic(playerId) > 0 then
		if MsgContains(message, "no") then
			npcHandler:say("Volte quando estiver pronto para trocar algumas fichas!", npc, creature)
		end
	end
	if MsgContains(message, "santa claus") then
		npcHandler:say({
			"Bem, ele não gosta muito que contem sua história... mas eu conto! Há muito, muito tempo, Papai Noel era apenas um pequeno anão ganancioso. Um verdadeiro avarento, eu lhe digo...",
			"Ele era ganancioso até mesmo para os padrões dos anões. Nunca dividia nada, nem dava o objeto mais barato que possuía...",
			"Certo dia, uma mulher foi até sua casa e pediu um copo de água...",
			"É claro que ele recusou. Chegou até a zombar dela por ser tão ingênua. Mas o que ele não sabia era que aquela mulher era uma espécie de fada poderosa, ou talvez uma deusa disfarçada...",
			"Seja como for, a mulher amaldiçoou o velho Noel, obrigando-o a dividir sua fortuna com todos que encontrasse...",
			"Noel ficou horrorizado. É claro que não suportava sequer a ideia de dividir qualquer coisa. Então, foi se esconder...",
			"Ele se escondeu nos lugares mais remotos do mundo, mas sempre acabavam encontrando-o, e a maldição o obrigava a dividir sua riqueza...",
			"E sabe de uma coisa? O velho Noel acabou gostando disso! Ele viu a alegria que seus presentes traziam, e isso abriu seu velho coração de pedra...",
			"E aprendeu que, dessa maneira, sua fortuna lhe trazia muito mais alegria e satisfação do que quando a mantinha trancada...",
			"Com o passar dos anos, ele transformou isso em uma brincadeira. Escondia-se em algum lugar para recompensar aqueles que o encontrassem...",
			"Mas uma vez por ano, em um dia muito especial, que por acaso é o aniversário de sua maldição, ele sai e leva presentes às pessoas, principalmente às crianças...",
			"Bem, essa é a história dele... Não, isso não é uma lágrima no meu olho. É só o vento, sabe?",
		}, npc, creature)
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	storeTable[playerId] = nil
end

npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
-- Palavras-chave de diálogo às quais o NPC responde no servidor oficial
keywordHandler:addKeyword({ "sleigh" }, StdModule.say, { npcHandler = npcHandler, text = "Ah, o trenó é mágico, é claro. Foi feito por um djinn que devia um favor ao bom e velho Noel." })
keywordHandler:addKeyword({ "stolen" }, StdModule.say, { npcHandler = npcHandler, text = "Os goblins do clã Grynch criaram o hábito de roubar presentes nas cidades e até do trenó do Papai Noel. Se encontrar algum, devolva-o para mim e eu o recompensarei com uma ficha. Você pode juntar fichas e trocá-las por um belo presente." })
keywordHandler:addKeyword(
	{ "goblin" },
	StdModule.say,
	{ npcHandler = npcHandler, text = "Os goblins do clã Grynch são um incômodo constante. Roubam tudo que não esteja pregado ao chão e, se possível, até isso... Não hesitam em roubar presentes de criancinhas. Se conseguir recuperar os presentes roubados, Papai Noel terá prazer em devolvê-los aos seus legítimos donos." }
)
keywordHandler:addKeyword(
	{ "grynch" },
	StdModule.say,
	{ npcHandler = npcHandler, text = "Os goblins do clã Grynch são um incômodo constante. Roubam tudo que não esteja pregado ao chão e, se possível, até isso... Não hesitam em roubar presentes de criancinhas. Se conseguir recuperar os presentes roubados, Papai Noel terá prazer em devolvê-los aos seus legítimos donos." }
)
keywordHandler:addKeyword({ "christmas bakery" }, StdModule.say, { npcHandler = npcHandler, text = "A entrada da confeitaria fica logo atrás da minha cabana." })
keywordHandler:addKeyword({ "deer" }, StdModule.say, { npcHandler = npcHandler, text = "Não são renas comuns, mas de uma rara espécie mágica. São divertidas e simpáticas, sabe. O problema é que preferem um ensopado feito de velhas boots of haste desgastadas. Acho que é isso que as mantém rápidas e voando. Mas que fedor horrível!!" })
keywordHandler:addKeyword({ "token" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Se tiver fichas que deseja trocar, basta me dizer que deseja entregá-las... Por 1 ficha, você recebe um gingerbreadman ou uma christmas cookie tray. Por 10 fichas, dou uma gingerbread recipe para você preparar seus próprios biscoitos de gengibre na confeitaria de Natal... Por 25 fichas, dou uma jewel case; por 50, você pode levar um santa hat, igual ao do Papai Noel... 75 fichas bastam para uma santa backpack fofinha ou uma snow flake tapestry; por 100, você recebe uma santa doll. Troco 150 fichas por uma snowman doll ou um snow globe... 250 fichas bastam para um frazzlemaw santa, um leaf golem santa, um maxxen santa, um ferumbras' teddy santa, um orclops santa, uma santa music box, uma santa fox, um nightmare beast santa... um santa leech ou um raccoon santa. Por fim, por 500 fichas, você recebe um santa teddy.",
})

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Registro da tabela npcConfig no npcType
npcType:register(npcConfig)
