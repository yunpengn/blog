#!/usr/bin/env bash

# Install all dependencies
npm install

# Switch back to the local master branch
git checkout master
echo "Check out to the master branch on local."

# Some messages before the deployment actually starts
echo "Starting to deploy this blog website ..."
echo "Proudly powered by Hexo.js at https://hexo.io/ ..."

# Start to deploy the Hexo blog website via a Git repository
hexo clean
hexo deploy --generate

# Prompt that the deployment is successful
echo "Deployment successful."
