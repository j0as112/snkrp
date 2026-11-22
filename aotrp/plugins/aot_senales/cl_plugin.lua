if (!CLIENT) then return end

local PLUGIN = PLUGIN

-- ============================================================
-- Bengala: sube unos 50 m dejando una estela de humo de color que dura en el cielo.
-- ============================================================
net.Receive("ixAotBengala", function()
	local origen = net.ReadVector()
	local info = PLUGIN.bengalas[net.ReadString()]
	if (!info) then return end

	local emisor = ParticleEmitter(origen)
	local c = info.color
	local pasos = 45
	local altura = 2600
	local deriva = VectorRand() * 120
	deriva.z = 0

	sound.Play("weapons/ar2/ar2_altfire.wav", origen, 100, 130)

	local paso = 0

	local function Estela()
		paso = paso + 1
		local f = paso / pasos
		local pos = origen + Vector(0, 0, altura * (1 - (1 - f) ^ 2)) + deriva * f

		for _ = 1, 3 do
			local p = emisor:Add("particle/particle_smokegrenade", pos + VectorRand() * 8)

			if (p) then
				p:SetVelocity(VectorRand() * 15)
				p:SetDieTime(math.Rand(18, 26))
				p:SetStartAlpha(220)
				p:SetEndAlpha(0)
				p:SetStartSize(35)
				p:SetEndSize(140)
				p:SetColor(c.r, c.g, c.b)
				p:SetRoll(math.Rand(0, 360))
				p:SetRollDelta(math.Rand(-0.3, 0.3))
				p:SetAirResistance(20)
				p:SetGravity(Vector(15, 5, 4))
			end
		end

		-- Punta brillante de la bengala.
		local chispa = emisor:Add("sprites/light_glow02_add", pos)
		if (chispa) then
			chispa:SetDieTime(0.25)
			chispa:SetStartAlpha(255)
			chispa:SetEndAlpha(0)
			chispa:SetStartSize(60)
			chispa:SetEndSize(10)
			chispa:SetColor(c.r, c.g, c.b)
		end

		if (paso >= pasos) then
			emisor:Finish()
		end
	end

	for i = 1, pasos do
		timer.Simple(i * 0.03, Estela)
	end
end)

-- ============================================================
-- Alarma de los Muros: campana y aviso a pantalla completa.
-- ============================================================
local alarma = {texto = "", hasta = 0}

net.Receive("ixAotAlarma", function()
	alarma.texto = net.ReadString()
	alarma.inicio = CurTime()
	alarma.hasta = CurTime() + 8

	surface.PlaySound("ambient/alarms/warningbell1.wav")
	timer.Simple(1.2, function() surface.PlaySound("ambient/alarms/warningbell1.wav") end)
	timer.Simple(2.4, function() surface.PlaySound("ambient/alarms/warningbell1.wav") end)
end)

surface.CreateFont("ixAotAlarma", {font = "Roboto", size = ScreenScale(16), weight = 900, extended = true})
surface.CreateFont("ixAotAlarmaTexto", {font = "Roboto", size = ScreenScale(9), weight = 600, extended = true})

function PLUGIN:HUDPaint()
	if (alarma.hasta < CurTime()) then return end

	local sw = ScrW()
	local vida = (CurTime() - alarma.inicio) / 8
	local alfa = 255 * math.min(1, (1 - vida) * 4)
	local parpadeo = math.abs(math.sin(CurTime() * 4))

	draw.RoundedBox(0, 0, ScrH() * 0.14, sw, ScreenScale(36), Color(90, 10, 10, 170 * alfa / 255))
	draw.SimpleTextOutlined("¡ALARMA EN LOS MUROS!", "ixAotAlarma", sw / 2, ScrH() * 0.14 + ScreenScale(12), Color(255, 80 + 120 * parpadeo, 60, alfa), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, alfa))
	draw.SimpleTextOutlined(alarma.texto, "ixAotAlarmaTexto", sw / 2, ScrH() * 0.14 + ScreenScale(27), Color(255, 255, 255, alfa), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alfa))
end
