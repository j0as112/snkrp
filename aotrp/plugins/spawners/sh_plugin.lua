local PLUGIN = PLUGIN

PLUGIN.name = "Spawner NPC"
PLUGIN.author = "Emanuele Pelandi"

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_hooks.lua")

CAMI.RegisterPrivilege({
    Name = "Helix - NPC Spawner",
    MinAccess = "admin"
})

local playerMeta = FindMetaTable("Player")
function playerMeta:CanUseNPCSpawner()
    return CAMI.PlayerHasAccess(self, "Helix - NPC Spawner", nil)
end

function PLUGIN:CanProperty(client, property, entity)
    if (entity:GetClass() == "npc_spawner" and client:GetMoveType() != MOVETYPE_NOCLIP) then
        return false
    end
end

properties.Add("gestorespawner", {
    MenuLabel = "Gestore Spawner",
    Order = 1,
    MenuIcon = "icon16/application_edit.png",

    Filter = function(self, entity, client)
        if (!IsValid(entity)) then return false end
        if (entity:GetClass() != "npc_spawner") then return false end

        return CAMI.PlayerHasAccess(client, "Helix - NPC Spawner", nil)
    end,

    Action = function(self, entity)
        self:MsgStart()
            net.WriteEntity(entity)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        local entity = net.ReadEntity()

        if (!IsValid(entity)) then return end
        if (!self:Filter(entity, client)) then return end

        net.Start("npcSpawnerOpen")
            net.WriteEntity(entity)
        net.Send(client)
    end
})

properties.Add("killspawnermobs", {
    MenuLabel = "Uccidi MOB Spawnati",
    Order = 2,
    MenuIcon = "icon16/heart_delete.png",

    Filter = function(self, entity, client)
        if (!IsValid(entity)) then return false end
        if (entity:GetClass() != "npc_spawner") then return false end

        return CAMI.PlayerHasAccess(client, "Helix - NPC Spawner", nil)
    end,

    Action = function(self, entity)
        self:MsgStart()
            net.WriteEntity(entity)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        local entity = net.ReadEntity()

        if (!IsValid(entity)) then return end
        if (!self:Filter(entity, client)) then return end

        if #entity.spawnedNPCs > 0 then
            for k,v in pairs(entity.spawnedNPCs) do
                timer.Simple(0.1, function()
                    if IsValid(v) then
                        entity:RemoveSpawnedNPC(v)
                        entity:RemoveEffect(v)
                        v:Remove()
                    end
                end)
            end
        end
    end
})


function PLUGIN:ShouldCollide(firstEnt, secondEnt)
    if (firstEnt:GetClass() == "npc_spawner" or secondEnt:GetClass() == "npc_spawner") then
        if firstEnt:GetClass() == "worldspawn" or secondEnt:GetClass() == "worldspawn" then
            return true
        end
        return false
    end
end

if not SERVER then return end
function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
    if IsValid(npc.ixSpawner) then
        npc.ixSpawner:RemoveSpawnedNPC(npc)
    end
end

ix.log.AddType("spawnerChanges", function(client, message)
    return "[SPAWNER] " .. client:GetName() .. " ha modificato uno spawner: \n" .. message
end)