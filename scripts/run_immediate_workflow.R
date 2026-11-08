# ==============================================================================
# IMMEDIATE WORKFLOW - NO GEE REQUIRED
# ==============================================================================
# Complete workflow that works with manually downloaded or R-package downloaded data
# ==============================================================================

cat("========================================\n")
cat("DEFORESTATION DETECTION - IMMEDIATE WORKFLOW\n")
cat("No Google Earth Engine Required\n")
cat("========================================\n\n")

# Step 1: Setup
cat("STEP 1: Setup and Configuration\n")
cat("-------------------------------\n")
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

aoi <- load_study_area()
cat("✓ Study area loaded:", round(as.numeric(st_area(aoi)) / 1e6, 2), "km²\n\n")

# Step 2: Check for data or download
cat("STEP 2: Satellite Data\n")
cat("----------------------\n")

# Check for any satellite data (Landsat, Sentinel, MODIS)
landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.(tif|jp2|SAFE)$", 
                           full.names = TRUE, recursive = TRUE)

if (length(landsat_files) == 0) {
  cat("No Landsat files found. Attempting download...\n\n")
  
  # Try immediate download
  tryCatch({
    source("scripts/download_landsat_immediate.R")
    landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", full.names = TRUE, recursive = TRUE)
  }, error = function(e) {
    cat("Automated download failed. Please download manually.\n")
    cat("Run: source('scripts/download_landsat_manual.R')\n")
    cat("Then place .tif files in:", LANDSAT_DIR, "\n")
    cat("Then run this script again.\n\n")
    stop("No Landsat data available")
  })
}

if (length(landsat_files) > 0) {
  cat("✓ Found", length(landsat_files), "satellite image files\n")
  cat("  Files:", paste(basename(head(landsat_files, 3)), collapse = ", "))
  if (length(landsat_files) > 3) cat(", ...")
  cat("\n  Ready for processing!\n\n")
} else {
  stop("No satellite data found. Please download data first.")
}

# Step 3: Preprocessing
cat("STEP 3: Preprocessing\n")
cat("---------------------\n")
source("R/05_preprocessing.R")

# Detect data type
data_type <- "unknown"
if (any(grepl("MOD13|MOD09|MOD16", basename(landsat_files)))) {
  data_type <- "modis"
  cat("Detected: MODIS data\n")
} else if (any(grepl("S2|SENTINEL", basename(landsat_files), ignore.case = TRUE))) {
  data_type <- "sentinel2"
  cat("Detected: Sentinel-2 data\n")
} else {
  data_type <- "landsat"
  cat("Detected: Landsat data\n")
}

landsat_processed <- preprocess_landsat(
  data_dir = LANDSAT_DIR,
  aoi = aoi,
  mosaic = length(landsat_files) > 1,
  clip = TRUE
)

cat("✓ Preprocessing complete\n\n")

# Step 4: Calculate Spectral Indices
cat("STEP 4: Calculate Spectral Indices\n")
cat("----------------------------------\n")
source("R/06_spectral_indices.R")

# Determine sensor type for index calculation
sensor_type <- ifelse(data_type == "modis", "modis",
                     ifelse(data_type == "sentinel2", "sentinel2", "landsat"))

# For MODIS, if it's already NDVI, use it directly
if (data_type == "modis" && nlyr(landsat_processed) == 1) {
  cat("MODIS NDVI detected - using directly\n")
  indices <- list(NDVI = landsat_processed)
  names(indices$NDVI) <- "NDVI"
} else {
  # Calculate indices
  indices <- calculate_spectral_indices(
    landsat_processed,
    indices = c("NDVI", "NBR")
  )
}

cat("✓ Spectral indices calculated\n")
cat("  NDVI range:", paste(round(minmax(indices$NDVI), 3), collapse = " to "), "\n")
cat("  NBR range:", paste(round(minmax(indices$NBR), 3), collapse = " to "), "\n\n")

# Step 5: Save results
cat("STEP 5: Saving Results\n")
cat("---------------------\n")

# Save NDVI
ndvi_file <- file.path(OUTPUT_DIR, "ndvi.tif")
writeRaster(indices$NDVI, ndvi_file, overwrite = TRUE)
cat("✓ Saved NDVI:", ndvi_file, "\n")

# Save NBR
nbr_file <- file.path(OUTPUT_DIR, "nbr.tif")
writeRaster(indices$NBR, nbr_file, overwrite = TRUE)
cat("✓ Saved NBR:", nbr_file, "\n\n")

# Step 6: Visualization
cat("STEP 6: Creating Visualizations\n")
cat("-------------------------------\n")
source("R/11_visualization.R")

# Create NDVI map
tryCatch({
  tmap_mode("plot")
  p <- tm_shape(indices$NDVI) +
    tm_raster(title = "NDVI", palette = "YlGn", style = "cont") +
    tm_layout(title = "NDVI Map")
  tmap_save(p, file.path(FIGURES_DIR, "ndvi_map.png"), 
            width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  cat("✓ Created NDVI map\n")
}, error = function(e) {
  cat("⚠ Could not create map:", e$message, "\n")
})

# Create NBR map
tryCatch({
  p <- tm_shape(indices$NBR) +
    tm_raster(title = "NBR", palette = "RdYlBu", style = "cont") +
    tm_layout(title = "NBR Map")
  tmap_save(p, file.path(FIGURES_DIR, "nbr_map.png"), 
            width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  cat("✓ Created NBR map\n")
}, error = function(e) {
  cat("⚠ Could not create map:", e$message, "\n")
})

cat("\n")

# Step 7: Change Detection (if multiple time periods)
cat("STEP 7: Change Detection\n")
cat("-----------------------\n")

if (length(landsat_files) >= 2) {
  cat("Multiple images found. Change detection possible.\n")
  cat("For change detection, you need NBR from two specific time periods.\n")
  cat("See: source('R/07_change_detection.R')\n\n")
} else {
  cat("Single image found. Change detection requires images from multiple dates.\n")
  cat("Download more images for different time periods to perform change detection.\n\n")
}

# Summary
cat("========================================\n")
cat("WORKFLOW COMPLETE!\n")
cat("========================================\n\n")

cat("Outputs saved to:\n")
cat("  Maps:", MAPS_DIR, "\n")
cat("  Statistics:", STATS_DIR, "\n")
cat("  Figures:", FIGURES_DIR, "\n\n")

cat("Generated files:\n")
cat("  - NDVI map:", file.path(OUTPUT_DIR, "ndvi.tif"), "\n")
cat("  - NBR map:", file.path(OUTPUT_DIR, "nbr.tif"), "\n")
cat("  - NDVI visualization:", file.path(FIGURES_DIR, "ndvi_map.png"), "\n")
cat("  - NBR visualization:", file.path(FIGURES_DIR, "nbr_map.png"), "\n\n")

cat("Next steps:\n")
cat("  1. For change detection, download images from multiple dates\n")
cat("  2. Run: source('R/07_change_detection.R')\n")
cat("  3. For time-series analysis: source('R/08_bfast_analysis.R')\n")
cat("  4. For classification: source('R/09_classification.R')\n\n")

cat("========================================\n\n")

