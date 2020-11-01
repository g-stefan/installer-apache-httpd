@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

SETLOCAL ENABLEDELAYEDEXPANSION

echo -^> github-release apache-httpd

call build.config.cmd
set PROJECT=apache-httpd
set VERSION=%PRODUCT_VERSION%

if not exist installer\ echo Error - no release & exit 1
if not exist installer\httpd-%VERSION%-installer.exe echo Error - no release - installer & exit 1

echo -^> github release %PROJECT% v%VERSION%

git pull --tags origin master
git rev-parse --quiet "v%VERSION%" 1>NUL 2>NUL
if not errorlevel 1 goto tagExists
git tag -a v%VERSION% -m "v%VERSION%"
git push --tags
echo Create release %PROJECT% v%VERSION%
github-release release --repo %PROJECT% --tag v%VERSION% --name "v%VERSION%" --description "Release"
pushd installer
for /r %%i in (httpd-%VERSION%-installer.exe) do echo Upload %%~nxi & github-release upload --repo %PROJECT% --tag v%VERSION% --name "%%~nxi" --file "%%i"
popd

goto :eof

:tagExists
echo Release already exists
exit 0
