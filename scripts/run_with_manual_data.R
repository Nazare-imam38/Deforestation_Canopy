# ==============================================================================
# COMPLETE WORKFLOW WITH MANUAL LANDSAT DATA
# ==============================================================================
# Runs the complete deforestation detection workflow using your manually
# downloaded Landsat files
# ==============================================================================

cat("========================================\n")
cat("DEFORESTATION DETECTION WORKFLOW\n")
cat("Using Manual Landsat Data\n")
cat("========================================\n\n")

# Step 1: Load packages and configuration
cat("STEP 1: Loading packages and configuration...\n")
cat("----------------------------------------------\n")
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")
aoi <- load_study_area()
cat("✓ Packages loaded and configuration applied.\n\n")

# Step 2: Process manual Landsat files
cat("STEP 2: Processing manual Landsat files...\n")
cat("-------------------------------------------\n")
source("scripts/process_manual_landsat.R")

# Get processed data
if (!exists("processed_landsat")) {
  stop("Failed to process Landsat files. Check errors above.")
}

cat("✓ Landsat data processed successfully!\n\n")

# Step 3: Calculate Spectral Indices
cat("STEP 3: Calculating Spectral Indices\n")
cat("------------------------------------\n")
source("R/06_spectral_indices.R")

# For Landsat 8/9, bands are: B1=Coastal, B2=Blue, B3=Green, B4=Red, B5=NIR, B6=SWIR1, B7=SWIR2
# So Red = band 4, NIR = band 5, SWIR2 = band 7

cat("Calculating NDVI and NBR...\n")

# Extract bands for indices
# If processed_landsat is a time series stack, use first scene for band extraction
if (nlyr(processed_landsat) > 7) {
  # Time series stack - extract first scene's bands
  first_scene <- processed_landsat[[1:7]]
  red_band <- first_scene[[4]]  # B4 = Red
  nir_band <- first_scene[[5]]  # B5 = NIR
  swir2_band <- first_scene[[7]]  # B7 = SWIR2
} else {
  # Single scene
  red_band <- processed_landsat[[4]]  # B4 = Red
  nir_band <- processed_landsat[[5]]  # B5 = NIR
  swir2_band <- processed_landsat[[7]]  # B7 = SWIR2
}

# Calculate NDVI
cat("  Calculating NDVI...\n")
ndvi <- (nir_band - red_band) / (nir_band + red_band)
names(ndvi) <- "NDVI"
cat("  ✓ NDVI calculated\n")

# Calculate NBR
cat("  Calculating NBR...\n")
nbr <- (nir_band - swir2_band) / (nir_band + swir2_band)
names(nbr) <- "NBR"
cat("  ✓ NBR calculated\n\n")

# Save indices
indices_dir <- file.path(OUTPUT_DIR, "indices")
dir.create(indices_dir, showWarnings = FALSE, recursive = TRUE)

writeRaster(ndvi, file.path(indices_dir, "ndvi.tif"), overwrite = TRUE)
writeRaster(nbr, file.path(indices_dir, "nbr.tif"), overwrite = TRUE)

cat("✓ Spectral indices saved to:", indices_dir, "\n\n")

# Step 4: Time Series Analysis (if multiple scenes)
cat("STEP 4: Time Series Analysis\n")
cat("----------------------------\n")

if (nlyr(processed_landsat) > 7) {
  cat("Multiple scenes detected - preparing for time series analysis...\n")
  
  # Calculate NDVI time series
  cat("Calculating NDVI time series...\n")
  
  # Extract Red and NIR bands for each date
  dates <- unique(gsub(".*_(\\d{4}-\\d{2}-\\d{2})$", "\\1", names(processed_landsat)))
  ndvi_ts <- list()
  
  for (i in 1:length(dates)) {
    date_layers <- grep(dates[i], names(processed_landsat))
    if (length(date_layers) >= 5) {
      red <- processed_landsat[[date_layers[4]]]  # B4
      nir <- processed_landsat[[date_layers[5]]]   # B5
      ndvi_date <- (nir - red) / (nir + red)
      names(ndvi_date) <- paste0("NDVI_", dates[i])
      ndvi_ts[[i]] <- ndvi_date
    }
  }
  
  if (length(ndvi_ts) > 0) {
    ndvi_stack <- rast(ndvi_ts)
    writeRaster(ndvi_stack, file.path(indices_dir, "ndvi_timeseries.tif"), overwrite = TRUE)
    cat("✓ NDVI time series saved (", nlyr(ndvi_stack), " dates)\n\n", sep = "")
  }
  
  cat("For BFAST analysis, use:\n")
  cat("  source('R/07_change_detection.R')\n")
  cat("  bfast_result <- detect_changes_bfast(ndvi_stack)\n\n")
  
} else {
  cat("Single scene - time series analysis requires multiple dates\n")
  cat("For change detection, download more scenes or use NBR differencing\n\n")
}

# Step 5: Generate Summary
cat("STEP 5: Summary\n")
cat("--------------\n")

cat("Processed Data Summary:\n")
cat("  Scenes:", ifelse(exists("landsat_scenes"), length(landsat_scenes), 1), "\n")
cat("  Total layers:", nlyr(processed_landsat), "\n")
cat("  Dimensions:", nrow(processed_landsat), "x", ncol(processed_landsat), "\n\n")

cat("Generated Outputs:\n")
cat("  NDVI:", file.path(indices_dir, "ndvi.tif"), "\n")
cat("  NBR:", file.path(indices_dir, "nbr.tif"), "\n")
if (exists("ndvi_stack")) {
  cat("  NDVI Time Series:", file.path(indices_dir, "ndvi_timeseries.tif"), "\n")
}
cat("\n")

cat("========================================\n")
cat("✓ WORKFLOW COMPLETE!\n")
cat("========================================\n\n")

cat("Next steps:\n")
cat("  1. Visualize results:\n")
cat("     source('R/09_visualization.R')\n\n")
cat("  2. Run change detection:\n")
cat("     source('R/07_change_detection.R')\n\n")
cat("  3. Classify land cover:\n")
cat("     source('R/08_classification.R')\n\n")

cat("Output directory:", OUTPUT_DIR, "\n\n")

