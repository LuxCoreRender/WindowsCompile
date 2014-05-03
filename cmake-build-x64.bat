REM echo off

cls

SETLOCAL ENABLEEXTENSIONS


set FULL_REBUILD=0
set BUILD_LUXRAYS_ONLY=0
set BUILD_LUXRENDER_ONLY=0

:ParseCmdParams
if "%1" EQU "" goto Start
if /i "%1" EQU "/rebuild" set FULL_REBUILD=1
if /i "%1" EQU "luxrays" set BUILD_LUXRAYS_ONLY=1
if /i "%1" EQU "luxrender" set BUILD_LUXRENDER_ONLY=1
shift
goto ParseCmdParams



:Start

if %FULL_REBUILD%==1 (
  echo =========================================
  echo ============  FULL REBUILD  =============
  echo =========================================
)

for %%a in (.) do set LUX_WINDOWS_BUILD_ROOT=%%~fa
for %%a in (support\bin) do set SUPPORT_BIN=%%~fa
for %%a in (..\windows_deps\bin\CMake\bin\cmake.exe) do set CMAKE=%%~fa
for %%a in (..\luxrays) do set LUXRAYS_ROOT=%%~fa
for %%a in (..\lux) do set LUX_ROOT=%%~fa

if not exist "%CMAKE%" goto CMakeNotFound
if not exist "%LUXRAYS_ROOT%" goto LuxRaysNotFound
if not exist "%LUX_ROOT%" goto LuxNotFound

for %%a in (..\windows_deps\include) do set INCLUDE_DIR=%%~fa
for %%a in (..\windows_deps\x64\Release\lib) do set LIB_DIR=%%~fa

set LUX_X64_BOOST_ROOT=%INCLUDE_DIR%\Boost
set LUX_X64_GLUT_ROOT=%INCLUDE_DIR%
set LUX_X64_GLEW_ROOT=%INCLUDE_DIR%
set LUX_X64_FREEIMAGE_ROOT=%INCLUDE_DIR%
set LUX_X64_QT_ROOT=%INCLUDE_DIR%\Qt

set CMAKE_OPTS=-G "Visual Studio 12 Win64" -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D CMAKE_BUILD_TYPE=RELEASE
set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:quiet /toolsversion:12.0  /property:"Platform=x64" /property:"Configuration=Release"

if %FULL_REBUILD%==1 rd /q /s Build_CMake
mkdir Build_CMake
cd Build_CMake

set LUXRAYS_BUILD_ROOT=%CD%\LuxRays
set LUXRENDER_BUILD_ROOT=%CD%\LuxRender

if %BUILD_LUXRENDER_ONLY%==1 goto BuildLuxRender

:BuildLuxRays
mkdir %LUXRAYS_BUILD_ROOT%
cd /d %LUXRAYS_BUILD_ROOT%

del CMakeCache.txt
%CMAKE% %CMAKE_OPTS% %LUXRAYS_ROOT%
if ERRORLEVEL 1 goto CMakeError

msbuild %MSBUILD_OPTS% LuxRays.sln
if ERRORLEVEL 1 goto CMakeError

cd ..

if %BUILD_LUXRAYS_ONLY%==1 goto exit

:BuildLuxRender
set CMAKE_OPTS=%CMAKE_OPTS% -D LuxRays_HOME=%LUXRAYS_BUILD_ROOT% -D LUXRAYS_INCLUDE_DIRS=%LUXRAYS_ROOT%\include

mkdir %LUXRENDER_BUILD_ROOT%
cd /d %LUXRENDER_BUILD_ROOT%

del CMakeCache.txt
%CMAKE% %CMAKE_OPTS% %LUX_ROOT%
if ERRORLEVEL 1 goto CMakeError

msbuild %MSBUILD_OPTS% Lux.sln
if ERRORLEVEL 1 goto CMakeError

cd ..

goto exit

:CMakeNotFound
echo --- FATAL ERROR: CMake not found ---
echo.
goto GeneralNotFound

:LuxRaysNotFound
goto GeneralNotFound

:LuxNotFound
goto GeneralNotFound

:GeneralNotFound
echo Please make sure you've cloned the repositories
echo so that they have the following structure:
echo   root_dir\lux
echo   root_dir\lux_rays
echo   root_dir\windows
echo   root_dir\windows_deps
goto exit

:CMakeError
echo --- FATAL ERROR RUNNING CMAKE ---
goto exit

:exit
goto :EOF
