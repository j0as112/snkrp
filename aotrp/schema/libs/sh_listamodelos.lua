-- Listas de modelos por cuerpo (se carga antes que las facciones).
-- Base: hydralis/kaouet. "bataillon" = Exploración, "garnison" = Guarnición,
-- "brigade" = Policía Militar, "recrue" = Cadetes, "instructeur" = Instructores.

AOTRP_MODELOS = AOTRP_MODELOS or {}

local BASE = "models/hydralis/kaouet/"

local function Soldados(cuerpo, conOficiales)
	local lista = {}

	for _, sexo in ipairs({"feminin", "masculin"}) do
		for i = 1, 3 do
			lista[#lista + 1] = string.format("%ssoldat_%s/%s/soldat_%s_%s_%d.mdl", BASE, sexo, cuerpo, sexo, cuerpo, i)
		end

		if (conOficiales) then
			for i = 1, 3 do
				lista[#lista + 1] = string.format("%ssoldat_%s/officier/%s/soldat_%s_%s_off_%d.mdl", BASE, sexo, cuerpo, sexo, cuerpo, i)
			end
		end
	end

	return lista
end

AOTRP_MODELOS.cadetes = Soldados("recrue", false)
AOTRP_MODELOS.instructores = Soldados("instructeur", false)
AOTRP_MODELOS.exploracion = Soldados("bataillon", true)
AOTRP_MODELOS.guarnicion = Soldados("garnison", true)
AOTRP_MODELOS.policia = Soldados("brigade", true)

AOTRP_MODELOS.civiles = {
	BASE .. "civil_feminin/bap_civil_feminin/civil/civil_feminin_chemise_1.mdl",
	BASE .. "civil_feminin/paysan_feminin/paysanne_1/civil_feminin_paysan_1_1.mdl",
	BASE .. "civil_feminin/paysan_feminin/paysanne_2/civil_feminin_paysan_2_1.mdl",
	BASE .. "civil_feminin/veste_feminin/veste_1/civil_feminin_veste_1_1.mdl",
	BASE .. "civil_masculin/bap_civil_masculin/bap/civil_masculin_chemise_bap_1.mdl",
	BASE .. "civil_masculin/bap_civil_masculin/civil/civil_masculin_chemise_1.mdl",
	BASE .. "civil_masculin/noble_masculin/bourge_1/civil_masculin_bourge_1.mdl",
	BASE .. "civil_masculin/noble_masculin/noble_1/civil_masculin_noble_1.mdl",
	BASE .. "civil_masculin/paysan_masculin/paysan_1/civil_masculin_paysan_1_1.mdl",
	BASE .. "civil_masculin/paysan_masculin/paysan_2/civil_masculin_paysan_2_1.mdl",
	BASE .. "civil_masculin/veste_masculin/veste_1/civil_masculin_veste_1_1.mdl",
}

-- Maestro de rol: puede usar cualquiera.
AOTRP_MODELOS.todos = {}

for _, lista in pairs({AOTRP_MODELOS.civiles, AOTRP_MODELOS.cadetes, AOTRP_MODELOS.instructores,
	AOTRP_MODELOS.exploracion, AOTRP_MODELOS.guarnicion, AOTRP_MODELOS.policia}) do
	for _, m in ipairs(lista) do
		AOTRP_MODELOS.todos[#AOTRP_MODELOS.todos + 1] = m
	end
end

AOTRP_MODELOS.todos[#AOTRP_MODELOS.todos + 1] = "models/kaesar/dotpixis/dotpixis.mdl"
