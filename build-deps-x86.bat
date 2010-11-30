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
echo Build Debug binaries ?
echo 0: No (default)
echo 1: Yes
set BUILD_DEBUG=0
set /P BUILD_DEBUG="Selection? "
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
set BUILDCHOICE=1
set /P BUILDCHOICE="Selection? "
IF %BUILDCHOICE% == 1 ( GOTO QT )
IF %BUILDCHOICE% == 2 ( GOTO Python )
IF /I %BUILDCHOICE% EQU q ( GOTO :EOF )
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
nmake confclean 1>nul 2>nul
echo.
echo Building Qt may take a very long time! The Qt configure utility will now 
echo ask you a few questions before building commences. The rest of the build 
echo process should be autonomous.
pause

rem Patch qmake.conf file to enable multithreaded compilation
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch mkspecs\win32-msvc2008\qmake.conf %LUX_WINDOWS_BUILD_ROOT%\support\qmake.conf.patch

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
call bootstrap.bat

:Boost_IOStreams
echo.
echo **************************************************************************
echo * Building Boost::IOStreams                                              *
echo **************************************************************************
IF %BUILD_DEBUG% EQU 1 ( bjam.exe toolset=msvc-9.0 variant=debug link=static threading=multi runtime-link=shared -a -sZLIB_SOURCE=%LUX_X86_ZLIB_ROOT% -sBZIP2_SOURCE=%LUX_X86_BZIP_ROOT% --with-iostreams --stagedir=stage/boost --build-dir=bin/boost debug stage )
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=shared -a -sZLIB_SOURCE=%LUX_X86_ZLIB_ROOT% -sBZIP2_SOURCE=%LUX_X86_BZIP_ROOT% --with-iostreams --stagedir=stage/boost --build-dir=bin/boost stage

:: hax boost script to force acceptance of python versions
copy /Y %LUX_WINDOWS_BUILD_ROOT%\support\python.jam .\tools\build\v2\tools

:Boost_Python2
echo.
echo **************************************************************************
echo * Building Boost::Python2                                                *
echo **************************************************************************
copy /Y %LUX_X86_PYTHON2_ROOT%\PC\pyconfig.h %LUX_X86_PYTHON2_ROOT%\Include
:: copy /Y %LUX_WINDOWS_BUILD_ROOT%\support\x86-project-config-26.jam .\project-config.jam
del project-config.jam
IF %BUILD_DEBUG% EQU 1 ( bjam.exe toolset=msvc-9.0 variant=debug link=static threading=multi runtime-link=shared -a -sPYTHON_SOURCE=%LUX_X86_PYTHON2_ROOT% --with-python --stagedir=stage/python2 --build-dir=bin/python2 python=2.6 target-os=windows debug stage )
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=shared -a -sPYTHON_SOURCE=%LUX_X86_PYTHON2_ROOT% --with-python --stagedir=stage/python2 --build-dir=bin/python2 python=2.6 target-os=windows stage

:Boost_Python3
echo.
echo **************************************************************************
echo * Building Boost::Python3                                                *
echo **************************************************************************
copy /Y %LUX_X86_PYTHON3_ROOT%\PC\pyconfig.h %LUX_X86_PYTHON3_ROOT%\Include
copy /Y %LUX_WINDOWS_BUILD_ROOT%\support\x86-project-config-31.jam .\project-config.jam
IF %BUILD_DEBUG% EQU 1 ( bjam.exe toolset=msvc-9.0 variant=debug link=static threading=multi runtime-link=shared -a -sPYTHON_SOURCE=%LUX_X86_PYTHON3_ROOT% --with-python --stagedir=stage/python3 --build-dir=bin/python3 python=3.1 target-os=windows debug stage ) 
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
IF %BUILD_DEBUG% EQU 1 ( bjam.exe toolset=msvc-9.0 variant=debug link=static threading=multi runtime-link=shared -a --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost debug stage ) 
IF %BUILD_DEBUG% EQU 1 ( bjam.exe toolset=msvc-9.0 variant=debug link=static threading=multi runtime-link=static -a --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost debug stage )
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=shared -a --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost stage
bjam.exe toolset=msvc-9.0 variant=release link=static threading=multi runtime-link=static -a --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost stage



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
:: ******************************* LuxRays ************************************
:: ****************************************************************************
:LuxRays
echo.
echo **************************************************************************
echo * Building LuxRays                                                       *
echo **************************************************************************
cd /d %LUX_WINDOWS_BUILD_ROOT%
IF %BUILD_DEBUG% EQU 1 (
	msbuild /m /property:"Configuration=Debug" /property:"Platform=Win32" /target:luxrays;benchpixel;benchsimple lux.sln
)

msbuild /m /property:"Configuration=Release" /property:"Platform=Win32" /target:luxrays;benchpixel;benchsimple lux.sln



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
