local config = {
    equippedRingId = 54271,

    -- Reservado para o futuro item que atravessa a proteção.
    piercing = {
        enabled = false,
        itemIds = {
            -- [ID_DO_ITEM] = true,
        },
        slots = { CONST_SLOT_LEFT },
    },
}

local function canPierce(attacker)
    if not config.piercing.enabled or not attacker then
        return false
    end

    local player = attacker:getPlayer()
    if not player then
        return false
    end

    for _, slot in ipairs(config.piercing.slots) do
        local item = player:getSlotItem(slot)

        if item and config.piercing.itemIds[item:getId()] then
            return true
        end
    end

    return false
end

local protection = CreatureEvent("AnelEternidadeProtecao")

function protection.onHealthChange(
    creature, attacker,
    primaryDamage, primaryType,
    secondaryDamage, secondaryType,
    origin
)
    if not creature:isPlayer() then
        return primaryDamage, primaryType,
            secondaryDamage, secondaryType
    end

    local ring = creature:getSlotItem(CONST_SLOT_RING)

    if not ring or ring:getId() ~= config.equippedRingId then
        return primaryDamage, primaryType,
            secondaryDamage, secondaryType
    end

    if canPierce(attacker) then
        return primaryDamage, primaryType,
            secondaryDamage, secondaryType
    end

    -- Bloqueia dano, preservando as curas.
    if primaryType ~= COMBAT_HEALING then
        primaryDamage = 0
    end

    if secondaryType ~= COMBAT_HEALING then
        secondaryDamage = 0
    end

    return primaryDamage, primaryType,
        secondaryDamage, secondaryType
end

protection:register()

local login = CreatureEvent("AnelEternidadeLogin")

function login.onLogin(player)
    player:registerEvent("AnelEternidadeProtecao")
    return true
end

login:register()