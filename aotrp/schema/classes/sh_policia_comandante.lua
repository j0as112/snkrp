CLASS.name = "Comandante"
CLASS.description = "Máxima autoridad del Policía Militar."
CLASS.faction = FACTION_POLICIA
CLASS.isDefault = false
CLASS.nivel = 4

-- Los rangos los asigna un mando o el staff con /Rango; desde el menú solo se puede volver al rango base.
function CLASS:CanSwitchTo(client)
	return self.isDefault
end

CLASS_POLICIA_COMANDANTE = CLASS.index
