ITEM.name = "Pistola de bengalas"
ITEM.description = "Lanza bengalas de humo de colores para comunicarse en campo abierto."
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.category = "Equipo militar"
ITEM.width = 2
ITEM.height = 1
ITEM.cargasMax = 8

function ITEM:GetDescription()
	return self.description .. "\nCargas: " .. self:GetData("cargas", self.cargasMax) .. "/" .. self.cargasMax
end

-- Una opción por color en el menú del item.
ITEM.functions = ITEM.functions or {}

for _, clave in ipairs({"roja", "verde", "negra", "amarilla", "morada"}) do
	ITEM.functions["Bengala_" .. clave] = {
		name = "Bengala " .. clave,
		icon = "icon16/flag_red.png",
		OnRun = function(item)
			local client = item.player

			if (item:GetData("cargas", item.cargasMax) <= 0) then
				client:Notify("No quedan cargas.")
				return false
			end

			if (CurTime() < (client.ixAotSigBengala or 0)) then
				client:Notify("Espera un momento antes de disparar otra bengala.")
				return false
			end

			local plugin = ix.plugin.Get("aot_senales")

			if (plugin and plugin:Disparar(client, clave)) then
				client.ixAotSigBengala = CurTime() + 3
				item:SetData("cargas", item:GetData("cargas", item.cargasMax) - 1)
			end

			return false
		end,
		OnCanRun = function(item)
			return !IsValid(item.entity)
		end
	}
end

ITEM.functions.Recargar = {
	name = "Recargar (5 monedas)",
	icon = "icon16/arrow_refresh.png",
	OnRun = function(item)
		local character = item.player:GetCharacter()

		if (!character:HasMoney(5)) then
			item.player:Notify("No tienes suficientes monedas.")
			return false
		end

		character:TakeMoney(5)
		item:SetData("cargas", item.cargasMax)
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("cargas", item.cargasMax) < item.cargasMax
	end
}
