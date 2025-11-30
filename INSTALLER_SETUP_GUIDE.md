# NXIVE Optimizer - Custom Installer Setup Guide

## 🎨 Creating a Beautiful Installer with Custom UI

This guide will help you create a professional installer with custom graphics like game installers.

---

## 📋 Prerequisites

### 1. Install NSIS (Nullsoft Scriptable Install System)
Download and install NSIS from: **https://nsis.sourceforge.io/Download**

---

## 🖼️ Creating Custom Installer Images

You need to create 2 custom images for your installer:

### Image 1: Welcome Screen (welcome.bmp)
- **Size**: 164 x 314 pixels
- **Format**: BMP (24-bit)
- **Location**: `installer_assets/welcome.bmp`
- **Design**: Should feature your app branding, logo, or attractive graphics
- **Example**: Can use a screenshot of your app or create a custom design with:
  - NXIVE logo
  - App name "NXIVE Optimizer"
  - Tagline "SSD Protection Tool"
  - Background color: Crimson Red (#DC143C) gradient

### Image 2: Header (header.bmp)
- **Size**: 150 x 57 pixels
- **Format**: BMP (24-bit)
- **Location**: `installer_assets/header.bmp`
- **Design**: Small header image that appears on each page
- **Example**: NXIVE logo or app icon with text

---

## 🎨 Design Tools

You can create these images using:
- **Photoshop** (Professional)
- **GIMP** (Free - https://www.gimp.org/)
- **Paint.NET** (Free - https://www.getpaint.net/)
- **Canva** (Online - https://www.canva.com/)

---

## 🚀 Quick Setup (Using Existing App Images)

If you want to quickly create the installer using your existing app screenshots:

### Option A: Use Screenshot 1 (assets/screenshots/1.png)
```bash
# Convert your existing screenshots to BMP format and resize
```

### Option B: Simple Solid Color Design
Create simple BMPs with:
- **Background**: Crimson Red (#DC143C)
- **Text**: "NXIVE OPTIMIZER" in white
- **Logo**: Your app icon (assets/images/nyxorax-logo.ico)

---

## 📝 Step-by-Step Build Process

### Step 1: Create the Images
1. Create `welcome.bmp` (164x314 pixels, 24-bit BMP)
2. Create `header.bmp` (150x57 pixels, 24-bit BMP)
3. Save both in `installer_assets/` folder

### Step 2: Compile the Installer

**Method A: Using NSIS GUI**
1. Right-click on `installer_nsis.nsi`
2. Select "Compile NSIS Script"
3. Wait for compilation to complete

**Method B: Using Command Line**
```bash
"C:\Program Files (x86)\NSIS\makensis.exe" installer_nsis.nsi
```

### Step 3: Find Your Installer
The installer will be created at:
```
installer_output/NXIVE_Optimizer_Setup.exe
```

---

## 🎯 Installer Features

Your custom installer includes:

✅ **Modern UI 2** - Beautiful, professional interface
✅ **Custom Colors** - Crimson red theme (#DC143C)
✅ **Custom Graphics** - Welcome and header images
✅ **License Agreement** - Shows LICENSE.txt
✅ **Progress Page** - Shows installation progress with your custom background
✅ **Desktop Shortcut** - Automatically created
✅ **Start Menu** - Creates program group
✅ **Uninstaller** - Professional uninstall process
✅ **Launch Option** - Option to launch app after install
✅ **GitHub Link** - Link to your GitHub on finish page
✅ **Upgrade Detection** - Detects and removes old versions

---

## 📐 Image Templates

### Welcome Screen Template (164x314)
```
┌─────────────────────────┐
│                         │
│    [NXIVE LOGO]        │
│                         │
│   NXIVE OPTIMIZER      │
│                         │
│  SSD Protection Tool   │
│                         │
│   Version 1.0.0        │
│                         │
│  [APP SCREENSHOT]      │
│                         │
│                         │
└─────────────────────────┘
```

### Header Template (150x57)
```
┌──────────────────────────────┐
│  [Logo]  NXIVE OPTIMIZER     │
└──────────────────────────────┘
```

---

## 🎨 Example Color Scheme

- **Primary**: #DC143C (Crimson Red)
- **Secondary**: #FFE4E1 (Light Pink)
- **Text**: #FFFFFF (White)
- **Accent**: #4CAF50 (Green for success)

---

## 🔧 Alternative: Quick Start Without Custom Images

If you don't want to create custom images right now, you can:

1. **Remove image lines** from `installer_nsis.nsi`:
   - Comment out or delete lines 34-44 (image definitions)

2. **Use default NSIS UI** - Still looks professional but without custom graphics

3. **Compile immediately** - The installer will work with default blue theme

---

## 📦 What Gets Installed

The installer will copy:
- ✅ NXIVE_Optimizer.exe
- ✅ All DLL files (flutter_windows.dll, etc.)
- ✅ Data folder with assets
- ✅ All required dependencies

Installation size: ~50-100 MB

---

## 🆘 Troubleshooting

**Problem**: NSIS not found
**Solution**: Install NSIS from https://nsis.sourceforge.io/Download

**Problem**: Images not showing
**Solution**: Ensure BMP files are exactly:
- welcome.bmp: 164x314 pixels, 24-bit
- header.bmp: 150x57 pixels, 24-bit

**Problem**: Compilation errors
**Solution**: Check that all file paths in the .nsi file are correct

---

## 🎊 Result

You'll get a professional installer like game installers with:
- Beautiful welcome screen with your branding
- Custom colors matching your app
- Smooth installation process
- Professional finish page

**File**: `installer_output/NXIVE_Optimizer_Setup.exe`

---

**Ready to build?** Just create your images and compile! 🚀
