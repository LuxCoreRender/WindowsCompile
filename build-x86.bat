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

IF EXIST build-vars.bat (
    call build-vars.bat
)

IF "%LUX_X86_PYTHON2_ROOT%" == "" (
    echo.
    echo %%LUX_X86_PYTHON2_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X86_PYTHON2_ROOT% (
    echo.
    echo %%LUX_X86_PYTHON2_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_PYTHON3_ROOT%" == "" (
    echo.
    echo %%LUX_X86_PYTHON3_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X86_PYTHON3_ROOT% (
    echo.
    echo %%LUX_X86_PYTHON3_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_BOOST_ROOT%" == "" (
    echo.
    echo %%LUX_X86_BOOST_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X86_BOOST_ROOT% (
    echo.
    echo %%LUX_X86_BOOST_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_QT_ROOT%" == "" (
    echo.
    echo %%LUX_X86_QT_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X86_QT_ROOT% (
    echo.
    echo %%LUX_X86_QT_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_FREEIMAGE_ROOT%" == "" (
    echo.
    echo %%LUX_X86_FREEIMAGE_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X86_FREEIMAGE_ROOT% (
    echo.
    echo %%LUX_X86_FREEIMAGE_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_ZLIB_ROOT%" == "" (
    echo.
    echo %%LUX_X86_ZLIB_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X86_ZLIB_ROOT% (
    echo.
    echo %%LUX_X86_ZLIB_ROOT%% not valid! Aborting.
    exit /b -1
)

vcbuild /? > nul
if NOT ERRORLEVEL 0 (
    echo.
    echo Cannot execute the 'vcbuild' command. Please run
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

:: Store known location
set BUILD_PATH="%CD%"

:StartChoice
set BUILDCHOICE=''

echo.
echo If this is your first time building LuxRender, you'll need to build the 
echo dependencies as well. After they've been built you'll shouldn't need to
echo rebuild them unless there's a change in versions.
echo.
echo If you've successfully built the dependencies before, you only need to
echo build LuxRender.
echo.
IF "%BUILD_PYTHON3%" == "" (
  echo Python 3 target is disabled, to enable set the %%BUILD_PYTHON3%% variable 
  echo before running this script.
  echo.
)
echo Build options:
echo 1: Build everything (all dependencies and LuxRender)
echo 2: Build everything but Qt
echo 3: Build dependencies only
echo 4: Build luxrender only (default)
echo q: Quit (do nothing)
echo.

set BUILDCHOICE=4
set /P BUILDCHOICE="Selection? "

IF %BUILDCHOICE% == 1 ( GOTO QT )
IF %BUILDCHOICE% == 2 ( GOTO Python )
IF %BUILDCHOICE% == 3 ( GOTO QT )
IF %BUILDCHOICE% == 4 ( GOTO LuxRender )
IF /I %BUILDCHOICE% EQU q ( GOTO :EOF )

echo Invalid choice

GOTO StartChoice


:BuildDeps
IF /I %BUILDCHOICE% GEQ 4 ( GOTO LuxRender )


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
nmake confclean 1>nul 2>nul
echo.
echo Building Qt may take a very long time! The Qt configure utility will now 
echo ask you a few questions before building commences. The rest of the build 
echo process should be autonomous.
pause

rem Patch qmake.conf file to enable multithreaded compilation
%BUILD_PATH%\support\bin\patch --forward --backup --batch mkspecs\win32-msvc2008\qmake.conf %BUILD_PATH%\support\qmake.conf.patch

configure -opensource -release -plugin-manifests -nomake demos -nomake examples -no-multimedia -no-phonon -no-phonon-backend -no-audio-backend -no-webkit -no-script -no-scripttools -no-sse2
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
vcbuild /nologo /rebuild pcbuild.sln "Debug|Win32"
vcbuild /nologo /rebuild pcbuild.sln "Release|Win32"


IF "%BUILD_PYTHON3%" == "" ( GOTO Boost )
echo.
echo **************************************************************************
echo * Building Python 3                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON3_ROOT%\PCbuild
vcbuild /nologo /rebuild pcbuild.sln "Debug|Win32"
vcbuild /nologo /rebuild pcbuild.sln "Release|Win32"


:: ****************************************************************************
:: ******************************* BOOST **************************************
:: ****************************************************************************
:Boost
echo.
echo **************************************************************************
echo * Building BJam                                                          *
echo **************************************************************************
cd /d %LUX_X86_BOOST_ROOT%
call bootstrap.bat

:Boost_IOStreams
echo.
echo **************************************************************************
echo * Building Boost::IOStreams                                              *
echo **************************************************************************
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=shared -a -sZLIB_SOURCE=%LUX_X86_ZLIB_ROOT% -sBZIP2_SOURCE=%LUX_X86_BZIP_ROOT% --with-iostreams --stagedir=stage/boost --build-dir=bin/boost stage

:: hax boost script to force acceptance of python versions
copy /Y %BUILD_PATH%\support\python.jam .\tools\build\v2\tools

:Boost_Python2
echo.
echo **************************************************************************
echo * Building Boost::Python2                                                *
echo **************************************************************************
copy /Y %LUX_X86_PYTHON2_ROOT%\PC\pyconfig.h %LUX_X86_PYTHON2_ROOT%\Include
copy /Y %BUILD_PATH%\support\x86-project-config-26.jam .\project-config.jam
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=shared -a -sPYTHON_SOURCE=%LUX_X86_PYTHON2_ROOT% --with-python --stagedir=stage/python2 --build-dir=bin/python2 python=2.6 target-os=windows stage

IF "%BUILD_PYTHON3%" == "" ( GOTO Boost_Remainder )
:Boost_Python3
echo.
echo **************************************************************************
echo * Building Boost::Python3                                                *
echo **************************************************************************
copy /Y %LUX_X86_PYTHON3_ROOT%\PC\pyconfig.h %LUX_X86_PYTHON3_ROOT%\Include
copy /Y %BUILD_PATH%\support\x86-project-config-31.jam .\project-config.jam
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=shared -a -sPYTHON_SOURCE=%LUX_X86_PYTHON3_ROOT% --with-python --stagedir=stage/python3 --build-dir=bin/python3 python=3.1 target-os=windows stage

:Boost_Remainder
echo.
echo **************************************************************************
echo * Building Boost::FileSystem                                             *
echo *          Boost::Program_Options                                        *
echo *          Boost::Regex                                                  *
echo *          Boost::Serialization                                          *
echo *          Boost::Thread                                                 *
echo **************************************************************************
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=shared -a --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost stage


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
%BUILD_PATH%\support\bin\patch --forward --backup --batch FreeImage.2008.sln %BUILD_PATH%\support\FreeImage.2008.sln.patch

msbuild /verbosity:minimal /property:"Configuration=Release" /property:"Platform=Win32" /property:"VCBuildOverride=%BUILD_PATH%\support\LuxFreeImage.vsprops" /target:"Clean" /target:"FreeImageLib" FreeImage.2008.sln








:: ****************************************************************************
:: ******************************* LuxRender **********************************
:: ****************************************************************************
:LuxRender
IF %BUILDCHOICE% EQU 3 ( GOTO postLuxRender )
echo.
echo **************************************************************************
echo * Building LuxRender                                                     *
echo **************************************************************************
cd /d %BUILD_PATH%

:: include flex and bison in system PATH
set PATH=%CD%\support\bin;%PATH%

:: vcbuild /nologo lux.sln "Debug|Win32"
:: vcbuild /nologo lux.sln "Pylux2Debug|Win32"
:: vcbuild /nologo lux.sln "Pylux3Debug|Win32"

vcbuild /nologo lux.sln "LuxRender|Win32"
vcbuild /nologo lux.sln "Pylux2Release|Win32"
IF NOT "%BUILD_PYTHON3%" == "" (
  vcbuild /nologo /clean lux.sln "Pylux3Release|Win32"
  vcbuild /nologo lux.sln "Pylux3Release|Win32"
)

vcbuild /nologo lux.sln "Console|Win32"
vcbuild /nologo lux.sln "Luxmerge|Win32"
vcbuild /nologo lux.sln "Luxcomp|Win32"

:: vcbuild /nologo lux.sln "Console SSE1|Win32"
:: vcbuild /nologo lux.sln "Release SSE1|Win32"


:: ****************************************************************************
:: *********************************** Install ********************************
:: ****************************************************************************

cd /d %BUILD_PATH%

IF EXIST ./install-x86.bat (
    call install-x86.bat
)

:postLuxRender
cd /d %BUILD_PATH%


echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building Completed                                              *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************
