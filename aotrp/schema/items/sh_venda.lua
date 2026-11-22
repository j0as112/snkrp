ITEM.name = "Venda"
ITEM.description = "Vendas de lino para contener una hemorragia. Úsala en ti o en quien tengas delante."
ITEM.model = "models/props_junk/garbage_newspaper001a.mdl"
ITEM.category = "Medicina"
ITEM.width = 1
ITEM.height = 1

local function Curar(item, objetivo)
	objetivo:SetHealth(math.min(objetivo:Health() + 25, objetivo:GetMaxHealth()))
	objetivo:EmitSound("items/medshot4.wav", 60)
end

ITEM.functions.Usar = {
	name = "Vendarte",
	icon = "icon16/heart.png",
	OnRun = function(item)
		Curar(item, item.player)
	end
}

ITEM.functions.Aplicar = {
	name = "Vendar a quien miras",
	icon = "icon16/heart_add.png",
	OnRun = function(item)
		local client = item.player
		local tr = client:GetEyeTraceNoCursor()
		local objetivo = tr.Entity

		if (IsValid(objetivo) and objetivo:IsPlayer() and objetivo:GetPos():DistToSqr(client:GetPos()) < 100 * 100) then
			Curar(item, objetivo)
			objetivo:Notify(client:GetName() .. " te ha vendado.")
			return true
		end

		client:Notify("No hay nadie a tu alcance.")
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity)
	end
}
