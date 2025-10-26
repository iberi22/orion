# /security-scan

Purpose: Basic dependency and secret hygiene checks.

## Steps (PowerShell)
```powershell
# Outdated dependencies
flutter pub outdated

# Static analysis (should be clean)
flutter analyze

# Optional: basic secret scan (simple heuristics)
git grep -n "API_KEY\|SECRET\|TOKEN" -- ':!*.lock' ':!*.png' ':!*.jpg' | Select-String -Pattern "^(?:(?!\.env).)*$"
```

## Notes
- Review findings and rotate any exposed credentials.
- Follow `docs/SECURITY.md` if present.
