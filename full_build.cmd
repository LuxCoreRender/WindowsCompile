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


call make_changelogs.cmd
