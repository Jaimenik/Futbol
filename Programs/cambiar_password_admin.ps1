# Pide una contraseña nueva para el usuario admin de la web y la guarda cifrada
$sec = Read-Host -AsSecureString 'Nueva contrasena para admin'
$env:ADMIN_PWD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
Start-Process "$PSScriptRoot\CambiarPasswordAdmin64.exe" -WorkingDirectory $PSScriptRoot -Wait
Remove-Item Env:ADMIN_PWD
Get-Content "$PSScriptRoot\CambiarPasswordAdmin.txt"
