[byte[]]$bytes = Get-Content TheMoonProject.exe -Encoding Byte -Raw
,$bytes |Set-Content TheMoonProject.exe.orig -Encoding Byte

#titlebar fix
$offset = 0xA5DB
$bytes[$offset++] = 0x00
$bytes[$offset] = 0x86

$offset = 0xA5DF
$bytes[$offset++] = 0xE9
$bytes[$offset++] = 0x8C
$bytes[$offset++] = 0xB0
$bytes[$offset++] = 0x33
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xA6A5
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xA7A4
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0x345670
$bytes[$offset++] = 0x68
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x04
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0xFF
$bytes[$offset++] = 0x15
$bytes[$offset++] = 0xC8
$bytes[$offset++] = 0x62
$bytes[$offset++] = 0x74
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0xE9
$bytes[$offset++] = 0x67
$bytes[$offset++] = 0x4F
$bytes[$offset++] = 0xCC
$bytes[$offset] = 0xFF

#widescreen fix
$offset = 0x000FFE7A
$bytes[$offset++] = 0xB8
$bytes[$offset++] = 0x82
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