CLASS.name = "Soldado"
CLASS.description = "Soldado raso del Cuerpo de Exploración."
CLASS.faction = FACTION_EXPLORACION
CLASS.isDefault = true
CLASS.nivel = 1

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_EXPLORACION_SOLDADO = CLASS.index
