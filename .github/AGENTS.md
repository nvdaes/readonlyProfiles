# Custom Agents

## convert-addon-template

Convert NVDA add-ons to use the official NV Access template structure.

**Usage:** `@workspace /convert-addon-template`

**What it does:**
1. Fetches the latest structure from https://github.com/nvaccess/addonTemplate
2. Compares current add-on structure with template requirements
3. Updates or creates necessary files (buildVars.py, sconstruct, manifest templates, site_scons/)
4. Preserves add-on-specific content and .github folder
5. Verifies build works with `scons`

**Preserves:**
- Add-on name, version, author, description
- Custom python sources and i18n sources
- Existing .github workflows (DO NOT REPLACE)
- Add-on source code in addon/ folder
- All localizations and documentation

**Updates/Creates:**
- site_scons/ build tools
- buildVars.py (structure only, keeps your data)
- sconstruct build script
- manifest.ini.tpl templates
- pyproject.toml (Ruff/Pyright config)
- style.css, .gitignore, .gitattributes

**Verification:**
- Runs `scons` to ensure build succeeds
- Checks all locale manifests generate
- Confirms .nvda-addon package creation
