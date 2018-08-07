Building LuxCoreRender with Visual Studio 2017 (Community)

This basic procedure to compile LuxCoreRender for Windows 64bit is:

1) Install VS2017 (Community Edition works too, https://www.visualstudio.com/downloads/). If you don't want the full IDE you can also install the "Build Tools for Visual Studio 2017";

2) Install cmake v3.11.2 or better (https://cmake.org/);

3) Create a "luxcorerender" directory;

4) Clone the following repositories inside the "luxcorerender" directory:
- https://github.com/LuxCoreRender/LuxCore
- https://github.com/LuxCoreRender/WindowsCompile
- https://github.com/LuxCoreRender/WindowsCompileDeps

NOTE: you need git LFS extension (https://git-lfs.github.com) to clone WindowsCompileDeps repository. Or you can install and use https://desktop.github.com to clone the repositories.

5) Open the VS2017 x64 command prompt (you must use "x64 Native Tools Command Prompt" to execute the .bat),
navigate to the "WindowsCompile" folder and simply invoke the cmake-build-x64.bat file:

cd C:\Path\to\luxcorerender\WindowsCompile\
.\cmake-build-x64.bat

(You can copy the filepath from an explorer window and 
paste it in the command prompt via right click -> paste)
The first run of the build process will take around 20 minutes 
(depending on your CPU) and the linking process may consume a lot of RAM.

The compiled binaries are in Build_CMake\LuxCore\bin\Release\
The pyluxcore.pyd binary is in Build_CMake\LuxCore\lib\Release
You can run the script collect-compiled-binaries.bat to collect them.

In order to create an official release, you need also to install Python v3.5, PyInstaller
(with a "pip install pyinstaller") and PySide
(download from https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyside the version for Python 3.5).
You can then pack the archive with the create-standalone.bat or create-sdk.bat.
Note that the create-standalone.bat assumes that you have 7zip installed in this path:
"C:\Program Files\7-Zip\7z.exe"
If that is not the case, the pyluxcoretools.zip will not be created.
