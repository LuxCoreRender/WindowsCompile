Building LuxCoreRender with Visual Studio (Express) 2013

This basic procedure to compile LuxCoreRender for Windows 64bit is:

1) Install VS2013 (Community Edition works too);

2) Create a "luxcorerender" directory;

3) Clone the following repositories inside the "luxcorerender" directory. There are four of them you need.
- https://github.com/LuxCoreRender/LuxCore
- https://github.com/LuxCoreRender/WindowsCompile
- https://github.com/LuxCoreRender/WindowsCompileDeps

You can install and use https://desktop.github.com to clone the repositories.

4) Open the VS2013 x64 command prompt (you must use "x64 Native Tools Command Prompt" to execute the .bat),
navigate to the "WindowsCompile" and simply invoke the cmake-build-x64.bat file.
