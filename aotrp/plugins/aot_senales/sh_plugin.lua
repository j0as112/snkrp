local PLUGIN = PLUGIN

PLUGIN.name = "AoT: señales"
PLUGIN.author = "j0as"
PLUGIN.description = "Bengalas de colores para comunicarse en campo abierto y alarma de los Muros para eventos."

-- Código de colores de las bengalas, como en el anime.
PLUGIN.bengalas = {
	roja = {color = Color(220, 40, 40), texto = "¡Titán avistado!"},
	verde = {color = Color(60, 200, 80), texto = "Dirección de avance."},
	negra = {color = Color(25, 25, 25), texto = "¡Titán aberrante!"},
	amarilla = {color = Color(235, 205, 40), texto = "Operación completada."},
	morada = {color = Color(150, 60, 200), texto = "¡Emergencia!"},
}

PLUGIN.ordenBengalas = {"roja", "verde", "negra", "amarilla", "morada"}
PLUGIN.alcanceBengala = 9000

ix.chat.Register("bengala", {
	CanHear = PLUGIN.alcanceBengala,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		local info = PLUGIN.bengalas[data and data.color or ""] or PLUGIN.bengalas.roja
		local nombre = IsValid(speaker) and speaker:Name() or "Alguien"
		chat.AddText(info.color, "[Bengala " .. (data and data.color or "") .. "] ", color_white, nombre .. ": " .. info.texto)
	end
})

ix.chat.Register("alarma", {
	CanHear = function() return true end,
	OnChatAdd = function(self, speaker, text)
		chat.AddText(Color(255, 70, 50), "[ALARMA] ", color_white, text)
	end
})

ix.command.Add("Bengala", {
	description = "Dispara una bengala: roja, verde, negra, amarilla o morada (necesitas una pistola de bengalas).",
	arguments = ix.type.string,
	OnRun = function(self, client, color)
		return PLUGIN:DispararConPistola(client, string.lower(color))
	end
})

ix.command.Add("Alarma", {
	description = "Hace sonar la alarma de los Muros con un mensaje para todo el servidor (mandos y staff).",
	arguments = ix.type.text,
	OnCheckAccess = function(self, client)
		return Schema:EsMando(client)
	end,
	OnRun = function(self, client, texto)
		PLUGIN:Alarma(client, texto)
	end
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
