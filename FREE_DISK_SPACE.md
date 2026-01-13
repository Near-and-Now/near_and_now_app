# 💾 Free Disk Space Guide

## ⚠️ Current Issue

**Error**: `No space left on device`  
**Available**: Only 2.2GB free  
**Needed**: 3-4GB minimum for Flutter  
**Recommended**: 10GB+ free space

---

## 🚨 Quick Fixes (Run These First)

### 1. Clean Homebrew Cache (Can free 5-10GB)
```bash
# See what Homebrew is using
du -sh ~/Library/Caches/Homebrew

# Clean it up
brew cleanup -s
rm -rf ~/Library/Caches/Homebrew
```

### 2. Clean System Caches (Can free 2-5GB)
```bash
# Clear user caches
rm -rf ~/Library/Caches/*

# Clear system logs
sudo rm -rf /var/log/*

# Clean up temp files
sudo rm -rf /private/tmp/*
```

### 3. Remove Old Node.js Projects (node_modules)
```bash
# Find all node_modules folders
find ~ -name "node_modules" -type d -prune 2>/dev/null

# Remove them (BE CAREFUL - only delete from old projects!)
# Example:
# rm -rf ~/old_project/node_modules
```

### 4. Empty Trash
```bash
# Empty trash from command line
rm -rf ~/.Trash/*
```

### 5. Clean Xcode Derived Data (If you have Xcode)
```bash
# Can free 10-30GB!
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Developer/Xcode/Archives
```

### 6. Clean Docker (If installed)
```bash
# Can free 10-50GB!
docker system prune -a --volumes
```

---

## 🔍 Find What's Taking Space

### Check Large Directories
```bash
# Find largest directories in home folder
du -sh ~/* | sort -hr | head -20

# Find largest files
find ~ -type f -size +100M -exec ls -lh {} \; 2>/dev/null | awk '{ print $9 ": " $5 }'
```

### Common Space Hogs
1. `~/Library/Caches/` - App caches
2. `~/Library/Developer/Xcode/` - Xcode data
3. `~/Library/Application Support/` - App data
4. `~/Downloads/` - Old downloads
5. `~/.npm/` - npm cache
6. `~/.gradle/` - Gradle cache
7. `~/node_modules/` in various projects

---

## 📋 Step-by-Step Cleanup

### Step 1: Quick Wins (Run all at once)
```bash
# This should free 5-15GB
brew cleanup -s
rm -rf ~/Library/Caches/Homebrew
rm -rf ~/.npm
rm -rf ~/.gradle
sudo rm -rf /var/log/*
rm -rf ~/.Trash/*
```

### Step 2: Check Space
```bash
df -h /
```

### Step 3: If Still Not Enough

**Option A: Remove Old Projects**
```bash
# List project folders by size
du -sh ~/projects/* | sort -hr

# Remove old projects you don't need
# BE CAREFUL - make sure you don't need them!
```

**Option B: Remove Applications**
- Open `/Applications/`
- Delete apps you don't use
- Don't forget to empty Trash after!

**Option C: Move Files to External Drive**
- Move large files/folders to external storage
- Documents, Videos, Photos, etc.

### Step 4: Run This Command
```bash
# After cleanup, check available space
df -h /
```

You should have **at least 5GB free** before trying to install Flutter again.

---

## ✅ After Freeing Space

### Try Flutter Installation Again
```bash
# Clean up any partial Flutter install
rm -rf /opt/homebrew/Caskroom/flutter

# Try installing again
brew install --cask flutter
```

### Alternative: Manual Flutter Installation
If Homebrew still fails, install manually:

```bash
# 1. Download Flutter
cd ~/
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Add to PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# 3. Verify
flutter --version
```

---

## 🎯 Quick Command Sequence

Run these in order:

```bash
# 1. Clean Homebrew (5-10GB)
brew cleanup -s && rm -rf ~/Library/Caches/Homebrew

# 2. Clean caches (2-5GB)
rm -rf ~/Library/Caches/*

# 3. Empty trash
rm -rf ~/.Trash/*

# 4. Clean logs
sudo rm -rf /var/log/*

# 5. Check space
df -h /

# 6. If enough space (5GB+), try Flutter again
brew install --cask flutter
```

---

## 💡 Maintenance Tips

**Keep Your Mac Clean:**
1. Run `brew cleanup` monthly
2. Empty trash regularly
3. Remove old node_modules from projects
4. Clean caches every few months
5. Use `DaisyDisk` or `OmniDiskSweeper` to visualize disk usage

---

## 🆘 Still Need More Space?

### Ultimate Options:
1. **Upgrade Storage** - Add external SSD
2. **Cloud Storage** - Move files to iCloud/Dropbox
3. **Reinstall macOS** - Fresh start (backup first!)
4. **Delete Large Apps** - GarageBand, iMovie, etc.

---

## ✨ Expected Results

After cleanup:
- **10GB+ free**: ✅ Perfect for Flutter + development
- **5-10GB free**: ✅ Good enough for Flutter
- **< 5GB free**: ⚠️ Need more cleanup

---

**Your Next Command**:
```bash
brew cleanup -s && rm -rf ~/Library/Caches/Homebrew && df -h /
```

This should free up enough space to install Flutter! 🚀

