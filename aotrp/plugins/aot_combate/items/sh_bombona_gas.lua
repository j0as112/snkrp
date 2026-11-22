ITEM.name = "Bombona de gas"
ITEM.description = "Gas comprimido para el equipo de maniobras. Recarga el depósito al completo."
ITEM.model = "models/props_junk/propane_tank001a.mdl"
ITEM.category = "Equipo militar"
ITEM.width = 1
ITEM.height = 2

ITEM.functions.Usar = {
	name = "Recargar 3DMG",
	icon = "icon16/arrow_refresh.png",
	OnRun = function(item)
		return AOT and AOT.Recargar and AOT.Recargar(item.player, 100, nil)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity)
	end
}
