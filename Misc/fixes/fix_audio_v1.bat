@echo off

:: 1. Create the folders
mkdir "Original"
mkdir "output"

:: 2. Re-encode the files into the temporary output folder
for %%f in (*.mp2) do (
    ffmpeg -i "%%f" -c:a mp2 -b:a 192k "output\%%f"
)

:: 3. Move the ORIGINAL files into the "Original" folder
move *.mp2 "Original\"

:: 4. Move the FIXED files from output back to the root
move "output\*.mp2" ".\"

:: 5. Clean up the empty output folder
rd "output"

echo Task Complete. Originals are in the 'Original' folder.
pause