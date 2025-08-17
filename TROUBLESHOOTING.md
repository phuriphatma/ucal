# GitHub Pages Troubleshooting

## Check your GitHub Pages settings:

1. **Go to**: https://github.com/phuriphatma/ucal/settings/pages

2. **Current Issue**: GitHub Pages is likely set to deploy from `main` branch

3. **Fix**: Change to deploy from `gh-pages` branch

## Alternative: Use GitHub CLI (if installed)
```bash
# Check current settings
gh repo view phuriphatma/ucal --json pages

# Set to gh-pages branch
gh api repos/phuriphatma/ucal/pages -X POST -f source.branch=gh-pages -f source.path=/
```

## Manual Verification:
Your gh-pages branch has:
- ✅ index.html (4180 bytes) - Landing page 
- ✅ main/ directory - Stable version
- ✅ dev/ directory - Development version  
- ✅ .nojekyll file - For GitHub Pages

The deployment files are correct - it's just the GitHub Pages source configuration!
