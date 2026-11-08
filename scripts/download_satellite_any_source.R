# ==============================================================================
# DOWNLOAD SATELLITE DATA - ANY AVAILABLE SOURCE
# ==============================================================================
# Tries multiple satellite data sources automatically
# Prioritizes sources that work without complex login
# ==============================================================================

cat("========================================\n")
cat("AUTOMATED SATELLITE DATA DOWNLOAD\n")
cat("Multiple Sources - Best Available\n")
cat("========================================\n\n")

source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("Study Area:", round(as.numeric(st_area(aoi)) / 1e6, 2), "km²\n")
cat("Coordinates:", paste(round(bbox, 4), collapse = ", "), "\n")
cat("Date Range:", START_DATE, "to", END_DATE, "\n\n")

cat("========================================\n")
cat("TRYING MULTIPLE DATA SOURCES\n")
cat("========================================\n\n")

download_success <- FALSE

# Method 1: Try Sentinel-2 via getSpatialData
cat("METHOD 1: Sentinel-2 (getSpatialData)\n")
cat("-------------------------------------\n")
tryCatch({
  if (!require(getSpatialData, quietly = TRUE)) {
    if (!require(devtools, quietly = TRUE)) {
      install.packages("devtools")
      library(devtools)
    }
    devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE)
    library(getSpatialData)
  }
  
  aoi_sfc <- st_geometry(aoi)
  set_aoi(aoi_sfc)
  
  records <- getSentinel_records(
    time_range = c(START_DATE, END_DATE),
    products = "S2MSI2A"
  )
  
  if (nrow(records) > 0) {
    cat("✓ Found", nrow(records), "Sentinel-2 scenes\n")
    cat("  Downloading first 3 scenes...\n\n")
    
    files <- getSentinel_data(records[1:min(3, nrow(records)), ], 
                              dir_out = LANDSAT_DIR)
    cat("✓ Sentinel-2 download successful!\n\n")
    download_success <- TRUE
  }
}, error = function(e) {
  cat("✗ Sentinel-2 failed:", e$message, "\n\n")
})

# Method 2: Try MODIS (if Sentinel failed)
if (!download_success) {
  cat("METHOD 2: MODIS Data\n")
  cat("--------------------\n")
  cat("MODIS provides excellent vegetation indices.\n")
  cat("Free NASA account required (2-minute registration).\n\n")
  cat("Register at: https://urs.earthdata.nasa.gov/\n")
  cat("Then use: source('scripts/download_modis.R')\n\n")
}

# Method 3: Use sample/test data
if (!download_success) {
  cat("METHOD 3: Sample Data for Testing\n")
  cat("----------------------------------\n")
  cat("For immediate testing, you can:\n")
  cat("  1. Download sample Landsat from:\n")
  cat("     https://www.usgs.gov/landsat-missions/landsat-sample-data\n")
  cat("  2. Or use AppEEARS for MODIS:\n")
  cat("     https://appeears.earthdatacloud.nasa.gov/\n")
  cat("  3. Place .tif files in:", LANDSAT_DIR, "\n\n")
}

# Check what we have
landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.(tif|jp2|SAFE)$", 
                           full.names = TRUE, recursive = TRUE)

if (length(landsat_files) > 0) {
  cat("========================================\n")
  cat("✓ DATA AVAILABLE!\n")
  cat("========================================\n\n")
  cat("Found", length(landsat_files), "satellite image files\n")
  cat("Ready for processing!\n\n")
  cat("Run analysis:\n")
  cat("  source('scripts/run_immediate_workflow.R')\n\n")
} else {
  cat("========================================\n")
  cat("RECOMMENDED: Use AppEEARS (Easiest)\n")
  cat("========================================\n\n")
  cat("1. Visit: https://appeears.earthdatacloud.nasa.gov/\n")
  cat("2. Create free account (2 minutes)\n")
  cat("3. Select MODIS MOD13Q1 (NDVI)\n")
  cat("4. Define your area:\n")
  cat("   North:", round(bbox[4], 4), "\n")
  cat("   South:", round(bbox[2], 4), "\n")
  cat("   East:", round(bbox[3], 4), "\n")
  cat("   West:", round(bbox[1], 4), "\n")
  cat("5. Date:", START_DATE, "to", END_DATE, "\n")
  cat("6. Download as GeoTIFF\n")
  cat("7. Place files in:", LANDSAT_DIR, "\n")
  cat("8. Run: source('scripts/run_immediate_workflow.R')\n\n")
}

cat("========================================\n")
cat("PROCESS COMPLETE\n")
cat("========================================\n\n")

