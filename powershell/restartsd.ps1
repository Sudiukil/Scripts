# Stops the StreamDeck software and restarts it

Get-Process -name "*streamdeck*" | Stop-Process
Get-Process -name "*node*" | Stop-Process
Start-Sleep 3
Start-Process "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"