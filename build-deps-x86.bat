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

CALL:checkEnvVarValid "LUX_X86_PYTHON2_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_PYTHON3_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_BOOST_ROOT"     || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_QT_ROOT"        || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_FREEIMAGE_ROOT" || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_GLUT_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_GLEW_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X86_ZLIB_ROOT"      || EXIT /b -1

msbuild /? > NUL
IF NOT ERRORLEVEL 0 (
	echo.
	echo Cannot execute the 'msbuild' command. Please run
	echo this script from the Visual Studio 2008 Command Prompt.
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

IF EXIST bin\syncqt.bat move bin\syncqt.bat bin\syncqt.bat.disabled

configure -opensource -release -fast -mp -plugin-manifests -nomake demos -nomake examples -no-multimedia -no-phonon -no-phonon-backend -no-audio-backend -no-webkit -no-script -no-scripttools -no-qt3support -no-sse2
nmake



:: ****************************************************************************
:: ******************************* PYTHON *************************************
:: ****************************************************************************
:Python
echo.
echo **************************************************************************
echo * Building Python 2                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON2_ROOT%\PCbuild
IF %BUILD_DEBUG% EQU 1 ( msbuild /m /property:"Configuration=Debug" /property:"Platform=Win32" /target:"python" pcbuild.sln )
msbuild /m /property:"Configuration=Release" /property:"Platform=Win32" /target:"python" pcbuild.sln


echo.
echo **************************************************************************
echo * Building Python 3                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON3_ROOT%\PCbuild
IF %BUILD_DEBUG% EQU 1 ( msbuild /m /property:"Configuration=Debug" /property:"Platform=Win32" /target:"python" pcbuild.sln )
msbuild /m /property:"Configuration=Release" /property:"Platform=Win32" /target:"python" pcbuild.sln



:: ****************************************************************************
:: ******************************* BOOST **************************************
:: ****************************************************************************
:Boost
echo.
echo **************************************************************************
echo * Building BJam                                                          *
echo **************************************************************************
cd /d %LUX_X86_BOOST_ROOT%
CALL bootstrap.bat
SET BJAM_OPTS=-a -q -j8 toolset=msvc-9.0 link=static threading=multi runtime-link=shared

:Boost_Python2
echo.
echo **************************************************************************
echo * Building Boost::Python2                                                *
echo **************************************************************************
copy /Y %LUX_X86_PYTHON2_ROOT%\PC\pyconfig.h %LUX_X86_PYTHON2_ROOT%\Include
copy /Y %LUX_WINDOWS_BUILD_ROOT%\support\x86-project-config-2.jam .\project-config.jam
IF %BUILD_DEBUG% EQU 1 ( bjam %BJAM_OPTS% variant=debug --with-python -sPYTHON_SOURCE=%LUX_X86_PYTHON2_ROOT% --stagedir=stage/python2 --build-dir=bin/python2 python=2.7 target-os=windows debug stage )
bjam %BJAM_OPTS% variant=release --with-python -sPYTHON_SOURCE=%LUX_X86_PYTHON2_ROOT% --stagedir=stage/python2 --build-dir=bin/python2 python=2.7 target-os=windows stage

:Boost_Python3
echo.
echo **************************************************************************
echo * Building Boost::Python3                                                *
echo **************************************************************************
copy /Y %LUX_X86_PYTHON3_ROOT%\PC\pyconfig.h %LUX_X86_PYTHON3_ROOT%\Include
copy /Y %LUX_WINDOWS_BUILD_ROOT%\support\x86-project-config-3.jam .\project-config.jam
IF %BUILD_DEBUG% EQU 1 ( bjam %BJAM_OPTS% variant=debug --with-python -sPYTHON_SOURCE=%LUX_X86_PYTHON3_ROOT% --stagedir=stage/python3 --build-dir=bin/python3 python=3.2 target-os=windows debug stage )
bjam %BJAM_OPTS% variant=release --with-python -sPYTHON_SOURCE=%LUX_X86_PYTHON3_ROOT% --stagedir=stage/python3 --build-dir=bin/python3 python=3.2 target-os=windows stage

:Boost_Remainder
echo.
echo **************************************************************************
echo * Building Boost::IOStreams                                              *
echo *          Boost::FileSystem                                             *
echo *          Boost::Program_Options                                        *
echo *          Boost::Regex                                                  *
echo *          Boost::Serialization                                          *
echo *          Boost::Thread                                                 *
echo **************************************************************************
IF %BUILD_DEBUG% EQU 1 ( bjam %BJAM_OPTS% variant=debug --with-date_time --with-filesystem --with-iostreams --with-program_options --with-regex --with-serialization --with-system --with-thread -sZLIB_SOURCE=%LUX_X86_ZLIB_ROOT% -sBZIP2_SOURCE=%LUX_X86_BZIP_ROOT% debug stage )
bjam %BJAM_OPTS% variant=release --with-date_time --with-filesystem --with-iostreams --with-program_options --with-regex --with-serialization --with-system --with-thread -sZLIB_SOURCE=%LUX_X86_ZLIB_ROOT% -sBZIP2_SOURCE=%LUX_X86_BZIP_ROOT%  stage

:: ****************************************************************************
:: ********************************** FreeImage *******************************
:: ****************************************************************************
:FreeImage
echo.
echo **************************************************************************
echo * Building FreeImage                                                     *
echo **************************************************************************
cd /d %LUX_X86_FREEIMAGE_ROOT%\FreeImage

rem Patch solution file to enable FreeImageLib as a build target
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch FreeImage.2008.sln %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage.2008.sln.patch

IF %BUILD_DEBUG% EQU 1 ( msbuild /m /verbosity:minimal /property:"Configuration=Debug" /property:"Platform=Win32" /property:"VCBuildOverride=%LUX_WINDOWS_BUILD_ROOT%\support\LuxFreeImage.vsprops" /target:"Clean" /target:"FreeImageLib" FreeImage.2008.sln )
msbuild /m /verbosity:minimal /property:"Configuration=Release" /property:"Platform=Win32" /property:"VCBuildOverride=%LUX_WINDOWS_BUILD_ROOT%\support\LuxFreeImage.vsprops" /target:"Clean" /target:"FreeImageLib" FreeImage.2008.sln

:: ****************************************************************************
:: ********************************** freeglut ********************************
:: ****************************************************************************
:freeglut
echo.
echo **************************************************************************
echo * Building freeglut
echo **************************************************************************
cd /d %LUX_X86_GLUT_ROOT%

IF %BUILD_DEBUG% EQU 1 ( msbuild /m /verbosity:minimal /property:"Configuration=Debug_Static" /property:"Platform=Win32" /target:"Clean" /target:"freeglut" VisualStudio\2008\freeglut.sln )
msbuild /m /verbosity:minimal /property:"Configuration=Release_Static" /property:"Platform=Win32" /target:"Clean" /target:"freeglut" VisualStudio\2008\freeglut.sln

:: ****************************************************************************
:: ********************************** GLEW ************************************
:: ****************************************************************************
:GLEW
echo.
echo **************************************************************************
echo * Building GLEW
echo **************************************************************************
cd /d %LUX_X86_GLEW_ROOT%

rem Install new solution and project files
copy %LUX_WINDOWS_BUILD_ROOT%\support\glew.sln build\vc6\glew.sln
copy %LUX_WINDOWS_BUILD_ROOT%\support\glew_static.vcproj build\vc6\glew_static.vcproj

IF %BUILD_DEBUG% EQU 1 ( msbuild /m /verbosity:minimal /property:"Configuration=Debug" /property:"Platform=Win32" /target:"Clean" /target:"glew_static" build\vc6\glew.sln )
msbuild /m /verbosity:minimal /property:"Configuration=Release" /property:"Platform=Win32" /target:"Clean" /target:"glew_static" build\vc6\glew.sln

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
