-- Intervalo entre os nascimentos de duas regiões consecutivas.
local config = {
    manualEnabled = true, -- Usa as posições da tabela monsters de cada região.
    mapSpawnsEnabled = true, -- Usa pontos encontrados no XML de spawns.
    intervalMinutes = 20,
    warningSeconds = 30,
    finishSeconds = 60,
}

-- Modo global: uma criatura do evento perto de cada spawn do arquivo inteiro.
-- A ativação é controlada por config.mapSpawnsEnabled, acima.
local mapSpawns = {
    spawnFile = "/home/canary/data-otservbr-global/world/otservbr-monster.xml",
    raio = 5,
    minDistance = 2,
    monsters = {
        "Lebre do Halloween"
    },
}

-- Cada chave identifica uma região e aparece nos anúncios.
-- Campos opcionais por região:
-- warning = "Uma névoa sinistra se aproxima de Thais...",
-- announcement = "O Halloween tomou as ruas de Thais!",
-- Sem esses campos, os textos abaixo usam o nome da região.
local regions = {
    ["THAIS"] = {
        warning = "Uma névoa sombria se aproxima de Thais...",
        announcement = "Algo sinistro tomou as ruas de Thais!",
        monsters = {
            {monster = "Guardiao das Aboboras", pos = Position(32377, 32150, 7), raio = 5, amount = 5},
            {monster = "Guardiao das Aboboras", pos = Position(32462, 32238, 7), raio = 5, amount = 5},
            {monster = "Guardiao das Aboboras", pos = Position(32360, 32304, 7), raio = 5, amount = 7}
        }
    },
    ["Ab'Dendriel"] = {
        warning = "A névoa sombria esta se esplahando pelo reino, se aproxima de Ab'Dendriel...",
        announcement = "Algo sinistro tomou as ruas de Ab'Dendriel! Parece que o Halloween chegou a cidade.",
        monsters = {
            {monster = "Caveira das Almas", pos = Position(32713, 31631, 7), raio = 1, amount = 1},
            {monster = "Caveira das Almas", pos = Position(32702, 31640, 7), raio = 1, amount = 1},
            {monster = "Caveira das Almas Guerreira", pos = Position(32702, 31641, 6), raio = 1, amount = 1},
            {monster = "Caveira das Almas", pos = Position(32698, 31651, 7), raio = 1, amount = 1},
            {monster = "Caveira das Almas", pos = Position(32705, 31681, 7), raio = 1, amount = 1},
            {monster = "Caveira das Almas", pos = Position(32668, 31673, 7), raio = 1, amount = 1},
            {monster = "Caveira das Almas", pos = Position(32655, 31665, 8), raio = 5, amount = 3},
            {monster = "Caveira das Almas", pos = Position(32647, 31685, 8), raio = 1, amount = 1},
            {monster = "Caveira das Almas", pos = Position(32687, 31676, 7), raio = 1, amount = 1},
            {monster = "Caveira das Almas", pos = Position(32686, 31699, 7), raio = 1, amount = 1}
        }
    },
    ["Ankrahmun"] = {
        warning = "A névoa sombria do Halloween se aproxima de Ankrahmun...",
        announcement = "Algo sinistro tomou os portões de Ankrahmun!",
        monsters = {
            {monster = "Caveira das Almas", pos = Position(33185, 32881, 7), raio = 3, amount = 2},
            {monster = "Caveira das Almas", pos = Position(33166, 32745, 7), raio = 8, amount = 8},
            {monster = "Caveira das Almas", pos = Position(33250, 32779, 7), raio = 10, amount = 10}
        }
    },
    ["Bounac"] = {
        warning = "Algo estranho se aproxima de Bounac...",
        announcement = "Algo sinistro tomou os arredores de Bounac!",
        monsters = {
            {monster = "Caveira das Almas Guerreira", pos = Position(32435, 32454, 7), raio = 1, amount = 1}
        }
    },
    ["Candia"] = {
        warning = "Tenham cuidada, as aguas de Candia estão estranhas...",
        announcement = "Algo sinistro tomou os arredores de Candia!",
        monsters = {
            {monster = "Guardiao das Aboboras", pos = Position(33353, 32130, 7), raio = 10, amount = 5}
        }
    },
    ["Carlin"] = {
        warning = "Os muros de Carlin estão frageis...",
        announcement = "Algo sinistro tomou os arredores de Carlin!",
        monsters = {
            {monster = "Guardiao das Aboboras", pos = Position(32408, 31781, 7), raio = 3, amount = 3},
            {monster = "Guardiao das Aboboras", pos = Position(32437, 31746, 7), raio = 7, amount = 7},
            {monster = "Caveira das Almas", pos = Position(32350, 31735, 7), raio = 7, amount = 5},
            {monster = "Caveira das Almas Guerreira", pos = Position(32387, 31806, 7), raio = 1, amount = 1},
        }
    }
}

-- O XML é somente lido; nenhum spawn original é removido ou substituído.
local function readMapSpawnPoints()
    local file, reason = io.open(mapSpawns.spawnFile, "r")
    if not file then
        logger.warn("Halloween: falha ao ler {}: {}.", mapSpawns.spawnFile, reason)
        return {}
    end
    local xml = file:read("*a")
    file:close()
    xml = xml:gsub("<!%-%-.-%-%->", "")
    local function attribute(text, name)
        return text:match(name .. '%s*=%s*"([^"<>]*)"')
            or text:match(name .. "%s*=%s*'([^'<>]*)'")
    end
    local points, seen = {}, {}
    for attrs, body in xml:gmatch("<monster%s+([^>]-)>(.-)</monster%s*>") do
        local cx, cy, cz = tonumber(attribute(attrs, "centerx")), tonumber(attribute(attrs, "centery")), tonumber(attribute(attrs, "centerz"))
        if cx and cy and cz then
            for child in body:gmatch("<monster%s+([^>]-)/%s*>") do
                local dx, dy = tonumber(attribute(child, "x")), tonumber(attribute(child, "y"))
                local z = tonumber(attribute(child, "z")) or cz
                if dx and dy then
                    local x, y = cx + dx, cy + dy
                    local key = x .. ":" .. y .. ":" .. z
                    if x >= 0 and x <= 65535 and y >= 0 and y <= 65535 and z >= 0 and z <= 15 and not seen[key] then
                        seen[key] = true
                        points[#points + 1] = Position(x, y, z)
                    end
                end
            end
        end
    end
    return points
end

local originalSpawnTiles = {}
local raidName = "halloween"
local zone = Zone(raidName)
local regionNames = {}

assert(config.intervalMinutes * 60 > config.warningSeconds,
    "Halloween: o intervalo deve ser maior que a antecedência do anúncio.")

for regionName, region in pairs(config.manualEnabled and regions or {}) do
    regionNames[#regionNames + 1] = regionName
    assert(type(region.monsters) == "table" and #region.monsters > 0,
        "Halloween: região sem monstros: " .. regionName)
    for _, entry in ipairs(region.monsters) do
        assert(entry.pos and type(entry.raio) == "number",
            "Halloween: informe pos e raio para cada monstro de " .. regionName)
        assert(entry.raio >= 0 and entry.raio <= 100 and entry.raio == math.floor(entry.raio),
            "Halloween: raio deve ser inteiro entre 0 e 100: " .. regionName)
        assert(type(entry.amount) == "number" and entry.amount >= 1 and entry.amount == math.floor(entry.amount),
            "Halloween: amount deve ser um inteiro positivo: " .. regionName)
        assert(entry.pos.x - entry.raio >= 0 and entry.pos.y - entry.raio >= 0
            and entry.pos.x + entry.raio <= 65535 and entry.pos.y + entry.raio <= 65535,
            "Halloween: área fora dos limites do mapa: " .. regionName)
        -- A zona engloba a área para controle da raid; os nascimentos usam o círculo abaixo.
        zone:addArea(
            Position(entry.pos.x - entry.raio, entry.pos.y - entry.raio, entry.pos.z),
            Position(entry.pos.x + entry.raio, entry.pos.y + entry.raio, entry.pos.z)
        )
    end
end

table.sort(regionNames)

local raid = Raid(raidName, {
    zone = zone,
    minActivePlayers = 0,
})

if config.mapSpawnsEnabled then
    assert(type(mapSpawns.raio) == "number" and mapSpawns.raio >= 1 and mapSpawns.raio <= 100 and mapSpawns.raio == math.floor(mapSpawns.raio), "Halloween: raio global inválido.")
    assert(type(mapSpawns.minDistance) == "number" and mapSpawns.minDistance >= 1 and mapSpawns.minDistance <= mapSpawns.raio, "Halloween: minDistance global inválida.")
    if type(mapSpawns.monsters) == "string" then mapSpawns.monsters = { mapSpawns.monsters } end
    assert(type(mapSpawns.monsters) == "table" and #mapSpawns.monsters > 0, "Halloween: informe a lista de monstros global.")
    for _, name in ipairs(mapSpawns.monsters) do
        assert(type(name) == "string" and name ~= "", "Halloween: informe um nome de monstro global válido.")
    end
end
if not config.mapSpawnsEnabled and #regionNames == 0 then
    function raid:tryStart(force) return false end
    raid:register()
    return
end

local function announce(message)
    raid:broadcast(MESSAGE_EVENT_ADVANCE, message)
    Webhook.sendMessage(":space_invader: " .. message, announcementChannels["raids"])
end

-- Sorteia pontos distintos dentro da circunferência, no mesmo andar do centro.
local function getSpawnPositions(entry, reserved)
    local candidates = {}
    for dx = -entry.raio, entry.raio do
        for dy = -entry.raio, entry.raio do
            local distanceSquared = dx * dx + dy * dy
            local x, y = entry.pos.x + dx, entry.pos.y + dy
            if distanceSquared <= entry.raio * entry.raio and distanceSquared >= (entry.minDistance or 0) ^ 2
                and x >= 0 and x <= 65535 and y >= 0 and y <= 65535 then
                candidates[#candidates + 1] = Position(x, y, entry.pos.z)
            end
        end
    end
    for index = #candidates, 2, -1 do
        local other = math.random(index)
        candidates[index], candidates[other] = candidates[other], candidates[index]
    end
    local positions = {}
    for _, position in ipairs(candidates) do
        local key = position.x .. ":" .. position.y .. ":" .. position.z
        local tile = Tile(position)
        if not reserved[key] and not (entry.mapSpawn and originalSpawnTiles[key]) and tile and tile:isWalkable(true, true, true, true)
            and not tile:hasFlag(TILESTATE_TELEPORT) then
            reserved[key] = true
            positions[#positions + 1] = position
            if #positions == entry.amount then
                break
            end
        end
    end
    return positions
end

-- Uma passagem global por chamada do scheduler, sem temporizador de repetição.
if config.mapSpawnsEnabled then
    raid:addBroadcast("A noite de Halloween chegou... Uma energia sombria se espalha pelo reino.")
        :autoAdvance(config.warningSeconds .. "s")
    raid:addStage({
        start = function()
            announce("Algo sinistro está acontecendo por todo o reino... Aventureiros, fiquem atentos!")
            local points = readMapSpawnPoints()
            originalSpawnTiles = {}
            for _, pos in ipairs(points) do
                originalSpawnTiles[pos.x .. ":" .. pos.y .. ":" .. pos.z] = true
            end
            local cursor, created, failed = 1, 0, 0
            local reserved = {}
            local function processBatch()
                local last = math.min(cursor + 49, #points)
                while cursor <= last do
                    local center = points[cursor]
                    local positions = getSpawnPositions({ pos = center, raio = mapSpawns.raio,
                        minDistance = mapSpawns.minDistance, amount = 1, mapSpawn = true }, reserved)
                    local position = positions[1]
                    local name = mapSpawns.monsters[math.random(#mapSpawns.monsters)]
                    if position and Game.createMonster(name, position, false, false) then
                        created = created + 1
                    else
                        failed = failed + 1
                    end
                    cursor = cursor + 1
                end
                if cursor <= #points then
                    raid:addEvent(processBatch, 100)
                else
                    logger.info("Halloween global concluído: {} posições, {} monstros criados, {} pontos sem nascimento.", #points, created, failed)
                    originalSpawnTiles = {}
                    raid:nextStage()
                end
            end
            processBatch()
        end,
    })
end

-- Cada início monta uma nova ordem, sem repetir regiões dentro da rodada.
local regionOrder = {}
raid:addStage({
    start = function()
        regionOrder = {}
        for index, name in ipairs(regionNames) do
            regionOrder[index] = name
        end
        for index = #regionOrder, 2, -1 do
            local other = math.random(index)
            regionOrder[index], regionOrder[other] = regionOrder[other], regionOrder[index]
        end
    end,
}):autoAdvance("1s")

local function addRegionStages(orderIndex)
    raid:addStage({
        start = function()
            local name = regionOrder[orderIndex]
            local region = regions[name]
            announce(region.warning or ("Uma energia sombria se aproxima de " .. name .. "... O Halloween está chegando!"))
        end,
    }):autoAdvance(config.warningSeconds .. "s")

    raid:addStage({
        start = function()
            local name = regionOrder[orderIndex]
            local region = regions[name]
            announce(region.announcement or ("O Halloween chegou a " .. name .. "! Algo sinistro espreita a região. Aventureiros, preparem-se!"))
            local reserved = {}
            for _, entry in ipairs(region.monsters) do
                local positions = getSpawnPositions(entry, reserved)
                if #positions < entry.amount then
                    logger.warn("Halloween: {} / {} posições livres para {} em {} (raio {}).",
                        #positions, entry.amount, entry.monster, name, entry.raio)
                end
                raid:spawnMonsters({
                    name = entry.monster,
                    positions = positions,
                })
            end
        end,
    }):autoAdvance(orderIndex < #regionNames
        and ((config.intervalMinutes * 60 - config.warningSeconds) .. "s")
        or (config.finishSeconds .. "s"))
end

for index = 1, #regionNames do
    addRegionStages(index)
end

if #regionNames == 0 then
    raid:addStage({ start = function() end }):autoAdvance(config.finishSeconds .. "s")
end

-- O scheduler força o início; recusa uma segunda rodada enquanto esta estiver ativa.
local originalTryStart = raid.tryStart
function raid:tryStart(force)
    if self.currentStage ~= Encounter.unstarted then
        return false
    end
    -- O datapack carrega os scripts antes dos monstros; consulta somente ao iniciar.
    if config.mapSpawnsEnabled then
        for _, name in ipairs(mapSpawns.monsters) do
            if not MonsterType(name) then
                logger.error("Halloween: monstro global não encontrado ao iniciar a raid: {}.", name)
                return false
            end
        end
    end
    return originalTryStart(self, force)
end

raid:register()
