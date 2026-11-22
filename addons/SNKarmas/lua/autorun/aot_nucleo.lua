-- SNK Armas: equipo de maniobras tridimensional (3DMG) y núcleo compartido con "SNK Titanes".
-- Funciona solo (sandbox, etc.) y se integra con Helix si el gamemode lo usa.

AOT = AOT or {}
AOT.VERSION = "1.0.0"
AOT.CLASE_3DMG = "aot_odm"

local COMPARTIDOS = {"aot/sh_config.lua", "aot/sh_partes.lua", "aot/sh_movimiento.lua"}
local CLIENTE = {"aot/cl_hud.lua", "aot/cl_efectos.lua"}
local SERVIDOR = {"aot/sv_nucleo.lua"}

if (SERVER) then
	for _, f in ipairs(COMPARTIDOS) do AddCSLuaFile(f) end
	for _, f in ipairs(CLIENTE) do AddCSLuaFile(f) end
end

for _, f in ipairs(COMPARTIDOS) do include(f) end

if (SERVER) then
	for _, f in ipairs(SERVIDOR) do include(f) end
else
	for _, f in ipairs(CLIENTE) do include(f) end
end

-- Helix: el arma siempre está "alzada" (no hace falta mantener R).
hook.Add("Initialize", "AOT_ArmaAlzada", function()
	if (ALWAYS_RAISED) then ALWAYS_RAISED[AOT.CLASE_3DMG] = true end
end)

-- Sin daño de caída mientras quede gas (el gas amortigua el aterrizaje).
hook.Add("GetFallDamage", "AOT_CaidaODM", function(client, speed)
	local wep = client:GetActiveWeapon()

	if (IsValid(wep) and wep.AOT_ODM) then
		if (wep:GetGas() > 1) then return 0 end
		return math.max(0, (speed - 600) * 0.12)
	end
end)
