# ==============================================================================
# VERIFY DOWNLOADED LANDSAT DATA
# ==============================================================================
# Check if downloaded Landsat files are ready for processing
# ==============================================================================

cat("========================================\n")
cat("VERIFYING DOWNLOADED LANDSAT DATA\n")
cat("========================================\n\n")

source("R/01_config.R")

# Check for Landsat files
cat("Checking for Landsat files...\n")
landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", 
                           full.names = TRUE, recursive = TRUE)

if (length(landsat_files) == 0) {
  cat("✗ No Landsat files found in", LANDSAT_DIR, "\n\n")
  cat("Please download Landsat data and place .tif files in:\n")
  cat("  ", LANDSAT_DIR, "\n\n")
  stop("No Landsat data found")
}

cat("✓ Found", length(landsat_files), "Landsat files\n\n")

# Check file structure
cat("Checking file structure...\n")
sample_file <- landsat_files[1]
cat("Sample file:", basename(sample_file), "\n")

# Try to read a file
if (require(terra, quietly = TRUE)) {
  tryCatch({
    test_raster <- rast(sample_file)
    cat("✓ Files are readable\n")
    cat("  Dimensions:", dim(test_raster), "\n")
    cat("  CRS:", crs(test_raster), "\n")
    cat("  Bands:", nlyr(test_raster), "\n\n")
  }, error = function(e) {
    cat("✗ Error reading file:", e$message, "\n\n")
  })
}

# List all files
cat("Downloaded files:\n")
for (i in 1:min(10, length(landsat_files))) {
  cat("  ", i, ":", basename(landsat_files[i]), "\n")
}
if (length(landsat_files) > 10) {
  cat("  ... and", length(landsat_files) - 10, "more files\n")
}
cat("\n")

# Check if files are in correct location
cat("File locations:\n")
unique_dirs <- unique(dirname(landsat_files))
for (dir in unique_dirs) {
  files_in_dir <- sum(dirname(landsat_files) == dir)
  cat("  ", dir, ":", files_in_dir, "files\n")
}
cat("\n")

cat("========================================\n")
cat("VERIFICATION COMPLETE\n")
cat("========================================\n\n")

if (length(landsat_files) > 0) {
  cat("✓ Data is ready for processing!\n\n")
  cat("Next steps:\n")
  cat("  1. Run preprocessing:\n")
  cat("     source('R/05_preprocessing.R')\n")
  cat("     source('R/03_load_study_area.R')\n")
  cat("     aoi <- load_study_area()\n")
  cat("     landsat <- preprocess_landsat(data_dir = '", LANDSAT_DIR, "', aoi = aoi)\n\n", sep = "")
  
  cat("  2. Or run complete workflow:\n")
  cat("     source('scripts/main_workflow.R')\n\n")
} else {
  cat("✗ No valid Landsat data found\n")
  cat("  Please download data first\n\n")
}

