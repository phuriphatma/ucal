#!/bin/bash

# Multi-Branch GitHub Pages Deploy Script
# This script creates a deployment structure with main and dev versions

set -e

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
    
    # Switch to target branch
    git checkout $branch_name 2>/dev/null || {
        echo -e "${YELLOW}⚠️ Branch ${branch_name} doesn't exist, using ${original_branch}${NC}"
        branch_name=$original_branch
    }
    
    # Copy essential files
    cp *.html "$target_dir/" 2>/dev/null || true
    cp *.js "$target_dir/" 2>/dev/null || true
    cp *.json "$target_dir/" 2>/dev/null || true
    cp *.png "$target_dir/" 2>/dev/null || true
    cp *.svg "$target_dir/" 2>/dev/null || true
    
    # Return to original branch
    git checkout $original_branch
}

# Copy main branch files to main directory
copy_app_files "$TEMP_DIR/main" "main"

# Copy development branch files to dev directory  
copy_app_files "$TEMP_DIR/dev" "development"

# Copy landing page to root
cp deploy-landing.html "$TEMP_DIR/index.html"

# Create or switch to gh-pages branch
echo -e "${YELLOW}🌐 Setting up gh-pages branch...${NC}"

# Check if gh-pages branch exists
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo -e "${BLUE}Switching to existing gh-pages branch${NC}"
    git checkout gh-pages
    
    # Clear existing content
    git rm -rf . 2>/dev/null || true
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
    
    # Ask user if they want to push
    echo -e "${YELLOW}Push to GitHub? (y/n): ${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        git push origin gh-pages --force
        echo -e "${GREEN}🎉 Deployed successfully!${NC}"
        echo -e "${BLUE}Your site will be available at:${NC}"
        echo -e "${GREEN}https://phuriphatma.github.io/ucal/${NC}"
        echo -e "${BLUE}📂 Main (Stable): https://phuriphatma.github.io/ucal/main/${NC}"
        echo -e "${BLUE}🧪 Dev (Testing): https://phuriphatma.github.io/ucal/dev/${NC}"
    else
        echo -e "${YELLOW}⏸️ Deployment prepared but not pushed. Run 'git push origin gh-pages --force' when ready.${NC}"
    fi
fi

# Return to original branch
git checkout "$CURRENT_BRANCH"

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
