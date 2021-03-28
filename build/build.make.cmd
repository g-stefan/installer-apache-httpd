@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

call build\build.config.cmd

echo -^> make %PRODUCT_NAME%

if exist temp\ rmdir /Q /S temp
if exist output\ rmdir /Q /S output

mkdir temp
7z x "vendor/httpd-%PRODUCT_VERSION%-win64-VS16.zip" -aoa -otemp
move "temp\Apache24" "output"
move "temp\ReadMe.txt" "output\Distribution-ReadMe.txt"
rmdir /Q /S temp

mkdir temp
7z x "vendor/httpd-%PRODUCT_VERSION%-win64-msvc-2019.7z" -aoa -otemp
move "temp\httpd-%PRODUCT_VERSION%-win64-msvc-2019\bin\rotatelogsw.exe" "output\bin\rotatelogsw.exe"
rmdir /Q /S temp

copy /B /Y vendor\vc-2019-redist.x64.exe output\vc-2019-redist.x64.exe
copy /B /Y source\httpd.conf output\conf\httpd.conf

rmdir /Q /S output\include
rmdir /Q /S output\lib
