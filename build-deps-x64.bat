@Echo off

echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo This script will use 3 pre-built binaries to help build dependencies
echo for LuxCoreRender:
echo  1: win_flex.exe       from http://sourceforge.net/projects/winflexbison/
echo  2: win_bison.exe      from http://sourceforge.net/projects/winflexbison/
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

CALL:checkEnvVarValid "LUX_WINDOWS_BUILD_ROOT" || EXIT /b -1
CALL:checkEnvVarValid "LUX_DEPS_ROOT"          || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_BLOSC_ROOT"     || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_BOOST_ROOT"     || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_BZIP_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_EMBREE_ROOT"      || EXIT /b -1
::CALL:checkEnvVarValid "LUX_X64_FREEIMAGE_ROOT" || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_JPEG_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_LIBPNG_ROOT"    || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_LIBTIFF_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_NUMPY311_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OIDN_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OIIO_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OPENEXR_ROOT"   || EXIT /b -1
::CALL:checkEnvVarValid "LUX_X64_OPENJPEG_ROOT"  || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_PYTHON311_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_TBB_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_ZLIB_ROOT"      || EXIT /b -1

set MSBUILD_VERSION=
FOR /f "tokens=1,2 delims=." %%a IN ('msbuild /nologo /version') DO set MSBUILD_VERSION_MAJOR=%%a
IF "%MSBUILD_VERSION_MAJOR%" NEQ "16" (
	echo.
	echo Could not find 'msbuild' version 15.
	echo Please run this script from the Visual Studio 2017 Command Prompt.
	echo Generated libraries will be usable also with Visual Studio 2019.
	EXIT /b -1
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

:StartChoice
echo.
echo WARNING: building dependencies is normally not needed to build
echo LuxCoreRender, you can just follow the instructions at:
echo https://github.com/LuxCoreRender/WindowsCompile
echo.
echo If you really need to build dependencies, answer the following questions,
echo otherwise PRESS CTRL-C NOW to exit this script.
echo.


:PythonChoice
echo.
echo Choose the version of Python used to build Boost.Python
echo Available options:
echo      S - Use system available version (see note)
echo     311 - Use Python 3.11 with NumPy 1.15.4
echo.
echo     NOTE: Recomended choice if you have installed a python version that
echo           you would like to use.
echo           To use system Python, its location must be listed in the PATH
echo           environment variable. The NumPy package must also be installed
echo           (with 'pip install numpy') or Boost.Numpy will not be built.
echo           Not all Python versions are supported:
echo           2.7, 3.5 and greater should work.
echo.
set PYTHON_CHOICE=0
set /P PYTHON_CHOICE="Python version? "
if %PYTHON_CHOICE% EQU s set PYTHON_CHOICE=S
if %PYTHON_CHOICE% EQU S (
    set BUILD_PYTHON=NO
    for /f "usebackq delims=" %%a in (`python -c "import sysconfig; import os; print(sysconfig.get_config_var('installed_base'))"`) do SET LUX_X64_PYTHON_ROOT=%%a
    for /f "usebackq" %%b in (`python -c "import sysconfig; print(sysconfig.get_config_var('VERSION'))"`) do set PYTHON_V=%%b
    echo %LUX_X64_PYTHON_ROOT%
    echo %PYTHON_V%
    goto DebugChoice
)
if %PYTHON_CHOICE% EQU 311 (
    set LUX_X64_PYTHON_ROOT=%LUX_X64_PYTHON311_ROOT%
    set LUX_X64_NUMPY_ROOT=%LUX_X64_NUMPY311_ROOT%
    goto DebugChoice
)
echo Invalid choice
goto PythonChoice

:DebugChoice
echo.
echo Build Debug binaries?
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

set LUX_WINDOWS_DEPS_ROOT=%LUX_DEPS_ROOT%\..\BuiltDeps
set INSTALL_DIR=%LUX_WINDOWS_DEPS_ROOT%\x64\%BUILD_CONFIGURATION%

set LIB_DIR=%INSTALL_DIR%\lib
mkdir %LIB_DIR%
set INCLUDE_DIR=%INSTALL_DIR%\..\..\include
mkdir %INCLUDE_DIR%

:: Make junction to include dir for braindead cmake scripts
rd %INSTALL_DIR%\include
mklink /j %INSTALL_DIR%\include %INCLUDE_DIR%

rem set CMAKE_OPTS=-G "Visual Studio 15 2017" -T v141,host=x64 -A x64 -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D BUILD_SHARED_LIBS=0 -D BOOST_ROOT="%LUX_X64_BOOST_ROOT%" -D ZLIB_ROOT="%LUX_X64_ZLIB_ROOT%" -D Boost_USE_STATIC_LIBS=1 -D QT_QMAKE_EXECUTABLE="%LUX_X64_QT_ROOT%\bin\qmake"
set CMAKE_OPTS=-G "Visual Studio 16 2019" -T v142,host=x64 -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D BUILD_SHARED_LIBS=0 -D BOOST_ROOT="%LUX_X64_BOOST_ROOT%" -D ZLIB_ROOT="%LUX_X64_ZLIB_ROOT%" -D Boost_USE_STATIC_LIBS=1 -D QT_QMAKE_EXECUTABLE="%LUX_X64_QT_ROOT%\bin\qmake"

set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:quiet /toolsversion:Current /property:"PlatformToolset=v142" /property:"Platform=x64" /property:ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props /target:"Clean"
REM set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:quiet /property:"Platform=x64" /property:ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props /target:"Clean"
set MSBUILD_RELEASE_OPTS=/property:"WholeProgramOptimization=False"
set MSBUILD_DEBUG_OPTS=

IF %BUILD_DEBUG% EQU 0 set MSBUILD_OPTS=%MSBUILD_OPTS% %MSBUILD_RELEASE_OPTS%
IF %BUILD_DEBUG% EQU 1 set MSBUILD_OPTS=%MSBUILD_OPTS% %MSBUILD_DEBUG_OPTS%


:BuildDepsChoice
echo.
echo Build options:
echo 1: Build all dependencies
echo q: Quit (do nothing)
echo.
set BUILDCHOICE=q
set /P BUILDCHOICE="Selection? "
IF %BUILDCHOICE% EQU 1 GOTO StartBuild
IF /I %BUILDCHOICE% EQU q GOTO:EOF
echo Invalid choice
GOTO BuildDepsChoice


:StartBuild
echo.
echo To use the freshly built dependencies for a standard LuxCoreRender build,
echo rename folder 'BuiltDeps' to 'WindowsCompileDeps'.
echo.

:: ****************************************************************************
:: ****************************************************************************
:: ******************************* BOOST **************************************
:: ****************************************************************************
:Boost
echo.
echo **************************************************************************
echo * Building Boost::DateTime                                               *
echo *          Boost::FileSystem                                             *
echo *          Boost::IOStreams                                              *
echo *          Boost::Locale                                                 *
echo *          Boost::Program_Options                                        *
echo *          Boost::Python                                                 *
echo *          Boost::Regex                                                  *
echo *          Boost::Serialization                                          *
echo *          Boost::System                                                 *
echo *          Boost::Thread                                                 *
echo **************************************************************************
cd /d %LUX_X64_BOOST_ROOT%

CALL bootstrap.bat
CALL:copyfile project-config.jam .\project-config.bck
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch libs\python\src\exec.cpp %LUX_WINDOWS_BUILD_ROOT%\support\boost.python-1.72.0.patch

b2 --clean
rd /q /s stage
set BJAM_OPTS=-a -q -j%NUMBER_OF_PROCESSORS% address-model=64 link=static threading=multi runtime-link=shared --with-date_time --with-filesystem --with-iostreams --with-locale --with-program_options --with-python --with-regex --with-serialization --with-system --with-thread -sBZIP2_SOURCE=%LUX_X64_BZIP_ROOT% -sZLIB_SOURCE=%LUX_X64_ZLIB_ROOT%
if "%PYTHON_CHOICE%" NEQ "S" (
    set BJAM_OPTS=%BJAM_OPTS% -sPYTHON_SOURCE="%LUX_X64_PYTHON_ROOT%"
    type %LUX_WINDOWS_BUILD_ROOT%\support\x64-project-config-%PYTHON_CHOICE%.jam >> project-config.jam
    CALL:xcopyFiles %LUX_X64_NUMPY_ROOT%\numpy\*.* %LUX_X64_PYTHON_ROOT%\Lib\site-packages\numpy
)
echo %BJAM_OPTS%
set BUILD_CONFIGURATION_BOOST=release
IF %BUILD_CONFIGURATION%==Debug set BUILD_CONFIGURATION_BOOST=debug

b2 %BJAM_OPTS% toolset=msvc-14.2 variant=%BUILD_CONFIGURATION_BOOST% stage
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Boost
mkdir %INCLUDE_DIR%\Boost\boost
CALL:xcopyFiles boost\*.* %INCLUDE_DIR%\Boost\boost
CALL:copyFile stage\lib\*.lib %LIB_DIR%


:: ****************************************************************************
:: ************************************ JPEG **********************************
:: ****************************************************************************
:JPEG
echo.
echo **************************************************************************
echo * Building JPEG
echo **************************************************************************
cd /d %LUX_X64_JPEG_ROOT%

%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch makejvcx.v16 %LUX_WINDOWS_BUILD_ROOT%\support\makejvcx.v16.patch

nmake /f makefile.vs setupcopy-v16
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"jpeg" jpeg.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile *.h %INCLUDE_DIR%
CALL:copyFile %BUILD_CONFIGURATION%\x64\*.lib %LIB_DIR%


:: ****************************************************************************
:: ************************************ zlib **********************************
:: ****************************************************************************
:zlib
echo.
echo **************************************************************************
echo * Building zlib
echo **************************************************************************
cd /d %LUX_X64_ZLIB_ROOT%

rmdir /s /q build
mkdir build
cd build
cmake %CMAKE_OPTS% ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"zlibstatic" zlib.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile ..\zconf.h.included ..\zconf.h

CALL:copyFile zconf.h %INCLUDE_DIR%
CALL:copyFile ..\zlib.h %INCLUDE_DIR%

IF %BUILD_CONFIGURATION%==Release CALL:copyFile %BUILD_CONFIGURATION%\zlibstatic.lib %LIB_DIR%\zlib1.lib
IF %BUILD_CONFIGURATION%==Debug   CALL:copyFile %BUILD_CONFIGURATION%\zlibstaticd.lib %LIB_DIR%\zlib1.lib


:: ****************************************************************************
:: *********************************** libPNG *********************************
:: ****************************************************************************
:libPNG
echo.
echo **************************************************************************
echo * Building libPNG
echo **************************************************************************
cd /d %LUX_X64_LIBPNG_ROOT%

rmdir /s /q build
mkdir build
cd build
cmake %CMAKE_OPTS% ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"png_static" libpng.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile ..\*.h %INCLUDE_DIR%
CALL:copyFile pnglibconf.h %INCLUDE_DIR%

IF %BUILD_CONFIGURATION%==Release CALL:copyFile %BUILD_CONFIGURATION%\libpng16_static.lib %LIB_DIR%\libpng.lib
IF %BUILD_CONFIGURATION%==Debug   CALL:copyFile %BUILD_CONFIGURATION%\libpng16_staticd.lib %LIB_DIR%\libpng.lib


:: ****************************************************************************
:: ********************************** libTIFF *********************************
:: ****************************************************************************
:libTIFF
echo.
echo **************************************************************************
echo * Building libTIFF
echo **************************************************************************
cd /d %LUX_X64_LIBTIFF_ROOT%

%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch nmake.opt %LUX_WINDOWS_BUILD_ROOT%\support\libtiff.nmake.opt.patch

nmake /f Makefile.vc Clean
if ERRORLEVEL 1 goto :EOF

IF %BUILD_CONFIGURATION%==Release (
	nmake /f Makefile.vc 
	if ERRORLEVEL 1 goto :EOF
)
IF %BUILD_CONFIGURATION%==Debug (
	nmake /f Makefile.vc DEBUG=1
	if ERRORLEVEL 1 goto :EOF
)

CALL:copyFile libtiff\*.h %INCLUDE_DIR%
CALL:copyFile libtiff\libtiff.lib %LIB_DIR%


:: ****************************************************************************
:: *********************************** OpenEXR ********************************
:: ****************************************************************************
:OpenEXR
echo.
echo **************************************************************************
echo * Building OpenEXR
echo **************************************************************************
cd /d %LUX_X64_OPENEXR_ROOT%

rmdir /s /q build-IlmBase
mkdir build-IlmBase
cd build-IlmBase
cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 -D BUILD_TESTING=0 -D CMAKE_INSTALL_PREFIX=%LUX_WINDOWS_DEPS_ROOT%\OpenEXR ..\IlmBase
if ERRORLEVEL 1 goto :EOF

rem cmake --build . --target install --config Release -- /toolsversion:15.0 /property:"PlatformToolset=v141" /property:"Platform=x64" /property:"ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props"
cmake --build . --target install --config Release -- /property:"Platform=x64" /property:"ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props"
if ERRORLEVEL 1 goto :EOF

cd ..
rmdir /s /q build-OpenEXR
mkdir build-OpenEXR
cd build-OpenEXR

cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 -D BUILD_TESTING=0 -D CMAKE_SYSTEM_PREFIX=%LUX_WINDOWS_DEPS_ROOT%\OpenEXR -D CMAKE_INSTALL_PREFIX=%LUX_WINDOWS_DEPS_ROOT%\OpenEXR ..\OpenEXR
if ERRORLEVEL 1 goto :EOF

rem cmake --build . --target install --config Release -- /toolsversion:15.0 /property:"PlatformToolset=v141" /property:"Platform=x64" /property:"ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props"
cmake --build . --target install --config Release -- /property:"Platform=x64" /property:"ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props"
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\OpenEXR
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\include\OpenEXR\*.h %INCLUDE_DIR%\OpenEXR
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\lib\Half-2_4.lib %LIB_DIR%\Half.lib
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\lib\Iex-2_4.lib %LIB_DIR%\Iex.lib
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\lib\IexMath-2_4.lib %LIB_DIR%\IexMath.lib
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\lib\IlmThread-2_4.lib %LIB_DIR%\IlmThread.lib
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\lib\Imath-2_4.lib %LIB_DIR%\Imath.lib
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\lib\IlmImf-2_4.lib %LIB_DIR%\IlmImf.lib
CALL:copyFile %LUX_WINDOWS_DEPS_ROOT%\OpenEXR\lib\IlmImfUtil-2_4.lib %LIB_DIR%\IlmImfUtil.lib


:: ****************************************************************************
:: ********************************** OpenJPEG ********************************
:: ****************************************************************************
REM :OpenJPEG
REM echo.
REM echo **************************************************************************
REM echo * Building OpenJPEG
REM echo **************************************************************************
REM cd /d %LUX_X64_OPENJPEG_ROOT%

REM rmdir /s /q build
REM mkdir build
REM cd build
REM cmake %CMAKE_OPTS% ..
REM if ERRORLEVEL 1 goto :EOF

REM msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"openjpeg" openjpeg.sln
REM if ERRORLEVEL 1 goto :EOF

REM CALL:copyFile ..\libopenjpeg\openjpeg.h %INCLUDE_DIR%
REM CALL:copyFile bin\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%


:: ****************************************************************************
:: ********************************* OpenImageIO ******************************
:: ****************************************************************************
:OpenImageIO
echo.
echo **************************************************************************
echo * Building OpenImageIO                                                    
echo **************************************************************************
cd /d %LUX_X64_OIIO_ROOT%

rmdir /s /q build
mkdir build
cd build
cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 -D LINKSTATIC=1 -D USE_FFMPEG=0 -D USE_PYTHON=0 -D USE_TBB=0 -D USE_OPENGL=0 -D USE_QT=0 -D USE_GIF=0 -D USE_OPENJPEG=0 -D USE_OPENSSL=0 -D USE_FIELD3D=0 -D USE_OCIO=0 -D USE_OPENCV=0 -D OIIO_BUILD_TOOLS=0 -D OIIO_BUILD_TESTS=0 ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"OpenImageIO" OpenImageIO.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\OpenImageIO
CALL:xcopyFiles ..\src\include\OpenImageIO\*.* %INCLUDE_DIR%\OpenImageIO
CALL:xcopyFiles include\OpenImageIO\detail\*.* %INCLUDE_DIR%\OpenImageIO\detail
CALL:copyFile include\OpenImageIO\oiioversion.h %INCLUDE_DIR%\OpenImageIO
CALL:copyFile lib\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%
rem CALL:copyFile lib\%BUILD_CONFIGURATION%\*.dll %LIB_DIR%


:: ****************************************************************************
:: ********************************** FreeImage *******************************
:: ****************************************************************************
REM :FreeImage
REM echo.
REM echo **************************************************************************
REM echo * Building FreeImage
REM echo **************************************************************************
REM cd /d %LUX_X64_FREEIMAGE_ROOT%\FreeImage

REM REM Install solution and project files for VS2013
REM CALL:xcopyFiles %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage\*.* .

REM REM Update source files
REM %LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage-3.16.0.patch

REM msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"FreeImageLib" FreeImage.2013.sln
REM if ERRORLEVEL 1 goto :EOF

REM CALL:copyFile Source\FreeImage.h %INCLUDE_DIR%
REM CALL:copyFile Dist\FreeImage.lib %LIB_DIR%\FreeImage.lib


:: ****************************************************************************
:: *********************************** embree *********************************
:: ****************************************************************************
:embree
echo.
echo **************************************************************************
echo * Copying embree files
echo **************************************************************************
cd /d %LUX_X64_EMBREE_ROOT%

rem Not necessary to build embree, we copy files from binary distribution
CALL:copyFile bin\embree3.dll %LIB_DIR%\embree3.dll
CALL:copyFile bin\tbb12.dll %LIB_DIR%\tbb12.dll
CALL:copyFile lib\embree3.lib %LIB_DIR%\embree3.lib
CALL:copyFile lib\tbb.lib %LIB_DIR%\tbb12.lib

mkdir %INCLUDE_DIR%\embree3
CALL:copyFile include\embree3\*.* %INCLUDE_DIR%\embree3


:: ****************************************************************************
:: ****************************** OpenImageDenoise ****************************
:: ****************************************************************************
:oidn
echo.
echo **************************************************************************
echo * Copying OpenImageDenoise files
echo **************************************************************************
cd /d %LUX_X64_OIDN_ROOT%

rem Not necessary to build OIDN, we copy files from binary distribution
rem This also overwrites tbb and tbbmalloc libraries with the OIDN version
CALL:copyFile bin\*.dll %LIB_DIR%
CALL:copyFile bin\oidnDenoise.exe %LIB_DIR%
CALL:copyFile lib\OpenImageDenoise.lib %LIB_DIR%
CALL:copyFile lib\tbb.lib %LIB_DIR%\tbb12.lib

mkdir %INCLUDE_DIR%\OpenImageDenoise
CALL:copyFile include\OpenImageDenoise\*.* %INCLUDE_DIR%\OpenImageDenoise


:: ****************************************************************************
:: ************************************* tbb **********************************
:: ****************************************************************************
:tbb
echo.
echo **************************************************************************
echo * Copying tbb files
echo **************************************************************************
cd /d %LUX_X64_TBB_ROOT%

rem Not necessary to build tbb, we copy files from binary distribution
CALL:copyFile lib\intel64\vc14\tbb.lib %LIB_DIR%\tbb.lib
CALL:copyFile bin\intel64\vc14\tbb.dll %LIB_DIR%\tbb.dll
CALL:copyFile lib\intel64\vc14\tbbmalloc.lib %LIB_DIR%\tbbmalloc.lib
CALL:copyFile bin\intel64\vc14\tbbmalloc.dll %LIB_DIR%\tbbmalloc.dll
CALL:copyFile lib\intel64\vc14\tbbproxy.lib %LIB_DIR%\tbbproxy.lib

mkdir %INCLUDE_DIR%\serial
mkdir %INCLUDE_DIR%\serial\tbb
CALL:xcopyFiles include\serial\*.* %INCLUDE_DIR%\serial

mkdir %INCLUDE_DIR%\tbb
CALL:xcopyFiles include\tbb\*.* %INCLUDE_DIR%\tbb


:: ****************************************************************************
:: ************************************ blosc *********************************
:: ****************************************************************************
:blosc
echo.
echo **************************************************************************
echo * Building blosc
echo **************************************************************************
cd /d %LUX_X64_BLOSC_ROOT%

rmdir /s /q build
mkdir build
cd build
cmake %CMAKE_OPTS% -DPREFER_EXTERNAL_ZLIB=ON -DBUILD_TESTS=OFF ..
if ERRORLEVEL 1 goto :EOF

cmake --build . --config %BUILD_CONFIGURATION%
if ERRORLEVEL 1 goto :EOF

CALL:copyFile ..\blosc\blosc.h %INCLUDE_DIR%\blosc.h
CALL:copyFile ..\blosc\blosc-export.h %INCLUDE_DIR%\blosc-export.h
CALL:copyFile blosc\%BUILD_CONFIGURATION%\libblosc.lib %LIB_DIR%\libblosc.lib


:postLuxCoreRender
:: ****************************************************************************
:: *********************************** Finished *******************************
:: ****************************************************************************
rd %INSTALL_DIR%\include
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

:xcopyFiles
:: Copy files recursively
:: %1 - Source filemask
:: %2 - Desination directory

SETLOCAL
xcopy /y /s /i %1 %2
if ERRORLEVEL 1 EXIT /b 1
ENDLOCAL
GOTO:EOF

:copyFile
:: Copy single file
:: %1 - Source filename
:: %2 - Desination filename

SETLOCAL
copy /y /v %1 %2
if ERRORLEVEL 1 EXIT /b 1
ENDLOCAL
GOTO:EOF
