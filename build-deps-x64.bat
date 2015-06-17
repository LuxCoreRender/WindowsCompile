@Echo off

echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo This script will use 3 pre-built binaries to help build LuxRender:
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
CALL:checkEnvVarValid "LUX_X64_BOOST_ROOT"     || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_BZIP_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_CMAKE_ROOT"     || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_FFTW_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_FREEIMAGE_ROOT" || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_GLUT_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_GLEW_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_ILMBASE_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_JPEG_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_LIBPNG_ROOT"    || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_LIBTIFF_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OIIO_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OPENEXR_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OPENJPEG_ROOT"  || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_PYTHON3_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_QT_ROOT"        || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_ZLIB_ROOT"      || EXIT /b -1

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
echo *        Building For x64                                                *
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
set BUILD_DEBUG=0
set /P BUILD_DEBUG="Selection? "
IF %BUILD_DEBUG% EQU 0 GOTO SetConfiguration
IF %BUILD_DEBUG% EQU 1 GOTO SetConfiguration
echo Invalid choice
GOTO DebugChoice


:SetConfiguration
IF %BUILD_DEBUG% EQU 0 set BUILD_CONFIGURATION=Release
IF %BUILD_DEBUG% EQU 1 set BUILD_CONFIGURATION=Debug

set LUX_WINDOWS_DEPS_ROOT=%LUX_DEPS_ROOT%\..\windows_deps
set INSTALL_DIR=%LUX_WINDOWS_DEPS_ROOT%\x64\%BUILD_CONFIGURATION%

set LIB_DIR=%INSTALL_DIR%\lib
mkdir %LIB_DIR%
set INCLUDE_DIR=%INSTALL_DIR%\..\..\include
mkdir %INCLUDE_DIR%
set BIN_DIR=%INSTALL_DIR%\..\..\bin
mkdir %BIN_DIR%

:: Make junction to include dir for braindead cmake scripts
rd %INSTALL_DIR%\include
mklink /j %INSTALL_DIR%\include %INCLUDE_DIR%

set CMAKE_OPTS=-G "Visual Studio 12 Win64" -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D BUILD_SHARED_LIBS=0 -D BOOST_ROOT="%LUX_X64_BOOST_ROOT%" -D ZLIB_ROOT="%LUX_X64_ZLIB_ROOT%" -D Boost_USE_STATIC_LIBS=1 -D QT_QMAKE_EXECUTABLE="%LUX_X64_QT_ROOT%\bin\qmake"

set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:quiet /toolsversion:12.0 /property:"PlatformToolset=v120" /property:"Platform=x64" /property:ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props /target:"Clean"
set MSBUILD_RELEASE_OPTS=/property:"WholeProgramOptimization=True"
set MSBUILD_DEBUG_OPTS=

IF %BUILD_DEBUG% EQU 0 set MSBUILD_OPTS=%MSBUILD_OPTS% %MSBUILD_RELEASE_OPTS%
IF %BUILD_DEBUG% EQU 1 set MSBUILD_OPTS=%MSBUILD_OPTS% %MSBUILD_DEBUG_OPTS%


:BuildDepsChoice
echo.
echo Build options:
echo 1: Build all dependencies (default)
echo 2: Build all but Qt
echo q: Quit (do nothing)
echo.
set BUILDCHOICE=1
set /P BUILDCHOICE="Selection? "
IF %BUILDCHOICE% EQU 1 GOTO StartBuild
IF %BUILDCHOICE% EQU 2 GOTO StartBuild
IF /I %BUILDCHOICE% EQU q GOTO:EOF
echo Invalid choice
GOTO BuildDepsChoice


:StartBuild
IF %BUILDCHOICE% EQU 2 GOTO NotQT


:: ****************************************************************************
:: ********************************** QT **************************************
:: ****************************************************************************
:QT
echo.
echo **************************************************************************
echo * Building Qt                                                            *
echo **************************************************************************
cd /d %LUX_X64_QT_ROOT%
echo.
echo Cleaning Qt, this may take a few moments...
nmake confclean 1>NUL 2>NUL
echo.
echo Building Qt may take a very long time! The Qt configure utility will now 
echo ask you a few questions before building commences. The rest of the build 
echo process should be autonomous.
pause

set BUILD_CONFIGURATION_QT=-release -ltcg
IF %BUILD_CONFIGURATION%==Debug set BUILD_CONFIGURATION_QT=-debug

configure -opensource -fast -mp -nomake demos -nomake examples -no-multimedia -no-phonon -no-phonon-backend -no-audio-backend -no-webkit -no-script -no-scripttools -no-qt3support %BUILD_CONFIGURATION_QT%
if ERRORLEVEL 1 goto :EOF

nmake
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Qt
CALL:xcopyFiles include\*.* %INCLUDE_DIR%\Qt\include
CALL:xcopyFiles src\*.h?? %INCLUDE_DIR%\Qt\src
CALL:copyFile lib\qtmain.lib %LIB_DIR%
CALL:copyFile lib\QtCore4.lib %LIB_DIR%
CALL:copyFile lib\QtCore4.dll %LIB_DIR%
CALL:copyFile lib\QtGui4.lib %LIB_DIR%
CALL:copyFile lib\QtGui4.dll %LIB_DIR%
CALL:copyFile lib\QtNetwork4.lib %LIB_DIR%
CALL:copyFile lib\QtNetwork4.dll %LIB_DIR%
CALL:copyFile bin\qmake.exe %LIB_DIR%
CALL:copyFile bin\moc.exe %LIB_DIR%
CALL:copyFile bin\uic.exe %LIB_DIR%
CALL:copyFile bin\rcc.exe %LIB_DIR%

:NotQT
:: ****************************************************************************
:: ******************************* PYTHON *************************************
:: ****************************************************************************
:Python
echo.
echo **************************************************************************
echo * Building Python 3                                                      *
echo **************************************************************************
cd /d %LUX_X64_PYTHON3_ROOT%\PCbuild
CALL:copyFile ..\PC\pyconfig.h ..\Include

rem Update pymath.h
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch ..\include\pymath.h %LUX_WINDOWS_BUILD_ROOT%\support\pymath.h.patch

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"python" pcbuild.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Python3
CALL:copyFile ..\include\*.h %INCLUDE_DIR%\Python3
CALL:copyFile amd64\python34.lib %LIB_DIR%
CALL:copyFile amd64\python34.dll %LIB_DIR%

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
type %LUX_WINDOWS_BUILD_ROOT%\support\x64-project-config-3.jam >> project-config.jam
set BJAM_OPTS=-a -q -j%NUMBER_OF_PROCESSORS% address-model=64 link=static threading=multi runtime-link=shared --with-date_time --with-filesystem --with-iostreams --with-locale --with-program_options --with-python --with-regex --with-serialization --with-system --with-thread -sBZIP2_SOURCE=%LUX_X64_BZIP_ROOT% -sPYTHON_SOURCE=%LUX_X64_PYTHON3_ROOT% -sZLIB_SOURCE=%LUX_X64_ZLIB_ROOT%

set BUILD_CONFIGURATION_BOOST=release
IF %BUILD_CONFIGURATION%==Debug set BUILD_CONFIGURATION_BOOST=debug

bjam %BJAM_OPTS% variant=%BUILD_CONFIGURATION_BOOST% stage
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Boost
mkdir %INCLUDE_DIR%\Boost\boost
CALL:xcopyFiles boost\*.* %INCLUDE_DIR%\Boost\boost
CALL:copyFile stage\lib\*.lib %LIB_DIR%

:: ****************************************************************************
:: ********************************** freeglut ********************************
:: ****************************************************************************
:freeglut
echo.
echo **************************************************************************
echo * Building freeglut
echo **************************************************************************
cd /d %LUX_X64_GLUT_ROOT%

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%_Static" /target:"freeglut" VisualStudio\2012\freeglut.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\GL
CALL:xcopyFiles include\GL\*.h %INCLUDE_DIR%\GL
CALL:copyFile lib\x64\* %LIB_DIR%


:: ****************************************************************************
:: ********************************** FFTW ************************************
:: ****************************************************************************
:FFTW
echo.
echo **************************************************************************
echo * Building FFTW
echo **************************************************************************
cd /d %LUX_X64_FFTW_ROOT%

msbuild %MSBUILD_OPTS% /property:"Configuration=Static-%BUILD_CONFIGURATION%" /target:"libfftw-3_3" fftw-3.3-libs\fftw-3.3-libs.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile api\fftw3.h %INCLUDE_DIR%
CALL:copyFile fftw-3.3-libs\x64\Static-%BUILD_CONFIGURATION%\libfftw-3.3.lib %LIB_DIR%\fftw3.lib


:: ****************************************************************************
:: ********************************** GLEW ************************************
:: ****************************************************************************
:GLEW
echo.
echo **************************************************************************
echo * Building GLEW
echo **************************************************************************
cd /d %LUX_X64_GLEW_ROOT%

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"glew_static" build\vc10\glew.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\GL
CALL:xcopyFiles include\GL\*.h %INCLUDE_DIR%\GL
IF %BUILD_CONFIGURATION%==Release CALL:copyFile lib\Release\x64\glew32s.lib %LIB_DIR%\glew32.lib
IF %BUILD_CONFIGURATION%==Debug   CALL:copyFile lib\Debug\x64\glew32sd.lib %LIB_DIR%\glew32.lib


:: ****************************************************************************
:: ************************************ JPEG **********************************
:: ****************************************************************************
:JPEG
echo.
echo **************************************************************************
echo * Building JPEG
echo **************************************************************************
cd /d %LUX_X64_JPEG_ROOT%

CALL:copyFile %LUX_WINDOWS_BUILD_ROOT%\support\jpeg.sln .
CALL:copyFile %LUX_WINDOWS_BUILD_ROOT%\support\jpeg.vcxproj .
CALL:copyFile jconfig.vc jconfig.h

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"jpeg" jpeg.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile *.h %INCLUDE_DIR%
CALL:copyFile x64\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%


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
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"zlibstatic" zlib.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile ..\zconf.h.included ..\zconf.h

CALL:copyFile zconf.h %INCLUDE_DIR%
CALL:copyFile ..\zlib.h %INCLUDE_DIR%

IF %BUILD_CONFIGURATION%==Release CALL:copyFile %BUILD_CONFIGURATION%\zlibstatic.lib %LIB_DIR%\zlib1.lib
IF %BUILD_CONFIGURATION%==Debug   CALL:copyFile %BUILD_CONFIGURATION%\zlibstaticd.lib %LIB_DIR%\zlib1.lib


:: ****************************************************************************
:: *********************************** IlmBase ********************************
:: ****************************************************************************
:IlmBase
echo.
echo **************************************************************************
echo * Building IlmBase
echo **************************************************************************
cd /d %LUX_X64_ILMBASE_ROOT%

rmdir /s /q build
mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"Half" /target:"IlmThread" /target:"Imath" ilmbase.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\OpenEXR
CALL:copyFile ..\config\*.h %INCLUDE_DIR%\OpenEXR
CALL:copyFile ..\Half\*.h %INCLUDE_DIR%\OpenEXR
CALL:copyFile ..\Iex\*.h %INCLUDE_DIR%\OpenEXR
CALL:copyFile ..\IlmThread\*.h %INCLUDE_DIR%\OpenEXR
CALL:copyFile ..\Imath\*.h %INCLUDE_DIR%\OpenEXR

CALL:copyFile Half\%BUILD_CONFIGURATION%\Half.lib %LIB_DIR%
CALL:copyFile Iex\%BUILD_CONFIGURATION%\Iex-2_2.lib %LIB_DIR%\Iex.lib
CALL:copyFile IlmThread\%BUILD_CONFIGURATION%\IlmThread-2_2.lib %LIB_DIR%\IlmThread.lib
CALL:copyFile Imath\%BUILD_CONFIGURATION%\Imath-2_2.lib %LIB_DIR%\Imath.lib


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
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"png16_static" libpng.sln
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

rem Update project files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch nmake.opt %LUX_WINDOWS_BUILD_ROOT%\support\libtiff.nmake.opt.patch

nmake /f Makefile.vc Clean
if ERRORLEVEL 1 goto :EOF

IF %BUILD_CONFIGURATION%==Release nmake /f Makefile.vc 
IF %BUILD_CONFIGURATION%==Debug nmake /f Makefile.vc DEBUG=1

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

rem Update project files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch CMakeLists.txt %LUX_WINDOWS_BUILD_ROOT%\support\openexr-2.2.0.CMakeLists.txt.patch

rmdir /s /q build
mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 -D ILMBASE_PACKAGE_PREFIX="%INSTALL_DIR%" ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"IlmImf" openexr.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\OpenEXR
CALL:copyFile ..\IlmImf\*.h %INCLUDE_DIR%\OpenEXR
CALL:copyFile ..\config\OpenEXRConfig.h %INCLUDE_DIR%\OpenEXR
CALL:copyFile IlmImf\%BUILD_CONFIGURATION%\IlmImf-2_2.lib %LIB_DIR%\IlmImf.lib


:: ****************************************************************************
:: ********************************** OpenJPEG ********************************
:: ****************************************************************************
:OpenJPEG
echo.
echo **************************************************************************
echo * Building OpenJPEG
echo **************************************************************************
cd /d %LUX_X64_OPENJPEG_ROOT%

rmdir /s /q build
mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"openjpeg" openjpeg.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile ..\libopenjpeg\openjpeg.h %INCLUDE_DIR%
CALL:copyFile bin\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%


:: ****************************************************************************
:: ********************************* OpenImageIO ******************************
:: ****************************************************************************
:OpenImageIO
echo.
echo **************************************************************************
echo * Building OpenImageIO                                                    
echo **************************************************************************
cd /d %LUX_X64_OIIO_ROOT%

rem Update project files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch src\cmake\modules\FindOpenJpeg.cmake %LUX_WINDOWS_BUILD_ROOT%\support\FindOpenJpeg.cmake.patch

rem Update source files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\openimageio-1.4.12.patch

rmdir /s /q build
mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% -D LINKSTATIC=1 -D USE_PYTHON=0 ..
if ERRORLEVEL 1 goto :EOF

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"OpenImageIO" OpenImageIO.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\OpenImageIO
CALL:copyFile ..\src\include\OpenImageIO\*.h %INCLUDE_DIR%\OpenImageIO
CALL:copyFile include\OpenImageIO\oiioversion.h %INCLUDE_DIR%\OpenImageIO
CALL:copyFile src\libOpenImageIO\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%
CALL:copyFile src\libOpenImageIO\%BUILD_CONFIGURATION%\*.dll %LIB_DIR%


:: ****************************************************************************
:: ********************************** FreeImage *******************************
:: ****************************************************************************
:FreeImage
echo.
echo **************************************************************************
echo * Building FreeImage
echo **************************************************************************
cd /d %LUX_X64_FREEIMAGE_ROOT%\FreeImage

rem Install solution and project files for VS2013
CALL:xcopyFiles %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage\*.* .

rem Update source files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage-3.16.0.patch

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"FreeImageLib" FreeImage.2013.sln
if ERRORLEVEL 1 goto :EOF

CALL:copyFile Source\FreeImage.h %INCLUDE_DIR%
CALL:copyFile Dist\FreeImage.lib %LIB_DIR%\FreeImage.lib

:: ****************************************************************************
:: ******************************** CMake *************************************
:: ****************************************************************************
:CMake
echo.
echo **************************************************************************
echo * Copying CMake
echo **************************************************************************
cd /d %LUX_X64_CMAKE_ROOT%
CALL:xcopyFiles *.* %BIN_DIR%\CMake

:postLuxRender
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
