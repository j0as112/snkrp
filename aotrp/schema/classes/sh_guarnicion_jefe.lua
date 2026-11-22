CLASS.name = "Jefe de escuadrón"
CLASS.description = "Dirige un escuadrón en el Tropas de Guarnición."
CLASS.faction = FACTION_GUARNICION
CLASS.isDefault = false
CLASS.nivel = 2

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_GUARNICION_JEFE = CLASS.index
