<# 
.SYNOPSIS
    This script is a powershell script that will from a Iwar2 ini input file convert all input assignement (from VPC configuration tool)
	to the new buttons assignement set by virpil control configuration (alpha 0.1.0.0)
	A new file will be created after input conversion.

.DESCRIPTION
	The script support following configuration (default Virpil buttons assignement)
			Virpil Constellation Alpha prime joystick
			Virpil Constellation Alpha joystick
			Virpil CDT Aero Grip
			Virpil Warbrd-grip
			MongoosT-50CM2/3 Throttle (no shift and 5 way shift modifier)
	        MongoosT-50CM2/3 Throttle in 5 way shift modifier (master) with virpil control panel 2 (slave).
			VMAX Prime Throttle (no shift and 5 way shifter)
			Control Panel 1
			Control Panel 2
	
	Note : Control Panel 3 (standalone) has no buttons assignement change between VPC Configuration and Vpc control configurator.

.EXAMPLE
    .\virpil_iwar2_conversion.ps1  from powershell terminal
	or powershell.exe -ep bypass -file "x:\xxx\virpil_iwar2_conversion.ps1" from a cmd terminal.

        Launch the script
    1.0     02.05.2026  First version
.LINK
    https://github.com/Choum28/
 #>
 
Add- -AssemblyName System.Windows.Forms
Add- -AssemblyName System.Drawing


$VirpilDevice = @(
"Constellation ALPHA",
"Constellation ALPHA Prime",
"CDT Aero Grip",
"WarBRD Grip",
"MongoosT-50CM2/3 1 mode",
"MongoosT-50CM2/3 5 mode selection",
"MongoosT-50CM2/3 5 mode + Control panel 2 (slave)",
"VMAX Prime Throttle 1 mode",
"VMAX Prime Throttle 5 mode",
"Control Panel 1",
"Control Panel 2")
$jsnumberlist = @("Joystick1","Joystick2","Joystick3","Joystick4","Joystick5","Joystick6","Joystick7","Joystick8")

function add-Device { 
    param(
        [string]$csv,
        [string]$jsnumber
		)
		$d = @{
			csv = $csv
			jsnumber = $jsnumber
		}
		return $d
}

# --- Verrou anti-boucle ---
$global:lock = $false

# --- Fichier XML sélectionné ---
$global:fichierXML = $null

# --- Formulaire ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Star citizen button mapping updater for VIRPIL Controls Configurator"
$form.Size = New-Object System.Drawing.Size(550,500)
$form.StartPosition = "CenterScreen"

# --- ComboBox pour choisir le nombre de lignes ---
$comboNb = New-Object System.Windows.Forms.ComboBox
$comboNb.Location = New-Object System.Drawing.Point(310,15)
$comboNb.Size     = New-Object System.Drawing.Size(50,20)
$comboNb.DropDownStyle = "DropDownList"

$comboNb.Items.AddRange(1..8)
$comboNb.SelectedIndex = 0
$form.Controls.Add($comboNb)

# --- Titres des colonnes ---
$labelcomboNb = New-Object System.Windows.Forms.Label
$labelcomboNb.Location = New-Object System.Drawing.Point(150,15)
$labelcomboNb.Size = New-Object System.Drawing.Size(200,20)
$labelcomboNb.Text = "Number of virpil device"
$labelcomboNb.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelcomboNb)

# --- Bouton XML ---
$btnXML = New-Object System.Windows.Forms.Button
$btnXML.Text = "Select Ini file"
$btnXML.Location = New-Object System.Drawing.Point(10,420)
$btnXML.Size = New-Object System.Drawing.Size(150,25)
$form.Controls.Add($btnXML)

# --- Label XML ---
$labelXML = New-Object System.Windows.Forms.Label
$labelXML.Location = New-Object System.Drawing.Point(10,380)
$labelXML.Size = New-Object System.Drawing.Size(400,40)
$labelXML.Text = "Select an IWAR2 Ini input file and click generate to create a new file updated with buttons mapping of VIRPIL Controls Configurator"
$form.Controls.Add($labelXML)

$btnXML.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Fichiers Ini (*.ini)|*.ini"
    $dialog.Title = "Select Iwar2 input ini file"

    if ($dialog.ShowDialog() -eq "OK") {
        $global:fichierXML = $dialog.FileName
        $labelXML.Text = "Ini choice : $($global:fichierXML)"
    }
})

# --- Panel pour les lignes dynamiques ---
$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point(30,60)
$panel.Size     = New-Object System.Drawing.Size(580,350)
$panel.AutoScroll = $true
$form.Controls.Add($panel)

# --- Stockage des ComboBox ---
$global:comboNormales = @()
$global:comboUniques  = @()

# --- Titres des colonnes ---
$labelTitreNormal = New-Object System.Windows.Forms.Label
$labelTitreNormal.Location = New-Object System.Drawing.Point(50,45)
$labelTitreNormal.Size = New-Object System.Drawing.Size(200,20)
$labelTitreNormal.Text = "Virpil device selection"
$labelTitreNormal.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelTitreNormal)

$labelTitreUnique = New-Object System.Windows.Forms.Label
$labelTitreUnique.Location = New-Object System.Drawing.Point(380,45)
$labelTitreUnique.Size = New-Object System.Drawing.Size(200,20)
$labelTitreUnique.Text = "Joystick Instance"
$labelTitreUnique.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelTitreUnique)


# --- Fonction : créer les lignes ---
function Create-Lines($nb) {

    # --- Sauvegarde des anciennes valeurs ---
    $oldVirpilDevice = @()
    $oldjsnumberlist  = @()

    if ($global:comboNormales.Count -gt 0) {
        for ($i=0; $i -lt $global:comboNormales.Count; $i++) {
            $oldVirpilDevice += $global:comboNormales[$i].SelectedItem
            $oldjsnumberlist  += $global:comboUniques[$i].SelectedItem
        }
    }

    # --- Réinitialisation du panel ---
    $panel.Controls.Clear()
    $global:comboNormales = @()
    $global:comboUniques  = @()

    # --- Création des nouvelles lignes ---
    for ($i=0; $i -lt $nb; $i++) {

        $y = 10 + ($i * 40)

        # Combo normale
        $cbN = New-Object System.Windows.Forms.ComboBox
        $cbN.Location = New-Object System.Drawing.Point(10, $y)
        $cbN.Size     = New-Object System.Drawing.Size(300,20)
        $cbN.DropDownStyle = "DropDownList"
        $cbN.Items.AddRange($VirpilDevice)

        # Restauration si possible
        if ($i -lt $oldVirpilDevice.Count -and $oldVirpilDevice[$i]) {
            $cbN.SelectedItem = $oldVirpilDevice[$i]
        } else {
            $cbN.SelectedIndex = 0
        }

        # Combo unique
        $cbU = New-Object System.Windows.Forms.ComboBox
        $cbU.Location = New-Object System.Drawing.Point(350, $y)
        $cbU.Size     = New-Object System.Drawing.Size(120,20)
        $cbU.DropDownStyle = "DropDownList"
        $cbU.Items.AddRange($jsnumberlist)

        # Restauration si possible
        if ($i -lt $oldjsnumberlist.Count -and $oldjsnumberlist[$i]) {
            $cbU.SelectedItem = $oldjsnumberlist[$i]
        }

        # Gestion de l’unicité
        $cbU.Add_SelectedIndexChanged({
            if ($global:lock) { return }
            $global:lock = $true

            $used = $global:comboUniques | ForEach-Object { $_.SelectedItem }

            foreach ($cb in $global:comboUniques) {
                $current = $cb.SelectedItem
                $cb.Items.Clear()

                foreach ($v in $jsnumberlist) {
                    if ($v -eq $current -or $v -notin $used) {
                        $cb.Items.Add($v)
                    }
                }

                if ($current -and $cb.Items.Contains($current)) {
                    $cb.SelectedItem = $current
                } else {
                    $cb.SelectedIndex = -1
                }
            }

            $global:lock = $false
        })

        # Ajout au panel
        $panel.Controls.Add($cbN)
        $panel.Controls.Add($cbU)

        # Stockage
        $global:comboNormales += $cbN
        $global:comboUniques  += $cbU
    }

    # --- Mise à jour finale de l’unicité ---
    $global:lock = $true
    $used = $global:comboUniques | ForEach-Object { $_.SelectedItem }

    foreach ($cb in $global:comboUniques) {
        $current = $cb.SelectedItem
        $cb.Items.Clear()

        foreach ($v in $jsnumberlist) {
            if ($v -eq $current -or $v -notin $used) { 
                $cb.Items.Add($v) | Out-Null
            }
        }

        if ($current -and $cb.Items.Contains($current)) {
            $cb.SelectedItem = $current
        } else {
            $cb.SelectedIndex = -1
        }
    }
    $global:lock = $false
}

# --- Création initiale ---
Create-Lines 1

# --- Mise à jour du nombre de lignes ---
$comboNb.Add_SelectedIndexChanged({
    Create-Lines([int]$comboNb.SelectedItem)
})

# --- Bouton OK ---
$btnOK = New-Object System.Windows.Forms.Button
$btnOK.Text = "Generate"
$btnOK.Location = New-Object System.Drawing.Point(400,420)
$btnOK.Add_Click({
	$device = @()
    # Vérification des combobox normales
    foreach ($cb in $global:comboNormales) {
        if ($cb.SelectedIndex -lt 0) {
            [System.Windows.Forms.MessageBox]::Show("Please set correct value in all device selection.")
            return
        }
    }

    # Vérification des combobox uniques
    foreach ($cb in $global:comboUniques) {
        if ($cb.SelectedIndex -lt 0) {
            [System.Windows.Forms.MessageBox]::Show("Please set correct value in all Js number.")
            return
        }
    }

    # Vérification du fichier XML (optionnel)
    if (-not $global:fichierXML) {
        [System.Windows.Forms.MessageBox]::Show("Please select an INI input file before clicking ok.")
        return
    }
	
	# --- Sélection du fichier XML d'export ---
	$saveDialog = New-Object System.Windows.Forms.SaveFileDialog
	$saveDialog.Filter = "Fichier Ini (*.ini)|*.ini"
	$saveDialog.Title = "Where do you want to save new Iwar2 ini input file?"
	$saveDialog.FileName = "export.ini"

	# Ouvrir dans le même dossier que le fichier d'entrée
	if ($global:fichierXML) {
		$saveDialog.InitialDirectory = [System.IO.Path]::GetDirectoryName($global:fichierXML)
	}
	if ($saveDialog.ShowDialog() -ne "OK") {
		[System.Windows.Forms.MessageBox]::Show("Export annulé.")
		$form.Close()
		return
	}
	# Vérifier que l'utilisateur n'a pas choisi le même fichier
	if ($saveDialog.FileName -eq $global:fichierXML) {
		[System.Windows.Forms.MessageBox]::Show("Source input file cannot be overwritten. Choose another name.")
		return
	} 

	# Stockage du chemin choisi
	$global:fichierExportXML = $saveDialog.FileName


    for ($i=0; $i -lt $global:comboNormales.Count; $i++) {
		$jsnumber = $global:comboUniques[$i].SelectedItem

		switch ($global:comboNormales[$i].SelectedItem) {	
			"Constellation ALPHA" { $csv = ".\Mapping\Const_alpha.csv" }
			"Constellation ALPHA Prime" { $csv = ".\Mapping\Const_alpha_prime.csv" }
			"CDT Aero Grip"  { $csv = ".\Mapping\cdt-aero.csv" }
			"WarBRD Grip"  { $csv = ".\Mapping\Warbrd-grip.csv" }
			"MongoosT-50CM2/3 1 mode" { $csv = ".\Mapping\ThrottleCM2-3.csv"}
			"MongoosT-50CM2/3 5 mode selection" { $csv = ".\Mapping\ThrottleCM2-3_5m.csv"}
			"MongoosT-50CM2/3 5 mode + Control panel 2 (slave)" { $csv = ".\Mapping\ThrottleCM2-3_5m_SlaveCP2.csv" }
			"VMAX Prime Throttle 1 mode" { $csv = ".\Mapping\VMAX Prime Throttle.csv" }
			"VMAX Prime Throttle 5 mode" { $csv = ".\Mapping\VMAX Prime Throttle-5m.csv" }
			"Control Panel 1" { $csv = ".\Mapping\CP1.csv" }
			"Control Panel 2" { $csv = ".\Mapping\CP2.csv" }
		}
		$device+=add-Device -csv $csv -jsNumber $jsnumber
	}
	foreach ($virpil in $device) {
		$mapping += Import-Csv -Path $virpil.csv | ForEach-Object {
				# OLD
			if ($_.OLD -match '^\d+$') {
				$_.OLD = "$($virpil.jsNumber), JoyButton$($_.OLD)"
			} else {
				$_.OLD = "$($virpil.jsNumber), Joy$($_.OLD.ToUpper())Axis"
			}
			
			# NEW
			if ($_.NEW -match '^\d+$') {
				$_.NEW = "$($virpil.jsNumber), JoyButton$($_.NEW)"
			} else {
				$_.NEW = "$($virpil.jsNumber), Joy$($_.NEW.ToUpper())Axis"
			}
			$_
		}
	}		
	#for debug
	#$mapping | Out-GridView
	#If overwrite, delete source file	
	if (Test-Path $fichierExportXML) {
		Remove-Item $fichierExportXML
	}
		$found = 0
		$linenumber = 0

	Get-Content $global:fichierXML | ForEach-Object {
		$line = $_
		$linenumber = $linenumber +1
		foreach ($row in $mapping) {
			$old = $row.OLD
			$new = $row.NEW
			if ($line -match $old) {
				$found =1
				Add-Content -Path $global:fichierExportXML -Value ($line -replace $old, $new)
				$line = $_
			}
		}
		if ($found -eq 0) {
			Add-Content -Path $global:fichierExportXML -Value $line
		}
		$found = 0
	}
	[System.Windows.Forms.MessageBox]::Show("New input file created in $($global:fichierExportXML)")
	$form.Close()
	$form.Dispose()
})

$form.Controls.Add($btnOK)

# --- Display ---
[void]$form.ShowDialog()
