local PLUGIN = PLUGIN

PLUGIN.name = "Sistema de Descripciones Extendidas"
PLUGIN.author = "Ghost"
PLUGIN.description = "Permite a los personajes definir una descripción más larga y una foto de referencia."

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.command.Add("VerDescExt", {
	description = "Echa un vistazo a tu propia descripción extendida.",
	OnRun = function(self, client)
		local textEntryData = client:GetCharacter():GetData("textDetDescData", nil) or "Sin descripción extendida."
		local textEntryDataURL = client:GetCharacter():GetData("textDetDescDataURL", nil) or "Sin foto de referencia."

		net.Start("ixOpenDetailedDescriptions")
			net.WriteEntity(client)
			net.WriteString(textEntryData)
			net.WriteString(textEntryDataURL)
		net.Send(client)
	end
})

ix.command.Add("EstablecerDescExt", {
	description = "Establece tu descripción extendida.",
	OnRun = function(self, client)
		net.Start("ixSetDetailedDescriptions")
		net.Send(client)
	end
})
