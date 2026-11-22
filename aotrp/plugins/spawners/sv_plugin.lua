
util.AddNetworkString("npcSpawnerOpen")
util.AddNetworkString("npcSpawnerSaveChanges")

function PLUGIN:SaveData()
    local data = {}

    for _, entity in ipairs(ents.FindByClass("npc_spawner")) do
        data[#data + 1] = {
            Pos = entity:GetPos(),
            Angles = entity:GetAngles(),
            Models = entity:GetModel(),
            Enabled = entity:GetEnabled(),
            MaxNPCS = entity:GetMaxNPCs(),
            SpawnInterval = entity:GetSpawnInterval(),
            NPCSRadius = entity:GetNPCSpawnRadius(),
            SpawnAmount = entity:GetSpawnAmount(),
            NPCClass = entity:GetNPCClass(),
            DespawnValue = entity:GetDespawnValue(),
            Materials = entity:GetSpawnMaterial(),
            EXP = entity:GetExp(),
            NPCHealth = entity:GetNPCHealth(),
            ModelScale = entity:GetMdlScale(),
            NPCColor = entity:GetNPCColor(),
            MinPlayers = entity:GetMinPlayers()
        }
    end

    self:SetData(data)
end

function PLUGIN:LoadData()
    for _, v in ipairs(self:GetData() or {}) do
        local entity = ents.Create("npc_spawner")
        entity:SetPos(v.Pos)
        entity:SetAngles(v.Angles)

        entity:SetModel(v.Models)
        entity:SetSolid(SOLID_BBOX)
        entity:PhysicsInit(SOLID_BBOX)

        local physObj = entity:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        entity:SetEnabled(v.Enabled)
        entity:SetMaxNPCs(v.MaxNPCS)
        entity:SetSpawnInterval(v.SpawnInterval)
        entity:SetNPCSpawnRadius(v.NPCSRadius)
        entity:SetSpawnAmount(v.SpawnAmount)
        entity:SetNPCClass(v.NPCClass)
        entity:SetDespawnValue(v.DespawnValue)
        entity:SetMaterial(v.Materials)
        entity:SetExp(v.EXP)
        entity:SetNPCHealth(v.NPCHealth)
        entity:SetMdlScale(v.ModelScale)
        entity:SetNPCColor(v.NPCColor)
        entity:SetMinPlayers(v.MinPlayers)
        entity:Spawn()
    end
end

net.Receive("npcSpawnerSaveChanges", function(len, client)
    local changes = {}
    local changeString = ""
    if (!CAMI.PlayerHasAccess(client, "Helix - NPC Spawner", nil)) then return end
    local entity = net.ReadEntity()
    local enabledBool = net.ReadBool()
    local npcClass = net.ReadString()
    local spawnMaterial = net.ReadString()
    local npcSpawnRadius = net.ReadUInt(14)
    local maxNPCs = net.ReadUInt(8)
    local spawnInterval = net.ReadUInt(16)
    local spawnAmount = net.ReadUInt(8)
    local despawnAmount = net.ReadUInt(8)
    local Exp = tonumber(net.ReadString()) or 0
    local npcHealth = tonumber(net.ReadString()) or 100
    local modelScale = net.ReadInt(16)
    local color = net.ReadColor()
    local minPlayers = net.ReadInt(8)

    if (!IsValid(entity) or entity:GetClass() != "npc_spawner") then return end

    if (entity:GetEnabled() != enabledBool) then
        changes[#changes + 1] = "Attivo: " .. tostring(entity:GetEnabled()) .. " -> " .. tostring(enabledBool)
        entity:SetEnabled(enabledBool)
    end
    if (entity:GetNPCClass() != npcClass) then
        changes[#changes + 1] = "Classe: " .. entity:GetNPCClass() .. " -> " .. npcClass
        entity:SetNPCClass(npcClass)
    end
    if (entity:GetNPCSpawnRadius() != npcSpawnRadius) then
        changes[#changes + 1] = "Raggio azione: " .. entity:GetNPCSpawnRadius() .. " -> " .. npcSpawnRadius
        entity:SetNPCSpawnRadius(npcSpawnRadius)
    end
    if (entity:GetMaxNPCs() != maxNPCs) then
        changes[#changes + 1] = "NPC massimi: " .. entity:GetMaxNPCs() .. " -> " .. maxNPCs
        entity:SetMaxNPCs(maxNPCs)
    end
    if (entity:GetSpawnInterval() != spawnInterval) then
        changes[#changes + 1] = "CD spawn: " .. entity:GetSpawnInterval() .. " -> " .. spawnInterval
        entity:SetSpawnInterval(spawnInterval)
    end
    if (entity:GetSpawnAmount() != spawnAmount) then
        changes[#changes + 1] = "Spawn per ciclo: " .. entity:GetSpawnAmount() .. " -> " .. spawnAmount
        entity:SetSpawnAmount(spawnAmount)
    end
    if (entity:GetDespawnValue() != despawnAmount) then
        changes[#changes + 1] = "CD Despawn: " .. entity:GetDespawnValue() .. " -> " .. despawnAmount
        entity:SetDespawnValue(despawnAmount)
    end
    if (entity:GetSpawnMaterial() != spawnMaterial) then
        changes[#changes + 1] = "Texture: " .. entity:GetSpawnMaterial() .. " -> " .. spawnMaterial
        entity:SetSpawnMaterial(spawnMaterial)
    end
    if (entity:GetExp() != Exp) then
        changes[#changes + 1] = "Exp: " .. entity:GetExp() .. " -> " .. Exp
        entity:SetExp(Exp)
    end
    if (entity:GetNPCHealth() != npcHealth) then
        changes[#changes + 1] = "Vita: " .. entity:GetNPCHealth() .. " -> " .. npcHealth
        entity:SetNPCHealth(npcHealth)
    end
    if (entity:GetMdlScale() != modelScale) then
        changes[#changes + 1] = "Scala modello: " .. entity:GetMdlScale() .. " -> " .. modelScale
        entity:SetMdlScale(modelScale)
    end
    if (entity:GetColor() != color) then
        changes[#changes + 1] = "Colore: r" .. entity:GetNPCColor().r .. ", g" .. entity:GetNPCColor().b .. ", b" .. " -> r" .. color.r .. ", g" .. color.g .. ", b" .. color.b
        entity:SetNPCColor(color)
    end
    if (entity:GetMinPlayers() != minPlayers) then
        changes[#changes + 1] = "Giocatori richiesti: " .. entity:GetMinPlayers() .. " -> " .. minPlayers
        entity:SetMinPlayers(minPlayers)
    end

    for _, v in pairs(changes) do
        changeString = changeString .. v .. "\n"
    end

    if SERVER and changeString != "" then
        ix.log.Add(client, "spawnerChanges", changeString)
    end
end)