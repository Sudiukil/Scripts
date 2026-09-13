# Script to set all monitors to a white fullscreen overlay
# Who needs a desk lamp when you have a shitload of monitors?

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$forms = @()
$allClosed = $false

# Create a form for each monitor
[System.Windows.Forms.Screen]::AllScreens | ForEach-Object {
  $form = New-Object System.Windows.Forms.Form
  $form.BackColor = [System.Drawing.Color]::White
  $form.ControlBox = $false
  $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
  $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
  $form.TopMost = $true
    
  # Position form on this monitor
  $form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
  $form.Left = $_.Bounds.Left
  $form.Top = $_.Bounds.Top
  $form.Width = $_.Bounds.Width
  $form.Height = $_.Bounds.Height
    
  # Close all forms on any key press or mouse click
  $closeAll = {
    if ($allClosed -eq $false) {
      $allClosed = $true
      $forms | ForEach-Object { $_.Close() }
      [System.Windows.Forms.Application]::Exit()
    }
  }
    
  $form.Add_KeyDown($closeAll)
  $form.Add_MouseClick($closeAll)
    
  $forms += $form
  $form.Show()
}

[System.Windows.Forms.Application]::Run()