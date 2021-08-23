[byte[]]$bytes = Get-Content Earth2150.exe -Encoding Byte -Raw
,$bytes |Set-Content Earth2150.exe.orig -Encoding Byte

#titlebar fix
$offset = 0xA7B1
$bytes[$offset++] = 0x68
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
$bytes[$offset] = 0x86

$offset = 0xA7BC
$bytes[$offset++] = 0xE9
$bytes[$offset++] = 0x6F
$bytes[$offset++] = 0x01
$bytes[$offset++] = 0x32
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xA825
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xA924
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0x32A930
$bytes[$offset++] = 0x68
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x04
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0xFF
$bytes[$offset++] = 0x15
$bytes[$offset++] = 0xAC
$bytes[$offset++] = 0xB2
$bytes[$offset++] = 0x72
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0xE9
$bytes[$offset++] = 0x84
$bytes[$offset++] = 0xFE
$bytes[$offset++] = 0xCD
$bytes[$offset] = 0xFF

,$bytes |Set-Content Earth2150.exe -Encoding Byte