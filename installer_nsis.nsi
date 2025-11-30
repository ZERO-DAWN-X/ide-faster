; NXIVE Optimizer - Modern Installer with Custom UI
; NSIS Modern User Interface

;--------------------------------
; Include Modern UI
!include "MUI2.nsh"

;--------------------------------
; General Settings
Name "NXIVE Optimizer"
OutFile "installer_output\NXIVE_Optimizer_Setup.exe"
Unicode True

; Default installation folder
InstallDir "$PROGRAMFILES64\NXIVE Optimizer"

; Get installation folder from registry if available
InstallDirRegKey HKLM "Software\NXIVE\Optimizer" "Install_Dir"

; Request application privileges
RequestExecutionLevel admin

; Compression
SetCompressor /SOLID lzma

;--------------------------------
; Variables
Var StartMenuFolder

;--------------------------------
; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "windows\runner\resources\app_icon.ico"
!define MUI_UNICON "windows\runner\resources\app_icon.ico"

; Welcome page with custom image
!define MUI_WELCOMEFINISHPAGE_BITMAP "installer_assets\welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "installer_assets\welcome.bmp"

; Header image
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "installer_assets\header.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "installer_assets\header.bmp"
!define MUI_HEADERIMAGE_RIGHT

; Custom colors
!define MUI_BGCOLOR "DC143C"
!define MUI_TEXTCOLOR "FFFFFF"

; Installation page with custom image
!define MUI_INSTFILESPAGE_COLORS "DC143C FFFFFF"

; Finish page
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\NXIVE_Optimizer.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch NXIVE Optimizer"
!define MUI_FINISHPAGE_LINK "Visit NXIVE on GitHub"
!define MUI_FINISHPAGE_LINK_LOCATION "https://github.com/ZERO-DAWN-X"

;--------------------------------
; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages
!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Installer Sections
Section "NXIVE Optimizer" SecMain
  SectionIn RO ; Read-only section

  ; Set output path to the installation directory
  SetOutPath $INSTDIR

  ; Put files there
  File /r "build\windows\x64\runner\Release\*.*"

  ; Store installation folder
  WriteRegStr HKLM "Software\NXIVE\Optimizer" "Install_Dir" "$INSTDIR"

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "DisplayName" "NXIVE Optimizer"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "DisplayIcon" "$INSTDIR\NXIVE_Optimizer.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "Publisher" "NXIVE"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "DisplayVersion" "1.0.0"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "NoRepair" 1

  ; Start Menu Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\NXIVE Optimizer.lnk" "$INSTDIR\NXIVE_Optimizer.exe"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  !insertmacro MUI_STARTMENU_WRITE_END

  ; Desktop Shortcut
  CreateShortcut "$DESKTOP\NXIVE Optimizer.lnk" "$INSTDIR\NXIVE_Optimizer.exe"
SectionEnd

;--------------------------------
; Descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} "NXIVE Optimizer - SSD Protection Tool"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Uninstaller Section
Section "Uninstall"
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer"
  DeleteRegKey HKLM "Software\NXIVE\Optimizer"

  ; Remove files and uninstaller
  Delete "$INSTDIR\*.*"
  RMDir /r "$INSTDIR"

  ; Remove shortcuts
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\*.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  Delete "$DESKTOP\NXIVE Optimizer.lnk"
SectionEnd

;--------------------------------
; Installer Functions
Function .onInit
  ; Check if already installed
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "UninstallString"
  StrCmp $R0 "" done

  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "NXIVE Optimizer is already installed. $\n$\nClick 'OK' to remove the previous version or 'Cancel' to cancel this upgrade." \
  IDOK uninst
  Abort

uninst:
  ClearErrors
  ExecWait '$R0 _?=$INSTDIR'

done:
FunctionEnd

Function .onInstSuccess
  MessageBox MB_OK "NXIVE Optimizer has been successfully installed!"
FunctionEnd
