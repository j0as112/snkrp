AddCSLuaFile("cl_init.lua")
DeriveGamemode("helix")

-- Contenido (modelos, materiales, sonidos) en la Workshop. El CODIGO de SNKarmas y SNKtitanes NO va
-- en la Workshop: vive en el repo y el servidor lo envia a los clientes. Coleccion "SNK Roleplay (servidor)".
for _, id in ipairs({"3844168113", "3844165113", "3844163136", "3844162594", "3844162132"}) do
	resource.AddWorkshop(id)
end
