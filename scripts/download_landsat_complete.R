# ==============================================================================
# COMPLETE LANDSAT DOWNLOAD WORKFLOW
# ==============================================================================
# Handles USGS login and downloads Landsat data
# ==============================================================================

cat("========================================\n")
cat("COMPLETE LANDSAT DOWNLOAD WORKFLOW\n")
cat("========================================\n\n")

# Step 1: Setup
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

aoi <- load_study_area()
bbox <- st_bbox(aoi)

# Step 2: Install and load getSpatialData
cat("STEP 1: Installing getSpatialData...\n")
cat("-----------------------------------\n")

if (!require(getSpatialData, quietly = TRUE)) {
  if (!require(devtools, quietly = TRUE)) {
    install.packages("devtools")
    library(devtools)
  }
  cat("Installing from GitHub...\n")
  devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE)
  library(getSpatialData)
}

cat("✓ getSpatialData loaded\n\n")

# Step 3: USGS Login
cat("STEP 2: USGS Login\n")
cat("------------------\n")
cat("You need to login to USGS EarthExplorer.\n")
cat("If you don't have an account, create one at:\n")
cat("  https://earthexplorer.usgs.gov/\n\n")

cat("To login, run:\n")
cat("  library(getSpatialData)\n")
cat("  login_USGS('your_username')\n")
cat("  # Enter your password when prompted\n\n")

cat("Have you logged in? (If yes, we'll proceed with download)\n")
cat("If not, please login first, then run this script again.\n\n")

# Try to proceed (will fail if not logged in, which is OK)
# Step 4: Set AOI
cat("STEP 3: Setting Study Area\n")
cat("---------------------------\n")

# Convert sf to sfc (preferred format for getSpatialData)
aoi_sfc <- st_geometry(aoi)
set_aoi(aoi_sfc)
cat("✓ Study area set\n")
cat("  Coordinates:", paste(round(bbox, 4), collapse = ", "), "\n\n")

# Step 5: Search for data
cat("STEP 4: Searching for Landsat Data\n")
cat("----------------------------------\n")
cat("Date range:", START_DATE, "to", END_DATE, "\n\n")

tryCatch({
  records <- getLandsat_records(
    time_range = c(START_DATE, END_DATE),
    products = "LANDSAT_8_C1"
  )
  
  if (nrow(records) > 0) {
    cat("✓ Found", nrow(records), "Landsat scenes\n\n")
    
    # Show sample
    cat("Sample records:\n")
    print(head(records[, c("entityId", "acquisitionDate", "cloudCover")], 3))
    cat("\n")
    
    # Limit to first 3-5 for testing
    max_download <- min(5, nrow(records))
    cat("Downloading first", max_download, "scenes...\n\n")
    records <- records[1:max_download, ]
    
    # Step 6: Download
    cat("STEP 5: Downloading Data\n")
    cat("------------------------\n")
    cat("This may take 10-30 minutes depending on file sizes...\n\n")
    
    files <- getLandsat_data(
      records,
      dir_out = LANDSAT_DIR,
      force = FALSE
    )
    
    cat("\n✓ Download complete!\n\n")
    
    # Verify
    landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", 
                               full.names = TRUE, recursive = TRUE)
    cat("Downloaded files:", length(landsat_files), "\n")
    cat("Location:", LANDSAT_DIR, "\n\n")
    
    cat("========================================\n")
    cat("DOWNLOAD SUCCESSFUL!\n")
    cat("========================================\n\n")
    cat("You can now run the analysis:\n")
    cat("  source('scripts/run_immediate_workflow.R')\n\n")
    
  } else {
    cat("✗ No scenes found\n")
    cat("  Try adjusting date range\n\n")
  }
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n\n")
  
  if (grepl("login|authentication|credentials", e$message, ignore.case = TRUE)) {
    cat("========================================\n")
    cat("USGS LOGIN REQUIRED\n")
    cat("========================================\n\n")
    cat("Please login first:\n\n")
    cat("1. Make sure you have a USGS account:\n")
    cat("   https://earthexplorer.usgs.gov/\n\n")
    cat("2. Login in R:\n")
    cat("   library(getSpatialData)\n")
    cat("   login_USGS('your_username')\n")
    cat("   # Enter password when prompted\n\n")
    cat("3. Then run this script again:\n")
    cat("   source('scripts/download_landsat_complete.R')\n\n")
  } else {
    cat("For manual download, run:\n")
    cat("  source('scripts/download_landsat_manual.R')\n\n")
  }
})

