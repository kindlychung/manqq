# TODO: Add comment
# 
# Author: kaiyin
###############################################################################


Mhplot = setRefClass(
		"Mhplot",
		fields = list(
				originalData = "data.frame",
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
			originalData$achr <<- rep(0, nchr)
			for(i in chrunique) {
				message(paste("Setting apparent chr (achr) for chromosome", i))
				originalData$achr <<- originalData$achr + (originalData$CHR >= i)
			}
		}
)


Mhplot$methods(
		# sort out the chr stuf, scale by each chr
		# notice I used the apparent chr here
		scaleByChr = function() {
			allchrScaledPos = rep(NA, nsnp)
			for (chrIter in chrunique) {
				message(paste("Checking chr ", chrIter, "..."))
				chrcheck = (chrIter == originalData$CHR)
				chrNsnp = sum(chrcheck)
				chrIdx = which(chrcheck)
				message(paste("Index of SNPs in chr ", chrIter, "(at head)"))
				print(head(chrIdx))
				message(paste("Index of SNPs in chr ", chrIter, "(at tail)"))
				print(tail(chrIdx))
				
				message(paste(chrNsnp, "SNPs in chr", chrIter))
				firstPos = originalData$BP[chrIdx[1]]
				message(paste("First BP in chr", chrIter, "is", firstPos))
				firstPos = rep(firstPos, chrNsnp)
				posDiff = originalData$BP[chrIdx] - firstPos
				message(paste("Relative BP in chr", chrIter, "is (at head)"))
				print(head(posDiff))
				message(paste("Relative BP in chr", chrIter, "is (at tail)"))
				print(tail(posDiff))
				
				# make sure it's scaled to the range (0, 1)
				scaledPos = posDiff / (posDiff[chrNsnp] + 0.5)
				message(paste("Scaled relative BP in chr", chrIter, "is (at head)"))
				print(head(scaledPos))
				message(paste("Scaled relative BP in chr", chrIter, "is (at tail)"))
				print(tail(scaledPos))
				allchrScaledPos[chrIdx] = scaledPos
			}
			
			originalData$sbp <<- originalData$achr + allchrScaledPos
			
			# diagnostic plots
			png("/tmp/chrpos.png")
			plot(allchrScaledPos)
			dev.off()
			png("/tmp/pos.png")
			plot(originalData$sbp)
			dev.off()
			png("/tmp/achr-chrpos.png")
			plot(originalData$achr, allchrScaledPos)
			dev.off()
			png("/tmp/achr-pos.png")
			plot(originalData$achr, originalData$sbp)
			dev.off()
			
#		message("scaled pos inside chromosomes: ")
#		print(allchrScaledPos)
#		message("scaled pos overall")
#		print(originalData$sbp)
			
			
		}
)



Mhplot$methods(
		mhplot = function(annotation=NULL) {
			maxlogp = ceiling(max(originalData$mlogp, na.rm = TRUE))
			message(paste("Maximum of -logP (rounded) is: ", maxlogp))
			minlogp = min(originalData$mlogp, na.rm = TRUE)
			message(paste("Minimum of -logP is: ", minlogp))
			gwthresh = -log10(5e-8)
			
			# if there are more than one chr, then x axis should be labeled by scaled BP (sbp)
			# if there is only one chr, then x axis should be labeled by BP
			if(length(chrunique) > 1) {
				message("More than one chromosome present, set coloring by chr...")
				chrColor = TRUE
				myplot = ggplot(originalData, aes(sbp, mlogp)) + xlab("Chromosomes") +
						scale_x_continuous(breaks=chrunique,
								minor_breaks=NULL,
								labels=chrunique)
			} else {
				message("Only one chromosome present, set no coloring by chr...")
				chrColor = FALSE
				myplot = ggplot(originalDatanalData, aes(BP, mlogp)) + xlab(paste("Position on CHR", chr[1]))
			}
			
			
			if(chrColor) {
				if(!is.null(colorvec)) {
					message("You have provided an extra color vector, coloring by both that and chr...")
					myplot = myplot + geom_point(aes(color=factor(paste(colorvec, achr %% 2)))) +
							scale_color_discrete(name="")
				} else {
					message("No extra color vector provided, just coloring by chr...")
					myplot = myplot + geom_point(aes(color=factor(achr %% 2))) +
							scale_color_discrete(guide=FALSE)
				}
			} else {
				if(!is.null(colorvec)) {
					message("You have provided an extra color vector, coloring by that...")
					myplot = myplot + geom_point(aes(color=factor(colorvec))) +
							scale_color_discrete(name="")
				} else {
					message("No extra color vector provided, no coloring")
					myplot = myplot + geom_point()
				}
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
			message(paste("Before removing NAs, there are", length(originalData$mlogp), "points in -logP"))
			o = originalData$mlogp[!is.na(originalData$mlogp)]
			message(paste("After removing NAs, there are", length(o), "points in -logP"))
			print(head(o))
			message("Sorting -logP...")
			o = sort(o, decreasing = TRUE)
			print(head(o))
			message("Calculating expected -logP...")
			e = -log10(ppoints(length(o)))
			print(head(e))
			qqdat = data.frame(e, o)
			qqplot = ggplot(qqdat, aes(e, o)) + geom_point(alpha=.4) +
					xlab("Expected -log P") + ylab("Observed -log P") +
					geom_abline(intercept=0, slope=1, alpha=.3)
			qqplot
		}
)

Mhplot$methods(
		initialize = function(chr=NULL, bp=NULL, p=NULL, snp=NULL, colorvec=NULL, plinkfile = NULL, pvalThresh = NULL) {
			if(! is.null(plinkfile)) {
				message("Reading from a plink output file...")
				originalData <<- readplinkoutr(filename=plinkfile)
			} else {
				if(is.null(chr) | is.null(bp) | is.null(p)) {
					stop("You should either give me a file in plink output format, or three vectors (chr, bp, p)")
				}
				message("Getting chr, bp, pval vectors inside R...")
				originalData <<- data.frame(CHR=chr, BP=bp, P=p)
				if(! is.na(snp)) {
					message("SNP names provided, adding it to data frame...")
					originalData$SNP <<- snp
				}
				#totest
			}
			
			message("Head of data before sorting:")
			print(head(originalData))
			message("Sorting data by CHR and BP...")
			originalData <<- originalData[order(originalData$CHR, originalData$BP), ]
			message("Head of data after sorting:")
			print(head(originalData))
			
			if(! is.null(pvalThresh)) {
				message(paste("You have requested to filter by p values, with threshold ", pvalThresh))
				originalData <<- originalData[which(originalData$P < pvalThresh), ]
				message("Head of data after filtering:")
				print(head(originalData))
			}
			
			nsnp <<- length(originalData$BP)
			message(paste(nsnp, "SNPs in total"))
			nchr <<- nsnp
			chrunique <<- sort(unique(originalData$CHR))
			message("SNPs are from the following chromosomes:")
			print(chrunique)
			message("Calculating -LogP...")
			originalData$mlogp <<- -log10(originalData$P)
			appChr()
			scaleByChr()
			colorvec <<- colorvec
		}
)

.DollarNames.Mhplot <- function(x, pattern){
	grep(pattern, getRefClass(class(x))$methods(), value=TRUE)
}
