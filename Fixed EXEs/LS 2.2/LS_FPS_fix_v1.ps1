[byte[]]$bytes = Get-Content LostSouls.exe -Encoding Byte -Raw
,$bytes |Set-Content LostSouls.exe.orig -Encoding Byte

#FPS default is 14
#60 => 3C 00 00 00
#120 => 78 00 00 00
#240 => F0 00 00 00
#vsync needs to be off
# off = 00
# on = 01

# =============== FPS

$offset = 0x284596
$bytes[$offset] = 0x3C

# =============== V-SYNC

$offset = 0x3701DC
$bytes[$offset] = 0x00

,$bytes |Set-Content LostSouls.exe -Encoding Byte