local internalNpcName = "King Tibianus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 332,
}

npcConfig.flags = {
	floorchange = false,
	profession = "king",
}
npcConfig.speechBubble = SPEECHBUBBLE_NORMAL

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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "farmine") and player:getStorageValue(TheNewFrontier.Questline) == 14 then
		if player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 1 then
			npcHandler:say("Ah, lembro-me vagamente de que nossos pequenos aliados desejavam construir uma base. Dizei-me: o que desejais?", npc, creature)
			npcHandler:setTopic(playerId, 10)
		else
			npcHandler:say("Tendes algo que possa me fazer mudar de ideia?", npc, creature)
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "flatter") and player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 1 then
		if npcHandler:getTopic(playerId) == 10 then
			npcHandler:say("Certamente! Sem a ajuda de Thais, nossos aliados não terão chance alguma! Enviarei ouro para apoiar sua causa.", npc, creature)
			player:setStorageValue(TheNewFrontier.Mission05.KingTibianus, 3)
		end
	elseif (MsgContains(message, "outfit")) or (MsgContains(message, "addon")) then
		npcHandler:say("Em troca de uma doação generosa, concederei um traje especial. Desejais fazer uma doação? Respondei {yes} para aceitar.", npc, creature)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		-- Trata a resposta "yes" conforme a etapa atual da conversa (tópico).
		if npcHandler:getTopic(playerId) == 1 then
			-- Na primeira confirmação, explica o preço e a ordem das partes do traje.
			npcHandler:say({ "Excelente! Vou explicar: o traje completo custa 1.000.000.000 de moedas de ouro, dividido em três partes. ...", "Primeiro, a armadura ({armor}) custa 500.000.000; depois, o capacete ({helmet}) custa 250.000.000; por fim, as botas ({boots}) custam mais 250.000.000 de moedas de ouro. ...", "Qual parte desejais adquirir? Dizei a palavra destacada em inglês: {armor}, {helmet} ou {boots}." }, npc, creature)
			npcHandler:setTopic(playerId, 2)
			-- O NPC só vai oferecer os addons se o player já tiver escolhido.
		elseif npcHandler:getTopic(playerId) == 2 then
			-- Se o jogador repetir "yes" sem escolher uma parte, encerra esta etapa.
			npcHandler:say("Nesse caso, retornai quando tiverdes decidido.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			-- Inicio do outfit
		elseif npcHandler:getTopic(playerId) == 3 then -- ARMOR/OUTFIT
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 1 then
				if player:getMoney() + player:getBankBalance() >= 500000000 then
					local inbox = player:getStoreInbox()
					local inboxItems = inbox:getItems()
					if inbox and #inboxItems < inbox:getMaxCapacity() then
						local decoKit = inbox:addItem(ITEM_DECORATION_KIT, 1)
						local decoItemName = ItemType(31510):getName()
						decoKit:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Desembrulhe este pacote dentro da sua própria casa para criar: " .. decoItemName .. ".")
						decoKit:setCustomAttribute("unWrapId", 31510)
						npcHandler:say("Recebei esta armadura como sinal de minha gratidão. Que este dia seja lembrado para sempre, meu amigo!", npc, creature)
						player:removeMoneyBank(500000000)
						player:addOutfit(1211)
						player:addOutfit(1210)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 1)
					else
						npcHandler:say("Liberai ao menos um espaço na caixa de entrada da loja (Store Inbox) e tentai novamente.", npc, creature)
					end
				else
					npcHandler:say("Não tendes ouro suficiente para essa doação. O valor pode estar convosco ou no banco.", npc, creature)
				end
			else
				npcHandler:say("Já possuís esta parte do traje.", npc, creature)
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do outfit
			-- Inicio do helmet
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 1 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 2 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						npcHandler:say("Recebei este capacete como sinal de minha gratidão. Que este dia seja lembrado para sempre, meu amigo!", npc, creature)
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 2)
						player:addOutfitAddon(1211, 2)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 2)
						npcHandler:setTopic(playerId, 2)
					else
						npcHandler:say("Não tendes ouro suficiente para essa doação. O valor pode estar convosco ou no banco.", npc, creature)
						npcHandler:setTopic(playerId, 2)
					end
				else
					npcHandler:say("Já possuís este traje ou complemento.", npc, creature)
					npcHandler:setTopic(playerId, 2)
				end
			else
				npcHandler:say("Primeiro, deveis adquirir a armadura. Dizei {armor} e confirmai com {yes}.", npc, creature)
				npcHandler:setTopic(playerId, 2)
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do helmet
			-- Inicio da boots
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 2 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 3 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						npcHandler:say("Recebei estas botas como sinal de minha gratidão. Que este dia seja lembrado para sempre, meu amigo!", npc, creature)
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 1)
						player:addOutfitAddon(1211, 1)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 3)
						npcHandler:setTopic(playerId, 2)
					else
						npcHandler:say("Não tendes ouro suficiente para essa doação. O valor pode estar convosco ou no banco.", npc, creature)
						npcHandler:setTopic(playerId, 2)
					end
				else
					npcHandler:say("Já possuís este traje ou complemento.", npc, creature)
					npcHandler:setTopic(playerId, 2)
				end
			else
				npcHandler:say("Primeiro, deveis adquirir o capacete. Dizei {helmet} e confirmai com {yes}.", npc, creature)
				npcHandler:setTopic(playerId, 2)
			end
			-- Fim da boots
			npcHandler:setTopic(playerId, 2)
			-- Retoma o diálogo da missão 5 de The New Frontier.
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 2 and player:removeItem(10009, 1) then
				npcHandler:say("Ah, lembro-me vagamente de que nossos pequenos aliados desejavam construir uma base. Dizei-me: o que desejais?", npc, creature)
				player:setStorageValue(TheNewFrontier.Mission05.KingTibianus, 1)
				npcHandler:setTopic(playerId, 10)
			end
		end
		-- inicio das opções armor/helmet/boots
		-- caso o player não diga YES, dirá alguma das seguintes palavras:
	elseif (MsgContains(message, "armor")) and npcHandler:getTopic(playerId) == 2 then
		npcHandler:say("Desejais doar 500.000.000 de moedas de ouro para adquirir a armadura do traje? Respondei {yes} para confirmar.", npc, creature)
		npcHandler:setTopic(playerId, 3) -- alterando o tópico para que no próximo YES ele faça o outfit
	elseif (MsgContains(message, "helmet")) and npcHandler:getTopic(playerId) == 2 then
		npcHandler:say("Desejais doar 250.000.000 de moedas de ouro para adquirir o capacete do traje? Respondei {yes} para confirmar.", npc, creature)
		npcHandler:setTopic(playerId, 4) -- alterando o tópico para que no próximo YES ele faça o helmet
	elseif (MsgContains(message, "boots")) and npcHandler:getTopic(playerId) == 2 then
		npcHandler:say("Desejais doar 250.000.000 de moedas de ouro para adquirir as botas do traje? Respondei {yes} para confirmar.", npc, creature)
		npcHandler:setTopic(playerId, 5) -- alterando o tópico para que no próximo YES ele faça a boots
	else
		if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 1 then
			npcHandler:say("Essa não é a resposta que eu esperava.", npc, creature)
			player:setStorageValue(TheNewFrontier.Mission05.KingTibianus, 2)
		end
	end
	-- fim das opções armor/helmet/boots
end
-- Promoção: cobra 20.000 moedas de ouro e exige nível 20.
local node1 = keywordHandler:addKeyword({ "promot" }, StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Posso promover vossa vocação por 20.000 moedas de ouro, a partir do nível 20. Desejais a promoção? Respondei {yes} para confirmar ou {no} para cancelar.",
})
node1:addChildKeyword({ "yes" }, StdModule.promotePlayer, {
	npcHandler = npcHandler,
	monk = true,
	cost = 20000,
	level = 20,
	text = "Parabéns! Vossa vocação foi promovida. Conferi a nova vocação ao olhar para vosso personagem.",
})
node1:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	text = "Muito bem. Retornai quando estiverdes pronto.",
	reset = true,
})
-- Conversas gerais. As palavras-chave em inglês devem ser mantidas.
keywordHandler:addKeyword({ "eremo" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Dizem que ele vive em uma pequena ilha próxima de Edron. Talvez os moradores de lá saibam mais a seu respeito.",
})
keywordHandler:addKeyword({ "otbr" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Excelente! Visitai www.otserv.com.br!",
})
keywordHandler:addKeyword({ "baah" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Baah é o habilidoso criador que reescreveu meu sistema de trajes.",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Sou vosso soberano, o Rei Tibianus III. Meu dever é preservar a justiça ({justice}) e orientar meus súditos.",
})
keywordHandler:addKeyword({ "justice" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Procuro governar nossos cidadãos com justiça. O exército e a {TBI} muito me ajudam nessa tarefa.",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Que absurdo! Deveríeis conhecer o nome de vosso próprio rei!",
})
keywordHandler:addKeyword({ "news" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "As novidades chegam à nossa magnífica cidade pelas mãos de bravos aventureiros. Eles contam suas jornadas na taverna de Frodo.",
})
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Agradeço a preocupação. Estou bem.",
})
keywordHandler:addKeyword({ "castle" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "O Castelo Rain é meu lar.",
})
keywordHandler:addKeyword({ "sell" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Vender? Vender o quê? Meu reino não está à venda!",
})
keywordHandler:addKeyword({ "god" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Honrai os deuses e, acima de tudo, pagai vossos impostos ({taxes}).",
})
keywordHandler:addKeyword({ "zathroth" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Procurai um sacerdote para aprender sobre os deuses.",
})
keywordHandler:addKeyword({ "citizen" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Os cidadãos de Tibia são meus súditos. Conversai com o velho monge Quentin se desejardes saber mais sobre eles.",
})
keywordHandler:addKeyword({ "sam" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Ele é um ferreiro habilidoso e um súdito leal.",
})
keywordHandler:addKeyword({ "frodo" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Ele é o proprietário da taverna Frodo's Hut e paga seus impostos fielmente.",
})
keywordHandler:addKeyword({ "gorn" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Ele já foi um dos maiores guerreiros de Tibia. Hoje, vende equipamentos.",
})
keywordHandler:addKeyword({ "benjamin" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Ele já foi meu maior general. Agora, com a idade avançada e a memória enfraquecida, trabalha no Correio Real de Tibia.",
})
keywordHandler:addKeyword({ "noodles" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "O poodle real Noodles é meu maior tesouro ({treasure})!",
})
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Ele segue o maligno deus Zathroth e é responsável por muitos ataques contra nós. Eliminai-o assim que o avistardes!",
})
keywordHandler:addKeyword({ "bozo" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Ele é meu bobo da corte e costuma alegrar meus dias.",
})
keywordHandler:addKeyword({ "treasure" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "O poodle real Noodles é meu maior tesouro!",
})
keywordHandler:addKeyword({ "monster" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Ide caçá-los! Pelo rei e pelo reino!",
})
keywordHandler:addKeyword({ "help" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Procurai o monge Quentin se precisardes de ajuda.",
})
keywordHandler:addKeyword({ "sewer" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Que assunto repugnante!",
})
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Masmorras não são lugares para reis.",
})
keywordHandler:addKeyword({ "equipment" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Podeis comprar equipamentos nas excelentes lojas de nossa cidade.",
})
keywordHandler:addKeyword({ "food" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Pedi comida ao cozinheiro real.",
})
keywordHandler:addKeyword({ "tax collector" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Aquele cobrador de impostos me causa tantos problemas! É muito preguiçoso. Aposto que nem sequer cobrou vossos impostos.",
})
keywordHandler:addKeyword({ "king" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Sou o rei! Cuidado com vossas palavras!",
})
keywordHandler:addKeyword({ "army" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Perguntai aos soldados sobre isso.",
})
keywordHandler:addKeyword({ "shop" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Visitai as lojas de nossos mercadores e artesãos.",
})
keywordHandler:addKeyword({ "guild" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "As quatro principais guildas são as dos cavaleiros, paladinos, druidas e feiticeiros.",
})
keywordHandler:addKeyword({ "minotaur" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Criaturas vis! Contudo, admito que são fortes e, por vezes, até astutas... à sua maneira bestial.",
})
keywordHandler:addKeyword({ "good" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "As forças do bem enfrentam grandes dificuldades nestes tempos sombrios.",
})
keywordHandler:addKeyword({ "evil" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Precisamos reunir todas as nossas forças para derrotar o mal!",
})
keywordHandler:addKeyword({ "order" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Precisamos de ordem para sobreviver!",
})
keywordHandler:addKeyword({ "chaos" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "O caos nasce do egoísmo.",
})
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "É a espada dos reis. Se a trouxerdes de volta, recebereis uma recompensa ({reward}) além de vossos maiores sonhos.",
})
keywordHandler:addKeyword({ "reward" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Se desejais uma recompensa, parti em missão e trazei-me a Excalibug!",
})
keywordHandler:addKeyword({ "chester" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Uma pessoa muito competente. Um pouco nervosa, mas muito competente.",
})
keywordHandler:addKeyword({ "tbi" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Essa organização é essencial para conter nossos inimigos. Sua sede fica no bastião da muralha norte.",
})
keywordHandler:addKeyword({ "tibia" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Em breve, toda esta terra estará sob meu governo novamente!",
})
keywordHandler:addAliasKeyword({ "land" })
keywordHandler:addKeyword({ "harkath" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Harkath Bloodblade é o general de nosso glorioso exército ({army}).",
})
keywordHandler:addAliasKeyword({ "bloodblade" })
keywordHandler:addAliasKeyword({ "general" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Quando houver necessidade, convocarei heróis novamente e os recompensarei por seus feitos.",
})
keywordHandler:addAliasKeyword({ "mission" })
keywordHandler:addKeyword({ "gold" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Para pagar vossos impostos, procurai o cobrador de impostos real.",
})
keywordHandler:addAliasKeyword({ "money" })
keywordHandler:addAliasKeyword({ "tax" })
keywordHandler:addAliasKeyword({ "collector" })
keywordHandler:addKeyword({ "time" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "É tempo de heróis!",
})
keywordHandler:addAliasKeyword({ "hero" })
keywordHandler:addAliasKeyword({ "adventurer" })
keywordHandler:addKeyword({ "enemy" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Nossos inimigos são numerosos. Os perversos minotauros, Ferumbras e a cidade rebelde de Carlin, ao norte, são apenas alguns deles.",
})
keywordHandler:addAliasKeyword({ "enemies" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Eles ousam rejeitar meu governo sobre todo o continente!",
})
keywordHandler:addKeyword({ "thais" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Nossa amada cidade possui excelentes lojas, sedes de guildas e um moderno sistema de esgoto.",
})
keywordHandler:addAliasKeyword({ "city" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Perguntai aos moradores sobre eles.",
})
keywordHandler:addAliasKeyword({ "craftsmen" })
keywordHandler:addKeyword({ "paladin" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Os paladinos são grandes protetores de Thais.",
})
keywordHandler:addAliasKeyword({ "elane" })
keywordHandler:addKeyword({ "knight" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Os bravos cavaleiros são essenciais à sobrevivência dos humanos em Thais.",
})
keywordHandler:addAliasKeyword({ "gregor" })
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "A magia dos feiticeiros é uma arma poderosa contra nossos inimigos.",
})
keywordHandler:addAliasKeyword({ "muriel" })
keywordHandler:addKeyword({ "druid" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Precisamos dos poderes de cura dos druidas para combater o mal.",
})
keywordHandler:addAliasKeyword({ "marvik" })

-- Saudações: o jogador pode dizer "hail king" ou "salutations king".
keywordHandler:addGreetKeyword({ "hail king" }, {
	npcHandler = npcHandler,
	text = "Saudações, meu leal súdito |PLAYERNAME|. Para uma promoção, dizei {promotion}. Para conhecer o traje especial, dizei {outfit}.",
})
keywordHandler:addGreetKeyword({ "salutations king" }, {
	npcHandler = npcHandler,
	text = "Saudações, meu leal súdito |PLAYERNAME|. Para uma promoção, dizei {promotion}. Para conhecer o traje especial, dizei {outfit}.",
})

npcHandler:setMessage(MESSAGE_WALKAWAY, "Que falta de educação!")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

-- Registra o NPC com as configurações acima.
npcType:register(npcConfig)
