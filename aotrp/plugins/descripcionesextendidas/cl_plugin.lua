net.Receive("ixOpenDetailedDescriptions", function()
	local client = net.ReadEntity()
	local textEntryData = net.ReadString()
	local textEntryDataURL = net.ReadString()
	
	local Frame = vgui.Create("DFrame")
	Frame:Center()
	Frame:SetPos(Frame:GetPos() - 150, 250, 0)
	Frame:SetSize(350, 500)
	Frame:SetTitle("Descripción Extendida")
	Frame:MakePopup()

	local List = vgui.Create("DListView", Frame)
	List:Dock( FILL )
	List:DockMargin( 0, 0, 0, 5 )
	List:SetMultiSelect(false)
	
	local textEntry = vgui.Create("DTextEntry", List)
	textEntry:Dock( FILL )
	textEntry:DockMargin( 0, 0, 0, 0 )
	textEntry:SetMultiline(true)
	textEntry:SetVerticalScrollbarEnabled(true)
	textEntry:SetEditable(false)
	textEntry:SetDisabled(true)

	textEntry:SetText(textEntryData)
	
	local DButton = vgui.Create("DButton", List)
	if (textEntryDataURL == "Sin foto de referencia.") then
		DButton:SetDisabled(true)
		DButton:SetText("Sin Foto")
	else
		DButton:SetTextColor(Color(0, 0, 0, 255))
		DButton:SetText("Ver Foto")
	end
	DButton:Dock( BOTTOM )
	DButton:DockMargin( 0, 0, 0, 0 )
	
	DButton.DoClick = function()
		local foto = vgui.Create("DFrame")
		foto:SetSize(ScrW() * 0.5, ScrH() * 0.5)
		foto:SetTitle("Foto de Referencia")
		foto:Center()
		foto:MakePopup()

		local html = foto:Add("HTML")
		html:Dock(FILL)
		html:OpenURL(textEntryDataURL)
	end
end)

net.Receive("ixSetDetailedDescriptions", function()
	local Frame = vgui.Create("DFrame")
	Frame:Center()
	Frame:SetPos(Frame:GetPos() - 150, 250, 0)
	Frame:SetSize(350, 500)
	Frame:SetTitle("Editar Descripción Extendida")
	Frame:MakePopup()

	local List = vgui.Create("DListView", Frame)
	List:Dock( FILL )
	List:DockMargin( 0, 0, 0, 5 )
	List:SetMultiSelect(false)
	
	local textEntry = vgui.Create("DTextEntry", List)
	textEntry:Dock( FILL )
	textEntry:DockMargin( 0, 0, 0, 0 )
	textEntry:SetMultiline(true)
	textEntry:SetVerticalScrollbarEnabled(true)
	
	if (LocalPlayer():GetCharacter():GetData("textDetDescData")) then
		textEntry:SetText(LocalPlayer():GetCharacter():GetData("textDetDescData"))
	end
	
	local DButton = vgui.Create("DButton", List)
	DButton:DockMargin( 0, 0, 0, 0 )
	DButton:Dock( BOTTOM )
	DButton:SetText("Editar")
	DButton:SetTextColor(Color(0, 0, 0, 255))
	
	local textEntryURL = vgui.Create("DTextEntry", List)
	textEntryURL:Dock( BOTTOM )
	textEntryURL:DockMargin( 0, 0, 0, 0 )
	textEntryURL:SetPlaceholderText("Introduce una URL para tu foto...")
	
	if (LocalPlayer():GetCharacter():GetData("textDetDescDataURL")) then
		textEntryURL:SetValue(LocalPlayer():GetCharacter():GetData("textDetDescDataURL"))
		textEntryURL:SetText(LocalPlayer():GetCharacter():GetData("textDetDescDataURL"))
	end
	
	DButton.DoClick = function()
		net.Start("ixEditDetailedDescriptions")
			net.WriteString(textEntryURL:GetValue())
			net.WriteString(textEntry:GetValue())
		net.SendToServer()
		Frame:Remove()
	end
end)

function PLUGIN:GetPlayerEntityMenu(client, options)
	options["Examinar"] = true
end