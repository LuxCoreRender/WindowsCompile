@Echo off



echo.
echo **************************************************************************
echo * Startup                                                                *
echo **************************************************************************
echo.
echo This script will use 2 pre-built binaries to download and extract source
echo code from the internet:
echo  1: GNU wget.exe       from http://gnuwin32.sourceforge.net/packages/wget.htm
echo  2: 7za.exe (7-zip)    from http://7-zip.org/download.html
echo.
echo If you do not wish to execute these binaries for any reason, PRESS CTRL-C NOW
echo Otherwise,
pause



echo.
echo **************************************************************************
echo * Checking environment                                                   *
echo **************************************************************************
set WGET=%CD%\support\bin\wget.exe
%WGET% --version 1> nul 2>&1
if ERRORLEVEL 9009 (
    echo.
    echo Cannot execute wget. Aborting.
    exit /b -1
)
set UNZIPBIN=%CD%\support\bin\7za.exe
%UNZIPBIN% > nul
if ERRORLEVEL 9009 (
    echo.
    echo Cannot execute unzip. Aborting.
    exit /b -1
)


set DOWNLOADS=%CD%\..\downloads
:: resolve relative path
FOR %%G in (%DOWNLOADS%) do (
    set DOWNLOADS=%%~fG
)

set D32=%CD%\..\deps\x86
FOR %%G in (%D32%) do (
    set D32=%%~fG
)

set D64=%CD%\..\deps\x64
FOR %%G in (%D64%) do (
    set D64=%%~fG
)

mkdir %DOWNLOADS% 2> nul
mkdir %D32% 2> nul
mkdir %D64% 2> nul

echo %DOWNLOADS%
echo %D32%
echo %D64%
echo OK

echo @Echo off > build-vars.bat

echo.
echo **************************************************************************
echo * Downloading Boost                                                      *
echo **************************************************************************
%WGET% http://sourceforge.net/projects/boost/files/boost/1.42.0/boost_1_42_0.zip/download -O %DOWNLOADS%\boost_1_42_0.zip
if ERRORLEVEL 1 (
    echo.
    echo Download failed. Are you connected to the internet?
    exit /b -1
)

echo.
echo **************************************************************************
echo * Extracting Boost                                                       *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\boost_1_42_0.zip -o%D32% > nul
xcopy /Q/E %D32%\boost_1_42_0 %D64%\boost_1_42_0\

echo set LUX_X86_BOOST_ROOT="%D32%\boost_1_42_0" >> build-vars.bat
echo set LUX_X64_BOOST_ROOT="%D64%\boost_1_42_0" >> build-vars.bat

echo.
echo **************************************************************************
echo * Downloading WxWidgets                                                  *
echo **************************************************************************
%WGET% http://sourceforge.net/projects/wxwindows/files/wxAll/2.8.10/wxWidgets-2.8.10.zip/download -O %DOWNLOADS%\wxWidgets-2.8.10.zip
if ERRORLEVEL 1 (
    echo.
    echo Download failed. Are you connected to the internet?
    exit /b -1
)

echo.
echo **************************************************************************
echo * Extracting WxWidgets                                                   *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\wxWidgets-2.8.10.zip -o%D32% > nul
xcopy /Q/E %D32%\wxWidgets-2.8.10 %D64%\wxWidgets-2.8.10\
exit /b -1

echo set LUX_X86_WX_ROOT="%D32%\wxWidgets-2.8.10" >> build-vars.bat
echo set LUX_X64_WX_ROOT="%D64%\wxWidgets-2.8.10" >> build-vars.bat

echo.
echo **************************************************************************
echo * Downloading zlib                                                       *
echo **************************************************************************
%WGET% http://zlib.net/zlib124.zip -O %DOWNLOADS%\zlib124.zip
if ERRORLEVEL 1 (
    echo.
    echo Download failed. Are you connected to the internet?
    exit /b -1
)

echo.
echo **************************************************************************
echo * Extracting zlib                                                        *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\zlib124.zip -o%D32% > nul
xcopy /Q/E %D32%\zlib-1.2.4 %D64%\zlib-1.2.4\

echo set LUX_X86_ZLIB_ROOT="%D32%\zlib-1.2.4" >> build-vars.bat
echo set LUX_X64_ZLIB_ROOT="%D64%\zlib-1.2.4" >> build-vars.bat

echo.
echo **************************************************************************
echo * Downloading bzip                                                       *
echo **************************************************************************
%WGET% http://www.bzip.org/1.0.5/bzip2-1.0.5.tar.gz -O %DOWNLOADS%\bzip2-1.0.5.tar.gz
if ERRORLEVEL 1 (
    echo.
    echo Download failed. Are you connected to the internet?
    exit /b -1
)

echo.
echo **************************************************************************
echo * Extracting bzip                                                        *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\bzip2-1.0.5.tar.gz > nul
%UNZIPBIN% x -y bzip2-1.0.5.tar -o%D32% > nul
del bzip2-1.0.5.tar
xcopy /Q/E %D32%\bzip2-1.0.5 %D64%\bzip2-1.0.5\

echo set LUX_X86_BZIP_ROOT="%D32%\bzip2-1.0.5" >> build-vars.bat
echo set LUX_X64_BZIP_ROOT="%D64%\bzip2-1.0.5" >> build-vars.bat

echo.
echo **************************************************************************
echo * Downloading OpenEXR                                                    *
echo **************************************************************************
%WGET% http://download.savannah.nongnu.org/releases/openexr/openexr-1.4.0a.tar.gz -O %DOWNLOADS%\openexr-1.4.0a.tar.gz
if ERRORLEVEL 1 (
    echo.
    echo Download failed. Are you connected to the internet?
    exit /b -1
)

echo.
echo **************************************************************************
echo * Extracting OpenEXR                                                     *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\openexr-1.4.0a.tar.gz > nul
%UNZIPBIN% x -y openexr-1.4.0a.tar -o%D32% > nul
del openexr-1.4.0a.tar
xcopy /Q/E %D32%\openexr-1.4.0 %D64%\openexr-1.4.0\

echo set LUX_X86_OPENEXR_ROOT="%D32%\openexr-1.4.0" >> build-vars.bat
echo set LUX_X64_OPENEXR_ROOT="%D64%\openexr-1.4.0" >> build-vars.bat

echo.
echo **************************************************************************
echo * Downloading Python 2                                                   *
echo **************************************************************************
%WGET% http://python.org/ftp/python/2.6.5/Python-2.6.5.tgz -O %DOWNLOADS%\Python-2.6.5.tgz
if ERRORLEVEL 1 (
    echo.
    echo Download failed. Are you connected to the internet?
    exit /b -1
)

echo.
echo **************************************************************************
echo * Extracting Python 2                                                    *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\Python-2.6.5.tgz > nul
%UNZIPBIN% x -y Python-2.6.5.tar -o%D32% > nul
del Python-2.6.5.tar
xcopy /Q/E %D32%\Python-2.6.5 %D64%\Python-2.6.5\

echo set LUX_X86_PYTHON2_ROOT="%D32%\Python-2.6.5" >> build-vars.bat
echo set LUX_X64_PYTHON2_ROOT="%D64%\Python-2.6.5" >> build-vars.bat

echo.
echo **************************************************************************
echo * Downloading Python 3                                                   *
echo **************************************************************************
%WGET% http://python.org/ftp/python/3.1.2/Python-3.1.2.tgz -O %DOWNLOADS%\Python-3.1.2.tgz
if ERRORLEVEL 1 (
    echo.
    echo Download failed. Are you connected to the internet?
    exit /b -1
)

echo.
echo **************************************************************************
echo * Extracting Python 3                                                    *
echo **************************************************************************
%UNZIPBIN% x -y %DOWNLOADS%\Python-3.1.2.tgz > nul
%UNZIPBIN% x -y Python-3.1.2.tar -o%D32% > nul
del Python-3.1.2.tgz
xcopy /Q/E %D32%\Python-3.1.2 %D64%\Python-3.1.2\

echo set LUX_X86_PYTHON3_ROOT="%D32%\Python-3.1.2" >> build-vars.bat
echo set LUX_X64_PYTHON3_ROOT="%D64%\Python-3.1.2" >> build-vars.bat


echo.
echo **************************************************************************
echo * DONE                                                                   *
echo **************************************************************************