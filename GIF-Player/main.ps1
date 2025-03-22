Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Téléchargement du GIF temporaire
$url = "https://media3.giphy.com/media/tJqyalvo9ahykfykAj/giphy.gif"
$gifPath = "$env:temp/g.gif"
iwr -Uri $url -OutFile $gifPath
$ErrorActionPreference = 'Stop'

# Création de l'icône pour le Tray
$trayIcon = New-Object System.Windows.Forms.NotifyIcon
$trayIcon.Icon = [System.Drawing.SystemIcons]::Information
$trayIcon.Visible = $true
$trayIcon.Text = "GIF en arrière-plan"

# Création du menu contextuel (clic droit sur l'icône)
$menu = New-Object System.Windows.Forms.ContextMenu
$exitItem = New-Object System.Windows.Forms.MenuItem "Quitter"
$menu.MenuItems.Add($exitItem)
$trayIcon.ContextMenu = $menu

# Fonction pour afficher le GIF
function Show-Gif {
    $form = New-Object System.Windows.Forms.Form
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $timer = New-Object System.Windows.Forms.Timer

    $form.FormBorderStyle = 'None'
    $form.ShowInTaskbar = $false
    $form.BackColor = [System.Drawing.Color]::Black
    $form.Size = New-Object System.Drawing.Size(490, 300)
    $form.StartPosition = 'CenterScreen'
    $form.TopMost = $true

    $pictureBox.Size = $form.Size
    $pictureBox.Image = [System.Drawing.Image]::FromFile($gifPath)

    # Animation du GIF
    $timer.Interval = 50
    $timer.Add_Tick({
        $pictureBox.Image.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Time, $timer.Tag)
        $pictureBox.Refresh()
        $timer.Tag = ($timer.Tag + 1) % $pictureBox.Image.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Time)
    })
    $timer.Tag = 0

    $form.Controls.Add($pictureBox)
    $form.Add_Shown({ $timer.Start() })
    
    # Fermer après 5 secondes
    Start-Sleep -Seconds 5
    $form.Close()
    $form.Dispose()
}

# Clic gauche sur l'icône pour afficher le GIF
$trayIcon.Add_MouseClick({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        Show-Gif
    }
})

# Clic droit sur "Quitter" pour fermer
$exitItem.Add_Click({
    $trayIcon.Dispose()
    Remove-Item $gifPath -ErrorAction SilentlyContinue
    exit
})

# Exécution en arrière-plan
[System.Windows.Forms.Application]::Run()
