Name "PsiphonChrome"
OutFile "psiphon-chrome-installer.exe"
InstallDir $APPDATA\PsiphonChrome

Section "install"
    # Set the installation directory as the destination for the following actions
    SetOutPath $INSTDIR

    # Drop the actual binary
    File /oname=psiphon-native-messaging-host.exe ..\..\host\bin\windows\psiphon-native-messaging-host-i386.exe

    # Setup the manifest file
    File ..\..\host\ca.psiphon.chrome-win.json
    WriteRegStr HKCU "Software\Google\Chrome\NativeMessagingHosts\ca.psiphon.chrome" "" "$INSTDIR\ca.psiphon.chrome-win.json"

    File logo.ico

    # External installation of the extension component
    WriteRegStr HKLM "Software\Google\Chrome\Extensions\gnalljkfdmkhinjcipgjjehclbpagega" "update_url" "https://clients2.google.com/service/update2/crx"

    # Create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    # Create registry keys for the "Add/Remove Programs" panel
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "DisplayName" "Psiphon for Chrome"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "DisplayIcon" "$\"$INSTDIR\logo.ico$\""
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "Publisher" "Psiphon Inc."
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "DisplayVersion" "0.0.1"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "NoModify" 1
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome" "NoRepair" 1

    !define ARP "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome"
    !include "FileFunc.nsh"

    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKCU "${ARP}" "EstimatedSize" "$0"
SectionEnd

Section "uninstall"
    # Delete dropped files
    Delete "$INSTDIR\*"

    # Delete registry keys
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PsiphonChrome"
    DeleteRegKey HKLM "Software\Google\Chrome\Extensions\gnalljkfdmkhinjcipgjjehclbpagega"
    DeleteRegKey HKCU "Software\Google\Chrome\NativeMessagingHosts\ca.psiphon.chrome"
SectionEnd
