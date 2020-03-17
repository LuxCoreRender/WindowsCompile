Building LuxCoreRender with Visual Studio 2017 (Community)
==========================================================

Basic procedure to compile LuxCoreRender for Windows 64bit
----------------------------------------------------------
1) Install VS2017 (Community Edition works too, https://www.visualstudio.com/downloads/).
If you don't want the full IDE you can also install the "Build Tools for Visual Studio 2017";

2) Install cmake v3.11.2 or better (https://cmake.org/);

3) If you want to build LuxCoreRender with OpenCL support, you also need to install an OpenCL SDK.
A lightweight one is the GPUOpen OCL SDK:
- https://github.com/GPUOpen-LibrariesAndSDKs/OCL-SDK/releases
If you use the suggested one, also replace the included 'cl.hpp' file with a more recent version:
- https://www.khronos.org/registry/OpenCL/api/2.1/cl.hpp

4) Create a "luxcorerender" directory;

5) Clone the following repositories inside the "luxcorerender" directory:
- https://github.com/LuxCoreRender/LuxCore
- https://github.com/LuxCoreRender/WindowsCompile
- https://github.com/LuxCoreRender/WindowsCompileDeps

NOTE: you need git LFS extension (https://git-lfs.github.com) to clone WindowsCompileDeps repository.
Or you can install and use https://desktop.github.com to clone the repositories.

6) Open the VS2017 x64 command prompt (you must use "x64 Native Tools Command Prompt" to execute the .bat),
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

Packaging a release
-------------------
In order to create an official release, you need also to install the following:
- Python v3.7
- PyInstaller (with a "pip install pyinstaller")
- PySide2 (with a "pip install PySide2")
- NumPy (with a "pip install numpy==1.15.4")

You can then package the release archive running the create-standalone.bat script.

In order to build the SDK version, just run:

cd C:\Path\to\luxcorerender\WindowsCompile\
.\cmake-build-x64.bat /dll
create-sdk.bat

NOTE: default build will use Python 3.7, the version embedded in Blender 2.8x.
If needed, you can specify the preferred version among from 3.5 to 3.8, e.g.:
.\cmake-build-x64.bat /python36

NOTE: normally you never need to build dependencies in order to build LuxCore, 
just use the WindowsCompileDeps repo as explained above.
The getdeps.bat and build-deps-x64.bat scripts are used mainly as a reference 
for developers and are not guaranteed to be always up-to-date.

Optional: compiling LuxMark
---------------------------
1) Clone LuxMark repository alongside the other ones in the "luxcorerender" 
directory:
- https://github.com/LuxCoreRender/LuxMark

2) Open the VS2017 x64 command prompt (you must use "x64 Native Tools Command Prompt" to execute the .bat),
navigate to the "WindowsCompile" folder and simply invoke the cmake-build-x64.bat file:

cd C:\Path\to\luxcorerender\WindowsCompile\
.\cmake-build-x64.bat

LuxCore is a prerequisite and will be built first, if necessary, 
then LuxMark build will start.

