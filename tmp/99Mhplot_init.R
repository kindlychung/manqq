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
			plot(sbp)
			dev.off()
			png("/tmp/achr-chrpos.png")
			plot(achr, allchrScaledPos)
			dev.off()
			png("/tmp/achr-pos.png")
			plot(achr, sbp)
			dev.off()
		}
)

Mhplot$methods(
    initialize = function(chr=NULL, bp=NULL, p=NULL, snp=NULL, colorvec=NULL, plinkfile = NULL) {
        if(! is.null(plinkfile)) {
			message("Reading from a plink output file...")
            originalData <<- readplinkoutr(plinkfile)
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

        nsnp <<- length(originalData$BP)
		message(paste(nsnp, "SNPs in total"))
        nchr <<- nsnp
        chrunique <<- sort(unique(originalData$CHR))
		message("SNPs are from the following chromosomes:")
		print(chrunique)
		message("Calculating -LogP...")
		print(head(originalData$P))
		mlogp <<- -log10(originalData$P)
		print(head(mlogp))
		print(dim(originalData))
        originalData$mlogp <<- rep(0, nsnp)
		print(head(originalData))
#        appChr()
#        scaleByChr()
#        colorvec <<- colorvec
    }
)

.DollarNames.Mhplot <- function(x, pattern){
  grep(pattern, getRefClass(class(x))$methods(), value=TRUE)
}