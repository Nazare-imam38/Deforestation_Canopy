# ==============================================================================
# AUTOMATED SENTINEL-2 DOWNLOAD
# ==============================================================================
# Download Sentinel-2 satellite imagery automatically
# Sentinel-2 is excellent for deforestation detection (10m resolution)
# ==============================================================================

cat("========================================\n")
cat("AUTOMATED SENTINEL-2 DOWNLOAD\n")
cat("========================================\n\n")

# Load packages and configuration
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Load study area
aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("Study Area:\n")
cat("  Coordinates: North", round(bbox[4], 4), ", South", round(bbox[2], 4),
    ", East", round(bbox[3], 4), ", West", round(bbox[1], 4), "\n")
cat("  Date Range:", START_DATE, "to", END_DATE, "\n\n")

cat("========================================\n")
cat("SENTINEL-2 DATA SOURCES\n")
cat("========================================\n\n")

cat("Sentinel-2 Advantages:\n")
cat("  ✓ 10m spatial resolution (better than Landsat 30m)\n")
cat("  ✓ Free and open access\n")
cat("  ✓ 5-day revisit time\n")
cat("  ✓ Excellent for deforestation detection\n")
cat("  ✓ Level-2A (Surface Reflectance) available\n\n")

cat("========================================\n")
cat("METHOD 1: Using getSpatialData (Recommended)\n")
cat("========================================\n\n")

# Install and load getSpatialData
if (!require(getSpatialData, quietly = TRUE)) {
  if (!require(devtools, quietly = TRUE)) {
    install.packages("devtools")
    library(devtools)
  }
  cat("Installing getSpatialData from GitHub...\n")
  devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE, force = TRUE)
  library(getSpatialData)
}

# Note: Sentinel-2 via getSpatialData may also require Copernicus login
# But let's try it first
cat("Attempting Sentinel-2 download...\n\n")

# Convert AOI to proper format
aoi_sfc <- st_geometry(aoi)
set_aoi(aoi_sfc)
cat("✓ Study area set\n\n")

# Try to search for Sentinel-2 data
tryCatch({
  cat("Searching for Sentinel-2 Level-2A data...\n")
  records <- getSentinel_records(
    time_range = c(START_DATE, END_DATE),
    products = "S2MSI2A"  # Sentinel-2 MultiSpectral Instrument Level-2A
  )
  
  if (nrow(records) > 0) {
    cat("✓ Found", nrow(records), "Sentinel-2 scenes\n\n")
    
    # Show sample
    cat("Sample scenes:\n")
    print(head(records[, c("title", "beginposition", "cloudcoverpercentage")], 3))
    cat("\n")
    
    # Limit to first 3 for download
    max_download <- min(3, nrow(records))
    cat("Downloading first", max_download, "scenes...\n\n")
    records_subset <- records[1:max_download, ]
    
    # Download
    cat("Downloading Sentinel-2 data...\n")
    cat("This may take 15-45 minutes depending on file sizes...\n\n")
    
    files <- getSentinel_data(
      records_subset,
      dir_out = LANDSAT_DIR,
      force = FALSE
    )
    
    cat("\n✓ Download complete!\n\n")
    
    # Verify
    sentinel_files <- list.files(LANDSAT_DIR, pattern = "\\.(tif|jp2|SAFE)$", 
                                 full.names = TRUE, recursive = TRUE)
    cat("Downloaded", length(sentinel_files), "files\n")
    cat("Location:", LANDSAT_DIR, "\n\n")
    
  } else {
    cat("✗ No Sentinel-2 scenes found\n")
    cat("  Try different date range\n\n")
  }
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n\n")
  
  if (grepl("login|authentication|copernicus", e$message, ignore.case = TRUE)) {
    cat("========================================\n")
    cat("COPERNICUS LOGIN REQUIRED\n")
    cat("========================================\n\n")
    cat("Sentinel-2 data requires Copernicus account (FREE):\n\n")
    cat("1. Register at: https://scihub.copernicus.eu/dhus/#/self-registration\n")
    cat("2. It's completely free\n")
    cat("3. Takes 2 minutes to register\n\n")
    cat("After registration, login in R:\n")
    cat("  library(getSpatialData)\n")
    cat("  login_Copernicus('your_username', 'your_password')\n\n")
    cat("Then run this script again.\n\n")
  }
})

# Alternative: MODIS data (no login for basic access)
cat("========================================\n")
cat("METHOD 2: MODIS Data (Alternative)\n")
cat("========================================\n\n")

cat("MODIS provides vegetation indices:\n")
cat("  - MOD13Q1: NDVI, 16-day composite, 250m resolution\n")
cat("  - Good for time-series analysis\n")
cat("  - Free NASA account required (also free)\n\n")

cat("To download MODIS:\n")
cat("  source('scripts/download_modis.R')\n\n")

cat("========================================\n")
cat("RECOMMENDATION\n")
cat("========================================\n\n")
cat("For immediate use:\n")
cat("  1. Register free Copernicus account (2 minutes)\n")
cat("  2. Login: login_Copernicus('username', 'password')\n")
cat("  3. Run this script again\n\n")

cat("Or use MODIS data which is also excellent for deforestation:\n")
cat("  source('scripts/download_modis.R')\n\n")

# Verify any downloaded files
landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.(tif|jp2|SAFE)$", 
                           full.names = TRUE, recursive = TRUE)

if (length(landsat_files) > 0) {
  cat("========================================\n")
  cat("FILES FOUND - READY FOR PROCESSING\n")
  cat("========================================\n\n")
  cat("Found", length(landsat_files), "satellite image files\n")
  cat("You can now run:\n")
  cat("  source('scripts/run_immediate_workflow.R')\n\n")
} else {
  cat("========================================\n")
  cat("NEXT STEPS\n")
  cat("========================================\n\n")
  cat("1. Register at Copernicus (free, 2 minutes)\n")
  cat("2. Login and download Sentinel-2\n")
  cat("OR\n")
  cat("3. Use MODIS data: source('scripts/download_modis.R')\n\n")
}

cat("========================================\n")
cat("DOWNLOAD PROCESS COMPLETE\n")
cat("========================================\n\n")

