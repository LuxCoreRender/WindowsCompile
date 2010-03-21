@Echo off

echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building For x86                                                *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************

:: Start in a known location
pushd /d %LUX_X86_BOOST_ROOT%
cd ..
set BUILD_PATH=%CD%


:: ****************************************************************************
:: ******************************* PYTHON *************************************
:: ****************************************************************************
:Python
echo.
echo **************************************************************************
echo * Building Python 2                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON2_ROOT%\PCbuild
msbuild /nologo /p:Configuration=Debug;Platform=Win32 pcbuild.sln
msbuild /nologo /p:Configuration=Release;Platform=Win32 pcbuild.sln

echo.
echo **************************************************************************
echo * Building Python 3                                                      *
echo **************************************************************************
cd /d %LUX_X86_PYTHON3_ROOT%\PCbuild
msbuild /nologo /p:Configuration=Debug;Platform=Win32 pcbuild.sln
msbuild /nologo /p:Configuration=Release;Platform=Win32 pcbuild.sln



:: ****************************************************************************
:: ******************************* BOOST **************************************
:: ****************************************************************************
:Boost
echo.
echo **************************************************************************
echo * Building BJam                                                          *
echo **************************************************************************
cd /d %LUX_X86_BOOST_ROOT%
call bootstrap.bat

echo.
echo **************************************************************************
echo * Building Boost::IOStreams                                              *
echo **************************************************************************
bjam -sZLIB_SOURCE=%BUILD_PATH%\zlib-1.2.3 -sBZIP2_SOURCE=%BUILD_PATH%\bzip2-1.0.5 --toolset=msvc --with-iostreams --stagedir=stage/boost --build-dir=bin/boost stage

echo.
echo **************************************************************************
echo * Building Boost::Python2                                                *
echo **************************************************************************
copy ..\..\Lux\windows\support\python-2.6.jam tools\build\v2\tools\python.jam
bjam -sPYTHON_SOURCE=%BUILD_PATH%\Python-2.6.4 --toolset=msvc --with-python --stagedir=stage/python2 --build-dir=bin/python2 python=2.6 stage

echo.
echo **************************************************************************
echo * Building Boost::Python3                                                *
echo **************************************************************************
copy ..\..\Lux\windows\support\python-3.1.jam tools\build\v2\tools\python.jam
bjam -sPYTHON_SOURCE=%BUILD_PATH%\Python-3.1.1 --toolset=msvc --with-python --stagedir=stage/python3 --build-dir=bin/python3 python=3.1 stage

echo.
echo **************************************************************************
echo * Building Boost::FileSystem                                             *
echo *          Boost::Program_Options                                        *
echo *          Boost::Regex                                                  *
echo *          Boost::Serialization                                          *
echo *          Boost::Thread                                                 *
echo **************************************************************************
bjam --toolset=msvc --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-thread --stagedir=stage/boost --build-dir=bin/boost stage



:: ****************************************************************************
:: ******************************* WXWIDGETS **********************************
:: ****************************************************************************
:WxWidgets
echo.
echo **************************************************************************
echo * Building WxWidgets                                                     *
echo **************************************************************************
cd /d %LUX_X86_WX_ROOT%\build\msw
del *.sln
del *.vcproj
echo.
echo We need to convert the old project files to sln/vcproj files.
echo I will open the old project for you, and VS should prompt you
echo to convert the projects. Proceed with the conversion, save the
echo solution and quit VS. Do not build the solution, I will continue
echo the build after you have saved the new projects.
echo.
echo ADDITIONAL: Open gl\Setup Headers\setup.h (the top one) and make
echo sure that wxUSE_GLCANVAS is defined as 1 (default is 0) on line 994.
pause
start /WAIT wx.dsw
echo Conversion finished. Building...
msbuild /nologo /p:Configuration=Debug;Platform=Win32 wx.sln
msbuild /nologo /p:Configuration=Release;Platform=Win32 wx.sln



:: ****************************************************************************
:: ******************************* OPENEXR ************************************
:: ****************************************************************************
:OpenEXR
echo.
echo **************************************************************************
echo * Building OpenEXR                                                       *
echo **************************************************************************
cd /d %LUX_X86_OPENEXR_ROOT%\vc\vc8
echo.
echo We need to convert the old project files to sln/vcproj files.
echo I will open the old project for you, and VS should prompt you
echo to convert the projects. Proceed with the conversion, save the
echo solution and quit VS. Do not build the solution, I will continue
echo the build after you have saved the new projects.
echo.
echo ADDITIONAL: For the project IlmImf, please add the zlib source
echo path to the "Additional Include Directories"
echo (Found under Configuration Properties \ C/C++ \ General)
pause
start /WAIT OpenEXR.sln
pause
echo Conversion finished. Building...
msbuild /nologo /p:Configuration=Debug;Platform=Win32 Half\Half.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 Iex\Iex.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 IlmImf\IlmImf.vcproj
msbuild /nologo /p:Configuration=Debug;Platform=Win32 Imath\Imath.vcproj

msbuild /nologo /p:Configuration=Release;Platform=Win32 Half\Half.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 Iex\Iex.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 IlmImf\IlmImf.vcproj
msbuild /nologo /p:Configuration=Release;Platform=Win32 Imath\Imath.vcproj



:: ****************************************************************************
:: ******************************* LuxRender***********************************
:: ****************************************************************************
:LuxRender
echo.
echo **************************************************************************
echo * Building LuxRender                                                     *
echo **************************************************************************
cd /d ..\..\..\..\Lux\windows
msbuild /nologo /p:Configuration=Debug;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux2Debug;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux3Debug;Platform=Win32 lux.sln

msbuild /nologo /p:Configuration=Release;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux2Release;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Pylux3Release;Platform=Win32 lux.sln

msbuild /nologo /p:Configuration=Console;Platform=Win32 lux.sln
msbuild /nologo /p:Configuration=Luxmerge;Platform=Win32 lux.sln

echo.
echo **************************************************************************
echo **************************************************************************
echo *                                                                        *
echo *        Building Completed                                              *
echo *                                                                        *
echo **************************************************************************
echo **************************************************************************
popd