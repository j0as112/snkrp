-- No hay menú de "negocios" de Helix: el comercio se hace con vendedores y rol.
function Schema:CanPlayerUseBusiness(client, uniqueID)
	return false
end

function Schema:CanDrive(client, entity)
	return false
end

-- Las clases son rangos: se asignan con /Rango, no se eligen en el menú (salvo volver al rango base).
function Schema:CanPlayerJoinClass(client, class, info)
	local clase = ix.class.list[class]

	if (clase and !clase.isDefault) then
		return false
	end
end
