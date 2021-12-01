;--------------------------------
; HTTPD Installer
;
; Public domain
; http://unlicense.org/
; Created by Grigore Stefan <g_stefan@yahoo.com>
;

!include "MUI2.nsh"
!include "LogicLib.nsh"

; The name of the installer
Name "HTTPD"

; Version
!define HTTPDVersion "$%PRODUCT_VERSION%"

; The file to write
OutFile "installer\httpd-${HTTPDVersion}-installer.exe"

Unicode True
RequestExecutionLevel admin
BrandingText "Grigore Stefan [ github.com/g-stefan ]"

; The default installation directory
InstallDir "$PROGRAMFILES64\HTTPD"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\HTTPD" "InstallPath"

;--------------------------------
;Interface Settings

!define MUI_ABORTWARNING
!define MUI_ICON "source\system-installer.ico"
!define MUI_UNICON "source\system-installer.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "source\xyo-installer-wizard.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "source\xyo-uninstaller-wizard.bmp"

;--------------------------------
;Pages

!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "output\LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!ifdef INNER
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!endif

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Generate signed uninstaller
!ifdef INNER
	!echo "Inner invocation"                  ; just to see what's going on
	OutFile "temp\dummy-installer.exe"       ; not really important where this is
	SetCompress off                           ; for speed
!else
	!echo "Outer invocation"
 
	; Call makensis again against current file, defining INNER.  This writes an installer for us which, when
	; it is invoked, will just write the uninstaller to some location, and then exit.
 
	!makensis '/NOCD /DINNER "source\${__FILE__}"' = 0
 
	; So now run that installer we just created as build\temp-installer.exe.  Since it
	; calls quit the return value isn't zero.
 
	!system 'set __COMPAT_LAYER=RunAsInvoker&"temp\dummy-installer.exe"' = 2
 
	; That will have written an uninstaller binary for us.  Now we sign it with your
	; favorite code signing tool.
 
	!system 'grigore-stefan.sign "HTTPD" "temp\Uninstall.exe"' = 0
 
	; Good.  Now we can carry on writing the real installer. 	 
!endif

;--------------------------------
;Signed uninstaller: Generate uninstaller only
Function .onInit
!ifdef INNER 
	; If INNER is defined, then we aren't supposed to do anything except write out
	; the uninstaller.  This is better than processing a command line option as it means
	; this entire code path is not present in the final (real) installer.
	SetSilent silent
	WriteUninstaller "$EXEDIR\Uninstall.exe"
	Quit  ; just bail out quickly when running the "inner" installer
!endif
FunctionEnd

;--------------------------------
;Some macros
!include "source\StrRep.nsh"
!include "source\ReplaceInFile.nsh"

!macro _ReplaceInFile SOURCE_FILE SEARCH_TEXT REPLACEMENT
  Push "${SOURCE_FILE}"
  Push "${SEARCH_TEXT}"
  Push "${REPLACEMENT}"
  Call RIF
!macroend

;--------------------------------
; Variables

Var PathProgramData
Var _ServerPath
Var _ConfigPath

;--------------------------------
;Installer Sections

Section "HTTPD (required)" MainSection

	SectionIn RO
	SetRegView 64

	; Set output path to the installation directory.
	SetOutPath $INSTDIR
	WriteRegStr HKLM "Software\HTTPD" "InstallPath" "$INSTDIR"

	; Write the uninstall keys for Windows
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "DisplayName" "HTTPD"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "Publisher" "Grigore Stefan [ github.com/g-stefan ]"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "DisplayVersion" "${HTTPDVersion}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "DisplayIcon" '"$INSTDIR\bin\httpd.exe"'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "UninstallString" '"$INSTDIR\Uninstall.exe"'
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "NoRepair" 1

	; Program files
	File /r "output\*"

	SetOutPath $INSTDIR

; Uninstaller
!ifndef INNER
	SetOutPath $INSTDIR
	; this packages the signed uninstaller 
	File "temp\Uninstall.exe"
!endif

	SetOutPath $INSTDIR

	; Computing EstimatedSize
	Call GetInstalledSize
	Pop $0
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD" "EstimatedSize" "$0"

	; Set to HKLM
	EnVar::SetHKLM

	; Set PATH
	EnVar::Check "PATH" "$INSTDIR\bin"
	Pop $0
	${If} $0 <> 0
		EnVar::AddValue "PATH" "$INSTDIR\bin"
		Pop $0
	${EndIf}

	; Set OPENSSL_CONF
	EnVar::Check "OPENSSL_CONF" "NULL"
	Pop $0
	${If} $0 <> 0
		EnVar::AddValue "OPENSSL_CONF" "$INSTDIR\conf\openssl.cnf"
		Pop $0
	${EndIf}

	SetOutPath $INSTDIR
	nsExec::Exec "vc-2022-redist.x64.exe /install /quiet /norestart"
	Sleep 3000
	Delete "vc-2022-redist.x64.exe"

	; Create ProgramData folder
	ReadEnvStr $0 "ProgramData"
	StrCpy $PathProgramData $0

	CreateDirectory "$PathProgramData\HTTPD"
	CreateDirectory "$PathProgramData\HTTPD\www"
	CreateDirectory "$PathProgramData\HTTPD\tmp"
	CreateDirectory "$PathProgramData\HTTPD\log"
	CreateDirectory "$PathProgramData\HTTPD\conf"
	CreateDirectory "$PathProgramData\HTTPD\conf\conf"
	CreateDirectory "$PathProgramData\HTTPD\conf\sites"

	${StrRep} "$_ServerPath" "$INSTDIR" "\" "/"
	${StrRep} "$_ConfigPath" "$PathProgramData\HTTPD" "\" "/"

	; Configure
	SetOutPath "$INSTDIR\conf"
	!insertmacro _ReplaceInFile "httpd.conf" "$$SERVER_PATH" "$_ServerPath"
	!insertmacro _ReplaceInFile "httpd.conf" "$$CONFIG_PATH" "$_ConfigPath"
	!insertmacro _ReplaceInFile "httpd.conf" "$$SERVER_PORT" "80"
	!insertmacro _ReplaceInFile "httpd.conf" "$$ADMIN_EMAIL" "unknown@localhost"
	Delete "httpd.conf.old"

	SetOutPath "$INSTDIR"
	${IfNot} ${FileExists} "$PathProgramData\HTTPD\www\index.html"
		CopyFiles "$INSTDIR\htdocs\index.html" "$PathProgramData\HTTPD\www\index.html"
	${EndIf}

	SetOutPath "$INSTDIR\bin"
	nsExec::Exec "httpd.exe -k install -n $\"HTTPD$\""
	nsExec::Exec "sc start HTTPD"
	Sleep 3000

	SetOutPath $TEMP

SectionEnd

;--------------------------------
;Descriptions

;Language strings
LangString DESC_MainSection ${LANG_ENGLISH} "HTTPD"

;Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${MainSection} $(DESC_MainSection)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section
!ifdef INNER
Section "Uninstall"

	SetRegView 64

	;--------------------------------
	; Validating $INSTDIR before uninstall

	!macro BadPathsCheck
	StrCpy $R0 $INSTDIR "" -2
	StrCmp $R0 ":\" bad
	StrCpy $R0 $INSTDIR "" -14
	StrCmp $R0 "\Program Files" bad
	StrCpy $R0 $INSTDIR "" -8
	StrCmp $R0 "\Windows" bad
	StrCpy $R0 $INSTDIR "" -6
	StrCmp $R0 "\WinNT" bad
	StrCpy $R0 $INSTDIR "" -9
	StrCmp $R0 "\system32" bad
	StrCpy $R0 $INSTDIR "" -8
	StrCmp $R0 "\Desktop" bad
	StrCpy $R0 $INSTDIR "" -23
	StrCmp $R0 "\Documents and Settings" bad
	StrCpy $R0 $INSTDIR "" -13
	StrCmp $R0 "\My Documents" bad done
	bad:
	  MessageBox MB_OK|MB_ICONSTOP "Install path invalid!"
	  Abort
	done:
	!macroend
 
	ClearErrors
	ReadRegStr $INSTDIR HKLM "Software\HTTPD" "InstallPath"
	IfErrors +2
	StrCmp $INSTDIR "" 0 +2
		StrCpy $INSTDIR "$PROGRAMFILES64\HTTPD"
 
	# Check that the uninstall isn't dangerous.
	!insertmacro BadPathsCheck
 
	# Does path end with "\HTTPD"?
	!define CHECK_PATH "\HTTPD"
	StrLen $R1 "${CHECK_PATH}"
	StrCpy $R0 $INSTDIR "" -$R1
	StrCmp $R0 "${CHECK_PATH}" +3
		MessageBox MB_YESNO|MB_ICONQUESTION "$INSTDIR - Unrecognised uninstall path. Continue anyway?" IDYES +2
		Abort
 
	IfFileExists "$INSTDIR\bin\*.*" 0 +2
	IfFileExists "$INSTDIR\bin\httpd.exe" +3
		MessageBox MB_OK|MB_ICONSTOP "Install path invalid!"
		Abort

	;--------------------------------
	; Do Uninstall

	SetOutPath $TEMP

	nsExec::Exec "sc stop HTTPD"
	Sleep 3000
	nsExec::Exec "sc delete HTTPD"
	Sleep 1000


	; Remove registry keys
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HTTPD"
	DeleteRegKey HKLM "Software\HTTPD"

	; Set to HKLM
	EnVar::SetHKLM

	; Remove PATH
	EnVar::Check "PATH" "$INSTDIR\bin"
	Pop $0
	${If} $0 = 0
		EnVar::DeleteValue "PATH" "$INSTDIR\bin"
		Pop $0
	${EndIf}

	; Remove OPENSSL_CONF
	EnVar::Check "OPENSSL_CONF" "$INSTDIR\conf\openssl.cnf"
	Pop $0
	${If} $0 = 0
		EnVar::Delete "OPENSSL_CONF"
		Pop $0
	${EndIf}

	; Remove ProgramData folder
	ReadEnvStr $0 "ProgramData"
	StrCpy $PathProgramData $0

	${If} ${FileExists} "$PathProgramData\HTTPD\www\*.*"
		MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 "Delete www content?" IDYES removeWWWFolderUn
		Goto doNotRemoveWWWFolderUn
		removeWWWFolderUn:
			 RMDir /r "$PathProgramData\HTTPD"
		doNotRemoveWWWFolderUn:
	${Else}
		 RMDir /r "$PathProgramData\HTTPD"
	${EndIf}

	SetOutPath $TEMP
	; Remove files and uninstaller
	RMDir /r "$INSTDIR"
	
SectionEnd
!endif
;--------------------------------
;Functions

; Return on top of stack the total size of the selected (installed) sections, formated as DWORD
Var GetInstalledSize.total
Function GetInstalledSize
	StrCpy $GetInstalledSize.total 0

	${if} ${SectionIsSelected} ${MainSection}
		SectionGetSize ${MainSection} $0
		IntOp $GetInstalledSize.total $GetInstalledSize.total + $0
	${endif}
 
	IntFmt $GetInstalledSize.total "0x%08X" $GetInstalledSize.total
	Push $GetInstalledSize.total
FunctionEnd
