# ==============================================================================
# QUICK SETUP SCRIPT
# ==============================================================================
# Run this script in RStudio to set up the project
# ==============================================================================

# Set working directory to project root
setwd("D:/RStudio/Deforestation Project")

cat("========================================\n")
cat("DEFORESTATION DETECTION PROJECT SETUP\n")
cat("========================================\n\n")

# Step 1: Install and load packages
cat("STEP 1: Installing and loading packages...\n")
cat("-------------------------------------------\n")
source("R/00_setup_packages.R")

# Step 2: Load configuration
cat("\nSTEP 2: Loading configuration...\n")
cat("----------------------------------\n")
source("R/01_config.R")

cat("\n========================================\n")
cat("SETUP COMPLETE!\n")
cat("========================================\n\n")

cat("Configuration Summary:\n")
cat("  Study Area:", STUDY_AREA_NAME, "\n")
cat("  Bounding Box:", paste(STUDY_BBOX, collapse = ", "), "\n")
cat("  Analysis Period:", START_DATE, "to", END_DATE, "\n")
cat("  Project Root:", PROJECT_ROOT, "\n\n")

cat("Next steps:\n")
cat("  1. Review configuration in R/01_config.R\n")
cat("  2. Modify STUDY_BBOX if needed for your study area\n")
cat("  3. Run: source('scripts/main_workflow.R')\n\n")

