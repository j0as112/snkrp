-- Titán aberrante: corre, hace eses, salta sobre sus presas y prefiere los grupos.
-- Algunos son "reptadores" (modelo a cuatro patas): más bajos y muy rápidos.

AddCSLuaFile()

ENT.Base = "aot_titan"
ENT.Type = "nextbot"
ENT.PrintName = "Titán aberrante"
ENT.Category = "Attack on Titan"
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.AOT_Aberrante = true
ENT.VelAndar = 220
ENT.VelCorrer = 520

ENT.Modelos = {
	"models/hydralis_titan1.mdl",
	"models/hydralis_titan2.mdl",
	"models/hydralis_titan3.mdl",
	"models/hydralis_titan4.mdl",
	"models/hydralis_titan5.mdl",
}

ENT.ModeloReptador = "models/hydralis_titan3_crawl.mdl"

if (SERVER) then
	function ENT:PostInicio()
		if (math.random() < 0.35 and util.IsValidModel(self.ModeloReptador)) then
			self:SetModel(self.ModeloReptador)
			self.MultEscala = 0.7
			self.VelCorrer = 450
		end
	end
end
