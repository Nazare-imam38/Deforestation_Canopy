# ==============================================================================
# PROCESS MANUALLY DOWNLOADED LANDSAT FILES
# ==============================================================================
# Processes the Landsat files you've manually downloaded
# ==============================================================================

cat("========================================\n")
cat("PROCESSING MANUAL LANDSAT FILES\n")
cat("========================================\n\n")

source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Load study area
aoi <- load_study_area()

cat("Study Area:", STUDY_AREA_NAME, "\n")
cat("Date Range:", START_DATE, "to", END_DATE, "\n\n")

cat("========================================\n")
cat("STEP 1: SCANNING LANDSAT FILES\n")
cat("========================================\n\n")

# Find all Landsat Surface Reflectance bands
sr_files <- list.files(LANDSAT_DIR, 
                       pattern = "SR_B[1-7]\\.TIF$", 
                       full.names = TRUE, 
                       recursive = TRUE,
                       ignore.case = TRUE)

if (length(sr_files) == 0) {
  stop("No Landsat Surface Reflectance files found in ", LANDSAT_DIR)
}

cat("Found", length(sr_files), "Surface Reflectance band files\n\n")

# Group files by scene
scene_pattern <- "LC(08|09)_L2SP_\\d+_\\d{8}_\\d{8}_\\d{2}_T1"
scene_ids <- unique(gsub(paste0(".*(", scene_pattern, ").*"), "\\1", sr_files))

cat("Detected", length(scene_ids), "Landsat scenes:\n")
for (i in 1:length(scene_ids)) {
  # Extract date
  date_match <- regmatches(scene_ids[i], regexpr("_\\d{8}_", scene_ids[i]))
  scene_date <- substr(date_match, 2, 9)
  formatted_date <- paste(substr(scene_date, 1, 4), 
                         substr(scene_date, 5, 6), 
                         substr(scene_date, 7, 8), sep = "-")
  
  # Detect Landsat version
  landsat_version <- ifelse(grepl("LC09", scene_ids[i]), "Landsat 9", "Landsat 8")
  
  cat("  ", i, ":", landsat_version, "-", formatted_date, "\n")
}
cat("\n")

cat("========================================\n")
cat("STEP 2: LOADING AND STACKING BANDS\n")
cat("========================================\n\n")

# Function to load a single scene
load_landsat_scene <- function(scene_id) {
  cat("Loading scene:", scene_id, "\n")
  
  # Find all bands for this scene
  scene_files <- sr_files[grepl(scene_id, sr_files)]
  
  # Sort by band number
  band_numbers <- as.numeric(gsub(".*SR_B(\\d+)\\.TIF$", "\\1", scene_files, ignore.case = TRUE))
  scene_files <- scene_files[order(band_numbers)]
  
  cat("  Found", length(scene_files), "bands\n")
  
  # Load bands
  bands <- lapply(scene_files, function(f) {
    tryCatch({
      r <- rast(f)
      return(r)
    }, error = function(e) {
      cat("    ✗ Error loading", basename(f), ":", e$message, "\n")
      return(NULL)
    })
  })
  
  # Remove NULLs
  bands <- bands[!sapply(bands, is.null)]
  
  if (length(bands) == 0) {
    cat("  ✗ Failed to load any bands\n")
    return(NULL)
  }
  
  # Stack bands
  cat("  Stacking", length(bands), "bands...\n")
  stacked <- rast(bands)
  
  # Name bands
  band_names <- paste0("B", 1:length(bands))
  names(stacked) <- band_names
  
  cat("  ✓ Scene loaded: ", nrow(stacked), "x", ncol(stacked), 
      ", ", nlyr(stacked), " bands\n\n")
  
  return(stacked)
}

# Load all scenes
scenes <- lapply(scene_ids, load_landsat_scene)
scenes <- scenes[!sapply(scenes, is.null)]

if (length(scenes) == 0) {
  stop("Failed to load any Landsat scenes")
}

cat("✓ Successfully loaded", length(scenes), "scenes\n\n")

cat("========================================\n")
cat("STEP 3: PREPROCESSING\n")
cat("========================================\n\n")

# Align all scenes to same grid
cat("Aligning scenes to common grid...\n")

# Get common extent (union of all scenes)
# Calculate min/max coordinates from all extents
extents <- lapply(scenes, ext)
extent_values <- lapply(extents, function(e) as.vector(e))
xmin <- min(sapply(extent_values, function(v) v[1]))
xmax <- max(sapply(extent_values, function(v) v[2]))
ymin <- min(sapply(extent_values, function(v) v[3]))
ymax <- max(sapply(extent_values, function(v) v[4]))
common_ext <- ext(xmin, xmax, ymin, ymax)

# Get common CRS (use first scene)
common_crs <- crs(scenes[[1]])

# Create template
template <- rast(ext = common_ext, 
                 crs = common_crs, 
                 resolution = c(30, 30))  # 30m for Landsat

cat("  Template: ", nrow(template), "x", ncol(template), 
    " pixels, ", crs(template), "\n")

# Resample all scenes to template
scenes_aligned <- lapply(1:length(scenes), function(i) {
  cat("  Aligning scene", i, "of", length(scenes), "...\n")
  resample(scenes[[i]], template, method = "bilinear")
})

cat("✓ All scenes aligned\n\n")

# Clip to study area (optional - skip if extents don't overlap)
cat("Clipping to study area (optional)...\n")

tryCatch({
  aoi_vect <- vect(aoi)
  
  # Reproject AOI if needed
  if (crs(aoi_vect) != crs(template)) {
    cat("  Reprojecting AOI...\n")
    aoi_vect <- project(aoi_vect, crs(template))
  }
  
  # Check if extents overlap
  scene_ext <- ext(scenes_aligned[[1]])
  aoi_ext <- ext(aoi_vect)
  
  # Check overlap
  if (scene_ext$xmin > aoi_ext$xmax || scene_ext$xmax < aoi_ext$xmin ||
      scene_ext$ymin > aoi_ext$ymax || scene_ext$ymax < aoi_ext$ymin) {
    cat("  ⚠ Extents do not overlap - skipping clipping\n")
    cat("  Processing entire scenes (you manually downloaded for your study area)\n\n")
    scenes_clipped <- scenes_aligned
  } else {
    # Clip each scene
    scenes_clipped <- lapply(1:length(scenes_aligned), function(i) {
      cat("  Clipping scene", i, "of", length(scenes_aligned), "...\n")
      tryCatch({
        cropped <- crop(scenes_aligned[[i]], aoi_vect)
        masked <- mask(cropped, aoi_vect)
        return(masked)
      }, error = function(e) {
        cat("    ⚠ Clipping failed, using entire scene:", e$message, "\n")
        return(scenes_aligned[[i]])
      })
    })
    cat("✓ All scenes clipped to study area\n\n")
  }
}, error = function(e) {
  cat("  ⚠ Clipping failed:", e$message, "\n")
  cat("  Processing entire scenes (you manually downloaded for your study area)\n\n")
  scenes_clipped <- scenes_aligned
})

# If multiple scenes, create time series stack
if (length(scenes_clipped) > 1) {
  cat("Creating time series stack from", length(scenes_clipped), "scenes...\n")
  
  # Ensure all have same number of bands
  n_bands <- min(sapply(scenes_clipped, nlyr))
  scenes_clipped <- lapply(scenes_clipped, function(s) {
    if (nlyr(s) > n_bands) {
      return(s[[1:n_bands]])
    }
    return(s)
  })
  
  # Stack as time series
  # Note: This creates a multi-temporal stack
  # Each layer represents a different date
  cat("  Stacking", length(scenes_clipped), "scenes...\n")
  time_series_stack <- rast(scenes_clipped)
  
  # Name layers with dates
  dates <- gsub(".*_(\\d{8})_.*", "\\1", scene_ids[1:length(scenes_clipped)])
  formatted_dates <- paste0(substr(dates, 1, 4), "-", 
                           substr(dates, 5, 6), "-", 
                           substr(dates, 7, 8))
  
  # For each date, name bands
  layer_names <- c()
  for (i in 1:length(formatted_dates)) {
    for (b in 1:n_bands) {
      layer_names <- c(layer_names, paste0("B", b, "_", formatted_dates[i]))
    }
  }
  names(time_series_stack) <- layer_names[1:nlyr(time_series_stack)]
  
  cat("✓ Time series stack created:", nlyr(time_series_stack), "layers\n\n")
  
  # Save processed stack
  output_file <- file.path(LANDSAT_DIR, "processed_landsat_stack.tif")
  cat("Saving processed stack to:", output_file, "\n")
  writeRaster(time_series_stack, output_file, overwrite = TRUE)
  cat("✓ Saved!\n\n")
  
  # Also save individual scenes for easier access
  for (i in 1:length(scenes_clipped)) {
    scene_output <- file.path(LANDSAT_DIR, 
                             paste0("processed_scene_", formatted_dates[i], ".tif"))
    writeRaster(scenes_clipped[[i]], scene_output, overwrite = TRUE)
  }
  cat("✓ Individual scenes saved\n\n")
  
  processed_data <- time_series_stack
  
} else {
  # Single scene
  cat("Single scene - using directly\n\n")
  processed_data <- scenes_clipped[[1]]
  
  # Save
  output_file <- file.path(LANDSAT_DIR, "processed_landsat.tif")
  writeRaster(processed_data, output_file, overwrite = TRUE)
  cat("✓ Saved to:", output_file, "\n\n")
}

cat("========================================\n")
cat("STEP 4: SUMMARY\n")
cat("========================================\n\n")

cat("Processed Landsat Data:\n")
cat("  Scenes:", length(scenes_clipped), "\n")
cat("  Bands per scene:", nlyr(scenes_clipped[[1]]), "\n")
cat("  Total layers:", nlyr(processed_data), "\n")
cat("  Dimensions:", nrow(processed_data), "x", ncol(processed_data), "\n")
cat("  CRS:", crs(processed_data), "\n")
cat("  Extent:", paste(round(ext(processed_data)[], 4), collapse = ", "), "\n\n")

cat("Band Information:\n")
cat("  B1: Coastal/Aerosol\n")
cat("  B2: Blue\n")
cat("  B3: Green\n")
cat("  B4: Red\n")
cat("  B5: Near Infrared (NIR)\n")
cat("  B6: SWIR 1\n")
cat("  B7: SWIR 2\n\n")

cat("========================================\n")
cat("✓ PROCESSING COMPLETE!\n")
cat("========================================\n\n")

cat("Next steps:\n")
cat("  1. Calculate spectral indices:\n")
cat("     source('R/06_spectral_indices.R')\n")
cat("     indices <- calculate_spectral_indices(processed_data)\n\n")
cat("  2. Run complete workflow:\n")
cat("     source('scripts/run_immediate_workflow.R')\n\n")

# Store processed data globally for use in other scripts
assign("processed_landsat", processed_data, envir = .GlobalEnv)
assign("landsat_scenes", scenes_clipped, envir = .GlobalEnv)

cat("Processed data stored as 'processed_landsat' in global environment\n\n")

