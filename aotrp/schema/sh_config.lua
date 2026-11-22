-- Moneda: en los Muros no hay un nombre canónico; se usan "monedas".
ix.currency.symbol = ""
ix.currency.singular = "moneda"
ix.currency.plural = "monedas"

-- Ajustes por defecto (se pueden cambiar en el menú de configuración de Helix).
ix.config.SetDefault("color", Color(120, 35, 35))
ix.config.SetDefault("scoreboardRecognition", true)
ix.config.SetDefault("maxCharacters", 3)

-- Altura del personaje (escala del modelo). 1 = normal; la fija el staff con /EstablecerAltura.
ix.char.RegisterVar("altura", {
	field = "altura",
	fieldType = ix.type.number,
	default = 1,
	isLocal = true,
	bNoDisplay = true
})
