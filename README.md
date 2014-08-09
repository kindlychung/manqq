# Requirements

* Operating system: Linux. This packeage relies on some linux utilities for text processing (sed, cut etc).
It's possible to install these tools on Windows through MinGW or Cygwin, but I haven't tried it.
* R packages: You need devtools to get started. ggplot2.

# Installation

    require(devtools)
    install_github("manqq", username="kindlychung")


# Changes

* no longer store CHR, SNP, BP as vectors, they are in a data frame
* reading of plink output file now handled by c++ functions

# To do

* check qq plot function
* diagnostic plot on and off
* test initializer using vectors
* replace message with warning?
