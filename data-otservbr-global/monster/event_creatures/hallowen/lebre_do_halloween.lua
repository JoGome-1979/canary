local mType = Game.createMonsterType("Lebre do Halloween")
local monster = {}

monster.description = "a Lebre do Halloween"
monster.experience = 10000
monster.outfit = {
	lookType = 74,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 5000
monster.maxHealth = 5000
monster.race = "blood"
monster.corpse = 0
monster.speed = 400
monster.manaCost = 0

monster.changeTarget = {
	interval = 2000,
	chance = 95,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = false,
	staticAttackChance = 10,
	targetDistance = 4,
	runHealth = 1000,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.voices = {
	interval = 5000,
	chance = 10,
}

monster.loot = {}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -10, maxDamage = -100 },
	{ name = "outfit", interval = 20000, chance = 10, radius = 3, effect = CONST_ME_BLOCKHIT, target = false, duration = 60000, outfitMonster = "Memory of a Vampire" },
	{ name = "outfit", interval = 20000, chance = 10, radius = 3, effect = CONST_ME_BLOCKHIT, target = false, duration = 60000, outfitMonster = "Guardiao das Aboboras" },
	{ name = "outfit", interval = 20000, chance = 10, radius = 3, effect = CONST_ME_BLOCKHIT, target = false, duration = 60000, outfitMonster = "Caveira das Almas"},
	{ name = "outfit", interval = 20000, chance = 10, radius = 3, effect = CONST_ME_BLOCKHIT, target = false, duration = 60000, outfitMonster = "Undead Minion" },
	{ name = "outfit", interval = 20000, chance = 10, radius = 3, effect = CONST_ME_BLOCKHIT, target = false, duration = 60000, outfitMonster = "Draken Elite" },

}

monster.defenses = {
	defense = 144,
	armor = 144,
	mitigation = 0.00,
	{ name = "combat", interval = 10000, chance = 50, type = COMBAT_HEALING, minDamage = 1500, maxDamage = 2000, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 100 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 100 },
	{ type = COMBAT_EARTHDAMAGE, percent = 100 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 100 },
	{ type = COMBAT_ICEDAMAGE, percent = 100 },
	{ type = COMBAT_HOLYDAMAGE, percent = 100 },
	{ type = COMBAT_DEATHDAMAGE, percent = 100 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

mType:register(monster)
