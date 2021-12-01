@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

call build\build.config.cmd

echo -^> vendor %PRODUCT_NAME%

if not exist vendor\ mkdir vendor

set VENDOR=httpd-%PRODUCT_VERSION%-win64-VS16.zip
set WEB_LINK=https://www.apachelounge.com/download/VS16/binaries/httpd-%PRODUCT_VERSION%-win64-VS16.zip
if not exist vendor\%VENDOR% curl -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" --insecure --location %WEB_LINK% --output vendor\%VENDOR%

set VENDOR=httpd-%PRODUCT_VERSION%-win64-msvc-2019.7z
set WEB_LINK=https://github.com/g-stefan/vendor-httpd/releases/download/v%PRODUCT_VERSION%/httpd-%PRODUCT_VERSION%-win64-msvc-2019.7z
if not exist vendor\%VENDOR% curl --insecure --location %WEB_LINK% --output vendor\%VENDOR%

set VENDOR=vc-2019-redist.x64.exe
set WEB_LINK=https://aka.ms/vs/16/release/vc_redist.x64.exe
if not exist vendor\%VENDOR% curl --insecure --location %WEB_LINK% --output vendor\%VENDOR%

set VENDOR=vc-2022-redist.x64.exe
set WEB_LINK=https://aka.ms/vs/17/release/vc_redist.x64.exe
if not exist vendor\%VENDOR% curl --insecure --location %WEB_LINK% --output vendor\%VENDOR%
