# read csv path
function Get-CsvPathFromIni {
    param(
        [string]$iniContent
    )
    $csvPath = ($iniContent | Where-Object {$_ -match '^\s*csv_path\s*=\s*(.+)'}).Matches.Groups[1].Value.Trim()
    return $csvPath
}

# Define a default URL to the INI file
$defaultIniUrl = "https://example.com/default.ini"

# Define the URL to the INI file
if ($args.Count -eq 0) {
    $iniUrl = $defaultIniUrl
} else {
    $iniUrl = $args[0]
}

# grab settings
try {
    $iniContent = (iwr -Uri $iniUrl).Content
} catch {
    Write-Host "[!] " -NoNewline -ForegroundColor Red
    Write-Host "could not grab settings"
}

$csvPath = Get-CsvPathFromIni -iniContent $iniContent

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
Get-ChildItem $env:TEMP\chocolatey -Recurse | Remove-Item -Force -Recurse

# Final messages
Write-Host "[!] " -NoNewline -ForegroundColor Green
Write-Host "installation finished!"
Write-Host "extras [q to exit]"
Write-Host "------------------"
Write-Host "0 - Permanently activate Windows"
Write-Host "1 - Run winutil"
Write-Host "2 - Install Firefox ESR"
Write-Host "3 - Install NeoVim"

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
