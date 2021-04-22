SET DIR=luxcorerender

:: Remove folder if it already exists
rd /s /q %DIR%

:: Create new folder for the binaries
md %DIR%

:: Pack pyluxcoretools
cd Build_CMake\LuxCore
PyInstaller ..\..\..\LuxCore\samples\pyluxcoretool\pyluxcoretool.win.spec
cd ..\..

:: Copy pyluxcoretools binaries
xcopy .\Build_CMake\LuxCore\dist\pyluxcoretool.exe %DIR%

:: Copy binaries
xcopy .\Build_CMake\LuxCore\bin\Release\luxcoreui.exe %DIR%
xcopy .\Build_CMake\LuxCore\lib\Release\pyluxcore.pyd %DIR%
xcopy .\Build_CMake\LuxCore\lib\pyluxcoretools.zip %DIR%

:: Copy DLLs from WindowsCompileDeps (assuming it is in same folder as WindowsCompile)
xcopy ..\WindowsCompileDeps\x64\Release\lib\OpenImageDenoise.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\oidnDenoise.exe %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\embree3.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbb12.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbb.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbbmalloc.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\nvrtc64*.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\nvrtc-builtins*.dll %DIR%

:: Copy additional files from LuxCore (assuming it is in same folder as WindowsCompile)
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
