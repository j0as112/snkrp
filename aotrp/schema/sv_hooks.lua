-- Equipo inicial al crear un personaje.
local EQUIPO_MILITAR = {"3dmg", "bombona_gas", "hojas_recambio", "pistola_bengalas", "racion", "cantimplora", "venda"}
local EQUIPO_CIVIL = {"racion", "cantimplora"}

function Schema:OnCharacterCreated(client, character)
	local inventario = character:GetInventory()
	if (!inventario) then return end

	local militar = self:EsMilitar(character)

	for _, item in ipairs(militar and EQUIPO_MILITAR or EQUIPO_CIVIL) do
		if (ix.item.list[item]) then
			inventario:Add(item)
		end
	end

	character:SetMoney(militar and 20 or 50)
end

-- Al aparecer: altura del personaje y saludo militar si el addon está instalado.
function Schema:PlayerLoadout(client)
	local character = client:GetCharacter()
	if (!character) then return end

	client:SetModelScale(math.Clamp(character:GetAltura() or 1, 0.3, 1.9), 0)

	if (self:EsMilitar(character) and weapons.GetStored("sasageyo_swep")) then
		client:Give("sasageyo_swep")
	end
end

-- Al pasar a un cuerpo militar (por ejemplo, al graduarse), se asegura el 3DMG.
function Schema:CharacterVarChanged(character, clave, anterior, nuevo)
	if (clave != "faction" or !self:EsMilitar(character)) then return end

	local inventario = character:GetInventory()

	if (inventario and !inventario:HasItem("3dmg")) then
		inventario:Add("3dmg")
	end
end
