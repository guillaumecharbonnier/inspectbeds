#!/usr/bin/env Rscript

# Install dependencies for InspectBeds Shiny App

cat("Installing InspectBeds dependencies...\n\n")

# Check if BiocManager is installed
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  cat("Installing BiocManager...\n")
  install.packages("BiocManager", repos = "https://cran.rstudio.com/")
}

# List of CRAN packages
cran_packages <- c(
  "shiny",
  "shinydashboard", 
  "DT",
  "ggplot2",
  "dplyr",
  "UpSetR",
  "plotly"
)

# List of Bioconductor packages
bioc_packages <- c(
  "GenomicRanges",
  "IRanges"
)

# Install CRAN packages
cat("\nInstalling CRAN packages...\n")
for (pkg in cran_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste("Installing", pkg, "...\n"))
    install.packages(pkg, repos = "https://cran.rstudio.com/")
  } else {
    cat(paste(pkg, "is already installed.\n"))
  }
}

# Install Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
for (pkg in bioc_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste("Installing", pkg, "...\n"))
    BiocManager::install(pkg, update = FALSE, ask = FALSE)
  } else {
    cat(paste(pkg, "is already installed.\n"))
  }
}

cat("\n✓ All dependencies installed successfully!\n")
cat("\nTo run the app, execute:\n")
cat("  Rscript -e \"shiny::runApp('app.R')\"\n")
cat("or in R console:\n")
cat("  shiny::runApp('app.R')\n\n")
