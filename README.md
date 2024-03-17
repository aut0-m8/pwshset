# `winset`

Install script for basic Windows packages and utilities. Intended for use on Windows 10 and above. Script uses chocolatey as the package manager.

### to run
1. Open PowerShell as Administrator
2. `Set-ExecutionPolicy ByPass -Scope Process -Force`
3. Execute script with `cd AppData/Local/Temp; iwr https://raw.githubusercontent.com/aut0-m8/winset/main/winset.ps1 -OutFile "winset.ps1"; .\winset.ps1; ri .\winset.ps1`. This will be shortened in v2.

Package list:
#### runtime
- vcredist-all
- dotnet
- openjdk
- python
#### development
- git
- cygwin
- mingw
- msys2
#### general
- axel
- winget
- 7zip
- mpv
- mupdf
- ffmpeg
- yt-dlp

### extra options
- Activate Windows with Microsoft Activation Scripts
- Install Firefox ESR
- Install vim

**Suggest** more packages in issues.

Script is a work in progress so expect **bugs**.
