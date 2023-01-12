// Created by Grigore Stefan <g_stefan@yahoo.com>
// Public domain (Unlicense) <http://unlicense.org>
// SPDX-FileCopyrightText: 2022 Grigore Stefan <g_stefan@yahoo.com>
// SPDX-License-Identifier: Unlicense

Fabricare.include("vendor");

// ---

messageAction("make");

if (Shell.fileExists("temp/build.done.flag")) {
	return;
};

Shell.removeDirRecursivelyForce("output");
Shell.removeDirRecursivelyForce("temp");

var version = getVersion();

Shell.mkdirRecursivelyIfNotExists("temp");
Shell.system("7z x vendor/httpd-"+version+"-win64-VS17.zip -aoa -otemp");
Shell.rename("temp/Apache24","output");
Shell.rename("temp/ReadMe.txt","output/Distribution-ReadMe.txt");
Shell.removeDirRecursivelyForce("temp");

Shell.mkdirRecursivelyIfNotExists("temp");
Shell.system("7z x vendor/httpd-"+version+"-win64-msvc-2022.7z -aoa -otemp");
Shell.rename("temp/bin/rotatelogsw.exe","output/bin/rotatelogsw.exe");
Shell.removeDirRecursivelyForce("temp");

Shell.copyFile("vendor/vc-2022-redist.x64.exe","output/vc-2022-redist.x64.exe");
Shell.copyFile("source/httpd.conf", "output/conf/httpd.conf");

Shell.removeDirRecursivelyForce("output/include");
Shell.removeDirRecursivelyForce("output/lib");

Shell.filePutContents("temp/build.done.flag", "done");
