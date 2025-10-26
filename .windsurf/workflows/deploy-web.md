# /deploy-web

Purpose: Build web and deploy to static hosting (e.g., Netlify/Vercel/GitHub Pages).

## Build
```powershell
flutter build web --release
```

## Deploy options
- Netlify CLI:
```powershell
# Requires: npm i -g netlify-cli
netlify deploy --dir .\build\web --prod --message "Orion web deploy"
```
- GitHub Pages (gh-pages branch):
```powershell
# Requires: npm i -g gh-pages
gh-pages -d build/web
```
- Vercel CLI:
```powershell
# Requires: npm i -g vercel
vercel --prod .\build\web
```

## Notes
- Ensure SPA route rewrites as needed for each provider.
