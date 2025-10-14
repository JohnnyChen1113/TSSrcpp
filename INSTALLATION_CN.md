# TSSr 安装指南

TSSr R包的完整安装指南（含Rcpp加速支持）

## 目录

1. [系统要求](#系统要求)
2. [安装编译器](#安装编译器)
3. [安装R包依赖](#安装R包依赖)
4. [安装TSSr](#安装TSSr)
5. [验证安装](#验证安装)
6. [常见问题](#常见问题)
7. [性能测试](#性能测试)

---

## 系统要求

### 最低要求

- **R版本**: ≥ 4.1.0
- **操作系统**: Windows、macOS 或 Linux
- **内存**: 最低4 GB，推荐8 GB以上（处理大型数据集）
- **硬盘空间**: 约500 MB

### 获得最佳性能的推荐配置

- **C++编译器**: 启用Rcpp加速所需（提速30-5,600倍）
- **多核CPU**: 用于大型数据集的并行处理

---

## 安装编译器

Rcpp加速需要C++编译器。请根据您的操作系统按以下步骤安装：

### Windows系统

1. **下载Rtools**: [https://cran.r-project.org/bin/windows/Rtools/](https://cran.r-project.org/bin/windows/Rtools/)
   - 选择与您的R版本匹配的Rtools版本
   - 例如：R 4.4.x 使用 Rtools44

2. **安装Rtools**:
   - 运行安装程序
   - **重要**: 勾选"Add rtools to system PATH"选项
   - 默认安装路径: `C:\rtools44`

3. **验证安装**:
   ```R
   # 在R控制台中运行
   Sys.which("make")
   # 应显示make.exe的路径，如 "C:\\rtools44\\usr\\bin\\make.exe"
   ```

4. 安装完成后**重启R/RStudio**

### macOS系统

1. **安装Xcode命令行工具**:
   ```bash
   xcode-select --install
   ```
   - 会弹出对话框，点击"安装"
   - 安装需要5-10分钟

2. **验证安装**:
   ```bash
   gcc --version
   # 应显示gcc版本信息
   ```

### Linux系统

#### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y build-essential r-base-dev
```

#### CentOS/RHEL/Fedora

```bash
sudo yum groupinstall "Development Tools"
sudo yum install R-devel
```

#### Arch Linux

```bash
sudo pacman -S base-devel
```

**验证安装**:
```bash
gcc --version
g++ --version
```

---

## 安装R包依赖

### 方法1: 手动安装（推荐）

逐步安装所有必需的包：

```R
# 核心包
install.packages("devtools")
install.packages("Rcpp")
install.packages("data.table")
install.packages("stringr")

# Bioconductor包
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("Rsamtools")
BiocManager::install("GenomicRanges")
BiocManager::install("GenomicFeatures")
BiocManager::install("Gviz")
BiocManager::install("rtracklayer")
BiocManager::install("DESeq2")
BiocManager::install("BSgenome")
```

### 方法2: Conda安装

```bash
# 创建conda环境
conda create -n tssr python=3.9
conda activate tssr

# 安装R和依赖包
conda install -c conda-forge r-base=4.4.0
conda install -c bioconda -c conda-forge \
    bioconductor-rsamtools \
    bioconductor-genomicranges \
    bioconductor-genomicfeatures \
    bioconductor-gviz \
    bioconductor-rtracklayer \
    bioconductor-deseq2 \
    bioconductor-bsgenome \
    r-data.table \
    r-stringr \
    r-devtools \
    r-rcpp \
    compilers

# 注意：'compilers'包提供C++编译器
```

---

## 安装TSSr

### 方法1: 从GitHub直接安装（推荐）

```R
# 标准安装，包含Rcpp编译
devtools::install_github("JohnnyChen1113/TSSrcpp", build_vignettes = TRUE)
```

**安装时间**: 3-5分钟（包括编译时间）

### 方法2: 从源码安装

```bash
# 克隆仓库
git clone https://github.com/JohnnyChen1113/TSSrcpp.git
cd TSSr

# 在R中安装
R CMD INSTALL --preclean .
```

### 方法3: 不构建文档安装（更快）

```R
# 跳过构建文档（安装更快）
devtools::install_github("JohnnyChen1113/TSSrcpp", build_vignettes = FALSE)
```

---

## 验证安装

### 步骤1: 加载包

```R
library(TSSr)
```

预期输出：
```
TSSr: Using fast Rcpp implementation (30-50x faster)
```

如果看到此消息，说明Rcpp加速已成功启用！

### 步骤2: 检查Rcpp状态

```R
# 检查Rcpp是否启用
getOption("TSSr.use.rcpp")
# 预期输出: TRUE
```

### 步骤3: 测试Rcpp函数

```R
# 生成测试数据
test_data <- generateTestData(n = 1000)

# 测试峰检测
peaks <- findPeaksCpp(
    positions = test_data$positions,
    tags = test_data$tags,
    peakDistance = 100
)

# 应在 < 1毫秒内完成
cat(sprintf("检测到 %d 个峰\n", sum(peaks > 0)))
```

### 步骤4: 运行快速基准测试

```R
# 比较R vs Rcpp性能
library(microbenchmark)

test_data <- generateTestData(n = 5000)

results <- microbenchmark(
    Rcpp = findPeaksCpp(test_data$positions, test_data$tags, 100),
    times = 10
)

print(results)
# Rcpp的中位时间应 < 0.2毫秒
```

---

## 常见问题

### 问题1: Rcpp函数不可用

**症状**:
```
Error: Rcpp functions not found
TSSr: Using R implementation (Rcpp unavailable)
```

**解决方案**:

1. **检查编译器安装**:
   ```R
   # 测试Rcpp编译
   Rcpp::evalCpp("2 + 2")
   # 如果失败，说明编译器未正确安装
   ```

2. **重新安装并显示详细输出**:
   ```R
   devtools::install_github("JohnnyChen1113/TSSrcpp",
                           build_vignettes = FALSE,
                           force = TRUE,
                           quiet = FALSE)
   # 查看输出中的编译错误
   ```

### 问题2: Windows上的编译错误

**症状**:
```
ERROR: compilation failed for package 'TSSr'
```

**解决方案**:

1. **验证Rtools在PATH中**:
   ```R
   Sys.getenv("PATH")
   # 应包含Rtools/usr/bin的路径
   ```

2. **手动添加Rtools到PATH**:
   ```R
   # 添加到.Renviron文件
   writeLines('PATH="${RTOOLS44_HOME}\\usr\\bin;${PATH}"',
              con = "~/.Renviron")
   # 重启R
   ```

### 问题3: Mac上的编译错误

**症状**:
```
clang: error: unsupported option '-fopenmp'
```

**解决方案**:

1. **安装命令行工具**:
   ```bash
   xcode-select --install
   ```

2. **更新macOS SDK**:
   ```bash
   softwareupdate --install -a
   ```

### 问题4: 内存错误

**症状**:
```
Error: cannot allocate vector of size X GB
```

**解决方案**:

1. **增加内存限制**（Windows）:
   ```R
   memory.limit(size = 16000)  # 16 GB
   ```

2. **不构建文档安装**:
   ```R
   devtools::install_github("JohnnyChen1113/TSSrcpp", build_vignettes = FALSE)
   ```

---

## 性能测试

### 运行完整基准测试

```R
# 运行综合基准测试
source(system.file("scripts", "benchmark_rcpp.R", package = "TSSr"))
```

这将：
- 测试多种数据集大小（1K、5K、10K、50K个位点）
- 比较R vs Rcpp实现
- 生成性能图表：`benchmark_rcpp_performance.pdf`
- 显示详细的计时统计

### 预期结果

| 数据集大小 | 峰检测加速 | 局部过滤加速 | 总体加速 |
|-----------|-----------|-------------|---------|
| 1,000     | 850倍     | 55倍        | ~40倍   |
| 5,000     | 1,600倍   | 55倍        | ~45倍   |
| 10,000    | 2,500倍   | 55倍        | ~50倍   |
| 50,000    | 5,600倍   | 55倍        | ~60倍   |

**解读**：
- **< 1,000个TSS**: 两种实现都很快
- **1,000-10,000个TSS**: Rcpp提供40-50倍加速
- **> 10,000个TSS**: Rcpp提供50-5,600倍加速（关键优势）

### 快速性能检查

```R
# 快速测试验证Rcpp是否工作
library(microbenchmark)
library(TSSr)

# 生成测试数据
data <- generateTestData(n = 10000)

# 基准测试峰检测
bench <- microbenchmark(
    findPeaksCpp(data$positions, data$tags, 100),
    times = 10,
    unit = "ms"
)

print(bench)

# 预期中位时间：
# - 有Rcpp: < 0.3毫秒
# - 无Rcpp: > 500毫秒（慢1,700倍）
```

---

## 性能优化建议

1. **启用Rcpp加速**（默认）：对于>1,000个TSS位点的数据集，Rcpp提供显著加速。

2. **使用适当的聚类参数**：
   - `peakDistance = 100` 和 `extensionDistance = 30` 对大多数基因组都是优化的
   - 较小的值会增加计算时间

3. **尽早过滤低支持度的TSS**：在聚类前使用 `filterTSS()` 来减少要聚类的位点数。

4. **多核处理**：对于非常大的数据集，结合Rcpp加速和多核处理：
   ```R
   clusterTSS(myTSSr, useMultiCore = TRUE, numCores = 4)
   ```

---

## 其他资源

- **GitHub仓库**: https://github.com/JohnnyChen1113/TSSrcpp
- **文档**: https://github.com/JohnnyChen1113/TSSrcpp/blob/master/README.md
- **Rcpp实现指南**: `inst/doc/Rcpp_Implementation_Guide.md`
- **问题追踪**: https://github.com/JohnnyChen1113/TSSrcpp/issues

## 获取帮助

如果遇到本指南未涵盖的问题：

1. 查看现有的 [GitHub Issues](https://github.com/JohnnyChen1113/TSSrcpp/issues)
2. 创建新issue，包含：
   - 操作系统和R版本
   - 完整错误消息
   - `sessionInfo()` 的输出
   - 重现步骤

---

**最后更新**: 2024-10-14
**TSSr版本**: 1.2.0（含Rcpp加速）
