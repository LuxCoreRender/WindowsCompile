@echo off

del old_changelog.txt 2>&1 1>nul
ren changelog.txt old_changelog.txt 2>&1 1>nul
for /f %%a in (last_changeset.txt) do hg shortlog --prune %%a -R ..\lux\ >> changelog.txt

move /y last_changeset.txt old_changeset.txt >nul
for /f "tokens=1,2" %%a in ('hg sum -R ..\lux') do if "%%a"=="parent:" (for /f "delims=: tokens=2" %%c in ("%%b") do echo %%c > last_changeset.txt)


del old_changelog.luxrays.txt 2>&1 1>nul
ren changelog.luxrays.txt old_changelog.luxrays.txt 2>&1 1>nul
for /f %%a in (last_changeset.luxrays.txt) do hg shortlog --prune %%a -R ..\luxrays\ >> changelog.luxrays.txt

move /y last_changeset.luxrays.txt old_changeset.luxrays.txt >nul
for /f "tokens=1,2" %%a in ('hg sum -R ..\luxrays') do if "%%a"=="parent:" (for /f "delims=: tokens=2" %%c in ("%%b") do echo %%c > last_changeset.luxrays.txt)