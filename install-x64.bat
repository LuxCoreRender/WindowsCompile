@Echo off

echo.
echo ****************************************************************************
echo * Install
echo ****************************************************************************

cd /d %LUX_WINDOWS_BUILD_ROOT%
cd ..

set OCL_VER=OpenCL
set REL_DIR=Release
call :Install64

cd /d %LUX_WINDOWS_BUILD_ROOT%
cd ..

set OCL_VER=NoOpenCL
set REL_DIR="\Release NoOpenCL"
call :Install64


goto Done

:: ------------------------------------------------------------------------------
:: This is a batch file equiv of a function
:Install64

set INSTALL_PATH="%CD%"\Dist\LuxRender_64_%OCL_VER%

IF NOT EXIST %INSTALL_PATH% (
	echo.
	echo making %INSTALL_PATH% directory
	mkdir %INSTALL_PATH%
)
IF NOT EXIST %INSTALL_PATH%\PyLux (
	mkdir %INSTALL_PATH%\PyLux
)
IF NOT EXIST %INSTALL_PATH%\PyLux\Python2 (
	mkdir %INSTALL_PATH%\PyLux\Python2
)
IF NOT EXIST %INSTALL_PATH%\PyLux\Python3 (
	mkdir %INSTALL_PATH%\PyLux\Python3
)
IF NOT EXIST %INSTALL_PATH%\imageformats (
	mkdir %INSTALL_PATH%\imageformats
)

cd %INSTALL_PATH%

echo Copying luxrender.exe
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\x64\%REL_DIR%\luxrender.exe .\ > nul
echo Copying luxconsole.exe
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\x64\%REL_DIR%\luxconsole.exe .\ > nul
echo Copying luxmerger.exe
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\x64\%REL_DIR%\luxmerger.exe .\ > nul
echo Copying Python 2 pylux.pyd
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\x64\%REL_DIR%\python2\pylux.pyd .\PyLux\Python2\ > nul
echo Copying Python 3 pylux.pyd
copy "%LUX_WINDOWS_BUILD_ROOT%"\Projects\luxrender\x64\%REL_DIR%\python3\pylux.pyd .\PyLux\Python3\ > nul

echo Copying Qt DLL's
copy "%LUX_X64_QT_ROOT%"\bin\QtCore4.dll . > nul
copy "%LUX_X64_QT_ROOT%"\bin\QtGui4.dll . > nul
:: copy "%LUX_X64_QT_ROOT%"\bin\QtOpenGL4.dll . > nul
copy "%LUX_X64_QT_ROOT%"\plugins\imageformats\qjpeg4.dll imageformats\ > nul
copy "%LUX_X64_QT_ROOT%"\plugins\imageformats\qtiff4.dll imageformats\ > nul

echo.
echo 64 bit %OCL_VER% binaries are available for use in
echo     %INSTALL_PATH%
echo.

goto :EOF
:: ------------------------------------------------------------------------------

:Done
cd /d %LUX_WINDOWS_BUILD_ROOT%