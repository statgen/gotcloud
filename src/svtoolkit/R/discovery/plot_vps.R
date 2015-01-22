
plotVariantsPerSamplePDF <- function(dataFile, outputFile) {
    pdf(outputFile, height=10, width=8)
    on.exit(dev.off(), add=T)
    plotVariantsPerSample(dataFile)
}

plotVariantsPerSample <- function(dataFile) {
    data = read.table(dataFile, header=T, stringsAsFactors=F, row.names=1)
    vpsData = data$VARIANTS
    names(vpsData) = rownames(data)
    singletonData = data$SINGLETONS
    names(singletonData) = rownames(data)
    sortedSamples = rownames(data)[order(vpsData)]
    madRange = 3.0
    med = median(vpsData)
    mad = mad(vpsData)
    threshold = med + madRange * mad
    lowThreshold = med - madRange * mad
    nSamples = length(vpsData)
    highSamples = sum(vpsData > threshold)
    lowSamples = sum(vpsData < lowThreshold)

    layout(matrix(1:3, nrow=3))
    on.exit(layout(matrix(1)), add=T)

    # TBD: also plot singletons

    colors = ifelse(vpsData[sortedSamples] > threshold, "darkgray", "blue")
    singletonColors = ifelse(vpsData[sortedSamples] > threshold, "darkgray", "darkred")
    ylim = c(0, 1.1*max(vpsData, na.rm=T))
    plot(1:length(sortedSamples), vpsData[sortedSamples], col=colors, ylim=ylim,
         main="Variants per sample", xlab="sample", ylab="variants", pch=18)
    points(1:length(sortedSamples), singletonData[sortedSamples], col=singletonColors, pch=18)
    legend("topleft", bty="n", col="white", lwd=1,
           legend=c(sprintf("VPS threshold (@%1.1f MAD): %1.1f + %1.1f * %1.1f = %1.1f", madRange, med, mad, madRange*mad, threshold),
                    sprintf("Filtered samples: %d of %d (%1.1f%%)", highSamples, nSamples, 100*(highSamples/nSamples)),
                    sprintf("Low samples: %d of %d (%1.1f%%)", lowSamples, nSamples, 100*(lowSamples/nSamples))))
    abline(h=threshold, col="darkgreen", lty="dashed")
    abline(h=lowThreshold, col="darkgreen", lty="dashed")

    # enlarge variants per sample
    ylim = c(pmax(0, lowThreshold-2*mad), threshold + 2*mad)
    plot(1:length(sortedSamples), vpsData[sortedSamples], col=colors, ylim=ylim,
         main="Variants per sample (enlarged)", xlab="sample", ylab="variants", pch=18)
    abline(h=threshold, col="darkgreen", lty="dashed")
    abline(h=lowThreshold, col="darkgreen", lty="dashed")

    # enlarge singletons per sample
    ylim = c(0, 1.5*max(singletonData[vpsData <= threshold], na.rm=T))
    plot(1:length(sortedSamples), singletonData[sortedSamples], col=singletonColors, ylim=ylim,
         main="Singletons per sample (enlarged)", xlab="sample", ylab="variants", pch=18)
}

args <- commandArgs(TRUE)

dataFile <- args[1]
pdfFile <- args[2]

plotVariantsPerSamplePDF(dataFile, pdfFile)
