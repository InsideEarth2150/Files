[byte[]]$bytes = Get-Content LostSouls.exe -Encoding Byte -Raw
,$bytes |Set-Content LostSouls.exe.orig -Encoding Byte

#default for 16:9 is 180, pick 0-255
#138 is the lowest value for 1920x1080 that allows 3 buttons vertically in the bottom panel
#180 is the lowest value for 1920x1080 that allows 4 buttons vertically in the bottom panel
$bottomPanelHeightFactor = 180
#default for 16:9 is 240, pick 0-255
#for 1920x1080, and value of $bottomPanelHeightFactor == 180, 160 is the heighest value that dispalys 4 buildings/units vertically in the side panel
#you won't get 5 boxes unless you minimize bottom panel
$rightPanelHeightFactor = 144

#titlebar fix
$offset = 0xA5DB + 0x350
$bytes[$offset++] = 0x00
$bytes[$offset] = 0x86

$offset = 0xA5DF + 0x350
$bytes[$offset++] = 0xE9
$bytes[$offset++] = 0x8C
$bytes[$offset++] = 0xB0
$bytes[$offset++] = 0x33
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xA6A5 + 0x350
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0xA7A4 + 0x350
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset++] = 0x90
$bytes[$offset] = 0x90

$offset = 0x345670 + 0x350
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

# =============== widescreen fixes

# 1. Constructor F1 fix
$offset = 0x000FFF7A
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

#2. Side panel size fix

$offset = 0x0026331C
$bytes[$offset++] = 0x8B
$bytes[$offset++] = 0x43
$bytes[$offset++] = 0x54
$bytes[$offset++] = 0x89
$bytes[$offset++] = 0x45
$bytes[$offset++] = 0x08
$bytes[$offset++] = 0xB8
$bytes[$offset++] = $rightPanelHeightFactor
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
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

#3. Bottom panel size adjustment

$offset = 0x0026342E
$bytes[$offset++] = 0x8B
$bytes[$offset++] = 0x4F
$bytes[$offset++] = 0x0C
$bytes[$offset++] = 0xB8
$bytes[$offset++] = $bottomPanelHeightFactor
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x00
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

,$bytes |Set-Content LostSouls.exe -Encoding Byte