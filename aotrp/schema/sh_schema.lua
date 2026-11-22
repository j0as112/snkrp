--[[
	Attack on Titan RP - schema de Helix
	Año 850, Paradis. La humanidad vive tras los Muros María, Rose y Sina.

	Estructura:
	  sh_config.lua     Moneda, ajustes por defecto y variables de personaje.
	  sh_modelos.lua    Modelos de jugador con animaciones humanas.
	  sh_hooks.lua      Hooks compartidos.
	  sv_hooks.lua      Hooks del servidor (equipo inicial, altura, sueldos).
	  cl_hooks.lua      Hooks del cliente (HUD de rango).
	  sh_comandos.lua   Comandos de mando y de staff.
	  factions/         Civiles, Cadetes, Cuerpo de Exploración, Guarnición, Policía Militar, Maestro de rol.
	  classes/          Rangos de cada cuerpo.
	  items/            Equipo y consumibles básicos.
]]

Schema.name = "Attack on Titan RP"
Schema.author = "j0as"
Schema.description = "Año 850. Tras los Muros, la humanidad resiste."

-- Facciones militares (uniqueID → true). Se usan para equipo inicial, rangos y permisos.
Schema.militares = {
	cadete = true,
	exploracion = true,
	guarnicion = true,
	policia = true,
}

-- ¿El personaje pertenece a un cuerpo militar?
function Schema:EsMilitar(character)
	local faccion = character and ix.faction.indices[character:GetFaction()]
	return faccion != nil and self.militares[faccion.uniqueID] == true
end

-- Nivel de rango del personaje (0 si no tiene). Lo define cada clase con CLASS.nivel.
function Schema:Rango(character)
	local clase = character and ix.class.list[character:GetClass()]
	return clase and clase.nivel or 0
end

-- Mandos: admins, maestros de rol y rangos de capitán (nivel 3) o superior.
function Schema:EsMando(client)
	if (!IsValid(client)) then return false end
	if (client:IsAdmin()) then return true end

	local character = client:GetCharacter()
	if (!character) then return false end

	return character:GetFaction() == FACTION_MAESTROROL or self:Rango(character) >= 3
end

ix.util.Include("sh_config.lua")
ix.util.Include("sh_modelos.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sh_comandos.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")
