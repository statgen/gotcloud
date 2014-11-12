
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

    if (length(args) != 4) {
        cat(sprintf("Usage: compute_depth_pvalue obsIn obsOut unobsIn unobsOut\n"))
        q(save="no", status=1)
    }

    cat(sprintf("%f\n", depth.chisq.1(as.numeric(args))))
}

depth.chisq.1 <- function(values) {
    if (all(values <= 0)) {
        return(NaN)
    }
    m <- matrix(values, ncol=2)
    htest <- suppressWarnings(chisq.test(m))
    return(htest$p.value)
}

main()
