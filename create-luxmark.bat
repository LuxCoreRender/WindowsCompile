SET DIR=luxmark

:: Remove folder if it already exists
rd /s /q %DIR%

:: Create new folder for the binaries
md %DIR%

:: Copy binaries
xcopy .\Build_CMake\LuxMark\bin\Release\luxmark.exe %DIR%
xcopy .\Build_CMake\LuxCore\bin\Release\luxcoreui.exe %DIR%

:: Copy DLLs from WindowsCompileDeps (assuming it is in same folder as WindowsCompile)
xcopy ..\WindowsCompileDeps\x64\Release\lib\OpenImageDenoise.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\embree3.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbb.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\tbbmalloc.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\OpenImageIO_LuxCore.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\nvrtc64*.dll %DIR%
xcopy ..\WindowsCompileDeps\x64\Release\lib\nvrtc-builtins*.dll %DIR%
xcopy ..\WindowsCompileDeps\Qt5\bin\Qt5Core.dll %DIR%
xcopy ..\WindowsCompileDeps\Qt5\bin\Qt5Gui.dll %DIR%
xcopy ..\WindowsCompileDeps\Qt5\bin\Qt5Network.dll %DIR%
xcopy ..\WindowsCompileDeps\Qt5\bin\Qt5Widgets.dll %DIR%
xcopy /e /i ..\WindowsCompileDeps\Qt5\plugins\platforms %DIR%\platforms

:: Copy addition files from LuxMark (assuming it is in same folder as WindowsCompile)
xcopy ..\LuxMark\README.txt %DIR%
xcopy ..\LuxMark\COPYING.txt %DIR%
xcopy ..\LuxMark\AUTHORS.txt %DIR%
xcopy /e /i ..\LuxMark\scenes %DIR%\scenes
