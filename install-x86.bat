@Echo off

echo.
echo ****************************************************************************
echo * Install
echo ****************************************************************************

cd /d %BUILD_PATH%
cd ..

IF NOT EXIST .\Dist\32 (
    echo.
    echo making Dist directory
    mkdir Dist\32
)

cd Dist\32
set INSTALL_PATH="%CD%"

copy %BUILD_PATH%\Projects\Win32\LuxRender\luxrender.exe luxrender.exe
copy %BUILD_PATH%\Projects\win32\Console\luxconsole.exe luxconsole.exe
copy %BUILD_PATH%\Projects\Win32\LuxMerge\luxmerger.exe luxmerger.exe
copy %LUX_X86_QT_ROOT%\bin\QtCore4.dll QtCore4.dll
copy %LUX_X86_QT_ROOT%\bin\QtGui4.dll QtGui4.dll
copy %LUX_X86_QT_ROOT%\bin\QtOpenGL4.dll QtOpenGL4.dll

cd /d %BUILD_PATH%

echo.
echo 32 bit binaries are availabe for use in %INSTALL_PATH%
echo.