ENT.Type = "anim"
ENT.PrintName = "NPC Spawner"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Int", 0, "MaxNPCs")
    self:NetworkVar("Int", 1, "SpawnAmount")
    self:NetworkVar("Int", 2, "SpawnInterval")
    self:NetworkVar("Int", 3, "NPCSpawnRadius")
    self:NetworkVar("Int", 4, "SpawnedNPCs")
    self:NetworkVar("String", 0, "NPCClass")
    self:NetworkVar("Int", 5, "DespawnValue")
    self:NetworkVar("String", 1, "SpawnMaterial")
    self:NetworkVar("Int", 6, "Exp")
    self:NetworkVar("Int", 7, "NPCHealth")
    self:NetworkVar("Int", 8, "MdlScale")
    self:NetworkVar("Float", 0, "ColorR")
    self:NetworkVar("Float", 1, "ColorG")
    self:NetworkVar("Float", 2, "ColorB")
    self:NetworkVar("Int", 9, "MinPlayers")

    self:SetEnabled(false)
    self:SetMaxNPCs(1)
    self:SetSpawnInterval(30)
    self:SetNPCSpawnRadius(200)
    self:SetSpawnAmount(1)
    self:SetSpawnedNPCs(0)
    self:SetNPCClass("npc_zombie")
    self:SetDespawnValue(10)
    self:SetSpawnMaterial("none")
    self:SetExp(0)
    self:SetNPCHealth(0)
    self:SetMdlScale(1)
    self:SetMinPlayers(1)

    self:SetColorR(255)
    self:SetColorG(255)
    self:SetColorB(255)

    if (SERVER) then
        self:NetworkVarNotify("Enabled", self.OnEnabled)
        self:NetworkVarNotify("SpawnInterval", self.OnSpawnIntervalChanged)
        self:NetworkVarNotify("DespawnValue", self.OnDespawnIntervalChanged)
    end

end

function ENT:Initialize()
    if (SERVER) then

        self.spawnedNPCs = {}
        self.playersInArea = {}

        self:SetModel("models/props_junk/sawblade001a.mdl")
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetColor(Color(255, 255, 255, 85))
        self:SetMaterial("models/debug/debugwhite")

        self:SetUseType(SIMPLE_USE)
        self:SetMoveType(MOVETYPE_NONE)
        self:DrawShadow(false)
        self:SetSolid(SOLID_BBOX)
        self:PhysicsInit(SOLID_BBOX)

        local physObj = self:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

    end

    self:SetCustomCollisionCheck(true)

end

function ENT:GetNPCColor()
    return Color(self:GetColorR(), self:GetColorG(), self:GetColorB(), 255)
end

function ENT:SetNPCColor(color)
    self:SetColorR(color.r)
    self:SetColorG(color.g)
    self:SetColorB(color.b)
end

function ENT:RemoveSpawnedNPC(npc)
        -- table.remove(self.spawnedNPCs, npc)
        for k,v in ipairs(self.spawnedNPCs) do
            if v == npc then
                table.remove(self.spawnedNPCs, k)
                if (timer.Exists(self:EntIndex() .. "_npc_exit_despawn_"  .. npc:EntIndex())) then timer.Remove(self:EntIndex() .. "_npc_exit_despawn_" .. npc:EntIndex()) end
                if (timer.Exists(self:EntIndex() .. "_player_exit_despawn_"  .. npc:EntIndex())) then timer.Remove(self:EntIndex() .. "_npc_exit_despawn_" .. npc:EntIndex()) end
            end
        end
    self:SetSpawnedNPCs(#self.spawnedNPCs)
end

if (SERVER) then
    function ENT:Use(activator)
        if (activator:CanUseNPCSpawner() and activator:GetMoveType() == MOVETYPE_NOCLIP) then
            net.Start("npcSpawnerOpen")
                net.WriteEntity(self)
            net.Send(activator)
        end
    end

    function ENT:OnDespawnIntervalChanged(name, old, new)
        timer.Adjust("NPCSpawnedMobsRemove"..self:EntIndex(), new, nil, nil)
    end
    function ENT:OnSpawnIntervalChanged(name, old, new)
        timer.Adjust(self:EntIndex() .. "_npc_spawner", self:GetSpawnInterval(), nil, nil)
    end

    function ENT:OnEnabled(name, old, new)
        if (new) then
            -- print("Spawner attivato")
            self:SpawnNPCs(nil)
            if (timer.Exists(self:EntIndex() .. "_npc_spawner")) then
                timer.Remove(self:EntIndex() .. "_npc_spawner")
            end
            timer.Create(self:EntIndex() .. "_npc_spawner_check_for_entry", 1, 0, function()
                -- self:SpawnNPCs()
                for k, client in pairs(player.GetAll()) do
                    if (client:GetPos():DistToSqr(self:GetPos()) < self:GetNPCSpawnRadius() * self:GetNPCSpawnRadius()) and client:Alive() then
                        
                            if not client.isInMobArea then 
                                client.isInMobArea = true
                                table.insert(self.playersInArea, client)
                            end
                        
                        if table.Count(self.spawnedNPCs) != 0 then 
                            for k, ent in pairs(self.spawnedNPCs) do
                                if not IsValid(ent) then return end
                                if (ent:GetPos():DistToSqr(self:GetPos()) < self:GetNPCSpawnRadius() * self:GetNPCSpawnRadius()) then 
                                    if (timer.Exists(self:EntIndex() .. "_npc_exit_despawn_" .. ent:EntIndex())) then timer.Remove(self:EntIndex() .. "_npc_exit_despawn_" .. ent:EntIndex()) end                 
                                else
                                    if not (timer.Exists(self:EntIndex() .. "_npc_exit_despawn_" .. ent:EntIndex())) then
                                        timer.Create(self:EntIndex() .. "_npc_exit_despawn_" .. ent:EntIndex(), self:GetDespawnValue(), 1, function()
                                            self:RemoveSpawnedNPC(ent)
                                            self:RemoveEffect(ent)   
                                            ent:Remove()     
                                        end)
                                    end
                                end
                            end
                        end

                        if table.Count(self.playersInArea) >= self:GetMinPlayers() then
                            if not timer.Exists(self:EntIndex() .. "_npc_spawner") then
                                if self:GetSpawnedNPCs() == 0 and not self.mobFirstSpawned then
                                    self.mobFirstSpawned = true
                                    timer.Simple(self:GetSpawnInterval(), function()
                                        self.mobFirstSpawned = false
                                    end)
                                    self:SpawnNPCs(client)
                                end
                                
                                timer.Create(self:EntIndex() .. "_npc_spawner", self:GetSpawnInterval(), 0, function()
                                    self:SpawnNPCs(client)
                                end)
                            end
                        else
                            if timer.Exists(self:EntIndex() .. "_npc_spawner") then timer.Remove(self:EntIndex() .. "_npc_spawner") end
                        end

                    else

                        for k,ply in pairs(self.playersInArea) do
                            if ply == client then
                                client.isInMobArea = false
                                table.remove(self.playersInArea, k)
                                break
                            end
                        end

                        if table.Count(self.playersInArea) < self:GetMinPlayers() then
                            if timer.Exists(self:EntIndex() .. "_npc_spawner") then timer.Remove(self:EntIndex() .. "_npc_spawner") end
                        end

                            for k, ent in pairs(self.spawnedNPCs) do
                                if table.Count(self.playersInArea) == 0 then
                                    if not IsValid(ent) then return end
                                    if not (timer.Exists(self:EntIndex() .. "_player_exit_despawn_" .. ent:EntIndex())) then
                                        timer.Create(self:EntIndex() .. "_player_exit_despawn_" .. ent:EntIndex(), self:GetDespawnValue(), 1, function()
                                            self:RemoveSpawnedNPC(ent)
                                            self:RemoveEffect(ent)   
                                            ent:Remove()  
                                        end)
                                    end
                                else
                                    if (timer.Exists(self:EntIndex() .. "_player_exit_despawn_" .. ent:EntIndex())) then timer.Remove(self:EntIndex() .. "_player_exit_despawn_" .. ent:EntIndex()) end
                                end
                            end

                        if table.Count(self.spawnedNPCs) != 0 then 
                            for k, ent in pairs(self.spawnedNPCs) do
                                if not IsValid(ent) then return end
                                if (ent:GetPos():DistToSqr(self:GetPos()) < self:GetNPCSpawnRadius() * self:GetNPCSpawnRadius()) then 
                                    if (timer.Exists(self:EntIndex() .. "_npc_exit_despawn_"  .. ent:EntIndex())) then timer.Remove(self:EntIndex() .. "_npc_exit_despawn_" .. ent:EntIndex()) return end                 
                                else
                                    if (timer.Exists(self:EntIndex() .. "_player_exit_despawn_" .. ent:EntIndex())) then return end
                                    if (timer.Exists(self:EntIndex() .. "_npc_exit_despawn_" .. ent:EntIndex())) then return end
                                    timer.Create(self:EntIndex() .. "_npc_exit_despawn_" .. ent:EntIndex(), self:GetDespawnValue(), 1, function()
                                        self:RemoveSpawnedNPC(ent)
                                        self:RemoveEffect(ent)   
                                        ent:Remove()   
                                    end)
                                end
                            end
                        end
                    end
                end
                
            end)
    
        else
            if (timer.Exists(self:EntIndex() .. "_npc_spawner")) then
                timer.Remove(self:EntIndex() .. "_npc_spawner")
            end
        end
        
    end

    function ENT:SpawnNPCs(npcTarget)
        if not self:GetEnabled() then return end
        
        local currentNPCs
        
        if self.spawnedNPCs then
            currentNPCs = table.Count(self.spawnedNPCs)
        else
            currentNPCs = 0
        end
        
        local spawnAmount = self:GetSpawnAmount()
        if spawnAmount > 1 then
            spawnAmount = spawnAmount - currentNPCs
        end
        
        local spawnerPos = self:GetPos()

        if (self:GetEnabled() and (self:GetMaxNPCs() > currentNPCs or self:GetMaxNPCs() == 0)) then
            
            for i = 1, spawnAmount do
                if currentNPCs == self:GetMaxNPCs() then break end
                local randAngle = math.Rand(0, 360)
                local randRadius = math.Rand(-self:GetNPCSpawnRadius(), self:GetNPCSpawnRadius())
                local x, y = randRadius * math.cos(randAngle), randRadius * math.sin(randAngle)
                local position = Vector(spawnerPos.x + x, spawnerPos.y + y, spawnerPos.z)
                local data = {
                    start = position + Vector(0, 0, 36),
                    endpos = position + Vector(0, 0, -100),
                    filter = self
                }
                local trace = util.TraceLine(data)

                local SpawnedNPC = ents.Create(self:GetNPCClass())
                SpawnedNPC.ixSpawner = self
                SpawnedNPC.experience = self:GetExp() or 0

                if self:GetSpawnMaterial() != "none" then
                    SpawnedNPC:SetMaterial(self:GetSpawnMaterial())
                end 
                    
                SpawnedNPC:SetPos(trace.HitPos + Vector(0, 0, 16))

                local positions = ix.util.FindEmptySpace(SpawnedNPC)
                if positions[1] then
                    SpawnedNPC:SetPos(positions[1])
                end

                if (SpawnedNPC) then
                    SpawnedNPC:SetPos(trace.HitPos + Vector(0, 0, 16))
                    SpawnedNPC:Spawn()

                    if SpawnedNPC.AOT_EsTitan then
                        -- Los titanes gestionan su propia vida; una escala > 1 en el spawner fija su tamaño.
                        if self:GetMdlScale() > 1 then
                            SpawnedNPC:FijarEscala(self:GetMdlScale())
                        end
                    else
                        if self:GetNPCHealth() != 0 then
                            SpawnedNPC:SetMaxHealth(self:GetNPCHealth())
                            SpawnedNPC:SetHealth(self:GetNPCHealth())
                        end

                        SpawnedNPC:SetModelScale(self:GetMdlScale())
                    end
                    SpawnedNPC:SetColor(Color(self:GetColorR(), self:GetColorG(), self:GetColorB()))

                    self.spawnedNPCs[#self.spawnedNPCs + 1] = SpawnedNPC
                    self:SetSpawnedNPCs(#self.spawnedNPCs)
                end
                                
            end
        end
    end

    function ENT:OnRemove()
        if (timer.Exists(self:EntIndex() .. "_npc_spawner")) then
            timer.Remove(self:EntIndex() .. "_npc_spawner")
        end
        if (timer.Exists("NPCSpawnedMobsRemove"..self:EntIndex())) then
            timer.Remove("NPCSpawnedMobsRemove"..self:EntIndex())
        end
        if (timer.Exists(self:EntIndex() .. "_npc_spawner_check_for_entry")) then
            timer.Remove(self:EntIndex() .. "_npc_spawner_check_for_entry")
        end

        if (self.spawnedNPCs and #self.spawnedNPCs > 0) then
            for k, v in pairs(self.spawnedNPCs) do
                if (IsValid(v)) then
                    if (timer.Exists(self:EntIndex() .. "_npc_exit_despawn_" .. v:EntIndex())) then
                        timer.Remove(self:EntIndex() .. "_npc_exit_despawn_" .. v:EntIndex())
                    end 
                    if (timer.Exists(self:EntIndex() .. "_player_exit_despawn_" .. v:EntIndex())) then
                        timer.Remove(self:EntIndex() .. "_player_exit_despawn_" .. v:EntIndex())
                    end
                    self:RemoveEffect(v)
                    v:Remove()
                end
            end
            for k, v in pairs(self.playersInArea) do
                if (IsValid(v)) then
                    v.isInMobArea = false
                end
            end
        end
    end
else
    function ENT:Draw()
        if (LocalPlayer():CanUseNPCSpawner() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP) then
            self:DrawModel()
            render.SetColorMaterial()
            if self:GetEnabled() then
                render.DrawSphere(self:GetPos(), self:GetNPCSpawnRadius(), 50, 50, Color(0, 180, 25, 155))
                render.SetColorMaterial()
            end
        end
    end

    ENT.PopulateEntityInfo = true

    function ENT:OnPopulateEntityInfo(container)
        if (LocalPlayer():CanUseNPCSpawner() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP) then
            local name = container:AddRow("title")
            name:SetImportant()
            name:SetText("Spawner NPC")
            name:SizeToContents()

            local enabled = container:AddRow("enabled")
            enabled:SetText("Attivo: " .. tostring(self:GetEnabled()))
            enabled:SizeToContents()

            local npcClass = container:AddRow("npcClass")
            npcClass:SetText("Classe: " .. self:GetNPCClass())
            npcClass:SizeToContents()

            local material = container:AddRow("material")
            material:SetText("Texture: " .. self:GetSpawnMaterial())
            material:SizeToContents()
            
            local maxNPCs = container:AddRow("maxNPCs")
            maxNPCs:SetText("Conteggio massimo: " .. self:GetMaxNPCs())
            maxNPCs:SizeToContents()

            local spawnInterval = container:AddRow("spawnInterval")
            spawnInterval:SetText("Intervallo cicli: " .. self:GetSpawnInterval())
            spawnInterval:SizeToContents()

            local spawnAmount = container:AddRow("spawnAmount")
            spawnAmount:SetText("Spawn per ciclo: " .. self:GetSpawnAmount())
            spawnAmount:SizeToContents()

            local despawnInterval = container:AddRow("despawnInterval")
            despawnInterval:SetText("Intervallo despawn: " .. self:GetDespawnValue())
            despawnInterval:SizeToContents()

            local Exp = container:AddRow("exp")
            Exp:SetText("Esperienza: " .. self:GetExp())
            Exp:SizeToContents()

            local NPCHealth = container:AddRow("NPCHealth")
            NPCHealth:SetText("Vita: " .. self:GetNPCHealth())
            NPCHealth:SizeToContents()

            local modelScale = container:AddRow("modelScale")
            modelScale:SetText("Scala modello: " .. self:GetMdlScale())
            modelScale:SizeToContents()

            local color = container:AddRow("color")
            color:SetText("Colore")
            color:SetBackgroundColor(self:GetNPCColor())
            color:SizeToContents()
 
            container:SizeToContents()
        end
    end
end

function ENT:RemoveEffect(ent)
    if not IsValid(ent) then return end
    local vPoint = ent:GetPos()
    local effectdata = EffectData()
    effectdata:SetOrigin(vPoint)
    util.Effect( "HunterDamage", effectdata )
end

hook.Add('EntityTakeDamage', "PlayerNotIsSphere", function(ent, dmginfo)
    if not ent.ixSpawner then return end
    local attacker = dmginfo:GetAttacker()
    if attacker.isInMobArea then return end
    dmginfo:ScaleDamage(0)
    local dmg = dmginfo:GetDamage()
    local dmg = math.floor(dmg)
    dmginfo:SetDamage(dmg)
end)