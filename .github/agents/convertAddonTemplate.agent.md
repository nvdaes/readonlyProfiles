---
name: convert-addon-template
description: Convert NVDA add-on to official NV Access template structure
---

# NVDA Add-on Template Converter

## Task
Convert this NVDA add-on to use the official NV Access template from https://github.com/nvaccess/addonTemplate

## Steps

### 1. Assessment Phase
- Examine current repository structure
- Check if already using NV Access template
- Identify files that need updating
- List add-on-specific customizations to preserve

### 2. Fetch Template
Fetch these files from nvaccess/addonTemplate using `github_repo` tool:
- buildVars.py
- sconstruct
- manifest.ini.tpl, manifest-translated.ini.tpl
- site_scons/ folder structure
- pyproject.toml
- style.css
- .gitignore, .gitattributes
- .pre-commit-config.yaml

### 3. Preserve Add-on Data
**CRITICAL: Do not lose these:**
- Add-on name, version, author details from buildVars.py
- Custom pythonSources, i18nSources, excludedFiles lists
- Base language setting (if not English)
- Custom markdown extensions
- **Existing .github/ folder and workflows**
- All addon/ source code
- All locale translations
- All documentation

### 4. Update Files
Create/update files from template while preserving add-on data:
- site_scons/ - copy complete folder
- buildVars.py - update structure, keep add-on info
- sconstruct - copy if not present or outdated
- manifest templates - copy if not present
- pyproject.toml - add/update
- style.css - copy if not present

**NEVER REPLACE:**
- .github/ folder
- addon/ source code
- addon/locale/ translations
- addon/doc/ documentation

### 5. Verification
After changes:
```bash
scons
```
Verify:
- Build completes without errors
- .nvda-addon file is created
- All locale manifests generate correctly
- Documentation processes correctly

## Expected Structure
```
addon-root/
├── .github/              # PRESERVE - DO NOT TOUCH
├── addon/
│   ├── globalPlugins/    # or other plugin types
│   ├── doc/<lang>/
│   └── locale/<lang>/
├── site_scons/
│   └── site_tools/
│       ├── gettexttool/
│       └── NVDATool/
├── buildVars.py
├── sconstruct
├── manifest.ini.tpl
├── manifest-translated.ini.tpl
├── pyproject.toml
├── style.css
└── COPYING.txt
```

## Success Criteria
✅ scons runs without errors
✅ .nvda-addon package is built
✅ All localizations work
✅ No data loss
✅ .github folder untouched
