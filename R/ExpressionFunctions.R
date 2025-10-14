###############################################################################
##.deseq2 function calcuates gene differential expression based on Deseq2 package
##.deseq2 function takes two assigned clusters and tss.raw table
##users need to provide which sample they want to compare and
##run script with the following example command:
##.deseq2(clustersx.asn,clustersy.asn, tss.raw,
##                              samplex <- c("ScerBY4741.1","ScerBY4741.2"),
##                              sampley <- c("ScerArrest.1","ScerArrest.2"),
##                              sampleOne <- "ScerBY4741",sampleTwo <- "ScerArrest")
############################################################################
##tss.raw is the raw tss merged tables, before any sums
############################################################################
.deseq2 <- function(object,cx,cy, tss.raw, samplex,sampley, sampleOne,sampleTwo,useMultiCore, numCores, temp_file){
  ##define variable as a NULL value
  TAGtables = NULL

  ##get raw count tables
  TAGtables <- object@TAGtables
  if(sampleOne%in%names(TAGtables)){
    xCounts<-TAGtables[[which(names(TAGtables)==sampleOne)]]
  } else{
    xCounts <-.tagCount_updated(cx, tss.raw,samplex,useMultiCore, numCores)
    ## save the tagCount results
    TAGtables[[sampleOne]]<-xCounts
  }

  if(sampleTwo%in%names(TAGtables)){
    yCounts<-TAGtables[[which(names(TAGtables)==sampleTwo)]]
  } else{
    yCounts <-.tagCount_updated(cy, tss.raw,sampley,useMultiCore, numCores)
    TAGtables[[sampleTwo]]<-yCounts
  }
  #save TAGtable to specified temp file
  save(TAGtables, file=temp_file)
  xCounts <- xCounts[,-c(2:11)]
  yCounts <- yCounts[,-c(2:11)]
  ##tag counts by gene for sampleOne
  setkey(xCounts, gene)
  if(useMultiCore){
    if(is.null(numCores)){
      numCores <- detectCores()
    }
    one <- mclapply(as.list(unique(xCounts$gene)), function(my.gene) {
      data <- xCounts[list(my.gene)]
      return(c(my.gene,colSums(data[,-c(1,2,3)])))
    }, mc.cores = numCores)
  }else{
    one <- lapply(as.list(unique(xCounts$gene)), function(my.gene) {
      data <- xCounts[list(my.gene)]
      return(c(my.gene,colSums(data[,-c(1,2,3)])))
    })
  }
  one <- data.frame(matrix(unlist(one), nrow=length(one), byrow=TRUE),stringsAsFactors=FALSE)

  ##tag counts by gene for sampleTwo
  setkey(yCounts, gene)
  if(useMultiCore){
    if(is.null(numCores)){
      numCores <- detectCores()
    }
    two <- mclapply(as.list(unique(yCounts$gene)), function(my.gene) {
      data <- yCounts[list(my.gene)]
      return(c(my.gene,colSums(data[,-c(1,2,3)])))
    }, mc.cores = numCores)

  }else{
    two <- lapply(as.list(unique(yCounts$gene)), function(my.gene) {
      data <- yCounts[list(my.gene)]
      return(c(my.gene,colSums(data[,-c(1,2,3)])))
    })
  }
  two <- data.frame(matrix(unlist(two), nrow=length(two), byrow=TRUE),stringsAsFactors=FALSE)
  ##merge the two raw count tables together by genes
  one[,2:ncol(one)] <- sapply(one[,2:ncol(one)], as.integer)
  two[,2:ncol(two)] <- sapply(two[,2:ncol(two)], as.integer)
  setnames(one, colnames(one), c("gene",samplex))
  setnames(two, colnames(two), c("gene",sampley))
  Dtable <- merge(one, two, by = c("gene"), all = TRUE)
  Dtable[is.na(Dtable)] = 0
  ##
  rownames(Dtable) <- Dtable[,1]
  Dtable <- Dtable[,-1]
  Dtable <- data.matrix(Dtable)
  condition <- factor(c(rep(sampleOne, times = length(samplex)), rep(sampleTwo, times = length(sampley))))
  dds <- DESeqDataSetFromMatrix(countData = Dtable,data.frame(condition), ~ condition)
  dds$condition <- factor(dds$condition, levels = c(sampleOne, sampleTwo))
  dds <- DESeq(dds)
  res <- results(dds)
  res <- res[order(res$padj),]
  return(as.data.frame(res))
}

############################################################################
##.tagCount - unified and optimized version
##This function calculates tag counts for each cluster across samples
##filterZeros: if TRUE, exclude rows with no counts before processing (faster)
.tagCount <- function(cs, tss.raw, samples, useMultiCore = FALSE, numCores = NULL, filterZeros = FALSE){

  ##define variable as a NULL value
  tag_sum = chr = strand = start = end = NULL

  # Validate inputs
  if(!is.data.frame(cs) && !is.data.table(cs)){
    stop("cs must be a data.frame or data.table")
  }
  if(!is.data.frame(tss.raw) && !is.data.table(tss.raw)){
    stop("tss.raw must be a data.frame or data.table")
  }
  if(!all(samples %in% colnames(tss.raw))){
    missing <- samples[!samples %in% colnames(tss.raw)]
    stop("Sample(s) not found in tss.raw: ", paste(missing, collapse = ", "))
  }

  # Select relevant columns
  cols <- c("chr","pos","strand", samples)
  tss <- tss.raw[,.SD, .SDcols = cols]

  # Filter out zero-count rows if requested (faster for large datasets)
  if(filterZeros){
    tss[, tag_sum := rowSums(.SD), .SDcols = samples]
    tss <- tss[tag_sum > 0]
    tss[, tag_sum := NULL]
  }

  # Set keys for faster subsetting
  setkey(tss, chr, strand)
  setDT(cs)

  # Configure multicore processing
  if(useMultiCore){
    if(is.null(numCores)){
      numCores <- detectCores()
    }
    message("Process is running on ", numCores, " cores...")

    # Use mclapply for parallel processing
    tags <- mclapply(seq_len(nrow(cs)), function(r){
      # Use data.table subsetting which is faster
      data <- tss[.(cs[r, chr], cs[r, strand])][pos >= cs[r, start] & pos <= cs[r, end]]
      # Use colSums for better performance than sapply
      if(nrow(data) > 0){
        return(colSums(data[, .SD, .SDcols = samples]))
      } else {
        return(rep(0, length(samples)))
      }
    }, mc.cores = numCores)

  } else {
    # Single-core processing
    tags <- lapply(seq_len(nrow(cs)), function(r){
      data <- tss[.(cs[r, chr], cs[r, strand])][pos >= cs[r, start] & pos <= cs[r, end]]
      if(nrow(data) > 0){
        return(colSums(data[, .SD, .SDcols = samples]))
      } else {
        return(rep(0, length(samples)))
      }
    })
  }

  # Convert to data.frame more efficiently
  tags <- do.call(rbind, tags)
  colnames(tags) <- samples

  # Combine with cluster data
  cs <- cbind(cs, tags)
  return(cs)
}

##.tagCount_updated - wrapper for backward compatibility
##This maintains the old interface but calls the new unified function
.tagCount_updated <- function(cs, tss.raw, samples, useMultiCore = FALSE, numCores = NULL){
  return(.tagCount(cs, tss.raw, samples, useMultiCore, numCores, filterZeros = TRUE))
}



