
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

    if (length(args) != 3) {
        cat(sprintf("Usage: plot_isd isdFile statFile outputFile\n"))
        q(save="no", status=1)
    }

    isdFile = args[1]
    statFile = args[2]
    outputFile = args[3]
    plotISD(isdFile, statFile, outputFile)
}

plotISD <- function(isdFiles, statFile, outputFile) {
    pdf(outputFile,paper="letter",width=8,height=10)
    on.exit(dev.off(),add=T)
    layoutMatrix = matrix(c(matrix(1:10,ncol=2,byrow=T),matrix(11:20,ncol=2,byrow=T)),ncol=4)
    layoutMatrix = matrix(1:20,ncol=4,byrow=T)
    layout(layoutMatrix)
    on.exit(layout(matrix(1)),add=T)
    marSave = par("mar")
    on.exit(par(mar=marSave),add=T)

    plotCex = 0.7
    par(mar=c(5,4,1,1))
    statData = read.table(statFile, sep="\t", header=T, stringsAsFactors=F)
    for (isdFile in isdFiles) {
        isdData = read.table(isdFile, sep="\t", header=T, stringsAsFactors=F)
        readGroupPaths = unique(isdData[,1:3])
        if (nrow(readGroupPaths) > 0) {
            for (i in 1:nrow(readGroupPaths)) {
                readGroupPath = as.vector(readGroupPaths[i,]);
                isdPathData = isdData[isdData[,1] == readGroupPath[[1]] &
                                      (is.na(readGroupPath[[2]]) | isdData[,2] == readGroupPath[[2]]) &
                                      (is.na(readGroupPath[[3]]) | isdData[,3] == readGroupPath[[3]]),]
                statPathData = statData[statData[,1] == readGroupPath[[1]] &
                                        (is.na(readGroupPath[[2]]) | statData[,2] == readGroupPath[[2]]) &
                                        (is.na(readGroupPath[[3]]) | statData[,3] == readGroupPath[[3]]),]
                normalizedCounts = isdPathData$COUNT / sum(isdPathData$COUNT)
                npairs = statPathData$NPAIRS
                med = statPathData$MEDIAN
                rsd = statPathData$RSD
                legendText = c(getPathText(readGroupPath),
                               sprintf("N=%d", npairs),
                               sprintf("%d +/- %1.1f", med, rsd))
                if (npairs == 0) {
                    xlim = c(0,1)
                    ylim = c(0,1)
                    plot(c(), c(), type="l", xlim=xlim, ylim=ylim,
                         xlab=NA, ylab=NA, cex.axis=plotCex)
                    legend("topright", legend=legendText, bty="n", cex=plotCex)
                    title(xlab="Insert size", line=2, cex.lab=plotCex)
                    title(ylab="Density", line=2, cex.lab=plotCex)
                    plot(c(), c(), type="l", xlim=xlim, ylim=ylim,
                         xlab=NA, ylab=NA, cex.axis=plotCex)
                    legend("topright", legend=legendText, bty="n", cex=plotCex)
                    title(xlab="Insert size", line=2, cex.lab=plotCex)
                    title(ylab="Density", line=2, cex.lab=plotCex)
                } else {
                    xlim = c(0, 3*med)
                    plot(isdPathData$ISIZE, normalizedCounts, type="l", xlim=xlim,
                         xlab=NA, ylab=NA, cex.axis=plotCex)
                    legend("topright", legend=legendText, bty="n", cex=plotCex)
                    title(xlab="Insert size", line=2, cex.lab=plotCex)
                    title(ylab="Density", line=2, cex.lab=plotCex)
                    ylim = c(0,1/(100*rsd))
                    plot(isdPathData$ISIZE, normalizedCounts, type="l", xlim=xlim, ylim=ylim,
                         xlab=NA, ylab=NA, cex.axis=plotCex)
                    legend("topright", legend=legendText, bty="n", cex=plotCex)
                    title(xlab="Insert size", line=2, cex.lab=plotCex)
                    title(ylab="Density", line=2, cex.lab=plotCex)
                }
            }
        }
    }
}

getPathText <- function(readGroupPath) {
    return(readGroupPath[!is.na(readGroupPath)])
}

main()
