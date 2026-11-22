local PLUGIN = PLUGIN

PLUGIN.name = "AoT: integración con el addon SNK Titanes"
PLUGIN.author = "j0as"
PLUGIN.description = "Configuración de Helix e items (gas y hojas) para el addon de Workshop 'SNK Titanes y 3DMG'."

-- El 3DMG, los titanes y la caja de suministros están en el addon SNKtitanes (Workshop).
-- Este plugin solo añade lo propio de Helix: configuración editable en el menú, items y el arma siempre alzada.
-- El addon lee estas claves si existen; si no, usa sus ConVars (aot_*).

local CAT = "Attack on Titan"

ix.config.Add("aotGasConsumo", 1, "Multiplicador del consumo de gas del 3DMG.", nil, {data = {min = 0, max = 5, decimals = 2}, category = CAT})
ix.config.Add("aotRangoGancho", 2600, "Alcance máximo de los ganchos (unidades; 52 ≈ 1 metro).", nil, {data = {min = 500, max = 6000}, category = CAT})
ix.config.Add("aotFuerzaGancho", 2300, "Fuerza con la que tiran los ganchos al recoger cable.", nil, {data = {min = 500, max = 6000}, category = CAT})
ix.config.Add("aotHojasRecambio", 4, "Pares de hojas de recambio que caben en las vainas.", nil, {data = {min = 0, max = 12}, category = CAT})
ix.config.Add("aotDesgasteHojas", 1, "Multiplicador del desgaste de las hojas.", nil, {data = {min = 0, max = 5, decimals = 2}, category = CAT})
ix.config.Add("aotDanoCorte", 1, "Multiplicador del daño de los cortes.", nil, {data = {min = 0.1, max = 5, decimals = 2}, category = CAT})
ix.config.Add("aotRegenBrazo", 30, "Segundos que tarda un titán en regenerar un brazo.", nil, {data = {min = 3, max = 300}, category = CAT})
ix.config.Add("aotRegenTendon", 20, "Segundos que tarda un titán en regenerar un tendón.", nil, {data = {min = 3, max = 300}, category = CAT})
ix.config.Add("aotRegenOjos", 12, "Segundos que un titán permanece ciego.", nil, {data = {min = 2, max = 120}, category = CAT})
ix.config.Add("aotTitanVelocidad", 1, "Multiplicador de velocidad de los titanes.", nil, {data = {min = 0.2, max = 3, decimals = 2}, category = CAT})
ix.config.Add("aotTitanEscalaMin", 4, "Tamaño mínimo de los titanes (escala del modelo; 4 ≈ 5 m).", nil, {data = {min = 1, max = 15, decimals = 1}, category = CAT})
ix.config.Add("aotTitanEscalaMax", 9, "Tamaño máximo de los titanes (escala del modelo; 9 ≈ 12 m).", nil, {data = {min = 1, max = 15, decimals = 1}, category = CAT})
ix.config.Add("aotTiempoComer", 3.5, "Segundos que un titán sostiene a su presa antes de devorarla.", nil, {data = {min = 1, max = 15, decimals = 1}, category = CAT})
ix.config.Add("aotDanoComer", 1000, "Daño del mordisco al devorar (1000 = muerte segura).", nil, {data = {min = 1, max = 1000}, category = CAT})
ix.config.Add("aotKillfeed", true, "Anunciar a todo el servidor cuando alguien abate un titán.", nil, {category = CAT})

ALWAYS_RAISED = ALWAYS_RAISED or {}
ALWAYS_RAISED["aot_odm"] = true

if (SERVER) then
	function PLUGIN:InitPostEntity()
		if (!AOT or !AOT.Recargar) then
			ErrorNoHalt("[AotRP] Falta el addon 'SNK Titanes y 3DMG' (SNKtitanes): el 3DMG y los titanes no funcionarán.\n")
		end
	end
end
