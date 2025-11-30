; NXIVE Optimizer - Professional Installer
; NSIS Modern User Interface - Simple Version (No custom images required)

;--------------------------------
; Include Modern UI
!include "MUI2.nsh"

;--------------------------------
; General Settings
Name "NXIVE Optimizer"
OutFile "NXIVE_Optimizer_Installer.exe"
Unicode True

; Default installation folder
InstallDir "$PROGRAMFILES64\NXIVE Optimizer"

; Get installation folder from registry if available
InstallDirRegKey HKLM "Software\NXIVE\Optimizer" "Install_Dir"

; Request application privileges
RequestExecutionLevel admin

; Compression
SetCompressor /SOLID lzma

; CRC Check
CRCCheck off

;--------------------------------
; Variables
Var StartMenuFolder

;--------------------------------
; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "windows\runner\resources\app_icon.ico"
!define MUI_UNICON "windows\runner\resources\app_icon.ico"

; Header image
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT

; Finish page settings
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\NXIVE_Optimizer.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch NXIVE Optimizer"
!define MUI_FINISHPAGE_LINK "Visit NXIVE on GitHub"
!define MUI_FINISHPAGE_LINK_LOCATION "https://github.com/ZERO-DAWN-X"

; Welcome page text
!define MUI_WELCOMEPAGE_TITLE "Welcome to NXIVE Optimizer Setup"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of NXIVE Optimizer - SSD Protection Tool.$\r$\n$\r$\nNXIVE Optimizer helps protect your SSD by moving IDE cache folders to alternate storage locations.$\r$\n$\r$\nClick Next to continue."

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
; Version Information
VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "NXIVE Optimizer"
VIAddVersionKey "CompanyName" "NXIVE"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2025 NXIVE"
VIAddVersionKey "FileDescription" "NXIVE Optimizer - SSD Protection Tool"
VIAddVersionKey "FileVersion" "1.0.0.0"
VIAddVersionKey "ProductVersion" "1.0.0"

;--------------------------------
; Installer Sections
Section "NXIVE Optimizer" SecMain
  SectionIn RO ; Read-only section

  ; Set output path to the installation directory
  SetOutPath $INSTDIR

  ; Display installing message
  DetailPrint "Installing NXIVE Optimizer..."

  ; Main executable and DLLs
  File "build\windows\x64\runner\Release\NXIVE_Optimizer.exe"
  File "build\windows\x64\runner\Release\flutter_windows.dll"
  File "build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"

  ; Data folder (excluding large screenshots)
  SetOutPath "$INSTDIR\data"
  File /r /x "*.md" "build\windows\x64\runner\Release\data\*.*"

  ; Store installation folder
  WriteRegStr HKLM "Software\NXIVE\Optimizer" "Install_Dir" "$INSTDIR"
  WriteRegStr HKLM "Software\NXIVE\Optimizer" "Version" "1.0.0"

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "DisplayName" "NXIVE Optimizer"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "DisplayIcon" "$INSTDIR\NXIVE_Optimizer.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "Publisher" "NXIVE"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "DisplayVersion" "1.0.0"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "URLInfoAbout" "https://github.com/ZERO-DAWN-X"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "NoRepair" 1

  ; Start Menu Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\NXIVE Optimizer.lnk" "$INSTDIR\NXIVE_Optimizer.exe" "" "$INSTDIR\NXIVE_Optimizer.exe" 0
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Uninstall NXIVE Optimizer.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
  !insertmacro MUI_STARTMENU_WRITE_END

  ; Desktop Shortcut
  CreateShortcut "$DESKTOP\NXIVE Optimizer.lnk" "$INSTDIR\NXIVE_Optimizer.exe" "" "$INSTDIR\NXIVE_Optimizer.exe" 0

  DetailPrint "Installation completed successfully!"
SectionEnd

;--------------------------------
; Section Descriptions
LangString DESC_SecMain ${LANG_ENGLISH} "NXIVE Optimizer - SSD Protection Tool. Protects your SSD by optimizing IDE cache storage locations."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Uninstaller Section
Section "Uninstall"
  ; Display message
  DetailPrint "Removing NXIVE Optimizer..."

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer"
  DeleteRegKey HKLM "Software\NXIVE\Optimizer"

  ; Remove files and uninstaller
  Delete "$INSTDIR\NXIVE_Optimizer.exe"
  Delete "$INSTDIR\Uninstall.exe"
  Delete "$INSTDIR\*.*"
  RMDir /r "$INSTDIR\data"
  RMDir /r "$INSTDIR"

  ; Remove shortcuts
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\NXIVE Optimizer.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall NXIVE Optimizer.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  Delete "$DESKTOP\NXIVE Optimizer.lnk"

  DetailPrint "Uninstallation completed!"
SectionEnd

;--------------------------------
; Installer Functions
Function .onInit
  ; Check if already installed
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NXIVE Optimizer" "UninstallString"
  StrCmp $R0 "" done

  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "NXIVE Optimizer is already installed.$\n$\nClick OK to uninstall the previous version and continue, or Cancel to cancel this installation." \
  IDOK uninst
  Abort

uninst:
  ClearErrors
  ExecWait '$R0 _?=$INSTDIR'
  IfErrors no_remove_uninstaller done
  no_remove_uninstaller:

done:
FunctionEnd

Function .onInstSuccess
  MessageBox MB_OK "NXIVE Optimizer v1.0.0 has been successfully installed!$\n$\nThank you for choosing NXIVE Optimizer."
FunctionEnd

Function .onInstFailed
  MessageBox MB_OK|MB_ICONSTOP "Installation failed. Please contact support."
FunctionEnd

;--------------------------------
; Uninstaller Functions
Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to uninstall NXIVE Optimizer?" IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  MessageBox MB_OK "NXIVE Optimizer has been successfully removed from your computer."
FunctionEnd
