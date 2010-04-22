@Echo off



echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo This script will use 2 pre-built binaries to help build LuxRender:
echo  1: GNU flex.exe       from http://gnuwin32.sourceforge.net/packages/flex.htm
echo  2: GNU bison.exe      from http://gnuwin32.sourceforge.net/packages/bison.htm
echo.
echo If you do not wish to execute these binaries for any reason, PRESS CTRL-C NOW
echo Otherwise,
pause


echo.
echo **************************************************************************
echo * Note for VC Express users who have 'hacked-in' 64bit support...        *
echo **************************************************************************
echo.
echo You need to edit the file C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcvarsall.bat
echo to point to the correct vcvars64.bat !!
echo.
pause


echo.
echo **************************************************************************
echo * Checking environment                                                   *
echo **************************************************************************

IF EXIST build-vars.bat (
    call build-vars.bat
)

IF %LUX_X64_PYTHON2_ROOT% == "" (
    echo.
    echo %%LUX_X64_PYTHON2_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X64_PYTHON2_ROOT% (
    echo.
    echo %%LUX_X64_PYTHON2_ROOT%% not valid! Aborting.
    exit /b -1
)
IF %LUX_X64_PYTHON3_ROOT% == "" (
    echo.
    echo %%LUX_X64_PYTHON3_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X64_PYTHON3_ROOT% (
    echo.
    echo %%LUX_X64_PYTHON3_ROOT%% not valid! Aborting.
    exit /b -1
)
IF %LUX_X64_BOOST_ROOT% == "" (
    echo.
    echo %%LUX_X64_BOOST_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X64_BOOST_ROOT% (
    echo.
    echo %%LUX_X64_BOOST_ROOT%% not valid! Aborting.
    exit /b -1
)
IF %LUX_X64_WX_ROOT% == "" (
    echo.
    echo %%LUX_X64_WX_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X64_WX_ROOT% (
    echo.
    echo %%LUX_X64_WX_ROOT%% not valid! Aborting.
    exit /b -1
)
IF %LUX_X64_OPENEXR_ROOT% == "" (
    echo.
    echo %%LUX_X64_OPENEXR_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST %LUX_X64_OPENEXR_ROOT% (
    echo.
    echo %%LUX_X64_OPENEXR_ROOT%% not valid! Aborting.
    exit /b -1
)

msbuild /nologo /version > nul
if NOT ERRORLEVEL 0 (
    echo.
    echo Cannot execute the 'msbuild' command. Please run
    echo this script from the Visual Studio 2008 x64 Win64 Command Prompt.
    exit /b -1
)

vcbuild /? > nul
if NOT ERRORLEVEL 0 (
    echo.
    echo Cannot execute the 'vcbuild' command. Please run
    echo this script from the Visual Studio 2008 x64 Win64 Command Prompt.
    exit /b -1
)

echo Environment OK.


echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building For x64                                                *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************

:: Store known location
set BUILD_PATH="%CD%"

:StartChoice
set BUILDCHOICE=''
:: choice /C NY /M "Build LuxRender only? (You can choose Y if you've already build the libraries)"
:: IF ERRORLEVEL 2 GOTO LuxRender

set /P BUILDCHOICE="Build LuxRender only? (You can choose Y if you've already build the libraries) [y/n] "
IF %BUILDCHOICE% == n ( GOTO Python )
IF %BUILDCHOICE% == y ( GOTO LuxRender )
echo Invalid choice
GOTO StartChoice


:: ****************************************************************************
:: ******************************* PYTHON *************************************
:: ****************************************************************************
:Python
echo.
echo **************************************************************************
echo * Building Python 2                                                      *
echo **************************************************************************
cd /d %LUX_X64_PYTHON2_ROOT%\PCbuild
vcbuild /nologo pcbuild.sln "Debug|x64"
vcbuild /nologo pcbuild.sln "Release|x64"

echo.
echo **************************************************************************
echo * Building Python 3                                                      *
echo **************************************************************************
cd /d %LUX_X64_PYTHON3_ROOT%\PCbuild
vcbuild /nologo pcbuild.sln "Debug|x64"
vcbuild /nologo pcbuild.sln "Release|x64"

:: ****************************************************************************
:: ******************************* BOOST **************************************
:: ****************************************************************************
:Boost
echo.
echo **************************************************************************
echo * Building BJam                                                          *
echo **************************************************************************
cd /d %LUX_X64_BOOST_ROOT%
call bootstrap.bat

echo.
echo **************************************************************************
echo * Building Boost::IOStreams                                              *
echo **************************************************************************
tools\jam\src\bin.ntx86_64\bjam.exe -sZLIB_SOURCE=%LUX_X64_ZLIB_ROOT% -sBZIP2_SOURCE=%LUX_X64_BZIP_ROOT% --toolset=msvc-9.0 address-model=64 --with-iostreams --stagedir=stage/boost --build-dir=bin/boost stage

:: hax boost script to force acceptance of python versions
copy /Y %BUILD_PATH%\support\python.jam .\tools\build\v2\tools

echo.
echo **************************************************************************
echo * Building Boost::Python (2 and 3)                                       *
echo **************************************************************************
copy /Y ..\Python-2.6.5\PC\pyconfig.h ..\Python-2.6.5\Include
copy /Y %BUILD_PATH%\support\x64-project-config-26.jam .\project-config.jam
tools\jam\src\bin.ntx86_64\bjam.exe -sPYTHON_SOURCE=%LUX_X64_PYTHON2_ROOT% --toolset=msvc-9.0 address-model=64 --with-python --stagedir=stage/python --build-dir=bin/python2 python=2.6 target-os=windows stage

rem echo.
rem echo **************************************************************************
rem echo * Building Boost::Python3                                                *
rem echo **************************************************************************
rem copy /Y ..\Python-3.1.2\PC\pyconfig.h ..\Python-3.1.2\Include
rem copy /Y %BUILD_PATH%\support\x64-project-config-31.jam .\project-config.jam
rem tools\jam\src\bin.ntx86_64\bjam.exe -sPYTHON_SOURCE=%LUX_X64_PYTHON3_ROOT% --toolset=msvc-9.0 address-model=64 --with-python --stagedir=stage/python3 --build-dir=bin/python3 python=3.1 target-os=windows stage

echo.
echo **************************************************************************
echo * Building Boost::FileSystem                                             *
echo *          Boost::Program_Options                                        *
echo *          Boost::Regex                                                  *
echo *          Boost::Serialization                                          *
echo *          Boost::Thread                                                 *
echo **************************************************************************
tools\jam\src\bin.ntx86_64\bjam.exe --toolset=msvc-9.0 address-model=64 --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost stage



:: ****************************************************************************
:: ******************************* WXWIDGETS **********************************
:: ****************************************************************************
:WxWidgets
echo.
echo **************************************************************************
echo * Building WxWidgets                                                     *
echo **************************************************************************
cd /d %LUX_X64_WX_ROOT%\build\msw

IF NOT EXIST "wx.sln" (
echo.
echo We need to convert the old project files to sln/vcproj files.
echo I will open the old project for you, and VS should prompt you
echo to convert the projects. Proceed with the conversion, save the
echo solution and quit VS. Do not build the solution, I will continue
echo the build after you have saved the new projects.
echo.
echo ADDITIONAL: Open gl\Setup Headers\setup.h ^(the top one^) and make
echo sure that wxUSE_GLCANVAS is defined as 1 ^(default is 0^) on line 994.
echo.
echo ADDITIONAL: You also need to create the x64 build platform !
echo ADDITIONAL: project 'base' needs WIN32 define changed to WIN64 in the
echo "Debug" and "Release" configurations !
pause
start /WAIT wx.dsw
echo Conversion finished. Building...
)

vcbuild /nologo wx.sln "Debug|x64"
vcbuild /nologo wx.sln "Release|x64"



:: ****************************************************************************
:: ******************************* ZLIB ***************************************
:: ****************************************************************************
:zlib
echo.
echo **************************************************************************
echo * Building zlib                                                          *
echo **************************************************************************
cd /d %LUX_X64_ZLIB_ROOT%\projects\visualc6

IF NOT EXIST "zlib.sln" (
echo.
echo We need to convert the old project files to sln/vcproj files.
echo I will open the old project for you, and VS should prompt you
echo to convert the projects. Proceed with the conversion, save the
echo solution and quit VS. Do not build the solution, I will continue
echo the build after you have saved the new projects.
echo.
echo ADDITIONAL: You also need to create the x64 build platform !
echo ADDITIONAL: projects needs WIN32 define changed to WIN64 in these
echo configurations: "LIB Debug" and "LIB Release" !
pause
start /WAIT zlib.dsw
echo Conversion finished. Building...
)

vcbuild /nologo zlib.sln "LIB Debug|x64"
vcbuild /nologo zlib.sln "LIB Release|x64"



:: ****************************************************************************
:: ******************************* OPENEXR ************************************
:: ****************************************************************************
:OpenEXR
echo.
echo **************************************************************************
echo * Building OpenEXR                                                       *
echo **************************************************************************
cd /d %LUX_X64_OPENEXR_ROOT%\vc\vc8
echo.
echo We need to convert the old project files to sln/vcproj files.
echo I will open the old project for you, and VS should prompt you
echo to convert the projects. Proceed with the conversion, save the
echo solution and quit VS. Do not build the solution, I will continue
echo the build after you have saved the new projects.
echo.
echo ADDITIONAL: You also need to create the x64 build platform !
pause
start /WAIT OpenEXR.sln
echo Do not continue until you save OpenEXR.sln and quit VS. Then,
pause
echo Conversion finished. Building...

:: copy zlibs
copy /Y %LUX_X64_ZLIB_ROOT%\zlib.h include\zlib.h
copy /Y %LUX_X64_ZLIB_ROOT%\zconf.h include\zconf.h
copy /Y %LUX_X64_ZLIB_ROOT%\projects\visualc6\Win32_LIB_Debug\*.lib lib\
copy /Y %LUX_X64_ZLIB_ROOT%\projects\visualc6\Win32_LIB_Release\*.lib lib\

vcbuild /nologo Half_eLut\Half_eLut.vcproj "Debug|x64"
vcbuild /nologo Half_toFloat\Half_toFloat.vcproj "Debug|x64"
vcbuild /nologo Half\Half.vcproj "Debug|x64"
vcbuild /nologo Iex\Iex.vcproj "Debug|x64"
vcbuild /nologo IlmThread\IlmThread.vcproj "Debug|x64"
vcbuild /nologo Imath\Imath.vcproj "Debug|x64"
vcbuild /nologo IlmImf\IlmImf.vcproj "Debug|x64"

vcbuild /nologo Half_eLut\Half_eLut.vcproj "Release|x64"
vcbuild /nologo Half_toFloat\Half_toFloat.vcproj "Release|x64"
vcbuild /nologo Half\Half.vcproj "Release|x64"
vcbuild /nologo Iex\Iex.vcproj "Release|x64"
vcbuild /nologo IlmThread\IlmThread.vcproj "Release|x64"
vcbuild /nologo Imath\Imath.vcproj "Release|x64"
vcbuild /nologo IlmImf\IlmImf.vcproj "Release|x64"



:: ****************************************************************************
:: ******************************* LuxRender***********************************
:: ****************************************************************************
:LuxRender
echo.
echo **************************************************************************
echo * Building LuxRender                                                     *
echo **************************************************************************
cd /d %BUILD_PATH%

:: include flex and bison in system PATH
set PATH=%CD%\support\bin;%PATH%

vcbuild /nologo lux.sln "Debug|x64"
del Projects\x64\Debug\binding.obj
vcbuild /nologo lux.sln "Pylux2Debug|x64"
del Projects\x64\Debug\binding.obj
vcbuild /nologo lux.sln "Pylux3Debug|x64"

vcbuild /nologo lux.sln "Release|x64"
del Projects\x64\Release\binding.obj
vcbuild /nologo lux.sln "Pylux2Release|x64"
del Projects\x64\Release\binding.obj
vcbuild /nologo lux.sln "Pylux3Release|x64"

vcbuild /nologo lux.sln "Console|x64"
vcbuild /nologo lux.sln "Luxmerge|x64"

echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building Completed                                              *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************
