SET DIR=luxcorerender

:: Remove folder if it already exists
rd /s /q %DIR%

:: Create new folder for the binaries
md %DIR%

:: Copy binaries
md %DIR%\bin
xcopy .\Build_CMake\LuxCore\bin\Release\luxcoreui.exe %DIR%\bin
xcopy .\Build_CMake\LuxCore\bin\Release\luxcoreconsole.exe %DIR%\bin
xcopy .\Build_CMake\LuxCore\bin\Release\luxcoredemo.exe %DIR%\bin
xcopy .\Build_CMake\LuxCore\bin\Release\luxcorescenedemo.exe %DIR%\bin

md %DIR%\lib
xcopy .\Build_CMake\LuxCore\bin\Release\luxcore.dll %DIR%\lib
xcopy .\Build_CMake\LuxCore\lib\Release\luxcore.lib %DIR%\lib
xcopy .\Build_CMake\LuxCore\lib\Release\pyluxcore.pyd %DIR%\lib

:: Copy DLLs from WindowsCompileDeps (assuming it is in same folder as WindowsCompile)
xcopy ..\WindowsCompileDeps\x64\Release\lib\OpenImageDenoise.dll %DIR%\lib
xcopy ..\WindowsCompileDeps\x64\Release\lib\oidnDenoise.exe %DIR%\lib
xcopy ..\WindowsCompileDeps\x64\Release\lib\embree3.dll %DIR%\lib
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbb12.dll %DIR%\lib
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbb.dll %DIR%\lib
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbbmalloc.dll %DIR%\lib
xcopy ..\WindowsCompileDeps\x64\Release\lib\nvrtc64*.dll %DIR%\lib
xcopy ..\WindowsCompileDeps\x64\Release\lib\nvrtc-builtins*.dll %DIR%\lib

:: Copy additional files from LuxCore (assuming it is in same folder as WindowsCompile)
xcopy ..\LuxCore\README.md %DIR%
xcopy ..\LuxCore\COPYING.txt %DIR%
xcopy ..\LuxCore\AUTHORS.txt %DIR%
xcopy ..\LuxCore\sdk\CMakeLists.txt %DIR%
md %DIR%\cmake
xcopy ..\LuxCore\cmake\Packages\FindOpenCL.cmake %DIR%\cmake

md %DIR%\include
md %DIR%\include\luxrays
md %DIR%\include\luxrays\utils
xcopy /E /I ..\LuxCore\include\luxrays\utils\cyhair %DIR%\include\luxrays\utils\cyhair
xcopy ..\LuxCore\include\luxrays\utils\exportdefs.h %DIR%\include\luxrays\utils
xcopy ..\LuxCore\include\luxrays\utils\ocl.h %DIR%\include\luxrays\utils
xcopy ..\LuxCore\include\luxrays\utils\oclerror.h %DIR%\include\luxrays\utils
xcopy ..\LuxCore\include\luxrays\utils\properties.h %DIR%\include\luxrays\utils
xcopy ..\LuxCore\include\luxrays\utils\utils.h %DIR%\include\luxrays\utils

md %DIR%\include\luxcore
xcopy Build_CMake\LuxCore\generated\include\luxcore\cfg.h %DIR%\include\luxcore
xcopy ..\LuxCore\include\luxcore\luxcore.h %DIR%\include\luxcore

xcopy /E /I ..\LuxCore\samples %DIR%\samples
xcopy /E /I ..\LuxCore\scenes %DIR%\scenes
