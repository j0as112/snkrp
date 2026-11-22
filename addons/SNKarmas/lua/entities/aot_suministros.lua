-- Caja de suministros: rellena gas y hojas del 3DMG al usarla (E).
-- Los admins la colocan desde el menú de entidades; se guarda en el mapa.

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Suministros (gas y hojas)"
ENT.Category = "Attack on Titan"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	-- -1 = ilimitado.
	self:NetworkVar("Int", 0, "Cargas")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/items/ammocrate_smg1.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		if (self:GetCargas() == 0) then self:SetCargas(-1) end

		local phys = self:GetPhysicsObject()
		if (IsValid(phys)) then phys:EnableMotion(false) end
	end

	function ENT:SpawnFunction(client, trace)
		local ent = ents.Create("aot_suministros")
		ent:SetPos(trace.HitPos + trace.HitNormal * 16)
		ent:SetAngles(Angle(0, client:EyeAngles().y + 180, 0))
		ent:Spawn()
		return ent
	end

	function ENT:Use(client)
		if (!IsValid(client) or !client:IsPlayer()) then return end
		if (CurTime() < (client.AOT_SigSuministro or 0)) then return end
		client.AOT_SigSuministro = CurTime() + 2

		if (self:GetCargas() == 0) then
			AOT.Avisar(client, "La caja de suministros está vacía.")
			return
		end

		if (AOT.Recargar(client, 100, AOT.Config("aotHojasRecambio", 4))) then
			AOT.Avisar(client, "Has repuesto gas y hojas.")
			local seq = self:LookupSequence("Open")
			if (seq and seq > 0) then self:ResetSequence(seq) end

			if (self:GetCargas() > 0) then self:SetCargas(self:GetCargas() - 1) end
		else
			AOT.Avisar(client, "Tu equipo ya está completo.")
		end
	end
else
	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(tooltip)
		local nombre = tooltip:AddRow("name")
		nombre:SetImportant()
		nombre:SetText("Suministros del Cuerpo")
		nombre:SizeToContents()

		local desc = tooltip:AddRow("description")
		local cargas = self:GetCargas()
		desc:SetText("Gas y hojas de recambio para el 3DMG." .. (cargas >= 0 and (" Quedan " .. cargas .. " recargas.") or ""))
		desc:SizeToContents()
	end
end
