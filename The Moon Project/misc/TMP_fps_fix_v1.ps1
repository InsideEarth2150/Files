[byte[]]$bytes = Get-Content TheMoonProject.exe -Encoding Byte -Raw
,$bytes |Set-Content TheMoonProject.exe.orig -Encoding Byte

#FPS default is 14
#60 => 3C 00 00 00
#120 => 78 00 00 00
#240 => F0 00 00 00
#vsync needs to be off
# off = 00
# on = 01

# =============== FPS

$offset = 0x35ED2C
$bytes[$offset] = 0xF0

# =============== V-SYNC

$offset = 0x3701EC
$bytes[$offset] = 0x00

,$bytes |Set-Content TheMoonProject.exe -Encoding Byte