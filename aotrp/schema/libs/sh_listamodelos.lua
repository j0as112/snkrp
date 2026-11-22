-- Listas de modelos por facción. Generado desde los modelos reales de la Workshop (SNK Modelos1/2/3).
-- Ruta base: models/j0as/aotrp/. Cada facción usa solo los suyos; el Maestro de rol puede usar todos.
-- (Los modelos "vip/" y "npc_" no se asignan a facciones: ver AOTRP_MODELOS.vip / .npc.)

AOTRP_MODELOS = AOTRP_MODELOS or {}

local BASE = "models/j0as/aotrp/"

local function Lista(relativas)
	local lista = {}

	for _, r in ipairs(relativas) do
		lista[#lista + 1] = BASE .. r
	end

	return lista
end

-- Civiles (camisa, campesinos, chaqueta, culto, burgueses/nobles, vestidos, ropa de invierno civil): 45 modelos
AOTRP_MODELOS.civiles = Lista({
	"civil_femenino/bap_civil_femenino/civil/civil_femenino_camisa_1.mdl",
	"civil_femenino/bap_civil_femenino/civil/civil_femenino_camisa_2.mdl",
	"civil_femenino/bap_civil_femenino/civil/civil_femenino_camisa_3.mdl",
	"civil_femenino/campesino_femenino/campesina_1/civil_femenino_campesino_1_1.mdl",
	"civil_femenino/campesino_femenino/campesina_1/civil_femenino_campesino_1_2.mdl",
	"civil_femenino/campesino_femenino/campesina_1/civil_femenino_campesino_1_3.mdl",
	"civil_femenino/campesino_femenino/campesina_2/civil_femenino_campesino_2_1.mdl",
	"civil_femenino/campesino_femenino/campesina_2/civil_femenino_campesino_2_2.mdl",
	"civil_femenino/campesino_femenino/campesina_2/civil_femenino_campesino_2_3.mdl",
	"civil_femenino/chaqueta_femenino/chaqueta_1/civil_femenino_chaqueta_1_1.mdl",
	"civil_femenino/chaqueta_femenino/chaqueta_1/civil_femenino_chaqueta_1_2.mdl",
	"civil_femenino/chaqueta_femenino/chaqueta_1/civil_femenino_chaqueta_1_3.mdl",
	"civil_femenino/invierno_femenino/invierno_civil_ropa_1.mdl",
	"civil_femenino/invierno_femenino/invierno_civil_ropa_2.mdl",
	"civil_femenino/invierno_femenino/invierno_civil_ropa_3.mdl",
	"civil_femenino/vestido_femenino/vestido_1/civil_femenino_vestido_1_1.mdl",
	"civil_femenino/vestido_femenino/vestido_1/civil_femenino_vestido_1_2.mdl",
	"civil_femenino/vestido_femenino/vestido_1/civil_femenino_vestido_1_3.mdl",
	"civil_femenino/vestido_femenino/vestido_2/civil_femenino_vestido_2_1.mdl",
	"civil_femenino/vestido_femenino/vestido_2/civil_femenino_vestido_2_2.mdl",
	"civil_femenino/vestido_femenino/vestido_2/civil_femenino_vestido_2_3.mdl",
	"civil_masculino/bap_civil_masculino/bap/civil_masculino_camisa_bap_1.mdl",
	"civil_masculino/bap_civil_masculino/bap/civil_masculino_camisa_bap_2.mdl",
	"civil_masculino/bap_civil_masculino/bap/civil_masculino_camisa_bap_3.mdl",
	"civil_masculino/bap_civil_masculino/civil/civil_masculino_camisa_1.mdl",
	"civil_masculino/bap_civil_masculino/civil/civil_masculino_camisa_2.mdl",
	"civil_masculino/bap_civil_masculino/civil/civil_masculino_camisa_3.mdl",
	"civil_masculino/campesino_masculino/campesino_1/civil_masculino_campesino_1_1.mdl",
	"civil_masculino/campesino_masculino/campesino_1/civil_masculino_campesino_1_2.mdl",
	"civil_masculino/campesino_masculino/campesino_1/civil_masculino_campesino_1_3.mdl",
	"civil_masculino/campesino_masculino/campesino_2/civil_masculino_campesino_2_1.mdl",
	"civil_masculino/campesino_masculino/campesino_2/civil_masculino_campesino_2_2.mdl",
	"civil_masculino/campesino_masculino/campesino_2/civil_masculino_campesino_2_3.mdl",
	"civil_masculino/chaqueta_masculino/chaqueta_1/civil_masculino_chaqueta_1_1.mdl",
	"civil_masculino/chaqueta_masculino/chaqueta_1/civil_masculino_chaqueta_1_2.mdl",
	"civil_masculino/chaqueta_masculino/chaqueta_1/civil_masculino_chaqueta_1_3.mdl",
	"civil_masculino/culto_masculino/civil_masculino_culto_1.mdl",
	"civil_masculino/culto_masculino/civil_masculino_culto_2.mdl",
	"civil_masculino/culto_masculino/civil_masculino_culto_3.mdl",
	"civil_masculino/noble_masculino/burgues_1/civil_masculino_burgues_1.mdl",
	"civil_masculino/noble_masculino/burgues_1/civil_masculino_burgues_2.mdl",
	"civil_masculino/noble_masculino/burgues_1/civil_masculino_burgues_3.mdl",
	"civil_masculino/noble_masculino/noble_1/civil_masculino_noble_1.mdl",
	"civil_masculino/noble_masculino/noble_1/civil_masculino_noble_2.mdl",
	"civil_masculino/noble_masculino/noble_1/civil_masculino_noble_3.mdl",
})

-- Cadetes (cadete y entrenamiento): 12 modelos
AOTRP_MODELOS.cadetes = Lista({
	"soldado_femenino/cadete/soldado_femenino_cadete_1.mdl",
	"soldado_femenino/cadete/soldado_femenino_cadete_2.mdl",
	"soldado_femenino/cadete/soldado_femenino_cadete_3.mdl",
	"soldado_femenino/entrenamiento/soldado_femenino_entrenamiento_1.mdl",
	"soldado_femenino/entrenamiento/soldado_femenino_entrenamiento_2.mdl",
	"soldado_femenino/entrenamiento/soldado_femenino_entrenamiento_3.mdl",
	"soldado_masculino/cadete/soldado_masculino_cadete_1.mdl",
	"soldado_masculino/cadete/soldado_masculino_cadete_2.mdl",
	"soldado_masculino/cadete/soldado_masculino_cadete_3.mdl",
	"soldado_masculino/entrenamiento/soldado_masculino_entrenamiento_1.mdl",
	"soldado_masculino/entrenamiento/soldado_masculino_entrenamiento_2.mdl",
	"soldado_masculino/entrenamiento/soldado_masculino_entrenamiento_3.mdl",
})

-- Instructores (instructor y oficiales de entrenamiento): 12 modelos
AOTRP_MODELOS.instructores = Lista({
	"soldado_femenino/instructor/soldado_femenino_instructor_1.mdl",
	"soldado_femenino/instructor/soldado_femenino_instructor_2.mdl",
	"soldado_femenino/instructor/soldado_femenino_instructor_3.mdl",
	"soldado_femenino/oficial/entrenamiento/soldado_femenino_entrenamiento_oficial_1.mdl",
	"soldado_femenino/oficial/entrenamiento/soldado_femenino_entrenamiento_oficial_2.mdl",
	"soldado_femenino/oficial/entrenamiento/soldado_femenino_entrenamiento_oficial_3.mdl",
	"soldado_masculino/instructor/soldado_masculino_instructor_1.mdl",
	"soldado_masculino/instructor/soldado_masculino_instructor_2.mdl",
	"soldado_masculino/instructor/soldado_masculino_instructor_3.mdl",
	"soldado_masculino/oficial/entrenamiento/soldado_masculino_entrenamiento_oficial_1.mdl",
	"soldado_masculino/oficial/entrenamiento/soldado_masculino_entrenamiento_oficial_2.mdl",
	"soldado_masculino/oficial/entrenamiento/soldado_masculino_entrenamiento_oficial_3.mdl",
})

-- Cuerpo de Exploración (soldados y oficiales): 12 modelos
AOTRP_MODELOS.exploracion = Lista({
	"soldado_femenino/exploracion/soldado_femenino_exploracion_1.mdl",
	"soldado_femenino/exploracion/soldado_femenino_exploracion_2.mdl",
	"soldado_femenino/exploracion/soldado_femenino_exploracion_3.mdl",
	"soldado_femenino/oficial/exploracion/soldado_femenino_exploracion_oficial_1.mdl",
	"soldado_femenino/oficial/exploracion/soldado_femenino_exploracion_oficial_2.mdl",
	"soldado_femenino/oficial/exploracion/soldado_femenino_exploracion_oficial_3.mdl",
	"soldado_masculino/exploracion/soldado_masculino_exploracion_1.mdl",
	"soldado_masculino/exploracion/soldado_masculino_exploracion_2.mdl",
	"soldado_masculino/exploracion/soldado_masculino_exploracion_3.mdl",
	"soldado_masculino/oficial/exploracion/soldado_masculino_exploracion_oficial_1.mdl",
	"soldado_masculino/oficial/exploracion/soldado_masculino_exploracion_oficial_2.mdl",
	"soldado_masculino/oficial/exploracion/soldado_masculino_exploracion_oficial_3.mdl",
})

-- Tropas de Guarnición (soldados, oficiales y comandante): 24 modelos
AOTRP_MODELOS.guarnicion = Lista({
	"soldado_femenino/guarnicion/soldado_femenino_guarnicion_1.mdl",
	"soldado_femenino/guarnicion/soldado_femenino_guarnicion_2.mdl",
	"soldado_femenino/guarnicion/soldado_femenino_guarnicion_3.mdl",
	"soldado_femenino/oficial/comandante_guarnicion/oficial/comandante_femenino_guarnicion_oficial_1.mdl",
	"soldado_femenino/oficial/comandante_guarnicion/oficial/comandante_femenino_guarnicion_oficial_2.mdl",
	"soldado_femenino/oficial/comandante_guarnicion/oficial/comandante_femenino_guarnicion_oficial_3.mdl",
	"soldado_femenino/oficial/comandante_guarnicion/soldado/comandante_femenino_guarnicion_1.mdl",
	"soldado_femenino/oficial/comandante_guarnicion/soldado/comandante_femenino_guarnicion_2.mdl",
	"soldado_femenino/oficial/comandante_guarnicion/soldado/comandante_femenino_guarnicion_3.mdl",
	"soldado_femenino/oficial/guarnicion/soldado_femenino_guarnicion_oficial_1.mdl",
	"soldado_femenino/oficial/guarnicion/soldado_femenino_guarnicion_oficial_2.mdl",
	"soldado_femenino/oficial/guarnicion/soldado_femenino_guarnicion_oficial_3.mdl",
	"soldado_masculino/guarnicion/soldado_masculino_guarnicion_1.mdl",
	"soldado_masculino/guarnicion/soldado_masculino_guarnicion_2.mdl",
	"soldado_masculino/guarnicion/soldado_masculino_guarnicion_3.mdl",
	"soldado_masculino/oficial/comandante_guarnicion/oficial/comandante_masculino_guarnicion_oficial_1.mdl",
	"soldado_masculino/oficial/comandante_guarnicion/oficial/comandante_masculino_guarnicion_oficial_2.mdl",
	"soldado_masculino/oficial/comandante_guarnicion/oficial/comandante_masculino_guarnicion_oficial_3.mdl",
	"soldado_masculino/oficial/comandante_guarnicion/soldado/comandante_soldado_masculino_guarnicion_1.mdl",
	"soldado_masculino/oficial/comandante_guarnicion/soldado/comandante_soldado_masculino_guarnicion_2.mdl",
	"soldado_masculino/oficial/comandante_guarnicion/soldado/comandante_soldado_masculino_guarnicion_3.mdl",
	"soldado_masculino/oficial/guarnicion/soldado_masculino_guarnicion_oficial_1.mdl",
	"soldado_masculino/oficial/guarnicion/soldado_masculino_guarnicion_oficial_2.mdl",
	"soldado_masculino/oficial/guarnicion/soldado_masculino_guarnicion_oficial_3.mdl",
})

-- Policía Militar (soldados y oficiales): 12 modelos
AOTRP_MODELOS.policia = Lista({
	"soldado_femenino/oficial/policia/soldado_femenino_policia_oficial_1.mdl",
	"soldado_femenino/oficial/policia/soldado_femenino_policia_oficial_2.mdl",
	"soldado_femenino/oficial/policia/soldado_femenino_policia_oficial_3.mdl",
	"soldado_femenino/policia/soldado_femenino_policia_1.mdl",
	"soldado_femenino/policia/soldado_femenino_policia_2.mdl",
	"soldado_femenino/policia/soldado_femenino_policia_3.mdl",
	"soldado_masculino/oficial/policia/soldado_masculino_policia_oficial_1.mdl",
	"soldado_masculino/oficial/policia/soldado_masculino_policia_oficial_2.mdl",
	"soldado_masculino/oficial/policia/soldado_masculino_policia_oficial_3.mdl",
	"soldado_masculino/policia/soldado_masculino_policia_1.mdl",
	"soldado_masculino/policia/soldado_masculino_policia_2.mdl",
	"soldado_masculino/policia/soldado_masculino_policia_3.mdl",
})

-- Ropa de invierno de soldados (solo staff): 6 modelos
AOTRP_MODELOS.invierno = Lista({
	"soldado_femenino/invierno/invierno_soldado_ropa_1.mdl",
	"soldado_femenino/invierno/invierno_soldado_ropa_2.mdl",
	"soldado_femenino/invierno/invierno_soldado_ropa_3.mdl",
	"soldado_masculino/invierno/invierno_soldado_ropa_1.mdl",
	"soldado_masculino/invierno/invierno_soldado_ropa_2.mdl",
	"soldado_masculino/invierno/invierno_soldado_ropa_3.mdl",
})

-- Versiones VIP (no asignadas a ninguna facción todavía): 108 modelos
AOTRP_MODELOS.vip = Lista({
	"vip/civil_femenino/bap_civil_femenino/civil/civil_femenino_camisa_1_vip.mdl",
	"vip/civil_femenino/bap_civil_femenino/civil/civil_femenino_camisa_2_vip.mdl",
	"vip/civil_femenino/bap_civil_femenino/civil/civil_femenino_camisa_3_vip.mdl",
	"vip/civil_femenino/campesino_femenino/campesina_1/civil_femenino_campesino_1_1_vip.mdl",
	"vip/civil_femenino/campesino_femenino/campesina_1/civil_femenino_campesino_1_2_vip.mdl",
	"vip/civil_femenino/campesino_femenino/campesina_1/civil_femenino_campesino_1_3_vip.mdl",
	"vip/civil_femenino/campesino_femenino/campesina_2/civil_femenino_campesino_2_1_vip.mdl",
	"vip/civil_femenino/campesino_femenino/campesina_2/civil_femenino_campesino_2_2_vip.mdl",
	"vip/civil_femenino/campesino_femenino/campesina_2/civil_femenino_campesino_2_3_vip.mdl",
	"vip/civil_femenino/chaqueta_femenino/chaqueta_1/civil_femenino_chaqueta_1_1_vip.mdl",
	"vip/civil_femenino/chaqueta_femenino/chaqueta_1/civil_femenino_chaqueta_1_2_vip.mdl",
	"vip/civil_femenino/chaqueta_femenino/chaqueta_1/civil_femenino_chaqueta_1_3_vip.mdl",
	"vip/civil_femenino/invierno_femenino/invierno_civil_ropa_1_vip.mdl",
	"vip/civil_femenino/invierno_femenino/invierno_civil_ropa_2_vip.mdl",
	"vip/civil_femenino/invierno_femenino/invierno_civil_ropa_3_vip.mdl",
	"vip/civil_femenino/vestido_femenino/vestido_1/civil_femenino_vestido_1_1_vip.mdl",
	"vip/civil_femenino/vestido_femenino/vestido_1/civil_femenino_vestido_1_2_vip.mdl",
	"vip/civil_femenino/vestido_femenino/vestido_1/civil_femenino_vestido_1_3_vip.mdl",
	"vip/civil_femenino/vestido_femenino/vestido_2/civil_femenino_vestido_2_1_vip.mdl",
	"vip/civil_femenino/vestido_femenino/vestido_2/civil_femenino_vestido_2_2_vip.mdl",
	"vip/civil_femenino/vestido_femenino/vestido_2/civil_femenino_vestido_2_3_vip.mdl",
	"vip/civil_masculino/bap_civil_masculino/civil/civil_masculino_camisa_1_vip.mdl",
	"vip/civil_masculino/bap_civil_masculino/civil/civil_masculino_camisa_2_vip.mdl",
	"vip/civil_masculino/bap_civil_masculino/civil/civil_masculino_camisa_3_vip.mdl",
	"vip/civil_masculino/campesino_masculino/campesino_1/civil_masculino_campesino_1_1_vip.mdl",
	"vip/civil_masculino/campesino_masculino/campesino_1/civil_masculino_campesino_1_2_vip.mdl",
	"vip/civil_masculino/campesino_masculino/campesino_1/civil_masculino_campesino_1_3_vip.mdl",
	"vip/civil_masculino/campesino_masculino/campesino_2/civil_masculino_campesino_2_1_vip.mdl",
	"vip/civil_masculino/campesino_masculino/campesino_2/civil_masculino_campesino_2_2_vip.mdl",
	"vip/civil_masculino/campesino_masculino/campesino_2/civil_masculino_campesino_2_3_vip.mdl",
	"vip/civil_masculino/chaqueta_masculino/chaqueta_1/civil_masculino_chaqueta_1_1_vip.mdl",
	"vip/civil_masculino/chaqueta_masculino/chaqueta_1/civil_masculino_chaqueta_1_2_vip.mdl",
	"vip/civil_masculino/chaqueta_masculino/chaqueta_1/civil_masculino_chaqueta_1_3_vip.mdl",
	"vip/civil_masculino/culto_masculino/civil_masculino_culto_1_vip.mdl",
	"vip/civil_masculino/culto_masculino/civil_masculino_culto_2_vip.mdl",
	"vip/civil_masculino/culto_masculino/civil_masculino_culto_3_vip.mdl",
	"vip/civil_masculino/noble_masculino/burgues_1/civil_masculino_burgues_1_vip.mdl",
	"vip/civil_masculino/noble_masculino/burgues_1/civil_masculino_burgues_2_vip.mdl",
	"vip/civil_masculino/noble_masculino/burgues_1/civil_masculino_burgues_3_vip.mdl",
	"vip/civil_masculino/noble_masculino/noble_1/civil_masculino_noble_1_vip.mdl",
	"vip/civil_masculino/noble_masculino/noble_1/civil_masculino_noble_2_vip.mdl",
	"vip/civil_masculino/noble_masculino/noble_1/civil_masculino_noble_3_vip.mdl",
	"vip/soldado_femenino/cadete/soldado_femenino_cadete_1_vip.mdl",
	"vip/soldado_femenino/cadete/soldado_femenino_cadete_2_vip.mdl",
	"vip/soldado_femenino/cadete/soldado_femenino_cadete_3_vip.mdl",
	"vip/soldado_femenino/entrenamiento/soldado_femenino_entrenamiento_1_vip.mdl",
	"vip/soldado_femenino/entrenamiento/soldado_femenino_entrenamiento_2_vip.mdl",
	"vip/soldado_femenino/entrenamiento/soldado_femenino_entrenamiento_3_vip.mdl",
	"vip/soldado_femenino/exploracion/soldado_femenino_exploracion_1_vip.mdl",
	"vip/soldado_femenino/exploracion/soldado_femenino_exploracion_2_vip.mdl",
	"vip/soldado_femenino/exploracion/soldado_femenino_exploracion_3_vip.mdl",
	"vip/soldado_femenino/guarnicion/soldado_femenino_guarnicion_1_vip.mdl",
	"vip/soldado_femenino/guarnicion/soldado_femenino_guarnicion_2_vip.mdl",
	"vip/soldado_femenino/guarnicion/soldado_femenino_guarnicion_3_vip.mdl",
	"vip/soldado_femenino/instructor/soldado_femenino_instructor_1_vip.mdl",
	"vip/soldado_femenino/instructor/soldado_femenino_instructor_2_vip.mdl",
	"vip/soldado_femenino/instructor/soldado_femenino_instructor_3_vip.mdl",
	"vip/soldado_femenino/invierno/invierno_soldado_ropa_1_vip.mdl",
	"vip/soldado_femenino/invierno/invierno_soldado_ropa_2_vip.mdl",
	"vip/soldado_femenino/invierno/invierno_soldado_ropa_3_vip.mdl",
	"vip/soldado_femenino/oficial/entrenamiento/soldado_femenino_entrenamiento_oficial_1_vip.mdl",
	"vip/soldado_femenino/oficial/entrenamiento/soldado_femenino_entrenamiento_oficial_2_vip.mdl",
	"vip/soldado_femenino/oficial/entrenamiento/soldado_femenino_entrenamiento_oficial_3_vip.mdl",
	"vip/soldado_femenino/oficial/exploracion/soldado_femenino_exploracion_oficial_1_vip.mdl",
	"vip/soldado_femenino/oficial/exploracion/soldado_femenino_exploracion_oficial_2_vip.mdl",
	"vip/soldado_femenino/oficial/exploracion/soldado_femenino_exploracion_oficial_3_vip.mdl",
	"vip/soldado_femenino/oficial/guarnicion/soldado_femenino_guarnicion_oficial_1_vip.mdl",
	"vip/soldado_femenino/oficial/guarnicion/soldado_femenino_guarnicion_oficial_2_vip.mdl",
	"vip/soldado_femenino/oficial/guarnicion/soldado_femenino_guarnicion_oficial_3_vip.mdl",
	"vip/soldado_femenino/oficial/policia/soldado_femenino_policia_oficial_1_vip.mdl",
	"vip/soldado_femenino/oficial/policia/soldado_femenino_policia_oficial_2_vip.mdl",
	"vip/soldado_femenino/oficial/policia/soldado_femenino_policia_oficial_3_vip.mdl",
	"vip/soldado_femenino/policia/soldado_femenino_policia_1_vip.mdl",
	"vip/soldado_femenino/policia/soldado_femenino_policia_2_vip.mdl",
	"vip/soldado_femenino/policia/soldado_femenino_policia_3_vip.mdl",
	"vip/soldado_masculino/cadete/soldado_masculino_cadete_1_vip.mdl",
	"vip/soldado_masculino/cadete/soldado_masculino_cadete_2_vip.mdl",
	"vip/soldado_masculino/cadete/soldado_masculino_cadete_3_vip.mdl",
	"vip/soldado_masculino/entrenamiento/soldado_masculino_entrenamiento_1_vip.mdl",
	"vip/soldado_masculino/entrenamiento/soldado_masculino_entrenamiento_2_vip.mdl",
	"vip/soldado_masculino/entrenamiento/soldado_masculino_entrenamiento_3_vip.mdl",
	"vip/soldado_masculino/exploracion/soldado_masculino_exploracion_1_vip.mdl",
	"vip/soldado_masculino/exploracion/soldado_masculino_exploracion_2_vip.mdl",
	"vip/soldado_masculino/exploracion/soldado_masculino_exploracion_3_vip.mdl",
	"vip/soldado_masculino/guarnicion/soldado_masculino_guarnicion_1_vip.mdl",
	"vip/soldado_masculino/guarnicion/soldado_masculino_guarnicion_2_vip.mdl",
	"vip/soldado_masculino/guarnicion/soldado_masculino_guarnicion_3_vip.mdl",
	"vip/soldado_masculino/instructor/soldado_masculino_instructor_1_vip.mdl",
	"vip/soldado_masculino/instructor/soldado_masculino_instructor_2_vip.mdl",
	"vip/soldado_masculino/instructor/soldado_masculino_instructor_3_vip.mdl",
	"vip/soldado_masculino/invierno/invierno_soldado_ropa_1_vip.mdl",
	"vip/soldado_masculino/invierno/invierno_soldado_ropa_2_vip.mdl",
	"vip/soldado_masculino/invierno/invierno_soldado_ropa_3_vip.mdl",
	"vip/soldado_masculino/oficial/entrenamiento/soldado_masculino_entrenamiento_oficial_1_vip.mdl",
	"vip/soldado_masculino/oficial/entrenamiento/soldado_masculino_entrenamiento_oficial_2_vip.mdl",
	"vip/soldado_masculino/oficial/entrenamiento/soldado_masculino_entrenamiento_oficial_3_vip.mdl",
	"vip/soldado_masculino/oficial/exploracion/soldado_masculino_exploracion_oficial_1_vip.mdl",
	"vip/soldado_masculino/oficial/exploracion/soldado_masculino_exploracion_oficial_2_vip.mdl",
	"vip/soldado_masculino/oficial/exploracion/soldado_masculino_exploracion_oficial_3_vip.mdl",
	"vip/soldado_masculino/oficial/guarnicion/soldado_masculino_guarnicion_oficial_1_vip.mdl",
	"vip/soldado_masculino/oficial/guarnicion/soldado_masculino_guarnicion_oficial_2_vip.mdl",
	"vip/soldado_masculino/oficial/guarnicion/soldado_masculino_guarnicion_oficial_3_vip.mdl",
	"vip/soldado_masculino/oficial/policia/soldado_masculino_policia_oficial_1_vip.mdl",
	"vip/soldado_masculino/oficial/policia/soldado_masculino_policia_oficial_2_vip.mdl",
	"vip/soldado_masculino/oficial/policia/soldado_masculino_policia_oficial_3_vip.mdl",
	"vip/soldado_masculino/policia/soldado_masculino_policia_1_vip.mdl",
	"vip/soldado_masculino/policia/soldado_masculino_policia_2_vip.mdl",
	"vip/soldado_masculino/policia/soldado_masculino_policia_3_vip.mdl",
})

-- Modelos para NPC (no jugables): 3 modelos
AOTRP_MODELOS.npc = Lista({
	"civil_masculino/noble_masculino/noble_1/npc_civil_masculino_noble_1.mdl",
	"civil_masculino/noble_masculino/noble_1/npc_civil_masculino_noble_2.mdl",
	"civil_masculino/noble_masculino/noble_1/npc_civil_masculino_noble_3.mdl",
})

-- Maestro de rol: puede usar cualquier modelo jugable.
AOTRP_MODELOS.todos = {}

for _, lista in pairs({AOTRP_MODELOS.civiles, AOTRP_MODELOS.cadetes, AOTRP_MODELOS.instructores,
	AOTRP_MODELOS.exploracion, AOTRP_MODELOS.guarnicion, AOTRP_MODELOS.policia, AOTRP_MODELOS.invierno,
	AOTRP_MODELOS.vip}) do
	for _, m in ipairs(lista) do
		AOTRP_MODELOS.todos[#AOTRP_MODELOS.todos + 1] = m
	end
end

AOTRP_MODELOS.todos[#AOTRP_MODELOS.todos + 1] = "models/kaesar/dotpixis/dotpixis.mdl"

-- Todos usan las animaciones humanas de Helix ("player").
for _, lista in pairs({AOTRP_MODELOS.todos, AOTRP_MODELOS.npc}) do
	for _, m in ipairs(lista) do
		ix.anim.SetModelClass(m, "player")
	end
end
