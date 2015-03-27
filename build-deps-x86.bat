@Echo off

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

IF EXIST build-vars.bat CALL build-vars.bat

CALL:checkEnvVarValid "LUX_X86_PYTHON3_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_BOOST_ROOT"     || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_QT_ROOT"        || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_FREEIMAGE_ROOT" || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_GLUT_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_GLEW_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_FFTW_ROOT"      || EXIT /b -1

set MSBUILD_VERSION=
FOR /f "tokens=1,2 delims=." %%a IN ('msbuild /nologo /version') DO set MSBUILD_VERSION=%%a.%%b
IF "%MSBUILD_VERSION%" NEQ "4.0" (
	echo.
	echo Could not find 'msbuild' version 4.0.
	echo Please run this script from the Visual Studio 2010 Command Prompt.
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

:StartChoice

echo.
echo If this is your first time building LuxRender, you'll need to build the 
echo dependencies as well. After they've been built you'll shouldn't need to
echo rebuild them unless there's a change in versions.
echo.
echo If you've successfully built the dependencies before, you only need to
echo build LuxRender.
echo.


:DebugChoice
echo Build Debug binaries?
echo 0: No (default)
echo 1: Yes
SET BUILD_DEBUG=0
SET /P BUILD_DEBUG="Selection? "
IF %BUILD_DEBUG% EQU 0 GOTO BuildDepsChoice 
IF %BUILD_DEBUG% EQU 1 GOTO BuildDepsChoice
echo Invalid choice
GOTO DebugChoice


:BuildDepsChoice
echo.
echo Build options:
echo 1: Build all dependencies (default)
echo 2: Build all but Qt
echo q: Quit (do nothing)
echo.
SET BUILDCHOICE=1
SET /P BUILDCHOICE="Selection? "
IF %BUILDCHOICE% EQU 1 GOTO QT
IF %BUILDCHOICE% EQU 2 GOTO Python
IF /I %BUILDCHOICE% EQU q GOTO:EOF
echo Invalid choice
GOTO BuildDepsChoice



:: ****************************************************************************
:: ********************************** QT **************************************
:: ****************************************************************************
:QT
echo.
echo **************************************************************************
echo * Building Qt                                                            *
echo **************************************************************************
cd /d %LUX_X86_QT_ROOT%
echo.
echo Cleaning Qt, this may take a few moments...
nmake confclean 1>NUL 2>NUL
echo.
echo Building Qt may take a very long time! The Qt configure utility will now 
echo ask you a few questions before building commences. The rest of the build 
echo process should be autonomous.
pause

configure -opensource -release -fast -ltcg -mp -plugin-manifests -nomake demos -nomake examples -no-multimedia -no-phonon -no-phonon-backend -no-audio-backend -no-webkit -no-script -no-scripttools -no-qt3support
nmake



:: ****************************************************************************
:: ******************************* PYTHON *************************************
:: ****************************************************************************
:Python
echo.
echo **************************************************************************
echo * Building Python 3                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON3_ROOT%\PCbuild
copy ..\PC\pyconfig.h ..\Include
IF %BUILD_DEBUG% EQU 1 ( msbuild /m /property:"Configuration=Debug" /property:"Platform=Win32" /target:"python" pcbuild.sln )
msbuild /m /property:"Configuration=Release" /property:"Platform=Win32" /target:"python" pcbuild.sln



:: ****************************************************************************
:: ******************************* BOOST **************************************
:: ****************************************************************************
:Boost
echo.
echo **************************************************************************
echo * Building Boost::IOStreams                                              *
echo *          Boost::FileSystem                                             *
echo *          Boost::Program_Options                                        *
echo *          Boost::Python3                                                *
echo *          Boost::Regex                                                  *
echo *          Boost::Serialization                                          *
echo *          Boost::Thread                                                 *
echo **************************************************************************
cd /d %LUX_X86_BOOST_ROOT%
CALL bootstrap.bat
type %LUX_WINDOWS_BUILD_ROOT%\support\x86-project-config-3.jam >> project-config.jam
SET BJAM_OPTS=-a -q -j%NUMBER_OF_PROCESSORS% link=static threading=multi runtime-link=shared --with-date_time --with-filesystem --with-iostreams --with-program_options --with-python --with-regex --with-serialization --with-system --with-thread --stagedir=stage/boost --build-dir=bin/boost -sBZIP2_SOURCE=%LUX_X86_BZIP_ROOT% -sPYTHON_SOURCE=%LUX_X86_PYTHON3_ROOT% -sZLIB_SOURCE=%LUX_X86_FREEIMAGE_ROOT%\FreeImage\Source\ZLib
IF %BUILD_DEBUG% EQU 1 ( bjam %BJAM_OPTS% variant=debug debug stage )
bjam %BJAM_OPTS% variant=release stage

:: ****************************************************************************
:: ********************************** FreeImage *******************************
:: ****************************************************************************
:FreeImage
echo.
echo **************************************************************************
echo * Building FreeImage                                                     *
echo **************************************************************************
cd /d %LUX_X86_FREEIMAGE_ROOT%\FreeImage

rem Install solution and project files for VS2010
xcopy /S /Y %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage\*.* .

IF %BUILD_DEBUG% EQU 1 ( msbuild /m /verbosity:minimal /property:"Configuration=Debug" /property:"Platform=Win32" /target:"Clean" /target:"FreeImageLib" FreeImage.2010.sln )
msbuild /m /verbosity:minimal /property:"Configuration=Release" /property:"Platform=Win32" /target:"Clean" /target:"FreeImageLib" FreeImage.2010.sln

:: ****************************************************************************
:: ********************************** freeglut ********************************
:: ****************************************************************************
:freeglut
echo.
echo **************************************************************************
echo * Building freeglut
echo **************************************************************************
cd /d %LUX_X86_GLUT_ROOT%

rem Update project files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch VisualStudio\2010\freeglut.vcxproj %LUX_WINDOWS_BUILD_ROOT%\support\freeglut.vcxproj.patch

IF %BUILD_DEBUG% EQU 1 ( msbuild /m /verbosity:minimal /property:"Configuration=Debug_Static" /property:"Platform=Win32" /target:"Clean" /target:"freeglut" VisualStudio\2010\freeglut.sln )
msbuild /m /verbosity:minimal /property:"Configuration=Release_Static" /property:"Platform=Win32" /target:"Clean" /target:"freeglut" VisualStudio\2010\freeglut.sln

:: ****************************************************************************
:: ********************************** GLEW ************************************
:: ****************************************************************************
:GLEW
echo.
echo **************************************************************************
echo * Building GLEW
echo **************************************************************************
cd /d %LUX_X86_GLEW_ROOT%

rem Update solution and project files for VS2010
copy /Y %LUX_WINDOWS_BUILD_ROOT%\support\glew\*.* build\vc10

IF %BUILD_DEBUG% EQU 1 ( msbuild /m /verbosity:minimal /property:"Configuration=Debug" /property:"Platform=Win32" /target:"Clean" /target:"glew_static" build\vc10\glew.sln )
msbuild /m /verbosity:minimal /property:"Configuration=Release" /property:"Platform=Win32" /target:"Clean" /target:"glew_static" build\vc10\glew.sln

:: ****************************************************************************
:: ********************************** FFTW ************************************
:: ****************************************************************************
:FFTW
echo.
echo **************************************************************************
echo * Building FFTW
echo **************************************************************************
cd /d %LUX_X86_FFTW_ROOT%

rem Update project files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch fftw-3.3-libs\libfftw-3.3\libfftw-3.3.vcxproj %LUX_WINDOWS_BUILD_ROOT%\support\libfftw-3.3.vcxproj.patch

IF %BUILD_DEBUG% EQU 1 ( msbuild /m /verbosity:minimal /property:"Configuration=Static-Debug" /property:"Platform=Win32" /target:"Clean" /target:"libfftw-3_3" fftw-3.3-libs\fftw-3.3-libs.sln )
msbuild /m /verbosity:minimal /property:"Configuration=Static-Release" /property:"Platform=Win32" /target:"Clean" /target:"libfftw-3_3" fftw-3.3-libs\fftw-3.3-libs.sln

:: ****************************************************************************
:: ******************************* LuxRays ************************************
:: ****************************************************************************
:LuxRays
echo.
echo **************************************************************************
echo * Building LuxRays                                                       *
echo **************************************************************************
cd /d %LUX_WINDOWS_BUILD_ROOT%
IF %BUILD_DEBUG% EQU 1 (
	msbuild /m /property:"Configuration=Debug" /property:"Platform=Win32" /target:luxrays lux.sln
)

msbuild /m /property:"Configuration=Release" /property:"Platform=Win32" /target:luxrays lux.sln



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
CALL SET ENVVAR=%%%~1%%
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
