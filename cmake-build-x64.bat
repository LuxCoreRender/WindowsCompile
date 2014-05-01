REM echo off

cls

SETLOCAL

REM pushd .

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

set CMAKE_OPTS=-G "Visual Studio 12 Win64" -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D CMAKE_BUILD_TYPE=RELWITHDEBINFO
set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:quiet /toolsversion:12.0  /property:"Platform=x64" /property:"Configuration=RelWithDebInfo"

rd /q /s cmake_build
mkdir cmake_build
cd cmake_build

rem goto BuildLux

:BuildLuxRays
mkdir luxrays_build
cd luxrays_build

set LUXRAYS_BUILD_ROOT=%CD%

%CMAKE% %CMAKE_OPTS% %LUXRAYS_ROOT%
if ERRORLEVEL 1 goto :CMakeError

msbuild %MSBUILD_OPTS% LuxRays.sln
if ERRORLEVEL 1 goto :CMakeError

cd ..

:BuildLux
set CMAKE_OPTS=%CMAKE_OPTS% -D LuxRays_HOME=%LUXRAYS_BUILD_ROOT% -D LUXRAYS_INCLUDE_DIRS=%LUXRAYS_ROOT%\include

mkdir lux_build
cd lux_build
%CMAKE% %CMAKE_OPTS% %LUX_ROOT%
if ERRORLEVEL 1 goto :CMakeError

rem msbuild %MSBUILD_OPTS% Lux.sln
rem if ERRORLEVEL 1 goto :CMakeError

goto :exit

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
goto :exit

:CMakeError
echo --- FATAL ERROR RUNNING CMAKE ---
goto :exit

:exit
goto :EOF