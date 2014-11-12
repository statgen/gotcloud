
# Globals

cmdArguments = NULL
cmdErrorCount = 0
partitionMap = NULL

# Loaded partition state

current.partition <- NULL
current.genotype.data <- NULL
current.confidence.data <- NULL
current.coverage.data <- NULL
current.count.data <- NULL
current.expected.data <- NULL
current.pair.data <- NULL
current.model.data <- NULL
current.truth.data <- NULL


main <- function() {
    cmdArguments <<- parseProgramArguments()
    siteList = if (is.null(cmdArguments$site)) NULL else unlist(strsplit(cmdArguments$site, ","))
    outputFile = if (is.null(cmdArguments$outputFile)) cmdArguments$O else cmdArguments$outputFile
    if (is.null(cmdArguments$site) || is.null(outputFile)) {
        cat("Usage: plot_cnps [options]\n")
        cat("Options:\n")
        cat(" --site siteList            List of site IDs to plot [required].\n")
        cat(" --outputFile file          Output file name [required].\n")
        cat(" --outputFileFormat format  Output file type (PDF or PNG) [optional, default PDF].\n")
        cat(" --auxFilePrefix string     Path prefix to auxilliary data files generated during genotyping [optional].\n")
        cat(" --runDirectory dir         Run directory containing auxilliary output files from genotyping [optional].\n")
        cat(" --partitionMapFile file    Map file specifying the partition for each site [optional].\n")
        cat(" --genderMapFile file       Map file providing the gender of each sample [optional].\n")
        cat(" --truthDataFile file       File containing truth data genotypes [optional].\n")
        cat(" --debug true/false         Enable debug output [optional, default false].\n")
        cat(" --verbose true/false       Enable verbose output [optional, default false].\n")
        cat(" --pretty true/false        Produce prettier plots but with less detail [optional, default false].\n")
        q(save="no", status=1)
    }
    plotCnps(siteList, outputFile)
    if (cmdErrorCount > 0) {
        q(save="no", status=1)
    }
}

plotCnps <- function(siteList, outputFile) {
    outputFormat = cmdArguments$outputFileFormat
    if (is.null(outputFormat) || outputFormat == "PDF") {
        if (length(siteList) == 1) {
            pdf(outputFile, width=8, height=5)
            on.exit(dev.off(),add=T)
        } else {
            pdf(outputFile, width=8, height=10)
            on.exit(dev.off(),add=T)
            layout(matrix(1:2,2,1))
            on.exit(layout(1),add=T)
        }
    } else if (outputFormat == "PNG") {
        if (length(siteList) != 1) {
            reportFatalError("Output type PNG can only be used with a single site")
        }
        png(outputFile, width=8, height=5, units="in", res=300)
        on.exit(dev.off(),add=T)
    } else {
        reportFatalError(paste("Unrecognized outputFileFormat:", outputFormat, collapse=" "))
    }
    plotSites(siteList)
}

plotSites <- function(siteList, threshold=1.3, ymax=NULL, impMethod=NULL) {
    gender.data <- loadGenderMap()
    current.truth.data <<- loadTruthData()
    for (cnp in siteList) {
        loadCnpData(cnp)
        if (is.null(current.partition) || ! (cnp %in% rownames(current.genotype.data))) {
            #cmdErrorCount <<- cmdErrorCount + 1
            cat(sprintf("Warning: No data found for site %s\n", cnp))
            next
        }
        if (asBoolean(cmdArguments$verbose)) {
            cat(sprintf("Plotting site %s ...\n", cnp))
        }
        plotCnpInternal(cnp,
                        current.coverage.data[cnp,],
                        current.count.data[cnp,],
                        current.expected.data[cnp,],
                        current.genotype.data[cnp,],
                        current.confidence.data[cnp,],
                        current.pair.data[cnp,],
                        loadModel(current.model.data[cnp,]),
                        current.model.data[cnp,],
                        current.truth.data[cnp,],
                        gender.data,
                        threshold=threshold,
                        ymax=ymax)
    }
}

plotCnpInternal <- function(cnp, coverage.data, count.data, expected.data, genotype.data, confidence.data, pair.data, model, norm.data, truth.data, gender.data=NULL, threshold=NULL, ymax=NULL) {
    # genotype.data is *our* genotype calls
    # optionally, we can take in gold standard reference calls and display those as well
    # make sure we plot cna genotypes (e.g. light blue)
    # model will be loaded from .gmm.dat file

    pretty <- asBoolean(cmdArguments$pretty)
    plot.legend <- TRUE
    if (pretty) {
        plot.legend <- FALSE
    }
    break.width <- 0.05
    cn.colors <- c("green", "orange", "blue", "red", "pink", "yellow", "purple")
    if (pretty) {
        cn.colors <- c("green", "orange", "blue", "red", "pink", "yellow", "purple", "darkgreen", "lightblue", "yellow3", "red3", "steelblue", "green3", "pink3", "brown", "blue3")
    }
    cna.color <- "lightgray"

    samples <- getSamples(genotype.data)

    expdata <- NULL
    if (cnp %in% rownames(coverage.data)) {
        covdata <- asNumericInf(coverage.data[cnp,samples])
    } else {
        expdata <- asNumericInf(expected.data[cnp,samples])
        covdata <- as.numeric(count.data[cnp,samples])/asNumericInf(expected.data[cnp,samples])
    }
    names(covdata) <- samples
    gtdata <- as.numeric(genotype.data[cnp,samples])
    names(gtdata) <- samples

    if (!is.null(threshold) && !is.null(confidence.data)) {
        confdata <- as.numeric(t(confidence.data[cnp,samples]))
        gtdata[confdata < threshold] <- NA
    }

    cnmax <- max(c(2,gtdata), na.rm=T)
    dmax <- ceiling(max(c(0,covdata[is.finite(covdata)]))+0.5)
    breaks <- seq(0,dmax,break.width)
    nbreaks <- length(breaks)

    hdata <- c()
    for (cn in 0:cnmax) {
        cnx <- covdata[!is.na(gtdata) & gtdata == cn]
        hn <- makeHist(seq(0,nbreaks,1), 0, cnx, round(cnx/break.width), length)
        hdata <- c(hdata, hn, 0)
    }
    cna <- covdata[is.na(gtdata)]
    names(cna) <- samples[is.na(gtdata)]
    hn <- makeHist(seq(0,nbreaks,1), 0, cna, round(cna/break.width), length)
    hdata <- c(hdata, hn, 0)
    mat <- matrix(hdata, nrow=cnmax+2, byrow=TRUE)
    mat.height <- max(apply(mat,2,sum))

    cnp.length <- pmax(0, genotype.data$RIGHTSTART - genotype.data$LEFTEND + 1)

    ncalls <- sum(!is.na(gtdata))
    call.rate <- ncalls / length(gtdata)
    ncalls <- sum(mat[1:3,])
    nnonref <- 2*sum(mat[1,]) + sum(mat[2,])
    if (cnmax >= 3) {
        ncalls <- ncalls + sum(mat[4,])
        nnonref <- nnonref + sum(mat[4,])
        if (cnmax >= 4) {
            ncalls <- ncalls + sum(mat[5,])
            nnonref <- nnonref + 2*sum(mat[5,])
        }
    }
    maf <- ifelse(ncalls == 0, NA, nnonref/(2*ncalls))

    title1 <- sprintf("%s", cnp)
    if (!is.null(truth.data) && ("ALT" %in% names(truth.data))) {
        title1 <- sprintf("%s / %s", title1, truth.data$ALT)
    }
    title2 <- sprintf("chr%s %d-%d",
                      genotype.data$CHR,
                      genotype.data$LEFTEND + 1,
                      genotype.data$RIGHTSTART - 1);
    if (cnp.length >= 1000) {
        title2 <- sprintf("%s %1.1fKb", title2, cnp.length/1000)
    } else {
        title2 <- sprintf("%s %db", title2, cnp.length)
    }
    #bkpt.id <- get_breakpoint_id(cnp)
    #if (!is.null(bkpt.id)) {
    #    title2 <- sprintf("%s %s", title2, bkpt.id)
    #}
    if (is.null(threshold)) {
        title3 <- "LOD: none"
    } else {
        title3 <- sprintf("LOD: %1.1f",  threshold)
    }
    title3 <- sprintf("%s CR: %1.1f%%", title3, call.rate * 100)
    if (!is.null(truth.data)) {
        truth.samples <- intersect(samples, names(truth.data))
        truth <- truth.data[truth.samples]
        gtcalls <- gtdata[truth.samples]
        miscalls <- sum(!is.na(gtcalls) & !is.na(truth) & gtcalls != truth)
        denom <- sum(!is.na(gtcalls) & !is.na(truth))
        if (denom > 0) {
            accuracy <- 1 - (miscalls / denom)
            title3 <- sprintf("%s ACC: %1.1f%%", title3, accuracy * 100)
        } else {
            title3 <- sprintf("%s ACC: NA", title3)
        }
        if (sum(!is.na(gtcalls) & !is.na(truth)) > 0) {
            denom2 <- sum(!is.na(gtcalls) & !is.na(truth) & (gtcalls != 2 | truth != 2))
            discord.rate <- ifelse(denom2 == 0, 0, miscalls/denom2)
            title3 <- sprintf("%s DR: %1.1f%%", title3, discord.rate * 100)
        } else {
            title3 <- sprintf("%s DR: NA", title3)
        }
    }
    title4 <- sprintf("MAF: %1.2f", maf)
    if (!is.null(norm.data)) {
        eff.length <- NULL
        if ("ELENGTH" %in% names(norm.data)) {
            eff.length <- norm.data[cnp,]$ELENGTH
        } else if ("ELENGTH" %in% names(norm.data)) {
            eff.length <- norm.data[cnp,]$EFFECTIVE_LENGTH
        }
        if (!is.null(eff.length)) {
            eff.fraction <- eff.length / cnp.length
            if (eff.length > 1000) {
                title4 <- sprintf("%s EL: %1.1fKb", title4, eff.length/1000)
            } else {
                title4 <- sprintf("%s EL: %db", title4, eff.length)
            }
            title4 <- sprintf("%s %1.1f%%", title4, eff.fraction*100)
        }
    }

    if (is.null(ymax)) {
        ymax <- mat.height
    }
    bar.colors <- c(cn.colors[1:pmin(cnmax+1,length(cn.colors))])
    if (length(bar.colors) < cnmax + 1) {
        bar.colors <- c(bar.colors, rep(bar.colors[length(bar.colors)], cnmax + 1 - length(bar.colors)))
    }
    bar.colors <- c(bar.colors, cna.color)
    ### hack to show only truth data
    ### bar.colors <- rep(cna.color, length(bar.colors))
    titles <- c(title1, title2, title3, title4)
    if (pretty) {
        titles <- c(title1, title2)
    }
    barplot(mat, space=0, col=bar.colors,
            ylim=c(0,pmin(pmax(1,mat.height),ymax)),
            xlab="normalized read depth", ylab="samples",
            main=titles)

    plot.x.scale = 1/break.width

    if (pretty && !is.null(model) && !is.na(model$NCLUSTERS)) {
        m1 = model$MEANS[2]
        dseq = seq(0, dmax, 1)
        axis(1, at=0.5+plot.x.scale*m1*dseq, labels=dseq)
    } else {
        axis(1,at=0.5+seq(0,dmax/break.width,1/break.width),labels=seq(0,dmax,1))
    }

    if (plot.legend) {
        legend("topright",
               fill=c(cn.colors,cna.color),
               legend=c(sprintf("CN%d", 0:(length(cn.colors)-2)),
                        sprintf("CN%d+", length(cn.colors)-1),
                        "NC"),
               inset=0.02, cex=0.8)
    }

    if (mat.height == 0) {
        return(NULL)
    }

    # build position map for samples in bar chart
    # order all samples by depth and genotype call and determine correct bin and offset
    # print(mat)
    colsums <- apply(mat,2,sum,na.rm=T)
    cumsums <- cumsum(colsums)
    b <- c(mapply(function(n) { rep(n, colsums[n]) }, 1:length(colsums)), recursive=T)
    s <- names(covdata)[order(covdata,na.last=T)]
    s <- setdiff(s,names(covdata)[is.na(covdata)])
    g <- gtdata[s]
    s <- s[order(b,g,na.last=T)]
    g <- gtdata[s]
    d <- covdata[s]
    offsets <- 1:length(b) - c(0,head(cumsums,-1))[b]
    bin.data <- data.frame(d=d,g=g,b=b,off=offsets)
    rownames(bin.data) <- s

    # print(d)
    # print(b)
    # print(l)
    # print(cumsums)
    # print(offsets)
    # print(length(d))
    # print(length(l))
    # print(length(b))
    # print(length(offsets))

    if (!is.null(truth.data)) {
        truth.colors <- sapply(rownames(bin.data),
                               function(sample) { v <- truth.data[cnp,sample];
                                                  if (is.null(v) || is.na(v)) {
                                                      return(NA)
                                                      #return(cna.color)
                                                  } else if (v > length(cn.colors)) {
                                                      return(cn.colors[length(cn.colors)])
                                                  } else {
                                                      return(cn.colors[v+1])
                                                  }})
        xvals <- bin.data$b[!is.null(truth.colors)]-0.5
        yvals <- bin.data$off[!is.null(truth.colors)]-0.3
        col <- truth.colors[!is.null(truth.colors)]
        points(xvals, yvals, pch=21, col=col, bg=col)
    }

    if (any(genotype.data$CHR %in% c("X", "Y", "chrX", "chrY")) && !is.null(gender.data)) {
        sample.genders <- gender.data[rownames(bin.data)]
        gender.colors <- c("lightblue3", "darkred")[sample.genders]
        xvals <- bin.data$b-0.5
        yvals <- bin.data$off-0.6
        points(xvals, yvals, pch=22, col=gender.colors, bg=gender.colors, cex=0.8)
    }

    if (!is.null(pair.data)) {
        # for all > 0, plot the pair count at the correct depth bin and offset
        pair.counts <- sapply(rownames(bin.data),
                              function(sample) { v <- pair.data[cnp,sample]; ifelse(is.null(v),NA,v) })
        xvals <- bin.data$b[pair.counts > 0]-0.5
        yvals <- bin.data$off[pair.counts > 0]-1
        labels <- pair.counts[pair.counts > 0]
        if (length(labels) > 0) {
            text(xvals,yvals,pos=3,labels=labels,font=2,cex=0.8)
        }
    }

    if (!is.null(model) && !is.na(model$NCLUSTERS) && !pretty) {
        # plot model curves and dashed vertical lines at the means
        variance.factor = mean(expdata, na.rm=T)
        # print(c("weights",model$WEIGHTS))
        # print(c("means",model$MEANS))
        # print(c("variances",model$VARIANCES))
        # print(c("std",sqrt(model$VARIANCES)))
        # print(c("vfactor", variance.factor))
        mapply(function (m,s,n) {
                   yscale <- n/plot.x.scale
                   range <- seq(m-4*s, m+4*s, length.out=100)
                   lines(0.5+plot.x.scale*range,yscale*dnorm(range,m,s),col="black", lwd=2.5)
                   plotVertLine(0.5+plot.x.scale*m,col="black",lty="dashed")
               },
               model$MEANS,
               sqrt(model$VARIANCES/variance.factor),
               model$WEIGHTS*length(samples))
    }
}

makeHist <- function(domain, value, data, idx, func) {
    result <- rep(value, length(domain))
    names(result) <- domain
    tapply.result <- tapply(data, idx, func)
    result[names(tapply.result)] <- tapply.result
    # remove NaNs from the input data
    result <- result[!(names(result) %in% "NaN")]
    return(result)
}

asNumericInf <- function(v) {
    v[v == "Infinity"] <- Inf
    v[v == "-Infinity"] <- -Inf
    return(as.numeric(v))
}

plotHorizLine <- function(coord, color="black", lty="solid") {
    width <- 2
    if (names(dev.cur()) == "pdf") {
        width <- 1
    }
    lines(par("usr")[1:2],rep(coord,2),col=color,lwd=width,lty=lty)
}

plotVertLine <- function(coord, color="black", lty="solid") {
    width <- 2
    if (names(dev.cur()) == "pdf") {
        width <- 1
    }
    lines(rep(coord,2),par("usr")[3:4],col=color,lwd=width,lty=lty)
}

loadModel <- function(modelData) {
    if (is.na(modelData$NCLUSTERS)) {
        return(NULL)
    }
    if ("WEIGHTS" %in% names(modelData)) {
        weights = as.numeric(strsplit(modelData$WEIGHTS,",")[[1]])
    } else {
        # old style, now should be obsolete
        weights = as.numeric(strsplit(modelData$PRIORS,",")[[1]])
    }
    means = as.numeric(strsplit(modelData$MEANS,",")[[1]])
    variances = as.numeric(strsplit(modelData$VARIANCES,",")[[1]])
    model = list(NCLUSTERS=modelData$NCLUSTERS,
                 LOGLIKELIHOOD=modelData$LOGLIKELIHOOD,
                 WEIGHTS=weights,
                 MEANS=means,
                 VARIANCES=variances)
    return(model)
}

loadCnpData <- function(cnp) {
    partition = getCnpPartition(cnp)
    if (!is.null(partition) && (is.null(current.partition) || partition != current.partition)) {
        loadPartition(partition)
    }
}

getCnpPartition <- function(cnp) {
    partition = cmdArguments$auxFilePrefix
    if (is.null(partition)) {
        if (is.null(partitionMap) && !is.null(cmdArguments$partitionMapFile)) {
            partitionMap <<- loadPartitionMap(cmdArguments$partitionMapFile)
        }
        if (!is.null(partitionMap)) {
            partitionId = partitionMap[cnp,"PARTITION"]
            if (!is.null(partitionId) && !is.na(partitionId) && !is.null(cmdArguments$runDirectory)) {
                partition = sprintf("%s/%s", cmdArguments$runDirectory, partitionId)
            }
        }
    }
    return(partition)
}

loadPartitionMap <- function(partitionMapFile) {
    return(read.table(partitionMapFile, sep="\t", header=T, stringsAsFactors=F, row.names=1))
}

loadPartition <- function(partition) {
    if ((is.null(current.partition) && !is.null(partition)) || is.null(partition) || (partition != current.partition)) {
        if (asBoolean(cmdArguments$debug)) {
            cat(sprintf("Loading data for partition %s ...\n", partition))
        }
        current.partition <<- NULL
        if (!file.exists(sprintf("%s%s", partition, ".genotypes.gts.dat"))) {
            cat(sprintf("Data file not found: %s%s\n", partition, ".genotypes.gts.dat"))
            return()
        }
        current.genotype.data <<- loadDataFile(partition, ".genotypes.gts.dat")
        current.confidence.data <<- loadDataFile(partition, ".genotypes.conf.dat")
        # obsolete
        #current.coverage.data <<- loadDataFile(partition, ".genotypes.coverage.dat")
        current.count.data <<- loadDataFile(partition, ".genotypes.counts.dat")
        current.expected.data <<- loadDataFile(partition, ".genotypes.expected.dat")
        current.pair.data <<- loadDataFile(partition, ".genotypes.paircounts.dat")
        current.model.data <<- loadDataFile(partition, ".genotypes.gmm.dat")
        if (is.null(cmdArguments$truthDataFile)) {
            current.truth.data <<- loadDataFile(partition, ".genotypes.truth.dat")
        }
        current.partition <<- partition
    }
}

loadDataFile <- function(partition, suffix) {
    file <- sprintf("%s%s", partition, suffix)
    if (!file.exists(file)) {
        return(NULL)
    }
    return(read.table(file, sep="\t", header=T, row.names=1, stringsAsFactors=F))
}

loadTruthData <- function() {
    if (is.null(cmdArguments$truthDataFile)) {
        return(NULL)
    }
    file.data = read.table(cmdArguments$truthDataFile, sep="\t", header=T, row.names=1, stringsAsFactors=F)
    return(file.data)
}

loadGenderMap <- function() {
    if (is.null(cmdArguments$genderMapFile)) {
        return(NULL)
    }
    file.data = read.table(cmdArguments$genderMapFile, sep="\t", stringsAsFactors=F)
    if ("SAMPLE" %in% names(file.data) && "GENDER" %in% names(file.data)) {
        gender.data = file.data$GENDER
        names(gender.data) = file.data$SAMPLE
    } else {
        gender.data = file.data[[2]]
        names(gender.data) = file.data[[1]]
    }
    gender.data[toupper(substr(gender.data,1,1)) %in% c("M","1")] = 1
    gender.data[toupper(substr(gender.data,1,1)) %in% c("F","2")] = 2
    gender.map = as.numeric(gender.data)
    names(gender.map) = names(gender.data)
    return(gender.map)
}

getSamples <- function(genotype.data) {
    samples = names(genotype.data)[6:length(genotype.data)]
    return(samples)
}

reportFatalError <- function(message) {
    cat(sprintf("ERROR\t%s\n", message, file=stderr()))
    q(save="no", status=1)
}

parseProgramArguments <- function() {
    result = list()
    positional = list()
    result[[""]] = positional
    args = commandArgs()
    if (length(args) == 0) {
        return(result)
    }
    for (i in 1:length(args)) {
        if (i == length(args)) {
            return(result)
        } else if (args[i] == "--args") {
            argpos = i+1
            break
        }
    }
    while (argpos <= length(args)) {
        arg = args[argpos]
        argpos = argpos + 1
        keyword = NULL
        if (nchar(arg) > 2 && substr(arg,1,2) == "--") {
            keyword = substr(arg,3,nchar(arg))
        } else if (nchar(arg) > 1 && substr(arg,1,1) == "-") {
            keyword = substr(arg,2,nchar(arg))
        } else {
            positional = c(positional, arg)
        }
        #cat(sprintf("pos %d kw %s arg %s\n", argpos, keyword, args[argpos]))
        if (!is.null(keyword) && argpos <= length(args)) {
            result[[as.character(keyword)]] = args[[argpos]]
            argpos = argpos + 1
        }
    }
    result[[1]] = positional
    return(result)
}

asBoolean <- function(arg) {
    if (is.null(arg)) {
        return(FALSE)
    }
    if (is.na(arg)) {
        return(FALSE)
    }
    if (is.logical(arg)) {
        return(arg)
    }
    return(arg == "true")
}

main()
