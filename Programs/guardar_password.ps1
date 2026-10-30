# Pide la contraseña de root de MySQL y la guarda cifrada en DfConnId.ini
$sec = Read-Host -AsSecureString 'Contrasena de root de MySQL'
$env:FUTBOL_PWD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$p = Start-Process "$PSScriptRoot\GuardarPassword64.exe" -WorkingDirectory $PSScriptRoot -PassThru -Wait
Remove-Item Env:FUTBOL_PWD
Get-Content "$PSScriptRoot\GuardarPassword.txt"
