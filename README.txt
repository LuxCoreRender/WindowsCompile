Building LuxCoreRender with Visual Studio (Express) 2013

This basic procedure to compile LuxCoreRender for Windows 64bit is:

1) Install VS2013 (Community Edition works too);

2) Create a "luxcorerender" directory;

3) Clone the following repositories inside the "luxcorerender" directory:
- https://github.com/LuxCoreRender/LuxCore
- https://github.com/LuxCoreRender/WindowsCompile
- https://github.com/LuxCoreRender/WindowsCompileDeps

You can install and use https://desktop.github.com to clone the repositories.

4) Open the VS2013 x64 command prompt (you must use "x64 Native Tools Command Prompt" to execute the .bat),
navigate to the "WindowsCompile" folder and simply invoke the cmake-build-x64.bat file:

cd C:\Path\to\luxcorerender\WindowsCompile\
.\cmake-build-x64.bat

(You can copy the filepath from an explorer window and 
paste it in the command prompt via right click -> paste)
The first run of the build process will take around 30 minutes 
(depending on your CPU) and the linking process may consume a lot of RAM.

The compiled binaries are in Build_CMake\LuxCore\bin\Release\
The pyluxcore.pyd binary is in Build_CMake\LuxCore\lib\Release
You can run the script collect-compiled-binaries.bat to collect them.
