
EXACT_SAMPLE_LIMIT <- 2000

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

    if (length(args) != 2) {
        cat(sprintf("Usage: compute_ranksum_pvalue dataFile direction\n"))
        q(save="no", status=1)
    }

    dataFile <- args[1]
    direction <- args[2]
    pvalue <- compute.ranksum.pvalue(dataFile, direction)
    cat(pvalue, "\n")
}

compute.ranksum.pvalue <- function(dataFile, direction) {
    input.data = read.table(dataFile, sep="\t", header=T, stringsAsFactors=F)
    nAffected = sum(input.data$AFFECTED == 1)
    nUnaffected = sum(input.data$AFFECTED == 0)
    exact = (nAffected < 10 || nUnaffected < 10) && (pmax(nAffected,nUnaffected) <= EXACT_SAMPLE_LIMIT)
    input.data$AFFECTED <- as.factor(1 - input.data$AFFECTED)
    wt <- wilcox.test(RANK ~ AFFECTED, input.data, alternative=direction, exact=exact)
    return(wt$p.value)
}

main()
