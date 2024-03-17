# choco
Write-Host "---[Installing Chocolatey]---"
Set-ExecutionPolicy ByPass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

Write-Host "---[Installing packages]---"
# runtime
choco upgrade -y vcredist-all
choco upgrade -y dotnet
choco upgrade -y openjdk
# development
choco upgrade -y git
choco upgrade -y make
choco upgrade -y cygwin
choco upgrade -y mingw
choco upgrade -y msys2
choco upgrade -y docker-desktop
choco upgrade -y python --params "/InstallDir:C:\Python"
# general
choco upgrade -y gnupg
choco upgrade -y sysinternals
choco upgrade -y powertoys
choco upgrade -y wireshark
choco upgrade -y openvpn
choco upgrade -y axel
choco upgrade -y 7zip
choco upgrade -y mpv
choco upgrade -y mupdf
choco upgrade -y ffmpeg
choco upgrade -y yt-dlp

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
    "${env:ProgramFiles}\7-Zip",
    "${env:ProgramFiles}\cygwin\bin",
    "${env:ProgramFiles}\mingw\bin",
    "${env:ProgramFiles}\msys2\usr\bin"
)

$oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $installDirs -join ";"
$newPath += ";$oldPath"
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

Remove-Item "$env:TEMP\chocolatey" -Recurse -Force

Write-Host "---[INSTALLATION FINISHED]---"
Write-Host "Extras`n"
Write-Host "q to exit`n"
Write-Host "0 - Run MAS (Microsoft Activation Scripts)`n"
Write-Host "1 - Install Firefox ESR`n"
Write-Host "2 - Install Vim`n"

while ($true) {
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
            "1" { choco upgrade -y firefoxesr }
            "2" { choco upgrade -y vim }
            "q" { exit }
            default { Write-Host "Invalid input!`n"; break }
        }
    }

    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
