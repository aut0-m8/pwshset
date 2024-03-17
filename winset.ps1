# choco
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "[-] running chocolatey install script"
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
}

Write-Host "[-] installing pkgs"
# runtime
choco upgrade -y vcredist-all
choco upgrade -y dotnet
choco upgrade -y directx
choco upgrade -y openjdk
# development
choco upgrade -y git
choco upgrade -y make
choco upgrade -y cygwin
choco upgrade -y mingw
choco upgrade -y msys2
choco upgrade -y golang
choco upgrade -y python --params "/InstallDir:C:\Python"
# general
choco upgrade -y gnupg
choco upgrade -y sysinternals
choco upgrade -y wireshark
choco upgrade -y openvpn
choco upgrade -y axel
choco upgrade -y 7zip
choco upgrade -y mpv
choco upgrade -y mupdf
choco upgrade -y ffmpeg
choco upgrade -y yt-dlp

# add to PATH
Write-Host "[-] setting environment variables"
$installDirs = @(
    "${env:ProgramFiles}\Java\jdk-*\bin",
    "${env:ProgramFiles}\Python\Scripts",
    "${env:ProgramFiles}\msys64\usr\bin",
    "${env:ProgramFiles}\dotnet",
    "${env:ProgramFiles}\yt-dlp",
    "${env:ProgramFiles}\ffmpeg\bin",
    "${env:ProgramFiles}\Git\cmd",
    "${env:ProgramFiles}\7-Zip",
    "${env:ProgramFiles}\cygwin\bin",
    "${env:ProgramFiles}\mingw\bin",
    "${env:ProgramFiles}\msys2\usr\bin"
)

$oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $installDirs -join ";"
$newPath += ";$oldPath"
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

Write-Host "[-] cleaning up"
Get-ChildItem $env:TEMP\chocolatey -Recurse | Remove-Item -Force -Recurse

Write-Host "[!]" -NoNewline -ForegroundColor Green
Write-Host "installation finished"
Write-Host "extras [q to exit]"
Write-Host "------------------"
Write-Host "0 - permanently activate Windows"
Write-Host "1 - run winutil"
Write-Host "2 - install Firefox ESR"
Write-Host "3 - install NeoVim"

function InstallOption {
    param(
        [char]$inputChar
    )

    switch ($inputChar) {
        '0' { irm https://massgrave.dev/get | iex; break }
        '1' { irm https://christitus.com/win | iex; break }
        '2' { choco upgrade -y firefoxesr; break }
        '3' { choco upgrade -y neovim; break }
        'q' { exit }
        default { Write-Host "invalid input" }
    }
}

while ($true) {
    $key = [System.Console]::ReadKey($true).KeyChar
    InstallOption -inputChar $key
}
