@Echo off

echo.
echo **************************************************************************
echo * Checking environment                                                   *
echo **************************************************************************

IF EXIST build-vars.bat CALL build-vars.bat

CALL:checkEnvVarValid "LUX_WINDOWS_DEPS_ROOT"  || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_BOOST_ROOT"     || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_QT_ROOT"        || EXIT /b -1

set MSBUILD_VERSION=
FOR /f "tokens=1,2 delims=." %%a IN ('msbuild /nologo /version') DO set MSBUILD_VERSION=%%a.%%b
IF "%MSBUILD_VERSION%" NEQ "12.0" (
	echo.
	echo Could not find 'msbuild' version 12.0.
	echo Please run this script from the Visual Studio 2013 Command Prompt.
	EXIT /b -1
)

echo Environment OK.

echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building For x86                                                *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************


:DebugChoice
echo Build Debug binaries ?
echo 0: No (default)
echo 1: Yes
set BUILD_DEBUG=0
set /P BUILD_DEBUG="Selection? "
IF %BUILD_DEBUG% EQU 0 GOTO SetConfiguration 
IF %BUILD_DEBUG% EQU 1 GOTO SetConfiguration
echo Invalid choice
GOTO DebugChoice


:SetConfiguration
IF %BUILD_DEBUG% EQU 0 set BUILD_CONFIGURATION=Release
IF %BUILD_DEBUG% EQU 1 set BUILD_CONFIGURATION=Debug

set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:quiet /property:"Platform=Win32" /target:"Clean"


:: ****************************************************************************
:: ******************************* LuxRender **********************************
:: ****************************************************************************
:LuxRender
echo.
echo **************************************************************************
echo * Building LuxRender                                                     *
echo **************************************************************************
cd /d %LUX_WINDOWS_BUILD_ROOT%\Visual Studio

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:UIs\LuxRender;UIs\LuxConsole;Tools\LuxComp;Tools\LuxMerger;Tools\LuxVR;Libraries\LibPyLux Lux.sln


:: ****************************************************************************
:: *********************************** Install ********************************
:: ****************************************************************************
cd /d %LUX_WINDOWS_BUILD_ROOT%

IF EXIST install-x86.bat CALL install-x86.bat


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

:: Functions below this point
GOTO:EOF

:checkEnvVarValid
:: Checks whether an environment variable is set to an existing directory
:: %1 - Environment variable to check

SETLOCAL
CALL set ENVVAR=%%%~1%%
IF "%ENVVAR%" == "" (
	echo.
	echo %%%~1%% not set! Aborting.
	EXIT /b 1
)

IF NOT EXIST "%ENVVAR%" (
	echo.
	echo %~1="%ENVVAR%"
	echo but "%ENVVAR%" does not exist! Aborting.
	EXIT /b 1
)
ENDLOCAL
GOTO:EOF
