# TODO: Add comment
# 
# Author: kaiyin
###############################################################################


require(devtools)
Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
load_all("/Users/kaiyin/personal_config_bin_files/workspace/manqq", reset = TRUE)
#x = readplinkoutr(filename="/Users/kaiyin/Desktop/rstest", covarHiden=FALSE)
#print(x)
#load_all("/Users/kaiyin/personal_config_bin_files/workspace/manqq", reset = TRUE, recompile=TRUE)
#o = Mhplot(plinkfile="/Users/kaiyin/Desktop/rstest")
o = Mhplot(plinkfile="/Users/kaiyin/Desktop/RS123_1kg.assoc.linear", pvalThresh=0.1)
print(o$mhplot())



require(devtools)
Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
install_github("manqq", username="kindlychung")
require(manqq)
o = Mhplot(plinkfile="/home/kaiyin/Desktop/rstest", pvalThresh=0.1)
o.plot = o$mhplot()
require(ggplot2)
ggsave(filename="/tmp/x.png", plot=o.plot)



require(devtools)
Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
#load_all("/Users/kaiyin/personal_config_bin_files/workspace/manqq", reset = TRUE)
load_all("/home/kaiyin/Desktop/manqq", reset = TRUE, recompile=TRUE)
#o = Mhplot(plinkfile="/Users/kaiyin/Desktop/rstest")
o = Mhplot(plinkfile="/home/kaiyin/Desktop/rstest", pvalThresh=0.1)
print(o$mhplot())
#print(o$qq())