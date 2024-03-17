# choco
Write-Host "---[Installing Chocolatey]---"
Set-ExecutionPolicy ByPass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

Write-Host "---[Installing packages]---"
# runtime
choco install -y vcredist-all
choco install -y dotnet
choco install -y openjdk
choco install -y python --params "/InstallDir:C:\Python"
# development
choco install -y git
choco install -y cygwin
choco install -y mingw
choco install -y msys2
# general
choco install -y openvpn
choco install -y axel
choco install -y 7zip
choco install -y mpv
choco install -y mupdf
choco install -y ffmpeg
choco install -y yt-dlp

# add to PATH
Write-Host "---[Setting environment variables]---"
$installDirs = @(
    "${env:ProgramFiles}\Java\jdk-*\bin",
    "${env:ProgramFiles}\Python\Scripts",
    "${env:ProgramFiles}\msys64\usr\bin",
    "${env:ProgramFiles}\dotnet",
    "${env:ProgramFiles}\yt-dlp",
    "${env:ProgramFiles}\ffmpeg\bin",
    "${env:ProgramFiles}\Git\cmd",
    "${env:ProgramFiles}\7-Zip"
)

$oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $installDirs -join ";"
$newPath += ";$oldPath"
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

Remove-Item "$env:TEMP\chocolatey" -Recurse -Force

Write-Host "---[INSTALLATION FINISHED]---"

function Show-Menu {
    Write-Host "Extras (^C to exit)`n"
    Write-Host "0 - Run MAS (Microsoft Activation Scripts)`n"
    Write-Host "1 - Install Firefox ESR`n"
    Write-Host "2 - Install Vim`n"
}

while ($true) {
    Show-Menu
    $choice = Read-Host ":"

    $selectedOptions = @()

    # range
    if ($choice -match '(\d+)\s*-\s*(\d+)') {
        $startRange = [int]$Matches[1]
        $endRange = [int]$Matches[2]
        $selectedOptions += $startRange..$endRange
    }
    else {
        # mult
        $selectedOptions += $choice -split '\s+'
    }

    foreach ($option in $selectedOptions) {
        switch ($option) {
            "0" { irm https://massgrave.dev/get | iex }
            "1" { choco install -y firefoxesr }
            "2" { choco install -y vim }
            default { Write-Host "Invalid input!`n" }
        }
    }

    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
