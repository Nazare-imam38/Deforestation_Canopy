# ==============================================================================
# GOOGLE EARTH ENGINE INITIALIZATION
# ==============================================================================
# This script initializes Google Earth Engine for data access
# Requires Google account authentication (first time only)
# ==============================================================================

# Load configuration
source("R/01_config.R")

# Load rgee package
if (!require(rgee)) {
  stop("Package 'rgee' is not installed. Please run R/00_setup_packages.R first.")
}

# Initialize Google Earth Engine
# This will prompt for authentication on first run
initialize_gee <- function() {
  cat("Initializing Google Earth Engine...\n")
  
  tryCatch({
    # Check if already initialized
    ee_check()
    cat("✓ Google Earth Engine is already initialized.\n")
    return(TRUE)
  }, error = function(e) {
    cat("Google Earth Engine not initialized. Starting initialization...\n")
    
    # Initialize with drive = TRUE to enable Google Drive export
    ee_Initialize(drive = TRUE)
    
    cat("✓ Google Earth Engine initialized successfully!\n")
    cat("  You can now access Landsat collections.\n\n")
    return(TRUE)
  })
}

# Test GEE connection
test_gee_connection <- function() {
  cat("Testing Google Earth Engine connection...\n")
  
  tryCatch({
    # Try to access a simple dataset
    test_image <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
    test_info <- test_image$getInfo()
    
    cat("✓ Connection successful!\n")
    cat("  Test image ID:", test_info$id, "\n")
    return(TRUE)
  }, error = function(e) {
    cat("✗ Connection failed:", e$message, "\n")
    return(FALSE)
  })
}

# Main execution
if (!interactive()) {
  initialize_gee()
  test_gee_connection()
}

cat("\nTo use in other scripts, run:\n")
cat("  source('R/02_initialize_gee.R')\n")
cat("  initialize_gee()\n\n")

