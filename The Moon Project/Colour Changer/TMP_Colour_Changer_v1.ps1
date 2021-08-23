[byte[]]$bytes = Get-Content TheMoonProject.exe -Encoding Byte -Raw
,$bytes |Set-Content TheMoonProject.exe.orig -Encoding Byte

$Player1R = D9 
$Player1G = 10
$Player1B = 0B
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144
$Player1 = 144

#Player 1 fix
$offset = 0x37107C
$bytes[$offset++] = $Player1R
$bytes[$offset++] = $Player1G
$bytes[$offset] = $Player1B

,$bytes |Set-Content TheMoonProject.exe -Encoding Byte