# TSSr Documentation Index

Complete guide to all documentation files in the TSSr package.

## 📚 Quick Navigation

| Document | Purpose | Audience | Reading Time |
|----------|---------|----------|--------------|
| [QUICK_START.md](#quick_start) | Get started in 5 minutes | New users | 5 min |
| [README.md](#readme) | Complete package guide | All users | 30 min |
| [INSTALLATION.md](#installation) | Detailed installation | Having issues | 15 min |
| [INSTALLATION_CN.md](#installation_cn) | 安装指南（中文） | 中文用户 | 15分钟 |
| [CHANGELOG.md](#changelog) | Version history | Developers | 10 min |
| [Rcpp_Implementation_Guide.md](#rcpp_guide) | Technical implementation | Developers | 20 min |

---

## Quick Start Paths

### 🚀 I'm a New User
1. Read [QUICK_START.md](#quick_start) (5 min)
2. Skim [README.md](#readme) sections 1-5
3. Try example code
4. Refer to [README.md](#readme) section 5 for detailed usage

### 🔧 I'm Having Installation Issues
1. Check [INSTALLATION.md](#installation) "Troubleshooting" section
2. Follow platform-specific compiler instructions
3. Try alternative installation methods

### 📊 I Want to Understand Performance
1. Read [README.md](#readme) section 1 "Performance Optimization"
2. Run benchmark suite: [README.md](#readme) section 7
3. Check [CHANGELOG.md](#changelog) for performance details

### 💻 I'm a Developer
1. Read [Rcpp_Implementation_Guide.md](#rcpp_guide)
2. Check [CHANGELOG.md](#changelog) for API changes
3. Review source code comments in `src/peak_detection.cpp`

---

## Document Details

### <a name="quick_start"></a>QUICK_START.md

**Quick Start Guide**

**Purpose**: Get TSSr running in 5 minutes

**Contents**:
- One-command installation
- Quick verification test
- Basic usage example
- Performance notes

**When to Read**:
- First time installing TSSr
- Want to test quickly before deep dive
- Need a refresher on basic usage

**Key Sections**:
1. Prerequisites installation (1 command)
2. TSSr installation (1 command)
3. Verification (30 seconds)
4. Basic usage example

---

### <a name="readme"></a>README.md

**Complete Package Documentation**

**Purpose**: Comprehensive guide to all TSSr features

**Contents**:
1. Introduction & Performance Overview
2. Prerequisites
3. Installation
4. Input Data
5. Usage (detailed walkthrough)
6. Contact Information
7. Performance Benchmarking
8. References

**When to Read**:
- After quick start, for detailed usage
- Looking for specific functionality
- Need examples for each function
- Want to understand data formats

**Key Sections**:
- **Section 1**: Overview + new Rcpp performance features
- **Section 3**: Standard installation (most users start here)
- **Section 5**: Complete usage tutorial with examples
- **Section 7**: Performance benchmarking

**Highlights**:
- Complete workflow from BAM to results
- Example code for every function
- Visualization examples
- Performance tips

---

### <a name="installation"></a>INSTALLATION.md

**Comprehensive Installation Guide (English)**

**Purpose**: Detailed installation with troubleshooting

**Contents**:
1. Prerequisites
2. Compiler Installation (Windows/Mac/Linux)
3. R Package Installation
4. TSSr Installation
5. Verification
6. Troubleshooting (extensive)
7. Performance Testing

**When to Read**:
- Installation failed using quick start
- Need platform-specific instructions
- Rcpp compilation not working
- Want to verify installation is optimal

**Key Sections**:
- **Section 2**: Detailed compiler setup for each OS
- **Section 6**: Troubleshooting (7+ common issues with solutions)
- **Section 7**: Performance verification

**Problem-Solution Format**:
- Issue 1: Rcpp functions not available
- Issue 2: Windows compilation errors
- Issue 3: Mac compilation errors
- Issue 4: Bioconductor package fails
- Issue 5: Memory errors
- Issue 6: Installation works but slow

---

### <a name="installation_cn"></a>INSTALLATION_CN.md

**完整安装指南（中文）**

**目的**: 详细的中文安装说明

**内容**:
1. 系统要求
2. 编译器安装（Windows/Mac/Linux）
3. R包依赖安装
4. TSSr安装
5. 验证安装
6. 常见问题
7. 性能测试

**何时阅读**:
- 中文用户首选
- 需要平台特定说明
- 安装遇到问题
- 验证安装是否成功

**重点章节**:
- **第2节**: 各操作系统编译器详细设置
- **第6节**: 常见问题（含解决方案）
- **第7节**: 性能验证

---

### <a name="changelog"></a>CHANGELOG.md

**Version History and Changes**

**Purpose**: Track all changes, new features, and bug fixes

**Contents**:
- Version 1.2.0 (Current - Rcpp Implementation)
  - Major new features
  - New files
  - Modified files
  - Performance improvements
  - API changes
  - Bug fixes
  - Migration guide

**When to Read**:
- Upgrading from older version
- Need to know what changed
- Looking for new features
- Understanding performance improvements
- Checking for breaking changes

**Key Sections**:
- **Major New Features**: Rcpp implementation details
- **Performance Benchmarks**: Quantitative improvements
- **API Changes**: New and modified functions
- **Migration Guide**: How to upgrade smoothly

**For Developers**:
- Complete list of modified files
- Technical implementation details
- Dependency changes
- Testing information

---

### <a name="rcpp_guide"></a>inst/doc/Rcpp_Implementation_Guide.md

**Technical Implementation Guide**

**Purpose**: Deep dive into Rcpp implementation

**Contents**:
1. Overview
2. Installation Methods (3 approaches)
3. Core C++ Functions
4. Usage Examples
5. Performance Comparison
6. Implementation Details
7. Algorithm Comparison (R vs C++)
8. Troubleshooting
9. Best Practices

**When to Read**:
- Want to understand how Rcpp works
- Contributing to development
- Debugging performance issues
- Learning about optimization techniques

**Key Sections**:
- **Section 3**: Detailed C++ function descriptions
- **Section 5**: Performance benchmarks with explanations
- **Section 7**: Side-by-side R vs C++ algorithm comparison
- **Section 9**: Performance optimization tips

**Technical Depth**:
- Algorithm complexity analysis
- Memory management strategies
- Binary search implementation
- Vector pre-allocation techniques

**For Contributors**:
- Code organization
- Testing strategy
- Adding new Rcpp functions
- Maintaining compatibility

---

## Additional Resources

### Source Code Documentation

**In-code documentation** (for developers):
- `src/peak_detection.cpp` - C++ implementation with detailed comments
- `R/ClusteringFunctions_Rcpp.R` - R wrapper functions
- `R/ClusteringFunctions.R` - Original R implementation

### Benchmark Scripts

- `inst/scripts/benchmark_rcpp.R` - Full benchmark suite
- `compile_and_test.R` - Compilation verification

### Man Pages

Standard R help pages (access via `?function_name`):
```R
?clusterTSS
?findPeaksCpp
?useFastClustering
?getTSS
?consensusCluster
```

---

## Documentation by Task

### Installation Tasks

| Task | Document | Section |
|------|----------|---------|
| Quick install | QUICK_START.md | All |
| Standard install | README.md | Section 3 |
| Detailed install | INSTALLATION.md | Sections 1-4 |
| 中文安装 | INSTALLATION_CN.md | 全部 |
| Compiler setup | INSTALLATION.md | Section 2 |
| Troubleshooting | INSTALLATION.md | Section 6 |
| Verify installation | INSTALLATION.md | Section 5 |

### Usage Tasks

| Task | Document | Section |
|------|----------|---------|
| Basic workflow | QUICK_START.md | Section 4 |
| Complete tutorial | README.md | Section 5 |
| Specific functions | README.md | Section 5 |
| Performance tips | README.md | Section 7 |
| Control Rcpp | Rcpp_Implementation_Guide.md | Section 4 |

### Performance Tasks

| Task | Document | Section |
|------|----------|---------|
| Performance overview | README.md | Section 1 |
| Run benchmarks | README.md | Section 7 |
| Understand speedups | CHANGELOG.md | Major Features |
| Optimization details | Rcpp_Implementation_Guide.md | Sections 5-7 |

### Development Tasks

| Task | Document | Section |
|------|----------|---------|
| Implementation details | Rcpp_Implementation_Guide.md | Sections 6-7 |
| API changes | CHANGELOG.md | API Changes |
| Code structure | Rcpp_Implementation_Guide.md | Section 3 |
| Adding features | Rcpp_Implementation_Guide.md | Section 9 |

---

## Quick Reference

### Most Common Questions

**Q: How do I install TSSr?**
→ [QUICK_START.md](#quick_start) or [README.md Section 3](#readme)

**Q: Installation failed, what do I do?**
→ [INSTALLATION.md Section 6](#installation)

**Q: Is Rcpp working?**
→ [INSTALLATION.md Section 5](#installation) or [README.md Section 3](#readme)

**Q: How much faster is the new version?**
→ [README.md Section 1](#readme) or [CHANGELOG.md](#changelog)

**Q: How do I use TSSr?**
→ [QUICK_START.md Section 4](#quick_start) or [README.md Section 5](#readme)

**Q: What changed in version 1.2.0?**
→ [CHANGELOG.md](#changelog)

**Q: How does the Rcpp implementation work?**
→ [Rcpp_Implementation_Guide.md](#rcpp_guide)

**Q: 中文安装说明在哪里？**
→ [INSTALLATION_CN.md](#installation_cn)

---

## Feedback

Found an issue with the documentation? Please report:
- GitHub Issues: https://github.com/JohnnyChen1113/TSSrcpp/issues
- Email: zhenguo.lin@slu.edu

---

**Last Updated**: 2024-10-14
