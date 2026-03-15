# NVDA Add-on Template Conversion Instructions

## Purpose
Convert NVDA add-ons to use the official NV Access template structure from https://github.com/nvaccess/addonTemplate

## Workflow

### 1. Initial Assessment
- Check current add-on structure
- Identify existing build system (old template vs new template)
- List files that need updating

### 2. Fetch Template
- Use `github_repo` tool to fetch content from `nvaccess/addonTemplate`
- Focus on these key files:
  - `buildVars.py` - build configuration
  - `sconstruct` - build script
  - `manifest.ini.tpl` and `manifest-translated.ini.tpl` - manifest templates
  - `site_scons/` folder - build tools
  - `pyproject.toml` - linter/type checker config
  - `style.css` - documentation styling
  - `.gitignore`, `.gitattributes` - version control
  - `.pre-commit-config.yaml` - code quality hooks

### 3. Preserve Add-on Content
When updating files, **preserve**:
- Add-on name, version, author, description in `buildVars.py`
- Custom `pythonSources`, `i18nSources`, `excludedFiles` lists
- Base language setting if not English
- Custom markdown extensions if used
- Existing `.github` folder (workflows, actions) - **DO NOT REPLACE**
- Add-on source code in `addon/` folder
- Localization files in `addon/locale/`
- Documentation in `addon/doc/`

### 4. Files to Update/Create
Replace or create these from template:
- `site_scons/` - complete folder with build tools
- `sconstruct` - build script (preserve if already using new template)
- `manifest.ini.tpl` and `manifest-translated.ini.tpl` - if not using template format
- Update `buildVars.py` structure while keeping add-on info
- `pyproject.toml` - add if missing
- `.pre-commit-config.yaml` - add if missing

### 5. Verification
- Run `scons` to verify build works
- Check that all locales generate properly
- Verify add-on package is created successfully

## Template File Structure
```
nvda-addon/
├── .github/          # Keep existing - DO NOT REPLACE
├── addon/
│   ├── globalPlugins/  (or appModules/, synthDrivers/, etc.)
│   ├── doc/
│   │   └── <lang>/
│   │       └── readme.md
│   ├── locale/
│   │   └── <lang>/
│   │       └── LC_MESSAGES/
│   │           └── nvda.po
│   └── manifest.ini
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
├── changelog.md
├── COPYING.txt (GPL v2)
├── .gitignore
├── .gitattributes
└── .pre-commit-config.yaml
```

## Key Points
1. **Always preserve .github folder** - contains custom workflows
2. **Preserve add-on-specific settings** in buildVars.py
3. **Test build** with `scons` after conversion
4. **Check site_scons is complete** - critical for build system

## Commands to Run
- `scons` - Build add-on package
- `scons pot` - Generate translation template
- `scons -c` - Clean build artifacts

## Success Criteria
- ✅ `scons` runs without errors
- ✅ Add-on package (.nvda-addon) is created
- ✅ All locale manifests are generated
- ✅ Documentation is processed correctly
- ✅ Existing functionality is preserved
