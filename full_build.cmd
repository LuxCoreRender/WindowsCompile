set LUX_WINDOWS_BUILD_ROOT=%CD%

msbuild /v:m /m full_build.txt

if NOT ERRORLEVEL 1 goto :install

echo.
echo ========== ERROR DURING BUILD ===========
echo.

goto :EOF

:install
cd /D %LUX_WINDOWS_BUILD_ROOT%

call install-x64.bat
call install-x86.bat


del changelog.old.txt >nul
ren changelog.txt changelog.old.txt >nul
for /f %%a in (last_changeset.txt) do hg shortlog --prune %%a -R ..\lux\ >> changelog.txt

move /y last_changeset.txt old_changeset.txt >nul
for /f "tokens=1,2" %%a in ('hg sum -R ..\lux') do if "%%a"=="parent:" (for /f "delims=: tokens=2" %%c in ("%%b") do echo %%c > last_changeset.txt)


del changelog.luxrays.old.txt >nul
ren changelog.luxrays.txt changelog.luxrays.old.txt >nul
for /f %%a in (last_changeset.luxrays.txt) do hg shortlog --prune %%a -R ..\luxrays\ >> changelog.luxrays.txt

move /y last_changeset.luxrays.txt old_changeset.luxrays.txt >nul
for /f "tokens=1,2" %%a in ('hg sum -R ..\luxrays') do if "%%a"=="parent:" (for /f "delims=: tokens=2" %%c in ("%%b") do echo %%c > last_changeset.luxrays.txt)