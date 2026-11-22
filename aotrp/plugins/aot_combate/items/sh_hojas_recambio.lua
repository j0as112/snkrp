ITEM.name = "Hojas de recambio"
ITEM.description = "Dos pares de hojas para las vainas del 3DMG."
ITEM.model = "models/olddeath/w_snk_sword.mdl"
ITEM.category = "Equipo militar"
ITEM.width = 2
ITEM.height = 1

ITEM.functions.Usar = {
	name = "Guardar en las vainas",
	icon = "icon16/add.png",
	OnRun = function(item)
		return AOT and AOT.Recargar and AOT.Recargar(item.player, nil, 2)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity)
	end
}
