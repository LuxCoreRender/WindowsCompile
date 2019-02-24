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
CALL:checkEnvVarValid "LUX_X64_FREEIMAGE_ROOT" || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_ILMBASE_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_JPEG_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_LIBPNG_ROOT"    || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_LIBTIFF_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_NUMPY35_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_NUMPY36_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_NUMPY37_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OIDN_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OIIO_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OPENEXR_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_OPENJPEG_ROOT"  || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_PYTHON35_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_PYTHON36_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_PYTHON37_ROOT"   || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_QT_ROOT"        || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_TBB_ROOT"      || EXIT /b -1
CALL:checkEnvVarValid "LUX_X64_ZLIB_ROOT"      || EXIT /b -1

set MSBUILD_VERSION=
FOR /f "tokens=1,2 delims=." %%a IN ('msbuild /nologo /version') DO set MSBUILD_VERSION_MAJOR=%%a
IF "%MSBUILD_VERSION_MAJOR%" NEQ "15" (
	echo.
	echo Could not find 'msbuild' version 15.
	echo Please run this script from the Visual Studio 2017 Command Prompt.
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

set LUX_WINDOWS_DEPS_ROOT=%LUX_DEPS_ROOT%\..\BuiltDeps
set INSTALL_DIR=%LUX_WINDOWS_DEPS_ROOT%\x64\%BUILD_CONFIGURATION%

set LIB_DIR=%INSTALL_DIR%\lib
mkdir %LIB_DIR%
set INCLUDE_DIR=%INSTALL_DIR%\..\..\include
mkdir %INCLUDE_DIR%

:: Make junction to include dir for braindead cmake scripts
rd %INSTALL_DIR%\include
mklink /j %INSTALL_DIR%\include %INCLUDE_DIR%

set CMAKE_OPTS=-G "Visual Studio 15 Win64" -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D BUILD_SHARED_LIBS=0 -D BOOST_ROOT="%LUX_X64_BOOST_ROOT%" -D ZLIB_ROOT="%LUX_X64_ZLIB_ROOT%" -D Boost_USE_STATIC_LIBS=1 -D QT_QMAKE_EXECUTABLE="%LUX_X64_QT_ROOT%\bin\qmake"

set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:quiet /toolsversion:15.0 /property:"PlatformToolset=v141" /property:"Platform=x64" /property:ForceImportBeforeCppTargets=%LUX_WINDOWS_BUILD_ROOT%\Support\MultiThreadedDLL.props /target:"Clean"
set MSBUILD_RELEASE_OPTS=/property:"WholeProgramOptimization=False"
set MSBUILD_DEBUG_OPTS=

IF %BUILD_DEBUG% EQU 0 set MSBUILD_OPTS=%MSBUILD_OPTS% %MSBUILD_RELEASE_OPTS%
IF %BUILD_DEBUG% EQU 1 set MSBUILD_OPTS=%MSBUILD_OPTS% %MSBUILD_DEBUG_OPTS%


:BuildDepsChoice
echo.
echo Build options:
echo 1: Build all dependencies
echo 2: Build all but Qt (default, Qt is not needed by LuxCoreRender)
echo q: Quit (do nothing)
echo.
set BUILDCHOICE=2
set /P BUILDCHOICE="Selection? "
IF %BUILDCHOICE% EQU 1 GOTO StartBuild
IF %BUILDCHOICE% EQU 2 GOTO StartBuild
IF /I %BUILDCHOICE% EQU q GOTO:EOF
echo Invalid choice
GOTO BuildDepsChoice


:StartBuild
echo.
echo To use the freshly built dependencies for a standard LuxCoreRender build,
echo rename folder 'BuiltDeps' to 'WindowsCompileDeps'.
echo.
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

%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\qt.patch

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
mkdir %LIB_DIR%\qtplugins
mkdir %LIB_DIR%\qtplugins\imageformats
CALL:copyFile plugins\imageformats\qjpeg4.dll %LIB_DIR%\qtplugins\imageformats
CALL:copyFile plugins\imageformats\qtga4.dll %LIB_DIR%\qtplugins\imageformats
CALL:copyFile plugins\imageformats\qtiff4.dll %LIB_DIR%\qtplugins\imageformats


:NotQT

:: ****************************************************************************
:: ******************************* PYTHON *************************************
:: ****************************************************************************
:Python
echo.
echo **************************************************************************
echo * Building Python 35                                                     *
echo **************************************************************************
cd /d %LUX_X64_PYTHON35_ROOT%\PCbuild
CALL:copyFile ..\PC\pyconfig.h ..\Include

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"python" /target:"_ctypes" pcbuild.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Python35
CALL:copyFile ..\include\*.h %INCLUDE_DIR%\Python35
CALL:copyFile amd64\python35.lib %LIB_DIR%
CALL:copyFile amd64\python35.dll %LIB_DIR%

echo.
echo **************************************************************************
echo * Building Python 36                                                     *
echo **************************************************************************
cd /d %LUX_X64_PYTHON36_ROOT%\PCbuild
CALL:copyFile ..\PC\pyconfig.h ..\Include

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"python" pcbuild.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Python36
CALL:copyFile ..\include\*.h %INCLUDE_DIR%\Python36
CALL:copyFile amd64\python36.lib %LIB_DIR%
CALL:copyFile amd64\python36.dll %LIB_DIR%

echo.
echo **************************************************************************
echo * Building Python 37                                                     *
echo **************************************************************************
cd /d %LUX_X64_PYTHON37_ROOT%\PCbuild
CALL:copyFile ..\PC\pyconfig.h ..\Include

msbuild %MSBUILD_OPTS% /property:"Configuration=%BUILD_CONFIGURATION%" /target:"python" /target:"_decimal" pcbuild.sln
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Python37
CALL:copyFile ..\include\*.h %INCLUDE_DIR%\Python37
CALL:copyFile amd64\python37.lib %LIB_DIR%
CALL:copyFile amd64\python37.dll %LIB_DIR%

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
type %LUX_WINDOWS_BUILD_ROOT%\support\x64-project-config-35.jam >> project-config.jam
CALL:xcopyFiles %LUX_X64_NUMPY35_ROOT%\numpy\*.* %LUX_X64_PYTHON35_ROOT%\Lib\site-packages\numpy
set BJAM_OPTS=-a -q -j%NUMBER_OF_PROCESSORS% address-model=64 link=static threading=multi runtime-link=shared --with-date_time --with-filesystem --with-iostreams --with-locale --with-program_options --with-python --with-regex --with-serialization --with-system --with-thread -sBZIP2_SOURCE=%LUX_X64_BZIP_ROOT% -sPYTHON_SOURCE=%LUX_X64_PYTHON35_ROOT% -sZLIB_SOURCE=%LUX_X64_ZLIB_ROOT%

set BUILD_CONFIGURATION_BOOST=release
IF %BUILD_CONFIGURATION%==Debug set BUILD_CONFIGURATION_BOOST=debug

bjam %BJAM_OPTS% variant=%BUILD_CONFIGURATION_BOOST% stage
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Boost
mkdir %INCLUDE_DIR%\Boost\boost
CALL:xcopyFiles boost\*.* %INCLUDE_DIR%\Boost\boost
CALL:copyFile stage\lib\*.lib %LIB_DIR%

:: with python 3.6
b2 --clean
CALL:copyfile project-config.bck .\project-config.jam
type %LUX_WINDOWS_BUILD_ROOT%\support\x64-project-config-36.jam >> project-config.jam
CALL:xcopyFiles %LUX_X64_NUMPY36_ROOT%\numpy\*.* %LUX_X64_PYTHON36_ROOT%\Lib\site-packages\numpy
set BJAM_OPTS=-a -q -j%NUMBER_OF_PROCESSORS% address-model=64 link=static threading=multi runtime-link=shared --with-python -sBZIP2_SOURCE=%LUX_X64_BZIP_ROOT% -sPYTHON_SOURCE=%LUX_X64_PYTHON36_ROOT% -sZLIB_SOURCE=%LUX_X64_ZLIB_ROOT%

set BUILD_CONFIGURATION_BOOST=release
IF %BUILD_CONFIGURATION%==Debug set BUILD_CONFIGURATION_BOOST=debug

bjam %BJAM_OPTS% variant=%BUILD_CONFIGURATION_BOOST% stage
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Boost
mkdir %INCLUDE_DIR%\Boost\boost
CALL:copyFile stage\lib\*.lib %LIB_DIR%

:: with python 3.7
b2 --clean
CALL:copyfile project-config.bck .\project-config.jam
type %LUX_WINDOWS_BUILD_ROOT%\support\x64-project-config-37.jam >> project-config.jam
CALL:xcopyFiles %LUX_X64_NUMPY37_ROOT%\numpy\*.* %LUX_X64_PYTHON37_ROOT%\Lib\site-packages\numpy
set BJAM_OPTS=-a -q -j%NUMBER_OF_PROCESSORS% address-model=64 link=static threading=multi runtime-link=shared --with-python -sBZIP2_SOURCE=%LUX_X64_BZIP_ROOT% -sPYTHON_SOURCE=%LUX_X64_PYTHON37_ROOT% -sZLIB_SOURCE=%LUX_X64_ZLIB_ROOT%

set BUILD_CONFIGURATION_BOOST=release
IF %BUILD_CONFIGURATION%==Debug set BUILD_CONFIGURATION_BOOST=debug

bjam %BJAM_OPTS% variant=%BUILD_CONFIGURATION_BOOST% stage
if ERRORLEVEL 1 goto :EOF

mkdir %INCLUDE_DIR%\Boost
mkdir %INCLUDE_DIR%\Boost\boost
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
cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 ..
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
cmake %CMAKE_OPTS% ..
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
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch .\libtiff\tif_config.vc.h %LUX_WINDOWS_BUILD_ROOT%\support\tif_config.vc.h.patch

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
cmake %CMAKE_OPTS% -D BUILD_SHARED_LIBS=0 -D ILMBASE_PACKAGE_PREFIX="%INSTALL_DIR%" ..
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
cmake %CMAKE_OPTS% ..
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

rem Update source files
%LUX_WINDOWS_BUILD_ROOT%\support\bin\patch --forward --backup --batch -p0 -i %LUX_WINDOWS_BUILD_ROOT%\support\openimageio-1.8.11.patch

rmdir /s /q build
mkdir build
cd build
cmake %CMAKE_OPTS% -D LINKSTATIC=1 -D USE_FFMPEG=0 -D USE_PYTHON=0 -D USE_TBB=0 -D USE_OPENGL=0 -D USE_QT=0 -D USE_GIF=0 -D USE_OPENJPEG=0 -D USE_OPENSSL=0 -D USE_FIELD3D=0 -D USE_OCIO=0 -D USE_OPENCV=0 -D OIIO_BUILD_TOOLS=0 -D OIIO_BUILD_TESTS=0 ..
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
CALL:copyFile bin\tbb.dll %LIB_DIR%\tbb.dll
CALL:copyFile bin\tbbmalloc.dll %LIB_DIR%\tbbmalloc.dll
CALL:copyFile lib\*.lib %LIB_DIR%

mkdir %INCLUDE_DIR%\embree3
CALL:copyFile include\embree3\*.* %INCLUDE_DIR%\embree3


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
CALL:copyFile lib\intel64\vc14\tbbproxy.lib %LIB_DIR%\tbbproxy.lib

mkdir %INCLUDE_DIR%\serial
mkdir %INCLUDE_DIR%\serial\tbb
CALL:xcopyFiles include\serial\*.* %INCLUDE_DIR%\serial

mkdir %INCLUDE_DIR%\tbb
CALL:xcopyFiles include\tbb\*.* %INCLUDE_DIR%\tbb


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
CALL:copyFile bin\*.dll %LIB_DIR%
CALL:copyFile lib\*.lib %LIB_DIR%

mkdir %INCLUDE_DIR%\OpenImageDenoise
CALL:copyFile include\OpenImageDenoise\*.* %INCLUDE_DIR%\OpenImageDenoise


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
cmake .. -DBUILD_TESTS=OFF
if ERRORLEVEL 1 goto :EOF

cmake --build .
if ERRORLEVEL 1 goto :EOF

CALL:copyFile ..\blosc\blosc.h %INCLUDE_DIR%\blosc.h
CALL:copyFile ..\blosc\blosc-export.h %INCLUDE_DIR%\blosc-export.h
CALL:copyFile blosc\Debug\blosc.lib %LIB_DIR%\blosc.lib


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
