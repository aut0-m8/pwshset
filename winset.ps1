Set-ExecutionPolicy ByPass -Scope Process -Force

$csvPath = "https://raw.githubusercontent.com/aut0-m8/winset/main/config/pkgs.csv"
$menu = 1

if ($csvPath -eq $null) {
    Write-Host "[!] " -NoNewline -ForegroundColor Red
    Write-Host "could not grab packages"
}

function ReadPackagesFromCSV {
    param(
        [string]$csvPath
    )

    if (Test-Path $csvPath) {
        $packages = Import-Csv $csvPath
        return $packages
    }
}

function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "[-] fetching & installing chocolatey"
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) > $null
    }
}
function Install-Winget {
    Install-Chocolatey  # Make sure Chocolatey is installed
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "[-] fetching & installing winget"
        choco install winget -y > $null
    }
}
function Install-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "[-] fetching & installing scoop"
        irm https://get.scoop.sh | iex > $null
    }
}
function Install-NuGet {
    Install-Chocolatey
    if (-not (Get-Command nuget -ErrorAction SilentlyContinue)) {
        Write-Host "[-] fetching & installing winget"
        choco install nuget.commandline -y > $null
    }
}

$packages = ReadPackagesFromCSV -csvPath $csvPath
$pkgMgrs = $packages | Select-Object -ExpandProperty pkgMgr -Unique
foreach ($package in $packages
Write-Host $packages

foreach ($pkgMgr in $pkgMgrs) {
    switch -Wildcard ($pkgMgr) {
        'choco' { Install-Chocolatey; break }
        'winget' { Install-Winget; break }
        'scoop' { Install-Scoop; break }
        'nuget' { Install-NuGet; break }
        default { break }
    }
}

    switch ($pkgMgr) {
        "c" { $pkgMgr = "choco" }
        "w" { $pkgMgr = "winget" }
        "s" { $pkgMgr = "scoop" }
        "n" { $pkgMgr = "nuget" }
        Default { Write-Host "Invalid package manager abbreviation: $pkgMgr" }
    }

    switch ($pkgAction) {
        "i" { $pkgAction = "install" }
        "r" { $pkgAction = "remove" }
        "p" { $pkgAction = "purge" }
        "ud" { $pkgAction = "update" }
        "ug" { $pkgAction = "upgrade" }
        Default { Write-Host "Invalid package action abbreviation: $pkgAction" }
    }

# install
foreach ($package in $packages) {
    Write-Host "[-] processing package $($package.pkgName)"
    $pkgMgr = $package.pkgMgr
    $pkgAction = $package.pkgAction
    $pkgFlags = $package.pkgFlags
    $pkgName = $package.pkgName

    iex "$pkgMgr $pkgAction $pkgFlags $pkgName"
}

# cleanup
Write-Host "[-] cleaning up"
Get-ChildItem $env:TEMP\ -Recurse | Remove-Item -Force -Recurse

# menu
if ($menu -eq 1) {
Write-Host "[!] " -NoNewline -ForegroundColor Green;
Write-Host "installation finished!";
Write-Host "extras [q to exit]";
Write-Host "------------------";
Write-Host "0 - Permanently activate Windows";
Write-Host "1 - Run winutil";
Write-Host "2 - Install Firefox ESR";
Write-Host "3 - Install NeoVim"; 

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
        default { Write-Host "Invalid input" }
    }
}

# Loop to handle user input for additional installations
while ($true) {
    $key = [System.Console]::ReadKey($true).KeyChar
    InstallOption -inputChar $key
}
}
