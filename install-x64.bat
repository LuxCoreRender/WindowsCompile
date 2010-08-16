@Echo off

echo.
echo ****************************************************************************
echo * Install
echo ****************************************************************************

cd /d %BUILD_PATH%
cd ..

IF NOT EXIST .\Dist\64 (
    echo.
    echo making Dist\64 directory
    mkdir Dist\64
)

cd Dist\64
set INSTALL_PATH="%CD%"

copy %BUILD_PATH%\Projects\x64\LuxRender\luxrender.exe luxrender.exe
copy %BUILD_PATH%\Projects\x64\Console\luxconsole.exe luxconsole.exe
copy %BUILD_PATH%\Projects\x64\LuxMerge\luxmerger.exe luxmerger.exe
copy %LUX_X64_QT_ROOT%\bin\QtCore4.dll QtCore4.dll
copy %LUX_X64_QT_ROOT%\bin\QtGui4.dll QtGui4.dll
copy %LUX_X64_QT_ROOT%\bin\QtOpenGL4.dll QtOpenGL4.dll

cd /d %BUILD_PATH%

echo.
echo 64 bit binaries are availabe for use in %INSTALL_PATH%
echo.