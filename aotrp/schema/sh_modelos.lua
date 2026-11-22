-- Modelos de jugador que usan las animaciones humanas de Helix ("player").
-- Los soldados y civiles (models/j0as/aotrp/) se registran en libs/sh_listamodelos.lua.

local MODELOS = {
	"models/kaesar/dotpixis/dotpixis.mdl",
	"models/models/walkyrie_falko/titan/titan_primordiaux/titan_assailant.mdl",
	"models/warwax/collossal_pm.mdl",
	"models/armoredtit/armored_pm.mdl",
	"models/models/walkyrie_falko/titan/titan_primordiaux/titan_colossal.mdl",
	"models/models/walkyrie_falko/titan/titan_primordiaux/titan_cuirasse.mdl",
	"models/models/walkyrie_falko/titan/titan_primordiaux/titan_feminin.mdl",
	"models/hydralis_titan1.mdl",
	"models/hydralis_titan2.mdl",
	"models/hydralis_titan3_crawl.mdl",
	"models/hydralis_titan3.mdl",
	"models/hydralis_titan4.mdl",
}

for _, modelo in ipairs(MODELOS) do
	ix.anim.SetModelClass(modelo, "player")
end
