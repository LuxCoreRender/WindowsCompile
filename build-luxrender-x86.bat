@Echo off

echo Building LuxRender on the command line is not currently supported. The
echo binaries produced will not function correctly. Please use the VS IDE
echo with the lux.sln file to build Lux binaries.
echo.
exit /b -1

echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo This script will use 3 pre-built binaries to help build LuxRender:
echo  1: GNU flex.exe       from http://gnuwin32.sourceforge.net/packages/flex.htm
echo  2: GNU bison.exe      from http://gnuwin32.sourceforge.net/packages/bison.htm
echo  3: GNU patch.exe      from http://gnuwin32.sourceforge.net/packages/patch.htm
echo.
echo If you do not wish to execute these binaries for any reason, PRESS CTRL-C NOW
echo Otherwise,
pause

echo.
echo **************************************************************************
echo * Checking environment                                                   *
echo **************************************************************************

IF EXIST build-vars.bat (
	call build-vars.bat
)

IF NOT EXIST %LUX_X86_PYTHON2_ROOT% (
	echo.
	echo %%LUX_X86_PYTHON2_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X86_PYTHON3_ROOT% (
	echo.
	echo %%LUX_X86_PYTHON3_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X86_BOOST_ROOT% (
	echo.
	echo %%LUX_X86_BOOST_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X86_QT_ROOT% (
	echo.
	echo %%LUX_X86_QT_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X86_FREEIMAGE_ROOT% (
	echo.
	echo %%LUX_X86_FREEIMAGE_ROOT%% not valid! Aborting.
	exit /b -1
)
IF NOT EXIST %LUX_X86_ZLIB_ROOT% (
	echo.
	echo %%LUX_X86_ZLIB_ROOT%% not valid! Aborting.
	exit /b -1
)

msbuild /? > nul
if NOT ERRORLEVEL 0 (
	echo.
	echo Cannot execute the 'msbuild' command. Please run
	echo this script from the Visual Studio 2008 Command Prompt.
	exit /b -1
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



:: ****************************************************************************
:: ******************************* LuxRender **********************************
:: ****************************************************************************
:LuxRender
IF %BUILDCHOICE% EQU 3 ( GOTO postLuxRender )
echo.
echo **************************************************************************
echo * Building LuxRender                                                     *
echo **************************************************************************
cd /d %LUX_WINDOWS_BUILD_ROOT%
IF %BUILD_DEBUG% EQU 1 (
	msbuild /m /property:"Configuration=Debug" /property:"Platform=Win32" /target:liblux;luxrender;luxconsole;luxcomp;luxmerger;pylux2;pylux3 lux.sln
	msbuild /m /property:"Configuration=Debug SSE1" /property:"Platform=Win32" /target:liblux;luxrender;luxconsole;luxcomp;luxmerger;pylux2;pylux3 lux.sln
)

msbuild /m /property:"Configuration=Release" /property:"Platform=Win32" /target:liblux;luxrender;luxconsole;luxcomp;luxmerger;pylux2;pylux3 lux.sln
msbuild /m /property:"Configuration=Release SSE1" /property:"Platform=Win32" /target:liblux;luxrender;luxconsole;luxcomp;luxmerger;pylux2;pylux3 lux.sln



:: ****************************************************************************
:: *********************************** Install ********************************
:: ****************************************************************************

cd /d %LUX_WINDOWS_BUILD_ROOT%

IF EXIST ./install-x86.bat (
	call install-x86.bat
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
