Building LuxCoreRender with Visual Studio 2017 (Community)

This basic procedure to compile LuxCoreRender for Windows 64bit is:

1) Install VS2017 (Community Edition works too, https://www.visualstudio.com/downloads/). If you don't want the full IDE you can also install the "Build Tools for Visual Studio 2017";
Note that you have to enable the "Visual C++ ATL for x86 and x64" in the installer if you want to compile luxcoreui.

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

In order to create an official release, you need also to install the following:
- Python v3.5
- PyInstaller (with a "pip install pyinstaller")
- PySide2 (with a "pip install PySide2")
  Note: a bug in PySide2 v5.12.1 prevents pyinstaller-packed executables to
        run properly. If you need to use pyluxcoretool.exe, then please
        install the previous version with:
        pip install PySide2==5.12.0 shiboken2==5.12.0
- NumPy (with a "pip install numpy==1.12.1")
You can then pack the archive with the create-standalone.bat or create-sdk.bat.

Note: default build will use Python 3.5, the version embedded in Blender 2.79b.
You can add an option to specify the version of your choice among 3.5, 3.6, 3.7, e.g.:
.\cmake-build-x64.bat /python36

Note: normally you never need to build dependencies in order to build LuxCore, 
just use the WindowsCompileDeps repo as explained above.
The getdeps.bat and build-deps-x64.bat scripts are used mainly as a reference 
for developers and are not guaranteed to be always up-to-date.
