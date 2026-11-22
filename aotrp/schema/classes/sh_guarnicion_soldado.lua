CLASS.name = "Soldado"
CLASS.description = "Soldado raso del Tropas de Guarnición."
CLASS.faction = FACTION_GUARNICION
CLASS.isDefault = true
CLASS.nivel = 1

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_GUARNICION_SOLDADO = CLASS.index
