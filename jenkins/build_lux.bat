@echo off
:: This script builds LuxRender for Windows using the Jenkins CI system
:: The script is expected to be called from inside Jenkins, in the Build
:: steps
setlocal
::Removal of double quotes in the PATH to avoid failure in commands
SET PATH=%PATH:"=%
::" just to balance syntax highlight in the editor

set BUILD_ARGS=
set CPU_PLATFORM=x64
set BITNESS=64
set LUX_VERSION=1.5
set OCL=OpenCL
set VC_PLATFORM=amd64
set SETUP_ARGS=--ocl
:ParseCmdParams
if NOT "%1"=="" (
  if "%1"=="/no-ocl" (
    set BUILD_ARGS=/no-ocl
    set SETUP_ARGS=
    set OCL=NoOpenCL
  )
  if "%1"=="/x86" (
    set CPU_PLATFORM=x86
    set BITNESS=32
    set BUILD_ARGS=%BUILD_ARGS% /x86
    set VC_PLATFORM=x86
  )
  shift
  goto :ParseCmdParams
)

set BUILD_TYPE=%BITNESS%_%OCL%
SET STAGE_DIR=w:\product-deployment\luxbuildno
SET INSTALLER_DIR=windows_installer
python "%WORKSPACE%\lux\makeBuildNumber.py" --notime "%WORKSPACE%\lux\core\version.h"
cd 
echo Installer dir: %INSTALLER_DIR%
if exist %INSTALLER_DIR% (
  pushd %INSTALLER_DIR%
  hg pull -u
  popd 
) else (
  hg clone http://bitbucket.org/luxrender/windows_installer %INSTALLER_DIR%
)

echo -------------------------------------------------------------
echo Compiling LuxRender
echo Lux %LUX_VERSION%, %CPU_PLATFORM%, %OCL%, %BUILD_TYPE%
echo -------------------------------------------------------------

cd "%WORKSPACE%\windows"
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" %VC_PLATFORM%
call cmake-build-x64 /rebuild %BUILD_ARGS% 

echo ------------------------------------------------
echo Preparing the installer
echo ------------------------------------------------

set BUILD_ROOT=windows\Build_CMake
set LUX_DIR=LuxRender
set LUXRAYS_DIR=LuxRays
set DEPS_DIR=windows_deps

set INSTALLER_SRC=%INSTALLER_DIR%\Source\Files
set PYLUX_DIR=PyLux

pushd %INSTALLER_DIR%

:: Obtain the LuxBlend files
echo ------------------------------------------------
echo Checking out/updating LuxBlend
echo ------------------------------------------------
set LUXBLEND_DIR=luxblend
set LUXBLEND_REPO=luxblend25
if not exist %LUXBLEND_DIR% (
  echo Pulling a fresh copy of the repository
  hg clone https://bitbucket.org/luxrender/%LUXBLEND_REPO% %LUXBLEND_DIR%
) else (
  echo Updating LuxBlend with the changes from the server repository
  pushd %LUXBLEND_DIR%
  hg pull -u
  popd
)
echo ------------------------------------------------
echo Moving the files to the installer dirs
echo ------------------------------------------------

:: libs
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\embree.dll"      "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\lux.dll"         "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\OpenImageIO.dll" "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\QtCore4.dll"     "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\QtGui4.dll"      "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
:: Lux tools
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\luxcomp.exe"      "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\luxconsole.exe"   "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\luxmerger.exe"    "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\luxrender.exe"    "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\luxvr.exe"        "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUXRAYS_DIR%\Bin\Release\slg4.exe" "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"

if not exist "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%\%PYLUX_DIR%" md "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%\%PYLUX_DIR%"
pushd "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%\%PYLUX_DIR%"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\lux.dll"               .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\OpenImageIO.dll"       .
copy "%WORKSPACE%\%DEPS_DIR%\%CPU_PLATFORM%\Release\lib\python34.dll"       .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\pylux.pyd"             .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUXRAYS_DIR%\lib\Release\pyluxcore.pyd" .
popd

echo ------------------------------------------------
echo Copying the Visual Studio 2013 redistributable
echo ------------------------------------------------
pushd "%WORKSPACE%\%INSTALLER_DIR%" 
copy VCPP_Redist\VisualStudio2013\vcredist_%CPU_PLATFORM%.exe Source\Files

::Luxblend
cd
robocopy "%LUXBLEND_DIR%\src\luxrender" "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%\luxrender" /mir
pushd "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%\luxrender"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\lux.dll"               .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\OpenImageIO.dll"       .
copy "%WORKSPACE%\%DEPS_DIR%\%CPU_PLATFORM%\Release\lib\python34.dll"   .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\pylux.pyd"             .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUXRAYS_DIR%\lib\Release\pyluxcore.pyd" .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\embree.dll"            .

popd

echo ------------------------------------------------
echo Creating the LuxBlend zipfile
echo ------------------------------------------------
pushd "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
"C:\Program Files\7-Zip\7z" a -r LuxBlend.zip luxrender\*.*
popd
::Create the Installer by using Inno setup
python configSetup.py --platform %CPU_PLATFORM% %SETUP_ARGS% luxSetup.iss
"C:\Program Files (x86)\Inno Setup 5\ISCC" luxSetup.iss

popd
