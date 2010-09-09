Echo off

set BOOST_VER_U=1_43_0
set BOOST_VER_P=1.43.0

set PYTHON2_VER=2.6.6
set PYTHON3_VER=3.1.2

set ZLIB_VER_P=1.2.3
set ZLIB_VER_N=123

set FREEIMAGE_VER_P=3.14.1
set FREEIMAGE_VER_N=3141

set QT_VER=4.6.2

set GLEW_VER=1.5.5


echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo We are going to download and extract these libraries:
echo   Boost %BOOST_VER_P%                             http://www.boost.org/
echo   QT %QT_VER%                                 http://qt.nokia.com/
echo   zlib %ZLIB_VER_P%                               http://www.zlib.net/
echo   bzip 1.0.5                               http://www.bzip.org/
echo   FreeImage %FREEIMAGE_VER_P%                         http://freeimage.sf.net/
echo   sqlite 3.5.9                             http://www.sqlite.org/
echo   Python %PYTHON2_VER% ^& Python %PYTHON3_VER%              http://www.python.org/
echo   and EITHER:
echo       GLEW %GLEW_VER%                               http://glew.sourceforge.net/
echo       GLUT 3.7.6                               http://www.idfun.de/glut64/
echo       NVIDIA CUDA ToolKit 3.1
echo           http://developer.nvidia.com/object/cuda_3_1_downloads.html
echo   OR:
echo       ATI Stream SDK 2.2
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


echo.
echo **************************************************************************
echo * Checking environment                                                   *
echo **************************************************************************
set WGET="%CD%\support\bin\wget.exe"
%WGET% --version 1> nul 2>&1
if ERRORLEVEL 9009 (
	echo.
	echo Cannot execute wget. Aborting.
	exit /b -1
)
set UNZIPBIN="%CD%\support\bin\7za.exe"
%UNZIPBIN% > nul
if ERRORLEVEL 9009 (
	echo.
	echo Cannot execute unzip. Aborting.
	exit /b -1
)

:: TODO: Add option to place deps and/or downloads elsewhere

set DOWNLOADS="%CD%\..\downloads"
:: resolve relative path
FOR %%G in (%DOWNLOADS%) do (
	set DOWNLOADS="%%~fG"
)

set D32="%CD%\..\deps\x86"
FOR %%G in (%D32%) do (
	set D32="%%~fG"
)
set D32R=%D32:"=%

set D64="%CD%\..\deps\x64"
FOR %%G in (%D64%) do (
	set D64="%%~fG"
)
set D64R=%D64:"=%

mkdir %DOWNLOADS% 2> nul
mkdir %D32% 2> nul
mkdir %D64% 2> nul

echo %DOWNLOADS%
echo %D32%
echo %D64%
echo OK

echo @Echo off > build-vars.bat
set LUX_WINDOWS_BUILD_ROOT="%CD%"
echo set LUX_WINDOWS_BUILD_ROOT="%CD%">> build-vars.bat

echo Windows Registry Editor Version 5.00 > build-vars.reg
echo. >> build-vars.reg
echo [HKEY_CURRENT_USER\Environment]>> build-vars.reg
echo "LUX_WINDOWS_BUILD_ROOT"="%CD:\=\\%">> build-vars.reg


:OpenCL
echo.
echo **************************************************************************
echo * OpenCL SDK                                                             *
echo **************************************************************************
:OpenCLChoice
set SKIP_GLEWGLUT=0
echo.
echo Please select which OpenCL SDK you wish to use:
echo.
echo 1. NVIDIA CUDA ToolKit 3.1 for Win 32 bit
echo 2. NVIDIA CUDA ToolKit 3.1 for Win 64 bit (also contains 32bit libs)
echo 3. ATI Stream SDK 2.2 for Vista/Win7 32 bit
echo 4. ATI Stream SDK 2.2 for Vista/Win7 64 bit (also contains 32bit libs)
echo 5. ATI Stream SDK 2.2 for XP SP3 32 bit
echo 6. ATI Stream SDK 2.2 for XP SP3 64 bit (also contains 32bit libs)
echo N. I have already installed an NVIDIA CUDA Toolkit
echo A. I have already installed an ATI Stream Toolkit
echo.
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO CUDA_32
IF %OPENCL_CHOICE% EQU 2 GOTO CUDA_64
IF %OPENCL_CHOICE% EQU 3 GOTO STREAM_1_32
IF %OPENCL_CHOICE% EQU 4 GOTO STREAM_1_64
IF %OPENCL_CHOICE% EQU 5 GOTO STREAM_2_32
IF %OPENCL_CHOICE% EQU 6 GOTO STREAM_2_64
IF "%OPENCL_CHOICE%" == "N" GOTO SetCUDAVars
IF "%OPENCL_CHOICE%" == "A" GOTO SetStreamVars
echo Invalid choice
GOTO OpenCLChoice

:CUDA_32
set OPENCL_VARS=SetCUDAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 3.1 for Win 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/3_1/toolkit/
set OPENCL_PKG=cudatoolkit_3.1_win_32.exe
GOTO OpenCLInstall

:CUDA_64
set OPENCL_VARS=SetCUDAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 3.1 for Win 64 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/3_1/toolkit/
set OPENCL_PKG=cudatoolkit_3.1_win_64.exe
GOTO OpenCLInstall

:STREAM_1_32
set OPENCL_VARS=SetStreamVars
set OPENCL_NAME=ATI Stream SDK 2.2 for Vista/Win7 32 bit
set OPENCL_URL=http://developer.amd.com/Downloads/
set OPENCL_PKG=ati-stream-sdk-v2.2-vista-win7-32.exe
GOTO OpenCLInstall

:STREAM_1_64
set OPENCL_VARS=SetStreamVars
set OPENCL_NAME=ATI Stream SDK 2.2 for Vista/Win7 64 bit
set OPENCL_URL=http://developer.amd.com/Downloads/
set OPENCL_PKG=ati-stream-sdk-v2.2-vista-win7-64.exe
GOTO OpenCLInstall

:STREAM_2_32
set OPENCL_VARS=SetStreamVars
set OPENCL_NAME=ATI Stream SDK 2.2 for XP SP3 32 bit
set OPENCL_URL=http://developer.amd.com/Downloads/
set OPENCL_PKG=ati-stream-sdk-v2.2-xp32.exe
GOTO OpenCLInstall

:STREAM_2_64
set OPENCL_VARS=SetStreamVars
set OPENCL_NAME=ATI Stream SDK 2.2 for XP SP3 64 bit
set OPENCL_URL=http://developer.amd.com/Downloads/
set OPENCL_PKG=ati-stream-sdk-v2.2-xp64.exe
GOTO OpenCLInstall

:OpenCLInstall
IF NOT EXIST %DOWNLOADS%\%OPENCL_PKG% (
	echo.
	echo **************************************************************************
	echo * Downloading %OPENCL_NAME%
	echo **************************************************************************
	%WGET% %OPENCL_URL%%OPENCL_PKG% -O %DOWNLOADS%\%OPENCL_PKG%
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo I will now launch the SDK installer. You can install anywhere you like, but to be
echo on the safe side, please choose a path that doesn't contain spaces.
start /WAIT "" %DOWNLOADS%\%OPENCL_PKG%
echo Waiting for installer. When finished,
pause
goto %OPENCL_VARS%

:SetCUDAVars
:: Use another cmd instance to get new env vars expanded
cmd /C echo set LUX_X86_OCL_LIBS="%CUDA_LIB_PATH%\..\lib\">> build-vars.bat
cmd /C echo set LUX_X86_OCL_INCLUDE="%CUDA_INC_PATH%">> build-vars.bat
cmd /C echo set LUX_X64_OCL_LIBS="%CUDA_LIB_PATH%">> build-vars.bat
cmd /C echo set LUX_X64_OCL_INCLUDE="%CUDA_INC_PATH%">> build-vars.bat

cmd /C echo "LUX_X86_OCL_LIBS"="%CUDA_LIB_PATH:\=\\%\\..\\lib\\">> build-vars.reg
cmd /C echo "LUX_X86_OCL_INCLUDE"="%CUDA_INC_PATH:\=\\%">> build-vars.reg
cmd /C echo "LUX_X64_OCL_LIBS"="%CUDA_LIB_PATH:\=\\%">> build-vars.reg
cmd /C echo "LUX_X64_OCL_INCLUDE"="%CUDA_INC_PATH:\=\\%">> build-vars.reg
goto OpenCLFinished

:SetStreamVars
:: Use another cmd instance to get new env vars expanded
cmd /C echo set LUX_X86_OCL_LIBS="%ATISTREAMSDKROOT%\lib\x86">> build-vars.bat
cmd /C echo set LUX_X86_OCL_INCLUDE="%ATISTREAMSDKROOT%\include">> build-vars.bat
cmd /C echo set LUX_X64_OCL_LIBS="%ATISTREAMSDKROOT%\lib\x86_64">> build-vars.bat
cmd /C echo set LUX_X64_OCL_INCLUDE="%ATISTREAMSDKROOT%\include">> build-vars.bat

cmd /C echo "LUX_X86_OCL_LIBS"="%ATISTREAMSDKROOT:\=\\%\\lib\\x86">> build-vars.reg
cmd /C echo "LUX_X86_OCL_INCLUDE"="%ATISTREAMSDKROOT:\=\\%\\include">> build-vars.reg
cmd /C echo "LUX_X64_OCL_LIBS"="%ATISTREAMSDKROOT:\=\\%\\lib\\x86_64">> build-vars.reg
cmd /C echo "LUX_X64_OCL_INCLUDE"="%ATISTREAMSDKROOT:\=\\%\\include">> build-vars.reg

set SKIP_GLEWGLUT=1
goto OpenCLFinished

:OpenCLFinished

:boost
IF NOT EXIST %DOWNLOADS%\boost_%BOOST_VER_U%.zip (
	echo.
	echo **************************************************************************
	echo * Downloading Boost                                                      *
	echo **************************************************************************
	%WGET% http://sourceforge.net/projects/boost/files/boost/%BOOST_VER_P%/boost_%BOOST_VER_U%.zip/download -O %DOWNLOADS%\boost_%BOOST_VER_U%.zip
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting Boost                                                       *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\boost_%BOOST_VER_U%.zip -o%D32% > nul
%UNZIPBIN% x -y %DOWNLOADS%\boost_%BOOST_VER_U%.zip -o%D64% > nul

echo set LUX_X86_BOOST_ROOT=%D32%\boost_%BOOST_VER_U%>> build-vars.bat
echo set LUX_X64_BOOST_ROOT=%D64%\boost_%BOOST_VER_U%>> build-vars.bat

echo "LUX_X86_BOOST_ROOT"="%D32R:\=\\%\\boost_%BOOST_VER_U%">> build-vars.reg
echo "LUX_X64_BOOST_ROOT"="%D64R:\=\\%\\boost_%BOOST_VER_U%">> build-vars.reg


:qt
IF NOT EXIST %DOWNLOADS%\qt-everywhere-opensource-src-%QT_VER%.zip (
	echo.
	echo **************************************************************************
	echo * Downloading QT                                                         *
	echo **************************************************************************
	%WGET% http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-%QT_VER%.zip -O %DOWNLOADS%\qt-everywhere-opensource-src-%QT_VER%.zip
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting QT                                                          *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\qt-everywhere-opensource-src-%QT_VER%.zip -o%D32% > nul
%UNZIPBIN% x -y %DOWNLOADS%\qt-everywhere-opensource-src-%QT_VER%.zip -o%D64% > nul

echo set LUX_X86_QT_ROOT=%D32%\qt-everywhere-opensource-src-%QT_VER%>> build-vars.bat
echo set LUX_X64_QT_ROOT=%D64%\qt-everywhere-opensource-src-%QT_VER%>> build-vars.bat

echo "LUX_X86_QT_ROOT"="%D32R:\=\\%\\qt-everywhere-opensource-src-%QT_VER%">> build-vars.reg
echo "LUX_X64_QT_ROOT"="%D64R:\=\\%\\qt-everywhere-opensource-src-%QT_VER%">> build-vars.reg


:zlib
IF NOT EXIST %DOWNLOADS%\zlib%ZLIB_VER_N%.zip (
	echo.
	echo **************************************************************************
	echo * Downloading zlib                                                       *
	echo **************************************************************************
	%WGET% http://sourceforge.net/projects/libpng/files/zlib/%ZLIB_VER_P%/zlib%ZLIB_VER_N%.zip/download -O %DOWNLOADS%\zlib%ZLIB_VER_N%.zip
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting zlib                                                        *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\zlib%ZLIB_VER_N%.zip -o%D32%\zlib-%ZLIB_VER_P% > nul
%UNZIPBIN% x -y %DOWNLOADS%\zlib%ZLIB_VER_N%.zip -o%D64%\zlib-%ZLIB_VER_P% > nul

echo set LUX_X86_ZLIB_ROOT=%D32%\zlib-%ZLIB_VER_P%>> build-vars.bat
echo set LUX_X64_ZLIB_ROOT=%D64%\zlib-%ZLIB_VER_P%>> build-vars.bat


:bzip
IF NOT EXIST %DOWNLOADS%\bzip2-1.0.5.tar.gz (
	echo.
	echo **************************************************************************
	echo * Downloading bzip                                                       *
	echo **************************************************************************
	%WGET% http://www.bzip.org/1.0.5/bzip2-1.0.5.tar.gz -O %DOWNLOADS%\bzip2-1.0.5.tar.gz
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting bzip                                                        *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\bzip2-1.0.5.tar.gz > nul
%UNZIPBIN% x -y bzip2-1.0.5.tar -o%D32% > nul
%UNZIPBIN% x -y bzip2-1.0.5.tar -o%D64% > nul
del bzip2-1.0.5.tar

echo set LUX_X86_BZIP_ROOT=%D32%\bzip2-1.0.5>> build-vars.bat
echo set LUX_X64_BZIP_ROOT=%D64%\bzip2-1.0.5>> build-vars.bat


:freeimage
IF NOT EXIST %DOWNLOADS%\FreeImage%FREEIMAGE_VER_N%.zip (
	echo.
	echo **************************************************************************
	echo * Downloading FreeImage                                                  *
	echo **************************************************************************
	%WGET% http://downloads.sourceforge.net/freeimage/FreeImage%FREEIMAGE_VER_N%.zip -O %DOWNLOADS%\FreeImage%FREEIMAGE_VER_N%.zip
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting FreeImage                                                   *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\FreeImage%FREEIMAGE_VER_N%.zip -o%D32%\FreeImage%FREEIMAGE_VER_N% > nul
%UNZIPBIN% x -y %DOWNLOADS%\FreeImage%FREEIMAGE_VER_N%.zip -o%D64%\FreeImage%FREEIMAGE_VER_N% > nul

echo set LUX_X86_FREEIMAGE_ROOT=%D32%\FreeImage%FREEIMAGE_VER_N%>> build-vars.bat
echo set LUX_X64_FREEIMAGE_ROOT=%D64%\FreeImage%FREEIMAGE_VER_N%>> build-vars.bat

echo "LUX_X86_FREEIMAGE_ROOT"="%D32R:\=\\%\\FreeImage%FREEIMAGE_VER_N%">> build-vars.reg
echo "LUX_X64_FREEIMAGE_ROOT"="%D64R:\=\\%\\FreeImage%FREEIMAGE_VER_N%">> build-vars.reg


:sqlite
IF NOT EXIST %DOWNLOADS%\sqlite-amalgamation-3_5_9.zip (
	echo.
	echo **************************************************************************
	echo * Downloading sqlite                                                     *
	echo **************************************************************************
	%WGET% http://www.sqlite.org/sqlite-amalgamation-3_5_9.zip -O %DOWNLOADS%\sqlite-amalgamation-3_5_9.zip
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting sqlite                                                      *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\sqlite-amalgamation-3_5_9.zip -o%D32%\sqlite-3.5.9 > nul
%UNZIPBIN% x -y %DOWNLOADS%\sqlite-amalgamation-3_5_9.zip -o%D64%\sqlite-3.5.9 > nul

echo set LUX_X86_SQLITE_ROOT=%D32%\sqlite-3.5.9>> build-vars.bat
echo set LUX_X64_SQLITE_ROOT=%D64%\sqlite-3.5.9>> build-vars.bat


:python2
IF NOT EXIST %DOWNLOADS%\Python-%PYTHON2_VER%.tgz (
	echo.
	echo **************************************************************************
	echo * Downloading Python 2                                                   *
	echo **************************************************************************
	%WGET% http://python.org/ftp/python/%PYTHON2_VER%/Python-%PYTHON2_VER%.tgz -O %DOWNLOADS%\Python-%PYTHON2_VER%.tgz
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting Python 2                                                    *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\Python-%PYTHON2_VER%.tgz > nul
%UNZIPBIN% x -y Python-%PYTHON2_VER%.tar -o%D32% > nul
%UNZIPBIN% x -y Python-%PYTHON2_VER%.tar -o%D64% > nul
del Python-%PYTHON2_VER%.tar

echo set LUX_X86_PYTHON2_ROOT=%D32%\Python-%PYTHON2_VER%>> build-vars.bat
echo set LUX_X64_PYTHON2_ROOT=%D64%\Python-%PYTHON2_VER%>> build-vars.bat

echo "LUX_X86_PYTHON2_ROOT"="%D32R:\=\\%\\Python-%PYTHON2_VER%">> build-vars.reg
echo "LUX_X64_PYTHON2_ROOT"="%D64R:\=\\%\\Python-%PYTHON2_VER%">> build-vars.reg


:python3
IF NOT EXIST %DOWNLOADS%\Python-%PYTHON3_VER%.tgz (
	echo.
	echo **************************************************************************
	echo * Downloading Python 3                                                   *
	echo **************************************************************************
	%WGET% http://python.org/ftp/python/%PYTHON3_VER%/Python-%PYTHON3_VER%.tgz -O %DOWNLOADS%\Python-%PYTHON3_VER%.tgz
	if ERRORLEVEL 1 (
		echo.
		echo Download failed. Are you connected to the internet?
		exit /b -1
	)
)
echo.
echo **************************************************************************
echo * Extracting Python 3                                                    *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\Python-%PYTHON3_VER%.tgz > nul
%UNZIPBIN% x -y Python-%PYTHON3_VER%.tar -o%D32% > nul
%UNZIPBIN% x -y Python-%PYTHON3_VER%.tar -o%D64% > nul
del Python-%PYTHON3_VER%.tar

echo set LUX_X86_PYTHON3_ROOT=%D32%\Python-%PYTHON3_VER%>> build-vars.bat
echo set LUX_X64_PYTHON3_ROOT=%D64%\Python-%PYTHON3_VER%>> build-vars.bat

echo "LUX_X86_PYTHON3_ROOT"="%D32R:\=\\%\\Python-%PYTHON3_VER%">> build-vars.reg
echo "LUX_X64_PYTHON3_ROOT"="%D64R:\=\\%\\Python-%PYTHON3_VER%">> build-vars.reg


IF %SKIP_GLEWGLUT% EQU 0 (
	IF NOT EXIST %DOWNLOADS%\glew-%GLEW_VER%-win32.zip (
		echo.
		echo **************************************************************************
		echo * Downloading GLEW 32 bit                                                *
		echo **************************************************************************
		%WGET% http://sourceforge.net/projects/glew/files/glew/%GLEW_VER%/glew-%GLEW_VER%-win32.zip/download -O %DOWNLOADS%\glew-%GLEW_VER%-win32.zip
		if ERRORLEVEL 1 (
			echo.
			echo Download failed. Are you connected to the internet?
			exit /b -1
		)
	)
	IF NOT EXIST %DOWNLOADS%\glew-%GLEW_VER%-win64.zip (
		echo.
		echo **************************************************************************
		echo * Downloading GLEW 64 bit                                                *
		echo **************************************************************************
		%WGET% http://sourceforge.net/projects/glew/files/glew/%GLEW_VER%/glew-%GLEW_VER%-win64.zip/download -O %DOWNLOADS%\glew-%GLEW_VER%-win64.zip
		if ERRORLEVEL 1 (
			echo.
			echo Download failed. Are you connected to the internet?
			exit /b -1
		)
	)
	echo.
	echo **************************************************************************
	echo * Extracting GLEW                                                        *
	echo **************************************************************************
	%UNZIPBIN% x -y %DOWNLOADS%\glew-%GLEW_VER%-win32.zip -o%D32%\ > nul
	%UNZIPBIN% x -y %DOWNLOADS%\glew-%GLEW_VER%-win64.zip -o%D64%\ > nul
	
	echo set LUX_X86_GLEW_INCLUDE=%D32%\glew-%GLEW_VER%\include>> build-vars.bat
	echo set LUX_X64_GLEW_INCLUDE=%D64%\glew-%GLEW_VER%\include>> build-vars.bat
	echo set LUX_X86_GLEW_LIBS=%D32%\glew-%GLEW_VER%\lib>> build-vars.bat
	echo set LUX_X64_GLEW_LIBS=%D64%\glew-%GLEW_VER%\lib>> build-vars.bat
	echo set LUX_X86_GLEW_BIN=%D32%\glew-%GLEW_VER%\bin>> build-vars.bat
	echo set LUX_X64_GLEW_BIN=%D64%\glew-%GLEW_VER%\bin>> build-vars.bat
	
	echo "LUX_X86_GLEW_INCLUDE"="%D32R:\=\\%\\glew-%GLEW_VER%\\include">> build-vars.reg
	echo "LUX_X64_GLEW_INCLUDE"="%D64R:\=\\%\\glew-%GLEW_VER%\\include">> build-vars.reg
	echo "LUX_X86_GLEW_LIBS"="%D32R:\=\\%\\glew-%GLEW_VER%\\lib">> build-vars.reg
	echo "LUX_X64_GLEW_LIBS"="%D64R:\=\\%\\glew-%GLEW_VER%\\lib">> build-vars.reg
	echo "LUX_X86_GLEW_BIN"="%D32R:\=\\%\\glew-%GLEW_VER%\\bin">> build-vars.reg
	echo "LUX_X64_GLEW_BIN"="%D64R:\=\\%\\glew-%GLEW_VER%\\bin">> build-vars.reg
	
	echo set LUX_X86_GLEW_LIBNAME=glew32>> build-vars.bat
	echo set LUX_X64_GLEW_LIBNAME=glew32>> build-vars.bat
	
	IF NOT EXIST %DOWNLOADS%\glut-3.7.6-bin-32and64.zip (
		echo.
		echo **************************************************************************
		echo * Downloading GLUT                                                       *
		echo **************************************************************************
		%WGET% http://www.idfun.de/glut64/glut-3.7.6-bin-32and64.zip -O %DOWNLOADS%\glut-3.7.6-bin-32and64.zip
		if ERRORLEVEL 1 (
			echo.
			echo Download failed. Are you connected to the internet?
			exit /b -1
		)
	)
	echo.
	echo **************************************************************************
	echo * Extracting GLUT                                                        *
	echo **************************************************************************
	:: Technically, we only need to extract once, because it conatins both 32 and 64 bit
	:: binaries, but that's awkward given the convention we've set up, and it's not very big
	%UNZIPBIN% x -y %DOWNLOADS%\glut-3.7.6-bin-32and64.zip -o%D32%\ > nul
	%UNZIPBIN% x -y %DOWNLOADS%\glut-3.7.6-bin-32and64.zip -o%D64%\ > nul
	
	:: Move the headers into the GL/ folder
	mkdir %D32%\glut-3.7.6-bin\GL
	move %D32%\glut-3.7.6-bin\glut.h %D32%\glut-3.7.6-bin\GL\
	mkdir %D64%\glut-3.7.6-bin\GL
	move %D64%\glut-3.7.6-bin\glut.h %D32%\glut-3.7.6-bin\GL\
	
	echo set LUX_X86_GLUT_INCLUDE=%D32%\glut-3.7.6-bin>> build-vars.bat
	echo set LUX_X64_GLUT_INCLUDE=%D64%\glut-3.7.6-bin>> build-vars.bat
	echo set LUX_X86_GLUT_LIBS=%D32%\glut-3.7.6-bin>> build-vars.bat
	echo set LUX_X64_GLUT_LIBS=%D64%\glut-3.7.6-bin>> build-vars.bat
	echo set LUX_X86_GLUT_BIN=%D32%\glut-3.7.6-bin>> build-vars.bat
	echo set LUX_X64_GLUT_BIN=%D64%\glut-3.7.6-bin>> build-vars.bat
	
	echo "LUX_X86_GLUT_INCLUDE"="%D32R:\=\\%\\glut-3.7.6-bin">> build-vars.reg
	echo "LUX_X64_GLUT_INCLUDE"="%D64R:\=\\%\\glut-3.7.6-bin">> build-vars.reg
	echo "LUX_X86_GLUT_LIBS"="%D32R:\=\\%\\glut-3.7.6-bin">> build-vars.reg
	echo "LUX_X64_GLUT_LIBS"="%D64R:\=\\%\\glut-3.7.6-bin">> build-vars.reg
	echo "LUX_X86_GLUT_BIN"="%D32R:\=\\%\\glut-3.7.6-bin">> build-vars.reg
	echo "LUX_X64_GLUT_BIN"="%D64R:\=\\%\\glut-3.7.6-bin">> build-vars.reg
) ELSE (
	echo **************************************************************************
	echo * Using GLEW AND GLUT from ATI Stream SDK                                *
	echo **************************************************************************
	
	cmd /C echo set LUX_X86_GLEW_INCLUDE="%ATISTREAMSDKROOT%\include">> build-vars.bat
	cmd /C echo set LUX_X64_GLEW_INCLUDE="%ATISTREAMSDKROOT%\include">> build-vars.bat
	cmd /C echo set LUX_X86_GLEW_LIBS="%ATISTREAMSDKROOT%\lib\x86">> build-vars.bat
	cmd /C echo set LUX_X64_GLEW_LIBS="%ATISTREAMSDKROOT%\lib\x86_64">> build-vars.bat
	cmd /C echo set LUX_X86_GLEW_BIN="%ATISTREAMSDKROOT%\bin\x86">> build-vars.bat
	cmd /C echo set LUX_X64_GLEW_BIN="%ATISTREAMSDKROOT%\bin\x86_64">> build-vars.bat
	
	cmd /C echo "LUX_X86_GLEW_INCLUDE"="%ATISTREAMSDKROOT:\=\\%\\include">> build-vars.reg
	cmd /C echo "LUX_X64_GLEW_INCLUDE"="%ATISTREAMSDKROOT:\=\\%\\include">> build-vars.reg
	cmd /C echo "LUX_X86_GLEW_LIBS"="%ATISTREAMSDKROOT:\=\\%\\lib\\x86">> build-vars.reg
	cmd /C echo "LUX_X64_GLEW_LIBS"="%ATISTREAMSDKROOT:\=\\%\\lib\\x86_64">> build-vars.reg
	cmd /C echo "LUX_X86_GLEW_BIN"="%ATISTREAMSDKROOT:\=\\%\\bin\\x86">> build-vars.reg
	cmd /C echo "LUX_X64_GLEW_BIN"="%ATISTREAMSDKROOT:\=\\%\\bin\\x86_64">> build-vars.reg
	
	echo set LUX_X86_GLEW_LIBNAME=glew32>> build-vars.bat
	echo set LUX_X64_GLEW_LIBNAME=glew64>> build-vars.bat
	
	cmd /C echo set LUX_X86_GLUT_INCLUDE="%ATISTREAMSDKROOT%\include">> build-vars.bat
	cmd /C echo set LUX_X64_GLUT_INCLUDE="%ATISTREAMSDKROOT%\include">> build-vars.bat
	cmd /C echo set LUX_X86_GLUT_LIBS="%ATISTREAMSDKROOT%\lib\x86">> build-vars.bat
	cmd /C echo set LUX_X64_GLUT_LIBS="%ATISTREAMSDKROOT%\lib\x86_64">> build-vars.bat
	cmd /C echo set LUX_X86_GLUT_BIN="%ATISTREAMSDKROOT%\bin\x86">> build-vars.bat
	cmd /C echo set LUX_X64_GLUT_BIN="%ATISTREAMSDKROOT%\bin\x86_64">> build-vars.bat
	
	cmd /C echo "LUX_X86_GLUT_INCLUDE"="%ATISTREAMSDKROOT:\=\\%\\include">> build-vars.reg
	cmd /C echo "LUX_X64_GLUT_INCLUDE"="%ATISTREAMSDKROOT:\=\\%\\include">> build-vars.reg
	cmd /C echo "LUX_X86_GLUT_LIBS"="%ATISTREAMSDKROOT:\=\\%\\lib\\x86">> build-vars.reg
	cmd /C echo "LUX_X64_GLUT_LIBS"="%ATISTREAMSDKROOT:\=\\%\\lib\\x86_64">> build-vars.reg
	cmd /C echo "LUX_X86_GLUT_BIN"="%ATISTREAMSDKROOT:\=\\%\\bin\\x86">> build-vars.reg
	cmd /C echo "LUX_X64_GLUT_BIN"="%ATISTREAMSDKROOT:\=\\%\\bin\\x86_64">> build-vars.reg
)



echo.
echo **************************************************************************
echo * DONE                                                                   *
echo **************************************************************************
echo.
:: echo I have created a batch file build-vars.bat that will set the required path
:: echo variables for building.
:: echo.
echo I have also created a registry file build-vars.reg that will permanently set 
echo the required path variables for building. After importing this into the 
echo registry, you'll need to log out and back in for the changes to take effect.
echo You need to do this before building LuxRender with Visual Studio.
echo.
:: echo To build for x86 you can now run build-x86.bat from a Visual Studio Command
:: echo Prompt window.
echo To build dependencies for x86 you can now run build-luxrender-x86.bat from a Visual
echo Studio Command Prompt window.
echo.
:: echo To build for x64 you can now run build-x64.bat from a Visual Studio Command
:: echo Prompt window.
echo To build dependencies for x64 you can now run build-luxrender-x64.bat from a Visual
echo Studio Command Prompt window.
echo.
