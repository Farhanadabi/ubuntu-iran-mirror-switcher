# Ubuntu Iran Mirror Switcher

A utility script to switch Ubuntu package repository mirrors to Iranian mirrors for faster downloads and better connectivity within Iran.

## 📖 Overview

This script helps Iranian Ubuntu users switch their package repository mirrors from the default international mirrors to local Iranian mirrors. This results in:

- ⚡ **Faster downloads** - Local mirrors provide better speed
- 🌐 **Better connectivity** - Reduced latency and connection issues
- 💰 **Cost savings** - Potentially lower bandwidth costs
- 🔄 **Easy switching** - Simple one-command mirror switching

## 🚀 Features

- Automatically detects your Ubuntu version
- Backs up your current sources.list before making changes
- Provides multiple Iranian mirror options
- Easy rollback to original configuration
- Supports both interactive and non-interactive modes
- Compatible with various Ubuntu versions

## 📋 Prerequisites

- Ubuntu Linux system
- Root/sudo privileges
- Active internet connection

## 🔧 Installation

### Method 1: Direct Download
```bash
wget https://github.com/Farhanadabi/ubuntu-iran-mirror-switcher/raw/main/ubuntu-iran-mirror-switcher.sh
chmod +x ubuntu-iran-mirror-switcher.sh
```

### Method 2: Clone Repository
```bash
git clone https://github.com/Farhanadabi/ubuntu-iran-mirror-switcher.git
cd ubuntu-iran-mirror-switcher
chmod +x ubuntu-iran-mirror-switcher.sh
```

## 🎯 Usage

### Basic Usage
```bash
sudo ./ubuntu-iran-mirror-switcher.sh
```

## 🏗️ You Can Add Other Available Iranian Mirrors Like :

- **ArvanCloud** - `mirror.arvancloud.ir`
- **Asis** - `ubuntu.asis.ai`
- **Shahed University** - `mirror.shahed.ac.ir`
- **Yazd University** - `mirror.yazd.ac.ir`
- **And more...**

## 📁 What It Does

1. **Backup**: Creates a backup of your current `/etc/apt/sources.list`
2. **Replace**: Replaces mirror URLs with Iranian alternatives
3. **Update**: Runs `apt update` to refresh package lists
4. **Verify**: Checks if the new mirrors are working correctly

## 🛡️ Safety Features

- **Automatic Backup**: Original sources.list is backed up before changes
- **Rollback Option**: Easy restoration to original configuration
- **Validation**: Checks mirror accessibility before switching
- **Confirmation**: Prompts for user confirmation before making changes

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📊 Mirror Performance

You can test mirror performance using:

```bash
# Test download speed
wget -O /dev/null http://mirror.arvancloud.ir/ubuntu/ls-lR.gz

# Compare multiple mirrors
for mirror in mirror.arvancloud.ir ubuntu.asis.ai; do
    echo "Testing $mirror..."
    time wget -O /dev/null http://$mirror/ubuntu/ls-lR.gz 2>&1
done
```

## ⚠️ Important Notes

- Always backup your system before making changes
- Some mirrors may have sync delays for the latest packages
- Corporate networks may have restrictions on certain mirrors
- Consider using official mirrors for critical production systems

## 🔗 Useful Links

- [Ubuntu Official Mirrors](https://launchpad.net/ubuntu/+archivemirrors)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Iranian Ubuntu community for maintaining local mirrors
- Mirror providers for their valuable service
- Contributors and users who helped improve this script



---

**Made with ❤️ for the Iranian Ubuntu community**

*This tool is provided as-is. Please test in a safe environment before using on production systems.*
