# ==============================================================================
# VERIFY MANUALLY DOWNLOADED LANDSAT FILES
# ==============================================================================
# Checks and verifies Landsat files placed manually in data/Landsat/
# ==============================================================================

cat("========================================\n")
cat("VERIFYING MANUALLY DOWNLOADED LANDSAT FILES\n")
cat("========================================\n\n")

source("R/00_setup_packages.R")
source("R/01_config.R")

# Check directory
if (!dir.exists(LANDSAT_DIR)) {
  stop("Directory not found: ", LANDSAT_DIR)
}

cat("Checking directory:", LANDSAT_DIR, "\n\n")

# Find all image files
image_files <- list.files(LANDSAT_DIR, 
                         pattern = "\\.(tif|TIF|tiff|TIFF|jp2|JP2)$", 
                         full.names = TRUE, 
                         recursive = TRUE)

# Also check for compressed files
compressed_files <- list.files(LANDSAT_DIR,
                              pattern = "\\.(tar|gz|zip)$",
                              full.names = TRUE,
                              recursive = TRUE)

cat("========================================\n")
cat("FILE INVENTORY\n")
cat("========================================\n\n")

if (length(image_files) > 0) {
  cat("✓ Found", length(image_files), "image files:\n\n")
  
  # Group by type
  tif_files <- image_files[grepl("\\.tif", image_files, ignore.case = TRUE)]
  jp2_files <- image_files[grepl("\\.jp2", image_files, ignore.case = TRUE)]
  
  if (length(tif_files) > 0) {
    cat("GeoTIFF files (", length(tif_files), "):\n", sep = "")
    for (i in 1:min(10, length(tif_files))) {
      file_info <- file.info(tif_files[i])
      cat("  ", i, ":", basename(tif_files[i]), 
          " (", round(file_info$size / 1e6, 2), " MB)\n", sep = "")
    }
    if (length(tif_files) > 10) {
      cat("  ... and", length(tif_files) - 10, "more files\n")
    }
    cat("\n")
  }
  
  if (length(jp2_files) > 0) {
    cat("JP2 files (", length(jp2_files), "):\n", sep = "")
    for (i in 1:min(10, length(jp2_files))) {
      file_info <- file.info(jp2_files[i])
      cat("  ", i, ":", basename(jp2_files[i]),
          " (", round(file_info$size / 1e6, 2), " MB)\n", sep = "")
    }
    if (length(jp2_files) > 10) {
      cat("  ... and", length(jp2_files) - 10, "more files\n")
    }
    cat("\n")
  }
} else {
  cat("⚠ No image files found (.tif, .jp2)\n\n")
}

if (length(compressed_files) > 0) {
  cat("Compressed files (", length(compressed_files), "):\n", sep = "")
  for (i in 1:length(compressed_files)) {
    file_info <- file.info(compressed_files[i])
    cat("  ", i, ":", basename(compressed_files[i]),
        " (", round(file_info$size / 1e6, 2), " MB)\n", sep = "")
  }
  cat("\n")
  cat("Note: Compressed files may need extraction.\n")
  cat("      Extract .tar or .tar.gz files to get .tif files.\n\n")
}

# Try to read a sample file to verify
cat("========================================\n")
cat("VERIFYING FILE FORMATS\n")
cat("========================================\n\n")

if (length(image_files) > 0) {
  # Try to read first file
  sample_file <- image_files[1]
  cat("Testing sample file:", basename(sample_file), "\n")
  
  tryCatch({
    # Try with terra
    test_raster <- rast(sample_file)
    
    cat("✓ File is readable!\n")
    cat("  Dimensions:", nrow(test_raster), "x", ncol(test_raster), "\n")
    cat("  Bands:", nlyr(test_raster), "\n")
    cat("  CRS:", crs(test_raster), "\n")
    cat("  Extent:", paste(round(ext(test_raster)[], 4), collapse = ", "), "\n\n")
    
    # Detect Landsat type
    filename <- basename(sample_file)
    if (grepl("LC08|LC09|LANDSAT_8|LANDSAT_9", filename, ignore.case = TRUE)) {
      cat("✓ Detected: Landsat 8/9\n")
    } else if (grepl("LC05|LC07|LANDSAT_5|LANDSAT_7", filename, ignore.case = TRUE)) {
      cat("✓ Detected: Landsat 5/7\n")
    } else if (grepl("S2|SENTINEL", filename, ignore.case = TRUE)) {
      cat("✓ Detected: Sentinel-2\n")
    } else if (grepl("MOD13|MOD09|MOD16", filename, ignore.case = TRUE)) {
      cat("✓ Detected: MODIS\n")
    } else {
      cat("⚠ Could not detect satellite type from filename\n")
    }
    cat("\n")
    
  }, error = function(e) {
    cat("✗ Error reading file:", e$message, "\n")
    cat("  File may be corrupted or in unsupported format\n\n")
  })
} else {
  cat("⚠ No image files to verify\n\n")
}

# Summary
cat("========================================\n")
cat("SUMMARY\n")
cat("========================================\n\n")

total_files <- length(image_files) + length(compressed_files)

if (total_files > 0) {
  cat("✓ Found", total_files, "files total\n")
  cat("  - Image files:", length(image_files), "\n")
  cat("  - Compressed files:", length(compressed_files), "\n\n")
  
  if (length(image_files) > 0) {
    cat("✓ Ready for processing!\n")
    cat("  Run: source('scripts/run_immediate_workflow.R')\n\n")
  } else if (length(compressed_files) > 0) {
    cat("⚠ Extract compressed files first\n")
    cat("  Then run this script again to verify\n\n")
  }
} else {
  cat("✗ No files found in", LANDSAT_DIR, "\n")
  cat("  Please place Landsat .tif files in this directory\n\n")
}

cat("========================================\n")
cat("VERIFICATION COMPLETE\n")
cat("========================================\n\n")

