# ==============================================================================
# DEFORESTATION DETECTION - MAIN WORKFLOW
# ==============================================================================
# Complete workflow for deforestation detection using Landsat time-series
# Run this script to execute the entire analysis pipeline
# ==============================================================================

# Clear workspace
rm(list = ls())
gc()

# Set working directory to project root
# If running in RStudio, uncomment the line below:
# setwd(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
# Otherwise, set manually:
if (!getwd() == "D:/RStudio/Deforestation Project") {
  setwd("D:/RStudio/Deforestation Project")
}

cat("========================================\n")
cat("DEFORESTATION DETECTION PROJECT\n")
cat("Main Workflow Script\n")
cat("========================================\n\n")

# ==============================================================================
# STEP 1: SETUP AND CONFIGURATION
# ==============================================================================
cat("STEP 1: Setup and Configuration\n")
cat("--------------------------------\n\n")

# Install and load packages
source("R/00_setup_packages.R")

# Load configuration
source("R/01_config.R")

# ==============================================================================
# STEP 2: GOOGLE EARTH ENGINE (OPTIONAL)
# ==============================================================================
cat("\nSTEP 2: Google Earth Engine (Optional)\n")
cat("--------------------------------------\n\n")

# GEE is optional - workflow can work with manually downloaded data
cat("Note: GEE is optional. You can use manually downloaded data.\n")
cat("      If you have GEE registered, it will be used for download.\n\n")

# Try to initialize GEE (but don't fail if not available)
tryCatch({
  source("R/02_initialize_gee.R")
  if (!exists("aoi_ee")) {
    source("scripts/setup_gee.R")
  }
  cat("✓ GEE available (will be used for download if needed)\n\n")
}, error = function(e) {
  cat("⚠ GEE not available (registration pending or not needed)\n")
  cat("  Workflow will use manually downloaded data\n\n")
})

# ==============================================================================
# STEP 3: LOAD STUDY AREA
# ==============================================================================
cat("\nSTEP 3: Load Study Area\n")
cat("-----------------------\n\n")

source("R/03_load_study_area.R")

# Option A: Load from shapefile
aoi <- load_study_area()

# Option B: Create from bounding box coordinates
# aoi <- load_study_area(bbox = c(100.0, 0.0, 101.0, 1.0))  # Example coordinates

# Save study area info
save_study_area_info(aoi)

# Convert to Earth Engine format (if using GEE)
# source("R/02_initialize_gee.R")
# aoi_ee <- aoi_to_ee(aoi)

# ==============================================================================
# STEP 4: DOWNLOAD LANDSAT DATA
# ==============================================================================
cat("\nSTEP 4: Download Landsat Data\n")
cat("-----------------------------\n\n")

# Check if Landsat data already exists
landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", full.names = TRUE, recursive = TRUE)

if (length(landsat_files) == 0) {
  cat("No Landsat files found.\n\n")
  cat("OPTION 1: Download using R packages (immediate)\n")
  cat("  source('scripts/download_landsat_immediate.R')\n\n")
  
  cat("OPTION 2: Manual download from USGS\n")
  cat("  source('scripts/download_landsat_manual.R')\n")
  cat("  Follow instructions to download from EarthExplorer\n")
  cat("  Place .tif files in:", LANDSAT_DIR, "\n\n")
  
  cat("OPTION 3: Google Earth Engine (if registered)\n")
  cat("  source('scripts/download_landsat_gee.R')\n\n")
  
  cat("For immediate processing, use OPTION 1 or OPTION 2.\n")
  cat("After downloading, run this workflow again.\n\n")
  
  # Try immediate download
  cat("Attempting immediate download with R packages...\n")
  tryCatch({
    source("scripts/download_landsat_immediate.R")
    # Re-check for files
    landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", full.names = TRUE, recursive = TRUE)
  }, error = function(e) {
    cat("Automated download not available. Please use manual download.\n")
    cat("Run: source('scripts/download_landsat_manual.R')\n\n")
  })
  
} else {
  cat("✓ Found", length(landsat_files), "existing Landsat files\n")
  cat("  Files are ready for processing!\n\n")
}

# ==============================================================================
# STEP 5: PREPROCESSING
# ==============================================================================
cat("\nSTEP 5: Preprocessing\n")
cat("--------------------\n\n")

source("R/05_preprocessing.R")

# Preprocess Landsat data
# This assumes Landsat files are already in data/Landsat/
landsat_processed <- preprocess_landsat(
  data_dir = LANDSAT_DIR,
  aoi = aoi,
  mosaic = TRUE,  # Set to FALSE if single scene
  clip = TRUE
)

# ==============================================================================
# STEP 6: CALCULATE SPECTRAL INDICES
# ==============================================================================
cat("\nSTEP 6: Calculate Spectral Indices\n")
cat("-----------------------------------\n\n")

source("R/06_spectral_indices.R")

# Calculate indices for single image
indices <- calculate_spectral_indices(
  landsat_processed,
  indices = c("NDVI", "NBR")
)

# For time series analysis, use:
# indices_ts <- calculate_indices_timeseries(landsat_files)

# ==============================================================================
# STEP 7: CHANGE DETECTION
# ==============================================================================
cat("\nSTEP 7: Change Detection\n")
cat("-----------------------\n\n")

source("R/07_change_detection.R")

# For change detection, you need NBR from two time periods
# Example: Load NBR from different years
# nbr_2015 <- rast("output/nbr_2015.tif")
# nbr_2024 <- rast("output/nbr_2024.tif")

# If you have time series data:
# nbr_stack <- rast(OUTPUT_FILES$nbr_stack)
# nbr_2015 <- nbr_stack[[1]]  # First time period
# nbr_2024 <- nbr_stack[[nlyr(nbr_stack)]]  # Last time period

# Run change detection
# deforestation_results <- detect_deforestation(
#   nbr_before = nbr_2015,
#   nbr_after = nbr_2024,
#   threshold = DNBR_THRESHOLD,
#   calculate_severity = TRUE,
#   detect_hotspots = TRUE
# )

# ==============================================================================
# STEP 8: BFAST TIME-SERIES ANALYSIS (Optional)
# ==============================================================================
cat("\nSTEP 8: BFAST Time-Series Analysis\n")
cat("----------------------------------\n\n")

# Uncomment to run BFAST analysis
# source("R/08_bfast_analysis.R")
# 
# # Load NDVI time series stack
# ndvi_stack <- rast(OUTPUT_FILES$ndvi_stack)
# 
# # Run BFAST on mean time series
# bfast_results <- analyze_bfast(
#   ndvi_stack,
#   start_year = 2000,
#   pixelwise = FALSE  # Set to TRUE for pixel-wise analysis (time-consuming)
# )

# ==============================================================================
# STEP 9: LAND COVER CLASSIFICATION (Optional)
# ==============================================================================
cat("\nSTEP 9: Land Cover Classification\n")
cat("----------------------------------\n\n")

# Uncomment to run classification
# source("R/09_classification.R")
# 
# # Load training data
# training_data <- load_training_data()
# 
# # Classify land cover
# classification_results <- classify_landcover(
#   raster_stack = landsat_processed,
#   training_data = training_data,
#   method = "randomForest"
# )

# ==============================================================================
# STEP 10: ACCURACY ASSESSMENT (Optional)
# ==============================================================================
cat("\nSTEP 10: Accuracy Assessment\n")
cat("----------------------------\n\n")

# Uncomment to assess accuracy
# source("R/10_accuracy_assessment.R")
# 
# # Load validation data
# validation_data <- read.csv("data/training/validation_points.csv")
# 
# # Extract predicted values
# predicted <- extract(classification_results$Classified, 
#                      vect(validation_data[, c("x", "y")]))
# 
# # Assess accuracy
# accuracy_metrics <- assess_accuracy(
#   predicted = predicted$LandCover,
#   actual = validation_data$class
# )

# ==============================================================================
# STEP 11: VISUALIZATION
# ==============================================================================
cat("\nSTEP 11: Visualization\n")
cat("---------------------\n\n")

source("R/11_visualization.R")

# Create visualizations
# create_all_visualizations(
#   deforestation_results = deforestation_results,
#   ndvi_ts = ndvi_stack,
#   nbr_ts = nbr_stack,
#   landcover = classification_results$Classified
# )

# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n========================================\n")
cat("WORKFLOW COMPLETE\n")
cat("========================================\n\n")

cat("Output files are saved in:\n")
cat("  Maps:", MAPS_DIR, "\n")
cat("  Statistics:", STATS_DIR, "\n")
cat("  Figures:", FIGURES_DIR, "\n\n")

cat("Next steps:\n")
cat("  1. Review output maps and statistics\n")
cat("  2. Adjust thresholds if needed\n")
cat("  3. Validate results with field data\n")
cat("  4. Generate final report\n\n")

cat("For detailed methodology, see README.md\n\n")

