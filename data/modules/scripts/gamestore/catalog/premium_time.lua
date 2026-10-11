local premiumCategoryName = "Premium Time"
local premiumOfferName = "Premium Time"

if configManager.getBoolean(configKeys.VIP_SYSTEM_ENABLED) then
	premiumCategoryName = "VIP Shop"
	premiumOfferName = "VIP"
end

local premiumDescription =
	"<i>Aproveite %d dias de Premium e desbloqueie novas possibilidades para sua aventura no Crystal!</i>\n\n&#8226; acesso às áreas Premium\n&#8226; viagens de navio e tapete mágico\n&#8226; acesso a mais magias\n&#8226; possibilidade de alugar casas\n&#8226; criação de guildas\n&#8226; treinamento offline\n&#8226; mais espaço nos depots\n&#8226; e muitas outras vantagens\n\n{usablebyallicon} válido para todos os personagens desta conta\n{activated} ativado imediatamente após a compra"

if configManager.getBoolean(configKeys.VIP_SYSTEM_ENABLED) then
	local vipBonusExp = configManager.getNumber(configKeys.VIP_BONUS_EXP)
	local vipBonusLoot = configManager.getNumber(configKeys.VIP_BONUS_LOOT)
	local vipBonusSkill = configManager.getNumber(configKeys.VIP_BONUS_SKILL)
	local vipStayOnline = configManager.getBoolean(configKeys.VIP_STAY_ONLINE)

	premiumDescription = "<i>Enhance your gaming experience by gaining advantages:</i>\n\n"
	if vipBonusExp > 0 then
		premiumDescription = premiumDescription .. "&#8226; +" .. vipBonusExp .. "% experience rate\n"
	end
	if vipBonusSkill > 0 then
		premiumDescription = premiumDescription .. "&#8226; +" .. vipBonusSkill .. "% skill training speed\n"
	end
	if vipBonusLoot > 0 then
		premiumDescription = premiumDescription .. "&#8226; +" .. vipBonusLoot .. "% loot\n"
	end
	if vipStayOnline then
		premiumDescription = premiumDescription .. "&#8226; stay online idle without getting disconnected\n"
	end
	premiumDescription = premiumDescription .. "\n{usablebyallicon} valid for all characters on this account\n{activated}"
end

return {
	icons = { "Category_PremiumTime.png" },
	name = premiumCategoryName,
	rookgaard = true,
	state = GameStore.States.STATE_NONE,
	offers = {
		{
			icons = { "Premium_Time_30.png" },
			name = string.format("7 Dias de %s", premiumOfferName),
			price = 150,
			id = 3007,
			validUntil = 7,
			description = string.format(premiumDescription, 7),
			type = GameStore.OfferTypes.OFFER_TYPE_PREMIUM,
		},
		{
			icons = { "Premium_Time_30.png" },
			name = string.format("15 Dias de %s", premiumOfferName),
			price = 270,
			id = 3015,
			validUntil = 15,
			description = string.format(premiumDescription, 15),
			type = GameStore.OfferTypes.OFFER_TYPE_PREMIUM,
		},
		{
			icons = { "Premium_Time_30.png" },
			name = string.format("30 Dias de %s", premiumOfferName),
			price = 500,
			id = 3030,
			validUntil = 30,
			description = string.format(premiumDescription, 30),
			type = GameStore.OfferTypes.OFFER_TYPE_PREMIUM,
		},
		{
			icons = { "Premium_Time_90.png" },
			name = string.format("90 Dias de %s", premiumOfferName),
			price = 1350,
			id = 3090,
			validUntil = 90,
			description = string.format(premiumDescription, 90),
			type = GameStore.OfferTypes.OFFER_TYPE_PREMIUM,
		},
		{
			icons = { "Premium_Time_180.png" },
			name = string.format("180 Dias de %s", premiumOfferName),
			price = 2500,
			id = 3180,
			validUntil = 180,
			description = string.format(premiumDescription, 180),
			type = GameStore.OfferTypes.OFFER_TYPE_PREMIUM,
		},
		{
			icons = { "Premium_Time_360.png" },
			name = string.format("360 Dias de %s", premiumOfferName),
			price = 4500,
			id = 3360,
			validUntil = 360,
			description = string.format(premiumDescription, 360),
			type = GameStore.OfferTypes.OFFER_TYPE_PREMIUM,
		},
	},
}
