# ==============================================================================
# FIX PACKAGE INSTALLATION ISSUES
# ==============================================================================
# Run this if you encounter package loading errors
# ==============================================================================

cat("========================================\n")
cat("FIXING PACKAGE INSTALLATION\n")
cat("========================================\n\n")

# Install lubridate explicitly (required by tidyverse)
cat("Installing lubridate (required dependency)...\n")
if (!require(lubridate, quietly = TRUE)) {
  install.packages("lubridate", dependencies = TRUE)
  library(lubridate)
}
cat("✓ lubridate installed and loaded\n\n")

# Install other common dependencies
cat("Installing additional dependencies...\n")
dependencies <- c("Rcpp", "BH", "plogr", "stringi", "stringr", "readr", "forcats")
for (pkg in dependencies) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("  Installing", pkg, "...\n")
    install.packages(pkg, dependencies = TRUE)
  }
}

# Now try to install tidyverse
cat("\nInstalling tidyverse...\n")
if (!require(tidyverse, quietly = TRUE)) {
  install.packages("tidyverse", dependencies = TRUE)
  library(tidyverse)
}
cat("✓ tidyverse installed and loaded\n\n")

# Verify all critical packages
cat("Verifying package installation...\n")
critical_packages <- c("sf", "terra", "dplyr", "lubridate", "tidyverse", 
                      "ggplot2", "tmap", "randomForest", "caret", "bfast", "zoo")

missing <- c()
for (pkg in critical_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    missing <- c(missing, pkg)
  }
}

if (length(missing) == 0) {
  cat("✓ All critical packages are installed and loaded!\n\n")
} else {
  cat("✗ Missing packages:", paste(missing, collapse = ", "), "\n")
  cat("  Installing missing packages...\n")
  install.packages(missing, dependencies = TRUE)
  cat("✓ Missing packages installed\n\n")
}

cat("========================================\n")
cat("PACKAGE FIX COMPLETE\n")
cat("========================================\n\n")

cat("Now try running:\n")
cat("  source('R/00_setup_packages.R')\n\n")

