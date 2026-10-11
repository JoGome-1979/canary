local function bankContains(message, keyword)
    if MsgContains(message, keyword) then
        return true
    end
    local aliases = {
        ["guild"] = { "guilda" },
        ["balance"] = { "saldo" },
        ["deposit"] = { "depositar", "deposito", "depósito" },
        ["withdraw"] = { "sacar", "saque" },
        ["transfer"] = { "transferir" },
        ["all"] = { "tudo" },
        ["yes"] = { "sim" },
        ["no"] = { "não", "nao" },
        ["change gold"] = { "trocar ouro" },
        ["change platinum"] = { "trocar platina" },
        ["change crystal"] = { "trocar cristal" },
        ["gold"] = { "ouro" },
        ["crystal"] = { "cristal" },
        ["guild balance"] = { "saldo da guilda", "guilda saldo" },
        ["guild withdraw"] = { "sacar da guilda", "saque da guilda", "guilda sacar" },
        ["guild transfer"] = { "transferir da guilda", "guilda transferir" },
    }
    for _, alias in ipairs(aliases[keyword] or {}) do
        if MsgContains(message, alias) then
            return true
        end
    end
    return false
end

local function bankRecipient(message)
    return string.match(message, "[Tt][Oo]%s+(.+)$")
        or string.match(message, "[Pp][Aa][Rr][Aa]%s+(.+)$")
end

local count = {}
local transfer = {}
local receiptFormat = "Data: %s\nTipo: %s\nValor em ouro: %d\nTitular do recibo: %s\nDestinatário: %s\n\n%s"

local function GetReceipt(info)
	local receipt = Game.createItem(info.success and 19598 or 19599)
	receipt:setAttribute(ITEM_ATTRIBUTE_TEXT, receiptFormat:format(os.date("%d. %b %Y - %H:%M:%S"), info.type, info.amount, info.owner, info.recipient, info.message))

	return receipt
end

function Npc:parseBankMessages(message, npc, creature, npcHandler)
	local messagesTable = {
		["money"] = "Podemos {trocar moedas} para vós. Também podeis consultar vossa {conta bancária}.",
		["change"] = "Há três tipos de moedas em Crystal: \z
                        100 moedas de ouro valem 1 de platina, e 100 de platina valem 1 de cristal. \z
                        Para trocar 100 moedas de ouro por 1 de platina, \z
                        dizei '{trocar ouro}' e depois '1'.",
		["bank"] = "Podemos {trocar moedas} para vós. Também podeis consultar vossa {conta bancária}.",
		["advanced"] = "Vossa conta bancária será usada automaticamente ao {alugar} uma casa ou fazer uma oferta \z
                            por um item no {mercado}. Perguntai-me se desejardes saber como esses serviços funcionam.",
		["help"] = "Podeis consultar vosso {saldo}, {depositar} ouro ou {sacar} moedas. \z
                        Também podeis {transferir} ouro a outros aventureiros, desde que tenham uma vocação.",
		["functions"] = "Podeis consultar vosso {saldo}, {depositar} ouro ou {sacar} moedas. \z
                            Também podeis {transferir} ouro a outros aventureiros, desde que tenham uma vocação.",
		["basic"] = "Podeis consultar vosso {saldo}, {depositar} ouro ou {sacar} moedas. \z
                        Também podeis {transferir} ouro a outros aventureiros, desde que tenham uma vocação.",
		["job"] = "Sirvo neste banco. Posso {trocar moedas} e ajudar-vos com vossa conta bancária.",
		["bank account"] = {
			"Todo aventureiro de Crystal possui uma conta. Podeis acessar vosso ouro em qualquer agência do Banco de Crystal! ...",
			"Desejais conhecer os serviços {básicos} ou os serviços {avançados} de vossa conta, \z
                ou já vos cansastes de minhas explicações?",
		},
	}

    local helpAliases = {
        dinheiro = "money", banco = "bank", ajuda = "help",
        ["funções"] = "functions", funcoes = "functions", trabalho = "job",
        ["básicos"] = "basic", basicos = "basic", ["avançados"] = "advanced", avancados = "advanced",
        ["conta bancária"] = "bank account", ["conta bancaria"] = "bank account",
        ["trocar moedas"] = "change",
    }
    for alias, original in pairs(helpAliases) do
        messagesTable[alias] = messagesTable[original]
    end

    -- Specific account topics must precede generic bank keywords.
    local selected = message
    if MsgContains(message, "bank account") then
        selected = "bank account"
    elseif MsgContains(message, "conta bancária") then
        selected = "conta bancária"
    elseif MsgContains(message, "conta bancaria") then
        selected = "conta bancaria"
    end
    local keys = {}
    for key in pairs(messagesTable) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b)
        if #a == #b then return a < b end
        return #a > #b
    end)
    for _, key in ipairs(keys) do
        if MsgContains(selected, key) then
            npcHandler:say(messagesTable[key], npc, creature, 3000)
            return
        end
    end
end

function Npc:parseBank(message, npc, creature, npcHandler)
	local player = Player(creature)
	local playerId = creature:getId()
	-- Balance
	if bankContains(message, "guild") then
		return true
	end

	if bankContains(message, "balance") then
		local balance = Bank.balance(player)
		if balance >= 100000000 then
			npcHandler:say(
				string.format(
					"Decerto sois um dos habitantes mais ricos destas terras! \z
                           Vosso saldo é de %d moedas de ouro.",
					balance
				),
				npc,
				creature
			)
			return true
		elseif balance >= 10000000 then
			npcHandler:say(
				string.format(
					"Vossa fortuna alcançou dez milhões e continua a crescer! \z
                           Vosso saldo é de %d moedas de ouro.",
					balance
				),
				npc,
				creature
			)
			return true
		elseif balance >= 1000000 then
			npcHandler:say(
				string.format(
					"Pelos deuses, vossa fortuna alcançou um milhão de moedas de ouro! \z
                           Vosso saldo é de %d moedas de ouro!",
					balance
				),
				npc,
				creature
			)
			return true
		elseif balance >= 100000 then
			npcHandler:say(
				string.format(
					"Acumulastes uma bela fortuna. \z
                           Vosso saldo é de %d moedas de ouro.",
					balance
				),
				npc,
				creature
			)
			return true
		else
			npcHandler:say(string.format("Vosso saldo é de %d moedas de ouro.", balance), npc, creature)
			return true
		end
		-- Deposit
	elseif (MsgContains(message, "deposit all") or MsgContains(message, "depositar tudo")) then
		count[playerId] = player:getMoney()
		npcHandler:say(string.format("Desejais depositar %d moedas de ouro?", count[playerId]), npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif bankContains(message, "deposit") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:say(string.format("Desejais depositar %d moedas de ouro?", count[playerId]), npc, creature)
				npcHandler:setTopic(playerId, 2)
			else
				npcHandler:say("Não tendes ouro suficiente.", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
			return true
		end
		count[playerId] = player:getMoney()
		npcHandler:say("Dizei-me quanto ouro desejais depositar. Podeis dizer {tudo}.", npc, creature)
		npcHandler:setTopic(playerId, 1)
	elseif bankContains(message, "all") then
		if npcHandler:getTopic(playerId) == 1 then
			count[playerId] = player:getMoney()
			npcHandler:say(string.format("Desejais depositar %d moedas de ouro?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 2)
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:say(string.format("Desejais depositar %d moedas de ouro?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 2)
			return true
		else
			npcHandler:say("Não tendes ouro suficiente.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if bankContains(message, "yes") then
			if Player.depositMoney(player, count[playerId]) then
				npcHandler:say(
					string.format(
						"Pois bem, acrescentamos %d moedas de ouro ao vosso {saldo}. \z
                               Podeis {sacar} vosso ouro quando desejardes.",
						count[playerId]
					),
					npc,
					creature
				)
			else
				npcHandler:say("Não tendes ouro suficiente.", npc, creature)
			end
		elseif bankContains(message, "no") then
			npcHandler:say("Como desejardes. Posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
		-- Withdraw
	elseif bankContains(message, "withdraw") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:say(string.format("Desejais sacar %d moedas de ouro de vossa conta bancária?", count[playerId]), npc, creature)
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
			npcHandler:say(string.format("Desejais sacar %d moedas de ouro de vossa conta bancária?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 7 then
		if bankContains(message, "yes") then
			local totalValue = count[playerId]
			local crystalCoins = math.floor(totalValue / 10000)
			totalValue = totalValue % 10000
			local platinumCoins = math.floor(totalValue / 100)
			totalValue = totalValue % 100
			local goldCoins = math.floor(totalValue / 1)
			local crystalPiles = math.floor((crystalCoins + 99) / 100)
			local platinumPiles = math.floor((platinumCoins + 99) / 100)
			local goldPiles = math.floor((goldCoins + 99) / 100)
			local totalPiles = crystalPiles + platinumPiles + goldPiles
			if player:getFreeCapacity() >= getMoneyWeight(count[playerId]) then
				if player:getFreeBackpackSlots() >= totalPiles then
					if not player:withdrawMoney(count[playerId]) then
						npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
					else
						npcHandler:say(string.format("Aqui estão vossas %i moedas de ouro. Dizei-me se precisardes de algo mais.", count[playerId]), npc, creature)
					end
				else
					npcHandler:say(
						string.format(
							"Aguardai! Não há espaço em vossa mochila para todas estas moedas.\nVoltai quando houver espaço, para que vosso ouro não caia ao chão!\nRecebereis %i pilhas de cristal (%i moedas), %i de platina (%i moedas) e %i de ouro (%i moedas). Reservai ao menos %i espaços livres em vossa mochila.\n",
							crystalPiles,
							crystalCoins,
							platinumPiles,
							platinumCoins,
							goldPiles,
							goldCoins,
							totalPiles
						),
						npc,
						creature
					)
				end
			else
				npcHandler:say("Aguardai! Não tendes capacidade para carregar todas essas moedas!", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif bankContains(message, "no") then
			npcHandler:say("Vossa vontade será respeitada! Voltai quando desejardes {sacar} vosso ouro.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
		-- Transfer
	elseif bankContains(message, "transfer") then
		count[playerId] = getMoneyCount(message)
		transfer[playerId] = bankRecipient(message)
		if string.match(message, "%d+") then
			if player:getBankBalance() < count[playerId] then
				npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return false
			end
			if transfer[playerId] then
				if player:getName():lower() == transfer[playerId]:lower() then
					npcHandler:say("Informai o nome de outro aventureiro para receber vosso ouro!", npc, creature)
					npcHandler:setTopic(playerId, 0)
					return true
				end
				local playerName = Game.getNormalizedPlayerName(transfer[playerId])
				if playerName then
					local arrayDenied = {
						"accountmanager",
						"rooksample",
						"druidsample",
						"sorcerersample",
						"knightsample",
						"paladinsample",
					}
					if table.contains(arrayDenied, string.gsub(transfer[playerId], " ", "")) then
						npcHandler:say("Esse aventureiro não existe.", npc, creature)
						npcHandler:setTopic(playerId, 0)
						return true
					end
					npcHandler:say(string.format("Desejais transferir %d moedas de ouro para %s?", count[playerId], string.titleCase(transfer[playerId])), npc, creature)
					npcHandler:setTopic(playerId, 13)
					return true
				else
					npcHandler:say("Esse aventureiro não existe.", npc, creature)
					npcHandler:setTopic(playerId, 0)
					return false
				end
			end
			if isValidMoney(count[playerId]) then
				npcHandler:say(string.format("A quem desejais transferir %d moedas de ouro?", count[playerId]), npc, creature)
				npcHandler:setTopic(playerId, 12)
				return true
			end
		end
		npcHandler:say("Dizei-me quanto ouro desejais transferir.", npc, creature)
		npcHandler:setTopic(playerId, 11)
	elseif npcHandler:getTopic(playerId) == 11 then
		count[playerId] = getMoneyCount(message)
		if not Bank.hasBalance(player, count[playerId]) then
			npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		if isValidMoney(count[playerId]) then
			npcHandler:say(string.format("A quem desejais transferir %d moedas de ouro?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 12)
		else
			npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 12 then
		transfer[playerId] = message
		if player:getName():lower() == transfer[playerId]:lower() then
			npcHandler:say("Informai o nome de outro aventureiro para receber vosso ouro!", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		local playerName = Game.getNormalizedPlayerName(transfer[playerId])
		if playerName then
			local arrayDenied = {
				"accountmanager",
				"rooksample",
				"druidsample",
				"sorcerersample",
				"knightsample",
				"paladinsample",
			}
			if table.contains(arrayDenied, string.gsub(transfer[playerId], " ", "")) then
				npcHandler:say("Esse aventureiro não existe.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end
			npcHandler:say(string.format("Desejais transferir %d moedas de ouro para %s?", count[playerId], playerName), npc, creature)
			npcHandler:setTopic(playerId, 13)
		else
			npcHandler:say("Esse aventureiro não existe.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 13 then
		if bankContains(message, "yes") then
			if not player:transferMoneyTo(transfer[playerId], count[playerId]) then
				npcHandler:say("Não podeis transferir ouro para essa conta.", npc, creature)
			else
				npcHandler:say(string.format("Pois bem. Transferistes %d moedas de ouro para %s.", count[playerId], string.titleCase(transfer[playerId])), npc, creature)
				transfer[playerId] = nil
			end
		elseif bankContains(message, "no") then
			npcHandler:say("Pois bem, posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		-- Change money
	elseif bankContains(message, "change gold") then
		npcHandler:say("Quantas moedas de platina desejais receber?", npc, creature)
		npcHandler:setTopic(playerId, 14)
	elseif npcHandler:getTopic(playerId) == 14 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Lamento, não tendes moedas de ouro suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say(string.format("Desejais trocar %d moedas de ouro por %d moedas de platina?", count[playerId] * 100, count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 15)
		end
	elseif npcHandler:getTopic(playerId) == 15 then
		if bankContains(message, "yes") then
			if player:removeItem(ITEM_GOLD_COIN, count[playerId] * 100) then
				player:addItem(ITEM_PLATINUM_COIN, count[playerId])
				npcHandler:say("Aqui tendes vossas moedas.", npc, creature)
			else
				npcHandler:say("Lamento, não tendes moedas de ouro suficientes.", npc, creature)
			end
		else
			npcHandler:say("Pois bem, posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif bankContains(message, "change platinum") then
		npcHandler:say("Desejais trocar vossas moedas de platina por {ouro} ou {cristal}?", npc, creature)
		npcHandler:setTopic(playerId, 16)
	elseif npcHandler:getTopic(playerId) == 16 then
		if bankContains(message, "gold") then
			npcHandler:say("Quantas moedas de platina desejais trocar por {ouro}?", npc, creature)
			npcHandler:setTopic(playerId, 17)
		elseif bankContains(message, "crystal") then
			npcHandler:say("Quantas moedas de cristal desejais receber?", npc, creature)
			npcHandler:setTopic(playerId, 19)
		else
			npcHandler:say("Pois bem, posso ajudar-vos em algo mais?", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 17 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Lamento, não tendes moedas de platina suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say(string.format("Desejais trocar %d moedas de platina por %d moedas de ouro?", count[playerId], count[playerId] * 100), npc, creature)
			npcHandler:setTopic(playerId, 18)
		end
	elseif npcHandler:getTopic(playerId) == 18 then
		if bankContains(message, "yes") then
			if player:removeItem(ITEM_PLATINUM_COIN, count[playerId]) then
				player:addItem(ITEM_GOLD_COIN, count[playerId] * 100)
				npcHandler:say("Aqui tendes vossas moedas.", npc, creature)
			else
				npcHandler:say("Lamento, não tendes moedas de platina suficientes.", npc, creature)
			end
		else
			npcHandler:say("Pois bem, posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Lamento, não tendes moedas de platina suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say(string.format("Desejais trocar %d moedas de platina por %d moedas de cristal?", count[playerId] * 100, count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 20)
		end
	elseif npcHandler:getTopic(playerId) == 20 then
		if bankContains(message, "yes") then
			if player:removeItem(ITEM_PLATINUM_COIN, count[playerId] * 100) then
				player:addItem(ITEM_CRYSTAL_COIN, count[playerId])
				npcHandler:say("Aqui tendes vossas moedas.", npc, creature)
			else
				npcHandler:say("Lamento, não tendes moedas de platina suficientes.", npc, creature)
			end
		else
			npcHandler:say("Pois bem, posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif bankContains(message, "change crystal") then
		npcHandler:say("Quantas moedas de cristal desejais trocar por platina?", npc, creature)
		npcHandler:setTopic(playerId, 21)
	elseif npcHandler:getTopic(playerId) == 21 then
		if getMoneyCount(message) < 1 then
			npcHandler:say("Lamento, não tendes moedas de cristal suficientes.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say(string.format("Desejais trocar %d moedas de cristal por %d moedas de platina?", count[playerId] * 100, count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 22)
		end
	elseif npcHandler:getTopic(playerId) == 22 then
		if bankContains(message, "yes") then
			if player:removeItem(ITEM_CRYSTAL_COIN, count[playerId]) then
				player:addItem(ITEM_PLATINUM_COIN, count[playerId] * 100)
				npcHandler:say("Aqui tendes vossas moedas.", npc, creature)
			else
				npcHandler:say("Lamento, não tendes moedas de cristal suficientes.", npc, creature)
			end
		else
			npcHandler:say("Pois bem, posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	end
end

function Npc:parseGuildBank(message, npc, creature, playerId, npcHandler)
	local player = Player(creature)
	-- Guild balance
	if bankContains(message, "guild balance") then
		npcHandler:setTopic(playerId, 0)
		if not player:getGuild() then
			npcHandler:say("Não pertenceis a uma guilda.", npc, creature)
			return false
		end
		npcHandler:say(string.format("O saldo de vossa guilda é de %d moedas de ouro.", Bank.balance(player:getGuild())), npc, creature)
		return true
		-- Guild deposit
	elseif (MsgContains(message, "guild deposit") or MsgContains(message, "depositar na guilda") or MsgContains(message, "guilda depositar")) then
		if not player:getGuild() then
			npcHandler:say("Não pertenceis a uma guilda.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if not Bank.hasBalance(player, count[playerId]) then
				npcHandler:say("Não tendes ouro suficiente.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return false
			end
			npcHandler:say(string.format("Desejais depositar %d moedas de ouro na {conta da guilda}?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 123)
			return true
		else
			npcHandler:say("Dizei-me quanto ouro desejais depositar na conta de vossa guilda.", npc, creature)
			npcHandler:setTopic(playerId, 122)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 122 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:say(string.format("Desejais depositar %d moedas de ouro na {conta da guilda}?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 123)
			return true
		else
			npcHandler:say("Não tendes ouro suficiente.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 123 then
		if bankContains(message, "yes") then
			npcHandler:say(
				string.format(
					"Registramos uma ordem para depositar %d moedas de ouro \z
                           na conta de vossa guilda. Consultai vossa inbox para ver o recibo.",
					count[playerId]
				),
				npc,
				creature
			)
			local guild = player:getGuild()
			local info = {
				type = "Depósito na guilda",
				amount = count[playerId],
				owner = player:getName() .. " da guilda " .. guild:getName(),
				recipient = guild:getName(),
			}
			local amount = tonumber(count[playerId])
			if Bank.hasBalance(player, amount) then
				info.message = "Informamos que vossa transferência foi concluída com sucesso."
				info.success = true
				Bank.transfer(player, guild, amount)
			else
				info.message = "Lamentamos informar que vossa solicitação não pôde ser atendida, \z
                                pois não há ouro suficiente em vossa conta bancária."
				info.success = false
			end

			local inbox = player:getInbox()
			local receipt = GetReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
		elseif bankContains(message, "no") then
			npcHandler:say("Como desejardes. Posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
		-- Guild withdraw
	elseif bankContains(message, "guild withdraw") then
		if not player:getGuild() then
			npcHandler:say("Lamento, mas não pertenceis a uma guilda.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		elseif player:getGuildLevel() < 2 then
			npcHandler:say("Somente líderes e vice-líderes podem sacar ouro da conta da guilda.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end

		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:say(string.format("Desejais sacar %d moedas de ouro da conta de vossa guilda?", count[playerId]), npc, creature)
				npcHandler:setTopic(playerId, 125)
			else
				npcHandler:say("Não há ouro suficiente na conta de vossa guilda.", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
			return true
		else
			npcHandler:say("Dizei-me quanto ouro desejais sacar da conta de vossa guilda.", npc, creature)
			npcHandler:setTopic(playerId, 124)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 124 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:say(string.format("Desejais sacar %d moedas de ouro da conta de vossa guilda?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 125)
		else
			npcHandler:say("Não há ouro suficiente na conta de vossa guilda.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 125 then
		if bankContains(message, "yes") then
			local guild = player:getGuild()
			npcHandler:say(
				string.format(
					"Registramos uma ordem para sacar %d moedas de ouro da conta de vossa guilda. \z
                            Consultai vossa inbox para ver o recibo.",
					count[playerId]
				),
				npc,
				creature
			)
			local info = {
				type = "Saque da guilda",
				amount = count[playerId],
				owner = player:getName() .. " da guilda " .. guild:getName(),
				recipient = player:getName(),
			}
			if Bank.hasBalance(guild, tonumber(count[playerId])) then
				info.message = "Informamos que vossa transferência foi concluída com sucesso."
				info.success = true
				Bank.transfer(guild, player, tonumber(count[playerId]))
			else
				info.message = "Lamentamos informar que vossa solicitação não pôde ser atendida, \z
                                pois não há ouro suficiente na conta de vossa guilda."
				info.success = false
			end

			local inbox = player:getInbox()
			local receipt = GetReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			npcHandler:setTopic(playerId, 0)
		elseif bankContains(message, "no") then
			npcHandler:say("Como desejardes. Posso ajudar-vos em algo mais?", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
		-- Guild transfer
	elseif bankContains(message, "guild transfer") then
		if not player:getGuild() then
			npcHandler:say("Lamento, mas não pertenceis a uma guilda.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		elseif player:getGuildLevel() < 2 then
			npcHandler:say("Somente líderes e vice-líderes podem transferir ouro da conta da guilda.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end

		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				transfer[playerId] = bankRecipient(message)
				local guildName = Game.getNormalizedGuildName(transfer[playerId])
				if Game.getNormalizedGuildName(transfer[playerId]) then
					npcHandler:say(string.format("Desejais transferir %d moedas de ouro de vossa guilda para a guilda %s?", count[playerId], guildName), npc, creature)
					npcHandler:setTopic(playerId, 128)
				else
					npcHandler:say(string.format("Para qual guilda desejais transferir %d moedas de ouro?", count[playerId]), npc, creature)
					npcHandler:setTopic(playerId, 127)
				end
			else
				npcHandler:say("Não há ouro suficiente na conta de vossa guilda.", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		else
			npcHandler:say("Dizei-me quanto ouro desejais transferir para uma guilda.", npc, creature)
			npcHandler:setTopic(playerId, 126)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 126 then
		count[playerId] = getMoneyCount(message)
		local guild = player:getGuild()
		if not guild or not Bank.hasBalance(guild, count[playerId]) then
			npcHandler:say("Não há ouro suficiente na conta de vossa guilda.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		if isValidMoney(count[playerId]) then
			npcHandler:say(string.format("Para qual guilda desejais transferir %d moedas de ouro?", count[playerId]), npc, creature)
			npcHandler:setTopic(playerId, 127)
		else
			npcHandler:say("Não há ouro suficiente em vossa conta.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 127 then
		transfer[playerId] = message
		local guild = player:getGuild()
		if guild:getName() == transfer[playerId] then
			npcHandler:say("Informai o nome de outra guilda para receber vosso ouro!", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		local guildName = Game.getNormalizedGuildName(transfer[playerId])
		if Game.getNormalizedGuildName(transfer[playerId]) then
			npcHandler:say(string.format("Desejais transferir %d moedas de ouro de vossa guilda para a guilda %s?", count[playerId], guildName), npc, creature)
			npcHandler:setTopic(playerId, 128)
		else
			npcHandler:say("Essa guilda não existe.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end
		return true
	elseif npcHandler:getTopic(playerId) == 128 then
		if bankContains(message, "yes") then
			npcHandler:say(string.format("Registramos uma ordem para transferir %d moedas de ouro de vossa guilda para a guilda %s. Consultai vossa inbox para ver o recibo.", count[playerId], string.titleCase(transfer[playerId])), npc, creature)
			local guild = player:getGuild()
			local info = {
				type = "Transferência entre guildas",
				amount = count[playerId],
				owner = player:getName() .. " da guilda " .. guild:getName(),
				recipient = transfer[playerId],
			}
			local amount = tonumber(count[playerId])
			if Bank.transferToGuild(guild, transfer[playerId], amount) then
				logger.info("Guild {} transferred {} gold to guild {}.", guild:getName(), amount, transfer[playerId])
				info.success = true
				info.message = "Informamos que vossa transferência foi concluída com sucesso."
			else
				logger.info("Guild {} failed to transfer {} gold to guild {}.", guild:getName(), amount, transfer[playerId])
				info.message = "Lamentamos informar que vossa solicitação não pôde ser atendida, pois não há ouro suficiente na conta de vossa guilda."
				info.success = false
			end
			local inbox = player:getInbox()
			local receipt = GetReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			npcHandler:setTopic(playerId, 0)
		elseif bankContains(message, "no") then
			npcHandler:say("Pois bem, posso ajudar-vos em algo mais?", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	end
end

-- Greet callback
function NpcBankGreetCallback(npc, creature)
	local playerId = creature:getId()
	count[playerId], transfer[playerId] = nil, nil
	return true
end
