ITEM.name = "Equipo 3DMG"
ITEM.description = "Un equipo de maniobras tridimensional reglamentario: ganchos, depósito de gas y vainas con hojas de recambio."
ITEM.category = "Weapons"
ITEM.model = "models/olddeath/w_snk_sword.mdl"
ITEM.class = "aot_odm" -- SWEP nuevo (plugins/aot_combate). El antiguo era "3dmg_expert".
ITEM.width = 2
ITEM.height = 2
ITEM.isWeapon = true
ITEM.isGrenade = false
ITEM.weaponCategory = "other"

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("equip")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		local estado = tooltip:AddRow("aotEstado")
		estado:SetText(string.format("Gas: %d%%  |  Filo: %d%%  |  Recambios: %d",
			self:GetData("aotGas", 100), self:GetData("aotFilo", 100), self:GetData("aotHojas", ix.config.Get("aotHojasRecambio", 4))))
		estado:SizeToContents()
	end
end
