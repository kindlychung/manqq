# TODO: Add comment
# 
# Author: kaiyin
###############################################################################



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
