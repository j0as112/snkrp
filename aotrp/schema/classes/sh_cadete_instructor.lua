CLASS.name = "Instructor"
CLASS.description = "Instructor del Cuerpo de Cadetes. Evalúa y gradúa a los reclutas."
CLASS.faction = FACTION_CADETE
CLASS.isDefault = false
CLASS.nivel = 3

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_CADETE_INSTRUCTOR = CLASS.index
