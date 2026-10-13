local mType = Game.createMonsterType("Caveira das Almas Guerreira")
local monster = {}

monster.description = "caveira das almas guerreira"
monster.experience = 5600

monster.outfit = {
	lookType = 33,
}

monster.health = 15000
monster.maxHealth = 15000
monster.race = "undead"
monster.speed = 244
monster.corpse = 5972

monster.flags = {
    summonable = false,       -- Jogador pode invocar
    attackable = true,        -- Pode receber ataques
    hostile = true,           -- Ataca jogadores
    convinceable = false,     -- Pode ser convencido
    illusionable = false,     -- Jogador pode copiar sua aparência

    pushable = false,         -- Pode ser empurrado
    canPushItems = true,      -- Pode afastar itens do caminho
    canPushCreatures = true,  -- Pode empurrar criaturas permitidas

    targetDistance = 1,       -- Distância desejada do alvo, em pisos
    runHealth = 200,            -- Vida abaixo da qual foge; 0 desativa
    staticAttackChance = 90,  -- Chance de ficar parado ao lutar junto ao alvo
    critChance = 10,           -- Chance de acerto crítico

    healthHidden = false,    -- Esconde a barra de vida

    canWalkOnEnergy = true, -- Aceita atravessar campos de energia
    canWalkOnFire = false,   -- Aceita atravessar campos de fogo
    canWalkOnPoison = true,  -- Aceita atravessar campos de veneno

    isBlockable = false,      -- Pode ser bloqueado fisicamente no caminho
    isPreyable = false,      -- Pode participar do sistema Prey
    isPreyExclusive = false, -- Marca como exclusivo de Prey
    isForgeCreature = false, -- Participa da seleção de criaturas da Forge

    rewardBoss = false,      -- Usa o sistema de recompensa de boss
    familiar = false,        -- Identifica como familiar
}

monster.light = {
	level = 2,
	color = 35,
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "Gnarrr!", yell = false },
	{ text = "Tcharrr!", yell = false },
	{ text = "Rrrah!", yell = false },
	{ text = "Rraaar!", yell = false },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -100, maxDamage = -700 },
	{ name = "combat", interval = 2000, chance = 15, type = COMBAT_LIFEDRAIN, minDamage = -300, maxDamage = -480, range = 1, effect = CONST_ME_MAGIC_RED, target = false },
	{ name = "combat", interval = 1500, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -380, maxDamage = -520, range = 7, shootEffect = CONST_ANI_SUDDENDEATH, effect = CONST_ME_MORTAREA, target = false },
}

monster.defenses = {
	defense = 15,
	armor = 75,
	mitigation = 2.16,
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = -5 },
	{ type = COMBAT_EARTHDAMAGE, percent = 5 },
	{ type = COMBAT_FIREDAMAGE, percent = -5 },
	{ type = COMBAT_LIFEDRAIN, percent = 0 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 0 },
	{ type = COMBAT_ICEDAMAGE, percent = 0 },
	{ type = COMBAT_HOLYDAMAGE, percent = -25 },
	{ type = COMBAT_DEATHDAMAGE, percent = 100 },
}

monster.immunities = {
	{ type = "paralyze", condition = false },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

monster.loot = {
    { id = 54270, chance = 25000, maxCount = 1 },
}


mType:register(monster)