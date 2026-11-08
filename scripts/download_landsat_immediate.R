# ==============================================================================
# IMMEDIATE LANDSAT DOWNLOAD - R PACKAGES METHOD
# ==============================================================================
# Download Landsat data using R packages (no GEE required)
# ==============================================================================

cat("========================================\n")
cat("IMMEDIATE LANDSAT DATA DOWNLOAD\n")
cat("Using R Packages (No GEE Required)\n")
cat("========================================\n\n")

# Step 1: Load packages and configuration
cat("STEP 1: Loading packages and configuration...\n")
cat("---------------------------------------------\n")
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Load study area
aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("✓ Configuration loaded\n")
cat("✓ Study area loaded\n\n")

# Step 2: Try getSpatialData package
cat("STEP 2: Attempting download with getSpatialData...\n")
cat("--------------------------------------------------\n")

# Install devtools if needed
if (!require(devtools, quietly = TRUE)) {
  cat("Installing devtools...\n")
  install.packages("devtools", dependencies = TRUE)
  library(devtools)
}

# Try to install getSpatialData from GitHub
if (!require(getSpatialData, quietly = TRUE)) {
  cat("Installing getSpatialData from GitHub...\n")
  cat("This may take a few minutes...\n\n")
  
  tryCatch({
    devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE)
    library(getSpatialData)
    cat("✓ getSpatialData installed and loaded\n\n")
  }, error = function(e) {
    cat("✗ getSpatialData installation failed\n")
    cat("  Error:", e$message, "\n")
    cat("  This package may not be available for R 4.5\n")
    cat("  Proceeding with alternative method...\n\n")
  })
}

# Step 3: If getSpatialData works, use it
if (require(getSpatialData, quietly = TRUE)) {
  cat("STEP 3: Using getSpatialData to download...\n")
  cat("-------------------------------------------\n")
  
  cat("NOTE: This requires USGS EarthExplorer account.\n")
  cat("If you don't have one, create free account at:\n")
  cat("  https://earthexplorer.usgs.gov/\n\n")
  
  # Convert AOI to proper format for getSpatialData
  # getSpatialData needs SpatialPolygons, sfc_POLYGON, or matrix
  tryCatch({
    # Convert sf to sfc_POLYGON (which getSpatialData accepts)
    if (inherits(aoi, "sf")) {
      aoi_sfc <- st_geometry(aoi)
      set_aoi(aoi_sfc)
    } else if (inherits(aoi, "sfc")) {
      set_aoi(aoi)
    } else {
      # Convert to matrix (bounding box)
      bbox_matrix <- matrix(c(bbox[1], bbox[2], bbox[3], bbox[4]), 
                           nrow = 2, ncol = 2, 
                           dimnames = list(c("x", "y"), c("min", "max")))
      set_aoi(bbox_matrix)
    }
    cat("✓ Study area set\n")
    
    # Check if logged in to USGS
    cat("Checking USGS login status...\n")
    # Note: getSpatialData doesn't have a direct login check function
    # We'll try to search and see if login is needed
    
    # Search for Landsat 8 data
    cat("Searching for Landsat 8 data...\n")
    cat("Date range:", START_DATE, "to", END_DATE, "\n\n")
    
    records <- getLandsat_records(
      time_range = c(START_DATE, END_DATE),
      products = "LANDSAT_8_C1"
    )
    
    if (nrow(records) > 0) {
      cat("✓ Found", nrow(records), "Landsat scenes\n\n")
      
      # Limit to first 5 for initial download
      if (nrow(records) > 5) {
        cat("Limiting to first 5 scenes for initial download...\n")
        records <- records[1:5, ]
      }
      
      # Download
      cat("Downloading scenes...\n")
      cat("This may take a while depending on file sizes...\n\n")
      
      files <- getLandsat_data(
        records, 
        dir_out = LANDSAT_DIR,
        force = FALSE
      )
      
      cat("\n✓ Download complete!\n")
      cat("Files saved to:", LANDSAT_DIR, "\n\n")
      
      # List downloaded files
      downloaded_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", 
                                    full.names = TRUE, recursive = TRUE)
      cat("Downloaded files:", length(downloaded_files), "\n\n")
      
    } else {
      cat("✗ No Landsat scenes found for the specified criteria\n")
      cat("  Try adjusting date range or cloud cover threshold\n\n")
    }
    
  }, error = function(e) {
    cat("✗ Error using getSpatialData:", e$message, "\n\n")
    
    if (grepl("login|authentication|credentials", e$message, ignore.case = TRUE)) {
      cat("USGS LOGIN REQUIRED:\n")
      cat("  1. Create free account at: https://earthexplorer.usgs.gov/\n")
      cat("  2. Then login in R:\n")
      cat("     library(getSpatialData)\n")
      cat("     login_USGS('your_username')\n")
      cat("     # Enter password when prompted\n")
      cat("  3. Then run this script again\n\n")
    } else if (grepl("aoi|polygon|spatial", e$message, ignore.case = TRUE)) {
      cat("AOI format issue. Trying alternative format...\n")
      # Try with bounding box matrix
      tryCatch({
        bbox_matrix <- matrix(c(bbox[1], bbox[2], bbox[3], bbox[4]), 
                             nrow = 2, ncol = 2, 
                             dimnames = list(c("x", "y"), c("min", "max")))
        set_aoi(bbox_matrix)
        cat("✓ AOI set using bounding box matrix\n")
        
        # Try search again
        records <- getLandsat_records(
          time_range = c(START_DATE, END_DATE),
          products = "LANDSAT_8_C1"
        )
        
        if (nrow(records) > 0) {
          cat("✓ Found", nrow(records), "Landsat scenes\n\n")
          # Continue with download...
        }
      }, error = function(e2) {
        cat("✗ Still failed:", e2$message, "\n")
        cat("  Proceeding with manual download instructions...\n\n")
      })
    } else {
      cat("  Proceeding with manual download instructions...\n\n")
    }
  })
  
} else {
  # Step 4: Alternative - Direct instructions for manual download
  cat("STEP 3: getSpatialData not available - Using manual download guide\n")
  cat("-------------------------------------------------------------------\n\n")
  
  cat("Since automated R package download is not available,\n")
  cat("here are your coordinates for manual download:\n\n")
  
  cat("USGS EarthExplorer Search Parameters:\n")
  cat("  North:", round(bbox[4], 4), "\n")
  cat("  South:", round(bbox[2], 4), "\n")
  cat("  East:", round(bbox[3], 4), "\n")
  cat("  West:", round(bbox[1], 4), "\n")
  cat("  Date Range:", START_DATE, "to", END_DATE, "\n")
  cat("  Dataset: Landsat Collection 2 Level-2\n")
  cat("  Product: Surface Reflectance\n")
  cat("  Cloud Cover: <", MAX_CLOUD_COVER, "%\n\n")
  
  cat("Steps:\n")
  cat("  1. Visit: https://earthexplorer.usgs.gov/\n")
  cat("  2. Create free account (if needed)\n")
  cat("  3. Use 'Search Criteria' → 'Geographic' → 'Coordinates'\n")
  cat("  4. Enter coordinates above\n")
  cat("  5. Select 'Data Sets' → 'Landsat Collection 2 Level-2'\n")
  cat("  6. Click 'Results' and download selected scenes\n")
  cat("  7. Extract .tar.gz files\n")
  cat("  8. Copy .tif files to:", LANDSAT_DIR, "\n\n")
  
  cat("After placing files, verify with:\n")
  cat("  source('scripts/verify_downloaded_data.R')\n\n")
}

# Step 5: Verify downloaded data
cat("STEP 4: Verifying downloaded data...\n")
cat("-----------------------------------\n")

landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", 
                           full.names = TRUE, recursive = TRUE)

if (length(landsat_files) > 0) {
  cat("✓ Found", length(landsat_files), "Landsat files\n")
  cat("  Files are ready for processing!\n\n")
  
  cat("Next steps:\n")
  cat("  1. Run preprocessing:\n")
  cat("     source('R/05_preprocessing.R')\n")
  cat("     landsat <- preprocess_landsat(data_dir = '", LANDSAT_DIR, "', aoi = aoi)\n\n", sep = "")
  
  cat("  2. Or run complete workflow:\n")
  cat("     source('scripts/main_workflow.R')\n\n")
  
} else {
  cat("⚠ No Landsat files found in", LANDSAT_DIR, "\n")
  cat("  Please download files and place them in the directory above\n\n")
}

cat("========================================\n")
cat("DOWNLOAD PROCESS COMPLETE\n")
cat("========================================\n\n")

