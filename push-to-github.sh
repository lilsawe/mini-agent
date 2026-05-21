#!/usr/bin/env bash
# Push mini-agent to GitHub
# Usage: 1. Fill in your GitHub username below
#        2. Create a new repo on GitHub: https://github.com/new (name: mini-agent, public, NO README/NO .gitignore/NO license)
#        3. Run: bash push-to-github.sh
#
# Authentication: If you use SSH, make sure your SSH key is added to GitHub.
# If you use HTTPS, you'll be prompted for your username + token.

set -e

GITHUB_USER="YOUR_GITHUB_USERNAME"   # ← CHANGE THIS to your GitHub username
REPO_NAME="mini-agent"

cd "$(dirname "$0")"

echo "==> Initializing git repo..."
git init

echo "==> Configuring git user..."
if [ -z "$(git config user.name)" ]; then
    echo "    Git user not configured. Setting up..."
    echo "    Enter your name:"
    read -r GIT_NAME
    git config user.name "$GIT_NAME"
    echo "    Enter your email:"
    read -r GIT_EMAIL
    git config user.email "$GIT_EMAIL"
fi

echo "==> Adding files..."
git add -A

echo "==> Creating initial commit..."
git commit -m "feat: mini-agent - AI Agent framework from scratch

- ~350 lines of Python implementing a complete ReAct agent loop
- DeepSeek LLM client with Function Calling support
- 5 built-in tools: Python execution, file I/O, calculator, web search
- Tool abstract base class and registry for easy extension
- Async architecture with asyncio
- CLI interface with REPL
- Comprehensive Chinese documentation"

echo ""
echo "==> Adding GitHub remote..."
git remote add origin "git@github.com:${GITHUB_USER}/${REPO_NAME}.git" 2>/dev/null || \
    git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo ""
echo "==> Pushing to GitHub..."
echo "    If this is your first push, you may need to:"
echo "    1. Create the repo at: https://github.com/new"
echo "       (Name: ${REPO_NAME}, Public, do NOT add README/.gitignore/license)"
echo "    2. If using HTTPS: use your GitHub username + personal access token as password"
echo ""
git branch -M main
git push -u origin main

echo ""
echo "==> Done! Your repo is at: https://github.com/${GITHUB_USER}/${REPO_NAME}"
