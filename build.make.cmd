@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

echo -^> make httpd

if exist build\ rmdir /Q /S build
if exist release\ rmdir /Q /S release

mkdir build
7z x "vendor/httpd-2.4.46-win64-VS16.zip" -aoa -obuild
move "build\Apache24" "release"
move "build\ReadMe.txt" "release\Distribution-ReadMe.txt"
rmdir /Q /S build

mkdir build
7z x "vendor/httpd-2.4.46-win64-msvc-2019.7z" -aoa -obuild
move "build\httpd-2.4.46-win64-msvc-2019\bin\rotatelogsw.exe" "release\bin\rotatelogsw.exe"
rmdir /Q /S build

copy /B /Y vendor\vc-2019-redist.x64.exe release\vc-2019-redist.x64.exe
copy /B /Y util\httpd.conf release\conf\httpd.conf
copy /B /Y util\httpd-php.conf release\conf\extra\httpd-php.conf

rmdir /Q /S release\include
rmdir /Q /S release\lib
