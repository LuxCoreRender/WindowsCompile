@echo off
:: This script builds LuxRender for Windows using the Jenkins CI system
:: The script is expected to be called from inside Jenkins, in the Build
:: steps

::Removal of double quotes in the PATH to avoid failure in commands
SET PATH=%PATH:"=%
::" just to balance syntax highlight in the editor
SET STAGE_DIR=w:\product-deployment\luxbuildno
SET INSTALLER_DIR=windows_installer
python "%WORKSPACE%\lux\makeBuildNumber.py" --notime "%WORKSPACE%\lux\core\version.h"
if exist %INSTALLER_DIR% (
  cd %INSTALLER_DIR%
  hg pull -u
) else (
  hg clone http://src.luxrender.net/windows_installer %INSTALLER_DIR%
)
echo ------------------------------------------------
echo Compiling LuxRender
echo ------------------------------------------------

cd "%WORKSPACE%\windows"
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" amd64
call cmake-build-x64

echo ------------------------------------------------
echo Preparing the installer
echo ------------------------------------------------

set BUILD_ROOT=windows\Build_CMake
set LUX_DIR=LuxRender
set LUXRAYS_DIR=LuxRays
set DEPS_DIR=windows_deps

set INSTALLER_ROOT=windows_installer
set INSTALLER_SRC=%INSTALLER_ROOT%\Source\Files
set BUILD_TYPE=64_OpenCL
set PYLUX_DIR=PyLux
set PLATFORM=x64
set LUX_VERSION=1.5
set OCL=OpenCL

if not exist %INSTALLER_ROOT% (
  hg clone http://src.luxrender.net/%INSTALLER_ROOT% %INSTALLER_ROOT%
)

pushd %INSTALLER_ROOT%

:: Obtain the LuxBlend files
echo ------------------------------------------------
echo Checking out/updating LuxBlend
echo ------------------------------------------------
set LUXBLEND_DIR=luxblend
set LUXBLEND_REPO=luxblend25
if not exist %LUXBLEND_DIR% (
  hg clone http://src.luxrender.net/%LUXBLEND_REPO% %LUXBLEND_DIR%
) else (
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
copy "%WORKSPACE%\%DEPS_DIR%\%PLATFORM%\Release\lib\python34.dll"       .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\pylux.pyd"             .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUXRAYS_DIR%\lib\Release\pyluxcore.pyd" .
popd

echo ------------------------------------------------
echo Copying the Visual Studio 2013 redistributable
echo ------------------------------------------------
pushd "%WORKSPACE%\%INSTALLER_ROOT%" 
copy VCPP_Redist\VisualStudio2013\vcredist_x64.exe Source\Files

::Luxblend
cd
robocopy "%LUXBLEND_DIR%\src\luxrender" "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%\luxrender" /mir
pushd "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%\luxrender"
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\lux.dll"               .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\OpenImageIO.dll"       .
copy "%WORKSPACE%\%DEPS_DIR%\%PLATFORM%\Release\lib\python34.dll"       .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUX_DIR%\RELEASE\pylux.pyd"             .
copy "%WORKSPACE%\%BUILD_ROOT%\%LUXRAYS_DIR%\lib\Release\pyluxcore.pyd" .
popd

echo ------------------------------------------------
echo Creating the LuxBlend zipfile
echo ------------------------------------------------
pushd "%WORKSPACE%\%INSTALLER_SRC%\LuxRender_%BUILD_TYPE%"
"C:\Program Files\7-Zip\7z" a -r LuxBlend.zip luxrender\*.*
popd
::Create the Installer by using Inno setup
"C:\Program Files (x86)\Inno Setup 5\ISCC" luxSetup.iss

popd
echo ------------------------------------------------
echo Delivering the build to the LuxRender.net server
echo ------------------------------------------------

cd %WORKSPACE%\%INSTALLER_ROOT%\Output
set LUX_SETUP=LuxRender %LUX_VERSION% %PLATFORM% %OCL% Setup.exe
scp -i \Users\Paolo\.ssh\id_rsa "%LUX_SETUP%" pciccone@luxrender.net:/home/pciccone
echo File transferred, moving it to the designated directory and setting the access rights
ssh -i \Users\Paolo\.ssh\id_rsa pciccone@luxrender.net "sudo mv '/home/pciccone/%LUX_SETUP%' /home/lux_release/release/builds"
ssh -i \Users\Paolo\.ssh\id_rsa pciccone@luxrender.net "sudo chown -R www:www /home/lux_release/release/builds/*"
