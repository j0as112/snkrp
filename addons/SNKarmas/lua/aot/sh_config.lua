-- Configuración del addon.
-- Con Helix: se usa la configuración de Helix (menú de configuración, categoría "Attack on Titan")
-- si el gamemode la registra. Sin Helix: ConVars de servidor (replicadas para la predicción).

AOT = AOT or {}

local CVARS = {
	aotGasConsumo = {"aot_gas_consumo", 1, "Multiplicador del consumo de gas del 3DMG."},
	aotRangoGancho = {"aot_rango_gancho", 2600, "Alcance máximo de los ganchos (52 ≈ 1 metro)."},
	aotFuerzaGancho = {"aot_fuerza_gancho", 2300, "Fuerza con la que tiran los ganchos."},
	aotHojasRecambio = {"aot_hojas_recambio", 4, "Pares de hojas de recambio en las vainas."},
	aotDesgasteHojas = {"aot_desgaste_hojas", 1, "Multiplicador del desgaste de las hojas."},
	aotDanoCorte = {"aot_dano_corte", 1, "Multiplicador del daño de los cortes."},
	aotRegenBrazo = {"aot_regen_brazo", 30, "Segundos para regenerar un brazo."},
	aotRegenTendon = {"aot_regen_tendon", 20, "Segundos para regenerar un tendón."},
	aotRegenOjos = {"aot_regen_ojos", 12, "Segundos de ceguera."},
	aotTitanVelocidad = {"aot_titan_velocidad", 1, "Multiplicador de velocidad de los titanes."},
	aotTitanEscalaMin = {"aot_titan_escala_min", 4, "Tamaño mínimo de los titanes (4 ≈ 5 m)."},
	aotTitanEscalaMax = {"aot_titan_escala_max", 9, "Tamaño máximo de los titanes (9 ≈ 12 m)."},
	aotTiempoComer = {"aot_tiempo_comer", 3.5, "Segundos que un titán sostiene a su presa antes de devorarla."},
	aotDanoComer = {"aot_dano_comer", 1000, "Daño del mordisco al devorar."},
	aotKillfeed = {"aot_killfeed", true, "Anunciar a todos cuando alguien abate un titán."},
}

AOT.CVars = AOT.CVars or {}

for clave, def in pairs(CVARS) do
	local valor = def[2]
	if (isbool(valor)) then valor = valor and 1 or 0 end

	AOT.CVars[clave] = CreateConVar(def[1], tostring(valor), bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED), def[3])
end

function AOT.Config(clave, defecto)
	if (ix and ix.config and ix.config.stored and ix.config.stored[clave] != nil) then
		return ix.config.Get(clave, defecto)
	end

	local cvar = AOT.CVars[clave]

	if (cvar) then
		if (isbool(defecto)) then return cvar:GetBool() end
		return cvar:GetFloat()
	end

	return defecto
end

-- Aviso al jugador: notificación de Helix si existe, si no, chat.
function AOT.Avisar(client, texto)
	if (!IsValid(client)) then return end

	if (client.Notify) then
		client:Notify(texto)
	elseif (SERVER) then
		client:ChatPrint(texto)
	end
end

-- Registra los métodos de una tabla como hooks (sustituye a los hooks de plugin de Helix).
function AOT.RegistrarHooks(tabla, prefijo)
	for nombre, fn in pairs(tabla) do
		if (isfunction(fn)) then
			hook.Add(nombre, "AOT_" .. prefijo .. "_" .. nombre, function(...)
				return fn(tabla, ...)
			end)
		end
	end
end
