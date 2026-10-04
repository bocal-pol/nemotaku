<#
.SYNOPSIS
    Installe la toolchain de développement Nemotaku : Visual Studio Build Tools (C++),
    vcpkg, et télécharge la CEF Binary Distribution (Windows 64-bit).

.DESCRIPTION
    Qt n'est volontairement PAS installé par ce script : Qt ne se distribue pas via winget,
    et son installeur officiel (Qt Online Installer / aqtinstall) nécessite un compte Qt
    (gratuit, licence open source LGPL). Ce script affiche les instructions à la fin.

.NOTES
    Nécessite une exécution en tant qu'administrateur pour Visual Studio Build Tools.
    Peut prendre 20-40 minutes et plusieurs Go de téléchargement/espace disque.
#>

[CmdletBinding()]
param(
    [string]$VcpkgDir = "C:\dev\vcpkg",
    [string]$CefDestDir = "C:\Projet\Nemotaku\third_party\cef",
    [switch]$SkipVisualStudio,
    [switch]$SkipVcpkg,
    [switch]$SkipCef
)

$ErrorActionPreference = "Stop"

function Write-Step($message) {
    Write-Host ""
    Write-Host "==> $message" -ForegroundColor Cyan
}

function Test-CommandExists($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

# --- 1. Visual Studio Build Tools (workload C++ Desktop) ---
if (-not $SkipVisualStudio) {
    Write-Step "Visual Studio Build Tools 2022 (workload C++ Desktop)"

    $vsInstalled = winget list --id Microsoft.VisualStudio.2022.BuildTools --source winget 2>$null
    if ($LASTEXITCODE -eq 0 -and $vsInstalled -match "Microsoft.VisualStudio.2022.BuildTools") {
        Write-Host "Déjà installé." -ForegroundColor Green
    } else {
        winget install --id Microsoft.VisualStudio.2022.BuildTools --source winget --accept-package-agreements --accept-source-agreements --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
        if ($LASTEXITCODE -ne 0) {
            throw "Échec de l'installation de Visual Studio Build Tools (code $LASTEXITCODE)."
        }
    }
} else {
    Write-Step "Visual Studio Build Tools — ignoré (-SkipVisualStudio)"
}

# --- 2. vcpkg (gestion de dépendances C++ tierces, hors CEF) ---
if (-not $SkipVcpkg) {
    Write-Step "vcpkg dans $VcpkgDir"

    if (Test-Path (Join-Path $VcpkgDir "vcpkg.exe")) {
        Write-Host "Déjà installé." -ForegroundColor Green
    } else {
        $parentDir = Split-Path $VcpkgDir -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        git clone https://github.com/microsoft/vcpkg.git $VcpkgDir
        if ($LASTEXITCODE -ne 0) {
            throw "Échec du clone de vcpkg."
        }
        & "$VcpkgDir\bootstrap-vcpkg.bat"
        if ($LASTEXITCODE -ne 0) {
            throw "Échec du bootstrap de vcpkg."
        }
    }
    Write-Host "Pense à définir VCPKG_ROOT=$VcpkgDir pour CMake (-DCMAKE_TOOLCHAIN_FILE=`$VcpkgDir\scripts\buildsystems\vcpkg.cmake)." -ForegroundColor Yellow
} else {
    Write-Step "vcpkg — ignoré (-SkipVcpkg)"
}

# --- 3. CEF Binary Distribution (téléchargement direct, pas vcpkg) ---
# Le port vcpkg "cef" est minimal et peu fiable pour un usage applicatif complet (ADR 0001).
# Procédure officielle du projet CEF : télécharger l'archive "standard" précompilée.
if (-not $SkipCef) {
    Write-Step "CEF Binary Distribution (Windows 64-bit, stable)"

    if (Test-Path $CefDestDir) {
        Write-Host "Déjà présent dans $CefDestDir — suppression avant retéléchargement ? Ignoré par défaut." -ForegroundColor Yellow
    } else {
        Write-Host "Résolution de la dernière version stable via l'index CEF officiel..."
        $indexUrl = "https://cef-builds.spotifycdn.com/index.json"
        $indexPath = Join-Path $env:TEMP "cef_index.json"
        Invoke-WebRequest -Uri $indexUrl -OutFile $indexPath -UseBasicParsing

        $index = Get-Content $indexPath -Raw | ConvertFrom-Json
        $versions = $index.windows64.versions | Where-Object { $_.channel -eq "stable" }

        # Tri par numéro Chromium réel (ex. chromium-154.0.8037.94), pas alphabétique sur cef_version
        $versionsSorted = $versions | Sort-Object -Descending -Property @{
            Expression = {
                if ($_.cef_version -match 'chromium-(\d+)\.(\d+)\.(\d+)\.(\d+)') {
                    [int64]("{0:D4}{1:D4}{2:D4}{3:D4}" -f [int]$Matches[1], [int]$Matches[2], [int]$Matches[3], [int]$Matches[4])
                } else { 0 }
            }
        }
        $latest = $versionsSorted[0]
        $standardFile = $latest.files | Where-Object { $_.type -eq "standard" } | Select-Object -First 1

        if (-not $standardFile) {
            throw "Aucune distribution 'standard' trouvée pour la dernière version stable CEF."
        }

        Write-Host "Version retenue : $($latest.cef_version) ($([math]::Round($standardFile.size / 1MB, 1)) Mo)"

        $archivePath = Join-Path $env:TEMP $standardFile.name
        $downloadUrl = "https://cef-builds.spotifycdn.com/$($standardFile.name)"

        Write-Host "Téléchargement depuis $downloadUrl ..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing

        Write-Host "Extraction vers $CefDestDir ..."
        New-Item -ItemType Directory -Path $CefDestDir -Force | Out-Null

        # .tar.bz2 : 7-Zip est nécessaire (tar natif Windows ne gère pas bz2 nativement sur toutes versions)
        if (Test-CommandExists "7z") {
            & 7z x $archivePath -o"$env:TEMP" -y | Out-Null
            $tarName = $standardFile.name -replace '\.bz2$', ''
            & 7z x (Join-Path $env:TEMP $tarName) -o"$CefDestDir" -y | Out-Null
        } elseif (Test-CommandExists "tar") {
            tar -xjf $archivePath -C $CefDestDir --strip-components=1
        } else {
            throw "Ni 7z ni tar disponibles pour extraire l'archive .tar.bz2. Installe 7-Zip (winget install 7zip.7zip) et relance."
        }

        Remove-Item $indexPath, $archivePath -Force -ErrorAction SilentlyContinue
        Write-Host "CEF extrait dans $CefDestDir" -ForegroundColor Green
    }
} else {
    Write-Step "CEF Binary Distribution — ignoré (-SkipCef)"
}

# --- 4. Qt : pas automatisable proprement via winget, instructions manuelles ---
Write-Step "Qt 6 — installation manuelle requise"
Write-Host @"
Qt ne se distribue pas via winget. Deux options officielles :

  1. Qt Online Installer (recommandé pour un usage desktop) :
     https://www.qt.io/download-qt-installer-oss
     -> créer un compte Qt (gratuit), installer Qt 6.x, modules "Desktop" + "Qt Widgets".

  2. aqtinstall (scriptable, utile pour CI) :
     pip install aqtinstall
     aqt install-qt windows desktop <version> win64_msvc2022_64 -O C:\Qt

Une fois installé, pointe CMake vers Qt avec :
  -DCMAKE_PREFIX_PATH=C:\Qt\<version>\msvc2022_64
"@ -ForegroundColor Yellow

Write-Step "Terminé"
Write-Host "Vérifie ensuite : cmake --version, git --version, et la présence de $CefDestDir"
