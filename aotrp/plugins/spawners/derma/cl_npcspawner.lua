
local PANEL = {}

function PANEL:Setup(entity)
    self.entity = entity

    self.enabledBoolValue = self.entity:GetEnabled()
    self.enabledBool:SetChecked(self.entity:GetEnabled(), true)
    self.npcClassValue = self.entity:GetNPCClass()
    self.npcClassText:SetValue(self.entity:GetNPCClass())
    self.spawnRadiusValue = self.entity:GetNPCSpawnRadius()
    self.spawnRadiusSlider:SetValue(self.entity:GetNPCSpawnRadius())
    self.maxNPCValue = self.entity:GetMaxNPCs()
    self.maxNPCSlider:SetValue(self.entity:GetMaxNPCs())
    self.spawnAmountValue = self.entity:GetSpawnAmount()
    self.spawnAmountSlider:SetValue(self.entity:GetSpawnAmount())
    self.spawnIntervalValue = self.entity:GetSpawnInterval()
    self.spawnIntervalSlider:SetValue(self.entity:GetSpawnInterval())
    self.despawnAmountValue = self.entity:GetDespawnValue()
    self.DespawnAmountSlider:SetValue(self.entity:GetDespawnValue())
    self.spawnMaterialValue = self.entity:GetSpawnMaterial() or "none"
    self.spawnMaterialText:SetValue(self.entity:GetSpawnMaterial())
    self.expValue = self.entity:GetExp()
    self.expSlider:SetValue(self.entity:GetExp())
    self.npcHealth = self.entity:GetNPCHealth()
    self.npcHealthSlider:SetValue(self.entity:GetNPCHealth())
    self.colorValue = self.entity:GetNPCColor()
    self.colorPicker:SetColor(self.entity:GetNPCColor())
    self.colorRow:SetBackgroundColor(Color(self.entity:GetNPCColor().r, self.entity:GetNPCColor().g, self.entity:GetNPCColor().b, 50))
    self.mdlScaleValue = self.entity:GetMdlScale()
    self.mdlScaleSlider:SetValue(self.entity:GetMdlScale())
    self.minPlayersValue = self.entity:GetMinPlayers()
    self.minPlayersSlider:SetValue(self.entity:GetMinPlayers())
end

function PANEL:Init()
    self:SetSize(ScrW() * 0.45, ScrH() * 0.67)
    self:SetTitle("Gestore Spawner NPC")
    self:Center()
    self:SetMouseInputEnabled(true)
    self:MakePopup()

    self.npcSpawnerPanel = self:Add("DPanel")
    self.npcSpawnerPanel:Dock(FILL)

    self.npcSpawnerPanel.AddRow = function(panel)
        local row = panel:Add("DPanel")
        AccessorFunc(row, "bShowReset", "ShowReset", FORCE_BOOL)
        row:Dock(TOP)
        row:SetWide(panel:GetWide() * 0.5 - 7)
        row:SetTall(ScrW() * 0.025)

        row.AddLabel = function(parent, text)
            local label = row:Add("DLabel")
            label:Dock(LEFT)
            label:Center()
            label:SetWide(self:GetWide())
            label:SetText(text)
            label:SetTextInset(4, 0)
            label:SetTextColor(color_white)
            label:SetFont("ixMediumFont")
        end

        row.AddSlider = function(parent, value, min, max, fValueChanged)
            row.slider = row:Add("ixNumSlider")
            row.slider:Dock(RIGHT)
            row.slider:SetWide(self:GetWide() * .4)
            row.slider:SetValue(value)
            row.slider:SetMin(min)
            row.slider:SetMax(max)
            row.slider.OnValueChanged = fValueChanged

            local sliderLabel = row.slider:GetLabel()
            sliderLabel:SetCursor("hand")
            sliderLabel:SetMouseInputEnabled(true)
            sliderLabel.OnMousePressed = function(_, key)
                if (key == MOUSE_LEFT) then
                    if (IsValid(self.entry)) then
                        self.entry:Remove()
                        return
                    end

                    self.entry = vgui.Create("ixSettingsRowNumberEntry")
                    self.entry:Attach(sliderLabel)
                    self.entry:SetValue(self:GetValue(), true)
                    self.entry.OnValueChanged = function(this)
                        local newValue = math.Round(this:GetValue(), row.slider:GetDecimals())

                        if (newValue != self:GetValue()) then
                            row.slider:SetValue(newValue, true)
                            row.slider:OnValueChanged(newValue)
                        end
                    end
                end
            end

            return row.slider
        end

        row.SetShowReset = function(parent, value, name, default)
            value = tobool(value)

            if (value and !IsValid(row.reset)) then
                row.reset = row:Add("DButton")
                row.reset:SetFont("ixSmallTitleIcons")
                row.reset:SetText("x")
                row.reset:SetTextColor(ColorAlpha(derma.GetColor("Warning", row), 100))
                row.reset:Dock(RIGHT)
                row.reset:SizeToContents()
                row.reset.Paint = nil
                row.reset.DoClick = function()
                    row:OnResetClicked()
                end
                row.reset:SetHelixTooltip(function(tooltip)
                    local title = tooltip:AddRow("title")
                    title:SetImportant()
                    title:SetText("Resetta")
                    title:SetBackgroundColor(derma.GetColor("Warning", row))
                    title:SizeToContents()

                    local description = tooltip:AddRow("description")
                    description:SetText(L("resetDefaultDescription", tostring(name), tostring(default)))
                    description:SizeToContents()
                end)
            elseif (!value and IsValid(row.reset)) then
                row.reset:Remove()
            end

            row.bShowReset = value
        end

        return row
    end

    self.enabledRow = self.npcSpawnerPanel:AddRow()
    self.enabledLabel = self.enabledRow:AddLabel("Attivo")
    self.enabledBool = self.enabledRow:Add("ixCheckBox")
    self.enabledBool:Dock(RIGHT)
    self.enabledBool.DoClick = function(panel)
        self.enabledBoolValue = panel:GetValue()
        self.enabledRow:SetShowReset(panel:GetValue() != self.entity:GetEnabled(), "Attivo", self.entity:GetEnabled())
    end
    self.enabledRow.OnResetClicked = function()
        self.enabledRow:SetShowReset(false)
        self.enabledBool:SetChecked(self.entity:GetEnabled())
    end

    self.npcClassRow = self.npcSpawnerPanel:AddRow()
    
    self.npcClassRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Classe NPC")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("La classe degli npc da spawnare.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.npcClassLabel = self.npcClassRow:AddLabel("Classe NPC")
    self.npcClassText = self.npcClassRow:Add("ixTextEntry")
    self.npcClassText:Dock(RIGHT)
    self.npcClassText:SetFont("ixMenuButtonFont")
    self.npcClassText:SetBackgroundColor(derma.GetColor("DarkerBackground", self))
    self.npcClassText:SetWide(self:GetWide() * 0.4)
    self.npcClassText.OnChange = function(panel)
        self.npcClassValue = panel:GetValue()
        self.npcClassRow:SetShowReset(panel:GetValue() != self.entity:GetNPCClass(), "Classe NPC", self.entity:GetNPCClass())
    end
    self.npcClassRow.OnResetClicked = function()
        self.npcClassRow:SetShowReset(false)
        self.npcClassText:SetValue(self.entity:GetNPCClass())
    end

    self.mdlScaleRow = self.npcSpawnerPanel:AddRow()
    
    self.mdlScaleRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Scala modello")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("La scala di grandezza secondo la quale spawneranno i mob.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.mdlScaleLabel = self.mdlScaleRow:AddLabel("Scala modello")
    self.mdlScaleSlider = self.mdlScaleRow:AddSlider(1, 1, 50, function(panel)
        self.mdlScaleValue = panel:GetValue()
        self.mdlScaleRow:SetShowReset(panel:GetValue() != self.entity:GetModelScale(), "Scala modello", self.entity:GetModelScale())
    end)
    self.mdlScaleRow.OnResetClicked = function()
        self.mdlScaleRow:SetShowReset(false)
        self.mdlScaleSlider:SetValue(self.entity:GetModelScale())
    end

    self.npcHealthRow = self.npcSpawnerPanel:AddRow()
    self.npcHealthRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("HP NPC")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Se il valore è 0, verrà usata la vita default del mob.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)
    self.npcHealthLabel = self.npcHealthRow:AddLabel("Vita")
    self.npcHealthSlider = self.npcHealthRow:AddSlider(0, 0, 1000, function(panel)
        self.npcHealth = panel:GetValue()
        self.npcHealthRow:SetShowReset(panel:GetValue() != self.entity:GetNPCHealth(), "Vita", self.entity:GetNPCHealth())
    end)
    self.npcHealthRow.OnResetClicked = function()
        self.npcHealthRow:SetShowReset(false)
        self.npcHealthSlider:SetValue(self.entity:SetNPCHealth())
    end

    self.expRow = self.npcSpawnerPanel:AddRow()

    self.expRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Esperienza")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("L'esperienza che verrà data ai player che uccidono i mob.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.expLabel = self.expRow:AddLabel("Esperienza")
    self.expSlider = self.expRow:AddSlider(0, 0, 1000, function(panel)
        self.expValue = panel:GetValue()
        self.expRow:SetShowReset(panel:GetValue() != self.entity:GetExp(), "Esperienza", self.entity:GetExp())
    end)
    self.expRow.OnResetClicked = function()
        self.expRow:SetShowReset(false)
        self.expSlider:SetValue(self.entity:GetExp())
    end

    self.spawnMaterialRow = self.npcSpawnerPanel:AddRow()
    self.spawnMaterialLabel = self.spawnMaterialRow:AddLabel("Texture NPC")

    self.spawnMaterialRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Texture")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("La texture che assumeranno i mob. La texture ha la precedenza sul colore. Se la texture non esiste, verrà usata la texture di default. Puoi trovare i materiali disponibili nel menu di spawn.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.spawnMaterialText = self.spawnMaterialRow:Add("ixTextEntry")
    self.spawnMaterialText:Dock(RIGHT)
    self.spawnMaterialText:SetFont("ixMenuButtonFont")
    self.spawnMaterialText:SetBackgroundColor(derma.GetColor("DarkerBackground", self))
    self.spawnMaterialText:SetWide(self:GetWide() * 0.4)
    self.spawnMaterialText.OnChange = function(panel)
        print(panel:GetValue())
        self.spawnMaterialValue = panel:GetValue()
        self.spawnMaterialRow:SetShowReset(panel:GetValue() != self.entity:GetSpawnMaterial(), "Texture NPC", self.entity:GetSpawnMaterial())
    end
    self.spawnMaterialRow.OnResetClicked = function()
        self.spawnMaterialRow:SetShowReset(false)
        self.spawnMaterialText:SetValue(self.entity:GetSpawnMaterial())
    end

    self.colorRow = self.npcSpawnerPanel:AddRow()

    self.colorRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Colore NPC")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Il colore che assumeranno i mob. La texture ha la precedenza sul colore.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.colorLabel = self.colorRow:AddLabel("Colore")
    self.colorPicker = self.colorRow:Add("DColorMixer")
    self.colorPicker:Dock(RIGHT)
    self.colorPicker:SetWide(self:GetWide() * .4)
    self.colorPicker:SetPalette(true)
    self.colorPicker:SetAlphaBar(true)
    self.colorPicker:SetWangs(true)
    self.colorPicker:SetColor(Color(0, 0, 0, 255))
    self.colorPicker:ValueChanged()
    self.colorPicker.ValueChanged = function(newCol)
        self.colorValue = Color(newCol:GetColor().r, newCol:GetColor().g, newCol:GetColor().b)
        self.colorRow:SetBackgroundColor(Color(newCol:GetColor().r, newCol:GetColor().g, newCol:GetColor().b, 50))
    end

    self.spawnRadiusRow = self.npcSpawnerPanel:AddRow()

    self.spawnRadiusRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Raggio spawn")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Il raggio entro il quale spawnano i mob.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)
    

    self.spawnRadiusLabel = self.spawnRadiusRow:AddLabel("Raggio attivazione e spawn")
    self.spawnRadiusSlider = self.spawnRadiusRow:AddSlider(0, 50, 16383, function(panel)
        self.spawnRadiusValue = panel:GetValue()
        self.spawnRadiusRow:SetShowReset(panel:GetValue() != self.entity:GetNPCSpawnRadius(), "Raggio attivazione e spawn", self.entity:GetNPCSpawnRadius())
    end)
    self.spawnRadiusRow.OnResetClicked = function()
        self.spawnRadiusRow:SetShowReset(false)
        self.spawnRadiusSlider:SetValue(self.entity:GetNPCSpawnRadius())
    end


    self.maxNPCRow = self.npcSpawnerPanel:AddRow()

    self.maxNPCRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("NPC massimi")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Se il valore è 0, il massimo sarà infinito.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.maxNPCLabel = self.maxNPCRow:AddLabel("Conteggio Massimo")
    self.maxNPCSlider = self.maxNPCRow:AddSlider(0, 0, 255, function(panel)
        self.maxNPCValue = panel:GetValue()
        self.maxNPCRow:SetShowReset(panel:GetValue() != self.entity:GetMaxNPCs(), "Conteggio massimo", self.entity:GetMaxNPCs())
    end)
    self.maxNPCRow.OnResetClicked = function()
        self.maxNPCRow:SetShowReset(false)
        self.maxNPCSlider:SetValue(self.entity:GetMaxNPCs())
    end

    self.minPlayersRow = self.npcSpawnerPanel:AddRow()

    self.minPlayersRow:SetHelixTooltip(function(tooltip)
        local name = tooltip:AddRow("name")
        name:SetText("Giocatori richiesti")
        name:SetImportant()
        name:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Numero di giocatori richiesti per avviare lo spawner.")
        description:SizeToContents()

        tooltip:SizeToContents()
    end)

    self.minPlayersLabel = self.minPlayersRow:AddLabel("Giocatori richiesti")
    self.minPlayersSlider = self.minPlayersRow:AddSlider(1, 1, 50, function(panel)
        self.minPlayersValue = panel:GetValue()
        self.minPlayersRow:SetShowReset(panel:GetValue() != self.entity:GetMinPlayers(), "Giocatori richiesti", self.entity:GetMinPlayers())
    end)
    self.minPlayersRow.OnResetClicked = function()
        self.minPlayersRow:SetShowReset(false)
        self.minPlayersSlider:SetValue(self.entity:GetMinPlayers())
    end

    self.spawnIntervalRow = self.npcSpawnerPanel:AddRow()

    self.spawnIntervalRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Intervallo spawn")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Ogni quanto spawnano i mob quando un giocatore è nel raggio. Contato in secondi.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.spawnIntervalLabel = self.spawnIntervalRow:AddLabel("Intervallo cicli in secondi")
    self.spawnIntervalSlider = self.spawnIntervalRow:AddSlider(0, 1, 900, function(panel)
        self.spawnIntervalValue = panel:GetValue()
        self.spawnIntervalRow:SetShowReset(panel:GetValue() != self.entity:GetSpawnInterval(), "Intervallo cicli in secondi", self.entity:GetSpawnInterval())
    end)
    self.spawnIntervalRow.OnResetClicked = function()
        self.spawnIntervalRow:SetShowReset(false)
        self.spawnIntervalSlider:SetValue(self.entity:GetSpawnInterval())
    end

    self.spawnAmountRow = self.npcSpawnerPanel:AddRow()
    
    self.spawnAmountRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Spawn per ciclo")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Quanti mob spawnano insieme per ogni ciclo.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.spawnAmountLabel = self.spawnAmountRow:AddLabel("Spawn per ogni ciclo")
    self.spawnAmountSlider = self.spawnAmountRow:AddSlider(0, 1, 255, function(panel)
        self.spawnAmountValue = panel:GetValue()
        self.spawnAmountRow:SetShowReset(panel:GetValue() != self.entity:GetSpawnAmount(), "Spawn per ogni ciclo", self.entity:GetSpawnAmount())
    end)
    self.spawnAmountRow.OnResetClicked = function()
        self.spawnAmountRow:SetShowReset(false)
        self.spawnAmountSlider:SetValue(self.entity:GetSpawnAmount())
    end

    self.DespawnAmountRow = self.npcSpawnerPanel:AddRow()

    self.DespawnAmountRow:SetHelixTooltip(function(tooltip)
        local title = tooltip:AddRow("title")
        title:SetImportant()
        title:SetText("Intervallo despawn")
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Ogni quanto despawnano i mob quando non ci sono giocatori nel raggio. Contato in secondi.")
        description:SizeToContents()
        tooltip:SizeToContents()
    end)

    self.DespawnAmountLabel = self.DespawnAmountRow:AddLabel("Intervallo di despawn")
    self.DespawnAmountSlider = self.DespawnAmountRow:AddSlider(1, 1, 255, function(panel)
        self.DespawnAmountValue = panel:GetValue()
        self.DespawnAmountRow:SetShowReset(panel:GetValue() != self.entity:GetDespawnValue(), "Intervallo di despawn", self.entity:GetDespawnValue())
    end)
    self.DespawnAmountRow.OnResetClicked = function()
        self.DespawnAmountRow:SetShowReset(false)
        self.DespawnAmountSlider:SetValue(self.entity:GetDespawnValue())
    end



    self.saveButton = self.npcSpawnerPanel:Add("DButton")
    self.saveButton:SetText("Salva modifiche")
    self.saveButton:SetFont("ixMediumFont")
    self.saveButton:SizeToContents()
    self.saveButton:Dock(FILL)
    self.saveButton.DoClick = function()
        self:SaveChanges()
        self:Remove()
    end

end

function PANEL:OnRemove()

end

function PANEL:SaveChanges()
    --[[ if self.DespawnAmountValue < 10 then
        self.DespawnAmountValue = 10
    end ]]
    
    net.Start("npcSpawnerSaveChanges")
        net.WriteEntity(self.entity)
        net.WriteBool(self.enabledBoolValue)
        net.WriteString(self.npcClassValue)
        net.WriteString(tostring(self.spawnMaterialValue))
        net.WriteUInt(self.spawnRadiusValue, 14)
        net.WriteUInt(self.maxNPCValue, 8)
        net.WriteUInt(self.spawnIntervalValue, 16)
        net.WriteUInt(self.spawnAmountValue, 8)
        net.WriteUInt(self.DespawnAmountValue, 8)
        net.WriteString(tostring(self.expValue))
        net.WriteString(tostring(self.npcHealth))
        net.WriteInt(self.mdlScaleValue, 16)
        net.WriteColor(self.colorValue)
        net.WriteInt(self.minPlayersValue, 8)
    net.SendToServer()
end

vgui.Register("npcSpawner", PANEL, "DFrame")