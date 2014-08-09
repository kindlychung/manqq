# TODO: Add comment
# 
# Author: kaiyin
###############################################################################



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
