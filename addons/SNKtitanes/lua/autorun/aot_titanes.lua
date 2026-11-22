-- SNK Titanes: titanes para Attack on Titan. Requiere el addon "SNK Armas" (3DMG y núcleo).

-- Aviso si falta el núcleo (se comprueba al iniciar, cuando ya se han cargado todos los addons).
hook.Add("Initialize", "AOT_ComprobarNucleo", function()
	if (!AOT or !AOT.PARTE) then
		ErrorNoHalt("[SNK Titanes] Falta el addon 'SNK Armas' (SNKarmas). Los titanes no funcionarán sin él.\n")
	end
end)

-- Compatibilidad: los nombres antiguos (npc_titan, npc_titan_deviant_sprinter) usan los titanes nuevos.
-- Se registran tarde para sobrescribir las versiones de otros addons antiguos.
local ALIAS = {
	npc_titan = {base = "aot_titan", nombre = "Titán"},
	npc_titan_deviant_sprinter = {base = "aot_titan_aberrante", nombre = "Titán aberrante (sprinter)"},
}

local function RegistrarAlias()
	for clase, info in pairs(ALIAS) do
		scripted_ents.Register({Base = info.base, Type = "nextbot", PrintName = info.nombre, Spawnable = false}, clase)
		list.Set("NPC", clase, {Name = info.nombre, Class = clase, Category = "Attack on Titan"})
	end
end

hook.Add("Initialize", "AOT_AliasTitanes", RegistrarAlias)
hook.Add("InitPostEntity", "AOT_AliasTitanes", RegistrarAlias)

list.Set("NPC", "aot_titan", {Name = "Titán", Class = "aot_titan", Category = "Attack on Titan"})
list.Set("NPC", "aot_titan_aberrante", {Name = "Titán aberrante", Class = "aot_titan_aberrante", Category = "Attack on Titan"})
