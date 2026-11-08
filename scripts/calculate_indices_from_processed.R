# ==============================================================================
# CALCULATE SPECTRAL INDICES FROM PROCESSED LANDSAT DATA
# ==============================================================================
# Calculates NDVI and NBR for all dates in the time series
# ==============================================================================

cat("========================================\n")
cat("CALCULATING SPECTRAL INDICES\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")

# Check if processed data exists
if (!exists("processed_landsat")) {
  cat("Loading processed Landsat data...\n")
  processed_file <- file.path(LANDSAT_DIR, "processed_landsat_stack.tif")
  if (file.exists(processed_file)) {
    processed_landsat <- rast(processed_file)
    cat("✓ Loaded from:", processed_file, "\n\n")
  } else {
    stop("Processed Landsat data not found. Run: source('scripts/process_manual_landsat.R')")
  }
}

cat("Processing", nlyr(processed_landsat), "layers\n")
cat("This represents", nlyr(processed_landsat) / 7, "scenes with 7 bands each\n\n")

# Extract dates from layer names
layer_names <- names(processed_landsat)
dates <- unique(gsub(".*_(\\d{4}-\\d{2}-\\d{2})$", "\\1", layer_names))
if (length(dates) == 0) {
  # If no dates in names, assume 3 scenes
  dates <- c("2024-12-09", "2024-12-17", "2024-12-25")
}

cat("Detected dates:", paste(dates, collapse = ", "), "\n\n")

cat("========================================\n")
cat("STEP 1: CALCULATING NDVI FOR EACH DATE\n")
cat("========================================\n\n")

# Calculate NDVI for each date
ndvi_list <- list()

for (i in 1:length(dates)) {
  date <- dates[i]
  cat("Processing date", i, "of", length(dates), ":", date, "\n")
  
  # Extract bands for this date (7 bands per scene)
  band_start <- (i - 1) * 7 + 1
  band_end <- i * 7
  
  if (band_end <= nlyr(processed_landsat)) {
    scene_bands <- processed_landsat[[band_start:band_end]]
    
    # Extract Red (B4 = index 4) and NIR (B5 = index 5)
    red_band <- scene_bands[[4]]
    nir_band <- scene_bands[[5]]
    
    # Calculate NDVI
    ndvi <- (nir_band - red_band) / (nir_band + red_band)
    names(ndvi) <- paste0("NDVI_", date)
    
    ndvi_list[[i]] <- ndvi
    
    # Show statistics
    ndvi_vals <- values(ndvi)
    ndvi_vals <- ndvi_vals[!is.na(ndvi_vals)]
    if (length(ndvi_vals) > 0) {
      cat("  ✓ NDVI calculated\n")
      cat("    Range:", round(min(ndvi_vals, na.rm = TRUE), 3), "to", 
          round(max(ndvi_vals, na.rm = TRUE), 3), "\n")
      cat("    Mean:", round(mean(ndvi_vals, na.rm = TRUE), 3), "\n\n")
    } else {
      cat("  ⚠ No valid NDVI values\n\n")
    }
  }
}

# Stack NDVI time series
if (length(ndvi_list) > 0) {
  ndvi_stack <- rast(ndvi_list)
  cat("✓ NDVI time series created:", nlyr(ndvi_stack), "layers\n\n")
} else {
  stop("Failed to calculate NDVI")
}

cat("========================================\n")
cat("STEP 2: CALCULATING NBR FOR EACH DATE\n")
cat("========================================\n\n")

# Calculate NBR for each date
nbr_list <- list()

for (i in 1:length(dates)) {
  date <- dates[i]
  cat("Processing date", i, "of", length(dates), ":", date, "\n")
  
  # Extract bands for this date
  band_start <- (i - 1) * 7 + 1
  band_end <- i * 7
  
  if (band_end <= nlyr(processed_landsat)) {
    scene_bands <- processed_landsat[[band_start:band_end]]
    
    # Extract NIR (B5 = index 5) and SWIR2 (B7 = index 7)
    nir_band <- scene_bands[[5]]
    swir2_band <- scene_bands[[7]]
    
    # Calculate NBR
    nbr <- (nir_band - swir2_band) / (nir_band + swir2_band)
    names(nbr) <- paste0("NBR_", date)
    
    nbr_list[[i]] <- nbr
    
    # Show statistics
    nbr_vals <- values(nbr)
    nbr_vals <- nbr_vals[!is.na(nbr_vals)]
    if (length(nbr_vals) > 0) {
      cat("  ✓ NBR calculated\n")
      cat("    Range:", round(min(nbr_vals, na.rm = TRUE), 3), "to", 
          round(max(nbr_vals, na.rm = TRUE), 3), "\n")
      cat("    Mean:", round(mean(nbr_vals, na.rm = TRUE), 3), "\n\n")
    } else {
      cat("  ⚠ No valid NBR values\n\n")
    }
  }
}

# Stack NBR time series
if (length(nbr_list) > 0) {
  nbr_stack <- rast(nbr_list)
  cat("✓ NBR time series created:", nlyr(nbr_stack), "layers\n\n")
} else {
  stop("Failed to calculate NBR")
}

cat("========================================\n")
cat("STEP 3: SAVING INDICES\n")
cat("========================================\n\n")

# Create output directory
indices_dir <- file.path(OUTPUT_DIR, "indices")
dir.create(indices_dir, showWarnings = FALSE, recursive = TRUE)

# Save NDVI stack
ndvi_file <- file.path(indices_dir, "ndvi_timeseries.tif")
writeRaster(ndvi_stack, ndvi_file, overwrite = TRUE)
cat("✓ NDVI time series saved:", ndvi_file, "\n")

# Save NBR stack
nbr_file <- file.path(indices_dir, "nbr_timeseries.tif")
writeRaster(nbr_stack, nbr_file, overwrite = TRUE)
cat("✓ NBR time series saved:", nbr_file, "\n")

# Save individual NDVI maps
for (i in 1:nlyr(ndvi_stack)) {
  ndvi_single <- ndvi_stack[[i]]
  date_name <- gsub("NDVI_", "", names(ndvi_single))
  single_file <- file.path(indices_dir, paste0("ndvi_", date_name, ".tif"))
  writeRaster(ndvi_single, single_file, overwrite = TRUE)
}
cat("✓ Individual NDVI maps saved\n")

# Save individual NBR maps
for (i in 1:nlyr(nbr_stack)) {
  nbr_single <- nbr_stack[[i]]
  date_name <- gsub("NBR_", "", names(nbr_single))
  single_file <- file.path(indices_dir, paste0("nbr_", date_name, ".tif"))
  writeRaster(nbr_single, single_file, overwrite = TRUE)
}
cat("✓ Individual NBR maps saved\n\n")

cat("========================================\n")
cat("STEP 4: SUMMARY\n")
cat("========================================\n\n")

cat("Spectral Indices Calculated:\n")
cat("  NDVI time series:", nlyr(ndvi_stack), "dates\n")
cat("  NBR time series:", nlyr(nbr_stack), "dates\n\n")

cat("Output Location:", indices_dir, "\n\n")

cat("Files Created:\n")
cat("  - ndvi_timeseries.tif (all dates)\n")
cat("  - nbr_timeseries.tif (all dates)\n")
cat("  - ndvi_YYYY-MM-DD.tif (individual dates)\n")
cat("  - nbr_YYYY-MM-DD.tif (individual dates)\n\n")

cat("========================================\n")
cat("✓ INDICES CALCULATION COMPLETE!\n")
cat("========================================\n\n")

cat("Next Steps:\n")
cat("  1. Visualize indices:\n")
cat("     plot(ndvi_stack)\n")
cat("     plot(nbr_stack)\n\n")
cat("  2. Calculate change detection:\n")
cat("     source('R/07_change_detection.R')\n\n")
cat("  3. Run NBR differencing:\n")
cat("     nbr_diff <- nbr_stack[[1]] - nbr_stack[[nlyr(nbr_stack)]]\n\n")

# Store in global environment
assign("ndvi_stack", ndvi_stack, envir = .GlobalEnv)
assign("nbr_stack", nbr_stack, envir = .GlobalEnv)

cat("Indices stored as 'ndvi_stack' and 'nbr_stack' in global environment\n\n")

