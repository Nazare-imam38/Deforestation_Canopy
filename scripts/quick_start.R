# ==============================================================================
# QUICK START - COMPLETE SETUP AND WORKFLOW
# ==============================================================================
# This script runs the complete setup and workflow in one go
# ==============================================================================

cat("========================================\n")
cat("DEFORESTATION DETECTION - QUICK START\n")
cat("========================================\n\n")

# Step 1: Load packages (should already be done)
cat("STEP 1: Loading packages...\n")
cat("----------------------------\n")
source("R/00_setup_packages.R")

# Step 2: Load configuration
cat("\nSTEP 2: Loading configuration...\n")
cat("-------------------------------\n")
source("R/01_config.R")

# Step 3: Load study area
cat("\nSTEP 3: Loading study area...\n")
cat("------------------------------\n")
source("R/03_load_study_area.R")
aoi <- load_study_area()

# Display summary
cat("\n========================================\n")
cat("SETUP COMPLETE!\n")
cat("========================================\n\n")
cat("Project Configuration:\n")
cat("  Study Area:", STUDY_AREA_NAME, "\n")
cat("  Bounding Box:", paste(round(STUDY_BBOX, 4), collapse = ", "), "\n")
cat("  Analysis Period:", START_DATE, "to", END_DATE, "\n")
cat("  Project Root:", PROJECT_ROOT, "\n\n")

bbox <- st_bbox(aoi)
cat("Study Area Details:\n")
cat("  Longitude:", round(bbox[1], 4), "to", round(bbox[3], 4), "\n")
cat("  Latitude:", round(bbox[2], 4), "to", round(bbox[4], 4), "\n")
area_km2 <- as.numeric(st_area(aoi)) / 1e6
cat("  Area:", round(area_km2, 2), "km²\n\n")

# Check for data
cat("Data Status:\n")
landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", full.names = TRUE, recursive = TRUE)
if (length(landsat_files) > 0) {
  cat("  ✓ Found", length(landsat_files), "Landsat files\n")
  cat("  Ready for processing!\n\n")
} else {
  cat("  ⚠ No Landsat files found\n")
  cat("  Place Landsat .tif files in:", LANDSAT_DIR, "\n\n")
}

cat("========================================\n")
cat("READY TO PROCEED!\n")
cat("========================================\n\n")
cat("Next steps:\n")
if (length(landsat_files) > 0) {
  cat("  1. Run: source('scripts/main_workflow.R')\n")
  cat("     This will process your Landsat data\n\n")
} else {
  cat("  1. Download Landsat data:\n")
  cat("     - Use Google Earth Engine (see R/04_download_landsat.R)\n")
  cat("     - Or download from USGS EarthExplorer\n")
  cat("     - Place .tif files in:", LANDSAT_DIR, "\n")
  cat("  2. Then run: source('scripts/main_workflow.R')\n\n")
}

cat("Output will be saved to:\n")
cat("  Maps:", MAPS_DIR, "\n")
cat("  Statistics:", STATS_DIR, "\n")
cat("  Figures:", FIGURES_DIR, "\n\n")

