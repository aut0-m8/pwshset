# read csv path
function FetchIniVars {
    param(
        [string]$iniContent
    )
    $csvPath = ($iniContent | Where-Object {$_ -match '^\s*csv_path\s*=\s*(.+)'}).Matches.Groups[1].Value.Trim()
    $menu = ($iniContent | Where-Object {$_ -match '^\s*menu\s*=\s*(.+)'}).Matches.Groups[1].Value.Trim()
    return @{ CsvPath = $csvPath; Menu = $menu }
}

$defaultIniUrl = "https://raw.githubusercontent.com/aut0-m8/winset/main/config/settings.ini"

if ($args.Count -eq 0) {
    $iniUrl = $defaultIniUrl
} else {
    $iniUrl = $args[0]
}

# grab settings
try {
    $iniContent = (iwr -Uri $iniUrl -UseBasicParsing).Content
} catch {
    Write-Host "[!] " -NoNewline -ForegroundColor Red
    Write-Host "could not grab settings"
}

$csvPath = FetchIniVars -iniContent $iniContent

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

$packages = ReadPackagesFromCSV -csvPath $csvPath

function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "[-] fetching & installing chocolatey"
        Set-ExecutionPolicy Bypass -Scope Process -Force;
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

$pkgMgrs = $packages | Select-Object -ExpandProperty pkgMgr -Unique

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

foreach ($pkgMgr in $pkgMgrs) {
    switch -Wildcard ($pkgMgr) {
        'choco' { Install-Chocolatey; break }
        'winget' { Install-Winget; break }
        'scoop' { Install-Scoop; break }
        'nuget' { Install-NuGet; break }
        default { break }
    }
}


# install
foreach ($package in $packages) {
    Write-Host "[-] processing package $($package.pkgName)"
    $pkgMgr = $package.pkgMgr
    $pkgAction = $package.pkgAction
    $pkgFlags = $package.pkgFlags
    $pkgName = $package.pkgName

    iex "$pkgMgr $pkgAction $pkgFlags $pkgName" > $null
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
