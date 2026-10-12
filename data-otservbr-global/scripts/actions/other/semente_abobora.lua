local config = {
	itemId = 54268,
	durationMinutes = 10,
	damageDealt = 110, -- Causa 110% do dano normal.
	damageReceived = 90, -- Recebe 90% do dano normal.
	subId = 54268, -- Identificador deste bônus.
}

local bonus = Condition(CONDITION_ATTRIBUTES)
bonus:setParameter(CONDITION_PARAM_SUBID, config.subId)
bonus:setParameter(
	CONDITION_PARAM_TICKS,
	config.durationMinutes * 60 * 1000
)
bonus:setParameter(CONDITION_PARAM_BUFF_DAMAGEDEALT, config.damageDealt)
bonus:setParameter(CONDITION_PARAM_BUFF_DAMAGERECEIVED, config.damageReceived)
bonus:setParameter(CONDITION_PARAM_BUFF_SPELL, true)

local seed = Action()

function seed.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getCondition(
		CONDITION_ATTRIBUTES,
		CONDITIONID_COMBAT,
		config.subId
	) then
		player:sendCancelMessage("O poder da semente já está ativo.")
		return true
	end

	if not player:addCondition(bonus) then
		player:sendCancelMessage("Não foi possível ativar a semente.")
		return true
	end

	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    
    local message = string.format(
	    "O poder da abóbora fortalece você por %d minutos: +%d%% de dano causado e -%d%% de dano recebido.",
	    config.durationMinutes,
	    config.damageDealt - 100,
	    100 - config.damageReceived
    )

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)

	return true
end

seed:id(config.itemId)
seed:register()