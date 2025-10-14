# TSSr Quick Start Guide

Get TSSr up and running in 5 minutes!

## 1. Install Prerequisites (5 minutes)

### Install R Packages

```R
# Install in one go
install.packages(c("devtools", "Rcpp", "data.table", "stringr"))

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(c("Rsamtools", "GenomicRanges", "GenomicFeatures",
                       "Gviz", "rtracklayer", "DESeq2", "BSgenome"))
```

### Install C++ Compiler (for 30-5,600x speedup)

**Windows**: Download and install [Rtools](https://cran.r-project.org/bin/windows/Rtools/)

**Mac**: Run in Terminal:
```bash
xcode-select --install
```

**Linux**: Run in Terminal:
```bash
sudo apt-get install build-essential r-base-dev
```

## 2. Install TSSr (2 minutes)

```R
devtools::install_github("JohnnyChen1113/TSSrcpp", build_vignettes = TRUE)
```

## 3. Verify Installation (30 seconds)

```R
library(TSSr)
# Should see: "TSSr: Using fast Rcpp implementation (30-50x faster)"

# Quick test
test_data <- generateTestData(n = 1000)
peaks <- findPeaksCpp(test_data$positions, test_data$tags, 100)
cat("✓ Installation successful!\n")
```

## 4. Basic Usage Example

```R
# Create TSSr object from BAM files
myTSSr <- new("TSSr",
    genomeName = "BSgenome.Scerevisiae.UCSC.sacCer3",
    inputFiles = c("sample1.bam", "sample2.bam"),
    inputFilesType = "bam",
    sampleLabels = c("Control", "Treatment"),
    sampleLabelsMerged = c("Control", "Treatment"),
    mergeIndex = c(1, 2),
    refSource = "genome_annotation.gff",
    organismName = "Saccharomyces cerevisiae")

# Call TSSs from BAM files
getTSS(myTSSr)

# Merge and normalize samples
mergeSamples(myTSSr)
normalizeTSS(myTSSr)
filterTSS(myTSSr, method = "TPM")

# Cluster TSSs to infer core promoters (now 30-50x faster!)
clusterTSS(myTSSr, method = "peakclu",
           peakDistance = 100,
           extensionDistance = 30,
           localThreshold = 0.02,
           clusterThreshold = 1)

# Generate consensus clusters
consensusCluster(myTSSr, dis = 50)

# Annotate clusters to genes
annotateCluster(myTSSr,
                clusters = "consensusClusters",
                upstream = 1000)

# Export results
exportClustersTable(myTSSr, data = "assigned")
exportTSStable(myTSSr, data = "processed")
```

## Performance Note

With Rcpp acceleration enabled (default):
- **Small datasets** (<1,000 TSS): Fast on both R and Rcpp
- **Medium datasets** (1,000-10,000 TSS): **40-50x faster**
- **Large datasets** (>10,000 TSS): **50-5,600x faster**

Check if Rcpp is enabled:
```R
getOption("TSSr.use.rcpp")  # Should return TRUE
```

## Troubleshooting

**If installation fails:** See [INSTALLATION.md](INSTALLATION.md) for detailed troubleshooting

**If Rcpp not working:** TSSr will automatically fall back to R implementation (slower but functional)

**For help:** https://github.com/JohnnyChen1113/TSSrcpp/issues

## Next Steps

- Read full documentation: [README.md](README.md)
- Run performance benchmarks:
  ```R
  source(system.file("scripts", "benchmark_rcpp.R", package = "TSSr"))
  ```
- Check example vignettes:
  ```R
  browseVignettes("TSSr")
  ```

---

**Quick Reference Links**:
- 📖 Full Documentation: [README.md](README.md)
- 🔧 Detailed Installation: [INSTALLATION.md](INSTALLATION.md)
- 🚀 Rcpp Implementation: [inst/doc/Rcpp_Implementation_Guide.md](inst/doc/Rcpp_Implementation_Guide.md)
- 🐛 Report Issues: https://github.com/JohnnyChen1113/TSSrcpp/issues
