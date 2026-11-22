CLASS.name = "Jefe de escuadrón"
CLASS.description = "Dirige un escuadrón en el Policía Militar."
CLASS.faction = FACTION_POLICIA
CLASS.isDefault = false
CLASS.nivel = 2

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_POLICIA_JEFE = CLASS.index
