# ==============================================================================
# VERIFY PACKAGE SETUP
# ==============================================================================
# Verify that all packages loaded successfully
# ==============================================================================

cat("========================================\n")
cat("VERIFYING PACKAGE INSTALLATION\n")
cat("========================================\n\n")

# List of critical packages to verify
critical_packages <- list(
  "Spatial" = c("sf", "terra", "raster", "sp"),
  "Data Manipulation" = c("dplyr", "tidyr", "lubridate", "tidyverse", "zoo"),
  "Visualization" = c("ggplot2", "tmap", "RColorBrewer", "viridis", "gridExtra"),
  "Machine Learning" = c("randomForest", "e1071", "caret"),
  "Time Series" = c("bfast", "strucchange", "zoo")
)

all_loaded <- TRUE
failed_packages <- c()

cat("Testing package loading...\n\n")

for (category in names(critical_packages)) {
  cat(category, "packages:\n")
  for (pkg in critical_packages[[category]]) {
    result <- tryCatch({
      library(pkg, character.only = TRUE, quietly = TRUE)
      cat("  ✓", pkg, "\n")
      TRUE
    }, error = function(e) {
      cat("  ✗", pkg, "-", e$message, "\n")
      FALSE
    }, warning = function(w) {
      # Warnings about version are OK, just note them
      cat("  ✓", pkg, "(version warning - OK)\n")
      TRUE
    })
    
    if (!result) {
      all_loaded <- FALSE
      failed_packages <- c(failed_packages, pkg)
    }
  }
  cat("\n")
}

cat("========================================\n")
if (all_loaded) {
  cat("✓ ALL PACKAGES LOADED SUCCESSFULLY!\n")
  cat("========================================\n\n")
  cat("Version warnings are normal and can be ignored.\n")
  cat("Your packages are ready to use!\n\n")
  cat("Next steps:\n")
  cat("  1. source('R/01_config.R')\n")
  cat("  2. source('R/03_load_study_area.R')\n")
  cat("  3. aoi <- load_study_area()\n")
  cat("  4. source('scripts/main_workflow.R')\n\n")
} else {
  cat("✗ SOME PACKAGES FAILED TO LOAD\n")
  cat("========================================\n\n")
  cat("Failed packages:", paste(failed_packages, collapse = ", "), "\n")
  cat("Try running: source('scripts/fix_packages.R')\n\n")
}

