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


Myclass = setRefClass(
    "Myclass",
    fields = list(
			dat = "data.frame"
	)
)
#Myclass$methods(
#		testadd = function() {
#			dat$z = 3:6
#		}
#		)
Myclass$methods(
		initialize = function(a) {
			dat <<- data.frame(x = 1:4, y = 2:5)
			dat$z = 3:6
		}
		)
o = Myclass(3:6)
print(o$dat)