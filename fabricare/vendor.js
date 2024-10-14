// Created by Grigore Stefan <g_stefan@yahoo.com>
// Public domain (Unlicense) <http://unlicense.org>
// SPDX-FileCopyrightText: 2022 Grigore Stefan <g_stefan@yahoo.com>
// SPDX-License-Identifier: Unlicense

messageAction("vendor");

Shell.mkdirRecursivelyIfNotExists("vendor");

var vendor="httpd-"+Project.version+"-win64-VS17.zip";
if (!Shell.fileExists("vendor/"+vendor)) {
	var webLink = "https://www.apachelounge.com/download/VS17/binaries/httpd-"+Project.version+"-240904-win64-VS17.zip";
	var cmd = "curl -A \"Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0\" --insecure --location "+webLink+" --output vendor/"+vendor;
	Console.writeLn(cmd);
	exitIf(Shell.system(cmd));
};

var vendorSourceGit = "https://github.com/g-stefan";
if (Shell.hasEnv("VENDOR_SOURCE_GIT")) {
	vendorSourceGit = Shell.getenv("VENDOR_SOURCE_GIT");
};

var vendorSourceAuth = "";
if (Shell.hasEnv("VENDOR_SOURCE_AUTH")) {
	vendorSourceAuth = Shell.getenv("VENDOR_SOURCE_AUTH");
};

var vendor="httpd-"+Project.version+"-win64-msvc-2022.7z";
if (!Shell.fileExists("vendor/"+vendor)) {
	var webLink = vendorSourceGit + "/vendor-httpd/releases/download/v" + Project.version + "/" + vendor;
	var cmd = "curl --insecure --location "+webLink+" "+vendorSourceAuth+" --output vendor/"+vendor;
	Console.writeLn(cmd);
	exitIf(Shell.system(cmd));
};

var vendor="vc-2022-redist.x64.exe";
if (!Shell.fileExists("vendor/"+vendor)) {
	var webLink = "https://aka.ms/vs/17/release/vc_redist.x64.exe";
	var cmd = "curl --insecure --location "+webLink+" --output vendor/"+vendor;
	Console.writeLn(cmd);
	exitIf(Shell.system(cmd));
};

