local rookgaardAdvance = CreatureEvent("RookgaardAdvance")
function rookgaardAdvance.onAdvance(player, skill, oldLevel, newLevel)
	if skill ~= SKILL_LEVEL or newLevel ~= 8 or player:getVocation():getId() ~= 0 then
		return true
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Parabéns! Você está pronto para deixar esta ilha e escolher sua vocação. Procure o Oráculo, localizado acima da academia em Rookgaard, antes de alcançar o nível 10!")
	return true
end

rookgaardAdvance:register()
