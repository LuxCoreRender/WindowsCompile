@Echo off

echo.
echo ****************************************************************************
echo * Install
echo ****************************************************************************

cd /d %LUX_WINDOWS_BUILD_ROOT%
cd ..

set SSE_VER=SSE1
set REL_DIR="\Release SSE1"
call :Install32

cd /d %LUX_WINDOWS_BUILD_ROOT%
cd ..

set SSE_VER=SSE2
set REL_DIR=Release
call :Install32

goto Done

:: ------------------------------------------------------------------------------
:: This is a batch file equiv of a function
:Install32

set INSTALL_PATH="%CD%"\Dist\32\%SSE_VER%

IF NOT EXIST %INSTALL_PATH% (
	echo.
	echo making %INSTALL_PATH% directory
	mkdir %INSTALL_PATH%
)
IF NOT EXIST %INSTALL_PATH%\Python2 (
	mkdir %INSTALL_PATH%\Python2
)
IF NOT EXIST %INSTALL_PATH%\Python3 (
	mkdir %INSTALL_PATH%\Python3
)

cd %INSTALL_PATH%

echo Copying luxrender.exe
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\Win32\%SSE_VER%\%REL_DIR%\luxrender.exe .\ > nul
echo Copying luxconsole.exe
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\Win32\%SSE_VER%\%REL_DIR%\luxconsole.exe .\ > nul
echo Copying luxmerger.exe
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\Win32\%SSE_VER%\%REL_DIR%\luxmerger.exe .\ > nul
echo Copying Python 2 pylux.pyd
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\Win32\%SSE_VER%\%REL_DIR%\python2\pylux.pyd Python2\ > nul
echo Copying Python 3 pylux.pyd
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\Win32\%SSE_VER%\%REL_DIR%\python3\pylux.pyd Python3\ > nul

echo Copying Qt DLL's
copy "%LUX_X86_QT_ROOT%"\bin\QtCore4.dll . > nul
copy "%LUX_X86_QT_ROOT%"\bin\QtGui4.dll . > nul
:: copy "%LUX_X86_QT_ROOT%"\bin\QtOpenGL4.dll . > nul

echo Copying Visual C++ CRT DLL's
copy "%VCINSTALLDIR%"\redist\x86\Microsoft.VC90.CRT\Microsoft.VC90.CRT.manifest . > nul
copy "%VCINSTALLDIR%"\redist\x86\Microsoft.VC90.CRT\msvcm90.dll . > nul
copy "%VCINSTALLDIR%"\redist\x86\Microsoft.VC90.CRT\msvcp90.dll . > nul
copy "%VCINSTALLDIR%"\redist\x86\Microsoft.VC90.CRT\msvcr90.dll . > nul

echo.
echo 32 bit %SSE_VER% binaries are available for use in:
echo     %INSTALL_PATH%
echo.

goto :EOF
:: ------------------------------------------------------------------------------

:Done
cd /d %LUX_WINDOWS_BUILD_ROOT%