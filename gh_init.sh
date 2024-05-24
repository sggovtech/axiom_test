#!/bin/bash
cd "$(dirname "$0")"
if ! command -v gh &> /dev/null; then
    echo "gh is not installed. Installing..."
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install git wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
fi
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing..."
    sudo apt install jq -y
fi
unset GITHUB_TOKEN
gh auth login --scopes delete_repo,repo,read:org,workflow
gh auth setup-git 
repo_name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
gh repo create $repo_name --public
remote_url=$(gh repo view $repo_name --json url | jq -r ".url")
cd "$(dirname "$0")/repos"
echo "Remote URL: $remote_url"
# Make repos folder a GitHub repo
cd "$(dirname "$0")/repos"
# Delete old repo if required
if [ -d .git ]; then
    echo "Deleting old repo..."
    git remote remove origin
    rm -rf .git
fi
git init
# Set URL to remote_url
git remote add origin $remote_url.git
git add --all 
git commit -m "Initial commit"
git push -u origin main 
read -p "Press Enter to continue..."
gh repo delete $repo_name --yes
