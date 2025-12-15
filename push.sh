#!/bin/bash

# Script untuk push ke GitHub dengan Personal Access Token
# Jalankan: bash push.sh

echo "🚀 CoreML Vision - Push to GitHub"
echo ""
echo "Anda perlu Personal Access Token dari GitHub"
echo "Buat di: https://github.com/settings/tokens"
echo ""
echo "Pilih scope: repo (all)"
echo ""
read -p "Masukkan GitHub username (elmeeee): " username
read -sp "Masukkan Personal Access Token: " token
echo ""
echo ""

# Set remote dengan token
git remote set-url origin https://${username}:${token}@github.com/elmeeee/CoreML-Vision.git

# Push
echo "Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo "🌐 https://github.com/elmeeee/CoreML-Vision"
else
    echo ""
    echo "❌ Push failed. Please check your credentials."
fi

# Remove token from remote URL for security
git remote set-url origin https://github.com/elmeeee/CoreML-Vision.git
