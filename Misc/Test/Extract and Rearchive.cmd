SET VERSION=2211
"C:\Program Files\7-Zip\7z.exe" x LS.zip
"C:\Program Files\7-Zip\7z.exe" x TMP.zip
"C:\Program Files\7-Zip\7z.exe" a -tzip ls_de_21-%VERSION%.zip ls_de_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip ls_en_21-%VERSION%.zip ls_en_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip ls_pl_21-%VERSION%.zip ls_pl_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip ls_ru_21-%VERSION%.zip ls_ru_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip ls_fr_21-%VERSION%.zip ls_fr_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip tmp_de_21-%VERSION%.zip tmp_de_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip tmp_en_21-%VERSION%.zip tmp_en_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip tmp_pl_21-%VERSION%.zip tmp_pl_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip tmp_ru_21-%VERSION%.zip tmp_ru_21-%VERSION%
"C:\Program Files\7-Zip\7z.exe" a -tzip tmp_fr_21-%VERSION%.zip tmp_fr_21-%VERSION%
RMDIR /s /q ls_de_21-%VERSION%
RMDIR /s /q ls_en_21-%VERSION%
RMDIR /s /q ls_pl_21-%VERSION%
RMDIR /s /q ls_ru_21-%VERSION%
RMDIR /s /q ls_fr_21-%VERSION%
RMDIR /s /q tmp_de_21-%VERSION%
RMDIR /s /q tmp_en_21-%VERSION%
RMDIR /s /q tmp_pl_21-%VERSION%
RMDIR /s /q tmp_ru_21-%VERSION%
RMDIR /s /q tmp_fr_21-%VERSION%
:: DEL LS.zip
:: DEL TMP.zip