#!/bin/bash
# Simple deployment script for GitHub Pages

echo "🚀 Deploying to GitHub Pages..."

# Save current state  
CURRENT_BRANCH=$(git branch --show-current)
git add . && git stash -q

# Create deployment structure
rm -rf /tmp/ucal-deploy
mkdir -p /tmp/ucal-deploy/{main,dev}

# Copy main branch files
echo "📋 Copying main branch..."
git checkout main -q
cp *.html *.js *.json *.png *.svg /tmp/ucal-deploy/main/

# Copy dev branch files  
echo "📋 Copying dev branch..."
git checkout development -q
cp *.html *.js *.json *.png *.svg /tmp/ucal-deploy/dev/

# Create landing page
echo '<html><head><title>UCAL</title><style>body{font-family:sans-serif;text-align:center;padding:50px}h1{color:#333}a{display:inline-block;margin:20px;padding:15px 30px;background:#007cba;color:white;text-decoration:none;border-radius:5px}</style></head><body><h1>🧮 UCAL</h1><p>Choose your version:</p><a href="/ucal/main/">🟢 Stable</a><a href="/ucal/dev/">🧪 Development</a></body></html>' > /tmp/ucal-deploy/index.html

# Deploy to gh-pages
echo "🌐 Deploying to gh-pages..."
git checkout gh-pages -q || git checkout --orphan gh-pages -q
rm -rf ./* 2>/dev/null || true
cp -r /tmp/ucal-deploy/* .
echo > .nojekyll
git add .
git commit -m "Deploy $(date)" -q
git push origin gh-pages --force -q

# Return to original branch
git checkout $CURRENT_BRANCH -q
git stash pop -q 2>/dev/null || true

echo "✅ Deployed! Check: https://phuriphatma.github.io/ucal/"
echo "🟢 Main: https://phuriphatma.github.io/ucal/main/"  
echo "🧪 Dev: https://phuriphatma.github.io/ucal/dev/"
