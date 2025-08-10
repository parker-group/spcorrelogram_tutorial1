**install.R**
```r
# install.R — installs packages needed by the tutorial
pkgs <- c("spdep", "sp", "sf", "ggplot2", "rmarkdown")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)
