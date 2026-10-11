local dawnportAdvance = CreatureEvent("DawnportAdvance")
local dawnportEvents = {}

-- Teleport to the dawnport temple after reaching level 20 (the player has five minutes before being teleported)
local function teleportToDawnportTemple(uid)
	local player = Player(uid)
	table.remove(dawnportEvents, uid)
	-- If not have the Oressa storage, teleport player to the temple
	if player and player:getStorageValue(Storage.Dawnport.DoorVocation) == -1 then
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
end

function dawnportAdvance.onAdvance(player, skill, oldLevel, newLevel)
	local town = player:getTown()
	-- Check that resides on dawnport
	if town and town:getId() == TOWNS_LIST.DAWNPORT then
		if skill == SKILL_LEVEL then
			-- Notify min level to leave dawnport
			if newLevel == 8 then
				player:sendTextMessage(
    				MESSAGE_EVENT_ADVANCE,
    				"Parabéns! \z
    				Agora você pode escolher sua vocação e deixar Dawnport. Fale com Oressa no templo."
				)
				-- Notify max level to stay in dawnport
			elseif newLevel >= 20 then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você atingiu o nível máximo permitido em Dawnport. Agora deve escolher sua vocação e deixar a ilha.")
				if not dawnportEvents[player:getId()] then
					-- Adds the event that teleports the player to the temple in five minutes after reaching level 20
					dawnportEvents[player:getId()] = addEvent(teleportToDawnportTemple, 5 * 60 * 1000, player:getId())
				end
			end
			-- Notify reached a skill limit
		elseif skill ~= SKILL_LEVEL and isSkillGrowthLimited(player, skill) then
			if skill == SKILL_MAGLEVEL then
				player:sendTextMessage(
					MESSAGE_EVENT_ADVANCE,
					"Você não pode treinar seu nível mágico mais. \z
					Se você quiser melhorá-lo mais, você deve ir para o continente."
				)
			else
				player:sendTextMessage(
    				MESSAGE_EVENT_ADVANCE,
    				"Você não pode mais aumentar o nível de suas habilidades. \z
    				Se deseja continuar aprimorando-as, deverá ir para o continente."
				)
			end
		end
	end
	return true
end

dawnportAdvance:register()
