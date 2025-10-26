# /web-dev

Purpose: Run on web or build for static hosting.

## Dev (Chrome)
```powershell
flutter run -d chrome
```

## Build (release)
```powershell
flutter build web --release
# Output at build\web
```

## Preview locally (optional)
```powershell
# Requires Node.js
npx serve .\build\web -l 5173
```
