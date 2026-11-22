CLASS.name = "Jefe de escuadrón"
CLASS.description = "Dirige un escuadrón en el Cuerpo de Exploración."
CLASS.faction = FACTION_EXPLORACION
CLASS.isDefault = false
CLASS.nivel = 2

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_EXPLORACION_JEFE = CLASS.index
