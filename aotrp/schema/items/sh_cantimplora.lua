ITEM.name = "Cantimplora"
ITEM.description = "Una cantimplora de cuero con agua."
ITEM.model = "models/props_junk/garbage_glassbottle001a.mdl"
ITEM.category = "Consumibles"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Beber = {
	name = "Beber",
	icon = "icon16/drink.png",
	OnRun = function(item)
		local client = item.player
		client:SetHealth(math.min(client:Health() + 5, client:GetMaxHealth()))
		client:SetLocalVar("stm", 100)
		client:EmitSound("npc/barnacle/barnacle_gulp1.wav", 60, 110)
	end
}
