[byte[]]$bytes = Get-Content Earth2150.exe -Encoding Byte -Raw
,$bytes |Set-Content Earth2150.exe.orig -Encoding Byte

#default for 16:9 is 180, pick 0-255
#138 is the lowest value for 1920x1080 that allows 3 buttons vertically in the bottom panel
#180 is the lowest value for 1920x1080 that allows 4 buttons vertically in the bottom panel
$bottomPanelHeightFactor = 180
#default for 16:9 is 240, pick 0-255
#for 1920x1080, and value of $bottomPanelHeightFactor == 180, 160 is the heighest value that dispalys 4 buildings/units vertically in the side panel
#you won't get 5 boxes unless you minimize bottom panel
$rightPanelHeightFactor = 144

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

# =============== widescreen fixes

# 1. Constructor F1 fix
$offset = 0x000FF471
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

$offset = 0x00253389
$bytes[$offset++] = 0x8B
$bytes[$offset++] = 0x77
$bytes[$offset++] = 0x54
$bytes[$offset++] = 0x89
$bytes[$offset++] = 0x75
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

$offset = 0x00253480
$bytes[$offset++] = 0xA1
$bytes[$offset++] = 0xEC
$bytes[$offset++] = 0xD2
$bytes[$offset++] = 0xA3
$bytes[$offset++] = 0x00
$bytes[$offset++] = 0x8B
$bytes[$offset++] = 0x78
$bytes[$offset++] = 0x54
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

,$bytes |Set-Content Earth2150.exe -Encoding Byte