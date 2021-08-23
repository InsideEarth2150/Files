[byte[]]$bytes = Get-Content TheMoonProject.exe -Encoding Byte -Raw
,$bytes |Set-Content TheMoonProject.exe.orig -Encoding Byte

#vsync values
# off = 00
# on = 01

# =============== V-SYNC

$offset = 0x3701EC
$bytes[$offset] = 0x01

,$bytes |Set-Content TheMoonProject.exe -Encoding Byte