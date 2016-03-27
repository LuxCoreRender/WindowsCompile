@echo off

SETLOCAL ENABLEEXTENSIONS

set FULL_REBUILD=0
set BUILD_LUXRAYS_ONLY=0
set BUILD_LUXMARK_ONLY=0
set BUILD_LUXRENDER_ONLY=0
set MSBUILD_PLATFORM=x64
set DISABLE_OPENCL=0
set CPU_PLATFORM=x64
set BUILD_TYPE=Release

:ParseCmdParams
if "%1" EQU "" goto Start
if /i "%1" EQU "/rebuild" set FULL_REBUILD=1
if /i "%1" EQU "luxrays" set BUILD_LUXRAYS_ONLY=1
if /i "%1" EQU "luxmark" set BUILD_LUXMARK_ONLY=1
if /i "%1" EQU "luxrender" set BUILD_LUXRENDER_ONLY=1
if /i "%1" EQU "/no-ocl" set DISABLE_OPENCL=1
if /i "%1" EQU "/debug" set BUILD_TYPE=Debug
if /i "%1" EQU "/x86" (
  set CPU_PLATFORM=x86
  set MSBUILD_PLATFORM=Win32
)

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
::for %%a in (..\windows_deps\bin\CMake\bin\cmake.exe) do set CMAKE=%%~fa
for %%a in (..\luxrays) do set LUXRAYS_ROOT=%%~fa
for %%a in (..\luxmark) do set LUXMARK_ROOT=%%~fa
for %%a in (..\lux) do set LUX_ROOT=%%~fa

echo Finding if CMake is installed...
for /f "tokens=*" %%a in ('where cmake') do SET CMAKE=%%~fa  

if exist "%CMAKE%" (
  echo CMake found at "%CMAKE%"
) else (
  for %%a in (..\windows_deps\bin\CMake\bin\cmake.exe) do set CMAKE=%%~fa
)

if not exist "%CMAKE%" goto CMakeNotFound
if not exist "%LUXRAYS_ROOT%" goto LuxRaysNotFound
if not exist "%LUX_ROOT%" goto LuxNotFound

:: Determine if we have CMake 2 or 3
for /F "tokens=3" %%G in ('cmake --version ^| find "cmake version"') do set CMAKE_VER=%%G
for /F "tokens=1 delims=." %%G in ("%CMAKE_VER%") do set CMAKE_VN_MAJOR=%%G
echo We are using CMake version: %CMAKE_VN_MAJOR%
:: Default values
set CMAKE_GENERATOR="Visual Studio 12 2013"
set CMAKE_TOOLSET=-T v120_xp
if "%CPU_PLATFORM%"=="x64" (
  set CMAKE_PLATFORM=-A %CPU_PLATFORM%
) else (
  set CMAKE_PLATFORM=
  set CMAKE_TOOLSET=
)

if %CMAKE_VN_MAJOR%==2 (
  set CMAKE_GENERATOR="Visual Studio 12 Win64"
  set CMAKE_PLATFORM=
)

for %%a in (..\windows_deps\include) do set INCLUDE_DIR=%%~fa
for %%a in (..\windows_deps\%CPU_PLATFORM%\Release\lib) do set LIB_DIR=%%~fa
echo LIB_DIR: %LIB_DIR%

::set LUX_X64_BOOST_ROOT=%INCLUDE_DIR%\Boost
::set LUX_X64_GLUT_ROOT=%INCLUDE_DIR%
::set LUX_X64_GLEW_ROOT=%INCLUDE_DIR%
::set LUX_X64_FREEIMAGE_ROOT=%INCLUDE_DIR%
::set LUX_X64_QT_ROOT=%INCLUDE_DIR%\Qt

if %DISABLE_OPENCL% EQU 1 (
  echo -----------------------------------------
  echo Disabling OpenCL
  echo -----------------------------------------

  set OCL_OPTION=-DLUXRAYS_DISABLE_OPENCL=1
) else (
  if "%CPU_PLATFORM%"=="x86" (
    set OCL_OPTION=-DOPENCL_X86=1
  ) else (
    set OCL_OPTION=
  )
)

set CMAKE_OPTS=-G %CMAKE_GENERATOR% %CMAKE_PLATFORM% %CMAKE_TOOLSET% -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D PYTHON_LIBRARY="%LIB_DIR%" -D PYTHON_INCLUDE_DIR="%INCLUDE_DIR%\Python3" -D CMAKE_BUILD_TYPE=%BUILD_TYPE% %OCL_OPTION%
rem To display only errors add: /clp:ErrorsOnly
set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:normal /toolsversion:12.0 /property:"Platform=%MSBUILD_PLATFORM%" /property:"Configuration=%BUILD_TYPE%" /p:WarningLevel=0

if %FULL_REBUILD%==1 rd /q /s Build_CMake
mkdir Build_CMake
cd Build_CMake

set LUXRAYS_BUILD_ROOT=%CD%\LuxRays
set LUXMARK_BUILD_ROOT=%CD%\LuxMark
set LUXRENDER_BUILD_ROOT=%CD%\LuxRender

set CMAKE_CACHE=CMakeCache.txt

if %BUILD_LUXMARK_ONLY%==1 goto BuildLuxMark
if %BUILD_LUXRENDER_ONLY%==1 goto BuildLuxRender

:BuildLuxRays
mkdir %LUXRAYS_BUILD_ROOT%
cd /d %LUXRAYS_BUILD_ROOT%

if exist %CMAKE_CACHE% del %CMAKE_CACHE%
"%CMAKE%" %CMAKE_OPTS% %LUXRAYS_ROOT%
if ERRORLEVEL 1 goto CMakeError

msbuild %MSBUILD_OPTS% LuxRays.sln
if ERRORLEVEL 1 goto CMakeError

cd ..

if %BUILD_LUXRAYS_ONLY%==1 goto exit

:BuildLuxMark
If Not Exist %LUXMARK_BUILD_ROOT% (goto BuildLuxRender)

set CMAKE_OPTS=%CMAKE_OPTS% -D LuxRays_HOME=%LUXRAYS_BUILD_ROOT% -D LUXRAYS_INCLUDE_DIRS=%LUXRAYS_ROOT%\include

mkdir %LUXMARK_BUILD_ROOT%
cd /d %LUXMARK_BUILD_ROOT%

if exist %CMAKE_CACHE% del %CMAKE_CACHE%
"%CMAKE%" %CMAKE_OPTS% %LUXMARK_ROOT%
if ERRORLEVEL 1 goto CMakeError

msbuild %MSBUILD_OPTS% LuxMark.sln

if ERRORLEVEL 1 goto CMakeError

cd ..

if %BUILD_LUXMARK_ONLY%==1 goto exit

:BuildLuxRender
set CMAKE_OPTS=%CMAKE_OPTS% -D LuxRays_HOME=%LUXRAYS_BUILD_ROOT% -D LUXRAYS_INCLUDE_DIRS=%LUXRAYS_ROOT%\include

mkdir %LUXRENDER_BUILD_ROOT%
cd /d %LUXRENDER_BUILD_ROOT%

if exist %CMAKE_CACHE% del %CMAKE_CACHE%
"%CMAKE%" %CMAKE_OPTS% %LUX_ROOT%
if ERRORLEVEL 1 goto CMakeError
echo "Compiling the Lux project"
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
exit /B 1
goto exit

:exit
goto :EOF
