###############################################################################
#' Precisely identify TSSs from bam files, paired end bam files, bed files,
#' BigWig files, tss files, or tss tables.
#'
#' @description getTSS function is used to precisely identify TSSs from multiple
#' input file formats. The files include users' home-made alignment files (bam format)
#' or downloaded files from public databases. See inputFilesType for details on
#' the supported input file formats.
#'
#' @usage getTSS(object, sequencingQualityThreshold = 10, 
#' mappingQualityThreshold = 20, softclippingAllowed = FALSE)
#'
#' @param object A TSSr object.
#' @param sequencingQualityThreshold Used only if inputFilesType == "bam" or
#' "bamPairedEnd", otherwise ignored.
#' @param mappingQualityThreshold Used only if inputFilesType == "bam" or
#' "bamPairedEnd", otherwise ignored.
#' @param softclippingAllowed Used only if inputFilesType == "bam" or
#' "bamPairedEnd". Default is FALSE.
#' @return Large List of elements - one element for each sample
#'
#' @export
#'
#' @examples
#' \donttest{
#' data(exampleTSSr)
#' #getTSS(exampleTSSr)
#' }
setGeneric("getTSS",function(object
                             ,sequencingQualityThreshold = 10
                             ,mappingQualityThreshold = 20
                             ,softclippingAllowed = FALSE)standardGeneric("getTSS"))
#' @rdname getTSS
#' @export
setMethod("getTSS",signature(object = "TSSr"), function(object
                                    ,sequencingQualityThreshold
                                    ,mappingQualityThreshold
                                    ,softclippingAllowed){
  ##Validate inputs
  if(length(object@genomeName) == 0){
    stop("genomeName must be specified in the TSSr object")
  }
  if(length(object@inputFiles) == 0){
    stop("inputFiles must be specified in the TSSr object")
  }
  if(length(object@sampleLabels) == 0){
    stop("sampleLabels must be specified in the TSSr object")
  }
  if(length(object@inputFiles) != length(object@sampleLabels)){
    stop("Number of inputFiles (", length(object@inputFiles),
         ") must match number of sampleLabels (", length(object@sampleLabels), ")")
  }

  # Validate threshold parameters
  if(!is.numeric(sequencingQualityThreshold) || sequencingQualityThreshold < 0){
    stop("sequencingQualityThreshold must be a non-negative number")
  }
  if(!is.numeric(mappingQualityThreshold) || mappingQualityThreshold < 0){
    stop("mappingQualityThreshold must be a non-negative number")
  }
  if(!is.logical(softclippingAllowed)){
    stop("softclippingAllowed must be TRUE or FALSE")
  }

  # Check if input files exist
  missing_files <- object@inputFiles[!file.exists(object@inputFiles)]
  if(length(missing_files) > 0){
    stop("Input file(s) not found:\n", paste(missing_files, collapse = "\n"))
  }

  ##initialize values
  Genome <- .getGenome(object@genomeName)
  sampleLabels <- object@sampleLabels
  inputFilesType <- object@inputFilesType
  if (length(object@sampleLabelsMerged) == 0) {
    object@sampleLabelsMerged <- sampleLabels
  }
  objName <- deparse(substitute(object))
  if(inputFilesType == "bam" | inputFilesType == "bamPairedEnd"){
    tss <- .getTSS_from_bam(object@inputFiles
                     ,Genome
                     ,sampleLabels
                     ,inputFilesType
                     ,sequencingQualityThreshold
                     ,mappingQualityThreshold
                     ,softclippingAllowed)
  }else if(inputFilesType == "bed"){
    tss <- .getTSS_from_bed(object@inputFiles, Genome, sampleLabels)
  }else if(inputFilesType == "BigWig"){
    tss <- .getTSS_from_BigWig(object@inputFiles,Genome, sampleLabels)
  }else if(inputFilesType == "tss"){
    tss <- .getTSS_from_tss(object@inputFiles, sampleLabels)
  }else if(inputFilesType == "TSStable"){
    tss <- .getTSS_from_TSStable(object@inputFiles, sampleLabels)
  }
  setorder(tss, "strand","chr","pos")
  # get library sizes
  object@librarySizes <- colSums(tss[,4:ncol(tss), drop = FALSE], na.rm = TRUE)

  object@TSSrawMatrix <- tss
  object@TSSprocessedMatrix <- tss
  assign(objName, object, envir = parent.frame())
})


