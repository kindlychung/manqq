# TODO: Add comment
# 
# Author: kaiyin
###############################################################################


require(devtools)
load_all("/Users/kaiyin/personal_config_bin_files/workspace/manqq", reset = TRUE)
#load_all("/Users/kaiyin/personal_config_bin_files/workspace/manqq", reset = TRUE, recompile=TRUE)
#o = Mhplot(plinkfile="/Users/kaiyin/Desktop/rstest")
o = Mhplot(plinkfile="/Users/kaiyin/Desktop/RS123_1kg.assoc.linear")
summary(o$originalData$P)
#print(o$mhplot())
print(o$qq())
