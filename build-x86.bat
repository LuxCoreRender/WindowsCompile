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
IF NOT EXIST "%LUX_X86_PYTHON2_ROOT%" (
    echo.
    echo %%LUX_X86_PYTHON2_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_PYTHON3_ROOT%" == "" (
    echo.
    echo %%LUX_X86_PYTHON3_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST "%LUX_X86_PYTHON3_ROOT%" (
    echo.
    echo %%LUX_X86_PYTHON3_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_BOOST_ROOT%" == "" (
    echo.
    echo %%LUX_X86_BOOST_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST "%LUX_X86_BOOST_ROOT%" (
    echo.
    echo %%LUX_X86_BOOST_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_WX_ROOT%" == "" (
    echo.
    echo %%LUX_X86_WX_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST "%LUX_X86_WX_ROOT%" (
    echo.
    echo %%LUX_X86_WX_ROOT%% not valid! Aborting.
    exit /b -1
)
IF "%LUX_X86_OPENEXR_ROOT%" == "" (
    echo.
    echo %%LUX_X86_OPENEXR_ROOT%% is not set! Aborting.
    exit /b -1
)
IF NOT EXIST "%LUX_X86_OPENEXR_ROOT%" (
    echo.
    echo %%LUX_X86_OPENEXR_ROOT%% not valid! Aborting.
    exit /b -1
)

msbuild /nologo /version > nul
if NOT ERRORLEVEL 0 (
    echo.
    echo Cannot execute the 'msbuild' command. Please run
    echo this script from the Visual Studio Command Prompt.
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
set BUILD_PATH=%CD%

choice /C NY /M "Build LuxRender only? (You can choose Y if you've already build the libraries)"
IF ERRORLEVEL 2 GOTO LuxRender


:: ****************************************************************************
:: ******************************* PYTHON *************************************
:: ****************************************************************************
:Python
echo.
echo **************************************************************************
echo * Building Python 2                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON2_ROOT%\PCbuild
msbuild /nologo /p:Configuration=Debug;Platform=Win32 pcbuild.sln
msbuild /nologo /p:Configuration=Release;Platform=Win32 pcbuild.sln

echo.
echo **************************************************************************
echo * Building Python 3                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON3_ROOT%\PCbuild
msbuild /nologo /p:Configuration=Debug;Platform=Win32 pcbuild.sln
msbuild /nologo /p:Configuration=Release;Platform=Win32 pcbuild.sln



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

echo.
echo **************************************************************************
echo * Building Boost::IOStreams                                              *
echo **************************************************************************
bjam -sZLIB_SOURCE=%LUX_X86_ZLIB_ROOT% -sBZIP2_SOURCE=%LUX_X86_BZIP_ROOT% --toolset=msvc --with-iostreams --stagedir=stage/boost --build-dir=bin/boost stage

echo.
echo **************************************************************************
echo * Building Boost::Python2                                                *
echo **************************************************************************
copy /Y %BUILD_PATH%\support\x86-project-config-26.jam .\project-config.jam
bjam -sPYTHON_SOURCE=%LUX_X86_PYTHON2_ROOT% --toolset=msvc --with-python --stagedir=stage/python2 --build-dir=bin/python2 python=2.6 target-os=windows stage

echo.
echo **************************************************************************
echo * Building Boost::Python3                                                *
echo **************************************************************************
copy /Y %BUILD_PATH%\support\x86-project-config-31.jam .\project-config.jam
bjam -sPYTHON_SOURCE=%LUX_X86_PYTHON3_ROOT% --toolset=msvc --with-python --stagedir=stage/python3 --build-dir=bin/python3 python=3.1 target-os=windows stage

echo.
echo **************************************************************************
echo * Building Boost::FileSystem                                             *
echo *          Boost::Program_Options                                        *
echo *          Boost::Regex                                                  *
echo *          Boost::Serialization                                          *
echo *          Boost::Thread                                                 *
echo **************************************************************************
bjam --toolset=msvc --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost stage



:: ****************************************************************************
:: ******************************* WXWIDGETS **********************************
:: ****************************************************************************
:WxWidgets
echo.
echo **************************************************************************
echo * Building WxWidgets                                                     *
echo **************************************************************************
cd /d %LUX_X86_WX_ROOT%\build\msw

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
pause
start /WAIT wx.dsw
echo Conversion finished. Building...
)

msbuild /nologo /p:Configuration=Debug;Platform=Win32 wx.sln
msbuild /nologo /p:Configuration=Release;Platform=Win32 wx.sln



:: ****************************************************************************
:: ******************************* ZLIB ***************************************
:: ****************************************************************************
:zlib
echo.
echo **************************************************************************
echo * Building zlib                                                          *
echo **************************************************************************
cd /d %LUX_X86_ZLIB_ROOT%\projects\visualc6

IF NOT EXIST "zlib.sln" (
echo.
echo We need to convert the old project files to sln/vcproj files.
echo I will open the old project for you, and VS should prompt you
echo to convert the projects. Proceed with the conversion, save the
echo solution and quit VS. Do not build the solution, I will continue
echo the build after you have saved the new projects.
echo.
pause
start /WAIT zlib.dsw
echo Conversion finished. Building...
)

msbuild /nologo /p:Configuration="LIB Debug";Platform=Win32 zlib.sln
msbuild /nologo /p:Configuration="LIB Release";Platform=Win32 zlib.sln



:: ****************************************************************************
:: ******************************* OPENEXR ************************************
:: ****************************************************************************
:OpenEXR
echo.
echo **************************************************************************
echo * Building OpenEXR                                                       *
echo **************************************************************************
cd /d %LUX_X86_OPENEXR_ROOT%\vc\vc8
echo.
echo We need to convert the old project files to sln/vcproj files.
echo I will open the old project for you, and VS should prompt you
echo to convert the projects. Proceed with the conversion, save the
echo solution and quit VS. Do not build the solution, I will continue
echo the build after you have saved the new projects.
echo.
::echo ADDITIONAL: For the project IlmImf, please add the zlib source
::echo path to the "Additional Include Directories"
::echo (Found under Configuration Properties \ C/C++ \ General)
pause
start /WAIT OpenEXR.sln
echo Do not continue until you save OpenEXR.sln and quit VS. Then,
pause
echo Conversion finished. Building...

:: copy zlibs
copy %LUX_X86_ZLIB_ROOT%\zlib.h include\zlib.h
copy %LUX_X86_ZLIB_ROOT%\zconf.h include\zconf.h
copy %LUX_X86_ZLIB_ROOT%\\projects\visualc6\Win32_LIB_Debug\*.lib lib\
copy %LUX_X86_ZLIB_ROOT%\\projects\visualc6\Win32_LIB_Release\*.lib lib\

msbuild /nologo /p:Configuration=Debug;Platform=Win32 Half_eLut\Half_eLut.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 Half_toFloat\Half_toFloat.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 Half\Half.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 Iex\Iex.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 IlmThread\IlmThread.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 Imath\Imath.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 IlmImf\IlmImf.vcproj

msbuild /nologo /p:Configuration=Release;Platform=Win32 Half_eLut\Half_eLut.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 Half_toFloat\Half_toFloat.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 Half\Half.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 Iex\Iex.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 IlmThread\IlmThread.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 Imath\Imath.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 IlmImf\IlmImf.vcproj



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

msbuild /nologo /p:Configuration=Debug;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux2Debug;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux3Debug;Platform=Win32 lux.sln

msbuild /nologo /p:Configuration=Release;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux2Release;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux3Release;Platform=Win32 lux.sln

msbuild /nologo /p:Configuration=Console;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Luxmerge;Platform=Win32 lux.sln

echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building Completed                                              *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************
