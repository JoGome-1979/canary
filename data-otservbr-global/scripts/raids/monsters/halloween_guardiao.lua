local regions = {
    {
        monster = "Guardiao das Aboboras",
        locin = Position(32652, 32690, 7),
        locout = Position(32662, 32700, 7),
        amount = 5,
    },
    {
        monster = "Guardiao das Aboboras",
        locin = Position(32415, 32320, 7),
        locout = Position(32425, 32330, 7),
        amount = 7,
    },
    {
        monster = "Guardiao das Aboboras",
        locin = Position(31991, 32210, 7),
        locout = Position(32001, 32220, 7),
        amount = 5,
    },
}

local raidName = "halloween.guardiao"
local zone = Zone(raidName)

for i, region in ipairs(regions) do
    region.zone = Zone(raidName .. ".regiao" .. i)
    region.zone:addArea(region.locin, region.locout)
    zone:addArea(region.locin, region.locout)
end

local raid = Raid(raidName, {
    zone = zone,
    minActivePlayers = 0,
})

raid:addBroadcast(
    "A noite de Halloween chegou... Uma energia sombria se espalha pelo reino."
):autoAdvance("30s")

raid:addBroadcast(
    "Algo sinistro está acontecendo em diferentes regiões do reino... Aventureiros, fiquem atentos!"
):autoAdvance("1s")

raid:addStage({
    start = function()
        for _, region in ipairs(regions) do
            for i = 1, region.amount do
                raid:spawnMonsters({
                    name = region.monster,
                    amount = 1,
                    position = region.zone:randomPosition(),
                })
            end
        end
    end,
}):autoAdvance("1m")

raid:register()