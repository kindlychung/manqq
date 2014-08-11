# Requirements

* git
* R packages: 
    * ggplot2
    * Rcpp
    * RcppArmadillo
    * devtools

# Installation

    require(devtools)
    Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
    install_github("rbed", username="kindlychung")


# Changes

* added pval filter
* no longer store CHR, SNP, BP as vectors, they are in a data frame
* reading of plink output file now handled by c++ functions

# To do

* test initializer using vectors
* replace message with warning?
