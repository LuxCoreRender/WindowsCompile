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
CALL:checkEnvVarValid "LUX_WINDOWS_DEPS_ROOT"  || EXIT /b -1
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

set INSTALL_DIR=%LUX_WINDOWS_DEPS_ROOT%\x64\%BUILD_CONFIGURATION%
set CMAKE_OPTS=-G "Visual Studio 12 Win64" -D CMAKE_PREFIX_PATH="%INSTALL_DIR%" -D BUILD_SHARED_LIBS=0 -D BOOST_ROOT="%LUX_X64_BOOST_ROOT%" -D Boost_USE_STATIC_LIBS=1 -D QT_QMAKE_EXECUTABLE="%LUX_X64_QT_ROOT%\bin\qmake"

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
IF %BUILDCHOICE% EQU 1 GOTO SetupInstallDirectories
IF %BUILDCHOICE% EQU 2 GOTO SetupInstallDirectories
IF /I %BUILDCHOICE% EQU q GOTO:EOF
echo Invalid choice
GOTO BuildDepsChoice


:SetupInstallDirectories
set LIB_DIR=%INSTALL_DIR%\lib
set INCLUDE_DIR=%INSTALL_DIR%\include
mkdir %LIB_DIR%
mkdir %INCLUDE_DIR%
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
nmake


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
copy ..\PC\pyconfig.h ..\Include

rem Update pymath.h
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch ..\include\pymath.h %LUX_WINDOWS_BUILD_ROOT%\support\pymath.h.patch

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"python" pcbuild.sln

mkdir %INCLUDE_DIR%\Python3.3
copy ..\include\*.h %INCLUDE_DIR%\Python3.3
IF %BUILD_CONFIGURATION%==Release copy amd64\python33.lib %LIB_DIR%
IF %BUILD_CONFIGURATION%==Release copy amd64\python33.dll %LIB_DIR%
IF %BUILD_CONFIGURATION%==Debug   copy amd64\python33_d.lib %LIB_DIR%
IF %BUILD_CONFIGURATION%==Debug   copy amd64\python33_d.dll %LIB_DIR%

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

rem Patch Boost 1.55.0 to build Serialization with Visual Studio 2013
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p1 -i %LUX_WINDOWS_BUILD_ROOT%\support\boost_1.55.0.patch

CALL bootstrap.bat
type %LUX_WINDOWS_BUILD_ROOT%\support\x64-project-config-3.jam >> project-config.jam
set BJAM_OPTS=-a -q -j%NUMBER_OF_PROCESSORS% address-model=64 link=static threading=multi runtime-link=shared --with-date_time --with-filesystem --with-iostreams --with-locale --with-program_options --with-python --with-regex --with-serialization --with-system --with-thread -sBZIP2_SOURCE=%LUX_X64_BZIP_ROOT% -sPYTHON_SOURCE=%LUX_X64_PYTHON3_ROOT% -sZLIB_SOURCE=%LUX_X64_ZLIB_ROOT%

set BUILD_CONFIGURATION_BOOST=release
IF %BUILD_CONFIGURATION%==Debug set BUILD_CONFIGURATION_BOOST=debug

bjam %BJAM_OPTS% variant=%BUILD_CONFIGURATION_BOOST% stage


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

mkdir %INCLUDE_DIR%\GL
copy include\GL\*.h %INCLUDE_DIR%\GL
copy lib\x64\* %LIB_DIR%


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

copy api\fftw3.h %INCLUDE_DIR%
copy fftw-3.3-libs\x64\Static-%BUILD_CONFIGURATION%\*.lib %LIB_DIR%


:: ****************************************************************************
:: ********************************** GLEW ************************************
:: ****************************************************************************
:GLEW
echo.
echo **************************************************************************
echo * Building GLEW
echo **************************************************************************
cd /d %LUX_X64_GLEW_ROOT%

rem Update resource file (GLEW git c5a3681eae4be587e7533bf2d13c77e7a1fa7404)
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch build\glew.rc %LUX_WINDOWS_BUILD_ROOT%\support\glew.rc.patch

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"glew_static" build\vc10\glew.sln

mkdir %INCLUDE_DIR%\GL
copy include\GL\*.h %INCLUDE_DIR%\GL
IF %BUILD_CONFIGURATION%==Release copy lib\Release\x64\glew32s.lib %LIB_DIR%\glew32.lib
IF %BUILD_CONFIGURATION%==Debug   copy lib\Debug\x64\glew32sd.lib %LIB_DIR%\glew32.lib


:: ****************************************************************************
:: ************************************ JPEG **********************************
:: ****************************************************************************
:JPEG
echo.
echo **************************************************************************
echo * Building JPEG
echo **************************************************************************
cd /d %LUX_X64_JPEG_ROOT%

copy %LUX_WINDOWS_BUILD_ROOT%\support\jpeg.sln .
copy %LUX_WINDOWS_BUILD_ROOT%\support\jpeg.vcxproj .
copy jconfig.vc jconfig.h

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"jpeg" jpeg.sln

copy *.h %INCLUDE_DIR%
copy x64\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%


:: ****************************************************************************
:: ************************************ zlib **********************************
:: ****************************************************************************
:zlib
echo.
echo **************************************************************************
echo * Building zlib
echo **************************************************************************
cd /d %LUX_X64_ZLIB_ROOT%

mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% ..

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"zlibstatic" zlib.sln

rem Put this back so we can build again if necessary
move ..\zconf.h.included ..\zconf.h

copy zconf.h %INCLUDE_DIR%
copy ..\zlib.h %INCLUDE_DIR%

IF %BUILD_CONFIGURATION%==Release copy %BUILD_CONFIGURATION%\zlibstatic.lib %LIB_DIR%\zlib1.lib
IF %BUILD_CONFIGURATION%==Debug   copy %BUILD_CONFIGURATION%\zlibstaticd.lib %LIB_DIR%\zlib1.lib


:: ****************************************************************************
:: *********************************** IlmBase ********************************
:: ****************************************************************************
:IlmBase
echo.
echo **************************************************************************
echo * Building IlmBase
echo **************************************************************************
cd /d %LUX_X64_ILMBASE_ROOT%

rem Update project files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch CMakeLists.txt %LUX_WINDOWS_BUILD_ROOT%\support\ilmbase-2.1.0.CMakeLists.txt.patch

rem Update source files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch Imath\ImathMatrixAlgo.cpp %LUX_WINDOWS_BUILD_ROOT%\support\ImathMatrixAlgo.cpp.patch

mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 ..

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"Half" /target:"IlmThread" /target:"Imath" ilmbase.sln

mkdir %INCLUDE_DIR%\OpenEXR
copy ..\config\*.h %INCLUDE_DIR%\OpenEXR
copy ..\Half\*.h %INCLUDE_DIR%\OpenEXR
copy ..\Iex\*.h %INCLUDE_DIR%\OpenEXR
copy ..\IlmThread\*.h %INCLUDE_DIR%\OpenEXR
copy ..\Imath\*.h %INCLUDE_DIR%\OpenEXR

copy Half\%BUILD_CONFIGURATION%\Half.lib %LIB_DIR%
copy Iex\%BUILD_CONFIGURATION%\Iex-2_1.lib %LIB_DIR%\Iex.lib
copy IlmThread\%BUILD_CONFIGURATION%\IlmThread-2_1.lib %LIB_DIR%\IlmThread.lib
copy Imath\%BUILD_CONFIGURATION%\Imath-2_1.lib %LIB_DIR%\Imath.lib


:: ****************************************************************************
:: *********************************** libPNG *********************************
:: ****************************************************************************
:libPNG
echo.
echo **************************************************************************
echo * Building libPNG
echo **************************************************************************
cd /d %LUX_X64_LIBPNG_ROOT%

mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% ..

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"png16_static" libpng.sln

copy ..\*.h %INCLUDE_DIR%
copy pnglibconf.h %INCLUDE_DIR%

IF %BUILD_CONFIGURATION%==Release copy %BUILD_CONFIGURATION%\libpng16_static.lib %LIB_DIR%\libpng.lib
IF %BUILD_CONFIGURATION%==Debug   copy %BUILD_CONFIGURATION%\libpng16_staticd.lib %LIB_DIR%\libpng.lib


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
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch nmake.opt %LUX_WINDOWS_BUILD_ROOT%\support\libtiff.nmake.opt.x64.patch

nmake /f Makefile.vc Clean

IF %BUILD_CONFIGURATION%==Release nmake /f Makefile.vc 
IF %BUILD_CONFIGURATION%==Debug nmake /f Makefile.vc DEBUG=1

copy libtiff\*.h %INCLUDE_DIR%
copy libtiff\libtiff.lib %LIB_DIR%


:: ****************************************************************************
:: *********************************** OpenEXR ********************************
:: ****************************************************************************
:OpenEXR
echo.
echo **************************************************************************
echo * Building OpenEXR
echo **************************************************************************
cd /d %LUX_X64_OPENEXR_ROOT%

rem Update source files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\openexr-2.1.0.patch

mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 -D ILMBASE_PACKAGE_PREFIX="%INSTALL_DIR%" ..

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"IlmImf" openexr.sln

mkdir %INCLUDE_DIR%\OpenEXR
copy ..\IlmImf\*.h %INCLUDE_DIR%\OpenEXR
copy ..\config\OpenEXRConfig.h %INCLUDE_DIR%\OpenEXR
copy IlmImf\%BUILD_CONFIGURATION%\IlmImf-2_1.lib %LIB_DIR%\IlmImf.lib


:: ****************************************************************************
:: ********************************** OpenJPEG ********************************
:: ****************************************************************************
:OpenJPEG
echo.
echo **************************************************************************
echo * Building OpenJPEG
echo **************************************************************************
cd /d %LUX_X64_OPENJPEG_ROOT%

mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% ..

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"openjpeg" openjpeg.sln

copy ..\libopenjpeg\openjpeg.h %INCLUDE_DIR%
copy bin\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%


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
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\openimageio-1.3.12.patch

mkdir build
cd build
%LUX_X64_CMAKE_ROOT%\bin\cmake %CMAKE_OPTS% -D LINKSTATIC=1 -D USE_PYTHON=0 ..

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"OpenImageIO" OpenImageIO.sln

mkdir %INCLUDE_DIR%\OpenImageIO
copy ..\src\include\*.h %INCLUDE_DIR%\OpenImageIO
copy include\version.h %INCLUDE_DIR%\OpenImageIO
copy src\libOpenImageIO\%BUILD_CONFIGURATION%\*.lib %LIB_DIR%
copy src\libOpenImageIO\%BUILD_CONFIGURATION%\*.dll %LIB_DIR%


:: ****************************************************************************
:: ********************************** FreeImage *******************************
:: ****************************************************************************
:FreeImage
echo.
echo **************************************************************************
echo * Building FreeImage
echo **************************************************************************
cd /d %LUX_X64_FREEIMAGE_ROOT%\FreeImage

rem Install solution and project files for VS2010
xcopy /S /Y %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage\*.* .

rem Update source files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\FreeImage-3.15.4.patch

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"FreeImage" FreeImage.2010.sln

copy Source\FreeImage.h %INCLUDE_DIR%
copy %BUILD_CONFIGURATION%\*.lib %LIB_DIR%
copy %BUILD_CONFIGURATION%\*.dll %LIB_DIR%


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
