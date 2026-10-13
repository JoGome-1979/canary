local mType = Game.createMonsterType("Guardiao das Aboboras")
local monster = {}

monster.description = "um guardião das abóboras"
monster.experience = 500

monster.outfit = {
	lookType = 1950,
}

monster.health = 6500
monster.maxHealth = 6500
monster.race = "venom"
monster.speed = 80
monster.corpse = 54267

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
	targetDistance = 1,
	runHealth = 150,
}

monster.attacks = {
	{
		name = "melee",
		interval = 2000,
		chance = 75,
		minDamage = -10,
		maxDamage = -200,
	},
}

monster.defenses = {
	defense = 0,
	armor = 0,
}

monster.loot = {
	{ id = 54268, chance = 33000, maxCount = 2 },
}


mType:register(monster)