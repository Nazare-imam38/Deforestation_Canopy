# ==============================================================================
# DEFORESTATION CHANGE DETECTION
# ==============================================================================
# Detects deforestation using NBR differencing and NDVI change
# ==============================================================================

cat("========================================\n")
cat("DEFORESTATION CHANGE DETECTION\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")

# Load indices if not already loaded
if (!exists("ndvi_stack") || !exists("nbr_stack")) {
  cat("Loading spectral indices...\n")
  indices_dir <- file.path(OUTPUT_DIR, "indices")
  
  ndvi_file <- file.path(indices_dir, "ndvi_timeseries.tif")
  nbr_file <- file.path(indices_dir, "nbr_timeseries.tif")
  
  if (file.exists(ndvi_file)) {
    ndvi_stack <- rast(ndvi_file)
    cat("✓ Loaded NDVI time series\n")
  } else {
    stop("NDVI time series not found. Run: source('scripts/calculate_indices_from_processed.R')")
  }
  
  if (file.exists(nbr_file)) {
    nbr_stack <- rast(nbr_file)
    cat("✓ Loaded NBR time series\n\n")
  } else {
    stop("NBR time series not found. Run: source('scripts/calculate_indices_from_processed.R')")
  }
}

cat("Time series information:\n")
cat("  NDVI dates:", paste(names(ndvi_stack), collapse = ", "), "\n")
cat("  NBR dates:", paste(names(nbr_stack), collapse = ", "), "\n\n")

cat("========================================\n")
cat("STEP 1: CALCULATING CHANGE DETECTION\n")
cat("========================================\n\n")

# Get first and last dates
first_date <- names(ndvi_stack)[1]
last_date <- names(ndvi_stack)[nlyr(ndvi_stack)]

cat("Comparing:", first_date, "to", last_date, "\n\n")

# NDVI Change
cat("Calculating NDVI change...\n")
ndvi_first <- ndvi_stack[[1]]
ndvi_last <- ndvi_stack[[nlyr(ndvi_stack)]]
ndvi_change <- ndvi_last - ndvi_first
names(ndvi_change) <- "NDVI_Change"
cat("✓ NDVI change calculated\n")
cat("  Range:", round(minmax(ndvi_change)[1], 3), "to", round(minmax(ndvi_change)[2], 3), "\n\n")

# NBR Change (dNBR - most important for deforestation)
cat("Calculating NBR change (dNBR)...\n")
nbr_first <- nbr_stack[[1]]
nbr_last <- nbr_stack[[nlyr(nbr_stack)]]
dNBR <- nbr_first - nbr_last  # First minus last (positive = loss)
names(dNBR) <- "dNBR"
cat("✓ dNBR calculated\n")
cat("  Range:", round(minmax(dNBR)[1], 3), "to", round(minmax(dNBR)[2], 3), "\n\n")

# Relative dNBR (RdNBR) - normalized by initial NBR
cat("Calculating Relative dNBR (RdNBR)...\n")
rdNBR <- dNBR / sqrt(abs(nbr_first))
# Handle division by zero
rdNBR[is.infinite(rdNBR)] <- NA
names(rdNBR) <- "RdNBR"
cat("✓ RdNBR calculated\n\n")

cat("========================================\n")
cat("STEP 2: CLASSIFYING DEFORESTATION\n")
cat("========================================\n\n")

# dNBR thresholds for deforestation classification
# Based on USGS Fire Severity Mapping standards, adapted for deforestation
cat("Classifying deforestation severity using dNBR...\n")

# Create deforestation classification
deforestation_class <- dNBR
values(deforestation_class) <- NA

# Get values
dNBR_vals <- values(dNBR)
nbr_first_vals <- values(nbr_first)

# Classification thresholds
# Negative dNBR = vegetation gain (reforestation)
# 0 to 0.1 = No change / Unburned
# 0.1 to 0.27 = Low severity / Low deforestation
# 0.27 to 0.44 = Moderate severity / Moderate deforestation  
# 0.44 to 0.66 = High severity / High deforestation
# > 0.66 = Very high severity / Severe deforestation

deforestation_vals <- rep(NA, length(dNBR_vals))

# Classify
deforestation_vals[dNBR_vals < -0.1] <- 1  # Reforestation/Gain
deforestation_vals[dNBR_vals >= -0.1 & dNBR_vals < 0.1] <- 2  # No change
deforestation_vals[dNBR_vals >= 0.1 & dNBR_vals < 0.27] <- 3  # Low deforestation
deforestation_vals[dNBR_vals >= 0.27 & dNBR_vals < 0.44] <- 4  # Moderate deforestation
deforestation_vals[dNBR_vals >= 0.44 & dNBR_vals < 0.66] <- 5  # High deforestation
deforestation_vals[dNBR_vals >= 0.66] <- 6  # Severe deforestation

values(deforestation_class) <- deforestation_vals
names(deforestation_class) <- "Deforestation_Class"

# Calculate statistics
cat("Deforestation Classification:\n")
for (i in 1:6) {
  count <- sum(deforestation_vals == i, na.rm = TRUE)
  pct <- round(count / length(deforestation_vals[!is.na(deforestation_vals)]) * 100, 2)
  class_name <- c("Reforestation", "No Change", "Low", "Moderate", "High", "Severe")[i]
  cat("  Class", i, "(", class_name, "):", count, "pixels (", pct, "%)\n")
}
cat("\n")

# Calculate deforestation area (classes 3-6)
deforestation_mask <- deforestation_class >= 3 & deforestation_class <= 6
deforestation_area_pixels <- sum(values(deforestation_mask), na.rm = TRUE)

# Calculate area in hectares (assuming 30m pixel size)
pixel_area_ha <- (30 * 30) / 10000  # 30m x 30m = 0.09 hectares per pixel
deforestation_area_ha <- deforestation_area_pixels * pixel_area_ha

cat("Deforestation Statistics:\n")
cat("  Deforestation pixels:", deforestation_area_pixels, "\n")
cat("  Deforestation area:", round(deforestation_area_ha, 2), "hectares\n")
cat("  Deforestation area:", round(deforestation_area_ha / 100, 2), "km²\n\n")

cat("========================================\n")
cat("STEP 3: SAVING RESULTS\n")
cat("========================================\n\n")

# Create output directory
change_dir <- file.path(OUTPUT_DIR, "change_detection")
dir.create(change_dir, showWarnings = FALSE, recursive = TRUE)

# Save change maps
writeRaster(ndvi_change, file.path(change_dir, "ndvi_change.tif"), overwrite = TRUE)
cat("✓ NDVI change saved\n")

writeRaster(dNBR, file.path(change_dir, "dnbr.tif"), overwrite = TRUE)
cat("✓ dNBR saved\n")

writeRaster(rdNBR, file.path(change_dir, "rdnbr.tif"), overwrite = TRUE)
cat("✓ RdNBR saved\n")

writeRaster(deforestation_class, file.path(change_dir, "deforestation_classification.tif"), overwrite = TRUE)
cat("✓ Deforestation classification saved\n\n")

cat("========================================\n")
cat("STEP 4: GENERATING SUMMARY STATISTICS\n")
cat("========================================\n\n")

# Create summary statistics
summary_stats <- data.frame(
  Metric = c(
    "NDVI Change (mean)",
    "NDVI Change (min)",
    "NDVI Change (max)",
    "dNBR (mean)",
    "dNBR (min)",
    "dNBR (max)",
    "Deforestation Area (ha)",
    "Deforestation Area (km²)",
    "Deforestation %"
  ),
  Value = c(
    round(mean(values(ndvi_change), na.rm = TRUE), 4),
    round(min(values(ndvi_change), na.rm = TRUE), 4),
    round(max(values(ndvi_change), na.rm = TRUE), 4),
    round(mean(values(dNBR), na.rm = TRUE), 4),
    round(min(values(dNBR), na.rm = TRUE), 4),
    round(max(values(dNBR), na.rm = TRUE), 4),
    round(deforestation_area_ha, 2),
    round(deforestation_area_ha / 100, 2),
    round(deforestation_area_pixels / length(deforestation_vals[!is.na(deforestation_vals)]) * 100, 2)
  )
)

# Save statistics
stats_file <- file.path(change_dir, "deforestation_statistics.csv")
write.csv(summary_stats, stats_file, row.names = FALSE)
cat("✓ Statistics saved:", stats_file, "\n\n")

print(summary_stats)
cat("\n")

cat("========================================\n")
cat("STEP 5: CREATING VISUALIZATIONS\n")
cat("========================================\n\n")

# Create maps directory
maps_dir <- file.path(OUTPUT_DIR, "maps")
dir.create(maps_dir, showWarnings = FALSE, recursive = TRUE)

cat("Visualization files will be created in:", maps_dir, "\n")
cat("You can plot them using:\n")
cat("  plot(ndvi_change, main = 'NDVI Change')\n")
cat("  plot(dNBR, main = 'dNBR - Deforestation Indicator')\n")
cat("  plot(deforestation_class, main = 'Deforestation Classification')\n\n")

cat("========================================\n")
cat("✓ CHANGE DETECTION COMPLETE!\n")
cat("========================================\n\n")

cat("Results Summary:\n")
cat("  - NDVI Change: Shows vegetation change\n")
cat("  - dNBR: Primary deforestation indicator (positive = loss)\n")
cat("  - Deforestation Classification: 6 classes from reforestation to severe\n")
cat("  - Statistics: Area calculations and percentages\n\n")

cat("Output Location:", change_dir, "\n\n")

cat("Next Steps:\n")
cat("  1. Visualize results:\n")
cat("     plot(dNBR, main = 'Deforestation (dNBR)')\n")
cat("     plot(deforestation_class, main = 'Deforestation Classification')\n\n")
cat("  2. Export maps:\n")
cat("     source('R/09_visualization.R')\n\n")
cat("  3. Land cover classification:\n")
cat("     source('R/08_classification.R')\n\n")

# Store in global environment
assign("ndvi_change", ndvi_change, envir = .GlobalEnv)
assign("dNBR", dNBR, envir = .GlobalEnv)
assign("rdNBR", rdNBR, envir = .GlobalEnv)
assign("deforestation_class", deforestation_class, envir = .GlobalEnv)

cat("Change detection results stored in global environment\n\n")

