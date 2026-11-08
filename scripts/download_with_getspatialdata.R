# ==============================================================================
# DOWNLOAD LANDSAT USING getSpatialData PACKAGE
# ==============================================================================
# Step-by-step guide for using getSpatialData package
# ==============================================================================

cat("========================================\n")
cat("DOWNLOAD LANDSAT USING getSpatialData\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Load getSpatialData
if (!require(getSpatialData, quietly = TRUE)) {
  if (!require(devtools, quietly = TRUE)) {
    install.packages("devtools")
    library(devtools)
  }
  cat("Installing getSpatialData from GitHub...\n")
  devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE)
  library(getSpatialData)
}

# Load study area
aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("STEP 1: USGS Login\n")
cat("------------------\n")
cat("You need a USGS EarthExplorer account.\n")
cat("If you don't have one:\n")
cat("  1. Visit: https://earthexplorer.usgs.gov/\n")
cat("  2. Click 'Register' (top right)\n")
cat("  3. Create free account\n\n")

cat("Login to USGS in R:\n")
cat("  library(getSpatialData)\n")
cat("  login_USGS('your_username')\n")
cat("  # Enter your password when prompted\n\n")

# Ask user if they want to login now
cat("Do you want to login now? (y/n): ")
# For automated script, we'll try to login
# In interactive mode, user can login manually

# STEP 2: Set AOI
cat("\nSTEP 2: Setting Study Area\n")
cat("---------------------------\n")

# Convert to proper format - try multiple formats
aoi_set <- FALSE

# Try 1: Convert sf to sfc
tryCatch({
  aoi_sfc <- st_geometry(aoi)
  set_aoi(aoi_sfc)
  cat("✓ Study area set (using sfc format)\n")
  aoi_set <- TRUE
}, error = function(e) {
  cat("  Format 1 failed, trying alternative...\n")
})

# Try 2: Use bounding box matrix
if (!aoi_set) {
  tryCatch({
    bbox_matrix <- matrix(
      c(bbox[1], bbox[2], bbox[3], bbox[4]),
      nrow = 2, ncol = 2,
      dimnames = list(c("x", "y"), c("min", "max"))
    )
    set_aoi(bbox_matrix)
    cat("✓ Study area set (using bounding box matrix)\n")
    aoi_set <- TRUE
  }, error = function(e) {
    cat("  Format 2 failed, trying alternative...\n")
  })
}

# Try 3: Convert to SpatialPolygons
if (!aoi_set && require(sp, quietly = TRUE)) {
  tryCatch({
    aoi_sp <- as(aoi, "Spatial")
    set_aoi(aoi_sp)
    cat("✓ Study area set (using SpatialPolygons format)\n")
    aoi_set <- TRUE
  }, error = function(e) {
    cat("  Format 3 failed\n")
  })
}

if (!aoi_set) {
  cat("✗ Could not set AOI. Using manual coordinates.\n")
  cat("  Coordinates for manual search:\n")
  cat("    North:", bbox[4], "\n")
  cat("    South:", bbox[2], "\n")
  cat("    East:", bbox[3], "\n")
  cat("    West:", bbox[1], "\n\n")
  stop("AOI setup failed")
}

# STEP 3: Search for data
cat("\nSTEP 3: Searching for Landsat Data\n")
cat("-----------------------------------\n")
cat("Date range:", START_DATE, "to", END_DATE, "\n\n")

tryCatch({
  records <- getLandsat_records(
    time_range = c(START_DATE, END_DATE),
    products = "LANDSAT_8_C1"  # Landsat 8 Collection 1
  )
  
  if (nrow(records) > 0) {
    cat("✓ Found", nrow(records), "Landsat scenes\n\n")
    
    # Show first few records
    cat("Sample records:\n")
    print(head(records[, c("entityId", "acquisitionDate", "cloudCover")], 5))
    cat("\n")
    
    # Limit to first 5 for initial download
    if (nrow(records) > 5) {
      cat("Limiting to first 5 scenes for initial download...\n")
      records <- records[1:5, ]
    }
    
    # STEP 4: Download
    cat("\nSTEP 4: Downloading Landsat Data\n")
    cat("---------------------------------\n")
    cat("This may take a while depending on file sizes...\n\n")
    
    files <- getLandsat_data(
      records,
      dir_out = LANDSAT_DIR,
      force = FALSE
    )
    
    cat("\n✓ Download complete!\n")
    cat("Files saved to:", LANDSAT_DIR, "\n\n")
    
    # Verify
    landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", 
                               full.names = TRUE, recursive = TRUE)
    cat("Downloaded files:", length(landsat_files), "\n\n")
    
  } else {
    cat("✗ No Landsat scenes found\n")
    cat("  Try adjusting date range or search criteria\n\n")
  }
  
}, error = function(e) {
  cat("✗ Search failed:", e$message, "\n\n")
  
  if (grepl("login|authentication", e$message, ignore.case = TRUE)) {
    cat("USGS LOGIN REQUIRED!\n")
    cat("Run these commands:\n")
    cat("  library(getSpatialData)\n")
    cat("  login_USGS('your_username')\n")
    cat("  # Enter password\n")
    cat("Then run this script again.\n\n")
  }
})

cat("========================================\n")
cat("DOWNLOAD PROCESS COMPLETE\n")
cat("========================================\n\n")

cat("If download was successful, you can now run:\n")
cat("  source('scripts/run_immediate_workflow.R')\n\n")

