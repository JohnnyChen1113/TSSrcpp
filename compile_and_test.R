#!/usr/bin/env Rscript
################################################################################
## 编译TSSr包并运行基准测试
################################################################################

cat("\n", rep("=", 70), "\n", sep="")
cat("           TSSr包Rcpp编译和基准测试流程\n")
cat(rep("=", 70), "\n\n", sep="")

# 检查必需的包
required_packages <- c("Rcpp", "devtools", "microbenchmark", "ggplot2", "data.table")
missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]

if(length(missing_packages) > 0) {
  cat("安装缺失的包:", paste(missing_packages, collapse=", "), "\n")
  install.packages(missing_packages, repos="https://cloud.r-project.org")
}

library(Rcpp)
library(devtools)

################################################################################
## 步骤1: 编译Rcpp代码
################################################################################
cat("\n=== 步骤1: 生成Rcpp导出函数 ===\n")
setwd("/mnt/b16/25_TSSr_vibing_dev/TSSr")

tryCatch({
  # 生成RcppExports.R和RcppExports.cpp
  Rcpp::compileAttributes(verbose = TRUE)
  cat("✓ Rcpp导出函数生成成功\n")
}, error = function(e) {
  cat("✗ 错误:", conditionMessage(e), "\n")
  quit(status = 1)
})

################################################################################
## 步骤2: 编译并安装包
################################################################################
cat("\n=== 步骤2: 编译并安装TSSr包 ===\n")

tryCatch({
  # 清理旧的编译文件
  if(file.exists("src/*.o")) unlink("src/*.o")
  if(file.exists("src/*.so")) unlink("src/*.so")
  if(file.exists("src/*.dll")) unlink("src/*.dll")

  # 编译并安装
  devtools::install(upgrade = "never", quiet = FALSE)
  cat("✓ TSSr包安装成功\n")
}, error = function(e) {
  cat("✗ 编译错误:", conditionMessage(e), "\n")
  cat("\n尝试使用R CMD INSTALL...\n")
  system("R CMD INSTALL --preclean .")
})

################################################################################
## 步骤3: 验证安装
################################################################################
cat("\n=== 步骤3: 验证Rcpp函数 ===\n")

# 卸载旧版本（如果有）
try(detach("package:TSSr", unload=TRUE), silent=TRUE)

# 加载新编译的版本
library(TSSr)

# 检查Rcpp函数
rcpp_functions <- c("findPeaksCpp", "localFilterCpp",
                    "calculateQuantilePositionCpp", "generateTestData")

cat("\n检查Rcpp函数可用性:\n")
for(func in rcpp_functions) {
  available <- exists(func)
  status <- ifelse(available, "✓", "✗")
  cat(sprintf("  %s %s\n", status, func))

  if(!available) {
    cat("\n警告: ", func, " 不可用，可能编译失败\n")
  }
}

# 检查Rcpp设置
cat("\nRcpp设置:\n")
cat("  TSSr.use.rcpp =", getOption("TSSr.use.rcpp"), "\n")

################################################################################
## 步骤4: 快速功能测试
################################################################################
cat("\n=== 步骤4: 快速功能测试 ===\n")

if(exists("generateTestData") && exists("findPeaksCpp")) {
  cat("\n测试Rcpp函数...\n")

  # 生成小测试数据
  test_data <- generateTestData(n = 100)

  # 测试峰检测
  peaks <- findPeaksCpp(test_data$positions, test_data$tags, 100)
  cat(sprintf("  峰检测: 在100个位点中检测到 %d 个峰\n", sum(peaks > 0)))

  # 测试局部过滤
  if(exists("localFilterCpp")) {
    keep <- localFilterCpp(test_data$positions, test_data$tags, peaks,
                          100, 0.02, "+")
    cat(sprintf("  局部过滤: 保留 %d/%d 个位点\n", sum(keep), length(keep)))
  }

  cat("\n✓ 功能测试通过\n")
} else {
  cat("\n⚠ 跳过功能测试（Rcpp函数不可用）\n")
}

################################################################################
## 步骤5: 询问是否运行完整基准测试
################################################################################
cat("\n", rep("=", 70), "\n", sep="")
cat("编译完成！\n")
cat(rep("=", 70), "\n\n", sep="")

cat("现在可以运行基准测试。这将需要5-10分钟时间。\n\n")
cat("运行命令:\n")
cat('  source("inst/scripts/benchmark_rcpp.R")\n\n')

# 自动运行基准测试
cat("正在启动基准测试...\n\n")
Sys.sleep(2)

if(file.exists("inst/scripts/benchmark_rcpp.R")) {
  source("inst/scripts/benchmark_rcpp.R")
} else {
  cat("⚠ 基准测试脚本不存在\n")
}
