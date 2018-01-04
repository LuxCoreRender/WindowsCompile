SET DIR=luxcorerender

:: Remove folder if it already exists
rd /s /q %DIR%

:: Create new folder for the binaries
md %DIR%

:: Copy binaries
xcopy .\Build_CMake\LuxCore\bin\Release\luxcoreui.exe %DIR%
xcopy .\Build_CMake\LuxCore\lib\Release\pyluxcore.pyd %DIR%

:: Copy DLLs from WindowsCompileDeps (assuming it is in same folder as WindowsCompile)
xcopy ..\WindowsCompileDeps\x64\Release\lib\embree.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbb.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\OpenImageIO.dll %DIR%

:: Copy addition files from LuxCore (assuming it is in same folder as WindowsCompile)
xcopy ..\LuxCore\README.md %DIR%
xcopy ..\LuxCore\COPYING.txt %DIR%
xcopy ..\LuxCore\AUTHORS.txt %DIR%
md %DIR%\scenes
md %DIR%\scenes\cornell
xcopy ..\LuxCore\scenes\cornell\cornell.cfg %DIR%\scenes\cornell
xcopy ..\LuxCore\scenes\cornell\cornell.scn %DIR%\scenes\cornell
xcopy ..\LuxCore\scenes\cornell\Khaki.ply %DIR%\scenes\cornell
xcopy ..\LuxCore\scenes\cornell\HalveRed.ply %DIR%\scenes\cornell
xcopy ..\LuxCore\scenes\cornell\DarkGreen.ply %DIR%\scenes\cornell
xcopy ..\LuxCore\scenes\cornell\Grey.ply %DIR%\scenes\cornell
