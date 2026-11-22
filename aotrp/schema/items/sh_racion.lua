ITEM.name = "Ración de campaña"
ITEM.description = "Pan duro, patata cocida y un trozo de carne seca envueltos en tela."
ITEM.model = "models/props_junk/garbage_bag001a.mdl"
ITEM.category = "Consumibles"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Comer = {
	name = "Comer",
	icon = "icon16/cake.png",
	OnRun = function(item)
		local client = item.player
		client:SetHealth(math.min(client:Health() + 10, client:GetMaxHealth()))
		client:EmitSound("npc/barnacle/barnacle_crunch3.wav", 60, 120)
	end
}
