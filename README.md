# Spatial Correlogram Tutorial (R)

A short, self-contained tutorial for building **spatial correlograms** in R—computing **Moran’s I** and **Geary’s C** across distance bins using the built-in `meuse` dataset (no external files). This is a good follow-up or precursor to the [variogram](https://github.com/parker-group/variogram_tutorial1) tutorial.

## What you'll learn
- What correlograms show (vs. semivariograms)
- Building equal-width distance bins (rings)
- Moran’s I by distance (with permutation p-values)
- Optional: Geary’s C correlogram

## Quick start

### A) View-only (no R)
Open the rendered HTML tutorial:
- `correlogram_tutorial1.html` (in this repo)
- https://parker-group.github.io/spcorrelogram_tutorial1/

### B) Hands-on (R installed)
In R:
```r
install.packages(c("spdep", "sp", "sf", "ggplot2", "rmarkdown"))  # first time
rmarkdown::render("correlogram_tutorial1.rmd", output_format = "html_document")
```

### C) Hands-on in your browser (no install)
Click to launch an interactive RStudio session with Binder:

[![Launch RStudio in Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/parker-group/spcorrelogram_tutorial1/HEAD?urlpath=rstudio)

When RStudio opens in the browser:
1. In the **Files** pane, click `correlogram_tutorial1.rmd`
2. Click **Knit** to render, or use **Run ▶** to step through

---

## Reproducing directly from the README in R
If you want to quickly reproduce the core correlogram example without opening the `.Rmd`, copy/paste this into your R console:
```r
# Install required packages (skip if already installed)
install.packages(c("spdep", "sp"))

# Load libraries
library(sp)
library(spdep)

# Load the example data
data(meuse)
coords <- as.matrix(meuse[, c("x","y")])   # numeric matrix of coordinates
x <- meuse$zinc                             # variable to analyze

# Build equal-width distance bins (e.g., 0–3000 m into 12 bins)
max_distance <- 3000
n_bins <- 12
edges <- seq(0, max_distance, length.out = n_bins + 1)

# Compute Moran's I by ring with permutation p-values
set.seed(123)
res <- do.call(rbind, lapply(seq_len(n_bins), function(i) {
  dmin <- edges[i]; dmax <- edges[i+1]
  nb <- dnearneigh(coords, d1 = dmin, d2 = dmax, longlat = FALSE)
  lw <- nb2listw(nb, style = "B", zero.policy = TRUE)  # binary weights
  if (sum(unlist(lw$weights)) == 0) {
    data.frame(bin=i, dmin=dmin, dmax=dmax, mid=(dmin+dmax)/2, I=NA_real_, p=NA_real_)
  } else {
    mc <- moran.mc(x, lw, nsim = 499, zero.policy = TRUE, alternative = "two.sided")
    data.frame(bin=i, dmin=dmin, dmax=dmax, mid=(dmin+dmax)/2,
               I=as.numeric(mc$statistic), p=mc$p.value)
  }
}))

# Quick base R plot
plot(res$mid, res$I, type="b", xlab="Distance (bin mid, m)", ylab="Moran's I")
abline(h=0, lty=2)
```
This minimal example runs the core correlogram workflow without needing any extra files.

---

## Notes
- Binder setup files (`runtime.txt` and `install.R`) are included for reproducibility.
- First Binder launch may take 1–3 minutes while it builds the environment.
