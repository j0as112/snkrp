-- Menu de bienvenida (el que sale nada mas conectar: crear, continuar, comunidad, salir) con estilo AoT.
-- Estructura copiada del menu de Naruto: pagina HTML a pantalla completa (DHTML) con panel de cristal, botones
-- animados y fondo propio; Lua solo conecta los botones con el flujo de Helix.
-- Contrato con ixCharMenu: Dim/Undim, loadButton:SetDisabled, UpdateReturnButton, bUsingCharacter.

local UI = ix.aotUI

-- Logo publicado con la pantalla de carga (GitHub Pages del repo).
local LOGO_URL = "https://j0as112.github.io/snkrp/logo.jpg"

local PAGINA = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  :root { --verde:#2f4a3a; --verde-osc:#0e1511; --pergamino:#d9c9a3; --acero:#8a929b; --sangre:#a82525; --oro:#c4a050; }
  * { margin:0; padding:0; box-sizing:border-box; user-select:none; }
  html, body { width:100%; height:100%; overflow:hidden; background:#0e1511; font-family:Georgia,'Palatino Linotype',serif; color:var(--pergamino); }

  /* ---- Escena: cielo de tormenta, sol bajo, muralla y niebla ---- */
  .escena { position:fixed; inset:0;
    background:
      radial-gradient(ellipse 55% 30% at 62% 58%, rgba(255,170,90,.30), transparent 70%),
      linear-gradient(180deg, #1a2826 0%, #2b3b36 38%, #7a4a30 58%, #0e1511 58.2%, #1c2620 70%, #0a0f0c 100%); }
  .muralla { position:absolute; left:0; right:0; top:46%; height:12%;
    background:
      repeating-linear-gradient(90deg, rgba(0,0,0,.35) 0 2px, transparent 2px 110px),
      repeating-linear-gradient(0deg, rgba(0,0,0,.3) 0 2px, transparent 2px 25%),
      linear-gradient(180deg, #5b6361, #3a403e);
    border-top:3px solid #8b918c; box-shadow:0 -10px 40px rgba(0,0,0,.5); }
  .niebla { position:absolute; inset:0; background:
      radial-gradient(ellipse 60% 18% at 25% 62%, rgba(190,200,190,.10), transparent),
      radial-gradient(ellipse 50% 16% at 80% 70%, rgba(190,200,190,.08), transparent);
    animation: deriva 26s ease-in-out infinite alternate; }
  @keyframes deriva { from { transform:translateX(-3%); } to { transform:translateX(3%); } }
  .vineta { position:fixed; inset:0; pointer-events:none;
    background:radial-gradient(ellipse at 60% 50%, transparent 35%, rgba(0,0,0,.78)); }
  canvas { position:fixed; inset:0; pointer-events:none; }

  /* ---- Panel de cristal ---- */
  .panel { position:relative; z-index:10; margin-left:7vw; width:min(34vw,520px); min-width:360px; top:50%; transform:translateY(-50%);
    padding:44px 44px 36px; background:rgba(14,21,17,.62); border:1px solid rgba(196,160,80,.35);
    box-shadow:0 25px 60px rgba(0,0,0,.65); backdrop-filter:blur(10px);
    opacity:0; animation: entra 1.2s .15s forwards cubic-bezier(.19,1,.22,1); }
  .panel::before, .panel::after { content:""; position:absolute; width:26px; height:26px; border:2px solid var(--oro); }
  .panel::before { top:-2px; left:-2px; border-right:0; border-bottom:0; }
  .panel::after { bottom:-2px; right:-2px; border-left:0; border-top:0; }
  @keyframes entra { from { opacity:0; transform:translate(-40px,-50%); } to { opacity:1; transform:translate(0,-50%); } }

  .cab { display:flex; align-items:center; gap:22px; margin-bottom:6px; }
  .cab img { width:96px; height:96px; border-radius:50%; object-fit:cover;
    box-shadow:0 0 0 2px rgba(196,160,80,.65), 0 0 26px rgba(0,0,0,.8); }
  h1 { font-size:3.6rem; line-height:.95; letter-spacing:.16em; font-weight:800; text-transform:uppercase; text-shadow:0 3px 16px rgba(0,0,0,.85); }
  h1 span { color:var(--sangre); }
  .lema { margin:14px 0 26px; font-style:italic; color:var(--acero); font-size:1.05rem; letter-spacing:.06em; }
  .filete { height:2px; background:linear-gradient(90deg, var(--oro), transparent); margin-bottom:26px; }

  .botones { display:flex; flex-direction:column; gap:10px; }
  .btn { position:relative; padding:17px 24px; font-size:1.05rem; letter-spacing:.28em; text-transform:uppercase; cursor:pointer;
    background:rgba(255,255,255,.04); border:1px solid rgba(255,255,255,.06); border-left:0 solid var(--oro);
    transition:all .3s cubic-bezier(.4,0,.2,1); }
  .btn:hover { background:rgba(47,74,58,.75); color:#fff; padding-left:38px; border-left:6px solid var(--oro);
    box-shadow:0 0 26px rgba(196,160,80,.18); }
  .btn.off { opacity:.35; cursor:not-allowed; } .btn.off:hover { background:rgba(255,255,255,.04); padding-left:24px; border-left:0; box-shadow:none; color:inherit; }
  .btn.peligro:hover { background:rgba(120,25,25,.75); border-left-color:#d84b4b; }
  .btn.oculto { display:none; }

  .pie { margin-top:26px; font-size:.78rem; color:rgba(138,146,155,.6); letter-spacing:.14em; text-align:center; }
</style>
</head>
<body>
  <div class="escena"><div class="muralla"></div><div class="niebla"></div></div>
  <canvas id="ceniza"></canvas>
  <div class="vineta"></div>

  <div class="panel">
    <div class="cab">
      <img src="]] .. LOGO_URL .. [[" onerror="this.style.display='none'">
      <h1>SNK <span>RP</span></h1>
    </div>
    <p class="lema">Shinzou wo Sasageyo &mdash; Ofrece tu coraz&oacute;n</p>
    <div class="filete"></div>
    <div class="botones">
      <div class="btn" id="b-new" onmouseenter="H()" onclick="T('new')">Nuevo soldado</div>
      <div class="btn" id="b-load" onmouseenter="H()" onclick="T('load')">Continuar</div>
      <div class="btn oculto" id="b-community" onmouseenter="H()" onclick="T('community')">Comunidad</div>
      <div class="btn peligro" id="b-exit" onmouseenter="H()" onclick="T('exit')">Abandonar</div>
    </div>
    <div class="pie">LOS MUROS &middot; MARIA &middot; ROSE &middot; SINA</div>
  </div>

<script>
  function T(a) { var e = document.getElementById('b-' + a); if (e.classList.contains('off')) return; window.gmod.Trigger(a); }
  function H() { window.gmod.Hover(); }
  function setCargar(ok) { document.getElementById('b-load').classList.toggle('off', !ok); }
  function setSalir(t) { document.getElementById('b-exit').textContent = t; }
  function setComunidad(t) { var e = document.getElementById('b-community'); e.textContent = t; e.classList.toggle('oculto', !t); }

  // Ceniza flotando (ambiente)
  (function () {
    var c = document.getElementById('ceniza'), x = c.getContext('2d'), p = [];
    function ajustar() { c.width = innerWidth; c.height = innerHeight; }
    ajustar(); addEventListener('resize', ajustar);
    for (var i = 0; i < 70; i++) p.push({ x: Math.random() * innerWidth, y: Math.random() * innerHeight, r: Math.random() * 1.8 + .4, v: Math.random() * .5 + .15, d: Math.random() * 2 - 1 });
    function f() {
      x.clearRect(0, 0, c.width, c.height);
      for (var i = 0; i < p.length; i++) {
        var q = p[i]; q.y -= q.v; q.x += q.d * .3;
        if (q.y < -5) { q.y = c.height + 5; q.x = Math.random() * c.width; }
        x.fillStyle = 'rgba(255,200,140,' + (.18 + q.r * .1) + ')'; x.beginPath(); x.arc(q.x, q.y, q.r, 0, 6.3); x.fill();
      }
      requestAnimationFrame(f);
    }
    f();
  })();
</script>
</body>
</html>
]]

-- Tipografia del menu: sans fina y limpia, con espaciado entre letras (estilo minimalista moderno).
surface.CreateFont("aotMenuTitulo", {font = "Roboto", size = ScreenScale(34), weight = 200, extended = true})
surface.CreateFont("aotMenuBoton", {font = "Roboto", size = ScreenScale(10.5), weight = 300, extended = true})
surface.CreateFont("aotMenuPequeno", {font = "Roboto", size = ScreenScale(5.2), weight = 400, extended = true})

-- Dibuja texto letra a letra con espaciado. alinear: 0 izquierda, 1 centro, 2 derecha. Devuelve el ancho.
local function TextoEspaciado(texto, fuente, x, y, color, espacio, alinear)
	surface.SetFont(fuente)

	local letras, ancho = {}, 0

	for _, codigo in utf8.codes(texto) do
		local c = utf8.char(codigo)
		local w = surface.GetTextSize(c)

		letras[#letras + 1] = {c = c, w = w}
		ancho = ancho + w + espacio
	end

	ancho = ancho - espacio

	local cursor = x

	if (alinear == 1) then cursor = x - ancho / 2 elseif (alinear == 2) then cursor = x - ancho end

	surface.SetTextColor(color)

	for _, l in ipairs(letras) do
		surface.SetTextPos(cursor, y)
		surface.DrawText(l.c)
		cursor = cursor + l.w + espacio
	end

	return ancho
end

-- Por defecto se usa el menu dibujado en Lua (fiable); "aot_menu_html 1" prueba la pagina HTML.
local CVAR_HTML = CreateClientConVar("aot_menu_html", "0", true, false)

local PANEL = {}

AccessorFunc(PANEL, "bUsingCharacter", "UsingCharacter", FORCE_BOOL)

function PANEL:Init()
	-- por si el motor no encadena el Init de la clase base
	if (self.subpanels == nil) then
		local base = vgui.GetControlTable("ixCharMenuPanel")
		if (base and base.Init) then base.Init(self) end
	end

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	self.cargarDeshabilitado = (#ix.characters == 0)

	-- Compat: ixCharMenu:OnCharacterDeleted usa mainPanel.loadButton:SetDisabled(...)
	self.loadButton = {
		SetDisabled = function(_, valor)
			self.cargarDeshabilitado = valor and true or false
			self:Refrescar()
		end
	}

	self.nacido = CurTime()
	self.htmlListo = false
	self.usarLua = !CVAR_HTML:GetBool()

	if (!self.usarLua) then
		self.html = self:Add("DHTML")
		self.html:SetSize(ScrW(), ScrH())
		self.html:SetPos(0, 0)

		self.html:AddFunction("gmod", "Trigger", function(accion)
			self:Accion(accion)
		end)

		self.html:AddFunction("gmod", "Hover", function()
			surface.PlaySound("helix/ui/rollover.wav")
		end)

		self.html.OnDocumentReady = function()
			self.htmlListo = true
			MsgN("[aot_interfaz] Menu de bienvenida HTML cargado.")
			self:Refrescar()
		end

		self.html:SetHTML(PAGINA)
	end
end

-- Estado de los botones segun el jugador (lo pinta el JS de la pagina).
function PANEL:Refrescar()
	if (!IsValid(self.html)) then return end

	local salir = self.bUsingCharacter and "Volver al juego" or "Abandonar"
	local comunidad = ""

	local url = ix.config.Get("communityURL", "")
	local texto = ix.config.Get("communityText", "@community")

	if (url != "" and texto != "") then
		comunidad = (texto == "@community") and "Comunidad" or ((texto:sub(1, 1) == "@") and L(texto:sub(2)) or texto)
	end

	self.html:RunJavascript(string.format("setCargar(%s);setSalir('%s');setComunidad('%s');",
		tostring(!self.cargarDeshabilitado), salir:gsub("'", ""), comunidad:gsub("'", "")))
end

function PANEL:Accion(accion)
	local parent = self:GetParent()

	if (accion == "community") then
		local url = ix.config.Get("communityURL", "")
		if (url != "") then gui.OpenURL(url) end

		return
	end

	surface.PlaySound("helix/ui/press.wav")

	if (accion == "exit") then
		if (self.bUsingCharacter) then
			parent:Close()
		else
			RunConsoleCommand("disconnect")
		end

		return
	end

	if (accion == "new") then
		local maximo = ix.config.Get("maxCharacters", 5)

		if (LocalPlayer():IsAdmin()) then
			maximo = maximo + 100
		end

		if (#ix.characters >= maximo) then
			parent:ShowNotice(3, L("maxCharacters"))
			return
		end

		self:Dim()
		parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
		parent.newCharacterPanel:SlideUp()
	elseif (accion == "load") then
		if (self.cargarDeshabilitado) then return end

		self:Dim()
		parent.loadCharacterPanel:SlideUp()
	end
end

-- Compat con ixCharMenu (cl_character.lua)
function PANEL:UpdateReturnButton(valor)
	if (valor != nil) then
		self.bUsingCharacter = valor
	end

	self:Refrescar()
end

function PANEL:OnDim()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	if (IsValid(self.html)) then
		self.html:SetMouseInputEnabled(false)
		self.html:SetVisible(false)
	end
end

function PANEL:OnUndim()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	if (IsValid(self.html) and !self.usarLua) then
		self.html:SetVisible(true)
		self.html:SetMouseInputEnabled(true)
	end

	self:Refrescar()
end

function PANEL:OnClose()
	for _, v in pairs(self:GetChildren()) do
		if (IsValid(v)) then
			v:SetVisible(false)
		end
	end
end

-- Si la pagina HTML no arranca (el navegador embebido de algunos clientes no la dibuja), se usa un menu
-- equivalente dibujado en Lua: mismo fondo, mismo panel, mismos botones.
function PANEL:Think()
	if (!self.usarLua and !self.htmlListo and CurTime() > (self.nacido or 0) + 1.5) then
		self.usarLua = true

		MsgN("[aot_interfaz] El menu HTML no arranco: se usa el menu en Lua.")

		if (IsValid(self.html)) then self.html:SetVisible(false) end
	end
end

function PANEL:Botones()
	local lista = {
		{id = "new", texto = "NUEVO SOLDADO"},
		{id = "load", texto = "CONTINUAR", apagado = self.cargarDeshabilitado},
	}

	local url = ix.config.Get("communityURL", "")
	local texto = ix.config.Get("communityText", "@community")

	if (url != "" and texto != "") then
		lista[#lista + 1] = {id = "community", texto = (texto == "@community") and "COMUNIDAD" or ((texto:sub(1, 1) == "@") and L(texto:sub(2)) or texto):utf8upper()}
	end

	lista[#lista + 1] = {id = "exit", texto = self.bUsingCharacter and "VOLVER AL JUEGO" or "ABANDONAR", peligro = true}

	return lista
end

function PANEL:Paint(ancho, alto)
	if (!self.usarLua) then return end

	-- Imagen de fondo; si todavia no se ha descargado, el fondo de estudio.
	if (!UI.DibujarFondoImagen(ancho, alto)) then
		UI.FondoEstudio(ancho, alto)
	end

	-- Degradado suave desde la izquierda (sin panel duro): negro casi solido y se funde con la imagen.
	local solido = ancho * 0.16
	local fin = ancho * 0.46

	surface.SetDrawColor(4, 6, 6, 238)
	surface.DrawRect(0, 0, solido, alto)
	surface.SetTexture(surface.GetTextureID("vgui/gradient-l"))
	surface.DrawTexturedRect(solido, 0, fin - solido, alto)

	local x = ancho * 0.075
	local lista = self:Botones()
	local dt = FrameTime()
	self.anim = self.anim or {}

	local filas = #lista
	local ls = ScreenScale(24)
	local fila = ScreenScale(20)
	local altoBloque = ls + ScreenScale(70) + filas * fila
	local y = (alto - altoBloque) / 2

	-- logo pequeno + marca
	local logo = UI.Logo()

	if (logo) then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(logo)
		surface.DrawTexturedRect(x, y, ls, ls)
	end

	surface.SetDrawColor(255, 255, 255, 35)
	surface.DrawOutlinedRect(x, y, ls, ls)

	y = y + ls + ScreenScale(14)
	TextoEspaciado("SNK RP", "aotMenuTitulo", x - ScreenScale(1), y, Color(240, 240, 238), ScreenScale(4), 0)

	y = y + ScreenScale(36)
	TextoEspaciado("ATTACK ON TITAN ROLEPLAY", "aotMenuPequeno", x, y, Color(150, 156, 160), ScreenScale(1.6), 0)

	y = y + ScreenScale(12)
	surface.SetDrawColor(UI.oro.r, UI.oro.g, UI.oro.b, 220)
	surface.DrawRect(x, y, ScreenScale(20), 2)

	y = y + ScreenScale(16)

	-- botones: solo texto; al pasar el raton se dibuja una linea y se desplaza ligeramente
	local mx, my = self:CursorPos()
	local anchoBoton = ancho * 0.28
	self.rectas = {}

	for i, b in ipairs(lista) do
		local by = y + (i - 1) * fila
		local encima = !b.apagado and mx >= x - ScreenScale(8) and mx <= x + anchoBoton and my >= by and my <= by + fila

		self.anim[b.id] = Lerp(math.min(dt * 12, 1), self.anim[b.id] or 0, encima and 1 or 0)

		local f = self.anim[b.id]

		if (encima and !b.sono) then
			b.sono = true
			surface.PlaySound("helix/ui/rollover.wav")
		elseif (!encima) then
			b.sono = false
		end

		-- velo muy sutil y linea inferior que crece
		if (f > 0.01) then
			surface.SetDrawColor(255, 255, 255, 9 * f)
			surface.DrawRect(x - ScreenScale(8), by, anchoBoton + ScreenScale(8), fila)

			surface.SetDrawColor(b.peligro and 216 or UI.oro.r, b.peligro and 80 or UI.oro.g, b.peligro and 80 or UI.oro.b, 230 * f)
			surface.DrawRect(x - ScreenScale(8), by + fila - 2, (anchoBoton + ScreenScale(8)) * f, 2)
		end

		local alfa = b.apagado and 70 or (150 + 105 * f)
		local color = b.peligro and Color(Lerp(f, 200, 235), Lerp(f, 200, 95), Lerp(f, 200, 95), alfa) or Color(240, 240, 238, alfa)

		TextoEspaciado(string.format("%02d", i), "aotMenuPequeno", x, by + fila / 2 - ScreenScale(2.6), Color(120, 126, 130, b.apagado and 70 or 200), ScreenScale(1), 0)
		TextoEspaciado(b.texto, "aotMenuBoton", x + ScreenScale(18) + f * ScreenScale(5), by + fila / 2 - ScreenScale(5.6), color, ScreenScale(2.2), 0)

		if (f > 0.05) then
			TextoEspaciado(">", "aotMenuBoton", x + anchoBoton - ScreenScale(8) - (1 - f) * ScreenScale(6), by + fila / 2 - ScreenScale(5.6), ColorAlpha(color, 255 * f), 0, 2)
		end

		self.rectas[#self.rectas + 1] = {x = x - ScreenScale(8), y = by, w = anchoBoton + ScreenScale(8), h = fila, id = b.id, apagado = b.apagado}
	end

	TextoEspaciado("LOS MUROS  /  MARIA  /  ROSE  /  SINA", "aotMenuPequeno", x, alto - ScreenScale(14), Color(120, 126, 130, 170), ScreenScale(1.4), 0)
end

function PANEL:OnMousePressed(codigo)
	if (!self.usarLua or codigo != MOUSE_LEFT) then return end

	local mx, my = self:CursorPos()

	for _, r in ipairs(self.rectas or {}) do
		if (!r.apagado and mx >= r.x and mx <= r.x + r.w and my >= r.y and my <= r.y + r.h) then
			self:Accion(r.id)
			return
		end
	end
end

vgui.Register("ixCharMenuMain", PANEL, "ixCharMenuPanel")
