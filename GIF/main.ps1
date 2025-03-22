Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Téléchargement du GIF temporaire
$url = "https://media3.giphy.com/media/tJqyalvo9ahykfykAj/giphy.gif"
$gifPath = "$env:temp/g.gif"
Invoke-WebRequest -Uri $url -OutFile $gifPath
$ErrorActionPreference = 'Stop'

# Fonction pour afficher le GIF en boucle et empêcher sa fermeture
function Show-Gif {
    $form = New-Object System.Windows.Forms.Form
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $gifImage = [System.Drawing.Image]::FromFile($gifPath)

    $form.FormBorderStyle = 'None'    # Pas de bordure
    $form.ShowInTaskbar = $false      # Ne pas afficher dans la barre des tâches
    $form.BackColor = [System.Drawing.Color]::Black
    $form.Size = New-Object System.Drawing.Size(490, 300)
    $form.StartPosition = 'CenterScreen'
    $form.TopMost = $true             # Toujours au premier plan

    # Empêcher la fermeture avec ALT+F4
    $form.Add_FormClosing({ $_.Cancel = $true })

    # Configuration de l'affichage du GIF
    $pictureBox.Size = $form.Size
    $pictureBox.Image = $gifImage

    # Utilisation de ImageAnimator pour bien animer le GIF
    [System.Drawing.ImageAnimator]::Animate($gifImage, { $pictureBox.Invalidate() })

    $form.Controls.Add($pictureBox)
    
    # Affichage du formulaire
    $form.ShowDialog()
}

# Lancer le GIF immédiatement
Show-Gif
