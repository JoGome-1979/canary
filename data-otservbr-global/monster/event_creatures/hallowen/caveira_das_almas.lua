local mType = Game.createMonsterType("Caveira das Almas")
local monster = {}

monster.description = "caveira das almas"
monster.experience = 750
monster.manaCost = 375

monster.outfit = {
	lookType = 33,
}

monster.health = 5000
monster.maxHealth = 5000
monster.race = "undead"
monster.speed = 100
monster.corpse = 5972

monster.flags = {
    summonable = true,       -- Jogador pode invocar
    attackable = true,        -- Pode receber ataques
    hostile = true,           -- Ataca jogadores
    convinceable = true,     -- Pode ser convencido
    illusionable = true,     -- Jogador pode copiar sua aparência

    pushable = false,         -- Pode ser empurrado
    canPushItems = true,      -- Pode afastar itens do caminho
    canPushCreatures = true,  -- Pode empurrar criaturas permitidas

    targetDistance = 1,       -- Distância desejada do alvo, em pisos
    runHealth = 0,            -- Vida abaixo da qual foge; 0 desativa
    staticAttackChance = 90,  -- Chance de ficar parado ao lutar junto ao alvo
    critChance = 0,           -- Chance de acerto crítico

    healthHidden = false,    -- Esconde a barra de vida

    canWalkOnEnergy = true, -- Aceita atravessar campos de energia
    canWalkOnFire = true,   -- Aceita atravessar campos de fogo
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
	{ name = "melee", interval = 2000, chance = 50, minDamage = 0, maxDamage = -230, effect = CONST_ME_DRAWBLOOD },
	-- Projétil mágico de morte
	{
		name = "combat",
		type = COMBAT_DEATHDAMAGE,
		interval = 5000,
		chance = 20,
		range = 10,
		target = true,
		minDamage = -50,
		maxDamage = -180,
		shootEffect = CONST_ANI_DEATH,
		effect = CONST_ME_MORTAREA,
	},
}

monster.defenses = {
	defense = 45,
	armor = 40,
	mitigation = 1.46,
	{ name = "speed", interval = 2000, chance = 35, speedChange = 270, effect = CONST_ME_MAGIC_GREEN, target = false, duration = 5000 },
	{ name = "combat", interval = 2000, chance = 10, type = COMBAT_HEALING, minDamage = 25, maxDamage = 75, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = -25 },
	{ type = COMBAT_EARTHDAMAGE, percent = -10 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 100 },
	{ type = COMBAT_ICEDAMAGE, percent = 100 },
	{ type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 0 },
}

monster.immunities = {
	{ type = "paralyze", condition = false },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

monster.loot = {
    { id = 3049, chance = 25000, maxCount = 1 },
}


mType:register(monster)