-- Física del 3DMG: se ejecuta dentro del movimiento predicho del jugador (cliente y servidor),
-- así el balanceo es suave y no hay tirones de red.

AOT = AOT or {}

if (CLIENT) then
	-- Tecla para fijar objetivo (por defecto, rueda del ratón). Cambiable con: aot_tecla_fijar <código>
	CreateClientConVar("aot_tecla_fijar", tostring(MOUSE_MIDDLE), true, true, "Tecla para fijar/soltar objetivo con el 3DMG.")
	CreateClientConVar("aot_efecto_velocidad", "1", true, false, "Efecto de FOV y líneas de velocidad con el 3DMG.")
	CreateClientConVar("aot_tercera_persona", "1", true, false, "Cámara en tercera persona con el 3DMG (1 = sí, 0 = primera persona).")
	CreateClientConVar("aot_anclaje_auto", "1", true, true, "Anclaje automático de los ganchos (1 = automático, 0 = apuntar a mano).")
	CreateClientConVar("aot_camara_distancia", "130", true, false, "Distancia base de la cámara en tercera persona.")
end

hook.Add("Move", "AOT_MovimientoODM", function(client, mv)
	local wep = client:GetActiveWeapon()

	if (IsValid(wep) and wep.AOT_ODM and client:Alive() and client:GetMoveType() == MOVETYPE_WALK) then
		wep:MoverODM(client, mv)
	end
end)

hook.Add("PlayerButtonDown", "AOT_FijarObjetivo", function(client, boton)
	if (!SERVER) then return end

	local wep = client:GetActiveWeapon()
	if (!IsValid(wep) or !wep.AOT_ODM) then return end

	if (boton == client:GetInfoNum("aot_tecla_fijar", MOUSE_MIDDLE)) then
		wep:AlternarFijacion()
	end
end)
