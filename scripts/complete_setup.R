# ==============================================================================
# COMPLETE SETUP - INSTALL ALL MISSING PACKAGES
# ==============================================================================
# This script ensures all packages are installed and working
# ==============================================================================

cat("========================================\n")
cat("COMPLETE PACKAGE SETUP\n")
cat("========================================\n\n")

# Step 1: Install missing visualization packages
cat("STEP 1: Installing missing packages...\n")
cat("---------------------------------------\n")
source("scripts/install_missing.R")

# Step 2: Load all packages
cat("\nSTEP 2: Loading packages...\n")
cat("----------------------------\n")
source("R/00_setup_packages.R")

# Step 3: Verify installation
cat("\nSTEP 3: Verifying installation...\n")
cat("----------------------------------\n")
source("scripts/verify_setup.R")

cat("\n========================================\n")
cat("SETUP COMPLETE!\n")
cat("========================================\n\n")

cat("If all packages loaded successfully, you can now:\n")
cat("  1. source('R/01_config.R')\n")
cat("  2. source('R/03_load_study_area.R')\n")
cat("  3. aoi <- load_study_area()\n")
cat("  4. source('scripts/main_workflow.R')\n\n")

