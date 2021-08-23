[byte[]]$bytes = Get-Content TheMoonProject.exe -Encoding Byte -Raw
,$bytes |Set-Content TheMoonProject.exe.orig -Encoding Byte

# =============== Mouse Fix

$offset = 0x2845D6
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

,$bytes |Set-Content TheMoonProject.exe -Encoding Byte