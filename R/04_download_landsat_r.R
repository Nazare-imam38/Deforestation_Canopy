# ==============================================================================
# DOWNLOAD LANDSAT DATA USING R PACKAGES
# ==============================================================================
# Alternative download methods using R libraries
# Works without Google Earth Engine registration
# ==============================================================================

source("R/01_config.R")

# Method 1: Using getSpatialData (if available)
download_landsat_getspatialdata <- function(aoi, start_date, end_date) {
  cat("METHOD 1: Using getSpatialData package...\n")
  cat("----------------------------------------\n")
  
  # Try to install from GitHub if not available
  if (!require(getSpatialData, quietly = TRUE)) {
    cat("Installing getSpatialData from GitHub...\n")
    if (!require(devtools, quietly = TRUE)) {
      install.packages("devtools")
      library(devtools)
    }
    tryCatch({
      devtools::install_github("16EAGLE/getSpatialData")
      library(getSpatialData)
    }, error = function(e) {
      cat("✗ getSpatialData installation failed:", e$message, "\n")
      cat("  Trying alternative methods...\n\n")
      return(NULL)
    })
  }
  
  if (require(getSpatialData, quietly = TRUE)) {
    cat("✓ getSpatialData loaded\n")
    
    # Login to USGS (requires account)
    cat("Note: USGS account required. If not logged in:\n")
    cat("  1. Create account at: https://earthexplorer.usgs.gov/\n")
    cat("  2. Run: login_USGS('your_username')\n\n")
    
    # Set AOI
    set_aoi(aoi)
    
    # Search for Landsat data
    cat("Searching for Landsat data...\n")
    records <- getLandsat_records(
      time_range = c(start_date, end_date),
      products = "LANDSAT_8_C1"  # Landsat 8 Collection 1
    )
    
    cat("Found", nrow(records), "records\n")
    
    if (nrow(records) > 0) {
      # Download records
      cat("Downloading records...\n")
      files <- getLandsat_data(records, dir_out = LANDSAT_DIR)
      return(files)
    }
  }
  
  return(NULL)
}

# Method 2: Using MODIStsp for MODIS (alternative data source)
download_modis_data <- function(aoi, start_date, end_date) {
  cat("METHOD 2: Using MODIS data (alternative)...\n")
  cat("--------------------------------------------\n")
  
  if (!require(MODIStsp, quietly = TRUE)) {
    cat("Installing MODIStsp...\n")
    install.packages("MODIStsp", dependencies = TRUE)
    library(MODIStsp)
  }
  
  cat("MODIS provides vegetation indices similar to Landsat.\n")
  cat("Products available: MOD13Q1 (NDVI), MOD16A2 (ET), etc.\n\n")
  
  # Get bounding box
  bbox <- st_bbox(aoi)
  
  # Configure MODIS download
  MODIStsp(
    gui = FALSE,
    out_folder = LANDSAT_DIR,
    selprod = "Vegetation_Indexes_16Days_1Km (M*D13Q1)",
    bandsel = "NDVI",
    user = "your_username",  # MODIS requires NASA account
    password = "your_password",
    start_date = start_date,
    end_date = end_date,
    bbox = c(bbox[1], bbox[2], bbox[3], bbox[4]),
    spatmeth = "bbox",
    out_projsel = "User Defined",
    output_proj = st_crs(aoi)$proj4string,
    resampling = "bilinear",
    delete_hdf = TRUE,
    download_server = "http"
  )
}

# Method 3: Direct download using USGS API (requires authentication)
download_landsat_usgs_api <- function(aoi, start_date, end_date) {
  cat("METHOD 3: Using USGS API directly...\n")
  cat("------------------------------------\n")
  
  # Get bounding box
  bbox <- st_bbox(aoi)
  
  # USGS EarthExplorer API endpoint
  # Note: This requires API key and authentication
  cat("USGS API requires:\n")
  cat("  1. API key from: https://earthexplorer.usgs.gov/inventory/documentation/datamart\n")
  cat("  2. Authentication token\n\n")
  
  cat("For now, use the web interface:\n")
  cat("  1. Visit: https://earthexplorer.usgs.gov/\n")
  cat("  2. Search with coordinates:\n")
  cat("     North:", bbox[4], "\n")
  cat("     South:", bbox[2], "\n")
  cat("     East:", bbox[3], "\n")
  cat("     West:", bbox[1], "\n")
  cat("  3. Download Landsat 8/9 Surface Reflectance\n")
  cat("  4. Place files in:", LANDSAT_DIR, "\n\n")
  
  return(NULL)
}

# Method 4: Download sample/test data
download_sample_landsat <- function() {
  cat("METHOD 4: Using sample/test Landsat data...\n")
  cat("---------------------------------------------\n")
  
  cat("For testing purposes, you can use sample Landsat data.\n")
  cat("This allows you to test the workflow while waiting for full data.\n\n")
  
  # Create a sample data directory
  sample_dir <- file.path(LANDSAT_DIR, "sample")
  dir.create(sample_dir, showWarnings = FALSE, recursive = TRUE)
  
  cat("Sample data sources:\n")
  cat("  1. USGS Sample Data: https://www.usgs.gov/landsat-missions/landsat-sample-data\n")
  cat("  2. Download a few test scenes\n")
  cat("  3. Place in:", sample_dir, "\n\n")
  
  return(sample_dir)
}

# Main download function - tries all methods
download_landsat_r_packages <- function(aoi = NULL, start_date = START_DATE, 
                                        end_date = END_DATE, method = "auto") {
  
  cat("========================================\n")
  cat("DOWNLOAD LANDSAT DATA USING R PACKAGES\n")
  cat("========================================\n\n")
  
  # Load study area if not provided
  if (is.null(aoi)) {
    source("R/03_load_study_area.R")
    aoi <- load_study_area()
  }
  
  cat("Study Area:\n")
  bbox <- st_bbox(aoi)
  cat("  Coordinates:", paste(round(bbox, 4), collapse = ", "), "\n")
  cat("  Date Range:", start_date, "to", end_date, "\n\n")
  
  # Try methods based on availability
  if (method == "auto" || method == "getspatialdata") {
    result <- download_landsat_getspatialdata(aoi, start_date, end_date)
    if (!is.null(result)) {
      return(result)
    }
  }
  
  if (method == "auto" || method == "modis") {
    cat("\nTrying MODIS as alternative...\n")
    download_modis_data(aoi, start_date, end_date)
  }
  
  # If all automated methods fail, provide manual instructions
  cat("\n========================================\n")
  cat("AUTOMATED DOWNLOAD NOT AVAILABLE\n")
  cat("========================================\n\n")
  cat("Recommended: Manual download from USGS EarthExplorer\n\n")
  
  download_landsat_usgs_api(aoi, start_date, end_date)
  
  cat("\nAfter downloading files manually, place them in:\n")
  cat("  ", LANDSAT_DIR, "\n\n")
  
  return(NULL)
}

cat("✓ Landsat download functions loaded!\n")
cat("\nUsage:\n")
cat("  source('R/03_load_study_area.R')\n")
cat("  aoi <- load_study_area()\n")
cat("  download_landsat_r_packages(aoi)\n\n")

