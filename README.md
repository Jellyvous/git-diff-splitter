# 🔧 Git Diff Splitter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20WSL-blue.svg)](https://github.com/yourusername/git-diff-splitter)

> 🚀 **Advanced Git diff analysis tool** that intelligently splits large diffs into manageable chunks for better code review and analysis.

Perfect for handling massive diffs, detailed code reviews, and comparing any Git references with flexible options!

## ✨ Features

- 🔄 **Flexible Comparison**: Compare any branch, commit, or Git reference
- 📊 **Smart Splitting**: Automatically split large diffs into reviewable chunks
- 🎨 **Colorful Output**: Beautiful CLI interface with progress indicators
- 🚫 **Smart Filtering**: Exclude migration files, tests, or custom patterns
- 📁 **Organized Output**: Clean file naming and directory structure
- 📈 **Detailed Statistics**: File count, line count, and change summary
- ⚙️ **Highly Configurable**: Customizable chunk sizes and exclusion patterns

## 📋 Requirements

- **Git** 2.0+
- **Bash** 4.0+
- **Standard Unix utilities**: `wc`, `split`, `date`

Works on: Linux, macOS, Windows (WSL/Git Bash)

## 🚀 Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/git-diff-splitter.git
cd git-diff-splitter

# Make executable
chmod +x split_diff_advanced.sh

# Optional: Add to PATH for global access
sudo ln -s $(pwd)/split_diff_advanced.sh /usr/local/bin/git-diff-splitter
```

### Manual Download

```bash
# Download directly
curl -O https://raw.githubusercontent.com/yourusername/git-diff-splitter/main/split_diff_advanced.sh
chmod +x split_diff_advanced.sh
```

## 📖 Usage

### Basic Syntax

```bash
./split_diff_advanced.sh <branch-name> [options]
```

### Quick Start Examples

```bash
# Compare feature branch with main
./split_diff_advanced.sh feature/new-feature

# Compare with develop branch
./split_diff_advanced.sh feature/new-feature -b develop

# Compare current HEAD with 5 commits ago
./split_diff_advanced.sh HEAD -b HEAD~5

# Compare with specific commit
./split_diff_advanced.sh feature/auth -b abc1234
```

## 🛠️ Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--base` | `-b` | Base commit/branch to compare against | `main` |
| `--max-lines` | `-l` | Maximum lines per chunk | `300` |
| `--output` | `-o` | Output directory name | `diff_parts` |
| `--exclude` | `-e` | File patterns to exclude | `*Migration*` |
| `--help` | `-h` | Show help message | - |

## 💡 Examples

### Example 1: Basic Feature Branch Review

```bash
./split_diff_advanced.sh feature/user-authentication
```

**Output:**
```
🔍 So sánh từ: main (a1b2c3d)
         đến: feature/user-authentication (x7y8z9a)
📏 Giới hạn lines mỗi part: 300
📁 Thư mục output: diff_parts
📋 Files thay đổi:
   src/auth/login.js
   src/auth/register.js
   tests/auth.test.js
   ... và 5 files khác
📊 Tổng số dòng trong diff: 850
📦 Diff quá lớn, đang chia thành các part...
✅ Đã chia thành 3 parts
```

### Example 2: Custom Configuration

```bash
./split_diff_advanced.sh develop \
    -b main \
    -l 500 \
    -o my_review \
    -e "*Migration*,*Test*,*.min.js"
```

### Example 3: Historical Comparison

```bash
# Compare current branch with last week
./split_diff_advanced.sh $(git branch --show-current) -b HEAD@{1.week.ago}

# Compare release branches
./split_diff_advanced.sh release/v2.0 -b release/v1.9
```

## 📊 Sample Output Structure

```
diff_parts/
├── diff_part_01_a1b2c3d_to_x7y8z9a.txt
├── diff_part_02_a1b2c3d_to_x7y8z9a.txt
└── diff_part_03_a1b2c3d_to_x7y8z9a.txt
```

Each part contains:
- File headers with clear boundaries
- Contextual diff information
- Easy-to-read unified diff format

## 🎯 Use Cases

### 🔍 **Code Review**
Break down massive pull requests into digestible chunks for thorough review.

### 📈 **Release Analysis**
Compare release branches to understand what changed between versions.

### 🔄 **Merge Preparation**
Analyze conflicts and changes before complex merges.

### 📋 **Documentation**
Generate structured diff reports for change documentation.

### 🧪 **Testing Strategy**
Identify areas that need testing based on code changes.

## 🎨 Advanced Usage

### Working with Complex Git References

```bash
# Compare merge commit with its first parent
./split_diff_advanced.sh HEAD -b HEAD^1

# Compare branch with common ancestor
./split_diff_advanced.sh feature/branch -b $(git merge-base main feature/branch)

# Compare using date references
./split_diff_advanced.sh main -b "main@{2023-01-01}"
```

### Custom Exclusion Patterns

```bash
# Exclude multiple patterns
./split_diff_advanced.sh develop -e "*.min.js,*Migration*,*Test*,package-lock.json"

# Exclude entire directories
./split_diff_advanced.sh feature/ui -e "node_modules/*,dist/*,build/*"
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **🍴 Fork** the repository
2. **🌿 Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **💻 Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **📤 Push** to the branch (`git push origin feature/amazing-feature`)
5. **📬 Open** a Pull Request

### Development Setup

```bash
git clone https://github.com/yourusername/git-diff-splitter.git
cd git-diff-splitter

# Create test repository for development
mkdir test_repo
cd test_repo
git init
# ... create test scenarios
```

## 🐛 Troubleshooting

### Common Issues

**Issue**: `Branch 'xyz' không tồn tại`
```bash
# Check available branches
git branch -a
# Or use remote branch
./split_diff_advanced.sh origin/feature-branch
```

**Issue**: Permission denied
```bash
chmod +x split_diff_advanced.sh
```

**Issue**: Large diffs taking too long
```bash
# Reduce chunk size for faster processing
./split_diff_advanced.sh branch-name -l 100
```

---

<p align="center">
  <a href="https://github.com/yourusername/git-diff-splitter/issues">🐛 Report Bug</a> •
  <a href="https://github.com/yourusername/git-diff-splitter/issues">✨ Request Feature</a> •
  <a href="https://github.com/yourusername/git-diff-splitter/discussions">💬 Discussions</a>
</p>

## 📚 Related Tools

- [git-delta](https://github.com/dandavison/delta) - Enhanced diff viewer
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) - Good-looking diffs
- [tig](https://github.com/jonas/tig) - Text-mode interface for Git

---

**Happy coding! 🚀**