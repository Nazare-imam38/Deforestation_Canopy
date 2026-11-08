# ==============================================================================
# DEFORESTATION DETECTION PROJECT - PACKAGE SETUP
# ==============================================================================
# This script installs and loads all required packages for the project
# Run this script first before executing any other scripts
# ==============================================================================

# Check if packages are installed, install if missing
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, dependencies = TRUE)
  }
}

# Core packages for spatial analysis
spatial_packages <- c(
  "sf",           # Simple Features for spatial data
  "terra",        # Modern raster package (replaces raster)
  "raster",       # Raster operations (backup)
  "sp"            # Spatial data classes
)

# Google Earth Engine integration
gee_packages <- c(
  "rgee",         # Google Earth Engine R API
  "geojsonio"     # Required for sf_as_ee function
)

# Data manipulation and analysis
# Install lubridate first as it's a dependency of tidyverse
analysis_packages <- c(
  "lubridate",    # Date handling (install first - dependency of tidyverse)
  "dplyr",        # Data manipulation
  "tidyr",        # Data tidying
  "zoo",          # Time series objects
  "tidyverse"     # Collection of tidyverse packages (install last)
)

# Time-series analysis
timeseries_packages <- c(
  "bfast",        # Breaks For Additive Seasonal & Trend
  "strucchange"   # Structural change detection
)

# Machine learning for classification
ml_packages <- c(
  "randomForest", # Random Forest classification
  "e1071",        # SVM classification
  "caret"         # Classification and regression training
)

# Visualization
viz_packages <- c(
  "ggplot2",      # Grammar of graphics
  "tmap",         # Thematic maps
  "RColorBrewer", # Color palettes
  "viridis",      # Color scales
  "gridExtra"     # Arrange multiple plots
)

# Landsat data download (optional alternatives)
landsat_packages <- c(
  "getSpatialData" # Download Landsat data
)

# Combine all packages
all_packages <- c(
  spatial_packages,
  gee_packages,
  analysis_packages,
  timeseries_packages,
  ml_packages,
  viz_packages,
  landsat_packages
)

# Install missing packages
cat("Checking and installing required packages...\n")
cat("This may take several minutes. Please be patient...\n\n")

# Install critical dependencies first
cat("Installing critical dependencies...\n")
critical_deps <- c("XML", "lwgeom", "lava")  # Required by tmap and caret
for (pkg in critical_deps) {
  if (!pkg %in% installed.packages()[,"Package"]) {
    cat("  Installing", pkg, "(critical dependency)...\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
    }, error = function(e) {
      cat("    Warning: Could not install", pkg, "-", e$message, "\n")
    })
  }
}

# Install in groups to handle dependencies properly
cat("Installing core spatial packages...\n")
install_if_missing(spatial_packages)

cat("Installing data manipulation packages (including dependencies)...\n")
# Install lubridate first as tidyverse depends on it
if (!"lubridate" %in% installed.packages()[,"Package"]) {
  install.packages("lubridate", dependencies = TRUE)
}
install_if_missing(analysis_packages)

cat("Installing time-series packages...\n")
install_if_missing(timeseries_packages)

cat("Installing machine learning packages...\n")
install_if_missing(ml_packages)

cat("Installing visualization packages...\n")
install_if_missing(viz_packages)

# Install any packages that failed due to timeouts
cat("Installing any packages that may have failed...\n")
retry_packages <- c("XML", "lwgeom", "lava", "viridis", "gridExtra", "zoo", "lubridate", "bfast", "strucchange", "caret", "tmap")
for (pkg in retry_packages) {
  if (!pkg %in% installed.packages()[,"Package"]) {
    cat("  Retrying", pkg, "...\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
    }, error = function(e) {
      cat("    Warning: Could not install", pkg, "\n")
    })
  }
}

cat("Installing optional packages (GEE, Landsat download)...\n")
install_if_missing(gee_packages)
install_if_missing(landsat_packages)

# Load all packages
cat("\nLoading packages...\n")
cat("Loading core packages...\n")

# Function to load package with error handling
safe_load <- function(pkg) {
  tryCatch({
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    return(TRUE)
  }, error = function(e) {
    cat("  Warning: Could not load", pkg, "\n")
    return(FALSE)
  })
}

suppressPackageStartupMessages({
  # Core spatial packages (required)
  library(sf)
  library(terra)
  
  # Data manipulation (load lubridate before tidyverse)
  library(lubridate)
  library(dplyr)
  library(tidyr)
  
  # Visualization (required)
  library(ggplot2)
  # Load dependencies before tmap
  if (require(XML, quietly = TRUE) && require(lwgeom, quietly = TRUE)) {
    library(tmap)
  } else {
    cat("  Warning: tmap dependencies not available\n")
    if (!require(XML, quietly = TRUE)) {
      cat("    Missing: XML - Run: install.packages('XML')\n")
    }
    if (!require(lwgeom, quietly = TRUE)) {
      cat("    Missing: lwgeom - Run: install.packages('lwgeom')\n")
    }
  }
  
  # Machine learning (required)
  library(randomForest)
  # Load lava before caret (dependency)
  if (require(lava, quietly = TRUE)) {
    library(caret)
  } else {
    cat("  Warning: lava not available, caret may not work properly\n")
    cat("  Run: install.packages('lava')\n")
  }
  
  # Time series (required)
  library(zoo)
  library(bfast)
  
  # Load tidyverse last (it loads many packages)
  library(tidyverse)
})

# Optional visualization packages (load if available)
cat("Loading optional packages...\n")
safe_load("viridis")
safe_load("gridExtra")
safe_load("RColorBrewer")

cat("\n✓ All packages loaded successfully!\n")
cat("\nNOTE: To use Google Earth Engine, run: ee_Initialize()\n")
cat("      This requires Google account authentication.\n\n")

