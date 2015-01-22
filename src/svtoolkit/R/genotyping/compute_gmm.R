
debug <- FALSE
parityThreshold <- 0

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

    while (TRUE) {
        if (args[1] == "-debug") {
            debug <<- TRUE
            args <- args[2:length(args)]
        } else if (args[1] == "-parityThreshold") {
            parityThreshold <<- as.numeric(args[2])
            args <- args[3:length(args)]
        } else {
            break
        }
    }

    if (length(args) < 2 || length(args) > 3) {
        cat("Usage: compute_gmm cnpId dataFile [maxClusters]\n")
        cat("  dataFile should contain <sample> <read-count> <expected-read-count>\n")
        q(save="no", status=1)
    }

    cnpId <- args[1]
    dataFile <- args[2]
    maxClusters <- 3
    if (length(args) > 2) {
        maxClusters <- as.integer(args[3])
    }
    model <- compute_mixture_model(cnpId, dataFile, maxClusters)
    if (is.null(model)) {
        cat("NULL\n")
    } else {
        cat(sprintf("%d %f\n", model$clusters, model$loglik))
        cat(paste(model$weights), "\n")
        cat(paste(model$means), "\n")
        cat(paste(model$variances), "\n")
    }
}

compute_mixture_model <- function(cnpId, dataFile, nClusters) {
    data <- read.table(dataFile, sep="\t", header=F, row.names=1, stringsAsFactors=FALSE)
    bestModel <- NULL
    for (mscale in c(seq(0.9,1.1,0.1))) {
        model <- gmm(data[[1]], data[[2]], mscale, nClusters)
        if (debug) {
            cat(sprintf("mscale: %1.1f loglik: %f weights: %s\n", mscale, model$loglik, paste(model$weights, collapse=" ")))
        }
        if (is.null(bestModel) || model$loglik > bestModel$loglik) {
            bestModel <- model
        }
    }
    return(bestModel)
}

gmm <- function(data, expected, mscale=1.0, M=3) {

    loglik_threshold <- 1e-4
    cn0_variance <- 0.2
    min_m1 <- 0.001
    min_m2 <- 0.001
    min_iter <- 10
    max_iter <- 100
    max_resets <- 5
    min_weight_factor <- 0.1

    ok <- is.finite(data) & is.finite(expected) & expected > 0
    data <- data[ok]
    expected <- expected[ok]

    if (debug) {
        cat(sprintf("observed: %s\n", paste(data, collapse=" ")))
        cat(sprintf("expected: %s\n", paste(expected, collapse=" ")))
    }

    N <- length(data)
    if (N == 0 || all(data == 0)) {
        return(NULL)
    }

    mc <- seq(0,M-1,1)
    vc <- c(cn0_variance, seq(1,M-1,1))
    weights <- rep(1/M,M)
    means <- mc * mscale
    variances <- vc * mscale

    loglik <- -Inf
    old_loglik <- -Inf
    delta_loglik <- NA
    iterations <- 0
    reset_count <- 0

    if (debug) {
        cat(sprintf("iteration %d m1: %g m2: %g vc: %s weights: %s means: %s variances: %s\n",
                    iterations, means[2], variances[2],
                    paste(sprintf("%g", vc), collapse=" "),
                    paste(sprintf("%g", weights), collapse=" "),
                    paste(sprintf("%g", means), collapse=" "),
                    paste(sprintf("%g", variances), collapse=" ")))
    }

    while ((iterations < min_iter) ||
           ((iterations < max_iter) && (is.na(delta_loglik) || (delta_loglik > loglik_threshold)))) {

        model <- estep(data, expected, weights, means, variances)
        loglik <- model$loglik
        z <- model$z
        if (model$reset) {
            old_loglik <- -Inf
            delta_loglik <- NA
            reset_count <- reset_count + 1
            if (reset_count < max_resets) {
                iterations <- pmax(0, iterations - min_iter)
            }
        }

        weights <- apply(z, 2, mean)
        weights <- rebalanceWeights(weights, min_weight_factor * (1/N))

        mcvec <- rep(mc, each=N)
        vcvec <- rep(vc, each=N)
        m1 <- pmax(min_m1, sum( (z * data * mcvec) / vcvec ) / sum( (z * mcvec * mcvec * expected) / vcvec ))
        m1 <- if (is.na(m1)) min_m1 else m1
        means <- mc * m1

        m2 <- pmax(min_m2, sum(z * (rep(data,M) - outer(expected,means))^2 / (expected*vcvec)) / sum(z))
        m2 <- if (is.na(m2)) min_m2 else m2
        variances <- vc * m2

        if (old_loglik != -Inf) {
            delta_loglik <- loglik - old_loglik
        }
        iterations <- iterations + 1

        if (!is.na(delta_loglik) && delta_loglik < -loglik_threshold) {
            message <- sprintf("EM loop failed to converge: iteration %d ll %g previous %g delta %g",
                               iterations, loglik, old_loglik, delta_loglik)
            if (debug) {
                warning(message)
            } else {
                # We fail to converge uniformly sometimes,
                # but as near as I can tell, this is due to underflow near zero in the loglik calculation
                # which creates the appearance of local maxima, but the EM loop is still, in fact,
                # converging to a global maximum.
                # stop(message)
            }
        }

        if (debug) {
            cat(sprintf("iteration %d ll: %g delta: %g\n", iterations, loglik, delta_loglik))
            cat(sprintf("iteration %d m1: %g m2: %g vc: %s weights: %s means: %s variances: %s\n",
                        iterations, m1, m2,
                        paste(sprintf("%g", vc), collapse=" "),
                        paste(sprintf("%g", weights), collapse=" "),
                        paste(sprintf("%g", means), collapse=" "),
                        paste(sprintf("%g", variances), collapse=" ")))
        }

        old_loglik <- loglik
    }

    if (debug) {
        cat(sprintf("iterations: %d\n", iterations))
        warnings()
    }

    return(list(clusters=M,
                loglik=loglik,
                weights=weights,
                means=means,
                variances=variances))
}

rebalanceWeights <- function(weights, minWeight) {
    topCluster = max(c(1,which(weights > minWeight)))
    weights[1:topCluster] = pmax(weights[1:topCluster], rep(minWeight, topCluster))
    weights = weights/sum(weights)
    return(weights)
}

estep <- function(data, expected, weights, means, variances) {

    EPSILON <- 10^-323

    z <- matrix(nrow=length(data), ncol=length(weights))
    for (i in 1:length(data)) {
        for (j in 1:length(weights)) {
            z[i,j] <- weights[j]*dnorm(data[i],expected[i]*means[j],sqrt(expected[i]*variances[j]))
        }
    }

    if (debug) {
        # print(z)
        # print(apply(z,1,sum,na.rm=TRUE))
    }

    reset <- FALSE
    loglik <- sum(log(pmax(apply(z,1,sum,na.rm=TRUE),EPSILON)))
    z <- z/apply(z,1,sum,na.rm=TRUE)
    if (any(is.nan(z))) {
        # for samples not assigned to any cluster, reset to uniform expectation
        z[is.nan(z)] <- 1/ncol(z)
        if (debug) {
            cat(sprintf("correcting z %d %f ...\n", nrow(z), sum(z)))
        }
        if (abs(sum(z) - nrow(z)) > 1e-4) {
            stop(sprintf("EM estep failed correction: %d %f\n", nrow(z), sum(z)))
        }
        reset <- TRUE
        loglik <- -Inf
    }

    if (debug) {
        # print(z)
    }

    # Check for fitting a single gaussian and force it to be CN2
    assignments <- c(apply(z,1,order,decreasing=TRUE)[1,])-1
    if (debug) {
        assignmentSummary = sapply(0:(ncol(z)-1), function(cn) { sum(assignments == cn) })
        cat(sprintf("assignments: %s\n", paste(assignmentSummary, collapse=" ")))
    }
    if (ncol(z) == 3 && all(assignments == 1)) {
        if (debug) {
            cat(sprintf("Changing monomorphic CN1 model to CN2 ...\n"))
            # print(z)
        }
        z[,2:3] <- z[,3:2]
        reset <- TRUE
        loglik <- -Inf
    }

    if (parityThreshold > 0) {
        M = ncol(z)
        parity = sum(apply(z,2,sum,na.rm=TRUE)[seq(1, M, 2)]) / sum(z,na.rm=T)
        if (debug) {
            # REMOVE ME
            cat(sprintf("#DBGCOMP_EXTERNAL: parity = %f, threshold = %f\n", parity, parityThreshold))
            print(c("pptest", parity, parityThreshold, parity < parityThreshold))
        }
        if (parity < parityThreshold) {
            if (debug) {
                # REMOVE ME
                cat(sprintf("#DBGMISC_EXTERNAL: In parity correction\n"))
            }
            assignmentSummary = sapply(0:(ncol(z)-1), function(cn) { sum(assignments == cn) })
            cm = sum(assignmentSummary * means) / sum(assignmentSummary)
            m1 = means[2]
            adj = cm/2 - round(cm/2)
            corrected = FALSE
            if (debug) {
                # REMOVE ME
                cat(sprintf("#DBGPARITY_EXT: cm = %f, m1 = %f, adj = %f\n", cm, m1, adj))
            }
            if (m1 < 0.75 || (adj >= 0 && m1 <= 1.25)) {
                if (debug) {
                    cat(sprintf("Correcting parity %f (shift down, cm = %f) ...\n", parity, cm));
                }
                shiftColumn = 1
                z[,1:(M-1)] = z[,2:M]
                z[,M] = 0
                corrected = TRUE
            } else if (m1 > 1.25 || (adj < 0 && m1 >= 0.75)) {
                if (debug) {
                    cat(sprintf("Correcting parity %f (shift up, cm = %f) ...\n", parity, cm));
                }
                shiftColumn = M
                z[,2:M] = z[,1:(M-1)]
                z[,1] = 0
                corrected = TRUE
            } else {
                if (debug) {
                    cat(sprintf("Not correcting parity %f (m1 = %f, cm = %f) ...\n", parity, m1, cm));
                }
            }
            if (corrected) {
                rowsums = apply(z,1,sum)
                z[rowsums == 0, shiftColumn] = 1
                rowsums[rowsums == 0] = 1
                z = z/rowsums
                reset <- TRUE
                loglik <- -Inf
            }
        }
    }

    return(list(loglik=loglik,z=z,reset=reset))
}

main()
