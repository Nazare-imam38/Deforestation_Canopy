# ==============================================================================
# COMPLETE GEE WORKFLOW - FROM SETUP TO DATA DOWNLOAD
# ==============================================================================
# Complete workflow for Google Earth Engine setup and data download
# ==============================================================================

cat("========================================\n")
cat("COMPLETE GOOGLE EARTH ENGINE WORKFLOW\n")
cat("========================================\n\n")

# Step 1: Setup GEE
cat("STEP 1: Setting up Google Earth Engine...\n")
cat("==========================================\n\n")
source("scripts/setup_gee.R")

# Step 2: Download Landsat data
cat("\nSTEP 2: Downloading Landsat data...\n")
cat("====================================\n\n")
source("scripts/download_landsat_gee.R")

# Summary
cat("\n========================================\n")
cat("WORKFLOW COMPLETE!\n")
cat("========================================\n\n")
cat("Summary:\n")
cat("  ✓ Google Earth Engine initialized\n")
cat("  ✓ Study area prepared\n")
cat("  ✓ Download tasks created\n\n")

cat("Next steps:\n")
cat("  1. Wait for GEE tasks to complete (check Google Drive)\n")
cat("  2. Download files: source('scripts/download_from_drive.R')\n")
cat("  3. Process data: source('scripts/main_workflow.R')\n\n")

cat("To check task status:\n")
cat("  tasks <- ee$batch$Task$list()\n")
cat("  print(tasks)\n\n")

cat("Files will be in Google Drive folder: rgee_backup\n")
cat("After download, files will be in: data/Landsat/\n\n")

