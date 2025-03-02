# Clears the Windows icon cache to solve icon display issues
# Run as administrator

# Kill explorer (using Stop-Process restarts automatically so fuck this)
taskkill /f /im explorer.exe

# Clear the icons and thumbnails cache (the hard way)
Remove-Item $env:LOCALAPPDATA\IconCache.db
Remove-Item $env:LOCALAPPDATA\Microsoft\Windows\Explorer\*cache*.db

# Wait and restart explorer
Start-Sleep 3
Start-Process explorer.exe

# Optionnal: get mad because it doesn't work for some reason