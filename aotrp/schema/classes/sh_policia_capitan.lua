CLASS.name = "Capitán"
CLASS.description = "Oficial al mando de una compañía del Policía Militar. Puede asignar rangos inferiores."
CLASS.faction = FACTION_POLICIA
CLASS.isDefault = false
CLASS.nivel = 3

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_POLICIA_CAPITAN = CLASS.index
