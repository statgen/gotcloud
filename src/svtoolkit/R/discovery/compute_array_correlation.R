
main <- function() {
    # Get values from command line
    args <- commandArgs()
    for (i in 1:length(args)) {
        if (i == length(args)) {
            args <- c()
        } else if (args[i] == "--args") {
            args <- args[(i+1):length(args)]
            break
        }
    }

    if (length(args) != 7) {
        cat(sprintf("Usage: compute_array_correlation cluster chr start end orientation data.file aux.output.file\n"))
        q(save="no", status=1)
    }

    cluster <- args[1]
    chr <- args[2]
    start <- args[3]
    end <- args[4]
    orientation <- args[5]
    dataFile <- args[6]
    auxFile <- ifelse(args[7] == "NA", NA, args[7])
    correlations <- compute.array.correlation(cluster, chr, start, end, orientation, dataFile, auxFile)
    cat(paste(correlations), "\n")
}

compute.array.correlation <- function(cluster, chr, start, end, orientation, dataFile, auxFile) {
    input.data <- read.table(dataFile, sep="\t", header=T, stringsAsFactors=F)
    sample.names <- names(input.data)[3:length(input.data)]
    depth.data <- as.numeric(input.data[input.data$SOURCE == "DEPTH", sample.names])
    array.ids <- sort(setdiff(input.data$SOURCE,"DEPTH"))
    correlations <- c()
    for (array.id in array.ids) {
        array.data <- input.data[input.data$SOURCE == array.id, sample.names]
        array.data <- apply(array.data, 2, mean)
        array.cor <- suppressWarnings(cor(depth.data, array.data, use="na.or.complete"))
        if (!is.na(auxFile)) {
            cat(paste(c(cluster, chr, start, end, orientation, array.id, array.data), collapse="\t"), "\n",
                file=auxFile,
                append=TRUE)
        }
        correlations <- c(correlations, array.cor)
    }
    return(correlations)
}

main()
