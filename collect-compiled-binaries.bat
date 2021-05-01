SET DIR=compiled_binaries

:: Remove folder if it already exists
rd /s /q %DIR%

:: Create new folder for the binaries
md %DIR%

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
