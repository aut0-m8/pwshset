# github fetch func
function githubfetch {
    param(
        [string]$Repo,
        [string]$AssetFilter
    )

    $url = "https://api.github.com/repos/$Repo/releases/latest"
    $releaseInfo = Invoke-RestMethod -Uri $url
    $latestAsset = $releaseInfo.assets | Where-Object { $_.name -like $AssetFilter } | Sort-Object -Property @{Expression={[version]$_.name}} | Select-Object -Last 1
    return $latestAsset.browser_download_url
}



# choco
Write-Host "Installing Chocolatey..."
Set-ExecutionPolicy ByPass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

Write-Host "Installing packages"
choco install -y git
choco install -y 7zip
choco install -y winget
choco install -y mpv
choco install -y openjdk
choco install -y python --params "/InstallDir:C:\Python"
choco install -y msys2
choco install -y dotnet
choco install -y vcredist-all


# yt-dlp
Write-Host "Installing yt-dlp..."
$ytDlp_ = githubfetch -Repo "yt-dlp/yt-dlp" -AssetFilter "yt-dlp.exe"
Invoke-WebRequest -Uri $ytDlp_ -OutFile "yt-dlp.exe"
Move-Item -Path "yt-dlp.exe" -Destination "$env:ProgramFiles\yt-dlp\yt-dlp.exe"

# ffmpeg
Write-Host "Downloading ffmpeg..."
$ffmpeg_ = githubfetch -Repo "FFmpeg/FFmpeg" -AssetFilter "ffmpeg-*-win64-static.zip"
Invoke-WebRequest -Uri $ffmpeg_ -OutFile "ffmpeg.zip"
Write-Host "Installing ffmpeg..."
Expand-Archive -Path "ffmpeg.zip" -DestinationPath "$env:ProgramFiles\ffmpeg"
Remove-Item -Path "ffmpeg.zip" -Force

# add to PATH
Write-Host "Setting environment variables..."
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

# log
$installedPackages = @("git", "7zip", "winget", "mpv", "openjdk", "python", "msys2", "dotnet", "vcredist-all", "yt-dlp", "ffmpeg")
$installedPackages | ForEach-Object { $_ + " --version" | Out-File -Append -FilePath ".\winset.log" }

Write-Host "Installation finished!"
Get-Content ".\winset.log"
