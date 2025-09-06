# macOS Development Environment Setup

Automated macOS development environment setup for modern web development.

## 🚀 Quick Start

### Single Command Install
**For fresh macOS systems - copy and paste this one command:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/brisc/mac-install/main/bootstrap.sh)
```

### Manual Install
If you have the project locally:
```bash
./setup.sh
```

## 📋 What Gets Installed

- **Homebrew** + 26 development packages
- **Node.js** (v10 + v20) via NVM
- **Ruby** via Homebrew
- **Git, Yarn, build tools**
- **VS Code, Chrome, Firefox**
- **iTerm2 + Oh My Zsh + Powerlevel10k**
- **Productivity apps** (Rectangle, Maccy, etc.)

## � Verify Installation

```bash
./check.sh
```

## 🚨 Troubleshooting

```bash
# Re-run setup (safe to retry)
./setup.sh

# Check what's missing
./check.sh

# Debug mode
bash -x ./setup.sh
```

Some apps might need approval in **System Preferences > Security & Privacy**.

---

**Setup takes 30-60 minutes on fresh macOS.** Safe to run multiple times.
