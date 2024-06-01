@Echo OFF

:: Versions to download / install
SET BOOST_VER_U=1_72_0
SET BOOST_VER_P=1.72.0

::SET FREEIMAGE_VER_P=3.16.0
::SET FREEIMAGE_VER_N=3160

SET BLOSC_VER=1.17.1
SET BZIP2_VER=1.0.8
SET EMBREE_VER=3.12.2
::SET ILMBASE_VER=2.2.0
SET JPEG_VER=9d
SET LIBPNG_VER=1.6.37
SET LIBTIFF_VER=4.0.9
SET NUMPY36_VER=1.15.4
SET NUMPY37_VER=1.15.4
SET OIDN_VER=1.4.1
SET OIIO_VER=2.2.13.1
SET OPENEXR_VER=2.4.1
::SET OPENJPEG_VER=1.5.1
SET PYTHON36_VER=3.6.8
SET PYTHON37_VER=3.7.7
SET PYTHON311_VER=3.11.8
SET QT_VER=5.12.2
SET TBB_VER=2019_U9
SET TBB_VER_FULL=2019_20191006
SET ZLIB_VER=1.2.11

:: Initial message to display to user
echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo We are going to download and extract these libraries:
echo   Blosc    	%BLOSC_VER%		https://github.com/Blosc/c-blosc/
echo   Boost      	%BOOST_VER_P%		http://www.boost.org/
echo   bzip       	%BZIP2_VER%		http://www.bzip.org/
echo   embree     	%EMBREE_VER%		https://embree.github.io
echo   FreeImage  	%FREEIMAGE_VER_P%		http://freeimage.sf.net/
echo   IlmBase    	%ILMBASE_VER%		http://www.openexr.com/
echo   JPEG       	%JPEG_VER%		http://www.ijg.org/
echo   libPNG     	%LIBPNG_VER%		http://www.libpng.org/
echo   libTIFF    	%LIBTIFF_VER%		http://www.libtiff.org/
echo   NumPy      	%NUMPY35_VER%		http://www.numpy.org/
echo   NumPy      	%NUMPY36_VER%		http://www.numpy.org/
echo   NumPy      	%NUMPY37_VER%		http://www.numpy.org/
echo   NumPy      	%NUMPY311_VER%		http://www.numpy.org/
echo   OpenEXR    	%OPENEXR_VER%		http://www.openexr.com/
echo   OpenImageDenoise %OIDN_VER%	https://openimagedenoise.github.io
echo   OpenImageIO	%OIIO_VER%		http://openimageio.org/
echo   OpenJPEG   	%OPENJPEG_VER%		http://www.openjpeg.org/
echo   Python     	%PYTHON35_VER%		http://www.python.org/
echo   Python     	%PYTHON36_VER%		http://www.python.org/
echo   Python     	%PYTHON37_VER%		http://www.python.org/
echo   Python     	%PYTHON311_VER%		http://www.python.org/
echo   QT         	%QT_VER%		http://www.qt.io/
echo   tbb        	%TBB_VER%		https://www.threadingbuildingblocks.org/
echo   zlib       	%ZLIB_VER%		http://www.zlib.net/
echo.
pause
echo   To build these dependencies and LuxCoreRender you will also need a 
echo   working installation of CMake (suggested version 3.11.2 or newer).
echo   To enable OpenCL support in LuxCoreRender you will need an OpenCL SDK,
echo   e.g. one among:
echo    1. GPUopen OCL SDK
echo    2. Intel SDK for OpenCL Applications
echo    3. NVIDIA CUDA Toolkit
echo   If you want to build LuxMark, Qt5 v%QT_VER% is also needed:
echo   http://download.qt.io/official_releases/qt/5.12/%QT_VER%/qt-opensource-windows-x86-%QT_VER%.exe
echo   The Qt5 installer weighs approximately 3.7 GB.
echo   None of these will be downloaded or installed by this script.
echo.
echo Downloading, extracting and building all this source code will require a 
echo lot of hard drive space. Make sure you have at least 15 GB.
echo.
echo This script will use 2 pre-built binaries to download and extract source
echo code from the internet:
echo  1: GNU wget.exe       from http://gnuwin32.sourceforge.net/packages/wget.htm
echo  2: 7z.exe (7-zip)     from http://www.7-zip.org/download.html
echo.
echo If you do not wish to execute these binaries for any reason, PRESS CTRL-C NOW
echo Otherwise,
pause

:: Check for required binaries and set variables
echo.
echo **************************************************************************
echo * Checking environment                                                   *
echo **************************************************************************
SET WGET="%CD%\support\bin\wget.exe"
%WGET% --version 1> NUL 2>&1
IF ERRORLEVEL 9009 (
	echo.
	echo Cannot execute wget. Aborting.
	EXIT /b -1
)
SET UNZIPBIN="%CD%\support\bin\7z.exe"
%UNZIPBIN% > NUL
IF ERRORLEVEL 9009 (
	echo.
	echo Cannot execute unzip. Aborting.
	EXIT /b -1
)

echo Finding if Python is installed...
for /f "tokens=*" %%a in ('where python') do SET PYTHON=%%~fa  

if exist "%PYTHON%" (
  echo Python found at "%PYTHON%"
) else (
  for /f "tokens=*" %%a in ('where py') do SET PYTHON=%%~fa
  if exist "%PYTHON%" (
    echo Python found at "%PYTHON%"
  ) else (
    echo Python was not found, NumPy will not be downloaded.
    echo Without it, you will not be able to build Boost.Numpy.
  )
)

set DOWNLOADS="%CD%\..\downloads"
set DEPSROOT="%CD%\..\deps"

set CHANGE_DEPSROOT=0
:ConfigDepsDir
:: Resolve relative paths
FOR %%G IN (%DOWNLOADS%) DO SET DOWNLOADS=%%~fG
FOR %%G IN (%DEPSROOT%) DO SET DEPSROOT=%%~fG

echo.
echo Downloads will be stored in "%DOWNLOADS%"
echo Dependencies will be extracted to "%DEPSROOT%"
echo.
echo Change these locations?
echo.
echo 0. No (default)
echo 1. Yes
echo.
set /P CHANGE_DEPSROOT="Selection? "
IF %CHANGE_DEPSROOT% EQU 0 GOTO DepsRootAccepted
IF %CHANGE_DEPSROOT% EQU 1 GOTO ChangeDepsRoot
echo Invalid selection
GOTO ConfigDepsDir


:ChangeDepsRoot
set /P DOWNLOADS="Enter path for downloads: "
set /P DEPSROOT="Enter path for dependencies: "
GOTO ConfigDepsDir


:DepsRootAccepted
set D64=%DEPSROOT%\x64

mkdir %DOWNLOADS% 2> NUL
mkdir %D64% 2> NUL


set FORCE_EXTRACT=0
:ForceExtractChoice
echo.
echo **************************************************************************
echo * Extract Option                                                         *
echo **************************************************************************
echo.
echo Should all sources be decompressed regardless of whether they have already
echo been extracted ?
echo.
echo 0. No (default)
echo 1. Yes
echo.
set /p FORCE_EXTRACT="Selection? "
IF %FORCE_EXTRACT% EQU 0 GOTO CreateBuildVars
IF %FORCE_EXTRACT% EQU 1 GOTO CreateBuildVars
echo Invalid choice
GOTO ForceExtractChoice


:CreateBuildVars
>  build-vars.bat echo @Echo off
REM >  build-vars.reg echo Windows Registry Editor Version 5.00
REM >> build-vars.reg echo.
REM >> build-vars.reg echo [HKEY_CURRENT_USER\Environment]
CALL:addBuildPathVar "LUX_WINDOWS_BUILD_ROOT", "%CD%"
CALL:addBuildPathVar "LUX_DEPS_ROOT", "%DEPSROOT%"
set LUX_WINDOWS_BUILD_ROOT="%CD%"


:blosc
CALL:downloadFile "Blosc %BLOSC_VER%", "https://github.com/Blosc/c-blosc/archive/v%BLOSC_VER%.zip", "c-blosc-%BLOSC_VER%.zip" || EXIT /b -1
CALL:extractFile "Blosc %BLOSC_VER%", "%DOWNLOADS%\c-blosc-%BLOSC_VER%.zip"

CALL:addBuildPathVar "LUX_X64_BLOSC_ROOT", "%D64%\c-blosc-%BLOSC_VER%"

:boost
CALL:downloadFile "Boost %BOOST_VER_P%", "https://boostorg.jfrog.io/artifactory/main/release/%BOOST_VER_P%/source/boost_%BOOST_VER_U%.7z", "boost_%BOOST_VER_U%.7z", "--content-disposition" || EXIT /b -1
CALL:extractFile "Boost %BOOST_VER_P%", "%DOWNLOADS%\boost_%BOOST_VER_U%.7z"

CALL:addBuildPathVar "LUX_X64_BOOST_ROOT", "%D64%\boost_%BOOST_VER_U%"

:bzip
CALL:downloadFile "bzip2 %BZIP2_VER%", "https://sourceware.org/pub/bzip2/bzip2-%BZIP2_VER%.tar.gz", "bzip2-%BZIP2_VER%.tar.gz", "--no-check-certificate --content-disposition" || EXIT /b -1
CALL:extractFile "bzip2 %BZIP2_VER%", "%DOWNLOADS%\bzip2-%BZIP2_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X64_BZIP_ROOT", "%D64%\bzip2-%BZIP2_VER%"

:embree
CALL:downloadFile "embree %EMBREE_VER%", "https://github.com/embree/embree/releases/download/v%EMBREE_VER%/embree-%EMBREE_VER%.x64.vc14.windows.zip", "embree-%EMBREE_VER%.zip" || EXIT /b -1
CALL:extractFile "embree %EMBREE_VER%", "%DOWNLOADS%\embree-%EMBREE_VER%.zip"
ren %D64%\embree-%EMBREE_VER%.x64.vc14.windows embree-%EMBREE_VER%

CALL:addBuildPathVar "LUX_X64_EMBREE_ROOT", "%D64%\embree-%EMBREE_VER%"

:freeimage
REM CALL:downloadFile "FreeImage %FREEIMAGE_VER_P%", "https://downloads.sourceforge.net/freeimage/FreeImage%FREEIMAGE_VER_N%.zip", "FreeImage%FREEIMAGE_VER_N%.zip", "--no-check-certificate --content-disposition" || EXIT /b -1
REM CALL:extractFile "FreeImage %FREEIMAGE_VER_P%", "%DOWNLOADS%\FreeImage%FREEIMAGE_VER_N%.zip", "FreeImage%FREEIMAGE_VER_N%"

REM CALL:addBuildPathVar "LUX_X64_FREEIMAGE_ROOT", "%D64%\FreeImage%FREEIMAGE_VER_N%"

:ilmbase
REM CALL:downloadFile "IlmBase %ILMBASE_VER%", "http://download.savannah.nongnu.org/releases/openexr/ilmbase-%ILMBASE_VER%.tar.gz", "ilmbase-%ILMBASE_VER%.tar.gz" || EXIT /b -1
REM CALL:extractFile "IlmBase %ILMBASE_VER%", "%DOWNLOADS%\ilmbase-%ILMBASE_VER%.tar.gz"

REM CALL:addBuildPathVar "LUX_X64_ILMBASE_ROOT", "%D64%\ilmbase-%ILMBASE_VER%"

:jpeg
CALL:downloadFile "JPEG %JPEG_VER%", "http://www.ijg.org/files/jpegsr%JPEG_VER%.zip", "jpeg-%JPEG_VER%.zip" || EXIT /b -1
CALL:extractFile "JPEG %JPEG_VER%", "%DOWNLOADS%\jpeg-%JPEG_VER%.zip"

CALL:addBuildPathVar "LUX_X64_JPEG_ROOT", "%D64%\jpeg-%JPEG_VER%"

:libpng
CALL:downloadFile "libPNG %LIBPNG_VER%", "https://download.sourceforge.net/libpng/libpng-%LIBPNG_VER%.tar.gz", "libpng-%LIBPNG_VER%.tar.gz", "--no-check-certificate --content-disposition" || EXIT /b -1
CALL:extractFile "libPNG %LIBPNG_VER%", "%DOWNLOADS%\libpng-%LIBPNG_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X64_LIBPNG_ROOT", "%D64%\libpng-%LIBPNG_VER%"

:libtiff
CALL:downloadFile "libTIFF %LIBTIFF_VER%", "http://download.osgeo.org/libtiff/tiff-%LIBTIFF_VER%.zip", "tiff-%LIBTIFF_VER%.zip" || EXIT /b -1
CALL:extractFile "libTIFF %LIBTIFF_VER%", "%DOWNLOADS%\tiff-%LIBTIFF_VER%.zip"

CALL:addBuildPathVar "LUX_X64_LIBTIFF_ROOT", "%D64%\tiff-%LIBTIFF_VER%"

:numpy36
if not exist "%DOWNLOADS%\numpy-%NUMPY36_VER%-cp36-none-win_amd64.whl" (
    "%PYTHON%" -m pip download -d %DOWNLOADS% --python-version 36 --only-binary=:all: numpy==%NUMPY36_VER%
)
CALL:extractFile "Numpy %NUMPY36_VER% for Python 3.6", "%DOWNLOADS%\numpy-%NUMPY36_VER%-cp36-none-win_amd64.whl", "numpy36-%NUMPY36_VER%"


CALL:addBuildPathVar "LUX_X64_NUMPY36_ROOT", "%D64%\numpy36-%NUMPY36_VER%"

:numpy37
if not exist "%DOWNLOADS%\numpy-%NUMPY37_VER%-cp37-none-win_amd64.whl" (
    "%PYTHON%" -m pip download -d %DOWNLOADS% --python-version 37 --only-binary=:all: numpy==%NUMPY37_VER%
)
CALL:extractFile "Numpy %NUMPY37_VER% for Python 3.7", "%DOWNLOADS%\numpy-%NUMPY37_VER%-cp37-none-win_amd64.whl", "numpy37-%NUMPY37_VER%"


CALL:addBuildPathVar "LUX_X64_NUMPY37_ROOT", "%D64%\numpy37-%NUMPY37_VER%"
)

:openexr
CALL:downloadFile "OpenEXR %OPENEXR_VER%", "https://github.com/AcademySoftwareFoundation/openexr/archive/v%OPENEXR_VER%.zip", "openexr-%OPENEXR_VER%.zip" || EXIT /b -1
CALL:extractFile "OpenEXR %OPENEXR_VER%", "%DOWNLOADS%\openexr-%OPENEXR_VER%.zip"

CALL:addBuildPathVar "LUX_X64_OPENEXR_ROOT", "%D64%\openexr-%OPENEXR_VER%"

:oidn
CALL:downloadFile "OpenImageDenoise %OIDN_VER%", "https://github.com/OpenImageDenoise/oidn/releases/download/v%OIDN_VER%/oidn-%OIDN_VER%.x64.vc14.windows.zip", "oidn-%OIDN_VER%.x64.vc14.windows.zip", "--no-check-certificate" || EXIT /b -1
CALL:extractFile "OpenImageDenoise %OIDN_VER%", "%DOWNLOADS%\oidn-%OIDN_VER%.x64.vc14.windows.zip"

CALL:addBuildPathVar "LUX_X64_OIDN_ROOT", "%D64%\oidn-%OIDN_VER%.x64.vc14.windows"

:oiio
CALL:downloadFile "OpenImageIO %OIIO_VER%", "http://github.com/OpenImageIO/oiio/archive/refs/tags/Release-%OIIO_VER%.zip", "oiio-Release-%OIIO_VER%.zip", "--no-check-certificate" || EXIT /b -1
CALL:extractFile "OpenImageIO %OIIO_VER%", "%DOWNLOADS%\oiio-Release-%OIIO_VER%.zip"

CALL:addBuildPathVar "LUX_X64_OIIO_ROOT", "%D64%\oiio-Release-%OIIO_VER%"

:openjpeg
REM CALL:downloadFile "OpenJPEG %OPENJPEG_VER%", "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/openjpeg/openjpeg-%OPENJPEG_VER%.tar.gz", "openjpeg-%OPENJPEG_VER%.tar.gz", "--no-check-certificate" || EXIT /b -1
REM CALL:extractFile "OpenJPEG %OPENJPEG_VER%", "%DOWNLOADS%\openjpeg-%OPENJPEG_VER%.tar.gz"

REM CALL:addBuildPathVar "LUX_X64_OPENJPEG_ROOT", "%D64%\openjpeg-%OPENJPEG_VER%"

:python36
CALL:downloadFile "Python %PYTHON36_VER%", "https://python.org/ftp/python/%PYTHON36_VER%/Python-%PYTHON36_VER%.tgz", "Python-%PYTHON36_VER%.tgz", "--no-check-certificate" || EXIT /b -1
CALL:extractFile "Python %PYTHON36_VER%", "%DOWNLOADS%\Python-%PYTHON36_VER%.tgz"

CALL:addBuildPathVar "LUX_X64_PYTHON36_ROOT", "%D64%\Python-%PYTHON36_VER%"

:python37
CALL:downloadFile "Python %PYTHON37_VER%", "https://python.org/ftp/python/%PYTHON37_VER%/Python-%PYTHON37_VER%.tgz", "Python-%PYTHON37_VER%.tgz", "--no-check-certificate" || EXIT /b -1
CALL:extractFile "Python %PYTHON37_VER%", "%DOWNLOADS%\Python-%PYTHON37_VER%.tgz"

CALL:addBuildPathVar "LUX_X64_PYTHON37_ROOT", "%D64%\Python-%PYTHON37_VER%"

:tbb
CALL:downloadFile "tbb %TBB_VER_FULL%", "https://github.com/01org/tbb/releases/download/%TBB_VER%/tbb%TBB_VER_FULL%oss_win.zip", "tbb%TBB_VER_FULL%oss.zip" || EXIT /b -1
CALL:extractFile "tbb %TBB_VER_FULL%", "%DOWNLOADS%\tbb%TBB_VER_FULL%oss.zip"
ren %D64%\tbb%TBB_VER_FULL%oss_win tbb%TBB_VER_FULL%oss

CALL:addBuildPathVar "LUX_X64_TBB_ROOT", "%D64%\tbb%TBB_VER_FULL%oss"

:zlib
CALL:downloadFile "zlib %ZLIB_VER%", "http://zlib.net/fossils/zlib-%ZLIB_VER%.tar.gz", "zlib-%ZLIB_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "zlib %ZLIB_VER%", "%DOWNLOADS%\zlib-%ZLIB_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X64_ZLIB_ROOT", "%D64%\zlib-%ZLIB_VER%"

:: Final message to display to user
echo.
echo **************************************************************************
echo * DONE                                                                   *
echo **************************************************************************
echo.

echo To build dependencies for x64 you can now run build-deps-x64.bat from a
echo Visual Studio Command Prompt for x64 window.
echo.

echo To build LuxCoreRender you can then run cmake-build-x64.bat from a
echo Visual Studio Command Prompt for x64 window.
echo.

:: Functions below this point
GOTO:EOF

:downloadFile
:: Downloads a file
:: %1 - Description
:: %2 - URI to download
:: %3 - Filename to save as
:: %4 - Additional options

IF NOT EXIST %DOWNLOADS%\%~3 (
	echo.
	echo **************************************************************************
	echo * Downloading %~1
	echo **************************************************************************
	IF EXIST %DOWNLOADS%\%~3.temp (
		del %DOWNLOADS%\%~3.temp
	)
	%WGET% %2 -O %DOWNLOADS%\%~3.temp %~4
	IF ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		EXIT /b -1
	)
	move /y %DOWNLOADS%\%~3.temp %DOWNLOADS%\%~3
)
GOTO:EOF

:extractFile
:: Extracts a file
:: %1 - Description
:: %2 - File to extract
:: %3 - Relative directory to extract into

SETLOCAL
:: Parse filename
FOR %%G IN (%2) DO SET FILENAME=%%~nG
FOR %%G IN (%2) DO SET FILEEXTENSION=%%~xG

:: Check if double extraction is called for (compressed tar files)
SET TAR=0
IF /i "%FILEEXTENSION%" == ".gz" (
	FOR %%G IN (%FILENAME%) DO SET FILEEXTENSION=%%~xG
	FOR %%G IN (%FILENAME%) DO SET FILENAME=%%~nG
)
IF /i "%FILEEXTENSION%" == ".tar" SET TAR=1
IF /i "%FILEEXTENSION%" == ".tgz" SET TAR=1

:: Decide if extraction is required
SET EXTRACT=1
IF EXIST %D64%\%FILENAME% (IF %FORCE_EXTRACT% NEQ 1 SET EXTRACT=0)
IF %EXTRACT% EQU 1 (
	echo.
	echo **************************************************************************
	echo * Extracting %~1
	echo **************************************************************************
	IF %TAR% EQU 1 (
		%UNZIPBIN% x -y %2 > NUL
		%UNZIPBIN% x -y %FILENAME%.tar -o%D64% > NUL
		del %FILENAME%.tar
	) ELSE (
		%UNZIPBIN% x -y %2 -o%D64%\%3 > NUL
	)
)
ENDLOCAL
GOTO:EOF

:addBuildVar
:: Creates build-vars.{bat,reg}
:: %1 - Variable to set
:: %2 - Value to set
:: %3 - Set in registry

SETLOCAL
SET VALUE=%~2
:: Use another cmd instance to get new environment variables expanded
>> build-vars.bat cmd /C echo SET %~1=%VALUE%
IF [%3] NEQ [] ( >> build-vars.reg cmd /C echo "%~1"="%VALUE:\=\\%" )
ENDLOCAL
GOTO:EOF

:addBuildPathVar
:: Calls addBuildVar after cleaning up the path in %2
:: %1 - Variable to set
:: %2 - Path value to set
:: %3 - Set in registry

SETLOCAL
:: Clean up the path value
FOR %%G IN (%2) DO SET VALUE=%%~fG
CALL:addBuildVar "%~1" "%VALUE%" %3
ENDLOCAL
GOTO:EOF
