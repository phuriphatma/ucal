#!/bin/bash

# Multi-Branch GitHub Pages Deploy Script
# This script creates a deployment structure with main and dev versions

set -e
set -x  # Enable debug output

echo "🚀 Starting multi-branch deployment setup..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_NAME="ucal"
CURRENT_BRANCH=$(git branch --show-current)
TEMP_DIR="/tmp/${REPO_NAME}-deploy"

echo -e "${BLUE}Current branch: ${CURRENT_BRANCH}${NC}"

# Create temporary deployment directory
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi
mkdir -p "$TEMP_DIR"

# Create the deployment structure
echo -e "${YELLOW}📁 Creating deployment structure...${NC}"
mkdir -p "$TEMP_DIR/main"
mkdir -p "$TEMP_DIR/dev"

# Function to copy app files to a directory
copy_app_files() {
    local target_dir=$1
    local branch_name=$2
    
    echo -e "${BLUE}📋 Copying files from ${branch_name} branch to ${target_dir}...${NC}"
    
    # Save current branch
    local original_branch=$(git branch --show-current)
    
    # Switch to target branch if it's different
    if [ "$branch_name" != "$original_branch" ]; then
        git checkout $branch_name 2>/dev/null || {
            echo -e "${YELLOW}⚠️ Branch ${branch_name} doesn't exist, using ${original_branch}${NC}"
            branch_name=$original_branch
        }
    fi
    
    # Copy essential files
    cp *.html "$target_dir/" 2>/dev/null || true
    cp *.js "$target_dir/" 2>/dev/null || true
    cp *.json "$target_dir/" 2>/dev/null || true
    cp *.png "$target_dir/" 2>/dev/null || true
    cp *.svg "$target_dir/" 2>/dev/null || true
    
    # Return to original branch if we switched
    if [ "$branch_name" != "$original_branch" ]; then
        git checkout $original_branch
    fi
}

# Copy main branch files to main directory
copy_app_files "$TEMP_DIR/main" "main"

# Copy development branch files to dev directory  
copy_app_files "$TEMP_DIR/dev" "development"

# Create landing page if it doesn't exist
echo -e "${YELLOW}📄 Creating landing page...${NC}"
cat > "$TEMP_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UCAL - Version Selector</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .container {
            text-align: center;
            max-width: 800px;
            padding: 2rem;
        }
        
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .subtitle {
            font-size: 1.2rem;
            margin-bottom: 3rem;
            opacity: 0.9;
        }
        
        .version-buttons {
            display: flex;
            gap: 2rem;
            justify-content: center;
            margin-bottom: 3rem;
            flex-wrap: wrap;
        }
        
        .version-btn {
            padding: 1.5rem 2rem;
            border: none;
            border-radius: 15px;
            font-size: 1.1rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            min-width: 200px;
        }
        
        .stable {
            background: rgba(46, 204, 113, 0.8);
            color: white;
        }
        
        .stable:hover {
            background: rgba(46, 204, 113, 1);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }
        
        .dev {
            background: rgba(241, 196, 15, 0.8);
            color: #2c3e50;
        }
        
        .dev:hover {
            background: rgba(241, 196, 15, 1);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }
        
        .feature {
            background: rgba(255, 255, 255, 0.1);
            padding: 1.5rem;
            border-radius: 10px;
            backdrop-filter: blur(5px);
        }
        
        .feature h3 {
            margin-bottom: 0.5rem;
            color: #f39c12;
        }
        
        @media (max-width: 768px) {
            h1 { font-size: 2rem; }
            .version-buttons { flex-direction: column; align-items: center; }
            .version-btn { min-width: 250px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧮 UCAL</h1>
        <p class="subtitle">GA Calculator - Choose Your Version</p>
        
        <div class="version-buttons">
            <a href="/ucal/main/" class="version-btn stable">
                🟢 Stable Version<br>
                <small>Production Ready</small>
            </a>
            <a href="/ucal/dev/" class="version-btn dev">
                🧪 Development Version<br>
                <small>Latest Features</small>
            </a>
        </div>
        
        <div class="features">
            <div class="feature">
                <h3>📱 GA Calculator</h3>
                <p>Comprehensive pregnancy calculator with multiple date formats</p>
            </div>
            <div class="feature">
                <h3>📊 Average Calculator</h3>
                <p>Quick mathematical calculations with history</p>
            </div>
            <div class="feature">
                <h3>⚙️ PWA Support</h3>
                <p>Install as mobile app, works offline</p>
            </div>
            <div class="feature">
                <h3>🎨 Settings</h3>
                <p>Customizable themes and preferences</p>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Create or switch to gh-pages branch
echo -e "${YELLOW}🌐 Setting up gh-pages branch...${NC}"

# Stash any changes first
git add . && git stash

# Check if gh-pages branch exists
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo -e "${BLUE}Switching to existing gh-pages branch${NC}"
    git checkout gh-pages
    
    # Clear existing content except .git
    find . -not -path './.git*' -delete 2>/dev/null || true
else
    echo -e "${BLUE}Creating new gh-pages branch${NC}"
    git checkout --orphan gh-pages
    
    # Remove all files from the new orphan branch
    git rm -rf . 2>/dev/null || true
fi

# Copy deployment files to root
echo -e "${YELLOW}📦 Copying deployment files...${NC}"
cp -r "$TEMP_DIR"/* .

# Create .nojekyll file to allow files starting with underscore
echo "" > .nojekyll

# Add all files
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠️ No changes to deploy${NC}"
else
    # Commit changes
    git commit -m "Deploy: Multi-branch GitHub Pages

📂 Structure:
- / (Landing page with version selector)
- /main/ (Stable version from main branch)
- /dev/ (Development version from development branch)

🔄 Auto-generated on $(date)
"

    echo -e "${GREEN}✅ Deployment committed to gh-pages branch${NC}"
    
    # Push to GitHub
    git push origin gh-pages --force
    echo -e "${GREEN}🎉 Deployed successfully!${NC}"
    echo -e "${BLUE}Your site will be available at:${NC}"
    echo -e "${GREEN}https://phuriphatma.github.io/ucal/${NC}"
    echo -e "${BLUE}📂 Main (Stable): https://phuriphatma.github.io/ucal/main/${NC}"
    echo -e "${BLUE}🧪 Dev (Testing): https://phuriphatma.github.io/ucal/dev/${NC}"
fi

# Return to original branch
git checkout "$CURRENT_BRANCH"

# Restore stashed changes if any
git stash pop 2>/dev/null || true

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "${GREEN}🎯 Multi-branch deployment setup complete!${NC}"
echo -e "${BLUE}You now have:${NC}"
echo -e "  🏠 Landing page: Choose between versions"
echo -e "  🟢 /main/: Stable production version"  
echo -e "  🧪 /dev/: Development testing version"
echo -e ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Make changes on development branch"
echo -e "  2. Run this script again to update deployment"
echo -e "  3. When ready, merge dev to main"
