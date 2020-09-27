@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

echo -^> installer httpd

if exist installer\ rmdir /Q /S installer
mkdir installer

if exist build\ rmdir /Q /S build
mkdir build

makensis.exe /NOCD "util\httpd-installer.nsi"

call grigore-stefan.sign "HTTPD" "installer\httpd-2.4.46-installer.exe"

if exist build\ rmdir /Q /S build
