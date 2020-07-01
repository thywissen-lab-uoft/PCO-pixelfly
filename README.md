# PCO-pixefly
Software and MATLAB drivers

This repository contains documentation, code, and drivers for operation of the PCO pixelfly cameras.

These cameras are no longer manufactured by PCO and are extremely outdated.  This repository aims to faciliate control of these cameras with modern computers.

The PCO 540 board is installed via the following ZIP.
DI_540_W7_W8_W10_V201_12.zip

The PCO 540 board is NOT COMPATIBLE with future releases of the PCO Camware software. The last known working version as of writing of this doucment is 3.17.  You may find the installer for this version of the Camware on PCO's website or in the drivers folder.

Our imaging code is based in x64 MATLAB.  In order to operate the camera using MATLAB, you must utilize the relevant SDK.  This depreciated camera is not compatible with the general PCO SDK packages.  Instead, it must be operated with the pixefly specific SDK. 

This SDK is no longer supported by PCO.

https://www.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-compiler
