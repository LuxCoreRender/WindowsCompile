@Echo off

echo.
echo **************************************************************************
echo * Checking environment                                                   *
echo **************************************************************************

IF EXIST build-vars.bat (
	call build-vars.bat
)


IF NOT EXIST %LUX_X64_PYTHON2_ROOT% (
	echo.
	echo %%LUX_X64_PYTHON2_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X64_PYTHON3_ROOT% (
	echo.
	echo %%LUX_X64_PYTHON3_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X64_BOOST_ROOT% (
	echo.
	echo %%LUX_X64_BOOST_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X64_QT_ROOT% (
	echo.
	echo %%LUX_X64_QT_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X64_FREEIMAGE_ROOT% (
	echo.
	echo %%LUX_X64_FREEIMAGE_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X64_ZLIB_ROOT% (
	echo.
	echo %%LUX_X64_ZLIB_ROOT%% not valid! Aborting.
	exit /b -1
)

set MSBUILD_VERSION=
FOR /f "tokens=1,2 delims=." %%a IN ('msbuild /nologo /version') DO set MSBUILD_VERSION=%%a.%%b
IF "%MSBUILD_VERSION%" NEQ "4.0" (
	echo.
	echo Could not find 'msbuild' version 4.0.
	echo Please run this script from the Visual Studio 2010 Command Prompt.
	exit /b -1
)


echo Environment OK.

set LUX_WINDOWS_BUILD_ROOT=%CD%


echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building For x64                                                *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************


:DebugChoice
echo Build Debug binaries ?
echo 0: No (default)
echo 1: Yes
set BUILD_DEBUG=0
set /P BUILD_DEBUG="Selection? "
IF %BUILD_DEBUG% EQU 0 GOTO LuxRender 
IF %BUILD_DEBUG% EQU 1 GOTO LuxRender
echo Invalid choice
GOTO DebugChoice


:: ****************************************************************************
:: ******************************* LuxRender **********************************
:: ****************************************************************************
:LuxRender
echo.
echo **************************************************************************
echo * Building LuxRender                                                     *
echo **************************************************************************
cd /d %LUX_WINDOWS_BUILD_ROOT%
IF %BUILD_DEBUG% EQU 1 (
	msbuild /m /property:"Configuration=Debug" /property:"Platform=x64" /target:liblux;luxrender;luxconsole;luxcomp;luxmerger;pylux2;pylux3 lux.sln
)

msbuild /v:m /m /property:"Configuration=Release" /property:"Platform=x64" /target:luxrays;liblux;luxrender;luxconsole;luxcomp;luxmerger;pylux2;pylux3 lux.sln



:: ****************************************************************************
:: *********************************** Install ********************************
:: ****************************************************************************

cd /d %LUX_WINDOWS_BUILD_ROOT%

IF EXIST ./install-x64.bat (
	call install-x64.bat
)



:postLuxRender
:: ****************************************************************************
:: *********************************** Finished *******************************
:: ****************************************************************************
cd /d %LUX_WINDOWS_BUILD_ROOT%

echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building Completed                                              *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************
