# choco
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "[-] running chocolatey install script"
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
}

$pkgmgr = choco
$pkgflags = upgrade -y

# install pkg
function InstallPkg {
  param([string]$pkgName)
  Write-Host "[-] fetching & upgrading $pkgName"
  $pkgmgr $mgrflags $pkgName > $null
}

# read csv
function ReadPackagesFromCSV {
    param(
        [string]$csvPath
    )
    if (Test-Path $csvPath) {
        Import-Csv $csvPath
    } else {
        Write-Host "[!] " -NoNewline -ForegroundColor Red
        Write-Host "csv not found, use default?"
        return @()
    }
}

# Define the path to the CSV file
$csvPath = "C:\path\to\your\packages.csv"  # Update this with the actual path

# Read package names from the CSV file
$packages = ReadPackagesFromCSV -csvPath $csvPath

# Iterate over each package and install it
foreach ($package in $packages) {
    InstallPkg -pkgName $package.Name
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
