CLASS.name = "Cadete"
CLASS.description = "Recluta en instrucción en el Cuerpo de Cadetes."
CLASS.faction = FACTION_CADETE
CLASS.isDefault = true
CLASS.nivel = 1

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_CADETE_RECLUTA = CLASS.index
