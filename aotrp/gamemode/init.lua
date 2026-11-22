AddCSLuaFile("cl_init.lua")
DeriveGamemode("helix")

-- Contenido de la Workshop que descargan los jugadores al entrar. Coleccion "SNK Roleplay (servidor)"
-- (https://steamcommunity.com/sharedfiles/filedetails/?id=3844314260).
-- El CODIGO de SNKarmas y SNKtitanes NO va en la Workshop: vive en el repo y el servidor lo envia.
local WORKSHOP = {
	-- Propios (solo contenido)
	"3844168113", -- SNK Armas
	"3844165113", -- SNK Titanes
	"3844162132", -- SNK Modelos1
	"3844162594", -- SNK Modelos2
	"3844163136", -- SNK Modelos3

	-- Mapa por defecto: los jugadores lo descargan de la Workshop al entrar
	"2795519670", -- rp_shiganshina_td - Shingeki No Kyojin Map (rp_shiganshina_tdv1)

	-- Animaciones y combate (wOS / lightsabers)
	"757604550",  -- [wOS] Animation Extension - Base (Full Version)
	"2646756503", -- [wOS] Animation Extension - Base (Code Only)
	"2916561591", -- [wOS] DynaBase - Dynamic Animation Manager
	"2917050373", -- [wOS] DynaBase Legacy Extensions
	"848953359",  -- [wOS] Animation Extension - Blade Symphony
	"848953556",  -- [wOS] Animation Extension - Day of Defeat
	"848953609",  -- [wOS] Animation Extension - Age of Chivalry
	"873302121",  -- [wOS] Animation Extension - Action Half-life
	"925184078",  -- [wOS] Animation Extension - Experimental
	"2247494212", -- [WOS] Standard Sword Art
	"3639759659", -- Wos Alexis Edit 2026 Guti
	"919270611",  -- [wOS] Advanced Lightsaber Attack System
	"1102570708", -- [wOS] Advanced Lightsaber Combat (Content Pack)
	"111412589",  -- Star Wars Lightsabers

	-- Particulas
	"2890316061", -- 3D Particle System Base
	"3021209695", -- [STool] GParticles
}

for _, id in ipairs(WORKSHOP) do
	resource.AddWorkshop(id)
end
