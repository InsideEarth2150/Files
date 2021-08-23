[byte[]]$bytes = Get-Content LostSouls.exe -Encoding Byte -Raw
,$bytes |Set-Content LostSouls.exe.orig -Encoding Byte

$offset = 0xA610
$bytes[$offset++] = 0x00
$bytes[$offset] = 0x86

$offset = 0xA92F
$bytes[$offset++] = 0xE9
$bytes[$offset++] = 0x8C
$bytes[$offset++] = 0xB0
$bytes[$offset++] = 0x33
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xA9F5
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xAAF4
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0x3459C0
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

,$bytes |Set-Content LostSouls.exe -Encoding Byte