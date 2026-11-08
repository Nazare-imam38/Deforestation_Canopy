# ==============================================================================
# GOOGLE EARTH ENGINE SETUP - COMPLETE GUIDE
# ==============================================================================
# This script sets up Google Earth Engine for Landsat data download
# ==============================================================================

cat("========================================\n")
cat("GOOGLE EARTH ENGINE SETUP\n")
cat("========================================\n\n")

# Load required packages
cat("STEP 1: Loading packages...\n")
cat("----------------------------\n")
source("R/00_setup_packages.R")

# Check if rgee is installed
if (!require(rgee, quietly = TRUE)) {
  cat("Installing rgee package...\n")
  install.packages("rgee", dependencies = TRUE)
  library(rgee)
}

# Check for geojsonio (required by sf_as_ee)
if (!require(geojsonio, quietly = TRUE)) {
  cat("Installing geojsonio package (required for GEE)...\n")
  install.packages("geojsonio", dependencies = TRUE)
  library(geojsonio)
}

# Load configuration
cat("\nSTEP 2: Loading configuration...\n")
cat("-------------------------------\n")
source("R/01_config.R")

# Initialize Google Earth Engine
cat("\nSTEP 3: Initializing Google Earth Engine...\n")
cat("-------------------------------------------\n")
cat("This will:\n")
cat("  1. Check if GEE is already initialized\n")
cat("  2. Prompt for Google account authentication (first time only)\n")
cat("  3. Set up GEE Python environment if needed\n\n")

tryCatch({
  # Check if already initialized AND authenticated
  ee_check()
  # Try to access GEE to verify authentication
  test <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
  cat("✓ Google Earth Engine is already initialized and authenticated!\n\n")
}, error = function(e) {
  # Check if it's just an authentication issue
  if (grepl("not initialized|ee-auth", e$message, ignore.case = TRUE)) {
    cat("GEE needs authentication. Initializing now...\n\n")
  } else {
    cat("Google Earth Engine not initialized. Starting setup...\n\n")
    
    # Check if earthengine-api is installed
    cat("Checking Python earthengine-api...\n")
    tryCatch({
      ee_check()
    }, error = function(check_err) {
      if (grepl("earthengine-api", check_err$message, ignore.case = TRUE)) {
        cat("earthengine-api not found. Installing...\n")
        cat("This may take a few minutes...\n\n")
        if (require(reticulate, quietly = TRUE)) {
          tryCatch({
            py_install("earthengine-api", pip = TRUE)
            cat("✓ Python environment set up\n\n")
          }, error = function(install_err) {
            cat("✗ Installation failed:", install_err$message, "\n")
            cat("  Please run: source('scripts/fix_gee_dependencies.R')\n\n")
            stop("GEE Python package installation required")
          })
        }
      }
    })
  }
  
  # Initialize with drive = TRUE for Google Drive export
  cat("Initializing GEE (this may take a moment)...\n")
  cat("You will be prompted to authenticate with your Google account.\n")
  cat("A browser window will open for authentication.\n\n")
  
  tryCatch({
    ee_Initialize(drive = TRUE)
    cat("✓ Google Earth Engine initialized and authenticated successfully!\n\n")
  }, error = function(e2) {
    cat("✗ Initialization failed:", e2$message, "\n\n")
    cat("Troubleshooting:\n")
    cat("  1. Make sure you have a Google account\n")
    cat("  2. Grant permissions when prompted\n")
    cat("  3. If browser doesn't open, check firewall settings\n")
    cat("  4. Try again: ee_Initialize(drive = TRUE)\n\n")
    stop("GEE initialization failed")
  })
})

# Test GEE connection
cat("STEP 4: Testing GEE connection...\n")
cat("---------------------------------\n")
tryCatch({
  # Test with a simple dataset
  test_image <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
  test_info <- test_image$getInfo()
  
  cat("✓ Connection successful!\n")
  cat("  Test image ID:", test_info$id, "\n")
  cat("  GEE is ready to use!\n\n")
}, error = function(e) {
  cat("✗ Connection test failed:", e$message, "\n")
  cat("  Please check your GEE setup\n\n")
})

# Load study area
cat("STEP 5: Preparing study area...\n")
cat("-------------------------------\n")
source("R/03_load_study_area.R")
aoi <- load_study_area()

cat("Study area loaded:\n")
bbox <- st_bbox(aoi)
cat("  Longitude:", round(bbox[1], 4), "to", round(bbox[3], 4), "\n")
cat("  Latitude:", round(bbox[2], 4), "to", round(bbox[4], 4), "\n")
area_km2 <- as.numeric(st_area(aoi)) / 1e6
cat("  Area:", round(area_km2, 2), "km²\n\n")

# Convert to Earth Engine format
cat("Converting study area to Earth Engine format...\n")
source("R/02_initialize_gee.R")
aoi_ee <- aoi_to_ee(aoi)
cat("✓ Study area ready for GEE!\n\n")

cat("========================================\n")
cat("GEE SETUP COMPLETE!\n")
cat("========================================\n\n")
cat("You can now download Landsat data using:\n")
cat("  source('scripts/download_landsat_gee.R')\n\n")

# Save aoi_ee for use in other scripts
assign("aoi_ee", aoi_ee, envir = .GlobalEnv)
cat("Study area (aoi_ee) is now available in your R session.\n\n")

