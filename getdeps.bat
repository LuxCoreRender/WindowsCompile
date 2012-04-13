@Echo OFF

:: Versions to download / install
SET BOOST_VER_U=1_47_0
SET BOOST_VER_P=1.47.0

SET PYTHON2_VER=2.7.1
SET PYTHON3_VER=3.2

SET FREEIMAGE_VER_P=3.14.1
SET FREEIMAGE_VER_N=3141

SET ZLIB_VER=1.2.3

SET BZIP2_VER=1.0.5

SET QT_VER=4.7.2

SET GLEW_VER=1.5.5

SET FREEGLUT_VER=2.6.0

:: Initial message to display to user
echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo We are going to download and extract these libraries:
echo   Boost %BOOST_VER_P%                             http://www.boost.org/
echo   QT %QT_VER%                                 http://qt.nokia.com/
echo   zlib %ZLIB_VER%                               http://www.zlib.net/
echo   bzip %BZIP2_VER%                               http://www.bzip.org/
echo   FreeImage %FREEIMAGE_VER_P%                         http://freeimage.sf.net/
echo   Python %PYTHON2_VER% ^& Python %PYTHON3_VER%              http://www.python.org/
echo   freeglut %FREEGLUT_VER%                           http://freeglut.sourceforge.net/
echo   and EITHER:
echo       GLEW %GLEW_VER%                           http://glew.sourceforge.net/
echo       NVIDIA CUDA ToolKit 3.1 / 4.0
echo           http://developer.nvidia.com/object/cuda_3_1_downloads.html
echo           http://developer.nvidia.com/cuda-toolkit-40
echo   OR:
echo       ATI Stream SDK 2.3 / 2.4
echo           http://developer.amd.com/gpu/atistreamsdk/pages/default.aspx
echo.
echo Downloading and extracting all this source code will require several gigabytes,
echo and building it will require a lot more. Make sure you have plenty of space
echo available on this drive, at least 15GB.
echo.
echo This script will use 2 pre-built binaries to download and extract source
echo code from the internet:
echo  1: GNU wget.exe       from http://gnuwin32.sourceforge.net/packages/wget.htm
echo  2: 7za.exe (7-zip)    from http://7-zip.org/download.html
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
SET UNZIPBIN="%CD%\support\bin\7za.exe"
%UNZIPBIN% > NUL
IF ERRORLEVEL 9009 (
	echo.
	echo Cannot execute unzip. Aborting.
	EXIT /b -1
)

set DOWNLOADS="%CD%\..\downloads"
set DEPSROOT="%CD%\..\deps"


:ConfigDepsDir
:: Resolve relative paths
FOR %%G IN (%DOWNLOADS%) DO SET DOWNLOADS=%%~fG
FOR %%G IN (%DEPSROOT%) DO SET DEPSROOT=%%~fG

set D32=%DEPSROOT%\x86
set D64=%DEPSROOT%\x64

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
mkdir %DOWNLOADS% 2> NUL
mkdir %D32% 2> NUL
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
>  build-vars.reg echo Windows Registry Editor Version 5.00
>> build-vars.reg echo.
>> build-vars.reg echo [HKEY_CURRENT_USER\Environment]
CALL:addBuildPathVar "LUX_WINDOWS_BUILD_ROOT", "%CD%"
set LUX_WINDOWS_BUILD_ROOT="%CD%"

:OpenCL
echo.
echo **************************************************************************
echo * OpenCL SDK                                                             *
echo **************************************************************************
:OpenCLChoice
echo.
echo Please select which OpenCL SDK you wish to use:
echo.
echo 1. NVIDIA CUDA ToolKit 3.1 for Win 32 bit
echo 2. NVIDIA CUDA ToolKit 3.1 for Win 64 bit (also contains 32bit libs)
echo 3. NVIDIA CUDA ToolKit 4.0 for Win 32 bit
echo 4. NVIDIA CUDA ToolKit 4.0 for Win 64 bit (also contains 32bit libs)
echo 5. AMD APP SDK 2.4 for Vista/Win7 32 bit
echo 6. AMD APP SDK 2.4 for Vista/Win7 64 bit (also contains 32bit libs)
echo 7. ATI STREAM SDK 2.3 for XP SP3 32 bit
echo 8. ATI STREAM SDK 2.3 for XP SP3 64 bit (also contains 32bit libs)
echo N3. I have already installed an NVIDIA CUDA 3.1 Toolkit
echo N4. I have already installed an NVIDIA CUDA 4.0 Toolkit
echo A. I have already installed an ATI Stream SDK
echo.
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO CUDA_1_32
IF %OPENCL_CHOICE% EQU 2 GOTO CUDA_1_64
IF %OPENCL_CHOICE% EQU 3 GOTO CUDA_2_32
IF %OPENCL_CHOICE% EQU 4 GOTO CUDA_2_64
IF %OPENCL_CHOICE% EQU 5 GOTO STREAM_1_32
IF %OPENCL_CHOICE% EQU 6 GOTO STREAM_1_64
IF %OPENCL_CHOICE% EQU 7 GOTO STREAM_2_32
IF %OPENCL_CHOICE% EQU 8 GOTO STREAM_2_64
IF /i "%OPENCL_CHOICE%" == "N3" GOTO SetCUDAVars1
IF /i "%OPENCL_CHOICE%" == "N4" GOTO SetCUDAVars2
IF /i "%OPENCL_CHOICE%" == "A" GOTO SetStreamVars
echo Invalid choice
GOTO OpenCLChoice

:CUDA_1_32
set OPENCL_VARS=SetCUDAVars1
set OPENCL_NAME=NVIDIA CUDA ToolKit 3.1 for Win 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/3_1/toolkit/
set OPENCL_PKG=cudatoolkit_3.1_win_32.exe
GOTO OpenCLInstall

:CUDA_1_64
set OPENCL_VARS=SetCUDAVars1
set OPENCL_NAME=NVIDIA CUDA ToolKit 3.1 for Win 64 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/3_1/toolkit/
set OPENCL_PKG=cudatoolkit_3.1_win_64.exe
GOTO OpenCLInstall

:CUDA_2_32
set OPENCL_VARS=SetCUDAVars2
set OPENCL_NAME=NVIDIA CUDA ToolKit 4.0 for Win 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/4_0/toolkit/
set OPENCL_PKG=cudatoolkit_4.0.17_win_32.msi
GOTO OpenCLInstall

:CUDA_2_64
set OPENCL_VARS=SetCUDAVars2
set OPENCL_NAME=NVIDIA CUDA ToolKit 4.0 for Win 64 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/4_0/toolkit/
set OPENCL_PKG=cudatoolkit_4.0.17_win_64.msi
GOTO OpenCLInstall

:STREAM_1_32
set OPENCL_VARS=SetAMDAPPVars
set OPENCL_NAME=AMD APP SDK 2.4 for Vista/Win7 32 bit
set OPENCL_URL=http://download2-developer.amd.com/amd/APPSDK/
set OPENCL_PKG=AMD-APP-SDK-v2.4-Windows-32.exe
GOTO OpenCLInstall

:STREAM_1_64
set OPENCL_VARS=SetAMDAPPVars
set OPENCL_NAME=AMD APP SDK 2.4 for Vista/Win7 64 bit
set OPENCL_URL=http://download2-developer.amd.com/amd/APPSDK/
set OPENCL_PKG=AMD-APP-SDK-v2.4-Windows-64.exe
GOTO OpenCLInstall

:STREAM_2_32
set OPENCL_VARS=SetStreamVars
set OPENCL_NAME=ATI Stream SDK 2.3 for XP SP3 32 bit
set OPENCL_URL=http://developer.amd.com/Downloads/
set OPENCL_PKG=ati-stream-sdk-v2.3-xp32.exe
GOTO OpenCLInstall

:STREAM_2_64
set OPENCL_VARS=SetStreamVars
set OPENCL_NAME=ATI Stream SDK 2.3 for XP SP3 64 bit
set OPENCL_URL=http://developer.amd.com/Downloads/
set OPENCL_PKG=ati-stream-sdk-v2.3-xp64.exe
GOTO OpenCLInstall

:OpenCLInstall
CALL:downloadFile "%OPENCL_NAME%", "%OPENCL_URL%%OPENCL_PKG%", "%OPENCL_PKG%" || EXIT /b -1

echo.
echo I will now launch the SDK installer. You can install anywhere you like, but to be
echo on the safe side, please choose a path that doesn't contain spaces.
start /WAIT "" %DOWNLOADS%\%OPENCL_PKG%
echo Waiting for installer. When finished,
pause
GOTO %OPENCL_VARS%

:SetCUDAVars1
CALL:addBuildPathVar "LUX_X86_OCL_LIBS",    "%CUDA_LIB_PATH%\..\lib\"
CALL:addBuildPathVar "LUX_X64_OCL_LIBS",    "%CUDA_LIB_PATH%"
CALL:addBuildPathVar "LUX_X86_OCL_INCLUDE", "%CUDA_INC_PATH%"
CALL:addBuildPathVar "LUX_X64_OCL_INCLUDE", "%CUDA_INC_PATH%"
GOTO OpenCLFinished

:SetCUDAVars2
CALL:addBuildPathVar "LUX_X86_OCL_LIBS",    "%CUDA_PATH%\lib\Win32"
CALL:addBuildPathVar "LUX_X64_OCL_LIBS",    "%CUDA_PATH%\lib\x64"
CALL:addBuildPathVar "LUX_X86_OCL_INCLUDE", "%CUDA_PATH%\include"
CALL:addBuildPathVar "LUX_X64_OCL_INCLUDE", "%CUDA_PATH%\include"
GOTO OpenCLFinished

:SetStreamVars
IF "%ATISTREAMSDKROOT%"=="" GOTO SetAMDAPPVars
CALL:addBuildPathVar "LUX_X86_OCL_LIBS",    "%ATISTREAMSDKROOT%\lib\x86"
CALL:addBuildPathVar "LUX_X64_OCL_LIBS",    "%ATISTREAMSDKROOT%\lib\x86_64"
CALL:addBuildPathVar "LUX_X86_OCL_INCLUDE", "%ATISTREAMSDKROOT%\include"
CALL:addBuildPathVar "LUX_X64_OCL_INCLUDE", "%ATISTREAMSDKROOT%\include"
GOTO OpenCLFinished

:SetAMDAPPVars
CALL:addBuildPathVar "LUX_X86_OCL_LIBS",    "%AMDAPPSDKROOT%\lib\x86"
CALL:addBuildPathVar "LUX_X64_OCL_LIBS",    "%AMDAPPSDKROOT%\lib\x86_64"
CALL:addBuildPathVar "LUX_X86_OCL_INCLUDE", "%AMDAPPSDKROOT%\include"
CALL:addBuildPathVar "LUX_X64_OCL_INCLUDE", "%AMDAPPSDKROOT%\include"
GOTO OpenCLFinished

:OpenCLFinished

:boost
CALL:downloadFile "Boost %BOOST_VER_P%", "http://sourceforge.net/projects/boost/files/boost/%BOOST_VER_P%/boost_%BOOST_VER_U%.7z/download", "boost_%BOOST_VER_U%.7z" || EXIT /b -1
CALL:extractFile "Boost %BOOST_VER_P%", "%DOWNLOADS%\boost_%BOOST_VER_U%.7z"

CALL:addBuildPathVar "LUX_X86_BOOST_ROOT", "%D32%\boost_%BOOST_VER_U%"
CALL:addBuildPathVar "LUX_X64_BOOST_ROOT", "%D64%\boost_%BOOST_VER_U%"

:qt
CALL:downloadFile "QT %QT_VER%", "http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-%QT_VER%.tar.gz", "qt-everywhere-opensource-src-%QT_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "QT %QT_VER%", "%DOWNLOADS%\qt-everywhere-opensource-src-%QT_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_QT_ROOT", "%D32%\qt-everywhere-opensource-src-%QT_VER%"
CALL:addBuildPathVar "LUX_X64_QT_ROOT", "%D64%\qt-everywhere-opensource-src-%QT_VER%"

:zlib
CALL:downloadFile "zlib %ZLIB_VER%", "http://sourceforge.net/projects/libpng/files/zlib/%ZLIB_VER%/zlib-%ZLIB_VER%.tar.gz/download", "zlib-%ZLIB_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "zlib %ZLIB_VER%", "%DOWNLOADS%\zlib-%ZLIB_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_ZLIB_ROOT", "%D32%\zlib-%ZLIB_VER%"
CALL:addBuildPathVar "LUX_X64_ZLIB_ROOT", "%D64%\zlib-%ZLIB_VER%"

:bzip
CALL:downloadFile "bzip2 %BZIP2_VER%", "http://www.bzip.org/%BZIP2_VER%/bzip2-%BZIP2_VER%.tar.gz", "bzip2-%BZIP2_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "bzip2 %BZIP2_VER%", "%DOWNLOADS%\bzip2-%BZIP2_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_BZIP_ROOT", "%D32%\bzip2-%BZIP2_VER%"
CALL:addBuildPathVar "LUX_X64_BZIP_ROOT", "%D64%\bzip2-%BZIP2_VER%"

:freeimage
CALL:downloadFile "FreeImage %FREEIMAGE_VER_P%", "http://downloads.sourceforge.net/freeimage/FreeImage%FREEIMAGE_VER_N%.zip", "FreeImage%FREEIMAGE_VER_N%.zip" || EXIT /b -1
CALL:extractFile "FreeImage %FREEIMAGE_VER_P%", "%DOWNLOADS%\FreeImage%FREEIMAGE_VER_N%.zip", "FreeImage%FREEIMAGE_VER_N%"

CALL:addBuildPathVar "LUX_X86_FREEIMAGE_ROOT", "%D32%\FreeImage%FREEIMAGE_VER_N%"
CALL:addBuildPathVar "LUX_X64_FREEIMAGE_ROOT", "%D64%\FreeImage%FREEIMAGE_VER_N%"

:python2
CALL:downloadFile "Python %PYTHON2_VER%", "http://python.org/ftp/python/%PYTHON2_VER%/Python-%PYTHON2_VER%.tgz", "Python-%PYTHON2_VER%.tgz" || EXIT /b -1
CALL:extractFile "Python %PYTHON2_VER%", "%DOWNLOADS%\Python-%PYTHON2_VER%.tgz"

CALL:addBuildPathVar "LUX_X86_PYTHON2_ROOT", "%D32%\Python-%PYTHON2_VER%"
CALL:addBuildPathVar "LUX_X64_PYTHON2_ROOT", "%D64%\Python-%PYTHON2_VER%"

:python3
CALL:downloadFile "Python %PYTHON3_VER%", "http://python.org/ftp/python/%PYTHON3_VER%/Python-%PYTHON3_VER%.tgz", "Python-%PYTHON3_VER%.tgz" || EXIT /b -1
CALL:extractFile "Python %PYTHON3_VER%", "%DOWNLOADS%\Python-%PYTHON3_VER%.tgz"

CALL:addBuildPathVar "LUX_X86_PYTHON3_ROOT", "%D32%\Python-%PYTHON3_VER%"
CALL:addBuildPathVar "LUX_X64_PYTHON3_ROOT", "%D64%\Python-%PYTHON3_VER%"

:freeglut
REM CALL:downloadFile "freeglut %FREEGLUT_VER%", "http://downloads.sourceforge.net/freeglut/freeglut-%FREEGLUT_VER%.tar.gz", "freeglut-%FREEGLUT_VER%.tar.gz" || EXIT /b -1
REM CALL:extractFile "freeglut %FREEGLUT_VER%", "%DOWNLOADS%\freeglut-%FREEGLUT_VER%.tar.gz"
CALL:extractFile "freeglut %FREEGLUT_VER%", "%LUX_WINDOWS_BUILD_ROOT%\support\freeglut-2.6.0.7z"

CALL:addBuildPathVar "LUX_X86_GLUT_ROOT",    "%D32%\freeglut-%FREEGLUT_VER%"
CALL:addBuildPathVar "LUX_X64_GLUT_ROOT",    "%D64%\freeglut-%FREEGLUT_VER%"
CALL:addBuildPathVar "LUX_X86_GLUT_INCLUDE", "%D32%\freeglut-%FREEGLUT_VER%\include"
CALL:addBuildPathVar "LUX_X64_GLUT_INCLUDE", "%D64%\freeglut-%FREEGLUT_VER%\include"
CALL:addBuildPathVar "LUX_X86_GLUT_LIBS",    "%D32%\freeglut-%FREEGLUT_VER%\VisualStudio2008Static\Win32\Release"
CALL:addBuildPathVar "LUX_X64_GLUT_LIBS",    "%D64%\freeglut-%FREEGLUT_VER%\VisualStudio2008Static\x64\Release"

:glew
CALL:downloadFile "GLEW %GLEW_VER% 32 bit", "http://www.luxrender.net/release/luxrender/dev/win/libs/glew-%GLEW_VER%_x86.zip", "glew-%GLEW_VER%_x86.zip" || EXIT /b -1
CALL:downloadFile "GLEW %GLEW_VER% 64 bit", "http://www.luxrender.net/release/luxrender/dev/win/libs/glew-%GLEW_VER%_x64.zip", "glew-%GLEW_VER%_x64.zip" || EXIT /b -1

echo.
echo **************************************************************************
echo * Extracting GLEW                                                        *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\glew-%GLEW_VER%_x86.zip -o%D32%\ > NUL
%UNZIPBIN% x -y %DOWNLOADS%\glew-%GLEW_VER%_x64.zip -o%D64%\ > NUL

CALL:addBuildPathVar "LUX_X86_GLEW_INCLUDE", "%D32%\glew-%GLEW_VER%\include"
CALL:addBuildPathVar "LUX_X64_GLEW_INCLUDE", "%D64%\glew-%GLEW_VER%\include"
CALL:addBuildPathVar "LUX_X86_GLEW_LIBS",    "%D32%\glew-%GLEW_VER%\lib"
CALL:addBuildPathVar "LUX_X64_GLEW_LIBS",    "%D64%\glew-%GLEW_VER%\lib"
CALL:addBuildPathVar "LUX_X86_GLEW_BIN",     "%D32%\glew-%GLEW_VER%\bin"
CALL:addBuildPathVar "LUX_X64_GLEW_BIN",     "%D64%\glew-%GLEW_VER%\bin"

CALL:addBuildVar "LUX_X86_GLEW_LIBNAME", "glew32s"
CALL:addBuildVar "LUX_X64_GLEW_LIBNAME", "glew64s"

:: Final message to display to user
echo.
echo **************************************************************************
echo * DONE                                                                   *
echo **************************************************************************
echo.

echo I have created a registry file build-vars.reg that will permanently set 
echo the required path variables for building. After importing this into the 
echo registry, you'll need to log out and back in for the changes to take effect.
echo You need to do this before building LuxRender with Visual Studio.
echo.

echo To build dependencies for x86 you can now run build-deps-x86.bat from a
echo Visual Studio Command Prompt for x86 window.
echo.

echo To build dependencies for x64 you can now run build-deps-x64.bat from a
echo Visual Studio Command Prompt for x64 window.
echo.

echo Building LuxRender is not currently supported from the command line, so
echo after building the dependecies, please import the build-vars.reg file,
echo and log out and back in again in order to build LuxRender with the 
echo Visual Studio IDE.
echo.

:: Functions below this point
GOTO:EOF

:downloadFile
:: Downloads a file
:: %1 - Description
:: %2 - URI to download
:: %3 - Filename to save as

IF NOT EXIST %DOWNLOADS%\%~3 (
	echo.
	echo **************************************************************************
	echo * Downloading %~1
	echo **************************************************************************
	%WGET% %2 -O %DOWNLOADS%\%~3
	IF ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		EXIT /b -1
	)
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
IF EXIST %D32%\%FILENAME% IF %FORCE_EXTRACT% NEQ 1 SET EXTRACT=0
IF %EXTRACT% EQU 1 (
	echo.
	echo **************************************************************************
	echo * Extracting %~1
	echo **************************************************************************
	IF %TAR% EQU 1 (
		%UNZIPBIN% x -y %2 > NUL
		%UNZIPBIN% x -y %FILENAME%.tar -o%D32% > NUL
		%UNZIPBIN% x -y %FILENAME%.tar -o%D64% > NUL
		del %FILENAME%.tar
	) ELSE (
		%UNZIPBIN% x -y %2 -o%D32%\%3 > NUL
		%UNZIPBIN% x -y %2 -o%D64%\%3 > NUL
	)
)
ENDLOCAL
GOTO:EOF

:addBuildVar
:: Creates build-vars.{bat,reg}
:: %1 - Variable to set
:: %2 - Value to set

SETLOCAL
SET VALUE=%~2
:: Use another cmd instance to get new environment variables expanded
>> build-vars.bat cmd /C echo SET %~1=%VALUE%
>> build-vars.reg cmd /C echo "%~1"="%VALUE:\=\\%"
ENDLOCAL
GOTO:EOF

:addBuildPathVar
:: Calls addBuildVar after cleaning up the path in %2
:: %1 - Variable to set
:: %2 - Path value to set

SETLOCAL
:: Clean up the path value
FOR %%G IN (%2) DO SET VALUE=%%~fG
CALL:addBuildVar "%~1" "%VALUE%"
ENDLOCAL
GOTO:EOF
