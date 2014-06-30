Mhplot = setRefClass(
    "Mhplot",
    fields = list(
    chr="numeric",
    snp="character",
    bp="numeric",
    pvals="numeric",
    nsnp="numeric",
    mlogp="numeric",
    nchr="numeric",
    chrunique="numeric",
    # apperant chr, see function below
    achr="numeric",
    # base-pair position scaled within chr
    sbp="numeric",
    # todo: base-pair position scaled to real length of chromosome!
    colorvec="ANY"
    )
)

Mhplot$methods(
    # apparent chr number
    # e.g. chr(1, 1, 4, 4, 5, 5, 7, 7) ==> chr(1, 1, 2, 2, 3, 3, 4, 4)
    # usefu for plotting
    appChr = function() {
        achr <<- rep(0, nchr)
        for(i in chrunique) {
            achr <<- achr + (chr >= i)
        }
    }
)

Mhplot$methods(
    # sort out the chr stuf, scale by each chr
    # notice I used the apparent chr here
    scaleByChr = function() {
        allchrScaledPos = rep(NA, nsnp)
        for (chrI in chrunique) {
            chrcheck = (chrI == chr)
            chrNsnp = sum(chrcheck)
            firstPos = bp[which(chrcheck)[1]]
            firstPos = rep(firstPos, chrNsnp)
            posDiff = bp[chrcheck] - firstPos
            # make sure it's scaled to the range (0, 1)
            scaledPos = posDiff / (posDiff[chrNsnp] + 0.5)
            allchrScaledPos[chrcheck] = scaledPos
        }
        ## allchrScaledPos = allchrScaledPos * 0.8
        sbp <<- achr + allchrScaledPos
    }
)

Mhplot$methods(
    getdf = function() {
        df = data.frame(chr, achr, bp, sbp, mlogp)
        if(length(colorvec) > 1) {
            df$colorvec = colorvec
        }
        if(length(snp) > 1) {
            df$snp = snp
        }
        df
    }
)

Mhplot$methods(
    getmhplot = function(annotation=NULL) {
        mydat = getdf()
        maxlogp = ceiling(max(mlogp, na.rm = TRUE))
        minlogp = min(mlogp, na.rm = TRUE)
        gwthresh = -log10(5e-8)

        # if there are more than one chr, then x axis should be labeled by scaled BP (sbp)
        # if there is only one chr, then x axis should be labeled by BP
        if(length(unique(chr)) > 1) {
            myplot = ggplot(mydat, aes(sbp, mlogp)) + xlab("CHR") +
                     scale_x_continuous(breaks=unique(achr),
                                        minor_breaks=NULL,
                                        labels=unique(chr))
        } else {
            myplot = ggplot(mydat, aes(bp, mlogp)) + xlab(paste("Position on CHR", chr[1]))
            chrColor = FALSE
        }


        if(!is.null(mydat$colorvec)) {
            myplot = myplot + geom_point(aes(color=factor(paste(colorvec, achr %% 2))), alpha=.6) +
                ## scale_color_manual(values=c("gray20", "gray50", "steelblue1", "steelblue4"), guide=FALSE)
                scale_color_discrete(name="")
        } else {
            myplot = myplot + geom_point(aes(color=factor(achr %% 2)), alpha=.6) +
                ## scale_color_manual(values = c("gray40", "gray50"), guide=FALSE)
                scale_color_discrete(guide=FALSE)
        }

        myplot = myplot +
            scale_y_continuous(limits=c(minlogp, maxlogp), minor_breaks=NULL) +
            geom_hline(yintercept=gwthresh, alpha=.5, color="blue") +
            ylab("-log P")

        # todo: annotation
        if(!is.null(annotation)) {
            if(snp == "0") {
                stop("You must initialize me with an vector of SNP names if you want to annotate!")
            } else {
            }
        }

        return(myplot)
    }
)

Mhplot$methods(
    qq = function() {
        o = mlogp[!is.na(mlogp)]
        o = sort(o, decreasing = TRUE)
        e = -log10(ppoints(length(o)))
        qqdat = data.frame(e, o)
        qqplot = ggplot(qqdat, aes(e, o)) + geom_point(alpha=.4) +
            xlab("Expected -log P") + ylab("Observed -log P") +
            geom_abline(intercept=0, slope=1, alpha=.3)
        qqplot
    }
)

Mhplot$methods(
    initialize = function(chrinit, bpinit, pvalsinit, snpinit="0", colorvec=NULL, plinkfile = NULL) {
        if(! is.null(plinkfile)) {
            plinkdat = readplinkout(plinkfile)
            chr <<- plinkdat$CHR
            bp <<- plinkdat$BP
            snp <<- plinkdat$SNP
            pvals <<- plinkdat$P
        } else {
            if(any(sort(chrinit) != chrinit)) {
                message("I will not sort CHR for you, since this might mess up with the other columns of your data!")
                stop("CHR must be in order (1,2,3...22, for example)!")
            }
            if(length(chrinit) != nsnp | length(pvalsinit) != nsnp) {
                stop("CHR, BP and P do not match in length!")
            }
            chr <<- chrinit
            bp <<-bpinit
            snp <<- snpinit
            pvals <<- pvalsinit
        }

        nsnp <<- length(bp)
        mlogp <<- -log10(pvals)
        nchr <<- length(chr)
        chrunique <<- unique(chr)
        appChr()
        scaleByChr()
        colorvec <<- colorvec
    }
)



## require(ggplot2)
## plinkplotObj = Mhplot("~/data/rs1exoseq/AgeSexSskn/ssknEx.assoc.linear")
## qqplot = plinkplotObj$qq()
## print(qqplot)
## ## plinkout = readplinkout("~/data/sskn_regions_from_fan/AgeSexRed/sskn_reg.assoc.logistic")
## ## plinkout = readplinkout("~/data/rs1exoseq/AgeSexSskn/ssknEx.assoc.linear")
## ## plinkout = plinkout[which(plinkout$CHR == 20), ]
## ## plinkout = plinkout[which(plinkout$CHR == 16), ]
## ## colorvec = sample(0:1, nrow(plinkout), replace=TRUE)
## ## plinkplotObj = Mhplot(plinkout$CHR, plinkout$BP, plinkout$P, colorvec=colorvec)
## ## plinkplotObj = Mhplot(plinkout$CHR, plinkout$BP, plinkout$P)
## ## plinkplot = plinkplotObj$getmhplot()
## ## print(plinkplot)
## qqplot = plinkplotObj$qq()
## print(qqplot)
