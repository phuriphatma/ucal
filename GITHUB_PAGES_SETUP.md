# GitHub Pages Configuration

Your GitHub Pages is currently set to deploy from the `main` branch, but we need it to deploy from the `gh-pages` branch for the multi-branch setup to work.

## To fix this:

1. Go to your GitHub repository: https://github.com/phuriphatma/ucal
2. Click on **Settings** tab
3. Scroll down to **Pages** section (in the left sidebar)
4. Under **Source**, change from:
   - Branch: `main` 
   - To: Branch: `gh-pages`
5. Keep the folder as `/ (root)`
6. Click **Save**

## Alternative: Use GitHub CLI (if you have it installed)
```bash
gh repo edit phuriphatma/ucal --enable-pages --pages-branch gh-pages
```

## After changing the setting:
- Your site will be available at: https://phuriphatma.github.io/ucal/
- Main version: https://phuriphatma.github.io/ucal/main/  
- Dev version: https://phuriphatma.github.io/ucal/dev/

## Then run the deploy script:
```bash
./deploy.sh
```

This will update your GitHub Pages with the latest code from both branches!
