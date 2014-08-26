;NSIS Modern User Interface
;Basic Script
;Written by William Wedler

; Tutorials
; http://www.seas.gwu.edu/~drum/java/lectures/appendix/installer/install.html
; http://www.pcauthority.com.au/Feature/24263,tutorial-create-a-nsis-install-script.aspx

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include "FileFunc.nsh"
  
  !include WordFunc.nsh
  !insertmacro VersionCompare
  
  !define VERSION "0.1.0"
  !define TITLE "CAD Utilities"
  
  !define REGPATH_WINUNINST "Software\Microsoft\Windows\CurrentVersion\Uninstall"

!macro RegAsmHelpers un
; Sharing functions between Installer and Uninstaller
; http://nsis.sourceforge.net/Sharing_functions_between_Installer_and_Uninstaller
; Create the shared functions

; http://nsis.sourceforge.net/Get_directory_of_installed_.NET_runtime
; Given a .NET version number, this function returns that .NET framework's
; install directory. Returns "" if the given .NET version is not installed.
; Params: [version] (eg. "v2.0")
; Return: [dir] (eg. "C:\WINNT\Microsoft.NET\Framework\v2.0.50727")
Function ${un}GetRegAsmDir
	Exch $R0 ; Set R0 to .net version major
	ReadRegStr $R2 HKLM \
		"Software\Microsoft\.NetFramework" "InstallRoot"
	FindFirst $0 $1 "$R2\$R0*"
	StrCpy $1 "$R2$1"
	Exch $1
FunctionEnd
!macroend
 
; Insert function as an installer and uninstaller function. 
!insertmacro RegAsmHelpers ""
!insertmacro RegAsmHelpers "un."

;--------------------------------
;General

  ;Name and file
  Name "${TITLE} ${VERSION}"
  OutFile "cad_util-setup-${VERSION}.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES64\Receptacle\${TITLE}"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\${TITLE}" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin ;Require admin rights on NT6+ (When UAC is turned on)

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE ".\End User Installation Agreement.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections
; See example at http://nsis.sourceforge.net/Simple_script:section_with_option

SectionGroup /e "Utilities"
Section "" SecDefault
  ;Store installation folder
  WriteRegStr HKCU "Software\${TITLE}" "" $INSTDIR    
    
  SetRegView 64
    
  ;Add uninstall information to Add/Remove Programs
  WriteRegStr HKLM "${REGPATH_WINUNINST}\${TITLE}" \
                 "${TITLE}" "${TITLE} -- Custom CAD Automation Utilities"
  WriteRegStr HKLM "${REGPATH_WINUNINST}\${TITLE}" \
                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "${REGPATH_WINUNINST}\${TITLE}" \
                 "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"

  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "${REGPATH_WINUNINST}\${TITLE}" "EstimatedSize" "$0"

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Plugin Host" SecCpyHost

  SetOutPath "$INSTDIR"
  
  ;ADDDING FILES
  File /r "..\build\host*"
  
SectionEnd

Section "Solidwork Addin" SecAddin

  SetOutPath "$INSTDIR"
  ;ADDDING FILES
  File /r "..\build\Addin*"
  
  ; To get this to work on 64 bit mode http://christian-fries.de/blog/files/2012-03-wow6432node.html
  SetRegView 64  
  
  ; Use RegAsm  
  ; get directory of .NET framework installation
  Push "v4.0"
  Call GetRegAsmDir
  Pop $R0 ; .net framework v4.0 installation directory
  nsExec::ExecToLog '"$R0\RegAsm.exe" /codebase "$INSTDIR\Addin\client\PluginClient.dll"'
  Pop $0 # return value/error/timeout
  DetailPrint "       Return value: $0"  
SectionEnd
SectionGroupEnd


;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecCpyHost ${LANG_ENGLISH} "Copying files"

  LangString ConfirmUninstall ${LANG_ENGLISH} "All existing \
	files and folders under the $(^Name) installation directory \
	will be removed.$\r$\nThis includes any files and folders \
	that have since been added after the installation of \
	${TITLE}.$\r$\n$\r$\nAre you sure you wish to continue?"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCpyHost} $(DESC_SecCpyBinaries)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
    
  SetRegView 64
  ; get directory of .NET framework installation
  Push "v4.0"
  Call un.GetRegAsmDir
  Pop $R0 ; .net framework v4.0 installation directory
  nsExec::ExecToLog '"$R0\RegAsm.exe" /u /codebase "$INSTDIR\Addin\client\PluginClient.dll"'
  Pop $0 # return value/error/timeout
  DetailPrint ""
  DetailPrint "       Return value: $0"
  DetailPrint ""
  
  DeleteRegKey /ifempty HKCU "Software\${TITLE}"
  DeleteRegKey HKLM "${REGPATH_WINUNINST}\${TITLE}"
  
  ;FILES TO DELETE
  Delete "$INSTDIR\Uninstall.exe"    

  MessageBox MB_OKCANCEL|MB_ICONINFORMATION $(ConfirmUninstall) IDOK +2
  Abort
  
  RMDir /r "$INSTDIR\..\${TITLE}"
SectionEnd

Function .onInit

; get directory of .NET framework installation
Push "v4.0"
Call GetRegAsmDir
Pop $R0 ; .net framework v4.0 installation directory
StrCmpS "" $R0 err_dot_net_not_found

return
 
err_dot_net_not_found:
	 MessageBox MB_OKCANCEL $R0
	Abort "Aborted: v4.0 .Net framework not found."	
FunctionEnd

