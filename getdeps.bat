@Echo OFF

:: Versions to download / install
SET BOOST_VER_U=1_55_0
SET BOOST_VER_P=1.55.0

SET FREEIMAGE_VER_P=3.16.0
SET FREEIMAGE_VER_N=3160

SET BZIP2_VER=1.0.6
SET CMAKE_VER=2.8.12.2
SET FFTW_VER=3.3.3
SET FREEGLUT_VER=2.8.1
SET GLEW_VER=1.10.0
SET ILMBASE_VER=2.1.0
SET JPEG_VER=9a
SET LIBPNG_VER=1.6.9
SET LIBTIFF_VER=4.0.3
SET OIIO_VER=1.3.12
SET OPENEXR_VER=2.1.0
SET OPENJPEG_VER=1.5.1
SET PYTHON3_VER=3.3.5
SET QT_VER=4.8.5
SET ZLIB_VER=1.2.8

:: Initial message to display to user
echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo We are going to download and extract these libraries:
echo   Boost      	%BOOST_VER_P%		http://www.boost.org/
echo   bzip       	%BZIP2_VER%		http://www.bzip.org/
echo   cmake      	%CMAKE_VER%	http://www.cmake.org/
echo   FFTW       	%FFTW_VER%		http://www.fftw.org/
echo   freeglut   	%FREEGLUT_VER%		http://freeglut.sourceforge.net/
echo   FreeImage  	%FREEIMAGE_VER_P%		http://freeimage.sf.net/
echo   GLEW       	%GLEW_VER%		http://glew.sourceforge.net/
echo   IlmBase    	%ILMBASE_VER%		http://www.openexr.com/
echo   JPEG       	%JPEG_VER%		http://www.ijg.org/
echo   libPNG     	%LIBPNG_VER%		http://www.libpng.org/
echo   libTIFF    	%LIBTIFF_VER%		http://www.libtiff.org/
echo   OpenEXR    	%OPENEXR_VER%		http://www.openexr.com/
echo   OpenImageIO	%OIIO_VER%		http://openimageio.org/
echo   OpenJPEG   	%OPENJPEG_VER%		http://www.openjpeg.org/
echo   Python     	%PYTHON3_VER%		http://www.python.org/
echo   QT         	%QT_VER%		http://qt-project.org/
echo   zlib       	%ZLIB_VER%		http://www.zlib.net/
echo.
pause
echo   and ONE OF:
echo       NVIDIA CUDA ToolKit
echo           https://developer.nvidia.com/cuda-toolkit
echo   OR:
echo       AMD APP SDK
echo           http://developer.amd.com/tools-and-sdks/heterogeneous-computing/amd-accelerated-parallel-processing-app-sdk/
echo   OR:
echo       Intel SDK for OpenCL
echo           http://software.intel.com/en-us/vcsource/tools/opencl-sdk
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
set D32=%DEPSROOT%\x86
set D64=%DEPSROOT%\x64

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
CALL:addBuildPathVar "LUX_WINDOWS_BUILD_ROOT", "%CD%", 1
CALL:addBuildPathVar "LUX_DEPS_ROOT", "%DEPSROOT%", 1
set LUX_WINDOWS_BUILD_ROOT="%CD%"

:OpenCL
echo.
echo **************************************************************************
echo * OpenCL SDK                                                             *
echo **************************************************************************
:OpenCLVendorChoice
echo.
echo Please select which OpenCL SDK vendor you wish to use:
echo 1. AMD
echo 2. Intel
echo 3. NVIDIA
echo.
echo Please select which OpenCL SDK vendor you wish to use:
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO OpenCL_AMD
IF %OPENCL_CHOICE% EQU 2 GOTO OpenCL_Intel
IF %OPENCL_CHOICE% EQU 3 GOTO OpenCL_NVIDIA
echo Invalid choice
GOTO OpenCLVendorChoice

:OpenCL_AMD
set OPENCL_DISPLAY_NAME=AMD APP SDK
echo.
echo Please select which AMD SDK you wish to use:
echo 1. %OPENCL_DISPLAY_NAME% 2.9 [Win 7/8/8.1] 32 bit
echo 2. %OPENCL_DISPLAY_NAME% 2.9 [Win 7/8/8.1] 64+32 bit
echo 3. I have already installed an %OPENCL_DISPLAY_NAME%
echo 4. Select another vendor
echo.
echo Please select which AMD SDK you wish to use:
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO AMD_APP_SDK_32
IF %OPENCL_CHOICE% EQU 2 GOTO AMD_APP_SDK_64
IF %OPENCL_CHOICE% EQU 3 GOTO SetAMDVars
IF %OPENCL_CHOICE% EQU 4 GOTO OpenCLVendorChoice
echo Invalid choice
GOTO OpenCL_AMD

:OpenCL_Intel
set OPENCL_DISPLAY_NAME=Intel SDK for OpenCL Applications
echo.
echo Please select which Intel SDK you wish to use:
echo 1. %OPENCL_DISPLAY_NAME% 2013 R3 [Win 7/8/8.1] 32 bit
echo 2. %OPENCL_DISPLAY_NAME% 2013 R3 [Win 7/8/8.1] 64+32 bit
echo 3. I have already installed an %OPENCL_DISPLAY_NAME%
echo 4. Select another vendor
echo.
echo Please select which Intel SDK you wish to use:
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO OpenCL_Intel_Runtime_32
IF %OPENCL_CHOICE% EQU 2 GOTO OpenCL_Intel_Runtime_64
IF %OPENCL_CHOICE% EQU 3 GOTO SetIntelVars
IF %OPENCL_CHOICE% EQU 4 GOTO OpenCLVendorChoice
echo Invalid choice
GOTO OpenCL_Intel

:OpenCL_Intel_Runtime_Common
echo.
echo If you do not have an Intel Graphics Driver with OpenCL support you will need
echo to install the Intel SDK for OpenCL - CPU Only Runtime Package.
echo.
echo Please select an option:
echo 1. Install Intel SDK for OpenCL - CPU Only Runtime Package 2013
echo 2. I have an Intel Graphics Driver with OpenCL support
echo    OR
echo    I have already installed Intel SDK for OpenCL - CPU Only Runtime Package 2013
echo 3. Select another vendor
echo.
echo Please select which Intel SDK you wish to use:
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
GOTO:EOF

:OpenCL_Intel_Runtime_32
CALL:OpenCL_Intel_Runtime_Common
IF %OPENCL_CHOICE% EQU 1 GOTO Intel_Runtime_32
IF %OPENCL_CHOICE% EQU 2 GOTO Intel_SDK_32
IF %OPENCL_CHOICE% EQU 3 GOTO OpenCLVendorChoice
echo Invalid choice
GOTO OpenCL_Intel_Runtime_32

:OpenCL_Intel_Runtime_64
CALL:OpenCL_Intel_Runtime_Common
IF %OPENCL_CHOICE% EQU 1 GOTO Intel_Runtime_64
IF %OPENCL_CHOICE% EQU 2 GOTO Intel_SDK_64
IF %OPENCL_CHOICE% EQU 3 GOTO OpenCLVendorChoice
echo Invalid choice
GOTO OpenCL_Intel_Runtime_64

:OpenCL_NVIDIA
set OPENCL_DISPLAY_NAME=NVIDIA CUDA ToolKit
echo.
echo Please select which NVIDIA SDK you wish to use:
echo 1. %OPENCL_DISPLAY_NAME% 5.5 for Desktop [XP/Vista/7/8/8.1]
echo 2. %OPENCL_DISPLAY_NAME% 5.5 for Notebook [Vista/7/8/8.1]
echo 3. I have already installed an %OPENCL_DISPLAY_NAME%
echo 4. Select another vendor
echo.
echo Please select which NVIDIA SDK you wish to use:
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO OpenCL_NVIDIA_Desktop
IF %OPENCL_CHOICE% EQU 2 GOTO OpenCL_NVIDIA_Notebook
IF %OPENCL_CHOICE% EQU 3 GOTO SetNVIDIAVars
IF %OPENCL_CHOICE% EQU 4 GOTO OpenCLVendorChoice
echo Invalid choice
GOTO OpenCL_NVIDIA

:OpenCL_NVIDIA_Desktop
echo.
echo Please select which NVIDIA SDK you wish to use:
echo 1. %OPENCL_DISPLAY_NAME% 5.5 for Desktop [Win XP] 32 bit
echo 2. %OPENCL_DISPLAY_NAME% 5.5 for Desktop [Win XP] 64+32 bit
echo 3. %OPENCL_DISPLAY_NAME% 5.5 for Desktop [Win Vista/7/8] 32 bit
echo 4. %OPENCL_DISPLAY_NAME% 5.5 for Desktop [Win Vista/7/8] 64+32 bit
echo 5. %OPENCL_DISPLAY_NAME% 5.5 for Desktop [Win 8.1] 32 bit
echo 6. %OPENCL_DISPLAY_NAME% 5.5 for Desktop [Win 8.1] 64+32 bit
echo 7. I have already installed an %OPENCL_DISPLAY_NAME%
echo 8. Select another vendor
echo.
echo Please select which NVIDIA SDK you wish to use:
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO NVIDIA_CUDA_Desktop_XP_32
IF %OPENCL_CHOICE% EQU 2 GOTO NVIDIA_CUDA_Desktop_XP_64
IF %OPENCL_CHOICE% EQU 3 GOTO NVIDIA_CUDA_Desktop_V78_32
IF %OPENCL_CHOICE% EQU 4 GOTO NVIDIA_CUDA_Desktop_V78_64
IF %OPENCL_CHOICE% EQU 5 GOTO NVIDIA_CUDA_Desktop_81_32
IF %OPENCL_CHOICE% EQU 6 GOTO NVIDIA_CUDA_Desktop_81_64
IF %OPENCL_CHOICE% EQU 7 GOTO SetNVIDIAVars
IF %OPENCL_CHOICE% EQU 8 GOTO OpenCLVendorChoice
echo Invalid choice
GOTO OpenCL_NVIDIA

:OpenCL_NVIDIA_Notebook
echo.
echo Please select which NVIDIA SDK you wish to use:
echo 1. %OPENCL_DISPLAY_NAME% 5.5 for Notebook [Win Vista/7/8] 32 bit
echo 2. %OPENCL_DISPLAY_NAME% 5.5 for Notebook [Win Vista/7/8] 64+32 bit
echo 3. %OPENCL_DISPLAY_NAME% 5.5 for Notebook [Win 8.1] 32 bit
echo 4. %OPENCL_DISPLAY_NAME% 5.5 for Notebook [Win 8.1] 64+32 bit
echo 5. I have already installed an %OPENCL_DISPLAY_NAME%
echo 6. Select another vendor
echo.
echo Please select which NVIDIA SDK you wish to use:
set OPENCL_CHOICE=0
set /p OPENCL_CHOICE="Selection? "
IF %OPENCL_CHOICE% EQU 1 GOTO NVIDIA_CUDA_Notebook_V78_32
IF %OPENCL_CHOICE% EQU 2 GOTO NVIDIA_CUDA_Notebook_V78_64
IF %OPENCL_CHOICE% EQU 3 GOTO NVIDIA_CUDA_Notebook_81_32
IF %OPENCL_CHOICE% EQU 4 GOTO NVIDIA_CUDA_Notebook_81_64
IF %OPENCL_CHOICE% EQU 5 GOTO SetNVIDIAVars
IF %OPENCL_CHOICE% EQU 6 GOTO OpenCLVendorChoice
echo Invalid choice
GOTO OpenCL_NVIDIA

:AMD_APP_SDK_32
set OPENCL_VARS=SetAMDVars
set OPENCL_NAME=AMD APP SDK 2.9 [Win 7/8/8.1] 32 bit
set OPENCL_URL=http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/12/
set OPENCL_PKG=AMD-UnifiedSDKInstaller-v1.0GA-Windows-offline-x86.exe
GOTO OpenCLInstall

:AMD_APP_SDK_64
set OPENCL_VARS=SetAMDVars
set OPENCL_NAME=AMD APP SDK 2.9 [Win 7/8/8.1] 64+32 bit
set OPENCL_URL=http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/12/
set OPENCL_PKG=AMD-UnifiedSDKInstaller-v1.0GA-Windows-offline-x64.exe
GOTO OpenCLInstall

:Intel_Runtime_32
set OPENCL_NAME=Intel SDK for OpenCL - CPU Only Runtime Package 2013 R3 [Win 7/8/8.1] 32 bit
set OPENCL_URL=http://registrationcenter.intel.com/irc_nas/3782/
set OPENCL_PKG=intel_sdk_for_ocl_applications_2013_r3_runtime_x86_setup.msi
CALL:downloadFile "%OPENCL_NAME%", "%OPENCL_URL%%OPENCL_PKG%", "%OPENCL_PKG%" || EXIT /b -1
echo.
echo I will now launch the runtime installer. You can install anywhere you like, but to be
echo on the safe side, please choose a path that doesn't contain spaces.
start /WAIT "" %DOWNLOADS%\%OPENCL_PKG%
echo Waiting for installer. When finished,
pause

:Intel_SDK_32
set OPENCL_VARS=SetIntelVars
set OPENCL_NAME=Intel SDK for OpenCL Applications 2013 R3 [Win 7/8/8.1] 32 bit
set OPENCL_URL=http://registrationcenter.intel.com/irc_nas/3782/
set OPENCL_PKG=intel_sdk_for_ocl_applications_2013_r3_x86_setup.exe
GOTO OpenCLInstall

:Intel_Runtime_64
set OPENCL_NAME=Intel SDK for OpenCL - CPU Only Runtime Package 2013 R3 [Win 7/8/8.1] 64+32 bit
set OPENCL_URL=http://registrationcenter.intel.com/irc_nas/3782/
set OPENCL_PKG=intel_sdk_for_ocl_applications_2013_r3_runtime_x64_setup.msi
CALL:downloadFile "%OPENCL_NAME%", "%OPENCL_URL%%OPENCL_PKG%", "%OPENCL_PKG%" || EXIT /b -1
echo.
echo I will now launch the runtime installer. You can install anywhere you like, but to be
echo on the safe side, please choose a path that doesn't contain spaces.
start /WAIT "" %DOWNLOADS%\%OPENCL_PKG%
echo Waiting for installer. When finished,
pause

:Intel_SDK_64
set OPENCL_VARS=SetIntelVars
set OPENCL_NAME=Intel SDK for OpenCL Applications 2013 R3 [Win 7/8/8.1] 64+32 bit
set OPENCL_URL=http://registrationcenter.intel.com/irc_nas/3782/
set OPENCL_PKG=intel_sdk_for_ocl_applications_2013_r3_x64_setup.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Desktop_XP_32
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Desktop [Win XP] 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.20_winxp_general_32.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Desktop_XP_64
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Desktop [Win XP] 64+32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.20_winxp_general_64.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Desktop_V78_32
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Desktop [Win Vista/7/8] 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.20_winvista_win7_win8_general_32.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Desktop_V78_64
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Desktop [Win Vista/7/8] 64+32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.20_winvista_win7_win8_general_64.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Desktop_81_32
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Desktop [Win 8.1] 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.31_win8.1_general_win32.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Desktop_81_64
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Desktop [Win 8.1] 64+32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.31_win8.1_general_x64.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Notebook_V78_32
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Notebook [Win Vista/7/8] 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.20_winvista_win7_win8_notebook_32.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Notebook_V78_64
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Notebook [Win Vista/7/8] 64+32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.20_winvista_win7_win8_notebook_64.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Notebook_81_32
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Notebook [Win 8.1] 32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.31_winvista_win7_win8_win8.1_notebook_win32.exe
GOTO OpenCLInstall

:NVIDIA_CUDA_Notebook_81_64
set OPENCL_VARS=SetNVIDIAVars
set OPENCL_NAME=NVIDIA CUDA ToolKit 5.5 for Notebook [Win 8.1] 64+32 bit
set OPENCL_URL=http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/
set OPENCL_PKG=cuda_5.5.31_winvista_win7_win8_win8.1_notebook_x64.exe
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

:SetAMDVars
CALL:addBuildPathVar "LUX_X86_OCL_LIBS",    "%AMDAPPSDKROOT%\lib\x86", 1
CALL:addBuildPathVar "LUX_X64_OCL_LIBS",    "%AMDAPPSDKROOT%\lib\x86_64", 1
CALL:addBuildPathVar "LUX_X86_OCL_INCLUDE", "%AMDAPPSDKROOT%\include", 1
CALL:addBuildPathVar "LUX_X64_OCL_INCLUDE", "%AMDAPPSDKROOT%\include", 1
GOTO OpenCLFinished

:SetIntelVars
CALL:addBuildPathVar "LUX_X86_OCL_LIBS",    "%INTELOCLSDKROOT%\lib\x86", 1
CALL:addBuildPathVar "LUX_X64_OCL_LIBS",    "%INTELOCLSDKROOT%\lib\x64", 1
CALL:addBuildPathVar "LUX_X86_OCL_INCLUDE", "%INTELOCLSDKROOT%\include", 1
CALL:addBuildPathVar "LUX_X64_OCL_INCLUDE", "%INTELOCLSDKROOT%\include", 1
GOTO OpenCLFinished

:SetNVIDIAVars
CALL:addBuildPathVar "LUX_X86_OCL_LIBS",    "%CUDA_PATH%\lib\Win32", 1
CALL:addBuildPathVar "LUX_X64_OCL_LIBS",    "%CUDA_PATH%\lib\x64", 1
CALL:addBuildPathVar "LUX_X86_OCL_INCLUDE", "%CUDA_PATH%\include", 1
CALL:addBuildPathVar "LUX_X64_OCL_INCLUDE", "%CUDA_PATH%\include", 1
GOTO OpenCLFinished

:OpenCLFinished

:boost
CALL:downloadFile "Boost %BOOST_VER_P%", "http://sourceforge.net/projects/boost/files/boost/%BOOST_VER_P%/boost_%BOOST_VER_U%.7z/download", "boost_%BOOST_VER_U%.7z" || EXIT /b -1
CALL:extractFile "Boost %BOOST_VER_P%", "%DOWNLOADS%\boost_%BOOST_VER_U%.7z"

CALL:addBuildPathVar "LUX_X86_BOOST_ROOT", "%D32%\boost_%BOOST_VER_U%", 1
CALL:addBuildPathVar "LUX_X64_BOOST_ROOT", "%D64%\boost_%BOOST_VER_U%", 1

:bzip
CALL:downloadFile "bzip2 %BZIP2_VER%", "http://www.bzip.org/%BZIP2_VER%/bzip2-%BZIP2_VER%.tar.gz", "bzip2-%BZIP2_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "bzip2 %BZIP2_VER%", "%DOWNLOADS%\bzip2-%BZIP2_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_BZIP_ROOT", "%D32%\bzip2-%BZIP2_VER%"
CALL:addBuildPathVar "LUX_X64_BZIP_ROOT", "%D64%\bzip2-%BZIP2_VER%"

:cmake
CALL:downloadFile "cmake %CMAKE_VER%", "http://www.cmake.org/files/v2.8/cmake-%CMAKE_VER%-win32-x86.zip", "cmake-%CMAKE_VER%-win32-x86.zip" || EXIT /b -1
CALL:extractFile "cmake %CMAKE_VER%", "%DOWNLOADS%\cmake-%CMAKE_VER%-win32-x86.zip"

CALL:addBuildPathVar "LUX_X86_CMAKE_ROOT", "%D32%\cmake-%CMAKE_VER%-win32-x86"
CALL:addBuildPathVar "LUX_X64_CMAKE_ROOT", "%D64%\cmake-%CMAKE_VER%-win32-x86"

:fftw
CALL:downloadFile "FFTW %FFTW_VER%", "http://www.fftw.org/fftw-%FFTW_VER%.tar.gz", "fftw-%FFTW_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "FFTW %FFTW_VER%", "%DOWNLOADS%\fftw-%FFTW_VER%.tar.gz"

CALL:downloadFile "FFTW 3.3 VS Solution", "ftp://ftp.fftw.org/pub/fftw/fftw-3.3-libs-visual-studio-2010.zip", "fftw-3.3-libs-visual-studio-2010.zip" || EXIT /b -1
CALL:extractFile "FFTW 3.3 VS Solution", "%DOWNLOADS%\fftw-3.3-libs-visual-studio-2010.zip", "fftw-%FFTW_VER%"

CALL:addBuildPathVar "LUX_X86_FFTW_ROOT",    "%D32%\fftw-%FFTW_VER%"
CALL:addBuildPathVar "LUX_X64_FFTW_ROOT",    "%D64%\fftw-%FFTW_VER%"

:freeglut
CALL:downloadFile "freeglut %FREEGLUT_VER%", "http://downloads.sourceforge.net/freeglut/freeglut-%FREEGLUT_VER%.tar.gz", "freeglut-%FREEGLUT_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "freeglut %FREEGLUT_VER%", "%DOWNLOADS%\freeglut-%FREEGLUT_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_GLUT_ROOT",    "%D32%\freeglut-%FREEGLUT_VER%"
CALL:addBuildPathVar "LUX_X64_GLUT_ROOT",    "%D64%\freeglut-%FREEGLUT_VER%"

:freeimage
CALL:downloadFile "FreeImage %FREEIMAGE_VER_P%", "http://downloads.sourceforge.net/freeimage/FreeImage%FREEIMAGE_VER_N%.zip", "FreeImage%FREEIMAGE_VER_N%.zip" || EXIT /b -1
CALL:extractFile "FreeImage %FREEIMAGE_VER_P%", "%DOWNLOADS%\FreeImage%FREEIMAGE_VER_N%.zip", "FreeImage%FREEIMAGE_VER_N%"

CALL:addBuildPathVar "LUX_X86_FREEIMAGE_ROOT", "%D32%\FreeImage%FREEIMAGE_VER_N%"
CALL:addBuildPathVar "LUX_X64_FREEIMAGE_ROOT", "%D64%\FreeImage%FREEIMAGE_VER_N%"

:glew
CALL:downloadFile "GLEW %GLEW_VER%", "http://sourceforge.net/projects/glew/files/glew/%GLEW_VER%/glew-%GLEW_VER%.tgz/download", "glew-%GLEW_VER%.tgz" || EXIT /b -1
CALL:extractFile "GLEW %GLEW_VER%", "%DOWNLOADS%\glew-%GLEW_VER%.tgz"

CALL:addBuildPathVar "LUX_X86_GLEW_ROOT",    "%D32%\glew-%GLEW_VER%"
CALL:addBuildPathVar "LUX_X64_GLEW_ROOT",    "%D64%\glew-%GLEW_VER%"

:ilmbase
CALL:downloadFile "IlmBase %ILMBASE_VER%", "http://download.savannah.nongnu.org/releases/openexr/ilmbase-%ILMBASE_VER%.tar.gz", "ilmbase-%ILMBASE_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "IlmBase %ILMBASE_VER%", "%DOWNLOADS%\ilmbase-%ILMBASE_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_ILMBASE_ROOT", "%D32%\ilmbase-%ILMBASE_VER%"
CALL:addBuildPathVar "LUX_X64_ILMBASE_ROOT", "%D64%\ilmbase-%ILMBASE_VER%"

:jpeg
CALL:downloadFile "JPEG %JPEG_VER%", "http://www.ijg.org/files/jpegsrc.v%JPEG_VER%.tar.gz", "jpeg-%JPEG_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "JPEG %JPEG_VER%", "%DOWNLOADS%\jpeg-%JPEG_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_JPEG_ROOT", "%D32%\jpeg-%JPEG_VER%"
CALL:addBuildPathVar "LUX_X64_JPEG_ROOT", "%D64%\jpeg-%JPEG_VER%"

:libpng
CALL:downloadFile "libPNG %LIBPNG_VER%", "http://download.sourceforge.net/libpng/libpng-%LIBPNG_VER%.tar.gz", "libpng-%LIBPNG_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "libPNG %LIBPNG_VER%", "%DOWNLOADS%\libpng-%LIBPNG_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_LIBPNG_ROOT", "%D32%\libpng-%LIBPNG_VER%"
CALL:addBuildPathVar "LUX_X64_LIBPNG_ROOT", "%D64%\libpng-%LIBPNG_VER%"

:libtiff
CALL:downloadFile "libTIFF %LIBTIFF_VER%", "ftp://ftp.remotesensing.org/pub/libtiff/tiff-%LIBTIFF_VER%.tar.gz", "tiff-%LIBTIFF_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "libTIFF %LIBTIFF_VER%", "%DOWNLOADS%\tiff-%LIBTIFF_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_LIBTIFF_ROOT", "%D32%\tiff-%LIBTIFF_VER%"
CALL:addBuildPathVar "LUX_X64_LIBTIFF_ROOT", "%D64%\tiff-%LIBTIFF_VER%"

:openexr
CALL:downloadFile "OpenEXR %OPENEXR_VER%", "http://download.savannah.nongnu.org/releases/openexr/openexr-%OPENEXR_VER%.tar.gz", "openexr-%OPENEXR_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "OpenEXR %OPENEXR_VER%", "%DOWNLOADS%\openexr-%OPENEXR_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_OPENEXR_ROOT", "%D32%\openexr-%OPENEXR_VER%"
CALL:addBuildPathVar "LUX_X64_OPENEXR_ROOT", "%D64%\openexr-%OPENEXR_VER%"

:oiio
CALL:downloadFile "OpenImageIO %OIIO_VER%", "http://github.com/OpenImageIO/oiio/archive/Release-%OIIO_VER%.tar.gz", "oiio-Release-%OIIO_VER%.tar.gz", "--no-check-certificate" || EXIT /b -1
CALL:extractFile "OpenImageIO %OIIO_VER%", "%DOWNLOADS%\oiio-Release-%OIIO_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_OIIO_ROOT", "%D32%\oiio-Release-%OIIO_VER%"
CALL:addBuildPathVar "LUX_X64_OIIO_ROOT", "%D64%\oiio-Release-%OIIO_VER%"

:openjpeg
CALL:downloadFile "OpenJPEG %OPENJPEG_VER%", "https://openjpeg.googlecode.com/files/openjpeg-%OPENJPEG_VER%.tar.gz", "openjpeg-%OPENJPEG_VER%.tar.gz", "--no-check-certificate" || EXIT /b -1
CALL:extractFile "OpenJPEG %OPENJPEG_VER%", "%DOWNLOADS%\openjpeg-%OPENJPEG_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_OPENJPEG_ROOT", "%D32%\openjpeg-%OPENJPEG_VER%"
CALL:addBuildPathVar "LUX_X64_OPENJPEG_ROOT", "%D64%\openjpeg-%OPENJPEG_VER%"

:python3
CALL:downloadFile "Python %PYTHON3_VER%", "http://python.org/ftp/python/%PYTHON3_VER%/Python-%PYTHON3_VER%.tgz", "Python-%PYTHON3_VER%.tgz", "--no-check-certificate" || EXIT /b -1
CALL:extractFile "Python %PYTHON3_VER%", "%DOWNLOADS%\Python-%PYTHON3_VER%.tgz"

CALL:addBuildPathVar "LUX_X86_PYTHON3_ROOT", "%D32%\Python-%PYTHON3_VER%"
CALL:addBuildPathVar "LUX_X64_PYTHON3_ROOT", "%D64%\Python-%PYTHON3_VER%"

:qt
CALL:downloadFile "QT %QT_VER%", "http://download.qt-project.org/official_releases/qt/4.8/%QT_VER%/qt-everywhere-opensource-src-%QT_VER%.tar.gz", "qt-everywhere-opensource-src-%QT_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "QT %QT_VER%", "%DOWNLOADS%\qt-everywhere-opensource-src-%QT_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_QT_ROOT", "%D32%\qt-everywhere-opensource-src-%QT_VER%", 1
CALL:addBuildPathVar "LUX_X64_QT_ROOT", "%D64%\qt-everywhere-opensource-src-%QT_VER%", 1

:zlib
CALL:downloadFile "zlib %ZLIB_VER%", "http://zlib.net/zlib-%ZLIB_VER%.tar.gz", "zlib-%ZLIB_VER%.tar.gz" || EXIT /b -1
CALL:extractFile "zlib %ZLIB_VER%", "%DOWNLOADS%\zlib-%ZLIB_VER%.tar.gz"

CALL:addBuildPathVar "LUX_X86_ZLIB_ROOT", "%D32%\zlib-%ZLIB_VER%"
CALL:addBuildPathVar "LUX_X64_ZLIB_ROOT", "%D64%\zlib-%ZLIB_VER%"

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
IF EXIST %D32%\%FILENAME% (IF %FORCE_EXTRACT% NEQ 1 SET EXTRACT=0)
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
