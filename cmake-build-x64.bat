@echo off

SETLOCAL ENABLEEXTENSIONS

set FULL_REBUILD=0
set BUILD_LUXCORE_ONLY=0
set BUILD_LUXMARK_ONLY=0
set CMAKE_ONLY=0
set MSBUILD_PLATFORM=x64
set DISABLE_OPENCL=0
set CPU_PLATFORM=x64
set BUILD_TYPE=Release
set BUILD_DLL=0
set PYTHON_VERSION=35

:ParseCmdParams
if "%1" EQU "" goto Start
if /i "%1" EQU "/rebuild" set FULL_REBUILD=1
if /i "%1" EQU "luxcore" set BUILD_LUXCORE_ONLY=1
if /i "%1" EQU "luxmark" set BUILD_LUXMARK_ONLY=1
if /i "%1" EQU "/cmake-only" set CMAKE_ONLY=1
if /i "%1" EQU "/no-ocl" set DISABLE_OPENCL=1
if /i "%1" EQU "/dll" set BUILD_DLL=1
if /i "%1" EQU "/debug" set BUILD_TYPE=Debug
if /i "%1" EQU "/python35" set PYTHON_VERSION=35
if /i "%1" EQU "/python36" set PYTHON_VERSION=36
if /i "%1" EQU "/python37" set PYTHON_VERSION=37

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
::for %%a in (..\WindowsCompileDeps\bin\CMake\bin\cmake.exe) do set CMAKE=%%~fa
for %%a in (..\LuxCore) do set LUXCORE_ROOT=%%~fa
for %%a in (..\LuxMark) do set LUXMARK_ROOT=%%~fa

echo Finding if CMake is installed...
for /f "tokens=*" %%a in ('where cmake') do SET CMAKE=%%~fa  

if exist "%CMAKE%" (
  echo CMake found at "%CMAKE%"
) else (
  for %%a in (..\WindowsCompileDeps\bin\CMake\bin\cmake.exe) do set CMAKE=%%~fa
)

if not exist "%CMAKE%" goto CMakeNotFound
if not exist "%LUXCORE_ROOT%" goto LuxCoreNotFound

:: Determine if we have CMake 2 or 3
for /F "tokens=3" %%G in ('cmd /c "%CMAKE%" --version ^| findstr /I /C:"cmake version"') do set CMAKE_VER=%%G
for /F "tokens=1 delims=." %%G in ("%CMAKE_VER%") do set CMAKE_VN_MAJOR=%%G
echo We are using CMake version: %CMAKE_VN_MAJOR%
:: Default values
set CMAKE_GENERATOR="Visual Studio 15 2017"
set CMAKE_TOOLSET=-T v141,host=x64
if "%CPU_PLATFORM%"=="x64" (
  set CMAKE_PLATFORM=-A %CPU_PLATFORM%
) else (
  set CMAKE_PLATFORM=
  set CMAKE_TOOLSET=
)

if %CMAKE_VN_MAJOR%==2 (
  echo You need CMake 3.11 or better to build LuxCoreRender
  goto CMakeNotFound
)

for %%a in (..\WindowsCompileDeps\include) do set INCLUDE_DIR=%%~fa
for %%a in (..\WindowsCompileDeps\%CPU_PLATFORM%\Release\lib) do set LIB_DIR=%%~fa
echo LIB_DIR: %LIB_DIR%

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

if %BUILD_DLL% EQU 1 (
  echo -----------------------------------------
  echo Enable LuxCore DLL
  echo -----------------------------------------

  set DLL_OPTION=-DBUILD_LUXCORE_DLL=1
) else (
  set DLL_OPTION=
)

set CMAKE_OPTS=-G %CMAKE_GENERATOR% %CMAKE_PLATFORM% %CMAKE_TOOLSET% -D LUXRAYS_CUSTOM_CONFIG=cmake\SpecializedConfig\Config_Windows.cmake -D CMAKE_INCLUDE_PATH="%INCLUDE_DIR%" -D CMAKE_LIBRARY_PATH="%LIB_DIR%" -D PYTHON_LIBRARY="%LIB_DIR%" -D PYTHON_V="%PYTHON_VERSION%" -D PYTHON_INCLUDE_DIR="%INCLUDE_DIR%\Python%PYTHON_VERSION%" -D CMAKE_BUILD_TYPE=%BUILD_TYPE% %OCL_OPTION% %DLL_OPTION%
rem To display only errors add: /clp:ErrorsOnly
set MSBUILD_OPTS=/nologo /maxcpucount /verbosity:normal /toolsversion:15.0 /property:"Platform=%MSBUILD_PLATFORM%" /property:"Configuration=%BUILD_TYPE%" /p:WarningLevel=0

if %FULL_REBUILD%==1 rd /q /s Build_CMake
mkdir Build_CMake
cd Build_CMake

set LUXCORE_BUILD_ROOT=%CD%\LuxCore
set LUXMARK_BUILD_ROOT=%CD%\LuxMark

set CMAKE_CACHE=CMakeCache.txt

if %BUILD_LUXMARK_ONLY%==1 goto BuildLuxMark

:BuildLuxCore
mkdir %LUXCORE_BUILD_ROOT%
cd /d %LUXCORE_BUILD_ROOT%

if exist %CMAKE_CACHE% del %CMAKE_CACHE%
"%CMAKE%" %CMAKE_OPTS% %LUXCORE_ROOT%
if ERRORLEVEL 1 goto CMakeError

if %CMAKE_ONLY%==0 (
  msbuild %MSBUILD_OPTS% LuxRays.sln
  if ERRORLEVEL 1 goto CMakeError
)

cd ..

if %BUILD_LUXCORE_ONLY%==1 goto exit

:BuildLuxMark
If Not Exist %LUXMARK_ROOT% (goto exit)

set CMAKE_OPTS=%CMAKE_OPTS% -D LuxRays_HOME=%LUXCORE_BUILD_ROOT% -D LUXRAYS_INCLUDE_DIRS=%LUXCORE_ROOT%\include -D SLG_INCLUDE_DIRS=%LUXCORE_ROOT%\include -D LUXCORE_INCLUDE_DIRS=%LUXCORE_ROOT%\include

mkdir %LUXMARK_BUILD_ROOT%
cd /d %LUXMARK_BUILD_ROOT%

echo "%CMAKE%" %CMAKE_OPTS% %LUXMARK_ROOT%
if exist %CMAKE_CACHE% del %CMAKE_CACHE%
"%CMAKE%" %CMAKE_OPTS% %LUXMARK_ROOT%
if ERRORLEVEL 1 goto CMakeError

if %CMAKE_ONLY%==0 (
  msbuild %MSBUILD_OPTS% LuxMark.sln
  if ERRORLEVEL 1 goto CMakeError
)

cd ..

goto exit

:CMakeNotFound
echo --- FATAL ERROR: CMake not found ---
echo.
goto exit

:LuxCoreNotFound
goto GeneralNotFound

:GeneralNotFound
echo Please make sure you've cloned the repositories
echo so that they have the following structure:
echo   root_dir\LuxCore
echo   root_dir\LuxMark (optional)
echo   root_dir\WindowsCompile
echo   root_dir\WindowsCompileDeps
goto exit

:CMakeError
echo --- FATAL ERROR RUNNING CMAKE ---
exit /B 1
goto exit

:exit
goto :EOF
