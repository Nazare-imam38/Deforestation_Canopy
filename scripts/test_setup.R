# ==============================================================================
# TEST SETUP SCRIPT
# ==============================================================================
# Run this to verify your setup is working correctly
# ==============================================================================

cat("========================================\n")
cat("TESTING PROJECT SETUP\n")
cat("========================================\n\n")

# Test 1: Configuration
cat("TEST 1: Loading configuration...\n")
tryCatch({
  source("R/01_config.R")
  cat("✓ Configuration loaded successfully!\n")
  cat("  Study Area:", STUDY_AREA_NAME, "\n")
  cat("  Bounding Box:", paste(STUDY_BBOX, collapse = ", "), "\n")
  cat("  Project Root:", PROJECT_ROOT, "\n\n")
}, error = function(e) {
  cat("✗ Configuration error:", e$message, "\n\n")
})

# Test 2: Package Installation
cat("TEST 2: Checking packages...\n")
required_packages <- c("sf", "terra", "dplyr", "ggplot2", "tmap")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(missing_packages) == 0) {
  cat("✓ All required packages are installed!\n\n")
} else {
  cat("✗ Missing packages:", paste(missing_packages, collapse = ", "), "\n")
  cat("  Run: source('R/00_setup_packages.R')\n\n")
}

# Test 3: Package Loading
cat("TEST 3: Loading packages...\n")
tryCatch({
  library(sf)
  library(terra)
  library(dplyr)
  cat("✓ Core packages loaded successfully!\n\n")
}, error = function(e) {
  cat("✗ Package loading error:", e$message, "\n\n")
})

# Test 4: Study Area Loading
cat("TEST 4: Loading study area...\n")
tryCatch({
  source("R/03_load_study_area.R")
  aoi <- load_study_area()
  cat("✓ Study area loaded successfully!\n")
  cat("  CRS:", st_crs(aoi)$input, "\n")
  cat("  Bounding box:", st_bbox(aoi), "\n\n")
}, error = function(e) {
  cat("✗ Study area loading error:", e$message, "\n")
  cat("  Check STUDY_BBOX in R/01_config.R\n\n")
})

# Test 5: Directory Structure
cat("TEST 5: Checking directory structure...\n")
required_dirs <- c("data", "data/Landsat", "data/shapefiles", "output", "R", "scripts")
missing_dirs <- required_dirs[!dir.exists(required_dirs)]

if (length(missing_dirs) == 0) {
  cat("✓ All required directories exist!\n\n")
} else {
  cat("✗ Missing directories:", paste(missing_dirs, collapse = ", "), "\n")
  cat("  Creating missing directories...\n")
  for (dir in missing_dirs) {
    dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  }
  cat("✓ Directories created!\n\n")
}

cat("========================================\n")
cat("SETUP TEST COMPLETE\n")
cat("========================================\n\n")

cat("If all tests passed, you're ready to run:\n")
cat("  source('scripts/main_workflow.R')\n\n")

