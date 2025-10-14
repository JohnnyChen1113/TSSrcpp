# TSSr Installation Guide

Complete guide for installing TSSr with Rcpp acceleration support.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installing Compilers](#installing-compilers)
3. [Installing R Packages](#installing-r-packages)
4. [Installing TSSr](#installing-tssr)
5. [Verifying Installation](#verifying-installation)
6. [Troubleshooting](#troubleshooting)
7. [Performance Testing](#performance-testing)

---

## Prerequisites

### Minimum Requirements

- **R version**: ≥ 4.1.0
- **Operating System**: Windows, macOS, or Linux
- **RAM**: 4 GB minimum, 8 GB+ recommended for large datasets
- **Disk Space**: ~500 MB for installation

### Recommended for Best Performance

- **C++ Compiler**: Required for Rcpp acceleration (30-5,600x speedup)
- **Multicore CPU**: For parallel processing of large datasets

---

## Installing Compilers

Rcpp acceleration requires a C++ compiler. Follow the instructions for your operating system:

### Windows

1. **Download Rtools** from [https://cran.r-project.org/bin/windows/Rtools/](https://cran.r-project.org/bin/windows/Rtools/)
   - Choose the Rtools version matching your R version
   - Example: Rtools44 for R 4.4.x

2. **Install Rtools**:
   - Run the installer
   - **Important**: Check the option "Add rtools to system PATH"
   - Default installation path: `C:\rtools44`

3. **Verify installation**:
   ```R
   # In R console
   Sys.which("make")
   # Should show path to make.exe, e.g., "C:\\rtools44\\usr\\bin\\make.exe"
   ```

4. **Restart R/RStudio** after installation

### macOS

1. **Install Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```
   - A dialog will appear - click "Install"
   - Installation takes 5-10 minutes

2. **Verify installation**:
   ```bash
   gcc --version
   # Should display gcc version information
   ```

3. **Alternative**: Install full Xcode from App Store (optional, larger download)

### Linux

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

**Verify installation**:
```bash
gcc --version
g++ --version
```

---

## Installing R Packages

### Method 1: Manual Installation (Recommended)

Install all required packages step-by-step:

```R
# Core packages
install.packages("devtools")
install.packages("Rcpp")
install.packages("data.table")
install.packages("stringr")

# Bioconductor packages
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

### Method 2: Conda Installation

```bash
# Create conda environment
conda create -n tssr python=3.9
conda activate tssr

# Install R and dependencies
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

# Note: 'compilers' package provides C++ compiler
```

### Method 3: One-Line Installation (may fail on some systems)

```R
# Install all at once (not recommended if any package fails)
pkgs <- c("devtools", "Rcpp", "data.table", "stringr")
install.packages(pkgs)

BiocManager::install(c("Rsamtools", "GenomicRanges", "GenomicFeatures",
                       "Gviz", "rtracklayer", "DESeq2", "BSgenome"))
```

---

## Installing TSSr

### Method 1: Direct from GitHub (Recommended)

```R
# Standard installation with Rcpp compilation
devtools::install_github("JohnnyChen1113/TSSrcpp", build_vignettes = TRUE)
```

**Installation time**: 3-5 minutes (includes compilation)

### Method 2: Install from Source

```bash
# Clone repository
git clone https://github.com/JohnnyChen1113/TSSrcpp.git
cd TSSr

# Install in R
R CMD INSTALL --preclean .
```

### Method 3: Install without Vignettes (faster)

```R
# Skip building vignettes (faster installation)
devtools::install_github("JohnnyChen1113/TSSrcpp", build_vignettes = FALSE)
```

---

## Verifying Installation

### Step 1: Load Package

```R
library(TSSr)
```

Expected output:
```
TSSr: Using fast Rcpp implementation (30-50x faster)
```

If you see this message, Rcpp acceleration is successfully enabled!

### Step 2: Check Rcpp Status

```R
# Check if Rcpp is enabled
getOption("TSSr.use.rcpp")
# Expected: TRUE
```

### Step 3: Test Rcpp Functions

```R
# Generate test data
test_data <- generateTestData(n = 1000)

# Test peak detection
peaks <- findPeaksCpp(
    positions = test_data$positions,
    tags = test_data$tags,
    peakDistance = 100
)

# Should complete in < 1 ms
cat(sprintf("Detected %d peaks\n", sum(peaks > 0)))
```

### Step 4: Run Quick Benchmark

```R
# Compare R vs Rcpp performance
library(microbenchmark)

test_data <- generateTestData(n = 5000)

results <- microbenchmark(
    Rcpp = findPeaksCpp(test_data$positions, test_data$tags, 100),
    times = 10
)

print(results)
# Median time should be < 0.2 ms for Rcpp
```

---

## Troubleshooting

### Issue 1: Rcpp Functions Not Available

**Symptom**:
```
Error: Rcpp functions not found
TSSr: Using R implementation (Rcpp unavailable)
```

**Solutions**:

1. **Check compiler installation**:
   ```R
   # Test Rcpp compilation
   Rcpp::evalCpp("2 + 2")
   # If this fails, compiler is not properly installed
   ```

2. **Reinstall with verbose output**:
   ```R
   devtools::install_github("JohnnyChen1113/TSSrcpp",
                           build_vignettes = FALSE,
                           force = TRUE,
                           quiet = FALSE)
   # Look for compilation errors in output
   ```

3. **Check NAMESPACE**:
   ```R
   # After installation, check if Rcpp is exported
   library(TSSr)
   exists("findPeaksCpp")  # Should return TRUE
   ```

### Issue 2: Compilation Errors on Windows

**Symptom**:
```
ERROR: compilation failed for package 'TSSr'
```

**Solutions**:

1. **Verify Rtools is in PATH**:
   ```R
   Sys.getenv("PATH")
   # Should contain path to Rtools/usr/bin
   ```

2. **Add Rtools to PATH manually**:
   ```R
   # Add to .Renviron file
   writeLines('PATH="${RTOOLS44_HOME}\\usr\\bin;${PATH}"',
              con = "~/.Renviron")
   # Restart R
   ```

3. **Reinstall Rtools** and ensure "Add to PATH" is checked

### Issue 3: Compilation Errors on Mac

**Symptom**:
```
clang: error: unsupported option '-fopenmp'
```

**Solutions**:

1. **Install Command Line Tools**:
   ```bash
   xcode-select --install
   ```

2. **Update to latest macOS SDK**:
   ```bash
   softwareupdate --install -a
   ```

3. **Check compiler version**:
   ```bash
   gcc --version
   clang --version
   ```

### Issue 4: Bioconductor Package Installation Fails

**Symptom**:
```
Error: Bioconductor package 'xxx' is not available
```

**Solutions**:

1. **Update BiocManager**:
   ```R
   install.packages("BiocManager")
   BiocManager::install(version = "3.18")  # Latest version
   ```

2. **Install packages one by one**:
   ```R
   BiocManager::install("GenomicRanges", ask = FALSE)
   BiocManager::install("DESeq2", ask = FALSE)
   # etc.
   ```

3. **Check Bioconductor version compatibility**:
   ```R
   BiocManager::valid()
   ```

### Issue 5: Memory Errors During Installation

**Symptom**:
```
Error: cannot allocate vector of size X GB
```

**Solutions**:

1. **Increase memory limit** (Windows):
   ```R
   memory.limit(size = 16000)  # 16 GB
   ```

2. **Close other applications** before installation

3. **Install without vignettes**:
   ```R
   devtools::install_github("JohnnyChen1113/TSSrcpp", build_vignettes = FALSE)
   ```

### Issue 6: Installation Works but Functions are Slow

**Symptom**: Installation succeeds but clustering is still slow

**Diagnosis**:
```R
# Check if Rcpp is actually being used
getOption("TSSr.use.rcpp")

# If FALSE, Rcpp compilation may have failed silently
```

**Solutions**:

1. **Force Rcpp usage**:
   ```R
   useFastClustering(use_rcpp = TRUE)
   ```

2. **Verify Rcpp functions exist**:
   ```R
   exists("findPeaksCpp")
   exists("localFilterCpp")
   exists("calculateQuantilePositionCpp")
   ```

3. **Check package installation location**:
   ```R
   find.package("TSSr")
   # Check if src/*.so or src/*.dll exists in this directory
   ```

---

## Performance Testing

### Run Full Benchmark Suite

```R
# Run comprehensive benchmarks
source(system.file("scripts", "benchmark_rcpp.R", package = "TSSr"))
```

This will:
- Test multiple dataset sizes (1K, 5K, 10K, 50K positions)
- Compare R vs Rcpp implementations
- Generate performance plots: `benchmark_rcpp_performance.pdf`
- Display detailed timing statistics

### Expected Results

| Dataset Size | Peak Detection | Local Filtering | Total Speedup |
|--------------|----------------|-----------------|---------------|
| 1,000        | 850x           | 55x             | ~40x          |
| 5,000        | 1,600x         | 55x             | ~45x          |
| 10,000       | 2,500x         | 55x             | ~50x          |
| 50,000       | 5,600x         | 55x             | ~60x          |

**Interpretation**:
- **< 1,000 TSS**: Both implementations are fast
- **1,000-10,000 TSS**: Rcpp provides 40-50x speedup
- **> 10,000 TSS**: Rcpp provides 50-5,600x speedup (critical)

### Quick Performance Check

```R
# Quick test to verify Rcpp is working
library(microbenchmark)
library(TSSr)

# Generate test data
data <- generateTestData(n = 10000)

# Benchmark peak detection
bench <- microbenchmark(
    findPeaksCpp(data$positions, data$tags, 100),
    times = 10,
    unit = "ms"
)

print(bench)

# Expected median time:
# - With Rcpp: < 0.3 ms
# - Without Rcpp: > 500 ms (1,700x slower)
```

---

## Additional Resources

- **GitHub Repository**: https://github.com/JohnnyChen1113/TSSrcpp
- **Documentation**: https://github.com/JohnnyChen1113/TSSrcpp/blob/master/README.md
- **Rcpp Implementation Guide**: `inst/doc/Rcpp_Implementation_Guide.md`
- **Issue Tracker**: https://github.com/JohnnyChen1113/TSSrcpp/issues

## Getting Help

If you encounter issues not covered in this guide:

1. Check existing [GitHub Issues](https://github.com/JohnnyChen1113/TSSrcpp/issues)
2. Create a new issue with:
   - Operating system and R version
   - Complete error message
   - Output of `sessionInfo()`
   - Steps to reproduce

---

**Last Updated**: 2024-10-14
**TSSr Version**: 1.2.0 (with Rcpp acceleration)
