#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'
# Config git
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

$addonId = $env:ADDON_ID.Trim()
if (-not $addonId) {
    Write-Error "Failed to get addon ID. Ensure buildVars.py and dependencies are present."
    exit 1
}

# Update xliff file
$xliffFile = "./$addonId.xliff"
$mdFile = "./readme.md"
if (Test-Path $mdFile) {
    if (Test-Path $xliffFile) {
        $tempXliff = [System.IO.Path]::GetTempFileName()
        Copy-Item "$addonId.xliff" $tempXliff -Force
        Write-Host "Copied $addonId.xliff to temporary file: $tempXliff"
        uv run .github/scripts/markdownTranslate.py updateXliff -m $mdFile -x $tempXliff -o $xliffFile
        Write-Host "Updated $xliffFile based on $mdFile"
    } else {
        Write-Host "XLIFF file not found, but readme.md exists. Creating an XLIFF template for translations."
        uv run .github/scripts/markdownTranslate.py generateXliff -m $mdFile -o $xliffFile
    }
} else {
    Write-Host "readme.md not found. Skipping XLIFF generation."
}

# Update pot file in Crowdin
uv run scons pot
$potFile = "$addonId.pot"
if (Test-Path $potFile) {
    Write-Host "Uploading updated POT to Crowdin..."
    ./l10nUtil.exe uploadSourceFile "$potFile" -c addon
} else {
    Write-Host "POT file not found, skipping POT update."
}

# Update xliff file in Crowdin
if (Test-Path $xliffFile) {
    Write-Host "Uploading XLIFF to Crowdin..."
    ./l10nUtil.exe uploadSourceFile "$xliffFile" -c addon
    git add "$xliffFile"
    git diff --staged --quiet
    if ($LASTEXITCODE -ne 0) {
        git commit -m "Update $xliffFile for $addonId"
        git push
      } else {
        Write-Host "No changes to $xliffFile, skipping commit."
    }
} else {
    Write-Host "XLIFF file not found, skipping XLIFF upload."
}

# Export translations
write-host "Exporting translations from Crowdin..."
./l10nUtil.exe exportTranslations -o _addonL10n -c addon

New-Item -ItemType Directory -Force -Path addon/locale | Out-Null
New-Item -ItemType Directory -Force -Path addon/doc | Out-Null


# Process each language directory
foreach ($dir in Get-ChildItem -Path "_addonL10n/$addonId" -Directory) {
    Write-Host "=============================="
    Write-Host "Processing language: $($dir.Name)"
    Write-Host "=============================="

    $langCode = $dir.Name

    # Paths
    $poFile = Join-Path $dir.FullName "$addonId.po"
    $localPoPath = "addon/locale/$langCode/LC_MESSAGES/nvda.po"

    $xliffFile = Join-Path $dir.FullName "$addonId.xliff"
    $targetDocDir = "addon/doc/$langCode"
    $mdFile = Join-Path $targetDocDir "readme.md"

    # ----------------------------
    # SKIP ENGLISH (source language)
    # ----------------------------
    if ($langCode -eq "en") {
        Write-Host "Skipping English (source language) → no XLIFF processing required"
        continue
    }

    # ----------------------------
    # PO PROCESSING
    # ----------------------------
    if (Test-Path $poFile) {
        Write-Host "Checking PO file..."
        uv run ./.github/scripts/checkTranslation.py "$poFile"
        $isPoTranslated = ($LASTEXITCODE -eq 0)
        Write-Host "PO translated: $isPoTranslated"
        if ($isPoTranslated) {
            Write-Host "Updating local PO"
            New-Item -ItemType Directory -Force -Path (Split-Path $localPoPath) | Out-Null
            Move-Item $poFile $localPoPath -Force
        } else {
            Write-Host "PO not translated"
            if (Test-Path $localPoPath) {
                Write-Host "Uploading local PO to Crowdin"
                ./l10nUtil.exe uploadTranslationFile $langCode "$addonId.po" $localPoPath -c addon
            } else {
                Write-Host "No local PO available"
            }
        }
    }

    # ----------------------------
    # XLIFF PROCESSING
    # ----------------------------
    if (Test-Path $xliffFile) {
        Write-Host "Checking XLIFF..."
        uv run ./.github/scripts/checkTranslation.py "$xliffFile"
        $isXliffTranslated = ($LASTEXITCODE -eq 0)
        Write-Host "XLIFF translated: $isXliffTranslated"
        if ($isXliffTranslated) {
            Write-Host "Converting XLIFF → MD"
            ./l10nUtil.exe xliff2md $xliffFile $mdFile
        } else {
            Write-Host "XLIFF not translated"
        }
    } else {
        Write-Host "No XLIFF file found"
    }
} # End foreach

# COMMIT CHANGES
git add addon/locale addon/doc
git diff --staged --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "Update translations for $addonId from Crowdin"
    git switch $env:downloadTranslationsBranch 2>$null

    if ($LASTEXITCODE -ne 0) {
        git switch -c $env:downloadTranslationsBranch
    }
    git push -f --set-upstream origin $env:downloadTranslationsBranch
} else {
    Write-Host "Nothing to commit."
}
